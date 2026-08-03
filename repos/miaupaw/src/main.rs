use anyhow::Result;
#[cfg(unix)]
use calloop::{
    EventLoop,
    timer::{TimeoutAction, Timer},
};
#[cfg(unix)]
use calloop_wayland_source::WaylandSource;
use core::capture;
use daemon::color_service::ColorService;
use core::terminal::{print_logo, log_info};
#[cfg(unix)]
use core::terminal::{log_error, log_warn};
use core::terminal::log_step;
use core::overlay::OverlayApp;
#[cfg(unix)]
use daemon::dbus_tray::DBusTray;
use daemon::scout::Scout;
use global_hotkey::GlobalHotKeyEvent;
#[cfg(unix)]
use std::time::Duration;
#[cfg(unix)]
use wayland_client::{Connection, globals::registry_queue_init};

pub mod cli;
pub mod connectors;
pub mod core;
pub mod daemon;
pub mod probe;

#[cfg(unix)]
use connectors::wayland::IEWaylandState;
pub use daemon::UserEvent;

use cli::{Mode, PickReq};

// CLI types, argument parsing, and help rendering live in `cli.rs`.
// Probe runners (--pixel / --pixels / --stdin / --pick finalization) live
// in `probe.rs`. This file keeps only what orchestrates the daemon: the
// per-platform event loops and `main()` itself.

/// Wayland daemon branch. Thin wrapper around ColorService that adds
/// only platform-specific orchestration: creating the Layer Shell overlay
/// and integrating with Calloop.
#[cfg(unix)]
struct DaemonApp {
    svc: ColorService,
    // RAII keep-alives; `None` in `--pick` one-shot (no tray icon, no
    // global-hotkey grab that would clash with a running daemon).
    _tray: Option<DBusTray>,
    _scout: Option<Scout>,
}

#[cfg(unix)]
impl DaemonApp {
    fn new(tray: DBusTray) -> Result<Self> {
        let svc = ColorService::new();
        let scout = Scout::new(&svc.config.system.hotkey)?;

        Ok(Self {
            svc,
            _tray: Some(tray),
            _scout: Some(scout),
        })
    }

    /// `--pick` one-shot: overlay-rendering ColorService only — no tray,
    /// no Scout (a one-shot must not steal the daemon's global hotkey).
    fn new_oneshot() -> Self {
        Self {
            svc: ColorService::new(),
            _tray: None,
            _scout: None,
        }
    }

    /// Activates eyedropper mode. Entry point for hotkeys and tray icon clicks.
    /// Synchronously hot-reloads config, fires KWin/Portal for raw-pixel capture,
    /// and raises the Wayland overlay.
    pub fn launch_overlay(
        &mut self,
        state: &mut IEWaylandState,
        qh: &wayland_client::QueueHandle<IEWaylandState>,
    ) {
        if state.overlay_app.is_some() {
            log_info("Overlay already active. Simulating LMB click.");
            state.simulate_click(qh);
            return;
        }

        log_info("Launching overlay...");
        let mut perf = self.svc.reload_config();

        // Pre-collect output metadata (output_state is !Send, must happen on this thread)
        let output_meta = state.collect_output_meta();

        let screencopy = match (&state.screencopy_manager, &state.shm) {
            (Some(manager), Some(shm)) => Some((&state.conn, manager, shm.wl_shm())),
            _ => None,
        };

        let canvas_res = capture::capture_all_outputs(
            &output_meta,
            screencopy,
            self.svc.dbus_conn.as_ref(),
        );

        if let Ok(canvas) = canvas_res {
            perf.log("Screen captured");

            let overlay = OverlayApp::new(
                canvas,
                self.svc.config.clone(),
                self.svc.cached_font_data.clone(),
                self.svc.hud_font_data.clone(),
                "COMPOSITOR: WAYLAND".to_string(),
                state.scale_factor,
            );

            state.launch_overlay(qh, overlay);
            log_step("Ready", "Overlay state initialized & Layer requested");
        } else {
            log_error("Failed to capture screen.");
        }
    }
}

/// Global context threaded through all Calloop callbacks.
/// Combines the Wayland dispatcher, daemon logic, and event queue
/// for lifecycle management (shutdown, channel handling).
#[cfg(unix)]
struct AppState {
    daemon: DaemonApp,
    wayland: IEWaylandState,
    qh: wayland_client::QueueHandle<IEWaylandState>,
    exit_requested: bool,
    /// Deferred About launch — gives menus time to close before screenshot
    about_requested_at: Option<std::time::Instant>,
    /// `Some` in `--pick` one-shot: overlay close relays + exits instead of
    /// the daemon's clipboard finalize.
    pick: Option<PickReq>,
}

// ─── Wayland Main Loop ──────────────────────────────────────────────────────

#[cfg(unix)]
fn run_wayland_daemon(pick: Option<PickReq>) -> Result<()> {
    let oneshot = pick.is_some();
    if !oneshot {
        print_logo();
        log_info("Wayland backend active");
        log_info("...");
        log_info("To trigger IE-R, bind system shortcuts to UNIX signals:");
        log_info("SIGUSR1 (Pick Color): killall -SIGUSR1 ie-r");
        log_info("SIGUSR2 (Open Menu):  killall -SIGUSR2 ie-r");
        log_info("... or pkill -SIGUSR1 ie-r");
        log_info("Hyprland example (add to hyprland.conf):");
        log_info("bind = SUPER SHIFT, P, exec, pkill -SIGUSR1 ie-r");
    }

    // Grab the Wayland socket and initialise the object registry.
    // This is the foundation without which the Layer Shell cannot be built.
    let conn = Connection::connect_to_env().expect("Failed to connect to Wayland");
    let (globals, mut event_queue) = registry_queue_init(&conn).expect("Failed to get registry");
    let qh = event_queue.handle();
    let mut wayland_state = IEWaylandState::new(conn.clone(), &globals, &qh);

    // `--pick` is one-shot: the overlay is launched immediately, before the
    // event loop has dispatched anything, so OutputState must be populated
    // up front (the daemon path gets this for free — its launch is deferred
    // to a signal long after dispatch began).
    if oneshot {
        for _ in 0..8 {
            event_queue.roundtrip(&mut wayland_state)?;
            let mut outs = wayland_state.output_state.outputs();
            let any = outs.next().is_some();
            let ready = wayland_state.output_state.outputs().all(|o| {
                wayland_state
                    .output_state
                    .info(&o)
                    .map(|i| i.logical_size.is_some() || i.modes.iter().any(|m| m.current))
                    .unwrap_or(false)
            });
            if any && ready {
                break;
            }
        }
    }

    // --- Signal Matrix (POSIX Kill Block) ---
    // Critical: we must intercept signals BEFORE Tokio spawns threads.
    // Without this, background workers inherit the old kill-mask
    // and the OS will simply terminate the process on -USR1.
    let signals = calloop::signals::Signals::new(&[
        calloop::signals::Signal::SIGUSR1,
        calloop::signals::Signal::SIGUSR2,
    ])?;

    // Tokio is needed solely to keep async DBus and zbus running under the hood.
    // We do not run our own code asynchronously, but let the crates breathe.
    let rt = tokio::runtime::Runtime::new()?;
    let _guard = rt.enter();

    // Calloop — Epoll at full power. We wait for OS events without burning CPU.
    let mut event_loop = EventLoop::<AppState>::try_new()?;
    let loop_handle = event_loop.handle();

    // Inject the Wayland queue into Epoll. Now any mouse movement
    // or click will wake our thread.
    let wayland_source = WaylandSource::new(conn.clone(), event_queue);
    loop_handle
        .insert_source(wayland_source, |_, queue, state: &mut AppState| {
            queue.dispatch_pending(&mut state.wayland)
        })
        .map_err(|e| anyhow::anyhow!("Wayland source error: {}", e))?;

    // Bridge between the SNI system tray (DBus) and our main loop.
    // The tray runs in its own thread and sends events (click/exit) here via a channel.
    let (tx, rx) = calloop::channel::channel();
    let sender = daemon::event_sender::EventSender::from_calloop(tx);
    let sender_for_signals = sender.clone();
    // `--pick` one-shot: no tray icon, no Scout. The tray-channel and
    // signals sources below stay wired but never fire — the process exits
    // on the first pick, well before any signal matters.
    let daemon = if oneshot {
        DaemonApp::new_oneshot()
    } else {
        DaemonApp::new(DBusTray::new(sender)?)?
    };

    loop_handle
        .insert_source(rx, |event, _, state: &mut AppState| {
            // Platform-independent events (config/history/template/HUD/homepage)
            // are handled by ColorService; only platform-specific ones come back.
            let calloop::channel::Event::Msg(event) = event else { return };
            let Some(event) = state.daemon.svc.handle_user_event(event) else { return };
            match event {
                UserEvent::LaunchOverlay(_coords) => {
                    // Wayland path doesn't currently need the specific coordinates since Wayland compositor manages pointers
                    state.daemon.launch_overlay(&mut state.wayland, &state.qh);
                }
                UserEvent::ShowAbout
                    if state.wayland.overlay_app.is_none() && state.wayland.about_surface.is_none()
                        && state.about_requested_at.is_none() =>
                {
                    state.about_requested_at = Some(std::time::Instant::now());
                }
                UserEvent::Quit => {
                    state.exit_requested = true;
                }
                _ => {}
            }
        })
        .map_err(|e| anyhow::anyhow!("Tray channel source error: {}", e))?;

    // Unix Signals (SIGUSR1 → overlay, SIGUSR2 → rofi menu)
    loop_handle
        .insert_source(
            signals,
            move |event: calloop::signals::Event, _, state: &mut AppState| {
                if event.signal() == calloop::signals::Signal::SIGUSR1 {
                    log_info("Received SIGUSR1. Launching overlay.");
                    state.daemon.launch_overlay(&mut state.wayland, &state.qh);
                } else if event.signal() == calloop::signals::Signal::SIGUSR2 {
                    log_info("Received SIGUSR2. Launching menu.");
                    let proxy = sender_for_signals.clone();
                    tokio::spawn(daemon::pipe_menu::show_menu(proxy));
                }
            },
        )
        .map_err(|e| anyhow::anyhow!("Signals source error: {}", e))?;

    // Daemon heartbeat: wake every ~50 ms to check global hotkeys (X11/Wayland-agnostic)
    // and confirm the overlay has closed cleanly so we can free buffers.
    let timer = Timer::immediate();
    loop_handle
        .insert_source(timer, |_, _, state: &mut AppState| {
            // Poll global hotkeys
            let mut hotkey_triggered = false;
            while let Ok(event) = GlobalHotKeyEvent::receiver().try_recv() {
                if event.state == global_hotkey::HotKeyState::Released {
                    hotkey_triggered = true;
                }
            }
            if hotkey_triggered {
                state.daemon.launch_overlay(&mut state.wayland, &state.qh);
            }

            if state.wayland.open_url {
                daemon::open_homepage();
                state.wayland.open_url = false;
            }

            // Deferred About launch: wait for menus to disappear before capturing background
            if let Some(t) = state.about_requested_at
                && t.elapsed() >= Duration::from_millis(150) {
                    state.about_requested_at = None;
                    if state.wayland.overlay_app.is_none() && state.wayland.about_surface.is_none() {
                        let hud_font = state.daemon.svc.hud_font_data.clone();
                        let dbus_conn = state.daemon.svc.dbus_conn.as_ref();
                        state.wayland.launch_about(&state.qh, hud_font, dbus_conn);
                    }
                }

            // --- Watchdog: single kick to bootstrap the render chain ---
            // Idle overlay (HUD off, no mouse) never calls render(), so the
            // watchdog inside render() never fires. We send ONE redraw when
            // the warning threshold is crossed; after that render() sets
            // needs_redraw=true itself and the frame callback keeps the loop alive.
            if let Some(ref app) = state.wayland.overlay_app {
                let timeout = app.config.system.auto_cancel;
                if timeout > 0 {
                    let elapsed = app.last_activity.elapsed().as_secs();
                    let warning_at = timeout.saturating_sub(core::overlay::WATCHDOG_WARNING_WINDOW_SECS);
                    if elapsed >= warning_at && !state.wayland.is_redraw_pending() {
                        state.wayland.request_redraw();
                        state.wayland.redraw(&state.qh);
                    }
                }
            }

            if state.wayland.exit {
                if let Some(ref mut o) = state.wayland.overlay_app {
                    let session = o.take_session();

                    if let Some(req) = state.pick.as_ref() {
                        // --pick one-shot: relay-redirect + exit. Never returns.
                        probe::finish_pick(&mut state.daemon.svc, session.colors, session.coords, session.phys_coords, req);
                    }
                    state.daemon.svc.finalize_overlay(&session.config, session.colors, session.coords);
                }

                state.wayland.close_overlay();
                state.wayland.exit = false; // Reset for next time
            }

            TimeoutAction::ToDuration(Duration::from_millis(
                state.daemon.svc.config.system.poll_interval_ms,
            ))
        })
        .map_err(|e| anyhow::anyhow!("Timer source error: {}", e))?;

    // Assemble the global state and enter the eternal OS-socket listening loop.
    let mut app_state = AppState {
        daemon,
        wayland: wayland_state,
        qh,
        exit_requested: false,
        about_requested_at: None,
        pick,
    };

    // `--pick` one-shot: launch the overlay now (no signal/tray to trigger
    // it). The loop then runs until the user clicks or cancels (Esc/RMB),
    // at which point the timer's exit branch relays + exits the process.
    if oneshot {
        let AppState { daemon, wayland, qh, .. } = &mut app_state;
        daemon.launch_overlay(wayland, qh);
    }

    let signal = event_loop.get_signal();

    event_loop.run(None, &mut app_state, |state| {
        let qh = state.qh.clone();
        state.wayland.flush_pending_enters(&qh);
        if state.exit_requested {
            signal.stop();
        }
    })?;

    Ok(())
}

// ─── X11 Main Loop ──────────────────────────────────────────────────────────

#[cfg(unix)]
fn run_x11_daemon(pick: Option<PickReq>) -> Result<()> {
    let svc = ColorService::new();

    // Tokio is required for DBusTray.
    let rt = tokio::runtime::Runtime::new()?;
    let _guard = rt.enter();

    connectors::x11::run_x11_daemon(svc, pick)
}

// ─── Windows Main Loop (stub) ───────────────────────────────────────────────

/// Windows daemon — hotkey + tray event loop.
///
/// Global hotkey and tray icon both send UserEvent through an mpsc channel.
/// The main loop polls hotkey events, tray events, and Win32 messages.
#[cfg(windows)]
fn run_windows_daemon(pick: Option<PickReq>, is_relaunch: bool) -> Result<()> {
    let oneshot = pick.is_some();

    // DPI awareness must be set before any window/capture calls.
    // Safe to call once; subsequent calls return E_ACCESSDENIED (ignored).
    unsafe {
        let _ = windows::Win32::UI::HiDpi::SetProcessDpiAwareness(
            windows::Win32::UI::HiDpi::PROCESS_PER_MONITOR_DPI_AWARE,
        );
    }

    if !oneshot {
        print_logo();
        log_info("Windows backend active");
    }

    let mut svc = ColorService::new();

    // --- One-shot fork (`ie-r --pick`) ---
    // Skip the whole tray/hotkey/message-pump scaffolding — just capture,
    // raise the overlay, finalize via probe::finish_pick (never returns)
    // on success, or exit 1 with a clear message on capture failure.
    if let Some(req) = pick {
        log_info("Pick mode (Windows) — launching overlay...");
        match capture::capture_all_outputs() {
            Ok(canvas) => {
                let overlay = OverlayApp::new(
                    canvas,
                    svc.config.clone(),
                    svc.cached_font_data.clone(),
                    svc.hud_font_data.clone(),
                    "COMPOSITOR: WINDOWS".to_string(),
                    1.0,
                );
                // No owner HWND on one-shot — overlay is a self-contained
                // top-level WS_POPUP, nothing else to clash with.
                let owner = windows::Win32::Foundation::HWND::default();
                match connectors::windows::run_overlay(overlay, owner) {
                    Ok(session) => {
                        // Never returns: relay-redirect + process::exit.
                        probe::finish_pick(&mut svc, session.colors, session.coords, session.phys_coords, &req);
                    }
                    Err(e) => {
                        eprintln!("error: overlay failed: {}", e);
                        std::process::exit(1);
                    }
                }
            }
            Err(e) => {
                eprintln!("error: capture failed: {}", e);
                std::process::exit(1);
            }
        }
    }

    let mut _scout = Scout::new(&svc.config.system.hotkey)?;

    // Show welcome balloon if it's the first run OR a relaunch (re-run triggered by user).
    // Config flag is consumed after the first run.
    let show_welcome = svc.config.system.welcome_balloon || is_relaunch;

    // Event channel: tray + IPC → main loop (same pattern as calloop on Linux)
    let (tx, rx) = std::sync::mpsc::channel::<daemon::UserEvent>();
    let sender = daemon::event_sender::EventSender::from_channel(tx);
    let tray = daemon::tray_win::WinTray::new(sender, show_welcome);
    let tray_hwnd = tray.get_hwnd();

    // If we showed the balloon because of the config flag, turn it off for next time.
    if svc.config.system.welcome_balloon {
        svc.config.system.welcome_balloon = false;
        svc.config.save();
    }

    log_info(&format!("Hotkey: {} (press to activate)", svc.config.system.hotkey));
    log_info("Waiting for hotkey...");

    // Message-pump loop: global-hotkey crate on Windows registers hotkeys on a
    // background thread, but some builds need the main thread to pump messages.
    // MsgWaitForMultipleObjectsEx avoids busy-spinning while keeping ~50ms latency.
    loop {
        // Pump Win32 messages (ensures WM_HOTKEY delivery if registered on this thread)
        unsafe {
            let mut msg = std::mem::zeroed::<windows::Win32::UI::WindowsAndMessaging::MSG>();
            while windows::Win32::UI::WindowsAndMessaging::PeekMessageW(
                &mut msg, None, 0, 0,
                windows::Win32::UI::WindowsAndMessaging::PM_REMOVE,
            ).as_bool() {
                let _ = windows::Win32::UI::WindowsAndMessaging::TranslateMessage(&msg);
                windows::Win32::UI::WindowsAndMessaging::DispatchMessageW(&msg);
            }
        }

        // Poll global hotkey events.
        // WM_HOTKEY on Windows is a single event (press only, no release),
        // so we trigger on Pressed — unlike Wayland/X11 which fires both.
        let mut triggered = false;
        while let Ok(event) = GlobalHotKeyEvent::receiver().try_recv() {
            if event.state == global_hotkey::HotKeyState::Pressed {
                triggered = true;
            }
        }

        // Poll tray / IPC events. Platform-independent ones are absorbed by
        // ColorService::handle_user_event; only platform-specific come back.
        while let Ok(event) = rx.try_recv() {
            let Some(event) = svc.handle_user_event(event) else { continue };
            match event {
                daemon::UserEvent::LaunchOverlay(_) => { triggered = true; }
                daemon::UserEvent::ShowAbout => {
                    daemon::about_win::show_about(svc.hud_font_data.clone());
                }
                daemon::UserEvent::Quit => {
                    log_info("Quit requested. Exiting.");
                    return Ok(());
                }
                _ => {}
            }
        }

        if triggered {
            log_info("Hotkey triggered. Launching overlay...");
            let prev_hotkey = svc.config.system.hotkey.clone();
            let mut perf = svc.reload_config();

            if svc.config.system.hotkey != prev_hotkey {
                _scout = Scout::new(&svc.config.system.hotkey).unwrap_or(_scout);
                log_step("Scout", &format!("Hotkey updated: {}", svc.config.system.hotkey));
            }

            match capture::capture_all_outputs() {
                Ok(canvas) => {
                    perf.log("Screen captured");

                    let overlay = OverlayApp::new(
                        canvas,
                        svc.config.clone(),
                        svc.cached_font_data.clone(),
                        svc.hud_font_data.clone(),
                        "COMPOSITOR: WINDOWS".to_string(),
                        1.0, // DPI handled by SetProcessDpiAwareness
                    );

                    match connectors::windows::run_overlay(overlay, tray_hwnd) {
                        Ok(session) => {
                            svc.finalize_overlay(&session.config, session.colors, session.coords);
                            log_step("Done", "Overlay closed");
                        }
                        Err(e) => log_step("Error", &format!("Overlay failed: {}", e)),
                    }
                }
                Err(e) => log_step("Error", &format!("Capture failed: {}", e)),
            }

            // Drain any hotkey events that accumulated while overlay was blocking
            while GlobalHotKeyEvent::receiver().try_recv().is_ok() {}

            log_info("Waiting for hotkey...");
        }

        // Wait for messages or 50ms timeout — avoids busy spin
        unsafe {
            let _ = windows::Win32::UI::WindowsAndMessaging::MsgWaitForMultipleObjectsEx(
                None, 50,
                windows::Win32::UI::WindowsAndMessaging::QS_ALLINPUT,
                windows::Win32::UI::WindowsAndMessaging::MSG_WAIT_FOR_MULTIPLE_OBJECTS_EX_FLAGS(0),
            );
        }
    }
}

// ─── Entry Point ─────────────────────────────────────────────────────────────

/// Checks for an existing instance via the hidden tray window.
/// If found, posts WM_CLOSE and waits for the window to disappear (up to 2 sec).
/// Returns true if an existing instance was found.
#[cfg(windows)]
fn check_and_kill_existing_instance_win() -> bool {
    use std::time::Duration;
    use windows::Win32::Foundation::*;
    use windows::Win32::UI::WindowsAndMessaging::*;

    unsafe {
        let hwnd = match FindWindowW(windows::core::w!("IERTray"), None) {
            Ok(h) if !h.is_invalid() => h,
            _ => return false,
        };

        log_info("Found existing instance. Asking it to quit politely...");
        let _ = PostMessageW(hwnd, WM_CLOSE, WPARAM(0), LPARAM(0));

        // Wait for the old tray window to disappear (up to 2 seconds)
        for _ in 0..20 {
            std::thread::sleep(Duration::from_millis(100));
            if FindWindowW(windows::core::w!("IERTray"), None).is_err() {
                log_info("Old instance successfully terminated. Taking over...");
                return true;
            }
        }
        crate::core::terminal::log_warn("Old instance didn't quit in time. Proceeding anyway.");
        true
    }
}

/// Checks via D-Bus whether another instance of the application is already running.
/// If it is, politely asks it to quit and waits for it to release resources.
#[cfg(unix)]
fn check_and_kill_existing_instance() {
    let rt = match tokio::runtime::Runtime::new() {
        Ok(rt) => rt,
        Err(_) => return,
    };

    rt.block_on(async {
        use std::time::Duration;

        let conn = match zbus::Connection::session().await {
            Ok(c) => c,
            Err(_) => return,
        };

        let proxy = match zbus::fdo::DBusProxy::new(&conn).await {
            Ok(p) => p,
            Err(_) => return,
        };

        // Check whether the D-Bus name we expect is already taken.
        let bus_name: zbus::names::WellKnownName = "org.kde.StatusNotifierItem.InstantEyedropper".try_into().unwrap();
        let bus_name_ref = zbus::names::BusName::WellKnown(bus_name.clone());

        if let Ok(has_owner) = proxy.name_has_owner(bus_name_ref.as_ref()).await
            && has_owner {
                log_info("Found existing instance. Asking it to quit politely...");

                // Send the Quit command via D-Bus.
                let _ = conn.call_method(
                    Some(bus_name.as_ref()),
                    "/StatusNotifierItem",
                    Some("org.kde.StatusNotifierItem"),
                    "Quit",
                    &(),
                ).await;

                // Wait for the old process to actually release the bus (up to 2 seconds).
                for _ in 0..20 {
                    tokio::time::sleep(Duration::from_millis(100)).await;
                    if let Ok(still_alive) = proxy.name_has_owner(bus_name_ref.as_ref()).await
                        && !still_alive {
                            log_info("Old instance successfully terminated. Taking over...");
                            return;
                        }
                }
                log_warn("Old instance didn't quit in time. Proceeding anyway, but resources might conflict.");
            }
    });
}

/// Entry point into the matrix.
/// Parse args → dispatch mode → launch platform event loop.
fn main() -> Result<()> {
    // Windows: enable ANSI escape sequences for BOTH stdout and stderr.
    // log_* writes to stderr; --help and probe values write to stdout.
    #[cfg(windows)]
    unsafe {
        use windows_sys::Win32::System::Console::*;
        for h in [STD_OUTPUT_HANDLE, STD_ERROR_HANDLE] {
            let handle = GetStdHandle(h);
            let mut mode = 0u32;
            GetConsoleMode(handle, &mut mode);
            let _ = SetConsoleMode(handle, mode | ENABLE_VIRTUAL_TERMINAL_PROCESSING);
        }
    }

    // Windows console warm-up: SGR reset + flush, both streams.
    // On layered consoles like ConEmu/Far the VT parser initialises its
    // palette state lazily on first escape — without this, the first few
    // coloured log lines render with a shifted palette (white → gray,
    // gray → black). Writing an explicit reset before any real output
    // pins the starting state.
    #[cfg(windows)]
    {
        use std::io::Write;
        eprint!("\x1b[0m");
        print!("\x1b[0m");
        let _ = std::io::stderr().flush();
        let _ = std::io::stdout().flush();
    }

    // 0. Parse arguments before any heavy initialization.
    // Arg/usage errors exit 2 (POSIX-ish: 2 = invalid invocation).
    let (mode, verbose, config_override) = match cli::parse_args() {
        Ok(m) => m,
        Err(e) => {
            eprintln!("error: {e}");
            std::process::exit(2);
        }
    };

    // 0.1. --config PATH: validate file exists & is readable, then install
    // it as the single source of truth for every subsequent Config::load /
    // get_config_path call (initial load, hot-reload, save). Fail fast on
    // typos — unlike the default location, a missing override path must
    // never silently seed a new file (that's hostile to user intent).
    if let Some(path) = config_override {
        if let Err(e) = core::config::validate_override(&path) {
            eprintln!("error: --config {e}");
            std::process::exit(2);
        }
        core::config::set_config_override(path);
    }

    // Verbosity (Variant A): daemon → all logs (long service, ops want them);
    // non-daemon CLI → silence INFO-tier by default; `-v`/`--verbose` overrides
    // either way. ERROR+WARN always reach stderr. See cli-roadmap-waves.md W1.
    {
        use core::terminal::{set_verbosity, Verbosity};
        let v = if verbose {
            Verbosity::Verbose
        } else {
            match mode {
                Mode::Daemon => Verbosity::Verbose,
                #[cfg(windows)]
                Mode::CaptureTest => Verbosity::Verbose,
                _ => Verbosity::Normal,
            }
        };
        set_verbosity(v);
    }

    // `--pick` falls through to the platform dispatch (it reuses the daemon
    // runner in one-shot mode), carrying its relay request here.
    #[cfg_attr(windows, allow(unused_assignments, unused_mut))]
    let mut pick_req: Option<PickReq> = None;

    // --help and --version fire instantly, no side effects.
    match mode {
        Mode::Help => {
            cli::print_help();
            return Ok(());
        }
        Mode::Version => {
            println!("ie-r {}", env!("CARGO_PKG_VERSION"));
            return Ok(());
        }
        Mode::Pixel { coords, format, float_precision, relays, average, phys } => {
            return probe::run_pixels(coords, format, float_precision, relays, average, phys);
        }
        Mode::Stdin { format, float_precision, relays, realtime, with_coords, average, phys } => {
            return probe::run_stdin(format, float_precision, relays, realtime, with_coords, average, phys);
        }
        Mode::History { format, float_precision, relays, limit } => {
            return probe::run_history(format, float_precision, relays, limit);
        }
        Mode::Monitors { relays } => {
            return probe::run_monitors(relays);
        }
        Mode::Pick { format, float_precision, relays, with_coords, average, phys } => {
            // Stash --average for the overlay path: process-wide static read
            // by OverlayApp init when overriding magnifier.aim_size.
            if let Some(avg) = average {
                core::config::set_pick_average_override(avg);
            }
            pick_req = Some(PickReq { format, float_precision, relays, with_coords, average, phys });
        }
        #[cfg(windows)]
        Mode::CaptureTest => {
            print_logo();
            log_info("Capture test mode");
            let canvas = capture::capture_all_outputs()?;
            let tile = canvas.active();
            let w = tile.capture.width;
            let h = tile.capture.height;
            let rgba: Vec<u8> = tile.capture.xrgb_buffer.iter().flat_map(|&px| {
                [((px >> 16) & 0xFF) as u8, ((px >> 8) & 0xFF) as u8, (px & 0xFF) as u8, 255u8]
            }).collect();
            let path = "ie-r-capture-test.png";
            image::save_buffer(path, &rgba, w, h, image::ColorType::Rgba8)?;
            log_step("Test", &format!("Saved {}x{} → {}", w, h, path));
            return Ok(());
        }
        Mode::Daemon => {}
    }

    // ── Daemon initialization ────────────────────────────────────────────────

    // 0. Display-presence guard. The overlay (daemon mode + `--pick` one-shot)
    // needs a graphical session — either Wayland socket or X11 server. Without
    // it, winit's X11 fallback drops into libX11 with a null display ptr and
    // segfaults in C land. Probe modes never reach this point (they
    // early-return above and work over D-Bus portal, which doesn't need a
    // local display — see `ie-r --pixel` working through SSH).
    #[cfg(unix)]
    {
        let has_wayland = std::env::var_os("WAYLAND_DISPLAY").is_some();
        let has_x11 = std::env::var_os("DISPLAY").is_some();
        if !has_wayland && !has_x11 {
            eprintln!("error: no display available (WAYLAND_DISPLAY and DISPLAY both unset)");
            eprintln!("help:  the overlay needs a graphical session.");
            eprintln!("       · for SSH workflows, use probe modes — `ie-r --pixel X,Y`,");
            eprintln!("         `--stdin`, `--history`, etc. all work via the D-Bus portal");
            eprintln!("         and don't need a local display.");
            eprintln!("       · for SSH + daemon, forward X11 with `ssh -X`.");
            std::process::exit(1);
        }
    }

    // 1. Announce our correct name to the OS so killall -SIGUSR1 ie-r works
    // even through layers of wrappers and loaders.
    #[cfg(unix)]
    {
        let ret = unsafe { libc::prctl(libc::PR_SET_NAME, c"ie-r".as_ptr()) };
        if ret != 0 {
            log_warn("prctl(PR_SET_NAME) failed — killall -SIGUSR1 ie-r may not work");
        }
    }

    // 2. Politely ask the old process to quit.
    // EXCEPT `--pick`: a one-shot must NOT kill a running tray daemon — it
    // just raises its own overlay alongside it. (Overlay/screencopy
    // contention between the two is the deferred IPC-niche concern.)
    #[cfg(unix)]
    if pick_req.is_none() {
        check_and_kill_existing_instance();
    }

    // 2. Politely ask the old process to quit (Windows).
    // FindWindowW("IERTray") → PostMessageW(WM_CLOSE) → wait for window to disappear.
    #[cfg(windows)]
    let is_relaunch = check_and_kill_existing_instance_win();

    // 3. Platform dispatch
    #[cfg(unix)]
    {
        // Attempt to connect to Wayland. If $WAYLAND_DISPLAY is empty or
        // the compositor does not respond, take the X11 path.
        match Connection::connect_to_env() {
            Ok(_conn) => {
                // conn is dropped here — run_wayland_daemon will create its own.
                drop(_conn);
                run_wayland_daemon(pick_req)
            }
            Err(e) => {
                log_info(&format!("Wayland connection failed ({}). Falling back to X11/Winit.", e));
                run_x11_daemon(pick_req)
            }
        }
    }

    #[cfg(windows)]
    {
        run_windows_daemon(pick_req, is_relaunch)
    }
}

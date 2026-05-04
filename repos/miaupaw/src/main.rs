use anyhow::Result;
#[cfg(unix)]
use calloop::{
    EventLoop,
    timer::{TimeoutAction, Timer},
};
#[cfg(unix)]
use calloop_wayland_source::WaylandSource;
use core::capture;
#[cfg(unix)]
use core::capture::OutputMeta;
use core::color_service::ColorService;
#[cfg(unix)]
use core::config::Config;
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

pub mod connectors;
pub mod core;
pub mod daemon;

#[cfg(unix)]
use connectors::wayland::IEWaylandState;
pub use daemon::UserEvent;

/// Wayland daemon branch. Thin wrapper around ColorService that adds
/// only platform-specific orchestration: creating the Layer Shell overlay
/// and integrating with Calloop.
#[cfg(unix)]
struct DaemonApp {
    svc: ColorService,
    _tray: DBusTray,
    _scout: Scout,
}

#[cfg(unix)]
impl DaemonApp {
    fn new(tray: DBusTray) -> Result<Self> {
        let svc = ColorService::new();
        let scout = Scout::new(&svc.config.system.hotkey)?;

        Ok(Self {
            svc,
            _tray: tray,
            _scout: scout,
        })
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
        let output_meta: Vec<_> = state.output_state.outputs().map(|o| {
            let info = state.output_state.info(&o);
            let name = info.as_ref()
                .and_then(|i| i.name.clone())
                .unwrap_or_default();
            let logical_pos = info.as_ref()
                .and_then(|i| i.logical_position)
                .or_else(|| info.as_ref().map(|i| i.location))
                .unwrap_or((0, 0));
            let logical_w = info.as_ref()
                .and_then(|i| i.logical_size)
                .map(|s| s.0)
                .unwrap_or(0);
            let logical_h = info.as_ref()
                .and_then(|i| i.logical_size)
                .map(|s| s.1)
                .unwrap_or(0);
            let transform = info.as_ref()
                .map(|i| i.transform)
                .unwrap_or(wayland_client::protocol::wl_output::Transform::Normal);
            OutputMeta { output: o, name, logical_pos, logical_w, logical_h, transform }
        }).collect();

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
}

// ─── Wayland Main Loop ──────────────────────────────────────────────────────

#[cfg(unix)]
fn run_wayland_daemon() -> Result<()> {
    print_logo();
    log_info("Wayland backend active");
    log_info("...");
    log_info("To trigger IE-R, bind system shortcuts to UNIX signals:");
    log_info("SIGUSR1 (Pick Color): killall -SIGUSR1 ie-r");
    log_info("SIGUSR2 (Open Menu):  killall -SIGUSR2 ie-r");
    log_info("... or pkill -SIGUSR1 ie-r");
    log_info("Hyprland example (add to hyprland.conf):");
    log_info("bind = SUPER SHIFT, P, exec, pkill -SIGUSR1 ie-r");

    // Grab the Wayland socket and initialise the object registry.
    // This is the foundation without which the Layer Shell cannot be built.
    let conn = Connection::connect_to_env().expect("Failed to connect to Wayland");
    let (globals, event_queue) = registry_queue_init(&conn).expect("Failed to get registry");
    let qh = event_queue.handle();
    let wayland_state = IEWaylandState::new(conn.clone(), &globals, &qh);

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
    let tray = DBusTray::new(sender)?;
    let daemon = DaemonApp::new(tray)?;

    loop_handle
        .insert_source(rx, |event, _, state: &mut AppState| match event {
            calloop::channel::Event::Msg(UserEvent::LaunchOverlay(_coords)) => {
                // Wayland path doesn't currently need the specific coordinates since Wayland compositor manages pointers
                state.daemon.launch_overlay(&mut state.wayland, &state.qh);
            }
            calloop::channel::Event::Msg(UserEvent::EditConfig) => {
                let config_path = Config::get_config_path();
                log_info(&format!("Opening config in editor: {:?}", config_path));
                let _ = open::that(config_path);
            }
            calloop::channel::Event::Msg(UserEvent::CopyFromHistory(hex)) => {
                let s = hex.trim_start_matches('#');
                if let Ok(val) = u32::from_str_radix(s, 16) {
                    let r = ((val >> 16) & 0xFF) as u8;
                    let g = ((val >> 8) & 0xFF) as u8;
                    let b = (val & 0xFF) as u8;
                    state.daemon.svc.copy_color(&[image::Rgba([r, g, b, 255])]);
                }
            }
            calloop::channel::Event::Msg(UserEvent::SelectTemplate(key)) => {
                log_step("Menu", &format!("Template selected: {}", key));
                state.daemon.svc.config.templates.selected = key.clone();
                state.daemon.svc.config.save();
                daemon::dbus_menu::DBusMenu::notify_template_changed(&key);
            }
            calloop::channel::Event::Msg(UserEvent::ShowAbout)
                if state.wayland.overlay_app.is_none() && state.wayland.about_surface.is_none()
                    && state.about_requested_at.is_none() =>
            {
                state.about_requested_at = Some(std::time::Instant::now());
            }
            calloop::channel::Event::Msg(UserEvent::OpenHomepage) => {
                daemon::open_homepage();
            }
            calloop::channel::Event::Msg(UserEvent::Quit) => {
                state.exit_requested = true;
            }
            calloop::channel::Event::Msg(UserEvent::ToggleHUD) => {
                state.daemon.svc.config.hud.show = !state.daemon.svc.config.hud.show;
                state.daemon.svc.config.save();
                crate::daemon::dbus_menu::DBusMenu::notify_hud_changed(
                    state.daemon.svc.config.hud.show,
                );
            }
            _ => {}
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
                    tokio::spawn(daemon::rofi_menu::show_menu(proxy));
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
                    let warning_at = timeout.saturating_sub(10);
                    if elapsed >= warning_at && !state.wayland.is_redraw_pending() {
                        state.wayland.request_redraw();
                        state.wayland.redraw(&state.qh);
                    }
                }
            }

            if state.wayland.exit {
                if let Some(ref mut o) = state.wayland.overlay_app {
                    let color_deck = o.take_color_deck();
                    let overlay_config = o.config.clone();

                    state.daemon.svc.finalize_overlay(&overlay_config, color_deck);
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
    };

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
fn run_x11_daemon() -> Result<()> {
    let svc = ColorService::new();

    // Tokio is required for DBusTray.
    let rt = tokio::runtime::Runtime::new()?;
    let _guard = rt.enter();

    connectors::x11::run_x11_daemon(svc)
}

// ─── Windows Main Loop (stub) ───────────────────────────────────────────────

/// Windows daemon — hotkey + tray event loop.
///
/// Global hotkey and tray icon both send UserEvent through an mpsc channel.
/// The main loop polls hotkey events, tray events, and Win32 messages.
#[cfg(windows)]
fn run_windows_daemon(is_relaunch: bool) -> Result<()> {
    // DPI awareness must be set before any window/capture calls.
    // Safe to call once; subsequent calls return E_ACCESSDENIED (ignored).
    unsafe {
        let _ = windows::Win32::UI::HiDpi::SetProcessDpiAwareness(
            windows::Win32::UI::HiDpi::PROCESS_PER_MONITOR_DPI_AWARE,
        );
    }

    print_logo();
    log_info("Windows backend active");

    let mut svc = ColorService::new();
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

        // Poll tray / IPC events
        while let Ok(event) = rx.try_recv() {
            match event {
                daemon::UserEvent::LaunchOverlay(_) => { triggered = true; }
                daemon::UserEvent::EditConfig => {
                    let config_path = crate::core::config::Config::get_config_path();
                    log_info(&format!("Opening config: {:?}", config_path));
                    let _ = open::that(config_path);
                }
                daemon::UserEvent::SelectTemplate(key) => {
                    log_step("Menu", &format!("Template: {}", key));
                    svc.config.templates.selected = key;
                    svc.config.save();
                }
                daemon::UserEvent::ToggleHUD => {
                    svc.config.hud.show = !svc.config.hud.show;
                    svc.config.save();
                    log_step("Menu", &format!("HUD: {}", if svc.config.hud.show { "on" } else { "off" }));
                }
                daemon::UserEvent::OpenHomepage => {
                    daemon::open_homepage();
                }
                daemon::UserEvent::CopyFromHistory(hex) => {
                    let s = hex.trim_start_matches('#');
                    if let Ok(val) = u32::from_str_radix(s, 16) {
                        let r = ((val >> 16) & 0xFF) as u8;
                        let g = ((val >> 8) & 0xFF) as u8;
                        let b = (val & 0xFF) as u8;
                        svc.copy_color(&[image::Rgba([r, g, b, 255])]);
                    }
                }
                daemon::UserEvent::ShowAbout => {
                    daemon::about_win::show_about(svc.hud_font_data.clone());
                }
                daemon::UserEvent::Quit => {
                    log_info("Quit requested. Exiting.");
                    return Ok(());
                }
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
                        Ok(result) => {
                            svc.finalize_overlay(&result.config, result.color_deck);
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
/// Wayland detected → Layer Shell + Calloop path.
/// No Wayland → fallback to the proven Winit + Softbuffer architecture.
fn main() -> Result<()> {
    // 0. Announce our correct name to the OS so killall -SIGUSR1 ie-r works
    // even through layers of wrappers and loaders.
    #[cfg(unix)]
    {
        let ret = unsafe { libc::prctl(libc::PR_SET_NAME, c"ie-r".as_ptr()) };
        if ret != 0 {
            log_warn("prctl(PR_SET_NAME) failed — killall -SIGUSR1 ie-r may not work");
        }
    }

    // Windows: enable ANSI escape sequences in console
    #[cfg(windows)]
    unsafe {
        use windows_sys::Win32::System::Console::*;
        let handle = GetStdHandle(STD_OUTPUT_HANDLE);
        let mut mode = 0u32;
        GetConsoleMode(handle, &mut mode);
        let _ = SetConsoleMode(handle, mode | ENABLE_VIRTUAL_TERMINAL_PROCESSING);
    }

    // 1. Politely ask the old process to quit.
    #[cfg(unix)]
    check_and_kill_existing_instance();

    // 1. Politely ask the old process to quit (Windows).
    // FindWindowW("IERTray") → PostMessageW(WM_CLOSE) → wait for window to disappear.
    #[cfg(windows)]
    let is_relaunch = check_and_kill_existing_instance_win();

    // 1.5. --capture-test: capture → PNG → exit (Phase 1 smoke test)
    #[cfg(windows)]
    if std::env::args().any(|a| a == "--capture-test") {
        use core::capture;
        use core::terminal::log_step;
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

    // 2. Platform dispatch
    #[cfg(unix)]
    {
        // Attempt to connect to Wayland. If $WAYLAND_DISPLAY is empty or
        // the compositor does not respond, take the X11 path.
        match Connection::connect_to_env() {
            Ok(_conn) => {
                // conn is dropped here — run_wayland_daemon will create its own.
                drop(_conn);
                run_wayland_daemon()
            }
            Err(e) => {
                log_info(&format!("Wayland connection failed ({}). Falling back to X11/Winit.", e));
                run_x11_daemon()
            }
        }
    }

    #[cfg(windows)]
    {
        run_windows_daemon(is_relaunch)
    }
}

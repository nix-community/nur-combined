/// X11/Winit Connector
/// Full-featured driver for the X11 (XWayland) environment.
/// Resurrects the original architecture from commit 4e0359f:
///   - One EventLoop<UserEvent> per process (critical for Winit)
///   - DaemonApp implements ApplicationHandler<UserEvent>
///   - OverlayApp creates/destroys the window via resumed()/window_event()
///   - KWin skip-taskbar script via D-Bus
///   - Buffer recycling between launches
///
/// Launch: WAYLAND_DISPLAY="" cargo run
use crate::core::capture;
use crate::core::color_service::ColorService;
use crate::core::overlay::{OverlayApp, UserAction};
use crate::daemon::UserEvent;
use crate::daemon::dbus_tray::DBusTray;
use crate::daemon::event_sender::EventSender;
use crate::daemon::scout::Scout;
use crate::core::terminal::{log_step, log_info, log_warn, log_error};
// ─── X11 Overlay Window ──────────────────────────────────────────────────────

use anyhow::Result;
use global_hotkey::GlobalHotKeyEvent;
use softbuffer::{Context, Surface};
use std::num::NonZeroU32;
use std::sync::Arc;
use std::time::{Duration, Instant};
use winit::application::ApplicationHandler;
use winit::event::{ElementState, MouseScrollDelta, WindowEvent};
use winit::event_loop::{ActiveEventLoop, ControlFlow, EventLoop};
use winit::window::{CursorIcon, Window, WindowId};
// ─── X11 Overlay Window ──────────────────────────────────────────────────────
// Manages the window lifecycle, softbuffer surface,
// and delegates rendering to core::OverlayApp.

struct X11OverlayWindow {
    app: OverlayApp,
    window: Option<Arc<Window>>,
    surface: Option<Surface<Arc<Window>, Arc<Window>>>,
    mouse_pos: Option<winit::dpi::PhysicalPosition<f64>>,
    ignored_stale_pos: Option<winit::dpi::PhysicalPosition<f64>>,
    scale_factor: f64,
    shift_pressed: bool,
    ctrl_pressed: bool,
    alt_pressed: bool,
    /// Monitor rects in canvas-local (= root X11) coordinates: (x, y, w, h).
    /// Used to clamp magnifier to the current monitor, same as Win32 connector.
    monitors: Vec<(i32, i32, i32, i32)>,
    /// Previous frame's dirty rects — swapped with app.dirty_rects around render()
    /// so the render loop can restore background only in changed regions (fast path).
    prev_dirty_rects: std::collections::VecDeque<(i32, i32, usize, usize)>,
}

impl X11OverlayWindow {
    fn new(app: OverlayApp) -> Self {
        Self {
            app,
            window: None,
            surface: None,
            mouse_pos: None,
            ignored_stale_pos: None,
            scale_factor: 1.0,
            shift_pressed: false,
            ctrl_pressed: false,
            alt_pressed: false,
            monitors: Vec::new(),
            prev_dirty_rects: std::collections::VecDeque::with_capacity(12),
        }
    }

    /// Creates a fullscreen borderless window on top of everything.
    /// `dbus_conn` is needed to query the real cursor position from KWin (XWayland workaround).
    fn create_window(
        &mut self,
        event_loop: &ActiveEventLoop,
        coords: Option<(i32, i32)>,
        dbus_conn: Option<&zbus::blocking::Connection>,
        root_size: Option<(u32, u32)>,
    ) {
        if self.window.is_some() {
            return;
        }

        let mut win_attr = Window::default_attributes()
            .with_title("Instant Eyedropper Reborn")
            .with_decorations(false)
            .with_position(winit::dpi::PhysicalPosition::new(0, 0))
            .with_visible(false); // Start invisible to avoid taskbar flicker

        #[cfg(target_os = "linux")]
        {
            use winit::platform::wayland::WindowAttributesExtWayland;
            use winit::platform::x11::{WindowAttributesExtX11, WindowType};

            // override_redirect = true: the window bypasses the window manager entirely.
            // This is critical for the overlay — KWin will not reserve space for the taskbar
            // and the window will occupy all 2560x1440 pixels, including the panel area.
            win_attr = WindowAttributesExtX11::with_override_redirect(win_attr, true);
            win_attr =
                WindowAttributesExtX11::with_x11_window_type(win_attr, vec![WindowType::Utility]);
            win_attr = WindowAttributesExtX11::with_name(win_attr, "ie-r", "Instant Eyedropper");
            win_attr =
                WindowAttributesExtWayland::with_name(win_attr, "ie-r", "Instant Eyedropper");
        }

        let window = Arc::new(event_loop.create_window(win_attr).unwrap());
        window.set_cursor(CursorIcon::Crosshair);

        // Explicitly set the window size.
        // Priority: root_size from XCB (giant window = full virtual desktop),
        // fallback — current Winit monitor (single-monitor mode).
        if let Some((rw, rh)) = root_size {
            let _ = window.request_inner_size(winit::dpi::PhysicalSize::new(rw, rh));
        } else if let Some(monitor) = window.current_monitor() {
            let _ = window.request_inner_size(monitor.size());
        }

        // Show the window and immediately request focus.
        // focus_window() is critical: without it KWin treats a window appearing
        // from a background process (the daemon) as "focus stealing" and shows
        // a notification bell instead of simply granting focus.
        window.set_visible(true);
        window.focus_window();

        let context = Context::new(window.clone()).unwrap();
        let surface = Surface::new(&context, window.clone()).unwrap();

        // ======================================================================
        // XWAYLAND STALE CURSOR — KNOWN LIMITATION
        // ======================================================================
        // ROOT CAUSE:
        //   When there are no mapped X11 windows, XWayland "goes to sleep" and
        //   stops synchronising the cursor position with the X11 server.
        //   XQueryPointer returns frozen coordinates — wherever the cursor was
        //   when the last X11 window was closed (or (0,0) on first launch).
        // WHY IT CANNOT BE FULLY FIXED:
        //   KWin in Plasma 5 had a D-Bus method `cursorPos()`, but Plasma 6
        //   removed it. No other API exists for obtaining the real cursor position
        //   from an X11 client under XWayland without opening a separate
        //   Wayland connection (overkill).
        // PRIORITY CASCADE (best to worst):
        //   1. D-Bus SNI coords — tray click. Coordinates are exact (100%).
        //   2. KWin cursorPos() — kept in case KDE reinstates it in the future.
        //      Currently returns None silently and we fall through.
        //   3. XQueryPointer — accurate on native X11, stale under XWayland.
        //   4. Screen center — last resort if everything else fails.
        // BEHAVIOUR ON HOTKEY LAUNCH UNDER XWAYLAND:
        //   The magnifier appears at the stale position (where the cursor was
        //   at last close), but instantly "snaps" to the real position on the
        //   first mouse movement (even 1 pixel). Better than an invisible eyedropper.
        // SPURIOUS EVENT FILTER:
        //   On window mapping, Winit sends a CursorMoved carrying those same
        //   stale coordinates. `ignored_stale_pos` discards that event so we
        //   do not "confirm" the false position.
        //   A real CursorMoved (different coordinates) clears the lock.
        // ======================================================================
        let x11_stale_pos = Self::query_x11_pointer();

        let initial_pos = if let Some((x, y)) = coords {
            // Priority 1: explicit coordinates from the tray click (100% accurate).
            log_step("X11", &format!("Using explicit coords from DBus tray: {}, {}", x, y));
            winit::dpi::PhysicalPosition::new(x as f64, y as f64)
        } else if let Some(pos) = dbus_conn.and_then(Self::query_compositor_cursor) {
            // Priority 2: KWin D-Bus (broken in Plasma 6, kept for the future).
            log_step("X11", &format!("Using KWin compositor cursor: {}, {}", pos.x, pos.y));
            pos
        } else if let Some(pos) = x11_stale_pos {
            // Priority 3: XQueryPointer (stale under XWayland, accurate on native X11).
            log_step("X11", &format!("Using XQueryPointer: {}, {} (stale under XWayland)", pos.x, pos.y));
            pos
        } else {
            // Priority 4: screen center.
            log_step("X11", "No cursor source available, using screen center");
            let (w, h) = window.current_monitor()
                .map(|m| (m.size().width as f64, m.size().height as f64))
                .unwrap_or((1920.0, 1080.0));
            winit::dpi::PhysicalPosition::new(w / 2.0, h / 2.0)
        };

        // XGrabPointer forces XWayland to bind the pointer to our window.
        // After this, Winit will start receiving real CursorMoved events.
        let _ = window.set_cursor_grab(winit::window::CursorGrabMode::Confined);

        // Collect monitor rects in canvas-local (= root X11) coords.
        // On X11 the root window is at (0,0), so XRandR positions are directly
        // canvas-local — no virtual-screen-origin offset needed (unlike Win32).
        self.monitors = event_loop.available_monitors()
            .map(|m| {
                let pos = m.position();
                let sz = m.size();
                (pos.x, pos.y, sz.width as i32, sz.height as i32)
            })
            .collect();

        self.window = Some(window);
        self.surface = Some(surface);
        self.ignored_stale_pos = x11_stale_pos;
        // Always show the magnifier immediately. Under XWayland it may appear
        // at a stale position, but that is better than an invisible eyedropper.
        self.mouse_pos = Some(initial_pos);
        self.app.update_physical_mouse(initial_pos.x, initial_pos.y);

        // Set initial monitor_rect so magnifier clamps correctly from the first frame.
        self.app.monitor_rect = Self::monitor_rect_at(&self.monitors, initial_pos.x as i32, initial_pos.y as i32);
    }

    /// XQueryPointer: accurate coordinates on native X11, stale under XWayland.
    fn query_x11_pointer() -> Option<winit::dpi::PhysicalPosition<f64>> {
        use x11rb::connection::Connection;
        use x11rb::protocol::xproto::ConnectionExt;

        let (conn, screen_num) = x11rb::connect(None).ok()?;
        let screen = &conn.setup().roots[screen_num];
        let reply = conn.query_pointer(screen.root).ok()?.reply().ok()?;

        Some(winit::dpi::PhysicalPosition::new(
            reply.root_x as f64,
            reply.root_y as f64,
        ))
    }

    /// Queries the cursor position from KWin via D-Bus (`org.kde.KWin.cursorPos`).
    ///
    /// STATUS: DOES NOT WORK in KDE Plasma 6 — the method was removed from the D-Bus interface.
    /// Kept in the cascade in case KDE reinstates it in a future version.
    /// On error, silently returns None and the cascade falls through to XQueryPointer.
    fn query_compositor_cursor(
        conn: &zbus::blocking::Connection,
    ) -> Option<winit::dpi::PhysicalPosition<f64>> {
        let reply = conn.call_method(
            Some("org.kde.KWin"),
            "/KWin",
            Some("org.kde.KWin"),
            "cursorPos",
            &(),
        ).ok()?;

        let (x, y): (i32, i32) = reply.body().deserialize().ok()?;
        log_step("KWin", &format!("Real cursor position: ({}, {})", x, y));
        Some(winit::dpi::PhysicalPosition::new(x as f64, y as f64))
    }

    /// Find the monitor rect containing (cx, cy); returns the nearest if none match.
    fn monitor_rect_at(monitors: &[(i32, i32, i32, i32)], cx: i32, cy: i32) -> Option<(i32, i32, i32, i32)> {
        monitors.iter()
            .find(|&&(mx, my, mw, mh)| cx >= mx && cx < mx + mw && cy >= my && cy < my + mh)
            .copied()
            .or_else(|| monitors.first().copied())
    }

    /// Tears down the window (surface drop -> X11 DestroyWindow).
    fn destroy_window(&mut self) {
        self.surface = None;
        self.window = None;
        self.mouse_pos = None;
        self.ignored_stale_pos = None;
    }

    fn redraw(&mut self) {
        if let (Some(window), Some(surface)) = (&self.window, &mut self.surface) {
            let size = window.inner_size();
            if size.width == 0 || size.height == 0 {
                return;
            }

            let (width, height) = (size.width, size.height);

            let _ = surface.resize(
                NonZeroU32::new(width).unwrap(),
                NonZeroU32::new(height).unwrap(),
            );

            let mut buffer = surface.buffer_mut().unwrap();
            let canvas = &mut *buffer;

            // DIRTY RECT CONTRACT (mirrors Win32 connector):
            //   1. Swap saved dirty_rects INTO app so render() restores background
            //      only in the previous frame's changed regions (fast path).
            //   2. render() returns partial=true and fills CURRENT frame's rects.
            //   3. present_with_damage receives each rect verbatim — no super-bbox
            //      hack like Wayland (compositor fractional-scaling seams don't
            //      exist on X11; softbuffer SHM put_image handles per-rect cleanly).
            //   4. Swap back to save them for the next frame.
            std::mem::swap(&mut self.app.dirty_rects, &mut self.prev_dirty_rects);
            let partial = self.app.render(canvas, width, height);

            if partial && !self.app.dirty_rects.is_empty() {
                let damage: Vec<softbuffer::Rect> = self.app.dirty_rects.iter()
                    .filter_map(|&(dx, dy, dw, dh)| {
                        let x = dx.max(0) as u32;
                        let y = dy.max(0) as u32;
                        let w = (dw as i32).min(width as i32 - dx.max(0)) as u32;
                        let h = (dh as i32).min(height as i32 - dy.max(0)) as u32;
                        NonZeroU32::new(w).zip(NonZeroU32::new(h))
                            .map(|(w, h)| softbuffer::Rect { x, y, width: w, height: h })
                    })
                    .collect();
                buffer.present_with_damage(&damage).unwrap();
            } else {
                buffer.present().unwrap();
            }

            std::mem::swap(&mut self.app.dirty_rects, &mut self.prev_dirty_rects);
        }
    }

    fn handle_window_event(&mut self, event: WindowEvent) {
        match event {
            WindowEvent::CloseRequested => self.app.should_exit = true,
            WindowEvent::RedrawRequested => {
                self.redraw();
            }
            WindowEvent::CursorMoved { position, .. } => {
                // Ignore the spurious CursorMoved from X11/Winit that fires on window
                // mapping when it carries stale XWayland coordinates.
                if let Some(stale) = self.ignored_stale_pos {
                    if (position.x - stale.x).abs() < 1.0 && (position.y - stale.y).abs() < 1.0 {
                        log_step("X11", "Ignored stale CursorMoved!");
                        return;
                    }
                    // Mouse has moved (coordinates differ from stale) — all good, clear the lock.
                    log_step("X11", &format!("First real movement registered: {:?}", position));
                    self.ignored_stale_pos = None;
                }

                self.mouse_pos = Some(position);
                self.app.update_physical_mouse(position.x, position.y);
                self.app.monitor_rect = Self::monitor_rect_at(
                    &self.monitors, position.x as i32, position.y as i32,
                );

                if let Some(window) = &self.window {
                    window.request_redraw();
                }
            }
            WindowEvent::MouseWheel { delta, .. } => {
                let y = match delta {
                    MouseScrollDelta::LineDelta(_, y) => y as f64,
                    MouseScrollDelta::PixelDelta(pos) => pos.y,
                };
                let zoom_delta = y.partial_cmp(&0.0).map_or(0, |o| o as i32);
                if zoom_delta != 0 {
                    // Handle mouse actions respecting modifiers (Ctrl/Shift).
                    if self.ctrl_pressed {
                        self.app
                            .handle_action(UserAction::ChangeFontSize(zoom_delta));
                    } else if self.shift_pressed {
                        self.app
                            .handle_action(UserAction::ResizeMagnifier(zoom_delta));
                    } else if self.alt_pressed {
                        self.app
                            .handle_action(UserAction::ChangeAimSize(zoom_delta));
                    } else {
                        self.app.handle_action(UserAction::Zoom(zoom_delta));
                    }
                    if let Some(window) = &self.window {
                        window.request_redraw();
                    }
                }
            }
            WindowEvent::MouseInput {
                state: ElementState::Pressed,
                button,
                ..
            } => {
                use winit::event::MouseButton;
                match button {
                    MouseButton::Right => {
                        self.app.handle_action(UserAction::Cancel);
                    }
                    MouseButton::Left | MouseButton::Middle => {
                        let serial = button == MouseButton::Middle || self.shift_pressed;
                        self.app.handle_action(UserAction::PickColor { serial });
                        if self.app.blink.is_some()
                            && let Some(window) = &self.window {
                                window.set_cursor(winit::window::CursorIcon::Default);
                            }
                    }
                    _ => {}
                }
            }
            WindowEvent::ScaleFactorChanged { scale_factor, .. } => {
                self.scale_factor = scale_factor;
            }
            _ => (),
        }
    }
}

// ─── X11 Daemon ──────────────────────────────────────────────────────────────
// Implements ApplicationHandler for the Winit EventLoop,
// mirroring the original DaemonApp from 4e0359f.

struct X11DaemonApp {
    svc: ColorService,
    _tray: DBusTray,
    _scout: Scout,
    overlay: Option<X11OverlayWindow>,
}

impl X11DaemonApp {
    fn new(svc: ColorService, tray: DBusTray, scout: Scout) -> Self {
        // KWin script: skipTaskbar + keepAbove.
        if let Some(ref conn) = svc.dbus_conn {
            Self::install_kwin_skip_taskbar(conn);
        }

        Self {
            svc,
            _tray: tray,
            _scout: scout,
            overlay: None,
        }
    }

    fn launch_overlay(&mut self, event_loop: &ActiveEventLoop, coords: Option<(i32, i32)>) {
        if self.overlay.is_some() {
            log_info("Overlay already active. Simulating LMB click.");
            if let Some(ow) = &mut self.overlay {
                ow.app.handle_action(UserAction::PickColor { serial: false });
                if ow.app.blink.is_some()
                    && let Some(w) = &ow.window {
                        w.set_cursor(winit::window::CursorIcon::Default);
                    }
                if let Some(w) = &ow.window {
                    w.request_redraw();
                }
            }
            return;
        }

        log_info("Launching overlay...");
        let mut perf = self.svc.reload_config();

        match capture_x11_root() {
            Ok(capture) => {
                let root_size = (capture.width, capture.height);
                perf.log("Screen captured (XCB root)");

                let app = OverlayApp::from_capture(
                    capture,
                    None, // No wl_output on X11
                    self.svc.config.clone(),
                    self.svc.cached_font_data.clone(),
                    self.svc.hud_font_data.clone(),
                    "COMPOSITOR: X11".to_string(),
                    1.0, // X11 native: scale_factor = 1.0 (logical == physical)
                );
                let mut ow = X11OverlayWindow::new(app);
                ow.create_window(event_loop, coords, self.svc.dbus_conn.as_ref(), Some(root_size));
                perf.log("Overlay window created & visible");

                self.overlay = Some(ow);
            }
            Err(e) => {
                log_error(&format!("Failed to capture screen via XCB: {}", e));
            }
        }
    }

    /// Loads a KWin Script that automatically hides ie-r windows from the taskbar.
    ///
    /// Mechanics: KWin has a built-in JavaScript engine for extensions.
    /// We load a micro-script via D-Bus (`org.kde.kwin.Scripting`)
    /// that hooks into `windowAdded` and sets `skipTaskbar = true`
    /// on every window whose `resourceClass === "ie-r"`.
    fn install_kwin_skip_taskbar(conn: &zbus::blocking::Connection) {
        use std::io::Write;

        let script = r#"
            function applyRule(client) {
                if (client.resourceClass === "ie-r") {
                    client.skipTaskbar = true;
                    client.skipSwitcher = true;
                    client.keepAbove = true;
                    client.demandsAttention = false;
                }
            }
            workspace.windowList().forEach(applyRule);
            workspace.windowAdded.connect(applyRule);
        "#;

        let temp = match tempfile::Builder::new().suffix(".js").tempfile() {
            Ok(mut f) => {
                if f.write_all(script.as_bytes()).is_err() {
                    return;
                }
                f
            }
            Err(_) => return,
        };

        let path_str = match temp.path().to_str() {
            Some(p) => p.to_string(),
            None => return,
        };

        let reply = conn.call_method(
            Some("org.kde.KWin"),
            "/Scripting",
            Some("org.kde.kwin.Scripting"),
            "loadScript",
            &(path_str.as_str(), "ie-r-skip-taskbar"),
        );

        match reply {
            Ok(msg) => {
                if let Ok(script_id) = msg.body().deserialize::<i32>() {
                    let script_path = format!("/Scripting/Script{}", script_id);
                    let obj_path = zbus::zvariant::ObjectPath::try_from(script_path.as_str());
                    if let Ok(path) = obj_path {
                        let _ = conn.call_method(
                            Some("org.kde.KWin"),
                            &path,
                            Some("org.kde.kwin.Script"),
                            "run",
                            &(),
                        );
                    }
                    log_step("KWin", &format!("Skip-taskbar script loaded (id: {})", script_id));
                }
            }
            Err(e) => {
                log_warn("KWin Scripting not available (expected on non-KDE):");
                let err_str = e.to_string();
                if let Some((first, second)) = err_str.split_once(": ") {
                    log_warn(&format!("{}:", first));
                    log_warn(second);
                } else {
                    log_warn(&err_str);
                }
            }
        }
    }
}

impl ApplicationHandler<UserEvent> for X11DaemonApp {
    fn resumed(&mut self, _event_loop: &ActiveEventLoop) {
        log_info("Daemon resumed/ready. Waiting for hotkeys...");
    }

    fn user_event(&mut self, event_loop: &ActiveEventLoop, event: UserEvent) {
        match event {
            UserEvent::ToggleHUD => {
                self.svc.config.hud.show = !self.svc.config.hud.show;
                self.svc.config.save();
                crate::daemon::dbus_menu::DBusMenu::notify_hud_changed(self.svc.config.hud.show);
            }
            UserEvent::LaunchOverlay(coords) => {
                log_info("LaunchOverlay event received!");
                self.launch_overlay(event_loop, coords);
            }
            UserEvent::OpenHomepage => {
                crate::daemon::open_homepage();
            }
            UserEvent::Quit => {
                log_info("Quit event received.");
                event_loop.exit();
            }
            UserEvent::EditConfig => {
                let config_path = crate::core::config::Config::get_config_path();
                log_info(&format!("Opening config in editor: {:?}", config_path));
                let _ = open::that(config_path);
            }
            UserEvent::CopyFromHistory(hex) => {
                let s = hex.trim_start_matches('#');
                if let Ok(val) = u32::from_str_radix(s, 16) {
                    let r = ((val >> 16) & 0xFF) as u8;
                    let g = ((val >> 8) & 0xFF) as u8;
                    let b = (val & 0xFF) as u8;
                    self.svc.copy_color(&[image::Rgba([r, g, b, 255])]);
                }
            }
            UserEvent::SelectTemplate(key) => {
                log_step("Menu", &format!("Template selected: {}", key));
                self.svc.config.templates.selected = key.clone();
                self.svc.config.save();
                crate::daemon::dbus_menu::DBusMenu::notify_template_changed(&key);
            }
            UserEvent::ShowAbout => {
                // TODO: X11 About window
            }
        }
    }

    fn window_event(
        &mut self,
        _event_loop: &ActiveEventLoop,
        _window_id: WindowId,
        event: WindowEvent,
    ) {
        let mut should_close = false;

        if let Some(ow) = &mut self.overlay {
            ow.handle_window_event(event);

            // If animation is active, ask Winit to redraw the window immediately.
            if ow.app.needs_redraw
                && let Some(w) = &ow.window {
                    w.request_redraw();
                }

            if ow.app.should_exit {
                let color_deck = ow.app.take_color_deck();
                self.svc.finalize_overlay(&ow.app.config, color_deck);
                should_close = true;
            }
        }

        if should_close
            && let Some(mut ow) = self.overlay.take() {
                ow.destroy_window();
                log_info("Overlay closed.");
            }
    }

    fn device_event(
        &mut self,
        _event_loop: &ActiveEventLoop,
        _device_id: winit::event::DeviceId,
        event: winit::event::DeviceEvent,
    ) {
        use winit::event::DeviceEvent;
        use winit::keyboard::{KeyCode, PhysicalKey};

        if let Some(ow) = &mut self.overlay
            && let DeviceEvent::Key(key) = event {
                let mut needs_wake = false;
                match key.physical_key {
                    PhysicalKey::Code(KeyCode::Escape) if key.state == ElementState::Pressed => {
                        ow.app.handle_action(UserAction::Cancel);
                        needs_wake = true;
                    }
                    PhysicalKey::Code(KeyCode::Backquote) if key.state == ElementState::Pressed => {
                        ow.app.handle_action(UserAction::ToggleHud);
                        needs_wake = true;
                    }
                    PhysicalKey::Code(KeyCode::Digit1) | PhysicalKey::Code(KeyCode::Numpad1)
                        if key.state == ElementState::Pressed =>
                    {
                        ow.app.handle_action(UserAction::SelectFormatDigit(1));
                        needs_wake = true;
                    }
                    PhysicalKey::Code(KeyCode::Digit2) | PhysicalKey::Code(KeyCode::Numpad2)
                        if key.state == ElementState::Pressed =>
                    {
                        ow.app.handle_action(UserAction::SelectFormatDigit(2));
                        needs_wake = true;
                    }
                    PhysicalKey::Code(KeyCode::Digit3) | PhysicalKey::Code(KeyCode::Numpad3)
                        if key.state == ElementState::Pressed =>
                    {
                        ow.app.handle_action(UserAction::SelectFormatDigit(3));
                        needs_wake = true;
                    }
                    PhysicalKey::Code(KeyCode::Digit4) if key.state == ElementState::Pressed => {
                        ow.app.handle_action(UserAction::SelectFormatDigit(4)); needs_wake = true;
                    }
                    PhysicalKey::Code(KeyCode::Digit5) if key.state == ElementState::Pressed => {
                        ow.app.handle_action(UserAction::SelectFormatDigit(5)); needs_wake = true;
                    }
                    PhysicalKey::Code(KeyCode::Digit6) if key.state == ElementState::Pressed => {
                        ow.app.handle_action(UserAction::SelectFormatDigit(6)); needs_wake = true;
                    }
                    PhysicalKey::Code(KeyCode::Digit7) if key.state == ElementState::Pressed => {
                        ow.app.handle_action(UserAction::SelectFormatDigit(7)); needs_wake = true;
                    }
                    PhysicalKey::Code(KeyCode::Digit8) if key.state == ElementState::Pressed => {
                        ow.app.handle_action(UserAction::SelectFormatDigit(8)); needs_wake = true;
                    }
                    PhysicalKey::Code(KeyCode::Digit9) if key.state == ElementState::Pressed => {
                        ow.app.handle_action(UserAction::SelectFormatDigit(9)); needs_wake = true;
                    }
                    PhysicalKey::Code(KeyCode::Digit0) if key.state == ElementState::Pressed => {
                        ow.app.handle_action(UserAction::SelectFormatDigit(0)); needs_wake = true;
                    }
                    PhysicalKey::Code(KeyCode::ShiftLeft)
                    | PhysicalKey::Code(KeyCode::ShiftRight) => {
                        ow.shift_pressed = key.state == ElementState::Pressed;
                        needs_wake = true;
                    }
                    PhysicalKey::Code(KeyCode::ControlLeft)
                    | PhysicalKey::Code(KeyCode::ControlRight) => {
                        ow.ctrl_pressed = key.state == ElementState::Pressed;
                        needs_wake = true;
                    }
                    PhysicalKey::Code(KeyCode::AltLeft)
                    | PhysicalKey::Code(KeyCode::AltRight) => {
                        ow.alt_pressed = key.state == ElementState::Pressed;
                        needs_wake = true;
                    }
                    PhysicalKey::Code(KeyCode::ArrowUp) => {
                        let action = if ow.ctrl_pressed || ow.shift_pressed { UserAction::Jump(0, -1) } else { UserAction::Nudge(0, -1) };
                        if key.state == ElementState::Pressed {
                            ow.app.handle_action(action);
                            needs_wake = true;
                        } else {
                            ow.app.handle_action(UserAction::KeyRelease { dx: 0, dy: -1 });
                        }
                    }
                    PhysicalKey::Code(KeyCode::ArrowDown) => {
                        let action = if ow.ctrl_pressed || ow.shift_pressed { UserAction::Jump(0, 1) } else { UserAction::Nudge(0, 1) };
                        if key.state == ElementState::Pressed {
                            ow.app.handle_action(action);
                            needs_wake = true;
                        } else {
                            ow.app.handle_action(UserAction::KeyRelease { dx: 0, dy: 1 });
                        }
                    }
                    PhysicalKey::Code(KeyCode::ArrowLeft) => {
                        let action = if ow.ctrl_pressed || ow.shift_pressed { UserAction::Jump(-1, 0) } else { UserAction::Nudge(-1, 0) };
                        if key.state == ElementState::Pressed {
                            ow.app.handle_action(action);
                            needs_wake = true;
                        } else {
                            ow.app.handle_action(UserAction::KeyRelease { dx: -1, dy: 0 });
                        }
                    }
                    PhysicalKey::Code(KeyCode::ArrowRight) => {
                        let action = if ow.ctrl_pressed || ow.shift_pressed { UserAction::Jump(1, 0) } else { UserAction::Nudge(1, 0) };
                        if key.state == ElementState::Pressed {
                            ow.app.handle_action(action);
                            needs_wake = true;
                        } else {
                            ow.app.handle_action(UserAction::KeyRelease { dx: 1, dy: 0 });
                        }
                    }
                    PhysicalKey::Code(KeyCode::Enter) | PhysicalKey::Code(KeyCode::NumpadEnter)
                        if key.state == ElementState::Pressed =>
                    {
                        ow.app.handle_action(UserAction::PickColor { serial: ow.shift_pressed });
                        if ow.app.blink.is_some()
                            && let Some(w) = &ow.window {
                                w.set_cursor(winit::window::CursorIcon::Default);
                            }
                        needs_wake = true;
                    }
                    PhysicalKey::Code(KeyCode::Space) if key.state == ElementState::Pressed => {
                        ow.app.handle_action(UserAction::PickColor { serial: true });
                        if ow.app.blink.is_some()
                            && let Some(w) = &ow.window {
                                w.set_cursor(winit::window::CursorIcon::Default);
                            }
                        needs_wake = true;
                    }
                    _ => {}
                }

                // "Kick" the event loop to process changes immediately.
                if needs_wake
                    && let Some(w) = &ow.window {
                        w.request_redraw();
                    }
            }
    }

    fn about_to_wait(&mut self, event_loop: &ActiveEventLoop) {
        let mut hotkey_triggered = false;
        while let Ok(event) = GlobalHotKeyEvent::receiver().try_recv() {
            if event.state == global_hotkey::HotKeyState::Released {
                hotkey_triggered = true;
            }
        }
        if hotkey_triggered {
            log_step("Scout", "Hotkey detected!");
            self.launch_overlay(event_loop, None);
        }

        if let Some(ow) = &mut self.overlay
            && ow.app.needs_redraw {
                if let Some(w) = &ow.window {
                    w.request_redraw();
                }
                // Run next frame immediately for smooth 60fps
                event_loop.set_control_flow(ControlFlow::WaitUntil(Instant::now() + Duration::from_millis(8)));
                return;
            }

        let next_frame_time =
            Instant::now() + Duration::from_millis(self.svc.config.system.poll_interval_ms);
        event_loop.set_control_flow(ControlFlow::WaitUntil(next_frame_time));
    }
}

// ─── Native X11 Capture ──────────────────────────────────────────────────────

/// Capture the full virtual desktop via XCB `get_image` on the root window.
///
/// Returns a ScreenCapture sized to the X11 root (= virtual desktop that
/// spans all monitors). The overlay window is created at the same size, so
/// cursor and capture coordinates match 1:1 with no heuristics.
fn capture_x11_root() -> anyhow::Result<capture::ScreenCapture> {
    use x11rb::connection::Connection;
    use x11rb::protocol::xproto::{ConnectionExt, ImageFormat};

    let (conn, screen_num) = x11rb::connect(None)
        .map_err(|e| anyhow::anyhow!("XCB connect failed: {}", e))?;
    let screen = &conn.setup().roots[screen_num];
    let root = screen.root;

    let geom = conn.get_geometry(root)
        .map_err(|e| anyhow::anyhow!("get_geometry request failed: {}", e))?
        .reply()
        .map_err(|e| anyhow::anyhow!("get_geometry reply failed: {}", e))?;

    let w = geom.width;
    let h = geom.height;
    log_step("X11", &format!("Root geometry: {}x{}", w, h));

    let reply = conn.get_image(
        ImageFormat::Z_PIXMAP,
        root,
        0, 0, w, h,
        !0u32, // plane_mask: all planes
    ).map_err(|e| anyhow::anyhow!("get_image request failed: {}", e))?
    .reply()
    .map_err(|e| anyhow::anyhow!("get_image reply failed: {}", e))?;

    let data = &reply.data;
    let pixel_count = w as usize * h as usize;
    let expected_bytes = pixel_count * 4;

    if data.len() < expected_bytes {
        return Err(anyhow::anyhow!(
            "XCB get_image: short data {} < {} expected ({}x{} @ 4bpp)",
            data.len(), expected_bytes, w, h
        ));
    }

    // ZPixmap on 24-bit TrueColor (little-endian): 4 bytes per pixel BGRX
    // u32::from_le_bytes([B,G,R,X]) = 0xXXRRGGBB = our XRGB format (top byte unused).
    let xrgb: Vec<u32> = data[..expected_bytes]
        .chunks_exact(4)
        .map(|c| u32::from_le_bytes([c[0], c[1], c[2], c[3]]) & 0x00FF_FFFF)
        .collect();

    log_step("Capture", &format!("XCB root: {}x{} ({} px)", w, h, xrgb.len()));

    Ok(capture::ScreenCapture { xrgb_buffer: xrgb, width: w as u32, height: h as u32 })
}

// ─── Public Entry Point ──────────────────────────────────────────────────────

use crate::core::terminal::print_logo;

/// Launches the daemon in X11 mode. Original architecture from 4e0359f.
/// Blocks the current thread indefinitely (Winit EventLoop).
pub fn run_x11_daemon(svc: ColorService) -> Result<()> {
    print_logo();
    log_info("X11 Winit backend active");
    log_info("...");
    log_info("To trigger IE-R, bind system shortcuts to UNIX signals:");
    log_info("SIGUSR1 (Pick Color): pkill -SIGUSR1 ie-r");
    log_info("SIGUSR2 (Open Menu):  pkill -SIGUSR2 ie-r");
    log_info("i3/bspwm/sxhkd example:");
    log_info("bindsym $mod+Shift+p exec pkill -SIGUSR1 ie-r");

    let scout = Scout::new(&svc.config.system.hotkey)?;

    #[cfg(target_os = "linux")]
    use winit::platform::x11::EventLoopBuilderExtX11;

    let mut builder = EventLoop::with_user_event();

    #[cfg(target_os = "linux")]
    {
        // Explicitly tell Winit: use X11 only, do not attempt to initialize Wayland.
        // This prevents a NoWaylandLib panic when launched outside a Nix shell.
        builder.with_x11();
    }

    let event_loop = builder
        .build()
        .map_err(|e| anyhow::anyhow!("Failed to build X11 EventLoop: {}", e))?;
    let proxy = event_loop.create_proxy();

    // Tokio for background DBus tasks
    let rt = tokio::runtime::Runtime::new()?;
    let _guard = rt.enter();

    // Wire up DBusTray via universal EventSender
    let sender = EventSender::from_winit(proxy);
    let tray = DBusTray::new(sender.clone())?;

    // Universal POSIX signal interception (SIGUSR1/SIGUSR2) via Tokio.
    // The entire x11.rs module is cfg(unix) gated in mod.rs,
    // so we can use tokio::signal::unix safely without local cfgs.
    use tokio::signal::unix::{signal, SignalKind};
    let sender_sig = sender.clone();
    rt.spawn(async move {
        if let (Ok(mut sig1), Ok(mut sig2)) = (
            signal(SignalKind::user_defined1()),
            signal(SignalKind::user_defined2()),
        ) {
            loop {
                tokio::select! {
                    _ = sig1.recv() => {
                        log_info("Received SIGUSR1 (X11). Launching overlay.");
                        sender_sig.send(UserEvent::LaunchOverlay(None));
                    }
                    _ = sig2.recv() => {
                        log_info("Received SIGUSR2 (X11). Launching menu.");
                        tokio::spawn(crate::daemon::pipe_menu::show_menu(sender_sig.clone()));
                    }
                }
            }
        }
    });

    let mut app = X11DaemonApp::new(svc, tray, scout);

    event_loop.run_app(&mut app)?;

    Ok(())
}

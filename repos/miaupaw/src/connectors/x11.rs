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
        }
    }

    /// Creates a fullscreen borderless window on top of everything.
    /// `dbus_conn` is needed to query the real cursor position from KWin (XWayland workaround).
    fn create_window(
        &mut self,
        event_loop: &ActiveEventLoop,
        coords: Option<(i32, i32)>,
        dbus_conn: Option<&zbus::blocking::Connection>,
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

        // Explicitly request the current monitor size
        // (override_redirect windows do not go fullscreen automatically).
        if let Some(monitor) = window.current_monitor() {
            let size = monitor.size();
            let _ = window.request_inner_size(size);
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

        self.window = Some(window);
        self.surface = Some(surface);
        self.ignored_stale_pos = x11_stale_pos;
        // Always show the magnifier immediately. Under XWayland it may appear
        // at a stale position, but that is better than an invisible eyedropper.
        self.mouse_pos = Some(initial_pos);
        self.app.update_physical_mouse(initial_pos.x, initial_pos.y);
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

            let width = size.width as usize;
            let height = size.height as usize;

            let _ = surface.resize(
                NonZeroU32::new(size.width).unwrap(),
                NonZeroU32::new(size.height).unwrap(),
            );

            let mut buffer = surface.buffer_mut().unwrap();
            let canvas = &mut *buffer;

            // Render the core (magnifier, glassmorphism, text, dirty rects).
            self.app.render(canvas, width as u32, height as u32);

            buffer.present().unwrap();
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

        if let Ok(capture) = capture::capture_screen(self.svc.dbus_conn.as_ref()) {
            // Detect scaling factor from primary monitor (X11 implementation quirk)
            let scale_factor = event_loop.primary_monitor().map(|m| m.scale_factor()).unwrap_or(1.0);
            perf.log("Screen captured");

            let app = OverlayApp::from_capture(
                capture,
                None, // No wl_output on X11
                self.svc.config.clone(),
                self.svc.cached_font_data.clone(),
                self.svc.hud_font_data.clone(),
                "COMPOSITOR: X11".to_string(),
                scale_factor,
            );
            let mut ow = X11OverlayWindow::new(app);
            ow.create_window(event_loop, coords, self.svc.dbus_conn.as_ref());
            perf.log("Overlay window created & visible");

            self.overlay = Some(ow);
        } else {
            log_error("Failed to capture screen.");
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
                log_warn(&format!("KWin Scripting not available (expected on non-KDE): {}", e));
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

// ─── Public Entry Point ──────────────────────────────────────────────────────

use crate::core::terminal::print_logo;

/// Launches the daemon in X11 mode. Original architecture from 4e0359f.
/// Blocks the current thread indefinitely (Winit EventLoop).
pub fn run_x11_daemon(svc: ColorService) -> Result<()> {
    print_logo();
    log_info("X11 Winit backend active");
    log_info("SIGUSR1 not available in X11 mode. Use hotkey or tray icon.");

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
    let tray = DBusTray::new(sender)?;

    let mut app = X11DaemonApp::new(svc, tray, scout);

    event_loop.run_app(&mut app)?;

    Ok(())
}

use smithay_client_toolkit::{
    compositor::CompositorHandler,
    delegate_compositor, delegate_keyboard, delegate_layer, delegate_output, delegate_pointer,
    delegate_registry, delegate_seat, delegate_shm, delegate_xdg_shell, delegate_xdg_window,
    output::{OutputHandler, OutputState},
    registry::{ProvidesRegistryState, RegistryState},
    registry_handlers,
    seat::{
        Capability, SeatHandler, SeatState,
        pointer::ThemeSpec,
    },
    shell::{
        WaylandSurface,
        wlr_layer::{LayerShellHandler, LayerSurface, LayerSurfaceConfigure},
        xdg::window::{Window, WindowConfigure, WindowHandler},
    },
    shm::{Shm, ShmHandler},
};
use std::num::NonZeroU32;
use wayland_client::{
    Connection, Dispatch, QueueHandle,
    protocol::{wl_output, wl_seat, wl_surface},
};
use wayland_protocols::wp::viewporter::client::{
    wp_viewport::WpViewport, wp_viewporter::WpViewporter,
};
use wayland_protocols::xdg::activation::v1::client::xdg_activation_v1::XdgActivationV1;
use wayland_protocols_wlr::screencopy::v1::client::zwlr_screencopy_manager_v1::ZwlrScreencopyManagerV1;

use super::{IEWaylandState, OverlaySurface};

// ══════════════════════════════════════════════════════════════════════════════
// SCTK Delegates — protocol glue between the Wayland compositor and IEWaylandState.
//
// Each Handler is a mandatory trait for the corresponding delegate_*! macro.
// Most callbacks are empty (the protocol requires an impl, but we have no use for them).
// Key ones: frame() → unblocks the next commit, configure() → triggers the first
// render, new_capability() → captures keyboard and themed pointer.
// ══════════════════════════════════════════════════════════════════════════════

impl CompositorHandler for IEWaylandState {
    fn scale_factor_changed(
        &mut self,
        _conn: &Connection,
        _qh: &QueueHandle<Self>,
        _surface: &wl_surface::WlSurface,
        factor: i32,
    ) {
        self.scale_factor = factor as f64;
        if let Some(app) = &mut self.overlay_app {
            app.update_scale(factor as f64);
        }
    }
    fn transform_changed(
        &mut self,
        _conn: &Connection,
        _qh: &QueueHandle<Self>,
        _surface: &wl_surface::WlSurface,
        _new_transform: wl_output::Transform,
    ) {
    }
    fn frame(
        &mut self,
        _conn: &Connection,
        qh: &QueueHandle<Self>,
        _surface: &wl_surface::WlSurface,
        _time: u32,
    ) {
        // About window — redraw for animations.
        if self.about_surface.as_ref().is_some_and(|a| *a.surface.wl_surface() == *_surface) {
            self.render_about(qh);
            return;
        }

        // Frame callback per-surface: unblock re-commit ONLY for this overlay.
        // Resetting all overlays would let B's callback unlock A and cause a double commit.
        if let Some(overlay) = self.overlays.iter_mut().find(|o| *o.surface.wl_surface() == *_surface) {
            overlay.committed = false;
            overlay.frame_pending = false;
        }
        if self.needs_redraw {
            self.redraw(qh);
        }
        // Blink animation may set should_exit from within render().
        if let Some(app) = &self.overlay_app
            && app.should_exit {
                self.exit = true;
            }
    }
    fn surface_enter(
        &mut self,
        _conn: &Connection,
        _qh: &QueueHandle<Self>,
        _surface: &wl_surface::WlSurface,
        _output: &wl_output::WlOutput,
    ) {
        // About window entered a monitor — update background for glassmorphism.
        if let Some(about) = &mut self.about_surface
            && about.surface.wl_surface() == _surface {
                about.update_bg_for_output(_output);
            }
    }
    fn surface_leave(
        &mut self,
        _conn: &Connection,
        _qh: &QueueHandle<Self>,
        _surface: &wl_surface::WlSurface,
        _output: &wl_output::WlOutput,
    ) {
    }
}

impl OutputHandler for IEWaylandState {
    fn output_state(&mut self) -> &mut OutputState {
        &mut self.output_state
    }
    fn new_output(&mut self, _conn: &Connection, _qh: &QueueHandle<Self>, _output: wl_output::WlOutput) {}
    fn update_output(&mut self, _conn: &Connection, _qh: &QueueHandle<Self>, _output: wl_output::WlOutput) {}
    fn output_destroyed(&mut self, _conn: &Connection, _qh: &QueueHandle<Self>, _output: wl_output::WlOutput) {
        // Hotplug: monitor disconnected mid-session. Remove the associated overlay
        // to avoid committing to a surface bound to a dead output.
        if let Some(idx) = self.overlays.iter().position(|o| o.output == _output) {
            let removed = self.overlays.remove(idx);
            if let Some(vp) = removed.viewport {
                vp.destroy();
            }
            // If the cursor was on this monitor — clear the active output.
            if self.active_output.as_ref() == Some(&_output) {
                self.active_output = None;
            }
        }
    }
}

impl LayerShellHandler for IEWaylandState {
    fn closed(&mut self, _conn: &Connection, _qh: &QueueHandle<Self>, _layer: &LayerSurface) {
        // Compositor is closing a specific Layer Shell surface (logout, hotplug, etc.).
        // If it's the About window — close it gracefully, don't kill the whole daemon.
        if self.about_surface.as_ref().is_some_and(|a| {
            if let OverlaySurface::Layer(l) = &a.surface { l == _layer } else { false }
        }) {
            self.close_about();
        } else {
            self.exit = true;
        }
    }
    fn configure(
        &mut self,
        _conn: &Connection,
        qh: &QueueHandle<Self>,
        layer: &LayerSurface,
        configure: LayerSurfaceConfigure,
        _serial: u32,
    ) {
        // About window configure → render static content
        if self.about_surface.as_ref().is_some_and(|a| {
            if let OverlaySurface::Layer(l) = &a.surface { l == layer } else { false }
        }) {
            self.render_about(qh);
            return;
        }

        let new_w = NonZeroU32::new(configure.new_size.0).map_or(1920, NonZeroU32::get);
        let new_h = NonZeroU32::new(configure.new_size.1).map_or(1080, NonZeroU32::get);

        let mut first_dimensions = false;
        if let Some((_, overlay)) = self.overlays.iter_mut().enumerate().find(|(_, o)| {
            if let OverlaySurface::Layer(l) = &o.surface { l == layer } else { false }
        }) {
            first_dimensions = overlay.width == 0;
            overlay.width = new_w;
            overlay.height = new_h;
        }

        // Every overlay must receive its first render on configure.
        // first_configure covers the very first, first_dimensions covers subsequent ones.
        // redraw() is safe to call multiple times — the committed flag skips
        // already-committed overlays, preventing double commits.
        if self.first_configure || first_dimensions {
            self.first_configure = false;
            self.needs_redraw = true;
            self.redraw(qh);
        }
    }
}

impl SeatHandler for IEWaylandState {
    fn seat_state(&mut self) -> &mut SeatState {
        &mut self.seat_state
    }
    fn new_seat(&mut self, _: &Connection, _: &QueueHandle<Self>, _: wl_seat::WlSeat) {}
    fn new_capability(
        &mut self,
        _conn: &Connection,
        qh: &QueueHandle<Self>,
        seat: wl_seat::WlSeat,
        capability: Capability,
    ) {
        if capability == Capability::Keyboard && self.keyboard.is_none()
            && let Ok(keyboard) = self.seat_state.get_keyboard(qh, &seat, None) {
                self.keyboard = Some(keyboard);
            }
        if capability == Capability::Pointer && self.pointer.is_none()
            && let Some(compositor) = &self.compositor {
                let surface = compositor.create_surface(qh);
                if let Ok(pointer) = self.seat_state.get_pointer_with_theme(
                    qh,
                    &seat,
                    self.shm.as_ref().unwrap().wl_shm(),
                    surface,
                    ThemeSpec::default(),
                ) {
                    self.pointer = Some(pointer);
                }
            }
    }
    fn remove_capability(
        &mut self,
        _conn: &Connection,
        _: &QueueHandle<Self>,
        _: wl_seat::WlSeat,
        capability: Capability,
    ) {
        if capability == Capability::Keyboard && self.keyboard.is_some() {
            self.keyboard.take().unwrap().release();
        }
        if capability == Capability::Pointer && self.pointer.is_some() {
            self.pointer.take().unwrap().pointer().release();
        }
    }
    fn remove_seat(&mut self, _: &Connection, _: &QueueHandle<Self>, _: wl_seat::WlSeat) {}
}

impl ShmHandler for IEWaylandState {
    fn shm_state(&mut self) -> &mut Shm {
        self.shm.as_mut().unwrap()
    }
}

impl ProvidesRegistryState for IEWaylandState {
    fn registry(&mut self) -> &mut RegistryState {
        &mut self.registry_state
    }
    registry_handlers![OutputState, SeatState];
}

// ── XDG Window (GNOME fallback) ─────────────────────────────────────────────
// Used when the compositor does not support Layer Shell (Mutter/GNOME).
// xdg_toplevel + fullscreen — less reliable path, but the only option for GNOME.

impl WindowHandler for IEWaylandState {
    fn request_close(&mut self, _conn: &Connection, _qh: &QueueHandle<Self>, _window: &Window) {
        // Compositor requests closing the xdg_toplevel (Alt+F4, decorations, logout).
        // If it's the About window — close it gracefully, don't kill the whole daemon.
        if self.about_surface.as_ref().is_some_and(|a| {
            if let OverlaySurface::Xdg(w) = &a.surface { w == _window } else { false }
        }) {
            self.close_about();
        } else {
            self.exit = true;
        }
    }
    fn configure(
        &mut self,
        _conn: &Connection,
        qh: &QueueHandle<Self>,
        window: &Window,
        configure: WindowConfigure,
        _serial: u32,
    ) {
        // About window configure → render static content
        if self.about_surface.as_ref().is_some_and(|a| {
            if let OverlaySurface::Xdg(w) = &a.surface { w == window } else { false }
        }) {
            self.render_about(qh);
            return;
        }

        let (nw, nh) = configure.new_size;
        let new_w = nw.map_or(1920, |v| v.get());
        let new_h = nh.map_or(1080, |v| v.get());

        // GNOME sends two configures: first (0,0) "client chooses" and then the real
        // fullscreen size. Track size changes — on each change clear committed to
        // unblock redraw for the new buffer.
        let mut size_changed = false;
        if let Some(overlay) = self.overlays.iter_mut().find(|o| {
            if let OverlaySurface::Xdg(w) = &o.surface { w == window } else { false }
        })
            && (overlay.width != new_w || overlay.height != new_h) {
                overlay.width = new_w;
                overlay.height = new_h;
                overlay.committed = false;
                size_changed = true;
            }

        if self.first_configure {
            // Consume the activation token: tell GNOME Shell the window has appeared.
            let token = crate::daemon::dbus_tray::LAST_ACTIVATION_TOKEN
                .lock()
                .ok()
                .and_then(|mut g| g.take());
            if let (Some(t), Some(activation)) = (token, &self.xdg_activation) {
                activation.activate(t, window.wl_surface());
            }
            self.first_configure = false;
            size_changed = true;
        }

        if size_changed {
            self.needs_redraw = true;
            self.redraw(qh);
        }
    }
}

// ══════════════════════════════════════════════════════════════════════════════
// Generated code — delegate macros and bare Dispatch impls.
// Macros wire the Handler traits above to Wayland protocol objects.
// Bare Dispatch impls are needed for protocols with no client-side events.
// ══════════════════════════════════════════════════════════════════════════════

delegate_compositor!(IEWaylandState);
delegate_output!(IEWaylandState);
delegate_shm!(IEWaylandState);
delegate_seat!(IEWaylandState);
delegate_keyboard!(IEWaylandState);
delegate_pointer!(IEWaylandState);
delegate_layer!(IEWaylandState);
delegate_registry!(IEWaylandState);
delegate_xdg_shell!(IEWaylandState);
delegate_xdg_window!(IEWaylandState);

impl Dispatch<WpViewporter, ()> for IEWaylandState {
    fn event(_: &mut Self, _: &WpViewporter, _: <WpViewporter as wayland_client::Proxy>::Event, _: &(), _: &Connection, _: &QueueHandle<Self>) {}
}

impl Dispatch<WpViewport, ()> for IEWaylandState {
    fn event(_: &mut Self, _: &WpViewport, _: <WpViewport as wayland_client::Proxy>::Event, _: &(), _: &Connection, _: &QueueHandle<Self>) {}
}

impl Dispatch<XdgActivationV1, ()> for IEWaylandState {
    fn event(_: &mut Self, _: &XdgActivationV1, _: <XdgActivationV1 as wayland_client::Proxy>::Event, _: &(), _: &Connection, _: &QueueHandle<Self>) {}
}

impl Dispatch<ZwlrScreencopyManagerV1, ()> for IEWaylandState {
    fn event(_: &mut Self, _: &ZwlrScreencopyManagerV1, _: <ZwlrScreencopyManagerV1 as wayland_client::Proxy>::Event, _: &(), _: &Connection, _: &QueueHandle<Self>) {}
}

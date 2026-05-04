mod delegates;
mod input;
mod render;
pub mod oracle; // Oracle — single source of truth for coordinate transformations

use smithay_client_toolkit::{
    compositor::CompositorState,
    output::OutputState,
    registry::RegistryState,
    seat::{
        SeatState,
        pointer::ThemedPointer,
    },
    shell::{
        WaylandSurface,
        wlr_layer::LayerShell,
        xdg::{XdgShell, window::Window},
    },
    shm::{Shm, slot::{SlotPool, Buffer}},
};
use wayland_client::{
    Connection, QueueHandle,
    protocol::{wl_keyboard, wl_output, wl_surface},
};
use wayland_protocols::wp::viewporter::client::{
    wp_viewport::WpViewport, wp_viewporter::WpViewporter,
};
use wayland_protocols::xdg::activation::v1::client::xdg_activation_v1::XdgActivationV1;
use wayland_protocols_wlr::screencopy::v1::client::zwlr_screencopy_manager_v1::ZwlrScreencopyManagerV1;
use smithay_client_toolkit::shell::wlr_layer::LayerSurface;

use crate::core::about::{self, AboutApp};
use crate::core::capture::MonitorTile;
use crate::core::overlay::{OverlayApp, UserAction};

pub enum OverlaySurface {
    Layer(LayerSurface),
    Xdg(Window),
}

impl OverlaySurface {
    pub fn wl_surface(&self) -> &wl_surface::WlSurface {
        match self {
            OverlaySurface::Layer(layer) => layer.wl_surface(),
            OverlaySurface::Xdg(window) => window.wl_surface(),
        }
    }
}

/// **Overlay on a specific monitor**
pub struct IEOverlay {
    pub output: wl_output::WlOutput,
    pub surface: OverlaySurface,
    pub viewport: Option<WpViewport>,
    /// Logical overlay size on this monitor (from configure).
    pub width: u32,
    pub height: u32,
    /// Dirty rects from this overlay's previous frame.
    /// Each monitor keeps its own — coordinates are tied to the physical tile size,
    /// and each has its own SHM buffers. Swapped into OverlayApp before render(),
    /// swapped back after.
    pub dirty_rects: std::collections::VecDeque<(i32, i32, usize, usize)>,
    /// Buffer already committed, awaiting frame callback. Double commit = protocol error.
    pub committed: bool,
    /// Waiting for frame callback from the compositor.
    pub frame_pending: bool,
    /// SHM buffers the compositor may still be reading (FIFO, triple buffering).
    pub buffers: std::collections::VecDeque<Buffer>,
}

/// About window surface — one per daemon, not per monitor.
pub struct AboutSurface {
    pub surface: OverlaySurface,
    pub viewport: Option<WpViewport>,
    pub app: AboutApp,
    /// SHM buffers (FIFO, triple buffering — same as overlay).
    pub buffers: std::collections::VecDeque<Buffer>,
    /// Captured tiles for all monitors (for selecting the correct background by output).
    pub tiles: Vec<MonitorTile>,
    /// Captured background for glassmorphism (cropped from the current monitor's tile).
    pub bg_buffer: Vec<u32>,
    /// Blur scratchpads (pre-allocated to the window size).
    pub blur_buf_1: Vec<u32>,
    pub blur_buf_2: Vec<u32>,
}

impl AboutSurface {
    /// Crops the center of the tile to the About window size.
    fn extract_bg(tile: &MonitorTile) -> Vec<u32> {
        let w = about::ABOUT_WIDTH as usize;
        let h = about::ABOUT_HEIGHT as usize;
        let mut bg = vec![0u32; w * h];
        let tw = tile.capture.width as usize;
        let th = tile.capture.height as usize;
        let src = &tile.capture.xrgb_buffer;

        let start_x = ((tw as i32 - w as i32) / 2).max(0) as usize;
        let start_y = ((th as i32 - h as i32) / 2).max(0) as usize;
        let copy_w = w.min(tw - start_x);

        for cy in 0..h {
            let sy = start_y + cy;
            if sy >= th { break; }
            bg[cy * w..cy * w + copy_w]
                .copy_from_slice(&src[sy * tw + start_x..sy * tw + start_x + copy_w]);
        }
        bg
    }

    /// Updates bg_buffer for the given output (called from surface_enter).
    /// Invalidates the blur cache to force a re-render with the correct background.
    pub fn update_bg_for_output(&mut self, output: &wl_output::WlOutput) {
        if let Some(tile) = self.tiles.iter().find(|t| t.output.as_ref() == Some(output)) {
            self.bg_buffer = Self::extract_bg(tile);
            self.app.invalidate_blur_cache();
            // Fresh scratchpads needed for blur recalculation.
            let sz = (about::ABOUT_WIDTH * about::ABOUT_HEIGHT) as usize;
            if self.blur_buf_1.is_empty() {
                self.blur_buf_1 = vec![0u32; sz];
                self.blur_buf_2 = vec![0u32; sz];
            }
        }
        // Tiles no longer needed — correct background selected, free the screenshots.
        self.tiles = Vec::new();
    }
}

/// Input state: cursor position, modifiers, enter tracking.
/// Isolates data updated on every mouse/keyboard event.
#[derive(Default)]
pub struct InputState {
    pub x: i32,                    // cursor logical X (surface-local)
    pub y: i32,                    // cursor logical Y (surface-local)
    pub inside: bool,              // cursor is inside the surface
    pub shift: bool,               // Shift held
    pub ctrl: bool,                // Ctrl held
    pub alt: bool,                 // Alt held
    pub pending_correction: bool,  // first Motion after Enter not yet received
    pub batch_count: u32,          // Enter events in the current dispatch batch
    pub phantom_count: u32,        // of which — Phantom (Hyprland batch, inactive monitors)
    /// Startup: batch-Enters (Type A), raw = cursor_global - 2*output_pos.
    /// After flush_pending_enters → false: all Enters are Type B, raw = cursor_local.
    pub startup_phase: bool,
}

/// **Wayland Matrix (SCTK State)**
///
/// Holds the display connection and routes hardware events → `OverlayApp`.
/// Protocol fields are flat (required by SCTK delegate macros);
/// input data is extracted into `InputState`.
pub struct IEWaylandState {
    // ── Wayland connection & protocols ──────────────────────────────
    pub conn: Connection,
    registry_state: RegistryState,
    pub output_state: OutputState,
    seat_state: SeatState,
    pub shm: Option<Shm>,                                    // wl_shm
    compositor: Option<CompositorState>,                      // wl_compositor
    layer_shell: Option<LayerShell>,                          // zwlr_layer_shell
    xdg_shell: Option<XdgShell>,                              // xdg_wm_base (GNOME fallback)
    xdg_activation: Option<XdgActivationV1>,                  // xdg_activation_v1
    viewporter: Option<WpViewporter>,                         // wp_viewporter (fractional scaling)
    pub screencopy_manager: Option<ZwlrScreencopyManagerV1>,  // wlr_screencopy (Hyprland/Sway)

    // ── Input devices & state ──────────────────────────────────────
    keyboard: Option<wl_keyboard::WlKeyboard>,
    pointer: Option<ThemedPointer>,
    pub input: InputState,
    pub compositor_hint: oracle::CompositorHint,               // classify_enter strategy

    // ── Overlay lifecycle ──────────────────────────────────────────
    pub overlays: Vec<IEOverlay>,                              // one per monitor
    pub overlay_app: Option<OverlayApp>,                       // render core
    pub about_surface: Option<AboutSurface>,                   // About window
    pub active_output: Option<wl_output::WlOutput>,            // monitor under cursor
    pool: Option<SlotPool>,                                    // SHM buffer pool
    pub scale_factor: f64,                                     // current compositor scale

    // ── Control flags ──────────────────────────────────────────────
    pub exit: bool,                                            // overlay exit signal
    first_configure: bool,                                     // first configure not yet handled
    needs_redraw: bool,                                        // dirty pixels pending
    pub open_url: bool,                                        // flag: open URL after exit
}
impl IEWaylandState {
    /// Forwards an action to OverlayApp, syncing exit and needs_redraw.
    /// Returns true if the overlay was active.
    pub fn is_redraw_pending(&self) -> bool {
        self.needs_redraw
    }

    /// Kick the render loop from outside (calloop timer).
    /// Safe to call with no overlay active — just sets the flag.
    pub fn request_redraw(&mut self) {
        self.needs_redraw = true;
    }

    pub fn dispatch(&mut self, action: UserAction) -> bool {
        if let Some(app) = &mut self.overlay_app {
            app.handle_action(action);
            if app.should_exit {
                self.exit = true;
            }
            self.needs_redraw = true;
            true
        } else {
            false
        }
    }

    pub fn new(conn: Connection, globals: &wayland_client::globals::GlobalList, qh: &QueueHandle<Self>) -> Self {
        let compositor = CompositorState::bind(globals, qh).ok();
        let layer_shell = LayerShell::bind(globals, qh).ok();
        let xdg_shell = XdgShell::bind(globals, qh).ok();
        let xdg_activation = globals.bind::<XdgActivationV1, _, _>(qh, 1..=1, ()).ok();
        let screencopy_manager = globals.bind::<ZwlrScreencopyManagerV1, _, _>(qh, 1..=1, ()).ok();
        let shm = Shm::bind(globals, qh).ok();
        let viewporter = globals.bind::<WpViewporter, _, _>(qh, 1..=1, ()).ok();

        // Detect Hyprland explicitly — its non-standard batch-Enter requires correction.
        // Everything else (Plasma, Sway, unknown) gets Standard: Wayland spec.
        let compositor_hint = if std::env::var("HYPRLAND_INSTANCE_SIGNATURE").is_ok() {
            oracle::CompositorHint::Hyprland
        } else {
            oracle::CompositorHint::Standard
        };

        Self {
            conn,
            registry_state: RegistryState::new(globals),
            output_state: OutputState::new(globals, qh),
            seat_state: SeatState::new(globals, qh),
            shm,
            compositor,
            layer_shell,
            xdg_shell,
            xdg_activation,
            viewporter,
            screencopy_manager,

            keyboard: None,
            pointer: None,
            input: InputState::default(),
            compositor_hint,

            overlays: Vec::new(),
            overlay_app: None,
            about_surface: None,
            active_output: None,
            pool: None,
            scale_factor: 1.0,

            exit: false,
            first_configure: true,
            needs_redraw: false,
            open_url: false,
        }
    }
}

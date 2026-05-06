/// - `primitives.rs` — draw_rect, draw_filled_rect, set_pixel, copy_region
///
/// Overlay — full-screen magnifier overlay module.
///
/// Structure:
/// - `mod.rs` — OverlayApp (public API, state, render, handle_action, spring physics)
/// - `hud.rs` — HUD: self-contained entity (state + animation + rendering)
/// - `magnifier.rs` — zoomed pixel rendering, grid, crosshair, HEX text
/// - `glass.rs` — glassmorphism effect (box blur + frosted tint)
/// - `primitives.rs` — draw_rect, draw_filled_rect, set_pixel, copy_region
mod glass;
pub mod hud;
mod magnifier;
pub mod primitives;
pub mod shapes;

// Re-export shared rendering primitives for other core modules (e.g. About window)
pub use glass::draw_frosted_rect;

use crate::core::capture::PhysicalCanvas;
#[cfg(unix)]
use crate::core::capture::ScreenCapture;
use crate::core::config::Config;
use image::Rgba;
#[cfg(unix)]
use wayland_client::protocol::wl_output;
use std::collections::HashMap;
use std::time::Instant;

use primitives::copy_region;

pub struct RepeatState {
    pub dx: i32,
    pub dy: i32,
    pub is_jump: bool,
    pub started: Instant,
    pub last_repeat: Instant,
}

pub struct OverlayApp {
    /// Pixel mosaic of all captured monitors. 
    /// Coordinates asked from it must be in the active tile's local physical space.
    pub canvas: PhysicalCanvas,

    // --- Legacy convenience aliases (always mirror the active tile) ---
    pub buf_width: u32,
    pub buf_height: u32,
    pub mouse_pos: Option<(f64, f64)>,
    pub physical_mouse_pos: Option<(f64, f64)>,
    pub scale_factor: f64,

    // Config holds all settings (aperture, size, colors, offsets)
    pub config: Config,

    pub backend_name: String,

    // Collected colors (for serial/multi-pick mode)
    pub color_deck: Vec<Rgba<u8>>,
    // Shutdown flag
    pub should_exit: bool,
    // Timing for first redraw
    first_redraw_time: Option<Instant>,

    // --- Core State ---
    pub last_frame_time: Option<Instant>,
    pub needs_redraw: bool,

    // --- Dirty Rect Optimization ---
    pub dirty_rects: std::collections::VecDeque<(i32, i32, usize, usize)>,
    /// ptr → tile_idx: which tile last performed a full copy into this SHM address.
    /// On dirty-path renders we verify the tile hasn't changed — otherwise foreign content
    /// could have overwritten the buffer while it was in SlotPool of another overlay.
    pub(crate) warmed_buffers: HashMap<usize, usize>,

    // --- Glassmorphism Scratchpads (shared between magnifier and HUD) ---
    pub blur_buf_1: Vec<u32>,
    pub blur_buf_2: Vec<u32>,

    // --- Sub-Entities ---
    pub magnifier: magnifier::Magnifier,
    pub hud: hud::Hud,

    // --- Visual Feedback ---
    pub flash_intensity: f32,

    // --- Keyboard Repeat Tracker ---
    pub repeat_tracker: Option<RepeatState>,

    // --- Final Blink Animation ---
    pub blink: Option<BlinkState>,

    // --- Watchdog (auto-exit on inactivity) ---
    pub last_activity: Instant,

    // Current monitor bounds in canvas-local coordinates (x, y, w, h).
    // Used by magnifier for edge-reflection and clamping on multi-monitor setups.
    // None = use canvas bounds (correct for Wayland per-output surfaces).
    pub monitor_rect: Option<(i32, i32, i32, i32)>,
}

/// State for the final color-capture animation.
/// While active, the magnifier is hidden; the overlay closes when the animation ends.
/// A single square in the blink animation train.
pub struct BlinkSquare {
    pub color: u32,
    pub delay: f32,             // stagger offset from train start (seconds)
}

/// A train of colored squares converging from magnifier to cursor.
pub struct BlinkState {
    pub origin: (f32, f32),     // center of the magnifier grid area (animation start)
    pub squares: Vec<BlinkSquare>,
    pub start_size: f32,        // initial square size (magnifier grid size)
    pub started: Instant,       // start timestamp
    pub duration: f32,          // total duration for the entire train (seconds)
    pub fly_time: f32,          // flight time per individual square (seconds)
}

#[derive(Debug, Clone, Copy, PartialEq)]
pub enum UserAction {
    Zoom(i32),
    ResizeMagnifier(i32),
    Nudge(i32, i32),
    Jump(i32, i32),
    ChangeFontSize(i32),
    ChangeAimSize(i32),
    SelectFormatDigit(usize),
    ToggleHud,
    /// Pick color under cursor.
    /// `serial: true` — add to deck (Shift+Click, Middle, Shift+Enter)
    /// `serial: false` — final pick, close overlay (Click, Enter)
    PickColor { serial: bool },
    /// Cancel operation (Esc, RMB). Clears the deck and closes the overlay.
    Cancel,
    /// Key release event (needed to stop keyboard auto-repeat movement).
    KeyRelease { dx: i32, dy: i32 },
}

impl OverlayApp {
    /// **Application initialization**
    ///
    /// Accepts a `PhysicalCanvas` (all monitors). Active tile = monitor under cursor.
    /// `background_buffer` mirrors the active tile's buffer — zero-copy, same Vec.
    pub fn new(
        canvas: PhysicalCanvas,
        mut config: Config,
        font_data: std::sync::Arc<Vec<u8>>,
        hud_font_data: std::sync::Arc<Vec<u8>>,
        backend_name: String,
        scale_factor: f64,
    ) -> Self {
        // Guarantee odd numbers for aperture and size (Optical Monolith foundation).
        // Critical for perfect centering of the central pixel.
        config.magnifier.aperture = magnifier::ensure_odd(config.magnifier.aperture as i32) as u32;
        config.magnifier.size = magnifier::ensure_odd(config.magnifier.size as i32) as u32;
        config.magnifier.aim_size = magnifier::ensure_odd(config.magnifier.aim_size.max(1) as i32) as u32;
        if config.magnifier.aim_size > config.magnifier.aperture {
            config.magnifier.aim_size = config.magnifier.aperture;
        }

        let magnifier_font_size = config.font.size;
        let magnifier = magnifier::Magnifier::new(font_data, magnifier_font_size);
        let hud = hud::Hud::new(hud_font_data, scale_factor, config.hud.show);

        let active = canvas.active();
        let buf_width = active.capture.width;
        let buf_height = active.capture.height;

        Self {
            canvas,
            buf_width,
            buf_height,
            mouse_pos: None,
            physical_mouse_pos: None,
            scale_factor,
            config,
            backend_name,
            color_deck: Vec::new(),
            should_exit: false,
            first_redraw_time: Some(Instant::now()),
            last_frame_time: None,
            needs_redraw: false,
            dirty_rects: std::collections::VecDeque::with_capacity(12),
            warmed_buffers: HashMap::new(),
            blur_buf_1: Vec::new(),
            blur_buf_2: Vec::new(),
            magnifier,
            hud,
            flash_intensity: 0.0,
            repeat_tracker: None,
            blink: None,
            last_activity: Instant::now(),
            monitor_rect: None,
        }
    }

    /// Convenience: create from single-monitor ScreenCapture (Portal / KWin fallback).
    #[cfg(unix)]
    pub fn from_capture(
        capture: ScreenCapture,
        output: Option<wl_output::WlOutput>,
        config: Config,
        font_data: std::sync::Arc<Vec<u8>>,
        hud_font_data: std::sync::Arc<Vec<u8>>,
        backend_name: String,
        scale_factor: f64,
    ) -> Self {
        Self::new(PhysicalCanvas::from_single(capture, output), config, font_data, hud_font_data, backend_name, scale_factor)
    }

    /// Updates the physical mouse position from OS connectors.
    /// `x, y` — physical coordinates in the active tile's local space (not world).
    /// `world_x, world_y` — world coordinates for cross-monitor pixel sampling.
    pub fn update_physical_mouse(&mut self, x: f64, y: f64) {
        self.last_activity = Instant::now();
        self.physical_mouse_pos = Some((x, y));
        self.mouse_pos = Some((x, y));
        self.needs_redraw = true;
    }

    /// Take and return the collected color deck.
    pub fn take_color_deck(&mut self) -> Vec<Rgba<u8>> {
        std::mem::take(&mut self.color_deck)
    }

    /// Extract RGB from the XRGB u32 buffer of the active tile.
    pub fn get_pixel_rgba(&self, x: u32, y: u32) -> Rgba<u8> {
        let active = self.canvas.active();
        let idx = y as usize * active.capture.width as usize + x as usize;
        let val = active.capture.xrgb_buffer.get(idx).copied().unwrap_or(0);
        let r = ((val >> 16) & 0xFF) as u8;
        let g = ((val >> 8) & 0xFF) as u8;
        let b = (val & 0xFF) as u8;
        Rgba([r, g, b, 255])
    }

    pub fn sample_aim_color(&self, x: u32, y: u32) -> Rgba<u8> {
        let aim_radius = self.config.magnifier.aim_size.max(1) as i32 / 2;
        let (r, g, b) = self.canvas.sample_average(x as i32, y as i32, aim_radius);
        Rgba([r, g, b, 255])
    }

    /// Fast search for the next significant color change (Jump Target).
    /// Cuts through gradients and noise using a configurable sensitivity threshold.
    pub fn find_jump_target(&self, start_x: u32, start_y: u32, dx: i32, dy: i32) -> (f64, f64) {
        let base_color = self.get_pixel_rgba(start_x, start_y);
        let mut curr_x = start_x as i32;
        let mut curr_y = start_y as i32;
        let active = self.canvas.active();
        let w = active.capture.width as i32;
        let h = active.capture.height as i32;

        // Sensitivity threshold (radar sense). Configurable.
        let threshold = self.config.magnifier.jump_threshold;

        curr_x += dx;
        curr_y += dy;

        while curr_x >= 0 && curr_x < w && curr_y >= 0 && curr_y < h {
            let color = self.get_pixel_rgba(curr_x as u32, curr_y as u32);
            let diff_r = (base_color.0[0] as i32 - color.0[0] as i32).abs();
            let diff_g = (base_color.0[1] as i32 - color.0[1] as i32).abs();
            let diff_b = (base_color.0[2] as i32 - color.0[2] as i32).abs();
            
            // Use the maximum channel difference (Chebyshev distance for colors).
            let max_diff = diff_r.max(diff_g).max(diff_b);
            
            if max_diff > threshold {
                 break;
            }

            curr_x += dx;
            curr_y += dy;
        }

        // Clamp back to safe bounds in case we hit the screen edge.
        curr_x = curr_x.clamp(0, w - 1);
        curr_y = curr_y.clamp(0, h - 1);

        (curr_x as f64, curr_y as f64)
    }

    /// Minimum magnifier window size so text does not overflow the frame.
    /// Includes a 10 px margin top and bottom.
    fn min_window_for_text(&self) -> i32 {
        let h = self.magnifier.estimate_text_height(&self.config, None).ceil() as i32;
        if h > 0 { h + 20 } else { 0 }
    }

    /// Full render cache reset: all buffers are marked as "cold",
    /// dirty rects are cleared → next frame will be a full memcpy.
    /// Call only on complete background change (new capture, overlay exit).
    fn invalidate_render(&mut self) {
        self.warmed_buffers.clear();
        self.dirty_rects.clear();
    }

    /// Synchronizes buf_width/buf_height when the active monitor changes.
    /// Called from redraw() before each render in the Mirror architecture.
    ///
    /// Does NOT touch dirty_rects — managed by the connector via per-overlay swap.
    /// Does NOT touch warmed_buffers — keyed by SHM ptr address, unique per monitor.
    /// Entries for other monitors remain valid.
    pub fn sync_active_tile(&mut self) {
        let tile = self.canvas.active();
        self.buf_width = tile.capture.width;
        self.buf_height = tile.capture.height;
        
        // Dynamically adopt the scale of the active monitor.
        // This solves the problem of "huge HUD on 1:1 monitors".
        if (self.scale_factor - tile.scale).abs() > 0.01 {
            self.scale_factor = tile.scale;
            self.hud.update_scale(self.scale_factor);
            // Re-apply font size to recalculate properly scaled glyphs
            self.magnifier.update_scale(self.config.font.size);
        }
    }

    /// Universal entry point for user events from all platforms.
    /// Mutates overlay state in response to user intent.
    pub fn handle_action(&mut self, action: UserAction) {
        self.last_activity = Instant::now();
        match action {
            UserAction::Zoom(delta) => {
                // Adjust aperture (field of view).
                // Pure math: 10% step, minimum 2 pixels.
                // At current < 20, the curve matches the standard step 2 (micro-level).
                // Step is always even (bitwise & !1) to preserve the odd size invariant (Optical Monolith).
                let current = self.config.magnifier.aperture as i32;
                let limit = self.config.magnifier.size as i32;
                let step = (current / 10).max(2) & !1;
                let new_aperture = (current - delta * step).clamp(1, limit);

                if new_aperture as u32 != self.config.magnifier.aperture {
                    self.config.magnifier.aperture = new_aperture as u32;
                    // aim_size cannot exceed aperture
                    if self.config.magnifier.aim_size > self.config.magnifier.aperture {
                        self.config.magnifier.aim_size = self.config.magnifier.aperture;
                    }
                    self.invalidate_render();
                }
            }
            UserAction::ResizeMagnifier(delta) => {
                // Change the physical window size on screen.
                // Pure math: 10% step, minimum 2 pixels.
                // Step is always even (bitwise & !1) to preserve the odd size invariant (Optical Monolith).
                let current = self.config.magnifier.size as i32;
                let step = (current / 10).max(2) & !1;
                let mut new_size = (current + delta * step).clamp(15, 901);
                new_size = magnifier::ensure_odd(new_size);

                // --- Text floor (The Wall) ---
                // The magnifier window cannot shrink below the size of the text inside it.
                let min_text = self.min_window_for_text();
                if new_size < min_text {
                    new_size = min_text;
                    // Optical Monolith guarantee: even at the floor, size must remain odd.
                    new_size = magnifier::ensure_odd(new_size);
                }

                if new_size as u32 != self.config.magnifier.size {
                    self.config.magnifier.size = new_size as u32;

                    // If window shrank — pull aperture in so there's no "reducing glass" effect.
                    // Both values are odd, so centering stays intact.
                    if self.config.magnifier.aperture > self.config.magnifier.size {
                        self.config.magnifier.aperture = self.config.magnifier.size;
                    }
                    // aim_size cannot exceed aperture (cascading clamp following aperture).
                    if self.config.magnifier.aim_size > self.config.magnifier.aperture {
                        self.config.magnifier.aim_size = self.config.magnifier.aperture;
                    }

                    self.invalidate_render();
                }
            }
            UserAction::Nudge(dx, dy) => {
                // Precision 1-pixel aim nudge (Sniper mode).
                if let Some((x, y)) = self.mouse_pos {
                    let active = self.canvas.active();
                    let new_x = (x + dx as f64).clamp(0.0, active.capture.width as f64 - 1.0);
                    let new_y = (y + dy as f64).clamp(0.0, active.capture.height as f64 - 1.0);
                    self.mouse_pos = Some((new_x, new_y));
                    self.needs_redraw = true;

                    // Start repeat tracker only if the direction has changed.
                    // Otherwise the system repeat_key would reset our timer.
                    if !matches!(self.repeat_tracker, Some(ref r) if r.dx == dx && r.dy == dy && !r.is_jump) {
                        let now = Instant::now();
                        self.repeat_tracker = Some(RepeatState { dx, dy, is_jump: false, started: now, last_repeat: now });
                    }
                }
            }
            UserAction::Jump(dx, dy) => {
                // Hyperspace jump (to the next visual boundary).
                if let Some((x, y)) = self.mouse_pos {
                    let target = self.find_jump_target(x as u32, y as u32, dx, dy);
                    self.mouse_pos = Some(target);
                    self.needs_redraw = true;

                    // Start repeat tracker only if the direction has changed.
                    if !matches!(self.repeat_tracker, Some(ref r) if r.dx == dx && r.dy == dy && r.is_jump) {
                        let now = Instant::now();
                        self.repeat_tracker = Some(RepeatState { dx, dy, is_jump: true, started: now, last_repeat: now });
                    }
                }
            }
            UserAction::KeyRelease { dx, dy } => {
                // If the released key matches the currently running repeat — stop it.
                if matches!(self.repeat_tracker, Some(ref r) if r.dx == dx && r.dy == dy) {
                    self.repeat_tracker = None;
                }
            }
            UserAction::ChangeFontSize(delta) => {
                self.repeat_tracker = None; // Emergency stop: any font-size change halts movement
                // Change font size on the fly.
                // Renderer recalculates metrics without re-reading from disk.
                let current = self.config.font.size;
                
                #[allow(clippy::if_same_then_else)]
                let new_size = if current == 0.0 && delta > 0 {
                    10.0 // Wake from collapsed mode (Collapse -> Show)
                } else if current == 10.0 && delta < 0 {
                    0.0  // Collapse into hidden mode (Show -> Collapse)
                } else if current == 0.0 && delta < 0 {
                    0.0  // Already hidden
                } else {
                    (current + delta as f32 * 2.0).clamp(10.0, 200.0)
                };

                if (new_size - current).abs() > 0.1 {
                    self.config.font.size = new_size;
                    self.magnifier.update_scale(new_size);

                    // --- Organic text-pushes-frame floor ---
                    // If the new font is larger than the current window, text "pushes" the frame.
                    let min_text = self.min_window_for_text();
                    if min_text > self.config.magnifier.size as i32 {
                        self.config.magnifier.size = magnifier::ensure_odd(min_text) as u32;
                    }

                    self.invalidate_render();
                    self.hud.invalidate_cache();
                }
            }
            UserAction::ChangeAimSize(delta) => {
                // Pure math: 10% step, minimum 2 pixels.
                // Step is always even (bitwise & !1) to preserve the odd size invariant (Optical Monolith).
                // Capped at aperture — cannot average pixels that aren't displayed.
                let current = self.config.magnifier.aim_size as i32;
                let limit = self.config.magnifier.aperture as i32;
                let step = (current / 10).max(2) & !1;
                let mut new_aim = current + delta * step;
                new_aim = new_aim.clamp(1, limit);
                new_aim = magnifier::ensure_odd(new_aim);
                
                if new_aim as u32 != self.config.magnifier.aim_size {
                    self.config.magnifier.aim_size = new_aim as u32;
                    self.invalidate_render();
                }
            }
            UserAction::SelectFormatDigit(digit) => {
                self.repeat_tracker = None;
                // Select format [1..9, 0] -> indices [0..8, 9].
                let actual_idx = if digit == 0 { 9 } else { digit - 1 };
                if actual_idx < crate::core::config::TEMPLATE_LABELS.len() {
                    self.config.templates.selected = crate::core::config::TEMPLATE_LABELS
                        [actual_idx]
                        .0
                        .to_string();
                    self.needs_redraw = true;
                    // Clear dirty rects to force a full magnifier redraw in case text length changed.
                    self.invalidate_render();
                    self.hud.invalidate_cache();
                }
            }
            UserAction::ToggleHud => {
                self.repeat_tracker = None;
                self.config.hud.show = !self.config.hud.show;
                self.hud.toggle(self.config.hud.show);
                self.needs_redraw = true;
            }
            UserAction::PickColor { serial } => {
                self.repeat_tracker = None; // Emergency stop: picking a color interrupts movement
                if let Some((x, y)) = self.mouse_pos {
                    let color = self.sample_aim_color(x as u32, y as u32);
                    self.color_deck.push(color);

                    if serial {
                        // Serial mode: flash + continue working.
                        self.flash_intensity = 1.0;
                        self.needs_redraw = true;
                    } else {
                        // Final pick: log the final coordinates.
                        crate::core::terminal::log_plain("Coords", &format!("({}, {})", x as u32, y as u32));
                        // Launch blink effect or exit immediately.
                        if self.config.physics.blink_effect == "converge" {
                            let target_size = self.config.magnifier.size as f64;
                            let grid_size = magnifier::ensure_odd(target_size.round() as i32) as f32;

                            // Grab the TRUE visual center of the magnifier from its state, to avoid
                            // "Desync State" during edge reflections or high animation speeds.
                            let (center_x, center_y) = self.magnifier.get_aperture_center()
                                .unwrap_or((x as f32, y as f32));

                            // Build the train: all colors from the deck (including the final pick).
                            // Stagger between launches is fixed (~20ms), capped at 100ms total spread.
                            // Each square flies the full 300ms — same speed regardless of count.
                            let count = self.color_deck.len();
                            // Fixed 100ms spread, evenly divided between squares.
                            // 2 colors: 100ms gap. 5: 25ms. 10: 11ms — dense tail.
                            let spread = if count <= 1 { 0.0 } else { 0.1 };
                            let stagger_step = if count > 1 { spread / (count - 1) as f32 } else { 0.0 };

                            let squares: Vec<BlinkSquare> = self.color_deck.iter().enumerate().map(|(i, c)| {
                                let rgb = ((c.0[0] as u32) << 16)
                                         | ((c.0[1] as u32) << 8)
                                         | (c.0[2] as u32);
                                BlinkSquare { color: rgb, delay: i as f32 * stagger_step }
                            }).collect();

                            let fly_time = 0.3_f32; // same speed as single square

                            // IMPORTANT: reset background caches and dirty regions.
                            self.invalidate_render();

                            self.blink = Some(BlinkState {
                                origin: (center_x, center_y),
                                squares,
                                start_size: grid_size,
                                started: Instant::now(),
                                duration: fly_time + spread, // 1 color: 0.3s, many: up to 0.4s
                                fly_time,
                            });
                            self.needs_redraw = true;
                        } else {
                            self.should_exit = true;
                        }
                    }
                }
            }
            UserAction::Cancel => {
                self.repeat_tracker = None;
                self.color_deck.clear();
                self.should_exit = true;
            }
        }
    }

    pub fn update_scale(&mut self, scale: f64) {
        self.scale_factor = scale;
        self.magnifier.update_scale(self.config.font.size);
        self.hud.update_scale(scale);
        self.invalidate_render();
    }

    /// **Frame render**
    ///
    /// Called by the system whenever the window needs to be redrawn.
    /// Receives a raw `canvas` slice from the Wayland SHM buffer.
    ///
    /// Returns `true` if dirty rect was used (partial damage),
    /// `false` if a full repaint was performed (full damage).
    /// **Main overlay render loop.**
    ///
    /// Called by the connector (wayland.rs / x11.rs) on every frame callback from the compositor.
    /// Receives a raw u32 slice from the Wayland SHM buffer and draws directly into it.
    ///
    /// Operation order:
    ///   1. **dt / frame time** — compute delta, clamp to 100ms (protection from idle spikes).
    ///   2. **Dirty rect restore** — if buffer is "warm", restore only changed regions;
    ///      otherwise full memcpy background → canvas (first-time "warming").
    ///   3. **Flash decay** — white flash fade-out after a serial pick.
    ///   4. **Keyboard repeat** — custom auto-repeat (OS repeat is unreliable in Wayland).
    ///   5. **Blink / Normal** — either the final converge animation, or magnifier + HUD.
    ///
    /// Returns `true` (partial damage) or `false` (full damage) — signal for wayland.rs
    /// to select the `damage_buffer` region.
    pub fn render(&mut self, canvas: &mut [u32], width: u32, height: u32) -> bool {
        if width == 0 || height == 0 {
            return false;
        }

        // --- Watchdog: auto-cancel on inactivity ---
        let inactive_secs_f = self.last_activity.elapsed().as_secs_f32();
        let timeout = self.config.system.auto_cancel;

        if timeout > 0 && inactive_secs_f >= timeout as f32 {
            self.should_exit = true;
            crate::core::terminal::log_step("System", "Watchdog: Auto-cancel triggered due to inactivity.");
        }

        let now = std::time::Instant::now();
        let mut dt = self
            .last_frame_time
            .map(|t| t.elapsed().as_secs_f64())
            .unwrap_or(0.016);
        
        // Prevent massive animation skips after waking up from idle state (>100ms)
        if dt > 0.1 {
            dt = 0.016; // Start with safe 60FPS frame time
        }
        
        self.last_frame_time = Some(now);

        // Clone config out of self to avoid borrow conflicts.
        let w = width as usize;
        let h = height as usize;

        // --- Dirty Rect / Buffer Warming ---
        // Wayland uses several SHM buffers simultaneously (typically 2–3, round-robin).
        // Each buffer is a separate chunk of memory with a unique address.
        // "Warming" = the buffer has received at least one full background copy.
        // Only a warm buffer can be updated partially: restore background only in
        // the previous frame's dirty_rects, instead of a full ~32MB memcpy each frame.
        // A cold buffer (new address) ALWAYS gets a full copy — otherwise artifacts
        // from the previous buffer content would leak through partial updates.
        // --- Dirty Rect / Buffer Warming ---
        let active = self.canvas.active();
        let background = &active.capture.xrgb_buffer;
        
        let ptr = canvas.as_ptr() as usize;
        let tile_idx = self.canvas.active_idx;
        let is_warmed = self.warmed_buffers.get(&ptr) == Some(&tile_idx);

        let use_dirty = is_warmed && self.mouse_pos.is_some() && !self.dirty_rects.is_empty();

        if use_dirty {
            // Fast path: restore only previous dirty regions from background
            for &(dx, dy, dw, dh) in &self.dirty_rects {
                copy_region(canvas, background, w, h, dx, dy, dw, dh);
            }
        } else {
            // Slow path: full background copy (first time seeing this buffer address for this monitor)
            let copy_len = background.len().min(canvas.len());
            if copy_len < canvas.len() {
                canvas.fill(0xFF000000); // Black letterbox for uninitialized SHM areas
            }
            canvas[..copy_len].copy_from_slice(&background[..copy_len]);
            self.warmed_buffers.insert(ptr, tile_idx);
        }

        // Reset the animation-pending flag before drawing.
        self.needs_redraw = false;

        // If the application is already exiting (e.g. Blink just finished),
        // suppress UI rendering. No ghost frames!
        if self.should_exit {
            return use_dirty;
        }

        // --- Flash Feedback Decay ---
        if self.flash_intensity > 0.0 {
            self.flash_intensity -= (dt as f32 * 5.0).max(0.1); 
            if self.flash_intensity < 0.0 {
                self.flash_intensity = 0.0;
            }
            // Require redraw while flash is actively decaying
            self.needs_redraw = true;
        }

        // --- Custom keyboard auto-repeat (independent of OS) ---
        // Wayland's system key-repeat is unreliable: some compositors send events
        // irregularly or with delay. Our tracker is self-contained:
        //   - repeat_tracker is set on first press (Nudge / Jump)
        //   - delay=350ms pause before "go" (matching keyboard feel)
        //   - rate=30ms (nudge) or 120ms (jump) between steps
        //   - any other action (pick, cancel, format) resets the tracker
        // Logic lives here in render() to tick in step with frame callbacks,
        // not in a separate thread with sleeps.
        // IMPORTANT: repeat logic runs AFTER needs_redraw reset, otherwise it gets clobbered.
        if let Some(ref repeat) = self.repeat_tracker {
            // While key is held — keep the render loop spinning so the timer ticks.
            self.needs_redraw = true;
            self.last_activity = Instant::now();

            let elapsed = repeat.started.elapsed().as_millis() as u64;
            let delay = 350; // Initial pause before repeat kicks in
            let rate = if repeat.is_jump { 120 } else { 30 }; // Interval between steps (ms)
            let (rdx, rdy, is_jump) = (repeat.dx, repeat.dy, repeat.is_jump);

            if elapsed > delay && repeat.last_repeat.elapsed().as_millis() as u64 >= rate
                && let Some((x, y)) = self.mouse_pos {
                    if is_jump {
                        let target = self.find_jump_target(x as u32, y as u32, rdx, rdy);
                        self.mouse_pos = Some(target);
                    } else {
                        let new_x = (x + rdx as f64).clamp(0.0, self.buf_width as f64 - 1.0);
                        let new_y = (y + rdy as f64).clamp(0.0, self.buf_height as f64 - 1.0);
                        self.mouse_pos = Some((new_x, new_y));
                    }
                    // Safely update after releasing the immutable borrow.
                    self.repeat_tracker.as_mut().unwrap().last_repeat = Instant::now();
                }
        }

        // =====================================================================
        // --- FINAL BLINK ANIMATION (if active — replaces magnifier and HUD) ---
        // =====================================================================
        // "Train" — closing animation when blink_effect = "converge".
        // All colors from the deck (including the final pick) fly from magnifier center
        // to cursor along a parabolic arc with staggered delays. Total time = 300ms regardless
        // of square count. Each square: EaseOutQuad, start_size→4px, border 6→1px.
        // While blink is active: magnifier, HUD and satellite cursor are NOT drawn.
        if let Some(ref blink) = self.blink {
            let global_t = blink.started.elapsed().as_secs_f32();
            if global_t >= blink.duration {
                self.blink = None;
                self.should_exit = true;
            } else {
                self.needs_redraw = true;

                // Target = current mouse position (cursor may have moved!).
                let target = self.mouse_pos
                    .map(|p| (p.0 as f32, p.1 as f32))
                    .unwrap_or(blink.origin);

                // Draw each train square (earlier ones underneath later ones).
                for sq in &blink.squares {
                    let local_t = global_t - sq.delay;
                    if local_t < 0.0 { continue; } // hasn't launched yet
                    let t = (local_t / blink.fly_time).min(1.0);
                    if t >= 1.0 { continue; } // already landed

                    // EaseOutQuad: fast start, smooth deceleration.
                    let ease = 1.0 - (1.0 - t) * (1.0 - t);

                    let base_x = blink.origin.0 + (target.0 - blink.origin.0) * ease;
                    let base_y = blink.origin.1 + (target.1 - blink.origin.1) * ease;

                    // Parabolic arc for the "hop" feel.
                    let dx = target.0 - blink.origin.0;
                    let hop_height = dx.abs() * 0.1 + 15.0;
                    let arc_offset = t * (1.0 - t) * 4.0 * hop_height;

                    let px = base_x;
                    let py = base_y - arc_offset;

                    // Size: from start_size down to 4px.
                    let size = (blink.start_size * (1.0 - ease) + 4.0).round() as i32;
                    let border = (1.0 * (1.0 - ease)).round() as i32;
                    let border = border.clamp(1, (size - 2).max(2) / 2);

                    let half = size / 2;
                    let bx = px as i32 - half;
                    let by = py as i32 - half;

                    for row in by.max(0)..(by + size).min(h as i32) {
                        for col in bx.max(0)..(bx + size).min(w as i32) {
                            let idx = row as usize * w + col as usize;
                            let is_border = row < by + border
                                         || row >= by + size - border
                                         || col < bx + border
                                         || col >= bx + size - border;

                            if is_border {
                                canvas[idx] = 0x00FFFFFF;
                            } else {
                                canvas[idx] = sq.color;
                            }
                        }
                    }
                }

                // Dirty rect for the full train (origin → target, max size).
                let full_size = blink.start_size as i32;
                let ox = blink.origin.0 as i32;
                let oy = blink.origin.1 as i32;
                let tx = target.0 as i32;
                let ty = target.1 as i32;
                let drx = (ox.min(tx) - full_size / 2 - 2).max(0);
                let dry = (oy.min(ty) - full_size - 2).max(0); // extra height for arc
                let drx2 = (ox.max(tx) + full_size / 2 + 2).min(w as i32);
                let dry2 = (oy.max(ty) + full_size / 2 + 2).min(h as i32);
                self.dirty_rects.push_back((drx, dry, (drx2 - drx) as usize, (dry2 - dry) as usize));
            }
        } else {
            // =====================================================================
            // --- NORMAL RENDERING (magnifier, satellite cursor, color deck, HUD) ---
            // =====================================================================
            
            // Draw magnifier and obtain precise render bounding box.
            if let Some(pos) = self.mouse_pos {
                let mut satellite_bounds = None;
                if let Some(phys) = self.physical_mouse_pos {
                    let dx = pos.0 - phys.0;
                    let dy = pos.1 - phys.1;
                    let dist = (dx * dx + dy * dy).sqrt();
                    // Draw satellite if the system cursor has lagged behind the logical aim.
                    // Magnifier is drawn on top (reading from the active tile canvas), so
                    // if it overlaps the satellite it will cleanly and correctly cover it.
                    if dist > 10.0 {
                        satellite_bounds = Some(shapes::draw_satellite_cursor(
                            canvas, w, h, pos.0 as i32, pos.1 as i32
                        ));
                    }
                }

                // --- Watchdog border pulse (warning before auto-exit) ---
                let timeout_f = timeout as f32;
                let warning_start = (timeout_f - 10.0).max(0.0);

                let border_color = if timeout > 0 && inactive_secs_f > warning_start {
                    self.needs_redraw = true; // keep render loop alive for animation
                    let progress = (inactive_secs_f - warning_start) / 10.0; // 0.0 -> 1.0

                    // Frequency: 0.5Hz (slow breath) → 2.5Hz (noticeable alarm)
                    let freq = 0.5 + progress * 2.0;
                    let pulse = (inactive_secs_f * std::f32::consts::PI * 2.0 * freq).sin() * 0.5 + 0.5;

                    // lerp: theme frame color → red
                    let r_base = ((self.config.colors.frame >> 16) & 0xFF) as f32;
                    let g_base = ((self.config.colors.frame >> 8) & 0xFF) as f32;
                    let b_base = (self.config.colors.frame & 0xFF) as f32;

                    let r = (r_base * (1.0 - pulse) + 255.0 * pulse) as u32;
                    let g = (g_base * (1.0 - pulse) + 30.0 * pulse) as u32; // cleaner red
                    let b = (b_base * (1.0 - pulse) + 30.0 * pulse) as u32;

                    (0xFF << 24) | (r << 16) | (g << 8) | b
                } else {
                    self.config.colors.frame
                };

                // Since sample() handles boundaries smoothly using local coords, we pass local directly.
                let ctx = magnifier::RenderCtx {
                    config: &self.config,
                    theme: &self.config.colors,
                    canvas: &self.canvas,
                    mouse_pos: pos,
                    local_mx: pos.0 as i32,
                    local_my: pos.1 as i32,
                    dt,
                    flash_intensity: self.flash_intensity,
                    frame_color: border_color,
                    monitor_rect: self.monitor_rect,
                };
                let (bounds, is_animating) = self.magnifier.render(
                    canvas, w, h, &ctx,
                    &mut self.blur_buf_1, &mut self.blur_buf_2,
                );

                if is_animating {
                    self.needs_redraw = true;
                }

                let mut final_bounds = bounds;

                // --- DRAW COLOR DECK ---
                if !self.color_deck.is_empty() {
                    let (mag_start_x, mag_start_y, mag_total_w, mag_h) = bounds;
                    let mag_w = mag_h; // Since magnifier is always square, its outer width = outer height
                    
                    let deck_bounds = shapes::draw_color_deck(
                        canvas,
                        w,
                        h,
                        mag_start_x,
                        mag_start_y + mag_h as i32 + 2,
                        mag_w,
                        &self.color_deck,
                        border_color,
                    );
                    
                    // Merge bounds (Union of Magnifier rect and Deck rect)
                    let f_x = mag_start_x.min(deck_bounds.0);
                    let f_y = mag_start_y.min(deck_bounds.1);
                    
                    let f_w = (mag_start_x + mag_total_w as i32).max(deck_bounds.0 + deck_bounds.2 as i32) - f_x;
                    let f_h = (mag_start_y + mag_h as i32).max(deck_bounds.1 + deck_bounds.3 as i32) - f_y;

                    final_bounds = (f_x, f_y, f_w as usize, f_h as usize);
                }

                while self.dirty_rects.len() >= 10 {
                    self.dirty_rects.pop_front();
                }
                if let Some(sb) = satellite_bounds {
                    self.dirty_rects.push_back(sb);
                }
                self.dirty_rects.push_back(final_bounds);

            } else if !self.dirty_rects.is_empty() {
                self.dirty_rects.clear();
                self.magnifier.reset();
                self.last_frame_time = None;
                self.hud.reset(self.config.hud.show);
            }

            // --- HUD: update() and render() are intentionally separated ---
            // update() advances physics (proximity detection, departure timer, spring) and
            // returns needs_redraw. Always called — even when HUD is fully hidden,
            // so the spring keeps ticking and the HUD slides smoothly off screen.
            // render() draws to canvas only if HUD is at least partially visible
            // (offset_x > VISIBILITY_THRESHOLD), returns dirty rect or None.
            if self.hud.update(dt, self.mouse_pos, self.config.hud.show, self.scale_factor) {
                self.needs_redraw = true;
            }

            let active_tile = self.canvas.active();
            if let Some(hud_bounds) = self.hud.render(
                canvas, w, h, &active_tile.capture.xrgb_buffer,
                &mut self.blur_buf_1, &mut self.blur_buf_2,
                &self.config, &self.config.colors, &self.backend_name, self.scale_factor,
            ) {
                self.dirty_rects.push_back(hud_bounds);
            }
        }

        if let Some(start) = self.first_redraw_time.take() {
            let elapsed = start.elapsed().as_millis();
            crate::core::terminal::log_step("Perf", &format!("First Redraw completed in {}ms", elapsed));
        }

        use_dirty
    }
}

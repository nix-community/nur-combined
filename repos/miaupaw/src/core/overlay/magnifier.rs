use super::primitives::{draw_filled_rect, draw_rect};
use crate::core::capture::PhysicalCanvas;
use crate::core::text::TextRenderer;
use crate::core::overlay::glass::draw_frosted_rect;
use crate::core::config::{ColorsConfig, Config};

/// Read-only rendering context passed from the overlay orchestrator.
/// Keeps magnifier's render() signature stable as new effects are added.
pub struct RenderCtx<'a> {
    pub config: &'a Config,
    pub theme: &'a ColorsConfig,
    pub canvas: &'a PhysicalCanvas,
    pub mouse_pos: (f64, f64),
    pub local_mx: i32,              // physical px, local to active tile — for cross-monitor sampling via canvas.sample()
    pub local_my: i32,              // physical px, local to active tile — for cross-monitor sampling via canvas.sample()
    pub dt: f64,
    pub flash_intensity: f32,
    pub frame_color: u32,
    // Current monitor bounds in canvas-local coords (x, y, w, h).
    // Magnifier clamps to this rect so it never crosses monitor boundaries.
    // None → fall back to full canvas bounds.
    pub monitor_rect: Option<(i32, i32, i32, i32)>,
}

const MARGIN: usize = 1;

/// Single source of truth: rounds value up to the nearest odd number.
/// Critical for the "Optical Monolith" — perfect aim centering on a single pixel.
pub fn ensure_odd(v: i32) -> i32 {
    if v % 2 == 0 { v + 1 } else { v }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_ensure_odd() {
        assert_eq!(ensure_odd(10), 11);
        assert_eq!(ensure_odd(11), 11);
        assert_eq!(ensure_odd(0), 1);
        assert_eq!(ensure_odd(-2), -1);
    }
}

/// Self-contained Magnifier entity.
/// Owns its own physics (anim_pos, anim_vel) and text renderer.
pub struct Magnifier {
    anim_pos: Option<(f64, f64)>,
    anim_vel: (f64, f64),

    // --- Smooth Zoom and Resize ---
    anim_size: Option<f64>,
    anim_size_vel: f64,
    anim_text_w: Option<f64>,
    anim_text_w_vel: f64,

    text_renderer: TextRenderer,
    total_time: f64,
}

impl Magnifier {
    pub fn new(font_data: std::sync::Arc<Vec<u8>>, font_size: f32) -> Self {
        Self {
            anim_pos: None,
            anim_vel: (0.0, 0.0),
            anim_size: None,
            anim_size_vel: 0.0,
            anim_text_w: None,
            anim_text_w_vel: 0.0,
            text_renderer: TextRenderer::new(font_data, font_size),
            total_time: 0.0,
        }
    }

    pub fn reset(&mut self) {
        self.anim_pos = None;
        self.anim_vel = (0.0, 0.0);
        self.anim_size = None;
        self.anim_size_vel = 0.0;
        self.anim_text_w = None;
        self.anim_text_w_vel = 0.0;
        self.total_time = 0.0;
    }

    pub fn update_scale(&mut self, font_size: f32) {
        self.text_renderer.update_size(font_size);
    }

    /// Returns the exact center of the magnifier window, accounting for physics and scaling.
    /// Used to synchronize the "blink" flash from the real visual position of the magnifier.
    pub fn get_aperture_center(&self) -> Option<(f32, f32)> {
        match (self.anim_pos, self.anim_size) {
            (Some((x, y)), Some(size)) => {
                let grid_size = ensure_odd(size.round() as i32) as f32;
                // + 1.0 to compensate for magnifier border (MARGIN = 1)
                let cx = x as f32 + 1.0 + grid_size / 2.0;
                let cy = y as f32 + 1.0 + grid_size / 2.0;
                Some((cx, cy))
            }
            _ => None,
        }
    }

    /// Prepares color text for display (with padding).
    /// Single source of truth for string construction, used in both render() and estimate.
    fn prepare_text(&self, config: &Config, r: u8, g: u8, b: u8) -> String {
        let visual_template = config.templates.get_visual_template();
        let display_template = crate::core::config::transform_template_for_display(&visual_template);
        let display_color = crate::core::formats::format_color(
            &display_template, r, g, b, config.templates.float_precision,
        );

        let display_lines: Vec<String> = display_color
            .split('\n')
            .map(|line| {
                format!(
                    "{}{}{}",
                    config.font.padding_left, line, config.font.padding_right
                )
            })
            .collect();
        display_lines.join("\n")
    }

    /// Estimates text block height for the given font size (or current if None).
    /// Used for the "bidirectional stop" of window and font physics.
    pub fn estimate_text_height(&self, config: &Config, override_font_size: Option<f32>) -> f32 {
        let active_size = override_font_size.unwrap_or(config.font.size);
        if active_size <= 0.0 {
            return 0.0;
        }

        // Use dummy black color for measurement (monospace text height is independent of values)
        let full_text = self.prepare_text(config, 0, 0, 0);

        let scale_mod = config.templates.get_current_scale_modifier();
        let line_spacing = config.templates.show.line_spacing;

        if let Some(fs) = override_font_size {
            // If a new size is provided, compute metrics on the fly without mutating state
            let temp_renderer = TextRenderer::new(self.text_renderer.font_data.clone(), fs);
            let (_, height) = temp_renderer.measure_text_bounds(&full_text, scale_mod, line_spacing);
            height
        } else {
            let (_, height) = self.text_renderer.measure_text_bounds(&full_text, scale_mod, line_spacing);
            height
        }
    }

    /// **Physics + magnifier render in one call.**
    ///
    /// Called from `OverlayApp::render()` every frame when `mouse_pos` is present.
    /// Combines three phases:
    ///
    ///   1. **Springs (Implicit Euler, O(1)):**
    ///      Animates `anim_size` (physical size), `anim_text_w` (text block width)
    ///      and `anim_pos` (screen position). Uses implicit Euler with divisor
    ///      `f = 1 + damping·dt + stiffness·dt²` — unconditionally stable at any dt,
    ///      no sub-step loops, no explosions on Wayland lag.
    ///
    ///   2. **Geometry:**
    ///      Computes `target_x/y` — magnifier position to the right of cursor (config offset).
    ///      If it doesn't fit on the right — flips to the left: `target_x = mx - total_width`.
    ///      Clamp ensures the magnifier stays within buffer bounds.
    ///
    ///   3. **Render:**
    ///      Border → black fill → zoomed pixels → frosted glass → hex text → flash.
    ///
    /// Returns `(bounds, is_animating)`:
    ///   - `bounds` = `(start_x, start_y, total_width, total_height)` for dirty rect
    ///   - `is_animating` = true while at least one spring hasn't settled
    pub fn render(
        &mut self,
        buffer: &mut [u32],
        width: usize,
        height: usize,
        ctx: &RenderCtx,
        blur_buf_1: &mut Vec<u32>,
        blur_buf_2: &mut Vec<u32>,
    ) -> ((i32, i32, usize, usize), bool) {
        let config = ctx.config;
        let theme = ctx.theme;
        let canvas = ctx.canvas;
        let mouse_pos = ctx.mouse_pos;
        let local_mx = ctx.local_mx;
        let local_my = ctx.local_my;
        let dt = ctx.dt;
        let flash_intensity = ctx.flash_intensity;
        let frame_color = ctx.frame_color;

        let target_size = config.magnifier.size as f64;

        let stiffness = config.physics.stiffness;
        let damping = config.physics.damping;
        let pop_effect = config.physics.pop_effect;

        self.total_time += dt;

        // --- Springs: pre-computed divisor (Implicit Euler) ---
        // f = 1 + damping·dt + stiffness·dt² — denominator of implicit integration scheme.
        // Makes the system unconditionally stable: at any dt (even 200ms after idle)
        // velocity decreases, not explodes. One divisor for all three springs per frame.
        let f = 1.0 + damping * dt + stiffness * dt * dt;

        // 1. Size animation
        // pop_effect = 0.0 → instant appear (anim_size starts at target_size).
        // pop_effect > 0.0 → spawn animation: start from 0, stiffness = stiffness * pop_effect.
        let pop_stiffness = stiffness * pop_effect;
        let pop_f = 1.0 + damping * dt + pop_stiffness * dt * dt;
        let mut cur_size = self.anim_size.unwrap_or(if pop_effect == 0.0 { target_size } else { 0.0 });
        let ds = target_size - cur_size;
        self.anim_size_vel = (self.anim_size_vel + dt * pop_stiffness * ds) / pop_f;
        cur_size += self.anim_size_vel * dt;

        // Stop thresholds for size
        if (cur_size - target_size).abs() < 0.1 && self.anim_size_vel.abs() < 0.1 {
            cur_size = target_size;
            self.anim_size_vel = 0.0;
        }
        self.anim_size = Some(cur_size);

        // --- Physical Optical Monolith Guarantee ---
        // Even if the logical size is odd, after scaling (e.g. 1.25x)
        // the physical screen size may become even, breaking aim centering.
        // We forcibly make the physical grid odd.
        let mut grid_size = cur_size.round() as usize;
        grid_size = ensure_odd(grid_size as i32) as usize;

        let aperture = config.magnifier.aperture as usize;
        let pixel_scale = grid_size as f64 / aperture as f64;

        let mx = mouse_pos.0 as i32;
        let my = mouse_pos.1 as i32;

        // Sample color: average over aim_size×aim_size area (radius=0 → single pixel)
        let aim_radius = config.magnifier.aim_size.max(1) as i32 / 2;
        let (r, g, b) = canvas.sample_average(local_mx, local_my, aim_radius);

        let scale_mod = config.templates.get_current_scale_modifier();
        let line_spacing = config.templates.show.line_spacing;

        // --- Text: one prepare_text call per frame ---
        // Build the display string once — needed for width measurement (measure)
        // and rendering (draw_hex_text). At font.size=0 (collapsed mode) text is hidden,
        // target_text_w=0.0, and the spring smoothly collapses the text block to zero.
        let full_text = if config.font.size > 0.0 {
            Some(self.prepare_text(config, r, g, b))
        } else {
            None
        };

        let (target_text_w, target_text_h) = match &full_text {
            Some(text) => {
                let (w, h) = self.text_renderer.measure_text_bounds(text, scale_mod, line_spacing);
                (w.ceil() as f64, h.ceil() as usize)
            }
            None => (0.0, 0),
        };

        let mut cur_text_w = self.anim_text_w.unwrap_or(target_text_w);
        let dw = target_text_w - cur_text_w;
        self.anim_text_w_vel = (self.anim_text_w_vel + dt * stiffness * dw) / f;
        cur_text_w += self.anim_text_w_vel * dt;

        if (cur_text_w - target_text_w).abs() < 0.1 && self.anim_text_w_vel.abs() < 0.1 {
            cur_text_w = target_text_w;
            self.anim_text_w_vel = 0.0;
        }
        self.anim_text_w = Some(cur_text_w);

        let text_box_width = cur_text_w.round() as usize;

        let magnifier_outer_width = grid_size + (MARGIN * 2);
        let magnifier_outer_height = grid_size + (MARGIN * 2);
        let text_outer_width = if text_box_width > 0 { text_box_width + (MARGIN * 2) } else { 0 };
        let total_width = if text_box_width > 0 { magnifier_outer_width + text_outer_width - MARGIN } else { magnifier_outer_width };

        //   target_x = mx - total_width - offset_x
        // --- Geometry: positioning with edge reflection ---
        // By default the magnifier sits to the right of the cursor (config offset_x)
        // and centers vertically on it (offset_y).
        // If magnifier + text block don't fit on the right — flip to the left:
        //   target_x = mx - total_width - offset_x
        // Similarly vertically: if we overflow the bottom edge — clamp to it.
        // Clamp ensures the magnifier doesn't go past the left/top screen edge.
        //
        // All position target calculations use final sizes (target_size, target_text_w),
        // not animated values (cur_size, cur_text_w). Otherwise the target drifts as the
        // magnifier grows — it "slides" instead of growing in place.
        let final_grid_size = ensure_odd(target_size.round() as i32) as usize;
        let final_outer_height = final_grid_size + (MARGIN * 2);
        let final_outer_width = final_grid_size + (MARGIN * 2);
        let final_text_outer_width = if target_text_w > 0.0 { target_text_w.ceil() as usize + (MARGIN * 2) } else { 0 };
        let final_total_width = if target_text_w > 0.0 { final_outer_width + final_text_outer_width - MARGIN } else { final_outer_width };

        let mut target_x = mx + config.magnifier.offset_x;
        let mut target_y = my - (final_outer_height as i32 / 2) + config.magnifier.offset_y;

        // Clamp to current monitor bounds (Windows multi-monitor) or full canvas (Wayland per-output).
        let (mon_x0, mon_y0, mon_x1, mon_y1) = match ctx.monitor_rect {
            Some((x, y, w, h)) => (x, y, x + w, y + h),
            None => (0, 0, width as i32, height as i32),
        };

        if target_x + final_total_width as i32 > mon_x1 {
            target_x = mx - final_total_width as i32 - config.magnifier.offset_x;
        }
        if target_y + final_outer_height as i32 > mon_y1 {
            target_y = mon_y1 - final_outer_height as i32;
        }
        target_x = target_x.max(mon_x0);
        target_y = target_y.max(mon_y0);

        let (mut current_x, mut current_y) = self.anim_pos.unwrap_or((mx as f64, my as f64));

        // While size is still animating — position uses the same stiffness as the size spring
        // (pop_stiffness) so both springs stay in sync. Afterwards — switch to global stiffness.
        let pos_stiffness = if (cur_size - target_size).abs() > 0.5 { pop_stiffness } else { stiffness };
        let pos_f = 1.0 + damping * dt + pos_stiffness * dt * dt;

        let dx = target_x as f64 - current_x;
        self.anim_vel.0 = (self.anim_vel.0 + dt * pos_stiffness * dx) / pos_f;
        current_x += self.anim_vel.0 * dt;

        let dy = target_y as f64 - current_y;
        self.anim_vel.1 = (self.anim_vel.1 + dt * pos_stiffness * dy) / pos_f;
        current_y += self.anim_vel.1 * dt;

        // Stop threshold for position
        if (current_x - target_x as f64).abs() < 0.1 && self.anim_vel.0.abs() < 0.1 {
            current_x = target_x as f64;
            self.anim_vel.0 = 0.0;
        }
        if (current_y - target_y as f64).abs() < 0.1 && self.anim_vel.1.abs() < 0.1 {
            current_y = target_y as f64;
            self.anim_vel.1 = 0.0;
        }

        let animating = cur_size != target_size 
                        || cur_text_w != target_text_w
                        || current_x != target_x as f64 || current_y != target_y as f64;

        self.anim_pos = Some((current_x, current_y));

        let start_x = current_x.round() as i32;
        let start_y = current_y.round() as i32;

        draw_rect(
            buffer, width, height, start_x, start_y, magnifier_outer_width, magnifier_outer_height, frame_color,
        );
        draw_filled_rect(
            buffer, width, height, start_x + 1, start_y + 1, grid_size, grid_size, 0x000000,
        );

        // bg_buf for glassmorphism = active tile's buffer (same physical monitor as the surface)
        let bg_buf = canvas.active().capture.xrgb_buffer.as_slice();

        let matrix_active = draw_zoomed_pixels(
            buffer, width, height, start_x, start_y, local_mx, local_my, canvas, pixel_scale, aperture, config.magnifier.aim_size as usize, theme, self.total_time,
        );

        if text_box_width > 0 && grid_size >= target_text_h {
            let text_box_start_x = start_x + magnifier_outer_width as i32 - MARGIN as i32;
            draw_rect(
                buffer, width, height, text_box_start_x, start_y, text_outer_width, magnifier_outer_height, frame_color,
            );

            draw_frosted_rect(
                buffer, width, height, text_box_start_x + 1, start_y + 1, text_box_width, magnifier_outer_height - 2,
                bg_buf, blur_buf_1, blur_buf_2, config.physics.blur_radius, theme.background, config.physics.glass_opacity,
            );

            if let Some(ref text) = full_text {
                draw_hex_text(
                    buffer, width, height, text_box_start_x + 1, start_y + 1, text_box_width, magnifier_outer_height - 2,
                    text, theme.foreground, &self.text_renderer, scale_mod, line_spacing, config.font.dim_zeros, true,
                );
            }
        }

        // --- Flash Feedback (click flash) ---
        if flash_intensity > 0.0 {
            // Draw white fill over the magnifier
            // Intensity (0..1) maps to opacity
            let alpha = (flash_intensity * 255.0) as u32;
            let fx = start_x + 1;
            let fy = start_y + 1;
            let fw = grid_size;
            let fh = grid_size;
            
            for row in (fy.max(0) as usize)..((fy + fh as i32).max(0) as usize).min(height) {
                let row_start = row * width;
                for col in (fx.max(0) as usize)..((fx + fw as i32).max(0) as usize).min(width) {
                    let idx = row_start + col;
                    let bg = buffer[idx];
                    let r = ((bg >> 16) & 0xFF) as u8;
                    let g = ((bg >> 8) & 0xFF) as u8;
                    let b = (bg & 0xFF) as u8;
                    
                    let inv_a = 255 - alpha;
                    let nr = (((r as u32) * inv_a + 255 * alpha) / 255) as u8;
                    let ng = (((g as u32) * inv_a + 255 * alpha) / 255) as u8;
                    let nb = (((b as u32) * inv_a + 255 * alpha) / 255) as u8;
                    
                    buffer[idx] = ((nr as u32) << 16) | ((ng as u32) << 8) | (nb as u32);
                }
            }
        }

        ((start_x, start_y, total_width, magnifier_outer_height), animating || matrix_active)
    }
}

/// **Digital Rain Easter Egg: The Dual-Layer Rift.**
/// **Upscale aperture×aperture pixels from background buffer into grid_size×grid_size area.**
///
/// Each logical pixel becomes a `pixel_scale × pixel_scale` rectangle on screen.
/// Size is computed to avoid gaps: the end of the next pixel is computed as
/// `(gx+1) * pixel_scale` and rounded — covering the entire grid without holes.
///
/// If a src pixel is outside the background buffer (screen edge) — Easter Egg activates:
/// dual-layer Digital Rain (Matrix Rift). Layer 1 — bright fast stream,
/// layer 2 — dim slow background. Both generated procedurally via hash(coords + time),
/// zero allocations, zero state storage.
///
/// Called for pixels outside the captured screen bounds.
/// Two independent layers, procedurally generated via hash(coords) + time — no allocations.
///   - Layer 2 (background): dim, slow, every 8th column, 1px grid for depth effect.
///   - Layer 1 (foreground): bright, fast, every 3rd column, 2px wide.
fn matrix_rain_color(src_x: i32, src_y: i32, time: f32) -> u32 {
    // Layer 2: Deep background (dim and slow)
    let h2 = {
        let mut h = (src_x as u32).wrapping_add(0xDEADC0DE);
        h ^= h >> 16;
        h = h.wrapping_mul(0x85ebca6b);
        h ^= h >> 13;
        h = h.wrapping_mul(0xc2b2ae35);
        h ^= h >> 16;
        h
    };

    let mut color_final = 0x00010401; // base void of the Rift

    if (h2 % 8) == 0 { // slow background (every 8th column)
        let speed = 3.0 + (h2 % 12) as f32;
        let cycle = 200.0 + (h2 % 200) as f32;
        let y_logic = src_y as f32 - time * speed;
        let phase = (y_logic % cycle + cycle) % cycle;
        let norm = phase / cycle;
        if norm < 0.4 {
            // Dim green tail without a head
            let dim_green = (norm / 0.4 * 50.0) as u32 + 5;
            color_final = (dim_green << 8) | 0x01;
        }
    }

    // Layer 1: Main stream (bright and fast)
    // 2-pixel width for the "foreground" plane
    let col_idx = src_x.div_euclid(2);
    let h1 = {
        let mut h = col_idx as u32;
        h ^= h >> 16;
        h = h.wrapping_mul(0x85ebca6b);
        h ^= h >> 13;
        h = h.wrapping_mul(0xc2b2ae35);
        h ^= h >> 16;
        h
    };

    if (h1 % 3) == 0 {
        let speed = 40.0 + (h1 % 60) as f32;
        let cycle = 150.0 + (h1 % 100) as f32;
        let y_logic = src_y as f32 - time * speed;
        let phase = (y_logic % cycle + cycle) % cycle;
        let normalized = phase / cycle;

        if normalized < 0.3 {
            let tail = normalized / 0.3;
            color_final = if tail > 0.95 {
                0xE8FFE8 // blazing head
            } else if tail > 0.7 {
                0x20FF60 // bright center
            } else {
                let green = (tail * 180.0) as u32 + 20;
                green << 8
            };
        }
    }

    color_final
}

/// Draws the aim marker over the zoomed grid.
/// aim_size=1 → dot (1×1 grid pixel), aim_size>1 → NxN frame.
#[allow(clippy::too_many_arguments)]
fn draw_aim_marker(
    buffer: &mut [u32],
    width: usize,
    height: usize,
    start_x: i32,
    start_y: i32,
    src_radius: i32,
    aim_size: usize,
    pixel_scale: f64,
    color: u32,
) {
    let aim_radius = aim_size as i32 / 2;
    let aim_start_gx = src_radius - aim_radius;
    let aim_start_gy = src_radius - aim_radius;
    let aim_end_gx = src_radius + aim_radius + 1;
    let aim_end_gy = src_radius + aim_radius + 1;

    let aim_x_f = start_x as f64 + 1.0 + (aim_start_gx as f64 * pixel_scale);
    let aim_y_f = start_y as f64 + 1.0 + (aim_start_gy as f64 * pixel_scale);
    let aim_x_end_f = start_x as f64 + 1.0 + (aim_end_gx as f64 * pixel_scale);
    let aim_y_end_f = start_y as f64 + 1.0 + (aim_end_gy as f64 * pixel_scale);

    let ix = aim_x_f.round() as i32;
    let iy = aim_y_f.round() as i32;
    let iw = (aim_x_end_f.round() as i32 - ix).max(1) as usize;
    let ih = (aim_y_end_f.round() as i32 - iy).max(1) as usize;

    draw_rect(buffer, width, height, ix, iy, iw, ih, color);
}

/// At `pixel_scale > 20` draws a grid over pixels (only at high zoom levels).
/// Returns `true` if at least one pixel was out of bounds (for the `matrix_active` flag).
#[allow(clippy::too_many_arguments)]
fn draw_zoomed_pixels(
    buffer: &mut [u32],
    width: usize,
    height: usize,
    start_x: i32,
    start_y: i32,
    local_mx: i32,
    local_my: i32,
    canvas: &PhysicalCanvas,
    pixel_scale: f64,
    aperture: usize,
    aim_size: usize,
    theme: &ColorsConfig,
    total_time: f64,
) -> bool {
    let mut matrix_hit = false;
    let src_radius = aperture as i32 / 2;
    let time = total_time as f32;

    for gy in 0..aperture as i32 {
        for gx in 0..aperture as i32 {
            let src_x = local_mx + (gx - src_radius);
            let src_y = local_my + (gy - src_radius);

            let color_p = canvas.sample(src_x, src_y)
                .map(|px| px & 0x00FFFFFF)
                .unwrap_or_else(|| { matrix_hit = true; matrix_rain_color(src_x, src_y, time) });

            let draw_x_f = start_x as f64 + 1.0 + (gx as f64 * pixel_scale);
            let draw_y_f = start_y as f64 + 1.0 + (gy as f64 * pixel_scale);

            // To avoid gaps from rounding, compute the end of the next pixel
            let draw_x_next_f = start_x as f64 + 1.0 + ((gx + 1) as f64 * pixel_scale);
            let draw_y_next_f = start_y as f64 + 1.0 + ((gy + 1) as f64 * pixel_scale);

            let ix = draw_x_f.round() as i32;
            let iy = draw_y_f.round() as i32;
            let iw = (draw_x_next_f.round() as i32 - ix).max(1) as usize;
            let ih = (draw_y_next_f.round() as i32 - iy).max(1) as usize;

            draw_filled_rect(buffer, width, height, ix, iy, iw, ih, color_p);

            // Draw grid only if pixels are large enough
            if pixel_scale > 20.0 {
                draw_rect(buffer, width, height, ix, iy, iw, ih, theme.grid);
            }
        }
    }

    draw_aim_marker(buffer, width, height, start_x, start_y, src_radius, aim_size, pixel_scale, theme.aim);

    matrix_hit
}

/// **Render hex code with precise vertical centering in the text box.**
///
/// Centering is non-trivial due to font metric quirks:
///   - `top_offset` = distance from bbox top to baseline (font-dependent)
///   - `ascent` = height of glyphs above baseline
///
/// Formula: `draw_y = box_center_y - top_offset - (total_height / 2) - ascent + 2`
/// The `+2` correction is an empirical offset for optical alignment.
///
/// When `center_x = true`, each line is horizontally centered within `box_w`.
#[allow(clippy::too_many_arguments)]
fn draw_hex_text(
    buffer: &mut [u32],
    width: usize,
    height: usize,
    box_x: i32,
    box_y: i32,
    box_w: usize,
    box_h: usize,
    text: &str,
    text_color: u32,
    text_renderer: &TextRenderer,
    scale_modifier: f32,
    line_spacing: f32,
    dim_opacity: f32,
    center_x: bool,
) {
    let (_, total_text_height) =
        text_renderer.measure_text_bounds(text, scale_modifier, line_spacing);

    let mod_top_offset = text_renderer.metrics.top_offset * scale_modifier;
    let mod_ascent = text_renderer.metrics.ascent * scale_modifier;

    let box_center_y = box_y as f32 + (box_h as f32) / 2.0;
    let text_draw_y = box_center_y - mod_top_offset - (total_text_height / 2.0) - mod_ascent + 2.0;

    text_renderer.draw_text_scaled(
        buffer,
        width,
        height,
        box_x,
        text_draw_y as i32,
        text,
        text_color,
        scale_modifier,
        line_spacing,
        dim_opacity,
        center_x,
        box_w,
    );
}

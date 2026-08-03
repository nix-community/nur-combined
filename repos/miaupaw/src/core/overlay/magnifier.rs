use super::primitives::{draw_filled_rect, draw_rect};
use crate::core::capture::PhysicalCanvas;
use crate::core::text::TextRenderer;
use crate::core::overlay::glass::draw_frosted_rect;
use crate::core::config::{ColorsConfig, Config};

/// Input context for the SIMULATION phase (step): everything springs,
/// geometry and measurements need. Canvas is read-only color sampling.
pub struct StepCtx<'a> {
    pub config: &'a Config,
    pub canvas: &'a PhysicalCanvas,
    pub aim_pos: (f64, f64),
    pub local_mx: i32,              // physical px, local to active tile
    pub local_my: i32,
    /// Active tile buffer size — position clamp bounds.
    pub buf_w: usize,
    pub buf_h: usize,
    // Current monitor bounds in canvas-local coords (x, y, w, h).
    // None → fall back to full buffer bounds.
    pub monitor_rect: Option<(i32, i32, i32, i32)>,
}

/// Input context for the PAINT phase (draw): theme, flash, frame color.
pub struct DrawCtx<'a> {
    pub config: &'a Config,
    pub theme: &'a ColorsConfig,
    pub canvas: &'a PhysicalCanvas,
    pub local_mx: i32,
    pub local_my: i32,
    pub flash_intensity: f32,
    pub frame_color: u32,
}

/// Frame geometry computed by `step()` and consumed by `draw()`.
/// Plain data — positioning (edge-flip included) is testable without
/// a framebuffer.
pub struct Layout {
    pub start_x: i32,
    pub start_y: i32,
    pub grid_size: usize,
    pub outer_w: usize,
    pub outer_h: usize,
    pub text_box_width: usize,
    pub text_outer_width: usize,
    pub total_width: usize,
    pub target_text_h: usize,
    pub pixel_scale: f64,
    pub full_text: Option<String>,
    pub animating: bool,
}

const MARGIN: usize = 1;

/// Single source of truth: rounds value up to the nearest odd number.
/// Critical for the "Optical Monolith" — perfect aim centering on a single pixel.
pub fn ensure_odd(v: i32) -> i32 {
    if v % 2 == 0 { v + 1 } else { v }
}

#[cfg(test)]
#[path = "magnifier_tests.rs"]
mod tests;

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

    /// **Simulation phase: springs + geometry + measurements.**
    ///
    /// Called from `OverlayApp::update()` every tick while aim_pos is present.
    ///   1. Springs (Implicit Euler, O(1)): anim_size / anim_text_w / anim_pos.
    ///      `f = 1 + damping·dt + stiffness·dt²` — stable at any dt.
    ///   2. Geometry: position right of the cursor, edge-flip left when it
    ///      doesn't fit, clamp to monitor_rect (or buffer). Targets use FINAL
    ///      sizes, not animated ones — otherwise the magnifier "slides"
    ///      instead of growing in place.
    ///   3. Measurements: color sample (read-only canvas) → text → block size.
    ///
    /// Returns [`Layout`] — plain data for `draw()` and for tests.
    pub fn step(&mut self, dt: f64, ctx: &StepCtx) -> Layout {
        let config = ctx.config;
        let target_size = config.magnifier.size as f64;

        let stiffness = config.physics.stiffness;
        let damping = config.physics.damping;
        let pop_effect = config.physics.pop_effect;

        self.total_time += dt;

        // --- Springs: pre-computed divisor (Implicit Euler) ---
        let f = 1.0 + damping * dt + stiffness * dt * dt;

        // 1. Size animation. pop_effect=0 → instant; >0 → spawn from zero.
        let pop_stiffness = stiffness * pop_effect;
        let pop_f = 1.0 + damping * dt + pop_stiffness * dt * dt;
        let mut cur_size = self.anim_size.unwrap_or(if pop_effect == 0.0 { target_size } else { 0.0 });
        let ds = target_size - cur_size;
        self.anim_size_vel = (self.anim_size_vel + dt * pop_stiffness * ds) / pop_f;
        cur_size += self.anim_size_vel * dt;

        if (cur_size - target_size).abs() < 0.1 && self.anim_size_vel.abs() < 0.1 {
            cur_size = target_size;
            self.anim_size_vel = 0.0;
        }
        self.anim_size = Some(cur_size);

        // --- Physical Optical Monolith Guarantee ---
        let mut grid_size = cur_size.round() as usize;
        grid_size = ensure_odd(grid_size as i32) as usize;

        let aperture = config.magnifier.aperture as usize;
        let pixel_scale = grid_size as f64 / aperture as f64;

        let mx = ctx.aim_pos.0 as i32;
        let my = ctx.aim_pos.1 as i32;

        // Color sample under the aim (read-only) — feeds the text.
        let aim_radius = config.magnifier.aim_size.max(1) as i32 / 2;
        let (r, g, b) = ctx.canvas.sample_average(ctx.local_mx, ctx.local_my, aim_radius);

        let scale_mod = config.templates.get_current_scale_modifier();
        let line_spacing = config.templates.show.line_spacing;

        // Text: one prepare_text per tick. font.size=0 → collapsed (no text).
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

        // --- Geometry: positioning with edge reflection ---
        // Targets use final sizes (target_size, target_text_w), not animated
        // ones — otherwise the target drifts while growing.
        let final_grid_size = ensure_odd(target_size.round() as i32) as usize;
        let final_outer_height = final_grid_size + (MARGIN * 2);
        let final_outer_width = final_grid_size + (MARGIN * 2);
        let final_text_outer_width = if target_text_w > 0.0 { target_text_w.ceil() as usize + (MARGIN * 2) } else { 0 };
        let final_total_width = if target_text_w > 0.0 { final_outer_width + final_text_outer_width - MARGIN } else { final_outer_width };

        let mut target_x = mx + config.magnifier.offset_x;
        let mut target_y = my - (final_outer_height as i32 / 2) + config.magnifier.offset_y;

        // Clamp to the current monitor (Win32/X11 multi-monitor) or buffer (Wayland per-output).
        let (mon_x0, mon_y0, mon_x1, mon_y1) = match ctx.monitor_rect {
            Some((x, y, w, h)) => (x, y, x + w, y + h),
            None => (0, 0, ctx.buf_w as i32, ctx.buf_h as i32),
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

        // While size is settling — position uses the same stiffness (springs in sync).
        let pos_stiffness = if (cur_size - target_size).abs() > 0.5 { pop_stiffness } else { stiffness };
        let pos_f = 1.0 + damping * dt + pos_stiffness * dt * dt;

        let dx = target_x as f64 - current_x;
        self.anim_vel.0 = (self.anim_vel.0 + dt * pos_stiffness * dx) / pos_f;
        current_x += self.anim_vel.0 * dt;

        let dy = target_y as f64 - current_y;
        self.anim_vel.1 = (self.anim_vel.1 + dt * pos_stiffness * dy) / pos_f;
        current_y += self.anim_vel.1 * dt;

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

        Layout {
            start_x: current_x.round() as i32,
            start_y: current_y.round() as i32,
            grid_size,
            outer_w: magnifier_outer_width,
            outer_h: magnifier_outer_height,
            text_box_width,
            text_outer_width,
            total_width,
            target_text_h,
            pixel_scale,
            full_text,
            animating,
        }
    }

    /// **Paint phase: blit from a prepared Layout.**
    ///
    /// Border → black fill → zoomed pixels → frosted glass → text → flash.
    /// Mutates NO state. Returns (dirty-rect bounds, matrix_active — digital
    /// rain is visible and wants another frame).
    #[allow(clippy::too_many_arguments)]
    pub fn draw(
        &self,
        buffer: &mut [u32],
        width: usize,
        height: usize,
        layout: &Layout,
        ctx: &DrawCtx,
        blur_buf_1: &mut Vec<u32>,
        blur_buf_2: &mut Vec<u32>,
    ) -> ((i32, i32, usize, usize), bool) {
        let config = ctx.config;
        let theme = ctx.theme;
        let start_x = layout.start_x;
        let start_y = layout.start_y;

        draw_rect(
            buffer, width, height, start_x, start_y, layout.outer_w, layout.outer_h, ctx.frame_color,
        );
        draw_filled_rect(
            buffer, width, height, start_x + 1, start_y + 1, layout.grid_size, layout.grid_size, 0x000000,
        );

        // bg_buf for glassmorphism = active tile's buffer (same physical monitor)
        let bg_buf = ctx.canvas.active().capture.xrgb_buffer.as_slice();

        let matrix_active = draw_zoomed_pixels(
            buffer, width, height, start_x, start_y, ctx.local_mx, ctx.local_my, ctx.canvas,
            layout.pixel_scale, config.magnifier.aperture as usize,
            config.magnifier.aim_size as usize, config.magnifier.show_aim, theme, self.total_time,
        );

        if layout.text_box_width > 0 && layout.grid_size >= layout.target_text_h {
            let scale_mod = config.templates.get_current_scale_modifier();
            let line_spacing = config.templates.show.line_spacing;
            let text_box_start_x = start_x + layout.outer_w as i32 - MARGIN as i32;
            draw_rect(
                buffer, width, height, text_box_start_x, start_y, layout.text_outer_width, layout.outer_h, ctx.frame_color,
            );

            draw_frosted_rect(
                buffer, width, height, text_box_start_x + 1, start_y + 1, layout.text_box_width, layout.outer_h - 2,
                bg_buf, blur_buf_1, blur_buf_2, config.physics.blur_radius, theme.background, config.physics.glass_opacity,
            );

            if let Some(ref text) = layout.full_text {
                draw_hex_text(
                    buffer, width, height, text_box_start_x + 1, start_y + 1, layout.text_box_width, layout.outer_h - 2,
                    text, theme.foreground, &self.text_renderer, scale_mod, line_spacing, config.font.dim_zeros, true,
                );
            }
        }

        // --- Flash Feedback (click flash) ---
        if ctx.flash_intensity > 0.0 {
            // Blend towards white in packed RB|G: two channels per multiply,
            // 8.8 fixed-point weights (shift instead of dividing by 255).
            let a256 = ((ctx.flash_intensity * 256.0) as u32).min(256);
            let inv_a = 256 - a256;
            let white_rb = 0x00FF00FF * a256;
            let white_g = 0x0000FF00 * a256;
            let fx = start_x + 1;
            let fy = start_y + 1;
            let fw = layout.grid_size;
            let fh = layout.grid_size;

            for row in (fy.max(0) as usize)..((fy + fh as i32).max(0) as usize).min(height) {
                let row_start = row * width;
                for col in (fx.max(0) as usize)..((fx + fw as i32).max(0) as usize).min(width) {
                    let idx = row_start + col;
                    let bg = buffer[idx];
                    let rb = (((bg & 0x00FF00FF) * inv_a + white_rb) >> 8) & 0x00FF00FF;
                    let g = (((bg & 0x0000FF00) * inv_a + white_g) >> 8) & 0x0000FF00;
                    buffer[idx] = rb | g;
                }
            }
        }

        ((start_x, start_y, layout.total_width, layout.outer_h), matrix_active)
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
    show_aim: bool,
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

    if show_aim {
        draw_aim_marker(buffer, width, height, start_x, start_y, src_radius, aim_size, pixel_scale, theme.aim);
    }

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

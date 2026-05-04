/// HEAD-UP-DISPLAY (HUD) — Self-contained entity.
///
/// HUD owns its state (animation, cache, timers) and behavior (update + render).
/// OverlayApp calls `hud.update()` and `hud.render()` without knowing implementation details.
///
/// Lifecycle:
///   1. `update()` — proximity detection, lazy timer, spring physics → returns needs_redraw
///   2. `render()` — base layer, realtime accents, glitches → returns dirty rect
use std::time::Instant;

use super::primitives::{draw_filled_rect, draw_rect};
use crate::core::config::{ColorsConfig, Config, TEMPLATE_LABELS};
use crate::core::overlay::glass::draw_frosted_rect;
use crate::core::text::TextRenderer;

// ==============================================================================
// --- Layout Constants (Single Source of Truth) ---
// ==============================================================================

const HUD_WIDTH: f64 = 500.0;
const HUD_HEIGHT: f64 = 528.0;
const MARGIN_X: f64 = 120.0;
const MARGIN_Y: f64 = 132.0;
/// Position of a fully hidden HUD (off the left edge of the screen)
const OFF_SCREEN: f64 = -700.0;
/// Visibility threshold: if offset_x is further left — skip drawing entirely (GPU savings)
const VISIBILITY_THRESHOLD: f64 = -670.0;
/// "Fully hidden" threshold for the lazy timer
const HIDDEN_THRESHOLD: f64 = -680.0;
/// Danger zone: if cursor is closer — HUD hides
const PROXIMITY_X: f64 = 700.0;
const PROXIMITY_Y: f64 = 752.0;
/// HUD font size (fixed, independent of config.font.size)
const FONT_SIZE: f64 = 52.0;

// --- Colors ---
const ACCENT_RED: u32 = 0xFF3B3B;
const KEY_AMBER: u32 = 0xFFCC00;
const DESC_GRAY: u32 = 0xC0C0C0;
const BRACKET_DIM_AMBER: u32 = 0x60FFCC00;
const FORMAT_GREEN: u32 = 0x12FF0E;
const FOOTER_PURPLE: u32 = 0x8072FF;
const BACKEND_CYAN: u32 = 0x5eead4;

// ==============================================================================
// --- Chromatic Aberration State ---
// ==============================================================================

/// Parameters of a single chromatic aberration band.
struct ChromaBand {
    h_split_base: usize,
    band_y: usize,
    band_h: usize,
}

/// Persistent chromatic: spawns for a random duration, jitters every frame.
struct ChromaState {
    bands: Vec<ChromaBand>,
    born: Instant,
    duration_ms: u64,
}

/// Parameters of a single horizontal tearing band.
struct TearBand {
    band_y: usize,
    band_h: usize,
    shift: i32,
}

/// Persistent tearing: band shifts and jitters, then smoothly snaps back.
struct TearState {
    bands: Vec<TearBand>,
    born: Instant,
    duration_ms: u64,
}

// ==============================================================================
// --- The Entity ---
// ==============================================================================

pub struct Hud {
    // --- Animation ---
    pub(crate) offset_x: f64,
    is_animating: bool,
    is_stabilizing: bool,

    // --- Caching ---
    cache: Vec<u32>,
    cache_valid: bool,

    // --- Timers ---
    /// Monotonic clock (Instant), independent of NTP. Cheaper than SystemTime (~2ns vs ~50ns).
    birth_time: Instant,
    stop_time: Option<Instant>,
    departure_timer: Option<(Instant, f64)>,

    // --- Chromatic Aberration ---
    chroma_state: Option<ChromaState>,

    // --- Tearing ---
    tear_state: Option<TearState>,

    // --- Cold Boot Flag ---
    /// First frame of life. If the cursor is already in the danger zone — don't pretend
    /// we were here, just vanish silently. No panic allowed.
    just_reset: bool,

    // --- Own Text Renderer ---
    text_renderer: TextRenderer,
}

impl Hud {
    /// Creates HUD with initial state.
    pub fn new(font_data: std::sync::Arc<Vec<u8>>, scale_factor: f64, show: bool) -> Self {
        Self {
            offset_x: if show { 0.0 } else { OFF_SCREEN },
            is_animating: false,
            is_stabilizing: false,
            cache: Vec::new(),
            cache_valid: false,
            birth_time: Instant::now(),
            stop_time: None,
            departure_timer: None,
            just_reset: show,
            chroma_state: None,
            tear_state: None,
            text_renderer: TextRenderer::new(font_data, FONT_SIZE as f32 * scale_factor as f32),
        }
    }

    /// Instant response to tilde toggle.
    pub fn toggle(&mut self, show: bool) {
        if show {
            // "Tilde kick" — slide in immediately (negative timer bypasses the delay)
            self.departure_timer = Some((Instant::now(), -1.0));
        } else {
            self.departure_timer = None;
        }
    }

    /// Invalidates cache (called on format change, font change, etc.)
    pub fn invalidate_cache(&mut self) {
        self.cache_valid = false;
    }

    /// Reset on overlay close / cursor loss.
    pub fn reset(&mut self, show: bool) {
        self.offset_x = if show { 0.0 } else { OFF_SCREEN };
        self.stop_time = None;
        self.departure_timer = None;
        self.just_reset = show;
    }

    /// Updates font scale and invalidates cache.
    pub fn update_scale(&mut self, scale: f64) {
        self.text_renderer.update_size(FONT_SIZE as f32 * scale as f32);
        self.cache_valid = false;
    }

    /// **HUD animation update.**
    ///
    /// Contains all stateful logic: proximity detection, lazy departure timer, spring physics.
    /// Returns `true` if the overlay needs a redraw because of the HUD.
    pub fn update(&mut self, dt: f64, mouse_pos: Option<(f64, f64)>, show: bool, scale: f64) -> bool {
        let mut needs_redraw = false;

        // --- Target Position ---
        let mut target = 0.0;

        if !show {
            target = OFF_SCREEN;
        } else {
            // Survival Instincts: magnifier cursor comes too close → HUD hides
            if let Some((mx, my)) = mouse_pos {
                if mx < PROXIMITY_X * scale && my < PROXIMITY_Y * scale {
                    if self.just_reset {
                        // Cold start inside the danger zone — vanish silently, no drama
                        self.offset_x = OFF_SCREEN;
                    }
                    target = OFF_SCREEN;
                    self.departure_timer = None; // survival over style — hide immediately
                }
                // Reset flag only when cursor position is known —
                // Wayland may stay silent for several frames after startup
                self.just_reset = false;
            }
        }

        // --- Personality & Laziness ---
        // When the threat passes, the HUD doesn't pop up like a soulless script.
        // It waits a random 1.0–3.0 seconds, scanning the ether.
        let is_fully_hidden = self.offset_x <= HIDDEN_THRESHOLD;
        if target == 0.0 && is_fully_hidden
            && self.departure_timer.is_none() {
                let elapsed_ms = self.birth_time.elapsed().as_millis() as u64;
                let rand = (elapsed_ms % 2000) as f64 / 1000.0;
                self.departure_timer = Some((Instant::now(), 1.0 + rand));
            }

        // While the timer is ticking, keep the HUD in place
        if target == 0.0
            && let Some((start, delay)) = self.departure_timer
                && start.elapsed().as_secs_f64() < delay {
                    target = self.offset_x; // quietly waiting in the shelter...
                    needs_redraw = true;
                }

        // --- Spring Animation ---
        let diff = target - self.offset_x;
        if diff.abs() > 0.5 {
            let speed = if diff < 0.0 { 18.0 } else { 7.0 };
            // Never jump more than 40% per frame (guard against Wayland throttle 50+ms)
            self.offset_x += diff * (speed * dt).clamp(0.0, 0.4);
            needs_redraw = true;
            self.stop_time = None;
        } else if self.offset_x != target {
            self.offset_x = target;
            if target == 0.0 {
                // Arrived at home position — trigger arrival glitch
                self.stop_time = Some(Instant::now());
                needs_redraw = true;
            } else {
                self.stop_time = None;
            }
        }

        self.is_animating = diff.abs() > 0.5;

        // --- Stabilization (post-arrival glitch window) ---
        self.is_stabilizing = false;
        if let Some(stop) = self.stop_time {
            if stop.elapsed().as_secs_f64() < 1.0 {
                needs_redraw = true;
                self.is_stabilizing = true;
            } else {
                self.stop_time = None;
            }
        }

        // Continuous breathing pulse (when HUD is stationary and visible)
        if target == 0.0 && !self.is_animating {
            needs_redraw = true;
        }

        needs_redraw
    }

    /// **HUD rendering.**
    ///
    /// Returns dirty rect `(x, y, w, h)` if HUD was drawn, `None` if hidden.
    #[allow(clippy::too_many_arguments)]
    pub fn render(
        &mut self,
        canvas: &mut [u32],
        width: usize,
        height: usize,
        bg_buffer: &[u32],
        blur_buf_1: &mut Vec<u32>,
        blur_buf_2: &mut Vec<u32>,
        config: &Config,
        theme: &ColorsConfig,
        backend_name: &str,
        scale: f64,
    ) -> Option<(i32, i32, usize, usize)> {
        if self.offset_x <= VISIBILITY_THRESHOLD {
            return None;
        }
        // Cursor position still unknown — don't show prematurely
        if self.just_reset {
            return None;
        }

        // --- Active Format Label ---
        let active_label = TEMPLATE_LABELS
            .iter()
            .find(|(k, _)| *k == config.templates.selected)
            .map(|(_, v)| *v)
            .unwrap_or("Unknown");

        let hud_w = (HUD_WIDTH * scale).round() as usize;
        let hud_h = (HUD_HEIGHT * scale).round() as usize;
        let x = ((MARGIN_X + self.offset_x) * scale).round() as i32;
        let y = (MARGIN_Y * scale).round() as i32;

        // Clipping
        let draw_x = x.max(0).min(width as i32);
        let draw_y = y.max(0).min(height as i32);
        let draw_x2 = (x + hud_w as i32).max(0).min(width as i32);
        let draw_y2 = (y + hud_h as i32).max(0).min(height as i32);
        let uw = (draw_x2 - draw_x) as usize;
        let uh = (draw_y2 - draw_y) as usize;
        let cx_offset = (draw_x - x) as usize;
        let cy_offset = (draw_y - y) as usize;

        // --- Caching ---
        if self.is_animating || !self.cache_valid || self.cache.len() != hud_w * hud_h {
            draw_base(
                canvas, width, height, bg_buffer, blur_buf_1, blur_buf_2,
                &self.text_renderer, config, theme,
                x, y, hud_w, hud_h, backend_name, scale, active_label,
            );

            // Save to cache only when animation has settled
            if !self.is_animating && uw > 0 && uh > 0 {
                self.cache.resize(hud_w * hud_h, 0);
                for cy in 0..uh {
                    let src_idx = (draw_y as usize + cy) * width + draw_x as usize;
                    let cache_idx = (cy_offset + cy) * hud_w + cx_offset;
                    self.cache[cache_idx..cache_idx + uw]
                        .copy_from_slice(&canvas[src_idx..src_idx + uw]);
                }
                self.cache_valid = true;
            }
        } else if uw > 0 && uh > 0 {
            // Fast path: blit from cache
            for cy in 0..uh {
                let dst_idx = (draw_y as usize + cy) * width + draw_x as usize;
                let src_idx = (cy_offset + cy) * hud_w + cx_offset;
                canvas[dst_idx..dst_idx + uw]
                    .copy_from_slice(&self.cache[src_idx..src_idx + uw]);
            }
        }

        // --- Realtime Accents (breathing slashes) ---
        let elapsed_ms = self.birth_time.elapsed().as_millis() as u64;

        draw_realtime_accents(
            canvas, width, height, x, y, hud_w, hud_h,
            scale, &self.text_renderer, elapsed_ms, true,
        );

        // --- Glitches ---
        let is_glitching = self.is_animating || self.is_stabilizing;

        // --- Persistent Tearing ---
        // Lifecycle mirrors chromatic: spawn → jitter → fade out.
        let tear_expired = self.tear_state.as_ref()
            .map(|ts| ts.born.elapsed().as_millis() >= ts.duration_ms as u128)
            .unwrap_or(true);

        if tear_expired {
            self.tear_state = None;
            if is_glitching {
                let mut seed = elapsed_ms as u32 ^ 0x7E_A8_BA_5E;
                let mut rng = || -> u32 { seed ^= seed << 13; seed ^= seed >> 17; seed ^= seed << 5; seed };

                let heavy_chance = config.hud.heavy_glitch_chance;
                let light_chance = config.hud.light_glitch_chance;

                let is_heavy = (rng() % 100) < heavy_chance;
                let is_light = (rng() % 100) < light_chance;

                if is_heavy || is_light {
                    let num_tears = if is_heavy { (rng() % 3) + 1 } else { 1 };
                    let mut bands = Vec::new();
                    for _ in 0..num_tears {
                        let band_h = if is_heavy { (rng() % 30 + 10) as usize } else { (rng() % 15 + 4) as usize };
                        let band_y = (rng() as usize) % uh.max(1);
                        let mut shift = if is_heavy { (rng() % 20 + 5) as i32 } else { (rng() % 5 + 1) as i32 };
                        if rng() % 2 == 0 { shift = -shift; }
                        bands.push(TearBand { band_y, band_h, shift });
                    }
                    // Lifetime: 150–550ms (hold + fade)
                    let duration_ms = 150 + (rng() % 400) as u64;
                    self.tear_state = Some(TearState { bands, born: Instant::now(), duration_ms });
                }
            }
        }

        if let Some(ref ts) = self.tear_state {
            apply_persistent_tear(canvas, width, draw_x as usize, draw_y as usize, uw, uh, ts);
        }

        // --- Persistent Chromatic Aberration ---
        // Independent lifecycle: spawns during a glitch, persists for a random duration with jitter.
        let chroma_expired = self.chroma_state.as_ref()
            .map(|cs| cs.born.elapsed().as_millis() >= cs.duration_ms as u128)
            .unwrap_or(true);

        if chroma_expired {
            self.chroma_state = None;
            if is_glitching {
                // Pseudo-random from elapsed_ms — new seed each frame, deterministic for a given ms
                let mut seed = elapsed_ms as u32 ^ 0xCA_FE_BA_BE;
                let mut rng = || -> u32 { seed ^= seed << 13; seed ^= seed >> 17; seed ^= seed << 5; seed };
                if rng() % 100 < config.hud.chromatic_chance {
                    let num_bands = (rng() % 6 + 4) as usize;
                    let bands = (0..num_bands).map(|_| ChromaBand {
                        h_split_base: (rng() % 18 + 6) as usize,  // 6–24px
                        band_y:       (rng() as usize) % uh.max(1),
                        band_h:       (rng() as usize) % 35 + 12,
                    }).collect();
                    let duration_ms = 400 + (rng() % 2100) as u64;  // 0.4–2.5s
                    self.chroma_state = Some(ChromaState { bands, born: Instant::now(), duration_ms });
                }
            }
        }

        if let Some(ref cs) = self.chroma_state {
            apply_persistent_chroma(canvas, width, draw_x as usize, draw_y as usize, uw, uh, cs);
        }

        Some((x, y, hud_w, hud_h))
    }
}

// ==============================================================================
// --- Private Rendering Helpers ---
// ==============================================================================

/// HUD base layer: glass, borders, header, hotkey table, footer, scanlines.
#[allow(clippy::too_many_arguments)]
fn draw_base(
    buffer: &mut [u32],
    width: usize,
    height: usize,
    bg_buffer: &[u32],
    blur_buf_1: &mut Vec<u32>,
    blur_buf_2: &mut Vec<u32>,
    text_renderer: &TextRenderer,
    config: &Config,
    theme: &ColorsConfig,
    x: i32,
    y: i32,
    hud_w: usize,
    hud_h: usize,
    backend_name: &str,
    scale: f64,
    color_format: &str,
) {
    if x + hud_w as i32 <= 0 || y + hud_h as i32 <= 0 {
        return;
    }

    // 1. Frosted glass background
    draw_frosted_rect(
        buffer, width, height, x, y, hud_w, hud_h,
        bg_buffer, blur_buf_1, blur_buf_2,
        config.physics.blur_radius, theme.background, 0.5,
    );

    // 2. Borders + top accent
    draw_rect(buffer, width, height, x, y, hud_w, hud_h, 0x1AFFFFFF);
    let top_accent_h = (2.0 * scale).max(1.0).round() as usize;
    draw_filled_rect(buffer, width, height, x, y, hud_w, top_accent_h, ACCENT_RED);

    // 3. Header: HEAD-UP-DISPLAY + backend info
    let header_y = y + (30.0 * scale).round() as i32;
    // '///' breathing animation is rendered in draw_realtime_accents
    text_renderer.draw_text_scaled(
        buffer, width, height,
        x + (75.0 * scale).round() as i32, header_y,
        "HEAD-UP-DISPLAY", 0x80ffffff, 0.4, 1.0, 1.0, false, 0,
    );

    let backend_width = text_renderer.measure_text_width(backend_name) * 0.35;
    text_renderer.draw_text_scaled(
        buffer, width, height,
        x + hud_w as i32 - (backend_width as i32) - (40.0 * scale).round() as i32,
        header_y + (2.0 * scale).round() as i32,
        backend_name, BACKEND_CYAN, 0.35, 1.0, 1.0, false, 0,
    );

    // Separator
    draw_filled_rect(
        buffer, width, height,
        x + (40.0 * scale).round() as i32,
        y + (60.0 * scale).round() as i32,
        (hud_w as i32 - (80.0 * scale).round() as i32) as usize,
        1, 0x15ffffff,
    );

    // 4. Hotkeys Table
    let table_y = y + (80.0 * scale).round() as i32;
    let line_h = (32.0 * scale).round() as i32;
    let rows = [
        ("LMB / ENTER", "CAPTURE PIXEL"),
        ("RMB / ESC", "ABORT ACTION"),
        ("MMB / SPACE", "STASH TO DECK"),
        ("◄ ▲ ▼ ►", "PRECISION NUDGE"),
        ("SHFT + ◄ ▲ ▼ ►", "HYPER JUMP"),
        ("1 ... 0", "SWITCH COLOR FORMAT"),
        ("SCROLL", "ADJUST APERTURE"),
        ("SHFT + SCROLL", "ADJUST MAGNIFIER"),
        ("CTRL + SCROLL", "ADJUST CODE SIZE"),
        ("ALT + SCROLL", "ADJUST AIM FIELD"),
        #[cfg(windows)]
        (config.system.hotkey.as_str(), "DEFAULT HOTKEY"),
        #[cfg(not(windows))]
        ("SIGUSR1 ie-r", "WAYLAND TRIGGER"),
        ("~", "HUD [ ON / OFF ]"),
    ];

    let row_scale = 0.40;
    for (i, (k, d)) in rows.iter().enumerate() {
        let row_y = table_y + (i as i32 * line_h);

        text_renderer.draw_text_scaled(
            buffer, width, height,
            x + (40.0 * scale).round() as i32, row_y,
            "[", BRACKET_DIM_AMBER, row_scale, 1.0, 1.0, false, 0,
        );
        let k_width = if k.contains("◄ ▲ ▼ ►") {
            let mut current_x = (x as f32 + 55.0 * scale as f32).round();
            if k.starts_with("SHFT + ") {
                text_renderer.draw_text_scaled(
                    buffer, width, height,
                    current_x as i32, row_y,
                    "SHFT + ", KEY_AMBER, row_scale, 1.0, 1.0, false, 0,
                );
                current_x += text_renderer.measure_text_width("SHFT + ") * row_scale;
            }

            // Rather than relying on unicode glyphs (often missing in basic fonts),
            // we draw perfect anti-aliased pixel triangles directly on the CPU.
            use crate::core::overlay::shapes::{draw_aa_triangle, TriangleDir};
            
            let size = (14.0 * scale).round() as f32;
            let gap = (8.0 * scale).round() as f32;
            let start_y = row_y as f32 + (4.0 * scale).round() as f32; // offset down from top of row

            draw_aa_triangle(buffer, width, height, current_x, start_y, size, TriangleDir::Left, KEY_AMBER);
            draw_aa_triangle(buffer, width, height, current_x + (size + gap), start_y, size, TriangleDir::Up, KEY_AMBER);
            draw_aa_triangle(buffer, width, height, current_x + (size + gap) * 2.0, start_y, size, TriangleDir::Down, KEY_AMBER);
            draw_aa_triangle(buffer, width, height, current_x + (size + gap) * 3.0, start_y, size, TriangleDir::Right, KEY_AMBER);
            
            let triangles_w = ((size + gap) * 4.0 - gap).ceil();
            current_x - (x as f32 + 55.0 * scale as f32).round() + triangles_w
        } else {
            text_renderer.draw_text_scaled(
                buffer, width, height,
                x + (55.0 * scale).round() as i32, row_y,
                k, KEY_AMBER, row_scale, 1.0, 1.0, false, 0,
            );
            text_renderer.measure_text_width(k) * row_scale
        };
        text_renderer.draw_text_scaled(
            buffer, width, height,
            x + (55.0 * scale).round() as i32 + k_width as i32 + (5.0 * scale).round() as i32,
            row_y, "]", BRACKET_DIM_AMBER, row_scale, 1.0, 1.0, false, 0,
        );

        text_renderer.draw_text_scaled(
            buffer, width, height,
            x + (270.0 * scale).round() as i32, row_y,
            d, DESC_GRAY, row_scale, 1.0, 1.0, false, 0,
        );
    }

    // 5. Footer
    let footer_y = y + hud_h as i32 - (45.0 * scale).round() as i32;

    let label = "FORMAT: ";
    let format_val = color_format.to_uppercase();
    text_renderer.draw_text_scaled(
        buffer, width, height,
        x + (40.0 * scale).round() as i32, footer_y,
        label, KEY_AMBER, 0.28, 1.0, 1.0, false, 0,
    );

    let label_width = text_renderer.measure_text_width(label) * 0.28;
    text_renderer.draw_text_scaled(
        buffer, width, height,
        x + (40.0 * scale).round() as i32 + label_width.round() as i32,
        footer_y, &format_val, FORMAT_GREEN, 0.28, 1.0, 1.0, false, 0,
    );

    draw_filled_rect(
        buffer, width, height,
        x + (40.0 * scale).round() as i32,
        footer_y - (10.0 * scale).round() as i32,
        (hud_w as i32 - (80.0 * scale).round() as i32) as usize,
        1, 0x0AFFFFFF,
    );

    let footer_text = "IE-R v0.1.1 // DIGITAL SENSOR";
    let footer_scale = 0.28;
    let footer_width = text_renderer.measure_text_width(footer_text) * footer_scale;
    text_renderer.draw_text_scaled(
        buffer, width, height,
        x + hud_w as i32 - (footer_width as i32) - (40.0 * scale).round() as i32,
        footer_y, footer_text, FOOTER_PURPLE, footer_scale, 1.0, 1.0, false, 0,
    );

    // 6. CRT Scanlines (dim every 3rd row)
    let screen_w = width as i32;
    let screen_h = height as i32;
    let draw_x = x.max(0).min(screen_w);
    let draw_y = y.max(0).min(screen_h);
    let draw_x2 = (x + hud_w as i32).max(0).min(screen_w);
    let draw_y2 = (y + hud_h as i32).max(0).min(screen_h);
    let uw = (draw_x2 - draw_x) as usize;
    let uh = (draw_y2 - draw_y) as usize;
    let ux = draw_x as usize;
    let uy = draw_y as usize;

    // CRT Scanlines: intensity from config (0.0 = no effect, 1.0 = black bars)
    let scanline_mult = ((1.0 - config.hud.scanlines_intensity) * 256.0) as u32;
    if uw > 0 && uh > 0 && scanline_mult < 256 {
        for gy in 0..uh {
            if gy % 3 == 0 {
                let row_idx = (uy + gy) * width + ux;
                for gx in 0..uw {
                    let px = buffer[row_idx + gx];
                    let r = (((px >> 16) & 0xFF) * scanline_mult / 256) & 0xFF;
                    let g = (((px >> 8) & 0xFF) * scanline_mult / 256) & 0xFF;
                    let b = ((px & 0xFF) * scanline_mult / 256) & 0xFF;
                    buffer[row_idx + gx] = (r << 16) | (g << 8) | b;
                }
            }
        }
    }
}

/// '///' breathing animation in the header (drawn on top of cache every frame).
#[allow(clippy::too_many_arguments)]
fn draw_realtime_accents(
    buffer: &mut [u32],
    width: usize,
    height: usize,
    x: i32,
    y: i32,
    hud_w: usize,
    hud_h: usize,
    scale: f64,
    text_renderer: &TextRenderer,
    time_ms: u64,
    is_active: bool,
) {
    if !is_active {
        return;
    }

    let screen_w = width as i32;
    let screen_h = height as i32;

    if x + hud_w as i32 <= 0 || y + hud_h as i32 <= 0 || x >= screen_w || y >= screen_h {
        return;
    }

    let header_y = y + (30.0 * scale).round() as i32;
    let base_x = x + (40.0 * scale).round() as i32;
    let slash_width = text_renderer.measure_text_width("/") * 0.4;

    for i in 0..3 {
        let t = time_ms as f64 / 1000.0;
        let phase_offset = i as f64 * -0.5;
        let pulse = ((t * 4.0) + phase_offset).sin() * 0.5 + 0.5;
        let dim_opacity = (pulse * 0.8 + 0.2) as f32;

        text_renderer.draw_text_scaled(
            buffer, width, height,
            base_x + (i as f32 * slash_width).round() as i32,
            header_y,
            "\x01/", ACCENT_RED, 0.4, 1.0, dim_opacity, false, 0,
        );
    }
}

/// Chromatic aberration with jitter and fade-out.
/// h_split oscillates around a base value each frame, amplitude decays linearly toward end of life.
fn apply_persistent_chroma(
    buffer: &mut [u32],
    width: usize,
    ux: usize,
    uy: usize,
    uw: usize,
    uh: usize,
    state: &ChromaState,
) {
    let elapsed_ms = state.born.elapsed().as_millis() as f32;
    let duration_ms = state.duration_ms as f32;
    let t = elapsed_ms * 0.001;

    // Linear decay: 1.0 → 0.0 over the effect lifetime
    let fade_out = (1.0 - (elapsed_ms / duration_ms)).clamp(0.0, 1.0);

    let border = 2usize;
    let ux = ux + border;
    let uw = uw.saturating_sub(border * 2);

    for band in &state.bands {
        // Golden ratio as phase offset — maximum distinctness between bands
        let p = band.h_split_base as f32 * 1.618;

        // Slow drift (0.25–0.4 Hz) — signal floats slowly around the base
        let drift = (t * 0.28 + p).sin() * 4.0;

        // Tremor: discrete jumps ~18 times/sec (hash-based jitter)
        let tremor_step = (t * 18.0 + p * 5.3) as u32;
        let h = tremor_step.wrapping_mul(2654435761u32) ^ band.h_split_base as u32;
        let tremor = (h % 7) as i32 - 3;

        // Rare spike (sawtooth): each band fires at its own moment, asynchronously
        let burst_phase = (t * 0.17 + p * 0.29).fract();
        let burst = if burst_phase > 0.83 {
            ((burst_phase - 0.83) / 0.17).powi(2) * 7.0
        } else {
            0.0
        };

        // Mix all noise components and scale by fade
        let raw_jitter = drift as i32 + tremor + burst as i32;
        let jitter = (raw_jitter as f32 * fade_out).round() as i32;
        let base_split = (band.h_split_base as f32 * fade_out).round() as i32;
        let jitter_clamped = jitter.clamp(-12, 12);
        let h_split = (base_split + jitter_clamped).max(1) as usize;

        for gy in band.band_y..(band.band_y + band.band_h).min(uh) {
            let row_idx = (uy + gy) * width + ux;
            if uw <= h_split * 2 { continue; }

            let mut history = [0u32; 32];
            let hist_len = h_split.min(32);
            history[..hist_len].copy_from_slice(&buffer[row_idx..row_idx + hist_len]);
            let mut hist_idx = 0usize;

            // Edge-Delta Luminance: uniform background (glass) yields delta ≈ 0 → untouched.
            // Text edges (high contrast) produce color ghosts.
            // Luma via multiply-shift: (R+G+B) * 0x5556 >> 16 ≡ / 3 (no division).
            let row = &mut buffer[row_idx..row_idx + uw];
            for gx in h_split..(uw - h_split) {
                let px_left = history[hist_idx];
                let px_center = row[gx];
                let px_right = row[gx + h_split];

                history[hist_idx] = px_center;
                hist_idx += 1;
                if hist_idx >= hist_len { hist_idx = 0; }

                let sum_c = ((px_center >> 16) & 0xFF) + ((px_center >> 8) & 0xFF) + (px_center & 0xFF);
                let luma_c = ((sum_c * 0x5556) >> 16) as i32;

                let sum_l = ((px_left >> 16) & 0xFF) + ((px_left >> 8) & 0xFF) + (px_left & 0xFF);
                let delta_l = ((sum_l * 0x5556) >> 16) as i32 - luma_c;

                let sum_r = ((px_right >> 16) & 0xFF) + ((px_right >> 8) & 0xFF) + (px_right & 0xFF);
                let delta_r = ((sum_r * 0x5556) >> 16) as i32 - luma_c;

                let c_r = ((px_center >> 16) & 0xFF) as i32;
                let c_g = (px_center >> 8) & 0xFF;
                let c_b = (px_center & 0xFF) as i32;

                let out_r = (c_r + delta_l).clamp(0, 255) as u32;
                let out_b = (c_b + delta_r).clamp(0, 255) as u32;

                row[gx] = (out_r << 16) | (c_g << 8) | out_b;
            }
        }
    }
}

/// Persistent horizontal tearing with trapezoidal envelope.
/// Band snaps into displacement, holds with jitter, and snaps back.
fn apply_persistent_tear(
    buffer: &mut [u32],
    width: usize,
    ux: usize,
    uy: usize,
    uw: usize,
    uh: usize,
    state: &TearState,
) {
    let border = 2usize;
    let inner_x = ux + border;
    let inner_w = uw.saturating_sub(border * 2);

    if inner_w == 0 { return; }

    let elapsed_ms = state.born.elapsed().as_millis() as u32;
    let duration_ms = state.duration_ms as f32;

    // Trapezoidal envelope: fast attack (15%), plateau, fast release (15%).
    // Smoothstep softens the edges.
    let phase = elapsed_ms as f32 / duration_ms;
    let linear_fade = (phase / 0.15).min((1.0 - phase) / 0.15).clamp(0.0, 1.0);
    let fade = linear_fade * linear_fade * (3.0 - 2.0 * linear_fade);

    for band in &state.bands {
        // Xorshift PRNG: cheap noise for jitter (±3px)
        let mut rng_state = elapsed_ms ^ (band.band_y as u32) ^ 0x0B_AD_C0_DE;
        if rng_state == 0 { rng_state = 1; }
        let mut rand_u32 = || -> u32 {
            rng_state ^= rng_state << 13; rng_state ^= rng_state >> 17; rng_state ^= rng_state << 5; rng_state
        };

        let jitter = (rand_u32() % 7) as i32 - 3;
        let dx = ((band.shift + jitter) as f32 * fade).round() as i32;
        if dx == 0 { continue; }

        let shift = dx.unsigned_abs() as usize;
        if inner_w <= shift || shift >= 256 { continue; }

        // Wrap buffer hoisted out of the row loop (1 init per band instead of N)
        let mut wrap = [0u32; 256];

        for gy in band.band_y..(band.band_y + band.band_h).min(uh) {
            let row_start = (uy + gy) * width + inner_x;
            let row = &mut buffer[row_start..row_start + inner_w];

            if dx > 0 {
                // Circular shift right via memmove (SIMD)
                wrap[..shift].copy_from_slice(&row[inner_w - shift..]);
                row.copy_within(..inner_w - shift, shift);
                row[..shift].copy_from_slice(&wrap[..shift]);
            } else {
                // Circular shift left via memmove (SIMD)
                wrap[..shift].copy_from_slice(&row[..shift]);
                row.copy_within(shift.., 0);
                row[inner_w - shift..].copy_from_slice(&wrap[..shift]);
            }
        }
    }
}

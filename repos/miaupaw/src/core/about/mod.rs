/// About — the "About" window.
///
/// Pure core: renders into a pixel buffer, knows nothing about Wayland/X11.
/// The connector creates a surface of the appropriate type and calls render().
use std::time::Instant;
use crate::core::text::TextRenderer;
use crate::core::overlay::primitives::{draw_rect, draw_filled_rect};
use crate::core::overlay::draw_frosted_rect;

/// Width of the About window (logical pixels).
pub const ABOUT_WIDTH: u32 = 1000;
/// Height = width / φ (golden ratio).
pub const ABOUT_HEIGHT: u32 = (ABOUT_WIDTH as f64 / 1.618) as u32; // 618

const ACCENT_RED: u32 = 0xFF3B3B;
const KEY_AMBER: u32 = 0xFFCC00;
const FOOTER_PURPLE: u32 = 0x8072FF;
const BACKEND_CYAN: u32 = 0x5eead4;

// --- Hermes Narrative Protocol ---
const NARRATIVE: &[&str] = &[
    "// TRANSMISSION START",
    "DECEPTIVE SIMPLICITY. INSTANT RESULT.",
    "20 YEARS OF EVOLUTION: FROM WIN32 TO WAYLAND.",
    "NO BLOAT. NO ELECTRON. NO COMPROMISE.",
    "JUST PURE RUST AND THE SPIRIT OF ZX SPECTRUM.",
    "WE REMEMBER THE PRICE OF EVERY BYTE.",
    "THIS IS NOT A PRODUCT. THIS IS A DIGITAL ART.",
    "POWERED BY DREAMS AND NIXOS DECLARATIVITY.",
    "CONSTRUCTIVE CYBERPUNK IS OUR STATE OF MIND.",
    " ",
    "// THE HEART OF THE STORM:",
    "COMPILED IN KYIV // 2026.",
    "STABILITY TEMPERED UNDER EXTERNAL INTERFERENCE.",
    "THE SPIRIT IS UNBREAKABLE. THE SIGNAL IS CLEAR.",
    " ",
    "// GREETINGS TO:",
    "THE HUNTERS OF PERFECTION.",
    "THE ARCHITECTS OF INTENT.",
    "THE ONES WHO STILL POKE MEMORY DIRECTLY.",
    "YOU ARE NOT ALONE IN THIS IMPERATIVE STORM.",
    "PANDORA DEVICE IS OPEN.",
    "CLICK. COLOR. DONE.",
    " ",
    "// SUPPORT THE SIGNAL:",
    "WWW.INSTANT-EYEDROPPER.COM",
    " ",
    "// END OF STREAM",
];

const TITLE: &str = "INSTANT EYEDROPPER REBORN";
const TITLE_SCALE: f32 = 1.2;
const FOOTER_PREFIX: &str = "v0.1.1-alpha // PANDORA CORE // ";
const FOOTER_URL: &str = "INSTANT-EYEDROPPER.COM";
const FOOTER_COPY: &str = " 2006-2026 // KYIV UKRAINE // KONSTANTIN YAGOLA";
const FOOTER_SCALE: f32 = 0.25;
const SCROLLER_SCALE: f32 = 0.35;

/// Pre-computed text metrics.
struct CachedMetrics {
    title_x: i32,
    title_y: i32,
    slash_w: f32,
    space_w: f32,
    footer_url_x: i32,
    footer_copy_w: f32,
    footer_y: i32,
    url_bounds: (i32, i32, i32, i32),
    line_widths: Vec<(f32, f32)>, 
}

pub struct AboutApp {
    text_renderer: TextRenderer,
    birth_time: Instant,
    pub url_bounds: Option<(i32, i32, i32, i32)>,
    cached_blur: Vec<u32>,
    metrics: Option<CachedMetrics>,
}

impl AboutApp {
    pub fn new(font_data: std::sync::Arc<Vec<u8>>) -> Self {
        let text_renderer = TextRenderer::new(font_data, 52.0);
        Self {
            text_renderer,
            birth_time: Instant::now(),
            url_bounds: None,
            cached_blur: Vec::new(),
            metrics: None,
        }
    }

    /// Invalidates the blur cache (monitor change means a different background).
    pub fn invalidate_blur_cache(&mut self) {
        self.cached_blur.clear();
    }

    fn ensure_metrics(&mut self, w: u32, h: u32) -> &CachedMetrics {
        if self.metrics.is_none() {
            let (title_w, _) = self.text_renderer.measure_text_bounds(TITLE, TITLE_SCALE, 1.0);
            let title_x = ((w as f32 - title_w) / 2.0) as i32;
            let title_y = (h as f32 * 0.20) as i32;
            let slash_w = self.text_renderer.measure_text_width("/") * 0.8;
            let space_w = self.text_renderer.measure_text_width(" ") * TITLE_SCALE;

            let footer_prefix_w = self.text_renderer.measure_text_width(FOOTER_PREFIX) * FOOTER_SCALE;
            let footer_url_w = self.text_renderer.measure_text_width(FOOTER_URL) * FOOTER_SCALE;
            let (footer_copy_w, _) = self.text_renderer.measure_text_bounds(FOOTER_COPY, FOOTER_SCALE, 1.0);
            let footer_y = (h as f32 * 0.92) as i32;
            let footer_url_x = 40 + footer_prefix_w.round() as i32;

            let line_widths: Vec<(f32, f32)> = NARRATIVE.iter()
                .map(|line| self.text_renderer.measure_text_bounds(line, SCROLLER_SCALE, 1.0))
                .collect();

            self.metrics = Some(CachedMetrics {
                title_x, title_y, slash_w, space_w,
                footer_url_x, footer_copy_w, footer_y,
                url_bounds: (footer_url_x, footer_y - 10, footer_url_w.round() as i32, 30),
                line_widths,
            });
        }
        self.metrics.as_ref().unwrap()
    }

    #[allow(clippy::too_many_arguments)]
    pub fn render(&mut self, buf: &mut [u32], w: u32, h: u32, bg_buffer: &[u32], blur_buf_1: &mut Vec<u32>, blur_buf_2: &mut Vec<u32>, blur_radius: usize) {
        let elapsed_ms = self.birth_time.elapsed().as_millis() as u64;
        let t = elapsed_ms as f64 / 1000.0;
        let pixels = (w * h) as usize;

        let glass_breathe = (t * 0.5).sin() * 0.05 + 0.55;
        let scan_y = (t * 0.15).fract() * h as f64;

        if self.cached_blur.is_empty() {
            self.cached_blur.resize(pixels, 0);
            draw_frosted_rect(&mut self.cached_blur, w as usize, h as usize, 0, 0, w as usize, h as usize, bg_buffer, blur_buf_1, blur_buf_2, blur_radius as i32, 0x00000000, 0.0);
        }

        let inv = ((1.0 - glass_breathe) * 256.0) as u32;
        for (buf_px, &cached_px) in buf.iter_mut().zip(self.cached_blur.iter()) {
            let r = (((cached_px >> 16) & 0xFF) * inv) >> 8;
            let g = (((cached_px >> 8) & 0xFF) * inv) >> 8;
            let b = ((cached_px & 0xFF) * inv) >> 8;
            *buf_px = (r << 16) | (g << 8) | b;
        }

        self.ensure_metrics(w, h);
        let m = self.metrics.as_ref().unwrap();
        let tx = m.title_x;
        let ty = m.title_y;
        let slash_w = m.slash_w;
        let fy = m.footer_y;
        self.url_bounds = Some(m.url_bounds);

        draw_rect(buf, w as usize, h as usize, 0, 0, w as usize, h as usize, 0x33ffffff);
        draw_filled_rect(buf, w as usize, h as usize, 0, 0, w as usize, 4, ACCENT_RED);

        // --- Logic: Reveal Sequence with Maximum Suspense ---
        let reveal_p1_start = 500;
        let reveal_p1_duration = 1000;
        let reveal_pause_duration = 2000; // 2s pause (symbol of 5 years of waiting)
        let reveal_p2_start = reveal_p1_start + reveal_p1_duration + reveal_pause_duration;
        let reveal_p2_duration = 500;
        
        let split_idx = 18;
        let typed_chars = if elapsed_ms < reveal_p1_start {
            0
        } else if elapsed_ms < reveal_p1_start + reveal_p1_duration {
            let progress = (elapsed_ms - reveal_p1_start) as f32 / reveal_p1_duration as f32;
            (split_idx as f32 * progress) as usize
        } else if elapsed_ms < reveal_p2_start {
            split_idx
        } else if elapsed_ms < reveal_p2_start + reveal_p2_duration {
            let progress = (elapsed_ms - reveal_p2_start) as f32 / reveal_p2_duration as f32;
            split_idx + ((TITLE.len() - split_idx) as f32 * progress) as usize
        } else {
            TITLE.len()
        };

        let current_title = &TITLE[..typed_chars];
        let reveal_done = typed_chars == TITLE.len();
        let cursor_visible = (t * 4.0).sin() > 0.0;

        // --- Unified Header Aberration ---
        let rjx = ((t * 23.0).sin() * 1.8 + (t * 47.0).cos() * 0.7).round() as i32;
        let rjy = ((t * 19.0).cos() * 1.2 + (t * 61.0).sin() * 0.5).round() as i32;
        let cjx = ((t * 31.0).cos() * 2.1 + (t * 53.0).sin() * 0.4).round() as i32;
        let cjy = ((t * 27.0).sin() * 1.5 + (t * 43.0).cos() * 0.6).round() as i32;

        let cur_x = tx + (self.text_renderer.measure_text_width(current_title) * TITLE_SCALE) as i32 + m.space_w as i32;

        // 1. Red Layer
        self.text_renderer.draw_text_scaled(buf, w as usize, h as usize, tx + rjx, ty + rjy, current_title, 0x99FF3B3B, TITLE_SCALE, 1.0, 0.6, false, 0);
        if cursor_visible {
            self.text_renderer.draw_text_scaled(buf, w as usize, h as usize, cur_x + rjx, ty + rjy, "█", 0x99FF3B3B, TITLE_SCALE, 1.0, 0.6, false, 0);
        }
        for i in 0..3 {
            let x = tx - (5.0 * slash_w) as i32 + (i as f32 * slash_w) as i32;
            self.text_renderer.draw_text_scaled(buf, w as usize, h as usize, x + rjx, ty + rjy, "/", 0x99FF3B3B, TITLE_SCALE, 1.0, 0.6, false, 0);
        }

        // 2. Cyan Layer
        self.text_renderer.draw_text_scaled(buf, w as usize, h as usize, tx + cjx, ty + cjy, current_title, 0x9900A2FF, TITLE_SCALE, 1.0, 0.6, false, 0);
        if cursor_visible {
            self.text_renderer.draw_text_scaled(buf, w as usize, h as usize, cur_x + cjx, ty + cjy, "█", 0x9900A2FF, TITLE_SCALE, 1.0, 0.6, false, 0);
        }
        for i in 0..3 {
            let x = tx - (5.0 * slash_w) as i32 + (i as f32 * slash_w) as i32;
            self.text_renderer.draw_text_scaled(buf, w as usize, h as usize, x + cjx, ty + cjy, "/", 0x9900A2FF, TITLE_SCALE, 1.0, 0.6, false, 0);
        }

        // 3. Anchor Layer
        self.text_renderer.draw_text_scaled(buf, w as usize, h as usize, tx, ty, current_title, 0xFFFFFFFF, TITLE_SCALE, 1.0, 1.0, false, 0);
        if cursor_visible {
            self.text_renderer.draw_text_scaled(buf, w as usize, h as usize, cur_x, ty, "█", 0xFFFFFFFF, TITLE_SCALE, 1.0, 1.0, false, 0);
        }
        let slash_colors = [ACCENT_RED, 0x12FF0E, 0x00A2FF];
        for (i, &color) in slash_colors.iter().enumerate() {
            let x = tx - (5.0 * slash_w) as i32 + (i as f32 * slash_w) as i32;
            self.text_renderer.draw_text_scaled(buf, w as usize, h as usize, x, ty, "/", color, TITLE_SCALE, 1.0, 1.0, false, 0);
        }

        // 4. Hermes Scroller
        if reveal_done {
            let scroll_start_t = t - (reveal_p2_start as f64 + reveal_p2_duration as f64) / 1000.0;
            let scroll_speed = 40.0;
            let line_h = 45.0;
            let total_content_h = NARRATIVE.len() as f64 * line_h;
            let scroll_offset = (scroll_start_t * scroll_speed) % (total_content_h + h as f64);
            let start_y = h as f64 - scroll_offset;
            let text_flicker = 0.95 + ((t * 88.0).sin() * 0.05).abs();
            let zone_top = h as f64 * 0.35;
            let zone_bot = h as f64 * 0.80;

            for (i, line) in NARRATIVE.iter().enumerate() {
                let ly = start_y + (i as f64 * line_h);
                if ly < zone_top || ly > zone_bot { continue; }
                let dist_to_top = (ly - zone_top).abs();
                let dist_to_bot = (zone_bot - ly).abs();
                let edge_fade = (dist_to_top.min(dist_to_bot) / 40.0).min(1.0) as f32;
                let (lw, _) = m.line_widths[i];
                let sinus_x = (t * 3.0 + ly * 0.01).sin() * 15.0;
                let color = if line.starts_with("//") { KEY_AMBER } else { 0xCCFFFFFF };
                self.text_renderer.draw_text_scaled(buf, w as usize, h as usize, ((w as f32 - lw) / 2.0) as i32 + sinus_x as i32, ly as i32, line, color, SCROLLER_SCALE, 1.0, text_flicker as f32 * edge_fade, false, 0);
            }
        }

        // 5. Footer
        self.text_renderer.draw_text_scaled(buf, w as usize, h as usize, 40, fy, FOOTER_PREFIX, KEY_AMBER, FOOTER_SCALE, 1.0, 0.8, false, 0);
        self.text_renderer.draw_text_scaled(buf, w as usize, h as usize, m.footer_url_x, fy, FOOTER_URL, BACKEND_CYAN, FOOTER_SCALE, 1.0, 0.8, false, 0);
        let fw_copy = m.footer_copy_w;
        self.text_renderer.draw_text_scaled(buf, w as usize, h as usize, w as i32 - fw_copy as i32 - 40, fy, FOOTER_COPY, FOOTER_PURPLE, FOOTER_SCALE, 1.0, 0.8, false, 0);

        // 6. Scanlines
        for gy in (0..h as usize).step_by(3) {
            let row_start = gy * w as usize;
            let row_end = row_start + w as usize;
            let scanline_mult = if (gy as f64 - scan_y).abs() < 10.0 { 230u32 } else { 180u32 };
            for px in &mut buf[row_start..row_end] {
                let v = *px;
                let r = (((v >> 16) & 0xFF) * scanline_mult) >> 8;
                let g = (((v >> 8) & 0xFF) * scanline_mult) >> 8;
                let b = ((v & 0xFF) * scanline_mult) >> 8;
                *px = (r << 16) | (g << 8) | b;
            }
        }
    }
}

use crate::core::metrics::TextMetrics;
use ab_glyph::{Font, FontVec, PxScale, ScaleFont};
use fontdb::{Database, Family, Query, Source};
use std::fs;
use std::sync::Arc;
use crate::core::terminal::log_step;

pub struct TextRenderer {
    pub font_data: Arc<Vec<u8>>,
    font: Option<FontVec>,
    scale: PxScale,
    pub metrics: TextMetrics,
}

impl TextRenderer {
    /// Creates a renderer from pre-loaded font bytes.
    /// Font table parsing (`cmap`, `head`, `hhea`) happens exactly once here.
    pub fn new(font_data: Arc<Vec<u8>>, size: f32) -> Self {
        let metrics = TextMetrics::new(&font_data, size);
        let font = FontVec::try_from_vec((*font_data).clone()).ok();
        Self {
            font_data,
            font,
            scale: PxScale::from(size),
            metrics,
        }
    }

    /// Updates font size without re-parsing font data.
    pub fn update_size(&mut self, size: f32) {
        self.scale = PxScale::from(size);
        if let Some(font) = &self.font {
            // FontVec implements Font — reuse for metric recalculation.
            self.metrics = TextMetrics::from_font(font, size);
        }
    }

    #[allow(clippy::too_many_arguments)]
    pub fn draw_text_scaled(
        &self,
        buffer: &mut [u32],
        width: usize,
        height: usize,
        x: i32,
        y: i32,
        text: &str,
        color: u32,
        scale_modifier: f32,
        line_spacing: f32,
        dim_opacity: f32,
        center_x: bool,
        box_width: usize, // required when center_x is true
    ) {
        // dim_opacity is used as a global alpha multiplier in the pixel blender,
        // so we don't dim color channels here to avoid muddy black artifacts.

        let font = match &self.font {
            Some(f) => f,
            None => return,
        };

        let mod_scale = PxScale {
            x: self.scale.x * scale_modifier,
            y: self.scale.y * scale_modifier,
        };
        let scaled_font = font.as_scaled(mod_scale);

        let mod_ascent = self.metrics.ascent * scale_modifier;
        let mod_height = self.metrics.height * scale_modifier;

        let lines: Vec<&str> = text.split('\n').collect();
        let mut current_y = y as f32 + mod_ascent;

        for line in lines {
            let mut caret = ab_glyph::point(0.0, 0.0);

            // If centering — measure the current line width.
            let mut line_width = 0.0;
            if center_x {
                for c in line.chars() {
                    if c.is_control() {
                        continue;
                    }
                    line_width += scaled_font.h_advance(scaled_font.glyph_id(c));
                }
            }

            let start_x = if center_x {
                x as f32 + (box_width as f32 - line_width) / 2.0
            } else {
                x as f32
            };

            // Initialize opacity to 1.0; dim_opacity kicks in after \x01.
            let current_color = color;
            let mut current_opacity_modifier = 1.0;

            for c in line.chars() {
                if c == '\x01' {
                    // \x01 — turn on dimming mid-string
                    current_opacity_modifier = dim_opacity;
                    continue;
                }
                if c == '\x02' {
                    // \x02 — restore full opacity
                    current_opacity_modifier = 1.0;
                    continue;
                }
                if c.is_control() {
                    continue;
                }
                let glyph = scaled_font.scaled_glyph(c);
                if let Some(outlined) = scaled_font.outline_glyph(glyph) {
                    let bounds = outlined.px_bounds();
                    outlined.draw(|gx, gy, coverage| {
                        let px = start_x + caret.x + bounds.min.x + gx as f32;
                        let py = current_y + bounds.min.y + gy as f32;

                        if px >= 0.0 && px < width as f32 && py >= 0.0 && py < height as f32 {
                            let px_idx = (py as usize) * width + (px as usize);
                            let bg = buffer[px_idx];

                            let final_cov = coverage * current_opacity_modifier;

                            let out_r = (final_cov * ((current_color >> 16) & 0xFF) as f32
                                + (1.0 - final_cov) * ((bg >> 16) & 0xFF) as f32)
                                as u32;
                            let out_g = (final_cov * ((current_color >> 8) & 0xFF) as f32
                                + (1.0 - final_cov) * ((bg >> 8) & 0xFF) as f32)
                                as u32;
                            let out_b = (final_cov * (current_color & 0xFF) as f32
                                + (1.0 - final_cov) * (bg & 0xFF) as f32)
                                as u32;

                            buffer[px_idx] = (out_r << 16) | (out_g << 8) | out_b;
                        }
                    });
                }
                caret.x += scaled_font.h_advance(scaled_font.glyph_id(c));
            }

            // Advance to next line accounting for line spacing modifier.
            current_y += mod_height * line_spacing;
        }
    }

    pub fn measure_text_width(&self, text: &str) -> f32 {
        self.measure_text_bounds(text, 1.0, 1.0).0
    }

    /// Returns (max_width, total_height) for multi-line text.
    pub fn measure_text_bounds(
        &self,
        text: &str,
        scale_modifier: f32,
        line_spacing: f32,
    ) -> (f32, f32) {
        let font = match &self.font {
            Some(f) => f,
            None => return (0.0, 0.0),
        };
        let mod_scale = PxScale {
            x: self.scale.x * scale_modifier,
            y: self.scale.y * scale_modifier,
        };
        let scaled_font = font.as_scaled(mod_scale);

        let mut max_width = 0.0_f32;
        let mut current_width = 0.0_f32;
        let mut lines = 1;

        for c in text.chars() {
            if c == '\n' {
                if current_width > max_width {
                    max_width = current_width;
                }
                current_width = 0.0;
                lines += 1;
                continue;
            }
            if c.is_control() {
                continue;
            }
            current_width += scaled_font.h_advance(scaled_font.glyph_id(c));
        }
        if current_width > max_width {
            max_width = current_width;
        }

        let base_height = self.metrics.height * scale_modifier;
        // First line takes base_height, each additional line takes base_height * line_spacing.
        let height = if lines > 1 {
            base_height + base_height * line_spacing * (lines - 1) as f32
        } else {
            base_height
        };

        (max_width, height)
    }
}

/// Loads JetBrains Mono Regular for HUD and About window.
///
/// Resolution order:
///   1. `IE_R_FONT_DIR` env var (set by portable launcher)
///   2. Relative to exe: `fonts/` (Windows portable), `../share/ie-r/fonts/` (Nix package)
///   3. System fontdb — JetBrains Mono if installed
///
/// Returns empty Vec on failure; caller falls back to the magnifier font.
pub fn load_hud_font(db: &Database) -> Vec<u8> {
    const FILENAME: &str = "JetBrainsMono-Regular.ttf";

    if let Ok(dir) = std::env::var("IE_R_FONT_DIR") {
        let path = std::path::PathBuf::from(dir).join(FILENAME);
        if let Ok(data) = fs::read(&path) {
            log_step("Font", &format!("HUD font from IE_R_FONT_DIR: {}", path.display()));
            return data;
        }
    }

    if let Ok(exe) = std::env::current_exe()
        && let Some(dir) = exe.parent() {
            let candidates = [
                dir.join("fonts").join(FILENAME),
                dir.join("..").join("share").join("ie-r").join("fonts").join(FILENAME),
            ];
            for path in &candidates {
                if let Ok(data) = fs::read(path) {
                    log_step("Font", &format!("HUD font: {}", path.display()));
                    return data;
                }
            }
        }

    let query = Query { families: &[Family::Name("JetBrains Mono")], ..Default::default() };
    if let Some(id) = db.query(&query)
        && let Some((Source::File(path), _)) = db.face_source(id)
            && let Ok(data) = fs::read(path) {
                log_step("Font", "HUD font: JetBrains Mono from system fonts");
                return data;
            }

    Vec::new()
}

/// Smart font hunter.
/// Scans the system once and finds the best monospace font from the provided list.
pub fn find_best_font(db: &Database, preferred: &str, elite_list: &[&str]) -> Vec<u8> {
    let query = Query {
        families: &[Family::Name(preferred)],
        ..Default::default()
    };
    if let Some(id) = db.query(&query)
        && let Some((Source::File(path), _)) = db.face_source(id)
            && let Ok(data) = fs::read(path) {
                log_step("Font", &format!("Found preferred match: {}", preferred));
                return data;
            }

    for name in elite_list {
        let query = Query {
            families: &[Family::Name(name)],
            ..Default::default()
        };
        if let Some(id) = db.query(&query)
            && let Some((Source::File(path), _)) = db.face_source(id)
                && let Ok(data) = fs::read(path) {
                    log_step("Font", &format!("Found best match from elite: {}", name));
                    return data;
                }
    }

    let fallback_query = Query {
        families: &[Family::Monospace],
        ..Default::default()
    };
    if let Some(id) = db.query(&fallback_query)
        && let Some((Source::File(path), _)) = db.face_source(id)
            && let Ok(data) = fs::read(path) {
                log_step("Font", "Using system generic Monospace");
                return data;
            }

    Vec::new()
}

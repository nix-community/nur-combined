use crate::core::metrics::TextMetrics;
use ab_glyph::{Font, FontVec, PxScale, ScaleFont};
use fontdb::{Database, Family, Query, Source};
use std::cell::RefCell;
use std::collections::HashMap;
use std::fs;
use std::sync::Arc;
use crate::core::terminal::log_step;

/// A cached rasterized glyph: coverage bitmap + placement metrics.
/// ab_glyph rasterizes the glyph at position (0,0) and the line's
/// fractional offset is applied at blit time with integer truncation —
/// the phase is always zero, so a (char, scale) cache reproduces the
/// output exactly.
struct CachedGlyph {
    w: usize,
    h: usize,
    min_x: f32,
    min_y: f32,
    advance: f32,
    coverage: Vec<u8>,
}

/// A safety valve against cache blow-up under continuously varying scale
/// (the alphabet is tiny and sizes are discrete — normally tens of entries).
const GLYPH_CACHE_LIMIT: usize = 1024;

pub struct TextRenderer {
    pub font_data: Arc<Vec<u8>>,
    font: Option<FontVec>,
    scale: PxScale,
    pub metrics: TextMetrics,
    /// Rasterization cache: (char, scale bits) → bitmap. RefCell — drawing
    /// takes `&self` (the paint phase mutates no state), access is single-threaded.
    glyph_cache: RefCell<HashMap<(char, u32), CachedGlyph>>,
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
            glyph_cache: RefCell::new(HashMap::new()),
        }
    }

    /// Updates font size without re-parsing font data.
    pub fn update_size(&mut self, size: f32) {
        self.scale = PxScale::from(size);
        if let Some(font) = &self.font {
            // FontVec implements Font — reuse for metric recalculation.
            self.metrics = TextMetrics::from_font(font, size);
        }
        // The cache key includes scale, but stale sizes are dead weight now.
        self.glyph_cache.borrow_mut().clear();
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

        let scale_bits = mod_scale.y.to_bits();
        let mut cache = self.glyph_cache.borrow_mut();
        if cache.len() > GLYPH_CACHE_LIMIT {
            cache.clear();
        }

        // Opacities in 8.8 fixed-point: full = 256, dim from dim_opacity.
        let dim256 = ((dim_opacity * 256.0).round() as i32).clamp(0, 256) as u32;
        let color_rb = color & 0x00FF00FF;
        let color_g = color & 0x0000FF00;

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

            // Initialize opacity to full; dim_opacity kicks in after \x01.
            let mut current_op256 = 256u32;

            for c in line.chars() {
                if c == '\x01' {
                    // \x01 — turn on dimming mid-string
                    current_op256 = dim256;
                    continue;
                }
                if c == '\x02' {
                    // \x02 — restore full opacity
                    current_op256 = 256;
                    continue;
                }
                if c.is_control() {
                    continue;
                }

                // Rasterization happens only on a cache miss. Empty glyphs
                // (space) are cached as 0×0, else they would miss forever.
                let g = cache.entry((c, scale_bits)).or_insert_with(|| {
                    let advance = scaled_font.h_advance(scaled_font.glyph_id(c));
                    let glyph = scaled_font.scaled_glyph(c);
                    match scaled_font.outline_glyph(glyph) {
                        Some(outlined) => {
                            let bounds = outlined.px_bounds();
                            let gw = (bounds.max.x - bounds.min.x) as usize;
                            let gh = (bounds.max.y - bounds.min.y) as usize;
                            let mut coverage = vec![0u8; gw * gh];
                            outlined.draw(|gx, gy, cov| {
                                let idx = gy as usize * gw + gx as usize;
                                if idx < coverage.len() {
                                    coverage[idx] = (cov * 255.0) as u8;
                                }
                            });
                            CachedGlyph {
                                w: gw, h: gh,
                                min_x: bounds.min.x, min_y: bounds.min.y,
                                advance, coverage,
                            }
                        }
                        None => CachedGlyph {
                            w: 0, h: 0, min_x: 0.0, min_y: 0.0,
                            advance, coverage: Vec::new(),
                        },
                    }
                });

                // Blit from cache: integer start (floor of the fractional
                // base — equivalent to the old per-pixel truncation), packed
                // RB|G blend: two channels per multiply, zero f32 per pixel.
                let ix0 = (start_x + caret.x + g.min_x).floor() as i32;
                let iy0 = (current_y + g.min_y).floor() as i32;

                for gy in 0..g.h {
                    let py = iy0 + gy as i32;
                    if py < 0 || py >= height as i32 {
                        continue;
                    }
                    let row = py as usize * width;
                    let cov_row = &g.coverage[gy * g.w..(gy + 1) * g.w];

                    for (gx, &cov) in cov_row.iter().enumerate() {
                        if cov == 0 {
                            continue;
                        }
                        let px = ix0 + gx as i32;
                        if px < 0 || px >= width as i32 {
                            continue;
                        }
                        // coverage 0..255 → weight 0..256 (×257>>8), then opacity.
                        let f = (((cov as u32 * 257) >> 8) * current_op256) >> 8;
                        let inv = 256 - f;

                        let idx = row + px as usize;
                        let bg = buffer[idx];
                        let rb = (((bg & 0x00FF00FF) * inv + color_rb * f) >> 8) & 0x00FF00FF;
                        let gr = (((bg & 0x0000FF00) * inv + color_g * f) >> 8) & 0x0000FF00;
                        buffer[idx] = rb | gr;
                    }
                }

                caret.x += g.advance;
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

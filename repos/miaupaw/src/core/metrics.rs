use ab_glyph::{Font, FontRef, PxScale, ScaleFont};

/// Pre-computed text metrics.
/// Used for stable vertical centering across font changes.
#[derive(Debug, Clone, Copy)]
pub struct TextMetrics {
    pub height: f32,
    pub top_offset: f32,
    pub ascent: f32,
}

impl TextMetrics {
    /// Computes metrics from raw font bytes.
    /// Used during initialization before FontVec is available.
    pub fn new(font_data: &[u8], font_size: f32) -> Self {
        if font_data.is_empty() {
            return Self::zero();
        }

        match FontRef::try_from_slice(font_data) {
            Ok(font) => Self::compute(&font, font_size),
            Err(_) => Self::zero(),
        }
    }

    /// Computes metrics from an already-parsed font.
    /// Used in update_size when FontVec is cached in TextRenderer.
    pub fn from_font(font: &impl Font, font_size: f32) -> Self {
        Self::compute(font, font_size)
    }

    fn zero() -> Self {
        Self {
            height: 0.0,
            top_offset: 0.0,
            ascent: 0.0,
        }
    }

    /// Core metrics calculation. Accepts any type implementing `Font`.
    /// Scans a reference set of HEX characters to determine visual bounds,
    /// ensuring stable centering without jumps when digits change.
    fn compute(font: &impl Font, font_size: f32) -> Self {
        let scale = PxScale::from(font_size);
        let scaled_font = font.as_scaled(scale);

        let ascent = scaled_font.ascent();

        //    Visual bounds via reference HEX character set
        let reference_text = "0123456789ABCDEF#";

        let mut min_y = f32::MAX;
        let mut max_y = f32::MIN;
        let mut has_bounds = false;

        for c in reference_text.chars() {
            let glyph = scaled_font.scaled_glyph(c);
            if let Some(outlined) = scaled_font.outline_glyph(glyph) {
                let bounds = outlined.px_bounds();
                if bounds.min.y < min_y {
                    min_y = bounds.min.y;
                }
                if bounds.max.y > max_y {
                    max_y = bounds.max.y;
                }
                has_bounds = true;
            }
        }

        if !has_bounds {
            return Self {
                height: 0.0,
                top_offset: 0.0,
                ascent,
            };
        }

        Self {
            height: max_y - min_y,
            top_offset: min_y,
            ascent,
        }
    }
}

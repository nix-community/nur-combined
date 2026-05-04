/// Template engine for color formats.
///
/// Supported tokens:
///   {R}, {G}, {B}       — hex uppercase (FF, 80, 30)
///   {r}, {g}, {b}       — hex lowercase (ff, 80, 30)
///   {rd}, {gd}, {bd}    — decimal (255, 128, 48)
///   {rf}, {gf}, {bf}    — float 0.0-1.0 (configurable precision)
///   {long}              — Windows COLORREF: r + 256*g + 65536*b
///   {h}                 — Hue (0-360)
///   {s}                 — Saturation % (0-100)
///   {l}                 — Lightness % (0-100, HSL)
///   {v}                 — Value % (0-100, HSV)
///   {c},{m},{y},{k}     — CMYK % (0-100)
///
/// All other characters pass through as-is.
/// Generates a zero-padded string for values up to 999.
/// Injects control codes:
///   \x01 — renderer directive: dim on
///   \x02 — renderer directive: dim off
/// Example: 5 → "\x0100\x025", 42 → "\x010\x0242".
/// Avoids per-frame allocations and regex parsing.
fn format_padded(val: u16) -> String {
    if val < 10 {
        format!("\x0100\x02{}", val)
    } else if val < 100 {
        format!("\x010\x02{}", val)
    } else {
        format!("\x02{}", val) // already 3 digits, dim off only
    }
}

/// Same as format_padded but for the Long format (up to 8 digits).
fn format_padded_long(val: u32) -> String {
    const ZEROS: &str = "00000000";
    let s = val.to_string();
    let pad_len = 8usize.saturating_sub(s.len());
    if pad_len > 0 {
        format!("\x01{}\x02{}", &ZEROS[..pad_len], s)
    } else {
        format!("\x02{}", s)
    }
}

pub struct Color {
    pub r: u8,
    pub g: u8,
    pub b: u8,
}

impl Color {
    pub fn new(r: u8, g: u8, b: u8) -> Self {
        Self { r, g, b }
    }

    pub fn to_hsl(&self) -> (u16, u8, u8) {
        let r = self.r as f32 / 255.0;
        let g = self.g as f32 / 255.0;
        let b = self.b as f32 / 255.0;

        let max = r.max(g).max(b);
        let min = r.min(g).min(b);
        let delta = max - min;

        let l = (max + min) / 2.0;

        let s = if delta == 0.0 {
            0.0
        } else {
            (delta / (1.0 - (2.0 * l - 1.0).abs())).clamp(0.0, 1.0)
        };

        let mut h = if delta == 0.0 {
            0.0
        } else if max == r {
            ((g - b) / delta) % 6.0
        } else if max == g {
            (b - r) / delta + 2.0
        } else {
            (r - g) / delta + 4.0
        };

        h *= 60.0;
        if h < 0.0 {
            h += 360.0;
        }

        (
            h.round() as u16,
            (s * 100.0).round() as u8,
            (l * 100.0).round() as u8,
        )
    }

    pub fn to_hsv(&self) -> (u16, u8, u8) {
        let r = self.r as f32 / 255.0;
        let g = self.g as f32 / 255.0;
        let b = self.b as f32 / 255.0;

        let max = r.max(g).max(b);
        let min = r.min(g).min(b);
        let delta = max - min;

        let v = max;

        let s = if max == 0.0 { 0.0 } else { delta / max };

        let mut h = if delta == 0.0 {
            0.0
        } else if max == r {
            ((g - b) / delta) % 6.0
        } else if max == g {
            (b - r) / delta + 2.0
        } else {
            (r - g) / delta + 4.0
        };

        h *= 60.0;
        if h < 0.0 {
            h += 360.0;
        }

        (
            h.round() as u16,
            (s * 100.0).round() as u8,
            (v * 100.0).round() as u8,
        )
    }

    pub fn to_cmyk(&self) -> (u8, u8, u8, u8) {
        let r = self.r as f32 / 255.0;
        let g = self.g as f32 / 255.0;
        let b = self.b as f32 / 255.0;

        let k = 1.0 - r.max(g).max(b);
        if k == 1.0 {
            return (0, 0, 0, 100);
        }

        let c = (1.0 - r - k) / (1.0 - k);
        let m = (1.0 - g - k) / (1.0 - k);
        let y = (1.0 - b - k) / (1.0 - k);

        (
            (c * 100.0).round() as u8,
            (m * 100.0).round() as u8,
            (y * 100.0).round() as u8,
            (k * 100.0).round() as u8,
        )
    }

    /// Full template engine. Replaces tokens {R}, {r}, {rd}, {rf}, {long}, {h}, etc.
    /// `precision` — decimal places for {rf},{gf},{bf}.
    /// Contextual logic for {s}:
    ///   Template contains {v} → HSV mode → {s} = HSV saturation
    ///   Otherwise             → HSL mode → {s} = HSL saturation
    pub fn format(&self, template: &str, precision: usize) -> String {
        let (hue, sat, light) = self.to_hsl();
        let (_, sat_hsv, val) = self.to_hsv();
        let (c, m, y, k) = self.to_cmyk();

        let effective_sat = if template.contains("{v}") {
            sat_hsv
        } else {
            sat
        };

        // Float RGB (0.0-1.0)
        let rf = self.r as f64 / 255.0;
        let gf = self.g as f64 / 255.0;
        let bf = self.b as f64 / 255.0;

        // Long (Windows COLORREF)
        let long_val = self.r as u32 + 256 * self.g as u32 + 65536 * self.b as u32;

        template
            // Hex uppercase (RGB order)
            .replace("{R}", &format!("{:02X}", self.r))
            .replace("{G}", &format!("{:02X}", self.g))
            .replace("{B}", &format!("{:02X}", self.b))
            // Hex lowercase (RGB order)
            .replace("{r}", &format!("{:02x}", self.r))
            .replace("{g}", &format!("{:02x}", self.g))
            .replace("{b}", &format!("{:02x}", self.b))
            // Float RGB
            .replace("{rf}", &format!("{:.prec$}", rf, prec = precision))
            .replace("{gf}", &format!("{:.prec$}", gf, prec = precision))
            .replace("{bf}", &format!("{:.prec$}", bf, prec = precision))
            // Decimal
            .replace("{rd}", &self.r.to_string())
            .replace("{gd}", &self.g.to_string())
            .replace("{bd}", &self.b.to_string())
            // Decimal padded (visual magic via control codes \x01 dim on, \x02 dim off)
            .replace("{rd_pad}", &format_padded(self.r as u16))
            .replace("{gd_pad}", &format_padded(self.g as u16))
            .replace("{bd_pad}", &format_padded(self.b as u16))
            // Long
            .replace("{long}", &long_val.to_string())
            .replace("{long_pad}", &format_padded_long(long_val))
            // HSL/HSV (hue shared, saturation contextual)
            .replace("{h}", &hue.to_string())
            .replace("{s}", &effective_sat.to_string())
            .replace("{l}", &light.to_string())
            .replace("{v}", &val.to_string())
            // HSL/HSV padded
            .replace("{h_pad}", &format_padded(hue))
            .replace("{s_pad}", &format_padded(effective_sat as u16))
            .replace("{l_pad}", &format_padded(light as u16))
            .replace("{v_pad}", &format_padded(val as u16))
            // CMYK
            .replace("{c}", &c.to_string())
            .replace("{m}", &m.to_string())
            .replace("{y}", &y.to_string())
            .replace("{k}", &k.to_string())
            // CMYK padded
            .replace("{c_pad}", &format_padded(c as u16))
            .replace("{m_pad}", &format_padded(m as u16))
            .replace("{y_pad}", &format_padded(y as u16))
            .replace("{k_pad}", &format_padded(k as u16))
    }
}

pub fn rgb_to_hex(r: u8, g: u8, b: u8) -> String {
    format!("#{:02X}{:02X}{:02X}", r, g, b)
}

pub fn format_color(template: &str, r: u8, g: u8, b: u8, precision: usize) -> String {
    let color = Color::new(r, g, b);
    color.format(template, precision)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_format_padded() {
        assert_eq!(format_padded(5), "\x0100\x025");
        assert_eq!(format_padded(42), "\x010\x0242");
        assert_eq!(format_padded(255), "\x02255");
    }

    #[test]
    fn test_hsl_conversion() {
        let white = Color::new(255, 255, 255);
        assert_eq!(white.to_hsl(), (0, 0, 100));

        let black = Color::new(0, 0, 0);
        assert_eq!(black.to_hsl(), (0, 0, 0));

        let red = Color::new(255, 0, 0);
        assert_eq!(red.to_hsl(), (0, 100, 50));
    }

    #[test]
    fn test_hsv_conversion() {
        let red = Color::new(255, 0, 0);
        assert_eq!(red.to_hsv(), (0, 100, 100));
    }

    #[test]
    fn test_cmyk_conversion() {
        let cyan = Color::new(0, 255, 255);
        assert_eq!(cyan.to_cmyk(), (100, 0, 0, 0));

        let black = Color::new(0, 0, 0);
        assert_eq!(black.to_cmyk(), (0, 0, 0, 100));
    }

    #[test]
    fn test_template_formatting() {
        let color = Color::new(255, 128, 64);

        // Hex
        assert_eq!(color.format("#{R}{G}{B}", 2), "#FF8040");
        assert_eq!(color.format("#{r}{g}{b}", 2), "#ff8040");

        // Decimal
        assert_eq!(color.format("rgb({rd}, {gd}, {bd})", 2), "rgb(255, 128, 64)");

        // Padded (visual magic)
        assert_eq!(color.format("{rd_pad}", 2), "\x02255");
        assert_eq!(color.format("{bd_pad}", 2), "\x010\x0264");

        // Float
        assert_eq!(color.format("{rf}", 1), "1.0");
        assert_eq!(color.format("{rf}", 2), "1.00");
    }
}

//! Color palette for terminal emulator.
//!
//! This module provides [`ColorPalette`] and [`ColorPaletteBuilder`] for managing
//! terminal colors. It supports:
//!
//! - **16 ANSI colors**: The standard palette (colors 0-15)
//! - **256-color mode**: Extended palette with 6×6×6 RGB cube and grayscale ramp
//! - **True color (24-bit RGB)**: Direct RGB color specification
//!
//! # Default ANSI Colors
//!
//! The default palette uses colors similar to common terminal emulators:
//!
//! | Index | Name | RGB |
//! |-------|------|-----|
//! | 0 | Black | `#000000` |
//! | 1 | Red | `#CC0000` |
//! | 2 | Green | `#4E9A06` |
//! | 3 | Yellow | `#C4A000` |
//! | 4 | Blue | `#3465A4` |
//! | 5 | Magenta | `#75507B` |
//! | 6 | Cyan | `#06989A` |
//! | 7 | White | `#D3D7CF` |
//! | 8 | Bright Black | `#555753` |
//! | 9 | Bright Red | `#EF2929` |
//! | 10 | Bright Green | `#8AE234` |
//! | 11 | Bright Yellow | `#FCE94F` |
//! | 12 | Bright Blue | `#729FCF` |
//! | 13 | Bright Magenta | `#AD7FA8` |
//! | 14 | Bright Cyan | `#34E2E2` |
//! | 15 | Bright White | `#EEEEEC` |
//!
//! # 256-Color Mode
//!
//! Colors 16-255 are calculated:
//!
//! - **16-231**: 6×6×6 RGB cube where each component is `0, 95, 135, 175, 215, 255`
//! - **232-255**: 24-step grayscale from `#080808` to `#EEEEEE`
//!
//! # Example
//!
//! ```
//! use gpui_terminal::ColorPalette;
//!
//! // Use default palette
//! let default = ColorPalette::default();
//!
//! // Or customize with builder
//! let custom = ColorPalette::builder()
//!     .background(0x1a, 0x1b, 0x26)  // Tokyo Night background
//!     .foreground(0xa9, 0xb1, 0xd6)  // Tokyo Night foreground
//!     .red(0xf7, 0x76, 0x8e)
//!     .green(0x9e, 0xce, 0x6a)
//!     .blue(0x7a, 0xa2, 0xf7)
//!     .build();
//! ```

use alacritty_terminal::term::color::Colors;
use alacritty_terminal::vte::ansi::{Color, NamedColor, Rgb};
use gpui::Hsla;

/// A color palette that maps ANSI colors to GPUI Hsla colors.
///
/// This struct maintains the 16-color ANSI palette, 256-color extended palette,
/// and special colors (foreground, background, cursor). It provides the
/// [`resolve`](Self::resolve) method to convert any terminal color to GPUI's
/// [`Hsla`] format for rendering.
///
/// # Color Resolution
///
/// The [`resolve`](Self::resolve) method handles all terminal color types:
///
/// 1. **Named colors** (0-15): Looked up in the ANSI palette
/// 2. **Special colors**: Foreground, Background, Cursor, Dim variants
/// 3. **Indexed colors** (16-255): Looked up in the extended palette
/// 4. **True colors**: Converted directly from RGB
///
/// # Creating a Palette
///
/// Use [`ColorPalette::default()`] for standard colors, or
/// [`ColorPalette::builder()`] for customization:
///
/// ```
/// use gpui_terminal::ColorPalette;
///
/// let palette = ColorPalette::builder()
///     .background(0x28, 0x28, 0x28)
///     .foreground(0xeb, 0xdb, 0xb2)
///     .build();
/// ```
#[derive(Debug, Clone)]
pub struct ColorPalette {
    /// The 16 standard ANSI colors (black, red, green, yellow, blue, magenta, cyan, white,
    /// and their bright variants)
    ansi_colors: [Hsla; 16],

    /// The 256-color palette (colors 16-255)
    /// Colors 0-15 are the standard ANSI colors
    /// Colors 16-231 are a 6x6x6 RGB cube
    /// Colors 232-255 are grayscale
    extended_colors: [Hsla; 256],

    /// Default foreground color
    foreground: Hsla,

    /// Default background color
    background: Hsla,

    /// Default cursor color
    cursor: Hsla,
}

impl Default for ColorPalette {
    fn default() -> Self {
        // Standard ANSI colors (based on common terminal emulator defaults)
        let ansi_colors = [
            // Normal colors
            rgb_to_hsla(Rgb {
                r: 0x00,
                g: 0x00,
                b: 0x00,
            }), // Black
            rgb_to_hsla(Rgb {
                r: 0xcc,
                g: 0x00,
                b: 0x00,
            }), // Red
            rgb_to_hsla(Rgb {
                r: 0x4e,
                g: 0x9a,
                b: 0x06,
            }), // Green
            rgb_to_hsla(Rgb {
                r: 0xc4,
                g: 0xa0,
                b: 0x00,
            }), // Yellow
            rgb_to_hsla(Rgb {
                r: 0x34,
                g: 0x65,
                b: 0xa4,
            }), // Blue
            rgb_to_hsla(Rgb {
                r: 0x75,
                g: 0x50,
                b: 0x7b,
            }), // Magenta
            rgb_to_hsla(Rgb {
                r: 0x06,
                g: 0x98,
                b: 0x9a,
            }), // Cyan
            rgb_to_hsla(Rgb {
                r: 0xd3,
                g: 0xd7,
                b: 0xcf,
            }), // White
            // Bright colors
            rgb_to_hsla(Rgb {
                r: 0x55,
                g: 0x57,
                b: 0x53,
            }), // Bright Black (Gray)
            rgb_to_hsla(Rgb {
                r: 0xef,
                g: 0x29,
                b: 0x29,
            }), // Bright Red
            rgb_to_hsla(Rgb {
                r: 0x8a,
                g: 0xe2,
                b: 0x34,
            }), // Bright Green
            rgb_to_hsla(Rgb {
                r: 0xfc,
                g: 0xe9,
                b: 0x4f,
            }), // Bright Yellow
            rgb_to_hsla(Rgb {
                r: 0x72,
                g: 0x9f,
                b: 0xcf,
            }), // Bright Blue
            rgb_to_hsla(Rgb {
                r: 0xad,
                g: 0x7f,
                b: 0xa8,
            }), // Bright Magenta
            rgb_to_hsla(Rgb {
                r: 0x34,
                g: 0xe2,
                b: 0xe2,
            }), // Bright Cyan
            rgb_to_hsla(Rgb {
                r: 0xee,
                g: 0xee,
                b: 0xec,
            }), // Bright White
        ];

        // Build the full 256-color palette
        let mut extended_colors = [Hsla::default(); 256];

        // First 16 colors are the standard ANSI colors
        extended_colors[0..16].copy_from_slice(&ansi_colors);

        // Colors 16-231: 6x6x6 RGB cube
        let mut idx = 16;
        for r in 0..6 {
            for g in 0..6 {
                for b in 0..6 {
                    let rgb = Rgb {
                        r: if r == 0 { 0 } else { 55 + r * 40 },
                        g: if g == 0 { 0 } else { 55 + g * 40 },
                        b: if b == 0 { 0 } else { 55 + b * 40 },
                    };
                    extended_colors[idx] = rgb_to_hsla(rgb);
                    idx += 1;
                }
            }
        }

        // Colors 232-255: Grayscale ramp
        for i in 0..24 {
            let gray = (8 + i * 10) as u8;
            extended_colors[232 + i] = rgb_to_hsla(Rgb {
                r: gray,
                g: gray,
                b: gray,
            });
        }

        // Default terminal colors
        let foreground = rgb_to_hsla(Rgb {
            r: 0xd4,
            g: 0xd4,
            b: 0xd4,
        }); // Light gray
        let background = rgb_to_hsla(Rgb {
            r: 0x1e,
            g: 0x1e,
            b: 0x1e,
        }); // Dark gray
        let cursor = rgb_to_hsla(Rgb {
            r: 0xff,
            g: 0xff,
            b: 0xff,
        }); // White

        Self {
            ansi_colors,
            extended_colors,
            foreground,
            background,
            cursor,
        }
    }
}

impl ColorPalette {
    /// Creates a new color palette with default colors.
    pub fn new() -> Self {
        Self::default()
    }

    /// Creates a new color palette builder for customizing colors.
    ///
    /// # Example
    ///
    /// ```
    /// use gpui_terminal::ColorPalette;
    ///
    /// let palette = ColorPalette::builder()
    ///     .background(0x16, 0x16, 0x17)
    ///     .foreground(0xC9, 0xC7, 0xCD)
    ///     .black(0x10, 0x10, 0x10)
    ///     .red(0xEF, 0xA6, 0xA2)
    ///     .build();
    /// ```
    pub fn builder() -> ColorPaletteBuilder {
        ColorPaletteBuilder::new()
    }

    /// Resolves a terminal color to a GPUI Hsla color.
    ///
    /// This method handles all terminal color types:
    /// - Named ANSI colors (0-15)
    /// - 256-color palette colors
    /// - True color (RGB) values
    ///
    /// # Arguments
    ///
    /// * `color` - The terminal color to resolve
    /// * `colors` - Optional color overrides from the terminal configuration
    ///
    /// # Returns
    ///
    /// The resolved Hsla color suitable for use with GPUI
    pub fn resolve(&self, color: Color, colors: &Colors) -> Hsla {
        match color {
            Color::Named(named) => {
                // Check if there's a custom color override first
                if let Some(rgb) = colors[named] {
                    return rgb_to_hsla(rgb);
                }

                // Handle different named color types
                let idx = named as usize;
                if idx < 16 {
                    // Standard ANSI colors (0-15)
                    self.ansi_colors[idx]
                } else {
                    // Special colors (Foreground, Background, Cursor, etc.)
                    match named {
                        NamedColor::Foreground => self.foreground,
                        NamedColor::Background => self.background,
                        NamedColor::Cursor => self.cursor,
                        NamedColor::DimForeground => {
                            // Dimmed version of foreground
                            let mut dim = self.foreground;
                            dim.l *= 0.7;
                            dim
                        }
                        NamedColor::BrightForeground => {
                            // Brighter version of foreground
                            let mut bright = self.foreground;
                            bright.l = (bright.l * 1.2).min(1.0);
                            bright
                        }
                        NamedColor::DimBlack
                        | NamedColor::DimRed
                        | NamedColor::DimGreen
                        | NamedColor::DimYellow
                        | NamedColor::DimBlue
                        | NamedColor::DimMagenta
                        | NamedColor::DimCyan
                        | NamedColor::DimWhite => {
                            // Dim variant - calculate base color index and dim it
                            let base_idx = match named {
                                NamedColor::DimBlack => 0,
                                NamedColor::DimRed => 1,
                                NamedColor::DimGreen => 2,
                                NamedColor::DimYellow => 3,
                                NamedColor::DimBlue => 4,
                                NamedColor::DimMagenta => 5,
                                NamedColor::DimCyan => 6,
                                NamedColor::DimWhite => 7,
                                _ => 7,
                            };
                            let mut dim = self.ansi_colors[base_idx];
                            dim.l *= 0.7;
                            dim
                        }
                        _ => self.foreground, // Fallback for any other special colors
                    }
                }
            }
            Color::Spec(rgb) => {
                // True color (24-bit RGB)
                rgb_to_hsla(rgb)
            }
            Color::Indexed(idx) => {
                // 256-color mode
                self.extended_colors[idx as usize]
            }
        }
    }

    /// Gets a reference to the ANSI color palette.
    pub fn ansi_colors(&self) -> &[Hsla; 16] {
        &self.ansi_colors
    }

    /// Gets a reference to the full 256-color palette.
    pub fn extended_colors(&self) -> &[Hsla; 256] {
        &self.extended_colors
    }

    /// Gets the default foreground color.
    pub fn foreground(&self) -> Hsla {
        self.foreground
    }

    /// Gets the default background color.
    pub fn background(&self) -> Hsla {
        self.background
    }

    /// Gets the default cursor color.
    pub fn cursor(&self) -> Hsla {
        self.cursor
    }
}

/// Converts an RGB color to GPUI's Hsla color format.
///
/// # Arguments
///
/// * `rgb` - The RGB color to convert (each component is 0-255)
///
/// # Returns
///
/// The converted Hsla color with full opacity
fn rgb_to_hsla(rgb: Rgb) -> Hsla {
    // Normalize RGB values to 0.0-1.0 range
    let r = rgb.r as f32 / 255.0;
    let g = rgb.g as f32 / 255.0;
    let b = rgb.b as f32 / 255.0;

    let max = r.max(g).max(b);
    let min = r.min(g).min(b);
    let delta = max - min;

    // Calculate lightness
    let l = (max + min) / 2.0;

    // Calculate saturation
    let s = if delta == 0.0 {
        0.0
    } else {
        delta / (1.0 - (2.0 * l - 1.0).abs())
    };

    // Calculate hue
    let h = if delta == 0.0 {
        0.0
    } else if max == r {
        60.0 * (((g - b) / delta) % 6.0)
    } else if max == g {
        60.0 * (((b - r) / delta) + 2.0)
    } else {
        60.0 * (((r - g) / delta) + 4.0)
    };

    // Normalize hue to 0.0-1.0 range (GPUI uses normalized values)
    let h = if h < 0.0 { h + 360.0 } else { h } / 360.0;

    Hsla {
        h,
        s,
        l,
        a: 1.0, // Full opacity
    }
}

/// Builder for creating a customized color palette.
///
/// Start with default colors and override specific ones as needed.
#[derive(Debug, Clone)]
pub struct ColorPaletteBuilder {
    palette: ColorPalette,
}

impl Default for ColorPaletteBuilder {
    fn default() -> Self {
        Self::new()
    }
}

impl ColorPaletteBuilder {
    /// Creates a new builder with default colors.
    pub fn new() -> Self {
        Self {
            palette: ColorPalette::default(),
        }
    }

    /// Sets the background color.
    pub fn background(mut self, r: u8, g: u8, b: u8) -> Self {
        self.palette.background = rgb_to_hsla(Rgb { r, g, b });
        self
    }

    /// Sets the foreground color.
    pub fn foreground(mut self, r: u8, g: u8, b: u8) -> Self {
        self.palette.foreground = rgb_to_hsla(Rgb { r, g, b });
        self
    }

    /// Sets the cursor color.
    pub fn cursor(mut self, r: u8, g: u8, b: u8) -> Self {
        self.palette.cursor = rgb_to_hsla(Rgb { r, g, b });
        self
    }

    /// Sets color 0 (black).
    pub fn black(mut self, r: u8, g: u8, b: u8) -> Self {
        self.set_ansi_color(0, r, g, b);
        self
    }

    /// Sets color 1 (red).
    pub fn red(mut self, r: u8, g: u8, b: u8) -> Self {
        self.set_ansi_color(1, r, g, b);
        self
    }

    /// Sets color 2 (green).
    pub fn green(mut self, r: u8, g: u8, b: u8) -> Self {
        self.set_ansi_color(2, r, g, b);
        self
    }

    /// Sets color 3 (yellow).
    pub fn yellow(mut self, r: u8, g: u8, b: u8) -> Self {
        self.set_ansi_color(3, r, g, b);
        self
    }

    /// Sets color 4 (blue).
    pub fn blue(mut self, r: u8, g: u8, b: u8) -> Self {
        self.set_ansi_color(4, r, g, b);
        self
    }

    /// Sets color 5 (magenta).
    pub fn magenta(mut self, r: u8, g: u8, b: u8) -> Self {
        self.set_ansi_color(5, r, g, b);
        self
    }

    /// Sets color 6 (cyan).
    pub fn cyan(mut self, r: u8, g: u8, b: u8) -> Self {
        self.set_ansi_color(6, r, g, b);
        self
    }

    /// Sets color 7 (white).
    pub fn white(mut self, r: u8, g: u8, b: u8) -> Self {
        self.set_ansi_color(7, r, g, b);
        self
    }

    /// Sets color 8 (bright black).
    pub fn bright_black(mut self, r: u8, g: u8, b: u8) -> Self {
        self.set_ansi_color(8, r, g, b);
        self
    }

    /// Sets color 9 (bright red).
    pub fn bright_red(mut self, r: u8, g: u8, b: u8) -> Self {
        self.set_ansi_color(9, r, g, b);
        self
    }

    /// Sets color 10 (bright green).
    pub fn bright_green(mut self, r: u8, g: u8, b: u8) -> Self {
        self.set_ansi_color(10, r, g, b);
        self
    }

    /// Sets color 11 (bright yellow).
    pub fn bright_yellow(mut self, r: u8, g: u8, b: u8) -> Self {
        self.set_ansi_color(11, r, g, b);
        self
    }

    /// Sets color 12 (bright blue).
    pub fn bright_blue(mut self, r: u8, g: u8, b: u8) -> Self {
        self.set_ansi_color(12, r, g, b);
        self
    }

    /// Sets color 13 (bright magenta).
    pub fn bright_magenta(mut self, r: u8, g: u8, b: u8) -> Self {
        self.set_ansi_color(13, r, g, b);
        self
    }

    /// Sets color 14 (bright cyan).
    pub fn bright_cyan(mut self, r: u8, g: u8, b: u8) -> Self {
        self.set_ansi_color(14, r, g, b);
        self
    }

    /// Sets color 15 (bright white).
    pub fn bright_white(mut self, r: u8, g: u8, b: u8) -> Self {
        self.set_ansi_color(15, r, g, b);
        self
    }

    /// Sets an ANSI color by index (0-15).
    fn set_ansi_color(&mut self, idx: usize, r: u8, g: u8, b: u8) {
        let color = rgb_to_hsla(Rgb { r, g, b });
        self.palette.ansi_colors[idx] = color;
        self.palette.extended_colors[idx] = color;
    }

    /// Builds the color palette.
    pub fn build(self) -> ColorPalette {
        self.palette
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_rgb_to_hsla_black() {
        let rgb = Rgb { r: 0, g: 0, b: 0 };
        let hsla = rgb_to_hsla(rgb);
        assert_eq!(hsla.l, 0.0);
        assert_eq!(hsla.s, 0.0);
        assert_eq!(hsla.a, 1.0);
    }

    #[test]
    fn test_rgb_to_hsla_white() {
        let rgb = Rgb {
            r: 255,
            g: 255,
            b: 255,
        };
        let hsla = rgb_to_hsla(rgb);
        assert_eq!(hsla.l, 1.0);
        assert_eq!(hsla.s, 0.0);
        assert_eq!(hsla.a, 1.0);
    }

    #[test]
    fn test_rgb_to_hsla_red() {
        let rgb = Rgb { r: 255, g: 0, b: 0 };
        let hsla = rgb_to_hsla(rgb);
        assert_eq!(hsla.h, 0.0);
        assert_eq!(hsla.s, 1.0);
        assert_eq!(hsla.a, 1.0);
    }

    #[test]
    fn test_color_palette_default() {
        let palette = ColorPalette::default();
        assert_eq!(palette.ansi_colors.len(), 16);
        assert_eq!(palette.extended_colors.len(), 256);
    }

    #[test]
    fn test_resolve_named_color() {
        use alacritty_terminal::vte::ansi::NamedColor;

        let palette = ColorPalette::new();
        let colors = Colors::default();
        let hsla = palette.resolve(Color::Named(NamedColor::Red), &colors);
        assert!(hsla.a > 0.0); // Should have some opacity
    }

    #[test]
    fn test_resolve_indexed_color() {
        let palette = ColorPalette::new();
        let colors = Colors::default();
        let hsla = palette.resolve(Color::Indexed(42), &colors);
        assert_eq!(hsla.a, 1.0);
    }

    #[test]
    fn test_resolve_spec_color() {
        let palette = ColorPalette::new();
        let colors = Colors::default();
        let rgb = Rgb {
            r: 128,
            g: 64,
            b: 192,
        };
        let hsla = palette.resolve(Color::Spec(rgb), &colors);
        assert_eq!(hsla.a, 1.0);
    }
}

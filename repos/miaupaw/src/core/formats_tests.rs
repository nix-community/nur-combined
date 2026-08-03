//! Tests for the template engine and color conversions (`formats.rs`).

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

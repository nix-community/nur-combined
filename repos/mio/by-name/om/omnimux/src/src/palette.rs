use gpui::WindowAppearance;
use gpui_terminal::color_scheme::is_dark_rgb;
use gpui_terminal::ColorPalette;

pub const DEFAULT_FONT_SIZE: f32 = 14.0;

/// Fallback families for glyphs missing from the primary monospace (Starship nerd
/// icons, powerline separators, and default emoji like hostname `ssh_symbol` 🌐).
pub fn symbol_font_fallbacks() -> Vec<String> {
    vec![
        "Symbols Nerd Font Mono".into(),
        "Symbols Nerd Font".into(),
        "Noto Color Emoji".into(),
    ]
}

pub fn is_dark_appearance(appearance: WindowAppearance) -> bool {
    matches!(
        appearance,
        WindowAppearance::Dark | WindowAppearance::VibrantDark
    )
}

/// `COLORFGBG` hint used by Cursor CLI and others when OSC 11 is unavailable.
/// Format is `fg;bg` as ANSI color indices (see Cursor terminal-setup docs).
pub fn colorfgbg_for_palette(colors: &ColorPalette) -> &'static str {
    if is_dark_rgb(colors.background_rgb()) {
        "15;0" // light-on-dark
    } else {
        "0;15" // dark-on-light
    }
}

pub fn palette_for_appearance(appearance: WindowAppearance) -> ColorPalette {
    if is_dark_appearance(appearance) {
        ColorPalette::default()
    } else {
        ColorPalette::builder()
            .background(0xff, 0xff, 0xff)
            .foreground(0x1e, 0x1e, 0x1e)
            .cursor(0x1e, 0x1e, 0x1e)
            .black(0x1e, 0x1e, 0x1e)
            .bright_black(0x55, 0x55, 0x55)
            .white(0xbb, 0xbb, 0xbb)
            .bright_white(0x88, 0x88, 0x88)
            .build()
    }
}

use gpui::SharedString;
use gpui::WindowAppearance;
use gpui_terminal::ColorPalette;

pub const DEFAULT_FONT_SIZE: f32 = 14.0;

/// Font family for title-bar icons (shipped under `$out/share/omnimux/fonts`).
pub const CHROME_ICON_FONT: &str = "Symbols Nerd Font";

/// Monochrome Nerd Font (PUA) glyphs for chrome — avoids KDE/Plasma color emoji.
pub fn chrome_search_icon() -> SharedString {
    "\u{f002}".into() // nf-fa-search
}

pub fn chrome_settings_icon() -> SharedString {
    "\u{f013}".into() // nf-fa-cog
}

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

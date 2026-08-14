use gpui::{App, WindowAppearance};
use gpui_terminal::color_scheme::is_dark_rgb;
use gpui_terminal::ColorPalette;

pub const DEFAULT_FONT_SIZE: f32 = 14.0;

/// Bundled last-resort face (`Hack-*.ttf` via `OMNIMUX_FONTS_DIR`) when no
/// system monospace family is registered with GPUI/fontdb.
pub const BUNDLED_TERMINAL_FONT_FAMILY: &str = "Hack";

/// Installed monospace families, preferred before the bundled Hack fallback.
/// GPUI matches font *file* family names, not fontconfig's `monospace` alias.
const PREFERRED_TERMINAL_FONTS: &[&str] = &[
    "SF Mono",
    "SFMono",
    "Menlo",
    "Monaco",
    "JetBrains Mono",
    "Cascadia Code",
    "Cascadia Mono",
    "Fira Code",
    "Fira Mono",
    "Source Code Pro",
    "Inconsolata",
    "DejaVu Sans Mono",
    "Noto Sans Mono",
    "Liberation Mono",
    "Ubuntu Mono",
    "Roboto Mono",
    "IBM Plex Mono",
    "Lilex",
    "Consolas",
    "Courier New",
];

/// Pick an installed system mono font; only use bundled Hack if none exist.
pub fn preferred_terminal_font_family(cx: &App) -> String {
    let names = cx.text_system().all_font_names();
    for candidate in PREFERRED_TERMINAL_FONTS {
        if let Some(found) = names.iter().find(|n| n.eq_ignore_ascii_case(candidate)) {
            return found.clone();
        }
    }
    BUNDLED_TERMINAL_FONT_FAMILY.to_string()
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

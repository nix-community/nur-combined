use gpui::{App, WindowAppearance};
use gpui_terminal::color_scheme::is_dark_rgb;
use gpui_terminal::ColorPalette;

pub const DEFAULT_FONT_SIZE: f32 = 14.0;

/// Bundled last-resort face (`Hack-*.ttf` via `OMNIMUX_FONTS_DIR`) when Linux has
/// no usable monospace family in GPUI/fontdb.
pub const BUNDLED_TERMINAL_FONT_FAMILY: &str = "Hack";

/// Real monospace family names (fontdb), never fontconfig's `monospace` alias.
/// GPUI `resolve_font("monospace")` falls through to Noto Sans on many KDE hosts.
/// Prefer SF Mono first (matches typical NixOS/ipc fontconfig); keep Nerd families
/// after plain monos so Starship can still use Symbols Nerd Font fallbacks when
/// the primary has no PUA glyphs.
const PREFERRED_LINUX_TERMINAL_FONTS: &[&str] = &[
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
    // Nerd-patched faces last among installed picks: full of PUA glyphs, but
    // Mono vs non-Mono cell widths differ; prefer a plain mono + Symbols fallback.
    "FiraCode Nerd Font",
    "FiraCode Nerd Font Mono",
    "Hack",
];

/// Primary terminal font family for new sessions.
///
/// - macOS: Menlo
/// - Linux: first installed name from [`PREFERRED_LINUX_TERMINAL_FONTS`], else
///   bundled Hack (GPUI does not honor fontconfig `monospace`)
/// - other: generic monospace
pub fn terminal_font_family(cx: &App) -> String {
    if cfg!(target_os = "macos") {
        return "Menlo".into();
    }
    if !cfg!(target_os = "linux") {
        return "monospace".into();
    }
    let names = cx.text_system().all_font_names();
    for candidate in PREFERRED_LINUX_TERMINAL_FONTS {
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

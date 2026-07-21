use std::path::PathBuf;

/// Directories that may contain shipped Nerd Font Symbols TTFs.
fn symbol_font_dirs() -> Vec<PathBuf> {
    let mut dirs = Vec::new();
    if let Ok(dir) = std::env::var("OMNIMUX_FONTS_DIR") {
        dirs.push(PathBuf::from(dir));
    }
    if let Ok(exe) = std::env::current_exe() {
        if let Some(bin_dir) = exe.parent() {
            // Nix: $out/bin/omnimux → $out/share/omnimux/fonts
            dirs.push(bin_dir.join("../share/omnimux/fonts"));
            dirs.push(bin_dir.join("fonts"));
            // Darwin .app: Contents/MacOS/Omnimux → Contents/Resources/fonts
            dirs.push(bin_dir.join("../Resources/fonts"));
        }
    }
    dirs
}

/// Load bundled Nerd + emoji fonts into GPUI for Starship / powerline fallbacks.
pub fn load_bundled_symbol_fonts(cx: &gpui::App) {
    use std::borrow::Cow;

    let mut fonts: Vec<Cow<'static, [u8]>> = Vec::new();
    for dir in symbol_font_dirs() {
        let Ok(entries) = std::fs::read_dir(&dir) else {
            continue;
        };
        for entry in entries.flatten() {
            let path = entry.path();
            let is_ttf = path
                .extension()
                .and_then(|e| e.to_str())
                .is_some_and(|e| e.eq_ignore_ascii_case("ttf"));
            if !is_ttf {
                continue;
            }
            if let Ok(bytes) = std::fs::read(&path) {
                fonts.push(Cow::Owned(bytes));
            }
        }
    }
    if fonts.is_empty() {
        return;
    }
    if let Err(err) = cx.text_system().add_fonts(fonts) {
        eprintln!("omnimux: failed to load bundled symbol fonts: {err}");
    }
}

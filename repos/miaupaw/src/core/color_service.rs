use arboard::Clipboard;

use crate::core::config::{Config, ELITE_FONTS};
use crate::core::formats;
use crate::core::text;
use crate::core::terminal::{Styled, log_step, log_info, log_error, log_plain, log_success};
use crate::daemon::timer::Perf;

/// Shared daemon business logic.
///
/// Single point of responsibility for:
///   - Config management (load, hot-reload, save)
///   - Font management (lookup, caching, hot-swap)
///   - Copying color to clipboard
///   - Maintaining color selection history
///
/// Used by both backends (Wayland and X11) via composition.
pub struct ColorService {
    pub config: Config,
    clipboard: Option<Clipboard>,
    #[cfg(unix)]
    pub dbus_conn: Option<zbus::blocking::Connection>,

    // --- Font Management ---
    font_db: fontdb::Database,
    cached_font_family: String,
    pub cached_font_data: std::sync::Arc<Vec<u8>>,
    pub hud_font_data: std::sync::Arc<Vec<u8>>,
}

impl Default for ColorService {
    fn default() -> Self {
        Self::new()
    }
}

impl ColorService {
    pub fn new() -> Self {
        let config = Config::load(false);
        #[cfg(unix)]
        crate::daemon::dbus_menu::DBusMenu::prime_layout_state(&config);
        let clipboard = Clipboard::new().ok();
        #[cfg(unix)]
        let dbus_conn = zbus::blocking::Connection::session().ok();

        // Font database is initialized once at daemon startup.
        let mut font_db = fontdb::Database::new();
        let mut perf = Perf::new();
        font_db.load_system_fonts();
        perf.log("System fonts loaded into DB");

        let font_data = std::sync::Arc::new(text::find_best_font(&font_db, &config.font.family, ELITE_FONTS));
        let raw_hud = text::load_hud_font(&font_db);
        let hud_font_data = if raw_hud.is_empty() { font_data.clone() } else { std::sync::Arc::new(raw_hud) };

        let cached_font_family = config.font.family.clone();
        Self {
            config,
            clipboard,
            #[cfg(unix)]
            dbus_conn,
            font_db,
            cached_font_family,
            cached_font_data: font_data,
            hud_font_data,
        }
    }

    /// Hot-reload of config and fonts.
    ///
    /// Called before each overlay launch (hotkey / SIGUSR1).
    /// Font is reloaded only when `font.family` changes — expensive operation.
    /// The font database (`font_db`) is loaded once at startup and stays in memory.
    /// Returns `Perf` for chained logging in the caller.
    pub fn reload_config(&mut self) -> Perf {
        let mut perf = Perf::new();
        perf.log("Hotkey/Event detected");

        self.config = Config::load(true);
        log_info("Configuration hot-reloaded");
        #[cfg(unix)]
        crate::daemon::dbus_menu::DBusMenu::notify_layout_update(&self.config);
        perf.log("Config loaded");

        // Font hot-reload: if font family changed, search in the already-loaded database.
        if self.config.font.family != self.cached_font_family {
            log_step("Font", &format!("Config font changed to '{}'. Re-hunting...", self.config.font.family));
            self.cached_font_data = std::sync::Arc::new(text::find_best_font(
                &self.font_db,
                &self.config.font.family,
                ELITE_FONTS,
            ));
            self.cached_font_family = self.config.font.family.clone();
            perf.log("New font loaded from cache");
        }

        perf
    }

    /// Converts RGB → selected format + copies to clipboard.
    ///
    /// Accepts a slice of `Rgba<u8>` (multiple in serial/deck mode).
    /// For each color: formats via `format_color`, prints an ANSI swatch to the terminal,
    /// appends to `clipboard_texts`. Final string is joined with `deck_separator`.
    /// History is updated in-memory only; `save()` is called externally in `finalize_overlay`.
    pub fn copy_color(&mut self, colors: &[image::Rgba<u8>]) {
        if colors.is_empty() { return; }

        let mut clipboard_texts = Vec::new();
        // Clone the template to drop the immutable borrow of config on `self`
        let selected_fmt = self.config.templates.get_selected_template().to_string();
        let precision = self.config.templates.float_precision;

        for color in colors {
            let r = color.0[0]; let g = color.0[1]; let b = color.0[2];
            let hex = formats::rgb_to_hex(r, g, b);
            let text = formats::format_color(&selected_fmt, r, g, b, precision);

            // Truecolor ANSI swatch of the picked pixel color
            let swatch = "██".rgb(r, g, b);
            log_plain("Color", &format!("{} {} → {}", swatch, hex.as_str().bold(), text.as_str().cyan()));

            clipboard_texts.push(text);
            self.save_history_entry(hex);
        }

        let separator = self.config.templates.deck_separator.replace("{nl}", "\n");
        let final_text = clipboard_texts.join(&separator);

        if let Some(clipboard) = &mut self.clipboard {
            if let Err(e) = clipboard.set_text(final_text) {
                log_error(&format!("Failed to copy to clipboard: {}", e));
            } else {
                log_step("Clipboard", &format!("Copied {} color(s)", clipboard_texts.len()));
            }
        } else if let Ok(mut clipboard) = Clipboard::new() {
            let _ = clipboard.set_text(final_text);
            self.clipboard = Some(clipboard);
            log_step("Clipboard", &format!("Copied {} color(s)", clipboard_texts.len()));
        } else {
            log_error("Clipboard not available.");
        }
    }

    /// Single overlay finalization entry point.
    ///
    /// Called after overlay closes (click, ESC, blink end).
    /// Accepts overlay config (`overlay_config`) — it may have changed during the session.
    ///
    /// Four steps (always in this order):
    ///   1. Sync   — merge changed fields from overlay_config back into self.config
    ///   2. Copy   — if colors picked: clipboard + history; otherwise log "cancelled"
    ///   3. Save   — single disk write: config + history together
    ///   4. Notify — update tray menu from the already-current self.config
    pub fn finalize_overlay(&mut self, overlay_config: &crate::core::config::Config, color_deck: Vec<image::Rgba<u8>>) {
        //    Sync: optics/HUD/format settings from overlay → daemon config
        self.config.magnifier.aperture = overlay_config.magnifier.aperture;
        self.config.magnifier.aim_size = overlay_config.magnifier.aim_size;
        self.config.magnifier.size = overlay_config.magnifier.size;
        self.config.font.size = overlay_config.font.size;
        self.config.hud.show = overlay_config.hud.show;
        self.config.templates.selected = overlay_config.templates.selected.clone();

        //    Copy: if colors were picked — to clipboard + history
        if !color_deck.is_empty() {
            self.copy_color(&color_deck);
        } else {
            log_info("Selection cancelled.");
        }

        //    Save: single disk write (settings + history)
        self.config.save();
        log_success("Saved", "Configuration and history updated");

        //    Notify: update tray menu — data is already current in self.config
        #[cfg(unix)]
        crate::daemon::dbus_menu::DBusMenu::notify_layout_update(&self.config);
    }

    fn save_history_entry(&mut self, hex: String) {
        self.config.push_history(hex);
        // Do not call save() here — avoids a double disk write.
    }
}

use std::sync::LazyLock;
use serde::{Deserialize, Serialize};
use std::fs;
use std::io::ErrorKind;
use crate::core::terminal::{log_step, log_warn, log_error};

// ==============================================================================
// --- THE SACRED TEXT (DEFAULT TEMPLATE) ---
// The default config is baked directly into the binary.
// This is the single Source of Truth for comments, structure, and default values.
// ==============================================================================
const DEFAULT_CONFIG_TEMPLATE: &str = include_str!("default_config.toml");

// Windows ships a different default hotkey — Alt+Backquote is free there,
// while on Linux it conflicts with KDE's window-switching shortcut.
#[cfg(windows)]
const DEFAULT_HOTKEY_WINDOWS: &str = "Alt+Shift+X";

/// Static default config instance for internal use (serde/defaults).
/// Parsed exactly once on first access.
static DEFAULT_INSTANCE: LazyLock<Config> = LazyLock::new(|| {
    toml_edit::de::from_str(DEFAULT_CONFIG_TEMPLATE)
        .expect("Failed to parse baked-in default_config.toml! Check syntax.")
});

// ==============================================================================
// --- DEVELOPER CONTROL PANEL (LOGIC & CALIBRATION) ---
// Logic that belongs in code lives here: weight calibration and resource lookup.
// ==============================================================================

/// Ordered list of preferred monospace fonts, from most to least preferred.
pub const ELITE_FONTS: &[&str] = &[
    "JetBrainsMono Nerd Font",
    "DroidSansM Nerd Font Mono",
    "RobotoMono Nerd Font Mono",
    "JetBrains Mono",
    "FiraCode Nerd Font",
    "Fira Code",
    "Hack Nerd Font",
    "Hack",
    "Cascadia Code",
    "Source Code Pro",
    "Inconsolata",
    "Ubuntu Mono",
    "DejaVu Sans Mono",
    "Liberation Mono",
    // Windows
    "Consolas",
    "Lucida Console",
    "Courier New",
];

// Font scale modifiers per format (visual density alignment).
pub const SCALE_MOD_HTML: f32 = 1.0;
pub const SCALE_MOD_HEX: f32 = 1.0;
pub const SCALE_MOD_RGB: f32 = 0.85;
pub const SCALE_MOD_RGBFLOAT: f32 = 0.60;
pub const SCALE_MOD_HSL: f32 = 0.75;
pub const SCALE_MOD_HSV: f32 = 0.75;
pub const SCALE_MOD_CMYK: f32 = 0.65;
pub const SCALE_MOD_DELPHI: f32 = 1.0;
pub const SCALE_MOD_VB: f32 = 1.0;
pub const SCALE_MOD_LONG: f32 = 1.0;

pub fn get_template_scale_modifier(template_key: &str) -> f32 {
    match template_key {
        "html" => SCALE_MOD_HTML,
        "hex" => SCALE_MOD_HEX,
        "rgb" => SCALE_MOD_RGB,
        "float" => SCALE_MOD_RGBFLOAT,
        "hsl" => SCALE_MOD_HSL,
        "hsv" => SCALE_MOD_HSV,
        "cmyk" => SCALE_MOD_CMYK,
        "delphi" => SCALE_MOD_DELPHI,
        "vb" => SCALE_MOD_VB,
        "long" => SCALE_MOD_LONG,
        _ => 1.0,
    }
}

/// Transforms a template for visual display in the Overlay.
/// Primary purpose: add zero-padding before passing to format_color.
pub fn transform_template_for_display(template: &str) -> String {
    let mut t = template.replace("{nl}", "\n");
    t = t
        .replace("{rd}", "{rd_pad}")
        .replace("{gd}", "{gd_pad}")
        .replace("{bd}", "{bd_pad}")
        .replace("{h}", "{h_pad}")
        .replace("{s}", "{s_pad}")
        .replace("{l}", "{l_pad}")
        .replace("{v}", "{v_pad}")
        .replace("{c}", "{c_pad}")
        .replace("{m}", "{m_pad}")
        .replace("{y}", "{y_pad}")
        .replace("{k}", "{k_pad}")
        .replace("{long}", "{long_pad}");
    t
}

/// Default color history shown on first run.
pub const DEFAULT_HISTORY_COLORS: &[&str] = &[
    "#E2B167",
    "#F9778F",
    "#BD9BF9",
    "#6E8CD3",
    "#7DCFFF",
    "#00F3FF",
    "#00FF88",
];

/// Display labels for the tray menu and HUD.
pub const TEMPLATE_LABELS: &[(&str, &str)] = &[
    ("html", "HTML"),
    ("hex", "Hex"),
    ("rgb", "RGB"),
    ("float", "RGB Float"),
    ("hsl", "HSL"),
    ("hsv", "HSV"),
    ("cmyk", "CMYK"),
    ("delphi", "Delphi"),
    ("vb", "VB Hex"),
    ("long", "Long"),
];

// ==============================================================================
// --- DATA STRUCTURES (THE SKELETON) ---
// ==============================================================================

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Config {
    #[serde(default)]
    pub magnifier: MagnifierConfig,
    #[serde(default)]
    pub colors: ColorsConfig,
    #[serde(default)]
    pub hud: HudConfig,
    #[serde(default)]
    pub font: FontConfig,
    #[serde(default)]
    pub physics: PhysicsConfig,
    #[serde(default)]
    pub templates: TemplatesConfig,
    #[serde(default)]
    pub history: HistoryConfig,
    #[serde(default)]
    pub system: SystemConfig,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MagnifierConfig {
    #[serde(default = "default_aperture")]
    pub aperture: u32,
    #[serde(default = "default_aim_size")]
    pub aim_size: u32,
    #[serde(default = "default_size")]
    pub size: u32,
    #[serde(default = "default_offset_x")]
    pub offset_x: i32,
    #[serde(default = "default_offset_y")]
    pub offset_y: i32,
    #[serde(default = "default_jump_threshold")]
    pub jump_threshold: i32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ColorsConfig {
    #[serde(default = "default_frame", with = "hex_color")]
    pub frame: u32,
    #[serde(default = "default_aim", with = "hex_color")]
    pub aim: u32,
    #[serde(default = "default_background", with = "hex_color")]
    pub background: u32,
    #[serde(default = "default_foreground", with = "hex_color")]
    pub foreground: u32,
    #[serde(default = "default_grid", with = "hex_color")]
    pub grid: u32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HudConfig {
    #[serde(default = "default_hud_show")]
    pub show: bool,
    #[serde(default = "default_hud_heavy_chance")]
    pub heavy_glitch_chance: u32,
    #[serde(default = "default_hud_light_chance")]
    pub light_glitch_chance: u32,
    #[serde(default = "default_hud_chromatic_chance")]
    pub chromatic_chance: u32,
    #[serde(default = "default_hud_scanlines")]
    pub scanlines_intensity: f32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FontConfig {
    #[serde(default = "default_font_family")]
    pub family: String,
    #[serde(default = "default_font_size")]
    pub size: f32,
    #[serde(default = "default_dim_zeros")]
    pub dim_zeros: f32,
    #[serde(default = "default_padding_left")]
    pub padding_left: String,
    #[serde(default = "default_padding_right")]
    pub padding_right: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PhysicsConfig {
    #[serde(default = "default_blur_radius")]
    pub blur_radius: i32,
    #[serde(default = "default_glass_opacity")]
    pub glass_opacity: f32,
    #[serde(default = "default_stiffness")]
    pub stiffness: f64,
    #[serde(default = "default_damping")]
    pub damping: f64,
    #[serde(default = "default_pop_effect")]
    pub pop_effect: f64,
    #[serde(default = "default_blink_effect")]
    pub blink_effect: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TemplatesConfig {
    #[serde(default = "default_selected_template")]
    pub selected: String,
    #[serde(default = "default_float_precision")]
    pub float_precision: usize,
    #[serde(default = "default_deck_separator")]
    pub deck_separator: String,
    #[serde(default)]
    pub copy: CopyTemplatesConfig,
    #[serde(default)]
    pub show: ShowTemplatesConfig,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CopyTemplatesConfig {
    #[serde(default = "default_tpl_html")]
    pub html: String,
    #[serde(default = "default_tpl_hex")]
    pub hex: String,
    #[serde(default = "default_tpl_rgb")]
    pub rgb: String,
    #[serde(default = "default_tpl_float")]
    pub float: String,
    #[serde(default = "default_tpl_hsl")]
    pub hsl: String,
    #[serde(default = "default_tpl_hsv")]
    pub hsv: String,
    #[serde(default = "default_tpl_cmyk")]
    pub cmyk: String,
    #[serde(default = "default_tpl_delphi")]
    pub delphi: String,
    #[serde(default = "default_tpl_vb")]
    pub vb: String,
    #[serde(default = "default_tpl_long")]
    pub long: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ShowTemplatesConfig {
    #[serde(default = "default_line_spacing")]
    pub line_spacing: f32,
    #[serde(flatten)]
    pub formats: indexmap::IndexMap<String, String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HistoryConfig {
    #[serde(default = "default_history_size")]
    pub size: usize,
    #[serde(default = "default_history_reverse")]
    pub reverse_order: bool,
    #[serde(default = "default_history_colors", skip_serializing)]
    pub colors: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
struct PersistedHistory {
    #[serde(default = "default_history_colors")]
    colors: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
#[serde(rename_all = "kebab-case")]
#[derive(Default)]
pub enum TrayIcon {
    #[default]
    Color,     // full-color pixmap, empty icon_name (all tray hosts)
    Mono,      // empty pixmap, icon_name="ie-r-symbolic" (DE-themed, DE must support it)
    MonoWhite, // white pixmap, empty icon_name (dark panels)
    MonoBlack, // black pixmap, empty icon_name (light panels)
    None,      // no tray icon, SNI not registered
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SystemConfig {
    #[serde(default)]
    pub tray_icon: TrayIcon,
    #[serde(default = "default_auto_cancel")]
    pub auto_cancel: u64,
    #[cfg(windows)]
    #[serde(default = "default_welcome_balloon")]
    pub welcome_balloon: bool,
    #[serde(default = "default_hotkey")]
    pub hotkey: String,
    #[serde(default = "default_poll_interval_ms")]
    pub poll_interval_ms: u64,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub menu_command: Option<Vec<String>>,
}

// --- Hex Color Serializer/Deserializer ---
mod hex_color {
    use serde::{self, Deserialize, Deserializer, Serializer};
    pub fn serialize<S>(value: &u32, serializer: S) -> Result<S::Ok, S::Error>
    where S: Serializer {
        let s = format!("#{:06X}", value & 0xFFFFFF);
        serializer.serialize_str(&s)
    }
    pub fn deserialize<'de, D>(deserializer: D) -> Result<u32, D::Error>
    where D: Deserializer<'de> {
        let s = String::deserialize(deserializer)?;
        let hex = s.trim_start_matches('#');
        u32::from_str_radix(hex, 16).map_err(serde::de::Error::custom)
    }
}

// ==============================================================================
// --- DEFAULT IMPLEMENTATIONS (SYNCED WITH TOML) ---
// These functions ensure correct serde behavior with partially-filled configs.
// All delegate to DEFAULT_INSTANCE parsed from default_config.toml.
// ==============================================================================

impl Default for Config { fn default() -> Self { DEFAULT_INSTANCE.clone() } }
impl Default for MagnifierConfig { fn default() -> Self { DEFAULT_INSTANCE.magnifier.clone() } }
impl Default for ColorsConfig { fn default() -> Self { DEFAULT_INSTANCE.colors.clone() } }
impl Default for HudConfig { fn default() -> Self { DEFAULT_INSTANCE.hud.clone() } }
impl Default for FontConfig { fn default() -> Self { DEFAULT_INSTANCE.font.clone() } }
impl Default for PhysicsConfig { fn default() -> Self { DEFAULT_INSTANCE.physics.clone() } }
impl Default for TemplatesConfig { fn default() -> Self { DEFAULT_INSTANCE.templates.clone() } }
impl Default for CopyTemplatesConfig { fn default() -> Self { DEFAULT_INSTANCE.templates.copy.clone() } }
impl Default for ShowTemplatesConfig { fn default() -> Self { DEFAULT_INSTANCE.templates.show.clone() } }
impl Default for HistoryConfig { fn default() -> Self { DEFAULT_INSTANCE.history.clone() } }
impl Default for SystemConfig { fn default() -> Self { DEFAULT_INSTANCE.system.clone() } }

fn default_aperture() -> u32 { DEFAULT_INSTANCE.magnifier.aperture }
fn default_aim_size() -> u32 { DEFAULT_INSTANCE.magnifier.aim_size }
fn default_size() -> u32 { DEFAULT_INSTANCE.magnifier.size }
fn default_offset_x() -> i32 { DEFAULT_INSTANCE.magnifier.offset_x }
fn default_offset_y() -> i32 { DEFAULT_INSTANCE.magnifier.offset_y }
fn default_jump_threshold() -> i32 { DEFAULT_INSTANCE.magnifier.jump_threshold }
fn default_frame() -> u32 { DEFAULT_INSTANCE.colors.frame }
fn default_aim() -> u32 { DEFAULT_INSTANCE.colors.aim }
fn default_background() -> u32 { DEFAULT_INSTANCE.colors.background }
fn default_foreground() -> u32 { DEFAULT_INSTANCE.colors.foreground }
fn default_grid() -> u32 { DEFAULT_INSTANCE.colors.grid }
fn default_hud_show() -> bool { DEFAULT_INSTANCE.hud.show }
fn default_hud_heavy_chance() -> u32 { DEFAULT_INSTANCE.hud.heavy_glitch_chance }
fn default_hud_light_chance() -> u32 { DEFAULT_INSTANCE.hud.light_glitch_chance }
fn default_hud_chromatic_chance() -> u32 { DEFAULT_INSTANCE.hud.chromatic_chance }
fn default_hud_scanlines() -> f32 { DEFAULT_INSTANCE.hud.scanlines_intensity }
fn default_font_family() -> String { DEFAULT_INSTANCE.font.family.clone() }
fn default_font_size() -> f32 { DEFAULT_INSTANCE.font.size }
fn default_dim_zeros() -> f32 { DEFAULT_INSTANCE.font.dim_zeros }
fn default_padding_left() -> String { DEFAULT_INSTANCE.font.padding_left.clone() }
fn default_padding_right() -> String { DEFAULT_INSTANCE.font.padding_right.clone() }
fn default_blur_radius() -> i32 { DEFAULT_INSTANCE.physics.blur_radius }
fn default_glass_opacity() -> f32 { DEFAULT_INSTANCE.physics.glass_opacity }
fn default_stiffness() -> f64 { DEFAULT_INSTANCE.physics.stiffness }
fn default_damping() -> f64 { DEFAULT_INSTANCE.physics.damping }
fn default_pop_effect() -> f64 { DEFAULT_INSTANCE.physics.pop_effect }
fn default_blink_effect() -> String { DEFAULT_INSTANCE.physics.blink_effect.clone() }
fn default_selected_template() -> String { DEFAULT_INSTANCE.templates.selected.clone() }
fn default_float_precision() -> usize { DEFAULT_INSTANCE.templates.float_precision }
fn default_deck_separator() -> String { DEFAULT_INSTANCE.templates.deck_separator.clone() }
fn default_tpl_html() -> String { DEFAULT_INSTANCE.templates.copy.html.clone() }
fn default_tpl_hex() -> String { DEFAULT_INSTANCE.templates.copy.hex.clone() }
fn default_tpl_rgb() -> String { DEFAULT_INSTANCE.templates.copy.rgb.clone() }
fn default_tpl_float() -> String { DEFAULT_INSTANCE.templates.copy.float.clone() }
fn default_tpl_hsl() -> String { DEFAULT_INSTANCE.templates.copy.hsl.clone() }
fn default_tpl_hsv() -> String { DEFAULT_INSTANCE.templates.copy.hsv.clone() }
fn default_tpl_cmyk() -> String { DEFAULT_INSTANCE.templates.copy.cmyk.clone() }
fn default_tpl_delphi() -> String { DEFAULT_INSTANCE.templates.copy.delphi.clone() }
fn default_tpl_vb() -> String { DEFAULT_INSTANCE.templates.copy.vb.clone() }
fn default_tpl_long() -> String { DEFAULT_INSTANCE.templates.copy.long.clone() }
fn default_line_spacing() -> f32 { DEFAULT_INSTANCE.templates.show.line_spacing }
fn default_history_size() -> usize { DEFAULT_INSTANCE.history.size }
fn default_history_reverse() -> bool { DEFAULT_INSTANCE.history.reverse_order }
fn default_history_colors() -> Vec<String> {
    DEFAULT_HISTORY_COLORS.iter().map(|s| s.to_string()).collect()
}
fn default_hotkey() -> String {
    #[cfg(windows)]
    return DEFAULT_HOTKEY_WINDOWS.to_string();
    #[cfg(not(windows))]
    DEFAULT_INSTANCE.system.hotkey.clone()
}
fn default_poll_interval_ms() -> u64 { DEFAULT_INSTANCE.system.poll_interval_ms }
fn default_auto_cancel() -> u64 { DEFAULT_INSTANCE.system.auto_cancel }
#[cfg(windows)]
fn default_welcome_balloon() -> bool { DEFAULT_INSTANCE.system.welcome_balloon }
// TrayIcon uses #[serde(default)] → TrayIcon::default() → Color

// ==============================================================================
// --- METHODS (THE BRAIN) ---
// ==============================================================================

impl Config {
    pub fn get_config_path() -> std::path::PathBuf {
        #[cfg(windows)]
        { Self::get_config_path_windows() }
        #[cfg(not(windows))]
        {
            let base = std::env::var("XDG_CONFIG_HOME")
                .map(std::path::PathBuf::from)
                .unwrap_or_else(|_| dirs_next().join(".config"));
            base.join("ie-r").join("config.toml")
        }
    }

    /// Windows config path resolution (three-tier fallback):
    /// 1. Next to exe — portable install, existing config takes priority
    /// 2. HOME/.config/ie-r/ — current behavior, respects user-set HOME
    /// 3. %APPDATA%\ie-r\ — standard Windows user data location
    #[cfg(windows)]
    fn get_config_path_windows() -> std::path::PathBuf {
        // Tier 1: portable — next to exe
        if let Ok(exe) = std::env::current_exe()
            && let Some(exe_dir) = exe.parent() {
                let portable = exe_dir.join("config.toml");
                if portable.exists() || is_dir_writable(exe_dir) {
                    return portable;
                }
            }

        // Tier 2: HOME (current behavior)
        if let Ok(home) = std::env::var("HOME") {
            return std::path::PathBuf::from(home)
                .join(".config").join("ie-r").join("config.toml");
        }

        // Tier 3: standard Windows AppData\Roaming
        if let Ok(appdata) = std::env::var("APPDATA") {
            return std::path::PathBuf::from(appdata)
                .join("ie-r").join("config.toml");
        }

        // Last resort: current dir
        std::path::PathBuf::from("config.toml")
    }

    fn backup_broken_file(path: &std::path::Path, prefix: &str) {
        if !path.exists() {
            return;
        }
        if let Some(dir) = path.parent() {
            for idx in 1..=99 {
                let backup_path = dir.join(format!("{}_broken_{:02}.toml", prefix, idx));
                if !backup_path.exists() {
                    if fs::rename(path, &backup_path).is_ok() {
                        log_step("Config", &format!("Broken {} moved to {:?}", prefix, backup_path));
                    }
                    return;
                }
            }
            log_error(&format!("Too many broken {} files! Backup skipped.", prefix));
        }
    }

    pub fn get_history_path() -> std::path::PathBuf {
        #[cfg(windows)]
        { Self::get_config_path().with_file_name("history.toml") }
        #[cfg(not(windows))]
        {
            let base = std::env::var("XDG_STATE_HOME")
                .map(std::path::PathBuf::from)
                .unwrap_or_else(|_| dirs_next().join(".local").join("state"));
            base.join("ie-r").join("history.toml")
        }
    }

    fn parse_menu_command_from_str(content: &str) -> Option<Option<Vec<String>>> {
        let doc = content.parse::<toml_edit::DocumentMut>().ok()?;
        let item = doc.get("system").and_then(|system| system.get("menu_command"));
        match item {
            Some(item) if item.is_none() => Some(None),
            Some(item) => {
                let arr = item.as_array()?;
                let mut command = Vec::with_capacity(arr.len());
                for value in arr.iter() {
                    command.push(value.as_str()?.to_string());
                }
                Some(Some(command))
            }
            None => Some(None),
        }
    }

    pub fn read_menu_command_from_disk() -> Option<Option<Vec<String>>> {
        let content = fs::read_to_string(Self::get_config_path()).ok()?;
        Self::parse_menu_command_from_str(&content)
    }

    fn load_history_colors(path: &std::path::Path, legacy_colors: Vec<String>) -> Vec<String> {
        match fs::read_to_string(path) {
            Ok(content) => match toml_edit::de::from_str::<PersistedHistory>(&content) {
                Ok(history) => history.colors,
                Err(e) => {
                    log_error(&format!("Error parsing {:?}: {}", path, e));
                    Self::backup_broken_file(path, "history");
                    log_warn("Falling back to config-embedded history.");
                    legacy_colors
                }
            },
            Err(e) if e.kind() == ErrorKind::NotFound => legacy_colors,
            Err(e) => {
                log_error(&format!("Error reading {:?}: {}", path, e));
                log_warn("Falling back to config-embedded history.");
                legacy_colors
            }
        }
    }

    fn save_history(&self) -> Result<(), String> {
        let path = Self::get_history_path();
        if let Some(parent) = path.parent() {
            fs::create_dir_all(parent)
                .map_err(|e| format!("Error creating history directory {:?}: {}", parent, e))?;
        }
        let mut toml = String::from("colors = [\n");
        for color in &self.history.colors {
            toml.push_str(&format!("    \"{}\",\n", color));
        }
        toml.push_str("]\n");
        fs::write(&path, toml)
            .map_err(|e| format!("Error writing {:?}: {}", path, e))?;
        log_step("Config", &format!("Saved history: {:?}", path));
        Ok(())
    }

    /// Loads config from disk. Falls back to defaults if the file is missing or invalid.
    pub fn load(silent: bool) -> Self {
        let path = Self::get_config_path();
        let mut loaded_from_config = false;
        let mut config = if let Ok(content) = fs::read_to_string(&path) {
            match toml_edit::de::from_str::<Config>(&content) {
                Ok(mut config) => {
                    loaded_from_config = true;
                    if !silent { log_step("Config", &format!("Target confirmed: {}", path.display())); }
                    let legacy_colors = config.history.colors.clone();
                    config.history.colors = Self::load_history_colors(&Self::get_history_path(), legacy_colors);
                    config
                }
                Err(e) => {
                    log_error(&format!("Error parsing {}: {}", path.display(), e));
                    Self::backup_broken_file(&path, "config");
                    log_warn("Falling back to defaults. Backup created.");
                    let _ = fs::write(&path, DEFAULT_CONFIG_TEMPLATE);
                    Self::default()
                }
            }
        } else {
            if let Some(parent) = path.parent() { let _ = fs::create_dir_all(parent); }
            #[allow(unused_mut)]
            let mut template = DEFAULT_CONFIG_TEMPLATE.to_string();
            #[cfg(windows)]
            { template = template.replace(
                &format!(r#"hotkey = "{}""#, DEFAULT_INSTANCE.system.hotkey),
                &format!(r#"hotkey = "{}""#, DEFAULT_HOTKEY_WINDOWS),
            ); }
            let _ = fs::write(&path, template);
            log_step("Config", &format!("Initialized new config from template: {}", path.display()));
            #[allow(unused_mut)]
            let mut config = Self::default();
            #[cfg(windows)]
            { config.system.hotkey = DEFAULT_HOTKEY_WINDOWS.to_string(); }
            config
        };

        if !loaded_from_config && config.history.colors.is_empty() {
            config.history.colors = Self::load_history_colors(&Self::get_history_path(), Vec::new());
        }
        config
    }

    /// Surgically saves current settings to disk, preserving user comments.
    pub fn save(&self) {
        let path = Self::get_config_path();
        if let Some(parent) = path.parent() { let _ = fs::create_dir_all(parent); }

        let existing_content = fs::read_to_string(&path).unwrap_or_default();

        let mut doc = match existing_content.parse::<toml_edit::DocumentMut>() {
            Ok(d) => d,
            Err(_) => {
                log_warn("Repairing corrupted config using template foundation...");
                Self::backup_broken_file(&path, "config");
                DEFAULT_CONFIG_TEMPLATE.parse::<toml_edit::DocumentMut>().unwrap_or_default()
            }
        };

        let mut merged = self.clone();
        if let Some(menu_command) = Self::parse_menu_command_from_str(&existing_content) {
            merged.system.menu_command = menu_command;
        }

        let Ok(new_toml_str) = toml_edit::ser::to_string(&merged) else { return };
        let Ok(new_doc) = new_toml_str.parse::<toml_edit::DocumentMut>() else { return };

        let root = doc.as_table_mut();
        for (key, s_val) in new_doc.as_table().iter() {
            if let Some(t_val) = root.get_mut(key) {
                update_toml_item(t_val, s_val);
            } else {
                let mut new_item = s_val.clone();
                if let Some(t) = new_item.as_table_mut() { t.set_implicit(true); }
                root.insert(key, new_item);
            }
        }

        let history_saved = match self.save_history() {
            Ok(()) => true,
            Err(e) => { log_error(&e); false }
        };
        if history_saved || !has_history_colors(root) {
            remove_history_colors(root);
        }

        let output = doc.to_string();
        if toml_edit::de::from_str::<Config>(&output).is_err() {
            log_error("save() produced unparseable TOML — skipping write to prevent corruption");
            log_error(&format!("--- broken output ---\n{}\n--- end ---", output));
            return;
        }
        if fs::write(&path, output).is_ok() {
            log_step("Config", &format!("Saved changes: {}", path.display()));
        }
    }

    pub fn push_history(&mut self, hex: String) {
        self.history.colors.retain(|c| c != &hex);
        self.history.colors.insert(0, hex);
        if self.history.colors.len() > self.history.size {
            self.history.colors.truncate(self.history.size);
        }
    }

    /// Returns the default hotkey from the baked-in template.
    pub fn default_hotkey() -> String {
        DEFAULT_INSTANCE.system.hotkey.clone()
    }
}

impl TemplatesConfig {
    /// Returns the template for the current `selected` key. Fallback → html.
    pub fn get_selected_template(&self) -> &str {
        match self.selected.as_str() {
            "html" => &self.copy.html,
            "hex" => &self.copy.hex,
            "rgb" => &self.copy.rgb,
            "float" => &self.copy.float,
            "hsl" => &self.copy.hsl,
            "hsv" => &self.copy.hsv,
            "cmyk" => &self.copy.cmyk,
            "delphi" => &self.copy.delphi,
            "vb" => &self.copy.vb,
            "long" => &self.copy.long,
            _ => &self.copy.html,
        }
    }

    pub fn get_current_scale_modifier(&self) -> f32 {
        get_template_scale_modifier(&self.selected)
    }

    /// Returns the visual display template for the overlay.
    pub fn get_visual_template(&self) -> String {
        if let Some(vt) = self.show.formats.get(&self.selected) {
            vt.clone()
        } else {
            self.get_selected_template().to_string()
        }
    }
}

/// Recursive helper that updates a TOML document while preserving user comments.
fn update_toml_item(target: &mut toml_edit::Item, source: &toml_edit::Item) {
    if let Some(t_table) = target.as_table_mut() {
        if let Some(s_table) = source.as_table() {
            for (key, s_val) in s_table.iter() {
                if let Some(t_val) = t_table.get_mut(key) { update_toml_item(t_val, s_val); }
                else { t_table.insert(key, s_val.clone()); }
            }
            return;
        }
        if let Some(s_inline) = source.as_inline_table() {
            for (key, s_val) in s_inline.iter() {
                let s_item = toml_edit::Item::Value(s_val.clone());
                if let Some(t_val) = t_table.get_mut(key) { update_toml_item(t_val, &s_item); }
                else { t_table.insert(key, s_item); }
            }
            return;
        }
    }

    if let Some(t_inline) = target.as_inline_table_mut() {
        if let Some(s_inline) = source.as_inline_table() {
            for (key, s_val) in s_inline.iter() { t_inline.insert(key, s_val.clone()); }
            return;
        }
        if let Some(s_table) = source.as_table() {
            for (key, s_val) in s_table.iter() {
                if let Some(s_val_as_value) = s_val.as_value() { t_inline.insert(key, s_val_as_value.clone()); }
            }
            return;
        }
    }

    if let (Some(t_val), Some(s_val)) = (target.as_value_mut(), source.as_value()) {
        let decor = t_val.decor().clone();
        let mut new_val = s_val.clone();
        if let Some(f) = new_val.as_float() {
            let rounded = (f * 100.0).round() / 100.0;
            new_val = toml_edit::Value::from(rounded);
        }
        if let Some(arr) = new_val.as_array_mut() {
            for item in arr.iter_mut() { item.decor_mut().set_prefix("\n    "); }
            arr.set_trailing("\n");
            arr.set_trailing_comma(true);
        }
        *t_val = new_val;
        *t_val.decor_mut() = decor;
    } else {
        *target = source.clone();
    }
}

fn remove_history_colors(root: &mut toml_edit::Table) {
    if let Some(history) = root.get_mut("history").and_then(|item| item.as_table_mut()) {
        history.remove("colors");
    }
}

fn has_history_colors(root: &toml_edit::Table) -> bool {
    root.get("history")
        .and_then(|item| item.as_table())
        .and_then(|history| history.get("colors"))
        .is_some()
}

#[cfg(not(windows))]
fn dirs_next() -> std::path::PathBuf {
    std::env::var("HOME")
        .map(std::path::PathBuf::from)
        .unwrap_or_else(|_| std::path::PathBuf::from("/tmp"))
}

/// Checks write access by attempting to create a temporary probe file.
/// Recurses into parent if the directory doesn't exist yet.
#[cfg(windows)]
fn is_dir_writable(dir: &std::path::Path) -> bool {
    if dir.exists() {
        let probe = dir.join(".ie-r-write-probe");
        match std::fs::File::create(&probe) {
            Ok(_) => { let _ = std::fs::remove_file(&probe); true }
            Err(_) => false,
        }
    } else {
        dir.parent().is_some_and(is_dir_writable)
    }
}

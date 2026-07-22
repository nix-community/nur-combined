use std::path::PathBuf;

use gpui_terminal::Osc52Policy;

pub fn config_dir() -> PathBuf {
    let home = std::env::var("HOME").unwrap_or_default();
    PathBuf::from(format!("{home}/.config/omnimux"))
}

/// Serializable OSC 52 policy for `settings.json`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, serde::Serialize, serde::Deserialize, Default)]
#[serde(rename_all = "snake_case")]
pub enum Osc52Setting {
    /// Block remote clipboard access (safest for untrusted hosts).
    #[default]
    Disabled,
    /// Allow remote → local clipboard writes only.
    OnlyCopy,
    /// Allow local clipboard → remote reads only.
    OnlyPaste,
    /// Allow both directions.
    CopyPaste,
}

impl From<Osc52Setting> for Osc52Policy {
    fn from(value: Osc52Setting) -> Self {
        match value {
            Osc52Setting::Disabled => Osc52Policy::Disabled,
            Osc52Setting::OnlyCopy => Osc52Policy::OnlyCopy,
            Osc52Setting::OnlyPaste => Osc52Policy::OnlyPaste,
            Osc52Setting::CopyPaste => Osc52Policy::CopyPaste,
        }
    }
}

impl From<Osc52Policy> for Osc52Setting {
    fn from(value: Osc52Policy) -> Self {
        match value {
            Osc52Policy::Disabled => Osc52Setting::Disabled,
            Osc52Policy::OnlyCopy => Osc52Setting::OnlyCopy,
            Osc52Policy::OnlyPaste => Osc52Setting::OnlyPaste,
            Osc52Policy::CopyPaste => Osc52Setting::CopyPaste,
        }
    }
}

impl Osc52Setting {
    pub fn label(self) -> &'static str {
        match self {
            Self::Disabled => "Disabled (recommended)",
            Self::OnlyCopy => "Remote → local only",
            Self::OnlyPaste => "Local → remote only",
            Self::CopyPaste => "Both directions",
        }
    }

    pub fn all() -> [Self; 4] {
        [
            Self::Disabled,
            Self::OnlyCopy,
            Self::OnlyPaste,
            Self::CopyPaste,
        ]
    }
}

#[derive(serde::Serialize, serde::Deserialize, Default)]
pub struct Settings {
    pub keep_tab_after_exit: Option<bool>,
    pub auto_reconnect: Option<bool>,
    pub remember_session: Option<bool>,
    pub sync_font_size_across_tabs: Option<bool>,
    pub remember_font_size: Option<bool>,
    /// Stored when remember_font_size is enabled (pixels).
    pub font_size: Option<f32>,
    /// OSC 52 remote clipboard policy. Default: disabled.
    pub osc52: Option<Osc52Setting>,
    /// Allow Cmd/Ctrl+click on http(s) / OSC 8 links (confirm before open). Default: off.
    pub open_links: Option<bool>,
}

pub fn load_settings() -> Settings {
    let path = config_dir().join("settings.json");
    std::fs::read_to_string(path)
        .ok()
        .and_then(|s| serde_json::from_str(&s).ok())
        .unwrap_or_default()
}

pub fn save_session(hosts: &[Option<String>]) {
    let dir = config_dir();
    let _ = std::fs::create_dir_all(&dir);
    let list: Vec<String> = hosts
        .iter()
        .map(|h| h.clone().unwrap_or_else(|| "localhost".to_string()))
        .collect();
    if let Ok(json) = serde_json::to_string_pretty(&list) {
        let _ = std::fs::write(dir.join("session.json"), json);
    }
}

pub fn load_session() -> Vec<Option<String>> {
    let path = config_dir().join("session.json");
    std::fs::read_to_string(path)
        .ok()
        .and_then(|s| serde_json::from_str::<Vec<String>>(&s).ok())
        .unwrap_or_default()
        .into_iter()
        .map(|h| if h == "localhost" { None } else { Some(h) })
        .collect()
}

pub fn save_settings_from_tabs(tabs: &crate::tabs::TerminalTabs) {
    let dir = config_dir();
    let _ = std::fs::create_dir_all(&dir);
    let settings = Settings {
        keep_tab_after_exit: Some(tabs.keep_tab_after_exit),
        auto_reconnect: Some(tabs.auto_reconnect),
        remember_session: Some(tabs.remember_session),
        sync_font_size_across_tabs: Some(tabs.sync_font_size_across_tabs),
        remember_font_size: Some(tabs.remember_font_size),
        font_size: if tabs.remember_font_size {
            Some(f32::from(tabs.font_size))
        } else {
            None
        },
        osc52: Some(tabs.osc52),
        open_links: Some(tabs.open_links),
    };
    if let Ok(json) = serde_json::to_string_pretty(&settings) {
        let _ = std::fs::write(dir.join("settings.json"), json);
    }
}

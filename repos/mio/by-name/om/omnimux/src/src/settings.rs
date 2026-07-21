use std::path::PathBuf;

pub fn config_dir() -> PathBuf {
    let home = std::env::var("HOME").unwrap_or_default();
    PathBuf::from(format!("{home}/.config/omnimux"))
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

use gtk::{gio, glib, prelude::*};
use serde::{Deserialize, Serialize};
use std::{collections::HashMap, fs, path::PathBuf, process::Command as Process};

#[derive(Clone, Copy, Debug, PartialEq)]
pub enum Command {
    EmptyTrash,
    DarkMode,
    VolumeUp,
    VolumeDown,
    VolumeMute,
    MicUp,
    MicDown,
    MicMute,
    Wifi,
    Bluetooth,
    DoNotDisturb,
}

impl Command {
    pub const ALL: [Self; 11] = [
        Self::EmptyTrash,
        Self::DarkMode,
        Self::VolumeUp,
        Self::VolumeDown,
        Self::VolumeMute,
        Self::MicUp,
        Self::MicDown,
        Self::MicMute,
        Self::Wifi,
        Self::Bluetooth,
        Self::DoNotDisturb,
    ];

    pub fn id(self) -> &'static str {
        match self {
            Self::EmptyTrash => "empty-trash",
            Self::DarkMode => "dark-mode",
            Self::VolumeUp => "volume-up",
            Self::VolumeDown => "volume-down",
            Self::VolumeMute => "volume-mute",
            Self::MicUp => "mic-up",
            Self::MicDown => "mic-down",
            Self::MicMute => "mic-mute",
            Self::Wifi => "wifi-toggle",
            Self::Bluetooth => "bluetooth-toggle",
            Self::DoNotDisturb => "do-not-disturb",
        }
    }

    pub fn title(self) -> &'static str {
        match self {
            Self::EmptyTrash => "Empty Trash",
            Self::DarkMode => "Toggle Dark Mode",
            Self::VolumeUp => "Volume Up",
            Self::VolumeDown => "Volume Down",
            Self::VolumeMute => "Toggle Speaker Mute",
            Self::MicUp => "Microphone Volume Up",
            Self::MicDown => "Microphone Volume Down",
            Self::MicMute => "Toggle Microphone Mute",
            Self::Wifi => "Toggle Wi-Fi",
            Self::Bluetooth => "Toggle Bluetooth",
            Self::DoNotDisturb => "Toggle Do Not Disturb",
        }
    }

    pub fn keywords(self) -> &'static str {
        match self {
            Self::EmptyTrash => "empty trash recycle bin rubbish delete clean",
            Self::DarkMode => "toggle dark mode light theme appearance system",
            Self::VolumeUp => "volume up speaker sound audio louder increase",
            Self::VolumeDown => "volume down speaker sound audio quieter decrease",
            Self::VolumeMute => "volume mute unmute speaker sound audio toggle",
            Self::MicUp => "mic microphone volume up input louder increase gain",
            Self::MicDown => "mic microphone volume down input quieter decrease gain",
            Self::MicMute => "mic microphone mute unmute input toggle",
            Self::Wifi => "wifi wi-fi wireless network internet toggle",
            Self::Bluetooth => "bluetooth blutooth bt wireless toggle",
            Self::DoNotDisturb => "do not disturb dnd notifications focus quiet toggle",
        }
    }

    pub fn icon(self) -> &'static str {
        match self {
            Self::EmptyTrash => "user-trash-symbolic",
            Self::DarkMode => "weather-clear-night-symbolic",
            Self::VolumeUp => "audio-volume-high-symbolic",
            Self::VolumeDown => "audio-volume-low-symbolic",
            Self::VolumeMute => "audio-volume-muted-symbolic",
            Self::MicUp | Self::MicDown | Self::MicMute => "microphone-sensitivity-muted-symbolic",
            Self::Wifi => "network-wireless-symbolic",
            Self::Bluetooth => "bluetooth-symbolic",
            Self::DoNotDisturb => "notifications-disabled-symbolic",
        }
    }
}

#[derive(Clone, Debug, PartialEq)]
pub struct Audio {
    pub volume: f64,
    pub muted: bool,
}

impl Audio {
    pub fn label(&self) -> String {
        format!(
            "{:.0}%{}",
            self.volume * 100.,
            if self.muted { " · Muted" } else { "" }
        )
    }
}

#[derive(Clone, Debug)]
pub struct Theme {
    pub scheme: String,
    pub dark: bool,
}

#[derive(Clone)]
pub struct Snapshot {
    pub speakers: Result<Audio, String>,
    pub mic: Result<Audio, String>,
    pub wifi: Result<bool, String>,
    pub bluetooth: Result<bool, String>,
    pub dnd: Result<bool, String>,
    pub theme: Result<Theme, String>,
}

impl Default for Snapshot {
    fn default() -> Self {
        Self {
            speakers: Err("Checking speakers…".into()),
            mic: Err("Checking microphone…".into()),
            wifi: Err("Checking Wi-Fi…".into()),
            bluetooth: Err("Checking Bluetooth…".into()),
            dnd: Err("Checking notifications…".into()),
            theme: theme(),
        }
    }
}

impl Snapshot {
    pub fn read() -> Self {
        Self {
            speakers: audio(false),
            mic: audio(true),
            wifi: wifi(),
            bluetooth: adapters().map(|a| a.iter().any(|(_, powered)| *powered)),
            dnd: dnd(),
            theme: theme(),
        }
    }

    pub fn description(&self, command: Command) -> String {
        let state = |value: &Result<bool, String>| match value {
            Ok(true) => "On".to_string(),
            Ok(false) => "Off".to_string(),
            Err(e) => e.clone(),
        };
        let audio_label = |value: &Result<Audio, String>| match value {
            Ok(a) => a.label(),
            Err(e) => e.clone(),
        };
        match command {
            Command::EmptyTrash => {
                "Permanently delete all trashed files · confirmation required".into()
            }
            Command::DarkMode => match &self.theme {
                Ok(t) => format!(
                    "KDE {} mode · {} · switch to {}",
                    if t.dark { "dark" } else { "light" },
                    t.scheme,
                    if t.dark { "light" } else { "dark" }
                ),
                Err(e) => e.clone(),
            },
            Command::VolumeUp | Command::VolumeDown => format!(
                "Speakers · {} · adjust by 5% · maximum 100%",
                audio_label(&self.speakers)
            ),
            Command::VolumeMute => format!(
                "Speakers · {} · Enter to mute or unmute",
                audio_label(&self.speakers)
            ),
            Command::MicUp | Command::MicDown => format!(
                "Microphone · {} · adjust by 5% · maximum 100%",
                audio_label(&self.mic)
            ),
            Command::MicMute => format!(
                "Microphone · {} · Enter to mute or unmute",
                audio_label(&self.mic)
            ),
            Command::Wifi => format!(
                "Wi-Fi: {} · turning off disconnects wireless networks",
                state(&self.wifi)
            ),
            Command::Bluetooth => format!(
                "Bluetooth: {} · turning off disconnects Bluetooth devices",
                state(&self.bluetooth)
            ),
            Command::DoNotDisturb => format!(
                "Do Not Disturb: {} · toggle KDE notification popups",
                state(&self.dnd)
            ),
        }
    }
}

fn output(program: &str, args: &[&str]) -> Result<String, String> {
    let result = Process::new(program)
        .args(args)
        .env("LC_ALL", "C")
        .output()
        .map_err(|e| format!("Could not run {program}: {e}"))?;
    if !result.status.success() {
        let error = String::from_utf8_lossy(&result.stderr);
        let error = if error.trim().is_empty() {
            String::from_utf8_lossy(&result.stdout)
        } else {
            error
        };
        return Err(format!(
            "{program}: {}",
            error.trim().chars().take(300).collect::<String>()
        ));
    }
    Ok(String::from_utf8_lossy(&result.stdout).trim().to_string())
}

fn parse_audio(value: &str) -> Result<Audio, String> {
    let volume = value
        .strip_prefix("Volume:")
        .and_then(|s| s.split_whitespace().next())
        .and_then(|s| s.parse::<f64>().ok())
        .filter(|v| v.is_finite() && *v >= 0.)
        .ok_or("Audio device is unavailable")?;
    Ok(Audio {
        volume,
        muted: value.contains("[MUTED]"),
    })
}

fn audio(mic: bool) -> Result<Audio, String> {
    parse_audio(&output("wpctl", &["get-volume", audio_id(mic)])?)
}

fn audio_id(mic: bool) -> &'static str {
    if mic {
        "@DEFAULT_AUDIO_SOURCE@"
    } else {
        "@DEFAULT_AUDIO_SINK@"
    }
}

fn wifi() -> Result<bool, String> {
    match output("nmcli", &["-t", "-f", "WIFI", "general"])?.as_str() {
        "enabled" => Ok(true),
        "disabled" => Ok(false),
        _ => Err("Wi-Fi status unavailable".into()),
    }
}

fn bus(kind: gio::BusType) -> Result<gio::DBusConnection, String> {
    gio::bus_get_sync(kind, None::<&gio::Cancellable>).map_err(|e| e.to_string())
}

fn call(
    bus: &gio::DBusConnection,
    service: &str,
    path: &str,
    interface: &str,
    method: &str,
    args: Option<&glib::Variant>,
) -> Result<glib::Variant, String> {
    bus.call_sync(
        Some(service),
        path,
        interface,
        method,
        args,
        None,
        gio::DBusCallFlags::NONE,
        5000,
        None::<&gio::Cancellable>,
    )
    .map_err(|e| e.to_string())
}

fn adapters() -> Result<Vec<(String, bool)>, String> {
    type Interfaces = HashMap<String, HashMap<String, glib::Variant>>;
    let reply = call(
        &bus(gio::BusType::System)?,
        "org.bluez",
        "/",
        "org.freedesktop.DBus.ObjectManager",
        "GetManagedObjects",
        None,
    )?;
    let (objects,) = reply
        .get::<(HashMap<glib::variant::ObjectPath, Interfaces>,)>()
        .ok_or("Invalid Bluetooth status response")?;
    let mut adapters: Vec<_> = objects
        .into_iter()
        .filter_map(|(path, interfaces)| {
            let props = interfaces.get("org.bluez.Adapter1")?;
            Some((path.to_string(), props.get("Powered")?.get::<bool>()?))
        })
        .collect();
    adapters.sort_by(|a, b| a.0.cmp(&b.0));
    if adapters.is_empty() {
        return Err("No Bluetooth adapter found".into());
    }
    Ok(adapters)
}

fn dnd() -> Result<bool, String> {
    let reply = call(
        &bus(gio::BusType::Session)?,
        "org.freedesktop.Notifications",
        "/org/freedesktop/Notifications",
        "org.freedesktop.DBus.Properties",
        "Get",
        Some(&("org.freedesktop.Notifications", "Inhibited").to_variant()),
    )?;
    reply
        .child_value(0)
        .as_variant()
        .and_then(|v| v.get::<bool>())
        .ok_or("Notification status unavailable".into())
}

fn config_home() -> PathBuf {
    std::env::var_os("XDG_CONFIG_HOME")
        .map(PathBuf::from)
        .unwrap_or_else(|| crate::core::home().join(".config"))
}

fn ini<'a>(text: &'a str, section: &str, key: &str) -> Option<&'a str> {
    let mut current = "";
    for line in text.lines().map(str::trim) {
        if line.starts_with('[') {
            current = line;
        } else if current == format!("[{section}]")
            && let Some((name, value)) = line.split_once('=')
            && name.trim() == key
        {
            return Some(value.trim());
        }
    }
    None
}

fn dark_colors(text: &str) -> Option<bool> {
    let rgb: Vec<f64> = ini(text, "Colors:Window", "BackgroundNormal")?
        .split(',')
        .map(str::parse)
        .collect::<Result<_, _>>()
        .ok()?;
    if rgb.len() < 3
        || rgb
            .iter()
            .any(|c| !c.is_finite() || !(0. ..=255.).contains(c))
    {
        return None;
    }
    Some(rgb[0] * 0.299 + rgb[1] * 0.587 + rgb[2] * 0.114 < 128.)
}

fn theme() -> Result<Theme, String> {
    let text = fs::read_to_string(config_home().join("kdeglobals")).map_err(|e| e.to_string())?;
    let scheme = ini(&text, "General", "ColorScheme")
        .ok_or("KDE color scheme unavailable")?
        .to_string();
    let dark = dark_colors(&text).unwrap_or_else(|| scheme.to_lowercase().contains("dark"));
    Ok(Theme { scheme, dark })
}

#[derive(Default, Serialize, Deserialize)]
#[serde(default)]
struct ThemePreferences {
    light: Option<String>,
    dark: Option<String>,
}

fn schemes() -> Vec<(String, bool)> {
    let mut roots = vec![
        std::env::var_os("XDG_DATA_HOME")
            .map(PathBuf::from)
            .unwrap_or_else(|| crate::core::home().join(".local/share")),
    ];
    roots.extend(std::env::split_paths(
        &std::env::var_os("XDG_DATA_DIRS").unwrap_or_else(|| "/usr/local/share:/usr/share".into()),
    ));
    let mut schemes = Vec::new();
    for root in roots {
        let Ok(files) = fs::read_dir(root.join("color-schemes")) else {
            continue;
        };
        for file in files.flatten() {
            let path = file.path();
            if path.extension().and_then(|s| s.to_str()) != Some("colors") {
                continue;
            }
            let Some(name) = path.file_stem().and_then(|s| s.to_str()) else {
                continue;
            };
            if schemes.iter().any(|(n, _)| n == name) {
                continue;
            }
            if let Some(dark) = fs::read_to_string(&path).ok().and_then(|s| dark_colors(&s)) {
                schemes.push((name.to_string(), dark));
            }
        }
    }
    schemes
}

fn target_scheme(
    current: &Theme,
    prefs: &ThemePreferences,
    available: &[(String, bool)],
) -> Result<String, String> {
    let remembered = if current.dark {
        &prefs.light
    } else {
        &prefs.dark
    };
    let family = if current.dark {
        current
            .scheme
            .strip_suffix("Dark")
            .unwrap_or(&current.scheme)
            .to_string()
    } else {
        format!(
            "{}Dark",
            current
                .scheme
                .strip_suffix("Light")
                .unwrap_or(&current.scheme)
        )
    };
    let fallback = if current.dark {
        "BreezeLight"
    } else {
        "BreezeDark"
    };
    for name in remembered
        .iter()
        .map(String::as_str)
        .chain([family.as_str(), fallback])
    {
        if available
            .iter()
            .any(|(n, dark)| n == name && *dark != current.dark)
        {
            return Ok(name.to_string());
        }
    }
    available
        .iter()
        .find(|(_, dark)| *dark != current.dark)
        .map(|(name, _)| name.clone())
        .ok_or("No matching light/dark color scheme is installed".into())
}

fn toggle_theme() -> Result<String, String> {
    use std::os::unix::fs::PermissionsExt;
    let current = theme()?;
    let path = crate::core::data_dir().join("desktop-themes.json");
    let mut prefs: ThemePreferences = match fs::read(&path) {
        Ok(bytes) => serde_json::from_slice(&bytes)
            .map_err(|e| format!("Could not read saved color schemes: {e}"))?,
        Err(e) if e.kind() == std::io::ErrorKind::NotFound => ThemePreferences::default(),
        Err(e) => return Err(e.to_string()),
    };
    let target = target_scheme(&current, &prefs, &schemes())?;
    output("plasma-apply-colorscheme", &[&target])?;
    if current.dark {
        prefs.dark = Some(current.scheme);
        prefs.light = Some(target.clone());
    } else {
        prefs.light = Some(current.scheme);
        prefs.dark = Some(target.clone());
    }
    let dir = crate::core::data_dir();
    fs::create_dir_all(&dir).map_err(|e| e.to_string())?;
    fs::set_permissions(&dir, fs::Permissions::from_mode(0o700)).map_err(|e| e.to_string())?;
    let tmp = dir.join("desktop-themes.tmp");
    fs::write(&tmp, serde_json::to_vec(&prefs).map_err(|e| e.to_string())?)
        .map_err(|e| e.to_string())?;
    fs::set_permissions(&tmp, fs::Permissions::from_mode(0o600)).map_err(|e| e.to_string())?;
    fs::rename(tmp, path).map_err(|e| e.to_string())?;
    Ok(format!(
        "{} mode · {target}",
        if current.dark { "Light" } else { "Dark" }
    ))
}

pub fn execute(command: Command) -> Result<String, String> {
    match command {
        Command::EmptyTrash => {
            output("ktrash6", &["--empty"])?;
            Ok("Trash emptied".into())
        }
        Command::DarkMode => toggle_theme(),
        Command::VolumeUp | Command::VolumeDown | Command::MicUp | Command::MicDown => {
            let mic = matches!(command, Command::MicUp | Command::MicDown);
            let increase = matches!(command, Command::VolumeUp | Command::MicUp);
            output(
                "wpctl",
                &[
                    "set-volume",
                    "--limit",
                    "1.0",
                    audio_id(mic),
                    if increase { "5%+" } else { "5%-" },
                ],
            )?;
            Ok(format!(
                "{} · {}",
                if mic { "Microphone" } else { "Speakers" },
                audio(mic)?.label()
            ))
        }
        Command::VolumeMute | Command::MicMute => {
            let mic = command == Command::MicMute;
            output("wpctl", &["set-mute", audio_id(mic), "toggle"])?;
            let state = audio(mic)?;
            Ok(format!(
                "{} {}",
                if mic { "Microphone" } else { "Speakers" },
                if state.muted { "muted" } else { "unmuted" }
            ))
        }
        Command::Wifi => {
            let enabled = !wifi()?;
            output(
                "nmcli",
                &[
                    "--wait",
                    "5",
                    "radio",
                    "wifi",
                    if enabled { "on" } else { "off" },
                ],
            )?;
            if wifi()? != enabled {
                return Err(
                    "Wi-Fi could not be changed; check the hardware switch or airplane mode".into(),
                );
            }
            Ok(format!("Wi-Fi {}", if enabled { "on" } else { "off" }))
        }
        Command::Bluetooth => {
            let adapters = adapters()?;
            let enabled = !adapters.iter().any(|(_, powered)| *powered);
            let bus = bus(gio::BusType::System)?;
            for (path, powered) in adapters {
                if powered != enabled {
                    call(
                        &bus,
                        "org.bluez",
                        &path,
                        "org.freedesktop.DBus.Properties",
                        "Set",
                        Some(&("org.bluez.Adapter1", "Powered", enabled.to_variant()).to_variant()),
                    )?;
                }
            }
            if self::adapters()?
                .iter()
                .any(|(_, powered)| *powered != enabled)
            {
                return Err("Bluetooth could not be changed on every adapter; check airplane mode or the hardware switch".into());
            }
            Ok(format!("Bluetooth {}", if enabled { "on" } else { "off" }))
        }
        Command::DoNotDisturb => {
            let previous = dnd()?;
            let bus = bus(gio::BusType::Session)?;
            // Use the same action as Plasma's notification applet, including manually enabled DND.
            call(
                &bus,
                "org.kde.kglobalaccel",
                "/component/plasmashell",
                "org.kde.kglobalaccel.Component",
                "invokeShortcut",
                Some(&("toggle do not disturb",).to_variant()),
            )?;
            // The action is delivered asynchronously to the applet.
            std::thread::sleep(std::time::Duration::from_millis(200));
            let enabled = dnd()?;
            if enabled == previous {
                return Err("KDE did not change Do Not Disturb. Check whether another application or screen sharing is suppressing notifications.".into());
            }
            Ok(format!(
                "Do Not Disturb {}",
                if enabled { "on" } else { "off" }
            ))
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parses_audio_status_without_accepting_invalid_values() {
        assert_eq!(
            parse_audio("Volume: 0.65 [MUTED]").unwrap(),
            Audio {
                volume: 0.65,
                muted: true
            }
        );
        assert_eq!(parse_audio("Volume: 1.20").unwrap().label(), "120%");
        for bad in ["", "Volume: NaN", "Volume: -0.5", "not found"] {
            assert!(parse_audio(bad).is_err());
        }
    }

    #[test]
    fn detects_actual_palette_and_restores_custom_scheme_pairs() {
        assert_eq!(
            dark_colors("[Colors:Window]\nBackgroundNormal=38,36,35"),
            Some(true)
        );
        assert_eq!(
            dark_colors("[Colors:Window]\nBackgroundNormal=214,210,208"),
            Some(false)
        );
        assert_eq!(
            dark_colors("[Colors:Window]\nBackgroundNormal=NaN,0,0"),
            None
        );
        let available = vec![
            ("OxygenDark".into(), true),
            ("Oxygen".into(), false),
            ("MyDay".into(), false),
        ];
        let current = Theme {
            scheme: "OxygenDark".into(),
            dark: true,
        };
        assert_eq!(
            target_scheme(&current, &ThemePreferences::default(), &available).unwrap(),
            "Oxygen"
        );
        let prefs = ThemePreferences {
            light: Some("MyDay".into()),
            dark: None,
        };
        assert_eq!(
            target_scheme(&current, &prefs, &available).unwrap(),
            "MyDay"
        );
        let current = Theme {
            scheme: "Oxygen".into(),
            dark: false,
        };
        assert_eq!(
            target_scheme(&current, &prefs, &available).unwrap(),
            "OxygenDark"
        );
        assert!(target_scheme(&current, &prefs, &[]).is_err());
    }
}

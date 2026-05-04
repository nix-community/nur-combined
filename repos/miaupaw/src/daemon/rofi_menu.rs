/// External launcher menu for wlroots-based compositors.
///
/// On KDE/GNOME the tray host renders dbusmenu popups natively.
/// On wlroots (Hyprland, Sway, niri, river…) GTK3 can't spawn a popup
/// from a layer-shell surface, so we launch an external menu instead.
///
/// Supports any dmenu-compatible tool via `menu_command` in config.
/// If unset, auto-detects: rofi → wofi → fuzzel.
use super::UserEvent;
use super::event_sender::EventSender;
use crate::core::terminal::log_error;

/// Desktop environments known to render dbusmenu popups natively.
/// Everything else gets the external menu fallback.
const NATIVE_POPUP_DESKTOPS: &[&str] = &[
    "KDE", "GNOME", "X-Cinnamon", "LXQt", "Deepin", "MATE", "Pantheon",
];

/// Returns `true` if the current DE can render a dbusmenu popup without help.
pub fn has_native_popup() -> bool {
    let desktop = std::env::var("XDG_CURRENT_DESKTOP").unwrap_or_default();
    desktop.split(':').any(|d| NATIVE_POPUP_DESKTOPS.contains(&d))
}

#[derive(Debug, Clone, PartialEq, Eq)]
enum Action {
    History(String),
    Template(String),
    ToggleHUD,
    EditConfig,
    About,
    Homepage,
    Quit,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum MenuInputMode {
    Plain,
    RofiIcons,
}

#[derive(Debug, Clone, PartialEq, Eq)]
struct LauncherSpec {
    cmd: String,
    args: Vec<String>,
    input_mode: MenuInputMode,
    custom: bool,
}

#[derive(Debug, Clone, PartialEq, Eq)]
struct MenuEntry {
    label: String,
    rofi_line: Option<String>,
    action: Action,
}

impl MenuEntry {
    fn line_for(&self, mode: MenuInputMode) -> &str {
        match mode {
            MenuInputMode::Plain => &self.label,
            MenuInputMode::RofiIcons => self.rofi_line.as_deref().unwrap_or(&self.label),
        }
    }
}

/// Returns launchers to try: custom command from config, or the default auto-detect chain.
fn resolve_launchers(menu_command: Option<&[String]>) -> Result<Vec<LauncherSpec>, String> {
    if let Some(command) = menu_command {
        if command.is_empty() {
            return Err("Invalid config: system.menu_command must contain an executable.".to_string());
        }

        let executable = command[0].trim();
        if executable.is_empty() {
            return Err("Invalid config: system.menu_command[0] must be a non-empty executable.".to_string());
        }

        return Ok(vec![LauncherSpec {
            cmd: executable.to_string(),
            args: command[1..].to_vec(),
            input_mode: MenuInputMode::Plain,
            custom: true,
        }]);
    }

    Ok(vec![
        LauncherSpec {
            cmd: "rofi".to_string(),
            args: vec![
                "-dmenu".to_string(),
                "-p".to_string(),
                "IE-R".to_string(),
                "-no-custom".to_string(),
                "-show-icons".to_string(),
            ],
            input_mode: MenuInputMode::RofiIcons,
            custom: false,
        },
        LauncherSpec {
            cmd: "wofi".to_string(),
            args: vec!["--dmenu".to_string(), "--prompt".to_string(), "IE-R".to_string()],
            input_mode: MenuInputMode::Plain,
            custom: false,
        },
        LauncherSpec {
            cmd: "fuzzel".to_string(),
            args: vec!["--dmenu".to_string(), "--prompt".to_string(), "IE-R ".to_string()],
            input_mode: MenuInputMode::Plain,
            custom: false,
        },
    ])
}

fn build_menu_entries(snap: &crate::daemon::dbus_menu::MenuSnapshot) -> Vec<MenuEntry> {
    use crate::core::config::TEMPLATE_LABELS;
    let mut entries = Vec::new();

    let color_icon_dir = std::path::PathBuf::from("/tmp/ie-r-colors");
    let _ = std::fs::create_dir_all(&color_icon_dir);

    for hex in &snap.history {
        let filename = format!("{}.png", hex.trim_start_matches('#'));
        let icon_path = color_icon_dir.join(&filename);
        if !icon_path.exists() {
            let png = crate::daemon::dbus_menu::generate_color_png(hex);
            let _ = std::fs::write(&icon_path, &png);
        }
        entries.push(MenuEntry {
            label: hex.clone(),
            rofi_line: Some(format!("{}\0icon\x1f{}", hex, icon_path.display())),
            action: Action::History(hex.clone()),
        });
    }

    for &(key, label) in TEMPLATE_LABELS {
        let dot = if snap.selected_template == key { "●" } else { "○" };
        entries.push(MenuEntry {
            label: format!("{} {}", dot, label),
            rofi_line: None,
            action: Action::Template(key.to_string()),
        });
    }

    let hud_dot = if snap.show_hud { "✓" } else { "○" };
    entries.push(MenuEntry {
        label: format!("{} Show HUD", hud_dot),
        rofi_line: None,
        action: Action::ToggleHUD,
    });
    entries.push(MenuEntry { label: "⚙ Edit Config".to_string(), rofi_line: None, action: Action::EditConfig });
    entries.push(MenuEntry { label: "🌐 Homepage".to_string(),   rofi_line: None, action: Action::Homepage });
    entries.push(MenuEntry { label: "ℹ About".to_string(),       rofi_line: None, action: Action::About });
    entries.push(MenuEntry { label: "✕ Quit".to_string(),        rofi_line: None, action: Action::Quit });

    entries
}

fn build_menu_input(entries: &[MenuEntry], mode: MenuInputMode) -> String {
    entries.iter().map(|entry| entry.line_for(mode)).collect::<Vec<_>>().join("\n")
}

fn resolve_action(selection: &str, entries: &[MenuEntry]) -> Option<Action> {
    let normalized = selection.split('\0').next().unwrap_or(selection).trim();
    if normalized.is_empty() {
        return None;
    }

    // Index-based fallback (some launchers may return a number)
    if let Ok(idx) = normalized.parse::<usize>() {
        return entries.get(idx).map(|entry| entry.action.clone());
    }

    entries.iter().find(|entry| entry.label == normalized).map(|entry| entry.action.clone())
}

fn dispatch_action(proxy: &EventSender, action: Action) {
    match action {
        Action::History(hex)  => { proxy.send(UserEvent::CopyFromHistory(hex)); }
        Action::Template(key) => { proxy.send(UserEvent::SelectTemplate(key)); }
        Action::ToggleHUD     => { proxy.send(UserEvent::ToggleHUD); }
        Action::EditConfig    => { proxy.send(UserEvent::EditConfig); }
        Action::About         => { proxy.send(UserEvent::ShowAbout); }
        Action::Homepage      => { proxy.send(UserEvent::OpenHomepage); }
        Action::Quit          => { proxy.send(UserEvent::Quit); }
    }
}

/// Show the context menu via an external launcher (custom command or rofi → wofi → fuzzel).
pub async fn show_menu(proxy: EventSender) {
    use crate::daemon::dbus_menu::MenuSnapshot;
    use tokio::io::AsyncWriteExt;

    let snap = MenuSnapshot::take();
    let entries = build_menu_entries(&snap);
    let menu_command = crate::core::config::Config::read_menu_command_from_disk().unwrap_or(snap.menu_command);
    let launchers = match resolve_launchers(menu_command.as_deref()) {
        Ok(launchers) => launchers,
        Err(err) => {
            log_error(&err);
            return;
        }
    };

    for launcher in launchers {
        let input = build_menu_input(&entries, launcher.input_mode);

        let mut child = match tokio::process::Command::new(&launcher.cmd)
            .args(&launcher.args)
            .stdin(std::process::Stdio::piped())
            .stdout(std::process::Stdio::piped())
            .spawn()
        {
            Ok(child) => child,
            Err(err) if launcher.custom => {
                log_error(&format!("Custom menu launcher failed to spawn ({}): {}", launcher.cmd, err));
                return;
            }
            Err(_) => continue,
        };

        if let Some(mut stdin) = child.stdin.take() {
            let _ = stdin.write_all(input.as_bytes()).await;
        }

        let out = match child.wait_with_output().await {
            Ok(output) => output,
            Err(err) => { log_error(&format!("menu launcher failed: {}", err)); return; }
        };

        let selection = String::from_utf8_lossy(&out.stdout);
        if let Some(action) = resolve_action(&selection, &entries) {
            dispatch_action(&proxy, action);
        }
        return;
    }

    log_error("No menu launcher found. Install rofi, wofi, or fuzzel, or set system.menu_command.");
}

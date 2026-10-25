use crate::*;
use serde::{Deserialize, Serialize};

pub const CATEGORIES: &[(&str, &str)] = &[
    ("passwords", "Password managers"),
    ("containers", "Docker and Podman"),
    ("fonts", "Fonts"),
    ("calendar", "Calendars and meeting availability"),
    ("contacts", "Contacts"),
    ("git", "Git and GitHub"),
    ("projects", "Editor projects"),
    ("ssh", "SSH hosts"),
    ("environment", "Environment and dotenv"),
    ("ai", "Local AI"),
    ("extensions", "Extensions and scripts"),
    ("clipboard", "Clipboard"),
    ("windows", "Windows and desktops"),
    ("system", "System, packages, services, and devices"),
    ("text", "Text and OCR tools"),
    ("saved", "Notes, snippets, and quicklinks"),
    ("timers", "Timers and alarms"),
    ("screen", "Screen and color tools"),
    ("emoji", "Emoji"),
    ("files", "File commands"),
    ("calculator", "Calculator and currency"),
];
#[derive(Clone, Debug, Serialize, Deserialize, PartialEq, Eq)]
pub struct Alias {
    pub name: String,
    pub target: String,
}
#[derive(Clone, Copy, Debug, Default, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "snake_case")]
pub enum Web {
    #[default]
    Google,
    DuckDuckGo,
    Bing,
    Brave,
    Disabled,
}
impl Web {
    pub fn label(self) -> &'static str {
        match self {
            Self::Google => "Google",
            Self::DuckDuckGo => "DuckDuckGo",
            Self::Bing => "Bing",
            Self::Brave => "Brave",
            Self::Disabled => "Web search disabled",
        }
    }
    pub fn url(self, query: &str) -> Option<String> {
        let base = match self {
            Self::Google => "https://www.google.com/search?q=",
            Self::DuckDuckGo => "https://duckduckgo.com/?q=",
            Self::Bing => "https://www.bing.com/search?q=",
            Self::Brave => "https://search.brave.com/search?q=",
            Self::Disabled => return None,
        };
        Some(format!("{base}{}", core::encode(query)))
    }
}
#[derive(Clone, Debug, Serialize, Deserialize)]
#[serde(default)]
pub struct Preferences {
    pub aliases: Vec<Alias>,
    pub web: Web,
    pub disabled: Vec<String>,
    pub ollama_model: String,
}
impl Default for Preferences {
    fn default() -> Self {
        Self {
            aliases: vec![Alias {
                name: "g".into(),
                target: "web {query}".into(),
            }],
            web: Web::Google,
            disabled: vec![],
            ollama_model: String::new(),
        }
    }
}
impl Preferences {
    pub fn enabled(&self, category: &str) -> bool {
        !self.disabled.iter().any(|c| c == category)
    }
    pub fn resolve(&self, input: &str) -> Result<String, String> {
        let mut text = input.trim().to_string();
        let mut seen = std::collections::HashSet::new();
        for depth in 0..=8 {
            let (head, tail) = text.split_once(char::is_whitespace).unwrap_or((&text, ""));
            let Some(alias) = self
                .aliases
                .iter()
                .find(|a| a.name.eq_ignore_ascii_case(head))
            else {
                return Ok(text);
            };
            if depth == 8 {
                return Err("Use at most eight chained aliases".into());
            }
            if !seen.insert(alias.name.to_ascii_lowercase()) {
                return Err("Aliases cannot form a cycle".into());
            }
            text = if alias.target.contains("{query}") {
                alias.target.replace("{query}", tail.trim())
            } else if tail.trim().is_empty() {
                alias.target.clone()
            } else {
                format!("{} {}", alias.target, tail.trim())
            };
            if text.len() > 8192 {
                return Err("Expanded alias exceeds 8 KiB".into());
            }
        }
        Err("Use at most eight chained aliases".into())
    }
    pub fn validate(&self) -> Result<(), String> {
        if self.aliases.len() > 64 {
            return Err("Use at most 64 aliases".into());
        }
        let mut seen = std::collections::HashSet::new();
        for alias in &self.aliases {
            if alias.name.is_empty()
                || alias.name.len() > 32
                || !alias
                    .name
                    .bytes()
                    .all(|c| c.is_ascii_alphanumeric() || b"_-".contains(&c))
                || !seen.insert(alias.name.to_ascii_lowercase())
            {
                return Err("Use unique alias names of 1–32 letters, digits, _ or -".into());
            }
            if alias.target.trim().is_empty()
                || alias.target.len() > 2048
                || alias.target.chars().any(char::is_control)
            {
                return Err("Alias targets must be nonempty search commands, at most 2 KiB".into());
            }
            self.resolve(&alias.name)?;
        }
        if self.ollama_model.len() > 160
            || self
                .ollama_model
                .chars()
                .any(|c| c.is_whitespace() || c.is_control())
        {
            return Err("Use an Ollama model name without spaces, at most 160 characters".into());
        }
        Ok(())
    }
}
pub fn category(query: &str) -> Option<&'static str> {
    let text = query.trim().to_ascii_lowercase();
    let head = text.split_whitespace().next().unwrap_or("");
    Some(match head {
        "workflow" | "workflows" => "extensions",
        "vault" => "clipboard",
        "pass" | "password" | "rbw" | "keepass" | "keepassxc" => "passwords",
        "ping" | "dig" | "wallpaper" | "accent" => "system",
        "scan" if text == "scan wifi" || text == "scan wi-fi" => "system",
        "my" if text == "my ports" || text == "my routes" => "system",
        "encrypt" | "decrypt" | "checksum" | "shred" => "files",
        "docker" | "podman" | "logs" => "containers",
        "font" | "fonts" => "fonts",
        "calendar" | "events" | "event" | "meet" => "calendar",
        "add" if text.starts_with("add event ") => "calendar",
        "contact" | "contacts" => "contacts",
        "git" | "gh" | "repo" | "repos" => "git",
        "code" | "projects" | "project" | "jetbrains" | "idea" | "pycharm" | "webstorm"
        | "clion" | "goland" | "rustrover" | "phpstorm" | "rider" | "rubymine" | "datagrip" => {
            "projects"
        }
        "ssh" => "ssh",
        "env" | "environment" | "dotenv" => "environment",
        "get" | "post" | "put" | "patch" | "delete" | "head" | "http" => "system",
        "ai" => "ai",
        "store" | "plugin" | "ext" => "extensions",
        "clip" => "clipboard",
        "layout" => "windows",
        "todo" | "todos" => "saved",
        "window" | "windows" | "desktop" | "desktops" | "switch" | "switcher" | "close"
        | "quit"
            if text != "quit spotlight" =>
        {
            "windows"
        }
        "kill" if text.starts_with("kill window") => "windows",
        "ip" | "battery" | "disk" | "ram" | "uptime" | "speakers" | "outputs" | "audio"
        | "music" | "player" | "play" | "playpause" | "play-pause" | "play/pause" | "pause"
        | "next" | "previous" | "stop" | "tabs" | "apt" | "pacman" | "flatpak" | "packages"
        | "service" | "services" | "systemctl" | "bluetooth" | "wifi" | "volume" | "kill" => {
            "system"
        }
        "my" if text == "my ip" => "system",
        "qr" | "ocr" | "lorem" | "case" | "json" | "uuid" | "hash" | "base64" | "define"
        | "dictionary" | "dict" | "translate" | "tldr" => "text",
        "generate" if text == "generate qr" || text.starts_with("generate qr ") => "text",
        "note" | "notes" | "snippet" | "snippets" | "quicklinks" | "quicklink" => "saved",
        "pomodoro" | "timer" | "alarm" | "remind" | "reminder" => "timers",
        "set" if text.contains("timer") || text.contains("alarm") => "timers",
        "palette" | "color" | "colors" | "pick" | "measure" | "screenshot" => "screen",
        "emoji" | "emojis" | "kaomoji" => "emoji",
        "history" | "bookmark" | "bookmarks" | "compress" | "resize" | "pdf" | "image"
        | "recent" | "rg" | "content" => "files",
        _ => return None,
    })
}
pub fn item_category(item: &Item) -> Option<&'static str> {
    if item.id.starts_with("link:")
        || item.id.starts_with("quick-note:")
        || item.id.starts_with("snippet:")
    {
        return Some("saved");
    }
    match &item.action {
        Action::Automation(_) => Some("extensions"),
        Action::Vault | Action::VaultPin(_) => Some("clipboard"),
        Action::Workflow(op) => Some(op.category()),
        Action::Query(q) => category(q),
        Action::Extension(_) | Action::RunExtension { .. } | Action::Script(_) => {
            Some("extensions")
        }
        Action::Page(p) => match p {
            Page::Fonts => Some("fonts"),
            Page::Files | Page::Recent => Some("files"),
            Page::Clipboard => Some("clipboard"),
            Page::Snippets | Page::Links | Page::Notes => Some("saved"),
            Page::Windows => Some("windows"),
            Page::Emoji => Some("emoji"),
            Page::Colors => Some("screen"),
            Page::Scripts => Some("extensions"),
            _ => None,
        },
        Action::FontPreview(_) | Action::ResetFont => Some("fonts"),
        Action::Copy(_) if item.badge == "Emoji" => Some("emoji"),
        Action::Snippet(_)
        | Action::QuickNote(_)
        | Action::CaptureNote(_)
        | Action::DesktopSnippets => Some("saved"),
        Action::ClearClipboard | Action::ClipboardImage(_) | Action::ClipboardTexture(_) => {
            Some("clipboard")
        }
        Action::Window(_) => Some("windows"),
        Action::Desktop(_) | Action::System(_) | Action::Caffeinate => Some("system"),
        Action::TimerSetup
        | Action::AlarmSetup
        | Action::Schedule(_)
        | Action::CancelReminder(_) => Some("timers"),
        Action::PickColor | Action::MeasureScreen => Some("screen"),
        Action::EmojiTones => Some("emoji"),
        Action::CalendarEvent(_) => Some("calendar"),
        _ => None,
    }
}
impl Ui {
    pub(super) fn effective_query(&self) -> String {
        let text = self.search.text();
        if *self.page.borrow() == Page::Root {
            self.store
                .borrow()
                .commands
                .resolve(&text)
                .unwrap_or_else(|_| text.to_string())
        } else {
            text.to_string()
        }
    }
    pub(super) fn customization_panel(self: &Rc<Self>) -> gtk::Box {
        let panel = gtk::Box::new(gtk::Orientation::Vertical, 10);
        let prefs = self.store.borrow().commands.clone();
        let title = gtk::Label::new(Some("Search commands"));
        title.set_xalign(0.);
        title.add_css_class("editor-title");
        panel.append(&title);
        let help = gtk::Label::new(Some(
            "Aliases use one name = target per line, for example ff = firefox or g = web {query}. Targets are Spotlight searches. Choose a fallback search engine and the categories to enable.",
        ));
        help.set_wrap(true);
        help.set_xalign(0.);
        panel.append(&help);
        let aliases = gtk::TextView::new();
        aliases.set_widget_name("command-aliases");
        aliases.set_monospace(true);
        aliases.buffer().set_text(
            &prefs
                .aliases
                .iter()
                .map(|a| format!("{} = {}", a.name, a.target))
                .collect::<Vec<_>>()
                .join("\n"),
        );
        panel.append(
            &gtk::ScrolledWindow::builder()
                .child(&aliases)
                .min_content_height(95)
                .build(),
        );
        let web = gtk::DropDown::from_strings(&[
            "Google",
            "DuckDuckGo",
            "Bing",
            "Brave",
            "Disable web fallback",
        ]);
        web.set_widget_name("fallback-engine");
        web.set_selected(prefs.web as u32);
        panel.append(&web);
        let model = gtk::Entry::builder()
            .placeholder_text("Local Ollama model (blank: first installed local model)")
            .text(&prefs.ollama_model)
            .build();
        model.set_widget_name("ollama-model");
        panel.append(&model);
        let mut checks = Vec::new();
        for &(id, label) in CATEGORIES {
            let check = gtk::CheckButton::with_label(label);
            check.set_widget_name(&format!("category-{id}"));
            check.set_active(prefs.enabled(id));
            panel.append(&check);
            checks.push((id, check));
        }
        let status = gtk::Label::new(None);
        status.set_xalign(0.);
        status.set_wrap(true);
        panel.append(&status);
        let apply = gtk::Button::with_label("Apply search settings");
        apply.set_widget_name("apply-command-settings");
        apply.add_css_class("accent");
        panel.append(&apply);
        let weak = Rc::downgrade(self);
        apply.connect_clicked(move |_| {
            let Some(ui) = weak.upgrade() else {
                return;
            };
            if !ui.can_save {
                status.set_text("Saved data is unreadable; search settings cannot be saved");
                return;
            }
            let buffer = aliases.buffer();
            let text = buffer.text(&buffer.start_iter(), &buffer.end_iter(), false);
            let mut entries = Vec::new();
            for (line_number, line) in text.lines().enumerate() {
                if line.trim().is_empty() {
                    continue;
                }
                let Some((name, target)) = line.split_once('=') else {
                    status.set_text(&format!("Line {} needs name = target", line_number + 1));
                    return;
                };
                entries.push(Alias {
                    name: name.trim().into(),
                    target: target.trim().into(),
                });
            }
            let prefs = Preferences {
                aliases: entries,
                web: match web.selected() {
                    0 => Web::Google,
                    1 => Web::DuckDuckGo,
                    2 => Web::Bing,
                    3 => Web::Brave,
                    _ => Web::Disabled,
                },
                disabled: checks
                    .iter()
                    .filter(|(_, c)| !c.is_active())
                    .map(|(id, _)| id.to_string())
                    .collect(),
                ollama_model: model.text().trim().into(),
            };
            if let Err(error) = prefs.validate() {
                status.set_text(&error);
                return;
            }
            let old = ui.store.borrow().commands.clone();
            ui.store.borrow_mut().commands = prefs;
            let saved = ui.store.borrow().save();
            if let Err(error) = saved {
                ui.store.borrow_mut().commands = old;
                status.set_text(&error);
                return;
            }
            ui.cancel_content();
            ui.extension_session.borrow_mut().take();
            ui.booster_cache.borrow_mut().clear();
            if ui.store.borrow().commands.enabled("extensions") {
                ui.load_extensions();
            } else {
                ui.extensions.borrow_mut().clear();
            }
            ui.refresh();
            status.set_text("Search settings saved");
        });
        panel
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn aliases_boundaries_cycles_and_web() {
        let mut p = Preferences::default();
        p.aliases.push(Alias {
            name: "ff".into(),
            target: "firefox".into(),
        });
        assert_eq!(p.resolve("ff work").unwrap(), "firefox work");
        assert_eq!(p.resolve("g coffee & café").unwrap(), "web coffee & café");
        assert_eq!(p.resolve("ffmpeg").unwrap(), "ffmpeg");
        p.aliases.push(Alias {
            name: "firefox".into(),
            target: "ff".into(),
        });
        assert!(p.validate().is_err());
        assert_eq!(
            Web::DuckDuckGo.url("café &").unwrap(),
            "https://duckduckgo.com/?q=caf%C3%A9%20%26"
        );
        assert!(Web::Disabled.url("a").is_none());
        let old: Preferences = serde_json::from_str("{}").unwrap();
        assert_eq!(old.web, Web::Google);
        assert_eq!(category("docker db"), Some("containers"));
        assert_eq!(category("fonts"), Some("fonts"));
        assert_eq!(category("dockerfile"), None);
    }
}

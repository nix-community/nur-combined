use gtk::prelude::*;
use std::{cell::Cell, rc::Rc};
#[path = "guide_topics.rs"]
mod catalog;

#[derive(Clone)]
pub enum Action {
    Search(String),
    Page(crate::Page),
    Settings(&'static str),
    Finish,
}

struct Step {
    category: &'static str,
    title: &'static str,
    description: &'static str,
    example: String,
    tip: &'static str,
    button: &'static str,
    action: Option<Action>,
}

pub fn panel(
    app: String,
    initial: usize,
    changed: impl Fn(usize) + 'static,
    activate: impl Fn(Action) + 'static,
) -> gtk::Box {
    let steps = Rc::new(catalog::topics(&app));
    let index = Rc::new(Cell::new(initial.min(steps.len() - 1)));
    let activate: Rc<dyn Fn(Action)> = Rc::new(activate);
    let panel = gtk::Box::new(gtk::Orientation::Vertical, 18);
    panel.add_css_class("editor");
    let chooser_label = gtk::Label::new(Some("Choose a topic · type to search the menu"));
    chooser_label.set_xalign(0.);
    chooser_label.add_css_class("subtitle");
    panel.append(&chooser_label);
    let labels: Vec<_> = steps
        .iter()
        .map(|t| format!("{} · {}", t.category, t.title))
        .collect();
    let chooser =
        gtk::DropDown::from_strings(&labels.iter().map(String::as_str).collect::<Vec<_>>());
    chooser.set_widget_name("guide-topics");
    chooser.set_expression(Some(&gtk::PropertyExpression::new(
        gtk::StringObject::static_type(),
        None::<&gtk::Expression>,
        "string",
    )));
    chooser.set_enable_search(true);
    // GTK 4.12 adds this property; retain compatibility with GTK 4.10.
    if chooser.find_property("search-match-mode").is_some() {
        chooser.set_property("search-match-mode", gtk::StringFilterMatchMode::Substring);
    }
    chooser.set_selected(index.get() as u32);
    chooser.update_property(&[gtk::accessible::Property::Label("Guide topic")]);
    panel.append(&chooser);
    let progress = gtk::Label::new(None);
    progress.set_xalign(0.);
    progress.add_css_class("subtitle");
    progress.set_widget_name("guide-progress");
    panel.append(&progress);
    let title = gtk::Label::new(None);
    title.set_xalign(0.);
    title.set_wrap(true);
    title.add_css_class("guide-title");
    title.set_widget_name("guide-title");
    panel.append(&title);
    let description = gtk::Label::new(None);
    description.set_xalign(0.);
    description.set_wrap(true);
    description.set_max_width_chars(55);
    description.set_widget_name("guide-description");
    panel.append(&description);
    let example = gtk::Label::new(None);
    example.set_xalign(0.);
    example.set_selectable(true);
    example.set_wrap(true);
    example.set_wrap_mode(gtk::pango::WrapMode::WordChar);
    example.set_max_width_chars(55);
    example.set_widget_name("guide-example");
    example.add_css_class("guide-example");
    panel.append(&example);
    let tip = gtk::Label::new(None);
    tip.set_xalign(0.);
    tip.set_wrap(true);
    tip.set_max_width_chars(55);
    tip.set_widget_name("guide-tip");
    tip.add_css_class("subtitle");
    panel.append(&tip);
    let try_it = gtk::Button::new();
    try_it.set_halign(gtk::Align::Start);
    try_it.set_widget_name("guide-try");
    panel.append(&try_it);
    let spacer = gtk::Box::new(gtk::Orientation::Vertical, 0);
    spacer.set_vexpand(true);
    panel.append(&spacer);
    let navigation = gtk::Box::new(gtk::Orientation::Horizontal, 8);
    let back = gtk::Button::with_label("Back");
    back.set_widget_name("guide-back");
    navigation.append(&back);
    let finish = gtk::Button::with_label("Start searching");
    finish.set_widget_name("guide-finish");
    navigation.append(&finish);
    let gap = gtk::Box::new(gtk::Orientation::Horizontal, 0);
    gap.set_hexpand(true);
    navigation.append(&gap);
    let next = gtk::Button::with_label("Next");
    next.add_css_class("accent");
    next.set_widget_name("guide-next");
    navigation.append(&next);
    panel.append(&navigation);
    let render: Rc<dyn Fn()> = {
        let steps = Rc::clone(&steps);
        let index = Rc::clone(&index);
        let back = back.downgrade();
        let next = next.downgrade();
        let try_it = try_it.downgrade();
        let chooser = chooser.downgrade();
        let container = panel.downgrade();
        Rc::new(move || {
            let i = index.get();
            let step = &steps[i];
            progress.set_text(&format!(
                "Feature guide · {} of {} · {}",
                i + 1,
                steps.len(),
                step.category
            ));
            title.set_text(step.title);
            description.set_text(step.description);
            example.set_text(&step.example);
            tip.set_text(step.tip);
            if let Some(back) = back.upgrade() {
                back.set_sensitive(i > 0);
            }
            if let Some(next) = next.upgrade() {
                next.set_label(if i + 1 == steps.len() {
                    "Start searching"
                } else {
                    "Next"
                });
            }
            if let Some(try_it) = try_it.upgrade() {
                try_it.set_visible(step.action.is_some());
                try_it.set_label(step.button);
            }
            if let Some(chooser) = chooser.upgrade() {
                chooser.set_selected(i as u32);
            }
            if let Some(panel) = container.upgrade()
                && let Some(scroll) = panel
                    .ancestor(gtk::ScrolledWindow::static_type())
                    .and_downcast::<gtk::ScrolledWindow>()
            {
                let adjustment = scroll.vadjustment();
                adjustment.set_value(adjustment.lower());
            }
            changed(i);
        })
    };
    let step = Rc::clone(&index);
    let examples = Rc::clone(&steps);
    let action = Rc::clone(&activate);
    try_it.connect_clicked(move |_| {
        if let Some(action_value) = examples[step.get()].action.clone() {
            action(action_value);
        }
    });
    let step = Rc::clone(&index);
    let update = Rc::clone(&render);
    back.connect_clicked(move |_| {
        step.set(step.get().saturating_sub(1));
        update();
    });
    let action = Rc::clone(&activate);
    finish.connect_clicked(move |_| action(Action::Finish));
    let step = Rc::clone(&index);
    let update = Rc::clone(&render);
    let total = steps.len();
    next.connect_clicked(move |_| {
        if step.get() + 1 == total {
            activate(Action::Finish);
        } else {
            step.set(step.get() + 1);
            update();
        }
    });
    let update = Rc::clone(&render);
    let step = index;
    chooser.connect_selected_notify(move |chooser| {
        let selected = chooser.selected() as usize;
        if selected < total && selected != step.get() {
            step.set(selected);
            update();
        }
    });
    render();
    panel
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn feature_inventory_and_calendar_example() {
        let steps = catalog::topics("Example app");
        assert!(steps.len() >= 40);
        let mut unique = std::collections::HashSet::new();
        for step in &steps {
            assert!(unique.insert(step.title));
            assert!(
                !step.category.is_empty()
                    && !step.description.is_empty()
                    && !step.example.is_empty()
                    && !step.tip.is_empty()
            );
            assert_eq!(step.action.is_some(), !step.button.is_empty());
        }
        let catalog = steps
            .iter()
            .map(|s| format!("{} {} {} {}", s.title, s.description, s.example, s.tip))
            .collect::<Vec<_>>()
            .join("\n");
        for feature in [
            "Search File",
            "Recent",
            "ripgrep",
            "Clipboard",
            "Obsidian",
            "Quicklinks",
            "Snippets",
            "Espanso",
            "Emoji",
            "Fonts",
            "Currency",
            "Calculator",
            "Unit",
            "dictionary",
            "translation",
            "tldr",
            "UUID",
            "Hash",
            "Base64",
            "calendar",
            "Contacts",
            "Timers",
            "Alarms",
            "Window Manager",
            "virtual desktops",
            "Color Picker",
            "Measurement",
            "Caffeinate",
            "microphone",
            "Wi-Fi",
            "Bluetooth",
            "Do Not Disturb",
            "dark",
            "Trash",
            "Lock Screen",
            "Screenshot",
            "process",
            "Git",
            "Docker",
            "Podman",
            "Script",
            "WASM",
            "interface size",
            "About",
            "quitting",
            "Reveal in Dolphin",
            "Copy Path",
            "Copy File",
            "Open With",
            "Get Info",
            "my ip",
            "ip local",
            "battery",
            "disk",
            "ram",
            "uptime",
            "qr hello",
            "generate qr",
            "ocr latest",
            "lorem 5",
            "case camel",
            "case snake",
            "case kebab",
            "json format",
            "Pin entry",
            "Unpin entry",
            "clip text",
            "clip images",
            "clip pinned",
            "Clear clipboard history",
            "close window",
            "quit app",
            "kill window",
            "tabs chrome",
            "speakers HDMI",
            "apt search",
            "pacman Ss",
            "flatpak search",
            "systemctl restart docker",
            "service status",
            "bluetooth connect AirPods",
            "code myproject",
            "jetbrains myproject",
            "project ~/Projects/myproject",
            "ssh myserver",
            "env PATH",
            "dotenv API",
            "gh pr list",
            "gh issue",
            "{cursor}",
            "{clipboard}",
            "ai summarize clipboard",
            "meet in 2h",
            "ff = firefox",
            "Docker and Podman",
            "community-plugins.toml",
            "spotlight --autostart",
            "spotlight --no-autostart",
            ".spotlightignore",
            "Tab / Ctrl+K",
            "cargo clippy",
            "usability_smoke.py",
            "music",
            "play/pause",
            "todo add buy milk",
            "Screenshot action chain",
            "do not request another portal capture",
            "play lofi",
            "history youtube",
            "bookmark github",
            "Decode QR",
            "compress image 50%",
            "resize 1080p",
            "image to webp",
            "pdf text",
            "palette ~/Pictures/photo.png",
            "git status",
            "docker logs nginx",
            "docker exec nginx",
            "get https://api.github.com/user",
            "Dotfiles sync",
            "dotenv diff .env.local .env.example",
            "pass github",
            "keepass setup",
            "ping 8.8.8.8",
            "dig github.com",
            "my ports",
            "scan wifi",
            "encrypt file",
            "checksum file",
            "shred file",
            "wallpaper next",
            "accent blue",
            "Secure Clipboard Vault",
            "vault → choose password or unlock",
            "one-hour expiry",
            "workflow run name",
            "Screenshot → OCR → Translate → Note",
            "Save & Run → Run chain",
            "OLLAMA_NO_CLOUD=1 ollama serve",
            "ai models",
            "ai ask what should I work on next?",
            "Send locally",
        ] {
            assert!(
                catalog.contains(feature),
                "Missing guide feature: {feature}"
            );
        }
        let calendar = steps
            .iter()
            .find(|s| s.title == "Create calendar events from text")
            .unwrap();
        assert!(
            matches!(&calendar.action, Some(Action::Search(q)) if crate::calendar::parse(q).unwrap().is_ok())
        );
    }
}

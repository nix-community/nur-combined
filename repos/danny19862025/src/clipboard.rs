use crate::{Action, Item, Ui};
use gtk::{gio, glib, prelude::*};
use serde::{Deserialize, Serialize};
use std::{path::PathBuf, rc::Rc, sync::mpsc, time::Duration};

#[derive(Clone, Serialize, Deserialize)]
#[serde(tag = "kind", rename_all = "snake_case")]
pub enum Pinned {
    Text { id: String, value: String },
    Image { id: String, path: PathBuf },
}
pub fn filter(query: &str) -> (&str, &str) {
    let q = query.trim();
    for (prefix, kind) in [
        ("clip text", "text"),
        ("clip images", "images"),
        ("clip image", "images"),
        ("text", "text"),
        ("images", "images"),
        ("image", "images"),
        ("clip pinned", "pinned"),
        ("pinned", "pinned"),
    ] {
        if q == prefix {
            return (kind, "");
        }
        if let Some(rest) = q
            .strip_prefix(prefix)
            .and_then(|s| s.strip_prefix(char::is_whitespace))
        {
            return (kind, rest.trim());
        }
    }
    ("all", q)
}
pub fn command(query: &str) -> Option<&str> {
    let q = query.trim();
    let rest = q.strip_prefix("clip ")?.trim();
    let mode = rest.split_whitespace().next()?;
    matches!(mode, "text" | "image" | "images" | "pinned").then_some(rest)
}
pub fn is_pinned(id: &str) -> bool {
    id.starts_with("pinned:") || id.starts_with("vault-pin:") || id == "clipboard-vault"
}
pub fn clear_history() -> Result<(), String> {
    let bus = gio::bus_get_sync(gio::BusType::Session, None::<&gio::Cancellable>)
        .map_err(|e| e.to_string())?;
    for method in ["clearClipboardHistory", "clearClipboardContents"] {
        bus.call_sync(
            Some("org.kde.klipper"),
            "/klipper",
            "org.kde.klipper.klipper",
            method,
            None,
            None,
            gio::DBusCallFlags::NONE,
            3000,
            None::<&gio::Cancellable>,
        )
        .map_err(|e| format!("Could not clear Klipper: {e}"))?;
    }
    Ok(())
}
impl Ui {
    pub(super) fn pinned_clipboard_items(&self) -> Vec<Item> {
        self.secure_pin_rows()
    }

    pub(super) fn clipboard_actions(
        self: &Rc<Self>,
        menu: &gtk::Box,
        popup: &gtk::Popover,
        selected: Option<&Item>,
    ) {
        if *self.page.borrow() != crate::Page::Clipboard {
            return;
        }
        if let Some(selected) = selected
            && matches!(
                selected.action,
                Action::Copy(_)
                    | Action::ClipboardImage(_)
                    | Action::ClipboardTexture(_)
                    | Action::VaultPin(_)
            )
        {
            let button = gtk::Button::with_label(if is_pinned(&selected.id) {
                "Unpin entry"
            } else {
                "Pin entry"
            });
            let ui = self.clone();
            let target = selected.clone();
            let pop = popup.clone();
            button.connect_clicked(move |_| {
                pop.popdown();
                ui.pin_clipboard(&target);
            });
            menu.append(&button);
        }
        for (label, query) in [
            ("Show text only", "clip text"),
            ("Show images only", "clip images"),
            ("Show pinned entries", "clip pinned"),
            ("Show all clipboard entries", ""),
        ] {
            let b = gtk::Button::with_label(label);
            let ui = self.clone();
            let pop = popup.clone();
            b.connect_clicked(move |_| {
                pop.popdown();
                ui.search.set_text(query);
            });
            menu.append(&b);
        }
        let clear = gtk::Button::with_label("Clear clipboard history…");
        let ui = self.clone();
        let pop = popup.clone();
        clear.connect_clicked(move |_| {
            pop.popdown();
            ui.clear_clipboard();
        });
        menu.append(&clear);
        menu.append(&gtk::Separator::new(gtk::Orientation::Horizontal));
    }
    pub(super) fn pin_clipboard(self: &Rc<Self>, selected: &Item) {
        self.pin_secure(selected);
    }

    pub(super) fn clear_clipboard(self: &Rc<Self>) {
        let ui = self.clone();
        self.confirm("Clear clipboard history?","Clear Klipper history and the current clipboard. Entries pinned in Spotlight are kept.","Clear history",move||{
            let(tx,rx)=mpsc::channel();std::thread::spawn(move||{let _=tx.send(clear_history());});let weak=Rc::downgrade(&ui);
            glib::timeout_add_local(Duration::from_millis(80),move||{let Some(ui)=weak.upgrade()else{return glib::ControlFlow::Break;};match rx.try_recv(){Ok(Ok(()))=>{ui.clips.borrow_mut().clear();ui.clip_images.borrow_mut().clear();ui.clip_current.borrow_mut().take();ui.clip_generation.set(ui.clip_generation.get().wrapping_add(1));ui.refresh();ui.error("History cleared · pinned entries kept");glib::ControlFlow::Break},Ok(Err(error))=>{ui.error(&error);glib::ControlFlow::Break},Err(mpsc::TryRecvError::Empty)=>glib::ControlFlow::Continue,Err(_)=>{ui.error("Clipboard clearing interrupted");glib::ControlFlow::Break}}});
        });
    }
}
#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn typed_filters_and_old_saved_data() {
        assert_eq!(filter("clip text café"), ("text", "café"));
        assert_eq!(filter("images hello"), ("images", "hello"));
        assert_eq!(filter("clip pinned"), ("pinned", ""));
        assert_eq!(filter("textual note"), ("all", "textual note"));
        assert_eq!(command("clipboard"), None);
        assert_eq!(command("clip"), None);
        assert_eq!(command("clip text"), Some("text"));
        let store: crate::core::Store = serde_json::from_str("{\"notes\":[]}").unwrap();
        assert!(store.pinned_clips.is_empty());
        let pin = Pinned::Text {
            id: "id".into(),
            value: "first\nsecond".into(),
        };
        let decoded: Pinned = serde_json::from_str(&serde_json::to_string(&pin).unwrap()).unwrap();
        assert!(matches!(decoded,Pinned::Text{value,..}if value=="first\nsecond"));
    }
}

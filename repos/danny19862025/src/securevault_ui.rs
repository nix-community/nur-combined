use crate::{
    Action, Item, Page, Ui, core, item,
    securevault::{self, Payload},
};
use gtk::{gdk, glib, prelude::*};
use std::{fs, rc::Rc, sync::mpsc, time::Duration};

impl Ui {
    pub(super) fn secure_pin_rows(&self) -> Vec<Item> {
        let Ok(vault) = self.secure_vault.try_lock() else {
            return vec![];
        };
        let mut rows = vec![item(
            "clipboard-vault",
            if vault.unlocked() {
                "Clipboard Vault · unlocked"
            } else {
                "Unlock Clipboard Vault"
            },
            "Encrypted pins · expire after one hour · Enter opens vault controls",
            "changes-prevent-symbolic",
            "Vault",
            Action::Vault,
        )];
        if !vault.unlocked() {
            return rows;
        }
        let now = securevault::now();
        for (id, expires, payload) in vault.snapshot(now).unwrap_or_default() {
            let badge = if matches!(payload, Ok(Payload::Image(_))) {
                "Secure image"
            } else {
                "Secure text"
            };
            let title: String = match payload {
                Ok(Payload::Text(ref text)) => text
                    .lines()
                    .next()
                    .unwrap_or("Encrypted text")
                    .chars()
                    .take(100)
                    .collect(),
                Ok(Payload::Image(_)) => "Encrypted clipboard image".into(),
                Err(_) => "Unreadable encrypted pin".into(),
            };
            rows.push(item(
                &format!("vault-pin:{id}"),
                &title,
                &format!(
                    "Encrypted · expires in {} min · Enter copies · Ctrl+K removes",
                    ((expires - now) + 59) / 60
                ),
                "changes-prevent-symbolic",
                badge,
                Action::VaultPin(id),
            ));
        }
        rows
    }
    pub(super) fn open_clipboard_vault(self: &Rc<Self>) {
        let Ok(vault) = self.secure_vault.try_lock() else {
            self.error("Vault is busy");
            return;
        };
        if vault.unlocked() {
            drop(vault);
            let ui = self.clone();
            self.confirm("Lock Clipboard Vault?", "Clear the in-memory key and hide secure pins. Pins still expire one hour after they were added.", "Lock vault", move || {
                if let Ok(mut vault) = ui.secure_vault.try_lock() { vault.lock(); }
                ui.clear_vault_views(); ui.error("Clipboard vault locked");
            });
            return;
        }
        let create = !vault.exists();
        drop(vault);
        if !self.can_save {
            self.error("Saved data is unreadable · fix it before creating or migrating pins");
            return;
        }
        let ui = self.clone();
        self.secret_prompt(
            if create {
                "Create Clipboard Vault · choose a master password"
            } else {
                "Unlock Clipboard Vault"
            },
            create,
            move |mut password| {
                if password.0.last() == Some(&b'\n') {
                    password.0.pop();
                }
                let vault = ui.secure_vault.clone();
                let (tx, rx) = mpsc::channel();
                ui.error("Unlocking encrypted clipboard vault…");
                std::thread::spawn(move || {
                    let result = vault
                        .lock()
                        .map_err(|_| "Vault interrupted".to_string())
                        .and_then(|mut v| v.unlock(&password.0, create));
                    let _ = tx.send(result);
                });
                let weak = Rc::downgrade(&ui);
                glib::timeout_add_local(Duration::from_millis(60), move || {
                    let Some(ui) = weak.upgrade() else {
                        return glib::ControlFlow::Break;
                    };
                    match rx.try_recv() {
                        Ok(Ok(())) => {
                            ui.migrate_legacy_pins();
                            ui.page(Page::Clipboard);
                            ui.search.set_text("clip pinned");
                            ui.refresh();
                            glib::ControlFlow::Break
                        }
                        Ok(Err(e)) => {
                            ui.refresh();
                            ui.error(&e);
                            glib::ControlFlow::Break
                        }
                        Err(mpsc::TryRecvError::Empty) => glib::ControlFlow::Continue,
                        Err(_) => {
                            ui.error("Vault unlock interrupted");
                            glib::ControlFlow::Break
                        }
                    }
                });
            },
        );
    }
    fn migrate_legacy_pins(self: &Rc<Self>) {
        let pins = self.store.borrow().pinned_clips.clone();
        if pins.is_empty() {
            self.error("Vault unlocked · new pins expire after one hour");
            return;
        }
        let result = (|| {
            let mut payloads = Vec::new();
            for pin in &pins {
                payloads.push(match pin {
                    crate::clipboard::Pinned::Text { value, .. } => Payload::Text(value.clone()),
                    crate::clipboard::Pinned::Image { path, .. } => {
                        crate::systemtools::regular(path)?;
                        let texture = crate::clipimage::load(path)?;
                        Payload::Image(texture.save_to_png_bytes().to_vec())
                    }
                });
            }
            self.secure_vault
                .lock()
                .map_err(|_| "Vault interrupted")?
                .add_batch(&payloads, securevault::now())?;
            let mut store = self.store.borrow_mut();
            let old = std::mem::take(&mut store.pinned_clips);
            if let Err(error) = store.save() {
                store.pinned_clips = old;
                return Err(format!(
                    "Encrypted copies saved, but legacy cleanup failed: {error}"
                ));
            }
            drop(store);
            let directory = core::data_dir().join("clipboard-pins");
            for pin in pins {
                if let crate::clipboard::Pinned::Image { path, .. } = pin
                    && path.parent() == Some(directory.as_path())
                {
                    fs::remove_file(path).map_err(
                        |_| "Encrypted pins saved, but an old plaintext image could not be removed",
                    )?;
                }
            }
            Ok(())
        })();
        self.error(match &result {
            Ok(()) => {
                "Existing pins encrypted · plaintext pin store cleared · one-hour expiry started"
            }
            Err(e) => e,
        });
    }
    pub(super) fn pin_secure(self: &Rc<Self>, selected: &Item) {
        if let Some(id) = selected.id.strip_prefix("vault-pin:") {
            let result = self
                .secure_vault
                .lock()
                .map_err(|_| "Vault interrupted".to_string())
                .and_then(|mut v| v.remove(id));
            self.refresh();
            self.error(
                result
                    .as_ref()
                    .err()
                    .map(String::as_str)
                    .unwrap_or("Encrypted pin removed"),
            );
            return;
        }
        if !self.can_save {
            self.error("Saved data is unreadable");
            return;
        }
        if !self.secure_vault.try_lock().is_ok_and(|v| v.unlocked()) {
            self.open_clipboard_vault();
            self.error("Unlock the vault, then pin the selected entry again");
            return;
        }
        let payload = match &selected.action {
            Action::Copy(text) => Payload::Text(text.clone()),
            Action::ClipboardTexture(texture) => {
                if i64::from(texture.width()) * i64::from(texture.height()) > 16_000_000 {
                    self.error("Pinned image exceeds 16 million pixels");
                    return;
                }
                Payload::Image(texture.save_to_png_bytes().to_vec())
            }
            Action::ClipboardImage(path) => match crate::clipimage::load(path) {
                Ok(t) => Payload::Image(t.save_to_png_bytes().to_vec()),
                Err(e) => {
                    self.error(&e);
                    return;
                }
            },
            _ => {
                self.error("Choose clipboard text or an image");
                return;
            }
        };
        let result = self
            .secure_vault
            .lock()
            .map_err(|_| "Vault interrupted".to_string())
            .and_then(|mut v| v.add(&payload, securevault::now()));
        self.refresh();
        self.error(
            result
                .as_ref()
                .err()
                .map(String::as_str)
                .unwrap_or("Pin encrypted · expires in one hour"),
        );
    }
    pub(super) fn copy_vault_pin(&self, id: &str) {
        let result = self
            .secure_vault
            .lock()
            .map_err(|_| "Vault interrupted".to_string())
            .and_then(|v| v.read(id, securevault::now()));
        let provider = match result {
            Ok(Payload::Text(ref text)) => crate::systemtools_ui::secret_provider(
                crate::systemtools::Secret(text.as_bytes().to_vec()),
            ),
            Ok(Payload::Image(ref bytes)) => {
                match gdk::Texture::from_bytes(&glib::Bytes::from_owned(bytes.clone())) {
                    Ok(texture) => gdk::ContentProvider::new_union(&[
                        gdk::ContentProvider::for_value(&texture.to_value()),
                        gdk::ContentProvider::for_bytes(
                            "x-kde-passwordManagerHint",
                            &glib::Bytes::from_static(b"secret"),
                        ),
                    ]),
                    Err(_) => {
                        self.error("Encrypted image could not be decoded");
                        return;
                    }
                }
            }
            Err(e) => {
                self.error(&e);
                return;
            }
        };
        let clipboard = self.window.clipboard();
        if let Err(e) = clipboard.set_content(Some(&provider)) {
            self.error(&e.to_string());
            return;
        }
        *self.vault_clipboard.borrow_mut() = Some(provider.clone());
        glib::timeout_add_local_once(Duration::from_secs(30), move || {
            if clipboard.content().as_ref() == Some(&provider) {
                let _ = clipboard.set_content(None::<&gdk::ContentProvider>);
            }
        });
        self.error("Secure pin copied · sensitive clipboard offer expires in 30 seconds");
    }
    fn clear_vault_views(self: &Rc<Self>) {
        if let Some(queue) = self.paste_queue.borrow_mut().take() {
            queue.stop();
        }
        if let Some(provider) = self.vault_clipboard.borrow_mut().take() {
            let clipboard = self.window.clipboard();
            if clipboard.content().as_ref() == Some(&provider) {
                let _ = clipboard.set_content(None::<&gdk::ContentProvider>);
            }
        }
        for window in gtk::Window::list_toplevels() {
            if window.widget_name() == "secure-paste-queue"
                && let Ok(window) = window.downcast::<gtk::Window>()
            {
                window.close();
            }
        }
        self.visible
            .borrow_mut()
            .retain(|row| !row.id.starts_with("vault-pin:"));
        self.refresh();
    }
    pub(super) fn vault_expiry_clock(self: &Rc<Self>) {
        let weak = Rc::downgrade(self);
        glib::timeout_add_local(Duration::from_secs(1), move || {
            let Some(ui) = weak.upgrade() else {
                return glib::ControlFlow::Break;
            };
            let changed = if let Ok(mut vault) = ui.secure_vault.try_lock() {
                match vault.prune(securevault::now()) {
                    Ok(changed) => changed,
                    Err(_) => {
                        vault.lock();
                        true
                    }
                }
            } else {
                false
            };
            if changed {
                ui.clear_vault_views();
            }
            glib::ControlFlow::Continue
        });
    }
}

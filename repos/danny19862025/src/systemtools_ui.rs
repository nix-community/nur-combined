use crate::{
    Ui,
    systemtools::{self, FileTool, Operation, Outcome, Secret, Vault},
};
use gtk::{gdk, gio, glib, prelude::*};
use std::{path::PathBuf, rc::Rc, sync::mpsc, time::Duration};

impl Ui {
    pub(super) fn execute_system_tool(self: &Rc<Self>, op: Operation) {
        match op {
            Operation::KeepassSetup => self.keepass_setup(),
            Operation::Pick(tool) => {
                let picker = gtk::FileDialog::builder()
                    .title(tool.title())
                    .modal(true)
                    .build();
                let ui = self.clone();
                picker.open(
                    Some(&self.window),
                    None::<&gio::Cancellable>,
                    move |result| {
                        if let Ok(file) = result {
                            if let Some(path) = file.path() {
                                ui.execute_system_tool(Operation::File(tool, path));
                            } else {
                                ui.error("Choose a local file");
                            }
                        }
                    },
                );
            }
            Operation::File(FileTool::Shred, path) => {
                let expected = match systemtools::regular(&path) {
                    Ok(id) => id,
                    Err(e) => {
                        self.error(&e);
                        return;
                    }
                };
                let ui = self.clone();
                self.confirm("Shred file permanently?", &format!("{}\n\nOverwrite this file with three passes and a final zero pass, then remove it. This cannot be undone. SSD wear levelling, copy-on-write filesystems, snapshots and backups can retain copies. Use disk encryption for reliable protection at rest.", path.display()), "Shred permanently", move || {
                    let path = path.clone(); let expected = expected.clone();
                    ui.system_tool_worker(move || systemtools::shred(&path, &expected));
                });
            }
            Operation::File(tool @ (FileTool::Encrypt | FileTool::Decrypt), path) => {
                if let Err(e) = systemtools::regular(&path) {
                    self.error(&e);
                    return;
                }
                let ui = self.clone();
                self.secret_prompt(tool.title(), tool == FileTool::Encrypt, move |secret| {
                    let path = path.clone();
                    ui.system_tool_worker(move || {
                        systemtools::transform(tool, &path, Some(secret))
                    });
                });
            }
            Operation::File(tool, path) => {
                self.system_tool_worker(move || systemtools::transform(tool, &path, None))
            }
            Operation::Password(Vault::Rbw, name) => self.system_tool_worker(move || {
                systemtools::password(Vault::Rbw, &name, None, None, None)
            }),
            Operation::Password(Vault::KeePass, name) => {
                let database = self.store.borrow().keepass_database.clone();
                let key = self.store.borrow().keepass_key_file.clone();
                let Some(database) = database else {
                    self.error("Choose your KeePassXC database with keepass setup first");
                    return;
                };
                let ui = self.clone();
                self.secret_prompt("Unlock KeePassXC database", false, move |master| {
                    let db = database.clone();
                    let key = key.clone();
                    let name = name.clone();
                    ui.system_tool_worker(move || {
                        systemtools::password(
                            Vault::KeePass,
                            &name,
                            Some(&db),
                            key.as_deref(),
                            Some(master),
                        )
                    });
                });
            }
            op => {
                if !self.can_save {
                    self.error("Saved settings are unreadable · appearance cannot be changed");
                    return;
                }
                self.system_tool_worker(move || systemtools::appearance(op));
            }
        }
    }
    pub(super) fn secret_prompt(
        self: &Rc<Self>,
        title: &str,
        repeat: bool,
        action: impl Fn(Secret) + 'static,
    ) {
        let dialog = gtk::Window::builder()
            .title(title)
            .transient_for(&self.window)
            .modal(true)
            .destroy_with_parent(true)
            .default_width(480)
            .build();
        dialog.set_widget_name("secret-dialog");
        let panel = gtk::Box::new(gtk::Orientation::Vertical, 12);
        panel.add_css_class("editor");
        let label = gtk::Label::new(Some(
            "Passphrase · used only for this action and never saved",
        ));
        label.set_wrap(true);
        panel.append(&label);
        let secret = gtk::PasswordEntry::builder()
            .show_peek_icon(false)
            .activates_default(true)
            .build();
        secret.set_widget_name("secret-input");
        secret.update_property(&[gtk::accessible::Property::Label("Passphrase")]);
        panel.append(&secret);
        let confirmation = gtk::PasswordEntry::builder()
            .show_peek_icon(false)
            .activates_default(true)
            .build();
        confirmation.set_widget_name("secret-confirm");
        confirmation.update_property(&[gtk::accessible::Property::Label("Repeat passphrase")]);
        if repeat {
            panel.append(&gtk::Label::new(Some("Repeat passphrase")));
            panel.append(&confirmation);
        }
        let status = gtk::Label::new(None);
        status.set_wrap(true);
        panel.append(&status);
        let row = gtk::Box::new(gtk::Orientation::Horizontal, 8);
        let cancel = gtk::Button::with_label("Cancel");
        cancel.set_widget_name("secret-cancel");
        let accept = gtk::Button::with_label("Continue");
        accept.set_widget_name("secret-accept");
        accept.add_css_class("accent");
        row.append(&cancel);
        row.append(&accept);
        panel.append(&row);
        dialog.set_child(Some(&panel));
        dialog.set_default_widget(Some(&accept));
        let weak = dialog.downgrade();
        cancel.connect_clicked(move |_| {
            if let Some(dialog) = weak.upgrade() {
                dialog.close();
            }
        });
        let weak = dialog.downgrade();
        let first = secret.clone();
        let second = confirmation.clone();
        accept.connect_clicked(move |button| {
            let text = first.text();
            if text.is_empty() || text.contains(['\n', '\r', '\0']) {
                status.set_text("Enter a nonempty passphrase without line breaks.");
                return;
            }
            if repeat && text != second.text() {
                status.set_text("The passphrases do not match.");
                return;
            }
            let mut bytes = text.as_bytes().to_vec();
            bytes.push(b'\n');
            drop(text);
            first.set_text("");
            second.set_text("");
            button.set_sensitive(false);
            if let Some(dialog) = weak.upgrade() {
                dialog.close();
            }
            action(Secret(bytes));
        });
        dialog.connect_close_request(move |_| {
            secret.set_text("");
            confirmation.set_text("");
            glib::Propagation::Proceed
        });
        escape_closes(&dialog);
        dialog.present();
    }
    fn keepass_setup(self: &Rc<Self>) {
        let dialog = gtk::Window::builder()
            .title("KeePassXC database")
            .transient_for(&self.window)
            .modal(true)
            .destroy_with_parent(true)
            .default_width(570)
            .build();
        dialog.set_widget_name("keepass-setup");
        let panel = gtk::Box::new(gtk::Orientation::Vertical, 12);
        panel.add_css_class("editor");
        let database = path_field(
            &panel,
            &dialog,
            "Database (.kdbx)",
            self.store.borrow().keepass_database.as_ref(),
        );
        database.set_widget_name("keepass-database");
        let key = path_field(
            &panel,
            &dialog,
            "Key file (optional)",
            self.store.borrow().keepass_key_file.as_ref(),
        );
        key.set_widget_name("keepass-key-file");
        let note = gtk::Label::new(Some(
            "Only these paths are saved. Each lookup asks for your database password. Use the exact Group/Entry path; hardware-key and key-only databases are not supported here.",
        ));
        note.set_wrap(true);
        panel.append(&note);
        let status = gtk::Label::new(None);
        status.set_wrap(true);
        panel.append(&status);
        let row = gtk::Box::new(gtk::Orientation::Horizontal, 8);
        let cancel = gtk::Button::with_label("Cancel");
        let save = gtk::Button::with_label("Save database");
        save.set_widget_name("keepass-save");
        row.append(&cancel);
        row.append(&save);
        panel.append(&row);
        let weak = dialog.downgrade();
        cancel.connect_clicked(move |_| {
            if let Some(d) = weak.upgrade() {
                d.close();
            }
        });
        let ui = self.clone();
        let weak = dialog.downgrade();
        save.connect_clicked(move |_| {
            if !ui.can_save {
                status.set_text("Saved settings are unreadable.");
                return;
            }
            let db = systemtools::expand(database.text().as_str());
            let key =
                (!key.text().trim().is_empty()).then(|| systemtools::expand(key.text().as_str()));
            if let Err(e) = systemtools::regular(&db).and_then(|_| {
                if let Some(p) = &key {
                    systemtools::regular(p).map(|_| ())
                } else {
                    Ok(())
                }
            }) {
                status.set_text(&e);
                return;
            }
            let mut store = ui.store.borrow_mut();
            let old_db = store.keepass_database.replace(db);
            let old_key = std::mem::replace(&mut store.keepass_key_file, key);
            if let Err(e) = store.save() {
                store.keepass_database = old_db;
                store.keepass_key_file = old_key;
                status.set_text(&e);
                return;
            }
            drop(store);
            if let Some(dialog) = weak.upgrade() {
                dialog.close();
            }
            ui.error("Database saved · type keepass Group/Entry to copy a password");
        });
        dialog.set_child(Some(&panel));
        escape_closes(&dialog);
        dialog.present();
    }
    pub(super) fn system_tool_worker(
        self: &Rc<Self>,
        work: impl FnOnce() -> Result<Outcome, String> + Send + 'static,
    ) {
        if self.booster_busy.replace(true) {
            self.error("Another command is still running");
            return;
        }
        self.error("Working…");
        let (tx, rx) = mpsc::channel();
        std::thread::spawn(move || {
            let _ = tx.send(work());
        });
        let weak = Rc::downgrade(self);
        glib::timeout_add_local(Duration::from_millis(50), move || {
            let Some(ui) = weak.upgrade() else {
                return glib::ControlFlow::Break;
            };
            let result = match rx.try_recv() {
                Ok(result) => result,
                Err(mpsc::TryRecvError::Empty) => return glib::ControlFlow::Continue,
                Err(_) => Err("Action interrupted".into()),
            };
            ui.booster_busy.set(false);
            match result {
                Err(e) => ui.error(&e),
                Ok(Outcome::Secret(secret)) => ui.copy_secret(secret),
                Ok(Outcome::Text(title, text)) => {
                    ui.error("");
                    ui.text_preview(&title, &text, None);
                }
                Ok(Outcome::File(path)) => {
                    ui.error("");
                    ui.text_preview(
                        "Saved file · original kept",
                        &path.display().to_string(),
                        Some(&gio::File::for_path(&path).uri()),
                    );
                }
                Ok(Outcome::Message(message)) => {
                    ui.booster_cache.borrow_mut().clear();
                    ui.refresh();
                    ui.error(&message);
                }
                Ok(Outcome::Wallpaper(path)) => {
                    let mut store = ui.store.borrow_mut();
                    let old = store.last_wallpaper.replace(path);
                    let result = store.save();
                    if result.is_err() {
                        store.last_wallpaper = old;
                    }
                    drop(store);
                    ui.booster_cache.borrow_mut().clear();
                    ui.refresh();
                    ui.error(match &result {
                        Ok(()) => "Wallpaper changed",
                        Err(_) => "Wallpaper changed · could not save cycle position",
                    });
                }
                Ok(Outcome::Accent(hex)) => {
                    let mut theme = ui.store.borrow().theme.clone();
                    theme.accent = hex;
                    match ui.set_theme(theme) {
                        Ok(()) => ui.error("KDE and Spotlight accent changed"),
                        Err(_) => ui.error("KDE accent changed · could not save Spotlight accent"),
                    }
                }
            }
            glib::ControlFlow::Break
        });
    }
    pub(super) fn copy_secret(&self, secret: Secret) {
        let clipboard = self.window.clipboard();
        let provider = secret_provider(secret);
        if let Err(e) = clipboard.set_content(Some(&provider)) {
            self.error(&e.to_string());
            return;
        }
        glib::timeout_add_local_once(Duration::from_secs(30), move || {
            // Preserve anything the user copied after this password.
            if clipboard.content().as_ref() == Some(&provider) {
                let _ = clipboard.set_content(None::<&gdk::ContentProvider>);
            }
        });
        self.error("Password copied · expires in 30 seconds · clipboard marked sensitive");
    }
}
pub(super) fn secret_provider(secret: Secret) -> gdk::ContentProvider {
    let bytes = glib::Bytes::from_owned(secret);
    gdk::ContentProvider::new_union(&[
        gdk::ContentProvider::for_bytes("text/plain;charset=utf-8", &bytes),
        gdk::ContentProvider::for_bytes("text/plain", &bytes),
        gdk::ContentProvider::for_bytes(
            "x-kde-passwordManagerHint",
            &glib::Bytes::from_static(b"secret"),
        ),
    ])
}
fn escape_closes(dialog: &gtk::Window) {
    let key = gtk::EventControllerKey::new();
    let weak = dialog.downgrade();
    key.connect_key_pressed(move |_, key, _, _| {
        if key == gdk::Key::Escape {
            if let Some(d) = weak.upgrade() {
                d.close();
            }
            glib::Propagation::Stop
        } else {
            glib::Propagation::Proceed
        }
    });
    dialog.add_controller(key);
}
fn path_field(
    panel: &gtk::Box,
    parent: &gtk::Window,
    label: &str,
    initial: Option<&PathBuf>,
) -> gtk::Entry {
    let caption = gtk::Label::new(Some(label));
    caption.set_xalign(0.);
    panel.append(&caption);
    let row = gtk::Box::new(gtk::Orientation::Horizontal, 8);
    let entry = gtk::Entry::builder().hexpand(true).build();
    if let Some(path) = initial {
        entry.set_text(&path.to_string_lossy());
    }
    entry.update_property(&[gtk::accessible::Property::Label(label)]);
    let browse = gtk::Button::with_label("Choose…");
    let target = entry.clone();
    let parent = parent.clone();
    browse.connect_clicked(move |_| {
        let target = target.clone();
        gtk::FileDialog::builder().modal(true).build().open(
            Some(&parent),
            None::<&gio::Cancellable>,
            move |result| {
                if let Ok(file) = result
                    && let Some(path) = file.path()
                {
                    target.set_text(&path.to_string_lossy());
                }
            },
        );
    });
    row.append(&entry);
    row.append(&browse);
    panel.append(&row);
    entry
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::*;
    fn window(name: &str) -> gtk::Window {
        gtk::Window::list_toplevels()
            .into_iter()
            .find_map(|w| {
                w.downcast::<gtk::Window>()
                    .ok()
                    .filter(|w| w.widget_name() == name)
            })
            .unwrap_or_else(|| panic!("Missing {name}"))
    }
    fn widget<T: IsA<gtk::Widget> + glib::object::IsClass>(parent: &gtk::Window, name: &str) -> T {
        test_widget(parent.upcast_ref(), &|w| w.widget_name() == name)
            .unwrap()
            .downcast::<T>()
            .ok()
            .unwrap()
    }
    #[test]
    #[ignore = "requires a desktop and isolated CLI/data fixtures; run tests/systemtools_smoke.py"]
    fn native_ui() {
        let root = PathBuf::from(std::env::var_os("SPOTLIGHT_SYSTEMTOOLS_FIXTURE").unwrap());
        assert!(core::data_dir().starts_with(&root));
        let app = gtk::Application::builder()
            .application_id("local.spotlight.SystemTools.Test")
            .build();
        let done = Rc::new(Cell::new(false));
        let completed = done.clone();
        app.connect_activate(move |app| {
            let ui = build_with_mode(app, true);
            let root = root.clone();
            let done = completed.clone();
            let source = root.join("ui fixture.txt");
            std::fs::write(&source, "abc").unwrap();
            let original_theme = ui.store.borrow().theme.clone();
            let started = std::time::Instant::now();
            let mut phase = 0;
            glib::timeout_add_local(Duration::from_millis(180), move || {
                assert!(
                    started.elapsed() < Duration::from_secs(35),
                    "UI timed out at phase {phase}"
                );
                match phase {
                    0 => ui.search.set_text("pass GitHub $(literal)"),
                    1 => {
                        if !ui.visible.borrow().iter().any(|i| {
                            matches!(
                                i.action,
                                Action::Booster(boosters::Operation::System(Operation::Password(
                                    ..
                                )))
                            )
                        }) {
                            return glib::ControlFlow::Continue;
                        }
                        let index = ui
                            .visible
                            .borrow()
                            .iter()
                            .position(|i| {
                                matches!(
                                    i.action,
                                    Action::Booster(boosters::Operation::System(
                                        Operation::Password(..)
                                    ))
                                )
                            })
                            .unwrap();
                        ui.list
                            .select_row(ui.list.row_at_index(index as i32).as_ref());
                        let favorites = ui.store.borrow().favorites.clone();
                        ui.favorite();
                        assert_eq!(ui.store.borrow().favorites, favorites);
                        assert!(
                            ui.visible
                                .borrow()
                                .iter()
                                .all(|i| i.id != "web" && !i.id.contains("GitHub"))
                        );
                        let hints = ui.booster_items(boosters::Query::System(
                            systemtools::Query::Password(None, String::new()),
                        ));
                        assert!(hints.iter().all(|i| i.id.starts_with("booster:password:")));
                        ui.execute_system_tool(Operation::File(FileTool::Shred, source.clone()));
                    }
                    2 => {
                        let dialog = window("action-confirmation");
                        widget::<gtk::Button>(&dialog, "confirmation-cancel").emit_clicked();
                        assert!(source.exists());
                        ui.execute_system_tool(Operation::File(FileTool::Encrypt, source.clone()));
                    }
                    3 => {
                        let dialog = window("secret-dialog");
                        widget::<gtk::PasswordEntry>(&dialog, "secret-input").set_text("test-one");
                        widget::<gtk::PasswordEntry>(&dialog, "secret-confirm")
                            .set_text("test-two");
                        widget::<gtk::Button>(&dialog, "secret-accept").emit_clicked();
                        assert!(dialog.is_visible());
                        widget::<gtk::Button>(&dialog, "secret-cancel").emit_clicked();
                        assert_eq!(std::fs::read_to_string(&source).unwrap(), "abc");
                        assert!(!root.join("ui fixture.txt.gpg").exists());
                        ui.execute_system_tool(Operation::KeepassSetup);
                    }
                    4 => {
                        let dialog = window("keepass-setup");
                        widget::<gtk::Entry>(&dialog, "keepass-database")
                            .set_text(&root.join("database.kdbx").to_string_lossy());
                        widget::<gtk::Entry>(&dialog, "keepass-key-file")
                            .set_text(&root.join("database.key").to_string_lossy());
                        widget::<gtk::Button>(&dialog, "keepass-save").emit_clicked();
                        assert_eq!(
                            ui.store.borrow().keepass_database.as_ref(),
                            Some(&root.join("database.kdbx"))
                        );
                        ui.execute_system_tool(Operation::Password(
                            Vault::KeePass,
                            "Group/GitHub".into(),
                        ));
                    }
                    5 => {
                        let dialog = window("secret-dialog");
                        let password = widget::<gtk::PasswordEntry>(&dialog, "secret-input");
                        password.set_text("must-not-persist");
                        widget::<gtk::Button>(&dialog, "secret-cancel").emit_clicked();
                        assert!(password.text().is_empty());
                        ui.execute_system_tool(Operation::Accent("blue".into()));
                    }
                    6 => {
                        if ui.booster_busy.get() {
                            return glib::ControlFlow::Continue;
                        }
                        assert_eq!(ui.store.borrow().theme.accent, "#3DAEE9");
                        assert_eq!(
                            ui.store.borrow().theme.background,
                            original_theme.background
                        );
                        assert_eq!(ui.store.borrow().theme.selection, original_theme.selection);
                        ui.execute_system_tool(Operation::Wallpaper(root.join("wallpaper.png")));
                    }
                    7 => {
                        if ui.booster_busy.get() {
                            return glib::ControlFlow::Continue;
                        }
                        assert_eq!(
                            ui.store.borrow().last_wallpaper.as_ref(),
                            Some(&root.join("wallpaper.png"))
                        );
                        let menu = gtk::Box::new(gtk::Orientation::Vertical, 0);
                        let popup = gtk::Popover::new();
                        let selected = item(
                            "test-file",
                            "File",
                            "",
                            "",
                            "",
                            Action::Open(gio::File::for_path(&source).uri().into()),
                        );
                        ui.file_actions(&menu, &popup, &selected);
                        for label in [
                            "Encrypt file",
                            "Decrypt file",
                            "Checksum file · SHA-256",
                            "Shred file permanently",
                        ] {
                            assert!(
                                test_widget(menu.upcast_ref(), &|w| w
                                    .downcast_ref::<gtk::Button>()
                                    .is_some_and(|b| b.label().as_deref() == Some(label)))
                                .is_some(),
                                "Missing {label}"
                            );
                        }
                        let provider = secret_provider(Secret(b"fixture-password".to_vec()));
                        assert!(
                            provider
                                .formats()
                                .contain_mime_type("x-kde-passwordManagerHint")
                        );
                        assert!(
                            provider
                                .formats()
                                .contain_mime_type("text/plain;charset=utf-8")
                        );
                        ui.save();
                        let saved =
                            std::fs::read_to_string(core::data_dir().join("data.json")).unwrap();
                        for private in [
                            "GitHub $(literal)",
                            "must-not-persist",
                            "fixture-password",
                            "test-one",
                            "test-two",
                        ] {
                            assert!(!saved.contains(private), "Private text persisted");
                        }
                        done.set(true);
                        ui.window.application().unwrap().quit();
                        return glib::ControlFlow::Break;
                    }
                    _ => unreachable!(),
                }
                phase += 1;
                glib::ControlFlow::Continue
            });
        });
        app.run_with_args(&["systemtools-test"]);
        assert!(done.get());
    }
}

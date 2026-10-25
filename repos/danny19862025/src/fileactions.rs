use crate::{Action, Item, Ui};
use gtk::{gdk, gio, glib, prelude::*};
use std::{
    path::{Path, PathBuf},
    process::{Command, Stdio},
    rc::Rc,
    sync::mpsc,
    time::Duration,
};

#[derive(Clone, Copy, Debug, PartialEq)]
pub enum FileAction {
    Reveal,
    CopyPath,
    Trash,
    CopyFile,
    OpenWith,
    Info,
}
pub fn path(item: &Item) -> Option<PathBuf> {
    if let Action::Open(uri) = &item.action {
        let file = gio::File::for_uri(uri);
        file.path()
    } else {
        None
    }
}
pub fn info(path: &Path) -> Result<String, String> {
    let file = gio::File::for_path(path);
    let info = file
        .query_info(
            "standard::*,time::modified,access::can-read,access::can-write",
            gio::FileQueryInfoFlags::NOFOLLOW_SYMLINKS,
            None::<&gio::Cancellable>,
        )
        .map_err(|e| e.to_string())?;
    let content = info.content_type().unwrap_or_default();
    let mime = gio::content_type_get_mime_type(&content).unwrap_or(content);
    let modified = glib::DateTime::from_unix_local(info.attribute_uint64("time::modified") as i64)
        .ok()
        .and_then(|d| d.format("%Y-%m-%d %H:%M:%S %Z").ok())
        .unwrap_or_default();
    Ok(format!(
        "Name: {}\nPath: {}\nType: {:?}\nMIME: {mime}\nSize: {} bytes{}\nModified: {modified}\nReadable: {}\nWritable: {}",
        info.display_name(),
        path.display(),
        info.file_type(),
        info.size(),
        if info.file_type() == gio::FileType::Directory {
            " (directory entry; contents are not summed)"
        } else {
            ""
        },
        info.boolean("access::can-read"),
        info.boolean("access::can-write")
    ))
}
pub fn reveal(path: &Path) -> Result<(), String> {
    match Command::new("dolphin")
        .arg("--select")
        .arg(path)
        .stdin(Stdio::null())
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .spawn()
    {
        Ok(mut child) => {
            std::thread::spawn(move || {
                let _ = child.wait();
            });
            Ok(())
        }
        Err(_) => {
            let bus = gio::bus_get_sync(gio::BusType::Session, None::<&gio::Cancellable>)
                .map_err(|e| e.to_string())?;
            bus.call_sync(
                Some("org.freedesktop.FileManager1"),
                "/org/freedesktop/FileManager1",
                "org.freedesktop.FileManager1",
                "ShowItems",
                Some(&(vec![gio::File::for_path(path).uri().to_string()], "").to_variant()),
                None,
                gio::DBusCallFlags::NONE,
                3000,
                None::<&gio::Cancellable>,
            )
            .map_err(|e| e.to_string())?;
            Ok(())
        }
    }
}
pub fn copy_provider(path: &Path) -> gdk::ContentProvider {
    let uri = gio::File::for_path(path).uri();
    gdk::ContentProvider::new_union(&[
        gdk::ContentProvider::for_bytes(
            "text/uri-list",
            &glib::Bytes::from_owned(format!("{uri}\r\n").into_bytes()),
        ),
        gdk::ContentProvider::for_bytes(
            "x-special/gnome-copied-files",
            &glib::Bytes::from_owned(format!("copy\n{uri}\n").into_bytes()),
        ),
        gdk::ContentProvider::for_bytes(
            "application/x-kde-cutselection",
            &glib::Bytes::from_static(b"0"),
        ),
    ])
}
impl Ui {
    pub(super) fn confirm(
        self: &Rc<Self>,
        title: &str,
        detail: &str,
        accept_label: &str,
        accept: impl Fn() + 'static,
    ) {
        let dialog = gtk::Window::builder()
            .title(title)
            .transient_for(&self.window)
            .modal(true)
            .destroy_with_parent(true)
            .default_width(480)
            .build();
        dialog.set_widget_name("action-confirmation");
        let panel = gtk::Box::new(gtk::Orientation::Vertical, 16);
        panel.add_css_class("editor");
        let heading = gtk::Label::new(Some(title));
        heading.add_css_class("item-title");
        heading.set_wrap(true);
        panel.append(&heading);
        let text = gtk::Label::new(Some(detail));
        text.set_wrap(true);
        text.set_xalign(0.);
        text.set_selectable(true);
        panel.append(&text);
        let row = gtk::Box::new(gtk::Orientation::Horizontal, 8);
        row.set_halign(gtk::Align::End);
        let cancel = gtk::Button::with_label("Cancel");
        cancel.set_widget_name("confirmation-cancel");
        let yes = gtk::Button::with_label(accept_label);
        yes.set_widget_name("confirmation-accept");
        yes.add_css_class("accent");
        row.append(&cancel);
        row.append(&yes);
        panel.append(&row);
        dialog.set_child(Some(&panel));
        let weak = dialog.downgrade();
        cancel.connect_clicked(move |_| {
            if let Some(d) = weak.upgrade() {
                d.close();
            }
        });
        let weak = dialog.downgrade();
        yes.connect_clicked(move |button| {
            button.set_sensitive(false);
            if let Some(d) = weak.upgrade() {
                d.close();
            }
            accept();
        });
        let keys = gtk::EventControllerKey::new();
        let weak = dialog.downgrade();
        keys.connect_key_pressed(move |_, key, _, _| {
            if key == gdk::Key::Escape {
                if let Some(d) = weak.upgrade() {
                    d.close();
                }
                glib::Propagation::Stop
            } else {
                glib::Propagation::Proceed
            }
        });
        dialog.add_controller(keys);
        dialog.present();
        cancel.grab_focus();
    }
    pub(super) fn file_actions(
        self: &Rc<Self>,
        menu: &gtk::Box,
        popup: &gtk::Popover,
        selected: &Item,
    ) {
        let Some(path) = path(selected) else {
            return;
        };
        for (name, action) in [
            ("Reveal in Dolphin", FileAction::Reveal),
            ("Copy Path", FileAction::CopyPath),
            ("Move to Trash", FileAction::Trash),
            ("Copy File", FileAction::CopyFile),
            ("Open With…", FileAction::OpenWith),
            ("Get Info", FileAction::Info),
        ] {
            let button = gtk::Button::with_label(name);
            let target = path.clone();
            let ui = self.clone();
            let pop = popup.clone();
            button.connect_clicked(move |_| {
                pop.popdown();
                ui.file_action(action, target.clone());
            });
            menu.append(&button);
        }
        if path.is_file() {
            for tool in [
                crate::systemtools::FileTool::Encrypt,
                crate::systemtools::FileTool::Decrypt,
                crate::systemtools::FileTool::Checksum,
                crate::systemtools::FileTool::Shred,
            ] {
                let button = gtk::Button::with_label(tool.title());
                let target = path.clone();
                let ui = self.clone();
                let pop = popup.clone();
                button.connect_clicked(move |_| {
                    pop.popdown();
                    ui.execute_system_tool(crate::systemtools::Operation::File(
                        tool,
                        target.clone(),
                    ));
                });
                menu.append(&button);
            }
        }
        if crate::search::image_path(&path) {
            for tool in [
                crate::localtools::Tool::Compress,
                crate::localtools::Tool::Resize,
                crate::localtools::Tool::Webp,
                crate::localtools::Tool::Palette,
            ] {
                let button = gtk::Button::with_label(tool.title());
                let ui = self.clone();
                let target = path.clone();
                let pop = popup.clone();
                button.connect_clicked(move |_| {
                    pop.popdown();
                    ui.execute_local(crate::localtools::Operation::File(tool, target.clone()));
                });
                menu.append(&button);
            }
        } else if path
            .extension()
            .is_some_and(|e| e.eq_ignore_ascii_case("pdf"))
        {
            let button = gtk::Button::with_label("Extract PDF text");
            let ui = self.clone();
            let pop = popup.clone();
            button.connect_clicked(move |_| {
                pop.popdown();
                ui.execute_local(crate::localtools::Operation::File(
                    crate::localtools::Tool::Pdf,
                    path.clone(),
                ));
            });
            menu.append(&button);
        }
        menu.append(&gtk::Separator::new(gtk::Orientation::Horizontal));
    }
    pub(super) fn file_action(self: &Rc<Self>, action: FileAction, path: PathBuf) {
        if action == FileAction::Trash {
            let ui = self.clone();
            let target = path.clone();
            self.confirm(
                "Move to Trash?",
                &format!(
                    "Move {} to the desktop Trash? You can restore it from your file manager.",
                    path.display()
                ),
                "Move to Trash",
                move || ui.file_action_now(FileAction::Trash, target.clone()),
            );
        } else {
            self.file_action_now(action, path);
        }
    }
    pub(super) fn file_action_now(self: &Rc<Self>, action: FileAction, path: PathBuf) {
        if std::fs::symlink_metadata(&path).is_err() {
            self.error("That file no longer exists · refresh the search");
            return;
        }
        match action {
            FileAction::CopyPath => {
                self.window.clipboard().set_text(&path.to_string_lossy());
                self.error("Path copied");
                return;
            }
            FileAction::CopyFile => {
                match self
                    .window
                    .clipboard()
                    .set_content(Some(&copy_provider(&path)))
                {
                    Ok(()) => self.error("File copied · paste into your file manager"),
                    Err(e) => self.error(&e.to_string()),
                }
                return;
            }
            FileAction::OpenWith => {
                self.open_with(path);
                return;
            }
            _ => {}
        }
        self.error("Working…");
        let (tx, rx) = mpsc::channel();
        let target = path.clone();
        std::thread::spawn(move || {
            let result = match action {
                FileAction::Reveal => {
                    reveal(&target).map(|_| "Revealed in the file manager".to_string())
                }
                FileAction::Trash => gio::File::for_path(&target)
                    .trash(None::<&gio::Cancellable>)
                    .map(|_| "Moved to Trash".to_string())
                    .map_err(|e| e.to_string()),
                FileAction::Info => info(&target),
                _ => unreachable!(),
            };
            let _ = tx.send(result);
        });
        let weak = Rc::downgrade(self);
        glib::timeout_add_local(Duration::from_millis(60), move || {
            let Some(ui) = weak.upgrade() else {
                return glib::ControlFlow::Break;
            };
            match rx.try_recv() {
                Ok(Ok(message)) => {
                    if action == FileAction::Info {
                        ui.error("");
                        ui.text_preview("File information", &message, None);
                    } else {
                        if action == FileAction::Trash {
                            ui.files.borrow_mut().retain(|p| !p.starts_with(&path));
                            ui.recents
                                .borrow_mut()
                                .retain(|(p, _)| !p.starts_with(&path));
                            ui.booster_cache.borrow_mut().clear();
                            ui.refresh();
                        }
                        ui.error(&message);
                    }
                    glib::ControlFlow::Break
                }
                Ok(Err(e)) => {
                    ui.error(&e);
                    glib::ControlFlow::Break
                }
                Err(mpsc::TryRecvError::Empty) => glib::ControlFlow::Continue,
                Err(_) => {
                    ui.error("File action interrupted");
                    glib::ControlFlow::Break
                }
            }
        });
    }
    #[allow(deprecated)]
    fn open_with(self: &Rc<Self>, path: PathBuf) {
        let file = gio::File::for_path(path);
        let dialog = gtk::AppChooserDialog::new(Some(&self.window), gtk::DialogFlags::MODAL, &file);
        dialog.set_title(Some("Open With"));
        let weak = Rc::downgrade(self);
        dialog.connect_response(move |dialog, response| {
            if response == gtk::ResponseType::Ok
                && let Some(app) = dialog.app_info()
                && let Err(e) =
                    app.launch(std::slice::from_ref(&file), None::<&gio::AppLaunchContext>)
                && let Some(ui) = weak.upgrade()
            {
                ui.error(&e.to_string());
            }
            dialog.close();
        });
        dialog.present();
    }
}

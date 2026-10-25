use crate::{
    Ui,
    devkit::{self, Operation, Request},
    dotfiles,
};
use gtk::{gio, glib, prelude::*};
use std::{
    rc::Rc,
    sync::{atomic::Ordering, mpsc},
    time::Duration,
};
impl Ui {
    pub(super) fn execute_kit(self: &Rc<Self>, op: Operation) {
        match op {
            Operation::Http(method, url) => self.http_scratch(&method, &url),
            Operation::Logs { engine, id, name } => self.container_logs(&engine, &id, &name),
            Operation::Exec {
                engine,
                id,
                command,
            } => match devkit::exec_container(&engine, &id, &command) {
                Ok(()) => self.window.set_visible(false),
                Err(e) => self.error(&e),
            },
            Operation::EnvDiff { left, right, key } => {
                match devkit::env_compare(&left, &right, &key) {
                    Ok(text) => self.text_preview("Environment comparison", &text, None),
                    Err(e) => self.error(&e),
                }
            }
        }
    }
    fn http_scratch(self: &Rc<Self>, method: &str, url: &str) {
        let dialog = gtk::Window::builder()
            .application(&self.window.application().unwrap())
            .title("HTTP Scratch")
            .transient_for(&self.window)
            .modal(true)
            .default_width(760)
            .default_height(680)
            .build();
        let panel = gtk::Box::new(gtk::Orientation::Vertical, 10);
        panel.add_css_class("editor");
        let methods = ["GET", "POST", "PUT", "PATCH", "DELETE", "HEAD", "OPTIONS"];
        let select = gtk::DropDown::from_strings(&methods);
        select.set_selected(methods.iter().position(|m| *m == method).unwrap_or(0) as u32);
        let address = gtk::Entry::builder()
            .placeholder_text("https://api.github.com/user")
            .hexpand(true)
            .build();
        address.set_text(url);
        let row = gtk::Box::new(gtk::Orientation::Horizontal, 8);
        row.append(&select);
        row.append(&address);
        panel.append(&row);
        panel.append(&gtk::Label::new(Some(
            "Headers · one Header: value per line",
        )));
        let headers = gtk::TextView::new();
        headers.set_monospace(true);
        headers.set_widget_name("http-headers");
        let scroll = gtk::ScrolledWindow::builder()
            .child(&headers)
            .min_content_height(70)
            .build();
        panel.append(&scroll);
        panel.append(&gtk::Label::new(Some("Request body")));
        let body = gtk::TextView::new();
        body.set_monospace(true);
        body.set_widget_name("http-body");
        panel.append(
            &gtk::ScrolledWindow::builder()
                .child(&body)
                .min_content_height(90)
                .build(),
        );
        let status = gtk::Label::new(Some(
            "Requests run when you press Send. Headers and bodies stay in this window.",
        ));
        status.set_wrap(true);
        status.set_xalign(0.);
        panel.append(&status);
        let response = gtk::TextView::new();
        response.set_editable(false);
        response.set_monospace(true);
        response.set_wrap_mode(gtk::WrapMode::WordChar);
        response.set_widget_name("http-response");
        panel.append(
            &gtk::ScrolledWindow::builder()
                .child(&response)
                .vexpand(true)
                .min_content_height(200)
                .build(),
        );
        let buttons = gtk::Box::new(gtk::Orientation::Horizontal, 8);
        let send = gtk::Button::with_label("Send");
        send.add_css_class("accent");
        let copy = gtk::Button::with_label("Copy Response");
        let close = gtk::Button::with_label("Close");
        buttons.append(&send);
        buttons.append(&copy);
        buttons.append(&close);
        panel.append(&buttons);
        let buffer = response.buffer();
        let clipboard = self.window.clipboard();
        copy.connect_clicked(move |_| {
            clipboard.set_text(&buffer.text(&buffer.start_iter(), &buffer.end_iter(), false))
        });
        let weak = dialog.downgrade();
        close.connect_clicked(move |_| {
            if let Some(d) = weak.upgrade() {
                d.close();
            }
        });
        let weak = dialog.downgrade();
        send.connect_clicked(move |button| {
            let text = |view: &gtk::TextView| {
                let b = view.buffer();
                b.text(&b.start_iter(), &b.end_iter(), false).to_string()
            };
            let req = Request {
                method: methods[select.selected() as usize].into(),
                url: address.text().to_string(),
                headers: text(&headers),
                body: text(&body),
            };
            button.set_sensitive(false);
            status.set_text("Sending…");
            let (tx, rx) = mpsc::channel();
            std::thread::spawn(move || {
                let _ = tx.send(devkit::request(&req));
            });
            let button = button.clone();
            let status = status.clone();
            let response = response.clone();
            let weak = weak.clone();
            glib::timeout_add_local(Duration::from_millis(60), move || {
                if weak.upgrade().is_none() {
                    return glib::ControlFlow::Break;
                }
                match rx.try_recv() {
                    Ok(result) => {
                        button.set_sensitive(true);
                        match result {
                            Ok(text) => {
                                response.buffer().set_text(&text);
                                status.set_text("Response received");
                            }
                            Err(e) => status.set_text(&e),
                        }
                        glib::ControlFlow::Break
                    }
                    Err(mpsc::TryRecvError::Empty) => glib::ControlFlow::Continue,
                    Err(_) => {
                        button.set_sensitive(true);
                        status.set_text("Request interrupted");
                        glib::ControlFlow::Break
                    }
                }
            });
        });
        dialog.set_child(Some(&panel));
        dialog.present();
    }
    fn container_logs(self: &Rc<Self>, engine: &str, id: &str, name: &str) {
        let tail = match devkit::tail(engine, id) {
            Ok(t) => t,
            Err(e) => {
                self.error(&e);
                return;
            }
        };
        let dialog = gtk::Window::builder()
            .application(&self.window.application().unwrap())
            .title(format!("Container Logs · {name}"))
            .transient_for(&self.window)
            .default_width(860)
            .default_height(540)
            .build();
        let panel = gtk::Box::new(gtk::Orientation::Vertical, 10);
        panel.add_css_class("editor");
        let text = gtk::TextView::new();
        text.set_editable(false);
        text.set_monospace(true);
        text.set_wrap_mode(gtk::WrapMode::WordChar);
        text.set_widget_name("container-log-text");
        panel.append(
            &gtk::ScrolledWindow::builder()
                .child(&text)
                .vexpand(true)
                .build(),
        );
        let buttons = gtk::Box::new(gtk::Orientation::Horizontal, 8);
        let stop = gtk::Button::with_label("Stop Tail");
        let copy = gtk::Button::with_label("Copy Logs");
        let close = gtk::Button::with_label("Close");
        buttons.append(&stop);
        buttons.append(&copy);
        buttons.append(&close);
        panel.append(&buttons);
        let cancel = tail.cancel.clone();
        stop.connect_clicked(move |b| {
            cancel.store(true, Ordering::Relaxed);
            b.set_sensitive(false);
        });
        let buffer = text.buffer();
        let clipboard = self.window.clipboard();
        copy.connect_clicked(move |_| {
            clipboard.set_text(&buffer.text(&buffer.start_iter(), &buffer.end_iter(), false))
        });
        let weak = dialog.downgrade();
        close.connect_clicked(move |_| {
            if let Some(d) = weak.upgrade() {
                d.close();
            }
        });
        let cancel = tail.cancel.clone();
        dialog.connect_close_request(move |_| {
            cancel.store(true, Ordering::Relaxed);
            glib::Propagation::Proceed
        });
        let weak = dialog.downgrade();
        let mut content = String::new();
        glib::timeout_add_local(Duration::from_millis(80), move || {
            let Some(window) = weak.upgrade() else {
                return glib::ControlFlow::Break;
            };
            if !window.is_visible() {
                return glib::ControlFlow::Break;
            }
            let mut changed = false;
            for _ in 0..64 {
                match tail.receiver.try_recv() {
                    Ok(line) => {
                        content.push_str(&line);
                        changed = true;
                    }
                    Err(mpsc::TryRecvError::Empty) => break,
                    Err(_) => {
                        stop.set_sensitive(false);
                        break;
                    }
                }
            }
            if changed {
                if content.len() > 1_048_576 {
                    let mut split = content.len() - 1_048_576;
                    while !content.is_char_boundary(split) {
                        split += 1;
                    }
                    content.drain(..split);
                }
                text.buffer().set_text(&content);
                let mut end = text.buffer().end_iter();
                text.scroll_to_iter(&mut end, 0., false, 0., 1.);
            }
            glib::ControlFlow::Continue
        });
        dialog.set_child(Some(&panel));
        dialog.present();
    }
    pub(super) fn dotfiles_panel(self: &Rc<Self>) -> gtk::Box {
        let panel = gtk::Box::new(gtk::Orientation::Vertical, 8);
        panel.set_widget_name("dotfiles-sync");
        panel.append(&gtk::Label::new(Some("Dotfiles sync")));
        let info = gtk::Label::new(Some(
            "Export snippets, saved notes, quick notes and quicklinks to spotlight/export.json in an existing Git clone. Export commits locally. Sync verifies a private GitHub origin before pushing.",
        ));
        info.set_wrap(true);
        info.set_xalign(0.);
        panel.append(&info);
        let path = gtk::Entry::builder()
            .placeholder_text("Private dotfiles repository folder")
            .build();
        path.set_widget_name("dotfiles-repo");
        if let Some(p) = &self.store.borrow().dotfiles_repo {
            path.set_text(&p.to_string_lossy());
        }
        panel.append(&path);
        let buttons = gtk::Box::new(gtk::Orientation::Horizontal, 8);
        let choose = gtk::Button::with_label("Choose repo");
        let export = gtk::Button::with_label("Export and commit");
        let sync = gtk::Button::with_label("Sync private repo");
        buttons.append(&choose);
        buttons.append(&export);
        buttons.append(&sync);
        panel.append(&buttons);
        let status = gtk::Label::new(None);
        status.set_wrap(true);
        status.set_xalign(0.);
        panel.append(&status);
        let entry = path.clone();
        let parent = self.window.clone();
        choose.connect_clicked(move |_| {
            let entry = entry.clone();
            gtk::FileDialog::builder()
                .title("Choose dotfiles Git repository")
                .build()
                .select_folder(Some(&parent), None::<&gio::Cancellable>, move |result| {
                    if let Ok(file) = result
                        && let Some(p) = file.path()
                    {
                        entry.set_text(&p.to_string_lossy());
                    }
                });
        });
        for (button, push) in [(&export, false), (&sync, true)] {
            let ui = self.clone();
            let path = path.clone();
            let status = status.clone();
            let export = export.clone();
            let sync = sync.clone();
            button.connect_clicked(move |_| {
                if !ui.can_save {
                    status.set_text("Saved data is unreadable; export is disabled");
                    return;
                }
                let path = dotfiles::expand_path(&path.text());
                if !path.is_dir() {
                    status.set_text("Choose an existing Git clone folder");
                    return;
                }
                let old = ui.store.borrow().dotfiles_repo.clone();
                ui.store.borrow_mut().dotfiles_repo = Some(path.clone());
                let saved = ui.store.borrow().save();
                if let Err(e) = saved {
                    ui.store.borrow_mut().dotfiles_repo = old;
                    status.set_text(&e);
                    return;
                }
                status.set_text(if push {
                    "Exporting and syncing…"
                } else {
                    "Exporting locally…"
                });
                export.set_sensitive(false);
                sync.set_sensitive(false);
                let (tx, rx) = mpsc::channel();
                std::thread::spawn(move || {
                    let result =
                        crate::core::Store::load().and_then(|s| dotfiles::export(&path, push, &s));
                    let _ = tx.send(result);
                });
                let status = status.clone();
                let export = export.clone();
                let sync = sync.clone();
                glib::timeout_add_local(Duration::from_millis(80), move || match rx.try_recv() {
                    Ok(result) => {
                        export.set_sensitive(true);
                        sync.set_sensitive(true);
                        status.set_text(&result.unwrap_or_else(|e| e));
                        glib::ControlFlow::Break
                    }
                    Err(mpsc::TryRecvError::Empty) => glib::ControlFlow::Continue,
                    Err(_) => {
                        export.set_sensitive(true);
                        sync.set_sensitive(true);
                        status.set_text("Export interrupted");
                        glib::ControlFlow::Break
                    }
                });
            });
        }
        panel
    }
}

#[cfg(test)]
mod tests {
    use crate::*;
    use std::{cell::Cell, fs};
    fn window(title: &str) -> gtk::Window {
        gtk::Window::list_toplevels()
            .into_iter()
            .filter_map(|w| w.downcast::<gtk::Window>().ok())
            .find(|w| w.is_visible() && w.title().as_deref() == Some(title))
            .unwrap_or_else(|| panic!("Missing window {title}"))
    }
    fn button(w: &gtk::Window, label: &str) -> gtk::Button {
        test_widget(w.upcast_ref(), &|w| {
            w.clone()
                .downcast::<gtk::Button>()
                .is_ok_and(|b| b.label().as_deref() == Some(label))
        })
        .unwrap_or_else(|| panic!("Missing {label}"))
        .downcast()
        .unwrap()
    }
    #[test]
    #[ignore = "requires isolated CLI/HTTP/desktop fixtures; run tests/devkit_smoke.py"]
    fn native_ui() {
        let root = PathBuf::from(std::env::var_os("SPOTLIGHT_KIT_ROOT").unwrap());
        assert!(core::data_dir().starts_with(&root));
        let app = gtk::Application::builder()
            .application_id("local.spotlight.Devkit.Test")
            .build();
        let done = Rc::new(Cell::new(false));
        let completed = done.clone();
        app.connect_activate(move |app| {
            let ui = build_with_mode(app, true);
            let done = done.clone();
            let root = root.clone();
            ui.settings();
            let settings = window("Spotlight Settings");
            assert!(button(&settings, "Export and commit").is_visible());
            assert!(button(&settings, "Sync private repo").is_visible());
            settings.close();
            ui.execute_kit(devkit::Operation::Http(
                "GET".into(),
                std::env::var("SPOTLIGHT_KIT_URL").unwrap(),
            ));
            let http = window("HTTP Scratch");
            button(&http, "Send").emit_clicked();
            let mut phase = 0;
            let started = std::time::Instant::now();
            let mut pid = 0u32;
            glib::timeout_add_local(Duration::from_millis(100), move || {
                assert!(
                    started.elapsed() < Duration::from_secs(20),
                    "Phase {phase} timed out"
                );
                match phase {
                    0 => {
                        let response =
                            test_widget(http.upcast_ref(), &|w| w.widget_name() == "http-response")
                                .unwrap()
                                .downcast::<gtk::TextView>()
                                .unwrap()
                                .buffer();
                        if !response
                            .text(&response.start_iter(), &response.end_iter(), false)
                            .contains("spotlight-fixture")
                        {
                            return glib::ControlFlow::Continue;
                        }
                        assert!(
                            response
                                .text(&response.start_iter(), &response.end_iter(), false)
                                .contains("200")
                        );
                        button(&http, "Close").emit_clicked();
                        ui.execute_kit(devkit::Operation::Logs {
                            engine: "docker".into(),
                            id: "a".repeat(64),
                            name: "nginx".into(),
                        });
                    }
                    1 => {
                        let logs = window("Container Logs · nginx");
                        let text = test_widget(logs.upcast_ref(), &|w| {
                            w.widget_name() == "container-log-text"
                        })
                        .unwrap()
                        .downcast::<gtk::TextView>()
                        .unwrap()
                        .buffer();
                        if !text
                            .text(&text.start_iter(), &text.end_iter(), false)
                            .contains("nginx fixture ready")
                        {
                            return glib::ControlFlow::Continue;
                        }
                        pid = fs::read_to_string(root.join("tail-pid"))
                            .unwrap()
                            .parse()
                            .unwrap();
                        button(&logs, "Close").emit_clicked();
                    }
                    _ => {
                        if PathBuf::from(format!("/proc/{pid}")).exists() {
                            return glib::ControlFlow::Continue;
                        }
                        assert!(
                            !core::Store::load()
                                .unwrap()
                                .usage
                                .keys()
                                .any(|k| k.contains("/user"))
                        );
                        done.set(true);
                        ui.window.application().unwrap().quit();
                        return glib::ControlFlow::Break;
                    }
                }
                phase += 1;
                glib::ControlFlow::Continue
            });
        });
        app.run_with_args::<&str>(&[]);
        assert!(completed.get());
    }
}

use crate::{Ui, core, localai};
use gtk::{gdk, glib, prelude::*};
use std::{
    cell::{Cell, RefCell},
    fs,
    io::Read,
    os::unix::fs::OpenOptionsExt,
    path::Path,
    rc::Rc,
    sync::{
        Arc,
        atomic::{AtomicBool, Ordering},
        mpsc,
    },
    time::Duration,
};

#[derive(Clone, Copy)]
pub struct Sources {
    pub project: bool,
    pub windows: bool,
    pub todos: bool,
}
fn bounded(text: &str, limit: usize) -> &str {
    let mut n = text.len().min(limit);
    while !text.is_char_boundary(n) {
        n -= 1;
    }
    &text[..n]
}
fn read(path: &Path, limit: usize) -> Result<String, String> {
    let file = fs::OpenOptions::new()
        .read(true)
        .custom_flags(libc::O_NOFOLLOW | libc::O_NONBLOCK)
        .open(path)
        .map_err(|_| "Context file could not be read")?;
    if !file.metadata().is_ok_and(|m| m.is_file()) {
        return Err("Context source is not a regular file".into());
    }
    let mut bytes = Vec::new();
    file.take(limit as u64)
        .read_to_end(&mut bytes)
        .map_err(|_| "Context source could not be read")?;
    Ok(String::from_utf8_lossy(&bytes).into_owned())
}
pub fn gather(project: Option<&Path>, sources: Sources) -> Result<String, String> {
    let mut sections = Vec::new();
    if sources.project {
        if let Some(root) = project {
            if fs::symlink_metadata(root)
                .map_err(|_| "Selected project is unavailable")?
                .file_type()
                .is_symlink()
                || !root.is_dir()
            {
                return Err("Select a regular project directory with the project command".into());
            }
            let mut names = Vec::new();
            let mut content = Vec::new();
            let rules = crate::fileignore::Rules::load(&core::home())?;
            for entry in ignore::WalkBuilder::new(root)
                .max_depth(Some(3))
                .follow_links(false)
                .hidden(true)
                .require_git(false)
                .filter_entry(|entry| {
                    entry.depth() == 0
                        || !entry.file_type().is_some_and(|t| t.is_dir())
                        || !["target", "build", "dist", "node_modules", "vendor"]
                            .iter()
                            .any(|name| entry.file_name() == *name)
                })
                .build()
                .flatten()
                .take(1000)
            {
                let path = entry.path();
                if !entry.file_type().is_some_and(|t| t.is_file()) || rules.excludes(path, false) {
                    continue;
                }
                let Ok(relative) = path.strip_prefix(root) else {
                    continue;
                };
                if relative.components().any(|c| {
                    ["target", "build", "dist", "node_modules", "vendor"]
                        .iter()
                        .any(|p| c.as_os_str() == *p)
                }) {
                    continue;
                }
                if names.len() < 100 {
                    names.push(relative.display().to_string());
                }
                if path.parent() == Some(root)
                    && [
                        "README.md",
                        "README.rst",
                        "README.txt",
                        "Cargo.toml",
                        "package.json",
                        "pyproject.toml",
                    ]
                    .iter()
                    .any(|name| path.file_name().is_some_and(|n| n == *name))
                    && content.len() < 4
                    && let Ok(text) = read(path, 4096)
                {
                    content.push(format!(
                        "--- {} (up to 4 KiB) ---\n{text}",
                        relative.display()
                    ));
                }
            }
            sections.push(format!("PROJECT: {}\nFiles (up to 100, depth 3; ignored, hidden and generated paths omitted):\n{}\n{}", root.display(), names.join("\n"), content.join("\n")));
        } else {
            sections.push(
                "PROJECT: No project selected. Use project ~/Projects/name in Spotlight.".into(),
            );
        }
    }
    if sources.windows {
        match crate::windowing::list() {
            Ok(windows) => sections.push(format!(
                "OPEN WINDOWS (up to 30):\n{}",
                windows
                    .into_iter()
                    .take(30)
                    .map(|w| format!(
                        "{} | {}{}",
                        bounded(&w.app, 100),
                        bounded(&w.title, 200),
                        if w.active { " [active]" } else { "" }
                    ))
                    .collect::<Vec<_>>()
                    .join("\n")
            )),
            Err(_) => sections.push("OPEN WINDOWS: Unavailable · KDE KWin is required.".into()),
        }
    }
    if sources.todos {
        let mut paths = vec![core::data_dir().join("todos.md")];
        if let Some(root) = project {
            paths.push(root.join("todos.md"));
        }
        for path in paths {
            if path.exists() {
                match read(&path, 8192) {
                    Ok(text) => {
                        sections.push(format!("TODOS: {} (up to 8 KiB)\n{text}", path.display()))
                    }
                    Err(_) => sections.push("TODOS: Source unavailable".into()),
                }
            }
        }
    }
    if sections.is_empty() {
        sections.push("No context sources selected.".into());
    }
    Ok(bounded(&sections.join("\n\n"), 48000).to_string())
}
impl Ui {
    pub(super) fn context_ai(self: &Rc<Self>, initial: &str) {
        let dialog = gtk::Window::builder()
            .title("Local AI · Project Context")
            .transient_for(&self.window)
            .modal(true)
            .destroy_with_parent(true)
            .default_width(780)
            .default_height(680)
            .build();
        dialog.set_widget_name("context-ai");
        let panel = gtk::Box::new(gtk::Orientation::Vertical, 10);
        panel.add_css_class("editor");
        let options = gtk::Box::new(gtk::Orientation::Horizontal, 12);
        let project = gtk::CheckButton::with_label("Selected project");
        project.set_active(true);
        project.set_widget_name("ai-source-project");
        let windows = gtk::CheckButton::with_label("Open window titles");
        windows.set_active(true);
        windows.set_widget_name("ai-source-windows");
        let todos = gtk::CheckButton::with_label("todos.md");
        todos.set_active(true);
        todos.set_widget_name("ai-source-todos");
        for button in [&project, &windows, &todos] {
            options.append(button);
        }
        panel.append(&options);
        let context = gtk::TextView::new();
        context.set_editable(false);
        context.set_monospace(true);
        context.set_wrap_mode(gtk::WrapMode::WordChar);
        context.set_widget_name("ai-context-preview");
        let expander = gtk::Expander::builder()
            .label("Review context sent to local Ollama")
            .expanded(true)
            .build();
        expander.set_child(Some(
            &gtk::ScrolledWindow::builder()
                .child(&context)
                .min_content_height(145)
                .max_content_height(200)
                .build(),
        ));
        panel.append(&expander);
        let refresh = gtk::Button::with_label("Refresh context");
        refresh.set_widget_name("ai-context-refresh");
        panel.append(&refresh);
        let question = gtk::Entry::builder()
            .placeholder_text("Ask about this project, your windows, or todos…")
            .max_length(4096)
            .activates_default(true)
            .build();
        question.set_text(initial);
        question.set_widget_name("ai-question");
        panel.append(&question);
        let output = gtk::TextView::new();
        output.set_editable(false);
        output.set_wrap_mode(gtk::WrapMode::WordChar);
        output.set_widget_name("ai-context-answer");
        panel.append(
            &gtk::ScrolledWindow::builder()
                .child(&output)
                .vexpand(true)
                .min_content_height(160)
                .build(),
        );
        let status = gtk::Label::new(Some("Gathering local context…"));
        status.set_wrap(true);
        status.set_xalign(0.);
        panel.append(&status);
        let row = gtk::Box::new(gtk::Orientation::Horizontal, 8);
        let send = gtk::Button::with_label("Send locally");
        send.add_css_class("accent");
        send.set_sensitive(false);
        send.set_widget_name("ai-context-send");
        let copy = gtk::Button::with_label("Copy answer");
        copy.set_sensitive(false);
        let note = gtk::Button::with_label("Save answer as note");
        note.set_sensitive(false);
        note.set_widget_name("ai-context-save-note");
        let close = gtk::Button::with_label("Close");
        for b in [&send, &copy, &note, &close] {
            row.append(b);
        }
        panel.append(&row);
        dialog.set_child(Some(&panel));
        dialog.set_default_widget(Some(&send));
        let cancel = Arc::new(AtomicBool::new(false));
        let flag = cancel.clone();
        dialog.connect_close_request(move |_| {
            flag.store(true, Ordering::Relaxed);
            glib::Propagation::Proceed
        });
        let weak = dialog.downgrade();
        close.connect_clicked(move |_| {
            if let Some(d) = weak.upgrade() {
                d.close();
            }
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
        let snapshot = Rc::new(RefCell::new(None::<String>));
        let generation = Rc::new(Cell::new(0u64));
        let project_path = self.store.borrow().project_context.clone();
        let load: Rc<dyn Fn()> = {
            let project = project.clone();
            let windows = windows.clone();
            let todos = todos.clone();
            let send = send.clone();
            let status = status.clone();
            let context = context.clone();
            let snapshot = snapshot.clone();
            let generation = generation.clone();
            let cancel = cancel.clone();
            Rc::new(move || {
                generation.set(generation.get().wrapping_add(1));
                let request = generation.get();
                snapshot.borrow_mut().take();
                send.set_sensitive(false);
                status.set_text("Gathering context · no model request yet…");
                let sources = Sources {
                    project: project.is_active(),
                    windows: windows.is_active(),
                    todos: todos.is_active(),
                };
                let path = project_path.clone();
                let (tx, rx) = mpsc::channel();
                std::thread::spawn(move || {
                    let _ = tx.send(gather(path.as_deref(), sources));
                });
                let snapshot = snapshot.clone();
                let generation = generation.clone();
                let cancel = cancel.clone();
                let send = send.clone();
                let status = status.clone();
                let context = context.clone();
                glib::timeout_add_local(Duration::from_millis(60), move || {
                    if cancel.load(Ordering::Relaxed) || generation.get() != request {
                        return glib::ControlFlow::Break;
                    }
                    match rx.try_recv() {
                        Ok(Ok(text)) => {
                            context.buffer().set_text(&text);
                            *snapshot.borrow_mut() = Some(text);
                            send.set_sensitive(true);
                            status.set_text("Review the exact context above, then Send locally · prompts and answers are not saved");
                            glib::ControlFlow::Break
                        }
                        Ok(Err(e)) => {
                            status.set_text(&e);
                            glib::ControlFlow::Break
                        }
                        Err(mpsc::TryRecvError::Empty) => glib::ControlFlow::Continue,
                        Err(_) => {
                            status.set_text("Context gathering interrupted");
                            glib::ControlFlow::Break
                        }
                    }
                });
            })
        };
        for button in [&project, &windows, &todos] {
            let load = load.clone();
            button.connect_toggled(move |_| load());
        }
        let loader = load.clone();
        refresh.connect_clicked(move |_| loader());
        load();
        let model = self.store.borrow().commands.ollama_model.clone();
        let status_send = status.clone();
        let output_send = output.clone();
        let copy_send = copy.clone();
        let note_send = note.clone();
        send.connect_clicked(move |button| {
            let q = question.text();
            if q.trim().is_empty() {
                status_send.set_text("Enter a question first.");
                return;
            }
            let Some(context) = snapshot.borrow().clone() else {
                return;
            };
            let input = serde_json::json!({"question":q.as_str(),"context":context}).to_string();
            if input.len() > 65536 {
                status_send.set_text("Question and context exceed 64 KiB · deselect a source");
                return;
            }
            button.set_sensitive(false);
            refresh.set_sensitive(false);
            for source in [&project, &windows, &todos] {
                source.set_sensitive(false);
            }
            copy_send.set_sensitive(false);
            note_send.set_sensitive(false);
            status_send.set_text("Answering with verified local Ollama…");
            let (tx, rx) = mpsc::channel();
            let cancel = cancel.clone();
            let worker_flag = cancel.clone();
            let model = model.clone();
            std::thread::spawn(move || {
                let _ = tx.send(localai::request("context", &input, &model, worker_flag));
            });
            let button = button.clone();
            let status = status_send.clone();
            let output = output_send.clone();
            let copy = copy_send.clone();
            let note = note_send.clone();
            let refresh = refresh.clone();
            let sources = [project.clone(), windows.clone(), todos.clone()];
            glib::timeout_add_local(Duration::from_millis(80), move || {
                if cancel.load(Ordering::Relaxed) {
                    return glib::ControlFlow::Break;
                }
                let result = match rx.try_recv() {
                    Ok(r) => r,
                    Err(mpsc::TryRecvError::Empty) => return glib::ControlFlow::Continue,
                    Err(_) => Err("Local AI interrupted".into()),
                };
                button.set_sensitive(true);
                refresh.set_sensitive(true);
                for source in &sources {
                    source.set_sensitive(true);
                }
                match result {
                    Ok(value) => {
                        output
                            .buffer()
                            .set_text(value["text"].as_str().unwrap_or(""));
                        status.set_text(&format!(
                            "{} · answered locally · no actions were executed",
                            value["model"].as_str().unwrap_or("Ollama")
                        ));
                        copy.set_sensitive(true);
                        note.set_sensitive(true);
                    }
                    Err(e) => status.set_text(&e),
                }
                glib::ControlFlow::Break
            });
        });
        let buffer = output.buffer();
        let clipboard = self.window.clipboard();
        copy.connect_clicked(move |_| {
            clipboard.set_text(&buffer.text(&buffer.start_iter(), &buffer.end_iter(), false))
        });
        let ui = self.clone();
        let buffer = output.buffer();
        note.connect_clicked(move |_| {
            let body = buffer.text(&buffer.start_iter(), &buffer.end_iter(), false);
            match ui.capture_note(&body) {
                Ok((_, message)) => ui.error(&message),
                Err(e) => ui.error(&e),
            }
        });
        dialog.present();
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn context_is_bounded_ignored_and_never_follows_secret_links() {
        let root = std::env::temp_dir().join(format!(
            "spotlight-ai-context-{}",
            glib::uuid_string_random()
        ));
        fs::create_dir_all(root.join("src")).unwrap();
        fs::write(root.join("README.md"), "Project summary fixture").unwrap();
        fs::write(
            root.join("src/main.rs"),
            "A source file name is context; its contents are not read",
        )
        .unwrap();
        fs::write(root.join(".env"), "SECRET_ENV_FIXTURE").unwrap();
        fs::write(root.join(".gitignore"), "ignored.txt\n").unwrap();
        fs::write(root.join("ignored.txt"), "PRIVATE_IGNORED_FIXTURE").unwrap();
        std::os::unix::fs::symlink(root.join(".env"), root.join("package.json")).unwrap();
        fs::create_dir(root.join("target")).unwrap();
        fs::write(
            root.join("target/generated.txt"),
            "PRIVATE_GENERATED_FIXTURE",
        )
        .unwrap();
        fs::write(root.join("todos.md"), "- [ ] Project todo fixture").unwrap();
        let context = gather(
            Some(&root),
            Sources {
                project: true,
                windows: false,
                todos: true,
            },
        )
        .unwrap();
        assert!(
            context.contains("Project summary fixture")
                && context.contains("Project todo fixture")
                && context.contains("src/main.rs")
        );
        for secret in [
            "SECRET_ENV_FIXTURE",
            "PRIVATE_IGNORED_FIXTURE",
            "PRIVATE_GENERATED_FIXTURE",
            "source file name is context",
        ] {
            assert!(!context.contains(secret));
        }
        assert!(context.len() <= 48000);
        let blank = gather(
            Some(&root),
            Sources {
                project: false,
                windows: false,
                todos: false,
            },
        )
        .unwrap();
        assert_eq!(blank, "No context sources selected.");
        fs::remove_dir_all(root).unwrap();
    }
}

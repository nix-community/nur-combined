use crate::*;
use std::{
    io::{Read, Write},
    process::Stdio,
    sync::{
        Arc,
        atomic::{AtomicBool, Ordering},
    },
};

pub fn request(
    operation: &str,
    text: &str,
    model: &str,
    cancel: Arc<AtomicBool>,
) -> Result<serde_json::Value, String> {
    if glib::find_program_in_path("ollama").is_none() {
        return Err("Install Ollama and a local text model first · see the Guide".into());
    }
    let port = std::env::var("SPOTLIGHT_OLLAMA_PORT")
        .unwrap_or_else(|_| "11434".into())
        .parse::<u16>()
        .ok()
        .filter(|p| *p > 0)
        .ok_or("Invalid local Ollama port")?;
    if text.len() > 65536 {
        return Err("Clipboard text exceeds 64 KiB".into());
    }
    let input =
        serde_json::to_vec(&serde_json::json!({"operation":operation,"text":text,"model":model}))
            .map_err(|e| e.to_string())?;
    let mut child = Command::new("python3")
        .args(["-c", include_str!("local_ai.py"), &port.to_string()])
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::null())
        .spawn()
        .map_err(|e| e.to_string())?;
    let mut stdin = child.stdin.take().unwrap();
    std::thread::spawn(move || {
        let _ = stdin.write_all(&input);
    });
    let stdout = child.stdout.take().unwrap();
    let (tx, rx) = mpsc::channel();
    std::thread::spawn(move || {
        let mut bytes = Vec::new();
        let result = stdout.take(1_048_577).read_to_end(&mut bytes);
        let _ = tx.send(result.map(|_| bytes));
    });
    let start = std::time::Instant::now();
    loop {
        if cancel.load(Ordering::Relaxed) || start.elapsed() > Duration::from_secs(95) {
            let _ = child.kill();
            let _ = child.wait();
            return Err("Local AI request cancelled or timed out".into());
        }
        match child.try_wait() {
            Ok(Some(status)) => {
                if !status.success() {
                    return Err("Local AI helper failed".into());
                }
                break;
            }
            Ok(None) => std::thread::sleep(Duration::from_millis(60)),
            Err(e) => {
                let _ = child.kill();
                let _ = child.wait();
                return Err(e.to_string());
            }
        }
    }
    let bytes = rx
        .recv_timeout(Duration::from_secs(1))
        .map_err(|_| "Local AI helper did not finish")?
        .map_err(|e| e.to_string())?;
    if bytes.len() > 1_048_576 {
        return Err("Local AI output exceeds 1 MiB".into());
    }
    let value: serde_json::Value =
        serde_json::from_slice(&bytes).map_err(|_| "Invalid local AI response")?;
    if let Some(error) = value["error"].as_str() {
        return Err(error.into());
    }
    Ok(value)
}
impl Ui {
    pub(super) fn summarize_clipboard(self: &Rc<Self>) {
        let dialog = gtk::Window::builder()
            .title("Local AI · Clipboard Summary")
            .transient_for(&self.window)
            .modal(true)
            .default_width(640)
            .default_height(460)
            .build();
        let panel = gtk::Box::new(gtk::Orientation::Vertical, 12);
        panel.add_css_class("editor");
        let status = gtk::Label::new(Some("Reading clipboard text · local Ollama only"));
        status.set_wrap(true);
        status.set_xalign(0.);
        panel.append(&status);
        let text = gtk::TextView::new();
        text.set_editable(false);
        text.set_wrap_mode(gtk::WrapMode::WordChar);
        text.set_widget_name("ai-summary");
        panel.append(
            &gtk::ScrolledWindow::builder()
                .child(&text)
                .vexpand(true)
                .build(),
        );
        let row = gtk::Box::new(gtk::Orientation::Horizontal, 8);
        let copy = gtk::Button::with_label("Copy summary");
        copy.set_sensitive(false);
        let close = gtk::Button::with_label("Close");
        row.append(&copy);
        row.append(&close);
        panel.append(&row);
        dialog.set_child(Some(&panel));
        let cancel = Arc::new(AtomicBool::new(false));
        let cancelled = cancel.clone();
        dialog.connect_close_request(move |_| {
            cancelled.store(true, Ordering::Relaxed);
            glib::Propagation::Proceed
        });
        let weak = dialog.downgrade();
        close.connect_clicked(move |_| {
            if let Some(d) = weak.upgrade() {
                d.close();
            }
        });
        let buffer = text.buffer();
        let clipboard = self.window.clipboard();
        copy.connect_clicked(move |_| {
            clipboard.set_text(&buffer.text(&buffer.start_iter(), &buffer.end_iter(), false))
        });
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
        let model = self.store.borrow().commands.ollama_model.clone();
        let weak = dialog.downgrade();
        self.window
            .clipboard()
            .read_text_async(None::<&gio::Cancellable>, move |result| {
                if cancel.load(Ordering::Relaxed) {
                    return;
                }
                let Some(dialog) = weak.upgrade() else {
                    return;
                };
                let input = match result {
                    Ok(Some(t)) if !t.trim().is_empty() && t.len() <= 65536 => t.to_string(),
                    _ => {
                        status
                            .set_text("Copy text first · up to 64 KiB · images are not summarized");
                        return;
                    }
                };
                status.set_text("Summarizing with local Ollama…");
                let (tx, rx) = mpsc::channel();
                let flag = cancel.clone();
                std::thread::spawn(move || {
                    let _ = tx.send(request("summarize", &input, &model, flag));
                });
                let weak = dialog.downgrade();
                glib::timeout_add_local(Duration::from_millis(80), move || {
                    if cancel.load(Ordering::Relaxed) || weak.upgrade().is_none() {
                        return glib::ControlFlow::Break;
                    }
                    match rx.try_recv() {
                        Ok(Ok(value)) => {
                            text.buffer().set_text(value["text"].as_str().unwrap_or(""));
                            status.set_text(&format!(
                                "{} · generated locally",
                                value["model"].as_str().unwrap_or("Ollama")
                            ));
                            copy.set_sensitive(true);
                            glib::ControlFlow::Break
                        }
                        Ok(Err(error)) => {
                            status.set_text(&error);
                            glib::ControlFlow::Break
                        }
                        Err(mpsc::TryRecvError::Empty) => glib::ControlFlow::Continue,
                        Err(_) => {
                            status.set_text("Local AI request interrupted");
                            glib::ControlFlow::Break
                        }
                    }
                });
            });
        dialog.present();
    }
}

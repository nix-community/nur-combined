use crate::core;
use base64::{Engine as _, engine::general_purpose::STANDARD as B64};
#[cfg(test)]
use gtk::gio;
use gtk::glib;
#[cfg(test)]
use gtk::prelude::*;
use std::{
    cell::{Cell, RefCell},
    io::{BufRead, BufReader, Write},
    path::PathBuf,
    process::{Child, Command, Stdio},
    rc::Rc,
    sync::mpsc,
    time::Duration,
};

pub struct Queue {
    helper: PathBuf,
    child: RefCell<Option<Child>>,
    memory: RefCell<Option<crate::systemtools::Secret>>,
    input: RefCell<Option<std::process::ChildStdin>>,
    pub active: Cell<bool>,
    pub ready: Cell<bool>,
    pub error: RefCell<Option<String>>,
}
impl Queue {
    #[cfg(test)]
    pub fn new(
        _: gtk::gdk::Clipboard,
        pins: &[crate::clipboard::Pinned],
    ) -> Result<Rc<Self>, String> {
        let pins = pins
            .iter()
            .map(|pin| match pin {
                crate::clipboard::Pinned::Text { value, .. } => Ok((
                    crate::securevault::Payload::Text(value.clone()),
                    crate::securevault::now() + 3600,
                )),
                crate::clipboard::Pinned::Image { path, .. } => {
                    let texture = gtk::gdk::Texture::from_file(&gio::File::for_path(path))
                        .map_err(|e| e.to_string())?;
                    Ok((
                        crate::securevault::Payload::Image(texture.save_to_png_bytes().to_vec()),
                        crate::securevault::now() + 3600,
                    ))
                }
            })
            .collect::<Result<Vec<_>, String>>()?;
        Self::new_secure(&pins)
    }
    pub fn new_secure(pins: &[(crate::securevault::Payload, i64)]) -> Result<Rc<Self>, String> {
        if pins.is_empty() || pins.len() > 50 {
            return Err("Select between 1 and 50 encrypted pins".into());
        }
        let installed = std::env::current_exe()
            .ok()
            .and_then(|p| p.parent().map(|p| p.join("spotlight-pastequeue")));
        let helper = [
            std::env::var_os("SPOTLIGHT_PASTEQUEUE_HELPER").map(PathBuf::from),
            installed,
            Some(core::home().join(".local/lib/spotlight/spotlight-pastequeue")),
            Some(
                PathBuf::from(env!("CARGO_MANIFEST_DIR"))
                    .join("target/native/spotlight-pastequeue"),
            ),
        ]
        .into_iter()
        .flatten()
        .find(|p| p.is_file())
        .ok_or("Build the updated paste queue helper with sh native/build-pastequeue.sh")?;
        let mut total = 0;
        let mut manifest = Vec::new();
        for (payload, expires) in pins {
            let (mime, bytes) = match payload {
                crate::securevault::Payload::Text(text) => {
                    ("text/plain;charset=utf-8", text.as_bytes())
                }
                crate::securevault::Payload::Image(bytes) => ("image/png", bytes.as_slice()),
            };
            total += bytes.len();
            if total > 67_108_864 {
                return Err("Queue exceeds 64 MiB".into());
            }
            manifest
                .push(serde_json::json!({"mime":mime,"data":B64.encode(bytes),"expires":expires}));
        }
        let mut encoded =
            serde_json::to_vec(&manifest).map_err(|_| "Cannot prepare secure queue")?;
        encoded.push(b'\n');
        Ok(Rc::new(Self {
            helper,
            child: RefCell::new(None),
            memory: RefCell::new(Some(crate::systemtools::Secret(encoded))),
            input: RefCell::new(None),
            active: Cell::new(true),
            ready: Cell::new(false),
            error: RefCell::new(None),
        }))
    }
    pub fn publish(self: &Rc<Self>) {
        if self.child.borrow().is_some() {
            return;
        }
        let memory = self.memory.borrow_mut().take();
        let result = Command::new(&self.helper)
            .arg("--stdin-json")
            .env(
                "QT_QPA_PLATFORM",
                if std::env::var_os("WAYLAND_DISPLAY").is_some() {
                    "wayland"
                } else {
                    "xcb"
                },
            )
            .stdin(Stdio::piped())
            .stdout(Stdio::piped())
            .stderr(Stdio::null())
            .spawn();
        let mut child = match result {
            Ok(c) => c,
            Err(e) => {
                self.active.set(false);
                *self.error.borrow_mut() = Some(format!("Cannot start paste queue: {e}"));
                return;
            }
        };
        let mut input = child.stdin.take().unwrap();
        let (input_tx, input_rx) = mpsc::channel();
        if let Some(memory) = memory {
            std::thread::spawn(move || {
                let _ = input.write_all(&memory.0);
                let _ = input_tx.send(input);
            });
        } else {
            let _ = input_tx.send(input);
        }
        let output = child.stdout.take().unwrap();
        *self.child.borrow_mut() = Some(child);
        let (tx, rx) = mpsc::channel();
        std::thread::spawn(move || {
            for line in BufReader::new(output).lines().map_while(Result::ok) {
                if tx.send(line).is_err() {
                    break;
                }
            }
        });
        let weak = Rc::downgrade(self);
        let started = std::time::Instant::now();
        glib::timeout_add_local(Duration::from_millis(25), move || {
            let Some(queue) = weak.upgrade() else {
                return glib::ControlFlow::Break;
            };
            if let Ok(input) = input_rx.try_recv() {
                *queue.input.borrow_mut() = Some(input);
            }
            loop {
                match rx.try_recv() {
                    Ok(line) if line == "ready" => queue.ready.set(true),
                    Ok(line) if line == "done" || line == "stopped" => {
                        queue.active.set(false);
                        return glib::ControlFlow::Break;
                    }
                    Ok(line) if line == "cancelled" => {
                        queue.active.set(false);
                        if !queue.ready.get() {
                            *queue.error.borrow_mut() =
                                Some("Could not acquire the background clipboard".into());
                        }
                        return glib::ControlFlow::Break;
                    }
                    Ok(line) if line.starts_with("error ") => {
                        queue.active.set(false);
                        *queue.error.borrow_mut() = Some(line[6..].into());
                        return glib::ControlFlow::Break;
                    }
                    Ok(_) => {}
                    Err(mpsc::TryRecvError::Empty) => break,
                    Err(_) => {
                        queue.active.set(false);
                        if !queue.ready.get() {
                            *queue.error.borrow_mut() =
                                Some("KDE background clipboard access is unavailable".into());
                        }
                        return glib::ControlFlow::Break;
                    }
                }
            }
            if !queue.ready.get() && started.elapsed() > Duration::from_secs(5) {
                queue.active.set(false);
                *queue.error.borrow_mut() = Some("Paste queue helper timed out".into());
                return glib::ControlFlow::Break;
            }
            glib::ControlFlow::Continue
        });
    }
    pub fn stop(&self) {
        self.active.set(false);
        if let Some(input) = self.input.borrow_mut().as_mut() {
            let _ = input.write_all(b"stop\n");
        } else if let Some(child) = self.child.borrow_mut().as_mut() {
            let _ = child.kill();
        }
    }
}
impl Drop for Queue {
    fn drop(&mut self) {
        if let Some(mut child) = self.child.borrow_mut().take() {
            let _ = child.kill();
            let _ = child.wait();
        }
    }
}

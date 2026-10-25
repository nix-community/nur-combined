use crate::{Ui, advanced, boosters};
use gtk::{gdk, gio, glib, prelude::*};
use std::{rc::Rc, sync::mpsc, time::Duration};
impl Ui {
    pub(super) fn execute_booster(self: &Rc<Self>, operation: boosters::Operation) {
        if let boosters::Operation::System(op) = operation {
            self.execute_system_tool(op);
            return;
        }
        if let boosters::Operation::Kit(op) = operation {
            self.execute_kit(op);
            return;
        }
        if let boosters::Operation::Local(op) = operation {
            self.execute_local(op);
            return;
        }
        if let boosters::Operation::Productivity(op) = &operation {
            match op {
                crate::productivity::Operation::Context(question) => self.context_ai(question),
                crate::productivity::Operation::SummarizeClipboard => self.summarize_clipboard(),
                crate::productivity::Operation::Plugin(plugin) => {
                    self.plugin_details(plugin.clone())
                }
            };
            return;
        }
        if let boosters::Operation::Dev(crate::devtools::Operation::Inspect { key, path }) =
            &operation
        {
            match crate::devtools::inspect(key, path.as_deref()) {
                Ok(value) => self.text_preview(key, &value, None),
                Err(error) => self.error(&error),
            }
            return;
        }
        if let boosters::Operation::Advanced(op) = &operation {
            match op {
                advanced::Operation::QrInput => {
                    self.qr_input();
                    return;
                }
                advanced::Operation::Image { bytes, title } => {
                    match gdk::Texture::from_bytes(&glib::Bytes::from_owned(bytes.clone())) {
                        Ok(texture) => self.image_preview_named(&texture, title),
                        Err(e) => self.error(&e.to_string()),
                    }
                    return;
                }
                advanced::Operation::OcrClipboard => {
                    self.error("Reading clipboard image…");
                    let weak = Rc::downgrade(self);
                    self.window.clipboard().read_texture_async(None::<&gio::Cancellable>,move|result|{
                        let Some(ui)=weak.upgrade()else{return;};match result{
                            Ok(Some(texture))=>{
                                if i64::from(texture.width())*i64::from(texture.height())>16_000_000{ui.error("OCR image exceeds 16 million pixels");return;}
                                let bytes=texture.save_to_png_bytes().to_vec();ui.ocr_worker(move||advanced::ocr_bytes(&bytes));
                            },
                            _=>ui.error("No image in the clipboard · choose OCR latest screenshot instead"),
                        }
                    });
                    return;
                }
                advanced::Operation::OcrLatest => {
                    self.ocr_worker(|| advanced::ocr_file(&advanced::latest_screenshot()?));
                    return;
                }
                _ => {}
            }
            if let Some((title, detail)) = op.confirmation() {
                let ui = self.clone();
                self.confirm(&title, &detail, "Continue", move || {
                    ui.execute_booster_now(operation.clone())
                });
                return;
            }
        }
        self.execute_booster_now(operation);
    }
    fn qr_input(self: &Rc<Self>) {
        let dialog = gtk::Window::builder()
            .title("Generate QR Code")
            .transient_for(&self.window)
            .modal(true)
            .default_width(520)
            .build();
        let panel = gtk::Box::new(gtk::Orientation::Vertical, 14);
        panel.add_css_class("editor");
        let entry = gtk::Entry::builder()
            .placeholder_text("Text or URL")
            .max_length(2048)
            .activates_default(true)
            .build();
        entry.update_property(&[gtk::accessible::Property::Label("QR text or URL")]);
        panel.append(&entry);
        let status = gtk::Label::new(None);
        status.set_wrap(true);
        status.set_xalign(0.);
        panel.append(&status);
        let row = gtk::Box::new(gtk::Orientation::Horizontal, 8);
        row.set_halign(gtk::Align::End);
        let cancel = gtk::Button::with_label("Cancel");
        let generate = gtk::Button::with_label("Generate");
        generate.add_css_class("accent");
        row.append(&cancel);
        row.append(&generate);
        panel.append(&row);
        dialog.set_child(Some(&panel));
        dialog.set_default_widget(Some(&generate));
        let weak = dialog.downgrade();
        cancel.connect_clicked(move |_| {
            if let Some(d) = weak.upgrade() {
                d.close();
            }
        });
        let weak = dialog.downgrade();
        let ui = self.clone();
        generate.connect_clicked(move |button| {
            let value = entry.text().to_string();
            if value.trim().is_empty() {
                status.set_text("Enter text or a URL.");
                return;
            }
            button.set_sensitive(false);
            status.set_text("Generating…");
            let (tx, rx) = mpsc::channel();
            std::thread::spawn(move || {
                let _ = tx.send(advanced::fetch(&advanced::Query::Qr(value)));
            });
            let weak = weak.clone();
            let ui = ui.clone();
            let button = button.clone();
            let status = status.clone();
            glib::timeout_add_local(Duration::from_millis(50), move || {
                let Some(dialog) = weak.upgrade() else {
                    return glib::ControlFlow::Break;
                };
                match rx.try_recv() {
                    Ok(Ok(rows)) => {
                        if let Some(op) = rows.into_iter().find_map(|r| r.operation) {
                            dialog.close();
                            ui.execute_booster(op);
                        } else {
                            button.set_sensitive(true);
                            status.set_text("Could not generate a QR code.");
                        }
                        glib::ControlFlow::Break
                    }
                    Ok(Err(error)) => {
                        button.set_sensitive(true);
                        status.set_text(&error);
                        glib::ControlFlow::Break
                    }
                    Err(mpsc::TryRecvError::Empty) => glib::ControlFlow::Continue,
                    Err(_) => {
                        button.set_sensitive(true);
                        status.set_text("QR generation interrupted.");
                        glib::ControlFlow::Break
                    }
                }
            });
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
    }
    pub(super) fn ocr_worker(
        self: &Rc<Self>,
        work: impl FnOnce() -> Result<String, String> + Send + 'static,
    ) {
        self.error("Extracting text…");
        let (tx, rx) = mpsc::channel();
        std::thread::spawn(move || {
            let _ = tx.send(work());
        });
        let weak = Rc::downgrade(self);
        glib::timeout_add_local(Duration::from_millis(80), move || {
            let Some(ui) = weak.upgrade() else {
                return glib::ControlFlow::Break;
            };
            match rx.try_recv() {
                Ok(Ok(text)) => {
                    ui.error("");
                    ui.text_preview("Extracted text", &text, None);
                    glib::ControlFlow::Break
                }
                Ok(Err(error)) => {
                    ui.error(&error);
                    glib::ControlFlow::Break
                }
                Err(mpsc::TryRecvError::Empty) => glib::ControlFlow::Continue,
                Err(_) => {
                    ui.error("OCR interrupted");
                    glib::ControlFlow::Break
                }
            }
        });
    }
}

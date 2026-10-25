use crate::{
    Ui,
    localtools::{self, Operation, Outcome, Tool},
};
use gtk::{gdk, gio, glib, prelude::*};
use std::{rc::Rc, sync::mpsc, time::Duration};
impl Ui {
    pub(super) fn execute_local(self: &Rc<Self>, operation: Operation) {
        match operation {
            Operation::Screenshot => self.capture_screen(true),
            Operation::Open(uri) => {
                let ui = self.clone();
                gio::AppInfo::launch_default_for_uri_async(
                    &uri,
                    None::<&gio::AppLaunchContext>,
                    None::<&gio::Cancellable>,
                    move |result| {
                        if let Err(e) = result {
                            ui.error(&e.to_string());
                        }
                    },
                );
            }
            Operation::Pick(tool) => {
                let dialog = gtk::FileDialog::builder()
                    .title(tool.title())
                    .modal(true)
                    .build();
                let filter = gtk::FileFilter::new();
                if tool == Tool::Pdf {
                    filter.set_name(Some("PDF files"));
                    filter.add_mime_type("application/pdf");
                } else {
                    filter.set_name(Some("Images"));
                    filter.add_pixbuf_formats();
                    filter.add_mime_type("image/webp");
                }
                dialog.set_default_filter(Some(&filter));
                let ui = self.clone();
                dialog.open(
                    Some(&self.window),
                    None::<&gio::Cancellable>,
                    move |result| {
                        if let Ok(file) = result {
                            if let Some(path) = file.path() {
                                ui.execute_local(Operation::File(tool, path));
                            } else {
                                ui.error("Choose a local file");
                            }
                        }
                    },
                );
            }
            work => self.local_worker(move || localtools::execute(work)),
        }
    }
    fn local_worker(
        self: &Rc<Self>,
        work: impl FnOnce() -> Result<Outcome, String> + Send + 'static,
    ) {
        self.error("Working locally…");
        let (tx, rx) = mpsc::channel();
        std::thread::spawn(move || {
            let _ = tx.send(work());
        });
        let weak = Rc::downgrade(self);
        glib::timeout_add_local(Duration::from_millis(60), move || {
            let Some(ui) = weak.upgrade() else {
                return glib::ControlFlow::Break;
            };
            match rx.try_recv() {
                Ok(Ok(outcome)) => {
                    ui.error("");
                    match outcome {
                        Outcome::Message(text) => {
                            ui.booster_cache.borrow_mut().retain(|query, _| {
                                !matches!(
                                    query,
                                    crate::boosters::Query::Local(localtools::Query::Music(..))
                                )
                            });
                            ui.refresh();
                            ui.error(&text);
                        }
                        Outcome::Text(text) => ui.text_preview("Extracted text", &text, None),
                        Outcome::File(path) => ui.text_preview(
                            "Saved file",
                            &path.display().to_string(),
                            Some(&gio::File::for_path(&path).uri()),
                        ),
                        Outcome::Palette(colors) => ui.palette_preview(&colors),
                    }
                    glib::ControlFlow::Break
                }
                Ok(Err(error)) => {
                    ui.error(&error);
                    glib::ControlFlow::Break
                }
                Err(mpsc::TryRecvError::Empty) => glib::ControlFlow::Continue,
                Err(_) => {
                    ui.error("Local action interrupted");
                    glib::ControlFlow::Break
                }
            }
        });
    }
    fn palette_preview(self: &Rc<Self>, colors: &[String]) {
        let dialog = gtk::Window::builder()
            .application(&self.window.application().unwrap())
            .title("Image Color Palette")
            .transient_for(&self.window)
            .modal(true)
            .default_width(420)
            .build();
        let panel = gtk::Box::new(gtk::Orientation::Vertical, 12);
        panel.add_css_class("editor");
        panel.append(&gtk::Label::new(Some(
            "Select a color to copy its hex value",
        )));
        for hex in colors {
            let button = gtk::Button::new();
            let row = gtk::Box::new(gtk::Orientation::Horizontal, 12);
            let swatch = gtk::DrawingArea::builder()
                .width_request(48)
                .height_request(36)
                .build();
            if let Ok(c) = gdk::RGBA::parse(hex) {
                swatch.set_draw_func(move |_, cr, w, h| {
                    cr.set_source_rgb(c.red() as f64, c.green() as f64, c.blue() as f64);
                    cr.rectangle(0., 0., w as f64, h as f64);
                    let _ = cr.fill();
                });
            }
            row.append(&swatch);
            row.append(&gtk::Label::new(Some(hex)));
            button.set_child(Some(&row));
            let hex = hex.clone();
            let ui = self.clone();
            button.connect_clicked(move |_| {
                ui.window.clipboard().set_text(&hex);
                *ui.picked_color.borrow_mut() = Some(hex.clone());
                ui.error(&format!("Copied {hex}"));
            });
            panel.append(&button);
        }
        let copy = gtk::Button::with_label("Copy All Colors");
        let text = colors.join("\n");
        let clipboard = self.window.clipboard();
        copy.connect_clicked(move |_| clipboard.set_text(&text));
        panel.append(&copy);
        let close = gtk::Button::with_label("Close");
        let weak = dialog.downgrade();
        close.connect_clicked(move |_| {
            if let Some(d) = weak.upgrade() {
                d.close();
            }
        });
        panel.append(&close);
        dialog.set_child(Some(&panel));
        dialog.present();
    }
    pub(super) fn finish_capture(
        self: &Rc<Self>,
        screenshot: bool,
        result: Result<Option<gtk::gdk_pixbuf::Pixbuf>, String>,
    ) {
        let workflow = if screenshot {
            self.workflow_capture.borrow_mut().take()
        } else {
            None
        };
        if let Some(callback) = workflow {
            self.measurement_request.borrow_mut().take();
            self.measuring_screen.set(false);
            self.window.present();
            callback(result);
            return;
        }
        if !screenshot {
            self.finish_measurement(result);
            return;
        }
        self.measurement_request.borrow_mut().take();
        self.measuring_screen.set(false);
        self.window.present();
        self.search.grab_focus();
        match result {
            Ok(Some(image)) => {
                self.image_preview_named(&gdk::Texture::for_pixbuf(&image), "Screenshot")
            }
            Ok(None) => self.error("Screenshot cancelled"),
            Err(e) => self.error(&e),
        }
    }
    pub(super) fn screenshot_actions(
        self: &Rc<Self>,
        panel: &gtk::Box,
        texture: &gdk::Texture,
        capture: &gtk::Window,
    ) {
        let actions = gtk::MenuButton::new();
        actions.set_label("Actions  Tab");
        actions.set_widget_name("screenshot-actions");
        actions.set_tooltip_text(Some(
            "Use this capture for OCR, QR, compression, pinning or saving · Tab or Ctrl+K",
        ));
        let popup = gtk::Popover::new();
        popup.set_has_arrow(false);
        let row = gtk::Box::new(gtk::Orientation::Vertical, 4);
        row.set_widget_name("screenshot-action-menu");
        popup.set_child(Some(&row));
        actions.set_popover(Some(&popup));
        for name in ["OCR", "Decode QR", "Compress", "Pin", "Save…"] {
            let button = gtk::Button::with_label(name);
            let ui = self.clone();
            let image = texture.clone();
            let pop = popup.clone();
            let parent = capture.clone();
            button.connect_clicked(move |_| {
                pop.popdown();
                match name {
                    "OCR" => {
                        let bytes = image.save_to_png_bytes().to_vec();
                        ui.ocr_worker(move || crate::advanced::ocr_bytes(&bytes));
                    }
                    "Decode QR" => {
                        let bytes = image.save_to_png_bytes().to_vec();
                        ui.local_worker(move || localtools::decode_qr(&bytes).map(Outcome::Text));
                    }
                    "Compress" => {
                        let dialog = gtk::FileDialog::builder()
                            .title("Save Compressed Screenshot")
                            .initial_name("Screenshot-quality-50.webp")
                            .modal(true)
                            .build();
                        let bytes = image.save_to_png_bytes().to_vec();
                        let ui = ui.clone();
                        let filter = gtk::FileFilter::new();
                        filter.set_name(Some("WebP image"));
                        filter.add_pattern("*.webp");
                        dialog.set_default_filter(Some(&filter));
                        dialog.save(Some(&parent), None::<&gio::Cancellable>, move |result| {
                            if let Ok(file) = result {
                                if let Some(path) = file.path() {
                                    ui.local_worker(move || {
                                        let compressed = localtools::compress_capture(&bytes)?;
                                        file.replace_contents(
                                            &compressed,
                                            None,
                                            false,
                                            gio::FileCreateFlags::PRIVATE,
                                            None::<&gio::Cancellable>,
                                        )
                                        .map_err(|e| e.to_string())?;
                                        Ok(Outcome::File(path))
                                    });
                                } else {
                                    ui.error(
                                        "Choose a local destination for the compressed screenshot",
                                    );
                                }
                            }
                        });
                    }
                    "Pin" => ui.pin_clipboard(&crate::item(
                        "screenshot",
                        "Screenshot",
                        "",
                        "camera-photo-symbolic",
                        "Image",
                        crate::Action::ClipboardTexture(image.clone()),
                    )),
                    _ => {
                        let dialog = gtk::FileDialog::builder()
                            .title("Save Screenshot")
                            .initial_name("Screenshot.png")
                            .modal(true)
                            .build();
                        let bytes = image.save_to_png_bytes();
                        let ui = ui.clone();
                        dialog.save(Some(&parent), None::<&gio::Cancellable>, move |result| {
                            if let Ok(file) = result {
                                match file.replace_contents(
                                    bytes.as_ref(),
                                    None,
                                    false,
                                    gio::FileCreateFlags::PRIVATE,
                                    None::<&gio::Cancellable>,
                                ) {
                                    Ok(_) => ui.error("Screenshot saved"),
                                    Err(e) => ui.error(&e.to_string()),
                                }
                            }
                        });
                    }
                }
            });
            row.append(&button);
        }
        let keys = gtk::EventControllerKey::new();
        keys.set_propagation_phase(gtk::PropagationPhase::Capture);
        let menu = actions.clone();
        keys.connect_key_pressed(move |_, key, _, modifiers| {
            let ctrl = modifiers.contains(gdk::ModifierType::CONTROL_MASK);
            let plain = !modifiers.intersects(
                gdk::ModifierType::CONTROL_MASK
                    | gdk::ModifierType::ALT_MASK
                    | gdk::ModifierType::SHIFT_MASK
                    | gdk::ModifierType::SUPER_MASK
                    | gdk::ModifierType::META_MASK,
            );
            if (key == gdk::Key::Tab && plain && !menu.is_active())
                || (ctrl && matches!(key, gdk::Key::k | gdk::Key::K))
            {
                menu.popup();
                glib::Propagation::Stop
            } else {
                glib::Propagation::Proceed
            }
        });
        capture.add_controller(keys);
        panel.append(&actions);
    }
}

#[cfg(test)]
mod tests {
    use crate::*;
    use std::cell::Cell;
    fn window(title: &str) -> gtk::Window {
        gtk::Window::list_toplevels()
            .into_iter()
            .filter_map(|w| w.downcast::<gtk::Window>().ok())
            .find(|w| w.is_visible() && w.title().as_deref() == Some(title))
            .unwrap_or_else(|| panic!("Missing {title}"))
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
    #[ignore = "requires a desktop and isolated data; run tests/features_smoke.py --ui"]
    fn native_ui() {
        let root =
            PathBuf::from(std::env::var_os("SPOTLIGHT_FEATURE_ROOT").expect("Use feature harness"));
        assert!(core::data_dir().starts_with(&root));
        let app = gtk::Application::builder()
            .application_id("local.spotlight.Localtools.Test")
            .build();
        let done = Rc::new(Cell::new(false));
        let completed = done.clone();
        app.connect_activate(move |app| {
            let ui = build_with_mode(app, true);
            ui.secure_vault
                .lock()
                .unwrap()
                .unlock(b"features fixture master password", true)
                .unwrap();
            let root = root.clone();
            let done = done.clone();
            let source = root.join("ocr.png");
            let image = gtk::gdk_pixbuf::Pixbuf::from_file(&source).unwrap();
            ui.finish_capture(true, Ok(Some(image)));
            let capture = window("Screenshot");
            let actions = test_widget(capture.upcast_ref(), &|w| {
                w.widget_name() == "screenshot-actions"
            })
            .unwrap()
            .downcast::<gtk::MenuButton>()
            .unwrap();
            actions.popup();
            for label in [
                "Copy Image",
                "OCR",
                "Decode QR",
                "Compress",
                "Pin",
                "Save…",
                "Close",
            ] {
                assert!(button(&capture, label).is_visible());
            }
            let pins = ui
                .secure_vault
                .lock()
                .unwrap()
                .entries(securevault::now())
                .unwrap()
                .len();
            button(&capture, "Pin").emit_clicked();
            assert!(Store::load().unwrap().pinned_clips.is_empty());
            assert_eq!(
                ui.secure_vault
                    .lock()
                    .unwrap()
                    .entries(securevault::now())
                    .unwrap()
                    .len(),
                pins + 1
            );
            button(&capture, "Copy Image").emit_clicked();
            let copy_done = Rc::new(Cell::new(false));
            let copied = copy_done.clone();
            ui.window
                .clipboard()
                .read_texture_async(None::<&gio::Cancellable>, move |r| {
                    assert!(r.unwrap().is_some());
                    copied.set(true);
                });
            button(&capture, "Close").emit_clicked();
            let selected = item(
                "fixture",
                "image",
                "",
                "image-x-generic-symbolic",
                "File",
                Action::Open(gio::File::for_path(&source).uri().into()),
            );
            let menu = gtk::Box::new(gtk::Orientation::Vertical, 4);
            ui.file_actions(&menu, &gtk::Popover::new(), &selected);
            for tool in [
                localtools::Tool::Compress,
                localtools::Tool::Resize,
                localtools::Tool::Webp,
                localtools::Tool::Palette,
            ] {
                assert!(
                    test_widget(menu.upcast_ref(), &|w| w
                        .clone()
                        .downcast::<gtk::Button>()
                        .is_ok_and(|b| b.label().as_deref() == Some(tool.title())))
                    .is_some()
                );
            }
            ui.execute_local(localtools::Operation::File(
                localtools::Tool::Palette,
                source,
            ));
            let started = std::time::Instant::now();
            glib::timeout_add_local(Duration::from_millis(100), move || {
                assert!(started.elapsed() < Duration::from_secs(15));
                let palette = gtk::Window::list_toplevels()
                    .into_iter()
                    .filter_map(|w| w.downcast::<gtk::Window>().ok())
                    .find(|w| {
                        w.is_visible() && w.title().as_deref() == Some("Image Color Palette")
                    });
                if let Some(palette) = palette {
                    if !copy_done.get() {
                        return glib::ControlFlow::Continue;
                    }
                    button(&palette, "Copy All Colors").emit_clicked();
                    button(&palette, "Close").emit_clicked();
                    for q in [
                        "history youtube",
                        "bookmark github",
                        "screenshot",
                        "play lofi",
                        "compress image 50%",
                        "resize 1080p",
                        "pdf text",
                        "image to webp",
                        "palette",
                    ] {
                        assert!(matches!(
                            boosters::Query::parse(q),
                            Some(boosters::Query::Local(_))
                        ));
                    }
                    done.set(true);
                    ui.window.application().unwrap().quit();
                    glib::ControlFlow::Break
                } else {
                    glib::ControlFlow::Continue
                }
            });
        });
        app.run_with_args::<&str>(&[]);
        assert!(completed.get());
    }
    async fn wait_window(title: &str) -> gtk::Window {
        for _ in 0..300 {
            if let Some(w) = gtk::Window::list_toplevels()
                .into_iter()
                .filter_map(|w| w.downcast::<gtk::Window>().ok())
                .find(|w| w.is_visible() && w.title().as_deref() == Some(title))
            {
                return w;
            }
            glib::timeout_future(Duration::from_millis(30)).await;
        }
        panic!("Missing window {title}");
    }
    fn tab_actions(capture: &gtk::Window) -> gtk::Popover {
        let controllers = capture.observe_controllers();
        let keys = (0..controllers.n_items())
            .find_map(|i| {
                controllers
                    .item(i)?
                    .downcast::<gtk::EventControllerKey>()
                    .ok()
            })
            .unwrap();
        assert!(keys.emit_by_name::<bool>(
            "key-pressed",
            &[&gdk::Key::Tab, &0u32, &gdk::ModifierType::empty()]
        ));
        let actions = test_widget(capture.upcast_ref(), &|w| {
            w.widget_name() == "screenshot-actions"
        })
        .unwrap()
        .downcast::<gtk::MenuButton>()
        .unwrap();
        let pop = actions.popover().unwrap();
        assert!(pop.is_visible());
        pop
    }
    #[test]
    #[ignore = "requires private screenshot portal and OCR/QR tools; run tests/features_smoke.py --ui"]
    fn screenshot_chain() {
        let root = PathBuf::from(std::env::var_os("SPOTLIGHT_FEATURE_ROOT").unwrap());
        assert!(core::data_dir().starts_with(&root));
        let rows = advanced::fetch(&advanced::Query::Qr(
            "https://example.test/same-capture".into(),
        ))
        .unwrap();
        let Some(boosters::Operation::Advanced(advanced::Operation::Image { bytes, .. })) =
            rows.into_iter().next().unwrap().operation
        else {
            panic!()
        };
        let loader = gtk::gdk_pixbuf::PixbufLoader::new();
        loader.write(&bytes).unwrap();
        loader.close().unwrap();
        let qr = loader.pixbuf().unwrap().add_alpha(false, 0, 0, 0).unwrap();
        let text = gtk::gdk_pixbuf::Pixbuf::from_file(root.join("ocr.png"))
            .unwrap()
            .add_alpha(false, 0, 0, 0)
            .unwrap();
        let capture = gtk::gdk_pixbuf::Pixbuf::new(
            gtk::gdk_pixbuf::Colorspace::Rgb,
            true,
            8,
            text.width().max(qr.width()),
            text.height() + qr.height() + 40,
        )
        .unwrap();
        capture.fill(0xffffffff);
        text.copy_area(0, 0, text.width(), text.height(), &capture, 0, 0);
        qr.copy_area(
            0,
            0,
            qr.width(),
            qr.height(),
            &capture,
            0,
            text.height() + 20,
        );
        capture.savev(root.join("chain.png"), "png", &[]).unwrap();
        let app = gtk::Application::builder()
            .application_id("local.spotlight.ScreenshotChain.Test")
            .build();
        let done = Rc::new(Cell::new(false));
        let completed = done.clone();
        app.connect_activate(move |app| {
            let ui=build_with_mode(app,true);ui.secure_vault.lock().unwrap().unlock(b"features fixture master password",true).unwrap();let root=root.clone();let done=done.clone();
            let guard_app=app.clone();glib::timeout_add_local_once(Duration::from_secs(25),move ||guard_app.quit());
            glib::MainContext::default().spawn_local(async move {
                ui.capture_screen(true);
                let capture=wait_window("Screenshot").await;
                assert_eq!(std::fs::read_to_string(root.join("portal-count")).unwrap(),"1");
                assert!(!root.join("portal-capture-1.png").exists(),"Portal temporary file was removed");
                tab_actions(&capture);button(&capture,"OCR").emit_clicked();
                let text=wait_window("Extracted text").await;
                let view=test_widget(text.upcast_ref(),&|w|w.is::<gtk::TextView>()).unwrap().downcast::<gtk::TextView>().unwrap();let buffer=view.buffer();
                assert!(buffer.text(&buffer.start_iter(),&buffer.end_iter(),false).contains("Spotlight 2026"));button(&text,"Close").emit_clicked();
                assert!(capture.is_visible());tab_actions(&capture);button(&capture,"Decode QR").emit_clicked();
                let result=wait_window("Extracted text").await;
                let view=test_widget(result.upcast_ref(),&|w|w.is::<gtk::TextView>()).unwrap().downcast::<gtk::TextView>().unwrap();let buffer=view.buffer();
                assert_eq!(buffer.text(&buffer.start_iter(),&buffer.end_iter(),false).trim(),"https://example.test/same-capture");button(&result,"Close").emit_clicked();
                tab_actions(&capture);let count=ui.secure_vault.lock().unwrap().entries(securevault::now()).unwrap().len();button(&capture,"Pin").emit_clicked();assert!(Store::load().unwrap().pinned_clips.is_empty());assert_eq!(ui.secure_vault.lock().unwrap().entries(securevault::now()).unwrap().len(),count+1);
                let image=test_widget(capture.upcast_ref(),&|w|w.is::<gtk::Picture>()).unwrap().downcast::<gtk::Picture>().unwrap().paintable().unwrap().downcast::<gdk::Texture>().unwrap();
                let png=image.save_to_png_bytes().to_vec();let expected=(image.width(),image.height());
                let (tx,rx)=std::sync::mpsc::channel();std::thread::spawn(move ||{let _=tx.send(localtools::compress_capture(&png));});
                let compressed=loop {if let Ok(value)=rx.try_recv(){break value.unwrap();}glib::timeout_future(Duration::from_millis(30)).await;};
                let loader=gtk::gdk_pixbuf::PixbufLoader::new();loader.write(&compressed).unwrap();loader.close().unwrap();let decoded=loader.pixbuf().unwrap();assert_eq!((decoded.width(),decoded.height()),expected);
                assert_eq!(std::fs::read_to_string(root.join("portal-count")).unwrap(),"1","OCR, QR, pin and compression must reuse one capture");
                assert!(ui.measurement_request.borrow().is_none());
                button(&capture,"Close").emit_clicked();done.set(true);ui.window.application().unwrap().quit();
                println!("One portal capture reused for Tab-menu OCR, QR, pin and WebP compression; source temporary file removed.");
            });
        });
        app.run_with_args(&["spotlight-screenshot-chain"]);
        assert!(completed.get());
    }
}

use crate::{
    Ui,
    automation::{self, Definition, Kind, Step},
    core,
};
use gtk::{gdk, gio, glib, prelude::*};
use std::{
    cell::{Cell, RefCell},
    rc::{Rc, Weak},
    sync::{
        Arc,
        atomic::{AtomicBool, Ordering},
        mpsc,
    },
    time::Duration,
};
#[derive(Clone)]
pub enum Command {
    Builder(Option<String>),
    Run(String),
    Delete(String),
}
impl Ui {
    pub(super) fn automation_rows(&self, query: &str) -> Vec<crate::Item> {
        if !self.store.borrow().commands.enabled("extensions") {
            return vec![];
        }
        let q = query.trim();
        if q != "workflow" && !q.starts_with("workflow ") && q != "workflows" {
            return vec![];
        }
        let rest = if q == "workflows" {
            ""
        } else {
            q.strip_prefix("workflow").unwrap_or("").trim()
        };
        let (verb, filter) = rest.split_once(' ').unwrap_or((rest, ""));
        let mut rows = vec![crate::item(
            "workflow-builder",
            "Workflow Builder",
            "Create a visual local chain · saved as WASM",
            "view-list-symbolic",
            "Workflow",
            crate::Action::Automation(Command::Builder(None)),
        )];
        if ["run", "edit", "delete"].contains(&verb) {
            rows.clear();
        }
        for def in automation::list() {
            let search = if ["run", "edit", "delete"].contains(&verb) {
                filter
            } else {
                rest
            };
            if core::score(search, &def.name).is_none() {
                continue;
            }
            let (title, op) = match verb {
                "edit" => (
                    format!("Edit workflow · {}", def.name),
                    Command::Builder(Some(def.id.clone())),
                ),
                "delete" => (
                    format!("Delete workflow · {}", def.name),
                    Command::Delete(def.id.clone()),
                ),
                _ => (
                    format!("Run workflow · {}", def.name),
                    Command::Run(def.id.clone()),
                ),
            };
            rows.push(crate::item(
                &format!("workflow:{}", def.id),
                &title,
                &def.steps
                    .iter()
                    .map(|s| s.kind.label())
                    .collect::<Vec<_>>()
                    .join(" → "),
                "media-playback-start-symbolic",
                "WASM workflow",
                crate::Action::Automation(op),
            ));
        }
        if rows.is_empty() {
            rows.push(crate::item(
                "workflow-empty",
                "No saved workflows match",
                "Type workflow to create or browse chains",
                "view-list-symbolic",
                "Workflow",
                crate::Action::Noop,
            ));
        }
        rows
    }
    pub(super) fn execute_automation(self: &Rc<Self>, command: Command) {
        match command {
            Command::Builder(id) => self.workflow_builder(id.as_deref()),
            Command::Run(id) => self.run_automation(&id),
            Command::Delete(id) => {
                let ui = self.clone();
                self.confirm(
                    "Delete saved workflow?",
                    "Remove its WASM file. Notes already created by it are kept.",
                    "Delete workflow",
                    move || {
                        let result = automation::remove(&id);
                        ui.refresh();
                        ui.error(
                            result
                                .as_ref()
                                .err()
                                .map(String::as_str)
                                .unwrap_or("Workflow removed"),
                        );
                    },
                );
            }
        }
    }
    fn workflow_builder(self: &Rc<Self>, id: Option<&str>) {
        let definition = match id.map(automation::load).transpose() {
            Ok(Some(d)) => d,
            Ok(None) => Definition::new(),
            Err(e) => {
                self.error(&e);
                return;
            }
        };
        let dialog = gtk::Window::builder()
            .title("Workflow Builder · Local WASM")
            .transient_for(&self.window)
            .modal(true)
            .destroy_with_parent(true)
            .default_width(740)
            .default_height(740)
            .build();
        dialog.set_widget_name("workflow-builder");
        let panel = gtk::Box::new(gtk::Orientation::Vertical, 12);
        panel.add_css_class("editor");
        panel.add_css_class("workflow-editor");
        let name = gtk::Entry::builder()
            .placeholder_text("Workflow name")
            .max_length(80)
            .build();
        name.set_text(&definition.name);
        name.set_widget_name("workflow-name");
        panel.append(&name);
        let description = gtk::Label::new(Some(
            "Arrange actions from top to bottom. Each action passes its output to the next.",
        ));
        description.set_wrap(true);
        description.set_xalign(0.);
        panel.append(&description);
        let templates = gtk::DropDown::from_strings(&[
            "Screenshot → OCR → Translate → Note",
            "Clipboard → Summarize → Note",
            "Input → Translate → Copy",
        ]);
        let template = gtk::Button::with_label("Load example");
        let row = gtk::Box::new(gtk::Orientation::Horizontal, 8);
        row.append(&templates);
        row.append(&template);
        panel.append(&row);
        let cards = gtk::Box::new(gtk::Orientation::Vertical, 6);
        cards.set_widget_name("workflow-cards");
        let steps = Rc::new(RefCell::new(definition.steps.clone()));
        render_cards(&cards, &steps);
        panel.append(
            &gtk::ScrolledWindow::builder()
                .child(&cards)
                .min_content_height(280)
                .vexpand(true)
                .build(),
        );
        let add = gtk::Button::with_label("+ Add action");
        add.set_widget_name("workflow-add");
        let values = steps.clone();
        let weak = cards.downgrade();
        add.connect_clicked(move |_| {
            if values.borrow().len() < 12 {
                values.borrow_mut().push(Step {
                    kind: Kind::Copy,
                    option: String::new(),
                });
                if let Some(cards) = weak.upgrade() {
                    render_cards(&cards, &values);
                }
            }
        });
        panel.append(&add);
        let values = steps.clone();
        let weak = cards.downgrade();
        template.connect_clicked(move |_| {
            let kinds = match templates.selected() {
                1 => vec![Kind::Clipboard, Kind::Summarize, Kind::Note],
                2 => vec![Kind::Input, Kind::Translate, Kind::Copy],
                _ => vec![Kind::Screenshot, Kind::Ocr, Kind::Translate, Kind::Note],
            };
            *values.borrow_mut() = kinds
                .into_iter()
                .map(|kind| Step {
                    kind,
                    option: if kind == Kind::Translate {
                        "English".into()
                    } else {
                        String::new()
                    },
                })
                .collect();
            if let Some(cards) = weak.upgrade() {
                render_cards(&cards, &values);
            }
        });
        let status = gtk::Label::new(Some(
            "Translate and Summarize require an installed local Ollama model; OCR requires Tesseract.",
        ));
        status.set_wrap(true);
        status.set_xalign(0.);
        status.set_widget_name("workflow-editor-status");
        panel.append(&status);
        let row = gtk::Box::new(gtk::Orientation::Horizontal, 8);
        let save = gtk::Button::with_label("Save WASM");
        save.set_widget_name("workflow-save");
        let run = gtk::Button::with_label("Save & Run");
        run.set_widget_name("workflow-save-run");
        run.add_css_class("accent");
        let close = gtk::Button::with_label("Close");
        for b in [&save, &run, &close] {
            row.append(b);
        }
        panel.append(&row);
        dialog.set_child(Some(&panel));
        for (button, start) in [(&save, false), (&run, true)] {
            let ui = self.clone();
            let name = name.clone();
            let steps = steps.clone();
            let status = status.clone();
            let base = definition.clone();
            let weak = dialog.downgrade();
            button.connect_clicked(move |_| {
                if !ui.can_save {
                    status.set_text("Saved settings are unreadable.");
                    return;
                }
                let mut def = base.clone();
                def.name = name.text().trim().into();
                def.steps = steps.borrow().clone();
                match automation::save(&def) {
                    Ok(path) => {
                        status.set_text(&format!("Saved {}", path.display()));
                        ui.refresh();
                        if start {
                            if let Some(d) = weak.upgrade() {
                                d.close();
                            }
                            ui.run_automation(&def.id);
                        }
                    }
                    Err(e) => status.set_text(&e),
                }
            });
        }
        let weak = dialog.downgrade();
        close.connect_clicked(move |_| {
            if let Some(d) = weak.upgrade() {
                d.close();
            }
        });
        escape(&dialog);
        dialog.present();
    }
    fn run_automation(self: &Rc<Self>, id: &str) {
        let def = match automation::load(id) {
            Ok(d) => d,
            Err(e) => {
                self.error(&e);
                return;
            }
        };
        let dialog = gtk::Window::builder()
            .title(format!("Workflow · {}", def.name))
            .transient_for(&self.window)
            .modal(true)
            .destroy_with_parent(true)
            .default_width(720)
            .default_height(540)
            .build();
        dialog.set_widget_name("workflow-runner");
        let panel = gtk::Box::new(gtk::Orientation::Vertical, 12);
        panel.add_css_class("editor");
        panel.add_css_class("workflow-editor");
        let chain = gtk::Label::new(Some(
            &def.steps
                .iter()
                .map(|s| s.kind.label())
                .collect::<Vec<_>>()
                .join(" → "),
        ));
        chain.set_wrap(true);
        panel.append(&chain);
        let label = gtk::Label::new(Some("Input text (used by Input actions)"));
        label.set_xalign(0.);
        panel.append(&label);
        let input = gtk::TextView::new();
        input.set_wrap_mode(gtk::WrapMode::WordChar);
        input.set_widget_name("workflow-input");
        panel.append(
            &gtk::ScrolledWindow::builder()
                .child(&input)
                .min_content_height(90)
                .build(),
        );
        let output = gtk::TextView::new();
        output.set_editable(false);
        output.set_wrap_mode(gtk::WrapMode::WordChar);
        output.set_widget_name("workflow-output");
        panel.append(
            &gtk::ScrolledWindow::builder()
                .child(&output)
                .vexpand(true)
                .min_content_height(180)
                .build(),
        );
        let status = gtk::Label::new(Some(
            "Review the chain, then Run. Copy and Save Note steps change the clipboard or create a note.",
        ));
        status.set_wrap(true);
        status.set_xalign(0.);
        status.set_widget_name("workflow-status");
        panel.append(&status);
        let buttons = gtk::Box::new(gtk::Orientation::Horizontal, 8);
        let start = gtk::Button::with_label("Run chain");
        start.set_widget_name("workflow-start");
        start.add_css_class("accent");
        let close = gtk::Button::with_label("Cancel / Close");
        buttons.append(&start);
        buttons.append(&close);
        panel.append(&buttons);
        dialog.set_child(Some(&panel));
        let cancel = Arc::new(AtomicBool::new(false));
        let flag = cancel.clone();
        let weak_ui = Rc::downgrade(self);
        dialog.connect_close_request(move |_| {
            flag.store(true, Ordering::Relaxed);
            if let Some(ui) = weak_ui.upgrade() {
                ui.cancel_workflow_capture();
            }
            glib::Propagation::Proceed
        });
        let weak = dialog.downgrade();
        close.connect_clicked(move |_| {
            if let Some(d) = weak.upgrade() {
                d.close();
            }
        });
        let state = Rc::new(Run {
            ui: Rc::downgrade(self),
            window: dialog.downgrade(),
            steps: def.steps,
            index: Cell::new(0),
            text: RefCell::new(String::new()),
            initial: RefCell::new(String::new()),
            image: RefCell::new(None),
            output,
            status,
            cancel,
            model: self.store.borrow().commands.ollama_model.clone(),
        });
        start.connect_clicked(move |button| {
            let buffer = input.buffer();
            let text = buffer.text(&buffer.start_iter(), &buffer.end_iter(), false);
            if text.len() > 65536 {
                state.status.set_text("Input exceeds 64 KiB");
                return;
            }
            button.set_sensitive(false);
            input.set_editable(false);
            *state.initial.borrow_mut() = text.to_string();
            *state.text.borrow_mut() = text.to_string();
            state.advance();
        });
        escape(&dialog);
        dialog.present();
    }
    pub(super) fn cancel_workflow_capture(&self) {
        if self.workflow_capture.borrow_mut().take().is_some() {
            if let Some((path, _)) = self.measurement_request.borrow_mut().take()
                && let Ok(bus) = gio::bus_get_sync(gio::BusType::Session, None::<&gio::Cancellable>)
            {
                bus.call(
                    Some("org.freedesktop.portal.Desktop"),
                    &path,
                    "org.freedesktop.portal.Request",
                    "Close",
                    None,
                    None,
                    gio::DBusCallFlags::NONE,
                    1000,
                    None::<&gio::Cancellable>,
                    |_| {},
                );
            }
            self.measuring_screen.set(false);
            self.window.present();
        }
    }
}
fn render_cards(panel: &gtk::Box, steps: &Rc<RefCell<Vec<Step>>>) {
    while let Some(child) = panel.first_child() {
        panel.remove(&child);
    }
    for (n, step) in steps.borrow().iter().enumerate() {
        let card = gtk::Box::new(gtk::Orientation::Vertical, 6);
        card.add_css_class("workflow-card");
        let row = gtk::Box::new(gtk::Orientation::Horizontal, 8);
        row.append(&gtk::Label::new(Some(&format!("{}", n + 1))));
        let kinds = Kind::ALL.map(Kind::label);
        let select = gtk::DropDown::from_strings(&kinds);
        select.set_selected(Kind::ALL.iter().position(|k| *k == step.kind).unwrap() as u32);
        select.set_hexpand(true);
        select.set_widget_name(&format!("workflow-kind-{n}"));
        row.append(&select);
        for (label, delta) in [("↑", -1), ("↓", 1), ("Remove", 0)] {
            let button = gtk::Button::with_label(label);
            let values = steps.clone();
            let weak = panel.downgrade();
            button.connect_clicked(move |_| {
                let mut stages = values.borrow_mut();
                if n >= stages.len() {
                    return;
                }
                if delta == 0 {
                    stages.remove(n);
                } else {
                    let next = n as i32 + delta;
                    if next >= 0 && (next as usize) < stages.len() {
                        stages.swap(n, next as usize);
                    }
                }
                drop(stages);
                if let Some(panel) = weak.upgrade() {
                    render_cards(&panel, &values);
                }
            });
            row.append(&button);
        }
        card.append(&row);
        let option = gtk::Entry::builder()
            .placeholder_text("Target language, e.g. Spanish (Translate only)")
            .max_length(80)
            .build();
        option.set_text(&step.option);
        option.set_sensitive(step.kind == Kind::Translate);
        option.set_visible(step.kind == Kind::Translate);
        option.set_widget_name(&format!("workflow-option-{n}"));
        let values = steps.clone();
        option.connect_changed(move |entry| {
            if let Some(step) = values.borrow_mut().get_mut(n) {
                step.option = entry.text().into();
            }
        });
        card.append(&option);
        let values = steps.clone();
        select.connect_selected_notify(move |select| {
            let kind = Kind::ALL[select.selected() as usize];
            let mut stages = values.borrow_mut();
            if let Some(step) = stages.get_mut(n) {
                step.kind = kind;
                step.option = if kind == Kind::Translate {
                    "English".into()
                } else {
                    String::new()
                };
                let text = step.option.clone();
                drop(stages);
                option.set_sensitive(kind == Kind::Translate);
                option.set_visible(kind == Kind::Translate);
                option.set_text(&text);
            }
        });
        panel.append(&card);
        if n + 1 < steps.borrow().len() {
            panel.append(&gtk::Label::new(Some("↓ output")));
        }
    }
}
struct Run {
    ui: Weak<Ui>,
    window: glib::WeakRef<gtk::Window>,
    steps: Vec<Step>,
    index: Cell<usize>,
    text: RefCell<String>,
    initial: RefCell<String>,
    image: RefCell<Option<Vec<u8>>>,
    output: gtk::TextView,
    status: gtk::Label,
    cancel: Arc<AtomicBool>,
    model: String,
}
impl Run {
    fn fail(&self, error: &str) {
        self.status.set_text(error);
        self.cancel.store(true, Ordering::Relaxed);
    }
    fn next(self: &Rc<Self>) {
        self.output.buffer().set_text(&self.text.borrow());
        self.index.set(self.index.get() + 1);
        self.advance();
    }
    fn advance(self: &Rc<Self>) {
        if self.cancel.load(Ordering::Relaxed) {
            return;
        }
        let Some(ui) = self.ui.upgrade() else {
            return;
        };
        let Some(window) = self.window.upgrade() else {
            return;
        };
        let Some(step) = self.steps.get(self.index.get()).cloned() else {
            self.image.borrow_mut().take();
            self.status
                .set_text("Workflow complete · intermediate data was not saved");
            return;
        };
        self.status.set_text(&format!(
            "{} / {} · {}",
            self.index.get() + 1,
            self.steps.len(),
            step.kind.label()
        ));
        match step.kind {
            Kind::Input => {
                if self.initial.borrow().trim().is_empty() {
                    self.fail("Enter input text before running this chain");
                    return;
                }
                *self.text.borrow_mut() = self.initial.borrow().clone();
                self.next();
            }
            Kind::Clipboard => {
                let state = self.clone();
                ui.window
                    .clipboard()
                    .read_text_async(None::<&gio::Cancellable>, move |result| {
                        if state.cancel.load(Ordering::Relaxed) {
                            return;
                        }
                        match result {
                            Ok(Some(text)) if !text.trim().is_empty() && text.len() <= 65536 => {
                                *state.text.borrow_mut() = text.into();
                                state.next();
                            }
                            _ => state.fail("Clipboard text is empty or exceeds 64 KiB"),
                        }
                    });
            }
            Kind::Screenshot => {
                if ui.measuring_screen.get() {
                    self.fail("Another screen capture is in progress");
                    return;
                }
                let state = self.clone();
                *ui.workflow_capture.borrow_mut() = Some(Box::new(move |result| {
                    if state.cancel.load(Ordering::Relaxed) {
                        return;
                    }
                    if let Some(window) = state.window.upgrade() {
                        window.present();
                    }
                    match result {
                        Ok(Some(image)) => match image.save_to_bufferv("png", &[]) {
                            Ok(bytes) if bytes.len() <= 16_777_216 => {
                                *state.image.borrow_mut() = Some(bytes);
                                state.text.borrow_mut().clear();
                                state.next();
                            }
                            _ => state.fail("Screenshot exceeds 16 MiB"),
                        },
                        Ok(None) => state.fail("Screenshot cancelled"),
                        Err(e) => state.fail(&e),
                    }
                }));
                window.set_visible(false);
                ui.capture_screen(true);
                let state = self.clone();
                glib::timeout_add_local_once(Duration::from_secs(45), move || {
                    if !state.cancel.load(Ordering::Relaxed)
                        && state
                            .steps
                            .get(state.index.get())
                            .is_some_and(|s| s.kind == Kind::Screenshot)
                    {
                        if let Some(ui) = state.ui.upgrade() {
                            ui.cancel_workflow_capture();
                        }
                        if let Some(window) = state.window.upgrade() {
                            window.present();
                        }
                        state.fail("Screenshot request timed out");
                    }
                });
            }
            Kind::Ocr => {
                let Some(bytes) = self.image.borrow_mut().take() else {
                    self.fail("No screenshot to OCR");
                    return;
                };
                self.worker(move || crate::advanced::ocr_bytes(&bytes));
            }
            Kind::Translate | Kind::Summarize => {
                let text = self.text.borrow().clone();
                if text.trim().is_empty() {
                    self.fail("This action needs nonempty text");
                    return;
                }
                let input = if step.kind == Kind::Translate {
                    serde_json::json!({"language":step.option,"text":text}).to_string()
                } else {
                    text
                };
                let model = self.model.clone();
                let flag = self.cancel.clone();
                self.worker(move || {
                    crate::localai::request(
                        if step.kind == Kind::Translate {
                            "translate"
                        } else {
                            "summarize"
                        },
                        &input,
                        &model,
                        flag,
                    )
                    .and_then(|v| {
                        v["text"]
                            .as_str()
                            .map(str::to_owned)
                            .ok_or_else(|| "Local model returned no text".into())
                    })
                });
            }
            Kind::Note => {
                let text = self.text.borrow();
                if text.trim().is_empty() {
                    self.fail("Cannot save an empty note");
                    return;
                }
                let result = ui.capture_note(&text);
                drop(text);
                match result {
                    Ok(_) => self.next(),
                    Err(e) => self.fail(&e),
                }
            }
            Kind::Copy => {
                if self.text.borrow().is_empty() {
                    self.fail("This action needs nonempty text");
                    return;
                }
                ui.window.clipboard().set_text(&self.text.borrow());
                self.next();
            }
        }
    }
    fn worker(self: &Rc<Self>, work: impl FnOnce() -> Result<String, String> + Send + 'static) {
        let (tx, rx) = mpsc::channel();
        std::thread::spawn(move || {
            let _ = tx.send(work());
        });
        let state = self.clone();
        glib::timeout_add_local(Duration::from_millis(60), move || {
            if state.cancel.load(Ordering::Relaxed) {
                return glib::ControlFlow::Break;
            }
            match rx.try_recv() {
                Ok(Ok(text)) if text.len() <= 65536 => {
                    *state.text.borrow_mut() = text;
                    state.next();
                    glib::ControlFlow::Break
                }
                Ok(Ok(_)) => {
                    state.fail("Action output exceeds 64 KiB");
                    glib::ControlFlow::Break
                }
                Ok(Err(e)) => {
                    state.fail(&e);
                    glib::ControlFlow::Break
                }
                Err(mpsc::TryRecvError::Empty) => glib::ControlFlow::Continue,
                Err(_) => {
                    state.fail("Workflow action interrupted");
                    glib::ControlFlow::Break
                }
            }
        });
    }
}
fn escape(dialog: &gtk::Window) {
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
}

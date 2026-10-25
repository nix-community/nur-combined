use crate::*;
use std::{
    fs,
    sync::{Arc, atomic::AtomicBool},
};
async fn pause() {
    glib::timeout_future(Duration::from_millis(40)).await;
}
async fn until(test: impl Fn() -> bool) {
    for _ in 0..300 {
        if test() {
            return;
        }
        pause().await;
    }
    panic!("Deep feature check timed out");
}
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
fn named<T: IsA<gtk::Widget> + glib::object::IsClass>(parent: &gtk::Window, name: &str) -> T {
    test_widget(parent.upcast_ref(), &|w| w.widget_name() == name)
        .unwrap_or_else(|| panic!("Missing {name}"))
        .downcast::<T>()
        .ok()
        .unwrap()
}
fn text(view: &gtk::TextView) -> String {
    let b = view.buffer();
    b.text(&b.start_iter(), &b.end_iter(), false).into()
}
#[test]
#[ignore = "requires isolated local Ollama fixtures; run tests/deep_features_smoke.py"]
fn backends() {
    let root = PathBuf::from(std::env::var_os("SPOTLIGHT_DEEP_ROOT").unwrap());
    assert!(core::data_dir().starts_with(&root));
    let request = || {
        localai::request(
            "context",
            r#"{"question":"Private context question fixture","context":"Selected project fixture"}"#,
            "test-local",
            Arc::new(AtomicBool::new(false)),
        )
    };
    assert_eq!(request().unwrap()["text"], "Context answer fixture");
    assert_eq!(
        localai::request(
            "translate",
            r#"{"text":"OCR text fixture","language":"Spanish"}"#,
            "test-local",
            Arc::new(AtomicBool::new(false))
        )
        .unwrap()["text"],
        "Translated fixture"
    );
    for flag in ["cloud-enabled", "remote-model", "redirect-server"] {
        fs::write(root.join(flag), "").unwrap();
        assert!(request().is_err());
        fs::remove_file(root.join(flag)).unwrap();
    }
    let def = automation::Definition::new();
    let path = automation::save(&def).unwrap();
    assert_eq!(automation::load(&def.id).unwrap().name, def.name);
    use std::os::unix::fs::PermissionsExt;
    assert_eq!(
        fs::metadata(&path).unwrap().permissions().mode() & 0o777,
        0o600
    );
    automation::remove(&def.id).unwrap();
    assert!(automation::load(&def.id).is_err());
}
#[test]
#[ignore = "requires private desktop, portal and Ollama fixtures; run tests/deep_features_smoke.py"]
fn native_ui() {
    let root = PathBuf::from(std::env::var_os("SPOTLIGHT_DEEP_ROOT").unwrap());
    assert!(core::data_dir().starts_with(&root));
    let app = gtk::Application::builder()
        .application_id("local.spotlight.DeepFeatures.Test")
        .build();
    let done = Rc::new(Cell::new(false));
    let complete = done.clone();
    app.connect_activate(move |app| {
        let ui = build_with_mode(app, true);
        let root = root.clone();
        let done = complete.clone();
        glib::spawn_future_local(async move {
            ui.store.borrow_mut().obsidian_disabled = true;
            ui.store.borrow_mut().project_context =
                Some(root.join("home/Projects/context-project"));
            let legacy = core::data_dir().join("clipboard-pins/old.png");
            fs::create_dir_all(legacy.parent().unwrap()).unwrap();
            fs::copy(root.join("screenshot-source.png"), &legacy).unwrap();
            ui.store.borrow_mut().pinned_clips = vec![
                clipboard::Pinned::Text {
                    id: "legacy-text".into(),
                    value: "Legacy private pin fixture".into(),
                },
                clipboard::Pinned::Image {
                    id: "legacy-image".into(),
                    path: legacy.clone(),
                },
            ];
            ui.save();
            ui.page(Page::Root);ui.search.set_text("vault");
            let vault_row=ui.visible.borrow().first().unwrap().clone();assert!(matches!(vault_row.action,Action::Vault));ui.launch(vault_row);
            let prompt = window("secret-dialog");
            named::<gtk::PasswordEntry>(&prompt, "secret-input")
                .set_text("fixture master password");
            named::<gtk::PasswordEntry>(&prompt, "secret-confirm")
                .set_text("fixture master password");
            named::<gtk::Button>(&prompt, "secret-accept").emit_clicked();
            until(|| {
                ui.secure_vault.try_lock().is_ok_and(|v| v.unlocked())
                    && ui.store.borrow().pinned_clips.is_empty()
            })
            .await;
            assert!(!legacy.exists());
            let disk = fs::read_to_string(core::data_dir().join("clipboard-vault.json")).unwrap();
            assert!(!disk.contains("Legacy private pin fixture"));
            assert!(Store::load().unwrap().pinned_clips.is_empty());
            ui.refresh();
            assert!(
                ui.visible
                    .borrow()
                    .iter()
                    .any(|r| r.id.starts_with("vault-pin:"))
            );
            let before = ui.store.borrow().favorites.clone();
            let index = ui
                .visible
                .borrow()
                .iter()
                .position(|r| r.id.starts_with("vault-pin:"))
                .unwrap();
            ui.list
                .select_row(ui.list.row_at_index(index as i32).as_ref());
            ui.favorite();
            assert_eq!(ui.store.borrow().favorites, before);
            ui.secure_vault.lock().unwrap().lock();
            ui.refresh();
            assert!(
                !ui.visible
                    .borrow()
                    .iter()
                    .any(|r| r.id.starts_with("vault-pin:"))
            );
            ui.open_clipboard_vault();
            let prompt = window("secret-dialog");
            named::<gtk::PasswordEntry>(&prompt, "secret-input").set_text("wrong");
            named::<gtk::Button>(&prompt, "secret-accept").emit_clicked();
            until(|| ui.notice.text().contains("Wrong master password")).await;
            assert!(!ui.secure_vault.lock().unwrap().unlocked());
            // Workflow Builder saves a genuine executable WASM plan.
            ui.execute_automation(automation_ui::Command::Builder(None));
            let builder = window("workflow-builder");
            named::<gtk::Entry>(&builder, "workflow-name").set_text("Fixture screenshot chain");
            named::<gtk::Entry>(&builder, "workflow-option-2").set_text("Spanish");
            for _ in 0..5 {
                pause().await;
            }
            capture_test_window(&builder, "/tmp/spotlight-workflow-builder.png");
            named::<gtk::Button>(&builder, "workflow-save").emit_clicked();
            let def = automation::list()
                .into_iter()
                .find(|d| d.name == "Fixture screenshot chain")
                .unwrap();
            assert_eq!(def.steps[2].option, "Spanish");
            builder.close();
            ui.page(Page::Root);ui.search.set_text("workflow run Fixture screenshot chain");
            let run_row=ui.visible.borrow().first().unwrap().clone();assert!(matches!(&run_row.action,Action::Automation(automation_ui::Command::Run(id)) if id==&def.id));ui.launch(run_row);
            let runner = window("workflow-runner");
            named::<gtk::Button>(&runner, "workflow-start").emit_clicked();
            until(|| {
                named::<gtk::Label>(&runner, "workflow-status")
                    .text()
                    .contains("Workflow complete")
            })
            .await;
            assert_eq!(
                text(&named::<gtk::TextView>(&runner, "workflow-output")),
                "Translated fixture"
            );
            assert_eq!(ui.store.borrow().quick_notes.len(), 1);
            let note = ui.store.borrow().quick_notes[0].path.clone();
            assert!(
                fs::read_to_string(note)
                    .unwrap()
                    .contains("Translated fixture")
            );
            runner.close();
            let mut cancelled = automation::Definition::new();
            cancelled.name = "Cancelled input note".into();
            cancelled.steps = vec![
                automation::Step {
                    kind: automation::Kind::Input,
                    option: String::new(),
                },
                automation::Step {
                    kind: automation::Kind::Note,
                    option: String::new(),
                },
            ];
            automation::save(&cancelled).unwrap();
            ui.execute_automation(automation_ui::Command::Run(cancelled.id));
            window("workflow-runner").close();
            assert_eq!(ui.store.borrow().quick_notes.len(), 1);
            let requests_before = fs::read_to_string(root.join("requests.jsonl"))
                .unwrap()
                .lines()
                .count();
            ui.context_ai("What should I work on next?");
            let context = window("context-ai");
            let preview = named::<gtk::TextView>(&context, "ai-context-preview");
            until(|| named::<gtk::Button>(&context, "ai-context-send").is_sensitive()).await;
            let included = text(&preview);
            assert!(
                included.contains("Project README context fixture")
                    && included.contains("Project todo fixture")
                    && included.contains("Context window fixture")
            );
            assert!(!included.contains("PRIVATE_ENV_MARKER"));
            assert_eq!(
                fs::read_to_string(root.join("requests.jsonl"))
                    .unwrap()
                    .lines()
                    .count(),
                requests_before,
                "Opening context must not call Ollama"
            );
            named::<gtk::CheckButton>(&context, "ai-source-windows").set_active(false);
            until(|| named::<gtk::Button>(&context, "ai-context-send").is_sensitive()).await;
            assert!(!text(&preview).contains("Context window fixture"));
            named::<gtk::Button>(&context, "ai-context-send").emit_clicked();
            until(|| {
                text(&named::<gtk::TextView>(&context, "ai-context-answer"))
                    == "Context answer fixture"
            })
            .await;
            for _ in 0..8 {
                pause().await;
            }
            capture_test_window(&context, "/tmp/spotlight-context-ai.png");
            context.close();
            let saved = fs::read_to_string(core::data_dir().join("data.json")).unwrap();
            for private in [
                "fixture master password",
                "Legacy private pin fixture",
                "What should I work on next?",
                "Project README context fixture",
                "PRIVATE_ENV_MARKER",
            ] {
                assert!(
                    !saved.contains(private),
                    "Private context leaked to saved settings"
                );
            }
            ui.secure_vault
                .lock()
                .unwrap()
                .prune(securevault::now() + 3600)
                .unwrap();
            assert!(
                ui.secure_vault
                    .lock()
                    .unwrap()
                    .entries(securevault::now() + 3600)
                    .unwrap()
                    .is_empty()
            );
            done.set(true);
            ui.window.application().unwrap().quit();
        });
    });
    app.run_with_args(&["deep-features-test"]);
    assert!(done.get());
}

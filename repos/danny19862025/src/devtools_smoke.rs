use crate::*;
use std::cell::Cell;

#[test]
#[ignore = "requires private fixtures and a desktop; run tests/devtools_smoke.py"]
fn native_ui() {
    let root = PathBuf::from(std::env::var_os("SPOTLIGHT_DEVTOOLS_ROOT").unwrap());
    assert!(core::data_dir().starts_with(&root));
    let app = gtk::Application::builder()
        .application_id("local.spotlight.DevTools.Test")
        .build();
    let done = Rc::new(Cell::new(false));
    let completed = done.clone();
    app.connect_activate(move |app| {
        let ui = build_with_mode(app, true);
        let root = root.clone();
        let done = completed.clone();
        ui.store.borrow_mut().snippets = vec![
            TextItem {
                name: "Placeholder fixture".into(),
                trigger: ";ph".into(),
                value: "é({cursor}) {clipboard}".into(),
            },
            TextItem {
                name: "Caret fixture".into(),
                trigger: ";pure".into(),
                value: "<{cursor}>".into(),
            },
        ];
        let mut phase = 0;
        let start = std::time::Instant::now();
        let copied = Rc::new(Cell::new(false));
        let text = gtk::TextView::new();
        ui.snippet_text_keys(&text);
        glib::timeout_add_local(Duration::from_millis(180), move || {
            assert!(
                start.elapsed() < Duration::from_secs(20),
                "Developer UI timed out at phase {phase}"
            );
            match phase {
                0 => {
                    ui.window.clipboard().set_text("CLIP {cursor}");
                    ui.search.set_text("prefix ;ph suffix");
                    ui.search.set_position("prefix ;ph".chars().count() as i32);
                    assert!(ui.expand_search_snippet(gdk::Key::Tab));
                }
                1 => {
                    if ui.search.text().as_str() == "prefix ;ph suffix" {
                        return glib::ControlFlow::Continue;
                    }
                    assert_eq!(ui.search.text(), "prefix é() CLIP {cursor} suffix");
                    assert_eq!(ui.search.position(), 9);
                    text.buffer().set_text(";pure");
                    text.buffer().place_cursor(&text.buffer().end_iter());
                    let controllers = text.observe_controllers();
                    let keys = (0..controllers.n_items())
                        .find_map(|n| {
                            controllers
                                .item(n)?
                                .downcast::<gtk::EventControllerKey>()
                                .ok()
                        })
                        .unwrap();
                    keys.emit_by_name::<bool>(
                        "key-pressed",
                        &[&gdk::Key::Tab, &0u32, &gdk::ModifierType::empty()],
                    );
                    assert_eq!(
                        text.buffer().text(
                            &text.buffer().start_iter(),
                            &text.buffer().end_iter(),
                            false
                        ),
                        "<>"
                    );
                    assert_eq!(text.buffer().cursor_position(), 1);
                    ui.search.set_text(";ph");
                    ui.search.set_position(-1);
                    assert!(ui.expand_search_snippet(gdk::Key::Tab));
                    ui.search.set_text("changed while reading clipboard");
                }
                2 => {
                    assert_eq!(ui.search.text(), "changed while reading clipboard");
                    ui.window.clipboard().set_text("CLIP {cursor}");
                    let copied = copied.clone();
                    let clipboard = ui.window.clipboard();
                    ui.notice.connect_label_notify(move |label| {
                        if label.text().starts_with("Snippet copied") {
                            let copied = copied.clone();
                            clipboard.read_text_async(None::<&gio::Cancellable>, move |result| {
                                assert_eq!(result.unwrap().unwrap(), "CLIP {cursor} / done");
                                copied.set(true);
                            });
                        }
                    });
                    ui.launch(item(
                        "booster:snippet-fixture",
                        "Snippet fixture",
                        "",
                        "",
                        "",
                        Action::Snippet("{clipboard} / {cursor}done".into()),
                    ));
                }
                3 => {
                    if !copied.get() {
                        return glib::ControlFlow::Continue;
                    }
                }
                4 => {
                    if !copied.get() {
                        return glib::ControlFlow::Continue;
                    }
                    ui.execute_booster(boosters::Operation::Dev(devtools::Operation::Inspect {
                        key: "SPOTLIGHT_TEST_SECRET".into(),
                        path: None,
                    }));
                    let preview = ui.preview_window.borrow().as_ref().unwrap().clone();
                    assert_eq!(preview.title().as_deref(), Some("SPOTLIGHT_TEST_SECRET"));
                    preview.close();
                    ui.preview_window.borrow_mut().take();
                    ui.execute_booster(boosters::Operation::Dev(devtools::Operation::UseProject(
                        root.join("my project café"),
                    )));
                }
                5 => {
                    if ui.booster_busy.get() {
                        return glib::ControlFlow::Continue;
                    }
                    assert_eq!(
                        Store::load().unwrap().project_context,
                        Some(root.join("my project café"))
                    );
                    ui.execute_booster(boosters::Operation::Dev(
                        devtools::Operation::OpenProject {
                            editor: "pycharm".into(),
                            path: root.join("JetBrains project"),
                        },
                    ));
                }
                6 => {
                    if ui.booster_busy.get() {
                        return glib::ControlFlow::Continue;
                    }
                    assert_eq!(
                        Store::load().unwrap().project_context,
                        Some(root.join("JetBrains project"))
                    );
                    ui.page(Page::Snippets);
                    assert!(matches!(ui.visible.borrow()[0].action, Action::Snippet(_)));
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
    app.run_with_args::<&str>(&[]);
    assert!(done.get());
}

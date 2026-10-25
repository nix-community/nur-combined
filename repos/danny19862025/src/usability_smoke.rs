use crate::*;

fn press(ui: &Ui, key: gdk::Key, mods: gdk::ModifierType) -> bool {
    let controllers = ui.window.observe_controllers();
    let keys = (0..controllers.n_items())
        .filter_map(|i| controllers.item(i))
        .find_map(|c| c.downcast::<gtk::EventControllerKey>().ok())
        .unwrap();
    keys.emit_by_name("key-pressed", &[&key, &0u32, &mods])
}
fn popover(ui: &Ui) -> Option<gtk::Popover> {
    test_widget(ui.window.upcast_ref(), &|w| {
        w.widget_name() == "actions-popover"
    })
    .map(|w| w.downcast().unwrap())
}

#[test]
#[ignore = "requires a desktop and isolated HOME; run tests/usability_smoke.py"]
fn native_ui() {
    assert!(
        core::home()
            .to_string_lossy()
            .starts_with("/tmp/spotlight-usability-")
    );
    let output = PathBuf::from(std::env::var_os("SPOTLIGHT_DEMO_OUTPUT").unwrap());
    let app = gtk::Application::builder()
        .application_id("local.spotlight.Usability.Test")
        .build();
    let done = Rc::new(Cell::new(false));
    let complete = done.clone();
    app.connect_activate(move |app| {
        let ui = build_with_mode(app, true);
        ui.apps.borrow_mut().clear();
        for (id, name, icon) in [
            ("firefox", "Firefox", "web-browser-symbolic"),
            ("code", "Visual Studio Code", "text-editor-symbolic"),
            ("files", "Files", "folder-symbolic"),
        ] {
            let info = gio::AppInfo::create_from_commandline(
                "true",
                Some(name),
                gio::AppInfoCreateFlags::NONE,
            )
            .unwrap();
            ui.apps.borrow_mut().push(item(
                &format!("app:{id}"),
                name,
                "Application",
                icon,
                "App",
                Action::App(info),
            ));
        }
        ui.store.borrow_mut().favorites = vec!["app:code".into(), "app:firefox".into()];
        ui.refresh();
        let done = complete.clone();
        let output = output.clone();
        let mut phase = 0;
        glib::timeout_add_local(Duration::from_millis(250), move || {
            match phase {
                0 => {
                    capture_test_window(
                        ui.window.upcast_ref(),
                        output.join("spotlight.png").to_str().unwrap(),
                    );
                    let button: gtk::Button = test_widget(ui.window.upcast_ref(), &|w| {
                        w.widget_name() == "actions-button"
                    })
                    .unwrap()
                    .downcast()
                    .unwrap();
                    assert_eq!(button.label().as_deref(), Some("Actions  Tab"));
                    assert!(button.is_visible());
                    ui.search.grab_focus();
                    assert!(!press(&ui, gdk::Key::Tab, gdk::ModifierType::SHIFT_MASK));
                    assert!(press(&ui, gdk::Key::Tab, gdk::ModifierType::empty()));
                    assert!(popover(&ui).unwrap().is_visible());
                    popover(&ui).unwrap().popdown();
                }
                1 => {
                    assert!(popover(&ui).is_none(), "closed popovers are unparented");
                    ui.search.grab_focus();
                    assert!(press(&ui, gdk::Key::k, gdk::ModifierType::CONTROL_MASK));
                    assert!(popover(&ui).unwrap().is_visible());
                    popover(&ui).unwrap().popdown();
                }
                2 => {
                    ui.store.borrow_mut().snippets.push(TextItem {
                        name: "Demo signature".into(),
                        value: "Best regards".into(),
                        trigger: ";sig".into(),
                    });
                    ui.search.grab_focus();
                    ui.search.set_text(";sig");
                    ui.search.set_position(-1);
                    ui.search.select_region(-1, -1);
                    assert_eq!(ui.search.position(), 4);
                    assert!(ui.search.selection_bounds().is_none());
                    assert!(press(&ui, gdk::Key::Tab, gdk::ModifierType::empty()));
                    assert_eq!(ui.search.text(), "Best regards");
                    assert!(
                        popover(&ui).is_none(),
                        "snippet triggers take priority over actions"
                    );
                    *ui.files.borrow_mut() = core::index_files().unwrap();
                    *ui.files_ready.borrow_mut() = true;
                    let recents = search::recent().unwrap();
                    assert!(
                        !recents
                            .iter()
                            .any(|(p, _)| p.starts_with(core::home().join("Private")))
                    );
                    *ui.recents.borrow_mut() = recents;
                    ui.search.set_text("");
                    ui.page(Page::Files);
                }
                3 => {
                    assert!(
                        ui.visible
                            .borrow()
                            .iter()
                            .any(|i| i.title == "project-notes.md")
                    );
                    assert!(
                        !ui.visible
                            .borrow()
                            .iter()
                            .any(|i| i.title.contains("secret"))
                    );
                    capture_test_window(
                        ui.window.upcast_ref(),
                        output.join("spotlight-files.png").to_str().unwrap(),
                    );
                    ui.search.grab_focus();
                    assert!(press(&ui, gdk::Key::Tab, gdk::ModifierType::empty()));
                    let pop = popover(&ui).unwrap();
                    let reveal = test_widget(pop.upcast_ref(), &|w| {
                        w.downcast_ref::<gtk::Button>()
                            .is_some_and(|b| b.label().is_some_and(|s| s.contains("Reveal")))
                    });
                    assert!(reveal.is_some(), "Tab exposes contextual file actions");
                    pop.popdown();
                }
                _ => {
                    done.set(true);
                    ui.window.application().unwrap().quit();
                    return glib::ControlFlow::Break;
                }
            }
            phase += 1;
            glib::ControlFlow::Continue
        });
    });
    app.run_with_args(&["usability-test"]);
    assert!(done.get());
}

use crate::*;
use std::{
    cell::Cell,
    fs,
    sync::{Arc, atomic::AtomicBool},
};

#[test]
#[ignore = "run tests/productivity_smoke.py with private fixtures"]
fn backends() {
    let root = PathBuf::from(std::env::var_os("SPOTLIGHT_PRODUCTIVITY_ROOT").unwrap());
    assert!(core::data_dir().starts_with(&root));
    let plugins = pluginstore::catalog().unwrap();
    assert_eq!(plugins.len(), 1);
    let mut p = plugins[0].clone();
    p.id = "store-fixture".into();
    let mut invalid = p.clone();
    invalid.id = "bad-checksum".into();
    invalid.sha256 = "0".repeat(64);
    assert!(pluginstore::install(&invalid).is_err());
    assert!(!core::data_dir().join("plugins/bad-checksum").exists());
    pluginstore::install(&p).unwrap();
    assert!(pluginstore::install(&p).is_err());
    let (manifests, errors) = extensions::discover_at(&core::data_dir().join("plugins"));
    assert!(errors.is_empty(), "{errors:?}");
    assert!(
        manifests
            .iter()
            .any(|m| m.id == "store-fixture" && m.runtime == extensions::Runtime::Wasm)
    );
    for artifact in [
        "https://evil.invalid/plugin.wasm",
        "https://github.com/owner/repo/raw/main/plugin.wasm",
        "https://github.com/owner/repo/releases/download/v1/../evil.wasm",
        "file:///tmp/plugin.wasm",
    ] {
        invalid = p.clone();
        invalid.artifact = artifact.into();
        assert!(invalid.validate().is_err());
    }
    let request = || {
        localai::request(
            "summarize",
            "Private clipboard fixture",
            "test-local",
            Arc::new(AtomicBool::new(false)),
        )
    };
    assert_eq!(request().unwrap()["text"], "Summary generated locally");
    for mode in [
        "cloud-enabled",
        "remote-model",
        "old-server",
        "redirect-server",
    ] {
        fs::write(root.join(mode), "").unwrap();
        assert!(request().is_err(), "{mode} must refuse generation");
        fs::remove_file(root.join(mode)).unwrap();
    }
    assert!(
        localai::request(
            "summarize",
            "Private clipboard fixture",
            "test-local",
            Arc::new(AtomicBool::new(true))
        )
        .is_err()
    );
    let rows = productivity::fetch(&productivity::Query::Meet("in 2h for 45m".into())).unwrap();
    assert!(rows[0].title.starts_with("Free ·"));
    assert!(matches!(
        rows[0].operation,
        Some(boosters::Operation::Preview { .. })
    ));
    let bridge = core::home().join(".local/lib/spotlight/spotlight-pim");
    let original = fs::read(&bridge).unwrap();
    fs::write(&bridge, "#!/bin/sh\necho 'cache incomplete' >&2\nexit 2\n").unwrap();
    assert!(productivity::fetch(&productivity::Query::Meet("in 2h".into())).is_err());
    fs::write(&bridge, original).unwrap();
}

fn window(title: &str) -> Option<gtk::Window> {
    gtk::Window::list_toplevels()
        .into_iter()
        .filter_map(|w| w.downcast().ok())
        .find(|w: &gtk::Window| w.is_visible() && w.title().as_deref() == Some(title))
}
#[test]
#[ignore = "requires a desktop and private fixtures; run tests/productivity_smoke.py"]
fn native_ui() {
    let root = PathBuf::from(std::env::var_os("SPOTLIGHT_PRODUCTIVITY_ROOT").unwrap());
    assert!(core::data_dir().starts_with(&root));
    let app = gtk::Application::builder()
        .application_id("local.spotlight.Productivity.Test")
        .build();
    let done = Rc::new(Cell::new(false));
    let completed = done.clone();
    app.connect_activate(move|app|{
        println!("Building productivity UI fixture");
        let ui=build_with_mode(app,true);let done=completed.clone();
        println!("Built productivity UI fixture");
        let info=gio::AppInfo::create_from_commandline("true",Some("Firefox"),gio::AppInfoCreateFlags::NONE).unwrap();
        ui.apps.borrow_mut().push(item("app:fixture-firefox","Firefox","Fixture browser","web-browser-symbolic","App",Action::App(info)));
        let panel=ui.customization_panel();let settings=gtk::Window::builder().application(app).transient_for(&ui.window).modal(true).title("Search Settings Fixture").default_width(580).default_height(680).build();settings.set_child(Some(&gtk::ScrolledWindow::builder().child(&panel).build()));settings.present();
        let aliases:gtk::TextView=test_widget(panel.upcast_ref(),&|w|w.widget_name()=="command-aliases").unwrap().downcast().unwrap();
        aliases.buffer().set_text("ff = firefox\ng = web {query}\ns = ai summarize clipboard");
        let web:gtk::DropDown=test_widget(panel.upcast_ref(),&|w|w.widget_name()=="fallback-engine").unwrap().downcast().unwrap();web.set_selected(1);
        for id in ["containers","fonts"]{let check:gtk::CheckButton=test_widget(panel.upcast_ref(),&|w|w.widget_name()==format!("category-{id}")).unwrap().downcast().unwrap();check.set_active(false);}
        let model:gtk::Entry=test_widget(panel.upcast_ref(),&|w|w.widget_name()=="ollama-model").unwrap().downcast().unwrap();model.set_text("test-local");
        let apply:gtk::Button=test_widget(panel.upcast_ref(),&|w|w.widget_name()=="apply-command-settings").unwrap().downcast().unwrap();apply.emit_clicked();assert!(!Store::load().unwrap().commands.enabled("containers"));
        println!("Applied search settings");
        aliases.buffer().set_text("ff = ff");apply.emit_clicked();assert!(Store::load().unwrap().commands.resolve("ff").is_ok());
        let mut phase=0;let mut last_phase=99;let start=std::time::Instant::now();let mut pending_gate_started=false;
        glib::timeout_add_local(Duration::from_millis(180),move||{
            if last_phase!=phase{println!("Productivity UI phase {phase}");last_phase=phase;}
            assert!(start.elapsed()<Duration::from_secs(30),"Productivity UI timed out at phase {phase}");
            match phase{
                0=>{
                    if !pending_gate_started {
                        settings.close();ui.page(Page::Root);
                        ui.store.borrow_mut().commands.disabled.retain(|c|c!="containers");
                        ui.search.set_text("docker");
                        assert!(ui.booster_pending.borrow().iter().any(|q|matches!(q,boosters::Query::Containers(..))));
                        ui.store.borrow_mut().commands.disabled.push("containers".into());ui.refresh();pending_gate_started=true;
                        return glib::ControlFlow::Continue;
                    }
                    if start.elapsed()<Duration::from_millis(900){return glib::ControlFlow::Continue;}
                    assert!(!PathBuf::from(std::env::var_os("SPOTLIGHT_PRODUCTIVITY_ROOT").unwrap()).join("docker-called").exists());
                    ui.page(Page::Root);ui.search.set_text("docker");assert!(ui.visible.borrow().iter().any(|r|r.id=="disabled-category"));assert!(!ui.booster_pending.borrow().iter().any(|q|matches!(q,boosters::Query::Containers(..))));
                    ui.search.set_text("fonts");assert!(!ui.visible.borrow().iter().any(|r|matches!(r.action,Action::FontPreview(_)|Action::Page(Page::Fonts))));
                    ui.search.set_text("ff");assert_eq!(ui.visible.borrow()[0].title,"Firefox");
                    ui.search.set_text("g café & work");assert!(matches!(&ui.visible.borrow()[0].action,Action::Open(url) if url=="https://duckduckgo.com/?q=caf%C3%A9%20%26%20work"));assert_eq!(ui.search.text(),"g café & work");
                    ui.search.set_text("s");
                },
                1=>{
                    let Some(row)=ui.visible.borrow().iter().find(|r|matches!(r.action,Action::Booster(boosters::Operation::Productivity(productivity::Operation::SummarizeClipboard)))).cloned()else{return glib::ControlFlow::Continue;};
                    ui.window.clipboard().set_text("Private UI clipboard fixture");ui.launch(row);
                },
                2=>{
                    let dialog=window("Local AI · Clipboard Summary").unwrap();let view:gtk::TextView=test_widget(dialog.upcast_ref(),&|w|w.widget_name()=="ai-summary").unwrap().downcast().unwrap();
                    if view.buffer().text(&view.buffer().start_iter(),&view.buffer().end_iter(),false).is_empty(){return glib::ControlFlow::Continue;}
                    assert_eq!(view.buffer().text(&view.buffer().start_iter(),&view.buffer().end_iter(),false),"Summary generated locally");assert!(!fs::read_to_string(core::data_dir().join("data.json")).unwrap().contains("Private UI clipboard fixture"));dialog.close();ui.search.set_text("store");
                },
                3=>{
                    let Some(row)=ui.visible.borrow().iter().find(|r|matches!(r.action,Action::Booster(boosters::Operation::Productivity(productivity::Operation::Plugin(_))))).cloned()else{return glib::ControlFlow::Continue;};ui.launch(row);
                    let dialog=window("Extension Store").unwrap();let install:gtk::Button=test_widget(dialog.upcast_ref(),&|w|w.widget_name()=="store-install").unwrap().downcast().unwrap();assert!(install.is_sensitive());install.emit_clicked();
                },
                4=>{
                    if !ui.extensions.borrow().iter().any(|m|m.id=="wasm-text"){return glib::ControlFlow::Continue;}
                    assert!(core::data_dir().join("plugins/wasm-text/plugin.wasm").is_file());window("Extension Store").unwrap().close();
                },
                5=>{
                    assert!(ui.extensions.borrow().iter().any(|m|m.id=="wasm-text"));done.set(true);ui.window.application().unwrap().quit();return glib::ControlFlow::Break;
                },_=>unreachable!(),
            }phase+=1;glib::ControlFlow::Continue
        });
    });
    app.run_with_args::<&str>(&[]);
    assert!(done.get());
}

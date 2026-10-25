use crate::*;
use std::{cell::Cell, fs, path::Path};

fn window(title: &str) -> Option<gtk::Window> {
    gtk::Window::list_toplevels()
        .into_iter()
        .filter_map(|w| w.downcast::<gtk::Window>().ok())
        .find(|w| w.is_visible() && w.title().as_deref() == Some(title))
}
fn button(window: &gtk::Window, label: &str) -> gtk::Button {
    test_widget(window.upcast_ref(), &|w| {
        w.clone()
            .downcast::<gtk::Button>()
            .is_ok_and(|b| b.label().as_deref() == Some(label))
    })
    .unwrap_or_else(|| panic!("Missing button {label}"))
    .downcast()
    .unwrap()
}
fn close(ui: &Rc<Ui>) {
    let preview = ui.preview_window.borrow_mut().take();
    if let Some(w) = preview {
        w.close();
    }
    for w in gtk::Window::list_toplevels()
        .into_iter()
        .filter_map(|w| w.downcast::<gtk::Window>().ok())
    {
        if w != ui.window.clone().upcast::<gtk::Window>() && w.is_visible() {
            w.close();
        }
    }
}
fn confirmation() -> gtk::Window {
    gtk::Window::list_toplevels()
        .into_iter()
        .filter_map(|w| w.downcast::<gtk::Window>().ok())
        .find(|w| w.is_visible() && w.widget_name() == "action-confirmation")
        .expect("Confirmation dialog must be visible")
}
fn confirmation_button(dialog: &gtk::Window, name: &str) -> gtk::Button {
    test_widget(dialog.upcast_ref(), &|w| w.widget_name() == name)
        .unwrap()
        .downcast()
        .unwrap()
}
fn clear_count(root: &Path) -> usize {
    fs::read_to_string(root.join("dbus-calls.jsonl"))
        .unwrap_or_default()
        .lines()
        .filter(|l| l.contains("clearClipboard"))
        .count()
}

#[test]
#[ignore = "requires a private D-Bus fixture and a desktop; run tests/features_smoke.py --ui"]
fn native_ui() {
    let root = PathBuf::from(
        std::env::var_os("SPOTLIGHT_FEATURE_ROOT").expect("Run tests/features_smoke.py --ui"),
    );
    assert!(
        root.file_name()
            .unwrap()
            .to_string_lossy()
            .starts_with("spotlight-features-")
    );
    assert!(core::data_dir().starts_with(&root));
    let app = gtk::Application::builder()
        .application_id("local.spotlight.Features.Test")
        .build();
    let completed = Rc::new(Cell::new(false));
    let done = completed.clone();
    app.connect_activate(move|app|{
        let ui=build_with_mode(app,true);let root=root.clone();let sample=root.join("file café # & demo.txt");
        *ui.files_ready.borrow_mut()=true;*ui.files.borrow_mut()=vec![sample.clone()];
        ui.page(Page::Files);ui.search.set_text("file café");
        let provider_done=Rc::new(Cell::new(false));let done=done.clone();
        let mut phase=0;let started=std::time::Instant::now();
        glib::timeout_add_local(Duration::from_millis(220),move||{
            assert!(started.elapsed()<Duration::from_secs(35),"UI verification timed out at phase {phase}");
            match phase{
                0=>{
                    let selected=ui.selected().unwrap();assert_eq!(fileactions::path(&selected).as_ref(),Some(&sample));
                    let menu=gtk::Box::new(gtk::Orientation::Vertical,6);let popup=gtk::Popover::new();ui.file_actions(&menu,&popup,&selected);
                    for label in ["Reveal in Dolphin","Copy Path","Move to Trash","Copy File","Open With…","Get Info"]{assert!(test_widget(menu.upcast_ref(),&|w|w.clone().downcast::<gtk::Button>().is_ok_and(|b|b.label().as_deref()==Some(label))).is_some(),"Missing file action {label}");}
                    ui.file_action(fileactions::FileAction::Info,sample.clone());
                }
                1=>{
                    let Some(preview)=ui.preview_window.borrow().as_ref().cloned()else{return glib::ControlFlow::Continue;};
                    let text=test_widget(preview.upcast_ref(),&|w|w.is::<gtk::TextView>()).unwrap().downcast::<gtk::TextView>().unwrap().buffer();assert!(text.text(&text.start_iter(),&text.end_iter(),false).contains("text/plain"));
                    close(&ui);ui.file_action(fileactions::FileAction::OpenWith,sample.clone());
                }
                2=>{
                    window("Open With").unwrap().close();
                    ui.secure_vault.lock().unwrap().unlock(b"features fixture master password",true).unwrap();
                    let selected=item("clip:fixture","Fixture pin","","edit-paste-symbolic","Text",Action::Copy("A pinned fixture\nsecond line".into()));ui.pin_clipboard(&selected);
                    assert!(Store::load().unwrap().pinned_clips.is_empty());assert_eq!(ui.secure_vault.lock().unwrap().entries(securevault::now()).unwrap().len(),1);
                    ui.clips.borrow_mut().clear();assert!(ui.clipboard_items().iter().any(|r|r.id.starts_with("vault-pin:")));
                    let selected=item("clip-image:fixture","Fixture image","","image-x-generic-symbolic","Image",Action::ClipboardImage(root.join("ocr.png")));ui.pin_clipboard(&selected);
                    assert_eq!(ui.secure_vault.lock().unwrap().entries(securevault::now()).unwrap().len(),2);
                    ui.page(Page::Root);ui.search.set_text("clip images");assert!(*ui.page.borrow()==Page::Clipboard);
                }
                3=>{
                    assert!(!ui.visible.borrow().is_empty());assert!(ui.visible.borrow().iter().all(|r|matches!(r.action,Action::ClipboardImage(_)|Action::ClipboardTexture(_)|Action::VaultPin(_))));
                    ui.search.set_text("clip pinned");assert_eq!(ui.visible.borrow().len(),3);
                    let image=ui.visible.borrow().iter().find(|r|r.badge=="Secure image").unwrap().clone();
                    use std::os::unix::fs::PermissionsExt;let path=core::data_dir().join("clipboard-vault.json");assert_eq!(fs::metadata(&path).unwrap().permissions().mode()&0o777,0o600);ui.pin_clipboard(&image);assert!(Store::load().unwrap().pinned_clips.is_empty());assert_eq!(ui.secure_vault.lock().unwrap().entries(securevault::now()).unwrap().len(),1);
                    ui.clear_clipboard();let dialog=confirmation();confirmation_button(&dialog,"confirmation-cancel").emit_clicked();assert_eq!(clear_count(&root),2);
                }
                4=>{
                    ui.execute_booster(boosters::Operation::Advanced(advanced::Operation::Install{manager:"apt".into(),package:"ui-demo-app".into(),remote:String::new()}));
                    assert!(!ui.booster_busy.get());let dialog=confirmation();confirmation_button(&dialog,"confirmation-cancel").emit_clicked();
                    assert!(!fs::read_to_string(root.join("calls.jsonl")).unwrap().contains("ui-demo-app"));
                    ui.execute_booster(boosters::Operation::Advanced(advanced::Operation::Install{manager:"apt".into(),package:"ui-demo-app".into(),remote:String::new()}));confirmation_button(&confirmation(),"confirmation-accept").emit_clicked();
                }
                5=>{
                    if ui.booster_busy.get(){return glib::ControlFlow::Continue;}
                    assert!(fs::read_to_string(root.join("calls.jsonl")).unwrap().contains("ui-demo-app"));
                    ui.execute_booster(boosters::Operation::Advanced(advanced::Operation::Service{system:true,action:"stop".into(),unit:"demo.service".into()}));assert!(!ui.booster_busy.get());confirmation_button(&confirmation(),"confirmation-cancel").emit_clicked();
                    let trash=root.join("ui-trash.txt");fs::write(&trash,"disposable UI fixture").unwrap();ui.file_action(fileactions::FileAction::Trash,trash.clone());confirmation_button(&confirmation(),"confirmation-cancel").emit_clicked();assert!(trash.exists());
                }
                6=>{
                    let trash=root.join("ui-trash.txt");ui.file_action(fileactions::FileAction::Trash,trash.clone());ui.search.set_text("different selection");confirmation_button(&confirmation(),"confirmation-accept").emit_clicked();
                }
                7=>{
                    if root.join("ui-trash.txt").exists(){return glib::ControlFlow::Continue;}assert!(sample.exists(),"Trash action must retain the originally confirmed target");
                    ui.execute_booster(boosters::Operation::Advanced(advanced::Operation::QrInput));let input=window("Generate QR Code").unwrap();test_widget(input.upcast_ref(),&|w|w.is::<gtk::Entry>()).unwrap().downcast::<gtk::Entry>().unwrap().set_text("Hello Spotlight café");button(&input,"Generate").emit_clicked();
                }
                8=>{let Some(qr)=window("QR code")else{return glib::ControlFlow::Continue;};assert!(button(&qr,"Copy Image").is_visible());close(&ui);ui.execute_booster(boosters::Operation::Advanced(advanced::Operation::OcrLatest));}
                9=>{
                    let Some(preview)=window("Extracted text")else{return glib::ControlFlow::Continue;};
                    let buffer=test_widget(preview.upcast_ref(),&|w|w.is::<gtk::TextView>()).unwrap().downcast::<gtk::TextView>().unwrap().buffer();assert!(buffer.text(&buffer.start_iter(),&buffer.end_iter(),false).contains("Spotlight"));close(&ui);
                    let provider=fileactions::copy_provider(&sample);assert!(provider.formats().mime_types().iter().any(|m|m=="text/uri-list"));assert!(provider.formats().mime_types().iter().any(|m|m=="x-special/gnome-copied-files"));
                    let output=gio::MemoryOutputStream::new_resizable();let stream=output.clone();let done=provider_done.clone();let expected=gio::File::for_path(&sample).uri().to_string();
                    provider.write_mime_type_async("text/uri-list",&output,glib::Priority::DEFAULT,None::<&gio::Cancellable>,move|result|{result.unwrap();stream.close(None::<&gio::Cancellable>).unwrap();assert_eq!(stream.steal_as_bytes().as_ref(),format!("{expected}\r\n").as_bytes());done.set(true);});
                }
                10=>{
                    if !provider_done.get(){return glib::ControlFlow::Continue;}
                    ui.page(Page::Root);ui.search.set_text("ip");
                }
                11=>{
                    if !ui.visible.borrow().iter().any(|i|i.title=="203.0.113.20"){return glib::ControlFlow::Continue;}
                    assert_eq!(clear_count(&root),2);assert!(!fs::read_to_string(core::data_dir().join("data.json")).unwrap().contains("203.0.113.20"));
                    capture_test_window(ui.window.upcast_ref(),"/tmp/spotlight-features-preview.png");
                    println!("Native GTK UI passed: file actions/info/Open With, immutable Trash targets, pin persistence and filters, cancelled clearing, install/service confirmations, QR/OCR previews, file-copy MIME payload, inline IP, and private usage history.");
                    done.set(true);ui.window.application().unwrap().quit();return glib::ControlFlow::Break;
                }
                _=>unreachable!(),
            }
            phase+=1;glib::ControlFlow::Continue
        });
    });
    app.run_with_args(&["spotlight-features-test"]);
    assert!(completed.get());
}

#[test]
#[ignore = "closes only disposable fixture windows; run tests/window_controls_smoke.py"]
fn kwin_window_controls() {
    let root = PathBuf::from(
        std::env::var_os("SPOTLIGHT_WINDOW_CONTROLS_ROOT")
            .expect("Run tests/window_controls_smoke.py"),
    );
    assert!(core::data_dir().starts_with(&root));
    let tag = std::env::var("SPOTLIGHT_WINDOW_CONTROLS_TAG").unwrap();
    assert!(tag.starts_with("Spotlight Control Fixture "));
    let expected_pid = std::env::var("SPOTLIGHT_WINDOW_CONTROLS_KILL_PID")
        .unwrap()
        .parse::<u32>()
        .unwrap();
    let context = glib::MainContext::default();
    let _guard = context.acquire().unwrap();
    let _bridge = windowing::register().unwrap();
    let mainloop = glib::MainLoop::new(Some(&context), false);
    let (tx, rx) = mpsc::channel();
    std::thread::spawn(move || {
        let result = std::panic::catch_unwind(|| {
            for mode in ["close", "quit", "kill"] {
                let filter = format!("{tag} {mode}");
                let rows = advanced::fetch(&advanced::Query::Windows {
                    mode: mode.into(),
                    filter: filter.clone(),
                })
                .unwrap();
                let op = rows
                    .into_iter()
                    .find_map(|r| r.operation)
                    .expect("A disposable fixture window must be found");
                let boosters::Operation::Advanced(op) = op else {
                    panic!("Unexpected action")
                };
                if mode == "kill" {
                    let advanced::Operation::Window { pid, started, .. } = &op else {
                        unreachable!()
                    };
                    assert_eq!(*pid, expected_pid);
                    let mut stale = op.clone();
                    if let advanced::Operation::Window { started, .. } = &mut stale {
                        *started = started.saturating_add(1);
                    }
                    assert!(advanced::execute(stale).is_err());
                    assert_eq!(boosters::process_identity(*pid).unwrap(), *started);
                }
                advanced::execute(op).unwrap();
            }
        })
        .map_err(|_| "KWin fixture action failed".to_string());
        let _ = tx.send(result);
    });
    let result = Rc::new(RefCell::new(None));
    let returned = result.clone();
    let loop2 = mainloop.clone();
    let started = std::time::Instant::now();
    glib::timeout_add_local(Duration::from_millis(50), move || match rx.try_recv() {
        Ok(value) => {
            *returned.borrow_mut() = Some(value);
            loop2.quit();
            glib::ControlFlow::Break
        }
        Err(mpsc::TryRecvError::Empty) if started.elapsed() < Duration::from_secs(25) => {
            glib::ControlFlow::Continue
        }
        _ => {
            *returned.borrow_mut() = Some(Err("KWin fixture timed out".into()));
            loop2.quit();
            glib::ControlFlow::Break
        }
    });
    mainloop.run();
    result.borrow_mut().take().unwrap().unwrap();
    println!(
        "Live KWin close/quit and targeted force-quit passed; stale PID identity was rejected."
    );
}

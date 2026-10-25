use crate::*;
use std::{fs, sync::mpsc};
async fn pause(ms: u64) {
    glib::timeout_future(Duration::from_millis(ms)).await;
}
async fn worker<T: Send + 'static>(f: impl FnOnce() -> T + Send + 'static) -> T {
    let (tx, rx) = mpsc::channel();
    std::thread::spawn(move || {
        let _ = tx.send(f());
    });
    loop {
        match rx.try_recv() {
            Ok(v) => return v,
            Err(mpsc::TryRecvError::Empty) => pause(20).await,
            Err(e) => panic!("{e}"),
        }
    }
}
fn launch_query(ui: &Rc<Ui>, query: &str) {
    ui.search.set_text(query);
    ui.refresh();
    let row = ui
        .visible
        .borrow()
        .first()
        .unwrap_or_else(|| panic!("No result for {query}"))
        .clone();
    ui.launch(row);
}
async fn fixture(root: &std::path::Path, kind: &str, result: &str) -> String {
    let path = root.join(result);
    if let Ok(id) = fs::read_to_string(root.join("fixture-window-id")) {
        worker(move || windowing::focus(&id)).await.unwrap();
        pause(200).await;
    }
    fs::write(
        root.join("command.json"),
        serde_json::to_vec(&serde_json::json!({"kind":kind,"result":result})).unwrap(),
    )
    .unwrap();
    for _ in 0..150 {
        if path.exists() {
            return fs::read_to_string(path).unwrap();
        }
        pause(20).await;
    }
    panic!("Fixture timed out: {kind}")
}
#[test]
#[ignore = "requires a disposable KWin fixture; run tests/workflow_smoke.py"]
fn native_workflows() {
    let root = PathBuf::from(std::env::var_os("SPOTLIGHT_WORKFLOW_ROOT").unwrap());
    assert!(core::data_dir().starts_with(&root));
    let tag = std::env::var("SPOTLIGHT_WORKFLOW_TAG").unwrap();
    let app = gtk::Application::builder()
        .application_id(format!("local.spotlight.Workflow.Test.f{tag}"))
        .build();
    let completed = Rc::new(Cell::new(false));
    let done = completed.clone();
    app.connect_activate(move |app| {
        let timeout_app=app.clone();glib::timeout_add_local_once(Duration::from_secs(25),move ||timeout_app.quit());
        let ui=build_with_mode(app,true);let root=root.clone();let tag=tag.clone();let done=done.clone();
        glib::MainContext::default().spawn_local(async move {
            launch_query(&ui,"todo add buy milk");
            assert!(fs::read_to_string(core::data_dir().join("todos.md")).unwrap().contains("- [ ] buy milk"));
            ui.search.set_text("milk");ui.refresh();assert!(ui.visible.borrow().iter().any(|i|i.id.starts_with("todo:")));
            launch_query(&ui,"todo");assert!(fs::read_to_string(core::data_dir().join("todos.md")).unwrap().contains("- [x] buy milk"));
            launch_query(&ui,"todo done");assert!(fs::read_to_string(core::data_dir().join("todos.md")).unwrap().contains("- [ ] buy milk"));
            ui.toggle_caffeinate();assert!(ui.caffeinate.borrow().is_some());
            launch_query(&ui,"pomodoro 1s");assert!(ui.pomodoro_awake.borrow().is_some());
            assert!(Store::load().unwrap().reminders.iter().any(|r|r.pomodoro));
            pause(1800).await;ui.check_reminders();assert!(ui.pomodoro_awake.borrow().is_none());assert!(ui.caffeinate.borrow().is_some());ui.dismiss_alarms();
            ui.toggle_caffeinate();launch_query(&ui,"pomodoro 25m");
            assert!(ui.pomodoro_awake.borrow().is_some());
            let id=ui.store.borrow().reminders.iter().find(|r|r.pomodoro).unwrap().id.clone();ui.cancel_reminder(&id);
            assert!(ui.pomodoro_awake.borrow().is_none());assert!(ui.caffeinate.borrow().is_none());
            launch_query(&ui,"layout save work");
            for _ in 0..150 {if !ui.layout_busy.get(){break;}pause(20).await;}
            assert!(!ui.layout_busy.get(),"{}",ui.notice.text());
            let all=Store::load().unwrap().window_layouts.remove("work").expect("Saved layout");
            let original=all.into_iter().find(|p|p.title==format!("Spotlight Workflow Fixture {tag}")).expect("Fixture placement");
            let mut moved=original.clone();moved.x+=80.;moved.y+=60.;moved.width=450.;moved.height=280.;
            let changed=moved.clone();worker(move ||windowing::restore_layout(&[changed])).await.unwrap();pause(400).await;
            let target_id=original.id.clone();let captured=worker(windowing::capture_layout).await.unwrap();let actual=captured.iter().find(|p|p.id==target_id).unwrap();
            assert!((actual.width-moved.width).abs()<3.,"Moved fixture: {actual:?}");
            ui.store.borrow_mut().window_layouts.insert("work".into(),vec![original.clone()]);
            launch_query(&ui,"layout work");for _ in 0..150 {if !ui.layout_busy.get(){break;}pause(20).await;}pause(300).await;
            let captured=worker(windowing::capture_layout).await.unwrap();let actual=captured.iter().find(|p|p.id==target_id).unwrap();
            assert!((actual.x-original.x).abs()<3. && (actual.y-original.y).abs()<3. && (actual.width-original.width).abs()<3.,"Restored fixture: {actual:?} vs {original:?}");
            fs::write(root.join("fixture-window-id"),&target_id).unwrap();
            // The queue editor's up button must change actual paste order.
            let second_id={let mut vault=ui.secure_vault.lock().unwrap();vault.unlock(b"queue fixture master password",true).unwrap();let second=vault.add(&securevault::Payload::Text("Second β".into()),securevault::now()).unwrap();vault.add(&securevault::Payload::Text("First α".into()),securevault::now()).unwrap();second};
            launch_query(&ui,"clip queue");
            let dialog=gtk::Window::list_toplevels().into_iter().filter_map(|w|w.downcast::<gtk::Window>().ok()).find(|w|w.title().as_deref()==Some("Clipboard paste queue")).unwrap();
            let second=test_widget(dialog.upcast_ref(),&|w|w.widget_name()==second_id).unwrap();
            let up=test_widget(&second,&|w|w.clone().downcast::<gtk::Button>().is_ok_and(|b|b.label().as_deref()==Some("↑"))).unwrap().downcast::<gtk::Button>().unwrap();up.emit_clicked();
            pause(350).await;
            test_widget(dialog.upcast_ref(),&|w|w.clone().downcast::<gtk::Button>().is_ok_and(|b|b.label().as_deref()==Some("Start paste queue"))).unwrap().downcast::<gtk::Button>().unwrap().emit_clicked();
            pause(500).await;assert!(ui.paste_queue.borrow().as_ref().unwrap().active.get(),"Klipper must not drain queue");
            let focus_id=target_id.clone();worker(move ||windowing::focus(&focus_id)).await.unwrap();pause(250).await;
            assert_eq!(fixture(&root,"paste","paste-1").await,"Second β");pause(250).await;
            assert_eq!(fixture(&root,"paste","paste-2").await,"First α");pause(250).await;
            assert!(!ui.paste_queue.borrow().as_ref().unwrap().active.get());
            let image_path=root.join("queue.png");
            let bytes=glib::Bytes::from_owned(vec![255u8,0,0,255,0,255,0,255]);
            let texture=gdk::MemoryTexture::new(2,1,gdk::MemoryFormat::R8g8b8a8,&bytes,8);
            texture.save_to_png(&image_path).unwrap();
            let mixed=vec![clipboard::Pinned::Image{id:"image".into(),path:image_path},clipboard::Pinned::Text{id:"last".into(),value:"After image".into()}];
            let images=pastequeue::Queue::new(ui.window.clipboard(),&mixed).unwrap();images.publish();pause(600).await;
            assert!(images.ready.get(),"{:?}",images.error.borrow());
            assert_eq!(fixture(&root,"image","image-size").await,"2x1");pause(250).await;
            assert_eq!(fixture(&root,"paste","after-image").await,"After image");pause(200).await;
            assert!(!images.active.get());
            images.stop();
            assert_eq!(fixture(&root,"paste","stopped-last").await,"");
            let q=pastequeue::Queue::new(ui.window.clipboard(),&[clipboard::Pinned::Text{id:"first".into(),value:"First α".into()},clipboard::Pinned::Text{id:"second".into(),value:"Second β".into()}]).unwrap();q.publish();pause(600).await;
            let replacement=pastequeue::Queue::new(ui.window.clipboard(),&[clipboard::Pinned::Text{id:"external".into(),value:"External clipboard replacement".into()}]).unwrap();replacement.publish();pause(700).await;
            assert!(!q.active.get(),"External clipboard ownership cancels queue");q.stop();
            let focus_id=target_id.clone();worker(move ||windowing::focus(&focus_id)).await.unwrap();pause(300).await;
            assert_eq!(fixture(&root,"paste","external-copy").await,"External clipboard replacement");
            println!("Workflows passed: Markdown add/search/complete/reopen, persisted Pomodoro expiry/cancellation with independent Caffeinate, real KWin save/move/restore, reordered cross-process GTK pastes, Klipper idle protection and external-copy cancellation.");
            done.set(true);ui.window.application().unwrap().quit();
        });
    });
    app.run_with_args(&["spotlight-workflow-test"]);
    assert!(completed.get());
}

mod about;
mod advanced;
mod advanced_ui;
mod automation;
mod automation_ui;
mod autostart;
mod boosters;
mod caffeinate;
mod calendar;
mod clipboard;
mod clipimage;
mod color;
mod contextai;
mod core;
mod currency;
mod customization;
#[cfg(test)]
mod deep_features_smoke;
mod desktop;
mod devkit;
mod devkit_ui;
mod devtools;
#[cfg(test)]
mod devtools_smoke;
mod dotfiles;
mod emoji;
mod extensions;
#[cfg(test)]
mod features_smoke;
mod fileactions;
mod fileignore;
mod fonts;
mod guide;
mod interface;
mod localai;
mod localtools;
mod localtools_ui;
mod measure;
mod mpris;
mod offline;
mod opener;
mod pastequeue;
mod pim;
mod pluginstore;
mod productivity;
#[cfg(test)]
mod productivity_smoke;
mod quicknote;
mod reminder;
mod search;
mod securevault;
mod securevault_ui;
mod shortcut;
mod snippets;
mod systemtools;
mod systemtools_ui;
mod texttools;
mod theme;
mod todos;
mod updates;
#[cfg(test)]
mod usability_smoke;
mod wasmplugins;
mod windowing;
mod workflow;
#[cfg(test)]
mod workflow_smoke;
use core::{Store, TextItem};
use gtk::{gdk, gio, glib, prelude::*};
use std::{
    cell::{Cell, RefCell},
    path::PathBuf,
    process::Command,
    rc::Rc,
    sync::mpsc,
    time::Duration,
};

type BoosterCache = std::collections::HashMap<
    boosters::Query,
    (std::time::Instant, Result<Vec<boosters::Entry>, String>),
>;

#[derive(Clone, Copy, PartialEq)]
enum Page {
    Root,
    Files,
    Recent,
    Clipboard,
    Snippets,
    Links,
    Notes,
    Scripts,
    Emoji,
    Fonts,
    Colors,
    Windows,
}
impl Page {
    fn title(self) -> &'static str {
        match self {
            Self::Root => "Suggestions",
            Self::Files => "Search File · home folder",
            Self::Recent => "Recent · files & folders",
            Self::Clipboard => "Clipboard history · KDE Klipper",
            Self::Snippets => "Snippets",
            Self::Links => "Quicklinks",
            Self::Notes => "Notes",
            Self::Scripts => "Plugins & script commands",
            Self::Emoji => "Everyday emoji & symbols",
            Self::Fonts => "Installed Fonts",
            Self::Colors => "Color Formats",
            Self::Windows => "Window Manager · active window",
        }
    }
    fn placeholder(self) -> &'static str {
        match self {
            Self::Root => "Search apps, commands, or the web…",
            Self::Files => "Search your files…",
            Self::Recent => "Search recent files & folders…",
            Self::Clipboard => "Search clipboard history…",
            Self::Snippets => "Search snippets…",
            Self::Links => "Search quicklinks…",
            Self::Notes => "Search notes…",
            Self::Scripts => "Search script commands…",
            Self::Emoji => "Search everyday emoji…",
            Self::Fonts => "Search installed fonts…",
            Self::Colors => "Search HEX, RGB, HSL, HSV…",
            Self::Windows => "Search window actions…",
        }
    }
}
#[derive(Clone)]
enum Action {
    Automation(automation_ui::Command),
    Vault,
    VaultPin(String),
    Workflow(workflow::Operation),
    Extension(extensions::Manifest),
    RunExtension {
        manifest: extensions::Manifest,
        args: Vec<String>,
        key: String,
    },
    ClipboardImage(PathBuf),
    ClipboardTexture(gdk::Texture),
    ClearClipboard,
    EmojiTones,
    Preview {
        title: String,
        text: String,
        open: Option<String>,
    },
    DesktopSnippets,
    Query(String),
    Booster(boosters::Operation),
    App(gio::AppInfo),
    Page(Page),
    Open(String),
    Copy(String),
    Snippet(String),
    Edit(Page, usize),
    Script(PathBuf),
    System(Vec<String>),
    Window(&'static str),
    New(Page),
    Settings,
    Walkthrough,
    Quit,
    MoreResults,
    FontPreview(String),
    ResetFont,
    Noop,
    PickColor,
    MeasureScreen,
    Caffeinate,
    Desktop(desktop::Command),
    AlarmSetup,
    TimerSetup,
    DismissAlarms,
    QuickNote(String),
    CaptureNote(String),
    Schedule(reminder::Draft),
    CancelReminder(String),
    CalendarEvent(calendar::Draft),
}
#[derive(Clone)]
struct Item {
    image: Option<gdk::Texture>,
    priority: i32,
    thumbnail: Option<PathBuf>,
    id: String,
    title: String,
    subtitle: String,
    badge: String,
    icon: String,
    gicon: Option<gio::Icon>,
    keywords: String,
    action: Action,
}
fn item(id: &str, title: &str, subtitle: &str, icon: &str, badge: &str, action: Action) -> Item {
    Item {
        image: None,
        priority: 0,
        thumbnail: None,
        id: id.into(),
        title: title.into(),
        subtitle: subtitle.into(),
        badge: badge.into(),
        icon: icon.into(),
        gicon: None,
        keywords: String::new(),
        action,
    }
}
struct Ui {
    vault_clipboard: RefCell<Option<gdk::ContentProvider>>,
    workflow_capture: RefCell<Option<WorkflowCapture>>,
    secure_vault: std::sync::Arc<std::sync::Mutex<securevault::Vault>>,
    window: gtk::ApplicationWindow,
    search: gtk::Entry,
    list: gtk::ListBox,
    section: gtk::Label,
    notice: gtk::Label,
    hint: gtk::Label,
    awake_status: gtk::Label,
    add: gtk::Button,
    back: gtk::Button,
    window_shortcuts: gtk::Button,
    file_shortcuts: gtk::Box,
    store: RefCell<Store>,
    can_save: bool,
    page: RefCell<Page>,
    apps: RefCell<Vec<Item>>,
    fonts: Vec<String>,
    font_css: gtk::CssProvider,
    theme_css: gtk::CssProvider,
    interface_css: gtk::CssProvider,
    guide_step: Cell<usize>,
    visible: RefCell<Vec<Item>>,
    rendered_search: RefCell<Option<(Page, String)>>,
    files: RefCell<Vec<PathBuf>>,
    file_loading: RefCell<bool>,
    files_ready: RefCell<bool>,
    clips: RefCell<Vec<String>>,
    clip_images: RefCell<Vec<clipimage::Image>>,
    clip_current: RefCell<Option<(gdk::Texture, Option<gdk::Texture>)>>,
    clip_generation: Cell<u64>,
    _window_bridge: Option<windowing::Bridge>,
    extensions: RefCell<Vec<extensions::Manifest>>,
    extension_errors: RefCell<Vec<String>>,
    extensions_loading: Cell<bool>,
    extension_session: RefCell<Option<ExtensionSession>>,
    content_session: RefCell<Option<ContentSession>>,
    result_limit: Cell<usize>,
    currency: RefCell<currency::State>,
    booster_cache: RefCell<BoosterCache>,
    booster_pending: RefCell<std::collections::HashSet<boosters::Query>>,
    booster_busy: Cell<bool>,
    desktop_snippets_running: Cell<bool>,
    recents: RefCell<Vec<(PathBuf, i64)>>,
    recents_loading: Cell<bool>,
    thumbnails: RefCell<search::Thumbnails>,
    thumbnail_targets: RefCell<std::collections::HashMap<PathBuf, Vec<glib::WeakRef<gtk::Image>>>>,
    thumbnails_polling: Cell<bool>,
    preview_window: RefCell<Option<gtk::Window>>,
    picker: RefCell<Option<(String, gio::SignalSubscription)>>,
    picking_color: Cell<bool>,
    picked_color: RefCell<Option<String>>,
    measurement_request: RefCell<Option<(String, gio::SignalSubscription)>>,
    measuring_screen: Cell<bool>,
    measurement_window: RefCell<Option<measure::Ruler>>,
    caffeinate: RefCell<Option<caffeinate::Inhibitor>>,
    pomodoro_awake: RefCell<Option<caffeinate::Inhibitor>>,
    paste_queue: RefCell<Option<Rc<pastequeue::Queue>>>,
    layout_busy: Cell<bool>,
    desktop_snapshot: RefCell<desktop::Snapshot>,
    desktop_loading: Cell<bool>,
    desktop_busy: Cell<bool>,
    desktop_generation: Cell<u64>,
    trash_dialog: RefCell<Option<gtk::Window>>,
    reminder_clock: RefCell<Option<glib::SourceId>>,
    note_editor: RefCell<Option<gtk::Window>>,
    note_draft: RefCell<String>,
    alarm_window: RefCell<Option<gtk::Window>>,
    alarm_repeat: RefCell<Option<glib::SourceId>>,
    alarm_label: RefCell<Option<gtk::Label>>,
    event_editor: RefCell<Option<gtk::Window>>,
}
struct ContentSession {
    query: search::Query,
    cancel: std::sync::Arc<std::sync::atomic::AtomicBool>,
    rows: Vec<boosters::Entry>,
    done: bool,
}
type WorkflowCapture = Box<dyn FnOnce(Result<Option<gtk::gdk_pixbuf::Pixbuf>, String>)>;
impl Drop for ContentSession {
    fn drop(&mut self) {
        self.cancel
            .store(true, std::sync::atomic::Ordering::Relaxed);
    }
}
struct ExtensionSession {
    key: String,
    manifest: extensions::Manifest,
    cancel: std::sync::Arc<std::sync::atomic::AtomicBool>,
    items: Vec<extensions::ResultItem>,
    status: String,
    done: bool,
}
impl Drop for ExtensionSession {
    fn drop(&mut self) {
        self.cancel
            .store(true, std::sync::atomic::Ordering::Relaxed);
    }
}
impl Ui {
    fn error(&self, text: &str) {
        self.notice.set_text(text);
        self.notice.set_visible(!text.is_empty());
    }
    fn save(&self) {
        if !self.can_save {
            self.error("Saved data is unreadable; saving is disabled to preserve data.json.");
            return;
        }
        if let Err(e) = self.store.borrow().save() {
            self.error(&format!("Could not save: {e}"));
        } else {
            let store = self.store.borrow();
            if let Err(e) = snippets::sync(&store.snippets, store.desktop_snippets) {
                self.error(&format!("Could not sync snippet triggers: {e}"));
            }
        }
    }
    fn selected(&self) -> Option<Item> {
        let index = self.list.selected_row()?.index() as usize;
        self.visible.borrow().get(index).cloned()
    }
    fn page(self: &Rc<Self>, page: Page) {
        *self.page.borrow_mut() = page;
        self.result_limit.set(60);
        self.error("");
        self.search.set_text("");
        self.search.set_placeholder_text(Some(page.placeholder()));
        self.back.set_visible(page != Page::Root);
        self.add
            .set_visible(matches!(page, Page::Snippets | Page::Links | Page::Notes));
        self.window_shortcuts.set_visible(page == Page::Windows);
        self.file_shortcuts.set_visible(page == Page::Root);
        self.search.grab_focus();
        if page == Page::Files {
            self.load_files();
        }
        if page == Page::Recent {
            self.load_recents();
        }
        if page == Page::Clipboard {
            self.load_clipboard();
        }
        if page == Page::Scripts {
            self.load_extensions();
        }
        self.refresh();
    }
    fn load_files(self: &Rc<Self>) {
        if *self.files_ready.borrow() || *self.file_loading.borrow() {
            return;
        }
        *self.file_loading.borrow_mut() = true;
        let (tx, rx) = mpsc::channel();
        std::thread::spawn(move || {
            let _ = tx.send(core::index_files());
        });
        let weak = Rc::downgrade(self);
        glib::timeout_add_local(Duration::from_millis(80), move || {
            let Some(ui) = weak.upgrade() else {
                return glib::ControlFlow::Break;
            };
            match rx.try_recv() {
                Ok(result) => {
                    let files = match result {
                        Ok(files) => files,
                        Err(error) => {
                            ui.files.borrow_mut().clear();
                            *ui.file_loading.borrow_mut() = false;
                            ui.error(&error);
                            return glib::ControlFlow::Break;
                        }
                    };
                    *ui.files.borrow_mut() = files;
                    *ui.file_loading.borrow_mut() = false;
                    *ui.files_ready.borrow_mut() = true;
                    ui.refresh();
                    glib::ControlFlow::Break
                }
                Err(mpsc::TryRecvError::Empty) => glib::ControlFlow::Continue,
                Err(_) => {
                    *ui.file_loading.borrow_mut() = false;
                    ui.error("File indexing failed");
                    glib::ControlFlow::Break
                }
            }
        });
    }
    fn file_items(&self, query: &str, recent_only: bool) -> Vec<Item> {
        let files = self.files.borrow();
        let recent = self.recents.borrow();
        let indexed = if recent_only {
            &[][..]
        } else {
            files.as_slice()
        };
        let mut seen = std::collections::HashSet::new();
        let mut matches: Vec<_> = recent
            .iter()
            .map(|(p, _)| p)
            .chain(indexed.iter())
            .filter(|p| !core::hidden_path(p))
            .filter(|p| seen.insert(p.to_path_buf()))
            .filter_map(|path| {
                let name = path.file_name()?.to_string_lossy();
                let score = if query.contains('/') {
                    core::score(query, &path.to_string_lossy())
                } else {
                    core::score(query, &name)
                }?;
                let rank = recent.iter().position(|(p, _)| p == path);
                Some((
                    score + rank.map(|i| 100 - i.min(90) as i32).unwrap_or(0),
                    path,
                ))
            })
            .collect();
        matches.sort_unstable_by(|a, b| b.0.cmp(&a.0).then_with(|| a.1.cmp(b.1)));
        matches
            .into_iter()
            .take(60)
            .filter_map(|(_, path)| {
                let name = path.file_name()?.to_string_lossy();
                let full_path = path.to_string_lossy();
                let mut result = item(
                    &full_path,
                    &name,
                    &full_path,
                    if path.is_dir() {
                        "folder-symbolic"
                    } else {
                        "text-x-generic-symbolic"
                    },
                    if recent.iter().any(|(p, _)| p == path) {
                        "Recent"
                    } else {
                        "File"
                    },
                    Action::Open(gio::File::for_path(path).uri().to_string()),
                );
                if search::image_path(path) {
                    result.thumbnail = Some(path.clone());
                }
                result.priority = recent
                    .iter()
                    .position(|(p, _)| p == path)
                    .map(|i| 90 - i.min(89) as i32)
                    .unwrap_or(0);
                Some(result)
            })
            .collect()
    }
    fn load_recents(self: &Rc<Self>) {
        if self.recents_loading.replace(true) {
            return;
        }
        let (tx, rx) = mpsc::channel();
        std::thread::spawn(move || {
            let _ = tx.send(search::recent());
        });
        let weak = Rc::downgrade(self);
        glib::timeout_add_local(Duration::from_millis(80), move || {
            let Some(ui) = weak.upgrade() else {
                return glib::ControlFlow::Break;
            };
            match rx.try_recv() {
                Ok(result) => {
                    ui.recents_loading.set(false);
                    match result {
                        Ok(recents) => *ui.recents.borrow_mut() = recents,
                        Err(error) => {
                            ui.recents.borrow_mut().clear();
                            ui.error(&error);
                        }
                    }
                    if ui.window.is_visible() {
                        ui.refresh();
                    }
                    glib::ControlFlow::Break
                }
                Err(mpsc::TryRecvError::Empty) => glib::ControlFlow::Continue,
                Err(_) => {
                    ui.recents_loading.set(false);
                    glib::ControlFlow::Break
                }
            }
        });
    }
    fn thumbnail(self: &Rc<Self>, path: &std::path::Path, image: &gtk::Image) {
        if let Some(bytes) = self.thumbnails.borrow_mut().request(path) {
            if let Ok(texture) = gdk::Texture::from_bytes(&glib::Bytes::from_owned(bytes)) {
                image.set_paintable(Some(&texture));
            }
        } else {
            let mut targets = self.thumbnail_targets.borrow_mut();
            targets.retain(|_, images| {
                images.retain(|i| i.upgrade().is_some());
                !images.is_empty()
            });
            targets
                .entry(path.into())
                .or_default()
                .push(image.downgrade());
        }
        if self.thumbnails.borrow().pending() && !self.thumbnails_polling.replace(true) {
            let weak = Rc::downgrade(self);
            glib::timeout_add_local(Duration::from_millis(80), move || {
                let Some(ui) = weak.upgrade() else {
                    return glib::ControlFlow::Break;
                };
                let changes = ui.thumbnails.borrow_mut().collect();
                for (path, data) in changes {
                    let images = ui
                        .thumbnail_targets
                        .borrow_mut()
                        .remove(&path)
                        .unwrap_or_default();
                    if let Some(data) = data
                        && let Ok(texture) =
                            gdk::Texture::from_bytes(&glib::Bytes::from_owned(data))
                    {
                        for image in images.into_iter().filter_map(|i| i.upgrade()) {
                            image.set_paintable(Some(&texture));
                        }
                    }
                }
                if ui.thumbnails.borrow().pending() {
                    glib::ControlFlow::Continue
                } else {
                    ui.thumbnails_polling.set(false);
                    glib::ControlFlow::Break
                }
            });
        }
    }
    fn load_clipboard(self: &Rc<Self>) {
        if self
            .paste_queue
            .borrow()
            .as_ref()
            .is_some_and(|q| q.active.get())
        {
            return;
        }
        self.capture_clipboard_image();
        let generation = self.clip_generation.get();
        self.clips.borrow_mut().clear();
        let (tx, rx) = mpsc::channel();
        std::thread::spawn(move || {
            let result = (|| -> Result<Vec<String>, String> {
                let bus = gio::bus_get_sync(gio::BusType::Session, None::<&gio::Cancellable>)
                    .map_err(|e| e.to_string())?;
                let call = |method: &str, args: Option<&glib::Variant>| {
                    bus.call_sync(
                        Some("org.kde.klipper"),
                        "/klipper",
                        "org.kde.klipper.klipper",
                        method,
                        args,
                        None,
                        gio::DBusCallFlags::NONE,
                        800,
                        None::<&gio::Cancellable>,
                    )
                    .map_err(|e| e.to_string())
                };
                let menu = call("getClipboardHistoryMenu", None)?
                    .get::<(Vec<String>,)>()
                    .ok_or("Unexpected clipboard response")?
                    .0;
                let mut texts = Vec::new();
                for i in 0..menu.len().min(60) {
                    let response =
                        call("getClipboardHistoryItem", Some(&(i as i32,).to_variant()))?;
                    if let Some((s,)) = response.get::<(String,)>()
                        && !s.is_empty()
                        && s.len() < 65536
                    {
                        texts.push(s);
                    }
                }
                Ok(texts)
            })();
            let images = clipimage::history();
            let _ = tx.send((result, images));
        });
        let weak = Rc::downgrade(self);
        glib::timeout_add_local(Duration::from_millis(80), move || {
            let Some(ui) = weak.upgrade() else {
                return glib::ControlFlow::Break;
            };
            if ui.clip_generation.get() != generation {
                return glib::ControlFlow::Break;
            }
            match rx.try_recv() {
                Ok((result, images)) => {
                    match images {
                        Ok(images) => *ui.clip_images.borrow_mut() = images,
                        Err(error) => ui.error(&error),
                    }
                    match result{Ok(texts)=>*ui.clips.borrow_mut()=texts,Err(_)=>ui.error("Clipboard history requires KDE Klipper. Enable it in your system tray.")};
                    ui.refresh();
                    glib::ControlFlow::Break
                }
                Err(mpsc::TryRecvError::Empty) => glib::ControlFlow::Continue,
                Err(_) => glib::ControlFlow::Break,
            }
        });
    }
    fn capture_clipboard_image(self: &Rc<Self>) {
        if self
            .window
            .clipboard()
            .formats()
            .contain_mime_type("x-kde-passwordManagerHint")
        {
            self.clip_current.borrow_mut().take();
            return;
        }
        let generation = self.clip_generation.get().wrapping_add(1);
        self.clip_generation.set(generation);
        self.clip_current.borrow_mut().take();
        let weak = Rc::downgrade(self);
        self.window
            .clipboard()
            .read_texture_async(None::<&gio::Cancellable>, move |result| {
                let Some(ui) = weak.upgrade() else { return };
                if ui.clip_generation.get() != generation {
                    return;
                }
                let Ok(Some(texture)) = result else { return };
                if i64::from(texture.width()) * i64::from(texture.height()) > 16_000_000 {
                    ui.error("Clipboard image exceeds 16 million pixels");
                    return;
                }
                *ui.clip_current.borrow_mut() = Some((texture.clone(), None));
                let (tx, rx) = mpsc::channel();
                std::thread::spawn(move || {
                    let _ = tx.send(clipimage::thumbnail(&texture));
                });
                let weak = Rc::downgrade(&ui);
                glib::timeout_add_local(Duration::from_millis(80), move || {
                    let Some(ui) = weak.upgrade() else {
                        return glib::ControlFlow::Break;
                    };
                    if ui.clip_generation.get() != generation {
                        return glib::ControlFlow::Break;
                    }
                    match rx.try_recv() {
                        Ok(result) => {
                            if let Ok(data) = result
                                && let Ok(texture) =
                                    gdk::Texture::from_bytes(&glib::Bytes::from_owned(data))
                                && let Some(current) = ui.clip_current.borrow_mut().as_mut()
                            {
                                current.1 = Some(texture);
                            }
                            if *ui.page.borrow() == Page::Clipboard {
                                ui.refresh();
                            }
                            glib::ControlFlow::Break
                        }
                        Err(mpsc::TryRecvError::Empty) => glib::ControlFlow::Continue,
                        Err(_) => glib::ControlFlow::Break,
                    }
                });
            });
    }
    fn clipboard_items(&self) -> Vec<Item> {
        let mut rows = self.pinned_clipboard_items();
        if let Some((texture, preview)) = self.clip_current.borrow().as_ref() {
            let mut row = item(
                "clip-image:current",
                &format!(
                    "Current clipboard image · {} × {}",
                    texture.width(),
                    texture.height()
                ),
                "Enter copies the image · Ctrl+K to preview",
                "image-x-generic-symbolic",
                "Image",
                Action::ClipboardTexture(texture.clone()),
            );
            row.image = preview.clone();
            row.priority = 200;
            rows.push(row);
        }
        for (n, image) in self.clip_images.borrow().iter().enumerate() {
            let mut row = item(
                &format!("clip-image:{n}"),
                &format!("Clipboard image · {} × {}", image.width, image.height),
                "Klipper image history · Enter copies · Ctrl+K previews",
                "image-x-generic-symbolic",
                "Image",
                Action::ClipboardImage(image.path.clone()),
            );
            row.image =
                gdk::Texture::from_bytes(&glib::Bytes::from_owned(image.preview.clone())).ok();
            row.priority = 100 - n as i32;
            rows.push(row);
        }
        rows.extend(self.clips.borrow().iter().enumerate().map(|(i, s)| {
            let mut row = item(
                &format!("clip:{i}"),
                &s.lines()
                    .next()
                    .unwrap_or("Text")
                    .chars()
                    .take(100)
                    .collect::<String>(),
                &format!("{} characters · Enter copies", s.chars().count()),
                "edit-paste-symbolic",
                "Text",
                Action::Copy(s.clone()),
            );
            row.priority = -(i as i32);
            row
        }));
        rows
    }
    fn clipboard_image(self: &Rc<Self>, path: PathBuf, preview: bool) {
        let (tx, rx) = mpsc::channel();
        std::thread::spawn(move || {
            let _ = tx.send(clipimage::load(&path));
        });
        let weak = Rc::downgrade(self);
        glib::timeout_add_local(Duration::from_millis(60), move || {
            let Some(ui) = weak.upgrade() else {
                return glib::ControlFlow::Break;
            };
            match rx.try_recv() {
                Ok(Ok(texture)) => {
                    if preview {
                        ui.image_preview(&texture);
                    } else {
                        ui.window.clipboard().set_texture(&texture);
                        ui.error("Image copied · paste it into your target app");
                    }
                    glib::ControlFlow::Break
                }
                Ok(Err(error)) => {
                    ui.error(&error);
                    glib::ControlFlow::Break
                }
                Err(mpsc::TryRecvError::Empty) => glib::ControlFlow::Continue,
                Err(_) => glib::ControlFlow::Break,
            }
        });
    }
    fn image_preview(self: &Rc<Self>, texture: &gdk::Texture) {
        self.image_preview_named(texture, "Clipboard Image");
    }
    fn image_preview_named(self: &Rc<Self>, texture: &gdk::Texture, title: &str) {
        let dialog = gtk::Window::builder()
            .application(&self.window.application().unwrap())
            .title(title)
            .transient_for(&self.window)
            .modal(true)
            .default_width(640)
            .default_height(460)
            .build();
        let panel = gtk::Box::new(gtk::Orientation::Vertical, 12);
        panel.add_css_class("editor");
        let picture = gtk::Picture::for_paintable(texture);
        picture.set_can_shrink(true);
        picture.set_content_fit(gtk::ContentFit::Contain);
        picture.set_vexpand(true);
        picture.set_hexpand(true);
        panel.append(&picture);
        let copy = gtk::Button::with_label("Copy Image");
        let image = texture.clone();
        let clipboard = self.window.clipboard();
        copy.connect_clicked(move |_| clipboard.set_texture(&image));
        panel.append(&copy);
        if title == "Screenshot" {
            self.screenshot_actions(&panel, texture, &dialog);
        }
        let close = gtk::Button::with_label("Close");
        let weak = dialog.downgrade();
        close.connect_clicked(move |_| {
            if let Some(dialog) = weak.upgrade() {
                dialog.close();
            }
        });
        panel.append(&close);
        dialog.set_child(Some(&panel));
        dialog.present();
    }
    fn color_items(&self) -> Vec<Item> {
        let picked = self.picked_color.borrow();
        let Some(hex) = picked.as_ref() else {
            return vec![item(
                "pick-color-first",
                "Pick a Color",
                "Choose a screen pixel to convert into different formats",
                "color-select-symbolic",
                "Pick",
                Action::PickColor,
            )];
        };
        color::formats(hex)
            .unwrap_or_default()
            .into_iter()
            .map(|format| {
                let subtitle = if format.name.contains("alpha")
                    || format.name == "RGBA"
                    || format.name == "HSLA"
                {
                    format!("{} · opaque alpha · Enter to copy", format.name)
                } else {
                    format!("{} · picked color · Enter to copy", format.name)
                };
                item(
                    &format!("color-format:{}", format.name),
                    &format.value,
                    &subtitle,
                    "●",
                    format.name,
                    Action::Copy(format.value.clone()),
                )
            })
            .collect()
    }
    fn font_items(&self) -> Vec<Item> {
        self.fonts
            .iter()
            .map(|family| {
                item(
                    &format!("font:{family}"),
                    family,
                    "The quick brown fox · Aa Bb 123 · Enter to preview",
                    "preferences-desktop-font-symbolic",
                    "Font",
                    Action::FontPreview(family.clone()),
                )
            })
            .collect()
    }
    fn set_font(self: &Rc<Self>, family: Option<&str>) -> Result<(), String> {
        if !self.can_save {
            return Err("Saved data is unreadable; cannot change the font".into());
        }
        if family.is_some_and(|name| !self.fonts.iter().any(|font| font == name)) {
            return Err("That font is not installed".into());
        }
        let mut store = self.store.borrow_mut();
        let previous = store.selected_font.clone();
        store.selected_font = family.map(str::to_string);
        if let Err(error) = store.save() {
            store.selected_font = previous;
            return Err(error);
        }
        drop(store);
        self.font_css
            .load_from_data(&family.map(fonts::css).unwrap_or_default());
        self.refresh();
        self.error(
            &family
                .map(|name| format!("Spotlight is now using {name}"))
                .unwrap_or_else(|| "Default font restored".into()),
        );
        Ok(())
    }
    fn font_preview(self: &Rc<Self>, family: &str) {
        let dialog = gtk::Window::builder()
            .title(format!("Font Preview · {family}"))
            .application(&self.window.application().unwrap())
            .transient_for(&self.window)
            .modal(true)
            .default_width(620)
            .default_height(330)
            .build();
        let panel = gtk::Box::new(gtk::Orientation::Vertical, 14);
        panel.add_css_class("editor");
        let title = gtk::Label::new(Some(family));
        title.set_xalign(0.);
        title.add_css_class("item-title");
        panel.append(&title);
        let input = gtk::Entry::builder()
            .placeholder_text("Type text to preview")
            .text("The quick brown fox jumps over the lazy dog. 0123456789")
            .build();
        panel.append(&input);
        let sample = gtk::Label::new(Some(&input.text()));
        sample.set_wrap(true);
        sample.set_selectable(true);
        sample.set_xalign(0.);
        sample.set_vexpand(true);
        let mut desc = gtk::pango::FontDescription::new();
        desc.set_family(family);
        desc.set_size(24 * gtk::pango::SCALE);
        let attrs = gtk::pango::AttrList::new();
        attrs.insert(gtk::pango::AttrFontDesc::new(&desc));
        sample.set_attributes(Some(&attrs));
        panel.append(&sample);
        input.connect_changed(move |entry| sample.set_text(&entry.text()));
        let status = gtk::Label::new(Some(
            "Use in Spotlight changes this launcher. Copy Font Name lets you choose it in another app.",
        ));
        status.set_wrap(true);
        status.set_xalign(0.);
        panel.append(&status);
        let buttons = gtk::Box::new(gtk::Orientation::Horizontal, 8);
        buttons.set_halign(gtk::Align::End);
        let close = gtk::Button::with_label("Close");
        let copy = gtk::Button::with_label("Copy Font Name");
        let use_font = gtk::Button::with_label("Use in Spotlight");
        use_font.add_css_class("accent");
        buttons.append(&close);
        buttons.append(&copy);
        buttons.append(&use_font);
        panel.append(&buttons);
        dialog.set_child(Some(&panel));
        let d = dialog.downgrade();
        close.connect_clicked(move |_| {
            if let Some(dialog) = d.upgrade() {
                dialog.close();
            }
        });
        let weak = Rc::downgrade(self);
        let name = family.to_string();
        let message = status.clone();
        copy.connect_clicked(move |_| {
            if let Some(ui) = weak.upgrade() {
                ui.window.clipboard().set_text(&name);
                message.set_text(&format!("Copied {name}"));
            }
        });
        let weak = Rc::downgrade(self);
        let name = family.to_string();
        use_font.connect_clicked(move |_| {
            if let Some(ui) = weak.upgrade() {
                match ui.set_font(Some(&name)) {
                    Ok(()) => status.set_text(&format!("Spotlight is now using {name}")),
                    Err(error) => status.set_text(&error),
                }
            }
        });
        let keys = gtk::EventControllerKey::new();
        let d = dialog.downgrade();
        keys.connect_key_pressed(move |_, key, _, _| {
            if key == gdk::Key::Escape {
                if let Some(dialog) = d.upgrade() {
                    dialog.close();
                }
                return glib::Propagation::Stop;
            }
            glib::Propagation::Proceed
        });
        dialog.add_controller(keys);
        dialog.present();
    }
    fn note_destination(&self) -> String {
        match self.store.borrow().obsidian_vault.as_ref() {
            Some(path) => format!(
                "Obsidian · {}",
                path.file_name().unwrap_or_default().to_string_lossy()
            ),
            None => "Spotlight local notes · connect Obsidian in Settings".into(),
        }
    }
    fn capture_note(self: &Rc<Self>, text: &str) -> Result<(quicknote::SavedNote, String), String> {
        if !self.can_save {
            return Err("Saved data is unreadable; fix it before saving notes".into());
        }
        let vault = self.store.borrow().obsidian_vault.clone();
        let note = quicknote::save(text, vault.as_deref(), &core::data_dir())?;
        let mut store = self.store.borrow_mut();
        store.quick_notes.insert(0, note.clone());
        store.quick_notes.truncate(100);
        let metadata_error = store.save().err();
        drop(store);
        if *self.files_ready.borrow()
            && self.files.borrow().len() < 25000
            && fileignore::Rules::load(&core::home())
                .is_ok_and(|rules| !rules.excludes(&note.path, false))
        {
            self.files.borrow_mut().push(note.path.clone());
        }
        let message = match metadata_error {
            Some(error) => format!(
                "Saved {} · could not save recent list: {error}",
                note.path.display()
            ),
            None => format!("Saved to {} · {}", self.note_destination(), note.title),
        };
        Ok((note, message))
    }
    fn calendar_event(self: &Rc<Self>, draft: calendar::Draft) {
        if let Some(dialog) = self.event_editor.borrow().as_ref() {
            dialog.present();
            return;
        }
        let weak = Rc::downgrade(self);
        let dialog = calendar::editor(&self.window, draft, move |message, title| {
            if let Some(ui) = weak.upgrade() {
                ui.booster_cache
                    .borrow_mut()
                    .retain(|q, _| !matches!(q, boosters::Query::Pim(pim::Kind::Calendar, _)));
                ui.page(Page::Root);
                ui.search.set_text(&format!("calendar {title}"));
                ui.error(&message);
            }
        });
        let weak = Rc::downgrade(self);
        dialog.connect_close_request(move |_| {
            if let Some(ui) = weak.upgrade() {
                ui.event_editor.borrow_mut().take();
            }
            glib::Propagation::Proceed
        });
        *self.event_editor.borrow_mut() = Some(dialog.clone());
        dialog.present();
    }
    fn quick_note(self: &Rc<Self>, initial: &str) {
        if let Some(dialog) = self.note_editor.borrow().as_ref() {
            dialog.present();
            return;
        }
        if !initial.is_empty() {
            *self.note_draft.borrow_mut() = initial.to_string();
        }
        let dialog = gtk::Window::builder()
            .title("Spotlight Quick Note")
            .transient_for(&self.window)
            .modal(true)
            .default_width(560)
            .default_height(360)
            .build();
        let panel = gtk::Box::new(gtk::Orientation::Vertical, 12);
        panel.add_css_class("editor");
        let title = gtk::Label::new(Some("Quick Note"));
        title.set_xalign(0.);
        title.add_css_class("item-title");
        panel.append(&title);
        let target = gtk::Label::new(Some(&self.note_destination()));
        target.set_xalign(0.);
        target.set_wrap(true);
        target.add_css_class("subtitle");
        panel.append(&target);
        let text = gtk::TextView::new();
        self.snippet_text_keys(&text);
        text.set_wrap_mode(gtk::WrapMode::WordChar);
        text.buffer().set_text(&self.note_draft.borrow());
        let scroll = gtk::ScrolledWindow::builder()
            .child(&text)
            .vexpand(true)
            .min_content_height(180)
            .build();
        panel.append(&scroll);
        let status = gtk::Label::new(Some(
            "Ctrl+Enter to save · Escape closes and keeps your draft",
        ));
        status.set_xalign(0.);
        status.set_wrap(true);
        status.add_css_class("subtitle");
        panel.append(&status);
        let buttons = gtk::Box::new(gtk::Orientation::Horizontal, 8);
        buttons.set_halign(gtk::Align::End);
        let cancel = gtk::Button::with_label("Close");
        let save = gtk::Button::with_label("Save Note");
        save.add_css_class("accent");
        let open = gtk::Button::with_label("Save & Open");
        buttons.append(&cancel);
        buttons.append(&open);
        buttons.append(&save);
        panel.append(&buttons);
        dialog.set_child(Some(&panel));
        let weak = Rc::downgrade(self);
        text.buffer().connect_changed(move |buffer| {
            if let Some(ui) = weak.upgrade() {
                *ui.note_draft.borrow_mut() = buffer
                    .text(&buffer.start_iter(), &buffer.end_iter(), false)
                    .to_string();
            }
        });
        for (button, should_open) in [(&save, false), (&open, true)] {
            let weak = Rc::downgrade(self);
            let buffer = text.buffer();
            let status = status.clone();
            let d = dialog.downgrade();
            button.connect_clicked(move |_| {
                let Some(ui) = weak.upgrade() else {
                    return;
                };
                let content = buffer.text(&buffer.start_iter(), &buffer.end_iter(), false);
                match ui.capture_note(&content) {
                    Ok((note, message)) => {
                        ui.note_draft.borrow_mut().clear();
                        if let Some(dialog) = d.upgrade() {
                            dialog.close();
                        }
                        ui.search.set_text("");
                        ui.refresh();
                        ui.error(&message);
                        if should_open {
                            match gio::AppInfo::launch_default_for_uri(
                                &quicknote::open_uri(&note),
                                None::<&gio::AppLaunchContext>,
                            ) {
                                Ok(()) => ui.window.set_visible(false),
                                Err(error) => {
                                    ui.error(&format!("Note saved; could not open it: {error}"))
                                }
                            }
                        }
                    }
                    Err(error) => status.set_text(&error),
                }
            });
        }
        let d = dialog.downgrade();
        cancel.connect_clicked(move |_| {
            if let Some(dialog) = d.upgrade() {
                dialog.close();
            }
        });
        let weak = Rc::downgrade(self);
        dialog.connect_close_request(move |_| {
            if let Some(ui) = weak.upgrade() {
                ui.note_editor.borrow_mut().take();
            }
            glib::Propagation::Proceed
        });
        let keys = gtk::EventControllerKey::new();
        let save_button = save.clone();
        let d = dialog.downgrade();
        keys.connect_key_pressed(move |_, key, _, modifiers| {
            if key == gdk::Key::Return && modifiers.contains(gdk::ModifierType::CONTROL_MASK) {
                save_button.emit_clicked();
                return glib::Propagation::Stop;
            }
            if key == gdk::Key::Escape {
                if let Some(dialog) = d.upgrade() {
                    dialog.close();
                }
                return glib::Propagation::Stop;
            }
            glib::Propagation::Proceed
        });
        dialog.add_controller(keys);
        *self.note_editor.borrow_mut() = Some(dialog.clone());
        dialog.present();
        text.grab_focus();
    }
    fn timer_setup(self: &Rc<Self>) {
        let dialog = gtk::Window::builder()
            .title("Set Timer")
            .application(&self.window.application().unwrap())
            .transient_for(&self.window)
            .modal(true)
            .default_width(440)
            .build();
        let panel = gtk::Box::new(gtk::Orientation::Vertical, 14);
        panel.add_css_class("editor");
        panel.append(&gtk::Label::new(Some("Choose a timer duration")));
        let row = gtk::Box::new(gtk::Orientation::Horizontal, 12);
        row.set_halign(gtk::Align::Center);
        let hours = gtk::SpinButton::with_range(0., 8760., 1.);
        let minutes = gtk::SpinButton::with_range(0., 59., 1.);
        minutes.set_value(5.);
        let seconds = gtk::SpinButton::with_range(0., 59., 1.);
        for (label, name, spin) in [
            ("Hours", "timer-hours", &hours),
            ("Minutes", "timer-minutes", &minutes),
            ("Seconds", "timer-seconds", &seconds),
        ] {
            spin.set_numeric(true);
            spin.set_widget_name(name);
            let column = gtk::Box::new(gtk::Orientation::Vertical, 6);
            column.append(&gtk::Label::new(Some(label)));
            column.append(spin);
            row.append(&column);
        }
        panel.append(&row);
        panel.append(&gtk::Label::new(Some(
            "The timer keeps running when Spotlight is hidden.",
        )));
        let status = gtk::Label::new(None);
        status.set_wrap(true);
        panel.append(&status);
        let buttons = gtk::Box::new(gtk::Orientation::Horizontal, 8);
        buttons.set_halign(gtk::Align::End);
        let cancel = gtk::Button::with_label("Cancel");
        let start = gtk::Button::with_label("Start Timer");
        start.add_css_class("accent");
        buttons.append(&cancel);
        buttons.append(&start);
        panel.append(&buttons);
        dialog.set_child(Some(&panel));
        dialog.set_default_widget(Some(&start));
        let d = dialog.downgrade();
        cancel.connect_clicked(move |_| {
            if let Some(dialog) = d.upgrade() {
                dialog.close();
            }
        });
        let weak = Rc::downgrade(self);
        let d = dialog.downgrade();
        let minute_entry = minutes.clone();
        start.connect_clicked(move |_| {
            let Some(ui) = weak.upgrade() else {
                return;
            };
            hours.update();
            minutes.update();
            seconds.update();
            let duration = hours.value_as_int() as u64 * 3600
                + minutes.value_as_int() as u64 * 60
                + seconds.value_as_int() as u64;
            if duration == 0 {
                status.set_text("Choose a duration greater than zero.");
                return;
            }
            if duration > 31_536_000 {
                status.set_text("Timers can run for up to 365 days.");
                return;
            }
            let before = ui.store.borrow().reminders.len();
            ui.schedule(reminder::Draft::Timer(duration));
            if ui.store.borrow().reminders.len() > before {
                if let Some(dialog) = d.upgrade() {
                    dialog.close();
                }
            } else {
                status.set_text(&ui.notice.text());
            }
        });
        let keys = gtk::EventControllerKey::new();
        let d = dialog.downgrade();
        let button = start.clone();
        keys.connect_key_pressed(move |_, key, _, _| {
            if key == gdk::Key::Escape {
                if let Some(dialog) = d.upgrade() {
                    dialog.close();
                }
                return glib::Propagation::Stop;
            }
            if key == gdk::Key::Return || key == gdk::Key::KP_Enter {
                button.emit_clicked();
                return glib::Propagation::Stop;
            }
            glib::Propagation::Proceed
        });
        keys.set_propagation_phase(gtk::PropagationPhase::Capture);
        dialog.add_controller(keys);
        dialog.present();
        minute_entry.grab_focus();
        minute_entry.select_region(0, -1);
    }
    fn alarm_setup(self: &Rc<Self>) {
        let Ok(now) = glib::DateTime::now_local() else {
            return;
        };
        let next = now.add_minutes(1).unwrap_or(now);
        let dialog = gtk::Window::builder()
            .title("Set Alarm")
            .application(&self.window.application().unwrap())
            .transient_for(&self.window)
            .modal(true)
            .default_width(420)
            .build();
        let panel = gtk::Box::new(gtk::Orientation::Vertical, 14);
        panel.add_css_class("editor");
        let label = gtk::Label::new(Some("Set an alarm · local time (24-hour clock)"));
        panel.append(&label);
        let row = gtk::Box::new(gtk::Orientation::Horizontal, 8);
        row.set_halign(gtk::Align::Center);
        let hour = gtk::SpinButton::with_range(0., 23., 1.);
        hour.set_numeric(true);
        hour.set_value(next.hour() as f64);
        let minute = gtk::SpinButton::with_range(0., 59., 1.);
        minute.set_numeric(true);
        minute.set_value(next.minute() as f64);
        row.append(&hour);
        row.append(&gtk::Label::new(Some(":")));
        row.append(&minute);
        panel.append(&row);
        panel.append(&gtk::Label::new(Some(
            "An earlier time is scheduled for tomorrow.",
        )));
        let status = gtk::Label::new(None);
        status.set_wrap(true);
        panel.append(&status);
        let buttons = gtk::Box::new(gtk::Orientation::Horizontal, 8);
        buttons.set_halign(gtk::Align::End);
        let test = gtk::Button::with_label("Test sound");
        let cancel = gtk::Button::with_label("Cancel");
        let set = gtk::Button::with_label("Set Alarm");
        set.add_css_class("accent");
        buttons.append(&test);
        buttons.append(&cancel);
        buttons.append(&set);
        panel.append(&buttons);
        dialog.set_child(Some(&panel));
        test.connect_clicked(|_| play_alarm_sound());
        let d = dialog.downgrade();
        cancel.connect_clicked(move |_| {
            if let Some(dialog) = d.upgrade() {
                dialog.close();
            }
        });
        let weak = Rc::downgrade(self);
        let d = dialog.downgrade();
        set.connect_clicked(move |_| {
            let Some(ui) = weak.upgrade() else {
                return;
            };
            let before = ui.store.borrow().reminders.len();
            hour.update();
            minute.update();
            ui.schedule(reminder::Draft::Alarm {
                hour: hour.value_as_int(),
                minute: minute.value_as_int(),
            });
            if ui.store.borrow().reminders.len() > before {
                if let Some(dialog) = d.upgrade() {
                    dialog.close();
                }
            } else {
                status.set_text(&ui.notice.text());
            }
        });
        dialog.present();
    }
    fn dismiss_alarms(self: &Rc<Self>) {
        let ids: Vec<_> = self
            .store
            .borrow()
            .ringing_reminders
            .iter()
            .map(|entry| entry.id.clone())
            .collect();
        self.store.borrow_mut().ringing_reminders.clear();
        self.save();
        if let Some(source) = self.alarm_repeat.borrow_mut().take() {
            source.remove();
        }
        if let Some(app) = self.window.application() {
            for id in ids {
                app.withdraw_notification(&format!("reminder-{id}"));
            }
        }
        if let Some(window) = self.alarm_window.borrow_mut().take() {
            window.destroy();
        }
        self.alarm_label.borrow_mut().take();
        self.refresh();
    }
    fn show_alarm(self: &Rc<Self>) {
        if self.store.borrow().ringing_reminders.is_empty() {
            return;
        }
        if let Some(window) = self.alarm_window.borrow().as_ref() {
            if let Some(label) = self.alarm_label.borrow().as_ref() {
                label.set_text(
                    &self
                        .store
                        .borrow()
                        .ringing_reminders
                        .iter()
                        .map(|entry| entry.title.as_str())
                        .collect::<Vec<_>>()
                        .join("\n"),
                );
            }
            window.present();
            return;
        }
        let window: gtk::Window = gtk::ApplicationWindow::builder()
            .application(&self.window.application().unwrap())
            .title("Spotlight Alarm")
            .default_width(440)
            .resizable(false)
            .build()
            .upcast();
        let panel = gtk::Box::new(gtk::Orientation::Vertical, 16);
        panel.add_css_class("editor");
        let heading = gtk::Label::new(Some("Alarm · time is up"));
        heading.add_css_class("item-title");
        panel.append(&heading);
        let text = self
            .store
            .borrow()
            .ringing_reminders
            .iter()
            .map(|entry| entry.title.clone())
            .collect::<Vec<_>>()
            .join("\n");
        let label = gtk::Label::new(Some(&text));
        label.set_wrap(true);
        *self.alarm_label.borrow_mut() = Some(label.clone());
        panel.append(&label);
        let dismiss = gtk::Button::with_label("Dismiss Alarm");
        dismiss.add_css_class("accent");
        panel.append(&dismiss);
        window.set_child(Some(&panel));
        let weak = Rc::downgrade(self);
        dismiss.connect_clicked(move |_| {
            if let Some(ui) = weak.upgrade() {
                ui.dismiss_alarms();
            }
        });
        let weak = Rc::downgrade(self);
        window.connect_close_request(move |_| {
            if let Some(ui) = weak.upgrade() {
                ui.dismiss_alarms();
            }
            glib::Propagation::Stop
        });
        *self.alarm_window.borrow_mut() = Some(window.clone());
        window.present();
        play_alarm_sound();
        let weak = Rc::downgrade(self);
        let source = glib::timeout_add_seconds_local(5, move || {
            let Some(ui) = weak.upgrade() else {
                return glib::ControlFlow::Break;
            };
            if ui.store.borrow().ringing_reminders.is_empty() {
                ui.alarm_repeat.borrow_mut().take();
                return glib::ControlFlow::Break;
            }
            play_alarm_sound();
            glib::ControlFlow::Continue
        });
        *self.alarm_repeat.borrow_mut() = Some(source);
    }
    fn schedule(self: &Rc<Self>, draft: reminder::Draft) {
        if !self.can_save {
            self.error("Cannot save timers while saved data is unreadable");
            return;
        }
        let pomodoro = matches!(draft, reminder::Draft::Pomodoro(_));
        if pomodoro && self.pomodoro_awake.borrow().is_none() {
            match caffeinate::Inhibitor::start() {
                Ok(inhibitor) => *self.pomodoro_awake.borrow_mut() = Some(inhibitor),
                Err(e) => {
                    self.error(&e);
                    return;
                }
            }
        }
        let result = (|| -> Result<String, String> {
            let now = glib::DateTime::now_local().map_err(|e| e.to_string())?;
            let entry = draft.create(&now)?;
            let due = glib::DateTime::from_unix_local(entry.due)
                .ok()
                .and_then(|date| date.format("%a %d %b %H:%M:%S %Z").ok())
                .map(|date| date.to_string())
                .unwrap_or_default();
            let label = format!("{} · due {due}", entry.title);
            let mut store = self.store.borrow_mut();
            if store.reminders.len() >= 100 {
                return Err("You can set up to 100 timers and alarms".into());
            }
            let id = entry.id.clone();
            store.reminders.push(entry);
            if let Err(error) = store.save() {
                store.reminders.retain(|entry| entry.id != id);
                return Err(error);
            }
            Ok(label)
        })();
        self.sync_pomodoro();
        match result {
            Ok(label) => {
                self.search.set_text("");
                self.refresh();
                self.error(&format!("{label} set · search timer or alarm to cancel"));
                self.arm_reminders();
            }
            Err(error) => self.error(&format!("Could not set reminder: {error}")),
        }
    }
    fn cancel_reminder(self: &Rc<Self>, id: &str) {
        if !self.can_save {
            self.error("Saved data cannot be changed");
            return;
        }
        let mut store = self.store.borrow_mut();
        let previous = store.reminders.clone();
        store.reminders.retain(|entry| entry.id != id);
        if let Err(error) = store.save() {
            store.reminders = previous;
            drop(store);
            self.error(&format!("Could not cancel reminder: {error}"));
            return;
        }
        let empty = store.reminders.is_empty();
        drop(store);
        if empty && let Some(source) = self.reminder_clock.borrow_mut().take() {
            source.remove();
        }
        self.sync_pomodoro();
        self.refresh();
        self.error("Reminder cancelled");
    }
    fn check_reminders(self: &Rc<Self>) {
        let Ok(now) = glib::DateTime::now_local() else {
            return;
        };
        let mut store = self.store.borrow_mut();
        let due = reminder::take_due(&mut store.reminders, now.to_unix());
        if due.is_empty() {
            let ringing = !store.ringing_reminders.is_empty();
            drop(store);
            if ringing && self.alarm_window.borrow().is_none() {
                self.show_alarm();
            }
            return;
        }
        store.ringing_reminders.extend(due.iter().cloned());
        let saved = store.save();
        drop(store);
        self.sync_pomodoro();
        for entry in &due {
            if let Some(app) = self.window.application() {
                let title = if entry.alarm {
                    "Spotlight alarm"
                } else {
                    "Timer finished"
                };
                let notification = gio::Notification::new(title);
                notification.set_body(Some(&entry.title));
                notification.set_priority(gio::NotificationPriority::Urgent);
                notification.set_default_action("app.show-alarm");
                app.send_notification(Some(&format!("reminder-{}", entry.id)), &notification);
            }
        }
        self.show_alarm();
        if self.window.is_visible() {
            self.refresh();
            self.error(&format!(
                "{} finished",
                due.iter()
                    .map(|entry| entry.title.as_str())
                    .collect::<Vec<_>>()
                    .join(", ")
            ));
        }
        if let Err(error) = saved {
            self.error(&format!("Could not save completed reminders: {error}"));
        }
    }
    fn arm_reminders(self: &Rc<Self>) {
        self.check_reminders();
        if self.reminder_clock.borrow().is_some() || self.store.borrow().reminders.is_empty() {
            return;
        }
        let weak = Rc::downgrade(self);
        let source = glib::timeout_add_seconds_local(1, move || {
            let Some(ui) = weak.upgrade() else {
                return glib::ControlFlow::Break;
            };
            ui.check_reminders();
            if ui.store.borrow().reminders.is_empty() {
                ui.reminder_clock.borrow_mut().take();
                glib::ControlFlow::Break
            } else {
                glib::ControlFlow::Continue
            }
        });
        *self.reminder_clock.borrow_mut() = Some(source);
    }
    fn finish_color(self: &Rc<Self>, result: Result<Option<String>, String>) {
        self.picker.borrow_mut().take();
        self.picking_color.set(false);
        match result {
            Ok(Some(hex)) => {
                self.window.clipboard().set_text(&hex);
                *self.picked_color.borrow_mut() = Some(hex.clone());
                self.page(Page::Colors);
                self.error(&format!(
                    "Copied {hex} · select another format and press Enter to copy"
                ));
            }
            Ok(None) => self.error("Color selection cancelled"),
            Err(message) => self.error(&message),
        }
        self.window.present();
        self.search.grab_focus();
    }
    fn pick_color(self: &Rc<Self>) {
        if self.picking_color.replace(true) {
            return;
        }
        self.window.set_visible(false);
        let weak = Rc::downgrade(self);
        glib::timeout_add_local_once(Duration::from_millis(250), move || {
            let Some(ui) = weak.upgrade() else {
                return;
            };
            let bus = match gio::bus_get_sync(gio::BusType::Session, None::<&gio::Cancellable>) {
                Ok(bus) => bus,
                Err(error) => {
                    ui.finish_color(Err(format!(
                        "Could not connect to the desktop color picker: {error}"
                    )));
                    return;
                }
            };
            let token = format!("spotlight_{}", glib::uuid_string_random().replace('-', ""));
            let sender = bus
                .unique_name()
                .unwrap()
                .trim_start_matches(':')
                .replace('.', "_");
            let path = format!("/org/freedesktop/portal/desktop/request/{sender}/{token}");
            let weak = Rc::downgrade(&ui);
            let subscription = bus.subscribe_to_signal(
                Some("org.freedesktop.portal.Desktop"),
                Some("org.freedesktop.portal.Request"),
                Some("Response"),
                Some(&path),
                None,
                gio::DBusSignalFlags::NONE,
                move |signal| {
                    if let Some(ui) = weak.upgrade() {
                        ui.finish_color(color::response(signal.parameters));
                        ui.refresh();
                    }
                },
            );
            *ui.picker.borrow_mut() = Some((path.clone(), subscription));
            let options = std::collections::HashMap::from([("handle_token", token.to_variant())]);
            let weak = Rc::downgrade(&ui);
            bus.call(
                Some("org.freedesktop.portal.Desktop"),
                "/org/freedesktop/portal/desktop",
                "org.freedesktop.portal.Screenshot",
                "PickColor",
                Some(&("", options).to_variant()),
                None,
                gio::DBusCallFlags::NONE,
                10000,
                None::<&gio::Cancellable>,
                move |result| {
                    let Some(ui) = weak.upgrade() else {
                        return;
                    };
                    match result {
                        Ok(reply) => {
                            let returned = reply.child_value(0);
                            if returned.str() != Some(path.as_str()) && ui.picker.borrow().is_some()
                            {
                                ui.finish_color(Err(
                                    "Unexpected response from the desktop color picker".into(),
                                ));
                            }
                        }
                        Err(error) => ui.finish_color(Err(format!(
                            "Could not open the desktop color picker: {error}"
                        ))),
                    }
                },
            );
        });
    }
    fn finish_measurement(
        self: &Rc<Self>,
        result: Result<Option<gtk::gdk_pixbuf::Pixbuf>, String>,
    ) {
        self.measurement_request.borrow_mut().take();
        match result {
            Ok(Some(image)) => {
                let ruler = measure::open(&self.window, image);
                let weak = Rc::downgrade(self);
                ruler.window.connect_close_request(move |_| {
                    if let Some(ui) = weak.upgrade() {
                        ui.measurement_window.borrow_mut().take();
                        ui.measuring_screen.set(false);
                        ui.window.present();
                        ui.search.grab_focus();
                    }
                    glib::Propagation::Proceed
                });
                ruler.window.present();
                *self.measurement_window.borrow_mut() = Some(ruler);
                return;
            }
            Ok(None) => self.error("Screen measurement cancelled"),
            Err(message) => self.error(&message),
        }
        self.measuring_screen.set(false);
        self.window.present();
        self.search.grab_focus();
    }
    fn measure_screen(self: &Rc<Self>) {
        self.capture_screen(false);
    }
    fn capture_screen(self: &Rc<Self>, screenshot: bool) {
        if self.measuring_screen.replace(true) {
            if let Some(ruler) = self.measurement_window.borrow().as_ref() {
                ruler.window.present();
            }
            return;
        }
        self.error("");
        self.window.set_visible(false);
        let weak = Rc::downgrade(self);
        glib::timeout_add_local_once(Duration::from_millis(300), move || {
            let Some(ui) = weak.upgrade() else { return };
            let bus = match gio::bus_get_sync(gio::BusType::Session, None::<&gio::Cancellable>) {
                Ok(bus) => bus,
                Err(error) => {
                    ui.finish_capture(
                        screenshot,
                        Err(format!("Could not connect to screen capture: {error}")),
                    );
                    return;
                }
            };
            let token = format!(
                "spotlight_measure_{}",
                glib::uuid_string_random().replace('-', "")
            );
            let sender = bus
                .unique_name()
                .unwrap()
                .trim_start_matches(':')
                .replace('.', "_");
            let path = format!("/org/freedesktop/portal/desktop/request/{sender}/{token}");
            let weak = Rc::downgrade(&ui);
            let subscription = bus.subscribe_to_signal(
                Some("org.freedesktop.portal.Desktop"),
                Some("org.freedesktop.portal.Request"),
                Some("Response"),
                Some(&path),
                None,
                gio::DBusSignalFlags::NONE,
                move |signal| {
                    if let Some(ui) = weak.upgrade() {
                        ui.finish_capture(screenshot, measure::response(signal.parameters));
                    }
                },
            );
            *ui.measurement_request.borrow_mut() = Some((path.clone(), subscription));
            let options = std::collections::HashMap::from([
                ("handle_token", token.to_variant()),
                ("interactive", screenshot.to_variant()),
            ]);
            let weak = Rc::downgrade(&ui);
            bus.call(
                Some("org.freedesktop.portal.Desktop"),
                "/org/freedesktop/portal/desktop",
                "org.freedesktop.portal.Screenshot",
                "Screenshot",
                Some(&("", options).to_variant()),
                None,
                gio::DBusCallFlags::NONE,
                10000,
                None::<&gio::Cancellable>,
                move |result| {
                    let Some(ui) = weak.upgrade() else { return };
                    if ui.measurement_request.borrow().is_none() {
                        return;
                    }
                    match result {
                        Ok(reply) if reply.child_value(0).str() == Some(path.as_str()) => {}
                        Ok(_) => ui.finish_capture(
                            screenshot,
                            Err("Unexpected response from screen capture".into()),
                        ),
                        Err(error) => ui.finish_capture(
                            screenshot,
                            Err(format!("Could not capture the screen: {error}")),
                        ),
                    }
                },
            );
        });
    }
    fn toggle_caffeinate(self: &Rc<Self>) {
        let mut state = self.caffeinate.borrow_mut();
        let result = if let Some(inhibitor) = state.as_mut() {
            inhibitor.stop().map(|()| {
                state.take();
                "Caffeinate is off · normal power saving restored"
            })
        } else {
            caffeinate::Inhibitor::start().map(|inhibitor| {
                *state = Some(inhibitor);
                "Caffeinate is on · screen and computer stay awake until turned off or Spotlight quits"
            })
        };
        drop(state);
        self.awake_status.set_visible(
            self.caffeinate.borrow().is_some() || self.pomodoro_awake.borrow().is_some(),
        );
        self.refresh();
        self.error(match &result {
            Ok(message) => message,
            Err(message) => message,
        });
    }
    fn refresh_desktop_rows(self: &Rc<Self>) {
        let selected = self.selected().map(|item| item.id);
        self.refresh();
        if let Some(id) = selected
            && let Some(index) = self.visible.borrow().iter().position(|item| item.id == id)
        {
            self.list
                .select_row(self.list.row_at_index(index as i32).as_ref());
        }
    }
    fn load_desktop(self: &Rc<Self>) {
        self.load_extensions();
        self.load_recents();
        if self.desktop_busy.get() || self.desktop_loading.replace(true) {
            return;
        }
        let generation = self.desktop_generation.get().wrapping_add(1);
        self.desktop_generation.set(generation);
        let (tx, rx) = mpsc::channel();
        std::thread::spawn(move || {
            let _ = tx.send(desktop::Snapshot::read());
        });
        let weak = Rc::downgrade(self);
        glib::timeout_add_local(Duration::from_millis(80), move || {
            let Some(ui) = weak.upgrade() else {
                return glib::ControlFlow::Break;
            };
            if ui.desktop_generation.get() != generation {
                return glib::ControlFlow::Break;
            }
            match rx.try_recv() {
                Ok(snapshot) => {
                    ui.desktop_loading.set(false);
                    *ui.desktop_snapshot.borrow_mut() = snapshot;
                    ui.refresh_desktop_rows();
                    glib::ControlFlow::Break
                }
                Err(mpsc::TryRecvError::Empty) => glib::ControlFlow::Continue,
                Err(_) => {
                    ui.desktop_loading.set(false);
                    glib::ControlFlow::Break
                }
            }
        });
    }
    fn desktop_command(self: &Rc<Self>, command: desktop::Command) {
        if self.desktop_busy.get() {
            self.error("A system command is still running");
            return;
        }
        if command == desktop::Command::EmptyTrash {
            self.confirm_empty_trash();
        } else {
            self.execute_desktop(command);
        }
    }
    fn execute_desktop(self: &Rc<Self>, command: desktop::Command) {
        if self.desktop_busy.replace(true) {
            return;
        }
        self.desktop_generation
            .set(self.desktop_generation.get().wrapping_add(1));
        self.desktop_loading.set(false);
        self.error(&format!("{}…", command.title()));
        let (tx, rx) = mpsc::channel();
        std::thread::spawn(move || {
            let result = desktop::execute(command);
            let _ = tx.send((result, desktop::Snapshot::read()));
        });
        let weak = Rc::downgrade(self);
        glib::timeout_add_local(Duration::from_millis(80), move || {
            let Some(ui) = weak.upgrade() else {
                return glib::ControlFlow::Break;
            };
            match rx.try_recv() {
                Ok((result, snapshot)) => {
                    ui.desktop_busy.set(false);
                    *ui.desktop_snapshot.borrow_mut() = snapshot;
                    ui.refresh_desktop_rows();
                    ui.error(match &result {
                        Ok(message) => message,
                        Err(message) => message,
                    });
                    glib::ControlFlow::Break
                }
                Err(mpsc::TryRecvError::Empty) => glib::ControlFlow::Continue,
                Err(_) => {
                    ui.desktop_busy.set(false);
                    ui.error("The system command did not complete");
                    glib::ControlFlow::Break
                }
            }
        });
    }
    fn confirm_empty_trash(self: &Rc<Self>) {
        if let Some(dialog) = self.trash_dialog.borrow().as_ref() {
            dialog.present();
            return;
        }
        let dialog = gtk::Window::builder()
            .application(&self.window.application().unwrap())
            .transient_for(&self.window)
            .modal(true)
            .destroy_with_parent(true)
            .title("Empty Trash?")
            .default_width(410)
            .resizable(false)
            .build();
        let content = gtk::Box::new(gtk::Orientation::Vertical, 16);
        content.add_css_class("editor");
        let title = gtk::Label::new(Some("Permanently empty the Trash?"));
        title.add_css_class("item-title");
        content.append(&title);
        let message = gtk::Label::new(Some(
            "All files in the Trash will be permanently deleted. This cannot be undone.",
        ));
        message.set_wrap(true);
        message.set_max_width_chars(48);
        content.append(&message);
        let buttons = gtk::Box::new(gtk::Orientation::Horizontal, 10);
        buttons.set_halign(gtk::Align::End);
        let cancel = gtk::Button::with_label("Cancel");
        let empty = gtk::Button::with_label("Empty Trash");
        empty.add_css_class("accent");
        buttons.append(&cancel);
        buttons.append(&empty);
        content.append(&buttons);
        dialog.set_child(Some(&content));
        dialog.set_default_widget(Some(&cancel));
        let weak_dialog = dialog.downgrade();
        cancel.connect_clicked(move |_| {
            if let Some(dialog) = weak_dialog.upgrade() {
                dialog.close();
            }
        });
        let weak_dialog = dialog.downgrade();
        let weak = Rc::downgrade(self);
        empty.connect_clicked(move |_| {
            if let Some(dialog) = weak_dialog.upgrade() {
                dialog.close();
            }
            if let Some(ui) = weak.upgrade() {
                ui.execute_desktop(desktop::Command::EmptyTrash);
            }
        });
        let weak = Rc::downgrade(self);
        dialog.connect_close_request(move |_| {
            if let Some(ui) = weak.upgrade() {
                ui.trash_dialog.borrow_mut().take();
                ui.search.grab_focus();
            }
            glib::Propagation::Proceed
        });
        let keys = gtk::EventControllerKey::new();
        let weak_dialog = dialog.downgrade();
        keys.connect_key_pressed(move |_, key, _, _| {
            if key == gdk::Key::Escape {
                if let Some(dialog) = weak_dialog.upgrade() {
                    dialog.close();
                }
                return glib::Propagation::Stop;
            }
            glib::Propagation::Proceed
        });
        dialog.add_controller(keys);
        *self.trash_dialog.borrow_mut() = Some(dialog.clone());
        dialog.present();
        cancel.grab_focus();
    }
    fn load_extensions(self: &Rc<Self>) {
        if !self.store.borrow().commands.enabled("extensions")
            && *self.page.borrow() != Page::Scripts
        {
            return;
        }
        if self.extensions_loading.replace(true) {
            return;
        }
        let (tx, rx) = mpsc::channel();
        std::thread::spawn(move || {
            let _ = tx.send(extensions::discover());
        });
        let weak = Rc::downgrade(self);
        glib::timeout_add_local(Duration::from_millis(80), move || {
            let Some(ui) = weak.upgrade() else {
                return glib::ControlFlow::Break;
            };
            match rx.try_recv() {
                Ok((manifests, errors)) => {
                    *ui.extensions.borrow_mut() = manifests;
                    *ui.extension_errors.borrow_mut() = errors;
                    ui.extensions_loading.set(false);
                    ui.refresh();
                    glib::ControlFlow::Break
                }
                Err(mpsc::TryRecvError::Empty) => glib::ControlFlow::Continue,
                Err(_) => {
                    ui.extensions_loading.set(false);
                    glib::ControlFlow::Break
                }
            }
        });
    }
    fn extension_icon(manifest: &extensions::Manifest, icon: &str, row: &mut Item) {
        if let Some(path) = manifest.icon_path(icon) {
            row.gicon = Some(gio::FileIcon::new(&gio::File::for_path(path)).upcast());
        } else if !icon.is_empty()
            && icon.len() <= 128
            && icon
                .bytes()
                .all(|c| c.is_ascii_alphanumeric() || b"-_.".contains(&c))
        {
            row.gicon = Some(gio::ThemedIcon::new(icon).upcast());
        } else if icon.chars().count() <= 8 {
            row.icon = icon.into();
        }
    }
    fn extension_menu(&self) -> Vec<Item> {
        let mut rows = self
            .extensions
            .borrow()
            .iter()
            .map(|m| {
                let mut row = item(
                    &format!("extension:{}", m.id),
                    &m.name,
                    &format!(
                        "{} · ext {} · {}",
                        m.description,
                        m.id,
                        if m.runtime == extensions::Runtime::Wasm {
                            "Sandboxed WASM"
                        } else {
                            "Script · full user access"
                        }
                    ),
                    "utilities-terminal-symbolic",
                    if m.runtime == extensions::Runtime::Wasm {
                        "WASM"
                    } else {
                        "Script"
                    },
                    Action::Extension(m.clone()),
                );
                Self::extension_icon(m, &m.icon, &mut row);
                row
            })
            .collect::<Vec<_>>();
        if *self.page.borrow() == Page::Scripts {
            rows.extend(self.extension_errors.borrow().iter().map(|e| {
                item(
                    "extension-error",
                    "Invalid extension manifest",
                    e,
                    "dialog-warning-symbolic",
                    "Error",
                    Action::Noop,
                )
            }));
        }
        rows
    }
    fn open_extension(self: &Rc<Self>, manifest: extensions::Manifest) {
        if manifest.mode == extensions::Mode::Search {
            self.page(Page::Root);
            self.search.set_text(&format!("ext {} ", manifest.id));
            self.search.set_position(-1);
            return;
        }
        if manifest.args.is_empty() {
            self.page(Page::Root);
            let key = format!("ext {}", manifest.id);
            self.search.set_text(&key);
            self.start_extension(manifest, Vec::new(), key, false);
            self.refresh();
            return;
        }
        let dialog = gtk::Window::builder()
            .application(&self.window.application().unwrap())
            .title(&manifest.name)
            .transient_for(&self.window)
            .modal(true)
            .default_width(480)
            .build();
        let panel = gtk::Box::new(gtk::Orientation::Vertical, 10);
        panel.add_css_class("editor");
        let description = gtk::Label::new(Some(&manifest.description));
        description.set_wrap(true);
        panel.append(&description);
        let mut entries = Vec::new();
        for arg in &manifest.args {
            let label = gtk::Label::new(Some(&format!(
                "{}{}",
                arg.name,
                if arg.required { " *" } else { "" }
            )));
            label.set_xalign(0.);
            panel.append(&label);
            let input = gtk::Entry::builder()
                .placeholder_text(&arg.placeholder)
                .text(&arg.default)
                .build();
            panel.append(&input);
            entries.push(input);
        }
        let status = gtk::Label::new(None);
        status.set_wrap(true);
        panel.append(&status);
        let run = gtk::Button::with_label("Run Extension");
        run.add_css_class("accent");
        panel.append(&run);
        let close = gtk::Button::with_label("Cancel");
        let weak_dialog = dialog.downgrade();
        close.connect_clicked(move |_| {
            if let Some(d) = weak_dialog.upgrade() {
                d.close();
            }
        });
        panel.append(&close);
        dialog.set_child(Some(&panel));
        let weak = Rc::downgrade(self);
        let weak_dialog = dialog.downgrade();
        run.connect_clicked(move |_| {
            let args = entries
                .iter()
                .map(|e| e.text().to_string())
                .collect::<Vec<_>>();
            if let Err(error) = manifest.validate_args(&args) {
                status.set_text(&error);
                return;
            }
            if let Some(ui) = weak.upgrade() {
                let key = format!(
                    "ext {} {}",
                    manifest.id,
                    args.iter()
                        .map(|a| serde_json::to_string(a).unwrap())
                        .collect::<Vec<_>>()
                        .join(" ")
                );
                if let Some(d) = weak_dialog.upgrade() {
                    d.close();
                }
                ui.page(Page::Root);
                ui.search.set_text(&key);
                ui.start_extension(manifest.clone(), args, key, false);
                ui.refresh();
            }
        });
        dialog.present();
    }
    fn start_extension(
        self: &Rc<Self>,
        manifest: extensions::Manifest,
        args: Vec<String>,
        key: String,
        debounce: bool,
    ) {
        let cancel = std::sync::Arc::new(std::sync::atomic::AtomicBool::new(false));
        *self.extension_session.borrow_mut() = Some(ExtensionSession {
            key: key.clone(),
            manifest: manifest.clone(),
            cancel: cancel.clone(),
            items: Vec::new(),
            status: "Running extension…".into(),
            done: false,
        });
        let weak = Rc::downgrade(self);
        glib::timeout_add_local_once(
            Duration::from_millis(if debounce { 350 } else { 0 }),
            move || {
                let Some(ui) = weak.upgrade() else { return };
                if cancel.load(std::sync::atomic::Ordering::Relaxed)
                    || ui.effective_query().trim() != key
                    || !ui.window.is_visible()
                {
                    return;
                }
                let (tx, rx) = mpsc::channel();
                let session_cancel = cancel.clone();
                std::thread::spawn(move || extensions::run(manifest, args, cancel, tx));
                let weak = Rc::downgrade(&ui);
                glib::timeout_add_local(Duration::from_millis(60), move || {
                    let Some(ui) = weak.upgrade() else {
                        return glib::ControlFlow::Break;
                    };
                    let selected = ui
                        .selected()
                        .filter(|i| i.id.starts_with("extension-result:"))
                        .map(|i| i.id);
                    let (done, changed) = {
                        let mut changed = false;
                        let mut guard = ui.extension_session.borrow_mut();
                        let Some(session) = guard.as_mut().filter(|s| {
                            s.key == key && std::sync::Arc::ptr_eq(&s.cancel, &session_cancel)
                        }) else {
                            return glib::ControlFlow::Break;
                        };
                        loop {
                            match rx.try_recv() {
                                Ok(event) => {
                                    changed = true;
                                    match event {
                                        extensions::Event::Item(item) => {
                                            if let Some(old) =
                                                session.items.iter_mut().find(|i| i.id == item.id)
                                            {
                                                *old = item;
                                            } else if session.items.len() < 50 {
                                                session.items.push(item);
                                            }
                                        }
                                        extensions::Event::Replace(items) => session.items = items,
                                        extensions::Event::Status(text) => session.status = text,
                                        extensions::Event::Done(result) => {
                                            session.done = true;
                                            session.status = result.err().unwrap_or_default();
                                        }
                                    }
                                }
                                Err(mpsc::TryRecvError::Empty) => break,
                                Err(mpsc::TryRecvError::Disconnected) => {
                                    if !session.done {
                                        session.done = true;
                                        session.status =
                                            "Extension stopped without a final result".into();
                                        changed = true;
                                    }
                                    break;
                                }
                            }
                        }
                        (session.done, changed)
                    };
                    if changed {
                        ui.refresh();
                        if let Some(id) = selected
                            && let Some(index) = ui.visible.borrow().iter().position(|i| i.id == id)
                        {
                            ui.list
                                .select_row(ui.list.row_at_index(index as i32).as_ref());
                        }
                    }
                    if done {
                        glib::ControlFlow::Break
                    } else {
                        glib::ControlFlow::Continue
                    }
                });
            },
        );
    }
    fn extension_items(self: &Rc<Self>, key: &str, id: &str, text: &str) -> Vec<Item> {
        let manifest = self
            .extensions
            .borrow()
            .iter()
            .find(|m| m.id == id)
            .cloned();
        let Some(manifest) = manifest else {
            return vec![item(
                "extension-help",
                if self.extensions_loading.get() {
                    "Loading extensions…"
                } else {
                    "Choose an installed extension"
                },
                "Type plugin <id> <arguments> · Script Commands lists WASM plugins and native scripts",
                "utilities-terminal-symbolic",
                "Info",
                Action::Page(Page::Scripts),
            )];
        };
        let args = match manifest.arguments(text) {
            Ok(args) => args,
            Err(error) => {
                return vec![item(
                    "extension-args",
                    &manifest.name,
                    &error,
                    "utilities-terminal-symbolic",
                    "Args",
                    Action::Extension(manifest.clone()),
                )];
            }
        };
        let matching = self
            .extension_session
            .borrow()
            .as_ref()
            .is_some_and(|s| s.key == key);
        if !matching {
            if manifest.mode == extensions::Mode::Search {
                self.start_extension(manifest.clone(), args, key.into(), true);
            } else {
                return vec![item(
                    "extension-run",
                    &format!("Run {}", manifest.name),
                    "Enter runs this extension with the supplied arguments",
                    "utilities-terminal-symbolic",
                    "Run",
                    Action::RunExtension {
                        manifest,
                        args,
                        key: key.into(),
                    },
                )];
            }
        }
        let session = self.extension_session.borrow();
        let Some(session) = session.as_ref() else {
            return Vec::new();
        };
        let mut rows = session
            .items
            .iter()
            .map(|entry| {
                let action = match &entry.action {
                    Some(extensions::Action::Copy { text }) => Action::Copy(text.clone()),
                    Some(extensions::Action::Open { url }) => Action::Open(url.clone()),
                    Some(extensions::Action::Run { args }) => Action::RunExtension {
                        manifest: manifest.clone(),
                        args: args.clone(),
                        key: key.into(),
                    },
                    None => Action::Noop,
                };
                let mut row = item(
                    &format!("extension-result:{}:{}", manifest.id, entry.id),
                    &entry.title,
                    &entry.subtitle,
                    "utilities-terminal-symbolic",
                    if manifest.runtime == extensions::Runtime::Wasm {
                        "WASM"
                    } else {
                        "Script"
                    },
                    action,
                );
                Self::extension_icon(
                    &session.manifest,
                    entry.icon.as_deref().unwrap_or(&manifest.icon),
                    &mut row,
                );
                row
            })
            .collect::<Vec<_>>();
        if !session.status.is_empty() {
            rows.push(item(
                "extension-status",
                &session.status,
                "Extension status",
                "utilities-terminal-symbolic",
                if session.done { "Done" } else { "Running" },
                Action::Noop,
            ));
        } else if rows.is_empty() {
            rows.push(item(
                "extension-empty",
                "No extension results",
                "Try another query or Ctrl+R",
                "utilities-terminal-symbolic",
                "Info",
                Action::Noop,
            ));
        }
        rows
    }
    fn emoji_items(&self) -> Vec<Item> {
        let store = self.store.borrow();
        let mut rows = emoji_items();
        let mut seen = std::collections::HashSet::new();
        for row in &mut rows {
            if let Action::Copy(symbol) = &mut row.action {
                let chosen = store
                    .emoji_tones
                    .get(&emoji::base(symbol))
                    .copied()
                    .or(store.emoji_skin_tone);
                let preferred = emoji::variant(symbol, chosen);
                row.icon = preferred.clone();
                row.keywords.push_str(&format!(" {preferred}"));
                if preferred != *symbol {
                    row.subtitle = format!(
                        "{} · preferred skin tone · Enter copies",
                        row.subtitle
                            .split(" · Enter")
                            .next()
                            .unwrap_or(&row.subtitle)
                    );
                }
                *symbol = preferred;
            }
        }
        rows.retain(|row| match &row.action {
            Action::Copy(symbol) => seen.insert(symbol.clone()),
            _ => true,
        });
        for (symbol, name) in emoji::kaomoji() {
            let mut row = item(
                &format!("kaomoji:{name}"),
                name,
                &format!("{symbol} · Enter copies"),
                "face-smile-symbolic",
                "Kaomoji",
                Action::Copy((*symbol).into()),
            );
            row.keywords = format!("kaomoji emoticon text face {name} {symbol}");
            rows.push(row);
        }
        rows
    }
    fn emoji_tones(self: &Rc<Self>) {
        let dialog = gtk::Window::builder()
            .title("Emoji Skin Tone")
            .transient_for(&self.window)
            .modal(true)
            .default_width(420)
            .build();
        let panel = gtk::Box::new(gtk::Orientation::Vertical, 10);
        panel.add_css_class("editor");
        let help = gtk::Label::new(Some(
            "Choose your default skin tone. Selecting a specific emoji variant also remembers its tone for future picks.",
        ));
        help.set_wrap(true);
        panel.append(&help);
        for (tone, label) in [
            (None, "👍 Default"),
            (Some(1), "👍🏻 Light"),
            (Some(2), "👍🏼 Medium-light"),
            (Some(3), "👍🏽 Medium"),
            (Some(4), "👍🏾 Medium-dark"),
            (Some(5), "👍🏿 Dark"),
        ] {
            let button = gtk::Button::with_label(label);
            let weak = Rc::downgrade(self);
            let d = dialog.downgrade();
            button.connect_clicked(move |_| {
                if let Some(ui) = weak.upgrade()
                    && ui.can_save
                {
                    let mut store = ui.store.borrow_mut();
                    store.emoji_skin_tone = tone;
                    store.emoji_tones.clear();
                    drop(store);
                    ui.save();
                    ui.refresh();
                }
                if let Some(d) = d.upgrade() {
                    d.close();
                }
            });
            panel.append(&button);
        }
        dialog.set_child(Some(&panel));
        dialog.present();
    }
    fn root(&self) -> Vec<Item> {
        let mut out = self.apps.borrow().clone();
        out.push(item(
            "local-ai-context",
            "Context-aware Local AI",
            "Review selected project, windows and todos before sending",
            "system-search-symbolic",
            "Local AI",
            Action::Query("ai context".into()),
        ));
        out.push(item(
            "clipboard-vault",
            "Secure Clipboard Vault",
            "Master password · encrypted pins expire after one hour",
            "changes-prevent-symbolic",
            "Vault",
            Action::Vault,
        ));
        out.push(item(
            "workflow-builder",
            "Workflow Builder",
            "Visual action chains saved as local WASM",
            "view-list-symbolic",
            "Workflow",
            Action::Automation(automation_ui::Command::Builder(None)),
        ));
        let mut help = item(
            "walkthrough",
            "Spotlight Guide",
            "Every feature, commands, examples, and shortcuts · F1",
            "help-browser-symbolic",
            "Guide",
            Action::Walkthrough,
        );
        help.keywords =
            "guide help walkthrough basics tutorial getting started features functions commands"
                .into();
        out.push(help);
        if self.store.borrow().commands.enabled("extensions") {
            out.extend(self.extension_menu());
        }
        let mut clear = item(
            "clear-clipboard-history",
            "Clear Clipboard History",
            "Clear Klipper history with confirmation · keeps Spotlight pins",
            "edit-clear-symbolic",
            "Clipboard",
            Action::ClearClipboard,
        );
        clear.keywords = "clear clipboard history clip clear".into();
        out.push(clear);
        out.push(item(
            "emoji-tones",
            "Emoji Skin Tone",
            "Choose a default tone · individual choices are remembered",
            "preferences-desktop-accessibility-symbolic",
            "Emoji",
            Action::EmojiTones,
        ));
        if self.store.borrow().selected_font.is_some() {
            out.push(item(
                "reset-font",
                "Reset Spotlight Font",
                "Restore Spotlight's default font",
                "preferences-desktop-font-symbolic",
                "Font",
                Action::ResetFont,
            ));
        }
        if !self.store.borrow().ringing_reminders.is_empty() {
            out.push(item(
                "dismiss-alarm",
                "Dismiss Alarm",
                "Stop the alarm sound and close the alert",
                "alarm-symbolic",
                "Dismiss",
                Action::DismissAlarms,
            ));
        }
        out.push(item(
            "quick-note",
            "Quick Note",
            &format!("{} · multiline capture", self.note_destination()),
            "document-edit-symbolic",
            "Note",
            Action::QuickNote(String::new()),
        ));
        let mut add_event = item(
            "add-calendar-event",
            "Add Calendar Event",
            "event Dinner on July 13 2027 at 6pm · review before saving",
            "x-office-calendar-symbolic",
            "Calendar",
            Action::CalendarEvent(calendar::Draft::default()),
        );
        add_event.keywords = "new event add event create event calendar appointment".into();
        out.push(add_event);
        let store = self.store.borrow();
        for (index, snippet) in store.snippets.iter().enumerate() {
            let mut result = item(
                &format!("snippet:{index}"),
                &snippet.name,
                &format!(
                    "Snippet · {} · Enter to copy",
                    if snippet.trigger.is_empty() {
                        "add a trigger in Snippets"
                    } else {
                        &snippet.trigger
                    }
                ),
                "document-edit-symbolic",
                "Snippet",
                Action::Snippet(snippet.value.clone()),
            );
            result.keywords = snippet.trigger.clone();
            out.push(result);
        }
        if let Some(vault) = &store.obsidian_vault {
            out.push(item(
                "obsidian-vault",
                "Open Obsidian Vault",
                &vault.to_string_lossy(),
                "document-open-symbolic",
                "Obsidian",
                Action::Open(format!(
                    "obsidian://open?vault={}",
                    core::encode(&vault.file_name().unwrap_or_default().to_string_lossy())
                )),
            ));
        }
        for note in &store.quick_notes {
            if note.path.is_file() {
                out.push(item(
                    &format!("quick-note:{}", note.path.display()),
                    &note.title,
                    if note.obsidian {
                        "Quick note · Open in Obsidian"
                    } else {
                        "Quick note · Open Markdown file"
                    },
                    "document-edit-symbolic",
                    "Note",
                    Action::Open(quicknote::open_uri(note)),
                ));
            }
        }
        drop(store);
        out.push(item(
            "set-timer",
            "Set Timer",
            "Type timer 5m or timer 1h30m · runs while Spotlight is hidden",
            "alarm-symbolic",
            "Command",
            Action::TimerSetup,
        ));
        out.push(item(
            "set-alarm",
            "Set Alarm",
            "Type alarm 7:30 am or alarm 18:45 · local time",
            "alarm-symbolic",
            "Command",
            Action::AlarmSetup,
        ));
        for entry in &self.store.borrow().reminders {
            let date = glib::DateTime::from_unix_local(entry.due)
                .ok()
                .and_then(|date| date.format("%a %d %b · %H:%M:%S").ok())
                .map(|date| date.to_string())
                .unwrap_or_default();
            out.push(item(
                &format!("reminder:{}", entry.id),
                &format!("Cancel {}", entry.title),
                &format!("Due {date} · Enter to cancel"),
                "alarm-symbolic",
                "Active",
                Action::CancelReminder(entry.id.clone()),
            ));
        }
        let mut picker = item(
            "color-picker",
            "Color Picker",
            "Pick a screen pixel · choose HEX, RGB, HSL, HSV · Escape cancels",
            "color-select-symbolic",
            "Command",
            Action::PickColor,
        );
        picker.keywords = "color colour picker pick eyedropper pipette screen pixel".into();
        out.push(picker);
        let mut ruler = item(
            "measure-screen",
            "Screen Measurement",
            "Drag to measure width, height, and distance in pixels · copy the result",
            "accessories-calculator-symbolic",
            "Command",
            Action::MeasureScreen,
        );
        ruler.keywords =
            "measure measurement ruler screen distance dimensions width height pixels mesurment"
                .into();
        out.push(ruler);
        let awake = self.caffeinate.borrow().is_some();
        let focus_awake = self.pomodoro_awake.borrow().is_some();
        let mut caffeine = item(
            "caffeinate",
            if awake {
                "Turn Off Caffeinate"
            } else if focus_awake {
                "Caffeinate · Pomodoro active"
            } else {
                "Caffeinate · Keep Awake"
            },
            if awake {
                if focus_awake {
                    "Manual Caffeinate active · Enter turns off manual mode; Pomodoro stays awake"
                } else {
                    "Active · Enter to restore normal screen and sleep settings"
                }
            } else if focus_awake {
                "Pomodoro is keeping awake · Enter also enables manual Caffeinate"
            } else {
                "Keep the screen and computer awake while Spotlight runs · Enter to turn on"
            },
            "weather-clear-symbolic",
            if awake {
                "On"
            } else if focus_awake {
                "Pomodoro"
            } else {
                "Off"
            },
            Action::Caffeinate,
        );
        caffeine.keywords =
            "caffeinate caffinate caffeine keep awake screen sleep suspend prevent disable".into();
        out.push(caffeine);
        for (id, title, detail, query) in [
            (
                "local-todos",
                "Local Todos",
                "todo add buy milk · todo · todo done · editable todos.md",
                "todo",
            ),
            (
                "saved-layouts",
                "Window Layouts",
                "layout save work · layout work",
                "layout",
            ),
            (
                "paste-queue",
                "Clipboard Paste Queue",
                "clip queue · paste pins in order",
                "clip queue",
            ),
            (
                "start-pomodoro",
                "Pomodoro",
                "pomodoro 25m · Caffeinate turns on during focus",
                "pomodoro 25m",
            ),
        ] {
            out.push(item(
                id,
                title,
                detail,
                "view-list-symbolic",
                "Command",
                Action::Query(query.into()),
            ));
        }
        out.push(window_shortcuts_item());
        out.push(item(
            "desktop-snippets",
            if self.store.borrow().desktop_snippets {
                "Disable Desktop Snippet Expansion"
            } else {
                "Enable Desktop Snippet Expansion"
            },
            "Expand trigger words across apps with Espanso · configure triggers in Snippets",
            "document-edit-symbolic",
            "Snippets",
            Action::DesktopSnippets,
        ));
        for (id, title, detail, query) in [
            (
                "offline-translate",
                "Offline Translator / Dictionary",
                "Local dictd and dictionary files · translate en es hello",
                "translate ",
            ),
            (
                "switch-windows",
                "Window Switcher",
                "List open KWin windows · window chrome",
                "window ",
            ),
            (
                "tldr",
                "Cheat Sheet · tldr",
                "Read command examples inside Spotlight · tldr tar",
                "tldr ",
            ),
            (
                "uuid",
                "Generate UUID",
                "Random UUID v4 · Enter copies",
                "uuid",
            ),
            (
                "hash",
                "Hash Generator",
                "hash mytext · SHA-256, SHA-512, SHA-1, MD5",
                "hash ",
            ),
            (
                "base64",
                "Base64 Encode / Decode",
                "base64 encode mytext or base64 decode <text>",
                "base64 encode ",
            ),
            (
                "content-search",
                "Search File Contents",
                "Use ripgrep · in: notes rust or in: ~/Projects phrase",
                "rg ",
            ),
            (
                "windows",
                "Open Windows",
                "Search open windows by title, app, and desktop",
                "window ",
            ),
            (
                "desktops",
                "Virtual Desktops",
                "Switch virtual desktops by name or number",
                "desktop ",
            ),
            (
                "switcher",
                "Window & Desktop Switcher",
                "Find windows and virtual desktops together",
                "switch ",
            ),
            (
                "contacts",
                "Search Contacts",
                "Akonadi / KAddressBook and local vCard resources",
                "contacts ",
            ),
            (
                "calendar",
                "Search Calendar",
                "Akonadi events and local iCalendar resources",
                "calendar ",
            ),
            (
                "dictionary",
                "Dictionary · Define Word",
                "Type define <word> · English definitions and examples",
                "define ",
            ),
            (
                "process-killer",
                "Process Killer",
                "Type kill firefox · choose a PID to terminate",
                "kill ",
            ),
            (
                "git-repos",
                "Git Repositories",
                "Fuzzy-search local repositories · open folder or GitHub",
                "git ",
            ),
            (
                "git-clone",
                "Git Clone",
                "Clone a repository into ~/Projects",
                "git clone ",
            ),
            (
                "github-view",
                "GitHub · View Repository",
                "Type gh repo view owner/repo or a local repository name",
                "gh repo view ",
            ),
            (
                "code-projects",
                "VS Code · Recent Projects",
                "Fuzzy-search recent VS Code folders and workspaces",
                "code ",
            ),
            (
                "jetbrains-projects",
                "JetBrains · Recent Projects",
                "Search recent projects across installed JetBrains IDEs",
                "jetbrains ",
            ),
            (
                "project-context",
                "Set Project Context",
                "Choose a project for GitHub commands and .env inspection",
                "project ",
            ),
            (
                "ssh-hosts",
                "SSH Hosts",
                "Find a configured SSH alias and connect in Konsole",
                "ssh ",
            ),
            (
                "environment-vars",
                "Environment Variables",
                "Search Spotlight’s process environment · Enter to inspect",
                "env ",
            ),
            (
                "dotenv-inspector",
                "Dotenv Inspector",
                "Inspect the current project’s .env or an explicit file path",
                "dotenv ",
            ),
            (
                "github-pulls",
                "GitHub · Pull Requests",
                "List or search pull requests in the current project",
                "gh pr list ",
            ),
            (
                "github-issues",
                "GitHub · Issues",
                "List or search issues in the current project",
                "gh issue ",
            ),
            (
                "docker-containers",
                "Docker Containers",
                "List containers · start or stop from Spotlight",
                "docker ",
            ),
            (
                "local-ai",
                "Local AI · Summarize Clipboard",
                "Summarize text with local-only Ollama",
                "ai summarize clipboard",
            ),
            (
                "calendar-availability",
                "Find a Free Meeting Slot",
                "Cached Akonadi availability · meet in 2h for 30m",
                "meet in 2h",
            ),
            (
                "extension-store",
                "Extension Store",
                "Browse the local catalog · reviewed WASM installs",
                "store",
            ),
            (
                "podman-containers",
                "Podman Containers",
                "List containers · start or stop from Spotlight",
                "podman ",
            ),
        ] {
            out.push(item(
                id,
                title,
                detail,
                "utilities-terminal-symbolic",
                "Command",
                Action::Query(query.into()),
            ));
        }
        for command in desktop::Command::ALL {
            let mut entry = item(
                command.id(),
                command.title(),
                &self.desktop_snapshot.borrow().description(command),
                command.icon(),
                "System",
                Action::Desktop(command),
            );
            entry.keywords = command.keywords().into();
            out.push(entry);
        }
        out.push(item(
            "color-formats",
            "Color Formats",
            "Convert the picked color · HEX, RGB, HSL, HSV",
            "color-select-symbolic",
            "Colors",
            Action::Page(Page::Colors),
        ));
        if let Some(hex) = self.picked_color.borrow().as_ref() {
            let mut picked = item(
                "picked-color",
                hex,
                "Last picked color · Enter to choose a copy format",
                "color-select-symbolic",
                "Color",
                Action::Page(Page::Colors),
            );
            picked.keywords = "color colour picked formats hex rgb rgba hsl hsla hsv hsb".into();
            out.push(picked);
        }
        for (p, name, desc, icon) in [
            (
                Page::Windows,
                "Window Manager",
                "Tile, maximize, restore, or move your active window · KDE",
                "view-grid-symbolic",
            ),
            (
                Page::Files,
                "Search File",
                "Find files and folders in your home directory",
                "folder-symbolic",
            ),
            (
                Page::Recent,
                "Recent",
                "Recently opened files and folders · newest first",
                "document-open-recent-symbolic",
            ),
            (
                Page::Clipboard,
                "Clipboard History",
                "Search and copy previous clipboard entries",
                "edit-paste-symbolic",
            ),
            (
                Page::Snippets,
                "Snippets",
                "Keep text you use often within reach",
                "insert-text-symbolic",
            ),
            (
                Page::Links,
                "Quicklinks",
                "Your favorite websites, one keystroke away",
                "web-browser-symbolic",
            ),
            (
                Page::Notes,
                "Notes",
                "Capture an idea without leaving your flow",
                "document-edit-symbolic",
            ),
            (
                Page::Scripts,
                "Script Commands",
                "Plugins · sandboxed WASM and executable scripts",
                "utilities-terminal-symbolic",
            ),
            (
                Page::Fonts,
                "Search Fonts",
                "Preview installed fonts · use in Spotlight or copy the name",
                "preferences-desktop-font-symbolic",
            ),
            (
                Page::Emoji,
                "Emoji & Symbols",
                "Everyday emoji · your most-used picks first",
                "face-smile-symbolic",
            ),
        ] {
            if matches!(p, Page::Files | Page::Recent) && self.search.text().trim().is_empty() {
                continue;
            }
            out.push(item(name, name, desc, icon, "Command", Action::Page(p)));
        }
        for (name, icon, args) in [
            (
                "Lock Screen",
                "system-lock-screen-symbolic",
                vec!["loginctl", "lock-session"],
            ),
            (
                "System Settings",
                "preferences-system-symbolic",
                vec!["systemsettings"],
            ),
        ] {
            out.push(item(
                name,
                name,
                "System action",
                icon,
                "System",
                Action::System(args.into_iter().map(str::to_string).collect()),
            ));
        }
        out.push(item(
            "settings",
            "Spotlight Settings",
            "Manage your launcher and keyboard shortcut",
            "emblem-system-symbolic",
            "Command",
            Action::Settings,
        ));
        for (title, description, query) in [
            (
                "Copy Password",
                "Bitwarden via rbw or a local KeePassXC database",
                "pass ",
            ),
            (
                "KeePassXC Setup",
                "Choose database and optional key file",
                "keepass setup",
            ),
            (
                "Ping Host",
                "Three bounded probes · inline, copyable results",
                "ping ",
            ),
            ("DNS Lookup", "Look up a hostname with dig", "dig "),
            (
                "Listening Ports",
                "Local listening TCP and UDP sockets",
                "my ports",
            ),
            (
                "Scan Wi-Fi",
                "Nearby networks via NetworkManager",
                "scan wifi",
            ),
            (
                "Network Routes",
                "Local routing table via iproute2",
                "my routes",
            ),
            (
                "Encrypt File",
                "GPG encryption · original kept",
                "encrypt file",
            ),
            (
                "Decrypt File",
                "GPG decryption · original kept",
                "decrypt file",
            ),
            ("Checksum File", "SHA-256 file checksum", "checksum file"),
            (
                "Shred File",
                "Permanent overwrite and removal · confirmation required",
                "shred file",
            ),
            (
                "Next Wallpaper",
                "Cycle local wallpapers on KDE",
                "wallpaper next",
            ),
            (
                "Accent Color",
                "Set KDE and Spotlight accent",
                "accent blue",
            ),
            (
                "IP Addresses",
                "Local and public IP addresses · ip or my ip",
                "ip",
            ),
            (
                "Battery Status",
                "Battery charge and charging state",
                "battery",
            ),
            ("Disk Usage", "Inline disk space for root and home", "disk"),
            ("Memory Usage", "RAM and swap usage · ram", "ram"),
            ("System Uptime", "Uptime and load averages", "uptime"),
            (
                "Generate QR Code",
                "Type qr followed by text or a URL",
                "qr ",
            ),
            (
                "OCR Image to Text",
                "Extract text from clipboard images or screenshots · Tesseract",
                "ocr",
            ),
            (
                "Lorem Ipsum",
                "Generate placeholder paragraphs · lorem 5",
                "lorem 5",
            ),
            (
                "Convert Text Case",
                "camel, snake, kebab, pascal, upper, lower, or title",
                "case camel ",
            ),
            (
                "Format JSON",
                "Validate and format JSON · json format {…}",
                "json format ",
            ),
            (
                "Audio Outputs",
                "Switch speakers, HDMI, or headphones",
                "speakers",
            ),
            (
                "Take Screenshot",
                "Capture once · Tab for OCR, QR, Compress, Pin and Save",
                "screenshot",
            ),
            (
                "Git Status Dashboard",
                "Dirty repositories under ~/Projects",
                "git status",
            ),
            (
                "Docker Logs",
                "Tail container logs in Spotlight",
                "docker logs ",
            ),
            (
                "Docker Exec",
                "Open an interactive container shell",
                "docker exec ",
            ),
            (
                "HTTP Scratch",
                "Make HTTP requests and inspect responses locally",
                "http ",
            ),
            (
                "Compare Dotenv Files",
                "Compare .env and .env.example in the current project",
                "dotenv diff",
            ),
            (
                "Music Controls",
                "Play, pause and skip MPRIS players",
                "music",
            ),
            (
                "Browser History",
                "Search Firefox, Chrome, Chromium and Brave history",
                "history ",
            ),
            (
                "Browser Bookmarks",
                "Search local browser bookmarks",
                "bookmark ",
            ),
            (
                "Compress Image 50%",
                "Save a WebP at quality 50 · original kept",
                "compress image 50%",
            ),
            (
                "Resize Image 1080p",
                "Fit within 1920 × 1080 · original kept",
                "resize 1080p",
            ),
            (
                "PDF Text",
                "Extract text locally with pdftotext",
                "pdf text",
            ),
            (
                "Image to WebP",
                "Convert locally · original kept",
                "image to webp",
            ),
            (
                "Color Palette from Image",
                "Choose an image and copy its dominant colors",
                "palette",
            ),
            (
                "Browser Tabs",
                "Recent Chrome pages · optional connected live tabs",
                "tabs chrome",
            ),
            (
                "Close Window",
                "Find a window and request a normal close",
                "close window",
            ),
            (
                "Quit App",
                "Close an application's windows with confirmation",
                "quit app",
            ),
            (
                "Force Quit Window",
                "Find a window to force quit · confirmation required",
                "kill window",
            ),
            (
                "Search Packages",
                "Search apt, pacman, or Flatpak · review installation first",
                "packages ",
            ),
            (
                "User Services",
                "Status and confirmed start, restart, or stop",
                "service status",
            ),
            (
                "System Services",
                "Status and confirmed actions with desktop authorization",
                "systemctl status",
            ),
            (
                "Bluetooth Devices",
                "Connect or disconnect known Bluetooth devices",
                "bluetooth devices",
            ),
        ] {
            out.push(item(
                &format!("command:{title}"),
                title,
                description,
                "system-search-symbolic",
                "Command",
                Action::Query(query.into()),
            ));
        }
        out.push(item(
            "quit",
            "Quit Spotlight",
            "Stop the background launcher",
            "application-exit-symbolic",
            "Command",
            Action::Quit,
        ));
        let store = self.store.borrow();
        for (i, link) in store.links.iter().enumerate() {
            out.push(item(
                &format!("link:{i}"),
                &link.name,
                &link.value,
                "web-browser-symbolic",
                "Quicklink",
                Action::Open(link.value.clone()),
            ));
        }
        out.retain(|item| {
            customization::item_category(item).is_none_or(|c| store.commands.enabled(c))
        });
        out
    }
    fn currency_item(self: &Rc<Self>, query: currency::Query) -> Item {
        let (source, target) = &query.pair;
        if source == target {
            let value = currency::convert(&query, 1.).unwrap();
            return item(
                "currency",
                &value,
                "Same currency · Enter to copy",
                "accessories-calculator-symbolic",
                "Currency",
                Action::Copy(value.clone()),
            );
        }
        if let Some((fetched, result)) = self.currency.borrow().cache.get(&query.pair) {
            let ttl = if result.is_ok() { 900 } else { 30 };
            if fetched.elapsed().as_secs() < ttl {
                return match result {
                    Ok(rate) => match currency::convert(&query, rate.rate) {
                        Some(value) => item(
                            "currency",
                            &value,
                            &format!(
                                "Frankfurter · rate date {} · 1 {source} = {} {target} · Enter to copy",
                                rate.date, rate.rate
                            ),
                            "accessories-calculator-symbolic",
                            "Currency",
                            Action::Copy(value.clone()),
                        ),
                        None => item(
                            "currency",
                            "Amount is too large",
                            "Try a smaller amount",
                            "dialog-warning-symbolic",
                            "Currency",
                            Action::Noop,
                        ),
                    },
                    Err(message) => item(
                        "currency",
                        "Currency conversion unavailable",
                        message,
                        "network-offline-symbolic",
                        "Currency",
                        Action::Noop,
                    ),
                };
            }
        }
        if self
            .currency
            .borrow_mut()
            .pending
            .insert(query.pair.clone())
        {
            let weak = Rc::downgrade(self);
            let pair = query.pair.clone();
            glib::timeout_add_local_once(Duration::from_millis(400), move || {
                let Some(ui) = weak.upgrade() else { return };
                let current = currency::parse(&ui.effective_query());
                if *ui.page.borrow() != Page::Root || !current.is_some_and(|q| q.pair == pair) {
                    ui.currency.borrow_mut().pending.remove(&pair);
                    return;
                }
                let (tx, rx) = mpsc::channel();
                let request_pair = pair.clone();
                std::thread::spawn(move || {
                    let _ = tx.send(currency::fetch(&request_pair));
                });
                let weak = Rc::downgrade(&ui);
                glib::timeout_add_local(Duration::from_millis(80), move || {
                    let Some(ui) = weak.upgrade() else {
                        return glib::ControlFlow::Break;
                    };
                    let result = match rx.try_recv() {
                        Ok(result) => result,
                        Err(mpsc::TryRecvError::Empty) => return glib::ControlFlow::Continue,
                        Err(_) => Err("Currency request interrupted".into()),
                    };
                    let mut state = ui.currency.borrow_mut();
                    state.pending.remove(&pair);
                    if state.cache.len() >= 64 {
                        state.cache.clear();
                    }
                    state
                        .cache
                        .insert(pair.clone(), (std::time::Instant::now(), result));
                    drop(state);
                    if *ui.page.borrow() == Page::Root
                        && currency::parse(&ui.effective_query()).is_some_and(|q| q.pair == pair)
                    {
                        ui.refresh();
                    }
                    glib::ControlFlow::Break
                });
            });
        }
        item(
            "currency",
            "Fetching exchange rate…",
            &format!("{source} → {target} · Frankfurter"),
            "network-transmit-receive-symbolic",
            "Currency",
            Action::Noop,
        )
    }
    fn cancel_content(&self) {
        if let Some(session) = self.content_session.borrow_mut().take() {
            self.booster_pending
                .borrow_mut()
                .remove(&boosters::Query::Search(session.query.clone()));
        }
    }
    fn content_entries(self: &Rc<Self>, query: search::Query) -> Vec<boosters::Entry> {
        if self.content_session.borrow().is_none() {
            let cancel = std::sync::Arc::new(std::sync::atomic::AtomicBool::new(false));
            *self.content_session.borrow_mut() = Some(ContentSession {
                query: query.clone(),
                cancel: cancel.clone(),
                rows: Vec::new(),
                done: false,
            });
            self.booster_pending
                .borrow_mut()
                .insert(boosters::Query::Search(query.clone()));
            let weak = Rc::downgrade(self);
            glib::timeout_add_local_once(Duration::from_millis(120), move || {
                let Some(ui) = weak.upgrade() else {
                    return;
                };
                if cancel.load(std::sync::atomic::Ordering::Relaxed) || !ui.window.is_visible() {
                    return;
                }
                let (tx, rx) = mpsc::channel();
                let worker_cancel = cancel.clone();
                std::thread::spawn(move || search::stream(&query, worker_cancel, tx));
                let weak = Rc::downgrade(&ui);
                glib::timeout_add_local(Duration::from_millis(40), move || {
                    let Some(ui) = weak.upgrade() else {
                        return glib::ControlFlow::Break;
                    };
                    let selected = ui
                        .selected()
                        .filter(|i| matches!(i.action, Action::Preview { .. }))
                        .map(|i| i.id);
                    let (done, changed, query) = {
                        let mut guard = ui.content_session.borrow_mut();
                        let Some(session) = guard
                            .as_mut()
                            .filter(|s| std::sync::Arc::ptr_eq(&s.cancel, &cancel))
                        else {
                            return glib::ControlFlow::Break;
                        };
                        let mut changed = false;
                        loop {
                            match rx.try_recv() {
                                Ok(search::Update::Match(row)) => {
                                    session.rows.push(*row);
                                    changed = true;
                                }
                                Ok(search::Update::Done(result)) => {
                                    session.rows = result.unwrap_or_else(|error| {
                                        vec![boosters::hint(
                                            error,
                                            "Ctrl+R retries · use rg phrase or in: ~/folder phrase",
                                        )]
                                    });
                                    session.done = true;
                                    changed = true;
                                    break;
                                }
                                Err(mpsc::TryRecvError::Empty) => break,
                                Err(_) => {
                                    session.done = true;
                                    break;
                                }
                            }
                        }
                        (session.done, changed, session.query.clone())
                    };
                    if done {
                        ui.booster_pending
                            .borrow_mut()
                            .remove(&boosters::Query::Search(query));
                    }
                    if changed {
                        ui.refresh();
                        if let Some(id) = selected
                            && let Some(index) = ui.visible.borrow().iter().position(|i| i.id == id)
                        {
                            ui.list
                                .select_row(ui.list.row_at_index(index as i32).as_ref());
                        }
                    }
                    if done {
                        glib::ControlFlow::Break
                    } else {
                        glib::ControlFlow::Continue
                    }
                });
            });
        }
        let session = self.content_session.borrow();
        let session = session.as_ref().unwrap();
        let mut rows = session.rows.clone();
        if !session.done {
            rows.push(boosters::hint(
                "Searching file contents…",
                "ripgrep · results arrive as files match · change the query to cancel",
            ));
        }
        rows
    }
    fn booster_items(self: &Rc<Self>, query: boosters::Query) -> Vec<Item> {
        let entries =
            if let boosters::Query::Search(content @ search::Query::Content { .. }) = &query {
                self.content_entries(content.clone())
            } else {
                let cached = self
                    .booster_cache
                    .borrow()
                    .get(&query)
                    .filter(|(time, result)| {
                        time.elapsed()
                            < if result.is_err() {
                                Duration::from_secs(30)
                            } else {
                                query.ttl()
                            }
                    })
                    .map(|(_, result)| result.clone());
                if let Some(result) = cached {
                    result.unwrap_or_else(|error| {
                        vec![boosters::hint(
                            error,
                            "Check the command or required tool · Ctrl+R retries",
                        )]
                    })
                } else {
                    if self.booster_pending.borrow_mut().insert(query.clone()) {
                        let weak = Rc::downgrade(self);
                        let request = query.clone();
                        glib::timeout_add_local_once(Duration::from_millis(350), move || {
                            let Some(ui) = weak.upgrade() else { return };
                            if *ui.page.borrow() != Page::Root
                                || customization::category(&ui.effective_query())
                                    .is_some_and(|c| !ui.store.borrow().commands.enabled(c))
                                || boosters::Query::parse(&ui.effective_query()).as_ref()
                                    != Some(&request)
                            {
                                ui.booster_pending.borrow_mut().remove(&request);
                                return;
                            }
                            let (tx, rx) = mpsc::channel();
                            let work = request.clone();
                            std::thread::spawn(move || {
                                let _ = tx.send(boosters::fetch(&work));
                            });
                            let weak = Rc::downgrade(&ui);
                            glib::timeout_add_local(Duration::from_millis(60), move || {
                                let Some(ui) = weak.upgrade() else {
                                    return glib::ControlFlow::Break;
                                };
                                let result = match rx.try_recv() {
                                    Ok(result) => result,
                                    Err(mpsc::TryRecvError::Empty) => {
                                        return glib::ControlFlow::Continue;
                                    }
                                    Err(_) => Err("Command lookup interrupted".into()),
                                };
                                ui.booster_pending.borrow_mut().remove(&request);
                                let mut cache = ui.booster_cache.borrow_mut();
                                if cache.len() >= 48 {
                                    cache.clear();
                                }
                                cache.insert(request.clone(), (std::time::Instant::now(), result));
                                drop(cache);
                                if *ui.page.borrow() == Page::Root
                                    && boosters::Query::parse(&ui.effective_query()).as_ref()
                                        == Some(&request)
                                {
                                    ui.refresh();
                                }
                                glib::ControlFlow::Break
                            });
                        });
                    }
                    vec![boosters::hint("Loading…", "Searching in the background")]
                }
            };
        entries
            .into_iter()
            .enumerate()
            .map(|(n, e)| {
                let thumbnail = match &e.operation {
                    Some(boosters::Operation::OpenPath(path)) if search::image_path(path) => {
                        Some(path.clone())
                    }
                    _ => None,
                };
                let action = match e.operation {
                    Some(boosters::Operation::Local(localtools::Operation::Open(uri))) => {
                        Action::Open(uri)
                    }
                    Some(boosters::Operation::Query(query)) => Action::Query(query),
                    Some(boosters::Operation::Preview { title, text, open }) => {
                        Action::Preview { title, text, open }
                    }
                    Some(boosters::Operation::OpenPath(path)) => {
                        Action::Open(gio::File::for_path(path).uri().into())
                    }
                    Some(boosters::Operation::Copy(text)) => Action::Copy(text),
                    Some(boosters::Operation::OpenRepo(path)) => {
                        Action::Open(gio::File::for_path(path).uri().into())
                    }
                    Some(op) => Action::Booster(op),
                    None => Action::Noop,
                };
                let id = if matches!(
                    query,
                    boosters::Query::System(systemtools::Query::Password(..))
                ) {
                    format!("booster:password:{n}")
                } else if matches!(
                    query,
                    boosters::Query::Productivity(productivity::Query::Ai(_))
                ) {
                    format!("booster:context-ai:{n}")
                } else {
                    format!("booster:{query:?}:{n}")
                };
                let mut row = item(
                    &id,
                    &e.title,
                    &e.detail,
                    match &query {
                        boosters::Query::Search(search::Query::Content { .. }) => {
                            "system-search-symbolic"
                        }
                        boosters::Query::Search(_) => "document-open-recent-symbolic",
                        boosters::Query::Windows(_) => "focus-windows-symbolic",
                        boosters::Query::Desktops(_) | boosters::Query::Switcher(_) => {
                            "view-grid-symbolic"
                        }
                        boosters::Query::Pim(pim::Kind::Contacts, _) => "avatar-default-symbolic",
                        boosters::Query::Pim(pim::Kind::Calendar, _) => {
                            "x-office-calendar-symbolic"
                        }
                        _ => "utilities-terminal-symbolic",
                    },
                    e.badge,
                    action,
                );
                row.thumbnail = thumbnail;
                row
            })
            .collect()
    }
    fn execute_booster_now(self: &Rc<Self>, operation: boosters::Operation) {
        if self.booster_busy.replace(true) {
            self.error("A developer command is still running");
            return;
        }
        self.error("Running command…");
        let project_context = match &operation {
            boosters::Operation::Dev(devtools::Operation::OpenProject { path, .. }) => {
                Some(devtools::project_directory(path))
            }
            boosters::Operation::Dev(devtools::Operation::UseProject(path)) => Some(path.clone()),
            _ => None,
        };
        let switching = matches!(
            operation,
            boosters::Operation::FocusWindow(_) | boosters::Operation::SwitchDesktop(_)
        );
        if switching {
            self.window.set_visible(false);
        }
        let (tx, rx) = mpsc::channel();
        std::thread::spawn(move || {
            if switching {
                std::thread::sleep(Duration::from_millis(250));
            }
            let _ = tx.send(boosters::execute(operation));
        });
        let weak = Rc::downgrade(self);
        glib::timeout_add_local(Duration::from_millis(80), move || {
            let Some(ui) = weak.upgrade() else {
                return glib::ControlFlow::Break;
            };
            let result = match rx.try_recv() {
                Ok(result) => result,
                Err(mpsc::TryRecvError::Empty) => return glib::ControlFlow::Continue,
                Err(_) => Err("Command interrupted".into()),
            };
            ui.booster_busy.set(false);
            if result.is_ok()
                && let Some(path) = &project_context
            {
                ui.store.borrow_mut().project_context = Some(path.clone());
                ui.save();
            }
            if switching && result.is_err() {
                ui.window.present();
            }
            ui.booster_cache.borrow_mut().clear();
            ui.refresh();
            ui.error(match &result {
                Ok(message) | Err(message) => message,
            });
            glib::ControlFlow::Break
        });
    }
    fn toggle_desktop_snippets(self: &Rc<Self>) {
        if !self.can_save {
            self.error("Saved data is unreadable; cannot change snippet settings");
            return;
        }
        let mut store = self.store.borrow_mut();
        store.desktop_snippets = !store.desktop_snippets;
        let enabled = store.desktop_snippets;
        if let Err(error) = store.save() {
            store.desktop_snippets = !enabled;
            drop(store);
            self.error(&error);
            return;
        }
        let result = snippets::sync(&store.snippets, enabled);
        drop(store);
        self.refresh();
        if let Err(error) = result {
            self.error(&error);
            return;
        }
        if enabled {
            self.start_desktop_snippets();
        } else {
            self.desktop_snippets_running.set(false);
            self.error("Desktop snippet triggers disabled · Spotlight text fields still expand on Space or Tab");
        }
    }
    fn start_desktop_snippets(self: &Rc<Self>) {
        self.error("Starting desktop snippet expansion…");
        let (tx, rx) = mpsc::channel();
        std::thread::spawn(move || {
            let status = boosters::run(Command::new("espanso").arg("status"), 5);
            let result = if status
                .as_ref()
                .is_ok_and(|s| s.to_lowercase().contains("is running"))
            {
                Ok(String::new())
            } else {
                boosters::run(Command::new("espanso").args(["start", "--unmanaged"]), 15)
            };
            let _ = tx.send(result);
        });
        let weak = Rc::downgrade(self);
        glib::timeout_add_local(Duration::from_millis(100), move || {
            let Some(ui) = weak.upgrade() else {
                return glib::ControlFlow::Break;
            };
            if !ui.store.borrow().desktop_snippets {
                return glib::ControlFlow::Break;
            }
            match rx.try_recv() {
                Ok(Ok(_)) => {
                    ui.desktop_snippets_running.set(true);
                    ui.error("Desktop expansion enabled · create a snippet trigger, then type it followed by Space");
                }
                Ok(Err(error)) => {
                    ui.desktop_snippets_running.set(false);
                    ui.error(&format!("Triggers saved. Install and configure Espanso for your desktop first: {error}. See Settings → Text Expansion Setup. Expansion inside Spotlight remains available."));
                }
                Err(mpsc::TryRecvError::Empty) => return glib::ControlFlow::Continue,
                Err(_) => ui.error("Could not start desktop expansion"),
            }
            glib::ControlFlow::Break
        });
    }
    fn render_snippet(
        self: &Rc<Self>,
        template: String,
        apply: impl FnOnce(snippets::Rendered) + 'static,
    ) {
        if !template.contains("{clipboard}") {
            apply(snippets::render(&template, ""));
            return;
        }
        let formats = self.window.clipboard().formats();
        if !formats.contains_type(String::static_type())
            && !formats
                .mime_types()
                .iter()
                .any(|mime| mime.starts_with("text/plain"))
        {
            apply(snippets::render(&template, ""));
            return;
        }
        let weak = Rc::downgrade(self);
        self.window
            .clipboard()
            .read_text_async(None::<&gio::Cancellable>, move |result| {
                let Some(ui) = weak.upgrade() else {
                    return;
                };
                match result {
                    Ok(Some(text)) if text.len() <= 1_048_576 => {
                        apply(snippets::render(&template, &text))
                    }
                    Ok(Some(_)) => ui.error("Clipboard text exceeds 1 MiB"),
                    Ok(None) => apply(snippets::render(&template, "")),
                    Err(error) => ui.error(&format!("Could not read clipboard text: {error}")),
                }
            });
    }
    fn snippet_text_keys(self: &Rc<Self>, text: &gtk::TextView) {
        let keys = gtk::EventControllerKey::new();
        keys.set_propagation_phase(gtk::PropagationPhase::Capture);
        let weak = Rc::downgrade(self);
        let view = text.downgrade();
        keys.connect_key_pressed(move |_, key, _, modifiers| {
            if ![gdk::Key::space, gdk::Key::Tab].contains(&key)
                || modifiers.intersects(
                    gdk::ModifierType::CONTROL_MASK
                        | gdk::ModifierType::ALT_MASK
                        | gdk::ModifierType::SHIFT_MASK,
                )
            {
                return glib::Propagation::Proceed;
            }
            let (Some(ui), Some(view)) = (weak.upgrade(), view.upgrade()) else {
                return glib::Propagation::Proceed;
            };
            if ui.desktop_snippets_running.get() {
                return glib::Propagation::Proceed;
            }
            let buffer = view.buffer();
            if buffer.has_selection() {
                return glib::Propagation::Proceed;
            }
            let end = buffer.iter_at_offset(buffer.cursor_position());
            let prefix = buffer.text(&buffer.start_iter(), &end, false);
            let expansion = snippets::expansion(&prefix, &ui.store.borrow().snippets)
                .map(|(start, value)| (prefix[..start].chars().count() as i32, value.to_string()));
            if let Some((start, value)) = expansion {
                let original = buffer.text(&buffer.start_iter(), &buffer.end_iter(), false);
                let position = buffer.cursor_position();
                let weak_buffer = buffer.downgrade();
                ui.render_snippet(value, move |rendered| {
                    let Some(buffer) = weak_buffer.upgrade() else {
                        return;
                    };
                    if buffer.has_selection()
                        || buffer.cursor_position() != position
                        || buffer.text(&buffer.start_iter(), &buffer.end_iter(), false) != original
                    {
                        return;
                    }
                    let insert = format!(
                        "{}{}",
                        rendered.text,
                        if key == gdk::Key::space { " " } else { "" }
                    );
                    let cursor =
                        start + rendered.cursor.unwrap_or_else(|| insert.chars().count()) as i32;
                    let mut end = buffer.iter_at_offset(position);
                    let mut begin = buffer.iter_at_offset(start);
                    buffer.begin_user_action();
                    buffer.delete(&mut begin, &mut end);
                    buffer.insert(&mut begin, &insert);
                    buffer.place_cursor(&buffer.iter_at_offset(cursor));
                    buffer.end_user_action();
                });
                return glib::Propagation::Stop;
            }
            glib::Propagation::Proceed
        });
        text.add_controller(keys);
    }
    fn expand_search_snippet(self: &Rc<Self>, key: gdk::Key) -> bool {
        if self.desktop_snippets_running.get() || self.search.selection_bounds().is_some() {
            return false;
        }
        let text = self.search.text();
        let cursor = self.search.position().max(0) as usize;
        let at = text
            .char_indices()
            .nth(cursor)
            .map(|(i, _)| i)
            .unwrap_or(text.len());
        let prefix = &text[..at];
        let expansion = snippets::expansion(prefix, &self.store.borrow().snippets)
            .map(|(start, value)| (start, value.to_string()));
        let Some((start, value)) = expansion else {
            return false;
        };
        let position = self.search.position();
        let search = self.search.downgrade();
        self.render_snippet(value, move |rendered| {
            let Some(search) = search.upgrade() else {
                return;
            };
            if search.text() != text
                || search.position() != position
                || search.selection_bounds().is_some()
            {
                return;
            }
            let insert = format!(
                "{}{}",
                rendered.text,
                if key == gdk::Key::space { " " } else { "" }
            );
            let result = format!("{}{}{}", &text[..start], insert, &text[at..]);
            let cursor = text[..start].chars().count()
                + rendered.cursor.unwrap_or_else(|| insert.chars().count());
            search.set_text(&result);
            search.set_position(cursor as i32);
        });
        true
    }
    fn refresh(self: &Rc<Self>) {
        let query = self.effective_query();
        let q = query.trim();
        let page = *self.page.borrow();
        let commands = self.store.borrow().commands.clone();
        let allowed = customization::category(q).is_none_or(|c| commands.enabled(c));
        let web_query = q
            .strip_prefix("web ")
            .or_else(|| (q == "web").then_some(""));
        if page == Page::Root
            && allowed
            && let Some(filter) = clipboard::command(q)
        {
            let filter = filter.to_string();
            self.page(Page::Clipboard);
            if !filter.is_empty() {
                self.search.set_text(&format!("clip {filter}"));
                self.search.set_position(-1);
            }
            return;
        }
        let (clip_kind, clip_search) = if page == Page::Clipboard {
            clipboard::filter(q)
        } else {
            ("all", q)
        };
        let selected = self
            .rendered_search
            .borrow()
            .as_ref()
            .filter(|(previous_page, previous_query)| *previous_page == page && previous_query == q)
            .and_then(|_| self.selected().map(|item| item.id));
        let explicit_lookup = page == Page::Root
            && allowed
            && (web_query.is_some()
                || boosters::Query::parse(q).is_some()
                || extensions::query(q).is_some());
        if self.content_session.borrow().as_ref().is_some_and(|s| {
            page != Page::Root || search::Query::parse(q).as_ref() != Some(&s.query)
        }) {
            self.cancel_content();
        }
        if self
            .extension_session
            .borrow()
            .as_ref()
            .is_some_and(|s| page != Page::Root || s.key != q)
        {
            self.extension_session.borrow_mut().take();
        }
        self.section.set_text(page.title());
        let mut items = match page {
            Page::Root if explicit_lookup => Vec::new(),
            Page::Root => self.root(),
            Page::Windows => window_items(),
            Page::Files => {
                if *self.file_loading.borrow() {
                    self.section.set_text("Indexing your home folder…");
                }
                self.file_items(q, false)
            }
            Page::Recent => self.file_items(q, true),
            Page::Clipboard => self
                .clipboard_items()
                .into_iter()
                .filter(|i| match clip_kind {
                    "text" => matches!(i.action, Action::Copy(_)) || i.badge == "Secure text",
                    "images" => {
                        i.badge == "Secure image"
                            || matches!(
                                i.action,
                                Action::ClipboardImage(_) | Action::ClipboardTexture(_)
                            )
                    }
                    "pinned" => clipboard::is_pinned(&i.id),
                    _ => true,
                })
                .collect(),
            Page::Snippets | Page::Links | Page::Notes => {
                let store = self.store.borrow();
                let source = match page {
                    Page::Snippets => &store.snippets,
                    Page::Links => &store.links,
                    _ => &store.notes,
                };
                let mut v: Vec<_> = source
                    .iter()
                    .enumerate()
                    .map(|(i, s)| {
                        item(
                            &format!("text:{i}"),
                            &s.name,
                            &format!(
                                "{}{}",
                                if page == Page::Snippets && !s.trigger.is_empty() {
                                    format!("{} → ", s.trigger)
                                } else {
                                    String::new()
                                },
                                s.value
                                    .lines()
                                    .next()
                                    .unwrap_or("")
                                    .chars()
                                    .take(100)
                                    .collect::<String>()
                            ),
                            if page == Page::Links {
                                "web-browser-symbolic"
                            } else {
                                "document-edit-symbolic"
                            },
                            "⌃E Edit",
                            if page == Page::Links {
                                Action::Open(s.value.clone())
                            } else if page == Page::Notes {
                                Action::Edit(page, i)
                            } else {
                                Action::Snippet(s.value.clone())
                            },
                        )
                    })
                    .collect();
                if source.is_empty() {
                    v.push(item(
                        "new",
                        "Create your first item",
                        "Press Enter to get started",
                        "list-add-symbolic",
                        "Create",
                        Action::New(page),
                    ));
                }
                v
            }
            Page::Scripts => {
                use std::os::unix::fs::PermissionsExt;
                let dir = core::data_dir().join("scripts");
                std::fs::read_dir(dir)
                    .into_iter()
                    .flatten()
                    .flatten()
                    .filter(|e| {
                        e.file_type().is_ok_and(|t| t.is_file())
                            && e.metadata()
                                .is_ok_and(|m| m.permissions().mode() & 0o111 != 0)
                    })
                    .map(|e| {
                        let path = e.path();
                        let name = e.file_name().to_string_lossy().replace(['_', '-'], " ");
                        item(
                            &path.to_string_lossy(),
                            &name,
                            "Run executable · Ctrl+K for actions",
                            "utilities-terminal-symbolic",
                            "Script",
                            Action::Script(path.clone()),
                        )
                    })
                    .collect()
            }
            Page::Emoji => self.emoji_items(),
            Page::Fonts => self.font_items(),
            Page::Colors => self.color_items(),
        };
        if page == Page::Root && !q.is_empty() && !explicit_lookup {
            if commands.enabled("emoji") {
                items.extend(self.emoji_items());
            }
            if commands.enabled("fonts") {
                items.extend(self.font_items());
            }
            if commands.enabled("screen") && self.picked_color.borrow().is_some() {
                items.extend(self.color_items());
            }
        }
        if page == Page::Scripts {
            items.extend(self.extension_menu());
        }
        let store = self.store.borrow();
        let mut ranked: Vec<_> = items
            .drain(..)
            .filter_map(|i| {
                let s = if matches!(i.action, Action::FontPreview(_)) {
                    let explicit = page == Page::Fonts || fonts::query(q).is_some();
                    let score = core::score(fonts::query(q).unwrap_or(q), &i.title);
                    score.filter(|score| explicit || *score >= 500)
                } else if !i.keywords.is_empty() {
                    core::score(q, &i.title).max(core::score(q, &i.keywords).map(|s| s - 100))
                } else if page == Page::Clipboard {
                    if let Action::Copy(ref text) = i.action {
                        core::score(clip_search, text)
                    } else {
                        core::score(
                            clip_search,
                            &format!("{} {} image picture screenshot", i.title, i.subtitle),
                        )
                    }
                } else {
                    core::score(q, &i.title)
                        .or_else(|| core::score(q, &i.subtitle).map(|s| s - 100))
                }?;
                let bonus = if page == Page::Root {
                    (if store.favorites.contains(&i.id) {
                        300
                    } else {
                        0
                    }) + store.usage.get(&i.id).copied().unwrap_or(0).min(100) as i32
                        + if i.badge == "Recent" {
                            if q.is_empty() { 180 } else { 80 }
                        } else {
                            0
                        }
                        + if q.is_empty() && matches!(i.action, Action::Page(_)) {
                            25
                        } else {
                            0
                        }
                } else {
                    0
                };
                Some((s + bonus + i.priority, i))
            })
            .collect();
        if page == Page::Emoji && q.is_empty() {
            // Stable sorting keeps the curated order when personal usage ties.
            ranked.sort_by(|a, b| {
                store
                    .favorites
                    .contains(&b.1.id)
                    .cmp(&store.favorites.contains(&a.1.id))
                    .then_with(|| {
                        store
                            .usage
                            .get(&b.1.id)
                            .copied()
                            .unwrap_or(0)
                            .cmp(&store.usage.get(&a.1.id).copied().unwrap_or(0))
                    })
            });
        } else if page != Page::Colors || !q.is_empty() {
            let apps_first = page == Page::Root && !q.is_empty();
            ranked.sort_by(|a, b| {
                (apps_first && matches!(b.1.action, Action::App(_)))
                    .cmp(&(apps_first && matches!(a.1.action, Action::App(_))))
                    .then_with(|| b.0.cmp(&a.0))
                    .then_with(|| a.1.title.cmp(&b.1.title))
            });
        }
        let limit = if matches!(page, Page::Emoji | Page::Fonts) {
            self.result_limit.get()
        } else {
            60
        };
        let total = ranked.len();
        let mut results: Vec<Item> = ranked.into_iter().take(limit).map(|(_, i)| i).collect();
        if matches!(page, Page::Emoji | Page::Fonts) {
            self.section
                .set_text(&format!("{} · {} of {total}", page.title(), results.len()));
            if total > limit {
                results.push(item(
                    "results:more",
                    if page == Page::Fonts {
                        "Show more fonts"
                    } else {
                        "Show more emoji"
                    },
                    "Load the next 60 results",
                    "list-add-symbolic",
                    "Enter",
                    Action::MoreResults,
                ));
            }
        }
        drop(store);
        if page == Page::Root && allowed {
            let workflow_rows = self.workflow_rows(q);
            if q == "todo"
                || q == "todos"
                || q.starts_with("todo ")
                || q == "layout"
                || q.starts_with("layout ")
                || q.starts_with("clip queue")
                || q == "workflow"
                || q == "workflows"
                || q.starts_with("workflow ")
                || q == "vault"
                || q == "clip vault"
            {
                results = workflow_rows;
            } else {
                results.splice(0..0, workflow_rows);
            }
        }
        if page == Page::Root && !q.is_empty() && allowed {
            if fonts::query(q) == Some("") {
                results.retain(|entry| !matches!(entry.action, Action::Page(Page::Fonts)));
                results.insert(
                    0,
                    item(
                        "font-browser",
                        "Search Fonts",
                        "Browse, preview, and use installed fonts",
                        "preferences-desktop-font-symbolic",
                        "Fonts",
                        Action::Page(Page::Fonts),
                    ),
                );
            }
            if let Some(content) = quicknote::query(q) {
                let action = if content.is_empty() {
                    Action::QuickNote(String::new())
                } else {
                    Action::CaptureNote(content.to_string())
                };
                results.insert(
                    0,
                    item(
                        "capture-note",
                        if content.is_empty() {
                            "Quick Note"
                        } else {
                            "Save Quick Note"
                        },
                        &format!(
                            "{} · Enter to {}",
                            self.note_destination(),
                            if content.is_empty() {
                                "write a note"
                            } else {
                                "save"
                            }
                        ),
                        "document-edit-symbolic",
                        "Note",
                        action,
                    ),
                );
            }
            if let Some(parsed) = reminder::parse(q) {
                let entry = match parsed {
                    Ok(draft) => item(
                        "schedule-reminder",
                        &format!("Set {}", draft.label()),
                        if matches!(draft, reminder::Draft::Pomodoro(_)) {
                            "Enter to start · Caffeinate auto-on until finish or cancellation"
                        } else {
                            "Enter to start · search timer or alarm to cancel"
                        },
                        "alarm-symbolic",
                        "Set",
                        Action::Schedule(draft),
                    ),
                    Err(hint) => item(
                        "reminder-help",
                        "Set a timer or alarm",
                        hint,
                        "alarm-symbolic",
                        "Set",
                        if ["alarm", "set alarm", "set an alarm"]
                            .contains(&q.to_ascii_lowercase().as_str())
                        {
                            Action::AlarmSetup
                        } else if ["timer", "set timer", "set a timer"]
                            .contains(&q.to_ascii_lowercase().as_str())
                        {
                            Action::TimerSetup
                        } else {
                            Action::Noop
                        },
                    ),
                };
                results.insert(0, entry);
            }
            if let Some(answer) = commands
                .enabled("calculator")
                .then(|| core::calculate(q))
                .flatten()
            {
                results.insert(
                    0,
                    item(
                        "calculator",
                        &answer,
                        q,
                        "accessories-calculator-symbolic",
                        "Copy result",
                        Action::Copy(answer.clone()),
                    ),
                );
            }
            if commands.enabled("calculator")
                && core::calculate(q).is_none()
                && let Some(query) = currency::parse(q)
            {
                results.insert(0, self.currency_item(query));
            }
            if q.starts_with("https://") || q.starts_with("http://") {
                results.insert(
                    0,
                    item(
                        "url",
                        &format!("Open {q}"),
                        "Open in your default browser",
                        "web-browser-symbolic",
                        "Open",
                        Action::Open(q.into()),
                    ),
                );
            }
            if let Some(url) = commands.web.url(web_query.unwrap_or(q)) {
                results.push(item(
                    "web",
                    &format!(
                        "Search {} for “{}”",
                        commands.web.label(),
                        web_query.unwrap_or(q)
                    ),
                    &format!("{} · Ctrl+Enter · default browser", commands.web.label()),
                    "system-search-symbolic",
                    "Search",
                    Action::Open(url),
                ));
            }
        }
        if page == Page::Root
            && allowed
            && let Some(command) = boosters::Query::parse(q)
            && calendar::parse(q).is_none()
        {
            let sensitive = matches!(
                command,
                boosters::Query::System(systemtools::Query::Password(..))
                    | boosters::Query::Productivity(productivity::Query::Ai(_))
            );
            let web = results.into_iter().find(|i| i.id == "web" && !sensitive);
            results = self.booster_items(command);
            if let Some(web) = web {
                results.push(web);
            }
            self.section.set_text("Spotlight tools · Ctrl+R refreshes");
        }
        if page == Page::Root
            && allowed
            && let Some((id, args)) = extensions::query(q)
        {
            results = self.extension_items(q, id, args);
            self.section
                .set_text("Extension results · Escape cancels · Ctrl+R reruns");
        }
        if page == Page::Root && allowed {
            if let Some(parsed) = calendar::parse(q) {
                let entry = match parsed {
                    Ok(draft) => item(
                        "create-calendar-event",
                        if draft.title.is_empty() {
                            "Add Calendar Event"
                        } else {
                            &draft.title
                        },
                        &format!("{} · Enter to review and add", draft.label()),
                        "x-office-calendar-symbolic",
                        "Add event",
                        Action::CalendarEvent(draft.clone()),
                    ),
                    Err(error) => item(
                        "calendar-event-help",
                        "Add Calendar Event",
                        &format!("{error} · Try event Dinner on July 13 2027 at 6pm"),
                        "x-office-calendar-symbolic",
                        "Calendar",
                        Action::Noop,
                    ),
                };
                results = vec![entry];
                self.section.set_text("Calendar · create an event");
            } else if ["calendar", "events"].contains(&q.to_ascii_lowercase().as_str()) {
                results.insert(
                    0,
                    item(
                        "add-calendar-event",
                        "Add Calendar Event",
                        "Choose a date, time, and calendar",
                        "x-office-calendar-symbolic",
                        "Calendar",
                        Action::CalendarEvent(calendar::Draft::default()),
                    ),
                );
            }
        }
        if page == Page::Root {
            results.retain(|i| customization::item_category(i).is_none_or(|c| commands.enabled(c)));
            if !allowed {
                results.insert(
                    0,
                    item(
                        "disabled-category",
                        "This command category is disabled",
                        "Enable it in Settings → General → Search commands",
                        "preferences-system-symbolic",
                        "Settings",
                        Action::Settings,
                    ),
                );
            } else if web_query.is_some() {
                results.retain(|i| i.id == "web");
                if results.is_empty() {
                    results.push(item(
                        "web-disabled",
                        "Web search is disabled",
                        "Choose a fallback engine in Settings → General",
                        "preferences-system-symbolic",
                        "Settings",
                        Action::Settings,
                    ));
                }
            }
        }
        while let Some(child) = self.list.first_child() {
            self.list.remove(&child);
        }
        for i in &results {
            self.list.append(&self.row(i));
        }
        if results.is_empty() {
            self.section.set_text(match page {
                Page::Scripts => "No plugins or scripts yet · open their folders in Settings",
                Page::Files if *self.file_loading.borrow() => "Indexing your home folder…",
                Page::Recent if self.recents_loading.get() => "Loading recent files…",
                Page::Recent if q.is_empty() => "No recent files yet · opened files appear here",
                _ => "No results · try another search",
            });
        }
        *self.visible.borrow_mut() = results;
        *self.rendered_search.borrow_mut() = Some((page, q.to_string()));
        let selected_index = selected
            .and_then(|id| self.visible.borrow().iter().position(|item| item.id == id))
            .unwrap_or(0);
        if let Some(row) = self.list.row_at_index(selected_index as i32) {
            self.list.select_row(Some(&row));
        }
        self.hint.set_text(
            if matches!(page, Page::Snippets | Page::Links | Page::Notes) {
                "⌃N New    ⌃E Edit    ⌃D Delete"
            } else if page == Page::Root && !q.is_empty() {
                // The provider is also named in the web result.
                if commands.web == customization::Web::Google {
                    "↑ ↓ Navigate    ⌃Enter Google"
                } else {
                    "↑ ↓ Navigate    ⌃Enter Web search"
                }
            } else {
                "↑ ↓ Navigate"
            },
        );
    }
    fn open_uri(&self, uri: &str) -> Result<(), String> {
        opener::open(uri)?;
        if uri.starts_with("file:")
            && let Some(path) = gio::File::for_uri(uri).path()
            && !core::hidden_path(&path)
            && path.exists()
        {
            gtk::RecentManager::default().add_item(uri);
            let now = glib::DateTime::now_utc().map(|d| d.to_unix()).unwrap_or(0);
            let mut recents = self.recents.borrow_mut();
            recents.retain(|(p, _)| p != &path);
            recents.insert(0, (path, now));
            recents.truncate(300);
            self.booster_cache
                .borrow_mut()
                .retain(|q, _| !matches!(q, boosters::Query::Search(search::Query::Recent(_))));
        }
        Ok(())
    }
    fn text_preview(self: &Rc<Self>, title: &str, text: &str, open: Option<&str>) {
        if let Some(old) = self.preview_window.borrow_mut().take() {
            old.close();
        }
        let dialog = gtk::Window::builder()
            .title(title)
            .transient_for(&self.window)
            .modal(true)
            .destroy_with_parent(true)
            .default_width(700)
            .default_height(500)
            .build();
        let panel = gtk::Box::new(gtk::Orientation::Vertical, 12);
        panel.add_css_class("editor");
        let heading = gtk::Label::new(Some(title));
        heading.set_xalign(0.);
        heading.add_css_class("item-title");
        panel.append(&heading);
        let view = gtk::TextView::new();
        view.set_editable(false);
        view.set_cursor_visible(true);
        view.set_monospace(true);
        view.set_wrap_mode(gtk::WrapMode::WordChar);
        view.buffer().set_text(text);
        panel.append(
            &gtk::ScrolledWindow::builder()
                .child(&view)
                .vexpand(true)
                .min_content_height(300)
                .build(),
        );
        let status = gtk::Label::new(None);
        status.set_wrap(true);
        panel.append(&status);
        let buttons = gtk::Box::new(gtk::Orientation::Horizontal, 8);
        buttons.set_halign(gtk::Align::End);
        let copy = gtk::Button::with_label("Copy All");
        let body = text.to_owned();
        let clipboard = self.window.clipboard();
        let label = status.clone();
        copy.connect_clicked(move |_| {
            clipboard.set_text(&body);
            label.set_text("Copied");
        });
        buttons.append(&copy);
        if let Some(uri) = open {
            let button = gtk::Button::with_label("Open in App");
            let uri = uri.to_owned();
            let status = status.clone();
            let weak = Rc::downgrade(self);
            button.connect_clicked(move |_| {
                if let Some(ui) = weak.upgrade()
                    && let Err(error) = ui.open_uri(&uri)
                {
                    status.set_text(&error.to_string());
                }
            });
            buttons.append(&button);
        }
        let close = gtk::Button::with_label("Close");
        let d = dialog.downgrade();
        close.connect_clicked(move |_| {
            if let Some(d) = d.upgrade() {
                d.close();
            }
        });
        buttons.append(&close);
        panel.append(&buttons);
        dialog.set_child(Some(&panel));
        let keys = gtk::EventControllerKey::new();
        let d = dialog.downgrade();
        keys.connect_key_pressed(move |_, key, _, _| {
            if key == gdk::Key::Escape {
                if let Some(d) = d.upgrade() {
                    d.close();
                }
                glib::Propagation::Stop
            } else {
                glib::Propagation::Proceed
            }
        });
        dialog.add_controller(keys);
        *self.preview_window.borrow_mut() = Some(dialog.clone());
        dialog.present();
    }
    fn row(self: &Rc<Self>, i: &Item) -> gtk::ListBoxRow {
        let row = gtk::ListBoxRow::new();
        let line = gtk::Box::new(gtk::Orientation::Horizontal, 12);
        if let Some(texture) = &i.image {
            let image = gtk::Image::from_paintable(Some(texture));
            image.set_pixel_size(42);
            image.add_css_class("tile");
            line.append(&image);
        } else if let Some(path) = &i.thumbnail {
            let image = gtk::Image::from_icon_name("image-x-generic-symbolic");
            image.set_pixel_size(42);
            image.add_css_class("tile");
            image.set_tooltip_text(Some(&path.display().to_string()));
            self.thumbnail(path, &image);
            line.append(&image);
        } else if let Some(icon) = &i.gicon {
            let image = gtk::Image::from_gicon(icon);
            image.set_pixel_size(28);
            image.add_css_class("tile");
            line.append(&image);
        } else if i.icon.ends_with("symbolic") {
            let image = gtk::Image::from_icon_name(&i.icon);
            image.set_pixel_size(23);
            image.add_css_class("tile");
            line.append(&image);
        } else {
            let label = gtk::Label::new(Some(&i.icon));
            if i.id.starts_with("color-format:")
                && let Some(rgb) = self
                    .picked_color
                    .borrow()
                    .as_ref()
                    .and_then(|hex| color::rgb(hex).ok())
            {
                let attrs = gtk::pango::AttrList::new();
                attrs.insert(gtk::pango::AttrColor::new_foreground(
                    rgb[0] as u16 * 257,
                    rgb[1] as u16 * 257,
                    rgb[2] as u16 * 257,
                ));
                label.set_attributes(Some(&attrs));
            }
            label.add_css_class("tile");
            line.append(&label);
        }
        let texts = gtk::Box::new(gtk::Orientation::Vertical, 3);
        texts.set_hexpand(true);
        let title = gtk::Label::new(Some(&i.title));
        title.set_xalign(0.);
        title.set_ellipsize(gtk::pango::EllipsizeMode::End);
        if i.id.starts_with("booster:Define") {
            title.set_ellipsize(gtk::pango::EllipsizeMode::None);
            title.set_wrap(true);
            title.set_wrap_mode(gtk::pango::WrapMode::WordChar);
        }
        title.add_css_class("item-title");
        texts.append(&title);
        if !i.subtitle.is_empty() {
            let sub = gtk::Label::new(Some(&i.subtitle));
            sub.set_xalign(0.);
            sub.set_ellipsize(gtk::pango::EllipsizeMode::End);
            sub.add_css_class("subtitle");
            if let Action::FontPreview(family) = &i.action {
                let mut desc = gtk::pango::FontDescription::new();
                desc.set_family(family);
                let attrs = gtk::pango::AttrList::new();
                attrs.insert(gtk::pango::AttrFontDesc::new(&desc));
                sub.set_attributes(Some(&attrs));
            }
            texts.append(&sub);
        }
        line.append(&texts);
        let fav = self.store.borrow().favorites.contains(&i.id);
        let badge = gtk::Label::new(Some(if fav { "★ Favorite" } else { &i.badge }));
        badge.add_css_class("badge");
        line.append(&badge);
        row.set_child(Some(&line));
        row
    }
    fn launch(self: &Rc<Self>, i: Item) {
        if i.id.starts_with("emoji:")
            && let Action::Copy(symbol) = &i.action
            && let Some(tone) = emoji::tone(symbol)
        {
            let mut store = self.store.borrow_mut();
            store.emoji_skin_tone = Some(tone);
            store.emoji_tones.insert(emoji::base(symbol), tone);
        }
        if !i.id.starts_with("booster:")
            && !i.id.starts_with("vault-pin:")
            && !i.id.starts_with("extension-result:")
        {
            let mut store = self.store.borrow_mut();
            let n = store.usage.entry(i.id.clone()).or_default();
            *n = n.saturating_add(1);
            drop(store);
            self.save();
        }
        let result: Result<(), String> = match i.action {
            Action::Automation(command) => {
                self.execute_automation(command);
                return;
            }
            Action::Vault => {
                self.open_clipboard_vault();
                return;
            }
            Action::VaultPin(id) => {
                self.copy_vault_pin(&id);
                return;
            }
            Action::Workflow(op) => {
                self.workflow(op);
                return;
            }
            Action::ClearClipboard => {
                self.clear_clipboard();
                return;
            }
            Action::Walkthrough => {
                self.settings_at(2);
                return;
            }
            Action::Extension(manifest) => {
                self.open_extension(manifest);
                return;
            }
            Action::RunExtension {
                manifest,
                args,
                key,
            } => {
                self.start_extension(manifest, args, key, false);
                self.refresh();
                return;
            }
            Action::ClipboardImage(path) => {
                self.clipboard_image(path, false);
                return;
            }
            Action::ClipboardTexture(texture) => {
                self.window.clipboard().set_texture(&texture);
                self.error("Image copied · paste it into your target app");
                return;
            }
            Action::EmojiTones => {
                self.emoji_tones();
                return;
            }
            Action::Preview { title, text, open } => {
                self.text_preview(&title, &text, open.as_deref());
                return;
            }
            Action::DesktopSnippets => {
                self.toggle_desktop_snippets();
                return;
            }
            Action::Query(query) => {
                self.page(Page::Root);
                self.search.set_text(&query);
                self.search.set_position(-1);
                return;
            }
            Action::Booster(operation) => {
                self.execute_booster(operation);
                return;
            }
            Action::App(app) => app
                .launch(&[], None::<&gio::AppLaunchContext>)
                .map_err(|e| e.to_string()),
            Action::Open(uri) => self.open_uri(&uri),
            Action::QuickNote(initial) => {
                self.quick_note(&initial);
                return;
            }
            Action::CaptureNote(content) => {
                match self.capture_note(&content) {
                    Ok((_, message)) => {
                        self.search.set_text("");
                        self.refresh();
                        self.error(&message);
                    }
                    Err(error) => self.error(&error),
                }
                return;
            }

            Action::Schedule(draft) => {
                self.schedule(draft);
                return;
            }
            Action::CancelReminder(id) => {
                self.cancel_reminder(&id);
                return;
            }
            Action::DismissAlarms => {
                self.dismiss_alarms();
                return;
            }
            Action::FontPreview(family) => {
                self.font_preview(&family);
                return;
            }
            Action::ResetFont => {
                if let Err(error) = self.set_font(None) {
                    self.error(&error);
                }
                return;
            }
            Action::TimerSetup => {
                self.timer_setup();
                return;
            }
            Action::CalendarEvent(draft) => {
                self.calendar_event(draft);
                return;
            }
            Action::AlarmSetup => {
                self.alarm_setup();
                return;
            }
            Action::PickColor => {
                self.pick_color();
                return;
            }
            Action::MeasureScreen => {
                self.measure_screen();
                return;
            }
            Action::Caffeinate => {
                self.toggle_caffeinate();
                return;
            }
            Action::Desktop(command) => {
                self.desktop_command(command);
                return;
            }
            Action::Noop => return,
            Action::MoreResults => {
                let next = self.result_limit.get();
                self.result_limit.set(next + 60);
                self.refresh();
                if let Some(row) = self.list.row_at_index(next as i32) {
                    self.list.select_row(Some(&row));
                    row.grab_focus();
                    self.search.grab_focus();
                }
                return;
            }
            Action::Copy(text) => {
                self.window.clipboard().set_text(&text);
                self.error("Copied to clipboard");
                return;
            }
            Action::Snippet(template) => {
                let weak = Rc::downgrade(self);
                self.render_snippet(template, move |rendered| {
                    if let Some(ui) = weak.upgrade() {
                        ui.window.clipboard().set_text(&rendered.text);
                        ui.error(if rendered.cursor.is_some() {
                            "Snippet copied · trigger expansion places the cursor"
                        } else {
                            "Snippet copied"
                        });
                    }
                });
                return;
            }
            Action::Page(p) => {
                self.page(p);
                return;
            }
            Action::New(p) => {
                self.editor(p, None);
                return;
            }
            Action::Edit(p, n) => {
                self.editor(p, Some(n));
                return;
            }
            Action::System(args) => Command::new(&args[0])
                .args(&args[1..])
                .spawn()
                .map(|mut child| {
                    std::thread::spawn(move || {
                        let _ = child.wait();
                    });
                })
                .map_err(|e| e.to_string()),
            Action::Window(shortcut) => {
                self.window_action(shortcut);
                return;
            }
            Action::Script(path) => {
                self.run_script(path);
                return;
            }
            Action::Settings => {
                self.settings();
                return;
            }
            Action::Quit => {
                if let Some(app) = self.window.application() {
                    app.quit();
                }
                return;
            }
        };
        match result {
            Ok(()) => self.window.set_visible(false),
            Err(e) => self.error(&format!("Could not open: {e}")),
        }
    }
    fn window_action(self: &Rc<Self>, shortcut: &'static str) {
        // Let KWin return focus to the previous app before invoking its action.
        self.window.set_visible(false);
        let ui = Rc::clone(self);
        glib::timeout_add_local_once(Duration::from_millis(250), move || {
            let result = (|| -> Result<(), String> {
                if ui.window.is_visible() || ui.window.is_active() {
                    return Err("Spotlight is still focused. Try the window action again.".into());
                }
                let bus = gio::bus_get_sync(gio::BusType::Session, None::<&gio::Cancellable>)
                    .map_err(|e| e.to_string())?;
                bus.call_sync(
                    Some("org.kde.kglobalaccel"),
                    "/component/kwin",
                    "org.kde.kglobalaccel.Component",
                    "invokeShortcut",
                    Some(&(shortcut,).to_variant()),
                    None,
                    gio::DBusCallFlags::NONE,
                    1000,
                    None::<&gio::Cancellable>,
                )
                .map_err(|e| e.to_string())?;
                Ok(())
            })();
            if let Err(e) = result {
                ui.window.present();
                ui.error(&format!("Window actions require KDE KWin: {e}"));
            }
        });
    }
    fn activate(self: &Rc<Self>) {
        if let Some(i) = self.selected() {
            self.launch(i);
        }
    }
    fn favorite(self: &Rc<Self>) {
        if let Some(i) = self.selected() {
            if i.id.starts_with("booster:context-ai:") {
                self.error("Local AI questions are excluded from saved favorites");
                return;
            }
            if i.id.starts_with("vault-pin:") {
                self.error("Secure pins are excluded from saved favorites");
                return;
            }
            if i.id.starts_with("booster:password:")
                || matches!(
                    i.action,
                    Action::Booster(boosters::Operation::System(
                        systemtools::Operation::Password(..)
                    ))
                )
            {
                self.error("Password lookups are kept out of saved favorites and history");
                return;
            }
            let mut store = self.store.borrow_mut();
            if store.favorites.contains(&i.id) {
                store.favorites.retain(|x| x != &i.id);
            } else {
                store.favorites.push(i.id);
            }
            drop(store);
            self.save();
            self.refresh();
        }
    }
    fn edit_selected(self: &Rc<Self>) {
        let p = *self.page.borrow();
        if matches!(p, Page::Snippets | Page::Links | Page::Notes)
            && let Some(i) = self.selected()
            && let Some(n) = i.id.strip_prefix("text:").and_then(|s| s.parse().ok())
        {
            self.editor(p, Some(n));
        }
    }
    fn delete_selected(self: &Rc<Self>) {
        let p = *self.page.borrow();
        if !matches!(p, Page::Snippets | Page::Links | Page::Notes) {
            return;
        }
        if let Some(n) = self.selected().and_then(|i| {
            i.id.strip_prefix("text:")
                .and_then(|s| s.parse::<usize>().ok())
        }) {
            let mut s = self.store.borrow_mut();
            let v = match p {
                Page::Snippets => &mut s.snippets,
                Page::Links => &mut s.links,
                _ => &mut s.notes,
            };
            if n < v.len() {
                v.remove(n);
            }
            drop(s);
            self.save();
            self.refresh();
        }
    }
    fn editor(self: &Rc<Self>, page: Page, index: Option<usize>) {
        let old = {
            let s = self.store.borrow();
            let v = match page {
                Page::Snippets => &s.snippets,
                Page::Links => &s.links,
                _ => &s.notes,
            };
            index.and_then(|n| v.get(n).cloned())
        };
        let dialog = gtk::Window::builder()
            .transient_for(&self.window)
            .modal(true)
            .title(if old.is_some() {
                "Edit item"
            } else {
                "Create item"
            })
            .default_width(500)
            .default_height(350)
            .build();
        let container = gtk::Box::new(gtk::Orientation::Vertical, 12);
        container.add_css_class("editor");
        let title = gtk::Label::new(Some(match page {
            Page::Links => "Quicklink",
            Page::Snippets => "Snippet",
            _ => "Note",
        }));
        title.set_xalign(0.);
        title.add_css_class("item-title");
        container.append(&title);
        let name = gtk::Entry::builder().placeholder_text("Name").build();
        if let Some(s) = &old {
            name.set_text(&s.name);
        }
        container.append(&name);
        let trigger = gtk::Entry::builder()
            .placeholder_text("Trigger word (optional), for example ;sig")
            .build();
        if page == Page::Snippets {
            if let Some(s) = &old {
                trigger.set_text(&s.trigger);
            }
            container.append(&trigger);
            let help = gtk::Label::new(Some(
                "Use {cursor} for the caret position and {clipboard} for current clipboard text. Type the trigger then Space or Tab in Spotlight. Enable Desktop Snippet Expansion to use triggers across apps (Espanso required).",
            ));
            help.set_wrap(true);
            help.set_xalign(0.);
            container.append(&help);
        }
        let value = gtk::TextView::new();
        if page == Page::Notes {
            self.snippet_text_keys(&value);
        }
        value.set_wrap_mode(gtk::WrapMode::WordChar);
        if let Some(s) = &old {
            value.buffer().set_text(&s.value);
        }
        let scrolled = gtk::ScrolledWindow::builder()
            .child(&value)
            .vexpand(true)
            .min_content_height(160)
            .build();
        container.append(&scrolled);
        if page == Page::Links {
            container.append(&gtk::Label::new(Some(
                "Use a full URL, for example https://github.com",
            )));
        }
        let status = gtk::Label::new(None);
        status.add_css_class("notice");
        container.append(&status);
        let buttons = gtk::Box::new(gtk::Orientation::Horizontal, 8);
        buttons.set_halign(gtk::Align::End);
        let cancel = gtk::Button::with_label("Cancel");
        let save = gtk::Button::with_label("Save");
        save.add_css_class("accent");
        buttons.append(&cancel);
        buttons.append(&save);
        container.append(&buttons);
        dialog.set_child(Some(&container));
        let d = dialog.clone();
        cancel.connect_clicked(move |_| d.close());
        let ui = Rc::clone(self);
        let d = dialog.clone();
        save.connect_clicked(move |_| {
            let n = name.text().trim().to_string();
            let b = value.buffer();
            let v = b.text(&b.start_iter(), &b.end_iter(), false).to_string();
            if n.is_empty() || v.trim().is_empty() {
                status.set_text("Add a name and content.");
                return;
            }
            if page == Page::Links && !v.starts_with("https://") && !v.starts_with("http://") {
                status.set_text("Quicklinks must start with https:// or http://");
                return;
            }
            let mut s = ui.store.borrow_mut();
            let trigger = if page == Page::Snippets {
                trigger.text().trim().to_string()
            } else {
                String::new()
            };
            if page == Page::Snippets
                && let Err(error) = snippets::validate(&trigger, &s.snippets, index)
            {
                status.set_text(&error);
                return;
            }
            if !ui.can_save {
                status.set_text("Saved data is unreadable; editing is disabled");
                return;
            }
            let list = match page {
                Page::Snippets => &mut s.snippets,
                Page::Links => &mut s.links,
                _ => &mut s.notes,
            };
            let entry = TextItem {
                name: n,
                value: v,
                trigger,
            };
            if let Some(index) = index {
                if let Some(i) = list.get_mut(index) {
                    *i = entry;
                }
            } else {
                list.push(entry);
            }
            drop(s);
            ui.save();
            ui.refresh();
            d.close();
        });
        dialog.present();
    }
    fn set_theme(&self, theme: theme::Theme) -> Result<(), String> {
        if !self.can_save {
            return Err("Saved data is unreadable; cannot change the theme".into());
        }
        let css = theme.css()?;
        let mut store = self.store.borrow_mut();
        let previous = std::mem::replace(&mut store.theme, theme);
        if let Err(error) = store.save() {
            store.theme = previous;
            return Err(error);
        }
        self.theme_css.load_from_data(&css);
        Ok(())
    }
    fn set_interface(&self, preferences: interface::Preferences) -> Result<(), String> {
        if !self.can_save {
            return Err("Saved data is unreadable; cannot change the interface".into());
        }
        let preferences = preferences.normalized();
        let mut store = self.store.borrow_mut();
        let previous = std::mem::replace(&mut store.interface, preferences);
        if let Err(error) = store.save() {
            store.interface = previous;
            return Err(error);
        }
        drop(store);
        self.interface_css.load_from_data(&preferences.css());
        let (width, height) = preferences.dimensions();
        interface::fit_window(&self.window, width, height);
        for window in gtk::Window::list_toplevels()
            .into_iter()
            .filter_map(|w| w.downcast::<gtk::Window>().ok())
        {
            if window.title().as_deref() == Some("Spotlight Settings") {
                let scale = i32::from(preferences.scale);
                interface::fit_window(&window, 640 * scale / 100, 740 * scale / 100);
            }
        }
        Ok(())
    }
    fn settings(self: &Rc<Self>) {
        self.settings_at(0);
    }
    fn settings_at(self: &Rc<Self>, tab: u32) {
        let dialog = gtk::Window::builder()
            .title("Spotlight Settings")
            .transient_for(&self.window)
            .modal(true)
            .default_width(640)
            .default_height(740)
            .build();
        let panel = gtk::Box::new(gtk::Orientation::Vertical, 16);
        panel.add_css_class("editor");
        for text in [
            "Spotlight · native Rust launcher",
            "Open launcher: Meta + Space (KDE)",
            "Enter opens · Esc goes back or hides · Tab or Ctrl+K shows actions",
            "Ctrl+F toggles favorite · Ctrl+N creates an item",
            "Clipboard history comes from KDE Klipper; explicitly pinned entries save in Spotlight.",
            "File search scans your home on demand, up to 25,000 entries.",
            "Hidden folders, build output, and symbolic links are skipped.",
        ] {
            let l = gtk::Label::new(Some(text));
            l.set_wrap(true);
            l.set_xalign(0.);
            panel.append(&l);
        }
        panel.append(&self.customization_panel());
        panel.append(&self.dotfiles_panel());
        let font_label = gtk::Label::new(Some(&format!(
            "Spotlight font: {}",
            self.store
                .borrow()
                .selected_font
                .as_deref()
                .unwrap_or("Default")
        )));
        font_label.set_xalign(0.);
        font_label.set_wrap(true);
        panel.append(&font_label);
        let font_buttons = gtk::Box::new(gtk::Orientation::Horizontal, 8);
        let search_fonts = gtk::Button::with_label("Search Fonts");
        let reset_font = gtk::Button::with_label("Reset Font");
        font_buttons.append(&search_fonts);
        font_buttons.append(&reset_font);
        panel.append(&font_buttons);
        let expansion = gtk::Button::with_label(if self.store.borrow().desktop_snippets {
            "Disable Desktop Snippet Expansion"
        } else {
            "Enable Desktop Snippet Expansion"
        });
        let setup = gtk::LinkButton::with_label(
            "https://espanso.org/docs/install/linux/",
            "Text Expansion Setup",
        );
        panel.append(&expansion);
        panel.append(&setup);
        let weak = Rc::downgrade(self);
        expansion.connect_clicked(move |button| {
            if let Some(ui) = weak.upgrade() {
                ui.toggle_desktop_snippets();
                button.set_label(if ui.store.borrow().desktop_snippets {
                    "Disable Desktop Snippet Expansion"
                } else {
                    "Enable Desktop Snippet Expansion"
                });
            }
        });
        let weak = Rc::downgrade(self);
        let parent = dialog.downgrade();
        search_fonts.connect_clicked(move |_| {
            if let Some(ui) = weak.upgrade() {
                if let Some(dialog) = parent.upgrade() {
                    dialog.close();
                }
                ui.page(Page::Fonts);
            }
        });
        let weak = Rc::downgrade(self);
        reset_font.connect_clicked(move |_| {
            if let Some(ui) = weak.upgrade() {
                match ui.set_font(None) {
                    Ok(()) => font_label.set_text("Spotlight font: Default"),
                    Err(error) => font_label.set_text(&error),
                }
            }
        });
        let vaults = quicknote::discover();
        let destination =
            gtk::Label::new(Some(&format!("Quick notes: {}", self.note_destination())));
        destination.set_xalign(0.);
        destination.set_wrap(true);
        panel.append(&destination);
        if !vaults.is_empty() {
            let found = gtk::Label::new(Some(&format!(
                "Detected vaults: {}",
                vaults
                    .iter()
                    .map(|vault| vault.name.as_str())
                    .collect::<Vec<_>>()
                    .join(", ")
            )));
            found.set_xalign(0.);
            found.set_wrap(true);
            found.add_css_class("subtitle");
            panel.append(&found);
        }
        let vault_path = gtk::Entry::builder()
            .placeholder_text("Obsidian vault folder")
            .build();
        if let Some(path) = self
            .store
            .borrow()
            .obsidian_vault
            .as_ref()
            .or_else(|| vaults.first().map(|vault| &vault.path))
        {
            vault_path.set_text(&path.to_string_lossy());
        }
        panel.append(&vault_path);
        let vault_status = gtk::Label::new(None);
        vault_status.set_wrap(true);
        vault_status.set_xalign(0.);
        panel.append(&vault_status);
        let vault_buttons = gtk::Box::new(gtk::Orientation::Horizontal, 8);
        let choose_vault = gtk::Button::with_label("Choose folder");
        let connect_vault = gtk::Button::with_label("Connect Obsidian");
        let disconnect_vault = gtk::Button::with_label("Use local notes");
        vault_buttons.append(&choose_vault);
        vault_buttons.append(&connect_vault);
        vault_buttons.append(&disconnect_vault);
        panel.append(&vault_buttons);
        let entry = vault_path.clone();
        let parent = dialog.downgrade();
        choose_vault.connect_clicked(move |_| {
            let chooser = gtk::FileDialog::builder()
                .title("Choose an Obsidian vault folder")
                .build();
            let entry = entry.clone();
            chooser.select_folder(
                parent.upgrade().as_ref(),
                None::<&gio::Cancellable>,
                move |result| {
                    if let Ok(folder) = result
                        && let Some(path) = folder.path()
                    {
                        entry.set_text(&path.to_string_lossy());
                    }
                },
            );
        });
        let weak = Rc::downgrade(self);
        let status = vault_status.clone();
        let label = destination.clone();
        connect_vault.connect_clicked(move |_| {
            let Some(ui) = weak.upgrade() else {
                return;
            };
            if !ui.can_save {
                status.set_text("Saved data is unreadable; cannot change the connection");
                return;
            }
            let path =
                match quicknote::validate_vault(std::path::Path::new(vault_path.text().trim())) {
                    Ok(path) => path,
                    Err(error) => {
                        status.set_text(&error);
                        return;
                    }
                };
            let mut store = ui.store.borrow_mut();
            let old = (store.obsidian_vault.clone(), store.obsidian_disabled);
            store.obsidian_vault = Some(path);
            store.obsidian_disabled = false;
            if let Err(error) = store.save() {
                store.obsidian_vault = old.0;
                store.obsidian_disabled = old.1;
                status.set_text(&error);
                return;
            }
            drop(store);
            label.set_text(&format!("Quick notes: {}", ui.note_destination()));
            status.set_text(
                "Connected · quick notes will save in Spotlight Quick Notes inside your vault",
            );
            ui.refresh();
        });
        let weak = Rc::downgrade(self);
        let status = vault_status;
        let label = destination;
        disconnect_vault.connect_clicked(move |_| {
            let Some(ui) = weak.upgrade() else {
                return;
            };
            if !ui.can_save {
                status.set_text("Saved data is unreadable; cannot change the connection");
                return;
            }
            let mut store = ui.store.borrow_mut();
            let old = (store.obsidian_vault.take(), store.obsidian_disabled);
            store.obsidian_disabled = true;
            if let Err(error) = store.save() {
                store.obsidian_vault = old.0;
                store.obsidian_disabled = old.1;
                status.set_text(&error);
                return;
            }
            drop(store);
            label.set_text(&format!("Quick notes: {}", ui.note_destination()));
            status.set_text("Future notes will save locally; existing vault notes are kept");
            ui.refresh();
        });
        for (label, directory) in [
            ("Open WASM plugins folder", "plugins"),
            ("Open scripts folder", "scripts"),
        ] {
            let folder = gtk::Button::with_label(label);
            let ui = Rc::clone(self);
            folder.connect_clicked(move |_| {
                let p = core::data_dir().join(directory);
                if let Err(e) = std::fs::create_dir_all(&p) {
                    ui.error(&e.to_string());
                    return;
                }
                if let Err(error) = ui.open_uri(&gio::File::for_path(p).uri()) {
                    ui.error(&format!("Could not open folder: {error}"));
                }
            });
            panel.append(&folder);
        }
        let refresh = gtk::Button::with_label("Refresh apps and file index");
        let ui = Rc::clone(self);
        refresh.connect_clicked(move |_| {
            *ui.apps.borrow_mut() = applications();
            ui.files.borrow_mut().clear();
            *ui.files_ready.borrow_mut() = false;
            ui.refresh();
            ui.error("Application list refreshed. Reopen file search to rebuild the index.");
        });
        panel.append(&refresh);
        let scroll = gtk::ScrolledWindow::builder()
            .child(&panel)
            .hscrollbar_policy(gtk::PolicyType::Never)
            .build();
        let tabs = gtk::Stack::builder()
            .transition_type(gtk::StackTransitionType::Crossfade)
            .transition_duration(160)
            .vexpand(true)
            .build();
        tabs.set_widget_name("settings-pages");
        tabs.add_titled(&scroll, Some("general"), "General");
        let weak = Rc::downgrade(self);
        let window_panel = interface::panel(self.store.borrow().interface, move |preferences| {
            weak.upgrade()
                .ok_or("Spotlight has closed")?
                .set_interface(preferences)
        });
        let window_scroll = gtk::ScrolledWindow::builder()
            .child(&window_panel)
            .hscrollbar_policy(gtk::PolicyType::Never)
            .build();
        tabs.add_titled(&window_scroll, Some("window"), "Window");
        let weak = Rc::downgrade(self);
        let theme_panel = theme::panel(self.store.borrow().theme.clone(), move |theme| {
            weak.upgrade()
                .ok_or("Spotlight has closed")?
                .set_theme(theme)
        });
        let theme_scroll = gtk::ScrolledWindow::builder()
            .child(&theme_panel)
            .hscrollbar_policy(gtk::PolicyType::Never)
            .build();
        tabs.add_titled(&theme_scroll, Some("theme"), "Theme");
        let app = {
            let apps = self.apps.borrow();
            apps.iter()
                .find(|app| app.title.to_lowercase().contains("firefox"))
                .or_else(|| apps.first())
                .map(|app| app.title.clone())
                .unwrap_or_else(|| "Firefox".into())
        };
        let weak = Rc::downgrade(self);
        let on_change = move |step| {
            if let Some(ui) = weak.upgrade() {
                ui.guide_step.set(step);
            }
        };
        let weak = Rc::downgrade(self);
        let parent = dialog.downgrade();
        let pages = tabs.downgrade();
        let guide = guide::panel(app, self.guide_step.get(), on_change, move |action| {
            let Some(ui) = weak.upgrade() else { return };
            if let guide::Action::Settings(name) = action {
                if let Some(tabs) = pages.upgrade() {
                    tabs.set_visible_child_name(name);
                }
                return;
            }
            if let Some(dialog) = parent.upgrade() {
                dialog.close();
            }
            match action {
                guide::Action::Search(query) => {
                    ui.page(Page::Root);
                    ui.search.set_text(&query);
                    ui.search.set_position(-1);
                }
                guide::Action::Page(page) => ui.page(page),
                guide::Action::Finish => {
                    ui.guide_step.set(0);
                    ui.page(Page::Root);
                }
                guide::Action::Settings(_) => unreachable!(),
            }
            ui.window.present();
            ui.search.grab_focus();
        });
        let guide_scroll = gtk::ScrolledWindow::builder()
            .child(&guide)
            .hscrollbar_policy(gtk::PolicyType::Never)
            .build();
        tabs.add_titled(&guide_scroll, Some("guide"), "Guide");
        let about_scroll = gtk::ScrolledWindow::builder()
            .child(&about::panel())
            .hscrollbar_policy(gtk::PolicyType::Never)
            .build();
        tabs.add_titled(&about_scroll, Some("about"), "About");
        tabs.set_visible_child_name(
            ["general", "theme", "guide", "about", "window"]
                .get(tab as usize)
                .copied()
                .unwrap_or("general"),
        );
        let layout = gtk::Box::new(gtk::Orientation::Vertical, 0);
        layout.add_css_class("settings-shell");
        let heading = gtk::Box::new(gtk::Orientation::Vertical, 5);
        heading.add_css_class("settings-heading");
        let title = gtk::Label::new(Some("Settings"));
        title.set_xalign(0.);
        title.add_css_class("guide-title");
        heading.append(&title);
        let subtitle = gtk::Label::new(Some("Make Spotlight feel like home."));
        subtitle.set_xalign(0.);
        subtitle.add_css_class("subtitle");
        heading.append(&subtitle);
        layout.append(&heading);
        let navigation = gtk::StackSwitcher::builder().stack(&tabs).build();
        navigation.add_css_class("settings-tabs");
        navigation.set_widget_name("settings-navigation");
        layout.append(&navigation);
        layout.append(&tabs);
        let done = gtk::Button::with_label("Done");
        done.set_halign(gtk::Align::End);
        let parent = dialog.downgrade();
        done.connect_clicked(move |_| {
            if let Some(dialog) = parent.upgrade() {
                dialog.close();
            }
        });
        let footer = gtk::Box::new(gtk::Orientation::Horizontal, 0);
        footer.add_css_class("settings-footer");
        done.set_hexpand(true);
        footer.append(&done);
        layout.append(&footer);
        let overlay = gtk::Overlay::new();
        overlay.set_child(Some(&layout));
        about::opening_animation(&overlay);
        dialog.set_child(Some(&overlay));
        let keys = gtk::EventControllerKey::new();
        let parent = dialog.downgrade();
        keys.connect_key_pressed(move |_, key, _, _| {
            if key == gdk::Key::Escape {
                if let Some(dialog) = parent.upgrade() {
                    dialog.close();
                }
                glib::Propagation::Stop
            } else {
                glib::Propagation::Proceed
            }
        });
        dialog.add_controller(keys);
        let scale = i32::from(self.store.borrow().interface.normalized().scale);
        interface::fit_window(&dialog, 640 * scale / 100, 740 * scale / 100);
        dialog.present();
    }
    fn actions(self: &Rc<Self>, button: &gtk::Button) {
        let popup = gtk::Popover::new();
        popup.set_widget_name("actions-popover");
        popup.set_parent(button);
        let menu = gtk::Box::new(gtk::Orientation::Vertical, 6);
        let selected = self.selected();
        self.clipboard_actions(&menu, &popup, selected.as_ref());
        if let Some(selected) = self.selected() {
            self.file_actions(&menu, &popup, &selected);
            match selected.action {
                Action::ClipboardImage(path) => {
                    let preview = gtk::Button::with_label("Preview Image");
                    let weak = Rc::downgrade(self);
                    let pop = popup.clone();
                    preview.connect_clicked(move |_| {
                        pop.popdown();
                        if let Some(ui) = weak.upgrade() {
                            ui.clipboard_image(path.clone(), true);
                        }
                    });
                    menu.append(&preview);
                }
                Action::ClipboardTexture(texture) => {
                    let preview = gtk::Button::with_label("Preview Image");
                    let weak = Rc::downgrade(self);
                    let pop = popup.clone();
                    preview.connect_clicked(move |_| {
                        pop.popdown();
                        if let Some(ui) = weak.upgrade() {
                            ui.image_preview(&texture);
                        }
                    });
                    menu.append(&preview);
                }
                _ => {}
            }
        }
        for (name, action) in [
            ("Open / run                     ↵", 0),
            ("Toggle favorite              Ctrl+F", 1),
            ("Copy selected text", 2),
            ("Edit item                          Ctrl+E", 3),
            ("Delete item                      Ctrl+D", 4),
            ("Settings", 5),
        ] {
            let b = gtk::Button::with_label(name);
            let ui = Rc::clone(self);
            let pop = popup.clone();
            b.connect_clicked(move |_| {
                pop.popdown();
                match action {
                    0 => ui.activate(),
                    1 => ui.favorite(),
                    2 => {
                        if let Some(i) = ui.selected() {
                            let text = match i.action {
                                Action::Copy(s) | Action::Open(s) => s,
                                _ => i.title,
                            };
                            ui.window.clipboard().set_text(&text);
                            ui.error("Copied to clipboard");
                        }
                    }
                    3 => ui.edit_selected(),
                    4 => ui.delete_selected(),
                    _ => ui.settings(),
                }
            });
            menu.append(&b);
        }
        popup.set_child(Some(&menu));
        popup.connect_closed(|p| p.unparent());
        popup.popup();
    }
    fn run_script(self: &Rc<Self>, path: PathBuf) {
        self.error("Running script…");
        let (tx, rx) = mpsc::channel();
        std::thread::spawn(move || {
            use std::io::Read;
            let result = (|| -> Result<String, String> {
                let mut child = Command::new(path)
                    .stdout(std::process::Stdio::piped())
                    .stderr(std::process::Stdio::inherit())
                    .spawn()
                    .map_err(|e| e.to_string())?;
                let mut bytes = Vec::new();
                let mut pipe = child.stdout.take().ok_or("Missing stdout")?.take(65536);
                pipe.read_to_end(&mut bytes).map_err(|e| e.to_string())?;
                drop(pipe);
                let truncated = bytes.len() == 65536;
                if truncated {
                    let _ = child.kill();
                }
                let status = child.wait().map_err(|e| e.to_string())?;
                Ok(format!(
                    "{}\n\n{}",
                    String::from_utf8_lossy(&bytes),
                    if truncated {
                        "Output capped at 64 KiB; script stopped.".to_string()
                    } else {
                        format!("Exit status: {status}")
                    }
                ))
            })();
            let _ = tx.send(result);
        });
        let weak = Rc::downgrade(self);
        glib::timeout_add_local(Duration::from_millis(100), move || {
            let Some(ui) = weak.upgrade() else {
                return glib::ControlFlow::Break;
            };
            match rx.try_recv() {
                Ok(r) => {
                    ui.error("");
                    match r {
                        Ok(s) => {
                            let d = gtk::Window::builder()
                                .title("Script output")
                                .transient_for(&ui.window)
                                .default_width(650)
                                .default_height(400)
                                .build();
                            let text = gtk::TextView::new();
                            text.set_editable(false);
                            text.set_monospace(true);
                            text.set_wrap_mode(gtk::WrapMode::WordChar);
                            text.buffer().set_text(&s);
                            d.set_child(Some(&gtk::ScrolledWindow::builder().child(&text).build()));
                            d.present();
                        }
                        Err(e) => ui.error(&e),
                    }
                    glib::ControlFlow::Break
                }
                Err(mpsc::TryRecvError::Empty) => glib::ControlFlow::Continue,
                Err(_) => glib::ControlFlow::Break,
            }
        });
    }
}
fn applications() -> Vec<Item> {
    gio::AppInfo::all()
        .into_iter()
        .filter(|a| a.should_show())
        .map(|a| {
            let name = a.display_name().to_string();
            let id = a.id().map(|s| s.to_string()).unwrap_or(name.clone());
            let mut i = item(
                &id,
                &name,
                "",
                "application-x-executable-symbolic",
                "Application",
                Action::App(a.clone()),
            );
            i.gicon = a.icon();
            i
        })
        .collect()
}
fn window_shortcuts_item() -> Item {
    let mut entry = item(
        "window-shortcuts",
        "Customize Window Shortcuts",
        "Open KDE's shortcut editor for KWin · assign keys, then Apply",
        "preferences-desktop-keyboard-shortcuts-symbolic",
        "Settings",
        Action::System(vec![
            "kcmshell6".into(),
            "--args".into(),
            "kwin".into(),
            "kcm_keys".into(),
        ]),
    );
    entry.keywords = "window manager customize customise costumize custom keyboard shortcuts hotkeys keybindings kwin".into();
    entry
}
fn window_items() -> Vec<Item> {
    let mut entries = vec![window_shortcuts_item()];
    entries.extend(
        [
            (
                "Left Half",
                "Window Quick Tile Left",
                "Tile to the left half",
            ),
            (
                "Right Half",
                "Window Quick Tile Right",
                "Tile to the right half",
            ),
            ("Top Half", "Window Quick Tile Top", "Tile to the top half"),
            (
                "Bottom Half",
                "Window Quick Tile Bottom",
                "Tile to the bottom half",
            ),
            (
                "Top Left Quarter",
                "Window Quick Tile Top Left",
                "Tile to the top left corner",
            ),
            (
                "Top Right Quarter",
                "Window Quick Tile Top Right",
                "Tile to the top right corner",
            ),
            (
                "Bottom Left Quarter",
                "Window Quick Tile Bottom Left",
                "Tile to the bottom left corner",
            ),
            (
                "Bottom Right Quarter",
                "Window Quick Tile Bottom Right",
                "Tile to the bottom right corner",
            ),
            ("Maximize", "Window Maximize", "Toggle maximized size"),
            (
                "Restore",
                "Window Restore",
                "Restore the window's previous size",
            ),
            (
                "Minimize",
                "Window Minimize",
                "Hide the window in the taskbar",
            ),
            (
                "Next Screen",
                "Window to Next Screen",
                "Move to the next monitor",
            ),
        ]
        .into_iter()
        .map(|(title, shortcut, description)| {
            item(
                &format!("window:{shortcut}"),
                title,
                description,
                "view-grid-symbolic",
                "Window",
                Action::Window(shortcut),
            )
        }),
    );
    entries
}

fn emoji_items() -> Vec<Item> {
    emoji::catalog()
        .iter()
        .map(|e| {
            let mut entry = item(
                &format!("emoji:{}", e.symbol),
                e.name,
                &format!("{} · Enter to copy", e.category),
                e.symbol,
                "Emoji",
                Action::Copy(e.symbol.to_string()),
            );
            entry.keywords = e.keywords.clone();
            entry
        })
        .collect()
}

fn build(app: &gtk::Application) -> Rc<Ui> {
    build_with_mode(app, std::env::args().any(|arg| arg == "--smoke-test"))
}
fn build_with_mode(app: &gtk::Application, test: bool) -> Rc<Ui> {
    let css = gtk::CssProvider::new();
    css.load_from_data(include_str!("../assets/style.css"));
    gtk::style_context_add_provider_for_display(
        &gdk::Display::default().expect("Display"),
        &css,
        gtk::STYLE_PROVIDER_PRIORITY_APPLICATION,
    );
    let window = gtk::ApplicationWindow::builder()
        .application(app)
        .title("Spotlight")
        .default_width(760)
        .default_height(530)
        .decorated(false)
        .resizable(false)
        .build();
    let font_css = gtk::CssProvider::new();
    let theme_css = gtk::CssProvider::new();
    let interface_css = gtk::CssProvider::new();
    gtk::style_context_add_provider_for_display(
        &gdk::Display::default().expect("Display"),
        &interface_css,
        gtk::STYLE_PROVIDER_PRIORITY_APPLICATION + 2,
    );
    gtk::style_context_add_provider_for_display(
        &gdk::Display::default().expect("Display"),
        &theme_css,
        gtk::STYLE_PROVIDER_PRIORITY_APPLICATION + 1,
    );
    gtk::style_context_add_provider_for_display(
        &gdk::Display::default().expect("Display"),
        &font_css,
        gtk::STYLE_PROVIDER_PRIORITY_APPLICATION + 1,
    );
    let mut installed_fonts: Vec<String> = window
        .pango_context()
        .list_families()
        .into_iter()
        .map(|family| family.name().to_string())
        .collect();
    installed_fonts.sort_by_key(|name| name.to_lowercase());
    installed_fonts.dedup();
    let shell = gtk::Box::new(gtk::Orientation::Vertical, 0);
    shell.add_css_class("shell");
    let top = gtk::Box::new(gtk::Orientation::Horizontal, 12);
    top.add_css_class("launcher-top");
    let back = gtk::Button::from_icon_name("go-previous-symbolic");
    back.add_css_class("flat");
    back.set_visible(false);
    top.append(&back);
    let brand = gtk::Label::new(Some("╱"));
    brand.add_css_class("brand");
    top.append(&brand);
    let search = gtk::Entry::builder()
        .placeholder_text(Page::Root.placeholder())
        .hexpand(true)
        .build();
    search.add_css_class("search");
    top.append(&search);
    let add = gtk::Button::from_icon_name("list-add-symbolic");
    add.set_tooltip_text(Some("Create item · Ctrl+N"));
    add.set_visible(false);
    top.append(&add);
    let windows = gtk::Button::from_icon_name("view-grid-symbolic");
    windows.add_css_class("flat");
    windows.set_tooltip_text(Some("Window Manager"));
    top.append(&windows);
    let window_shortcuts = gtk::Button::with_label("Customize Shortcuts");
    window_shortcuts.set_tooltip_text(Some("Customize KWin's window shortcuts in KDE Settings"));
    window_shortcuts.set_visible(false);
    top.append(&window_shortcuts);
    let settings = gtk::Button::from_icon_name("emblem-system-symbolic");
    settings.add_css_class("flat");
    settings.set_tooltip_text(Some("Settings"));
    top.append(&settings);
    shell.append(&top);
    let file_shortcuts = gtk::Box::new(gtk::Orientation::Horizontal, 10);
    file_shortcuts.add_css_class("file-shortcuts");
    file_shortcuts.set_widget_name("file-shortcuts");
    let search_file = gtk::Button::new();
    let recent_files = gtk::Button::new();
    for (button, name, label, icon) in [
        (
            &search_file,
            "search-file",
            "Search File",
            "folder-symbolic",
        ),
        (
            &recent_files,
            "recent-files",
            "Recent",
            "document-open-recent-symbolic",
        ),
    ] {
        button.set_widget_name(name);
        let contents = gtk::Box::new(gtk::Orientation::Horizontal, 8);
        contents.append(&gtk::Image::from_icon_name(icon));
        contents.append(&gtk::Label::new(Some(label)));
        button.set_child(Some(&contents));
        button.update_property(&[gtk::accessible::Property::Label(label)]);
        file_shortcuts.append(button);
    }
    search_file.set_tooltip_text(Some("Search files and folders · keeps your current search"));
    recent_files.set_tooltip_text(Some("Browse recently opened files and folders"));
    shell.append(&file_shortcuts);
    let section = gtk::Label::new(Some("Suggestions"));
    section.set_xalign(0.);
    section.add_css_class("section");
    shell.append(&section);
    let list = gtk::ListBox::new();
    list.set_selection_mode(gtk::SelectionMode::Single);
    list.set_activate_on_single_click(false);
    let scroll = gtk::ScrolledWindow::builder()
        .child(&list)
        .hscrollbar_policy(gtk::PolicyType::Never)
        .vexpand(true)
        .min_content_height(240)
        .build();
    shell.append(&scroll);
    let notice = gtk::Label::new(None);
    notice.set_xalign(0.);
    notice.set_wrap(true);
    notice.add_css_class("notice");
    notice.set_visible(false);
    shell.append(&notice);
    let footer = gtk::Box::new(gtk::Orientation::Horizontal, 8);
    footer.add_css_class("footer");
    let label = gtk::Label::new(Some("╱  Spotlight"));
    footer.append(&label);
    let hint = gtk::Label::new(Some("↑ ↓ Navigate"));
    hint.set_hexpand(true);
    hint.set_xalign(0.);
    hint.set_margin_start(16);
    footer.append(&hint);
    let awake_status = gtk::Label::new(Some("☕ Awake"));
    awake_status.set_tooltip_text(Some("Caffeinate is on · search Caffeinate to turn it off"));
    awake_status.add_css_class("notice");
    awake_status.set_visible(false);
    footer.append(&awake_status);
    let open = gtk::Button::with_label("Open  ↵");
    open.add_css_class("flat");
    footer.append(&open);
    let actions = gtk::Button::with_label("Actions  Tab");
    actions.set_widget_name("actions-button");
    actions.set_tooltip_text(Some("Actions for the selected result · Tab or Ctrl+K"));
    actions.add_css_class("flat");
    footer.append(&actions);
    shell.append(&footer);
    window.set_child(Some(&shell));
    let (mut store, load_error) = match Store::load() {
        Ok(s) => (s, None),
        Err(e) => (Store::default(), Some(e)),
    };
    if load_error.is_none() && store.obsidian_vault.is_none() && !store.obsidian_disabled && !test {
        let vaults = quicknote::discover();
        if vaults.len() == 1 {
            store.obsidian_vault = Some(vaults[0].path.clone());
            if let Err(error) = store.save() {
                eprintln!("Could not save the Obsidian connection: {error}");
            }
        }
    }
    if let Some(family) = store
        .selected_font
        .as_ref()
        .filter(|family| installed_fonts.contains(family))
    {
        font_css.load_from_data(&fonts::css(family));
    }
    match store.theme.css() {
        Ok(css) => theme_css.load_from_data(&css),
        Err(error) => {
            eprintln!("Invalid saved theme; using default colors: {error}");
            theme_css.load_from_data(&theme::Theme::default().css().unwrap());
            store.theme = theme::Theme::default();
        }
    }
    store.interface = store.interface.normalized();
    interface_css.load_from_data(&store.interface.css());
    let (width, height) = store.interface.dimensions();
    interface::fit_window(&window, width, height);
    let ui = Rc::new(Ui {
        vault_clipboard: RefCell::new(None),
        workflow_capture: RefCell::new(None),
        secure_vault: std::sync::Arc::new(std::sync::Mutex::new(securevault::Vault::new(
            core::data_dir().join("clipboard-vault.json"),
        ))),
        window,
        search,
        list,
        section,
        notice,
        hint,
        awake_status,
        add,
        back,
        window_shortcuts,
        file_shortcuts,
        store: RefCell::new(store),
        can_save: load_error.is_none(),
        page: RefCell::new(Page::Root),
        apps: RefCell::new(applications()),
        fonts: installed_fonts,
        font_css,
        theme_css,
        interface_css,
        guide_step: Cell::new(0),
        visible: RefCell::new(Vec::new()),
        rendered_search: RefCell::new(None),
        files: RefCell::new(Vec::new()),
        file_loading: RefCell::new(false),
        files_ready: RefCell::new(false),
        clips: RefCell::new(Vec::new()),
        clip_images: RefCell::new(Vec::new()),
        clip_current: RefCell::new(None),
        clip_generation: Cell::new(0),
        _window_bridge: windowing::register().ok(),
        extensions: RefCell::new(Vec::new()),
        extension_errors: RefCell::new(Vec::new()),
        extensions_loading: Cell::new(false),
        extension_session: RefCell::new(None),
        content_session: RefCell::new(None),
        result_limit: Cell::new(60),
        currency: RefCell::new(currency::State::default()),
        booster_cache: RefCell::new(std::collections::HashMap::new()),
        booster_pending: RefCell::new(std::collections::HashSet::new()),
        booster_busy: Cell::new(false),
        desktop_snippets_running: Cell::new(false),
        recents: RefCell::new(Vec::new()),
        recents_loading: Cell::new(false),
        thumbnails: RefCell::new(search::Thumbnails::default()),
        thumbnail_targets: RefCell::new(std::collections::HashMap::new()),
        thumbnails_polling: Cell::new(false),
        preview_window: RefCell::new(None),
        picker: RefCell::new(None),
        picking_color: Cell::new(false),
        picked_color: RefCell::new(None),
        measurement_request: RefCell::new(None),
        measuring_screen: Cell::new(false),
        measurement_window: RefCell::new(None),
        caffeinate: RefCell::new(None),
        pomodoro_awake: RefCell::new(None),
        paste_queue: RefCell::new(None),
        layout_busy: Cell::new(false),
        desktop_snapshot: RefCell::new(desktop::Snapshot::default()),
        desktop_loading: Cell::new(false),
        desktop_busy: Cell::new(false),
        desktop_generation: Cell::new(0),
        trash_dialog: RefCell::new(None),
        reminder_clock: RefCell::new(None),
        note_editor: RefCell::new(None),
        note_draft: RefCell::new(String::new()),
        alarm_window: RefCell::new(None),
        alarm_repeat: RefCell::new(None),
        alarm_label: RefCell::new(None),
        event_editor: RefCell::new(None),
    });
    ui.vault_expiry_clock();
    let weak_queue_ui = Rc::downgrade(&ui);
    app.connect_shutdown(move |_| {
        if let Some(ui) = weak_queue_ui.upgrade() {
            ui.paste_queue.borrow_mut().take();
            if let Ok(mut vault) = ui.secure_vault.try_lock() {
                vault.lock();
            }
            ui.pomodoro_awake.borrow_mut().take();
        }
    });
    if let Some(e) = load_error {
        ui.error(&format!(
            "Saved data could not be read: {e}. See data.json before saving new items."
        ));
    }
    let u = Rc::clone(&ui);
    ui.search.connect_changed(move |_| {
        u.result_limit.set(60);
        if u.search.text().trim().eq_ignore_ascii_case("uuid") {
            u.booster_cache
                .borrow_mut()
                .remove(&boosters::Query::Text(texttools::Query::Uuid));
        }
        u.refresh();
    });
    let u = Rc::clone(&ui);
    ui.search.connect_activate(move |_| u.activate());
    let u = Rc::clone(&ui);
    ui.list.connect_row_activated(move |_, row| {
        let selected = u.visible.borrow().get(row.index() as usize).cloned();
        if let Some(i) = selected {
            u.launch(i);
        }
    });
    let motion = gtk::EventControllerMotion::new();
    let list = ui.list.downgrade();
    motion.connect_motion(move |_, _, y| {
        if let Some(list) = list.upgrade()
            && let Some(row) = list.row_at_y(y.floor() as i32)
            && row.is_selectable()
        {
            list.select_row(Some(&row));
        }
    });
    ui.list.add_controller(motion);
    let u = Rc::clone(&ui);
    ui.back.connect_clicked(move |_| u.page(Page::Root));
    let u = Rc::clone(&ui);
    search_file.connect_clicked(move |_| {
        let query = u.search.text().to_string();
        u.page(Page::Files);
        if boosters::Query::parse(query.trim()).is_none()
            && extensions::query(query.trim()).is_none()
        {
            u.search.set_text(&query);
        }
    });
    let u = Rc::clone(&ui);
    recent_files.connect_clicked(move |_| u.page(Page::Recent));
    let u = Rc::clone(&ui);
    ui.add
        .connect_clicked(move |_| u.editor(*u.page.borrow(), None));
    let u = Rc::clone(&ui);
    settings.connect_clicked(move |_| u.settings());
    let u = Rc::clone(&ui);
    windows.connect_clicked(move |_| u.page(Page::Windows));
    let u = Rc::clone(&ui);
    ui.window_shortcuts
        .connect_clicked(move |_| u.launch(window_shortcuts_item()));
    let u = Rc::clone(&ui);
    open.connect_clicked(move |_| u.activate());
    let u = Rc::clone(&ui);
    actions.connect_clicked(move |b| u.actions(b));
    let keys = gtk::EventControllerKey::new();
    keys.set_propagation_phase(gtk::PropagationPhase::Capture);
    let u = Rc::clone(&ui);
    let action_button = actions.clone();
    keys.connect_key_pressed(move |_, key, _, mods| {
        let ctrl = mods.contains(gdk::ModifierType::CONTROL_MASK);
        if key == gdk::Key::F1 {
            u.settings_at(2);
            return glib::Propagation::Stop;
        }
        if key == gdk::Key::Escape {
            if *u.page.borrow() != Page::Root {
                u.page(Page::Root);
            } else {
                u.window.set_visible(false);
            }
            return glib::Propagation::Stop;
        }
        if ctrl {
            match key {
                gdk::Key::r | gdk::Key::R => {
                    u.cancel_content();
                    if *u.page.borrow() == Page::Scripts {
                        u.load_extensions();
                    }
                    if *u.page.borrow() == Page::Clipboard {
                        u.load_clipboard();
                    }
                    if *u.page.borrow() == Page::Recent {
                        u.load_recents();
                    }
                    if *u.page.borrow() == Page::Files {
                        *u.files_ready.borrow_mut() = false;
                        u.load_files();
                        u.load_recents();
                    }
                    u.extension_session.borrow_mut().take();
                    u.booster_cache.borrow_mut().clear();
                    u.refresh();
                }
                gdk::Key::Return | gdk::Key::KP_Enter if *u.page.borrow() == Page::Root => {
                    let web = u
                        .visible
                        .borrow()
                        .iter()
                        .find(|entry| entry.id == "web")
                        .cloned();
                    if let Some(web) = web {
                        u.launch(web);
                    }
                }
                gdk::Key::k | gdk::Key::K => u.actions(&action_button),
                gdk::Key::f | gdk::Key::F => u.favorite(),
                gdk::Key::n | gdk::Key::N => {
                    let p = *u.page.borrow();
                    if matches!(p, Page::Snippets | Page::Links | Page::Notes) {
                        u.editor(p, None);
                    }
                }
                gdk::Key::e | gdk::Key::E => u.edit_selected(),
                gdk::Key::d | gdk::Key::D => u.delete_selected(),
                gdk::Key::comma => u.settings(),
                _ => return glib::Propagation::Proceed,
            };
            return glib::Propagation::Stop;
        }
        if [gdk::Key::space, gdk::Key::Tab].contains(&key)
            && !mods.intersects(gdk::ModifierType::ALT_MASK | gdk::ModifierType::SHIFT_MASK)
            && gtk::prelude::GtkWindowExt::focus(&u.window)
                .is_some_and(|focus| focus == u.search || focus.is_ancestor(&u.search))
            && u.expand_search_snippet(key)
        {
            return glib::Propagation::Stop;
        }
        if key == gdk::Key::Tab
            && !mods.intersects(
                gdk::ModifierType::ALT_MASK
                    | gdk::ModifierType::SHIFT_MASK
                    | gdk::ModifierType::SUPER_MASK
                    | gdk::ModifierType::META_MASK,
            )
            && gtk::prelude::GtkWindowExt::focus(&u.window).is_some_and(|focus| {
                focus == u.search
                    || focus.is_ancestor(&u.search)
                    || focus == u.list
                    || focus.is_ancestor(&u.list)
            })
        {
            u.actions(&action_button);
            return glib::Propagation::Stop;
        }
        if key == gdk::Key::Down || key == gdk::Key::Up {
            let total = u.visible.borrow().len() as i32;
            if total > 0 {
                let at = u.list.selected_row().map(|r| r.index()).unwrap_or(0);
                let next = if key == gdk::Key::Down {
                    (at + 1).min(total - 1)
                } else {
                    (at - 1).max(0)
                };
                if let Some(row) = u.list.row_at_index(next) {
                    u.list.select_row(Some(&row));
                    row.grab_focus();
                    u.search.grab_focus();
                }
            }
            return glib::Propagation::Stop;
        }
        glib::Propagation::Proceed
    });
    ui.window.add_controller(keys);
    let weak = Rc::downgrade(&ui);
    ui.window.connect_visible_notify(move |w| {
        if !w.is_visible()
            && let Some(ui) = weak.upgrade()
        {
            ui.extension_session.borrow_mut().take();
            ui.cancel_content();
        }
    });
    ui.window.connect_close_request(|w| {
        w.set_visible(false);
        glib::Propagation::Stop
    });
    ui.refresh();
    if test || !std::env::args().any(|a| a == "--background") {
        ui.window.present();
        ui.search.grab_focus();
    }
    if !test {
        ui.load_desktop();
        ui.arm_reminders();
        ui.sync_pomodoro();
        if ui.can_save && ui.store.borrow().desktop_snippets {
            let result = {
                let store = ui.store.borrow();
                snippets::sync(&store.snippets, true)
            };
            if let Err(error) = result {
                ui.error(&error);
            } else {
                ui.start_desktop_snippets();
            }
        }
    }
    ui
}
fn smoke_currency(ui: Rc<Ui>) {
    ui.search.set_text("100 USD to AUD");
    assert_eq!(ui.visible.borrow()[0].title, "Fetching exchange rate…");
    let started = std::time::Instant::now();
    glib::timeout_add_local(Duration::from_millis(100), move || {
        let pair = ("USD".into(), "AUD".into());
        if let Some((_, result)) = ui.currency.borrow().cache.get(&pair) {
            let rate = result.as_ref().expect("Live currency API request");
            let query = currency::parse("100 USD to AUD").unwrap();
            assert_eq!(
                ui.visible.borrow()[0].title,
                currency::convert(&query, rate.rate).unwrap()
            );
            assert!(ui.visible.borrow()[0].subtitle.contains(&rate.date));
            println!(
                "Live currency UI passed: {} · rate date {}",
                ui.visible.borrow()[0].title,
                rate.date
            );
            if std::env::args().any(|a| a == "--currency-screenshot") {
                capture_smoke(Rc::clone(&ui));
            } else {
                smoke(Rc::clone(&ui));
            }
            return glib::ControlFlow::Break;
        }
        assert!(
            started.elapsed().as_secs() < 16,
            "Live currency request timed out"
        );
        glib::ControlFlow::Continue
    });
}
fn play_alarm_sound() {
    std::thread::spawn(|| {
        let played = Command::new("paplay")
            .arg("/usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga")
            .status()
            .is_ok_and(|status| status.success());
        if !played {
            let result = Command::new("canberra-gtk-play")
                .args([
                    "--id",
                    "alarm-clock-elapsed",
                    "--description",
                    "Spotlight alarm",
                ])
                .status();
            if !result.is_ok_and(|status| status.success()) {
                eprintln!("Spotlight could not play the alarm sound");
            }
        }
    });
}

fn test_widget(
    widget: &gtk::Widget,
    predicate: &dyn Fn(&gtk::Widget) -> bool,
) -> Option<gtk::Widget> {
    if predicate(widget) {
        return Some(widget.clone());
    }
    let mut child = widget.first_child();
    while let Some(widget) = child {
        if let Some(found) = test_widget(&widget, predicate) {
            return Some(found);
        }
        child = widget.next_sibling();
    }
    None
}
fn smoke_folder_open(ui: Rc<Ui>) {
    assert!(core::data_dir().starts_with("/tmp"));
    let folder = core::home().join("Folder café # & test");
    let document = core::home().join("ordinary document.txt");
    assert!(folder.is_dir() && document.is_file());
    *ui.files.borrow_mut() = vec![folder.clone(), document.clone()];
    *ui.files_ready.borrow_mut() = true;
    ui.page(Page::Files);
    ui.search.set_text("Folder café # & test");
    assert_eq!(ui.selected().unwrap().id, folder.to_string_lossy());
    ui.activate();
    assert!(
        !ui.window.is_visible(),
        "Folder search launched the file manager"
    );
    assert!(ui.recents.borrow().iter().any(|(path, _)| path == &folder));
    ui.page(Page::Recent);
    let mut phase = 0;
    glib::timeout_add_local(Duration::from_millis(350), move || {
        match phase {
            0 => {
                if ui.recents_loading.get() {
                    return glib::ControlFlow::Continue;
                }
                ui.window.present();
                ui.search.set_text("Folder café # & test");
                assert_eq!(ui.selected().unwrap().id, folder.to_string_lossy());
                ui.activate();
                assert!(
                    !ui.window.is_visible(),
                    "Recent folders use the file manager too"
                );
                ui.page(Page::Files);
                ui.search.set_text("ordinary document.txt");
                assert_eq!(ui.selected().unwrap().id, document.to_string_lossy());
                ui.activate();
                assert!(
                    !ui.window.is_visible(),
                    "Documents still use their own default application"
                );
            }
            1 => {
                ui.window.present();
                ui.settings();
                let settings = test_settings_window();
                let open = test_widget(settings.upcast_ref(), &|w| {
                    w.clone()
                        .downcast::<gtk::Button>()
                        .is_ok_and(|b| b.label().as_deref() == Some("Open scripts folder"))
                })
                .unwrap()
                .downcast::<gtk::Button>()
                .unwrap();
                open.emit_clicked();
                assert!(
                    !ui.notice.is_visible(),
                    "Settings folder opens without errors"
                );
                settings.close();
                println!(
                    "Folder opening UI passed: Search File, Recent, Settings folders, URI escaping, normal document defaults, and recent registration"
                );
                ui.window.application().unwrap().quit();
                return glib::ControlFlow::Break;
            }
            _ => unreachable!(),
        }
        phase += 1;
        glib::ControlFlow::Continue
    });
}
fn smoke_guide(ui: Rc<Ui>) {
    assert!(core::data_dir().starts_with("/tmp"));
    ui.settings_at(2);
    let mut phase = 0;
    let started = std::time::Instant::now();
    glib::timeout_add_local(Duration::from_millis(400), move || {
        assert!(
            started.elapsed().as_secs() < 15,
            "Guide UI timed out at phase {phase}"
        );
        let chooser = |settings: &gtk::Window| -> gtk::DropDown {
            test_widget(settings.upcast_ref(), &|w| {
                w.widget_name() == "guide-topics"
            })
            .unwrap()
            .downcast()
            .unwrap()
        };
        let label = |settings: &gtk::Window, name: &str| -> gtk::Label {
            test_widget(settings.upcast_ref(), &|w| w.widget_name() == name)
                .unwrap()
                .downcast()
                .unwrap()
        };
        let topic_index = |menu: &gtk::DropDown, title: &str| -> u32 {
            let model = menu.model().unwrap();
            (0..model.n_items())
                .find(|i| {
                    model
                        .item(*i)
                        .and_downcast::<gtk::StringObject>()
                        .is_some_and(|s| s.string().ends_with(&format!(" · {title}")))
                })
                .unwrap_or_else(|| panic!("Missing guide topic {title}"))
        };
        match phase {
            0 => {
                let settings = test_settings_window();
                let menu = chooser(&settings);
                let model = menu.model().unwrap();
                assert!(model.n_items() >= 90);
                for title in [
                    "Music controls · MPRIS players",
                    "Browser history and bookmarks",
                    "Local todos",
                    "Git status dashboard · dirty repositories",
                    "Screenshot action chain · OCR, QR, compress and pin",
                ] {
                    topic_index(&menu, title);
                }
                assert!(menu.enables_search());
                for index in 0..model.n_items() {
                    menu.set_selected(index);
                    assert_eq!(ui.guide_step.get(), index as usize);
                    for name in [
                        "guide-title",
                        "guide-description",
                        "guide-example",
                        "guide-tip",
                    ] {
                        assert!(
                            !label(&settings, name).text().is_empty(),
                            "Topic {index}: {name}"
                        );
                    }
                    assert!(label(&settings, "guide-progress").text().contains(&format!(
                        "{} of {}",
                        index + 1,
                        model.n_items()
                    )));
                }
                menu.set_selected(topic_index(&menu, "Create calendar events from text"));
            }
            1 => {
                let settings = test_settings_window();
                assert_eq!(
                    label(&settings, "guide-title").text().as_str(),
                    "Create calendar events from text"
                );
                assert!(
                    label(&settings, "guide-example")
                        .text()
                        .contains("July 13 2027")
                );
                capture_test_window(&settings, "/tmp/spotlight-guide-calendar.png");
                let menu = chooser(&settings);
                menu.emit_by_name::<()>("activate", &[]);
            }
            2 => {
                let settings = test_settings_window();
                let menu = chooser(&settings);
                let search: gtk::SearchEntry =
                    test_widget(menu.upcast_ref(), &|w| w.is::<gtk::SearchEntry>())
                        .unwrap()
                        .downcast()
                        .unwrap();
                if search.text().as_str() != "uuid" {
                    search.set_text("uuid");
                    return glib::ControlFlow::Continue;
                }
                let list: gtk::ListView = test_widget(menu.upcast_ref(), &|w| {
                    w.is::<gtk::ListView>() && w.is_mapped()
                })
                .unwrap()
                .downcast()
                .unwrap();
                capture_test_window(&settings, "/tmp/spotlight-guide-topics.png");
                assert_eq!(
                    list.model().unwrap().n_items(),
                    1,
                    "Topic search matches words after the category prefix"
                );
                capture_test_window(&settings, "/tmp/spotlight-guide-topics.png");
                let popup: gtk::Popover =
                    test_widget(menu.upcast_ref(), &|w| w.is::<gtk::Popover>())
                        .unwrap()
                        .downcast()
                        .unwrap();
                popup.popdown();
                menu.set_selected(topic_index(&menu, "Create calendar events from text"));
                test_named_button(&settings, "guide-try").emit_clicked();
                assert_eq!(ui.search.text().as_str(), "event on July 13 2027");
                assert!(
                    ui.event_editor.borrow().is_none(),
                    "Guide example only prepares the event search"
                );
                assert!(ui.store.borrow().reminders.is_empty());
                ui.settings_at(2);
            }
            3 => {
                let settings = test_settings_window();
                let menu = chooser(&settings);
                assert_eq!(
                    menu.selected(),
                    topic_index(&menu, "Create calendar events from text"),
                    "Guide remembers a jumped-to topic"
                );
                menu.set_selected(topic_index(&menu, "Recent files and folders"));
                test_named_button(&settings, "guide-try").emit_clicked();
                assert!(
                    *ui.page.borrow() == Page::Recent,
                    "Recent example opens the separate view"
                );
                ui.settings_at(2);
                let menu = chooser(&test_settings_window());
                menu.set_selected(topic_index(&menu, "HTTP scratch · quick REST client"));
            }
            4 => {
                let settings = test_settings_window();
                assert_eq!(
                    label(&settings, "guide-title").text().as_str(),
                    "HTTP scratch · quick REST client"
                );
                capture_test_window(&settings, "/tmp/spotlight-guide-http.png");
                test_named_button(&settings, "guide-try").emit_clicked();
                assert_eq!(ui.search.text().as_str(), "get https://api.github.com/user");
                assert!(
                    !gtk::Window::list_toplevels()
                        .into_iter()
                        .filter_map(|w| w.downcast::<gtk::Window>().ok())
                        .any(|w| w.title().as_deref() == Some("HTTP Scratch")),
                    "Guide only prepares HTTP search"
                );
                ui.settings_at(2);
                let menu = chooser(&test_settings_window());
                menu.set_selected(topic_index(
                    &menu,
                    "Dotfiles sync · export to a private Git repo",
                ));
            }
            5 => {
                let settings = test_settings_window();
                assert_eq!(
                    label(&settings, "guide-title").text().as_str(),
                    "Dotfiles sync · export to a private Git repo"
                );
                capture_test_window(&settings, "/tmp/spotlight-guide-dotfiles.png");
                test_named_button(&settings, "guide-try").emit_clicked();
                let tabs: gtk::Stack = test_widget(settings.upcast_ref(), &|w| {
                    w.widget_name() == "settings-pages"
                })
                .unwrap()
                .downcast()
                .unwrap();
                assert_eq!(tabs.visible_child_name().as_deref(), Some("general"));
                assert!(
                    ui.store.borrow().dotfiles_repo.is_none(),
                    "Guide does not configure or run exports"
                );
                tabs.set_visible_child_name("guide");
            }
            6 => {
                let settings = test_settings_window();
                let menu = chooser(&settings);
                menu.set_selected(topic_index(&menu, "Window layout and interface size"));
                test_named_button(&settings, "guide-try").emit_clicked();
                let tabs: gtk::Stack = test_widget(settings.upcast_ref(), &|w| {
                    w.widget_name() == "settings-pages"
                })
                .unwrap()
                .downcast()
                .unwrap();
                assert_eq!(tabs.visible_child_name().as_deref(), Some("window"));
                tabs.set_visible_child_name("guide");
                let last = chooser(&settings).model().unwrap().n_items() - 1;
                chooser(&settings).set_selected(last);
                assert_eq!(
                    test_named_button(&settings, "guide-next")
                        .label()
                        .as_deref(),
                    Some("Start searching")
                );
                test_named_button(&settings, "guide-back").emit_clicked();
                assert_eq!(chooser(&settings).selected(), last - 1);
                test_named_button(&settings, "guide-finish").emit_clicked();
                assert!(*ui.page.borrow() == Page::Root);
                assert_eq!(ui.guide_step.get(), 0);
                ui.settings_at(2);
            }
            7 => {
                let settings = test_settings_window();
                assert_eq!(chooser(&settings).selected(), 0);
                capture_test_window(&settings, "/tmp/spotlight-guide-overview.png");
                let menu = chooser(&settings);
                menu.set_selected(topic_index(
                    &menu,
                    "Screenshot action chain · OCR, QR, compress and pin",
                ));
            }
            8 => {
                let settings = test_settings_window();
                assert!(
                    label(&settings, "guide-description")
                        .text()
                        .contains("one capture")
                );
                assert!(label(&settings, "guide-example").text().contains("Tab"));
                assert!(label(&settings, "guide-tip").text().contains("same image"));
                capture_test_window(&settings, "/tmp/spotlight-guide-screenshot-chain.png");
                settings.close();
                println!(
                    "Guide UI passed: every topic, new local tools and screenshot chain, searchable topic menu, direct navigation, calendar, Recent and HTTP examples, dotfiles and Settings links, remembered topic, Back, and Start searching"
                );
                ui.window.application().unwrap().quit();
                return glib::ControlFlow::Break;
            }
            _ => unreachable!(),
        }
        phase += 1;
        glib::ControlFlow::Continue
    });
}
fn smoke_calendar(ui: Rc<Ui>) {
    assert!(core::data_dir().starts_with("/tmp"));
    ui.search.set_text("event on july 13 2027");
    assert!(
        matches!(&ui.visible.borrow()[0].action, Action::CalendarEvent(d) if d.year == 2027 && d.month == 7 && d.day == 13 && d.title.is_empty())
    );
    ui.activate();
    let mut phase = 0;
    let started = std::time::Instant::now();
    let folder = core::data_dir().join("calendars");
    let count = move || {
        std::fs::read_dir(&folder)
            .into_iter()
            .flatten()
            .flatten()
            .count()
    };
    glib::timeout_add_local(Duration::from_millis(350), move || {
        assert!(
            started.elapsed().as_secs() < 15,
            "Calendar UI timed out at phase {phase}: {}",
            ui.notice.text()
        );
        let field = |dialog: &gtk::Window, name: &str| -> gtk::Entry {
            test_widget(dialog.upcast_ref(), &|w| w.widget_name() == name)
                .unwrap()
                .downcast()
                .unwrap()
        };
        match phase {
            0 => {
                let dialog = ui.event_editor.borrow().as_ref().unwrap().clone();
                let save = test_named_button(&dialog, "event-save");
                if !save.is_sensitive() {
                    return glib::ControlFlow::Continue;
                }
                assert_eq!(count(), 0, "Preview creates no calendar files");
                assert_eq!(field(&dialog, "event-date").text().as_str(), "2027-07-13");
                let title = field(&dialog, "event-title");
                title.set_text("Birthday café 🎉");
                field(&dialog, "event-date").set_text("2027-02-30");
                save.emit_clicked();
                assert_eq!(count(), 0, "Invalid date cannot be saved");
                field(&dialog, "event-date").set_text("July 13 2027");
                title.set_text("");
                save.emit_clicked();
                assert_eq!(count(), 0, "A title is required");
                title.set_text("Birthday café 🎉");
                field(&dialog, "event-location").set_text("Room, one; café");
            }
            1 => {
                let dialog = ui.event_editor.borrow().as_ref().unwrap().clone();
                capture_test_window(&dialog, "/tmp/spotlight-event-all-day.png");
                let save = test_named_button(&dialog, "event-save");
                save.emit_clicked();
                save.emit_clicked(); // A second activation must not duplicate a pending save.
            }
            2 => {
                if ui.event_editor.borrow().is_some() || !ui.booster_pending.borrow().is_empty() {
                    return glib::ControlFlow::Continue;
                }
                assert_eq!(count(), 1, "One all-day event was persisted");
                assert!(ui.visible.borrow().iter().any(|i| i.title == "Birthday café 🎉" && matches!(&i.action, Action::Preview { text, .. } if text.contains("20270713") && text.contains("20270714"))));
                ui.search
                    .set_text("add event Meeting on July 13 2027 at 3:30pm");
                ui.activate();
            }
            3 => {
                let dialog = ui.event_editor.borrow().as_ref().unwrap().clone();
                if !test_named_button(&dialog, "event-save").is_sensitive() {
                    return glib::ControlFlow::Continue;
                }
                assert_eq!(field(&dialog, "event-time").text().as_str(), "15:30");
                let duration: gtk::SpinButton = test_widget(dialog.upcast_ref(), &|w| {
                    w.widget_name() == "event-duration"
                })
                .unwrap()
                .downcast()
                .unwrap();
                duration.set_value(90.);
                let all_day: gtk::CheckButton =
                    test_widget(dialog.upcast_ref(), &|w| w.widget_name() == "event-all-day")
                        .unwrap()
                        .downcast()
                        .unwrap();
                assert!(!all_day.is_active());
                field(&dialog, "event-title").set_text("Edited meeting");
            }
            4 => {
                let dialog = ui.event_editor.borrow().as_ref().unwrap().clone();
                capture_test_window(&dialog, "/tmp/spotlight-event-timed.png");
                test_named_button(&dialog, "event-save").emit_clicked();
            }
            5 => {
                if ui.event_editor.borrow().is_some() || !ui.booster_pending.borrow().is_empty() {
                    return glib::ControlFlow::Continue;
                }
                assert_eq!(count(), 2);
                assert_eq!(
                    ui.search.text().as_str(),
                    "calendar Edited meeting",
                    "Search uses the edited title"
                );
                assert!(
                    ui.visible
                        .borrow()
                        .iter()
                        .any(|i| i.title == "Edited meeting")
                );
                capture_test_window(ui.window.upcast_ref(), "/tmp/spotlight-event-search.png");
                ui.search.set_text("event Cancelled on July 13 2027");
                ui.activate();
                let dialog = ui.event_editor.borrow().as_ref().unwrap().clone();
                dialog.close();
                assert!(ui.event_editor.borrow().is_none());
                assert_eq!(count(), 2, "Cancel does not create an event");
                let saved =
                    std::fs::read_to_string(core::data_dir().join("data.json")).unwrap_or_default();
                assert!(
                    !saved.contains("Birthday café") && !saved.contains("Edited meeting"),
                    "Event contents stay out of usage history"
                );
                println!(
                    "Calendar UI passed: natural dates, required title, invalid-date rejection, review, all-day and timed saves, duplicate protection, edited title, persisted search, cancellation, and private usage history"
                );
                ui.window.application().unwrap().quit();
                return glib::ControlFlow::Break;
            }
            _ => unreachable!(),
        }
        phase += 1;
        glib::ControlFlow::Continue
    });
}
fn smoke_notes(ui: Rc<Ui>) {
    glib::timeout_add_local_once(Duration::from_millis(500), move || {
        assert!(
            ui.store.borrow().quick_notes.is_empty(),
            "Use an isolated XDG_DATA_HOME for note tests"
        );
        let vault = core::data_dir().join("Test vault");
        std::fs::create_dir_all(vault.join(".obsidian")).unwrap();
        ui.store.borrow_mut().obsidian_vault = Some(vault.clone());
        ui.store.borrow().save().unwrap();
        ui.search.set_text("note One-line capture café 🎉");
        assert!(matches!(
            ui.visible.borrow()[0].action,
            Action::CaptureNote(_)
        ));
        ui.activate();
        let saved = Store::load().unwrap();
        assert_eq!(saved.quick_notes.len(), 1);
        assert_eq!(
            std::fs::read_to_string(&saved.quick_notes[0].path).unwrap(),
            "One-line capture café 🎉\n"
        );
        assert!(
            saved.quick_notes[0]
                .path
                .starts_with(vault.canonicalize().unwrap())
        );
        ui.search.set_text("One-line capture");
        assert!(ui.visible.borrow().iter().any(|entry| matches!(&entry.action, Action::Open(uri) if uri.starts_with("obsidian://open?path="))), "Saved notes open in Obsidian");
        ui.window
            .application()
            .unwrap()
            .activate_action("quick-note", None);
        let dialog = ui.note_editor.borrow().as_ref().unwrap().clone();
        let text: gtk::TextView =
            test_widget(dialog.upcast_ref(), &|widget| widget.is::<gtk::TextView>())
                .unwrap()
                .downcast()
                .unwrap();
        let body = "Multiline capture\n\n    indented code\n- a list\n";
        text.buffer().set_text(body);
        dialog.close();
        assert!(ui.note_editor.borrow().is_none());
        ui.quick_note("");
        let dialog = ui.note_editor.borrow().as_ref().unwrap().clone();
        let text: gtk::TextView =
            test_widget(dialog.upcast_ref(), &|widget| widget.is::<gtk::TextView>())
                .unwrap()
                .downcast()
                .unwrap();
        assert_eq!(
            text.buffer()
                .text(
                    &text.buffer().start_iter(),
                    &text.buffer().end_iter(),
                    false
                )
                .as_str(),
            body,
            "Draft survives closing the note box"
        );
        let save: gtk::Button = test_widget(dialog.upcast_ref(), &|widget| {
            widget
                .clone()
                .downcast::<gtk::Button>()
                .is_ok_and(|button| button.label().as_deref() == Some("Save Note"))
        })
        .unwrap()
        .downcast()
        .unwrap();
        save.emit_clicked();
        assert!(ui.note_editor.borrow().is_none());
        let saved = Store::load().unwrap();
        assert_eq!(saved.quick_notes.len(), 2);
        assert_eq!(
            std::fs::read_to_string(&saved.quick_notes[0].path).unwrap(),
            body
        );
        assert!(ui.note_draft.borrow().is_empty());
        assert_eq!(saved.obsidian_vault, Some(vault));
        println!(
            "Quick-note UI passed: search capture, Markdown content, vault connection, recent notes, Obsidian URI, multiline editor, draft retention, saved state"
        );
        ui.search.set_text("");
        smoke(Rc::clone(&ui));
    });
}
fn smoke_alarm(ui: Rc<Ui>) {
    assert!(
        ui.store.borrow().reminders.is_empty() && ui.store.borrow().ringing_reminders.is_empty(),
        "Use isolated empty data for alarm tests"
    );
    ui.search.set_text("alarm");
    assert!(
        matches!(ui.visible.borrow()[0].action, Action::AlarmSetup),
        "Bare alarm opens setup"
    );
    ui.activate();
    glib::timeout_add_local_once(Duration::from_millis(300), move || {
        let dialog = ui
            .window
            .application()
            .unwrap()
            .windows()
            .into_iter()
            .find(|window| window.title().as_deref() == Some("Set Alarm"))
            .expect("Alarm setup window");
        let set: gtk::Button = test_widget(dialog.upcast_ref(), &|widget| {
            widget
                .clone()
                .downcast::<gtk::Button>()
                .is_ok_and(|button| button.label().as_deref() == Some("Set Alarm"))
        })
        .unwrap()
        .downcast()
        .unwrap();
        set.emit_clicked();
        let alarm = Store::load().unwrap().reminders[0].clone();
        assert!(alarm.alarm);
        let now = glib::DateTime::now_local().unwrap().to_unix();
        assert!(
            alarm.due > now && alarm.due <= now + 60,
            "Next-minute local alarm"
        );
        println!(
            "Real clock alarm set; waiting {} seconds for expiry",
            alarm.due - now
        );
        ui.window.set_visible(false);
        let id = alarm.id.clone();
        let started = std::time::Instant::now();
        glib::timeout_add_local(Duration::from_millis(100), move || {
            assert!(started.elapsed().as_secs() < 70, "Alarm did not fire");
            if ui
                .store
                .borrow()
                .ringing_reminders
                .iter()
                .any(|entry| entry.id == id)
            {
                assert!(
                    ui.alarm_window.borrow().as_ref().unwrap().is_visible(),
                    "Alarm alert visible"
                );
                assert!(
                    ui.alarm_repeat.borrow().is_some(),
                    "Repeating alarm sound scheduled"
                );
                assert!(
                    Store::load()
                        .unwrap()
                        .ringing_reminders
                        .iter()
                        .any(|entry| entry.id == id),
                    "Ringing state survives restart"
                );
                let window = ui.alarm_window.borrow().as_ref().unwrap().clone();
                let dismiss: gtk::Button = test_widget(window.upcast_ref(), &|widget| {
                    widget
                        .clone()
                        .downcast::<gtk::Button>()
                        .is_ok_and(|button| button.label().as_deref() == Some("Dismiss Alarm"))
                })
                .unwrap()
                .downcast()
                .unwrap();
                dismiss.emit_clicked();
                assert!(ui.alarm_window.borrow().is_none());
                assert!(ui.alarm_repeat.borrow().is_none());
                assert!(Store::load().unwrap().ringing_reminders.is_empty());
                println!(
                    "Alarm UI passed: setup form, real clock deadline, visible alert, repeating sound source, persisted ringing state, dismissal"
                );
                ui.window.application().unwrap().quit();
                return glib::ControlFlow::Break;
            }
            glib::ControlFlow::Continue
        });
    });
}
fn capture_test_window(window: &gtk::Window, path: &str) {
    let paint = gtk::WidgetPaintable::new(Some(window));
    let snapshot = gtk::Snapshot::new();
    paint.snapshot(&snapshot, window.width() as f64, window.height() as f64);
    if let Some(node) = snapshot.to_node()
        && let Some(renderer) = window.renderer()
    {
        renderer
            .render_texture(&node, None)
            .save_to_png(path)
            .unwrap();
    }
}
fn smoke_superpowers(ui: Rc<Ui>) {
    assert_eq!(
        std::env::var("SPOTLIGHT_SUPER_FIXTURES").as_deref(),
        Ok("1")
    );
    assert!(core::data_dir().starts_with("/tmp"));
    ui.search.set_editable(false);
    let shield = gtk::EventControllerKey::new();
    shield.set_propagation_phase(gtk::PropagationPhase::Capture);
    shield.connect_key_pressed(|_, _, _, _| glib::Propagation::Stop);
    ui.window.add_controller(shield);
    ui.load_extensions();
    let fixture_name = std::env::var("SPOTLIGHT_DESKTOP_FIXTURE_NAME").unwrap();
    let fixture_id = std::env::var("SPOTLIGHT_DESKTOP_FIXTURE_ID").unwrap();
    let original_id = std::env::var("SPOTLIGHT_DESKTOP_ORIGINAL_ID").unwrap();
    let root = PathBuf::from(std::env::var_os("SPOTLIGHT_SUPER_ROOT").unwrap());
    let mut phase = 0;
    let started = std::time::Instant::now();
    let mut phase_at = started;
    glib::timeout_add_local(Duration::from_millis(50), move || {
        assert!(
            started.elapsed() < Duration::from_secs(35),
            "Superpowers UI timed out at phase {phase}: {}",
            ui.notice.text()
        );
        if phase_at.elapsed() < Duration::from_millis(180) || ui.extensions_loading.get() {
            return glib::ControlFlow::Continue;
        }
        match phase {
            0 => {
                assert_eq!(ui.extensions.borrow().len(), 2);
                assert!(
                    ui.extensions
                        .borrow()
                        .iter()
                        .all(|m| m.runtime == extensions::Runtime::Wasm)
                );
                ui.search.set_text("plugin wasm-text café ß");
            }
            1 => {
                if !ui
                    .extension_session
                    .borrow()
                    .as_ref()
                    .is_some_and(|s| s.done)
                {
                    return glib::ControlFlow::Continue;
                }
                assert!(
                    ui.visible
                        .borrow()
                        .iter()
                        .any(|i| matches!(&i.action,Action::Copy(s) if s=="CAFÉ SS")),
                    "Rust WASM plugin: {:?}",
                    ui.visible
                        .borrow()
                        .iter()
                        .map(|i| &i.title)
                        .collect::<Vec<_>>()
                );
                capture_test_window(ui.window.upcast_ref(), "/tmp/spotlight-wasm-preview.png");
                ui.search.set_text("plugin wasm-loop cancel");
            }
            2 => {
                let cancel = {
                    let session = ui.extension_session.borrow();
                    let Some(s) = session.as_ref().filter(|s| !s.items.is_empty()) else {
                        return glib::ControlFlow::Continue;
                    };
                    // Fast machines may exhaust fuel before the next UI frame.
                    assert!(
                        !s.done || s.status.contains("fuel"),
                        "Loop must still run or stop at its fuel bound: {}",
                        s.status
                    );
                    assert_eq!(s.items[0].title, "WASM before loop");
                    s.cancel.clone()
                };
                ui.search.set_text("in: Notes stream-fixture");
                assert!(cancel.load(std::sync::atomic::Ordering::Relaxed));
            }
            3 => {
                let cancel = {
                    let session = ui.content_session.borrow();
                    let Some(s) = session.as_ref().filter(|s| !s.rows.is_empty()) else {
                        return glib::ControlFlow::Continue;
                    };
                    assert!(!s.done, "First rg result arrives before the scan exits");
                    s.cancel.clone()
                };
                assert!(
                    ui.visible
                        .borrow()
                        .iter()
                        .any(|i| i.title.contains("stream-fixture"))
                );
                capture_test_window(
                    ui.window.upcast_ref(),
                    "/tmp/spotlight-content-stream-preview.png",
                );
                ui.search.set_text("rg new-pattern");
                assert!(cancel.load(std::sync::atomic::Ordering::Relaxed));
            }
            4 => {
                if !ui.content_session.borrow().as_ref().is_some_and(|s| s.done) {
                    return glib::ControlFlow::Continue;
                }
                assert!(
                    !ui.visible
                        .borrow()
                        .iter()
                        .any(|i| i.title.contains("stream-fixture"))
                );
                assert!(!root.join("search-uncancelled").exists());
                ui.search.set_text(&format!("desktop {fixture_name}"));
            }
            5 => {
                if !ui.booster_pending.borrow().is_empty() {
                    return glib::ControlFlow::Continue;
                }
                let row = ui.visible.borrow()[0].clone();
                assert!(
                    matches!(&row.action,Action::Booster(boosters::Operation::SwitchDesktop(id)) if id==&fixture_id),
                    "Desktop discovery: {} · {}",
                    row.title,
                    row.subtitle
                );
                capture_test_window(
                    ui.window.upcast_ref(),
                    "/tmp/spotlight-desktops-preview.png",
                );
                ui.launch(row);
            }
            6 => {
                if ui.booster_busy.get() || !ui.booster_pending.borrow().is_empty() {
                    return glib::ControlFlow::Continue;
                }
                assert!(!ui.window.is_visible());
                assert!(
                    ui.visible
                        .borrow()
                        .iter()
                        .any(|i| i.subtitle.starts_with("Current")),
                    "Temporary desktop became current: {}",
                    ui.notice.text()
                );
                ui.execute_booster(boosters::Operation::SwitchDesktop(original_id.clone()));
            }
            7 => {
                if ui.booster_busy.get() || !ui.booster_pending.borrow().is_empty() {
                    return glib::ControlFlow::Continue;
                }
                assert!(
                    !ui.visible
                        .borrow()
                        .iter()
                        .any(|i| i.subtitle.starts_with("Current")),
                    "Returned to the original desktop"
                );
                ui.window.present();
                ui.search.set_text(&format!("switch {fixture_name}"));
            }
            8 => {
                if !ui.booster_pending.borrow().is_empty() {
                    return glib::ControlFlow::Continue;
                }
                assert!(ui.visible.borrow().iter().any(|i|matches!(&i.action,Action::Booster(boosters::Operation::SwitchDesktop(id))if id==&fixture_id)));
                assert!(!root.join("search-uncancelled").exists());
                ui.search.set_text("plugin wasm-loop quit");
            }
            9 => {
                if !ui
                    .extension_session
                    .borrow()
                    .as_ref()
                    .is_some_and(|s| !s.items.is_empty())
                {
                    return glib::ControlFlow::Continue;
                }
                println!(
                    "Superpowers UI passed: compiled Rust WASM results, bounded looping plugin, query cancellation, streaming rg results, stale scan cancellation, live virtual desktop discovery, switch, return, combined switcher, and worker cleanup on quit"
                );
                ui.window.application().unwrap().quit();
                return glib::ControlFlow::Break;
            }
            _ => unreachable!(),
        }
        phase += 1;
        phase_at = std::time::Instant::now();
        glib::ControlFlow::Continue
    });
}
fn smoke_plus(ui: Rc<Ui>) {
    assert_eq!(std::env::var("SPOTLIGHT_PLUS_FIXTURES").as_deref(), Ok("1"));
    assert!(core::data_dir().starts_with("/tmp"));
    ui.search.set_editable(false);
    let shield = gtk::EventControllerKey::new();
    shield.set_propagation_phase(gtk::PropagationPhase::Capture);
    shield.connect_key_pressed(|_, _, _, _| glib::Propagation::Stop);
    ui.window.add_controller(shield);
    type Backup = Option<(Option<gdk::Texture>, Option<String>)>;
    let backup: Rc<RefCell<Backup>> = Rc::new(RefCell::new(None));
    let originally_empty = ui.window.clipboard().formats().to_string().is_empty();
    let saved = backup.clone();
    let clipboard = ui.window.clipboard();
    glib::timeout_add_local_once(Duration::from_millis(250), move || {
        let clip = clipboard.clone();
        clipboard.read_texture_async(None::<&gio::Cancellable>, move |result| {
            if let Ok(Some(texture)) = result {
                *saved.borrow_mut() = Some((Some(texture), None));
            } else {
                clip.read_text_async(None::<&gio::Cancellable>, move |text| {
                    *saved.borrow_mut() = Some((None, text.ok().flatten().map(|s| s.to_string())));
                });
            }
        });
    });
    ui.load_extensions();
    let mut phase = 0;
    let started = std::time::Instant::now();
    let mut phase_at = started;
    let verified = Rc::new(Cell::new(None));
    let mut fixture_window = String::new();
    glib::timeout_add_local(Duration::from_millis(60), move || {
        assert!(
            started.elapsed().as_secs() < 35,
            "Plus UI timed out at phase {phase}: {}",
            ui.notice.text()
        );
        if phase_at.elapsed() < Duration::from_millis(250)
            || ui.extensions_loading.get()
            || backup.borrow().is_none()
        {
            return glib::ControlFlow::Continue;
        }
        let restore = || {
            if std::env::var_os("SPOTLIGHT_PLUS_SKIP_COPY").is_some() {
                return;
            }
            if let Some((image, text)) = backup.borrow().as_ref() {
                if let Some(image) = image {
                    ui.window.clipboard().set_texture(image);
                } else if let Some(text) = text {
                    ui.window.clipboard().set_text(text);
                } else if originally_empty {
                    let _ = ui
                        .window
                        .clipboard()
                        .set_content(None::<&gdk::ContentProvider>);
                }
            }
        };
        let can_copy = std::env::var_os("SPOTLIGHT_PLUS_SKIP_COPY").is_none()
            && backup
                .borrow()
                .as_ref()
                .is_some_and(|(i, t)| i.is_some() || t.is_some() || originally_empty);
        match phase {
            0 => {
                assert_eq!(ui.extensions.borrow().len(), 3);
                assert!(!ui.extension_errors.borrow().is_empty());
                ui.search.set_text("ext live stream");
            }
            1 => {
                let session = ui.extension_session.borrow();
                let Some(s) = session.as_ref() else {
                    return glib::ControlFlow::Continue;
                };
                if s.items.is_empty() {
                    return glib::ControlFlow::Continue;
                }
                assert!(
                    !s.done,
                    "First result must arrive while extension is still working"
                );
                assert_eq!(s.items[0].title, "First stream");
            }
            2 => {
                if !ui
                    .extension_session
                    .borrow()
                    .as_ref()
                    .is_some_and(|s| s.done)
                {
                    return glib::ControlFlow::Continue;
                }
                assert_eq!(
                    ui.extension_session.borrow().as_ref().unwrap().items.len(),
                    2
                );
                assert_eq!(ui.selected().unwrap().title, "First stream");
                capture_test_window(
                    ui.window.upcast_ref(),
                    "/tmp/spotlight-extensions-preview.png",
                );
                ui.search.set_text("ext live cancel");
            }
            3 => {
                if !ui
                    .extension_session
                    .borrow()
                    .as_ref()
                    .is_some_and(|s| !s.items.is_empty())
                {
                    return glib::ControlFlow::Continue;
                }
                ui.search.set_text("hash abc");
                assert!(ui.extension_session.borrow().is_none());
            }
            4 => {
                let manifest = ui
                    .extensions
                    .borrow()
                    .iter()
                    .find(|m| m.id == "args")
                    .unwrap()
                    .clone();
                ui.open_extension(manifest);
            }
            5 => {
                let dialog = ui
                    .window
                    .application()
                    .unwrap()
                    .windows()
                    .into_iter()
                    .find(|w| w.title().as_deref() == Some("Argument Echo"))
                    .unwrap();
                let input: gtk::Entry = test_widget(dialog.upcast_ref(), &|w| w.is::<gtk::Entry>())
                    .unwrap()
                    .downcast()
                    .unwrap();
                input.set_text("literal ; $(no shell)");
                let run: gtk::Button = test_widget(dialog.upcast_ref(), &|w| {
                    w.clone()
                        .downcast::<gtk::Button>()
                        .is_ok_and(|b| b.label().as_deref() == Some("Run Extension"))
                })
                .unwrap()
                .downcast()
                .unwrap();
                run.emit_clicked();
            }
            6 => {
                if !ui
                    .extension_session
                    .borrow()
                    .as_ref()
                    .is_some_and(|s| s.done)
                {
                    return glib::ControlFlow::Continue;
                }
                assert_eq!(ui.visible.borrow()[0].title, "literal ; $(no shell)");
                ui.search.set_text("ext invalid anything");
            }
            7 => {
                if !ui
                    .extension_session
                    .borrow()
                    .as_ref()
                    .is_some_and(|s| s.done)
                {
                    return glib::ControlFlow::Continue;
                }
                assert!(
                    ui.extension_session
                        .borrow()
                        .as_ref()
                        .unwrap()
                        .status
                        .contains("Invalid JSON")
                );
                ui.search.set_text("translate en es hello");
            }
            8 => {
                if !ui.booster_pending.borrow().is_empty() {
                    return glib::ControlFlow::Continue;
                }
                assert!(
                    matches!(&ui.visible.borrow()[0].action,Action::Preview{text,..}if text.contains("hola"))
                );
                ui.page(Page::Clipboard);
            }
            9 => {
                if ui.clip_images.borrow().is_empty() {
                    return glib::ControlFlow::Continue;
                }
                assert_eq!(ui.clip_images.borrow()[0].width, 96);
                assert_eq!(ui.clip_images.borrow()[0].height, 64);
                let texture = clipimage::load(&ui.clip_images.borrow()[0].path).unwrap();
                ui.image_preview(&texture);
                let preview = ui
                    .window
                    .application()
                    .unwrap()
                    .windows()
                    .into_iter()
                    .find(|w| w.title().as_deref() == Some("Clipboard Image"))
                    .unwrap();
                assert!(test_widget(preview.upcast_ref(), &|w| w.is::<gtk::Picture>()).is_some());
                preview.close();
                capture_test_window(
                    ui.window.upcast_ref(),
                    "/tmp/spotlight-clipboard-images-preview.png",
                );
                if can_copy {
                    let row = ui
                        .visible
                        .borrow()
                        .iter()
                        .find(|i| matches!(i.action, Action::ClipboardImage(_)))
                        .unwrap()
                        .clone();
                    ui.launch(row);
                } else {
                    verified.set(Some(true));
                }
            }
            10 => {
                if can_copy {
                    if !ui.notice.text().starts_with("Image copied") {
                        return glib::ControlFlow::Continue;
                    }
                    let saved = backup.clone();
                    let check = verified.clone();
                    let clip = ui.window.clipboard();
                    let restore_clip = clip.clone();
                    clip.read_texture_async(None::<&gio::Cancellable>, move |result| {
                        let valid = result.is_ok_and(|image| {
                            image.is_some_and(|t| t.width() == 96 && t.height() == 64)
                        });
                        if let Some((image, text)) = saved.borrow().as_ref() {
                            if let Some(image) = image {
                                restore_clip.set_texture(image);
                            } else if let Some(text) = text {
                                restore_clip.set_text(text);
                            } else if originally_empty {
                                let _ = restore_clip.set_content(None::<&gdk::ContentProvider>);
                            }
                        }
                        check.set(Some(valid));
                    });
                }
            }
            11 => {
                let Some(valid) = verified.get() else {
                    return glib::ControlFlow::Continue;
                };
                assert!(valid, "Image copy round trip");
                ui.page(Page::Root);
                ui.search.set_text("thumbs up: dark skin tone");
            }
            12 => {
                let row = ui
                    .visible
                    .borrow()
                    .iter()
                    .find(|i| matches!(&i.action,Action::Copy(s)if s=="👍🏿"))
                    .unwrap()
                    .clone();
                if can_copy {
                    ui.launch(row);
                    restore();
                } else {
                    ui.store.borrow_mut().emoji_skin_tone = Some(5);
                    ui.save();
                }
                assert_eq!(Store::load().unwrap().emoji_skin_tone, Some(5));
                assert!(
                    ui.emoji_items().iter().any(
                        |i| i.id == "emoji:👋" && matches!(&i.action,Action::Copy(s)if s=="👋🏿")
                    )
                );
                ui.search.set_text("kaomoji shrug");
            }
            13 => {
                assert!(
                    matches!(&ui.visible.borrow()[0].action,Action::Copy(s)if s=="¯\\_(ツ)_/¯")
                );
                let title = std::env::var("SPOTLIGHT_WINDOW_FIXTURE_TITLE").unwrap();
                ui.search.set_text(&format!("window {title}"));
            }
            14 => {
                if !ui.booster_pending.borrow().is_empty() {
                    return glib::ControlFlow::Continue;
                }
                let first = ui.visible.borrow()[0].clone();
                let Action::Booster(boosters::Operation::FocusWindow(id)) = &first.action else {
                    panic!(
                        "Live KWin discovery failed: {} · {}",
                        first.title, first.subtitle
                    )
                };
                fixture_window = id.clone();
                capture_test_window(
                    ui.window.upcast_ref(),
                    "/tmp/spotlight-window-switcher-preview.png",
                );
                ui.launch(first);
            }
            15 => {
                if ui.booster_busy.get() || !ui.booster_pending.borrow().is_empty() {
                    return glib::ControlFlow::Continue;
                }
                assert!(!ui.window.is_visible(), "Switcher releases launcher focus");
                assert!(ui.visible.borrow().iter().any(|i|matches!(&i.action,Action::Booster(boosters::Operation::FocusWindow(id))if id==&fixture_window)&&i.subtitle.contains("Active")),"KWin activated the fixture window: {}",ui.notice.text());
                ui.window.present();
            }
            _ => {
                restore();
                let root = PathBuf::from(std::env::var_os("SPOTLIGHT_PLUS_ROOT").unwrap());
                assert!(!root.join("uncancelled").exists());
                println!(
                    "Plus UI passed: streamed results, cancellation, argument forms, malformed output, offline lookup, native Klipper images, image preview, copy check={}, emoji preference persistence, kaomoji, live KWin listing and focus",
                    can_copy
                );
                ui.window.application().unwrap().quit();
                return glib::ControlFlow::Break;
            }
        }
        phase += 1;
        phase_at = std::time::Instant::now();
        glib::ControlFlow::Continue
    });
}
fn smoke_interface(ui: Rc<Ui>) {
    assert!(core::data_dir().starts_with("/tmp"));
    ui.settings_at(4);
    let base_size = Rc::new(Cell::new((0, 0)));
    let mut phase = 0;
    glib::timeout_add_local(Duration::from_millis(450), move || {
        match phase {
            0 => {
                base_size.set((ui.window.width(), ui.window.height()));
                let settings = test_settings_window();
                capture_test_window(&settings, "/tmp/spotlight-window-settings.png");
                test_widget(settings.upcast_ref(), &|w| {
                    w.widget_name() == "window-expanded"
                })
                .unwrap()
                .downcast::<gtk::ToggleButton>()
                .unwrap()
                .set_active(true);
                test_widget(settings.upcast_ref(), &|w| {
                    w.widget_name() == "interface-size"
                })
                .unwrap()
                .downcast::<gtk::DropDown>()
                .unwrap()
                .set_selected(3);
                assert_eq!(
                    ui.store.borrow().interface,
                    interface::Preferences::default(),
                    "Draft controls wait for Apply"
                );
                test_named_button(&settings, "interface-apply").emit_clicked();
            }
            1 => {
                let preferences = interface::Preferences {
                    mode: interface::WindowMode::Expanded,
                    scale: 125,
                };
                assert_eq!(Store::load().unwrap().interface, preferences);
                assert!(
                    ui.window.width() > base_size.get().0,
                    "Expanded increases width"
                );
                assert!(
                    ui.window.height() > base_size.get().1,
                    "Expanded increases height"
                );
                capture_test_window(
                    ui.window.upcast_ref(),
                    "/tmp/spotlight-expanded-interface.png",
                );
                let settings = test_settings_window();
                let save = test_named_button(&settings, "interface-apply");
                save.set_state_flags(gtk::StateFlags::PRELIGHT, false);
            }
            2 => {
                let settings = test_settings_window();
                capture_test_window(&settings, "/tmp/spotlight-window-hover.png");
                settings.close();
                ui.settings_at(4);
            }
            3 => {
                let settings = test_settings_window();
                let expanded = test_widget(settings.upcast_ref(), &|w| {
                    w.widget_name() == "window-expanded"
                })
                .unwrap()
                .downcast::<gtk::ToggleButton>()
                .unwrap();
                assert!(expanded.is_active(), "Reopening restores saved mode");
                let size = test_widget(settings.upcast_ref(), &|w| {
                    w.widget_name() == "interface-size"
                })
                .unwrap()
                .downcast::<gtk::DropDown>()
                .unwrap();
                assert_eq!(
                    size.selected(),
                    3,
                    "Reopening restores saved interface size"
                );
                test_named_button(&settings, "interface-reset").emit_clicked();
                assert_eq!(size.selected(), 1);
                assert!(!expanded.is_active());
                test_named_button(&settings, "interface-apply").emit_clicked();
            }
            4 => {
                assert_eq!(
                    Store::load().unwrap().interface,
                    interface::Preferences::default()
                );
                assert_eq!(
                    (ui.window.width(), ui.window.height()),
                    base_size.get(),
                    "Compact/default restores window dimensions"
                );
                let settings = test_settings_window();
                test_widget(settings.upcast_ref(), &|w| {
                    w.widget_name() == "interface-size"
                })
                .unwrap()
                .downcast::<gtk::DropDown>()
                .unwrap()
                .set_selected(0);
                test_named_button(&settings, "interface-apply").emit_clicked();
            }
            5 => {
                assert_eq!(Store::load().unwrap().interface.scale, 90);
                assert!(
                    ui.window.width() < base_size.get().0,
                    "Small interface reduces window width"
                );
                capture_test_window(ui.window.upcast_ref(), "/tmp/spotlight-compact-small.png");
                let settings = test_settings_window();
                capture_test_window(&settings, "/tmp/spotlight-window-small.png");
                test_named_button(&settings, "interface-reset").emit_clicked();
                test_named_button(&settings, "interface-apply").emit_clicked();
                settings.close();
                println!(
                    "Interface UI passed: draft/apply, expanded and compact geometry, saved mode and scale, reset, small layout, hover rendering"
                );
                ui.window.application().unwrap().quit();
                return glib::ControlFlow::Break;
            }
            _ => unreachable!(),
        }
        phase += 1;
        glib::ControlFlow::Continue
    });
}

fn assert_clean_scroll_edge(window: &gtk::Window, scroll: &gtk::ScrolledWindow, path: &str) {
    // Check the formerly visible undershoot border in an empty part of the view.
    let image = gtk::gdk_pixbuf::Pixbuf::from_file(path).unwrap();
    let bytes = image.read_pixel_bytes();
    let bounds = scroll.compute_bounds(window).unwrap();
    let x = (image.width() - 90) as usize;
    let top = bounds.y().round() as usize;
    let stride = image.rowstride() as usize;
    let channels = image.n_channels() as usize;
    let sample = |y: usize| {
        let offset = y * stride + x * channels;
        &bytes[offset..offset + 3]
    };
    for offset in 32..44 {
        assert_eq!(
            sample(top + offset),
            sample(top + 30),
            "Unwanted horizontal border over scrolled content at {path}:{}",
            top + offset
        );
    }
}

fn smoke_scroll(ui: Rc<Ui>) {
    assert!(core::data_dir().starts_with("/tmp"));
    ui.page(Page::Fonts);
    let mut phase = 0;
    glib::timeout_add_local(Duration::from_millis(450), move || {
        let scroll = ui
            .list
            .ancestor(gtk::ScrolledWindow::static_type())
            .unwrap()
            .downcast::<gtk::ScrolledWindow>()
            .unwrap();
        let adjustment = scroll.vadjustment();
        let end = (adjustment.upper() - adjustment.page_size()).max(0.);
        match phase {
            0 => {
                assert!(end > 0., "Font list must scroll");
                if let Some(row) = ui.list.row_at_index(2) {
                    ui.list.select_row(Some(&row));
                    row.grab_focus();
                    ui.search.grab_focus();
                }
                capture_test_window(ui.window.upcast_ref(), "/tmp/spotlight-scroll-top.png");
                adjustment.set_value(end / 2.);
            }
            1 => {
                capture_test_window(ui.window.upcast_ref(), "/tmp/spotlight-scroll-middle.png");
                assert_clean_scroll_edge(
                    ui.window.upcast_ref(),
                    &scroll,
                    "/tmp/spotlight-scroll-middle.png",
                );
                adjustment.set_value(end);
            }
            2 => {
                capture_test_window(ui.window.upcast_ref(), "/tmp/spotlight-scroll-bottom.png");
                assert_clean_scroll_edge(
                    ui.window.upcast_ref(),
                    &scroll,
                    "/tmp/spotlight-scroll-bottom.png",
                );
                adjustment.set_value(0.);
            }
            3 => {
                capture_test_window(ui.window.upcast_ref(), "/tmp/spotlight-scroll-return.png");
                ui.settings();
            }
            4 => {
                let settings = test_settings_window();
                let tabs = test_widget(settings.upcast_ref(), &|w| {
                    w.widget_name() == "settings-pages"
                })
                .unwrap()
                .downcast::<gtk::Stack>()
                .unwrap();
                let scroll = tabs
                    .visible_child()
                    .unwrap()
                    .downcast::<gtk::ScrolledWindow>()
                    .unwrap();
                let adjustment = scroll.vadjustment();
                let end = adjustment.upper() - adjustment.page_size();
                assert!(end > 0., "General settings must scroll");
                adjustment.set_value(end / 2.);
            }
            5 => {
                let settings = test_settings_window();
                capture_test_window(&settings, "/tmp/spotlight-settings-scroll.png");
                let tabs = test_widget(settings.upcast_ref(), &|w| {
                    w.widget_name() == "settings-pages"
                })
                .unwrap()
                .downcast::<gtk::Stack>()
                .unwrap();
                let scroll = tabs
                    .visible_child()
                    .unwrap()
                    .downcast::<gtk::ScrolledWindow>()
                    .unwrap();
                assert_clean_scroll_edge(&settings, &scroll, "/tmp/spotlight-settings-scroll.png");
                settings.close();
                println!(
                    "Scroll UI passed: no ghost border in search or Settings, scrolling down and back up"
                );
                ui.window.application().unwrap().quit();
                return glib::ControlFlow::Break;
            }
            _ => unreachable!(),
        }
        phase += 1;
        glib::ControlFlow::Continue
    });
}

fn smoke_search_tools(ui: Rc<Ui>) {
    assert_eq!(
        std::env::var("SPOTLIGHT_SEARCH_FIXTURES").as_deref(),
        Ok("1")
    );
    assert!(core::data_dir().starts_with("/tmp"));
    ui.search.set_editable(false);
    let shield = gtk::EventControllerKey::new();
    shield.set_propagation_phase(gtk::PropagationPhase::Capture);
    shield.connect_key_pressed(|_, _, _, _| glib::Propagation::Stop);
    ui.window.add_controller(shield);
    // Native pointer movement must not select fixture rows during scripted actions.
    // The hover checks below emit controller signals explicitly.
    let pointer = gtk::EventControllerLegacy::new();
    pointer.set_propagation_phase(gtk::PropagationPhase::Capture);
    pointer.connect_event(|_, event| {
        if matches!(
            event.event_type(),
            gdk::EventType::MotionNotify
                | gdk::EventType::EnterNotify
                | gdk::EventType::LeaveNotify
                | gdk::EventType::ButtonPress
                | gdk::EventType::ButtonRelease
                | gdk::EventType::Scroll
        ) {
            glib::Propagation::Stop
        } else {
            glib::Propagation::Proceed
        }
    });
    ui.window.add_controller(pointer);
    ui.load_recents();
    ui.search.set_text("uuid");
    let mut phase = 0;
    let mut phase_at = std::time::Instant::now();
    let started = phase_at;
    let mut uuid = String::new();
    glib::timeout_add_local(Duration::from_millis(100), move || {
        assert!(
            started.elapsed().as_secs() < 32,
            "Search UI timed out at phase {phase}: {}",
            ui.notice.text()
        );
        if !ui.booster_pending.borrow().is_empty()
            || ui.recents_loading.get()
            || ui.thumbnails_polling.get()
            || phase_at.elapsed() < Duration::from_millis(500)
        {
            return glib::ControlFlow::Continue;
        }
        let first = ui.visible.borrow().first().cloned().unwrap();
        match phase {
            0 => {
                assert!(matches!(&first.action,Action::Copy(s) if s.len()==36));
                uuid = first.title;
                ui.search.set_text("hash abc");
            }
            1 => {
                assert_eq!(
                    first.title,
                    "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
                );
                ui.search.set_text("uuid");
            }
            2 => {
                assert_ne!(first.title, uuid);
                ui.search.set_text("base64 encode café");
            }
            3 => {
                assert_eq!(first.title, "Y2Fmw6k=");
                ui.search.set_text("base64 decode Y2Fmw6k=");
            }
            4 => {
                assert_eq!(first.title, "café");
                ui.search.set_text("tldr tar");
            }
            5 => {
                assert!(
                    ui.visible
                        .borrow()
                        .iter()
                        .filter(|i| i.badge == "Example")
                        .count()
                        >= 6
                );
                assert!(matches!(first.action, Action::Preview { .. }));
                ui.activate();
            }
            6 => {
                let dialog = ui.preview_window.borrow().as_ref().unwrap().clone();
                let text: gtk::TextView =
                    test_widget(dialog.upcast_ref(), &|w| w.is::<gtk::TextView>())
                        .unwrap()
                        .downcast()
                        .unwrap();
                assert!(
                    text.buffer()
                        .text(
                            &text.buffer().start_iter(),
                            &text.buffer().end_iter(),
                            false
                        )
                        .contains("tar -czf")
                );
                capture_test_window(&dialog, "/tmp/spotlight-cheats-preview.png");
                ui.preview_window.borrow_mut().take().unwrap().close();
                ui.search.set_text("recent folders");
            }
            7 => {
                assert!(ui.visible.borrow().iter().filter(|i|i.badge=="Recent").all(|i|matches!(&i.action,Action::Open(uri) if gio::File::for_uri(uri).path().unwrap().is_dir())));
                ui.search.set_text("recent files");
            }
            8 => {
                assert_eq!(first.title, "blue sample.png");
                assert!(first.thumbnail.is_some());
                let row = ui.list.row_at_index(0).unwrap();
                let image: gtk::Image = test_widget(row.upcast_ref(), &|w| w.is::<gtk::Image>())
                    .unwrap()
                    .downcast()
                    .unwrap();
                assert!(
                    image.paintable().is_some_and(|p| p.is::<gdk::Texture>()),
                    "Background image thumbnail decoded"
                );
                capture_test_window(ui.window.upcast_ref(), "/tmp/spotlight-recents-preview.png");
                ui.search.set_text("in: notes rust");
            }
            9 => {
                assert!(first.title.starts_with("story.md:2"), "{}", first.title);
                assert_eq!(
                    ui.visible
                        .borrow()
                        .iter()
                        .filter(|i| i.badge == "Content")
                        .count(),
                    1
                );
                ui.activate();
            }
            10 => {
                ui.preview_window.borrow_mut().take().unwrap().close();
                ui.search.set_text("contacts Danny");
            }
            11 => {
                assert_eq!(first.title, "Danny Example");
                assert!(first.subtitle.contains("danny@example.test"));
                ui.activate();
            }
            12 => {
                ui.preview_window.borrow_mut().take().unwrap().close();
                ui.search.set_text("calendar Rust");
            }
            13 => {
                assert_eq!(first.title, "Rust meetup");
                assert!(first.subtitle.contains("2026-10-20 18:00"));
                ui.activate();
            }
            14 => {
                let dialog = ui.preview_window.borrow_mut().take().unwrap();
                let text: gtk::TextView =
                    test_widget(dialog.upcast_ref(), &|w| w.is::<gtk::TextView>())
                        .unwrap()
                        .downcast()
                        .unwrap();
                assert!(
                    text.buffer()
                        .text(
                            &text.buffer().start_iter(),
                            &text.buffer().end_iter(),
                            false
                        )
                        .contains("FREQ=WEEKLY")
                );
                dialog.close();
                ui.search.set_text("base64 decode a!");
            }
            15 => {
                assert!(first.title.contains("Invalid Base64"));
                ui.page(Page::Root);
                assert!(
                    ui.file_shortcuts.is_visible(),
                    "File shortcuts are pinned above results"
                );
                assert!(
                    !ui.visible
                        .borrow()
                        .iter()
                        .any(|i| matches!(i.badge.as_str(), "File" | "Recent")),
                    "Home suggestions contain no loose files"
                );
                assert!(
                    !*ui.files_ready.borrow() && !*ui.file_loading.borrow(),
                    "Main search does not index files"
                );
                test_named_button(ui.window.upcast_ref(), "recent-files").emit_clicked();
            }
            16 => {
                assert!(
                    *ui.page.borrow() == Page::Recent && !ui.file_shortcuts.is_visible(),
                    "Pinned Recent opens its own view"
                );
                assert!(
                    ui.visible
                        .borrow()
                        .iter()
                        .any(|i| i.title == "blue sample.png")
                );
                assert!(ui.visible.borrow().iter().all(|i| i.badge == "Recent"));
                ui.search.set_text("story.md");
                assert_eq!(
                    ui.visible.borrow().len(),
                    1,
                    "Recent search filters history"
                );
                assert_eq!(ui.visible.borrow()[0].title, "story.md");
                ui.page(Page::Root);
                let saved =
                    std::fs::read_to_string(core::data_dir().join("data.json")).unwrap_or_default();
                assert!(
                    !saved.contains("hash abc") && !saved.contains("contacts Danny"),
                    "Search content is not persisted in usage history"
                );
                let original_apps = ui.apps.borrow().clone();
                let mut exact_app = original_apps.first().unwrap().clone();
                exact_app.id = "fixture:exact-app".into();
                exact_app.title = "Priority Fixture".into();
                let mut partial_app = exact_app.clone();
                partial_app.id = "fixture:partial-app".into();
                partial_app.title = "Priority Fixture App".into();
                *ui.apps.borrow_mut() = vec![partial_app, exact_app];
                let file = core::home().join("Priority Fixture");
                ui.recents.borrow_mut().insert(0, (file.clone(), 1));
                ui.recents
                    .borrow_mut()
                    .insert(1, (core::home().join("Priority Fixture Folder"), 1));
                ui.search.set_text("Priority Fixture");
                {
                    let results = ui.visible.borrow();
                    assert_eq!(
                        results[0].id, "fixture:exact-app",
                        "Best matching app comes first"
                    );
                    assert_eq!(
                        results[1].id, "fixture:partial-app",
                        "Other matching apps remain available"
                    );
                    assert!(
                        results
                            .iter()
                            .all(|i| !matches!(i.badge.as_str(), "File" | "Recent")),
                        "Main search excludes matching files and folders"
                    );
                }
                assert!(
                    ui.file_shortcuts.is_visible(),
                    "Pins stay visible while typing"
                );
            }
            17 => {
                let controllers = ui.list.observe_controllers();
                let motion = (0..controllers.n_items())
                    .find_map(|index| {
                        controllers
                            .item(index)?
                            .downcast::<gtk::EventControllerMotion>()
                            .ok()
                    })
                    .unwrap();
                let hover = |index| {
                    let row = ui.list.row_at_index(index).unwrap();
                    let bounds = row.allocation();
                    motion.emit_by_name::<()>(
                        "motion",
                        &[
                            &20.0f64,
                            &(f64::from(bounds.y()) + f64::from(bounds.height()) / 2.0),
                        ],
                    );
                };
                hover(1);
                assert_eq!(
                    ui.selected().unwrap().id,
                    "fixture:partial-app",
                    "Hover selects the app used by Enter and Open"
                );
                capture_test_window(
                    ui.window.upcast_ref(),
                    "/tmp/spotlight-pinned-files-preview.png",
                );
                test_named_button(ui.window.upcast_ref(), "search-file").emit_clicked();
                assert!(
                    *ui.page.borrow() == Page::Files,
                    "Pinned Search File opens file search"
                );
                assert_eq!(
                    ui.search.text().as_str(),
                    "Priority Fixture",
                    "File search keeps the typed query"
                );
                assert!(!ui.file_shortcuts.is_visible());
                let folder = core::home()
                    .join("Priority Fixture Folder")
                    .to_string_lossy()
                    .into_owned();
                let index = ui
                    .visible
                    .borrow()
                    .iter()
                    .position(|item| item.id == folder)
                    .unwrap();
                ui.list
                    .select_row(ui.list.row_at_index(index as i32).as_ref());
                assert_eq!(
                    ui.selected().unwrap().id,
                    folder,
                    "File search allows selecting folders"
                );
                ui.refresh();
                assert_eq!(
                    ui.selected().unwrap().id,
                    folder,
                    "Background refresh preserves the hovered selection"
                );
            }
            18 => {
                let controllers = ui.list.observe_controllers();
                let motion = (0..controllers.n_items())
                    .find_map(|index| {
                        controllers
                            .item(index)?
                            .downcast::<gtk::EventControllerMotion>()
                            .ok()
                    })
                    .unwrap();
                let folder = core::home()
                    .join("Priority Fixture Folder")
                    .to_string_lossy()
                    .into_owned();
                assert_eq!(
                    ui.selected().unwrap().id,
                    folder,
                    "Selection survives asynchronous result updates"
                );
                ui.list.select_row(ui.list.row_at_index(0).as_ref());
                motion.emit_by_name::<()>("enter", &[&20.0f64, &20.0f64]);
                assert_eq!(
                    ui.selected().unwrap().id,
                    core::home().join("Priority Fixture").to_string_lossy(),
                    "A stationary pointer does not replace keyboard selection after rebuilding rows"
                );
                let index = ui
                    .visible
                    .borrow()
                    .iter()
                    .position(|item| item.id == folder)
                    .unwrap();
                let row = ui.list.row_at_index(index as i32).unwrap();
                let bounds = row.allocation();
                motion.emit_by_name::<()>(
                    "motion",
                    &[
                        &20.0f64,
                        &(f64::from(bounds.y()) + f64::from(bounds.height()) / 2.0),
                    ],
                );
                assert_eq!(
                    ui.selected().unwrap().id,
                    folder,
                    "Mouse movement resumes selection after keyboard navigation"
                );
                capture_test_window(ui.window.upcast_ref(), "/tmp/spotlight-hover-preview.png");
                let indexed_only = core::home().join("Search File Only.txt");
                ui.search.set_text(&indexed_only.to_string_lossy());
                assert!(ui.visible.borrow().iter().any(|i| matches!(&i.action, Action::Open(uri) if uri == gio::File::for_path(&indexed_only).uri().as_str())), "Search File accepts full paths to indexed files");
                assert!(
                    ui.file_items("Search File Only", true).is_empty(),
                    "Recent excludes files that have never been opened"
                );
                ui.page(Page::Root);
                ui.search.set_text("Priority Fixture App");
                assert_eq!(
                    ui.selected().unwrap().id,
                    "fixture:partial-app",
                    "New search selects its top result"
                );
                ui.settings();
                let settings = gtk::Window::list_toplevels()
                    .into_iter()
                    .filter_map(|widget| widget.downcast::<gtk::Window>().ok())
                    .find(|window| window.title().as_deref() == Some("Spotlight Settings"))
                    .unwrap();
                let tabs = test_widget(settings.upcast_ref(), &|w| {
                    w.widget_name() == "settings-pages"
                })
                .unwrap()
                .downcast::<gtk::Stack>()
                .unwrap();
                assert_eq!(tabs.pages().n_items(), 5);
                tabs.set_visible_child_name("theme");
                let presets = test_widget(settings.upcast_ref(), &|w| {
                    w.widget_name() == "theme-presets"
                })
                .unwrap()
                .downcast::<gtk::DropDown>()
                .unwrap();
                presets.set_selected(1);
                let apply =
                    test_widget(settings.upcast_ref(), &|w| w.widget_name() == "theme-apply")
                        .unwrap()
                        .downcast::<gtk::Button>()
                        .unwrap();
                apply.emit_clicked();
                assert_eq!(
                    Store::load().unwrap().theme,
                    theme::Theme::preset(1),
                    "Theme preset persists"
                );
                let accent = test_widget(settings.upcast_ref(), &|w| {
                    w.widget_name() == "theme-accent"
                })
                .unwrap()
                .downcast::<gtk::Entry>()
                .unwrap();
                let picker = test_widget(settings.upcast_ref(), &|w| {
                    w.widget_name() == "theme-accent-picker"
                })
                .unwrap()
                .downcast::<gtk::ColorDialogButton>()
                .unwrap();
                picker.set_rgba(&gdk::RGBA::parse("#0088CC").unwrap());
                assert_eq!(
                    accent.text().as_str(),
                    "#0088CC",
                    "Native color picker updates the hex field"
                );
                accent.set_text("invalid");
                apply.emit_clicked();
                assert_eq!(
                    Store::load().unwrap().theme,
                    theme::Theme::preset(1),
                    "Invalid colors do not overwrite the saved theme"
                );
                accent.set_text("#0088CC");
                apply.emit_clicked();
                assert_eq!(Store::load().unwrap().theme.accent, "#0088CC");
                assert_eq!(presets.selected(), 3, "Editing a color selects Custom");
            }
            19 => {
                let settings = gtk::Window::list_toplevels()
                    .into_iter()
                    .filter_map(|widget| widget.downcast::<gtk::Window>().ok())
                    .find(|window| window.title().as_deref() == Some("Spotlight Settings"))
                    .unwrap();
                capture_test_window(&settings, "/tmp/spotlight-theme-light-preview.png");
                capture_test_window(
                    ui.window.upcast_ref(),
                    "/tmp/spotlight-theme-launcher-preview.png",
                );
                let reset =
                    test_widget(settings.upcast_ref(), &|w| w.widget_name() == "theme-reset")
                        .unwrap()
                        .downcast::<gtk::Button>()
                        .unwrap();
                reset.emit_clicked();
                let apply =
                    test_widget(settings.upcast_ref(), &|w| w.widget_name() == "theme-apply")
                        .unwrap()
                        .downcast::<gtk::Button>()
                        .unwrap();
                apply.emit_clicked();
                assert_eq!(
                    Store::load().unwrap().theme,
                    theme::Theme::default(),
                    "Reset restores the default colors"
                );
                settings.close();
                ui.settings();
            }
            20 => {
                let settings = gtk::Window::list_toplevels()
                    .into_iter()
                    .filter_map(|widget| widget.downcast::<gtk::Window>().ok())
                    .find(|window| window.title().as_deref() == Some("Spotlight Settings"))
                    .unwrap();
                let tabs = test_widget(settings.upcast_ref(), &|w| {
                    w.widget_name() == "settings-pages"
                })
                .unwrap()
                .downcast::<gtk::Stack>()
                .unwrap();
                tabs.set_visible_child_name("theme");
            }
            21 => {
                let settings = gtk::Window::list_toplevels()
                    .into_iter()
                    .filter_map(|widget| widget.downcast::<gtk::Window>().ok())
                    .find(|window| window.title().as_deref() == Some("Spotlight Settings"))
                    .unwrap();
                let background = test_widget(settings.upcast_ref(), &|w| {
                    w.widget_name() == "theme-background"
                })
                .unwrap()
                .downcast::<gtk::Entry>()
                .unwrap();
                assert_eq!(
                    background.text().as_str(),
                    theme::Theme::default().background,
                    "Reopened Settings loads saved colors"
                );
                capture_test_window(&settings, "/tmp/spotlight-theme-dark-preview.png");
                settings.close();
                ui.search.set_text("walkthrough");
                let help = ui
                    .visible
                    .borrow()
                    .iter()
                    .find(|item| item.id == "walkthrough")
                    .unwrap()
                    .clone();
                ui.launch(help);
            }
            22 => {
                let settings = test_settings_window();
                let tabs = test_widget(settings.upcast_ref(), &|w| {
                    w.widget_name() == "settings-pages"
                })
                .unwrap()
                .downcast::<gtk::Stack>()
                .unwrap();
                assert_eq!(
                    tabs.visible_child_name().as_deref(),
                    Some("guide"),
                    "Search opens the walkthrough tab"
                );
                let progress = test_widget(settings.upcast_ref(), &|w| {
                    w.widget_name() == "guide-progress"
                })
                .unwrap()
                .downcast::<gtk::Label>()
                .unwrap();
                assert!(progress.text().contains("1 of "));
                let back = test_named_button(&settings, "guide-back");
                assert!(!back.is_sensitive());
                test_named_button(&settings, "guide-next").emit_clicked();
                assert!(progress.text().contains("2 of "));
                back.emit_clicked();
                assert!(progress.text().contains("1 of "));
            }
            23 => {
                let settings = test_settings_window();
                capture_test_window(&settings, "/tmp/spotlight-guide-preview.png");
                test_named_button(&settings, "guide-try").emit_clicked();
                assert!(
                    !ui.search.text().is_empty(),
                    "App example fills the search without launching an app"
                );
                ui.settings_at(2);
                let settings = test_settings_window();
                let next = test_named_button(&settings, "guide-next");
                next.emit_clicked();
                next.emit_clicked();
                assert!(
                    !test_named_button(&settings, "guide-try").is_visible(),
                    "Shortcut step has no example action"
                );
                next.emit_clicked();
                test_named_button(&settings, "guide-try").emit_clicked();
                assert_eq!(ui.search.text().as_str(), "2+3*4");
                assert_eq!(ui.visible.borrow()[0].title, "14");
                ui.settings_at(2);
            }
            24 => {
                let settings = test_settings_window();
                let progress = test_widget(settings.upcast_ref(), &|w| {
                    w.widget_name() == "guide-progress"
                })
                .unwrap()
                .downcast::<gtk::Label>()
                .unwrap();
                assert!(
                    progress.text().contains("4 of "),
                    "Guide resumes after trying an example"
                );
                let next = test_named_button(&settings, "guide-next");
                next.emit_clicked();
                next.emit_clicked();
                assert_eq!(next.label().as_deref(), Some("Next"));
                test_named_button(&settings, "guide-try").emit_clicked();
                let tabs = test_widget(settings.upcast_ref(), &|w| {
                    w.widget_name() == "settings-pages"
                })
                .unwrap()
                .downcast::<gtk::Stack>()
                .unwrap();
                assert_eq!(
                    tabs.visible_child_name().as_deref(),
                    Some("theme"),
                    "Theme topic opens Theme settings"
                );
                tabs.set_visible_child_name("guide");
                let chooser: gtk::DropDown = test_widget(settings.upcast_ref(), &|w| {
                    w.widget_name() == "guide-topics"
                })
                .unwrap()
                .downcast()
                .unwrap();
                let count = chooser.model().unwrap().n_items();
                assert!(count >= 40, "Guide covers the full feature catalog");
                chooser.set_selected(count - 1);
                assert_eq!(next.label().as_deref(), Some("Start searching"));
                next.emit_clicked();
                assert_eq!(ui.search.text().as_str(), "");
                assert!(*ui.page.borrow() == Page::Root);
                assert_eq!(
                    ui.guide_step.get(),
                    0,
                    "Completed guide restarts from the beginning"
                );
                ui.settings_at(3);
            }
            25 => {
                let settings = test_settings_window();
                let tabs = test_widget(settings.upcast_ref(), &|w| {
                    w.widget_name() == "settings-pages"
                })
                .unwrap()
                .downcast::<gtk::Stack>()
                .unwrap();
                assert_eq!(tabs.visible_child_name().as_deref(), Some("about"));
                let version = test_widget(settings.upcast_ref(), &|w| {
                    w.widget_name() == "about-version"
                })
                .unwrap()
                .downcast::<gtk::Label>()
                .unwrap();
                assert_eq!(
                    version.text().as_str(),
                    concat!("Version ", env!("CARGO_PKG_VERSION"))
                );
                let logo = test_widget(settings.upcast_ref(), &|w| w.widget_name() == "about-logo")
                    .unwrap();
                assert!(logo.is_mapped(), "About logo is visible");
                capture_test_window(&settings, "/tmp/spotlight-about-preview.png");
            }
            26 => {
                let settings = test_settings_window();
                capture_test_window(&settings, "/tmp/spotlight-about-animation-preview.png");
                let tabs = test_widget(settings.upcast_ref(), &|w| {
                    w.widget_name() == "settings-pages"
                })
                .unwrap()
                .downcast::<gtk::Stack>()
                .unwrap();
                // Exercise the actual navigation buttons as well as programmatic guide links.
                let navigation = test_widget(settings.upcast_ref(), &|w| {
                    w.widget_name() == "settings-navigation"
                })
                .unwrap();
                let general = test_widget(&navigation, &|w| {
                    w.clone().downcast::<gtk::ToggleButton>().is_ok_and(|b| {
                        test_widget(b.upcast_ref(), &|child| {
                            child
                                .clone()
                                .downcast::<gtk::Label>()
                                .is_ok_and(|label| label.text() == "General")
                        })
                        .is_some()
                    })
                })
                .unwrap()
                .downcast::<gtk::ToggleButton>()
                .unwrap();
                general.set_active(true);
                assert_eq!(tabs.visible_child_name().as_deref(), Some("general"));
            }
            27 => {
                let settings = test_settings_window();
                capture_test_window(&settings, "/tmp/spotlight-settings-general-preview.png");
                settings.close();
                println!(
                    "Search UI passed: pinned Search File and Recent views, clean main search, query transfer, flat settings navigation, About logo and build version, walkthrough navigation, examples, resume and completion, Settings theme tab, saved presets and custom colors, validation and reset, app and folder hover selection, refresh preservation, keyboard/mouse selection, UUID regeneration, hash/Base64 vectors, inline cheat sheets, actual XDG recency and folders, async image thumbnails, real ripgrep content results, local PIM previews, invalid input, and private usage history"
                );
                ui.window.application().unwrap().quit();
                return glib::ControlFlow::Break;
            }
            _ => unreachable!(),
        }
        phase += 1;
        phase_at = std::time::Instant::now();
        glib::ControlFlow::Continue
    });
}
fn test_settings_window() -> gtk::Window {
    gtk::Window::list_toplevels()
        .into_iter()
        .filter_map(|widget| widget.downcast::<gtk::Window>().ok())
        .find(|window| {
            window.title().as_deref() == Some("Spotlight Settings") && window.is_visible()
        })
        .unwrap()
}
fn test_named_button(window: &gtk::Window, name: &str) -> gtk::Button {
    test_widget(window.upcast_ref(), &|widget| widget.widget_name() == name)
        .unwrap()
        .downcast::<gtk::Button>()
        .unwrap()
}
fn smoke_boosters(ui: Rc<Ui>) {
    // Keep typing in the real desktop from changing the isolated fixture query.
    ui.search.set_editable(false);
    let shield = gtk::EventControllerKey::new();
    shield.set_propagation_phase(gtk::PropagationPhase::Capture);
    shield.connect_key_pressed(|_, _, _, _| glib::Propagation::Stop);
    ui.window.add_controller(shield);
    assert_eq!(
        std::env::var("SPOTLIGHT_TEST_TOOLS").as_deref(),
        Ok("1"),
        "Run tests/boosters_smoke.py with isolated CLI fixtures"
    );
    assert!(core::data_dir().starts_with("/tmp"));
    ui.store.borrow_mut().snippets.push(TextItem {
        name: "Signature".into(),
        trigger: ";sig".into(),
        value: "Regards, Danny".into(),
    });
    ui.save();
    ui.search.set_text("note café ;sig");
    ui.search.set_position(-1);
    assert!(ui.expand_search_snippet(gdk::Key::Tab));
    assert_eq!(ui.search.text(), "note café Regards, Danny");
    let text = gtk::TextView::new();
    ui.snippet_text_keys(&text);
    text.buffer().set_text(";sig");
    let controllers = text.observe_controllers();
    let keys = (0..controllers.n_items())
        .find_map(|i| {
            controllers
                .item(i)?
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
        "Regards, Danny"
    );
    ui.toggle_desktop_snippets();
    assert!(
        std::fs::read_to_string(snippets::config_path())
            .unwrap()
            .contains(";sig")
    );
    ui.toggle_desktop_snippets();
    assert!(
        !std::fs::read_to_string(snippets::config_path())
            .unwrap()
            .contains(";sig")
    );
    let mut child = Command::new("sleep").arg("40").spawn().unwrap();
    let pid = child.id();
    ui.search.set_text("define test");
    let mut phase = 0;
    let started = std::time::Instant::now();
    glib::timeout_add_local(Duration::from_millis(100), move || {
        assert!(
            started.elapsed().as_secs() < 35,
            "Booster UI test timed out at phase {phase}: {}",
            ui.notice.text()
        );
        if ui.booster_busy.get() || !ui.booster_pending.borrow().is_empty() {
            return glib::ControlFlow::Continue;
        }
        let first = ui.visible.borrow().first().cloned().unwrap();
        match phase {
            0 => {
                assert!(
                    matches!(first.action, Action::Copy(_)),
                    "Dictionary row: {}",
                    first.title
                );
                assert!(first.subtitle.contains("noun"));
                ui.search.set_text("docker web");
            }
            1 => {
                assert!(first.title.starts_with("Stop web"), "{}", first.title);
                ui.activate();
            }
            2 => {
                assert!(first.title.starts_with("Start web"), "{}", first.title);
                ui.activate();
            }
            3 => {
                assert!(first.title.starts_with("Stop web"));
                ui.search.set_text("podman db");
            }
            4 => {
                assert!(first.title.starts_with("Start db"));
                ui.activate();
            }
            5 => {
                assert!(first.title.starts_with("Stop db"));
                ui.search.set_text("git sptlt");
            }
            6 => {
                assert!(
                    ui.visible
                        .borrow()
                        .iter()
                        .any(|i| matches!(i.action, Action::Open(_))),
                    "Fuzzy repository match"
                );
                ui.search.set_text("gh repo view owner/repo");
            }
            7 => {
                assert!(matches!(
                    first.action,
                    Action::Booster(boosters::Operation::ViewRemote(_))
                ));
                ui.activate();
            }
            8 => {
                assert!(ui.notice.text().contains("Opened repository"));
                ui.search
                    .set_text("git clone https://example.com/owner/new-repo.git");
            }
            9 => {
                assert!(matches!(
                    first.action,
                    Action::Booster(boosters::Operation::Clone(_))
                ));
                ui.activate();
            }
            10 => {
                assert!(core::home().join("Projects/new-repo/.git").exists());
                ui.search.set_text(&format!("kill {pid}"));
            }
            11 => {
                assert!(
                    matches!(first.action, Action::Booster(boosters::Operation::Terminate { pid: p, .. }) if p == pid)
                );
                ui.activate();
            }
            12 => {
                assert!(child.try_wait().unwrap().is_some());
                assert_eq!(first.title, "No matching processes");
                ui.search.set_text("define missing");
            }
            13 => {
                assert!(first.title.contains("No definition found"));
                // A delayed old lookup must never replace a newer query.
                ui.search.set_text("define slow");
            }
            14 => unreachable!(),
            15 => {
                assert!(ui.search.text().starts_with("define test"));
                assert!(matches!(first.action, Action::Copy(_)));
            }
            _ => {
                println!(
                    "Booster UI passed: dictionary, fuzzy repositories, clone and gh dispatch, Docker/Podman start/stop, selected-child termination, errors, snippet expansion and desktop sync"
                );
                let paint = gtk::WidgetPaintable::new(Some(&ui.window));
                let snapshot = gtk::Snapshot::new();
                paint.snapshot(
                    &snapshot,
                    ui.window.width() as f64,
                    ui.window.height() as f64,
                );
                if let Some(node) = snapshot.to_node()
                    && let Some(renderer) = ui.window.renderer()
                {
                    renderer
                        .render_texture(&node, None)
                        .save_to_png("/tmp/spotlight-boosters-preview.png")
                        .unwrap();
                }
                ui.window.application().unwrap().quit();
                return glib::ControlFlow::Break;
            }
        }
        phase += 1;
        if phase == 14 {
            let weak = Rc::downgrade(&ui);
            glib::timeout_add_local_once(Duration::from_millis(500), move || {
                if let Some(ui) = weak.upgrade() {
                    ui.search.set_text("define test");
                }
            });
            phase = 15;
        }
        glib::ControlFlow::Continue
    });
}
fn smoke_desktop_commands(ui: Rc<Ui>) {
    ui.load_desktop();
    let started = std::time::Instant::now();
    glib::timeout_add_local(Duration::from_millis(100), move || {
        assert!(started.elapsed().as_secs() < 20, "Desktop status timed out");
        if ui.desktop_loading.get() {
            return glib::ControlFlow::Continue;
        }
        let status = ui.desktop_snapshot.borrow().clone();
        assert!(status.speakers.is_ok(), "{:?}", status.speakers);
        assert!(status.mic.is_ok(), "{:?}", status.mic);
        assert!(status.wifi.is_ok(), "{:?}", status.wifi);
        assert!(status.bluetooth.is_ok(), "{:?}", status.bluetooth);
        assert!(status.dnd.is_ok(), "{:?}", status.dnd);
        assert!(status.theme.is_ok(), "{:?}", status.theme);
        ui.page(Page::Windows);
        assert!(ui.window_shortcuts.is_visible());
        assert_eq!(
            ui.visible
                .borrow()
                .iter()
                .filter(|i| matches!(i.action, Action::Window(_)))
                .count(),
            12
        );
        ui.search.set_text("customize shortcuts");
        assert_eq!(ui.visible.borrow()[0].id, "window-shortcuts");
        assert!(
            matches!(&ui.visible.borrow()[0].action, Action::System(args)
            if args == &["kcmshell6", "--args", "kwin", "kcm_keys"])
        );
        ui.page(Page::Root);
        assert!(!ui.window_shortcuts.is_visible());
        ui.search.set_text("window shortcuts");
        assert!(
            ui.visible
                .borrow()
                .iter()
                .any(|i| i.id == "window-shortcuts")
        );
        println!(
            "Window shortcut customization passed: visible button, KWin editor arguments, search in Window Manager and main search, twelve window actions retained"
        );
        for (query, expected) in [
            ("empty trash", desktop::Command::EmptyTrash),
            ("dark mode", desktop::Command::DarkMode),
            ("volume up", desktop::Command::VolumeUp),
            ("volume down", desktop::Command::VolumeDown),
            ("speaker mute", desktop::Command::VolumeMute),
            ("mic up", desktop::Command::MicUp),
            ("mic down", desktop::Command::MicDown),
            ("mic mute", desktop::Command::MicMute),
            ("wifi", desktop::Command::Wifi),
            ("blutooth", desktop::Command::Bluetooth),
            ("do not disturb", desktop::Command::DoNotDisturb),
            ("dnd", desktop::Command::DoNotDisturb),
        ] {
            ui.search.set_text(query);
            assert!(
                ui.visible
                    .borrow()
                    .iter()
                    .any(|i| matches!(i.action, Action::Desktop(c) if c == expected)),
                "Command search: {query}"
            );
        }
        ui.search.set_text("empty trash");
        let index = ui
            .visible
            .borrow()
            .iter()
            .position(|i| matches!(i.action, Action::Desktop(desktop::Command::EmptyTrash)))
            .unwrap();
        ui.list
            .select_row(ui.list.row_at_index(index as i32).as_ref());
        ui.activate();
        assert!(
            !ui.desktop_busy.get(),
            "Trash must not empty before confirmation"
        );
        let dialog = ui.trash_dialog.borrow().as_ref().unwrap().clone();
        assert!(dialog.is_modal());
        let cancel: gtk::Button = test_widget(dialog.upcast_ref(), &|widget| {
            widget
                .clone()
                .downcast::<gtk::Button>()
                .is_ok_and(|button| button.label().as_deref() == Some("Cancel"))
        })
        .unwrap()
        .downcast()
        .unwrap();
        cancel.emit_clicked();
        assert!(ui.trash_dialog.borrow().is_none());
        assert!(
            !ui.desktop_busy.get(),
            "Cancel must not start the trash command"
        );
        println!(
            "Desktop controls UI passed: all eleven commands searchable, live speaker/microphone/Wi-Fi/Bluetooth/DND/theme status, modal Trash confirmation and safe cancellation"
        );
        ui.window.application().unwrap().quit();
        glib::ControlFlow::Break
    });
}
fn smoke_screen_tools(ui: Rc<Ui>) {
    glib::timeout_add_local_once(Duration::from_millis(500), move || {
        for query in ["measure", "ruler", "screen measurement", "mesurment"] {
            ui.search.set_text(query);
            assert!(
                ui.visible
                    .borrow()
                    .iter()
                    .any(|i| matches!(i.action, Action::MeasureScreen)),
                "Measurement search: {query}"
            );
        }
        ui.measuring_screen.set(true);
        ui.window.set_visible(false);
        let image =
            gtk::gdk_pixbuf::Pixbuf::new(gtk::gdk_pixbuf::Colorspace::Rgb, false, 8, 1600, 900)
                .unwrap();
        image.fill(0x303946ff);
        ui.finish_measurement(Ok(Some(image)));
        let ruler = ui.measurement_window.borrow().as_ref().unwrap().clone();
        glib::timeout_add_local_once(Duration::from_millis(700), move || {
            assert!(ruler.window.is_fullscreen());
            let w = ruler.area.width() as f64;
            let h = ruler.area.height() as f64;
            let scale = (w / 1600.).min(h / 900.);
            let x = (w - 1600. * scale) / 2. + 100. * scale;
            let y = (h - 900. * scale) / 2. + 250. * scale;
            ruler.drag.emit_by_name::<()>("drag-begin", &[&x, &y]);
            ruler
                .drag
                .emit_by_name::<()>("drag-update", &[&(300. * scale), &(400. * scale)]);
            ruler
                .drag
                .emit_by_name::<()>("drag-end", &[&(300. * scale), &(400. * scale)]);
            assert_eq!(ruler.readout.text(), "300 × 400 px · distance 500.0 px");
            assert!(ruler.copy.is_sensitive());
            let paint = gtk::WidgetPaintable::new(Some(&ruler.window));
            let snapshot = gtk::Snapshot::new();
            paint.snapshot(&snapshot, w, h);
            if let Some(node) = snapshot.to_node() {
                ruler
                    .window
                    .renderer()
                    .unwrap()
                    .render_texture(&node, None)
                    .save_to_png("/tmp/spotlight-measure-preview.png")
                    .unwrap();
            }
            ruler.copy.emit_clicked();
            ui.window.clipboard().read_text_async(None::<&gio::Cancellable>, move |result| {
                assert_eq!(result.unwrap().as_deref(), Some("300 × 400 px · distance 500.0 px"));
                ruler.window.close();
                assert!(!ui.measuring_screen.get());
                assert!(ui.measurement_window.borrow().is_none());
                assert!(ui.window.is_visible());
                ui.finish_measurement(Ok(None));
                assert!(ui.notice.text().contains("cancelled"));
                println!("Measurement UI passed: search, fullscreen, scaled drag, width/height/distance, real clipboard, close and cancellation");
                for query in ["caffeinate", "caffinate", "keep awake"] {
                    ui.search.set_text(query);
                    assert!(ui.visible.borrow().iter().any(|i| matches!(i.action, Action::Caffeinate)), "Caffeinate search: {query}");
                }
                ui.toggle_caffeinate();
                assert!(ui.caffeinate.borrow().is_some(), "{}", ui.notice.text());
                ui.window.set_visible(false);
                // PowerDevil deliberately waits five seconds before enforcing an inhibition.
                glib::timeout_add_local_once(Duration::from_millis(6000), move || {
                    let bus = gio::bus_get_sync(gio::BusType::Session, None::<&gio::Cancellable>).unwrap();
                    let check = || {
                        bus.call_sync(Some("org.kde.Solid.PowerManagement"),
                            "/org/kde/Solid/PowerManagement/PolicyAgent", "org.kde.Solid.PowerManagement.PolicyAgent",
                            "ListInhibitions", None, None, gio::DBusCallFlags::NONE, 3000, None::<&gio::Cancellable>)
                            .unwrap().get::<(std::collections::HashMap<String, String>,)>().unwrap().0
                            .values().any(|reason| reason.contains("Spotlight Caffeinate"))
                    };
                    assert!(check(), "KDE must have a real active Caffeinate inhibition while the launcher is hidden");
                    for policy in [1u32, 4u32] {
                        let result = bus.call_sync(Some("org.kde.Solid.PowerManagement"),
                            "/org/kde/Solid/PowerManagement/PolicyAgent", "org.kde.Solid.PowerManagement.PolicyAgent",
                            "HasInhibition", Some(&(policy,).to_variant()), None, gio::DBusCallFlags::NONE, 3000, None::<&gio::Cancellable>).unwrap();
                        assert!(result.get::<(bool,)>().unwrap().0, "Sleep and screen power saving must both be inhibited");
                    }
                    ui.toggle_caffeinate();
                    assert!(ui.caffeinate.borrow().is_none(), "{}", ui.notice.text());
                    glib::timeout_add_local_once(Duration::from_millis(600), move || {
                        let result = bus.call_sync(Some("org.kde.Solid.PowerManagement"),
                            "/org/kde/Solid/PowerManagement/PolicyAgent", "org.kde.Solid.PowerManagement.PolicyAgent",
                            "ListInhibitions", None, None, gio::DBusCallFlags::NONE, 3000, None::<&gio::Cancellable>).unwrap();
                        let entries = result.get::<(std::collections::HashMap<String, String>,)>().unwrap().0;
                        assert!(!entries.values().any(|reason| reason.contains("Spotlight Caffeinate")), "KDE power saving must be restored");
                        println!("Caffeinate UI passed: search, real KDE power inhibition while hidden, toggle off, released inhibition");
                        ui.window.application().unwrap().quit();
                    });
                });
            });
        });
    });
}
fn smoke_measure_live(ui: Rc<Ui>) {
    ui.measure_screen();
    let started = std::time::Instant::now();
    glib::timeout_add_local(Duration::from_millis(300), move || {
        if let Some(ruler) = ui.measurement_window.borrow().as_ref().cloned() {
            if ruler.area.width() == 0 {
                return glib::ControlFlow::Continue;
            }
            println!(
                "Live screenshot portal passed: fullscreen ruler is {} × {}",
                ruler.area.width(),
                ruler.area.height()
            );
            ruler
                .drag
                .emit_by_name::<()>("drag-begin", &[&320f64, &360f64]);
            ruler
                .drag
                .emit_by_name::<()>("drag-end", &[&600f64, &400f64]);
            let weak = Rc::downgrade(&ui);
            glib::timeout_add_local_once(Duration::from_millis(700), move || {
                let paint = gtk::WidgetPaintable::new(Some(&ruler.window));
                let snapshot = gtk::Snapshot::new();
                paint.snapshot(
                    &snapshot,
                    ruler.window.width() as f64,
                    ruler.window.height() as f64,
                );
                if let Some(node) = snapshot.to_node() {
                    ruler
                        .window
                        .renderer()
                        .unwrap()
                        .render_texture(&node, None)
                        .save_to_png("/tmp/spotlight-measure-live.png")
                        .unwrap();
                }
                ruler.window.close();
                if let Some(ui) = weak.upgrade() {
                    ui.window.application().unwrap().quit();
                }
            });
            return glib::ControlFlow::Break;
        }
        assert!(
            ui.measuring_screen.get(),
            "Live screen capture failed: {}",
            ui.notice.text()
        );
        assert!(
            started.elapsed().as_secs() < 45,
            "Screen capture timed out waiting for the desktop portal"
        );
        glib::ControlFlow::Continue
    });
}
fn smoke_colors(ui: Rc<Ui>) {
    ui.page(Page::Colors);
    assert!(
        matches!(ui.visible.borrow()[0].action, Action::PickColor),
        "Empty converter offers color picking"
    );
    ui.finish_color(Ok(Some("#0080FF".into())));
    assert!(*ui.page.borrow() == Page::Colors);
    assert_eq!(ui.visible.borrow().len(), 7, "All color formats offered");
    ui.search.set_text("rgba");
    let expected = "rgba(0, 128, 255, 1)";
    let index = ui
        .visible
        .borrow()
        .iter()
        .position(|entry| matches!(&entry.action, Action::Copy(value) if value == expected))
        .unwrap();
    ui.list
        .select_row(ui.list.row_at_index(index as i32).as_ref());
    ui.activate();
    ui.window.clipboard().read_text_async(None::<&gio::Cancellable>, move |result| {
        assert_eq!(result.unwrap().as_deref(), Some("rgba(0, 128, 255, 1)"), "Chosen format reaches the clipboard");
        ui.page(Page::Root); ui.search.set_text("hsl");
        assert!(ui.visible.borrow().iter().any(|entry| matches!(&entry.action, Action::Copy(value) if value == "hsl(209.882, 100%, 50%)")), "HSL searchable from main bar");
        ui.finish_color(Ok(None));
        assert_eq!(ui.picked_color.borrow().as_deref(), Some("#0080FF"), "Cancellation keeps the selected color");
        ui.search.set_text("color formats");
        assert!(matches!(ui.visible.borrow()[0].action, Action::Page(Page::Colors)));
        ui.activate();
        assert_eq!(ui.visible.borrow().len(), 7, "Formats can be reopened");
        println!("Color format UI passed: picker handoff, seven formats, filtering, actual RGBA clipboard contents, main search, cancellation, reopening");
        ui.window.application().unwrap().quit();
    });
}
fn smoke_fonts(ui: Rc<Ui>) {
    assert!(!ui.fonts.is_empty(), "Installed fonts discovered");
    assert!(
        ui.store.borrow().selected_font.is_none(),
        "Use isolated data for font tests"
    );
    ui.search.set_text("fonts");
    assert!(
        matches!(ui.visible.borrow()[0].action, Action::Page(Page::Fonts)),
        "Fonts command is discoverable"
    );
    ui.activate();
    assert_eq!(*ui.page.borrow() as u8, Page::Fonts as u8);
    if ui.fonts.len() > 60 {
        assert_eq!(ui.visible.borrow().len(), 61);
        ui.list.select_row(ui.list.row_at_index(60).as_ref());
        ui.activate();
        assert!(
            ui.visible.borrow().len() > 61,
            "Browse more installed fonts"
        );
    }
    let family = ui
        .fonts
        .iter()
        .find(|name| name.eq_ignore_ascii_case("DejaVu Sans Mono"))
        .or_else(|| {
            ui.fonts
                .iter()
                .find(|name| name.eq_ignore_ascii_case("Monospace"))
        })
        .unwrap_or(&ui.fonts[0])
        .clone();
    ui.page(Page::Root);
    ui.search.set_text(&format!("font {family}"));
    assert!(matches!(&ui.visible.borrow()[0].action, Action::FontPreview(name) if name == &family));
    ui.activate();
    glib::timeout_add_local_once(Duration::from_millis(300), move || {
        let title = format!("Font Preview · {family}");
        let dialog = ui
            .window
            .application()
            .unwrap()
            .windows()
            .into_iter()
            .find(|window| window.title().as_deref() == Some(title.as_str()))
            .unwrap();
        let input: gtk::Entry =
            test_widget(dialog.upcast_ref(), &|widget| widget.is::<gtk::Entry>())
                .unwrap()
                .downcast()
                .unwrap();
        input.set_text("Custom font preview 123");
        assert!(
            test_widget(dialog.upcast_ref(), &|widget| widget
                .clone()
                .downcast::<gtk::Label>()
                .is_ok_and(|label| label.text() == "Custom font preview 123"))
            .is_some(),
            "Editable preview"
        );
        let button = |label: &str| -> gtk::Button {
            test_widget(dialog.upcast_ref(), &|widget| {
                widget
                    .clone()
                    .downcast::<gtk::Button>()
                    .is_ok_and(|button| button.label().as_deref() == Some(label))
            })
            .unwrap()
            .downcast()
            .unwrap()
        };
        button("Copy Font Name").emit_clicked();
        assert!(
            ui.store.borrow().selected_font.is_none(),
            "Copying does not change the font"
        );
        button("Use in Spotlight").emit_clicked();
        assert_eq!(
            Store::load().unwrap().selected_font.as_deref(),
            Some(family.as_str()),
            "Selected font saved"
        );
        glib::timeout_add_local_once(Duration::from_millis(300), move || {
            let applied = ui
                .search
                .pango_context()
                .font_description()
                .unwrap()
                .family()
                .unwrap()
                .to_string();
            assert!(
                applied.contains(&family),
                "Actual rendered font family: {applied}"
            );
            dialog.close();
            ui.page(Page::Root);
            ui.search.set_text("reset spotlight font");
            assert!(matches!(ui.visible.borrow()[0].action, Action::ResetFont));
            ui.activate();
            assert!(
                Store::load().unwrap().selected_font.is_none(),
                "Default font restored and saved"
            );
            println!(
                "Font UI passed: discovery, pagination, main search, editable preview, copy, apply, actual rendering, saved preference, reset"
            );
            ui.window.application().unwrap().quit();
        });
    });
}
fn smoke_timer_setup(ui: Rc<Ui>) {
    assert!(
        ui.store.borrow().reminders.is_empty() && ui.store.borrow().ringing_reminders.is_empty(),
        "Use isolated empty data for timer setup tests"
    );
    ui.search.set_text("set timer for 5 minutes");
    assert!(matches!(
        ui.visible.borrow()[0].action,
        Action::Schedule(reminder::Draft::Timer(300))
    ));
    ui.activate();
    assert_eq!(Store::load().unwrap().reminders.len(), 1);
    ui.search.set_text("cancel timer");
    ui.activate();
    assert!(Store::load().unwrap().reminders.is_empty());
    for query in ["timer", "set timer", "set a timer"] {
        ui.search.set_text(query);
        assert!(
            matches!(ui.visible.borrow()[0].action, Action::TimerSetup),
            "Timer setup command: {query}"
        );
    }
    ui.activate();
    glib::timeout_add_local_once(Duration::from_millis(300), move || {
        let dialog = ui
            .window
            .application()
            .unwrap()
            .windows()
            .into_iter()
            .find(|window| window.title().as_deref() == Some("Set Timer"))
            .unwrap();
        let spinner = |name: &str| -> gtk::SpinButton {
            test_widget(dialog.upcast_ref(), &|widget| widget.widget_name() == name)
                .unwrap()
                .downcast()
                .unwrap()
        };
        let hours = spinner("timer-hours");
        let minutes = spinner("timer-minutes");
        let seconds = spinner("timer-seconds");
        let start: gtk::Button = test_widget(dialog.upcast_ref(), &|widget| {
            widget
                .clone()
                .downcast::<gtk::Button>()
                .is_ok_and(|button| button.label().as_deref() == Some("Start Timer"))
        })
        .unwrap()
        .downcast()
        .unwrap();
        hours.set_text("0");
        minutes.set_text("0");
        seconds.set_text("0");
        start.emit_clicked();
        assert!(
            ui.store.borrow().reminders.is_empty(),
            "Rejects zero duration"
        );
        assert!(dialog.is_visible());
        seconds.set_text("2");
        start.emit_clicked();
        let saved = Store::load().unwrap();
        assert_eq!(saved.reminders.len(), 1);
        assert!(!saved.reminders[0].alarm);
        assert_eq!(
            saved.reminders[0].title, "Timer · 2s",
            "Uses typed spin-button values"
        );
        ui.window.set_visible(false);
        glib::timeout_add_local_once(Duration::from_secs(4), move || {
            assert!(ui.store.borrow().reminders.is_empty());
            assert_eq!(Store::load().unwrap().ringing_reminders.len(), 1);
            assert!(
                ui.alarm_window.borrow().as_ref().unwrap().is_visible(),
                "Finished timer shows its alert"
            );
            assert!(ui.alarm_repeat.borrow().is_some());
            ui.dismiss_alarms();
            assert!(Store::load().unwrap().ringing_reminders.is_empty());
            assert!(ui.alarm_repeat.borrow().is_none());
            println!(
                "Timer setup UI passed: command aliases, text timers, cancellation, duration picker, zero-duration validation, typed values, hidden expiry, alert, dismissal"
            );
            ui.window.application().unwrap().quit();
        });
    });
}
fn smoke_reminders(ui: Rc<Ui>) {
    assert!(
        ui.store.borrow().reminders.is_empty(),
        "Use an isolated XDG_DATA_HOME for reminder tests"
    );
    ui.search.set_text("timer 2 seconds");
    assert!(matches!(
        ui.visible.borrow()[0].action,
        Action::Schedule(reminder::Draft::Timer(2))
    ));
    ui.activate();
    assert_eq!(Store::load().unwrap().reminders.len(), 1, "Timer saved");
    ui.window.set_visible(false);
    glib::timeout_add_local_once(Duration::from_secs(4), move || {
        assert!(
            ui.store.borrow().reminders.is_empty(),
            "Timer fired while hidden"
        );
        assert!(
            Store::load().unwrap().reminders.is_empty(),
            "Completed timer removed from saved state"
        );
        assert!(
            ui.reminder_clock.borrow().is_none(),
            "No idle timer polling"
        );
        assert_eq!(
            Store::load().unwrap().ringing_reminders.len(),
            1,
            "Unacknowledged alert saved"
        );
        assert!(
            ui.alarm_window.borrow().as_ref().unwrap().is_visible(),
            "Visible timer alert"
        );
        ui.dismiss_alarms();
        assert!(Store::load().unwrap().ringing_reminders.is_empty());
        assert!(ui.alarm_repeat.borrow().is_none());
        ui.window.present();
        ui.search.set_text("alarm 23:59");
        assert!(matches!(
            ui.visible.borrow()[0].action,
            Action::Schedule(reminder::Draft::Alarm {
                hour: 23,
                minute: 59
            })
        ));
        ui.activate();
        let stored = Store::load().unwrap();
        assert_eq!(stored.reminders.len(), 1, "Alarm saved");
        assert!(stored.reminders[0].alarm);
        ui.search.set_text("cancel alarm");
        assert!(matches!(
            ui.visible.borrow()[0].action,
            Action::CancelReminder(_)
        ));
        ui.activate();
        assert!(
            Store::load().unwrap().reminders.is_empty(),
            "Alarm cancellation saved"
        );
        println!(
            "Reminder UI passed: hidden timer expiry, notification, saved state, alarm creation and cancellation, idle scheduler cleanup"
        );
        smoke(Rc::clone(&ui));
    });
}
fn smoke(ui: Rc<Ui>) {
    glib::timeout_add_local_once(Duration::from_millis(500), move || {
        assert!(!ui.apps.borrow().is_empty(), "Application discovery");
        ui.search.set_text("coffee & café");
        let web = ui
            .visible
            .borrow()
            .iter()
            .find(|entry| entry.id == "web")
            .unwrap()
            .clone();
        assert!(web.title.starts_with("Search Google"));
        assert!(
            matches!(&web.action, Action::Open(uri) if uri == "https://www.google.com/search?q=coffee%20%26%20caf%C3%A9")
        );
        assert!(ui.hint.text().contains("Google"));
        for query in ["color picker", "colour", "eyedropper"] {
            ui.search.set_text(query);
            assert!(
                ui.visible
                    .borrow()
                    .iter()
                    .any(|entry| matches!(entry.action, Action::PickColor)),
                "Color picker search: {query}"
            );
        }
        ui.finish_color(Ok(Some("#0080FF".into())));
        ui.refresh();
        assert_eq!(ui.picked_color.borrow().as_deref(), Some("#0080FF"));
        assert!(
            *ui.page.borrow() == Page::Colors,
            "Picked color opens format choices"
        );
        assert_eq!(ui.visible.borrow().len(), 7);
        ui.search.set_text("hex");
        assert!(
            ui.visible
                .borrow()
                .iter()
                .any(|entry| matches!(&entry.action, Action::Copy(value) if value == "#0080FF")),
            "Picked hex available to copy"
        );
        ui.finish_color(Ok(None));
        assert_eq!(
            ui.picked_color.borrow().as_deref(),
            Some("#0080FF"),
            "Cancellation preserves the last color"
        );
        ui.page(Page::Root);
        ui.search.set_text("hsl");
        assert!(ui.visible.borrow().iter().any(|entry| matches!(&entry.action, Action::Copy(value) if value == "hsl(209.882, 100%, 50%)")), "Picked color formats searchable from main bar");
        ui.error("");
        ui.currency.borrow_mut().cache.insert(
            ("USD".into(), "AUD".into()),
            (
                std::time::Instant::now(),
                Ok(currency::Rate {
                    date: "2026-10-15".into(),
                    base: "USD".into(),
                    quote: "AUD".into(),
                    rate: 1.5,
                }),
            ),
        );
        ui.search.set_text("100 USD to AUD");
        assert_eq!(ui.visible.borrow()[0].title, "150.00 AUD");
        assert!(ui.visible.borrow()[0].subtitle.contains("2026-10-15"));
        ui.search.set_text("200 usd in aud");
        assert_eq!(
            ui.visible.borrow()[0].title,
            "300.00 AUD",
            "Reuses rate for a new amount"
        );
        ui.currency.borrow_mut().cache.insert(
            ("AAA".into(), "BBB".into()),
            (
                std::time::Instant::now(),
                Err("Test connection failure".into()),
            ),
        );
        ui.search.set_text("100 AAA to BBB");
        assert_eq!(
            ui.visible.borrow()[0].title,
            "Currency conversion unavailable"
        );
        assert!(matches!(ui.visible.borrow()[0].action, Action::Noop));
        ui.search.set_text("2+3*4");
        assert_eq!(ui.visible.borrow()[0].title, "14");
        ui.search.set_text("10 km to mi");
        assert!(ui.visible.borrow()[0].title.starts_with("6.2137"));
        for (query, expected) in [
            ("smile", "😀"),
            ("penguin", "🐧"),
            ("flag: Australia", "🇦🇺"),
            ("thumbs up: dark skin tone", "👍🏿"),
            ("woman technologist", "👩‍💻"),
            ("coffee", "☕"),
        ] {
            ui.search.set_text(query);
            assert!(
                ui.visible
                    .borrow()
                    .iter()
                    .any(|entry| matches!(&entry.action, Action::Copy(value) if value == expected)),
                "Main search finds emoji: {query}"
            );
        }
        ui.search.set_text("grinning face");
        let emoji_index = ui
            .visible
            .borrow()
            .iter()
            .position(|entry| matches!(&entry.action, Action::Copy(value) if value == "😀"))
            .unwrap();
        ui.list
            .select_row(ui.list.row_at_index(emoji_index as i32).as_ref());
        ui.activate();
        assert_eq!(ui.notice.text(), "Copied to clipboard");
        let previous_usage = ui.store.borrow().usage.clone();
        let previous_favorites = ui.store.borrow().favorites.clone();
        ui.store.borrow_mut().usage.clear();
        ui.store.borrow_mut().favorites.clear();
        ui.store.borrow_mut().usage.insert("emoji:👍".into(), 5);
        ui.page(Page::Emoji);
        assert!(
            matches!(&ui.visible.borrow()[0].action, Action::Copy(value) if value == "👍"),
            "Most-used emoji first"
        );
        ui.store.borrow_mut().favorites.push("emoji:❤️".into());
        ui.refresh();
        assert!(
            matches!(&ui.visible.borrow()[0].action, Action::Copy(value) if value == "❤️"),
            "Favorite emoji first"
        );
        ui.store.borrow_mut().usage = previous_usage;
        ui.store.borrow_mut().favorites = previous_favorites;
        ui.refresh();
        assert_eq!(
            ui.visible.borrow().len(),
            61,
            "First emoji batch plus Show more"
        );
        assert!(
            ui.section
                .text()
                .contains(&ui.emoji_items().len().to_string())
        );
        ui.list.select_row(ui.list.row_at_index(60).as_ref());
        ui.activate();
        assert_eq!(
            ui.visible.borrow().len(),
            ui.emoji_items().len(),
            "Everyday selection fully browsable"
        );
        for (query, expected) in [
            ("penguin", "🐧"),
            ("flag: Australia", "🇦🇺"),
            ("thumbs up: dark skin tone", "👍🏿"),
            ("woman technologist", "👩‍💻"),
            ("red heart", "❤️"),
            ("coffee", "☕"),
        ] {
            ui.search.set_text(query);
            assert!(
                matches!(&ui.visible.borrow()[0].action, Action::Copy(value) if value == expected),
                "Emoji search: {query}"
            );
        }
        ui.search.set_text("eggplant");
        assert!(
            !ui.visible
                .borrow()
                .iter()
                .any(|entry| matches!(&entry.action, Action::Copy(value) if value == "🍆")),
            "Unwanted emoji excluded"
        );
        ui.search.set_text("");
        assert_eq!(
            ui.visible.borrow().len(),
            61,
            "Search resets browsing limit"
        );
        ui.page(Page::Windows);
        assert_eq!(
            ui.visible.borrow().len(),
            13,
            "Window actions and shortcut customization available"
        );
        assert!(
            ui.window_shortcuts.is_visible(),
            "Shortcut button visible in Window Manager"
        );
        ui.search.set_text("customize shortcuts");
        assert_eq!(ui.visible.borrow()[0].id, "window-shortcuts");
        assert!(
            matches!(&ui.visible.borrow()[0].action, Action::System(args)
            if args == &["kcmshell6", "--args", "kwin", "kcm_keys"]),
            "Shortcut editor opens with KWin selected"
        );
        ui.search.set_text("left half");
        assert_eq!(ui.visible.borrow()[0].title, "Left Half");
        ui.page(Page::Files);
        assert!(
            !ui.window_shortcuts.is_visible(),
            "Shortcut button belongs to Window Manager"
        );
        ui.page(Page::Clipboard);
        let checked = Rc::clone(&ui);
        glib::timeout_add_local_once(Duration::from_millis(1000), move || {
            assert!(*checked.files_ready.borrow(), "File index completed");
            assert!(!checked.files.borrow().is_empty(), "Files discovered");
            assert!(
                checked.files.borrow().len() <= 25000,
                "File index stays bounded"
            );
            assert!(
                !checked.notice.is_visible(),
                "Klipper integration did not report an error"
            );
            checked.page(Page::Files);
            let name = checked.files.borrow()[0]
                .file_name()
                .unwrap()
                .to_string_lossy()
                .into_owned();
            checked.search.set_text(&name);
            assert_eq!(
                checked.visible.borrow()[0].title,
                name,
                "Exact file search wins"
            );
            checked.page(Page::Root);
            let indexed_path = checked.files.borrow()[0].clone();
            let indexed_uri = gio::File::for_path(&indexed_path).uri().to_string();
            checked.search.set_text(&name);
            assert!(
                checked.visible.borrow().iter().all(
                    |entry| !matches!(&entry.action, Action::Open(uri) if uri == &indexed_uri)
                ),
                "Main search keeps indexed files inside Search File"
            );
            checked.search.set_text(&indexed_path.to_string_lossy());
            test_named_button(checked.window.upcast_ref(), "search-file").emit_clicked();
            assert!(
                checked
                    .visible
                    .borrow()
                    .iter()
                    .any(|entry| matches!(&entry.action, Action::Open(uri) if uri == &indexed_uri)),
                "Pinned Search File accepts the path typed in main search"
            );
            checked.page(Page::Root);
            assert!(
                !checked
                    .visible
                    .borrow()
                    .iter()
                    .any(|entry| entry.badge == "File"),
                "Empty main search keeps suggestions uncluttered"
            );
            smoke_window_action(checked);
        });
    });
}
fn smoke_window_action(ui: Rc<Ui>) {
    let target = gtk::ApplicationWindow::builder()
        .application(&ui.window.application().unwrap())
        .title("Spotlight window action check")
        .default_width(320)
        .default_height(200)
        .build();
    target.present();
    glib::timeout_add_local_once(Duration::from_millis(400), move || {
        ui.window.present();
        glib::timeout_add_local_once(Duration::from_millis(400), move || {
            assert!(
                target.is_active() || ui.window.is_active(),
                "A test window has focus"
            );
            ui.window_action("Window Maximize");
            glib::timeout_add_local_once(Duration::from_millis(1000), move || {
                assert!(!ui.window.is_visible(), "Launcher hides for window action");
                assert!(target.is_maximized(), "KWin maximized the previous window");
                target.destroy();
                ui.window.present();
                capture_smoke(ui);
            });
        });
    });
}
fn capture_smoke(ui: Rc<Ui>) {
    let currency_screenshot = std::env::args().any(|a| a == "--currency-screenshot");
    if !currency_screenshot {
        ui.page(Page::Root);
        ui.search.set_text("");
    }
    let ui2 = Rc::clone(&ui);
    glib::timeout_add_local_once(Duration::from_millis(300), move || {
        let paint = gtk::WidgetPaintable::new(Some(&ui2.window));
        let snapshot = gtk::Snapshot::new();
        paint.snapshot(
            &snapshot,
            ui2.window.width() as f64,
            ui2.window.height() as f64,
        );
        if let Some(node) = snapshot.to_node()
            && let Some(renderer) = ui2.window.renderer()
        {
            let texture = renderer.render_texture(&node, None);
            texture
                .save_to_png(std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join(
                    if currency_screenshot {
                        "currency-preview.png"
                    } else {
                        "preview.png"
                    },
                ))
                .expect("Save preview");
        }
        if currency_screenshot {
            println!("Saved currency-preview.png");
        } else {
            println!(
                "GUI smoke checks passed: app discovery, calculation, conversion, emoji search, bounded file index, file search, Klipper integration, window action search, KWin maximize, navigation, rendering."
            );
        }
        ui2.window.application().unwrap().quit();
    });
}
fn main() -> glib::ExitCode {
    let enable_startup = std::env::args().any(|a| a == "--autostart");
    let disable_startup = std::env::args().any(|a| a == "--no-autostart");
    if enable_startup || disable_startup {
        let result = if enable_startup && disable_startup {
            Err("Choose --autostart or --no-autostart, not both".into())
        } else {
            autostart::configure(enable_startup)
        };
        return match result {
            Ok(()) => glib::ExitCode::SUCCESS,
            Err(error) => {
                eprintln!("{error}");
                glib::ExitCode::FAILURE
            }
        };
    }
    if std::env::args_os().nth(1).as_deref() == Some(std::ffi::OsStr::new("--wasm-plugin-worker")) {
        return match wasmplugins::worker() {
            Ok(()) => glib::ExitCode::SUCCESS,
            Err(error) => {
                eprintln!("WASM plugin: {error}");
                glib::ExitCode::FAILURE
            }
        };
    }
    if std::env::args().any(|a| a == "--install-shortcut") {
        return match shortcut::install() {
            Ok(()) => glib::ExitCode::SUCCESS,
            Err(e) => {
                eprintln!("{e}");
                glib::ExitCode::FAILURE
            }
        };
    }
    if let Some(action) = std::env::args().find_map(|a| match a.as_str() {
        "--quit" => Some("quit"),
        "--diagnostics" => Some("diagnostics"),
        "--quick-note" => Some("quick-note"),
        _ => None,
    }) {
        let result = (|| -> Result<(), glib::Error> {
            let bus = gio::bus_get_sync(gio::BusType::Session, None::<&gio::Cancellable>)?;
            let args = (
                action,
                Vec::<glib::Variant>::new(),
                std::collections::HashMap::<String, glib::Variant>::new(),
            )
                .to_variant();
            bus.call_sync(
                Some("local.spotlight.Spotlight"),
                "/local/spotlight/Spotlight",
                "org.gtk.Actions",
                "Activate",
                Some(&args),
                None,
                gio::DBusCallFlags::NONE,
                2000,
                None::<&gio::Cancellable>,
            )?;
            Ok(())
        })();
        match result {
            Ok(()) => return glib::ExitCode::SUCCESS,
            Err(_) if action == "quick-note" => {}
            Err(e) => {
                eprintln!("Spotlight is not running: {e}");
                return glib::ExitCode::FAILURE;
            }
        };
    }
    let test = std::env::args().any(|a| a == "--smoke-test");
    if !test && std::env::args().any(|a| a == "--background") {
        // A login entry must not toggle a launcher that is already running.
        let running = gio::bus_get_sync(gio::BusType::Session, None::<&gio::Cancellable>)
            .ok()
            .and_then(|bus| {
                bus.call_sync(
                    Some("org.freedesktop.DBus"),
                    "/org/freedesktop/DBus",
                    "org.freedesktop.DBus",
                    "NameHasOwner",
                    Some(&("local.spotlight.Spotlight",).to_variant()),
                    None,
                    gio::DBusCallFlags::NONE,
                    2000,
                    None::<&gio::Cancellable>,
                )
                .ok()
            })
            .and_then(|reply| reply.get::<(bool,)>())
            .is_some_and(|(owned,)| owned);
        if running {
            return glib::ExitCode::SUCCESS;
        }
    }
    let app = gtk::Application::builder()
        .application_id(if test {
            "local.spotlight.Spotlight.Test"
        } else {
            "local.spotlight.Spotlight"
        })
        .build();
    let ui: Rc<RefCell<Option<Rc<Ui>>>> = Rc::new(RefCell::new(None));
    let quit = gio::SimpleAction::new("quit", None);
    let weak = app.downgrade();
    quit.connect_activate(move |_, _| {
        if let Some(app) = weak.upgrade() {
            app.quit();
        }
    });
    app.add_action(&quit);
    let show = gio::SimpleAction::new("show", None);
    let state = Rc::clone(&ui);
    show.connect_activate(move |_, _| {
        if let Some(ui) = state.borrow().as_ref() {
            ui.page(Page::Root);
            ui.load_desktop();
            ui.window.present();
            ui.search.grab_focus();
        }
    });
    app.add_action(&show);
    let show_alarm = gio::SimpleAction::new("show-alarm", None);
    let state = Rc::clone(&ui);
    show_alarm.connect_activate(move |_, _| {
        if let Some(ui) = state.borrow().as_ref() {
            ui.show_alarm();
        }
    });
    app.add_action(&show_alarm);
    let quick_note = gio::SimpleAction::new("quick-note", None);
    let state = Rc::clone(&ui);
    quick_note.connect_activate(move |_, _| {
        if let Some(ui) = state.borrow().as_ref() {
            ui.window.present();
            ui.quick_note("");
        }
    });
    app.add_action(&quick_note);
    let diagnostics = gio::SimpleAction::new("diagnostics", None);
    let state = Rc::clone(&ui);
    diagnostics.connect_activate(move |_, _| {
        if let Ok(stats) = std::fs::read_to_string("/proc/self/smaps_rollup") {
            for line in stats.lines().filter(|s| {
                s.starts_with("Rss:")
                    || s.starts_with("Pss:")
                    || s.starts_with("Private_Clean:")
                    || s.starts_with("Private_Dirty:")
            }) {
                println!("{line}");
            }
        }
        if let Some(ui) = state.borrow().as_ref() {
            println!(
                "Panel visible: {} · indexed files: {}",
                ui.window.is_visible(),
                ui.files.borrow().len()
            );
        }
    });
    app.add_action(&diagnostics);
    app.connect_activate(move |app| {
        if let Some(ui) = ui.borrow().as_ref() {
            if ui.measuring_screen.get() {
                if let Some(ruler) = ui.measurement_window.borrow().as_ref() {
                    ruler.window.present();
                }
                return;
            }
            if ui.window.is_visible() {
                ui.window.set_visible(false);
            } else {
                ui.page(Page::Root);
                ui.load_desktop();
                ui.window.present();
                ui.search.grab_focus();
            }
            return;
        }
        let built = build(app);
        if test {
            if std::env::args().any(|a| a == "--superpowers-smoke-test") {
                smoke_superpowers(Rc::clone(&built));
            } else if std::env::args().any(|a| a == "--plus-smoke-test") {
                smoke_plus(Rc::clone(&built));
            } else if std::env::args().any(|a| a == "--interface-smoke-test") {
                smoke_interface(Rc::clone(&built));
            } else if std::env::args().any(|a| a == "--scroll-smoke-test") {
                smoke_scroll(Rc::clone(&built));
            } else if std::env::args().any(|a| a == "--search-tools-smoke-test") {
                smoke_search_tools(Rc::clone(&built));
            } else if std::env::args().any(|a| a == "--boosters-smoke-test") {
                smoke_boosters(Rc::clone(&built));
            } else if std::env::args().any(|a| a == "--desktop-controls-smoke-test") {
                smoke_desktop_commands(Rc::clone(&built));
            } else if std::env::args().any(|a| a == "--screen-tools-smoke-test") {
                smoke_screen_tools(Rc::clone(&built));
            } else if std::env::args().any(|a| a == "--measure-live-smoke-test") {
                smoke_measure_live(Rc::clone(&built));
            } else if std::env::args().any(|a| a == "--colors-smoke-test") {
                smoke_colors(Rc::clone(&built));
            } else if std::env::args().any(|a| a == "--fonts-smoke-test") {
                smoke_fonts(Rc::clone(&built));
            } else if std::env::args().any(|a| a == "--timer-setup-smoke-test") {
                smoke_timer_setup(Rc::clone(&built));
            } else if std::env::args().any(|a| a == "--alarm-smoke-test") {
                smoke_alarm(Rc::clone(&built));
            } else if std::env::args().any(|a| a == "--notes-smoke-test") {
                smoke_notes(Rc::clone(&built));
            } else if std::env::args().any(|a| a == "--calendar-smoke-test") {
                smoke_calendar(Rc::clone(&built));
            } else if std::env::args().any(|a| a == "--guide-smoke-test") {
                smoke_guide(Rc::clone(&built));
            } else if std::env::args().any(|a| a == "--folder-open-smoke-test") {
                smoke_folder_open(Rc::clone(&built));
            } else if std::env::args().any(|a| a == "--reminder-smoke-test") {
                smoke_reminders(Rc::clone(&built));
            } else if std::env::args().any(|a| a == "--live-currency-test") {
                smoke_currency(Rc::clone(&built));
            } else {
                smoke(Rc::clone(&built));
            }
        }
        if std::env::args().any(|arg| arg == "--quick-note") {
            built.quick_note("");
        }
        *ui.borrow_mut() = Some(built);
    });
    let lifetime: Rc<RefCell<Option<gio::ApplicationHoldGuard>>> = Rc::new(RefCell::new(None));
    let primary_lifetime = Rc::clone(&lifetime);
    app.connect_startup(move |app| {
        *primary_lifetime.borrow_mut() = Some(app.hold());
    });
    let result = app.run_with_args(&["spotlight"]);
    lifetime.borrow_mut().take();
    result
}

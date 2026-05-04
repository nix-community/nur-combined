use super::UserEvent;
use crate::core::config::TEMPLATE_LABELS;
use crate::daemon::event_sender::EventSender;
use std::collections::HashMap;
use std::sync::{LazyLock, RwLock};
use zbus::zvariant::Value;
use zbus::{fdo::Result, interface};
use crate::core::terminal::log_step;

// DBus Menu Constants
const MENU_OBJECT_PATH: &str = "/MenuBar";

// ID ranges:
//   1        = "Pick Color" (launch)
//   10       = "Edit Config"
//   11       = "Quit"
//   12       = "Toggle HUD"
//   13       = "About"
//   20-22    = separators
//   100-199  = color history (dynamic)
//   200-299  = template selector (dynamic)

pub static DBUS_MENU_REVISION: std::sync::atomic::AtomicU32 = std::sync::atomic::AtomicU32::new(1);

// =============================================================================
// Shared state between zbus tasks and the main loop.
// DBusMenu lives inside a tokio task (zbus server). The main thread cannot
// directly access DBusMenu fields — different thread.
// One RwLock<MenuState> — atomic snapshot of all menu state in one lock.
// Invariant: state is updated only via notify_* functions; get_layout() only reads.
// =============================================================================

/// Consolidated menu state: history, display settings, PNG icon cache.
/// One RwLock instead of five — atomic updates, no ordering concerns.
struct MenuState {
    /// Color history in raw order (newest-first, before any reversal).
    history: Vec<String>,
    /// History reversal flag. Applied on each MenuSnapshot::take().
    reverse_order: bool,
    /// Optional external launcher override for wlroots popup fallback.
    menu_command: Option<Vec<String>>,
    /// Selected format template key (e.g. "hex", "rgb", "hsl").
    selected_template: String,
    /// HUD visibility state (the "Show HUD" checkbox in the menu).
    show_hud: bool,
    /// PNG icon cache for history items: hex → Vec<u8>. Generated on first access,
    /// pruned when history updates remove colors.
    png_cache: HashMap<String, Vec<u8>>,
}

impl MenuState {
    fn new() -> Self {
        Self {
            history: Vec::new(),
            reverse_order: false,
            menu_command: None,
            selected_template: String::new(),
            show_hud: true,
            png_cache: HashMap::new(),
        }
    }
}

static MENU_STATE: LazyLock<RwLock<MenuState>> = LazyLock::new(|| RwLock::new(MenuState::new()));

/// Snapshot of menu state — single source of truth for both dbusmenu and external launchers.
/// Read from caches (not disk), guaranteed consistent.
pub struct MenuSnapshot {
    pub history: Vec<String>,
    pub menu_command: Option<Vec<String>>,
    pub selected_template: String,
    pub show_hud: bool,
}

impl MenuSnapshot {
    /// Atomic snapshot of all menu state under a single read lock.
    pub fn take() -> Self {
        let state = MENU_STATE.read().unwrap();
        let history = if state.reverse_order {
            state.history.iter().rev().cloned().collect()
        } else {
            state.history.clone()
        };
        Self {
            history,
            menu_command: state.menu_command.clone(),
            selected_template: state.selected_template.clone(),
            show_hud: state.show_hud,
        }
    }
}

pub struct DBusMenu {
    proxy: EventSender,
    dynamic_items: RwLock<HashMap<i32, String>>,
}

#[interface(name = "com.canonical.dbusmenu")]
impl DBusMenu {
    //   [Pick Color]
    //   --- separator ---
    //   --- separator ---
    //   --- separator ---
    //   [Show HUD ✓]             ← toggle (ID 12)
    //   --- separator ---
    //   [Edit Config]            ← ID 10
    //   --- separator ---
    //   [Quit]                   ← ID 11
    // get_layout: builds the menu tree on each tray open.
    // Called by the tray manager (KDE, GNOME, ...) on icon click.
    // Rebuilds the full tree each time (dbusmenu has no incremental update support).
    // Reads only from static caches — no disk reads.
    #[allow(clippy::type_complexity)]
    fn get_layout(
        &self,
        _parent_id: i32,
        _recursion_depth: i32,
        _property_names: Vec<String>,
    ) -> Result<(u32, (i32, HashMap<String, Value<'_>>, Vec<Value<'_>>))> {
        let revision = DBUS_MENU_REVISION.load(std::sync::atomic::Ordering::Relaxed);

        // Root Node (Id 0)
        let root_id = 0;
        let mut root_props: HashMap<String, Value> = HashMap::new();
        root_props.insert("children-display".to_string(), Value::from("submenu"));

        let snap = MenuSnapshot::take();
        let mut children = Vec::new();

        // Item 1: "Pick Color"
        let mut item1_props: HashMap<String, Value> = HashMap::new();
        item1_props.insert("label".to_string(), Value::from("Pick Color"));
        item1_props.insert("enabled".to_string(), Value::from(true));
        item1_props.insert("visible".to_string(), Value::from(true));
        item1_props.insert("icon-name".to_string(), Value::from("ie-r"));
        children.push(Value::from((1i32, item1_props, Vec::<Value>::new())));

        // --- SECTION: Color History ---
        let mut next_dynamic_id = 100;
        let mut map = self.dynamic_items.write().unwrap();
        map.clear();

        if !snap.history.is_empty() {
            let mut sep1_props: HashMap<String, Value> = HashMap::new();
            sep1_props.insert("type".to_string(), Value::from("separator"));
            children.push(Value::from((20i32, sep1_props, Vec::<Value>::new())));

            for hex_color in snap.history.iter() {
                let mut props: HashMap<String, Value> = HashMap::new();
                props.insert("label".to_string(), Value::from(hex_color.clone()));
                props.insert("enabled".to_string(), Value::from(true));
                props.insert("visible".to_string(), Value::from(true));

                // PNG from cache (read lock); generate + write lock on miss.
                // MenuSnapshot::take() already released its read lock — no deadlock.
                let png_data = {
                    let state = MENU_STATE.read().unwrap();
                    state.png_cache.get(hex_color.as_str()).cloned()
                }
                .unwrap_or_else(|| {
                    let png = generate_color_png(hex_color);
                    MENU_STATE.write().unwrap().png_cache.insert(hex_color.clone(), png.clone());
                    png
                });
                props.insert("icon-data".to_string(), Value::from(png_data));

                children.push(Value::from((next_dynamic_id, props, Vec::<Value>::new())));
                map.insert(next_dynamic_id, hex_color.clone());
                next_dynamic_id += 1;
            }
        }

        // --- SECTION: Template Selector (radio buttons) ---

        // Separator before templates
        let mut sep_tpl_props: HashMap<String, Value> = HashMap::new();
        sep_tpl_props.insert("type".to_string(), Value::from("separator"));
        children.push(Value::from((23i32, sep_tpl_props, Vec::<Value>::new())));

        for (tpl_id, &(key, label)) in (200i32..).zip(TEMPLATE_LABELS.iter()) {
            let mut props: HashMap<String, Value> = HashMap::new();
            props.insert("label".to_string(), Value::from(label));
            props.insert("enabled".to_string(), Value::from(true));
            props.insert("visible".to_string(), Value::from(true));
            // toggle-type = "radio" → checkmark/dot on the selected item
            props.insert("toggle-type".to_string(), Value::from("radio"));
            // toggle-state: 1 = checked, 0 = unchecked
            let is_selected: i32 = if snap.selected_template == key { 1 } else { 0 };
            props.insert("toggle-state".to_string(), Value::from(is_selected));

            children.push(Value::from((tpl_id, props, Vec::<Value>::new())));
            map.insert(tpl_id, key.to_string());
        }

        // --- SECTION: HUD Toggle ---
        let mut sep_hud_props: HashMap<String, Value> = HashMap::new();
        sep_hud_props.insert("type".to_string(), Value::from("separator"));
        children.push(Value::from((24i32, sep_hud_props, Vec::<Value>::new())));

        let mut hud_props: HashMap<String, Value> = HashMap::new();
        hud_props.insert("label".to_string(), Value::from("Show HUD"));
        hud_props.insert("enabled".to_string(), Value::from(true));
        hud_props.insert("visible".to_string(), Value::from(true));
        hud_props.insert("toggle-type".to_string(), Value::from("checkmark"));
        hud_props.insert(
            "toggle-state".to_string(),
            Value::from(if snap.show_hud { 1i32 } else { 0i32 }),
        );
        children.push(Value::from((12i32, hud_props, Vec::<Value>::new())));

        // --- SECTION: Edit Config ---
        let mut sep2_props: HashMap<String, Value> = HashMap::new();
        sep2_props.insert("type".to_string(), Value::from("separator"));
        children.push(Value::from((21i32, sep2_props, Vec::<Value>::new())));

        let mut edit_props: HashMap<String, Value> = HashMap::new();
        edit_props.insert("label".to_string(), Value::from("Edit Config"));
        edit_props.insert("enabled".to_string(), Value::from(true));
        edit_props.insert("visible".to_string(), Value::from(true));
        edit_props.insert("icon-name".to_string(), Value::from("preferences-system"));
        children.push(Value::from((10i32, edit_props, Vec::<Value>::new())));

        // Item: Homepage
        let mut home_props: HashMap<String, Value> = HashMap::new();
        home_props.insert("label".to_string(), Value::from("Homepage"));
        home_props.insert("enabled".to_string(), Value::from(true));
        home_props.insert("visible".to_string(), Value::from(true));
        home_props.insert("icon-name".to_string(), Value::from("web-browser"));
        children.push(Value::from((14i32, home_props, Vec::<Value>::new())));

        // Item: About
        let mut about_props: HashMap<String, Value> = HashMap::new();
        about_props.insert("label".to_string(), Value::from("About"));
        about_props.insert("enabled".to_string(), Value::from(true));
        about_props.insert("visible".to_string(), Value::from(true));
        about_props.insert("icon-name".to_string(), Value::from("help-about"));
        children.push(Value::from((13i32, about_props, Vec::<Value>::new())));

        // Separator before Quit
        let mut sep3_props: HashMap<String, Value> = HashMap::new();
        sep3_props.insert("type".to_string(), Value::from("separator"));
        children.push(Value::from((22i32, sep3_props, Vec::<Value>::new())));

        // Item: Quit
        let mut quit_props: HashMap<String, Value> = HashMap::new();
        quit_props.insert("label".to_string(), Value::from("Quit"));
        quit_props.insert("enabled".to_string(), Value::from(true));
        quit_props.insert("visible".to_string(), Value::from(true));
        quit_props.insert("icon-name".to_string(), Value::from("application-exit"));
        children.push(Value::from((11i32, quit_props, Vec::<Value>::new())));

        Ok((revision, (root_id, root_props, children)))
    }

    // GetGroupProperties
    fn get_group_properties(
        &self,
        _ids: Vec<i32>,
        _property_names: Vec<String>,
    ) -> Result<Vec<(i32, HashMap<String, Value<'_>>)>> {
        Ok(Vec::new())
    }

    // GetProperty
    fn get_property(&self, _id: i32, _name: String) -> Result<Value<'_>> {
        Ok(Value::from(""))
    }

    // Event
    fn event(&self, id: i32, event_id: String, _data: Value<'_>, _timestamp: u32) -> Result<()> {
        log_step("DBus", &format!("Menu Event: Id={}, Event={}", id, event_id));

        if event_id == "clicked" {
            match id {
                1 => {
                    self.proxy.send(UserEvent::LaunchOverlay(None));
                }
                10 => {
                    self.proxy.send(UserEvent::EditConfig);
                }
                11 => {
                    self.proxy.send(UserEvent::Quit);
                }
                12 => {
                    self.proxy.send(UserEvent::ToggleHUD);
                }
                13 => {
                    self.proxy.send(UserEvent::ShowAbout);
                }
                14 => {
                    self.proxy.send(UserEvent::OpenHomepage);
                }
                _ => {
                    let map = self.dynamic_items.read().unwrap();
                    if let Some(value) = map.get(&id) {
                        if (200..300).contains(&id) {
                            // Template selector: value = template key (e.g. "html")
                            self.proxy.send(UserEvent::SelectTemplate(value.clone()));
                        } else {
                            // Color history: value = hex color
                            self.proxy.send(UserEvent::CopyFromHistory(value.clone()));
                        }
                    }
                }
            }
        }
        Ok(())
    }

    // AboutToShow
    fn about_to_show(&self, _id: i32) -> Result<bool> {
        Ok(false)
    }

    // HIJACK: we abuse this DBus method as a "right-click detected" signal.
    // On wlroots the dbusmenu GTK popup won't render (GTK3 can't popup from
    // layer-shell), so we launch an external menu instead and return empty
    // so the tray host doesn't wait for a popup that will never appear.
    fn about_to_show_group(
        &self,
        _ids: Vec<i32>,
    ) -> Result<(Vec<i32>, Vec<i32>)> {
        if !crate::daemon::rofi_menu::has_native_popup() {
            let proxy = self.proxy.clone();
            tokio::spawn(crate::daemon::rofi_menu::show_menu(proxy));
        }
        Ok((Vec::new(), Vec::new()))
    }

    // Properties

    #[zbus(property)]
    fn version(&self) -> u32 {
        3
    }

    #[zbus(property)]
    fn status(&self) -> &str {
        "normal"
    }
}

impl DBusMenu {
    pub fn new(proxy: EventSender) -> Self {
        let config = crate::core::config::Config::load(true);
        {
            let mut state = MENU_STATE.write().unwrap();
            state.history = config.history.colors;
            state.reverse_order = config.history.reverse_order;
            state.selected_template = config.templates.selected.clone();
            state.show_hud = config.hud.show;
        }

        Self {
            proxy,
            dynamic_items: RwLock::new(HashMap::new()),
        }
    }

    pub fn path() -> &'static str {
        MENU_OBJECT_PATH
    }

    fn sync_state(config: &crate::core::config::Config) {
        let mut state = MENU_STATE.write().unwrap();
        state.history = config.history.colors.clone();
        state.reverse_order = config.history.reverse_order;
        state.menu_command = config.system.menu_command.clone();
        state.selected_template = config.templates.selected.clone();
        state.show_hud = config.hud.show;
    }

    pub fn prime_layout_state(config: &crate::core::config::Config) {
        Self::sync_state(config);
    }

    /// Updates menu state from an already-loaded config and notifies the taskbar.
    /// Accepts a ready config — no disk read (data is current after save()).
    pub fn notify_layout_update(config: &crate::core::config::Config) {
        {
            Self::sync_state(config);
            // Prune PNG cache: remove icons for colors no longer in history.
            // Without this the cache grows unboundedly over long daemon runs.
            // Stale keys are collected separately to avoid borrow conflict with history.
            let mut state = MENU_STATE.write().unwrap();
            let stale: Vec<String> = state.png_cache.keys()
                .filter(|hex| !state.history.contains(hex))
                .cloned()
                .collect();
            for key in stale {
                state.png_cache.remove(&key);
            }
        }
        Self::emit_layout_signal();
    }

    /// Updates only the selected template (without touching history).
    pub fn notify_template_changed(template_key: &str) {
        MENU_STATE.write().unwrap().selected_template = template_key.to_string();
        Self::emit_layout_signal();
    }

    /// Updates only the HUD visibility state.
    pub fn notify_hud_changed(show: bool) {
        MENU_STATE.write().unwrap().show_hud = show;
        Self::emit_layout_signal();
    }

    fn emit_layout_signal() {
        if let Some(conn) = crate::daemon::dbus_tray::DBUS_CONNECTION.get() {
            let new_rev = DBUS_MENU_REVISION.fetch_add(1, std::sync::atomic::Ordering::Relaxed) + 1;
            let conn_cloned = conn.clone();

            tokio::spawn(async move {
                let _ = conn_cloned
                    .emit_signal(
                        Option::<&str>::None,
                        MENU_OBJECT_PATH,
                        "com.canonical.dbusmenu",
                        "LayoutUpdated",
                        &(new_rev, 0i32),
                    )
                    .await;
            });
        }
    }
}

/// Generates a 16x16 PNG dbusmenu icon from a hex color string.
pub fn generate_color_png(hex_color: &str) -> Vec<u8> {
    let mut rgba_u32 = 0xFFFFFFFFu32;
    let s = hex_color.trim_start_matches('#');
    if let Ok(val) = u32::from_str_radix(s, 16) {
        let r = ((val >> 16) & 0xFF) as u8;
        let g = ((val >> 8) & 0xFF) as u8;
        let b = (val & 0xFF) as u8;
        rgba_u32 = u32::from_be_bytes([r, g, b, 255]);
    }

    let size = 16;
    let mut img = image::RgbaImage::new(size, size);
    let r = ((rgba_u32 >> 24) & 0xFF) as u8;
    let g = ((rgba_u32 >> 16) & 0xFF) as u8;
    let b = ((rgba_u32 >> 8) & 0xFF) as u8;

    for x in 0..size {
        for y in 0..size {
            if x == 0 || y == 0 || x == size - 1 || y == size - 1 {
                img.put_pixel(x, y, image::Rgba([128, 128, 128, 255])); // gray border
            } else {
                img.put_pixel(x, y, image::Rgba([r, g, b, 255]));
            }
        }
    }

    let mut cursor = std::io::Cursor::new(Vec::new());
    let _ = img.write_to(&mut cursor, image::ImageFormat::Png);
    cursor.into_inner()
}

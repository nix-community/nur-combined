use super::UserEvent;
use crate::daemon::event_sender::EventSender;
use anyhow::Result;
use std::sync::LazyLock;
use zbus::{Connection, interface};
use crate::core::terminal::{log_step, log_info, log_error};

/// ARGB32 big-endian pixels for IconPixmap — decoded once from an embedded PNG.
/// StatusNotifierItem spec format: a(iiay), each pixel [A, R, G, B].
fn decode_argb_pixmap(png_bytes: &[u8]) -> Vec<(i32, i32, Vec<u8>)> {
    let img = image::load_from_memory(png_bytes)
        .expect("embedded tray icon is valid PNG")
        .to_rgba8();
    let (w, h) = img.dimensions();
    let argb: Vec<u8> = img.pixels().flat_map(|p| [p[3], p[0], p[1], p[2]]).collect();
    vec![(w as i32, h as i32, argb)]
}

/// Monochrome pixmap: alpha from original, all pixels set to the given color (r, g, b).
fn decode_mono_pixmap(png_bytes: &[u8], r: u8, g: u8, b: u8) -> Vec<(i32, i32, Vec<u8>)> {
    let img = image::load_from_memory(png_bytes)
        .expect("embedded tray icon is valid PNG")
        .to_rgba8();
    let (w, h) = img.dimensions();
    let argb: Vec<u8> = img.pixels().flat_map(|p| [p[3], r, g, b]).collect();
    vec![(w as i32, h as i32, argb)]
}

static TRAY_ICON_COLOR: LazyLock<Vec<(i32, i32, Vec<u8>)>> = LazyLock::new(|| {
    decode_argb_pixmap(include_bytes!("../../assets/ie-r-64x64.png"))
});

static TRAY_ICON_WHITE: LazyLock<Vec<(i32, i32, Vec<u8>)>> = LazyLock::new(|| {
    decode_argb_pixmap(include_bytes!("../../assets/ie-r-white-64x64.png"))
});

static TRAY_ICON_BLACK: LazyLock<Vec<(i32, i32, Vec<u8>)>> = LazyLock::new(|| {
    decode_mono_pixmap(include_bytes!("../../assets/ie-r-white-64x64.png"), 30, 30, 30)
});

// DBus Constants
const SERVICE_NAME: &str = "org.kde.StatusNotifierItem.InstantEyedropper";
const OBJECT_PATH: &str = "/StatusNotifierItem";
const WATCHER_SERVICE_NAME: &str = "org.kde.StatusNotifierWatcher";
const WATCHER_OBJECT_PATH: &str = "/StatusNotifierWatcher";
const WATCHER_INTERFACE_NAME: &str = "org.kde.StatusNotifierWatcher";

pub static DBUS_CONNECTION: std::sync::OnceLock<zbus::Connection> = std::sync::OnceLock::new();

/// Last XDG activation token from GNOME Shell (via tray click).
/// Used as parent_window when calling XDG Portal.
pub static LAST_ACTIVATION_TOKEN: std::sync::Mutex<Option<String>> = std::sync::Mutex::new(None);

pub struct DBusTray {
    _handle: tokio::task::JoinHandle<()>,
}

struct TrayItem {
    proxy: EventSender,
}

#[interface(name = "org.kde.StatusNotifierItem")]
impl TrayItem {
    // Properties

    #[zbus(property)]
    fn category(&self) -> &str {
        "ApplicationStatus"
    }

    #[zbus(property)]
    fn id(&self) -> &str {
        "ie-r"
    }

    #[zbus(property)]
    fn title(&self) -> &str {
        "Instant Eyedropper Reborn"
    }

    #[zbus(property)]
    fn status(&self) -> &str {
        "Active"
    }

    // Icon properties
    #[zbus(property)]
    fn icon_name(&self) -> String {
        use crate::core::config::{Config, TrayIcon};
        match Config::load(true).system.tray_icon {
            TrayIcon::Mono      => "ie-r-symbolic".to_string(),
            TrayIcon::Color
            | TrayIcon::MonoWhite
            | TrayIcon::MonoBlack
            | TrayIcon::None => String::new(),
        }
    }

    #[zbus(property)]
    fn icon_theme_path(&self) -> String {
        std::env::current_exe()
            .ok()
            .and_then(|p| p.parent()?.parent().map(|p| p.join("share/icons")))
            .map(|p| p.to_string_lossy().into_owned())
            .unwrap_or_default()
    }

    #[zbus(property)]
    fn icon_pixmap(&self) -> Vec<(i32, i32, Vec<u8>)> {
        use crate::core::config::{Config, TrayIcon};
        match Config::load(true).system.tray_icon {
            TrayIcon::Color     => TRAY_ICON_COLOR.clone(),
            TrayIcon::MonoWhite => TRAY_ICON_WHITE.clone(),
            TrayIcon::MonoBlack  => TRAY_ICON_BLACK.clone(),
            // Empty pixmap forces tray host to use IconName lookup (DE-themed symbolic).
            TrayIcon::Mono | TrayIcon::None => vec![],
        }
    }

    #[zbus(property)]
    fn item_is_menu(&self) -> bool {
        false
    }

    #[zbus(property)]
    fn menu(&self) -> zbus::zvariant::ObjectPath<'static> {
        use crate::daemon::dbus_menu::DBusMenu;
        zbus::zvariant::ObjectPath::from_str_unchecked(DBusMenu::path())
    }

    // Methods for handling clicks

    // Primary click (Left Click) -> Launch Overlay
    fn activate(&self, x: i32, y: i32) {
        log_step("DBus", &format!("Activate (Left Click) at {}, {}", x, y));
        self.proxy.send(UserEvent::LaunchOverlay(Some((x, y))));
    }

    // Secondary click (Right Click) -> Quit / Menu
    fn secondary_activate(&self, _x: i32, _y: i32) {
        // Handled by ContextMenu on wlroots, native dbusmenu on KDE/GNOME.
    }

    fn provide_xdg_activation_token(&self, token: String) {
        log_step("DBus", &format!("ActivationToken: {}", token));
        if let Ok(mut guard) = LAST_ACTIVATION_TOKEN.lock() {
            *guard = Some(token);
        }
    }

    fn scroll(&self, _delta: i32, _orientation: &str) {
        // Ignored
    }

    // ContextMenu — called by wlroots tray hosts (waybar etc.) when Menu="/"
    fn context_menu(&self, _x: i32, _y: i32) {
        log_step("DBus", "ContextMenu → external menu");
        let proxy = self.proxy.clone();
        tokio::spawn(crate::daemon::rofi_menu::show_menu(proxy));
    }

    // Explicit polite shutdown method (used by new instances)
    fn quit(&self) {
        log_info("Received polite Quit request from new instance. Shutting down...");
        self.proxy.send(UserEvent::Quit);
    }

    // Signals (required by spec)
    #[zbus(signal)]
    async fn new_icon(&self, _emitter: zbus::object_server::SignalEmitter<'_>) -> zbus::Result<()> {
        unimplemented!()
    }

    #[zbus(signal)]
    async fn new_attention_icon(
        &self,
        _emitter: zbus::object_server::SignalEmitter<'_>,
    ) -> zbus::Result<()> {
        unimplemented!()
    }

    #[zbus(signal)]
    async fn new_overlay_icon(
        &self,
        _emitter: zbus::object_server::SignalEmitter<'_>,
    ) -> zbus::Result<()> {
        unimplemented!()
    }

    #[zbus(signal)]
    async fn new_menu(&self, _emitter: zbus::object_server::SignalEmitter<'_>) -> zbus::Result<()> {
        unimplemented!()
    }

    #[zbus(signal)]
    async fn new_status(
        &self,
        _emitter: zbus::object_server::SignalEmitter<'_>,
        _status: &str,
    ) -> zbus::Result<()> {
        unimplemented!()
    }

    #[zbus(signal)]
    async fn new_tool_tip(
        &self,
        _emitter: zbus::object_server::SignalEmitter<'_>,
    ) -> zbus::Result<()> {
        unimplemented!()
    }
}

impl DBusTray {
    pub fn new(proxy: EventSender) -> Result<Self> {
        use crate::core::config::{Config, TrayIcon};
        if Config::load(true).system.tray_icon == TrayIcon::None {
            log_step("DBus", "Tray icon disabled (tray_icon = none)");
            return Ok(Self { _handle: tokio::spawn(async {}) });
        }

        let proxy_clone = proxy.clone();

        // 2. Spawn DBus Task
        let handle = tokio::spawn(async move {
            if let Err(e) = Self::run_dbus(proxy_clone).await {
                log_error(&format!("DBus Tray Error: {}", e));
            }
        });

        Ok(Self { _handle: handle })
    }

    async fn run_dbus(proxy: EventSender) -> Result<()> {
        let connection = Connection::session().await?;
        let _ = DBUS_CONNECTION.set(connection.clone());
        connection.request_name(SERVICE_NAME).await?;

        // 1. Create Menu
        use crate::daemon::dbus_menu::DBusMenu;
        let menu_item = DBusMenu::new(proxy.clone());
        connection
            .object_server()
            .at(DBusMenu::path(), menu_item)
            .await?;

        // 2. Create Tray Item
        let tray_item = TrayItem { proxy };

        connection
            .object_server()
            .at(OBJECT_PATH, tray_item)
            .await?;

        // Watcher Registration
        let watcher_proxy: zbus::Proxy<'_> = zbus::Proxy::new(
            &connection,
            WATCHER_SERVICE_NAME,
            WATCHER_OBJECT_PATH,
            WATCHER_INTERFACE_NAME,
        )
        .await?;

        // Try to register immediately — if Waybar hasn't started SNW yet, we don't fail:
        // NameOwnerChanged below catches its appearance and registers us then.
        match watcher_proxy
            .call_method("RegisterStatusNotifierItem", &(SERVICE_NAME,))
            .await
        {
            Ok(_) => log_step("DBus", "StatusNotifierItem registered"),
            Err(e) => log_step("DBus", &format!("Watcher not ready at startup ({e}), will register when it appears")),
        }

        // Tray host (waybar, KDE panel) needs time to discover our SNI and connect
        // its DbusmenuGtkClient to /MenuBar. There's no handshake signal in the
        // dbusmenu protocol, so we wait a fixed delay then emit LayoutUpdated to
        // trigger the host's initial GetLayout call. 300ms is conservative — the
        // host is already running, it just needs to process the registration.
        tokio::time::sleep(std::time::Duration::from_millis(300)).await;
        use crate::daemon::dbus_menu::DBUS_MENU_REVISION;
        let rev = DBUS_MENU_REVISION.load(std::sync::atomic::Ordering::Relaxed);
        let _ = connection
            .emit_signal(
                Option::<&str>::None,
                DBusMenu::path(),
                "com.canonical.dbusmenu",
                "LayoutUpdated",
                &(rev, 0i32),
            )
            .await;
        log_step("DBus", "LayoutUpdated signal emitted");

        // Re-register with StatusNotifierWatcher whenever it restarts (e.g. waybar restart).
        // Without this, ie-r disappears from the tray after the host reloads.
        let dbus_proxy = zbus::fdo::DBusProxy::new(&connection).await?;
        use futures_util::StreamExt;
        let mut name_changes = dbus_proxy.receive_name_owner_changed().await?;
        while let Some(signal) = name_changes.next().await {
            let args = signal.args()?;
            if args.name() == WATCHER_SERVICE_NAME && !args.new_owner().as_deref().unwrap_or("").is_empty() {
                log_step("DBus", "StatusNotifierWatcher reappeared — re-registering");
                let _ = watcher_proxy
                    .call_method("RegisterStatusNotifierItem", &(SERVICE_NAME,))
                    .await;
            }
        }

        Ok(())
    }
}

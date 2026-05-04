#[cfg(unix)]
pub mod dbus_menu;
#[cfg(unix)]
pub mod dbus_tray;
#[cfg(windows)]
pub mod about_win;
pub mod event_sender;
#[cfg(unix)]
pub mod rofi_menu;
#[cfg(windows)]
pub mod tray_win;
pub mod scout;
pub mod timer;

/// Events from the outside world (tray, hotkeys, signals) to the main event loop.
/// Defined here rather than main.rs because all daemon modules and connectors use them.
pub enum UserEvent {
    LaunchOverlay(Option<(i32, i32)>),
    EditConfig,
    ToggleHUD,
    CopyFromHistory(String),
    SelectTemplate(String),
    ShowAbout,
    OpenHomepage,
    Quit,
}

/// Opens the homepage in the default browser.
pub fn open_homepage() {
    #[cfg(unix)]
    let url = "https://instant-eyedropper.com/linux/?ie-r";
    #[cfg(windows)]
    let url = "https://instant-eyedropper.com/?ie-r";

    let _ = open::that(url);
}

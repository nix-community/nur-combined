// ══════════════════════════════════════════════════════════════════════════════
//   1. KWin DBus (silent → interactive retry)
// XDG Desktop Portal — cross-DE single-capture fallback for Wayland.
//
// capture_screen() cascade: KWin DBus → XDG Portal.
// Used as Tier 3 in capture_all_outputs(); the X11 connector goes through
// capture_x11_root() (native XCB) instead.
// ══════════════════════════════════════════════════════════════════════════════

use anyhow::Result;
use image::RgbaImage;
use std::time::Instant;

use crate::core::terminal::{log_step, log_warn, log_info};
use super::{ScreenCapture, rgba_to_capture};

/// Single-capture cascade. Returns one frame the size of the visible virtual
/// desktop (per-output slicing happens on top via splitter heuristic).
///
/// Protocol hierarchy:
///   1. `KWin ScreenShot2 DBus` — Direct inject into compositor (<10ms). KDE Wayland only.
///   2. `XDG Desktop Portal`    — Fallback bus. Cross-DE, but slow (~700ms first init).
pub fn capture_screen(dbus_conn: Option<&zbus::blocking::Connection>) -> Result<ScreenCapture> {
    let start_total = Instant::now();

    // 1. Fast path: KWin DBus (if connection available)
    if let Some(conn) = dbus_conn {
        match super::kwin::capture_screen_dbus(conn) {
            Ok(cap) => {
                log_step("Capture", &format!(
                    "KWin DBus: {}ms ({}x{})",
                    start_total.elapsed().as_millis(),
                    cap.width,
                    cap.height
                ));
                return Ok(cap);
            }
            Err(e) => {
                let e_str = e.to_string();
                let (kind, desc) = e_str.split_once(": ").unwrap_or(("", &e_str));
                log_warn("KWin DBus offline");
                if !kind.is_empty() { log_warn(&format!("   {}:", kind)); }
                log_warn(&format!("   {}", desc));
                log_warn("Switching to Portal...");
            }
        }
    } else {
        log_info("Skipping KWin DBus capture (no connection provided).");
    }

    // 2. XDG Desktop Portal (cross-DE fallback)
    let rt_handle = tokio::runtime::Handle::current();
    let img = rt_handle.block_on(capture_via_portal())
        .map_err(|e| anyhow::anyhow!("All capture methods failed (Portal): {}", e))?;
    log_step("Capture", &format!("XDG Portal: {}ms", start_total.elapsed().as_millis()));
    Ok(rgba_to_capture(&img))
}

/// **XDG Desktop Portal Screenshot**
/// Works on any Wayland DE (GNOME, KDE, Sway, Hyprland...).
/// The first call shows a system "Allow / Deny" dialog.
/// Subsequent calls may be automatic (if the DE remembered the choice).
async fn capture_via_portal() -> Result<RgbaImage> {
    use ashpd::desktop::screenshot::Screenshot;
    use ashpd::{WindowIdentifier, WindowIdentifierType};

    // Clone the token (not take): it is needed twice —
    // 1. here as parent_window for Portal (authorization on GNOME)
    // 2. later in WindowHandler::configure for xdg_activation_v1.activate() (dismisses spinner)
    let token = crate::daemon::dbus_tray::LAST_ACTIVATION_TOKEN
        .lock()
        .ok()
        .and_then(|g| g.clone());

    if let Some(ref t) = token {
        log_step("Portal", &format!("Using activation token: {}", t));
    }

    let identifier = token.map(|t| WindowIdentifier::X11(WindowIdentifierType::Wayland(t)));

    let screenshot = Screenshot::request()
        .interactive(false) // no region selection dialog — full screen
        .identifier(identifier)
        .send()
        .await?
        .response()?;

    let uri = screenshot.uri();
    // URI format: file:///tmp/screenshot.png
    let path = uri.path();

    let img = image::open(path)?.to_rgba8();

    // Remove temporary file created by the portal
    let _ = std::fs::remove_file(path);

    Ok(img)
}

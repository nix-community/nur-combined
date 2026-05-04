// ══════════════════════════════════════════════════════════════════════════════
//   1. KWin DBus (silent → interactive retry)
//   3. Spectacle CLI (last resort, KDE-only)
// XDG Desktop Portal + Spectacle — cross-DE fallback for screen capture.
//
// capture_screen() — cascade:
//   1. KWin DBus (silent → interactive retry)
//   2. XDG Desktop Portal (async, via ashpd)
//   3. Spectacle CLI (last resort, KDE-only)
//
// Used as Tier 3 in capture_all_outputs() and as the only path
// for the X11 connector (capture::capture_screen → portal::capture_screen).
// ══════════════════════════════════════════════════════════════════════════════

use anyhow::{Result, anyhow};
use image::RgbaImage;
use std::fs::File;
use std::io::BufReader;
use std::process::Command;
use std::time::{Duration, Instant};

use crate::core::terminal::{log_step, log_warn, log_info};
use super::{ScreenCapture, rgba_to_capture};

/// **Main Calibre.** Attempts to capture the framebuffer by the fastest available method.
///
/// Protocol hierarchy:
///   1. `KWin ScreenShot2 DBus` — Direct inject into compositor (<10ms). KDE Wayland only.
///   2. `XDG Desktop Portal`    — Fallback bus. Cross-DE, but slow (~700ms first init).
///   3. `Spectacle`             — If even the portal is dead, invoke the external tool (last resort).
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
    match rt_handle.block_on(capture_via_portal()) {
        Ok(img) => {
            log_step("Capture", &format!("XDG Portal: {}ms", start_total.elapsed().as_millis()));
            return Ok(rgba_to_capture(&img));
        }
        Err(e) => {
            log_warn(&format!("Portal failed: {}. Falling back to Spectacle...", e));
        }
    }

    // 3. Last resort: Spectacle (KDE-only)
    capture_via_spectacle()
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

fn capture_via_spectacle() -> Result<ScreenCapture> {
    let output_path = "/tmp/ie-r-capture.png";
    // -m / --current: capture only the monitor under cursor.
    // Without this Spectacle uses XCB on the X11 root window and returns the
    // entire Xinerama bounding box (virtual desktop), which the X11 connector
    // then squishes into a single-monitor window ("double vision" bug).
    // Per-monitor mode matches the launch-monitor window 1:1 — no smoosh.
    let status = match Command::new("spectacle")
        .arg("-b")
        .arg("-n")
        .arg("-m")
        .arg("-o")
        .arg(output_path)
        .status()
    {
        Ok(s) => s,
        Err(e) if e.kind() == std::io::ErrorKind::NotFound => {
            log_warn("spectacle is not installed — last-resort capture path unavailable.");
            log_warn("Install it via your package manager (e.g. `sudo pacman -S spectacle`,");
            log_warn("`apt install kde-spectacle`, `dnf install spectacle`), or ensure that");
            log_warn("xdg-desktop-portal is running so the Portal path succeeds first.");
            return Err(anyhow!("spectacle binary not found in PATH"));
        }
        Err(e) => return Err(anyhow!("failed to spawn spectacle: {}", e)),
    };
    if !status.success() {
        log_warn(&format!("spectacle exited unsuccessfully ({status}) — capture file may be missing"));
    }

    let start_wait = Instant::now();
    let mut image_result: Result<ScreenCapture> = Err(anyhow!("File not found"));
    while start_wait.elapsed() < Duration::from_secs(2) {
        if let Ok(file) = File::open(output_path) {
            let reader = image::ImageReader::new(BufReader::new(file)).with_guessed_format()?;
            if let Ok(dyn_img) = reader.decode() {
                let cap = rgba_to_capture(&dyn_img.to_rgba8());
                log_step("Capture", &format!(
                    "Spectacle: {}ms ({}x{})",
                    start_wait.elapsed().as_millis(), cap.width, cap.height,
                ));
                image_result = Ok(cap);
                break;
            }
        }
        std::thread::sleep(Duration::from_millis(50));
    }

    let _ = std::fs::remove_file(output_path);
    image_result.map_err(|e| anyhow!("All capture methods failed: {}", e))
}

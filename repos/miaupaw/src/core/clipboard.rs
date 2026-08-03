//! The single low-level clipboard primitive.
//!
//! One implementation, two callers: `ColorService`'s cold path (the daemon
//! keeps a cached long-lived handle as its own optimization) and the
//! headless `--clipboard` relay. Keeps the arboard call site from being
//! duplicated without forcing headless to drag in the font-heavy
//! `ColorService`.
//!
//! Linux selection-persistence wrinkle: both X11 and Wayland clipboard
//! protocols require an *owner* process to remain alive to serve content
//! requests. A one-shot CLI exits immediately, so a naive `set_text` loses
//! ownership and the clipboard goes empty.
//!
//! Per-backend strategy:
//!
//! - **X11**: `arboard::SetExtLinux::wait_until` (100ms) — long enough for
//!   any clipboard manager (klipper / parcellite / xsel-daemon) to harvest
//!   via DBus roundtrip, no user-visible delay. Without a manager the
//!   content is still lost — platform contract, not ours.
//!
//! - **Wayland**: shell out to `wl-copy` (from the `wl-clipboard` package).
//!   wl-copy forks a daemon itself and holds the selection — no manager
//!   needed. Falls back to the arboard path if wl-copy isn't installed
//!   (which will fail unless a manager is present — same trade-off as X11).
//!   This is the same auto-detect-external-tool pattern as `pipe_menu`'s
//!   `rofi → wofi → fuzzel` chain.
//!
//! - **Windows**: clipboard is global system state, persists across process
//!   lifetimes by design. No wait, no shell-out.
//!
//! Track-not-build: if anyone ever needs to override the Wayland command
//! (e.g. `wl-clip-persist`), add `system.wayland_clipboard_command` by
//! analogy with `system.menu_command`. Until then, hardcoded `wl-copy`.

use arboard::Clipboard;
#[cfg(unix)]
use arboard::SetExtLinux;
#[cfg(unix)]
use std::time::{Duration, Instant};

/// Set the system clipboard to `text`. `Err(reason)` feeds `RelayOutcome`.
pub fn set_text(text: &str) -> Result<(), String> {
    #[cfg(unix)]
    {
        // Wayland: prefer wl-copy (handles its own daemonization).
        if std::env::var("WAYLAND_DISPLAY").is_ok()
            && let Ok(()) = wl_copy(text) {
                return Ok(());
            }
    }
    let mut cb = Clipboard::new().map_err(|e| e.to_string())?;
    set_text_on(&mut cb, text)
}

#[cfg(unix)]
fn set_text_on(cb: &mut Clipboard, text: &str) -> Result<(), String> {
    cb.set()
        .wait_until(Instant::now() + Duration::from_millis(100))
        .text(text)
        .map_err(|e| e.to_string())
}

#[cfg(windows)]
fn set_text_on(cb: &mut Clipboard, text: &str) -> Result<(), String> {
    cb.set_text(text).map_err(|e| e.to_string())
}

/// Shell out to `wl-copy` (from `wl-clipboard` package). wl-copy reads stdin,
/// forks a background daemon to hold the selection, and exits — meaning by
/// the time `wait()` returns, persistence is already arranged.
#[cfg(unix)]
fn wl_copy(text: &str) -> Result<(), String> {
    use std::io::Write;
    use std::process::{Command, Stdio};

    let mut child = Command::new("wl-copy")
        .stdin(Stdio::piped())
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .spawn()
        .map_err(|e| format!("wl-copy not available: {e}"))?;

    child
        .stdin
        .as_mut()
        .ok_or_else(|| "wl-copy stdin pipe unavailable".to_string())?
        .write_all(text.as_bytes())
        .map_err(|e| format!("wl-copy stdin write failed: {e}"))?;

    let status = child.wait().map_err(|e| format!("wl-copy wait failed: {e}"))?;
    if !status.success() {
        return Err(format!("wl-copy exited with status {}", status.code().unwrap_or(-1)));
    }
    Ok(())
}

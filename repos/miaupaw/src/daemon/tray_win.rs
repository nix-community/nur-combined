//! Win32 system tray icon — Phase 3 connector.
//!
//! Shell_NotifyIconW + TrackPopupMenu in its own thread.
//! Sends UserEvent via EventSender (mpsc channel) to the main daemon loop.
//! Same role as dbus_tray.rs + dbus_menu.rs on Linux.

use std::sync::Arc;
use std::sync::atomic::{AtomicIsize, Ordering};

use anyhow::Result;
use windows::core::PCWSTR;
use windows::Win32::Foundation::*;
use windows::Win32::Graphics::Gdi::*;
use windows::Win32::System::LibraryLoader::GetModuleHandleW;
use windows::Win32::System::Registry::*;
use windows::Win32::UI::Input::KeyboardAndMouse::{ActivateKeyboardLayout, GetKeyboardLayout};
use windows::Win32::UI::Shell::*;
use windows::Win32::UI::WindowsAndMessaging::*;

use super::UserEvent;
use super::event_sender::EventSender;
use crate::core::config::{Config, TrayIcon, TEMPLATE_LABELS};
use crate::core::terminal::{log_step, log_error};

// ══════════════════════════════════════════════════════════════════════════════
// Constants
// ══════════════════════════════════════════════════════════════════════════════

const WM_TRAY_CALLBACK: u32 = WM_APP + 1;
const TRAY_UID: u32 = 1;

// Menu item IDs
// Menu item IDs — mirrors dbus_menu.rs convention
const IDM_PICK_COLOR: u32 = 1;
const IDM_EDIT_CONFIG: u32 = 10;
const IDM_QUIT: u32 = 11;
const IDM_TOGGLE_HUD: u32 = 12;
const IDM_ABOUT: u32 = 13;
const IDM_HOMEPAGE: u32 = 14;
const IDM_AUTOSTART: u32 = 15;
const IDM_HISTORY_BASE: u32 = 100; // 100..109 for color history
const IDM_TEMPLATE_BASE: u32 = 200; // 200..209 for format templates

const AUTOSTART_REG_PATH: &str = r"Software\Microsoft\Windows\CurrentVersion\Run";
const AUTOSTART_REG_VALUE: &str = "ie-r";

// ══════════════════════════════════════════════════════════════════════════════
// Public API
// ══════════════════════════════════════════════════════════════════════════════

/// Win32 system tray icon. Runs Shell_NotifyIconW in its own thread.
/// Dropping this struct posts WM_CLOSE to the hidden window, cleanly exiting
/// the tray thread and removing the icon.
pub struct WinTray {
    thread: Option<std::thread::JoinHandle<()>>,
    hwnd: Arc<AtomicIsize>,
}

impl WinTray {
    pub fn new(sender: EventSender, show_welcome: bool) -> Self {
        let config = Config::load(true);
        if config.system.tray_icon == TrayIcon::None {
            log_step("Tray", "Disabled by config (tray-icon = \"none\")");
            return Self { thread: None, hwnd: Arc::new(AtomicIsize::new(0)) };
        }

        let hwnd_store = Arc::new(AtomicIsize::new(0));
        let hwnd_clone = hwnd_store.clone();

        let thread = std::thread::spawn(move || {
            if let Err(e) = run_tray_thread(sender, hwnd_clone, show_welcome) {
                log_error(&format!("Tray thread failed: {}", e));
            }
        });

        Self {
            thread: Some(thread),
            hwnd: hwnd_store,
        }
    }

    /// Returns the HWND of the hidden tray window.
    pub fn get_hwnd(&self) -> HWND {
        HWND(self.hwnd.load(Ordering::Acquire) as *mut _)
    }
}

impl Drop for WinTray {
    fn drop(&mut self) {
        let raw = self.hwnd.load(Ordering::Acquire);
        if raw != 0 {
            unsafe {
                let hwnd = HWND(raw as *mut _);
                let _ = PostMessageW(hwnd, WM_CLOSE, WPARAM(0), LPARAM(0));
            }
        }
        if let Some(t) = self.thread.take() {
            let _ = t.join();
        }
    }
}

// ══════════════════════════════════════════════════════════════════════════════
// Tray thread
// ══════════════════════════════════════════════════════════════════════════════

/// State stored in GWLP_USERDATA of the hidden tray window.
struct TrayState {
    sender: EventSender,
    hicon: HICON,
    wm_taskbar_created: u32,
}

fn run_tray_thread(sender: EventSender, hwnd_store: Arc<AtomicIsize>, show_welcome: bool) -> Result<()> {
    unsafe {
        // Register for TaskbarCreated — re-add icon if Explorer restarts
        let wm_taskbar_created = RegisterWindowMessageW(windows::core::w!("TaskbarCreated"));

        // Register window class
        let class_name = windows::core::w!("IERTray");
        let wc = WNDCLASSEXW {
            cbSize: std::mem::size_of::<WNDCLASSEXW>() as u32,
            lpfnWndProc: Some(tray_wnd_proc),
            lpszClassName: class_name,
            ..Default::default()
        };
        RegisterClassExW(&wc);

        // Invisible top-level window (serves as owner for the overlay to hide it from taskbar).
        // Unlike HWND_MESSAGE, this can be an owner for visible top-level windows.
        let hwnd = CreateWindowExW(
            WINDOW_EX_STYLE::default(),
            class_name,
            windows::core::w!("IE-R Tray"),
            WINDOW_STYLE::default(), // No WS_VISIBLE
            0, 0, 0, 0,
            None, None, None, None,
        )?;

        hwnd_store.store(hwnd.0 as isize, Ordering::Release);

        // Load icon at the exact tray size — SM_CXSMICON × SM_CYSMICON (16×16 at 96 DPI,
        // scales with system DPI). LoadImageW picks the best-matching size from the ICO.
        // LR_SHARED: handle is owned by the OS (reference-counted) — do NOT DestroyIcon.
        let cx = GetSystemMetrics(SM_CXSMICON);
        let cy = GetSystemMetrics(SM_CYSMICON);
        let hicon = LoadImageW(
            GetModuleHandleW(None).unwrap_or_default(),
            #[allow(clippy::manual_dangling_ptr)]
            PCWSTR(1 as *const u16), // MAKEINTRESOURCEW(1) — matches `1 ICON` in .rc; dangling() gives addr=2, not 1
            IMAGE_ICON,
            cx, cy,
            LR_SHARED,
        ).map(|h| HICON(h.0))
        .unwrap_or_else(|_| LoadIconW(None, IDI_APPLICATION).unwrap_or_default());

        // Store state in window user data
        let state = Box::new(TrayState { sender, hicon, wm_taskbar_created });
        SetWindowLongPtrW(hwnd, GWLP_USERDATA, Box::into_raw(state) as isize);

        // Add tray icon (with retry for slow Explorer startup)
        add_tray_icon(hwnd, hicon, show_welcome);

        // Message pump — blocks until WM_CLOSE/WM_QUIT
        let mut msg = std::mem::zeroed::<MSG>();
        while GetMessageW(&mut msg, None, 0, 0).as_bool() {
            let _ = TranslateMessage(&msg);
            DispatchMessageW(&msg);
        }

        // Cleanup
        remove_tray_icon(hwnd);
        // LR_SHARED icons are owned by the OS — do NOT call DestroyIcon.

        let ptr = GetWindowLongPtrW(hwnd, GWLP_USERDATA) as *mut TrayState;
        if !ptr.is_null() {
            SetWindowLongPtrW(hwnd, GWLP_USERDATA, 0);
            let _ = Box::from_raw(ptr);
        }
        let _ = DestroyWindow(hwnd);
        let _ = UnregisterClassW(class_name, None);
    }
    Ok(())
}

// ══════════════════════════════════════════════════════════════════════════════
// Shell_NotifyIconW
// ══════════════════════════════════════════════════════════════════════════════

unsafe fn add_tray_icon(hwnd: HWND, hicon: HICON, show_welcome: bool) {
    unsafe {
        let mut nid = NOTIFYICONDATAW {
            cbSize: std::mem::size_of::<NOTIFYICONDATAW>() as u32,
            hWnd: hwnd,
            uID: TRAY_UID,
            uFlags: NIF_ICON | NIF_MESSAGE | NIF_TIP,
            uCallbackMessage: WM_TRAY_CALLBACK,
            hIcon: hicon,
            ..Default::default()
        };

        let tip = "Instant Eyedropper Reborn";
        for (i, ch) in tip.encode_utf16().enumerate() {
            if i >= 127 { break; }
            nid.szTip[i] = ch;
        }

        if show_welcome {
            nid.uFlags |= NIF_INFO;
            nid.dwInfoFlags = NIIF_INFO;
            
            let title = "Instant Eyedropper Reborn";
            for (i, ch) in title.encode_utf16().enumerate() {
                if i >= 63 { break; }
                nid.szInfoTitle[i] = ch;
            }

            let info = "DIGITAL SENSOR READY.\nClick here to start picking colors.";
            for (i, ch) in info.encode_utf16().enumerate() {
                if i >= 255 { break; }
                nid.szInfo[i] = ch;
            }        }

        // Retry loop: Explorer may not be ready at boot
        for attempt in 0..10u32 {
            if Shell_NotifyIconW(NIM_ADD, &nid).as_bool() {
                log_step("Tray", "Icon added to system tray");
                return;
            }
            let delay_ms = 500 * (1u64 << attempt.min(4));
            log_step("Tray", &format!("Shell not ready, retry in {}ms", delay_ms));
            std::thread::sleep(std::time::Duration::from_millis(delay_ms));
        }
        log_error("Failed to add tray icon after 10 attempts");
    }
}

unsafe fn remove_tray_icon(hwnd: HWND) {
    unsafe {
        let nid = NOTIFYICONDATAW {
            cbSize: std::mem::size_of::<NOTIFYICONDATAW>() as u32,
            hWnd: hwnd,
            uID: TRAY_UID,
            ..Default::default()
        };
        let _ = Shell_NotifyIconW(NIM_DELETE, &nid);
    }
}

// ══════════════════════════════════════════════════════════════════════════════
// Window procedure
// ══════════════════════════════════════════════════════════════════════════════

unsafe extern "system" fn tray_wnd_proc(
    hwnd: HWND, msg: u32, wparam: WPARAM, lparam: LPARAM,
) -> LRESULT {
    unsafe {
    let ptr = GetWindowLongPtrW(hwnd, GWLP_USERDATA) as *const TrayState;
    if ptr.is_null() {
        // Check for TaskbarCreated before state is set (shouldn't happen, but safe)
        return DefWindowProcW(hwnd, msg, wparam, lparam);
    }
    let state = &*ptr;

    // TaskbarCreated — Explorer restarted, re-add our icon
    if msg == state.wm_taskbar_created && state.wm_taskbar_created != 0 {
        log_step("Tray", "Explorer restarted — re-adding tray icon");
        add_tray_icon(hwnd, state.hicon, false);
        return LRESULT(0);
    }

    match msg {
        WM_TRAY_CALLBACK => {
            let event = (lparam.0 & 0xFFFF) as u32;
            match event {
                // Left click → pick color
                WM_LBUTTONUP => {
                    state.sender.send(UserEvent::LaunchOverlay(None));
                }
                // Right click → context menu
                WM_RBUTTONUP => {
                    show_context_menu(hwnd, &state.sender);
                }
                _ => {}
            }
            LRESULT(0)
        }

        WM_COMMAND => {
            let id = (wparam.0 & 0xFFFF) as u32;
            handle_menu_command(&state.sender, id);
            LRESULT(0)
        }

        WM_CLOSE => {
            // Tell main loop to exit before killing the message pump
            state.sender.send(UserEvent::Quit);
            PostQuitMessage(0);
            LRESULT(0)
        }

        _ => DefWindowProcW(hwnd, msg, wparam, lparam),
    }
    } // unsafe
}

// ══════════════════════════════════════════════════════════════════════════════
// Context menu
// ══════════════════════════════════════════════════════════════════════════════

unsafe fn show_context_menu(hwnd: HWND, _sender: &EventSender) {
    unsafe {
        let hmenu = CreatePopupMenu().expect("CreatePopupMenu");
        let config = Config::load(true);

        // DPI-aware icon size: 16px at 96 DPI, scales with system DPI.
        // GetDeviceCaps works on Win 8.1+ (no GetDpiForSystem which is Win10+).
        let icon_size = {
            let hdc = GetDC(None);
            let dpi = GetDeviceCaps(hdc, LOGPIXELSX);
            ReleaseDC(None, hdc);
            std::cmp::max(16, 16 * dpi / 96)
        };

        // Collect HBITMAPs so we can clean them up after TrackPopupMenu
        let mut bitmaps: Vec<HBITMAP> = Vec::new();

        // ── "Pick Color" ────────────────────────────────────────────
        let _ = AppendMenuW(hmenu, MF_STRING, IDM_PICK_COLOR as usize,
            windows::core::w!("Pick Color"));

        let _ = AppendMenuW(hmenu, MF_SEPARATOR, 0, None);

        // ── Color history (flat list, newest first) ─────────────────
        for (i, hex) in config.history.colors.iter().enumerate() {
            if i >= config.history.size { break; }
            let id = IDM_HISTORY_BASE + i as u32;
            let wide: Vec<u16> = hex.encode_utf16().chain(std::iter::once(0)).collect();
            let _ = AppendMenuW(hmenu, MF_STRING, id as usize, PCWSTR(wide.as_ptr()));

            // Attach color swatch bitmap via MENUITEMINFOW.hbmpItem
            if let Some(hbm) = create_color_bitmap(hex, icon_size) {
                let mii = MENUITEMINFOW {
                    cbSize: std::mem::size_of::<MENUITEMINFOW>() as u32,
                    fMask: MIIM_BITMAP,
                    hbmpItem: hbm,
                    ..Default::default()
                };
                let _ = SetMenuItemInfoW(hmenu, id, false, &mii);
                bitmaps.push(hbm);
            }
        }
        if !config.history.colors.is_empty() {
            let _ = AppendMenuW(hmenu, MF_SEPARATOR, 0, None);
        }

        // ── Template selector (radio-style checkmarks) ──────────────
        for (i, &(key, label)) in TEMPLATE_LABELS.iter().enumerate() {
            let id = IDM_TEMPLATE_BASE + i as u32;
            let wide: Vec<u16> = label.encode_utf16().chain(std::iter::once(0)).collect();
            let flags = if config.templates.selected == key {
                MF_STRING | MF_CHECKED
            } else {
                MF_STRING
            };
            let _ = AppendMenuW(hmenu, flags, id as usize, PCWSTR(wide.as_ptr()));
        }

        let _ = AppendMenuW(hmenu, MF_SEPARATOR, 0, None);

        // ── Toggles ─────────────────────────────────────────────────
        // ── Show HUD ────────────────────────────────────────────────
        let hud_flags = if config.hud.show { MF_STRING | MF_CHECKED } else { MF_STRING };
        let _ = AppendMenuW(hmenu, hud_flags, IDM_TOGGLE_HUD as usize,
            windows::core::w!("Show HUD"));

        // ── Launch at Startup (reads registry each open — always accurate) ──
        let autostart_flags = if is_autostart_enabled() {
            MF_STRING | MF_CHECKED
        } else {
            MF_STRING
        };
        let _ = AppendMenuW(hmenu, autostart_flags, IDM_AUTOSTART as usize,
            windows::core::w!("Launch at Startup"));

        let _ = AppendMenuW(hmenu, MF_SEPARATOR, 0, None);

        // ── Edit Config ─────────────────────────────────────────────
        let _ = AppendMenuW(hmenu, MF_STRING, IDM_EDIT_CONFIG as usize,
            windows::core::w!("Edit Config"));

        // ── Homepage ────────────────────────────────────────────────
        let _ = AppendMenuW(hmenu, MF_STRING, IDM_HOMEPAGE as usize,
            windows::core::w!("Homepage"));

        // ── About ───────────────────────────────────────────────────
        let _ = AppendMenuW(hmenu, MF_STRING, IDM_ABOUT as usize,
            windows::core::w!("About"));

        let _ = AppendMenuW(hmenu, MF_SEPARATOR, 0, None);

        // ── Quit ────────────────────────────────────────────────────
        let _ = AppendMenuW(hmenu, MF_STRING, IDM_QUIT as usize,
            windows::core::w!("Quit"));

        // Load the foreground thread's keyboard layout (HKL) into our thread
        // BEFORE SetForegroundWindow. When our tray thread becomes foreground,
        // Windows activates its HKL — if it differs from the user's active layout,
        // the input language indicator switches. By pre-loading the correct HKL,
        // the switch becomes a no-op and the user sees nothing.
        // No race condition: this is a one-shot load, no attach/detach dance.
        let prev_hwnd = GetForegroundWindow();
        let prev_tid = GetWindowThreadProcessId(prev_hwnd, None);
        if prev_tid != 0 {
            let hkl = GetKeyboardLayout(prev_tid);
            let _ = ActivateKeyboardLayout(hkl, Default::default());
        }

        let _ = SetForegroundWindow(hwnd);

        let mut pt = std::mem::zeroed::<POINT>();
        let _ = GetCursorPos(&mut pt);

        // No alignment flags — Windows auto-flips the menu to stay on screen,
        // regardless of taskbar position (top/bottom/left/right).
        // TPM_RIGHTBUTTON: menu items respond to right-click too (legacy IE behavior).
        let _ = TrackPopupMenu(hmenu, TPM_RIGHTBUTTON,
            pt.x, pt.y, 0, hwnd, None);

        // Post dummy message to fix subsequent right-clicks
        // (TrackPopupMenu's internal modal loop quirk)
        let _ = PostMessageW(hwnd, WM_NULL, WPARAM(0), LPARAM(0));

        let _ = DestroyMenu(hmenu);

        // Free color swatch bitmaps (menu no longer references them)
        for hbm in bitmaps {
            let _ = DeleteObject(hbm);
        }
    }
}

/// Creates a DPI-aware color swatch HBITMAP from a hex color string.
/// Returns None if the hex string is invalid. Lives only in memory — no temp files.
unsafe fn create_color_bitmap(hex: &str, size: i32) -> Option<HBITMAP> {
    unsafe {
        let s = hex.trim_start_matches('#');
        let val = u32::from_str_radix(s, 16).ok()?;
        let r = ((val >> 16) & 0xFF) as u8;
        let g = ((val >> 8) & 0xFF) as u8;
        let b = (val & 0xFF) as u8;

        let hdc_screen = GetDC(None);
        let hdc_mem = CreateCompatibleDC(hdc_screen);

        let bmi = BITMAPINFO {
            bmiHeader: BITMAPINFOHEADER {
                biSize: std::mem::size_of::<BITMAPINFOHEADER>() as u32,
                biWidth: size,
                biHeight: -size, // top-down
                biPlanes: 1,
                biBitCount: 32,
                biCompression: BI_RGB.0,
                ..Default::default()
            },
            ..Default::default()
        };

        let mut bits_ptr: *mut std::ffi::c_void = std::ptr::null_mut();
        let hbm = CreateDIBSection(hdc_mem, &bmi, DIB_RGB_COLORS, &mut bits_ptr, None, 0);
        let hbm = match hbm {
            Ok(h) => h,
            Err(_) => {
                let _ = DeleteDC(hdc_mem);
                ReleaseDC(None, hdc_screen);
                return None;
            }
        };

        let pixel_count = (size * size) as usize;
        let dst = std::slice::from_raw_parts_mut(bits_ptr as *mut u32, pixel_count);

        // 0xAARRGGBB — menu bitmaps on Vista+ use pre-multiplied alpha
        let fill = 0xFF000000 | (r as u32) << 16 | (g as u32) << 8 | b as u32;
        let border = 0xFF808080u32; // gray border, fully opaque

        let sz = size as usize;
        for y in 0..sz {
            for x in 0..sz {
                dst[y * sz + x] = if x == 0 || y == 0 || x == sz - 1 || y == sz - 1 {
                    border
                } else {
                    fill
                };
            }
        }

        let _ = DeleteDC(hdc_mem);
        ReleaseDC(None, hdc_screen);

        Some(hbm)
    }
}

fn handle_menu_command(sender: &EventSender, id: u32) {
    match id {
        IDM_PICK_COLOR => sender.send(UserEvent::LaunchOverlay(None)),
        IDM_EDIT_CONFIG => sender.send(UserEvent::EditConfig),
        IDM_QUIT => sender.send(UserEvent::Quit),
        IDM_TOGGLE_HUD => sender.send(UserEvent::ToggleHUD),
        IDM_AUTOSTART => set_autostart(!is_autostart_enabled()),
        IDM_ABOUT => sender.send(UserEvent::ShowAbout),
        IDM_HOMEPAGE => sender.send(UserEvent::OpenHomepage),
        _ if id >= IDM_TEMPLATE_BASE
            && id < IDM_TEMPLATE_BASE + TEMPLATE_LABELS.len() as u32 =>
        {
            let idx = (id - IDM_TEMPLATE_BASE) as usize;
            let key = TEMPLATE_LABELS[idx].0;
            sender.send(UserEvent::SelectTemplate(key.to_string()));
        }
        _ if (IDM_HISTORY_BASE..IDM_HISTORY_BASE + 100).contains(&id) =>
        {
            // Re-read config to get color at this index
            let config = Config::load(true);
            let idx = (id - IDM_HISTORY_BASE) as usize;
            if let Some(hex) = config.history.colors.get(idx) {
                sender.send(UserEvent::CopyFromHistory(hex.clone()));
            }
        }
        _ => {}
    }
}

// ══════════════════════════════════════════════════════════════════════════════
// Autostart — HKCU\...\Run registry helpers
// ══════════════════════════════════════════════════════════════════════════════

/// Returns true if ie-r is registered in HKCU Run key.
/// Reads registry directly — always reflects real state, not cached config.
fn is_autostart_enabled() -> bool {
    unsafe {
        let path: Vec<u16> = AUTOSTART_REG_PATH.encode_utf16()
            .chain(std::iter::once(0)).collect();
        let value: Vec<u16> = AUTOSTART_REG_VALUE.encode_utf16()
            .chain(std::iter::once(0)).collect();

        let mut hkey = HKEY::default();
        if RegOpenKeyExW(
            HKEY_CURRENT_USER,
            PCWSTR(path.as_ptr()),
            0,
            KEY_READ,
            &mut hkey,
        ).is_err() {
            return false;
        }

        let result = RegQueryValueExW(hkey, PCWSTR(value.as_ptr()), None, None, None, None);
        let _ = RegCloseKey(hkey);
        result.is_ok()
    }
}

/// Writes or removes the HKCU Run entry for ie-r.
fn set_autostart(enable: bool) {
    unsafe {
        let path: Vec<u16> = AUTOSTART_REG_PATH.encode_utf16()
            .chain(std::iter::once(0)).collect();
        let value: Vec<u16> = AUTOSTART_REG_VALUE.encode_utf16()
            .chain(std::iter::once(0)).collect();

        let mut hkey = HKEY::default();
        if RegOpenKeyExW(
            HKEY_CURRENT_USER,
            PCWSTR(path.as_ptr()),
            0,
            KEY_SET_VALUE,
            &mut hkey,
        ).is_err() {
            return;
        }

        if enable {
            // Autostart via the GUI launcher stub so no console window appears.
            let tray_exe = std::env::current_exe().ok()
                .and_then(|p| p.parent().map(|d| d.join("ie-r-tray.exe")));
            if let Some(exe_path) = tray_exe {
                let quoted = format!("\"{}\"", exe_path.to_string_lossy());
                let exe_wide: Vec<u16> = quoted
                    .encode_utf16().chain(std::iter::once(0)).collect();
                let bytes = std::slice::from_raw_parts(
                    exe_wide.as_ptr() as *const u8,
                    exe_wide.len() * 2,
                );
                let _ = RegSetValueExW(
                    hkey,
                    PCWSTR(value.as_ptr()),
                    0,
                    REG_SZ,
                    Some(bytes),
                );
                log_step("Autostart", "Enabled — registry entry written");
            }
        } else {
            let _ = RegDeleteValueW(hkey, PCWSTR(value.as_ptr()));
            log_step("Autostart", "Disabled — registry entry removed");
        }

        let _ = RegCloseKey(hkey);
    }
}

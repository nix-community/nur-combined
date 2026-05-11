//! Win32 overlay window — Phase 2 connector.
//!
//! Creates a fullscreen popup covering the virtual screen, renders the frozen
//! screenshot + magnifier/HUD via OverlayApp::render(), and translates Win32
//! messages into UserAction commands.
//!
//! Render pipeline: OverlayApp::render(canvas) → DIB section → dirty rect BitBlt → window.
//!
//! DIRTY RECT CONTRACT: render() returns partial damage regions in dirty_rects.
//! We BitBlt ONLY those regions, NOT the full screen. Without this, CPU pegs at
//! 100% from ~480MB/s of wasted memcpy (8MB × 60fps). See ARCHITECTURE.md.

use std::time::Instant;

use anyhow::Result;
use image::Rgba;
use windows::Win32::Foundation::*;
use windows::Win32::Graphics::Gdi::*;
use windows::Win32::UI::Input::KeyboardAndMouse::*;
use windows::Win32::UI::WindowsAndMessaging::*;

use crate::core::config::Config;
use crate::core::overlay::{OverlayApp, UserAction};
use crate::core::terminal::log_step;

// ══════════════════════════════════════════════════════════════════════════════
// Public API
// ══════════════════════════════════════════════════════════════════════════════

/// Result of an overlay session.
pub struct OverlayResult {
    pub color_deck: Vec<Rgba<u8>>,
    pub config: Config,
}

/// Run the Win32 overlay loop.  Blocks until the user picks a color or cancels.
///
/// `app` must already contain the captured `PhysicalCanvas`.
/// Returns the collected color deck (empty if cancelled).
pub fn run_overlay(app: OverlayApp, owner: HWND) -> Result<OverlayResult> {
    let start = Instant::now();

    unsafe {
        // Virtual screen covers all monitors (may have negative origin)
        let vx = GetSystemMetrics(SM_XVIRTUALSCREEN);
        let vy = GetSystemMetrics(SM_YVIRTUALSCREEN);
        let vw = GetSystemMetrics(SM_CXVIRTUALSCREEN);
        let vh = GetSystemMetrics(SM_CYVIRTUALSCREEN);

        if vw == 0 || vh == 0 {
            anyhow::bail!("Virtual screen is 0×0");
        }

        // ── Register window class ────────────────────────────────────────
        let class_name = windows::core::w!("IEROverlay");
        let wc = WNDCLASSEXW {
            cbSize: std::mem::size_of::<WNDCLASSEXW>() as u32,
            style: CS_HREDRAW | CS_VREDRAW,
            lpfnWndProc: Some(wnd_proc),
            hCursor: LoadCursorW(None, IDC_CROSS)?,
            lpszClassName: class_name,
            ..Default::default()
        };
        RegisterClassExW(&wc);

        // ── Create fullscreen popup ──────────────────────────────────────
        // WS_EX_TOOLWINDOW: ensures no taskbar entry and keeps us out of Alt-Tab.
        // WS_EX_TOPMOST: keeps us above other windows.
        // WS_EX_NOACTIVATE: window never takes focus — keyboard input comes via
        // WH_KEYBOARD_LL hook instead, so other apps keep their focus undisturbed.
        let hwnd = CreateWindowExW(
            WS_EX_TOPMOST | WS_EX_TOOLWINDOW | WS_EX_NOACTIVATE,
            class_name,
            windows::core::w!("IE-R"),
            WS_POPUP | WS_VISIBLE,
            vx, vy, vw, vh,
            owner, None, None, None,
        )?;

        // ── Create DIB section (32-bit top-down, matches XRGB8888) ──────
        let hdc_screen = GetDC(None);
        let hdc_mem_owned = CreateCompatibleDC(hdc_screen);
        let hdc_mem = HDC(hdc_mem_owned.0);
        let bmi = BITMAPINFO {
            bmiHeader: BITMAPINFOHEADER {
                biSize: std::mem::size_of::<BITMAPINFOHEADER>() as u32,
                biWidth: vw,
                biHeight: -vh, // negative = top-down
                biPlanes: 1,
                biBitCount: 32,
                biCompression: BI_RGB.0,
                ..Default::default()
            },
            ..Default::default()
        };
        let mut bits_ptr: *mut std::ffi::c_void = std::ptr::null_mut();
        let hbitmap = CreateDIBSection(hdc_mem, &bmi, DIB_RGB_COLORS, &mut bits_ptr, None, 0)?;
        SelectObject(hdc_mem, hbitmap);
        ReleaseDC(None, hdc_screen);

        if bits_ptr.is_null() {
            anyhow::bail!("CreateDIBSection returned null bits pointer");
        }

        // ── Build overlay state and attach to window ─────────────────────
        let mut state = Box::new(Win32State {
            app,
            hdc_mem,
            bitmap_bits: bits_ptr as *mut u32,
            width: vw as u32,
            height: vh as u32,
            vx,
            vy,
            shift: false,
            ctrl: false,
            alt: false,
            needs_redraw: true,
            prev_dirty_rects: std::collections::VecDeque::with_capacity(12),
        });

        // Initial mouse position and monitor rect
        let mut cursor_pt = POINT::default();
        if GetCursorPos(&mut cursor_pt).is_ok() {
            let mx = (cursor_pt.x - vx) as f64;
            let my = (cursor_pt.y - vy) as f64;
            state.app.update_physical_mouse(mx, my);

            let hmon = MonitorFromPoint(cursor_pt, MONITOR_DEFAULTTONEAREST);
            let mut mi = MONITORINFO {
                cbSize: std::mem::size_of::<MONITORINFO>() as u32,
                ..Default::default()
            };
            if GetMonitorInfoW(hmon, &mut mi).as_bool() {
                let r = &mi.rcMonitor;
                state.app.monitor_rect = Some((
                    r.left   - vx,
                    r.top    - vy,
                    r.right  - r.left,
                    r.bottom - r.top,
                ));
            }
        }

        SetWindowLongPtrW(hwnd, GWLP_USERDATA, (&*state) as *const Win32State as isize);

        // ── Install low-level keyboard hook ──────────────────────────────
        // WS_EX_NOACTIVATE means WM_KEYDOWN never arrives — hook fills that role.
        // Active only for overlay lifetime; input is swallowed while overlay is up.
        HOOK_HWND.with(|c| c.set(hwnd.0 as isize));
        let hhook = SetWindowsHookExW(WH_KEYBOARD_LL, Some(keyboard_hook), None, 0)
            .inspect_err(|_| { HOOK_HWND.with(|c| c.set(0)); })?;
        let mhook = SetWindowsHookExW(WH_MOUSE_LL, Some(mouse_hook), None, 0)
            .inspect_err(|_| { let _ = UnhookWindowsHookEx(hhook); HOOK_HWND.with(|c| c.set(0)); })?;

        log_step("Overlay", &format!(
            "Win32 window {}×{} @ ({},{}) — init {}ms",
            vw, vh, vx, vy, start.elapsed().as_millis(),
        ));

        // ── Initial render ───────────────────────────────────────────────
        render_frame(&mut state, hwnd);

        // ── Message loop ─────────────────────────────────────────────────
        let mut msg = MSG::default();
        loop {
            // Drain all pending messages
            while PeekMessageW(&mut msg, None, 0, 0, PM_REMOVE).as_bool() {
                if msg.message == WM_QUIT {
                    break;
                }
                // WM_HOTKEY is a thread message (hwnd=NULL) — won't reach wnd_proc.
                // Handle here: second hotkey press while overlay active = pick color.
                if msg.message == WM_HOTKEY {
                    // Second hotkey press = final pick (always non-serial).
                    // Shift is part of the hotkey combo itself, not a modifier intent.
                    dispatch(&mut state, UserAction::PickColor { serial: false });
                    continue;
                }
                let _ = TranslateMessage(&msg);
                DispatchMessageW(&msg);
            }

            if msg.message == WM_QUIT || state.app.should_exit {
                break;
            }

            // Watchdog: cancel overlay if inactive for too long.
            let timeout = state.app.config.system.auto_cancel;
            if timeout > 0 && state.app.last_activity.elapsed().as_secs() >= timeout {
                crate::core::terminal::log_step("Watchdog", "Overlay cancelled due to inactivity");
                break;
            }

            // Render if dirty
            if state.needs_redraw || state.app.needs_redraw
                || state.app.blink.is_some() || state.app.repeat_tracker.is_some()
            {
                render_frame(&mut state, hwnd);
                state.needs_redraw = false;
            }

            // Wait for messages or ~16ms (≈60 fps) — avoids busy spin
            let _ = MsgWaitForMultipleObjectsEx(
                None, 16, QS_ALLINPUT, MSG_WAIT_FOR_MULTIPLE_OBJECTS_EX_FLAGS(0),
            );
        }

        // ── Cleanup ──────────────────────────────────────────────────────
        let _ = UnhookWindowsHookEx(hhook);
        let _ = UnhookWindowsHookEx(mhook);
        HOOK_HWND.with(|c| c.set(0));
        // Detach state pointer before drop
        SetWindowLongPtrW(hwnd, GWLP_USERDATA, 0);
        let _ = DestroyWindow(hwnd);
        let _ = UnregisterClassW(class_name, None);
        let _ = DeleteDC(hdc_mem);
        let _ = DeleteObject(hbitmap);

        let deck = state.app.take_color_deck();
        let config = state.app.config.clone();
        Ok(OverlayResult { color_deck: deck, config })
    }
}

// ══════════════════════════════════════════════════════════════════════════════
// Internal state
// ══════════════════════════════════════════════════════════════════════════════

/// Internal state of the Win32 overlay, attached to the HWND via GWLP_USERDATA.
/// This acts as the bridge between the OS-specific rendering/input state and
/// the cross-platform `OverlayApp` logic.
struct Win32State {
    app: OverlayApp,
    hdc_mem: HDC,
    bitmap_bits: *mut u32,
    width: u32,
    height: u32,
    // Virtual screen origin (SM_XVIRTUALSCREEN / SM_YVIRTUALSCREEN).
    // Used to translate absolute screen coords to canvas-local coords.
    vx: i32,
    vy: i32,
    // Modifier tracking (WM_KEYDOWN/UP doesn't bundle modifiers like Wayland)
    shift: bool,
    ctrl: bool,
    alt: bool,
    needs_redraw: bool,
    /// Dirty rects from the previous frame — swapped with OverlayApp each render.
    /// Same pattern as Wayland connector's per-overlay dirty_rects storage.
    prev_dirty_rects: std::collections::VecDeque<(i32, i32, usize, usize)>,
}

// ══════════════════════════════════════════════════════════════════════════════
// Rendering
// ══════════════════════════════════════════════════════════════════════════════

/// Render one frame: OverlayApp → DIB → BitBlt to window.
///
/// Uses dirty rect optimization: swap dirty_rects with OverlayApp before render,
/// then BitBlt each dirty region individually instead of the full screen.
/// Same swap pattern as Wayland connector (render.rs) — single DIB buffer is always
/// "warmed" after the first full frame, so partial updates work from frame 2.
///
/// Unlike Wayland, we don't merge rects into a super bounding box — that's a
/// workaround for compositor fractional scaling artifacts (seams at rect boundaries).
/// Win32 BitBlt is a direct pixel copy with no compositor in the path, so per-rect
/// blitting is safe and more efficient.
unsafe fn render_frame(state: &mut Win32State, hwnd: HWND) {
    unsafe {
        let len = (state.width * state.height) as usize;
        let canvas = std::slice::from_raw_parts_mut(state.bitmap_bits, len);

        // Swap previous dirty_rects into OverlayApp (for background restoration)
        std::mem::swap(&mut state.app.dirty_rects, &mut state.prev_dirty_rects);

        let partial = state.app.render(canvas, state.width, state.height);

        let hdc = GetDC(hwnd);

        if partial && !state.app.dirty_rects.is_empty() {
            // Fast path: BitBlt each dirty rect individually
            for &(dx, dy, dw, dh) in &state.app.dirty_rects {
                let x = dx.max(0);
                let y = dy.max(0);
                let w = (dw as i32).min(state.width as i32 - x);
                let h = (dh as i32).min(state.height as i32 - y);
                if w > 0 && h > 0 {
                    let _ = BitBlt(hdc, x, y, w, h, state.hdc_mem, x, y, SRCCOPY);
                }
            }
        } else {
            // Full blit (first frame or tile change)
            let _ = BitBlt(
                hdc, 0, 0,
                state.width as i32, state.height as i32,
                state.hdc_mem, 0, 0,
                SRCCOPY,
            );
        }

        ReleaseDC(hwnd, hdc);

        // Swap dirty_rects back for next frame
        std::mem::swap(&mut state.app.dirty_rects, &mut state.prev_dirty_rects);
    }
}

// ══════════════════════════════════════════════════════════════════════════════
// WH_KEYBOARD_LL hook — focus-independent keyboard input
// ══════════════════════════════════════════════════════════════════════════════

// Private messages for LL hook → wnd_proc bridge.
// Offset from WM_APP by 100 to avoid collision if other subsystems use WM_APP+0..+N.
// Reserved range: WM_APP+100 .. WM_APP+102.
const WM_HOOK_KEYDOWN:   u32 = WM_APP + 100; // keyboard LL hook: key down
const WM_HOOK_KEYUP:     u32 = WM_APP + 101; // keyboard LL hook: key up
const WM_HOOK_WHEEL:     u32 = WM_APP + 102; // mouse LL hook: wheel delta

thread_local! {
    // HWND of the active overlay window; 0 when no overlay is running.
    // Written by run_overlay, read by keyboard_hook (same thread).
    static HOOK_HWND: std::cell::Cell<isize> = const { std::cell::Cell::new(0) };
}

unsafe extern "system" fn mouse_hook(code: i32, wparam: WPARAM, lparam: LPARAM) -> LRESULT {
    unsafe {
        if code >= 0 {
            let hwnd_val = HOOK_HWND.with(|c| c.get());
            if hwnd_val != 0 && wparam.0 as u32 == WM_MOUSEWHEEL {
                let ms = &*(lparam.0 as *const MSLLHOOKSTRUCT);
                let delta = (ms.mouseData >> 16) as i16;
                let _ = PostMessageW(HWND(hwnd_val as *mut _), WM_HOOK_WHEEL, WPARAM(delta as usize), LPARAM(0));
                return LRESULT(1); // swallow — redirected manually above
            }
        }
        CallNextHookEx(HHOOK::default(), code, wparam, lparam)
    }
}

unsafe extern "system" fn keyboard_hook(code: i32, wparam: WPARAM, lparam: LPARAM) -> LRESULT {
    unsafe {
        if code >= 0 {
            let hwnd_val = HOOK_HWND.with(|c| c.get());
            if hwnd_val != 0 {
                let kb = &*(lparam.0 as *const KBDLLHOOKSTRUCT);
                let vk = VIRTUAL_KEY(kb.vkCode as u16);
                let is_down = wparam.0 == WM_KEYDOWN as usize
                    || wparam.0 == WM_SYSKEYDOWN as usize;

                // Post to our window only for keys we actually handle.
                if is_overlay_action_key(vk) || is_modifier_key(vk) {
                    let msg = if is_down { WM_HOOK_KEYDOWN } else { WM_HOOK_KEYUP };
                    let _ = PostMessageW(HWND(hwnd_val as *mut _), msg, WPARAM(kb.vkCode as usize), LPARAM(0));
                }

                // Swallow only action keys. Modifiers and everything else pass
                // through — this preserves OS keyboard state (no "stuck" modifiers
                // on overlay exit) and lets RegisterHotKey match the second press.
                if is_overlay_action_key(vk) {
                    return LRESULT(1);
                }
            }
        }
        CallNextHookEx(HHOOK::default(), code, wparam, lparam)
    }
}

// ══════════════════════════════════════════════════════════════════════════════
// Win32 message handler
// ══════════════════════════════════════════════════════════════════════════════

unsafe extern "system" fn wnd_proc(
    hwnd: HWND, msg: u32, wparam: WPARAM, lparam: LPARAM,
) -> LRESULT {
    unsafe {
    let ptr = GetWindowLongPtrW(hwnd, GWLP_USERDATA);
    if ptr == 0 {
        return DefWindowProcW(hwnd, msg, wparam, lparam);
    }
    let state = &mut *(ptr as *mut Win32State);

    match msg {
        // ── Mouse movement ───────────────────────────────────────
        WM_MOUSEMOVE => {
            let x = (lparam.0 & 0xFFFF) as i16 as f64;
            let y = ((lparam.0 >> 16) & 0xFFFF) as i16 as f64;
            if state.app.physical_mouse_pos == Some((x, y)) {
                return LRESULT(0);
            }
            state.app.update_physical_mouse(x, y);

            // Detect current monitor and store its bounds in canvas-local coords.
            // Magnifier uses this to clamp/reflect within the monitor boundary.
            let abs_x = x as i32 + state.vx;
            let abs_y = y as i32 + state.vy;
            let pt = POINT { x: abs_x, y: abs_y };
            let hmon = MonitorFromPoint(pt, MONITOR_DEFAULTTONEAREST);
            let mut mi = MONITORINFO {
                cbSize: std::mem::size_of::<MONITORINFO>() as u32,
                ..Default::default()
            };
            if GetMonitorInfoW(hmon, &mut mi).as_bool() {
                let r = &mi.rcMonitor;
                state.app.monitor_rect = Some((
                    r.left   - state.vx,
                    r.top    - state.vy,
                    r.right  - r.left,
                    r.bottom - r.top,
                ));
            }

            state.needs_redraw = true;
            LRESULT(0)
        }

        // ── Mouse buttons ────────────────────────────────────────
        WM_LBUTTONDOWN => {
            dispatch(state, UserAction::PickColor { serial: state.shift });
            LRESULT(0)
        }
        WM_MBUTTONDOWN => {
            dispatch(state, UserAction::PickColor { serial: true });
            LRESULT(0)
        }
        WM_RBUTTONDOWN => LRESULT(0), // eat — cancel fires on button up
        WM_RBUTTONUP => {
            dispatch(state, UserAction::Cancel);
            LRESULT(0) // don't call DefWindowProc — it would generate WM_CONTEXTMENU
        }
        WM_CONTEXTMENU => LRESULT(0), // defensive: eat in case it arrives anyway

        // ── Mouse wheel ──────────────────────────────────────────
        // WM_MOUSEWHEEL is dead with WS_EX_NOACTIVATE (wheel goes to focused
        // window). Kept as defensive fallback; real path is WM_HOOK_WHEEL.
        WM_MOUSEWHEEL => {
            handle_wheel(state, (wparam.0 >> 16) as i16);
            LRESULT(0)
        }

        // ── Keyboard (dead with WS_EX_NOACTIVATE) ────────────────
        // WM_KEY* never arrive when window has no focus. Kept as defensive
        // fallback; real path is WM_HOOK_KEYDOWN / WM_HOOK_KEYUP via keyboard hook.
        WM_KEYDOWN | WM_SYSKEYDOWN => {
            handle_key_down(state, VIRTUAL_KEY(wparam.0 as u16));
            LRESULT(0)
        }
        WM_KEYUP | WM_SYSKEYUP => {
            handle_key_up(state, VIRTUAL_KEY(wparam.0 as u16));
            LRESULT(0)
        }

        // ── LL hook paths (WS_EX_NOACTIVATE — primary input channel) ─────
        WM_HOOK_WHEEL => {
            handle_wheel(state, wparam.0 as i16);
            LRESULT(0)
        }
        WM_HOOK_KEYDOWN => {
            handle_key_down(state, VIRTUAL_KEY(wparam.0 as u16));
            LRESULT(0)
        }
        WM_HOOK_KEYUP => {
            handle_key_up(state, VIRTUAL_KEY(wparam.0 as u16));
            LRESULT(0)
        }

        // ── Anti-flicker ─────────────────────────────────────────
        WM_ERASEBKGND => LRESULT(1),

        // ── Cursor: keep crosshair even when window gets SetCursor
        WM_SETCURSOR => {
            if let Ok(cursor) = LoadCursorW(None, IDC_CROSS) {
                SetCursor(cursor);
            }
            LRESULT(1)
        }

        _ => DefWindowProcW(hwnd, msg, wparam, lparam),
    }
    } // unsafe
}

// ══════════════════════════════════════════════════════════════════════════════
// Helpers
// ══════════════════════════════════════════════════════════════════════════════

/// Handle key-down event. Single source of truth for both WM_KEYDOWN (defensive
/// fallback) and WM_HOOK_KEYDOWN (LL hook primary path).
fn handle_key_down(state: &mut Win32State, vk: VIRTUAL_KEY) {
    match vk {
        VK_ESCAPE => dispatch(state, UserAction::Cancel),
        VK_RETURN => dispatch(state, UserAction::PickColor { serial: state.shift }),
        VK_SPACE  => dispatch(state, UserAction::PickColor { serial: true }),
        VK_OEM_3  => dispatch(state, UserAction::ToggleHud), // `/~ key
        VK_LEFT | VK_RIGHT | VK_UP | VK_DOWN => {
            let (dx, dy) = arrow_delta(vk);
            let action = if state.shift || state.ctrl {
                UserAction::Jump(dx, dy)
            } else {
                UserAction::Nudge(dx, dy)
            };
            dispatch(state, action);
        }
        vk if is_digit_vk(vk) => {
            dispatch(state, UserAction::SelectFormatDigit(digit_from_vk(vk)));
        }
        // Modifier tracking
        VK_SHIFT | VK_LSHIFT | VK_RSHIFT => state.shift = true,
        VK_CONTROL | VK_LCONTROL | VK_RCONTROL => state.ctrl = true,
        VK_MENU | VK_LMENU | VK_RMENU => state.alt = true,
        _ => {}
    }
}

/// Handle key-up event. Single source of truth for both WM_KEYUP (defensive
/// fallback) and WM_HOOK_KEYUP (LL hook primary path).
fn handle_key_up(state: &mut Win32State, vk: VIRTUAL_KEY) {
    match vk {
        VK_SHIFT | VK_LSHIFT | VK_RSHIFT => state.shift = false,
        VK_CONTROL | VK_LCONTROL | VK_RCONTROL => state.ctrl = false,
        VK_MENU | VK_LMENU | VK_RMENU => state.alt = false,
        VK_LEFT | VK_RIGHT | VK_UP | VK_DOWN => {
            let (dx, dy) = arrow_delta(vk);
            state.app.handle_action(UserAction::KeyRelease { dx, dy });
            state.needs_redraw = true;
        }
        _ => {}
    }
}

/// Handle mouse wheel delta. Single source of truth for both WM_MOUSEWHEEL
/// (defensive fallback) and WM_HOOK_WHEEL (LL hook primary path).
fn handle_wheel(state: &mut Win32State, raw_delta: i16) {
    let steps = if raw_delta > 0 { 1 } else { -1 };
    let action = if state.ctrl {
        UserAction::ChangeFontSize(steps)
    } else if state.shift {
        UserAction::ResizeMagnifier(steps)
    } else if state.alt {
        UserAction::ChangeAimSize(steps)
    } else {
        UserAction::Zoom(steps)
    };
    dispatch(state, action);
}

/// Helper to send an action to the core OverlayApp and request a redraw.
#[inline]
fn dispatch(state: &mut Win32State, action: UserAction) {
    state.app.handle_action(action);
    state.needs_redraw = true;
}

/// Converts a virtual key into an (x, y) directional vector for jump/nudge actions.
#[inline]
fn arrow_delta(vk: VIRTUAL_KEY) -> (i32, i32) {
    match vk {
        VK_LEFT  => (-1,  0),
        VK_RIGHT => ( 1,  0),
        VK_UP    => ( 0, -1),
        VK_DOWN  => ( 0,  1),
        _        => ( 0,  0),
    }
}

/// Checks if the virtual key corresponds to a digit (0-9).
#[inline]
fn is_digit_vk(vk: VIRTUAL_KEY) -> bool {
    vk.0 >= 0x30 && vk.0 <= 0x39
}

/// Extracts the integer value from a digit virtual key.
/// Note: '0' maps to index 10 to match the 1...0 keyboard layout order.
#[inline]
fn digit_from_vk(vk: VIRTUAL_KEY) -> usize {
    if vk.0 == 0x30 { 10 } else { (vk.0 - 0x30) as usize }
}

/// Keys the overlay actively handles — swallowed by the LL hook to prevent
/// them from leaking to the focused application.
#[inline]
fn is_overlay_action_key(vk: VIRTUAL_KEY) -> bool {
    matches!(vk,
        VK_ESCAPE | VK_RETURN | VK_SPACE | VK_OEM_3 |
        VK_LEFT | VK_RIGHT | VK_UP | VK_DOWN
    ) || is_digit_vk(vk)
}

/// Modifier keys — tracked locally but MUST pass through the hook to preserve
/// OS keyboard state. Swallowing these causes "stuck modifiers" on overlay exit
/// and breaks RegisterHotKey matching.
#[inline]
fn is_modifier_key(vk: VIRTUAL_KEY) -> bool {
    matches!(vk,
        VK_SHIFT | VK_LSHIFT | VK_RSHIFT |
        VK_CONTROL | VK_LCONTROL | VK_RCONTROL |
        VK_MENU | VK_LMENU | VK_RMENU
    )
}

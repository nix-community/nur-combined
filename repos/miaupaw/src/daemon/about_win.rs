//! Win32 About window — glassmorphism + Hermes scroller.
//!
//! Reuses the platform-agnostic `AboutApp` core: captures the screen region
//! behind the window for frosted glass blur, renders into a DIB section,
//! and drives the animation with a Win32 timer.
//!
//! Lifecycle: `show_about(font_data)` spawns a thread → creates a centered
//! WS_POPUP → runs its own message loop → returns on Escape / click outside.

use std::sync::Arc;

use anyhow::Result;
use windows::Win32::Foundation::*;
use windows::Win32::Graphics::Gdi::*;
use windows::Win32::UI::Input::KeyboardAndMouse::*;
use windows::Win32::UI::WindowsAndMessaging::*;

use crate::core::about::{AboutApp, ABOUT_WIDTH, ABOUT_HEIGHT};
use crate::core::terminal::log_step;

const TIMER_ID: usize = 1;
const FRAME_MS: u32 = 16; // ~60fps

/// State attached to the about window via GWLP_USERDATA.
struct AboutState {
    app: AboutApp,
    hdc_mem: HDC,
    bitmap_bits: *mut u32,
    bg_buffer: Vec<u32>,
    blur_buf_1: Vec<u32>,
    blur_buf_2: Vec<u32>,
    width: u32,
    height: u32,
}

/// Spawns the About window in a dedicated thread (non-blocking for the daemon loop).
pub fn show_about(font_data: Arc<Vec<u8>>) {
    std::thread::spawn(move || {
        if let Err(e) = run_about_window(font_data) {
            crate::core::terminal::log_error(&format!("About window failed: {}", e));
        }
    });
}

fn run_about_window(font_data: Arc<Vec<u8>>) -> Result<()> {
    let w = ABOUT_WIDTH as i32;
    let h = ABOUT_HEIGHT as i32;

    unsafe {
        // ── Center on primary monitor ─────────────────────────────────
        let screen_w = GetSystemMetrics(SM_CXSCREEN);
        let screen_h = GetSystemMetrics(SM_CYSCREEN);
        let x = (screen_w - w) / 2;
        let y = (screen_h - h) / 2;

        // ── Capture background for glassmorphism BEFORE creating window ──
        let bg_buffer = capture_screen_region(x, y, w, h);

        // ── Register window class ─────────────────────────────────────
        let class_name = windows::core::w!("IERAbout");
        let wc = WNDCLASSEXW {
            cbSize: std::mem::size_of::<WNDCLASSEXW>() as u32,
            style: CS_HREDRAW | CS_VREDRAW,
            lpfnWndProc: Some(about_wnd_proc),
            hCursor: LoadCursorW(None, IDC_ARROW)?,
            lpszClassName: class_name,
            ..Default::default()
        };
        RegisterClassExW(&wc);

        // ── Create borderless popup ───────────────────────────────────
        let hwnd = CreateWindowExW(
            WS_EX_TOPMOST,
            class_name,
            windows::core::w!("About — Instant Eyedropper Reborn"),
            WS_POPUP | WS_VISIBLE,
            x, y, w, h,
            None, None, None, None,
        )?;

        // ── Create DIB section for rendering ──────────────────────────
        let hdc_screen = GetDC(None);
        let hdc_mem_owned = CreateCompatibleDC(hdc_screen);
        let hdc_mem = HDC(hdc_mem_owned.0);
        let bmi = BITMAPINFO {
            bmiHeader: BITMAPINFOHEADER {
                biSize: std::mem::size_of::<BITMAPINFOHEADER>() as u32,
                biWidth: w,
                biHeight: -h, // top-down
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

        let pixels = (ABOUT_WIDTH * ABOUT_HEIGHT) as usize;
        let state = Box::new(AboutState {
            app: AboutApp::new(font_data),
            hdc_mem,
            bitmap_bits: bits_ptr as *mut u32,
            bg_buffer,
            blur_buf_1: vec![0u32; pixels],
            blur_buf_2: vec![0u32; pixels],
            width: ABOUT_WIDTH,
            height: ABOUT_HEIGHT,
        });

        SetWindowLongPtrW(hwnd, GWLP_USERDATA, Box::into_raw(state) as isize);

        // ── Grab focus ────────────────────────────────────────────────
        let _ = SetForegroundWindow(hwnd);
        let _ = SetFocus(hwnd);

        // ── Start animation timer ─────────────────────────────────────
        let _ = SetTimer(hwnd, TIMER_ID, FRAME_MS, None);

        // ── Initial render ────────────────────────────────────────────
        render_about_frame(hwnd);

        log_step("About", "Window launched with glassmorphism");

        // ── Message loop ──────────────────────────────────────────────
        let mut msg = std::mem::zeroed::<MSG>();
        while GetMessageW(&mut msg, None, 0, 0).as_bool() {
            let _ = TranslateMessage(&msg);
            DispatchMessageW(&msg);
        }

        // ── Cleanup ───────────────────────────────────────────────────
        let _ = KillTimer(hwnd, TIMER_ID);
        let ptr = GetWindowLongPtrW(hwnd, GWLP_USERDATA) as *mut AboutState;
        if !ptr.is_null() {
            SetWindowLongPtrW(hwnd, GWLP_USERDATA, 0);
            let state = Box::from_raw(ptr);
            let _ = DeleteDC(state.hdc_mem);
        }
        let _ = DeleteObject(hbitmap);
        let _ = DestroyWindow(hwnd);
        let _ = UnregisterClassW(class_name, None);
    }

    Ok(())
}

// ══════════════════════════════════════════════════════════════════════════════
// Background capture (BitBlt from screen DC)
// ══════════════════════════════════════════════════════════════════════════════

/// Captures a screen region as XRGB u32 buffer for glassmorphism background.
unsafe fn capture_screen_region(x: i32, y: i32, w: i32, h: i32) -> Vec<u32> {
    unsafe {
        let hdc_screen = GetDC(None);
        let hdc_mem = CreateCompatibleDC(hdc_screen);

        let bmi = BITMAPINFO {
            bmiHeader: BITMAPINFOHEADER {
                biSize: std::mem::size_of::<BITMAPINFOHEADER>() as u32,
                biWidth: w,
                biHeight: -h,
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
                return vec![0u32; (w * h) as usize];
            }
        };

        SelectObject(hdc_mem, hbm);
        let _ = BitBlt(hdc_mem, 0, 0, w, h, hdc_screen, x, y, SRCCOPY);

        let pixels = (w * h) as usize;
        let src = std::slice::from_raw_parts(bits_ptr as *const u32, pixels);
        let result = src.to_vec();

        let _ = DeleteObject(hbm);
        let _ = DeleteDC(hdc_mem);
        ReleaseDC(None, hdc_screen);

        result
    }
}

// ══════════════════════════════════════════════════════════════════════════════
// Render
// ══════════════════════════════════════════════════════════════════════════════

unsafe fn render_about_frame(hwnd: HWND) {
    unsafe {
        let ptr = GetWindowLongPtrW(hwnd, GWLP_USERDATA) as *mut AboutState;
        if ptr.is_null() { return; }
        let state = &mut *ptr;

        let pixels = (state.width * state.height) as usize;
        let buf = std::slice::from_raw_parts_mut(state.bitmap_bits, pixels);

        state.app.render(
            buf,
            state.width,
            state.height,
            &state.bg_buffer,
            &mut state.blur_buf_1,
            &mut state.blur_buf_2,
            20, // blur radius — same as Wayland
        );

        // Full-window BitBlt (About is small — 1000×618, no dirty rect needed)
        let hdc_win = GetDC(hwnd);
        let _ = BitBlt(
            hdc_win, 0, 0,
            state.width as i32, state.height as i32,
            state.hdc_mem, 0, 0,
            SRCCOPY,
        );
        ReleaseDC(hwnd, hdc_win);
    }
}

// ══════════════════════════════════════════════════════════════════════════════
// Window procedure
// ══════════════════════════════════════════════════════════════════════════════

unsafe extern "system" fn about_wnd_proc(
    hwnd: HWND, msg: u32, wparam: WPARAM, lparam: LPARAM,
) -> LRESULT {
    unsafe {
    match msg {
        WM_TIMER => {
            render_about_frame(hwnd);
            LRESULT(0)
        }

        WM_KEYDOWN => {
            let vk = wparam.0 as u16;
            if vk == VK_ESCAPE.0 {
                PostQuitMessage(0);
            }
            LRESULT(0)
        }

        WM_SETCURSOR => {
            // Switch to hand cursor when hovering over the URL.
            // Option chain: any None → fall through to DefWindowProc.
            let handled = (|| -> Option<()> {
                ((lparam.0 & 0xFFFF) as u16 == HTCLIENT as u16).then_some(())?;
                let state = (GetWindowLongPtrW(hwnd, GWLP_USERDATA) as *const AboutState).as_ref()?;
                let mut pt = POINT::default();
                let _ = GetCursorPos(&mut pt);
                let _ = ScreenToClient(hwnd, &mut pt);
                let (ux, uy, uw, uh) = state.app.url_bounds?;
                (pt.x >= ux && pt.x <= ux + uw && pt.y >= uy && pt.y <= uy + uh).then_some(())?;
                SetCursor(LoadCursorW(None, IDC_HAND).ok()?);
                Some(())
            })();
            if handled.is_some() { LRESULT(1) } else { DefWindowProcW(hwnd, msg, wparam, lparam) }
        }

        WM_LBUTTONDOWN => {
            // Click on URL → open homepage
            let ptr = GetWindowLongPtrW(hwnd, GWLP_USERDATA) as *const AboutState;
            if !ptr.is_null() {
                let state = &*ptr;
                let x = (lparam.0 & 0xFFFF) as i16 as i32;
                let y = ((lparam.0 >> 16) & 0xFFFF) as i16 as i32;
                if let Some((ux, uy, uw, uh)) = state.app.url_bounds
                    && x >= ux && x <= ux + uw && y >= uy && y <= uy + uh {
                        crate::daemon::open_homepage();
                    }
            }
            LRESULT(0)
        }

        // Click outside → close (WM_ACTIVATE with WA_INACTIVE)
        WM_ACTIVATE => {
            let activation = (wparam.0 & 0xFFFF) as u32;
            if activation == 0 { // WA_INACTIVE
                PostQuitMessage(0);
            }
            LRESULT(0)
        }

        WM_CLOSE => {
            PostQuitMessage(0);
            LRESULT(0)
        }

        _ => DefWindowProcW(hwnd, msg, wparam, lparam),
    }
    } // unsafe
}

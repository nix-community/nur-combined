//! Windows screen capture: DXGI Desktop Duplication (Tier 1) + GDI BitBlt (Tier 2).
//!
//! DXGI captures per-monitor at native resolution via GPU texture copy (~5ms).
//! GDI fallback captures the entire virtual screen via BitBlt (~30ms).
//! BGRA → XRGB conversion matches wlr.rs pixel format contract.

use std::time::Instant;
use anyhow::{Result, Context as _};
use windows::core::Interface;
use windows::Win32::Foundation::RECT;
use windows::Win32::Graphics::Direct3D::D3D_DRIVER_TYPE_UNKNOWN;
use windows::Win32::Graphics::Direct3D11::*;
use windows::Win32::Graphics::Dxgi::*;
use windows::Win32::Graphics::Dxgi::Common::*;
use windows::Win32::Graphics::Gdi::*;
use windows::Win32::System::Com::*;
use windows::Win32::UI::WindowsAndMessaging::*;

use super::{ScreenCapture, MonitorTile, PhysicalCanvas};
use crate::core::terminal::{log_step, log_warn};

// ══════════════════════════════════════════════════════════════════════════════
// Tier 1: DXGI Desktop Duplication (Windows 8+, GPU-accelerated)
// ══════════════════════════════════════════════════════════════════════════════

/// Capture all monitors via DXGI Desktop Duplication.
/// Enumerates adapters (GPUs) and outputs (monitors), captures each independently.
pub fn capture_dxgi() -> Result<PhysicalCanvas> {
    let start = Instant::now();

    unsafe {
        // COM init — ignore S_FALSE (already initialized)
        let _ = CoInitializeEx(None, COINIT_MULTITHREADED);

        let factory: IDXGIFactory1 = CreateDXGIFactory1()?;
        let mut tiles = Vec::new();
        let mut adapter_idx = 0u32;

        while let Ok(adapter) = factory.EnumAdapters1(adapter_idx) {
            // D3D11CreateDevice expects IDXGIAdapter, not IDXGIAdapter1
            let adapter_base: IDXGIAdapter = adapter.cast()?;

            // Create D3D11 device for this GPU
            let mut device = None;
            let mut ctx = None;
            let hr = D3D11CreateDevice(
                Some(&adapter_base),
                D3D_DRIVER_TYPE_UNKNOWN,
                None,
                D3D11_CREATE_DEVICE_FLAG(0),
                None,
                D3D11_SDK_VERSION,
                Some(&mut device),
                None,
                Some(&mut ctx),
            );

            if hr.is_err() || device.is_none() {
                adapter_idx += 1;
                continue;
            }
            let device = device.unwrap();
            let ctx = ctx.unwrap();

            // Enumerate monitors on this GPU
            let mut output_idx = 0u32;
            while let Ok(output) = adapter.EnumOutputs(output_idx) {
                match capture_output_dxgi(&device, &ctx, &output) {
                    Ok(tile) => tiles.push(tile),
                    Err(e) => log_warn(&format!("DXGI skip output {}.{}: {}", adapter_idx, output_idx, e)),
                }
                output_idx += 1;
            }

            adapter_idx += 1;
        }

        if tiles.is_empty() {
            anyhow::bail!("DXGI: no monitors captured");
        }

        log_step("Capture", &format!(
            "DXGI: {}ms ({} monitor{})",
            start.elapsed().as_millis(),
            tiles.len(),
            if tiles.len() == 1 { "" } else { "s" },
        ));
        Ok(PhysicalCanvas::build(tiles))
    }
}

/// Capture a single output via DXGI Desktop Duplication.
unsafe fn capture_output_dxgi(
    device: &ID3D11Device,
    ctx: &ID3D11DeviceContext,
    output: &IDXGIOutput,
) -> Result<MonitorTile> {
    unsafe {
        let desc = output.GetDesc()?;
        let output1: IDXGIOutput1 = output.cast()?;

        // Duplicate the output surface
        let duplication = output1.DuplicateOutput(device)
            .context("DuplicateOutput failed (GPU exclusive? RDP session?)")?;

        // NOTE: first AcquireNextFrame on a static desktop may return black
        // (DXGI only delivers frames on compositor updates). In real usage the
        // user has been active (hotkey press → mouse movement) so this is fine.
        // If --capture-test shows black, it's a cold-start artifact, not a bug.

        // Acquire the frame (1s timeout)
        let mut frame_info = DXGI_OUTDUPL_FRAME_INFO::default();
        let mut resource = None;
        duplication.AcquireNextFrame(1000, &mut frame_info, &mut resource)?;
        let resource = resource.context("AcquireNextFrame returned no resource")?;

        // Get the captured texture
        let texture: ID3D11Texture2D = resource.cast()?;
        let mut tex_desc = D3D11_TEXTURE2D_DESC::default();
        texture.GetDesc(&mut tex_desc);

        // Create a staging texture we can read from CPU
        let staging_desc = D3D11_TEXTURE2D_DESC {
            Width: tex_desc.Width,
            Height: tex_desc.Height,
            MipLevels: 1,
            ArraySize: 1,
            Format: tex_desc.Format,
            SampleDesc: DXGI_SAMPLE_DESC { Count: 1, Quality: 0 },
            Usage: D3D11_USAGE_STAGING,
            BindFlags: 0,
            CPUAccessFlags: D3D11_CPU_ACCESS_READ.0 as u32,
            MiscFlags: 0,
        };
        let mut staging: Option<ID3D11Texture2D> = None;
        device.CreateTexture2D(&staging_desc, None, Some(&mut staging))?;
        let staging = staging.context("CreateTexture2D returned None")?;

        // GPU copy: captured frame → staging texture
        let staging_res: ID3D11Resource = staging.cast()?;
        let texture_res: ID3D11Resource = texture.cast()?;
        ctx.CopyResource(&staging_res, &texture_res);

        // Map staging texture for CPU read
        let mut mapped = D3D11_MAPPED_SUBRESOURCE::default();
        ctx.Map(&staging_res, 0, D3D11_MAP_READ, 0, Some(&mut mapped))?;

        let width = tex_desc.Width;
        let height = tex_desc.Height;
        let xrgb_buffer = bgra_to_xrgb(mapped.pData as *const u8, width, height, mapped.RowPitch);

        ctx.Unmap(&staging_res, 0);
        duplication.ReleaseFrame()?;

        // Monitor position in virtual desktop coordinates
        let rect: RECT = desc.DesktopCoordinates;
        Ok(MonitorTile {
            capture: ScreenCapture { xrgb_buffer, width, height },
            scale: 1.0,
            logical_pos: (rect.left, rect.top),
            logical_w: width as i32,
            logical_h: height as i32,
        })
    }
}

// ══════════════════════════════════════════════════════════════════════════════
// Tier 2: GDI BitBlt (fallback for VMs, RDP, old GPUs)
// ══════════════════════════════════════════════════════════════════════════════

/// Capture the entire virtual screen via GDI BitBlt.
/// Single-tile capture covering all monitors.
pub fn capture_gdi() -> Result<PhysicalCanvas> {
    let start = Instant::now();

    unsafe {
        // Virtual screen covers all monitors (may have negative coords)
        let x = GetSystemMetrics(SM_XVIRTUALSCREEN);
        let y = GetSystemMetrics(SM_YVIRTUALSCREEN);
        let width = GetSystemMetrics(SM_CXVIRTUALSCREEN) as u32;
        let height = GetSystemMetrics(SM_CYVIRTUALSCREEN) as u32;

        if width == 0 || height == 0 {
            anyhow::bail!("GDI: virtual screen is 0x0");
        }

        let hdc_screen = GetDC(None);
        let hdc_mem = CreateCompatibleDC(hdc_screen);
        let hbitmap = CreateCompatibleBitmap(hdc_screen, width as i32, height as i32);
        let old = SelectObject(hdc_mem, hbitmap);

        // CAPTUREBLT — required to capture layered (semi-transparent) windows
        BitBlt(hdc_mem, 0, 0, width as i32, height as i32,
               hdc_screen, x, y, SRCCOPY | CAPTUREBLT)?;

        let mut bmi = BITMAPINFO {
            bmiHeader: BITMAPINFOHEADER {
                biSize: std::mem::size_of::<BITMAPINFOHEADER>() as u32,
                biWidth: width as i32,
                biHeight: -(height as i32), // negative = top-down DIB
                biPlanes: 1,
                biBitCount: 32,
                biCompression: BI_RGB.0,
                ..Default::default()
            },
            ..Default::default()
        };

        let mut pixels = vec![0u32; (width * height) as usize];
        GetDIBits(
            hdc_mem, hbitmap, 0, height,
            Some(pixels.as_mut_ptr() as *mut _),
            &mut bmi,
            DIB_RGB_COLORS,
        );

        // GDI 32-bit DIB: memory [B,G,R,0] → u32 little-endian = 0x00RRGGBB
        // Already in our XRGB format — no conversion needed.

        // Cleanup GDI objects
        SelectObject(hdc_mem, old);
        let _ = DeleteObject(hbitmap);
        let _ = DeleteDC(hdc_mem);
        ReleaseDC(None, hdc_screen);

        log_step("Capture", &format!(
            "GDI BitBlt: {}ms ({}x{})", start.elapsed().as_millis(), width, height,
        ));

        Ok(PhysicalCanvas::from_single(ScreenCapture {
            xrgb_buffer: pixels,
            width,
            height,
        }))
    }
}

// ══════════════════════════════════════════════════════════════════════════════
// Pixel conversion: BGRA → XRGB
// ══════════════════════════════════════════════════════════════════════════════

/// Convert DXGI BGRA pixels to XRGB u32 (mask out alpha channel).
/// Handles stride != width*4 (DXGI textures may have row padding).
///
/// Memory layout:  [B, G, R, A]  →  u32 little-endian = 0xAARRGGBB
/// We want:                         u32               = 0x00RRGGBB
/// Conversion:     pixel & 0x00FF_FFFF
fn bgra_to_xrgb(ptr: *const u8, width: u32, height: u32, stride: u32) -> Vec<u32> {
    let num_pixels = (width * height) as usize;

    // Fast path: tightly packed rows — bytemuck cast + alpha mask
    if stride == width * 4 {
        let byte_len = num_pixels * 4;
        let slice = unsafe { std::slice::from_raw_parts(ptr, byte_len) };
        if let Ok(u32s) = bytemuck::try_cast_slice::<u8, u32>(slice) {
            return u32s.iter().map(|&p| p & 0x00FF_FFFF).collect();
        }
    }

    // Slow path: row-by-row with stride (padding between rows)
    let mut buf = Vec::with_capacity(num_pixels);
    for row in 0..height {
        let row_ptr = unsafe { ptr.add((row * stride) as usize) };
        let row_slice = unsafe { std::slice::from_raw_parts(row_ptr, (width * 4) as usize) };
        for chunk in row_slice.chunks_exact(4) {
            let b = chunk[0] as u32;
            let g = chunk[1] as u32;
            let r = chunk[2] as u32;
            buf.push((r << 16) | (g << 8) | b);
        }
    }
    buf
}

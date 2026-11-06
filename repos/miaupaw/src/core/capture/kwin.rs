// ══════════════════════════════════════════════════════════════════════════════
// KWin ScreenShot2 DBus — direct inject into compositor.
//
// Two modes:
//   capture_output_dbus(conn, name) — capture a specific monitor by name.
//   capture_screen_dbus(conn)       — capture the active screen (single-tile fallback).
//
// Protocol: SCM_RIGHTS passes fd to KWin, which writes raw pixels directly into it
// (byte order and stride from the reply metadata).
// Authorization: silent → interactive retry on NoAuthorized.
// ══════════════════════════════════════════════════════════════════════════════

use anyhow::{Result, anyhow};
use std::fs::File;
use std::time::{Duration, Instant};

use crate::core::terminal::{log_step, log_warn, log_info};
use super::{ScreenCapture, rgba_to_capture};

/// **The Ghost DBus Call**
/// Fires directly at KWin. Works only if our app is authorized,
/// which requires a correct .desktop file with `X-KDE-DBUS-Restricted-Interfaces`.
/// Has a fallback matrix: first tries silently, and if NoAuthorized is returned,
/// retries with `interactive=true`, requesting permission from the compositor.
pub fn capture_screen_dbus(conn: &zbus::blocking::Connection) -> Result<ScreenCapture> {
    // 1. Attempt silent capture (fast, <10ms, if authorized)
    match perform_kwin_capture(conn, false, None) {
        Ok(img) => Ok(img),
        Err(e) => {
            let err_str = e.to_string();
            // 2. If KWin says "Not authorized", request permission interactively
            if err_str.contains("NoAuthorized") {
                log_warn("KWin Authorization missing. Retrying with interactive prompt...");
                log_info("Action Required: Please click 'Allow' and check 'Remember' in the KWin dialog!");

                // 3. Attempt interactive capture (shows dialog if user hasn't saved the choice)
                match perform_kwin_capture(conn, true, None) {
                    Ok(img) => {
                        log_info("Interactive authorization granted! Next time it will be silent.");
                        Ok(img)
                    }
                    Err(e2) => Err(anyhow!("KWin Interactive Capture failed: {}", e2)),
                }
            } else {
                Err(e)
            }
        }
    }
}

/// Capture a specific monitor by name (KWin ScreenShot2 → CaptureScreen).
/// For Plasma multi-monitor: called separately for each output.
pub fn capture_output_dbus(
    conn: &zbus::blocking::Connection,
    screen_name: &str,
) -> Result<ScreenCapture> {
    perform_kwin_capture(conn, false, Some(screen_name))
}

fn perform_kwin_capture(
    conn: &zbus::blocking::Connection,
    interactive: bool,
    // Some(name) → CaptureScreen(name)  /  None → CaptureActiveScreen
    screen_name: Option<&str>,
) -> Result<ScreenCapture> {
    use std::collections::HashMap;
    use std::os::unix::io::AsFd;
    use tempfile::NamedTempFile;
    use zbus::zvariant::OwnedValue;

    let t0 = Instant::now();

    // 1. FD setup (File Descriptor Matrix)
    // Create a Unix temp file. KWin will dump raw pixels directly into it.
    // No PNG encoding — raw bytes only.
    let temp_file = NamedTempFile::new()?;

    // Convert file to descriptor. SCM_RIGHTS protocol clones it into the compositor process.
    let fd = zbus::zvariant::Fd::from(temp_file.as_fd());

    let mut options: HashMap<String, OwnedValue> = HashMap::new();
    options.insert("interactive".to_string(), OwnedValue::from(interactive));
    options.insert("native-resolution".to_string(), OwnedValue::from(true));

    let t1 = Instant::now();

    // 2. Injection (The Trigger)
    // Make the call. At this point the kernel (via SCM_RIGHTS) secretly passes our `fd`
    // directly into KWin compositor's internal file descriptor table.
    let reply = if let Some(name) = screen_name {
        conn.call_method(
            Some("org.kde.KWin"),
            "/org/kde/KWin/ScreenShot2",
            Some("org.kde.KWin.ScreenShot2"),
            "CaptureScreen",
            &(name, options, fd),
        )?
    } else {
        conn.call_method(
            Some("org.kde.KWin"),
            "/org/kde/KWin/ScreenShot2",
            Some("org.kde.KWin.ScreenShot2"),
            "CaptureActiveScreen",
            &(options, fd),
        )?
    };

    let t2 = Instant::now();
    log_step("Capture", &format!("KWin DBus: {}ms", (t2 - t1).as_millis()));

    let metadata: HashMap<String, OwnedValue> = reply.body().deserialize()?;
    let width = metadata
        .get("width")
        .and_then(|v| u32::try_from(v).ok())
        .unwrap_or(0);
    let height = metadata
        .get("height")
        .and_then(|v| u32::try_from(v).ok())
        .unwrap_or(0);
    let reply_type = metadata
        .get("type")
        .and_then(|v| <&str>::try_from(v).ok())
        .unwrap_or("unknown");

    // KWin sends the QImage::Format and bytesPerLine of the raw buffer.
    // Plasma 6.8 reads back via glReadPixels(GL_RGBA) → Format_RGBX8888; older
    // KWin sent ARGB32. Missing keys (very old KWin) → assume tight ARGB32.
    let format = metadata.get("format").and_then(|v| u32::try_from(v).ok());
    let stride = metadata
        .get("stride")
        .and_then(|v| u32::try_from(v).ok())
        .unwrap_or(width * 4);

    if width == 0 || height == 0 {
        return Err(anyhow!("KWin capture: invalid dimensions {}x{}", width, height));
    }
    let layout = if reply_type == "raw" {
        let layout = RawLayout::from_qimage_format(format).ok_or_else(|| {
            anyhow!("KWin capture: unsupported QImage format {:?} — falling back", format)
        })?;
        if stride < width * 4 {
            return Err(anyhow!("KWin capture: stride {} too small for width {}", stride, width));
        }
        Some(layout)
    } else {
        None
    };
    let expected_size = stride as u64 * height as u64;
    // Pre-allocate: we know the exact size (14MB for 2560×1440).
    // Without this, Vec grows through 3-4 reallocs (0→4K→32K→...→14MB).
    let mut bytes = Vec::with_capacity(expected_size as usize);
    let mut poll_count = 0u32;
    let t3 = Instant::now();
    let mut file = File::open(temp_file.path())?;

    use std::io::{Read, Seek, SeekFrom};

    while t3.elapsed() < Duration::from_millis(500) {
        // seek(End) is cheaper than metadata().len(): one lseek vs fstat
        let current_size = file.seek(SeekFrom::End(0)).unwrap_or(0);
        if reply_type == "raw" && current_size >= expected_size {
            file.seek(SeekFrom::Start(0))?;
            let t_read = Instant::now();
            file.read_to_end(&mut bytes)?;
            log_step("Capture", &format!("File read: {}ms ({}MB)", t_read.elapsed().as_millis(), bytes.len() / 1_000_000));
            break;
        } else if reply_type != "raw" && current_size > 0 {
            file.seek(SeekFrom::Start(0))?;
            file.read_to_end(&mut bytes)?;
            break;
        }
        poll_count += 1;
        std::thread::sleep(Duration::from_millis(1));
    }

    let t4 = Instant::now();
    log_step("Capture", &format!("Polling: {}ms ({} polls)", (t4 - t3).as_millis(), poll_count));

    if bytes.is_empty() {
        return Err(anyhow!("DBus capture resulted in empty or incomplete data"));
    }

    if let Some(layout) = layout {
        if bytes.len() >= expected_size as usize {
            let xrgb = raw_to_xrgb(bytes, width, height, stride, layout);
            log_step("Capture", &format!(
                "Total: {}ms ({}x{}, type={}, format={:?}, stride={})",
                t0.elapsed().as_millis(), width, height, reply_type, format, stride
            ));
            return Ok(ScreenCapture {
                xrgb_buffer: xrgb,
                width,
                height,
            });
        } else {
            log_warn(&format!("Raw capture size mismatch: expected >= {}, got {}", expected_size, bytes.len()));
        }
    }

    let reader = image::ImageReader::new(std::io::Cursor::new(bytes)).with_guessed_format()?;
    let dyn_img = reader.decode()?;
    Ok(rgba_to_capture(&dyn_img.to_rgba8()))
}

/// Byte order of a 32-bit raw KWin buffer, derived from its QImage::Format.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum RawLayout {
    /// RGB32 / ARGB32 / ARGB32_Premultiplied: native u32 0xAARRGGBB,
    /// little-endian memory [B,G,R,A].
    Bgrx,
    /// RGBX8888 / RGBA8888 / RGBA8888_Premultiplied: memory [R,G,B,A].
    Rgbx,
}

impl RawLayout {
    /// Map a QImage::Format value. Premultiplied alpha is ignored: screen
    /// pixels are opaque. Anything else (10-bit, 16-bit, float) → None.
    fn from_qimage_format(format: Option<u32>) -> Option<Self> {
        match format {
            // Format_RGB32 = 4, Format_ARGB32 = 5, Format_ARGB32_Premultiplied = 6
            None | Some(4..=6) => Some(RawLayout::Bgrx),
            // Format_RGBX8888 = 16, Format_RGBA8888 = 17, Format_RGBA8888_Premultiplied = 18
            Some(16..=18) => Some(RawLayout::Rgbx),
            _ => None,
        }
    }
}

/// Convert a raw KWin buffer to XRGB u32, honoring stride and byte order.
/// Caller guarantees `bytes.len() >= stride * height` and `stride >= width * 4`.
fn raw_to_xrgb(mut bytes: Vec<u8>, width: u32, height: u32, stride: u32, layout: RawLayout) -> Vec<u32> {
    let num_pixels = (width * height) as usize;

    // Fast path: tightly packed native ARGB32 — zero-copy cast if the
    // allocator returned an aligned pointer (usually yes), then mask alpha.
    if layout == RawLayout::Bgrx && stride == width * 4 {
        bytes.truncate(num_pixels * 4);
        let mut xrgb: Vec<u32> = match bytemuck::try_cast_vec(bytes) {
            Ok(v) => v,
            Err((_err, bytes)) => bytes
                .as_chunks::<4>().0
                .iter()
                .map(|c| u32::from_le_bytes([c[0], c[1], c[2], c[3]]))
                .collect(),
        };
        xrgb.iter_mut().for_each(|p| *p &= 0x00FF_FFFF);
        return xrgb;
    }

    // Slow path: byte-by-byte, row by row (padding between rows)
    let mut buf = Vec::with_capacity(num_pixels);
    for row in bytes.chunks_exact(stride as usize).take(height as usize) {
        for c in row[..width as usize * 4].as_chunks::<4>().0 {
            let (r, g, b) = match layout {
                RawLayout::Rgbx => (c[0], c[1], c[2]),
                RawLayout::Bgrx => (c[2], c[1], c[0]),
            };
            buf.push(((r as u32) << 16) | ((g as u32) << 8) | (b as u32));
        }
    }
    buf
}

// Tests live in kwin_tests.rs (test mechanics out of the logic file).
#[cfg(test)]
#[path = "kwin_tests.rs"]
mod tests;

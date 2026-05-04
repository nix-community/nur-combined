// ══════════════════════════════════════════════════════════════════════════════
// WLR Screencopy — frame capture via zwlr_screencopy_manager_v1.
//
// Each capture_output() call creates a private event queue and runs completely
// isolated from the main event loop. This allows capturing multiple monitors
// in parallel (one thread per output).
//
// ShmRegion — RAII wrapper over memfd+mmap, guaranteeing cleanup on any
// exit path (including early ? return).
// ══════════════════════════════════════════════════════════════════════════════

use super::ScreenCapture;
use crate::core::terminal::{log_step, log_warn};
use std::time::{Duration, Instant};
use wayland_client::{
    Connection, Dispatch, QueueHandle,
    protocol::{wl_buffer, wl_output, wl_shm, wl_shm_pool},
};
use wayland_protocols_wlr::screencopy::v1::client::{
    zwlr_screencopy_frame_v1::{self, ZwlrScreencopyFrameV1},
    zwlr_screencopy_manager_v1::ZwlrScreencopyManagerV1,
};

// ── RAII wrapper for shared memory region ────────────────────────────────────

/// Anonymous in-memory file (memfd) + mmap. Drop cleans up both resources.
struct ShmRegion {
    ptr: *mut libc::c_void,
    size: usize,
    fd: i32,
}

impl ShmRegion {
    /// Creates memfd + mmap of the required size.
    fn new(size: usize) -> anyhow::Result<Self> {
        unsafe {
            let name = b"ie-r-screencopy\0";
            let fd = libc::memfd_create(name.as_ptr() as *const libc::c_char, libc::MFD_CLOEXEC);
            if fd < 0 {
                return Err(anyhow::anyhow!("Failed to create memfd"));
            }
            if libc::ftruncate(fd, size as libc::off_t) < 0 {
                libc::close(fd);
                return Err(anyhow::anyhow!("Failed to resize memfd"));
            }
            let ptr = libc::mmap(
                std::ptr::null_mut(),
                size,
                libc::PROT_READ | libc::PROT_WRITE,
                libc::MAP_SHARED,
                fd,
                0,
            );
            if ptr == libc::MAP_FAILED {
                libc::close(fd);
                return Err(anyhow::anyhow!("Failed to mmap"));
            }
            Ok(Self { ptr, size, fd })
        }
    }

    /// Raw pointer to the mapped memory.
    fn as_ptr(&self) -> *const u8 {
        self.ptr as *const u8
    }

    /// BorrowedFd for creating a Wayland SHM Pool.
    fn borrowed_fd(&self) -> std::os::fd::BorrowedFd<'_> {
        unsafe { std::os::fd::BorrowedFd::borrow_raw(self.fd) }
    }
}

impl Drop for ShmRegion {
    fn drop(&mut self) {
        unsafe {
            libc::munmap(self.ptr, self.size);
            libc::close(self.fd);
        }
    }
}

// ── Capture handler (inline state, no Arc<Mutex>) ───────────────────────────

/// Frame capture state for WLR Screencopy.
/// Lives on the capture_output() stack — Arc<Mutex> not needed,
/// handler and state are on the same thread in the same event queue.
struct WlrCaptureHandler {
    buffer_info: Option<(u32, u32, u32, wl_shm::Format)>,
    ready: bool,
    failed: bool,
}

impl WlrCaptureHandler {
    fn new() -> Self {
        Self { buffer_info: None, ready: false, failed: false }
    }
}

impl Dispatch<ZwlrScreencopyFrameV1, ()> for WlrCaptureHandler {
    fn event(
        state: &mut Self,
        _frame: &ZwlrScreencopyFrameV1,
        event: zwlr_screencopy_frame_v1::Event,
        _: &(),
        _: &Connection,
        _: &QueueHandle<Self>,
    ) {
        match event {
            zwlr_screencopy_frame_v1::Event::Buffer {
                format, width, height, stride,
            } => {
                let fmt = format.into_result().unwrap_or(wl_shm::Format::Xrgb8888);
                state.buffer_info = Some((width, height, stride, fmt));
            }
            zwlr_screencopy_frame_v1::Event::Ready { .. } => {
                state.ready = true;
            }
            zwlr_screencopy_frame_v1::Event::Failed => {
                state.failed = true;
            }
            _ => {}
        }
    }
}

// Empty dispatchers for protocols with no client-side events
impl Dispatch<wl_buffer::WlBuffer, ()> for WlrCaptureHandler {
    fn event(_: &mut Self, _: &wl_buffer::WlBuffer, _: wl_buffer::Event, _: &(), _: &Connection, _: &QueueHandle<Self>) {}
}

impl Dispatch<wl_shm_pool::WlShmPool, ()> for WlrCaptureHandler {
    fn event(_: &mut Self, _: &wl_shm_pool::WlShmPool, _: wl_shm_pool::Event, _: &(), _: &Connection, _: &QueueHandle<Self>) {}
}

// ── Public API ──────────────────────────────────────────────────────────────

/// Performs an instant screen capture via wlr-screencopy.
/// Each call is an isolated round-trip with a private event queue.
pub fn capture_output(
    conn: &Connection,
    manager: &ZwlrScreencopyManagerV1,
    shm: &wl_shm::WlShm,
    output: &wl_output::WlOutput,
) -> anyhow::Result<ScreenCapture> {
    let mut event_queue = conn.new_event_queue();
    let qh = event_queue.handle();
    let mut handler = WlrCaptureHandler::new();

    // 1. Request capture of a specific monitor
    let frame = manager.capture_output(0, output, &qh, ());

    // 2. Wait for Buffer event (compositor will report memory parameters)
    let start = Instant::now();
    loop {
        event_queue.blocking_dispatch(&mut handler)?;
        if handler.failed {
            return Err(anyhow::anyhow!("WLR Screencopy failed at initialization"));
        }
        if handler.buffer_info.is_some() {
            break;
        }
        if start.elapsed() > Duration::from_millis(500) {
            return Err(anyhow::anyhow!("WLR Screencopy timeout waiting for Buffer info"));
        }
    }

    let (width, height, stride, format) = handler.buffer_info
        .ok_or_else(|| anyhow::anyhow!("WLR Screencopy: compositor sent no Buffer info"))?;

    if width == 0 || height == 0 {
        return Err(anyhow::anyhow!("WLR Screencopy: invalid dimensions {}x{}", width, height));
    }
    if stride < width.saturating_mul(4) {
        return Err(anyhow::anyhow!("WLR Screencopy: stride {} too small for width {}", stride, width));
    }
    let size = (stride as u64 * height as u64) as usize;

    // 3. RAII: memfd + mmap — Drop guarantees cleanup on any exit path
    let region = ShmRegion::new(size)?;

    // 4. Create Wayland SHM Pool and Buffer
    let pool = shm.create_pool(region.borrowed_fd(), size as i32, &qh, ());
    let buffer = pool.create_buffer(0, width as i32, height as i32, stride as i32, format, &qh, ());

    // 5. Signal compositor to write pixels into our buffer
    frame.copy(&buffer);

    // 6. Wait for Ready event
    loop {
        event_queue.blocking_dispatch(&mut handler)?;
        if handler.failed {
            return Err(anyhow::anyhow!("WLR Screencopy failed during copy"));
        }
        if handler.ready {
            break;
        }
        if start.elapsed() > Duration::from_millis(1000) {
            return Err(anyhow::anyhow!("WLR Screencopy timeout waiting for Ready"));
        }
    }

    // 7. Convert raw data → XRGB u32 vector
    let xrgb_buffer = convert_to_xrgb(region.as_ptr(), width, height, stride, format);

    log_step("Capture", &format!(
        "WLR Screencopy: {}ms ({}x{}, {:?})",
        start.elapsed().as_millis(), width, height, format,
    ));

    // 8. Clean up Wayland objects (ShmRegion is cleaned via Drop)
    frame.destroy();
    buffer.destroy();
    pool.destroy();

    Ok(ScreenCapture { xrgb_buffer, width, height })
}

/// Convert raw pixels to XRGB u32.
///
/// For Xrgb8888/Argb8888 (native little-endian) — zero-copy via bytemuck.
/// For exotic formats — byte-by-byte fallback.
fn convert_to_xrgb(ptr: *const u8, width: u32, height: u32, stride: u32, format: wl_shm::Format) -> Vec<u32> {
    let num_pixels = (width * height) as usize;

    // Fast path: if stride == width*4 (no padding) and format is native —
    // a zero-copy cast of the entire block is possible.
    let tightly_packed = stride == width * 4;

    if tightly_packed && matches!(format, wl_shm::Format::Xbgr8888 | wl_shm::Format::Abgr8888) {
        // Xbgr8888 little-endian: [R,G,B,X] → swap R↔B to get 0x00RRGGBB
        let byte_len = num_pixels * 4;
        let slice = unsafe { std::slice::from_raw_parts(ptr, byte_len) };
        return slice.chunks_exact(4).map(|c| {
            ((c[0] as u32) << 16) | ((c[1] as u32) << 8) | (c[2] as u32)
        }).collect();
    }

    if tightly_packed && matches!(format, wl_shm::Format::Xrgb8888 | wl_shm::Format::Argb8888) {
        let byte_len = num_pixels * 4;
        let slice = unsafe { std::slice::from_raw_parts(ptr, byte_len) };
        // In little-endian [B,G,R,X] reads as u32 = 0xXRGB — exactly our format.
        // Alignment check: mmap is usually aligned, but if not — fallback to slow path.
        let u32_slice: &[u32] = match bytemuck::try_cast_slice(slice) {
            Ok(s) => s,
            Err(_) => {
                // Misaligned mmap — byte-by-byte fallback
                return slice.chunks_exact(4)
                    .map(|c| u32::from_ne_bytes([c[0], c[1], c[2], c[3]]))
                    .collect();
            }
        };
        if format == wl_shm::Format::Argb8888 {
            // Mask out the alpha channel
            return u32_slice.iter().map(|&p| p & 0x00FF_FFFF).collect();
        }
        return u32_slice.to_vec();
    }

    match format {
        wl_shm::Format::Xrgb8888 | wl_shm::Format::Argb8888
        | wl_shm::Format::Xbgr8888 | wl_shm::Format::Abgr8888 => {}
        _ => log_warn(&format!(
            "Exotic pixel format detected: {:?} — colors may be wrong. \
             Please report at https://github.com/spicebrains/ie-r/issues",
            format
        )),
    }

    let size = (stride * height) as usize;
    let slice = unsafe { std::slice::from_raw_parts(ptr, size) };
    let mut buf = Vec::with_capacity(num_pixels);

    for row in 0..height {
        let row_start = (row * stride) as usize;
        let row_slice = &slice[row_start..row_start + (width * 4) as usize];

        for chunk in row_slice.chunks_exact(4) {
            let (r, g, b) = match format {
                // Xbgr8888/Abgr8888 little-endian: [R,G,B,X]
                wl_shm::Format::Xbgr8888 | wl_shm::Format::Abgr8888 =>
                    (chunk[0] as u32, chunk[1] as u32, chunk[2] as u32),
                // Xrgb8888/Argb8888 little-endian: [B,G,R,X]
                _ =>
                    (chunk[2] as u32, chunk[1] as u32, chunk[0] as u32),
            };
            buf.push((r << 16) | (g << 8) | b);
        }
    }

    buf
}

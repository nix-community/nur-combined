#[cfg(unix)]
pub mod kwin;
#[cfg(unix)]
pub mod portal;
#[cfg(unix)]
pub mod wlr;
#[cfg(windows)]
pub mod windows;

// Re-export for X11 connector and backwards compatibility.
#[cfg(unix)]
pub use portal::capture_screen;

use anyhow::Result;
#[cfg(unix)]
use crate::core::terminal::{log_step, log_warn};
#[cfg(unix)]
use wayland_client::protocol::wl_output;

// ══════════════════════════════════════════════════════════════════════════════
// Capture pipeline data types.
//
// ScreenCapture  — raw XRGB8888 buffer for a single monitor.
// MonitorTile    — ScreenCapture + tile metadata (scale, position, output).
// PhysicalCanvas — virtual mosaic of all monitors, unified interface for
//                  overlay/render/input regardless of capture method.
// ══════════════════════════════════════════════════════════════════════════════

/// Screenshot data ready for SHM/HBITMAP (XRGB8888)
pub struct ScreenCapture {
    pub xrgb_buffer: Vec<u32>,
    pub width: u32,
    pub height: u32,
}

pub struct MonitorTile {
    pub capture: ScreenCapture,
    /// Platform-specific output handle (WlOutput on Unix, unused on Windows for now)
    #[cfg(unix)]
    pub output: Option<wayland_client::protocol::wl_output::WlOutput>,
    /// Fractional scale factor (e.g. 1.0, 1.5, 2.0).
    /// Used to translate pointer events (logical) → world coordinates.
    pub scale: f64,
    /// Logical position of this monitor in compositor space.
    pub logical_pos: (i32, i32),
    /// Logical (post-transform) dimensions reported by the compositor.
    /// Stored verbatim so cross-tile probes don't have to reconstruct them
    /// from `capture.width / scale` (which round-trips through f64).
    pub logical_w: i32,
    pub logical_h: i32,
    #[cfg(unix)]
    pub transform: wl_output::Transform,
}

impl MonitorTile {
    /// Construct a tile from capture + output metadata.
    /// Scale = capture_width / logical_width (fractional scaling).
    #[cfg(unix)]
    pub fn from_capture(
        capture: ScreenCapture,
        output: wayland_client::protocol::wl_output::WlOutput,
        logical_pos: (i32, i32),
        logical_w: i32,
        logical_h: i32,
        transform: wl_output::Transform,
    ) -> Self {
        let capture = apply_transform(capture, transform);
        let scale = if logical_w > 0 {
            capture.width as f64 / logical_w as f64
        } else {
            1.0
        };
        Self { capture, output: Some(output), scale, logical_pos, logical_w, logical_h, transform }
    }
}

/// Virtual mosaic of all captured monitors.
///
/// No single contiguous buffer — each tile lives in its own allocation.
/// Pixel lookup is O(N) where N = number of monitors (typically 1–4).
pub struct PhysicalCanvas {
    pub tiles: Vec<MonitorTile>,
    /// Index of the tile where the overlay surface currently lives.
    pub active_idx: usize,
}

impl PhysicalCanvas {
    /// Create a canvas from a set of tiles.
    pub fn build(tiles: Vec<MonitorTile>) -> Self {
        Self { tiles, active_idx: 0 }
    }

    /// Tile index by wl_output. O(N), N = number of monitors (1–4).
    #[cfg(unix)]
    pub fn find_tile(&self, output: &wayland_client::protocol::wl_output::WlOutput) -> Option<usize> {
        self.tiles.iter().position(|t| t.output.as_ref() == Some(output))
    }

    /// Like find_tile, but falls back to 0 (for input — cursor is always on some monitor).
    #[cfg(unix)]
    pub fn tile_index_for(&self, output: &wayland_client::protocol::wl_output::WlOutput) -> usize {
        self.find_tile(output).unwrap_or(0)
    }

    /// Create a canvas from a single full-desktop capture (Portal, X11, KWin).
    #[cfg(unix)]
    pub fn from_single(capture: ScreenCapture, output: Option<wayland_client::protocol::wl_output::WlOutput>) -> Self {
        let logical_w = capture.width as i32;
        let logical_h = capture.height as i32;
        Self {
            tiles: vec![MonitorTile {
                capture,
                output,
                scale: 1.0,
                logical_pos: (0, 0),
                logical_w,
                logical_h,
                transform: wl_output::Transform::Normal,
            }],
            active_idx: 0,
        }
    }

    /// Create a canvas from a single full-desktop capture (Windows / headless).
    #[cfg(windows)]
    pub fn from_single(capture: ScreenCapture) -> Self {
        let logical_w = capture.width as i32;
        let logical_h = capture.height as i32;
        Self {
            tiles: vec![MonitorTile {
                capture,
                scale: 1.0,
                logical_pos: (0, 0),
                logical_w,
                logical_h,
            }],
            active_idx: 0,
        }
    }

    /// Sample a pixel using active tile's local physical coordinates.
    /// If the point extends beyond the active tile, it does a raycast through
    /// the compositor's logical space to find the correct adjacent physical pixel.
    #[inline]
    pub fn sample(&self, local_x: i32, local_y: i32) -> Option<u32> {
        let active = self.active();

        // Fast path: point is inside the active tile
        if local_x >= 0 && (local_x as u32) < active.capture.width &&
           local_y >= 0 && (local_y as u32) < active.capture.height {
            let idx = local_y as usize * active.capture.width as usize + local_x as usize;
            return Some(active.capture.xrgb_buffer[idx]);
        }

        // Slower path: Raycast across logical space.
        // Convert local physical -> absolute logical coordinate
        let logical_x = active.logical_pos.0 + (local_x as f64 / active.scale).floor() as i32;
        let logical_y = active.logical_pos.1 + (local_y as f64 / active.scale).floor() as i32;

        for tile in &self.tiles {
            // Checking if the absolute logical pos hits this tile's logical box
            if logical_x >= tile.logical_pos.0 && logical_x < tile.logical_pos.0 + tile.logical_w &&
               logical_y >= tile.logical_pos.1 && logical_y < tile.logical_pos.1 + tile.logical_h {

                // Translate back to the target tile's local physical pixels
                let target_local_log_x = logical_x - tile.logical_pos.0;
                let target_local_log_y = logical_y - tile.logical_pos.1;

                let phys_x = (target_local_log_x as f64 * tile.scale).round() as i32;
                let phys_y = (target_local_log_y as f64 * tile.scale).round() as i32;

                if phys_x >= 0 && (phys_x as u32) < tile.capture.width &&
                   phys_y >= 0 && (phys_y as u32) < tile.capture.height {
                    let idx = phys_y as usize * tile.capture.width as usize + phys_x as usize;
                    return Some(tile.capture.xrgb_buffer[idx]);
                }
            }
        }
        None
    }

    /// Average color of (2*radius+1)² area around (cx, cy). radius=0 → single pixel.
    /// Cross-monitor aware via sample(). Out-of-bounds pixels are excluded from the average.
    pub fn sample_average(&self, cx: i32, cy: i32, radius: i32) -> (u8, u8, u8) {
        let mut sum_r = 0u32;
        let mut sum_g = 0u32;
        let mut sum_b = 0u32;
        let mut count = 0u32;
        for dy in -radius..=radius {
            for dx in -radius..=radius {
                if let Some(px) = self.sample(cx + dx, cy + dy) {
                    sum_r += (px >> 16) & 0xFF;
                    sum_g += (px >> 8) & 0xFF;
                    sum_b += px & 0xFF;
                    count += 1;
                }
            }
        }
        (
            sum_r.checked_div(count).unwrap_or(0) as u8,
            sum_g.checked_div(count).unwrap_or(0) as u8,
            sum_b.checked_div(count).unwrap_or(0) as u8,
        )
    }

    /// The tile where the overlay surface lives.
    /// Saturates to tile 0 if `active_idx` is out of range — `tiles` is
    /// guaranteed non-empty by every public constructor, so this never panics.
    pub fn active(&self) -> &MonitorTile {
        self.tiles.get(self.active_idx).unwrap_or(&self.tiles[0])
    }
}

/// Apply a Wayland output transform to an XRGB capture.
///
/// Each `wl_output::Transform` is decomposed into 3 booleans (whether dst dims
/// are rotated, whether each axis is reversed). Const generics monomorphize
/// the inner loop per variant — branches collapse at compile time, so the
/// hot path is identical to a hand-specialized rotation kernel.
#[cfg(unix)]
fn apply_transform(capture: ScreenCapture, transform: wl_output::Transform) -> ScreenCapture {
    use wl_output::Transform as T;
    match transform {
        T::Normal     => capture,
        T::Flipped    => rotate_xrgb::<false, true,  false>(capture),
        T::_180       => rotate_xrgb::<false, true,  true >(capture),
        T::Flipped180 => rotate_xrgb::<false, false, true >(capture),
        T::_90        => rotate_xrgb::<true,  true,  false>(capture),
        T::_270       => rotate_xrgb::<true,  false, true >(capture),
        T::Flipped90  => rotate_xrgb::<true,  true,  true >(capture),
        T::Flipped270 => rotate_xrgb::<true,  false, false>(capture),
        _ => capture,
    }
}

/// Rotation/flip kernel parametrized at compile time:
///   * `SWAP_DIMS` — output width/height are swapped (90°/270° rotations)
///   * `COL_FLIP`  — destination column index is reversed
///   * `ROW_FLIP`  — destination row index is reversed
///
/// All `if` checks below are on const generic params, so LLVM strips them
/// and emits 8 specialized loops (one per call site in `apply_transform`).
#[cfg(unix)]
#[inline]
fn rotate_xrgb<const SWAP_DIMS: bool, const COL_FLIP: bool, const ROW_FLIP: bool>(
    capture: ScreenCapture,
) -> ScreenCapture {
    let src_w = capture.width as usize;
    let src_h = capture.height as usize;
    let src = &capture.xrgb_buffer;
    let (dst_w, dst_h) = if SWAP_DIMS { (src_h, src_w) } else { (src_w, src_h) };
    let mut dst = vec![0u32; dst_w * dst_h];

    for y in 0..src_h {
        for x in 0..src_w {
            let col_src = if SWAP_DIMS { y } else { x };
            let row_src = if SWAP_DIMS { x } else { y };
            let col = if COL_FLIP { dst_w - 1 - col_src } else { col_src };
            let row = if ROW_FLIP { dst_h - 1 - row_src } else { row_src };
            dst[row * dst_w + col] = src[y * src_w + x];
        }
    }

    ScreenCapture { xrgb_buffer: dst, width: dst_w as u32, height: dst_h as u32 }
}

/// Copy a sub-rectangle out of an XRGB capture into a fresh buffer.
/// Caller must ensure (x+w, y+h) ≤ (src.width, src.height).
#[cfg(unix)]
pub(crate) fn crop_xrgb(src: &ScreenCapture, x: u32, y: u32, w: u32, h: u32) -> ScreenCapture {
    let src_w = src.width as usize;
    let xs = x as usize;
    let ws = w as usize;
    let mut buf = Vec::with_capacity(ws * h as usize);
    for row in 0..h as usize {
        let off = (y as usize + row) * src_w + xs;
        buf.extend_from_slice(&src.xrgb_buffer[off..off + ws]);
    }
    ScreenCapture { xrgb_buffer: buf, width: w, height: h }
}

/// Convert decoded RGBA image to XRGB u32 buffer
#[cfg(unix)]
pub(crate) fn rgba_to_capture(img: &image::RgbaImage) -> ScreenCapture {
    let (w, h) = img.dimensions();
    let raw = img.as_raw();
    let num = (w * h) as usize;
    let mut buf = Vec::with_capacity(num);
    for chunk in raw.chunks_exact(4) {
        buf.push(((chunk[0] as u32) << 16) | ((chunk[1] as u32) << 8) | (chunk[2] as u32));
    }
    ScreenCapture {
        xrgb_buffer: buf,
        width: w,
        height: h,
    }
}

// ══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════════════════════════════════════════════════════════

/// Output metadata pre-collected on the main thread (OutputState is !Send).
#[cfg(unix)]
pub struct OutputMeta {
    pub output: wayland_client::protocol::wl_output::WlOutput,
    pub name: String,
    pub logical_pos: (i32, i32),
    pub logical_w: i32,
    pub logical_h: i32,
    pub transform: wl_output::Transform,
}

/// Capture all monitors, selecting the best available protocol.
#[cfg(unix)]
pub fn capture_all_outputs(
    output_meta: &[OutputMeta],
    screencopy: Option<(&wayland_client::Connection, &wayland_protocols_wlr::screencopy::v1::client::zwlr_screencopy_manager_v1::ZwlrScreencopyManagerV1, &wayland_client::protocol::wl_shm::WlShm)>,
    dbus_conn: Option<&zbus::blocking::Connection>,
) -> Result<PhysicalCanvas> {
    // Phase 0 diagnostic: force Tier3 fallback path for testing (skip Tier1/Tier2).
    let force_tier3 = std::env::var("IE_R_FORCE_TIER3").is_ok();
    if force_tier3 {
        log_warn("IE_R_FORCE_TIER3 set: skipping Tier1 (WLR) and Tier2 (KWin per-output)");
    }

    // --- Tier 1: WLR Screencopy (Hyprland / Sway) ---
    if !force_tier3 && let Some((conn, manager, wl_shm)) = screencopy {
        let handles: Vec<_> = output_meta.iter().map(|meta| {
            let conn = conn.clone();
            let manager = manager.clone();
            let wl_shm = wl_shm.clone();
            let out_clone = meta.output.clone();
            let logical_pos = meta.logical_pos;
            let logical_w = meta.logical_w;
            let logical_h = meta.logical_h;
            let transform = meta.transform;
            std::thread::spawn(move || {
                wlr::capture_output(&conn, &manager, &wl_shm, &out_clone)
                    .map(|capture| MonitorTile::from_capture(capture, out_clone, logical_pos, logical_w, logical_h, transform))
            })
        }).collect();

        let tiles: Vec<_> = handles.into_iter()
            .filter_map(|h| h.join().ok()?.map_err(|e| {
                log_warn(&format!("WLR capture skipped: {}", e));
            }).ok())
            .collect();

        if !tiles.is_empty() {
            return Ok(PhysicalCanvas::build(tiles));
        }
    }

    // --- Tier 2: KWin per-output DBus (Plasma multi-monitor) ---
    if !force_tier3 && let Some(conn) = dbus_conn {
        let tiles: Vec<_> = output_meta.iter()
            .filter(|m| !m.name.is_empty())
            .filter_map(|meta| {
                match kwin::capture_output_dbus(conn, &meta.name) {
                    Ok(capture) => Some(MonitorTile::from_capture(
                        capture,
                        meta.output.clone(),
                        meta.logical_pos,
                        meta.logical_w,
                        meta.logical_h,
                        meta.transform,
                    )),
                    Err(e) => {
                        let e_str = e.to_string();
                        let (kind, desc) = e_str.split_once(": ").unwrap_or(("", &e_str));
                        log_warn(&format!("KWin capture skipped for {}:", meta.name));
                        if !kind.is_empty() { log_warn(&format!("   {}:", kind)); }
                        log_warn(&format!("   {}", desc));
                        None
                    }
                }
            })
            .collect();

        if !tiles.is_empty() {
            return Ok(PhysicalCanvas::build(tiles));
        }
    }

    // --- Tier 3: single-capture fallback (KWin single / XDG Portal / Spectacle) ---
    let capture = portal::capture_screen(dbus_conn)?;

    // Try to split the virtual-desktop capture into per-output tiles.
    // If the heuristic accepts, render gets a real multi-tile canvas
    // (no smoosh); otherwise we fall back to single-tile (legacy behavior).
    if let Some(tiles) = try_split_virtual_desktop(&capture, output_meta) {
        log_step("Tier3", &format!("split → {} tile(s)", tiles.len()));
        return Ok(PhysicalCanvas::build(tiles));
    }

    log_warn("Tier3: split heuristic rejected — single-tile fallback (smoosh likely)");
    let output = output_meta.first().map(|m| m.output.clone());
    Ok(PhysicalCanvas::from_single(capture, output))
}

/// Attempt to slice a virtual-desktop capture (XDG Portal / KWin single /
/// Spectacle) into per-output tiles using the compositor-reported layout.
///
/// Heuristic — accept the split only when the capture cleanly matches the
/// logical union of all outputs at a single uniform scale:
///   * `capture.size ≈ union.size × s` for some `s ∈ {0.5, 1.0, 1.5, 2.0, …}`
///   * `sx == sy` within tolerance
///   * all outputs report `Transform::Normal` (rotated outputs deferred)
///
/// Empirical (Hyprland XDG Portal):
///   * scale=1.0 case: capture 6400×2400 = union 6400×2400 (no scaling)
///   * scale=2.0 case: capture 8960×2880 = union 4480×1440 × 2 (HiDPI on)
///   * non-zero union origin (e.g. min_x=1920) handled via offset subtraction
///
/// Returns `None` if the capture format is unexpected (e.g. Spectacle on X11
/// with overlapping displays, mixed-scale Wayland configs we haven't seen yet).
#[cfg(unix)]
fn try_split_virtual_desktop(
    capture: &ScreenCapture,
    output_meta: &[OutputMeta],
) -> Option<Vec<MonitorTile>> {
    if output_meta.is_empty() { return None; }

    let min_x = output_meta.iter().map(|m| m.logical_pos.0).min()?;
    let min_y = output_meta.iter().map(|m| m.logical_pos.1).min()?;
    let max_x = output_meta.iter().map(|m| m.logical_pos.0 + m.logical_w).max()?;
    let max_y = output_meta.iter().map(|m| m.logical_pos.1 + m.logical_h).max()?;
    let union_w = max_x - min_x;
    let union_h = max_y - min_y;
    if union_w <= 0 || union_h <= 0 { return None; }

    let sx = capture.width  as f64 / union_w as f64;
    let sy = capture.height as f64 / union_h as f64;
    let s  = (sx + sy) * 0.5;

    // sx and sy must agree (uniform scaling)
    if (sx - sy).abs() / s.max(1e-6) > 0.01 { return None; }
    // s must be a sane multiple of 0.5 (1.0, 1.5, 2.0, 2.5, 3.0…)
    let s_round = (s * 2.0).round() / 2.0;
    if s_round < 0.95 || (s - s_round).abs() > 0.05 { return None; }
    // rotated outputs in single-capture mode aren't worth handling yet
    if output_meta.iter().any(|m| m.transform != wl_output::Transform::Normal) {
        return None;
    }

    let mut tiles = Vec::with_capacity(output_meta.len());
    for m in output_meta {
        let px = ((m.logical_pos.0 - min_x) as f64 * s_round).round() as i32;
        let py = ((m.logical_pos.1 - min_y) as f64 * s_round).round() as i32;
        let pw = (m.logical_w as f64 * s_round).round() as i32;
        let ph = (m.logical_h as f64 * s_round).round() as i32;
        if px < 0 || py < 0 || pw <= 0 || ph <= 0 { return None; }
        if (px + pw) as u32 > capture.width || (py + ph) as u32 > capture.height {
            return None;
        }
        let sub = crop_xrgb(capture, px as u32, py as u32, pw as u32, ph as u32);
        tiles.push(MonitorTile::from_capture(
            sub,
            m.output.clone(),
            m.logical_pos,
            m.logical_w,
            m.logical_h,
            m.transform,
        ));
    }
    Some(tiles)
}

// ══════════════════════════════════════════════════════════════════════════════
// Windows capture — DXGI Desktop Duplication / GDI BitBlt (Phase 1).
// ══════════════════════════════════════════════════════════════════════════════

/// Capture all monitors: GDI BitBlt (Tier 1) → DXGI Desktop Duplication (Tier 2).
///
/// GDI first: reliable on all Windows versions including 8.1 VMs.
/// DXGI has cold-start issues (black frame without prior compositor activity)
/// and higher latency with warm-up (~90ms). GDI BitBlt is ~30ms and always works.
/// TODO: revisit tier order after real-hardware testing (DXGI may be faster there).
#[cfg(windows)]
pub fn capture_all_outputs() -> Result<PhysicalCanvas> {
    use crate::core::terminal::log_warn;

    // Tier 1: GDI BitBlt (~30ms, reliable, single virtual screen)
    match windows::capture_gdi() {
        Ok(canvas) => return Ok(canvas),
        Err(e) => log_warn(&format!("GDI failed, falling back to DXGI: {}", e)),
    }

    // Tier 2: DXGI Desktop Duplication (may return black on cold start)
    windows::capture_dxgi()
}

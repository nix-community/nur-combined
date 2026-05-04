use smithay_client_toolkit::{
    shell::{
        WaylandSurface,
        wlr_layer::{Anchor, KeyboardInteractivity, Layer},
        xdg::window::WindowDecorations,
    },
    shm::slot::SlotPool,
};
use wayland_client::{QueueHandle, protocol::wl_shm};

use crate::core::about::{self, AboutApp};
use crate::core::capture::{self, OutputMeta};
use crate::core::overlay::{OverlayApp, UserAction};
use crate::core::terminal::{log_info, log_error, Styled};

use super::{IEWaylandState, IEOverlay, AboutSurface, OverlaySurface};

// ══════════════════════════════════════════════════════════════════════════════
// Overlay lifecycle and render loop.
//
// Flow: launch_overlay() → [configure → redraw]* → close_overlay()
//
// launch_overlay creates a Layer Shell surface on each monitor.
// Compositor sends configure with dimensions → first redraw.
// Every mouse move / frame callback → another redraw.
// After PickColor/Cancel → close_overlay() destroys the surfaces.
// ══════════════════════════════════════════════════════════════════════════════

impl IEWaylandState {

    /// Awakens the Layer Shell.
    /// Creates a "window" that is not really a window but a hardcore overlay
    /// nailed on top of all compositor UI (even above taskbars).
    pub fn launch_overlay(&mut self, qh: &QueueHandle<Self>, app: OverlayApp) {
        if !self.overlays.is_empty() {
            return;
        }

        let compositor = self.compositor.as_ref().expect("wl_compositor required");
        let shm = self.shm.as_ref().expect("wl_shm required");

        let outputs: Vec<_> = self.output_state.outputs().collect();
        log_info(&format!("Launching overlays on {} monitor(s)...", outputs.len()));

        for output in outputs {
            let surface = compositor.create_surface(qh);

            // Dual surface strategy: Layer Shell (Hyprland/Sway/KDE) → xdg_toplevel fallback (GNOME)
            let surface_type = if let Some(layer_shell) = &self.layer_shell {
                let layer = layer_shell.create_layer_surface(
                    qh,
                    surface.clone(),
                    Layer::Overlay,
                    Some("ie-r"),
                    Some(&output),
                );

                layer.set_anchor(Anchor::TOP | Anchor::BOTTOM | Anchor::LEFT | Anchor::RIGHT);
                layer.set_keyboard_interactivity(KeyboardInteractivity::Exclusive);
                layer.set_exclusive_zone(-1);
                layer.commit();
                OverlaySurface::Layer(layer)
            } else if let Some(xdg_shell) = &self.xdg_shell {
                let window = xdg_shell.create_window(surface.clone(), WindowDecorations::None, qh);
                window.set_title("Instant Eyedropper Reborn");
                window.set_app_id("ie-r");
                window.set_fullscreen(Some(&output));
                window.commit();
                OverlaySurface::Xdg(window)
            } else {
                continue;
            };

            let viewport = self
                .viewporter
                .as_ref()
                .map(|vp| vp.get_viewport(&surface, qh, ()));

            self.overlays.push(IEOverlay {
                output,
                surface: surface_type,
                viewport,
                width: 0,
                height: 0,
                dirty_rects: std::collections::VecDeque::with_capacity(12),
                committed: false,
                frame_pending: false,
                buffers: std::collections::VecDeque::with_capacity(3),
            });
        }

        // SHM buffer pool — sized to the largest monitor (not hardcoded 4K).
        let max_pixels = app.canvas.tiles.iter()
            .map(|t| (t.capture.width * t.capture.height) as usize)
            .max()
            .unwrap_or(3840 * 2160);
        self.pool = Some(SlotPool::new(max_pixels * 4, shm).expect("Failed to create SHM pool"));
        self.overlay_app = Some(app);

        for output in self.output_state.outputs() {
            if let Some(info) = self.output_state.info(&output) {
                eprintln!("{} name={:?}  pos={:?}  size={:?}",
                    format!("[{: >10}]", "Monitor").magenta(),
                    info.name, info.logical_position, info.logical_size);
            }
        }

        // Reset state for a new overlay session.
        // Cursor off-screen (-1000) — magnifier will not render until the first Motion.
        self.first_configure = true;
        self.exit = false;
        self.needs_redraw = false;
        self.input.inside = false;
        self.input.x = -1000;
        self.input.y = -1000;
        self.input.startup_phase = true;
        for o in self.overlays.iter_mut() { o.buffers.clear(); }
    }

    /// Destroys all Layer Shell surfaces and resets overlay state.
    /// Called from the main loop after finalize_overlay (color copy, history save).
    pub fn close_overlay(&mut self) {
        for overlay in self.overlays.drain(..) {
            if let Some(vp) = overlay.viewport {
                vp.destroy();
            }
        }
        self.overlay_app = None;
        self.active_output = None;
        self.input.pending_correction = false;
        self.input.batch_count = 0;
        self.input.phantom_count = 0;
    }

    /// Called from the calloop post-dispatch closure after each dispatch_pending.
    /// No longer activates anything — only cleans up the batch state.
    pub fn flush_pending_enters(&mut self, _qh: &QueueHandle<Self>) {
        if self.input.batch_count > 1 {
            let tag = format!("[{: >10}]", "Flush");
            let real = self.input.batch_count - self.input.phantom_count;
            eprintln!("{} Batch: {} enters → {} real, {} phantom",
                tag.gray(), self.input.batch_count, real, self.input.phantom_count);
        }
        // Switch to Processing only if this batch contained Enter events.
        // Flush arrives after every dispatch cycle, including empty ones (before
        // batch-Enters arrive). An empty Flush must not reset enter_phase.
        if self.input.startup_phase && self.input.batch_count > 0 {
            self.input.startup_phase = false;
        }
        self.input.batch_count = 0;
        self.input.phantom_count = 0;
    }

    /// Simulates a left mouse click to capture color via hotkey
    /// when the overlay is already running.
    pub fn simulate_click(&mut self, qh: &QueueHandle<Self>) {
        self.dispatch(UserAction::PickColor { serial: false });
        if self.needs_redraw {
            self.redraw(qh);
        }
        // Blink animation may set should_exit from within render().
        if self.overlay_app.as_ref().is_some_and(|a| a.should_exit) {
            self.exit = true;
        }
    }

    /// **Main render loop (The Draw Loop)**
    /// Fires like a Kalashnikov on every mouse Movement Event
    /// or wl_surface::frame signal (monitor refresh rate).
    /// Uses triple buffering (SlotPool) and Dirty Rectangles to
    /// erase and redraw only the magnifier, not copying 32MB of background each frame.
    pub fn redraw(&mut self, qh: &QueueHandle<Self>) {
        if self.overlays.is_empty() {
            return;
        }

        let app = match &mut self.overlay_app {
            Some(app) => app,
            None => return,
        };

        if let Some(pool) = &mut self.pool {
            // Mirror render: each overlay keeps its own dirty_rects (tile coordinates).
            // Swapped into OverlayApp before render(), swapped back after.
            // Inactive overlays (no cursor) are skipped if their dirty state is clean —
            // they already show the background. This saves CPU: only the active monitor renders.
            for overlay_idx in 0..self.overlays.len() {
                // None = first frame, pointer enter not yet received → render all.
                let is_active = self.active_output.is_none()
                    || self.active_output.as_ref() == Some(&self.overlays[overlay_idx].output);

                // Skip render: not yet configured or already committed (awaiting frame callback).
                if self.overlays[overlay_idx].width == 0 || self.overlays[overlay_idx].committed {
                    continue;
                }

                // Inactive overlay with clean dirty state — already showing background, skip.
                // Only render if there are dirty regions (need to erase the old magnifier).
                if !is_active && self.overlays[overlay_idx].dirty_rects.is_empty() {
                    continue;
                }

                // --- Phase 1: Read-only overlay data ---
                let tile_idx = match app.canvas.find_tile(&self.overlays[overlay_idx].output) {
                    Some(idx) => idx,
                    None => continue,
                };

                let tile = &app.canvas.tiles[tile_idx];
                let buf_w = tile.capture.width;
                let buf_h = tile.capture.height;
                let stride = buf_w as i32 * 4;

                let (buffer, canvas) = match pool.create_buffer(
                    buf_w as i32,
                    buf_h as i32,
                    stride,
                    wl_shm::Format::Xrgb8888,
                ) {
                    Ok(b) => b,
                    Err(e) => {
                        log_error(&format!("Failed to create shm buffer for output {}: {:?}", tile_idx, e));
                        continue;
                    }
                };

                // wp_viewporter: buffer renders at physical resolution (capture size),
                // but compositor scales it to the logical overlay size.
                // Without this, fractional scaling (125%, 150%) produces a blurry image.
                if let Some(viewport) = &self.overlays[overlay_idx].viewport {
                    let ow = self.overlays[overlay_idx].width;
                    let oh = self.overlays[overlay_idx].height;
                    if ow > 0 && oh > 0 {
                        viewport.set_destination(ow as i32, oh as i32);
                    }
                }

                // SAFETY: SHM buffer is 4-byte aligned (wl_shm guarantees page-aligned mmap).
                // Convert &mut [u8] → &mut [u32] for direct XRGB8888 pixel writes.
                let (_, canvas_u32, _) = unsafe { canvas.align_to_mut::<u32>() };

                if !is_active {
                    // --- Inactive monitor: direct background memcpy, skip render() ---
                    let background = &app.canvas.tiles[tile_idx].capture.xrgb_buffer;
                    let copy_len = background.len().min(canvas_u32.len());
                    if copy_len < canvas_u32.len() {
                        canvas_u32.fill(0xFF000000); // Black letterbox for uninitialized SHM areas
                    }
                    canvas_u32[..copy_len].copy_from_slice(&background[..copy_len]);
                    // Invalidate ALL warmed buffers for this tile.
                    //
                    // Problem: dirty_rects[ovl] are being cleared, but old SHM buffers
                    // (that previously showed the magnifier) remain in warmed_buffers
                    // with tile_idx == this tile. When they return from the pool:
                    //   is_warmed=true, dirty_rects only contains new positions →
                    //   dirty path doesn't know the old magnifier position → ghost not erased.
                    //
                    // Fix: on CLEAN, remove all entries for this tile → next render
                    // of each old buffer gets is_warmed=false → full copy.
                    app.warmed_buffers.retain(|_, v| *v != tile_idx);
                    // Dirty rects cleared — overlay is now clean, will be skipped in future frames.
                    self.overlays[overlay_idx].dirty_rects.clear();
                    // Full damage — the entire buffer was overwritten.
                    let wl_surface = self.overlays[overlay_idx].surface.wl_surface();
                    wl_surface.damage_buffer(0, 0, buf_w as i32, buf_h as i32);
                } else {
                    // --- Active monitor: full render pipeline ---
                    app.canvas.active_idx = tile_idx;
                    app.sync_active_tile();
                    std::mem::swap(&mut app.dirty_rects, &mut self.overlays[overlay_idx].dirty_rects);

                    app.render(canvas_u32, buf_w, buf_h);

                    // --- Super Bounding Box for damage_buffer ---
                    // One bbox instead of a mosaic of rects: with fractional scaling the compositor
                    // loses 1px at seams due to f64→i32 rounding. One rectangle guarantees
                    // no visible seams. Clamp to buffer size is mandatory.
                    // (see artifacts/2026.02.27/kwin_fractional_damage.md)
                    {
                        let wl_surface = self.overlays[overlay_idx].surface.wl_surface();
                        if !app.dirty_rects.is_empty() {
                            let mut min_x = i32::MAX;
                            let mut min_y = i32::MAX;
                            let mut max_x = i32::MIN;
                            let mut max_y = i32::MIN;
                            for &(dx, dy, dw, dh) in &app.dirty_rects {
                                min_x = min_x.min(dx);
                                min_y = min_y.min(dy);
                                max_x = max_x.max(dx + dw as i32);
                                max_y = max_y.max(dy + dh as i32);
                            }
                            min_x = min_x.max(0);
                            min_y = min_y.max(0);
                            max_x = max_x.min(buf_w as i32);
                            max_y = max_y.min(buf_h as i32);
                            let dw = max_x - min_x;
                            let dh = max_y - min_y;
                            if dw > 0 && dh > 0 {
                                wl_surface.damage_buffer(min_x, min_y, dw, dh);
                            } else {
                                wl_surface.damage_buffer(0, 0, buf_w as i32, buf_h as i32);
                            }
                        } else {
                            wl_surface.damage_buffer(0, 0, buf_w as i32, buf_h as i32);
                        }
                    }

                    // Swap dirty_rects back into the overlay (for the next frame).
                    std::mem::swap(&mut app.dirty_rects, &mut self.overlays[overlay_idx].dirty_rects);
                }

                // --- Phase 4: Wayland commit ---
                // WE ALWAYS request a frame callback on commit!
                // Otherwise Wayland may hold the buffer indefinitely (or beyond 3 frames),
                // causing Protocol error 4294967295 on wl_shm_pool.
                let wl_surface = self.overlays[overlay_idx].surface.wl_surface();
                buffer.attach_to(wl_surface).expect("Failed to attach buffer");
                wl_surface.frame(qh, wl_surface.clone());

                match &self.overlays[overlay_idx].surface {
                    OverlaySurface::Layer(layer) => layer.commit(),
                    OverlaySurface::Xdg(window) => window.commit(),
                }

                self.overlays[overlay_idx].committed = true;
                self.overlays[overlay_idx].frame_pending = true;

                // Per-overlay triple buffering: keep the last 3 buffers.
                if self.overlays[overlay_idx].buffers.len() >= 3 {
                    self.overlays[overlay_idx].buffers.pop_front();
                }
                self.overlays[overlay_idx].buffers.push_back(buffer);
            }

            self.needs_redraw = app.needs_redraw;
        }
    }

    // ══════════════════════════════════════════════════════════════════════════
    // About window lifecycle
    // ══════════════════════════════════════════════════════════════════════════

    pub fn launch_about(&mut self, qh: &QueueHandle<Self>, font_data: std::sync::Arc<Vec<u8>>, dbus_conn: Option<&zbus::blocking::Connection>) {
        if self.about_surface.is_some() || self.overlay_app.is_some() {
            return;
        }

        let compositor = self.compositor.as_ref().expect("wl_compositor required");

        // 1. Capture background BEFORE creating the surface (so the window doesn't appear in the screenshot).
        let output_meta: Vec<_> = self.output_state.outputs().map(|o| {
            let info = self.output_state.info(&o);
            let name = info.as_ref().and_then(|i| i.name.clone()).unwrap_or_default();
            let logical_pos = info.as_ref().and_then(|i| i.logical_position).unwrap_or((0, 0));
            let logical_w = info.as_ref().and_then(|i| i.logical_size).map(|s| s.0).unwrap_or(0);
            let logical_h = info.as_ref().and_then(|i| i.logical_size).map(|s| s.1).unwrap_or(0);
            let transform = info.as_ref()
                .map(|i| i.transform)
                .unwrap_or(wayland_client::protocol::wl_output::Transform::Normal);
            OutputMeta { output: o, name, logical_pos, logical_w, logical_h, transform }
        }).collect();

        let screencopy = match (&self.screencopy_manager, &self.shm) {
            (Some(manager), Some(shm)) => Some((&self.conn, manager, shm.wl_shm())),
            _ => None,
        };

        let canvas = capture::capture_all_outputs(&output_meta, screencopy, dbus_conn)
            .unwrap_or_else(|e| {
                log_error(&format!("About capture failed: {:?}", e));
                capture::PhysicalCanvas { tiles: Vec::new(), active_idx: 0 }
            });

        // Crop background from the first tile (fallback); correct monitor determined in surface_enter.
        let w = about::ABOUT_WIDTH;
        let h = about::ABOUT_HEIGHT;
        let bg_buffer = if !canvas.tiles.is_empty() {
            AboutSurface::extract_bg(&canvas.tiles[0])
        } else {
            vec![0u32; (w * h) as usize]
        };

        let surface = compositor.create_surface(qh);

        // Same dual-surface fallback as the overlay.
        let surface_type = if let Some(layer_shell) = &self.layer_shell {
            let layer = layer_shell.create_layer_surface(
                qh,
                surface.clone(),
                Layer::Overlay,
                Some("ie-r-about"),
                None, // not bound to a specific monitor — compositor will choose
            );
            layer.set_size(w, h);
            layer.set_keyboard_interactivity(KeyboardInteractivity::Exclusive);
            layer.commit();
            OverlaySurface::Layer(layer)
        } else if let Some(xdg_shell) = &self.xdg_shell {
            let window = xdg_shell.create_window(surface.clone(), WindowDecorations::None, qh);
            window.set_title("About — Instant Eyedropper Reborn");
            window.set_app_id("ie-r");
            window.set_min_size(Some((w, h)));
            window.set_max_size(Some((w, h)));
            window.commit();
            OverlaySurface::Xdg(window)
        } else {
            return;
        };

        let viewport = self
            .viewporter
            .as_ref()
            .map(|vp| vp.get_viewport(&surface, qh, ()));

        self.about_surface = Some(AboutSurface {
            surface: surface_type,
            viewport,
            app: AboutApp::new(font_data),
            buffers: std::collections::VecDeque::with_capacity(3),
            tiles: canvas.tiles,
            bg_buffer,
            blur_buf_1: vec![0u32; (w * h) as usize],
            blur_buf_2: vec![0u32; (w * h) as usize],
        });

        log_info("About window launched (with glass context)");
    }

    pub fn close_about(&mut self) {
        if let Some(about) = self.about_surface.take()
            && let Some(vp) = about.viewport {
                vp.destroy();
            }
    }

    pub fn render_about(&mut self, qh: &QueueHandle<Self>) {
        let shm = match &self.shm {
            Some(shm) => shm,
            None => return,
        };

        let about = match &mut self.about_surface {
            Some(a) => a,
            None => return,
        };

        let w = about::ABOUT_WIDTH;
        let h = about::ABOUT_HEIGHT;
        let stride = w as i32 * 4;

        // Ensure the pool exists in state.
        if self.pool.is_none() {
            self.pool = Some(SlotPool::new(w as usize * h as usize * 4, shm).expect("Failed to create SHM pool for About"));
        }
        let pool = self.pool.as_mut().unwrap();

        let (buffer, canvas) = match pool.create_buffer(w as i32, h as i32, stride, wl_shm::Format::Xrgb8888) {
            Ok(b) => b,
            Err(_) => return,
        };

        let (_, canvas_u32, _) = unsafe { canvas.align_to_mut::<u32>() };
        
        // Render with glassmorphism.
        about.app.render(
            canvas_u32, w, h,
            &about.bg_buffer,
            &mut about.blur_buf_1,
            &mut about.blur_buf_2,
            20, // Fixed blur radius for About window
        );

        // Blur is cached in AboutApp after the first frame — scratchpads no longer needed (~4.8MB).
        if !about.blur_buf_1.is_empty() {
            about.blur_buf_1 = Vec::new();
            about.blur_buf_2 = Vec::new();
        }

        let wl_surface = about.surface.wl_surface();
        wl_surface.damage_buffer(0, 0, w as i32, h as i32);
        
        // Request frame callback so AboutApp animations keep running (/// breathe).
        wl_surface.frame(qh, wl_surface.clone());
        
        buffer.attach_to(wl_surface).expect("Failed to attach about buffer");

        match &about.surface {
            OverlaySurface::Layer(layer) => layer.commit(),
            OverlaySurface::Xdg(window) => window.commit(),
        }

        if about.buffers.len() >= 3 {
            about.buffers.pop_front();
        }
        about.buffers.push_back(buffer);
    }
}

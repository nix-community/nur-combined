/// Translation of Wayland input events → `UserAction`.
///
/// Pure mapper: no business logic, only converts hardware signals
/// (keysym, pointer event) into commands for OverlayApp via `self.dispatch()`.
/// All coordinate math is delegated to Oracle.
use smithay_client_toolkit::seat::{
    keyboard::{KeyEvent, KeyboardHandler, Keysym, Modifiers, RawModifiers},
    pointer::{CursorIcon, PointerEvent, PointerEventKind, PointerHandler},
};
use wayland_client::{Connection, QueueHandle, protocol::{wl_keyboard, wl_pointer}};

use crate::connectors::keymap;
use crate::core::config::CursorStyle;
use crate::core::overlay::UserAction;
use crate::core::terminal::Styled;

use super::{IEWaylandState, InputState};
use super::oracle::{Oracle, EnterKind};

/// Wayland-specific: keysym → digit as typed (top row + numpad).
/// The digit→action policy lives in keymap; this is pure code translation.
fn digit_of_keysym(k: Keysym) -> Option<u8> {
    match k {
        Keysym::_1 | Keysym::KP_1 => Some(1),
        Keysym::_2 | Keysym::KP_2 => Some(2),
        Keysym::_3 | Keysym::KP_3 => Some(3),
        Keysym::_4 | Keysym::KP_4 => Some(4),
        Keysym::_5 | Keysym::KP_5 => Some(5),
        Keysym::_6 | Keysym::KP_6 => Some(6),
        Keysym::_7 | Keysym::KP_7 => Some(7),
        Keysym::_8 | Keysym::KP_8 => Some(8),
        Keysym::_9 | Keysym::KP_9 => Some(9),
        Keysym::_0 | Keysym::KP_0 => Some(0),
        _ => None,
    }
}

fn mods_of(input: &InputState) -> keymap::Mods {
    keymap::Mods { shift: input.shift, ctrl: input.ctrl, alt: input.alt }
}

/// Maps the user-facing [`CursorStyle`] to the right sctk call. Only the
/// MAIN overlay-aim cursor goes through here; transient cursor flips for
/// the About window hover/pick-blink stay on their own (`CursorIcon::Default`
/// etc) — they're UI state, not user policy.
fn apply_overlay_cursor(
    pointer: &mut smithay_client_toolkit::seat::pointer::ThemedPointer,
    conn: &Connection,
    style: CursorStyle,
) {
    match style {
        CursorStyle::Crosshair => { let _ = pointer.set_cursor(conn, CursorIcon::Crosshair); }
        CursorStyle::Default   => { let _ = pointer.set_cursor(conn, CursorIcon::Default); }
        CursorStyle::None      => { let _ = pointer.hide_cursor(); }
    }
}

// ── Keyboard ────────────────────────────────────────────────────────────────
// Escape/Enter/Space → dispatch(). Arrows → Nudge/Jump depending on modifiers.
// Digits 1-0 → select format template. Tilde → HUD toggle.
// A single redraw is called at the end of press_key, not in each arm.

impl KeyboardHandler for IEWaylandState {
    fn enter(
        &mut self,
        _: &Connection,
        _: &QueueHandle<Self>,
        _: &wl_keyboard::WlKeyboard,
        _surface: &wayland_client::protocol::wl_surface::WlSurface,
        _: u32,
        _: &[u32],
        _keysyms: &[Keysym],
    ) {
    }
    fn leave(
        &mut self,
        _: &Connection,
        _: &QueueHandle<Self>,
        _: &wl_keyboard::WlKeyboard,
        surface: &wayland_client::protocol::wl_surface::WlSurface,
        _: u32,
    ) {
        // If focus leaves the About window — close it.
        if let Some(about) = &self.about_surface
            && about.surface.wl_surface() == surface {
                self.close_about();
            }
    }
    fn press_key(
        &mut self,
        _conn: &Connection,
        qh: &QueueHandle<Self>,
        _: &wl_keyboard::WlKeyboard,
        _: u32,
        event: KeyEvent,
    ) {
        // About window: any key → close.
        if self.about_surface.is_some() {
            self.close_about();
            return;
        }

        match event.keysym {
            Keysym::Escape => {
                if !self.dispatch(UserAction::Cancel) {
                    self.exit = true;
                }
            }
            Keysym::Return | Keysym::KP_Enter => {
                self.dispatch(UserAction::PickColor { serial: self.input.shift });
            }
            Keysym::space => {
                self.dispatch(UserAction::PickColor { serial: true });
            }
            _ => {
                let mods = mods_of(&self.input);
                let action = if event.raw_code == 41 {
                    // - Seriously, you downloaded a gig of docs for one line?! )
                    // - Well what did you expect? That's the way of the Hunter!
                    // Physical KEY_GRAVE (evdev code 41), works on any keyboard layout
                    Some(UserAction::ToggleHud)
                } else if let Some(d) = digit_of_keysym(event.keysym) {
                    keymap::digit_action(d)
                } else {
                    match event.keysym {
                        Keysym::Up    => Some(keymap::arrow_action(mods, 0, -1)),
                        Keysym::Down  => Some(keymap::arrow_action(mods, 0, 1)),
                        Keysym::Left  => Some(keymap::arrow_action(mods, -1, 0)),
                        Keysym::Right => Some(keymap::arrow_action(mods, 1, 0)),
                        Keysym::grave | Keysym::asciitilde => Some(UserAction::ToggleHud), // Fallback
                        _ => None,
                    }
                };

                if let Some(act) = action {
                    self.dispatch(act);
                }
            }
        }

        if self.needs_redraw {
            self.redraw(qh);
        }
    }
    fn repeat_key(
        &mut self,
        _conn: &Connection,
        _qh: &QueueHandle<Self>,
        _keyboard: &wl_keyboard::WlKeyboard,
        _serial: u32,
        _event: KeyEvent,
    ) {
    }
    /// Arrow key release — separate path (no dispatch), because
    /// KeyRelease does not require a redraw and cannot trigger exit.
    fn release_key(
        &mut self,
        _: &Connection,
        _: &QueueHandle<Self>,
        _: &wl_keyboard::WlKeyboard,
        _: u32,
        event: KeyEvent,
    ) {
        let action = match event.keysym {
            Keysym::Up    => Some(keymap::arrow_release(0, -1)),
            Keysym::Down  => Some(keymap::arrow_release(0, 1)),
            Keysym::Left  => Some(keymap::arrow_release(-1, 0)),
            Keysym::Right => Some(keymap::arrow_release(1, 0)),
            _ => None,
        };

        if let Some(act) = action
            && let Some(app) = &mut self.overlay_app {
                app.handle_action(act);
            }
    }
    fn update_modifiers(
        &mut self,
        _: &Connection,
        _: &QueueHandle<Self>,
        _: &wl_keyboard::WlKeyboard,
        _serial: u32,
        modifiers: Modifiers,
        _raw_modifiers: RawModifiers,
        _layout: u32,
    ) {
        self.input.shift = modifiers.shift;
        self.input.ctrl = modifiers.ctrl;
        self.input.alt = modifiers.alt;
    }
}

// ── Pointer ─────────────────────────────────────────────────────────────────
// Pointer event lifecycle on a multi-monitor overlay:
//
//   Enter → [Motion]* → Leave → Enter (other monitor) → ...
//
// Enter comes in two types (see oracle.rs):
//   Type A (startup)    — compositor batch on launch, requires Oracle correction.
//   Type B (processing) — re-entry / cross-monitor transition, coords already surface-local.
//
// Motion — hot path (~60-144 Hz). Two passes: first computes buf_pos (read-only
// borrow of overlay_app), second updates active_idx and physical mouse (mutable borrow).
// Split is forced — the borrow checker disallows simultaneous &self and &mut self.

impl PointerHandler for IEWaylandState {
    fn pointer_frame(
        &mut self,
        _conn: &Connection,
        qh: &QueueHandle<Self>,
        _pointer: &wl_pointer::WlPointer,
        events: &[PointerEvent],
    ) {
        for event in events {
            // About window: handle link click and close.
            if let Some(about) = &self.about_surface {
                let is_hover = if let Some((ux, uy, uw, uh)) = about.app.url_bounds {
                    (self.input.x >= ux && self.input.x <= ux + uw) &&
                    (self.input.y >= uy && self.input.y <= uy + uh)
                } else {
                    false
                };

                match event.kind {
                    PointerEventKind::Motion { .. } => {
                        self.input.x = event.position.0 as i32;
                        self.input.y = event.position.1 as i32;
                        if let Some(pointer) = &mut self.pointer {
                            let icon = if is_hover { CursorIcon::Pointer } else { CursorIcon::Default };
                            let _ = pointer.set_cursor(_conn, icon);
                        }
                    }
                    PointerEventKind::Press { button, .. } => {
                        if is_hover && button == 0x110 { // LMB on link
                            self.open_url = true;
                            self.close_about();
                            if let Some(pointer) = &mut self.pointer {
                                let _ = pointer.set_cursor(_conn, CursorIcon::Default);
                            }
                            return;
                        } else if button == 0x111 || button == 0x110 { // Any click outside link — close
                            self.close_about();
                            if let Some(pointer) = &mut self.pointer {
                                let _ = pointer.set_cursor(_conn, CursorIcon::Default);
                            }
                            return;
                        }
                    }
                    _ => {}
                }
                continue;
            }

            // Find the overlay that owns this event.
            let overlay_idx = self.overlays.iter().position(|o| *o.surface.wl_surface() == event.surface);
            let overlay_idx = match overlay_idx {
                Some(idx) => idx,
                None => continue,
            };

            match event.kind {
                PointerEventKind::Enter { .. } => {
                    self.input.inside = true;
                    self.input.x = event.position.0 as i32;
                    self.input.y = event.position.1 as i32;

                    // Unlock ONLY the entering overlay: it may have stalled after a one-shot
                    // commit (no frame callback). Other overlays unlock naturally via their
                    // own frame callback — force-unlocking them = double commit = protocol error.
                    self.overlays[overlay_idx].committed = false;

                    // Cache overlay dims before borrowing overlay_app
                    let ovl_w = self.overlays[overlay_idx].width;
                    let ovl_h = self.overlays[overlay_idx].height;
                    let ovl_output = self.overlays[overlay_idx].output.clone();

                    if let Some(app) = &mut self.overlay_app {
                        let tile_idx = app.canvas.tile_index_for(&ovl_output);
                        let tile = &app.canvas.tiles[tile_idx];

                        self.input.batch_count += 1;

                        if self.input.startup_phase {
                            // Startup: batch-Enter (Type A). raw = cursor_global - 2*output_pos.
                            // Correction needed: corrected = raw + lpos = cursor_local.
                            // Phantom detection via oracle: corrected outside [0,ovl) →
                            // Enter arrived for an inactive monitor, ignore.
                            let oracle = Oracle::new(
                                tile.logical_pos,
                                ovl_w, ovl_h,
                                tile.capture.width, tile.capture.height,
                                self.compositor_hint
                            );
                            let enter_result = oracle.classify_enter(self.input.x, self.input.y);
                            let is_phantom = matches!(enter_result, EnterKind::Phantom);

                            if crate::core::terminal::info_visible() {
                                let tag = format!("[{: >10}]", "Enter");
                                eprintln!("{} tile={} lpos={:?} raw=({},{}) mod=({},{}) phantom={} ovl={}x{} [startup]",
                                    if is_phantom { tag.gray() } else { tag.yellow().bold() },
                                    tile_idx, tile.logical_pos, self.input.x, self.input.y,
                                    self.input.x + tile.logical_pos.0, self.input.y + tile.logical_pos.1,
                                    is_phantom, ovl_w, ovl_h);
                            }

                            if let EnterKind::Real { buf_x, buf_y } = enter_result {
                                app.canvas.active_idx = tile_idx;
                                self.active_output = Some(ovl_output);
                                app.magnifier.reset();
                                app.update_cursor(buf_x, buf_y);
                            } else {
                                self.input.phantom_count += 1;
                            }
                        } else {
                            // Processing: Enter Type B. raw = cursor_local — no correction needed.
                            // This covers: re-entry Enter before Motion and cross-monitor transitions.
                            // No phantom detection — compositor doesn't send Enter to surfaces
                            // where the cursor isn't present.
                            let oracle = Oracle::new(
                                tile.logical_pos,
                                ovl_w, ovl_h,
                                tile.capture.width, tile.capture.height,
                                self.compositor_hint
                            );
                            let (buf_x, buf_y) = oracle.motion_to_buffer(self.input.x, self.input.y);

                            if crate::core::terminal::info_visible() {
                                let tag = format!("[{: >10}]", "Enter");
                                eprintln!("{} tile={} lpos={:?} raw=({},{}) ovl={}x{} [processing]",
                                    tag.yellow().bold(), tile_idx, tile.logical_pos,
                                    self.input.x, self.input.y, ovl_w, ovl_h);
                            }

                            let is_same_output = self.active_output.as_ref() == Some(&ovl_output);
                            app.canvas.active_idx = tile_idx;
                            self.active_output = Some(ovl_output);
                            if !is_same_output {
                                // Cross-monitor transition — full reset with spawn animation.
                                app.magnifier.reset();
                            }
                            app.update_cursor(buf_x, buf_y);
                        }
                        self.input.pending_correction = true;
                        // Phantom (startup) — ignored. Motion will pick up the correct position.
                    }

                    // Set cursor per config (default = Crosshair, classic
                    // eyedropper behavior).
                    let cursor_style = self.overlay_app.as_ref()
                        .map(|a| a.config.system.cursor)
                        .unwrap_or_default();
                    if let Some(pointer) = &mut self.pointer {
                        apply_overlay_cursor(pointer, _conn, cursor_style);
                    }

                    self.needs_redraw = true;
                    self.redraw(qh);
                }
                PointerEventKind::Leave { .. } => {
                    self.input.inside = false;
                    // We do NOT reset mouse_pos immediately — the cursor may just be moving to another overlay.
                    self.needs_redraw = true;
                    self.redraw(qh);
                }
                PointerEventKind::Motion { .. } => {
                    self.input.x = event.position.0 as i32;
                    self.input.y = event.position.1 as i32;

                    let motion_output = self.overlays[overlay_idx].output.clone();
                    let ovl_w = self.overlays[overlay_idx].width;
                    let ovl_h = self.overlays[overlay_idx].height;

                    // Pass 1 (read-only): surface-local → buffer coords via Oracle
                    let buf_pos = if let Some(app) = &self.overlay_app {
                        let tile_idx = app.canvas.tile_index_for(&motion_output);
                        let tile = &app.canvas.tiles[tile_idx];
                        Oracle::new(
                            tile.logical_pos, 
                            ovl_w, ovl_h, 
                            tile.capture.width, tile.capture.height,
                            self.compositor_hint
                        ).motion_to_buffer(self.input.x, self.input.y)
                    } else {
                        (self.input.x as f64, self.input.y as f64)
                    };

                    if self.input.pending_correction && crate::core::terminal::info_visible() {
                        let tag = format!("[{: >10}]", "Motion");
                        eprintln!("{} tile={} raw=({},{}) buf=({:.0},{:.0}) [first]",
                            tag.blue().bold(), overlay_idx, self.input.x, self.input.y,
                            buf_pos.0, buf_pos.1);
                    }

                    // Pass 2 (mutable): update active tile and position in OverlayApp.
                    if let Some(app) = &mut self.overlay_app {
                        let tile_idx = app.canvas.tile_index_for(&motion_output);
                        app.canvas.active_idx = tile_idx;
                        // Motion always provides correct surface-local coords. Update active_output
                        // here in case the Enter was phantom and didn't update it.
                        self.active_output = Some(motion_output);
                        // Enter coords may have been imprecise (stale wl_output.position).
                        // Motion always gives correct surface-local coords.
                        // Don't reset the magnifier — let the spring chase the corrected target
                        // naturally, preserving the spawn animation.
                        if self.input.pending_correction {
                            self.input.pending_correction = false;
                        }
                        app.update_cursor(buf_pos.0, buf_pos.1);
                    }

                    self.needs_redraw = true;
                    self.redraw(qh);
                }
                PointerEventKind::Press { button, .. } => {
                    // BTN_LEFT = 0x110, BTN_RIGHT = 0x111, BTN_MIDDLE = 0x112
                    let mask = button;

                    if mask == 0x111 {
                        // Right Click → Cancel (exit without color)
                        if !self.dispatch(UserAction::Cancel) {
                            self.exit = true;
                        }
                    } else if mask == 0x110 || mask == 0x112 {
                        // Left Click or Middle Click → Pick color
                        // Middle and Shift+Left are always serial; plain Left is the final pick.
                        let serial = mask == 0x112 || self.input.shift;
                        self.dispatch(UserAction::PickColor { serial });
                        if self.overlay_app.as_ref().is_some_and(|a| a.blink.is_some())
                            && let Some(pointer) = &self.pointer {
                                let _ = pointer.set_cursor(_conn, CursorIcon::Default);
                            }
                    }

                    if self.needs_redraw {
                        self.redraw(qh);
                    }
                    // Blink animation may set should_exit from within render().
                    if let Some(app) = &self.overlay_app
                        && app.should_exit {
                            self.exit = true;
                        }
                }
                PointerEventKind::Axis { vertical, .. } => {
                    // Wayland sends discrete (mouse wheel, steps) or continuous (touchpad, pixels).
                    // Discrete takes priority — these are precise clicks. Continuous = approximation.
                    let mut delta = 0;

                    // Negative scroll = up (zoom in), positive = down (zoom out).
                    if vertical.discrete < 0 {
                        delta = 1;
                    } else if vertical.discrete > 0 {
                        delta = -1;
                    } else if vertical.absolute < 0.0 {
                        // Touchpad smooth scroll approximation
                        delta = 1;
                    } else if vertical.absolute > 0.0 {
                        delta = -1;
                    }

                    if delta != 0 {
                        self.dispatch(keymap::wheel_action(mods_of(&self.input), delta));
                        self.redraw(qh);
                    }
                }
                _ => {}
            }
        }
    }
}

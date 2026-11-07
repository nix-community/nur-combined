///   corrected = raw + logical_pos = cursor_local  ✓
///   raw = cursor_local, corrected = cursor_global > ovl_w → phantom ✓
/// Oracle — single source of truth for coordinate transformations.
///
/// Accepts raw compositor event data (raw surface-local coords from
/// wl_pointer::Enter / Motion), returns clean values without compositor-specific
/// chaos: Enter classification (real / phantom) and position in the capture buffer.
///
/// # Why this is needed
///
/// Different compositors send Enter with different raw-coordinate formulas.
/// Mixing that empiricism with event-handling logic leads to unreadable code.
/// Oracle isolates the math: input.rs stays declarative.
///
/// # Compositor-specific strategy
///
/// The Wayland spec states: `wl_pointer::Enter` provides surface-local coordinates.
/// `Standard` is the default behavior (Plasma, Sway, any unknown compositor).
/// `HyprlandLegacy` is the Hyprland < 0.57 deviation and requires correction.
///
/// ## Standard (Plasma, Sway, Mutter, Hyprland ≥ 0.57 and all unknowns)
///
/// Compositor sends exactly one Enter to the active monitor.
/// `raw = cursor_local` — Wayland spec. No phantom Enters.
/// Use raw directly.
///
/// ## HyprlandLegacy (Hyprland < 0.57, version read from the IPC socket)
///
/// Before 0.57 `CLayerSurface::onMap()` force-set pointer focus onto an
/// exclusive-keyboard layer (`setPointerFocus(surface, LOCAL)`) — the source of
/// both the batch-Enter to every layer and the odd raw formula. 0.57.0 (PR #15899)
/// replaced the forced focus with `simulateMouseMovement()`: Enter now comes from
/// the regular hit-test, once, with honest surface-local coordinates. On 0.57 the
/// correction below pushed the real Enter past the overlay edge and dropped it as
/// a phantom — the magnifier stayed invisible until the first Motion (measured
/// 2026-11-07 on 0.57.1, single monitor positioned at 1920×0).
///
/// Two Enter types:
///
/// **Batch-Enter on overlay launch** — Hyprland broadcasts Enter to all layer-shell
/// surfaces simultaneously. raw = cursor_global - 2*output_pos, therefore:
///
///   corrected = raw + logical_pos = cursor_local  ✓
///
/// **Re-entry Enter on movement** — cursor crosses the surface boundary:
///
///   raw = cursor_local, corrected = cursor_global > ovl_w → phantom ✓
///
/// Algorithm: `corrected = raw + logical_pos`. If out of [0, ovl_w) → phantom.
/// Empirically derived from Hyprland deviation testing.

#[derive(Debug, Clone, Copy, PartialEq)]
pub enum CompositorHint {
    /// Wayland-spec behavior: raw = cursor_local, one Enter per active monitor.
    /// Default for Plasma, Sway, Mutter, Hyprland ≥ 0.57 and any unknown compositor.
    Standard,
    /// Non-standard Hyprland < 0.57 batch-Enter: raw = cursor_global - 2*output_pos.
    /// Chosen by `detect()` from HYPRLAND_INSTANCE_SIGNATURE + the IPC socket version.
    HyprlandLegacy,
}

/// First Hyprland release with spec-compliant Enter (PR #15899 landed in 0.57.0).
const HYPRLAND_SPEC_ENTER_SINCE: (u32, u32) = (0, 57);

impl CompositorHint {
    /// Picks the strategy from the environment. Non-Hyprland → Standard with zero
    /// syscalls. Hyprland → ask the compositor itself over the IPC socket: below 0.57
    /// → Legacy, otherwise Standard. Unreadable version (socket unavailable, unknown
    /// reply format) → Standard: that is the spec and every new release follows it;
    /// Legacy is a dying exception and must not be picked blindly.
    pub fn detect() -> Self {
        let Ok(signature) = std::env::var("HYPRLAND_INSTANCE_SIGNATURE") else {
            return Self::Standard;
        };
        match hyprland_version(&signature) {
            Some(v) if v < HYPRLAND_SPEC_ENTER_SINCE => {
                crate::core::terminal::log_step("Oracle",
                    &format!("Hyprland {}.{} → legacy batch-Enter correction", v.0, v.1));
                Self::HyprlandLegacy
            }
            Some(v) => {
                crate::core::terminal::log_step("Oracle",
                    &format!("Hyprland {}.{} → spec-compliant Enter", v.0, v.1));
                Self::Standard
            }
            None => {
                crate::core::terminal::log_warn(
                    "Hyprland version unknown (IPC socket unreadable) — assuming spec-compliant Enter");
                Self::Standard
            }
        }
    }
}

/// Asks Hyprland IPC for `version` (`$XDG_RUNTIME_DIR/hypr/<sig>/.socket.sock`,
/// pre-0.40 `/tmp/hypr/<sig>/`). One round-trip at daemon start, short timeouts:
/// a stuck socket must not delay startup.
fn hyprland_version(signature: &str) -> Option<(u32, u32)> {
    use std::io::{Read, Write};
    use std::os::unix::net::UnixStream;
    use std::time::Duration;

    let runtime_dir = std::env::var("XDG_RUNTIME_DIR").unwrap_or_else(|_| "/run/user/1000".into());
    let candidates = [
        format!("{runtime_dir}/hypr/{signature}/.socket.sock"),
        format!("/tmp/hypr/{signature}/.socket.sock"),
    ];
    for path in &candidates {
        let Ok(mut stream) = UnixStream::connect(path) else { continue };
        let timeout = Some(Duration::from_millis(200));
        let _ = stream.set_read_timeout(timeout);
        let _ = stream.set_write_timeout(timeout);
        if stream.write_all(b"version").is_err() { continue; }
        let mut reply = String::new();
        let _ = stream.read_to_string(&mut reply);
        if let Some(v) = parse_hyprland_version(&reply) {
            return Some(v);
        }
    }
    None
}

/// Extracts (major, minor) from a `hyprctl version` reply. Two formats: new —
/// `Hyprland 0.57.1 built from branch …`, old — no version on the first line but
/// `Tag: v0.41.2, commits: …`. Takes the first version-looking token following the
/// word `Hyprland` or `Tag:`.
pub(crate) fn parse_hyprland_version(reply: &str) -> Option<(u32, u32)> {
    let mut after_anchor = false;
    for word in reply.split_whitespace() {
        if after_anchor {
            let v = word.trim_start_matches('v').trim_end_matches(',');
            let mut parts = v.split('.');
            if let (Some(maj), Some(min)) = (parts.next(), parts.next())
                && let (Ok(maj), Ok(min)) = (maj.parse::<u32>(), min.parse::<u32>()) {
                    return Some((maj, min));
                }
        }
        after_anchor = matches!(word.trim_end_matches(','), "Hyprland" | "Tag:");
    }
    None
}

pub enum EnterKind {
    /// Real Enter: cursor is genuinely on this monitor.
    /// `buf_x`, `buf_y` — position in capture-buffer coordinates.
    Real { buf_x: f64, buf_y: f64 },
    /// Phantom Enter: compositor sent Enter to an inactive monitor.
    /// Ignored; the first Motion event will pick up the correct position.
    Phantom,
}

pub struct Oracle {
    /// Monitor's logical position in the compositor's global space.
    /// Source: `output_state.info(&output).logical_position`.
    logical_pos: (i32, i32),
    /// Logical overlay size (compositor pixels).
    ovl_w: u32,
    ovl_h: u32,
    /// Scale: capture_size / ovl_size. Converts logical coordinates to buffer coordinates.
    scale_x: f64,
    scale_y: f64,
    /// Compositor type hint for selecting the classification strategy.
    hint: CompositorHint,
}

impl Oracle {
    pub fn new(
        logical_pos: (i32, i32),
        ovl_w: u32,
        ovl_h: u32,
        cap_w: u32,
        cap_h: u32,
        hint: CompositorHint,
    ) -> Self {
        let scale_x = cap_w as f64 / ovl_w.max(1) as f64;
        let scale_y = cap_h as f64 / ovl_h.max(1) as f64;
        Self {
            logical_pos,
            ovl_w,
            ovl_h,
            scale_x,
            scale_y,
            hint,
        }
    }

    /// Classifies an Enter event.
    ///
    /// For HyprlandLegacy (< 0.57): corrected = raw + logical_pos.
    /// If corrected falls outside [0, ovl_w) × [0, ovl_h) — phantom.
    ///
    /// Motion events do not go through this method — they are always surface-local
    /// and require no classification. See `motion_to_buffer`.
    pub fn classify_enter(&self, raw_x: i32, raw_y: i32) -> EnterKind {
        match self.hint {
            CompositorHint::HyprlandLegacy => {
                // Batch-Enter: raw = cursor_global - 2*output_pos.
                // Batch-Enter: raw = cursor_global - 2*output_pos.
                // Correct: corrected = raw + logical_pos = cursor_local.
                // If out of bounds — phantom (Enter to an inactive monitor).
                let corrected_x = raw_x + self.logical_pos.0;
                let corrected_y = raw_y + self.logical_pos.1;

                let is_phantom = corrected_x < 0 || corrected_x > self.ovl_w as i32
                              || corrected_y < 0 || corrected_y > self.ovl_h as i32;

                if is_phantom {
                    return EnterKind::Phantom;
                }

                let clamped_x = corrected_x.clamp(0, self.ovl_w as i32 - 1);
                let clamped_y = corrected_y.clamp(0, self.ovl_h as i32 - 1);
                EnterKind::Real {
                    buf_x: clamped_x as f64 * self.scale_x,
                    buf_y: clamped_y as f64 * self.scale_y,
                }
            }
            CompositorHint::Standard => {
                // Wayland spec: raw = cursor_local. Compositor sends Enter only to
                // the active monitor — phantom detection is not needed.
                let clamped_x = raw_x.clamp(0, self.ovl_w as i32 - 1);
                let clamped_y = raw_y.clamp(0, self.ovl_h as i32 - 1);
                EnterKind::Real {
                    buf_x: clamped_x as f64 * self.scale_x,
                    buf_y: clamped_y as f64 * self.scale_y,
                }
            }
        }
    }

    /// Converts Motion surface-local coordinates to capture-buffer coordinates.
    ///
    /// Motion always provides correct surface-local coords — no correction needed,
    /// only scaling.
    pub fn motion_to_buffer(&self, raw_x: i32, raw_y: i32) -> (f64, f64) {
        (raw_x as f64 * self.scale_x, raw_y as f64 * self.scale_y)
    }
}

#[cfg(test)]
#[path = "oracle_tests.rs"]
mod tests;

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
/// `Hyprland` deviates from the norm and requires correction.
///
/// ## Standard (Plasma, Sway, Mutter and all unknowns)
///
/// Compositor sends exactly one Enter to the active monitor.
/// `raw = cursor_local` — Wayland spec. No phantom Enters.
/// Use raw directly.
///
/// ## Hyprland (detected via HYPRLAND_INSTANCE_SIGNATURE)
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
/// Details: artifacts/2026.03.17/ENTER_INVESTIGATION.md

#[derive(Debug, Clone, Copy, PartialEq)]
pub enum CompositorHint {
    /// Wayland-spec behavior: raw = cursor_local, one Enter per active monitor.
    /// Default for Plasma, Sway, Mutter and any unknown compositor.
    Standard,
    /// Non-standard batch-Enter: raw = cursor_global - 2*output_pos.
    /// Detected via the HYPRLAND_INSTANCE_SIGNATURE env var.
    Hyprland,
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
    #[allow(dead_code)]
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
    /// For Hyprland: corrected = raw + logical_pos.
    /// If corrected falls outside [0, ovl_w) × [0, ovl_h) — phantom.
    ///
    /// Motion events do not go through this method — they are always surface-local
    /// and require no classification. See `motion_to_buffer`.
    pub fn classify_enter(&self, raw_x: i32, raw_y: i32) -> EnterKind {
        match self.hint {
            CompositorHint::Hyprland => {
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

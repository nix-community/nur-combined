//!
//! Oracle tests — Enter classification and Motion scaling.
//! Compositor empiricism (Hyprland batch-Enter) pinned down as tests.

use super::*;

/// A 1920×1080-logical / 2880×1620-physical (scale 1.5) monitor at `pos`.
fn oracle_at(pos: (i32, i32), hint: CompositorHint) -> Oracle {
    Oracle::new(pos, 1920, 1080, 2880, 1620, hint)
}

#[test]
fn test_standard_enter_is_surface_local_scaled() {
    // Wayland spec: raw = cursor_local — scaling only.
    let o = oracle_at((1920, 0), CompositorHint::Standard);
    match o.classify_enter(100, 200) {
        EnterKind::Real { buf_x, buf_y } => {
            assert_eq!(buf_x, 150.0);
            assert_eq!(buf_y, 300.0);
        }
        EnterKind::Phantom => panic!("Standard never produces phantoms"),
    }
}

#[test]
fn test_standard_enter_clamps_to_overlay() {
    let o = oracle_at((0, 0), CompositorHint::Standard);
    match o.classify_enter(5000, -10) {
        EnterKind::Real { buf_x, buf_y } => {
            assert_eq!(buf_x, 1919.0 * 1.5);
            assert_eq!(buf_y, 0.0);
        }
        EnterKind::Phantom => panic!("Standard never produces phantoms"),
    }
}

#[test]
fn test_hyprland_batch_enter_corrected() {
    // Hyprland batch-Enter: raw = cursor_global - 2*output_pos.
    //   raw = 2020 - 2*1920 = -1820; corrected = -1820 + 1920 = 100 ✓
    // Monitor at (1920, 0), cursor at global (2020, 50):
    //   raw = 2020 - 2*1920 = -1820; corrected = -1820 + 1920 = 100 ✓
    let o = oracle_at((1920, 0), CompositorHint::Hyprland);
    match o.classify_enter(-1820, 50) {
        EnterKind::Real { buf_x, buf_y } => {
            assert_eq!(buf_x, 150.0); // 100 * 1.5
            assert_eq!(buf_y, 75.0);  // 50 * 1.5
        }
        EnterKind::Phantom => panic!("cursor IS on this monitor — must be Real"),
    }
}

#[test]
fn test_hyprland_phantom_enter_detected() {
    //   raw = 100 - 3840 = -3740; corrected = -1820 < 0 → phantom ✓
    // Cursor on ANOTHER monitor: corrected falls outside [0, ovl] → phantom.
    let o = oracle_at((1920, 0), CompositorHint::Hyprland);
    assert!(matches!(o.classify_enter(-3740, 50), EnterKind::Phantom));
}

#[test]
fn test_motion_to_buffer_scales() {
    let o = oracle_at((1920, 0), CompositorHint::Hyprland);
    assert_eq!(o.motion_to_buffer(100, 200), (150.0, 300.0));
    // Motion is never classified or corrected — even on Hyprland.
    let o = oracle_at((0, 0), CompositorHint::Standard);
    assert_eq!(o.motion_to_buffer(0, 0), (0.0, 0.0));
}

//!
//! Oracle tests — Enter classification, Motion scaling and the strategy switch
//! by Hyprland version. Compositor empiricism (batch-Enter < 0.57) pinned down
//! as tests.

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
    // Hyprland < 0.57 batch-Enter: raw = cursor_global - 2*output_pos.
    //   raw = 2020 - 2*1920 = -1820; corrected = -1820 + 1920 = 100 ✓
    // Monitor at (1920, 0), cursor at global (2020, 50):
    //   raw = 2020 - 2*1920 = -1820; corrected = -1820 + 1920 = 100 ✓
    let o = oracle_at((1920, 0), CompositorHint::HyprlandLegacy);
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
    let o = oracle_at((1920, 0), CompositorHint::HyprlandLegacy);
    assert!(matches!(o.classify_enter(-3740, 50), EnterKind::Phantom));
}

#[test]
fn test_hyprland_057_enter_is_spec_local_under_standard() {
    // Regression 2026-11-07: Hyprland 0.57.1, single monitor at (1920, 0), cursor
    // at global (4233, 83) → Enter raw = (2313, 83), already surface-local. Under
    // Legacy corrected = 4233 > 2560 → phantom, no magnifier. Under Standard — Real.
    let legacy = Oracle::new((1920, 0), 2560, 1440, 2560, 1440, CompositorHint::HyprlandLegacy);
    assert!(matches!(legacy.classify_enter(2313, 83), EnterKind::Phantom));

    let standard = Oracle::new((1920, 0), 2560, 1440, 2560, 1440, CompositorHint::Standard);
    match standard.classify_enter(2313, 83) {
        EnterKind::Real { buf_x, buf_y } => {
            assert_eq!(buf_x, 2313.0);
            assert_eq!(buf_y, 83.0);
        }
        EnterKind::Phantom => panic!("spec-local Enter must be Real under Standard"),
    }
}

#[test]
fn test_parse_hyprland_version_formats() {
    // New format (≥ ~0.42): version on the first line.
    let modern = "Hyprland 0.57.1 built from branch v0.57.1-b at commit acc1aa0 clean ([gha] Nix: update inputs).\nDate: 2026-11-03\nTag: v0.57.1, commits: -1\n";
    assert_eq!(parse_hyprland_version(modern), Some((0, 57)));

    // Old format: no version on the first line, only in Tag.
    let legacy = "Hyprland, built from branch main at commit 1a2b3c4d dirty (fix: thing).\nDate: Mon Jun 10 2024\nTag: v0.41.2, commits: 4789\n";
    assert_eq!(parse_hyprland_version(legacy), Some((0, 41)));

    // Garbage → None, the detector falls back to Standard.
    assert_eq!(parse_hyprland_version(""), None);
    assert_eq!(parse_hyprland_version("Hyprland built from somewhere"), None);
}

#[test]
fn test_version_threshold_splits_legacy_and_spec() {
    // Threshold 0.57 inclusive: 0.55/0.56 → Legacy, 0.57+ and 1.x → Standard.
    assert!((0, 55) < HYPRLAND_SPEC_ENTER_SINCE);
    assert!((0, 56) < HYPRLAND_SPEC_ENTER_SINCE);
    assert!((0, 57) >= HYPRLAND_SPEC_ENTER_SINCE);
    assert!((0, 58) >= HYPRLAND_SPEC_ENTER_SINCE);
    assert!((1, 0) >= HYPRLAND_SPEC_ENTER_SINCE);
}

#[test]
fn test_motion_to_buffer_scales() {
    let o = oracle_at((1920, 0), CompositorHint::HyprlandLegacy);
    assert_eq!(o.motion_to_buffer(100, 200), (150.0, 300.0));
    // Motion is never classified or corrected — even on Hyprland.
    let o = oracle_at((0, 0), CompositorHint::Standard);
    assert_eq!(o.motion_to_buffer(0, 0), (0.0, 0.0));
}

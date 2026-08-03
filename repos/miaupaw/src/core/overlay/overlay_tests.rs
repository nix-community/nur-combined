//!
//! Overlay state-machine tests: handle_action clamps, deck, take_session.
//! The core renders into `&mut [u32]` and knows nothing about the OS — it
//! builds with no display, fonts, or Wayland: empty font data yields
//! TextMetrics::zero / font=None.

use super::*;
use crate::core::capture::{PhysicalCanvas, ScreenCapture};
use crate::core::config::Config;
use std::sync::Arc;

/// 100×100 uniform canvas + default config + empty fonts.
fn app() -> OverlayApp {
    app_with_fill(0x808080)
}

fn app_with_fill(fill: u32) -> OverlayApp {
    let capture = ScreenCapture {
        xrgb_buffer: vec![fill; 100 * 100],
        width: 100,
        height: 100,
    };
    let canvas = PhysicalCanvas::from_single(capture, None);
    OverlayApp::new(
        canvas,
        Config::default(),
        Arc::new(Vec::new()),
        Arc::new(Vec::new()),
        "TEST".to_string(),
        1.0,
    )
}

#[test]
fn test_new_normalizes_to_odd() {
    let app = app();
    assert_eq!(app.config.magnifier.aperture % 2, 1, "aperture must be odd");
    assert_eq!(app.config.magnifier.size % 2, 1, "size must be odd");
    assert_eq!(app.config.magnifier.aim_size % 2, 1, "aim_size must be odd");
    assert!(app.config.magnifier.aim_size <= app.config.magnifier.aperture);
}

#[test]
fn test_zoom_keeps_aperture_within_size_and_odd() {
    let mut app = app();
    // Zoom out to the stop: aperture must never exceed size.
    for _ in 0..200 {
        app.handle_action(UserAction::Zoom(-1));
    }
    assert!(app.config.magnifier.aperture <= app.config.magnifier.size);
    assert_eq!(app.config.magnifier.aperture % 2, 1);

    // Zoom in to the stop: minimum 1, oddness preserved.
    for _ in 0..200 {
        app.handle_action(UserAction::Zoom(1));
    }
    assert!(app.config.magnifier.aperture >= 1);
    assert_eq!(app.config.magnifier.aperture % 2, 1);
}

#[test]
fn test_resize_cascades_aperture_and_aim() {
    let mut app = app();
    // Shrink the window to the stop: the size → aperture → aim_size cascade
    // must preserve aperture ≤ size and aim_size ≤ aperture.
    for _ in 0..200 {
        app.handle_action(UserAction::ResizeMagnifier(-1));
    }
    let m = &app.config.magnifier;
    assert!(m.aperture <= m.size, "aperture {} > size {}", m.aperture, m.size);
    assert!(m.aim_size <= m.aperture, "aim {} > aperture {}", m.aim_size, m.aperture);
    assert_eq!(m.size % 2, 1);
    assert_eq!(m.aperture % 2, 1);
}

#[test]
fn test_aim_size_capped_by_aperture_and_odd() {
    let mut app = app();
    for _ in 0..200 {
        app.handle_action(UserAction::ChangeAimSize(1));
    }
    let m = &app.config.magnifier;
    assert!(m.aim_size <= m.aperture);
    assert_eq!(m.aim_size % 2, 1);

    for _ in 0..200 {
        app.handle_action(UserAction::ChangeAimSize(-1));
    }
    assert!(app.config.magnifier.aim_size >= 1);
    assert_eq!(app.config.magnifier.aim_size % 2, 1);
}

#[test]
fn test_select_format_digit_convention() {
    // keymap convention: the digit as typed. '1' → first template, '0' → tenth.
    use crate::core::config::TEMPLATE_LABELS;
    let mut app = app();
    app.handle_action(UserAction::SelectFormatDigit(1));
    assert_eq!(app.config.templates.selected, TEMPLATE_LABELS[0].0);
    app.handle_action(UserAction::SelectFormatDigit(9));
    assert_eq!(app.config.templates.selected, TEMPLATE_LABELS[8].0);
    app.handle_action(UserAction::SelectFormatDigit(0));
    assert_eq!(app.config.templates.selected, TEMPLATE_LABELS[9].0);
}

#[test]
fn test_serial_pick_pushes_pick_record() {
    let mut app = app_with_fill(0x123456);
    app.update_cursor(5.0, 7.0);
    app.handle_action(UserAction::PickColor { serial: true });

    assert_eq!(app.deck.len(), 1);
    let p = app.deck[0];
    assert_eq!(p.color, image::Rgba([0x12, 0x34, 0x56, 255]));
    assert_eq!((p.tile, p.phys_x, p.phys_y), (0, 5, 7));
    assert!(!app.should_exit, "serial pick must not close the overlay");
    assert!(app.flash_intensity > 0.0, "serial pick flashes");
}

#[test]
fn test_pick_disabled_gate() {
    let mut app = app();
    app.config.pick.enabled = false;
    app.update_cursor(5.0, 5.0);
    app.handle_action(UserAction::PickColor { serial: true });
    app.handle_action(UserAction::PickColor { serial: false });

    assert!(app.deck.is_empty(), "pick.enabled=false must gate every sample gesture");
    assert!(!app.should_exit, "final pick is a no-op too — overlay stays (magnifier mode)");
}

#[test]
fn test_cancel_clears_deck_and_exits() {
    let mut app = app();
    app.update_cursor(5.0, 5.0);
    app.handle_action(UserAction::PickColor { serial: true });
    app.handle_action(UserAction::Cancel);

    assert!(app.deck.is_empty());
    assert!(app.should_exit);
}

#[test]
fn test_take_session_lockstep_and_drain() {
    let mut app = app_with_fill(0xA0B0C0);
    app.update_cursor(3.0, 4.0);
    app.handle_action(UserAction::PickColor { serial: true });
    app.update_cursor(10.0, 20.0);
    app.handle_action(UserAction::PickColor { serial: true });

    let session = app.take_session();
    // All three projections share one length — by construction from Vec<Pick>.
    assert_eq!(session.colors.len(), 2);
    assert_eq!(session.coords.len(), 2);
    assert_eq!(session.phys_coords.len(), 2);
    assert_eq!(session.phys_coords, vec![(0, 3, 4), (0, 10, 20)]);
    // Single-tile canvas at scale 1.0: logical view == physical view.
    assert_eq!(session.coords, vec![(3, 4), (10, 20)]);

    // Deck drained; a second take yields an empty session.
    assert!(app.deck.is_empty());
    let empty = app.take_session();
    assert!(empty.colors.is_empty() && empty.coords.is_empty() && empty.phys_coords.is_empty());
}

// ─── update(): state ticks, headless ────────────────────────────────────────

use std::time::{Duration, Instant};

#[test]
fn test_update_watchdog_auto_cancel() {
    let mut app = app();
    app.config.system.auto_cancel = 5;
    app.last_activity = Instant::now() - Duration::from_secs(6);
    app.update(0.016);
    assert!(app.should_exit, "inactivity beyond auto_cancel closes the overlay");
}

#[test]
fn test_update_watchdog_disabled_when_zero() {
    let mut app = app();
    app.config.system.auto_cancel = 0;
    app.last_activity = Instant::now() - Duration::from_secs(3600);
    app.update(0.016);
    assert!(!app.should_exit, "auto_cancel=0 disables the watchdog");
}

#[test]
fn test_update_flash_decays_to_zero() {
    let mut app = app();
    app.flash_intensity = 1.0;
    app.update(0.016);
    assert!(app.flash_intensity < 1.0);
    assert!(app.needs_redraw, "decaying flash keeps the loop alive");
    for _ in 0..100 {
        app.update(0.016);
    }
    assert_eq!(app.flash_intensity, 0.0);
}

#[test]
fn test_update_repeat_moves_aim_after_delay() {
    let mut app = app();
    app.update_cursor(50.0, 50.0);
    let now = Instant::now();
    app.repeat_tracker = Some(RepeatState {
        dx: 1,
        dy: 0,
        is_jump: false,
        started: now - Duration::from_millis(400),
        last_repeat: now - Duration::from_millis(100),
    });
    app.update(0.016);
    assert_eq!(app.aim_pos, Some((51.0, 50.0)), "repeat nudges the aim by 1px");
    assert!(app.needs_redraw);

    // KeyRelease of the same key — instant stop.
    app.handle_action(UserAction::KeyRelease { dx: 1, dy: 0 });
    assert!(app.repeat_tracker.is_none());
}

#[test]
fn test_update_repeat_waits_initial_delay() {
    let mut app = app();
    app.update_cursor(50.0, 50.0);
    let now = Instant::now();
    app.repeat_tracker = Some(RepeatState {
        dx: 1,
        dy: 0,
        is_jump: false,
        started: now,
        last_repeat: now,
    });
    app.update(0.016);
    assert_eq!(app.aim_pos, Some((50.0, 50.0)), "no movement before the 350ms delay");
}

#[test]
fn test_update_blink_lifecycle() {
    let mut app = app();
    app.update_cursor(50.0, 50.0);
    app.blink = Some(BlinkState {
        origin: (50.0, 50.0),
        squares: vec![BlinkSquare { color: 0xFF0000, delay: 0.0 }],
        start_size: 100.0,
        started: Instant::now(),
        duration: 10.0,
        fly_time: 0.3,
    });

    app.update(0.016);
    assert!(app.blink.is_some(), "mid-flight: the train is alive");
    assert!(app.needs_redraw);
    assert!(!app.should_exit);
    assert!(app.magnifier_layout.is_none(), "magnifier hidden while blink flies");

    app.blink.as_mut().unwrap().started = Instant::now() - Duration::from_secs(11);
    app.update(0.016);
    assert!(app.blink.is_none(), "landed: the train is gone");
    assert!(app.should_exit, "landing closes the overlay");
}

#[test]
fn test_update_layout_presence_follows_mouse() {
    let mut app = app();
    app.update(0.016);
    assert!(app.magnifier_layout.is_none(), "no aim — no layout");

    app.update_cursor(50.0, 50.0);
    app.update(0.016);
    assert!(app.magnifier_layout.is_some(), "live aim — layout computed");
}

#[test]
fn test_update_border_pulse_kicks_in_before_timeout() {
    let mut app = app();
    app.config.system.auto_cancel = 30;
    app.update_cursor(50.0, 50.0);
    let calm = app.config.colors.frame;

    app.update(0.016);
    assert_eq!(app.border_color, calm, "fresh activity — calm frame");

    // 25s idle of 30: inside the 10-second warning window — the frame pulses.
    app.last_activity = Instant::now() - Duration::from_secs(25);
    app.update(0.016);
    assert_ne!(app.border_color, calm, "warning window — pulsing frame");
    assert!(app.needs_redraw, "pulse keeps the loop alive");
    assert!(!app.should_exit);
}

use super::*;

#[test]
fn test_ensure_odd() {
    assert_eq!(ensure_odd(10), 11);
    assert_eq!(ensure_odd(11), 11);
    assert_eq!(ensure_odd(0), 1);
    assert_eq!(ensure_odd(-2), -1);
}

// ─── step(): springs and geometry, headless ─────────────────────────────────

use crate::core::capture::{PhysicalCanvas, ScreenCapture};
use crate::core::config::Config;

fn canvas_400() -> PhysicalCanvas {
    PhysicalCanvas::from_single(
        ScreenCapture { xrgb_buffer: vec![0x808080; 400 * 400], width: 400, height: 400 },
        None,
    )
}

fn settle(mag: &mut Magnifier, config: &Config, canvas: &PhysicalCanvas, x: f64, y: f64,
          monitor_rect: Option<(i32, i32, i32, i32)>) -> Layout {
    let ctx = StepCtx {
        config,
        canvas,
        aim_pos: (x, y),
        local_mx: x as i32,
        local_my: y as i32,
        buf_w: 400,
        buf_h: 400,
        monitor_rect,
    };
    let mut layout = mag.step(0.016, &ctx);
    for _ in 0..5000 {
        if !layout.animating {
            break;
        }
        layout = mag.step(0.016, &ctx);
    }
    layout
}

#[test]
fn test_step_springs_settle_and_grid_is_odd() {
    let config = Config::default();
    let canvas = canvas_400();
    let mut mag = Magnifier::new(std::sync::Arc::new(Vec::new()), config.font.size);

    let layout = settle(&mut mag, &config, &canvas, 50.0, 200.0, None);
    assert!(!layout.animating, "springs must settle");
    assert_eq!(layout.grid_size % 2, 1, "Optical Monolith: odd grid");
    // Plenty of room on the right — magnifier sits right of the cursor.
    assert!(layout.start_x > 50);
}

#[test]
fn test_step_edge_flip_left_at_right_edge() {
    let config = Config::default();
    let canvas = canvas_400();
    let mut mag = Magnifier::new(std::sync::Arc::new(Vec::new()), config.font.size);

    // Cursor at the right buffer edge: the magnifier must flip left and stay
    // fully inside the bounds. (Multi-monitor edge regression guard.)
    let layout = settle(&mut mag, &config, &canvas, 390.0, 200.0, None);
    assert!(
        layout.start_x + layout.total_width as i32 <= 400,
        "stays inside the buffer: start_x={} total={}",
        layout.start_x,
        layout.total_width
    );
    assert!(layout.start_x < 390, "flipped left of the cursor");
}

#[test]
fn test_step_clamps_to_monitor_rect() {
    let config = Config::default();
    let canvas = canvas_400();
    let mut mag = Magnifier::new(std::sync::Arc::new(Vec::new()), config.font.size);

    // A virtual 200×200 monitor at (100,100) — the magnifier honours its origin.
    let layout = settle(&mut mag, &config, &canvas, 110.0, 110.0, Some((100, 100, 200, 200)));
    assert!(layout.start_x >= 100, "clamped to monitor x0: {}", layout.start_x);
    assert!(layout.start_y >= 100, "clamped to monitor y0: {}", layout.start_y);
}

//! CLI surface tests: dual coord syntax and emit-side conversion.

use super::*;
use crate::core::capture::{MonitorTile, PhysicalCanvas, ScreenCapture};
use wayland_client::protocol::wl_output::Transform;

#[test]
fn test_parse_logical_default() {
    assert!(matches!(
        parse_pixel_coords("100,200", false),
        Ok(PixelCoord::Logical(100, 200))
    ));
    assert!(matches!(
        parse_pixel_coords("100 200", false),
        Ok(PixelCoord::Logical(100, 200))
    ));
}

#[test]
fn test_parse_explicit_physical_syntax_wins_over_flag() {
    assert!(matches!(
        parse_pixel_coords("2:10,20", false),
        Ok(PixelCoord::Physical(2, 10, 20))
    ));
    assert!(matches!(
        parse_pixel_coords("2:10,20", true),
        Ok(PixelCoord::Physical(2, 10, 20))
    ));
}

#[test]
fn test_parse_phys_flag_defers_monitor_resolution() {
    // --ph without N: — monitor resolves after capture (PhysicalDefaulted).
    assert!(matches!(
        parse_pixel_coords("10,20", true),
        Ok(PixelCoord::PhysicalDefaulted(10, 20))
    ));
}

#[test]
fn test_parse_negative_coords() {
    // Negative logical coords are legal (monitors left of the origin).
    assert!(matches!(
        parse_pixel_coords("-5,7", false),
        Ok(PixelCoord::Logical(-5, 7))
    ));
}

#[test]
fn test_parse_rejects_garbage() {
    assert!(parse_pixel_coords("abc", false).is_err());
    assert!(parse_pixel_coords("1,2,3", false).is_err());
    assert!(parse_pixel_coords("x:1,2", false).is_err());
    assert!(parse_pixel_coords("", false).is_err());
}

fn canvas_scale2_at(pos: (i32, i32)) -> PhysicalCanvas {
    // 100×100 logical at scale 2.0 → 200×200 physical.
    PhysicalCanvas::build(vec![MonitorTile {
        capture: ScreenCapture { xrgb_buffer: vec![0; 200 * 200], width: 200, height: 200 },
        output: None,
        name: String::new(),
        scale: 2.0,
        logical_pos: pos,
        logical_w: 100,
        logical_h: 100,
        transform: Transform::Normal,
    }])
}

#[test]
fn test_render_coord_identity_when_form_matches() {
    let canvas = canvas_scale2_at((0, 0));
    assert!(matches!(
        render_coord(&canvas, PixelCoord::Logical(10, 10), false),
        PixelCoord::Logical(10, 10)
    ));
    assert!(matches!(
        render_coord(&canvas, PixelCoord::Physical(0, 20, 20), true),
        PixelCoord::Physical(0, 20, 20)
    ));
}

#[test]
fn test_render_coord_converts_both_ways() {
    let canvas = canvas_scale2_at((0, 0));
    assert!(matches!(
        render_coord(&canvas, PixelCoord::Logical(10, 10), true),
        PixelCoord::Physical(0, 20, 20)
    ));
    assert!(matches!(
        render_coord(&canvas, PixelCoord::Physical(0, 20, 20), false),
        PixelCoord::Logical(10, 10)
    ));
}

#[test]
fn test_render_coord_stays_absolute_on_offset_origin() {
    // Monitor anchored at (-100, 0): CLI logical coords are absolute
    // compositor space — the layout origin does NOT shift the conversion
    // (2026-08-09 contract, artifacts/2026.08.09/coords-investigation.md).
    let canvas = canvas_scale2_at((-100, 0));
    assert!(matches!(
        render_coord(&canvas, PixelCoord::Logical(-90, 10), true),
        PixelCoord::Physical(0, 20, 20)
    ));
    assert!(matches!(
        render_coord(&canvas, PixelCoord::Physical(0, 20, 20), false),
        PixelCoord::Logical(-90, 10)
    ));
}

#[test]
fn test_render_coord_off_canvas_falls_back_to_input_form() {
    let canvas = canvas_scale2_at((0, 0));
    // Off-canvas: stderr warning + the input form, no silent corruption.
    assert!(matches!(
        render_coord(&canvas, PixelCoord::Logical(5000, 5000), true),
        PixelCoord::Logical(5000, 5000)
    ));
}

#[test]
fn test_coord_input_string_roundtrip() {
    assert_eq!(PixelCoord::Logical(3, 4).as_input_string(), "3,4");
    assert_eq!(PixelCoord::Physical(1, 3, 4).as_input_string(), "1:3,4");
    assert_eq!(PixelCoord::PhysicalDefaulted(3, 4).as_input_string(), "?:3,4");
}

/// Cross-mode contract: a row printed by `--monitors` must re-parse as `--pixel`
/// input and land exactly on its monitor's top-left pixel. This is the test that
/// would have caught the original coord defect — `run_monitors` printed raw
/// compositor positions while `--pixel` consumed canvas-shifted ones, and every
/// single-mode test still passed.
#[test]
fn test_monitors_row_feeds_back_into_pixel_input() {
    for origin in [(0, 0), (1920, 0), (-1820, -200)] {
        let canvas = canvas_scale2_at(origin);
        let row = crate::probe::monitor_row(0, &canvas.tiles[0], &canvas);

        let fields: Vec<&str> = row.split('\t').collect();
        assert_eq!(fields.len(), 6, "row shape changed: {row:?}");

        // The X,Y field must parse with the very same parser user input goes through.
        let coord = parse_pixel_coords(fields[3], false)
            .unwrap_or_else(|e| panic!("printed coord {:?} is not valid input: {e}", fields[3]));

        let PixelCoord::Logical(x, y) = coord else {
            panic!("--monitors must print logical coords, got {coord:?}");
        };

        assert_eq!(
            canvas.logical_to_physical(x, y),
            Some((0, 0, 0)),
            "origin {origin:?}: printed {x},{y} must resolve to tile 0 local (0,0)"
        );
    }
}

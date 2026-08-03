//! Capture-layer tests: transform kernel + PhysicalCanvas coordinate math.

use super::*;
use wayland_client::protocol::wl_output::Transform;

// ─── Transform kernel ───────────────────────────────────────────────────────

#[test]
fn test_apply_transform_identity() {
    let capture = ScreenCapture {
        xrgb_buffer: vec![1, 2, 3, 4, 5, 6],
        width: 3,
        height: 2,
    };
    let result = apply_transform(capture, Transform::Normal);
    assert_eq!(result.width, 3);
    assert_eq!(result.height, 2);
    assert_eq!(result.xrgb_buffer, vec![1, 2, 3, 4, 5, 6]);
}

#[test]
fn test_apply_transform_flipped() {
    // Source (3x2):
    // [1, 2, 3]
    // [4, 5, 6]
    // Flipped (horizontal mirror):
    // [3, 2, 1]
    // [6, 5, 4]
    let capture = ScreenCapture {
        xrgb_buffer: vec![1, 2, 3, 4, 5, 6],
        width: 3,
        height: 2,
    };
    let result = apply_transform(capture, Transform::Flipped);
    assert_eq!(result.width, 3);
    assert_eq!(result.height, 2);
    assert_eq!(result.xrgb_buffer, vec![3, 2, 1, 6, 5, 4]);
}

#[test]
fn test_apply_transform_90() {
    // Source (3x2):
    // [1, 2, 3]
    // [4, 5, 6]
    // 90 deg clockwise:
    // [4, 1]
    // [5, 2]
    // [6, 3]
    let capture = ScreenCapture {
        xrgb_buffer: vec![1, 2, 3, 4, 5, 6],
        width: 3,
        height: 2,
    };
    let result = apply_transform(capture, Transform::_90);
    assert_eq!(result.width, 2);
    assert_eq!(result.height, 3);
    assert_eq!(result.xrgb_buffer, vec![4, 1, 5, 2, 6, 3]);
}

#[test]
fn test_apply_transform_180() {
    // Source (3x2):
    // [1, 2, 3]
    // [4, 5, 6]
    // 180 deg:
    // [6, 5, 4]
    // [3, 2, 1]
    let capture = ScreenCapture {
        xrgb_buffer: vec![1, 2, 3, 4, 5, 6],
        width: 3,
        height: 2,
    };
    let result = apply_transform(capture, Transform::_180);
    assert_eq!(result.width, 3);
    assert_eq!(result.height, 2);
    assert_eq!(result.xrgb_buffer, vec![6, 5, 4, 3, 2, 1]);
}

#[test]
fn test_apply_transform_270() {
    // Source (3x2):
    // [1, 2, 3]
    // [4, 5, 6]
    // 270 deg clockwise (or 90 deg counter-clockwise):
    // [3, 6]
    // [2, 5]
    // [1, 4]
    let capture = ScreenCapture {
        xrgb_buffer: vec![1, 2, 3, 4, 5, 6],
        width: 3,
        height: 2,
    };
    let result = apply_transform(capture, Transform::_270);
    assert_eq!(result.width, 2);
    assert_eq!(result.height, 3);
    assert_eq!(result.xrgb_buffer, vec![3, 6, 2, 5, 1, 4]);
}

// ─── PhysicalCanvas coordinate math ─────────────────────────────────────────
// The project's minefield: logical↔physical conversions, fractional scale,
// negative origins. Tiles are built by hand (output: None) — no Wayland
// connection required.

/// A tile filled with a single value. Scale derives as phys_w / logical_w.
fn tile(
    fill: u32,
    phys_w: u32,
    phys_h: u32,
    logical_pos: (i32, i32),
    logical_w: i32,
    logical_h: i32,
) -> MonitorTile {
    MonitorTile {
        capture: ScreenCapture {
            xrgb_buffer: vec![fill; (phys_w * phys_h) as usize],
            width: phys_w,
            height: phys_h,
        },
        output: None,
        name: String::new(),
        scale: phys_w as f64 / logical_w as f64,
        logical_pos,
        logical_w,
        logical_h,
        transform: Transform::Normal,
    }
}

#[test]
fn test_roundtrip_fractional_scale() {
    // 100x100 logical at scale 1.5 → 150x150 physical.
    let canvas = PhysicalCanvas::build(vec![tile(0xABCDEF, 150, 150, (0, 0), 100, 100)]);

    assert_eq!(canvas.logical_to_physical(10, 10), Some((0, 15, 15)));
    assert_eq!(canvas.physical_to_logical(0, 15, 15), Some((10, 10)));

    // Round-trip across the whole logical space survives the f64 detour.
    for l in [0, 1, 33, 67, 99] {
        let (idx, px, py) = canvas.logical_to_physical(l, l).unwrap();
        assert_eq!(canvas.physical_to_logical(idx, px, py), Some((l, l)), "logical {l}");
    }
}

#[test]
fn test_negative_origin_min_origin_and_logical_coords_for() {
    // Left monitor anchored at -1920 — the real "secondary on the left" layout.
    let canvas = PhysicalCanvas::build(vec![
        tile(0x111111, 1920, 1080, (-1920, 0), 1920, 1080),
        tile(0x222222, 1920, 1080, (0, 0), 1920, 1080),
    ]);

    assert_eq!(canvas.min_origin(), (-1920, 0));

    // Per-tile-physical deck → desktop-relative logical (grim/slurp convention).
    let coords = canvas.logical_coords_for(&[(0, 10, 10), (1, 5, 5)]);
    assert_eq!(coords, vec![(10, 10), (1925, 5)]);
}

#[test]
fn test_sample_logical_routes_to_correct_tile() {
    let canvas = PhysicalCanvas::build(vec![
        tile(0x111111, 1920, 1080, (-1920, 0), 1920, 1080),
        tile(0x222222, 1920, 1080, (0, 0), 1920, 1080),
    ]);

    // Absolute compositor logical space (no min_origin shift).
    assert_eq!(canvas.sample_logical(-1915, 5), Some(0x111111));
    assert_eq!(canvas.sample_logical(5, 5), Some(0x222222));
    assert_eq!(canvas.sample_logical(-5000, 5), None);
    assert_eq!(canvas.sample_logical(5000, 5), None);
}

#[test]
fn test_sample_vector_oob_is_per_element() {
    let canvas = PhysicalCanvas::build(vec![tile(0x334455, 100, 100, (0, 0), 100, 100)]);

    let results = canvas.sample_vector(&[(5, 5), (99_999, 0), (99, 99)], 0);
    assert_eq!(results, vec![Some(0x334455), None, Some(0x334455)]);
}

#[test]
fn test_sample_in_tile_average_uniform_and_oob() {
    let canvas = PhysicalCanvas::build(vec![tile(0x404040, 9, 9, (0, 0), 9, 9)]);

    // Uniform fill: average == the value at any radius.
    assert_eq!(canvas.sample_in_tile_average(0, 4, 4, 1), Some(0x404040));
    // OOB neighbours are excluded from the average, not pulled toward zero.
    assert_eq!(canvas.sample_in_tile_average(0, 0, 0, 2), Some(0x404040));
    // OOB centre — None (single-read contract).
    assert_eq!(canvas.sample_in_tile_average(0, 50, 50, 1), None);
    // Non-existent monitor — None.
    assert_eq!(canvas.sample_in_tile_average(7, 4, 4, 0), None);
}

#[test]
fn test_average_kernel_math() {
    // 3×3: centre 90, the rest 9 → (90 + 8*9) / 9 = 18.
    let grid = [[9u32, 9, 9], [9, 90, 9], [9, 9, 9]];
    let result = average_kernel(1, |dx, dy| {
        let x = (1 + dx) as usize;
        let y = (1 + dy) as usize;
        grid.get(y).and_then(|row| row.get(x)).copied()
    });
    assert_eq!(result, Some(18));

    // All samples OOB → None.
    assert_eq!(average_kernel(1, |_, _| None::<u32>), None);
}

#[derive(Clone, Copy)]
pub enum TriangleDir {
    Up,
    Down,
    Left,
    Right,
}

/// Draws an anti-aliased triangle using 4x4 SSAA.
/// CPU math, 0 allocations, perfect edges with no external dependencies.
#[allow(clippy::too_many_arguments)]
pub fn draw_aa_triangle(
    buffer: &mut [u32],
    buf_w: usize,
    buf_h: usize,
    x: f32,
    y: f32,
    size: f32,
    dir: TriangleDir,
    color: u32,
) {
    let r_new = ((color >> 16) & 0xFF) as f32;
    let g_new = ((color >> 8) & 0xFF) as f32;
    let b_new = (color & 0xFF) as f32;

    let cx = x + size / 2.0;
    let cy = y + size / 2.0;
    
    // Make the triangle slightly smaller than the bounding box for aesthetics
    let s = size * 0.8;

    let (x1, y1, x2, y2, x3, y3) = match dir {
        TriangleDir::Right => (cx - s / 2.0, cy - s / 2.0, cx - s / 2.0, cy + s / 2.0, cx + s / 2.0, cy),
        TriangleDir::Left  => (cx + s / 2.0, cy - s / 2.0, cx + s / 2.0, cy + s / 2.0, cx - s / 2.0, cy),
        TriangleDir::Up    => (cx - s / 2.0, cy + s / 2.0, cx + s / 2.0, cy + s / 2.0, cx, cy - s / 2.0),
        TriangleDir::Down  => (cx - s / 2.0, cy - s / 2.0, cx + s / 2.0, cy - s / 2.0, cx, cy + s / 2.0),
    };

    let px_min = x.floor() as i32;
    let px_max = (x + size).ceil() as i32;
    let py_min = y.floor() as i32;
    let py_max = (y + size).ceil() as i32;

    for py in py_min..=py_max {
        for px in px_min..=px_max {
            if px < 0 || px >= buf_w as i32 || py < 0 || py >= buf_h as i32 {
                continue;
            }

            let mut coverage = 0;
            // 4x4 SSAA (sampling 16 subpixels)
            for sy in 0..4 {
                for sx in 0..4 {
                    let tx = px as f32 + (sx as f32 + 0.5) / 4.0;
                    let ty = py as f32 + (sy as f32 + 0.5) / 4.0;
                    
                    let d1 = (tx - x2) * (y1 - y2) - (x1 - x2) * (ty - y2);
                    let d2 = (tx - x3) * (y2 - y3) - (x2 - x3) * (ty - y3);
                    let d3 = (tx - x1) * (y3 - y1) - (x3 - x1) * (ty - y1);
                    
                    let has_neg = (d1 < 0.0) || (d2 < 0.0) || (d3 < 0.0);
                    let has_pos = (d1 > 0.0) || (d2 > 0.0) || (d3 > 0.0);
                    
                    if !(has_neg && has_pos) {
                        coverage += 1;
                    }
                }
            }

            if coverage > 0 {
                let alpha = coverage as f32 / 16.0;
                let bg_color = buffer[(py as usize) * buf_w + (px as usize)];
                
                let r_bg = ((bg_color >> 16) & 0xFF) as f32;
                let g_bg = ((bg_color >> 8) & 0xFF) as f32;
                let b_bg = (bg_color & 0xFF) as f32;

                let r = (r_new * alpha + r_bg * (1.0 - alpha)) as u32;
                let g = (g_new * alpha + g_bg * (1.0 - alpha)) as u32;
                let b = (b_new * alpha + b_bg * (1.0 - alpha)) as u32;

                let final_color = (r << 16) | (g << 8) | b;
                buffer[(py as usize) * buf_w + (px as usize)] = final_color;
            }
        }
    }
}

#[allow(clippy::too_many_arguments)]
pub fn draw_color_deck(
    buffer: &mut [u32],
    width: usize,
    height: usize,
    start_x: i32,
    start_y: i32,
    mag_width: usize,
    deck: &[image::Rgba<u8>],
    frame_color: u32,
) -> (i32, i32, usize, usize) {
    if deck.is_empty() {
        return (start_x, start_y, 0, 0);
    }

    let n = deck.len();
    let box_size = 14;
    let gap = 2;
    let ideal_width = n * box_size + n.saturating_sub(1) * gap;

    // The total drawing width will not exceed mag_width
    let render_width = ideal_width.min(mag_width);

    let start_draw_x = if ideal_width < mag_width {
        start_x + (mag_width as i32 - ideal_width as i32) / 2
    } else {
        start_x
    };

    let step = if ideal_width > mag_width && n > 1 {
        (mag_width as f64 - box_size as f64) / (n - 1) as f64
    } else {
        (box_size + gap) as f64
    };

    for (i, color) in deck.iter().enumerate() {
        let x = start_draw_x + (i as f64 * step).round() as i32;
        let y = start_y;
        
        let c_u32 = ((color.0[0] as u32) << 16) | ((color.0[1] as u32) << 8) | (color.0[2] as u32);
        
        super::primitives::draw_rect(buffer, width, height, x, y, box_size, box_size, frame_color);
        super::primitives::draw_filled_rect(buffer, width, height, x + 1, y + 1, box_size - 2, box_size - 2, c_u32);
    }

    (start_draw_x, start_y, render_width, box_size)
}

/// Draws a phantom satellite cursor at the logical aim point,
/// when the system cursor has lagged behind (e.g. keyboard navigation).
/// Uses fast bitwise inversion (XOR) to always be contrasted against the background.
pub fn draw_satellite_cursor(
    buffer: &mut [u32],
    buf_w: usize,
    buf_h: usize,
    cx: i32,
    cy: i32,
) -> (i32, i32, usize, usize) {
    let s = 10; // offset from center
    let l = 8; // corner arm length
    let t = 1; // line thickness

    let mut draw_xor_rect = |rx: i32, ry: i32, rw: i32, rh: i32| {
        for y in ry..(ry + rh) {
            for x in rx..(rx + rw) {
                if x >= 0 && x < buf_w as i32 && y >= 0 && y < buf_h as i32 {
                    let idx = (y as usize) * buf_w + (x as usize);
                    buffer[idx] ^= 0x00FFFFFF;
                }
            }
        }
    };

    // Center dot
    draw_xor_rect(cx - t / 2, cy - t / 2, t, t);

    // Top-left ⌜
    draw_xor_rect(cx - s, cy - s, l, t); // horizontal
    draw_xor_rect(cx - s, cy - s, t, l); // vertical

    // Top-right ⌝
    draw_xor_rect(cx + s - l + t, cy - s, l, t);
    draw_xor_rect(cx + s, cy - s, t, l);

    // Bottom-left ⌞
    draw_xor_rect(cx - s, cy + s, l, t);
    draw_xor_rect(cx - s, cy + s - l + t, t, l);

    // Bottom-right ⌟
    draw_xor_rect(cx + s - l + t, cy + s, l, t);
    draw_xor_rect(cx + s, cy + s - l + t, t, l);

    // Return bounding box with margin
    let bound_size = ((s + t) * 2 + 4) as usize;
    let bound_start_x = cx - s - t - 2;
    let bound_start_y = cy - s - t - 2;

    (bound_start_x, bound_start_y, bound_size, bound_size)
}

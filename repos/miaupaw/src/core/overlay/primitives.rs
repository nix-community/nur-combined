/// Drawing primitives and utilities.
///
/// Pure stateless functions: set_pixel, draw_rect, draw_filled_rect.
/// Used by other overlay modules to render UI elements.
/// Safe pixel set (with bounds check)
pub fn set_pixel(buffer: &mut [u32], width: usize, height: usize, x: i32, y: i32, color: u32) {
    if x >= 0 && x < width as i32 && y >= 0 && y < height as i32 {
        buffer[(y as usize) * width + (x as usize)] = color;
    }
}

/// Draw an empty rectangle (outline)
#[allow(clippy::too_many_arguments)]
pub fn draw_rect(
    buffer: &mut [u32],
    width: usize,
    height: usize,
    x: i32,
    y: i32,
    w: usize,
    h: usize,
    color: u32,
) {
    for i in 0..w {
        set_pixel(buffer, width, height, x + i as i32, y, color);
        set_pixel(buffer, width, height, x + i as i32, y + h as i32 - 1, color);
    }
    for i in 0..h {
        set_pixel(buffer, width, height, x, y + i as i32, color);
        set_pixel(buffer, width, height, x + w as i32 - 1, y + i as i32, color);
    }
}

/// Draw a filled rectangle.
///
/// Optimization: bounds are checked once, then each row is filled
/// via `slice.fill(color)` — memset-level performance (SIMD).
#[allow(clippy::too_many_arguments)]
pub fn draw_filled_rect(
    buffer: &mut [u32],
    width: usize,
    height: usize,
    x: i32,
    y: i32,
    w: usize,
    h: usize,
    color: u32,
) {
    // Clamp rectangle to buffer bounds
    let x0 = (x.max(0) as usize).min(width);
    let y0 = (y.max(0) as usize).min(height);
    let x1 = ((x + w as i32).max(0) as usize).min(width);
    let y1 = ((y + h as i32).max(0) as usize).min(height);

    for row in y0..y1 {
        let start = row * width + x0;
        let end = row * width + x1;
        buffer[start..end].fill(color);
    }
}

/// Copies a rectangular region from background into canvas (row-by-row via memcpy).
#[allow(clippy::too_many_arguments)]
pub fn copy_region(
    canvas: &mut [u32],
    bg: &[u32],
    buf_w: usize,
    buf_h: usize,
    x: i32,
    y: i32,
    w: usize,
    h: usize,
) {
    let x0 = (x.max(0) as usize).min(buf_w);
    let y0 = (y.max(0) as usize).min(buf_h);
    let x1 = ((x + w as i32).max(0) as usize).min(buf_w);
    let y1 = ((y + h as i32).max(0) as usize).min(buf_h);

    for row in y0..y1 {
        let start = row * buf_w + x0;
        let end = row * buf_w + x1;
        if end <= canvas.len() && end <= bg.len() {
            canvas[start..end].copy_from_slice(&bg[start..end]);
        }
    }
}

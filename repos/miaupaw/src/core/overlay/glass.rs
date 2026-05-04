/// **Frosted Glass / Glassmorphism Effect**
/// Implementation of frosted glass effect via optimized Box Blur (O(N))
/// with a two-pass strategy (horizontal + vertical) and zero-alloc
/// via pre-sized scratchpads.
/// Render frosted glass with blur and semi-transparent tint.
/// Uses provided scratchpad buffers for zero-alloc operation.
#[allow(clippy::too_many_arguments)]
pub fn draw_frosted_rect(
    canvas: &mut [u32],
    width: usize,
    height: usize,
    x: i32,
    y: i32,
    w: usize,
    h: usize,
    bg_buffer: &[u32],
    blur_buf_1: &mut Vec<u32>,
    blur_buf_2: &mut Vec<u32>,
    blur_radius: i32,
    tint_color: u32,
    alpha: f32, // 0.0 = clear, 1.0 = solid tint
) {
    let x0 = (x.max(0) as usize).min(width);
    let y0 = (y.max(0) as usize).min(height);
    let x1 = ((x + w as i32).max(0) as usize).min(width);
    let y1 = ((y + h as i32).max(0) as usize).min(height);

    if x1 <= x0 || y1 <= y0 {
        return;
    }

    // --- Fast Path: Blur Disabled ---
    if blur_radius < 0 {
        for row in y0..y1 {
            canvas[row * width + x0..row * width + x1].fill(tint_color);
        }
        return;
    }

    let box_w = x1 - x0;
    let box_h = y1 - y0;
    let target_len = box_w * box_h;

    blur_buf_1.resize(target_len, 0);
    blur_buf_2.resize(target_len, 0);

    // 1. Copy ROI (Region of Interest) from raw background into scratchpad
    for by in 0..box_h {
        let bg_idx = (y0 + by) * width + x0;
        let blur_idx = by * box_w;
        blur_buf_1[blur_idx..blur_idx + box_w].copy_from_slice(&bg_buffer[bg_idx..bg_idx + box_w]);
    }

    let r = blur_radius.max(1) as usize;

    // 2. Horizontal pass (Box Blur O(N) with sliding window)
    for by in 0..box_h {
        let row_offset = by * box_w;
        let mut sum_r = 0;
        let mut sum_g = 0;
        let mut sum_b = 0;
        let mut count = 0;

        for bw in 0..=r.min(box_w.saturating_sub(1)) {
            let px = blur_buf_1[row_offset + bw];
            sum_r += (px >> 16) & 0xFF;
            sum_g += (px >> 8) & 0xFF;
            sum_b += px & 0xFF;
            count += 1;
        }

        for bx in 0..box_w {
            let c = count.max(1);
            blur_buf_2[row_offset + bx] =
                ((sum_r / c) << 16) | ((sum_g / c) << 8) | (sum_b / c);

            if bx >= r {
                let old_x = bx - r;
                let old_px = blur_buf_1[row_offset + old_x];
                sum_r -= (old_px >> 16) & 0xFF;
                sum_g -= (old_px >> 8) & 0xFF;
                sum_b -= old_px & 0xFF;
                count -= 1;
            }

            if bx + r + 1 < box_w {
                let new_x = bx + r + 1;
                let new_px = blur_buf_1[row_offset + new_x];
                sum_r += (new_px >> 16) & 0xFF;
                sum_g += (new_px >> 8) & 0xFF;
                sum_b += new_px & 0xFF;
                count += 1;
            }
        }
    }

    // 3. Vertical pass and alpha compositing
    let tint_r = ((tint_color >> 16) & 0xFF) as f32;
    let tint_g = ((tint_color >> 8) & 0xFF) as f32;
    let tint_b = (tint_color & 0xFF) as f32;
    let inv_alpha = 1.0 - alpha;

    for bx in 0..box_w {
        let mut sum_r = 0;
        let mut sum_g = 0;
        let mut sum_b = 0;
        let mut count = 0;

        for bh in 0..=r.min(box_h.saturating_sub(1)) {
            let px = blur_buf_2[bh * box_w + bx];
            sum_r += (px >> 16) & 0xFF;
            sum_g += (px >> 8) & 0xFF;
            sum_b += px & 0xFF;
            count += 1;
        }

        for by in 0..box_h {
            let c = count.max(1);
            let avg_r = (sum_r / c) as f32;
            let avg_g = (sum_g / c) as f32;
            let avg_b = (sum_b / c) as f32;

            let final_r = (avg_r * inv_alpha + tint_r * alpha) as u32;
            let final_g = (avg_g * inv_alpha + tint_g * alpha) as u32;
            let final_b = (avg_b * inv_alpha + tint_b * alpha) as u32;

            canvas[(y0 + by) * width + (x0 + bx)] = (final_r << 16) | (final_g << 8) | final_b;

            if by >= r {
                let old_y = by - r;
                let old_px = blur_buf_2[old_y * box_w + bx];
                sum_r -= (old_px >> 16) & 0xFF;
                sum_g -= (old_px >> 8) & 0xFF;
                sum_b -= old_px & 0xFF;
                count -= 1;
            }

            if by + r + 1 < box_h {
                let new_y = by + r + 1;
                let new_px = blur_buf_2[new_y * box_w + bx];
                sum_r += (new_px >> 16) & 0xFF;
                sum_g += (new_px >> 8) & 0xFF;
                sum_b += new_px & 0xFF;
                count += 1;
            }
        }
    }
}

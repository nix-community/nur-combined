/// **Frosted Glass / Glassmorphism Effect**
/// pre-sized scratchpads.
///
/// Three-stage pipeline: downsample (d×d block average) → two-pass O(N)
/// box blur in the reduced space → bilinear upsample with tint. Blur is a
/// low-pass filter, so dropping resolution before it is visually invisible
/// while doing d² times less work. Zero-alloc via pre-sized scratchpads.
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
    let r = blur_radius.max(1) as usize;

    // --- Downsample factor ---
    // d=4 for large boxes (HUD): blur gets 16x cheaper. d=2 for medium ones,
    // d=1 for tiny ones — same pipeline, downsample and upsample degenerate
    // into copies (no separate code paths).
    let d_shift: usize = if r >= 4 && box_w.min(box_h) >= 32 {
        2
    } else if r >= 2 && box_w.min(box_h) >= 16 {
        1
    } else {
        0
    };
    let d = 1usize << d_shift;
    let small_w = box_w.div_ceil(d);
    let small_h = box_h.div_ceil(d);
    let small_len = small_w * small_h;
    // Radius in the reduced space: downsampling is itself a prefilter
    // (~d×d box), the effective radius after upsample ≈ the original r.
    let rs = (r >> d_shift).max(1);

    // blur_buf_1 = the small image + a tail for the vertical pass' running
    // column sums (3×small_w words). blur_buf_2 = the horizontal pass.
    blur_buf_1.resize(small_len + 3 * small_w, 0);
    blur_buf_2.resize(small_len, 0);
    let (small_img, col_sums) = blur_buf_1.split_at_mut(small_len);

    // 1. Downsample: d×d block average straight from bg_buffer — there is no
    // separate ROI copy anymore. Every full-res pixel flows through this loop,
    // so the accumulator is SWAR: R|B share one u32 (R from bit 16, B from
    // bit 0 — block sums ≤ 255·16 take 12 bits, never bleeding into the R
    // lane), G goes separately. Two and+add per pixel instead of six
    // shift/mask/add; unpacking happens once per block. Full blocks divide
    // by shift, edge ones by div.
    for sy in 0..small_h {
        let by_start = sy * d;
        let by_end = ((sy + 1) * d).min(box_h);
        let out_row = sy * small_w;
        for sx in 0..small_w {
            let bx_start = sx * d;
            let bx_end = ((sx + 1) * d).min(box_w);
            let mut acc_rb = 0u32;
            let mut acc_g = 0u32;
            for yy in by_start..by_end {
                let row = (y0 + yy) * width + x0;
                for &px in &bg_buffer[row + bx_start..row + bx_end] {
                    acc_rb += px & 0x00FF00FF;
                    acc_g += px & 0x0000FF00;
                }
            }
            let (sr, sg, sb) = (acc_rb >> 16, acc_g >> 8, acc_rb & 0xFFFF);
            let area = (by_end - by_start) * (bx_end - bx_start);
            let (ar, ag, ab) = if area == d * d {
                (sr >> (d_shift * 2), sg >> (d_shift * 2), sb >> (d_shift * 2))
            } else {
                let a = area as u32;
                (sr / a, sg / a, sb / a)
            };
            small_img[out_row + sx] = (ar << 16) | (ag << 8) | ab;
        }
    }

    // Division replaced by fixed-point reciprocal multiplication:
    // m = ceil(2^32 / c), then (sum * m) >> 32 == sum / c exactly while
    // sum * c < 2^32 (here sum ≤ 255·511, c ≤ 511 — orders of magnitude
    // of headroom). count only changes near window edges, so m is
    // recomputed there alone; the steady-state hot loop is mul+shift.
    let recip = |c: u32| -> u64 { (1u64 << 32).div_ceil(c as u64) };
    let avg = |sum: u32, m: u64| -> u32 { ((sum as u64 * m) >> 32) as u32 };

    // 2. Horizontal pass (Box Blur O(N) with sliding window)
    for sy in 0..small_h {
        let row_offset = sy * small_w;
        let mut sum_r = 0;
        let mut sum_g = 0;
        let mut sum_b = 0;
        let mut count: u32 = 0;

        for sw in 0..=rs.min(small_w - 1) {
            let px = small_img[row_offset + sw];
            sum_r += (px >> 16) & 0xFF;
            sum_g += (px >> 8) & 0xFF;
            sum_b += px & 0xFF;
            count += 1;
        }
        let mut m = recip(count.max(1));

        for sx in 0..small_w {
            blur_buf_2[row_offset + sx] =
                (avg(sum_r, m) << 16) | (avg(sum_g, m) << 8) | avg(sum_b, m);

            let prev_count = count;
            if sx >= rs {
                let old_px = small_img[row_offset + sx - rs];
                sum_r -= (old_px >> 16) & 0xFF;
                sum_g -= (old_px >> 8) & 0xFF;
                sum_b -= old_px & 0xFF;
                count -= 1;
            }

            if sx + rs + 1 < small_w {
                let new_px = small_img[row_offset + sx + rs + 1];
                sum_r += (new_px >> 16) & 0xFF;
                sum_g += (new_px >> 8) & 0xFF;
                sum_b += new_px & 0xFF;
                count += 1;
            }

            // In steady state both branches cancel out — m stays put.
            if count != prev_count {
                m = recip(count.max(1));
            }
        }
    }

    // 3. Vertical pass (row-major, running sums for all columns at once —
    // every blur_buf_2 read and small_img write is sequential).
    // small_img's source role is done — the blur overwrites it in place.
    let (sum_r, rest) = col_sums.split_at_mut(small_w);
    let (sum_g, sum_b) = rest.split_at_mut(small_w);
    sum_r.fill(0);
    sum_g.fill(0);
    sum_b.fill(0);

    let mut count: u32 = 0;
    for sh in 0..=rs.min(small_h - 1) {
        let row = &blur_buf_2[sh * small_w..(sh + 1) * small_w];
        for (sx, &px) in row.iter().enumerate() {
            sum_r[sx] += (px >> 16) & 0xFF;
            sum_g[sx] += (px >> 8) & 0xFF;
            sum_b[sx] += px & 0xFF;
        }
        count += 1;
    }

    for sy in 0..small_h {
        // count changes once per row → reciprocal once per row.
        let m = recip(count.max(1));
        let out_row = sy * small_w;

        for sx in 0..small_w {
            small_img[out_row + sx] =
                (avg(sum_r[sx], m) << 16) | (avg(sum_g[sx], m) << 8) | avg(sum_b[sx], m);
        }

        if sy >= rs {
            let old_row = &blur_buf_2[(sy - rs) * small_w..(sy - rs + 1) * small_w];
            for (sx, &px) in old_row.iter().enumerate() {
                sum_r[sx] -= (px >> 16) & 0xFF;
                sum_g[sx] -= (px >> 8) & 0xFF;
                sum_b[sx] -= px & 0xFF;
            }
            count -= 1;
        }

        if sy + rs + 1 < small_h {
            let new_row = &blur_buf_2[(sy + rs + 1) * small_w..(sy + rs + 2) * small_w];
            for (sx, &px) in new_row.iter().enumerate() {
                sum_r[sx] += (px >> 16) & 0xFF;
                sum_g[sx] += (px >> 8) & 0xFF;
                sum_b[sx] += px & 0xFF;
            }
            count += 1;
        }
    }

    // 4. Bilinear upsample + tint compositing.
    //
    // Packed RB|G: the R and B channels share one u32 via the 0x00FF00FF
    // mask — one lerp serves both with a single multiply (weights ≤ 256, no
    // cross-lane carry: 0xFF·256 < 2^16). Tint is 8.8 fixed-point with terms
    // precomputed once — zero f32 in the loop.
    let lerp = |a: u32, b: u32, f: u32| -> u32 {
        let inv = 256 - f;
        let rb = (((a & 0x00FF00FF) * inv + (b & 0x00FF00FF) * f) >> 8) & 0x00FF00FF;
        let g = (((a & 0x0000FF00) * inv + (b & 0x0000FF00) * f) >> 8) & 0x0000FF00;
        rb | g
    };

    let a256 = ((alpha * 256.0).round() as i32).clamp(0, 256) as u32;
    let inv_a256 = 256 - a256;
    let pre_rb = (tint_color & 0x00FF00FF) * a256;
    let pre_g = (tint_color & 0x0000FF00) * a256;

    // Center mapping: u = (x + 0.5)/d − 0.5 in 8.8 fixed-point; edges clamp.
    // With d=1 it degenerates into identity (frac = 0, lerp is a copy).
    let coord = |i: usize| -> usize { ((((i << 8) + 128) >> d_shift) as i32 - 128).max(0) as usize };

    for by in 0..box_h {
        let t = coord(by);
        let j0 = (t >> 8).min(small_h - 1);
        let j1 = (j0 + 1).min(small_h - 1);
        let fy = (t & 0xFF) as u32;
        let row0 = &small_img[j0 * small_w..(j0 + 1) * small_w];
        let row1 = &small_img[j1 * small_w..(j1 + 1) * small_w];
        let out_row = (y0 + by) * width + x0;

        for bx in 0..box_w {
            let t = coord(bx);
            let i0 = (t >> 8).min(small_w - 1);
            let i1 = (i0 + 1).min(small_w - 1);
            let fx = (t & 0xFF) as u32;

            let top = lerp(row0[i0], row0[i1], fx);
            let bot = lerp(row1[i0], row1[i1], fx);
            let px = lerp(top, bot, fy);

            let rb = (((px & 0x00FF00FF) * inv_a256 + pre_rb) >> 8) & 0x00FF00FF;
            let g = (((px & 0x0000FF00) * inv_a256 + pre_g) >> 8) & 0x0000FF00;
            canvas[out_row + bx] = rb | g;
        }
    }
}

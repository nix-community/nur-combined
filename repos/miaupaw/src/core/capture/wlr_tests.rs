//! WLR pixel-converter tests: per-format channel layout, stride padding,
//! 24-bit formats (issue #7 — mango hands out Bgr888).

use super::*;

fn convert(bytes: &[u8], width: u32, height: u32, stride: u32, format: wl_shm::Format) -> Vec<u32> {
    convert_to_xrgb(bytes.as_ptr(), width, height, stride, format)
}

#[test]
fn test_xrgb8888_tight() {
    // Little-endian memory: [B,G,R,X] → 0x00RRGGBB
    let bytes = [0, 0, 255, 0, 0, 255, 0, 0];
    assert_eq!(
        convert(&bytes, 2, 1, 8, wl_shm::Format::Xrgb8888),
        vec![0xFF0000, 0x00FF00]
    );
}

#[test]
fn test_argb8888_masks_alpha() {
    let bytes = [0, 0, 255, 128, 0, 255, 0, 255];
    assert_eq!(
        convert(&bytes, 2, 1, 8, wl_shm::Format::Argb8888),
        vec![0xFF0000, 0x00FF00]
    );
}

#[test]
fn test_xbgr8888_swaps_channels() {
    // Memory: [R,G,B,X]
    let bytes = [255, 0, 0, 0, 0, 255, 0, 0];
    assert_eq!(
        convert(&bytes, 2, 1, 8, wl_shm::Format::Xbgr8888),
        vec![0xFF0000, 0x00FF00]
    );
}

#[test]
fn test_xrgb8888_with_stride_padding() {
    // width=1, stride=8: 4 bytes of padding at the end of each row
    let bytes = [0, 0, 255, 0, 9, 9, 9, 9, 0, 255, 0, 0, 9, 9, 9, 9];
    assert_eq!(
        convert(&bytes, 1, 2, 8, wl_shm::Format::Xrgb8888),
        vec![0xFF0000, 0x00FF00]
    );
}

#[test]
fn test_rgb888_24bit() {
    // DRM RGB888 little-endian → memory [B,G,R]
    let bytes = [0, 0, 255, 0, 255, 0];
    assert_eq!(
        convert(&bytes, 2, 1, 6, wl_shm::Format::Rgb888),
        vec![0xFF0000, 0x00FF00]
    );
}

#[test]
fn test_bgr888_24bit_with_padding() {
    // DRM BGR888 little-endian → memory [R,G,B]; width=2, stride=8 (2 bytes padding)
    let bytes = [
        255, 0, 0, 0, 255, 0, 9, 9,
        0, 0, 255, 255, 255, 255, 9, 9,
    ];
    assert_eq!(
        convert(&bytes, 2, 2, 8, wl_shm::Format::Bgr888),
        vec![0xFF0000, 0x00FF00, 0x0000FF, 0xFFFFFF]
    );
}

#[test]
fn test_format_bpp() {
    assert_eq!(format_bpp(wl_shm::Format::Rgb888), 3);
    assert_eq!(format_bpp(wl_shm::Format::Bgr888), 3);
    assert_eq!(format_bpp(wl_shm::Format::Xrgb8888), 4);
    // Unknown exotics are conservatively treated as 4-byte
    assert_eq!(format_bpp(wl_shm::Format::Argb2101010), 4);
}

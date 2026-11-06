//! KWin raw-buffer tests: QImage format mapping, channel order, stride padding
//! (issue #16 — Plasma 6.8 hands out RGBX8888).

use super::*;

#[test]
fn test_format_mapping() {
    assert_eq!(RawLayout::from_qimage_format(None), Some(RawLayout::Bgrx));
    assert_eq!(RawLayout::from_qimage_format(Some(4)), Some(RawLayout::Bgrx));
    assert_eq!(RawLayout::from_qimage_format(Some(6)), Some(RawLayout::Bgrx));
    assert_eq!(RawLayout::from_qimage_format(Some(16)), Some(RawLayout::Rgbx));
    assert_eq!(RawLayout::from_qimage_format(Some(18)), Some(RawLayout::Rgbx));
    // Format_A2BGR30_Premultiplied = 20, Format_RGBA64 = 26: not handled
    assert_eq!(RawLayout::from_qimage_format(Some(20)), None);
    assert_eq!(RawLayout::from_qimage_format(Some(26)), None);
}

#[test]
fn test_argb32_tight_masks_alpha() {
    // Little-endian memory: [B,G,R,A] → 0x00RRGGBB
    let bytes = vec![0, 0, 255, 255, 0, 255, 0, 255];
    assert_eq!(raw_to_xrgb(bytes, 2, 1, 8, RawLayout::Bgrx), vec![0xFF0000, 0x00FF00]);
}

#[test]
fn test_rgbx8888_red_stays_red() {
    // Memory: [R,G,B,X] — pure red must not come out blue
    let bytes = vec![255, 0, 0, 255, 0, 0, 255, 255];
    assert_eq!(raw_to_xrgb(bytes, 2, 1, 8, RawLayout::Rgbx), vec![0xFF0000, 0x0000FF]);
}

#[test]
fn test_stride_padding() {
    // 1x2 image, stride 8: 4 bytes of padding after each row
    let bytes = vec![
        255, 0, 0, 255, 9, 9, 9, 9,
        0, 255, 0, 255, 9, 9, 9, 9,
    ];
    assert_eq!(raw_to_xrgb(bytes.clone(), 1, 2, 8, RawLayout::Rgbx), vec![0xFF0000, 0x00FF00]);
    assert_eq!(raw_to_xrgb(bytes, 1, 2, 8, RawLayout::Bgrx), vec![0x0000FF, 0x00FF00]);
}

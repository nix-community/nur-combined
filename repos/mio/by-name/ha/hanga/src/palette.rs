//! Generic stacked voxel palette (`W x W*n`) for `bevy_voxel_world`.
//! Layer `i` is material index `i` (0 unused; 1+ follow the mod catalog).

use std::path::{Path, PathBuf};
use std::sync::OnceLock;

pub const VOXEL_PALETTE_TILE: u32 = 16;
pub const VOXEL_PALETTE_LAYERS: u32 = 16;
pub const VOXEL_PALETTE_FILE: &str = "voxel_palette.png";

/// Catalog-index colors. Urban Chaos order is
/// air, concrete, asphalt, glass, sidewalk, grass, tile, rail, workbench, brick.
const LAYER_RGB: [[u8; 3]; VOXEL_PALETTE_LAYERS as usize] = [
    [24, 24, 28],
    [198, 192, 180],
    [48, 48, 52],
    [140, 198, 214],
    [172, 166, 156],
    [62, 122, 52],
    [198, 168, 112],
    [88, 92, 98],
    [120, 86, 62],
    [160, 72, 64],
    [72, 96, 120],
    [90, 110, 70],
    [200, 180, 80],
    [96, 64, 120],
    [48, 72, 88],
    [180, 180, 184],
];

/// Writes the palette once and returns the AssetPlugin directory.
pub fn ensure_asset_dir() -> PathBuf {
    static DIR: OnceLock<PathBuf> = OnceLock::new();
    DIR.get_or_init(|| {
        let dir = std::env::temp_dir().join(format!("hanga-assets-{}", std::process::id()));
        let _ = std::fs::create_dir_all(&dir);
        let path = dir.join(VOXEL_PALETTE_FILE);
        let _ = std::fs::write(&path, voxel_palette_png());
        dir
    })
    .clone()
}

pub fn voxel_palette_path() -> PathBuf {
    ensure_asset_dir().join(VOXEL_PALETTE_FILE)
}

pub fn voxel_palette_png() -> Vec<u8> {
    let w = VOXEL_PALETTE_TILE;
    let h = VOXEL_PALETTE_TILE * VOXEL_PALETTE_LAYERS;
    let mut raw = Vec::with_capacity(((1 + w * 3) * h) as usize);
    for layer in 0..VOXEL_PALETTE_LAYERS {
        let [r, g, b] = LAYER_RGB[layer as usize];
        for y in 0..VOXEL_PALETTE_TILE {
            raw.push(0);
            for x in 0..VOXEL_PALETTE_TILE {
                let n = (x.wrapping_mul(17) ^ y.wrapping_mul(31) ^ layer.wrapping_mul(13)) & 15;
                let d = n as i16 - 7;
                raw.push((i16::from(r) + d).clamp(0, 255) as u8);
                raw.push((i16::from(g) + d).clamp(0, 255) as u8);
                raw.push((i16::from(b) + d).clamp(0, 255) as u8);
            }
        }
    }
    encode_png(w, h, &raw)
}

fn encode_png(width: u32, height: u32, raw: &[u8]) -> Vec<u8> {
    let mut out = Vec::new();
    out.extend_from_slice(&[137, 80, 78, 71, 13, 10, 26, 10]);
    let mut ihdr = Vec::new();
    ihdr.extend_from_slice(&width.to_be_bytes());
    ihdr.extend_from_slice(&height.to_be_bytes());
    ihdr.extend_from_slice(&[8, 2, 0, 0, 0]);
    write_chunk(&mut out, b"IHDR", &ihdr);
    write_chunk(&mut out, b"IDAT", &zlib_store(raw));
    write_chunk(&mut out, b"IEND", &[]);
    out
}

fn write_chunk(out: &mut Vec<u8>, tag: &[u8; 4], data: &[u8]) {
    out.extend_from_slice(&(data.len() as u32).to_be_bytes());
    let mut body = Vec::with_capacity(4 + data.len());
    body.extend_from_slice(tag);
    body.extend_from_slice(data);
    out.extend_from_slice(&body);
    out.extend_from_slice(&crc32(&body).to_be_bytes());
}

fn zlib_store(data: &[u8]) -> Vec<u8> {
    let mut out = vec![0x78, 0x01];
    let mut i = 0;
    while i < data.len() {
        let end = (i + 65535).min(data.len());
        let last = end == data.len();
        let len = (end - i) as u16;
        out.push(if last { 0x01 } else { 0x00 });
        out.extend_from_slice(&len.to_le_bytes());
        out.extend_from_slice(&(!len).to_le_bytes());
        out.extend_from_slice(&data[i..end]);
        i = end;
    }
    out.extend_from_slice(&adler32(data).to_be_bytes());
    out
}

fn adler32(data: &[u8]) -> u32 {
    let mut a = 1u32;
    let mut b = 0u32;
    for &byte in data {
        a = (a + u32::from(byte)) % 65521;
        b = (b + a) % 65521;
    }
    (b << 16) | a
}

fn crc32(data: &[u8]) -> u32 {
    let mut c = 0xffff_ffffu32;
    for &byte in data {
        c ^= u32::from(byte);
        for _ in 0..8 {
            c = if c & 1 != 0 {
                (c >> 1) ^ 0xedb8_8320
            } else {
                c >> 1
            };
        }
    }
    !c
}

pub fn is_palette_png(bytes: &[u8]) -> bool {
    bytes.starts_with(&[137, 80, 78, 71, 13, 10, 26, 10])
}

pub fn palette_exists_on_disk(dir: &Path) -> bool {
    dir.join(VOXEL_PALETTE_FILE).is_file()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn palette_png_is_valid_header_and_size() {
        let png = voxel_palette_png();
        assert!(is_palette_png(&png));
        assert!(png.len() > 200);
        assert_eq!(&png[16..20], &VOXEL_PALETTE_TILE.to_be_bytes());
        assert_eq!(
            &png[20..24],
            &(VOXEL_PALETTE_TILE * VOXEL_PALETTE_LAYERS).to_be_bytes()
        );
    }

    #[test]
    fn ensure_asset_dir_writes_file() {
        let dir = ensure_asset_dir();
        assert!(palette_exists_on_disk(&dir));
        let bytes = std::fs::read(voxel_palette_path()).unwrap();
        assert!(is_palette_png(&bytes));
    }
}

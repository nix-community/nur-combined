//! Generic stacked voxel palette and sky textures the host can write for Bevy.
//! Colors and optional PNG files come from the selected game; this crate only encodes.

use std::path::{Path, PathBuf};
use std::sync::OnceLock;

use crate::game::GameSpec;

pub const VOXEL_PALETTE_TILE: u32 = 16;
pub const VOXEL_PALETTE_LAYERS: u32 = 16;
pub const VOXEL_PALETTE_FILE: &str = "voxel_palette.png";
pub const CLOUD_FILE: &str = "cloud.png";
pub const CLOUD_TILE: u32 = 256;

/// Neutral fallback when a game does not list `palette.N`.
pub const DEFAULT_LAYER_RGB: [[u8; 3]; VOXEL_PALETTE_LAYERS as usize] = [
    [24, 24, 28],
    [160, 160, 164],
    [120, 120, 124],
    [180, 180, 184],
    [140, 140, 144],
    [100, 120, 100],
    [168, 160, 140],
    [88, 88, 92],
    [120, 100, 80],
    [140, 80, 72],
    [72, 88, 104],
    [90, 110, 70],
    [180, 168, 80],
    [96, 64, 120],
    [48, 72, 88],
    [180, 180, 184],
];

pub fn asset_dir() -> PathBuf {
    static DIR: OnceLock<PathBuf> = OnceLock::new();
    DIR.get_or_init(|| {
        let dir = std::env::temp_dir().join(format!("hanga-assets-{}", std::process::id()));
        let _ = std::fs::create_dir_all(&dir);
        dir
    })
    .clone()
}

/// Writes the palette once and returns the AssetPlugin directory.
pub fn ensure_asset_dir() -> PathBuf {
    let dir = asset_dir();
    let path = dir.join(VOXEL_PALETTE_FILE);
    if !path.is_file() {
        let _ = std::fs::write(&path, voxel_palette_png());
    }
    dir
}

/// Install voxel palette + optional cloud texture for this game into the asset dir.
pub fn prepare_asset_dir(game: &GameSpec, search: &[PathBuf]) -> PathBuf {
    let dir = asset_dir();
    let palette_bytes = resolve_or_generate_palette(game, search);
    let _ = std::fs::write(dir.join(VOXEL_PALETTE_FILE), palette_bytes);
    let cloud_path = dir.join(CLOUD_FILE);
    if let Some(bytes) = resolve_or_generate_cloud(game, search) {
        let _ = std::fs::write(&cloud_path, bytes);
    } else {
        let _ = std::fs::remove_file(&cloud_path);
    }
    dir
}

fn resolve_or_generate_palette(game: &GameSpec, search: &[PathBuf]) -> Vec<u8> {
    if let Some(name) = game.atmosphere.voxel_palette.as_deref() {
        if let Some(path) = crate::game::resolve_game_texture(game, name, search) {
            if let Ok(bytes) = std::fs::read(&path) {
                if is_palette_png(&bytes) {
                    return bytes;
                }
            }
        }
    }
    voxel_palette_png_from(game.palette_layers())
}

fn resolve_or_generate_cloud(game: &GameSpec, search: &[PathBuf]) -> Option<Vec<u8>> {
    let spec = game.atmosphere.cloud.as_deref()?;
    if spec != "generated" {
        if let Some(path) = crate::game::resolve_game_texture(game, spec, search) {
            if let Ok(bytes) = std::fs::read(&path) {
                if is_palette_png(&bytes) {
                    return Some(bytes);
                }
            }
        }
    }
    Some(cloud_png(game.atmosphere.cloud_color, game.id.as_bytes()))
}

pub fn voxel_palette_path() -> PathBuf {
    asset_dir().join(VOXEL_PALETTE_FILE)
}

pub fn voxel_palette_png() -> Vec<u8> {
    voxel_palette_png_from(DEFAULT_LAYER_RGB)
}

pub fn voxel_palette_png_from(layers: [[u8; 3]; VOXEL_PALETTE_LAYERS as usize]) -> Vec<u8> {
    let w = VOXEL_PALETTE_TILE;
    let h = VOXEL_PALETTE_TILE * VOXEL_PALETTE_LAYERS;
    let mut raw = Vec::with_capacity(((1 + w * 3) * h) as usize);
    for layer in 0..VOXEL_PALETTE_LAYERS {
        let [r, g, b] = layers[layer as usize];
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
    encode_png(w, h, 3, &raw)
}

/// Soft RGBA clouds. The game picks the tint; the host only noise-paints.
pub fn cloud_png(color: [f32; 3], seed: &[u8]) -> Vec<u8> {
    let w = CLOUD_TILE;
    let mut raw = Vec::with_capacity(((1 + w * 4) * w) as usize);
    let salt = seed.iter().fold(0x9E37_79B9u32, |h, b| {
        h.wrapping_mul(16777619) ^ u32::from(*b)
    });
    let cr = (color[0] * 255.0).clamp(0.0, 255.0) as u8;
    let cg = (color[1] * 255.0).clamp(0.0, 255.0) as u8;
    let cb = (color[2] * 255.0).clamp(0.0, 255.0) as u8;
    for y in 0..w {
        raw.push(0);
        for x in 0..w {
            let n = fbm(x as f32 / 32.0, y as f32 / 32.0, salt);
            let edge = 1.0
                - ((x as f32 / w as f32 - 0.5).abs() * 1.6)
                    .max((y as f32 / w as f32 - 0.5).abs() * 1.6)
                    .min(1.0);
            let alpha = ((n - 0.42).max(0.0) * 2.4 * edge).clamp(0.0, 0.88);
            raw.push(cr);
            raw.push(cg);
            raw.push(cb);
            raw.push((alpha * 255.0) as u8);
        }
    }
    encode_png(w, w, 4, &raw)
}

fn fbm(x: f32, y: f32, seed: u32) -> f32 {
    let mut amp = 0.5;
    let mut freq = 1.0;
    let mut sum = 0.0;
    let mut norm = 0.0;
    for octave in 0..5u32 {
        sum += amp * value_noise(x * freq, y * freq, seed ^ (octave * 0x9E37));
        norm += amp;
        amp *= 0.5;
        freq *= 2.05;
    }
    sum / norm
}

fn value_noise(x: f32, y: f32, seed: u32) -> f32 {
    let x0 = x.floor() as i32;
    let y0 = y.floor() as i32;
    let fx = x - x0 as f32;
    let fy = y - y0 as f32;
    let sx = fx * fx * (3.0 - 2.0 * fx);
    let sy = fy * fy * (3.0 - 2.0 * fy);
    let a = hash2(x0, y0, seed);
    let b = hash2(x0 + 1, y0, seed);
    let c = hash2(x0, y0 + 1, seed);
    let d = hash2(x0 + 1, y0 + 1, seed);
    let u = a + (b - a) * sx;
    let v = c + (d - c) * sx;
    u + (v - u) * sy
}

fn hash2(x: i32, y: i32, seed: u32) -> f32 {
    let mut n = (x as u32)
        .wrapping_mul(374761393)
        ^ (y as u32).wrapping_mul(668265263)
        ^ seed;
    n = (n ^ (n >> 13)).wrapping_mul(1274126177);
    (n & 0xffff) as f32 / 65535.0
}

fn encode_png(width: u32, height: u32, channels: u8, raw: &[u8]) -> Vec<u8> {
    let mut out = Vec::new();
    out.extend_from_slice(&[137, 80, 78, 71, 13, 10, 26, 10]);
    let mut ihdr = Vec::new();
    ihdr.extend_from_slice(&width.to_be_bytes());
    ihdr.extend_from_slice(&height.to_be_bytes());
    let color_type = if channels == 4 { 6 } else { 2 };
    ihdr.extend_from_slice(&[8, color_type, 0, 0, 0]);
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

    #[test]
    fn cloud_png_is_rgba() {
        let png = cloud_png([0.95, 0.96, 0.98], b"urban_chaos");
        assert!(is_palette_png(&png));
        assert_eq!(&png[16..20], &CLOUD_TILE.to_be_bytes());
        assert_eq!(&png[20..24], &CLOUD_TILE.to_be_bytes());
        assert_eq!(png[25], 6, "color type RGBA");
        assert_ne!(
            cloud_png([0.95, 0.96, 0.98], b"urban_chaos"),
            cloud_png([0.95, 0.96, 0.98], b"testbed")
        );
    }

    #[test]
    fn prepare_writes_cloud_only_when_the_game_asks() {
        let urban = crate::game::shipped_games()
            .into_iter()
            .find(|g| g.id == "urban_chaos")
            .unwrap();
        let dir = prepare_asset_dir(&urban, &[]);
        assert!(dir.join(CLOUD_FILE).is_file());
        let bed = crate::game::implicit_game("lone");
        prepare_asset_dir(&bed, &[]);
        assert!(!dir.join(CLOUD_FILE).is_file());
    }
}

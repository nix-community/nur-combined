//! Spatial sound helpers. Mods advertise filenames via `sound-kit`; the host
//! stages `.wav`/`.ogg` into the Bevy asset dir (mod files win, else a beep).

use std::path::{Path, PathBuf};

use crate::kit::Node;

#[derive(Clone, Debug, Default, PartialEq, Eq)]
pub struct SoundKit {
    pub file: String,
}

/// Basename only; rejects path separators and non-audio suffixes.
pub fn parse_sound_kit_node(node: &Node) -> Option<SoundKit> {
    if node.is_empty() {
        return None;
    }
    let file = match node {
        Node::Text(text) => text.clone(),
        _ => node.get("file").map(Node::text).unwrap_or_default(),
    };
    sanitize_sound_file(&file).map(|file| SoundKit { file })
}

pub fn sanitize_sound_file(file: &str) -> Option<String> {
    let file = file.trim();
    if file.is_empty()
        || file.contains('/')
        || file.contains('\\')
        || file.contains("..")
        || file.contains('\0')
    {
        return None;
    }
    let lower = file.to_ascii_lowercase();
    if !(lower.ends_with(".wav") || lower.ends_with(".ogg")) {
        return None;
    }
    Some(file.to_string())
}

/// Default filename when the mod returns empty / unknown.
pub fn default_sound_file(action: &str) -> Option<&'static str> {
    match action {
        "break" => Some("break.wav"),
        "place" => Some("place.wav"),
        "explode" => Some("explode.wav"),
        "crash" => Some("crash.wav"),
        "fracture" => Some("fracture.wav"),
        _ => None,
    }
}

/// Tiny mono PCM WAV (sine beep) used when no mod asset is on disk.
pub fn procedural_wav(freq_hz: f32, duration_ms: u32, amplitude: f32) -> Vec<u8> {
    let sample_rate = 22_050u32;
    let n = (sample_rate as u64 * u64::from(duration_ms) / 1000) as usize;
    let amp = amplitude.clamp(0.0, 1.0);
    let mut pcm = Vec::with_capacity(n * 2);
    for i in 0..n {
        let t = i as f32 / sample_rate as f32;
        let env = if i < 64 {
            i as f32 / 64.0
        } else if i + 128 >= n {
            ((n - i) as f32 / 128.0).clamp(0.0, 1.0)
        } else {
            1.0
        };
        let sample = (t * freq_hz * std::f32::consts::TAU).sin() * amp * env;
        let q = (sample * i16::MAX as f32) as i16;
        pcm.extend_from_slice(&q.to_le_bytes());
    }
    wav_wrap(sample_rate, 1, 16, &pcm)
}

pub fn default_sound_bytes(file: &str) -> Option<Vec<u8>> {
    match file {
        "break.wav" => Some(procedural_wav(520.0, 70, 0.28)),
        "place.wav" => Some(procedural_wav(720.0, 50, 0.22)),
        "explode.wav" => Some(procedural_wav(70.0, 220, 0.45)),
        "crash.wav" => Some(procedural_wav(110.0, 160, 0.38)),
        "fracture.wav" => Some(procedural_wav(240.0, 140, 0.32)),
        _ => None,
    }
}

fn wav_wrap(sample_rate: u32, channels: u16, bits: u16, pcm: &[u8]) -> Vec<u8> {
    let byte_rate = sample_rate * u32::from(channels) * u32::from(bits) / 8;
    let block_align = channels * bits / 8;
    let data_len = pcm.len() as u32;
    let mut out = Vec::with_capacity(44 + pcm.len());
    out.extend_from_slice(b"RIFF");
    out.extend_from_slice(&(36 + data_len).to_le_bytes());
    out.extend_from_slice(b"WAVE");
    out.extend_from_slice(b"fmt ");
    out.extend_from_slice(&16u32.to_le_bytes());
    out.extend_from_slice(&1u16.to_le_bytes());
    out.extend_from_slice(&channels.to_le_bytes());
    out.extend_from_slice(&sample_rate.to_le_bytes());
    out.extend_from_slice(&byte_rate.to_le_bytes());
    out.extend_from_slice(&block_align.to_le_bytes());
    out.extend_from_slice(&bits.to_le_bytes());
    out.extend_from_slice(b"data");
    out.extend_from_slice(&data_len.to_le_bytes());
    out.extend_from_slice(pcm);
    out
}

/// Look under `HANGA_MODS/<pack>/assets/sounds/<file>` and flat `assets/sounds/`.
pub fn resolve_mod_sound(search: &[PathBuf], file: &str) -> Option<Vec<u8>> {
    let Some(file) = sanitize_sound_file(file) else {
        return None;
    };
    for root in search {
        let direct = [
            root.join("assets/sounds").join(&file),
            root.join("sounds").join(&file),
        ];
        for path in direct {
            if let Ok(bytes) = std::fs::read(&path) {
                if !bytes.is_empty() {
                    return Some(bytes);
                }
            }
        }
        if !root.is_dir() {
            continue;
        }
        let Ok(entries) = std::fs::read_dir(root) else {
            continue;
        };
        for entry in entries.flatten() {
            let path = entry.path().join("assets/sounds").join(&file);
            if let Ok(bytes) = std::fs::read(&path) {
                if !bytes.is_empty() {
                    return Some(bytes);
                }
            }
        }
    }
    None
}

/// Ensure `sounds/<file>` exists in the Bevy asset root. Returns the asset-relative path.
pub fn ensure_sound_asset(asset_dir: &Path, search: &[PathBuf], file: &str) -> Option<String> {
    let file = sanitize_sound_file(file)?;
    let sounds_dir = asset_dir.join("sounds");
    let dest = sounds_dir.join(&file);
    if !dest.is_file() {
        let bytes = resolve_mod_sound(search, &file).or_else(|| default_sound_bytes(&file))?;
        let _ = std::fs::create_dir_all(&sounds_dir);
        let _ = std::fs::write(&dest, bytes);
    }
    if dest.is_file() {
        Some(format!("sounds/{file}"))
    } else {
        None
    }
}

pub fn sound_search_dirs(env_mods: Option<&Path>, cwd: &Path) -> Vec<PathBuf> {
    let mut dirs = Vec::new();
    if let Some(env) = env_mods {
        dirs.push(env.to_path_buf());
    }
    dirs.push(cwd.join("mods"));
    dirs.push(cwd.join("share/hanga/mods"));
    dirs
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::kit::Node;

    #[test]
    fn rejects_path_traversal() {
        assert!(sanitize_sound_file("../x.wav").is_none());
        assert!(sanitize_sound_file("a/b.wav").is_none());
        assert!(sanitize_sound_file("ok.wav").is_some());
        assert!(sanitize_sound_file("ok.ogg").is_some());
        assert!(sanitize_sound_file("ok.mp3").is_none());
    }

    #[test]
    fn parses_dict_and_text_kits() {
        let dict = Node::Dict(vec![("file".into(), Node::Text("break.wav".into()))]);
        assert_eq!(
            parse_sound_kit_node(&dict).unwrap().file,
            "break.wav"
        );
        assert_eq!(
            parse_sound_kit_node(&Node::Text("crash.wav".into()))
                .unwrap()
                .file,
            "crash.wav"
        );
        assert!(parse_sound_kit_node(&Node::Empty).is_none());
    }

    #[test]
    fn wav_header_is_valid() {
        let wav = procedural_wav(440.0, 50, 0.2);
        assert!(wav.starts_with(b"RIFF"));
        assert_eq!(&wav[8..12], b"WAVE");
        assert!(wav.len() > 44);
    }

    #[test]
    fn stages_procedural_default() {
        let dir = std::env::temp_dir().join(format!(
            "hanga-sound-test-{}",
            std::process::id()
        ));
        let _ = std::fs::remove_dir_all(&dir);
        let _ = std::fs::create_dir_all(&dir);
        let rel = ensure_sound_asset(&dir, &[], "break.wav").unwrap();
        assert_eq!(rel, "sounds/break.wav");
        assert!(dir.join("sounds/break.wav").is_file());
        let _ = std::fs::remove_dir_all(&dir);
    }
}

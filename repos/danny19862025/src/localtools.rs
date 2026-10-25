use crate::boosters::{self, Entry, Operation as Op, entry, hint};
use gtk::gdk_pixbuf::Pixbuf;
use serde_json::Value;
use std::{
    collections::HashMap,
    fs,
    io::Write,
    path::{Path, PathBuf},
    process::Command,
};

#[derive(Clone, Debug, PartialEq, Eq, Hash)]
pub enum Query {
    Music(String, String),
    Browser(String, String),
    File(Tool, String),
    Screenshot,
}
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum Tool {
    Compress,
    Resize,
    Pdf,
    Webp,
    Palette,
}
impl Tool {
    pub fn title(self) -> &'static str {
        match self {
            Self::Compress => "Compress image · quality 50%",
            Self::Resize => "Resize image to fit 1080p",
            Self::Pdf => "Extract PDF text",
            Self::Webp => "Convert image to WebP",
            Self::Palette => "Extract five image colors",
        }
    }
}
#[derive(Clone, Debug)]
pub enum Operation {
    Music { player: String, command: String },
    Open(String),
    File(Tool, PathBuf),
    Pick(Tool),
    Screenshot,
}
pub enum Outcome {
    Text(String),
    File(PathBuf),
    Palette(Vec<String>),
    Message(String),
}
fn action(
    title: impl Into<String>,
    detail: impl Into<String>,
    badge: &'static str,
    op: Operation,
) -> Entry {
    entry(title, detail, badge, Op::Local(op))
}
fn media_command(text: &str) -> Option<&'static str> {
    match text.to_ascii_lowercase().as_str() {
        "playpause" | "play-pause" | "play/pause" => Some("play-pause"),
        "play" => Some("play"),
        "pause" => Some("pause"),
        "next" => Some("next"),
        "previous" => Some("previous"),
        "stop" => Some("stop"),
        _ => None,
    }
}
impl Query {
    pub fn parse(text: &str) -> Option<Self> {
        let text = text.trim();
        let lower = text.to_ascii_lowercase();
        if matches!(
            lower.as_str(),
            "screenshot" | "take screenshot" | "capture screen"
        ) {
            return Some(Self::Screenshot);
        }
        let (head, tail) = text.split_once(char::is_whitespace).unwrap_or((text, ""));
        let tail = tail.trim();
        match head.to_ascii_lowercase().as_str() {
            "music" | "player" => {
                let (action, filter) = tail.split_once(char::is_whitespace).unwrap_or((tail, ""));
                if let Some(action) = media_command(action) {
                    Some(Self::Music(action.into(), filter.trim().into()))
                } else {
                    Some(Self::Music("controls".into(), tail.into()))
                }
            }
            "playpause" | "play-pause" | "play/pause" => {
                Some(Self::Music("play-pause".into(), tail.into()))
            }
            "pause" | "next" | "previous" | "play" | "stop"
                if tail.is_empty()
                    || head.eq_ignore_ascii_case("play")
                    || tail.eq_ignore_ascii_case("track") =>
            {
                Some(Self::Music(head.to_ascii_lowercase(), tail.into()))
            }
            "history" => Some(Self::Browser("history".into(), tail.into())),
            "bookmark" | "bookmarks" => Some(Self::Browser("bookmark".into(), tail.into())),
            "palette" => Some(Self::File(Tool::Palette, tail.into())),
            _ => {
                for (prefix, tool) in [
                    ("compress image 50%", Tool::Compress),
                    ("compress image", Tool::Compress),
                    ("resize 1080p", Tool::Resize),
                    ("pdf text", Tool::Pdf),
                    ("image to webp", Tool::Webp),
                    ("color palette", Tool::Palette),
                ] {
                    if lower == prefix || lower.starts_with(&format!("{prefix} ")) {
                        let path = text[prefix.len()..].trim();
                        if prefix == "compress image"
                            && path
                                .split_whitespace()
                                .next()
                                .is_some_and(|p| p.ends_with('%'))
                        {
                            return None;
                        }
                        return Some(Self::File(tool, path.into()));
                    }
                }
                None
            }
        }
    }
}
pub fn fetch(query: &Query) -> Result<Vec<Entry>, String> {
    match query {
        Query::Screenshot => Ok(vec![action(
            "Take Screenshot",
            "Capture once via portal · Tab for OCR, QR, Compress, Pin or Save",
            "Screen",
            Operation::Screenshot,
        )]),
        Query::Browser(mode, filter) => browser(mode, filter, ""),
        Query::File(tool, path) => Ok(vec![action(
            tool.title(),
            if path.is_empty() {
                "Choose a local file".into()
            } else {
                format!("{} · original kept", path)
            },
            "File",
            if path.is_empty() {
                Operation::Pick(*tool)
            } else {
                Operation::File(*tool, expand(path))
            },
        )]),
        Query::Music(command, search) => music(command, search),
    }
}
fn expand(text: &str) -> PathBuf {
    let text = text.trim_matches('"').trim_matches('\'');
    text.strip_prefix("~/")
        .map(|p| crate::core::home().join(p))
        .unwrap_or_else(|| PathBuf::from(text))
}
pub fn browser(mode: &str, filter: &str, only: &str) -> Result<Vec<Entry>, String> {
    let work = Work::new()?;
    let body = boosters::run(
        Command::new("python3").args([
            "-c",
            include_str!("browser_data.py"),
            mode,
            filter,
            "",
            "",
            only,
            &work.0.to_string_lossy(),
        ]),
        8,
    )?;
    let result: Value = serde_json::from_str(&body).map_err(|e| e.to_string())?;
    let mut rows = Vec::new();
    for row in result["rows"].as_array().into_iter().flatten() {
        let (Some(title), Some(url), Some(browser)) = (
            row["title"].as_str(),
            row["url"].as_str(),
            row["browser"].as_str(),
        ) else {
            continue;
        };
        rows.push(action(
            title,
            format!("{browser} · {url}"),
            if mode == "bookmark" {
                "Bookmark"
            } else {
                "History"
            },
            Operation::Open(url.into()),
        ));
    }
    if rows.is_empty() {
        rows.push(hint("No matching browser pages", "Search history youtube or bookmark github · reads local Firefox, Chrome, Chromium and Brave profiles"));
    }
    if result["errors"].as_array().is_some_and(|e| !e.is_empty()) {
        rows.push(hint(
            "Some browser profiles could not be read",
            "A profile is busy or unavailable · try again after closing the browser",
        ));
    }
    Ok(rows)
}
fn music(command: &str, search: &str) -> Result<Vec<Entry>, String> {
    let uri = if command == "play" && !search.is_empty() && search != "track" {
        format!(
            "https://www.youtube.com/results?search_query={}",
            crate::core::encode(search)
        )
    } else {
        String::new()
    };
    let mut rows = Vec::new();
    if !uri.is_empty() {
        // MPRIS open-uri cannot search catalogs. Open an explicitly labelled search instead.
        rows.push(action(
            format!("Find {search} on YouTube"),
            "Opens music search in your browser · choose a track to play",
            "Music",
            Operation::Open(uri.clone()),
        ));
    }
    for player in crate::mpris::players()? {
        if command != "play"
            && !search.is_empty()
            && search != "track"
            && !format!("{} {} {}", player.service, player.identity, player.track)
                .to_lowercase()
                .contains(&search.to_lowercase())
        {
            continue;
        }
        let commands: Vec<&str> = if command == "controls" {
            vec!["play-pause", "play", "pause", "next", "previous", "stop"]
        } else if command == "play" && !search.is_empty() && search != "track" {
            vec![]
        } else {
            vec![command]
        };
        let mut controls = 0;
        for cmd in commands {
            if !player.supports(cmd) {
                continue;
            }
            controls += 1;
            rows.push(action(
                format!(
                    "{} · {}",
                    match cmd {
                        "play-pause" => "Play / Pause",
                        "play" => "Play",
                        "pause" => "Pause",
                        "next" => "Next track",
                        "previous" => "Previous track",
                        _ => "Stop",
                    },
                    player.identity
                ),
                format!("{} · {}", player.status, player.track),
                "Music",
                Operation::Music {
                    player: player.service.clone(),
                    command: cmd.into(),
                },
            ));
        }
        if controls == 0 && uri.is_empty() {
            rows.push(hint(
                format!("{} · {}", player.identity, player.status),
                format!("{} · requested control unavailable", player.track),
            ));
        }
    }
    if rows.is_empty() {
        rows.push(hint(
            "No MPRIS music player found",
            "Open a music player or a browser tab with media, then try again",
        ));
    }
    Ok(rows)
}
pub fn available(program: &str) -> bool {
    std::env::var_os("PATH")
        .is_some_and(|paths| std::env::split_paths(&paths).any(|p| p.join(program).is_file()))
}

pub fn execute(operation: Operation) -> Result<Outcome, String> {
    match operation {
        Operation::Music { player, command } => {
            crate::mpris::control(&player, &command)?;
            Ok(Outcome::Message(format!("{command} · {player}")))
        }
        Operation::File(tool, path) => transform(tool, &path),
        _ => Err("This action needs the Spotlight window".into()),
    }
}
fn image_size(path: &Path) -> Result<(i32, i32), String> {
    let (_, w, h) = Pixbuf::file_info(path).ok_or("Unsupported image")?;
    if w <= 0 || h <= 0 || i64::from(w) * i64::from(h) > 80_000_000 {
        return Err("Image exceeds 80 million pixels".into());
    }
    Ok((w, h))
}
fn transform(tool: Tool, path: &Path) -> Result<Outcome, String> {
    let path = path
        .canonicalize()
        .map_err(|e| format!("Could not open file: {e}"))?;
    if !path.is_file() {
        return Err("Choose a file".into());
    }
    if tool == Tool::Palette {
        return palette(&path).map(Outcome::Palette);
    }
    if tool == Tool::Pdf {
        return boosters::run(
            Command::new("pdftotext")
                .args(["-layout"])
                .arg(&path)
                .arg("-"),
            30,
        )
        .and_then(|s| {
            if s.trim().is_empty() {
                Err("No PDF text found · scanned PDFs need OCR".into())
            } else {
                Ok(Outcome::Text(s))
            }
        });
    }
    image_size(&path)?;
    // Work in a private directory. Publish with create_new so existing files cannot be overwritten.
    let work = Work::new()?;
    let (suffix, ext) = match tool {
        Tool::Compress => ("quality-50", "webp"),
        Tool::Resize => ("1080p", "png"),
        _ => ("converted", "webp"),
    };
    let temp = work.0.join(format!("output.{ext}"));
    let input = work.0.join(format!(
        "input.{}",
        path.extension().unwrap_or_default().to_string_lossy()
    ));
    std::os::unix::fs::symlink(&path, &input).map_err(|e| e.to_string())?;
    if available("vips") {
        let mut cmd = Command::new("vips");
        if tool == Tool::Resize {
            cmd.arg("thumbnail")
                .arg(&input)
                .arg(&temp)
                .args(["1920", "--height", "1080", "--size", "down"]);
        } else {
            cmd.arg("copy").arg(&input).arg(format!(
                "{}[Q={}]",
                temp.display(),
                if tool == Tool::Compress { 50 } else { 80 }
            ));
        }
        boosters::run(&mut cmd, 30)?;
    } else if available("ffmpeg") {
        let mut cmd = Command::new("ffmpeg");
        cmd.args(["-v", "error", "-nostdin", "-n", "-i"])
            .arg(&input)
            .args(["-frames:v", "1"]);
        match tool {
            Tool::Resize => {
                cmd.args([
                    "-vf",
                    "scale=w='min(1920,iw)':h='min(1080,ih)':force_original_aspect_ratio=decrease",
                ]);
            }
            Tool::Compress => {
                cmd.args(["-c:v", "libwebp", "-quality", "50"]);
            }
            _ => {
                cmd.args(["-c:v", "libwebp", "-quality", "80"]);
            }
        }
        cmd.arg(&temp);
        boosters::run(&mut cmd, 30)?;
    } else {
        return Err("Image conversion requires vips or ffmpeg".into());
    }
    let stem = path.file_stem().unwrap_or_default().to_string_lossy();
    for n in 1..1000 {
        let output = path.with_file_name(format!(
            "{stem}-{suffix}{}{ext}",
            if n == 1 { ".".into() } else { format!("-{n}.") }
        ));
        use std::os::unix::fs::OpenOptionsExt;
        match fs::OpenOptions::new()
            .write(true)
            .create_new(true)
            .mode(0o600)
            .open(&output)
        {
            Ok(mut file) => {
                let result = (|| {
                    let mut input = fs::File::open(&temp)?;
                    std::io::copy(&mut input, &mut file)?;
                    file.flush()
                })();
                if let Err(e) = result {
                    let _ = fs::remove_file(&output);
                    return Err(e.to_string());
                }
                return Ok(Outcome::File(output));
            }
            Err(e) if e.kind() == std::io::ErrorKind::AlreadyExists => continue,
            Err(e) => return Err(e.to_string()),
        }
    }
    Err("Could not choose an unused output filename".into())
}
pub fn compress_capture(bytes: &[u8]) -> Result<Vec<u8>, String> {
    if bytes.len() > 67_108_864 {
        return Err("Screenshot exceeds 64 MiB".into());
    }
    let work = Work::new()?;
    let input = work.0.join("Screenshot.png");
    fs::write(&input, bytes).map_err(|e| e.to_string())?;
    let Outcome::File(output) = transform(Tool::Compress, &input)? else {
        return Err("Image conversion returned no image".into());
    };
    fs::read(output).map_err(|e| e.to_string())
}
pub struct Work(pub PathBuf);
impl Work {
    pub fn new() -> Result<Self, String> {
        use std::os::unix::fs::DirBuilderExt;
        let path = std::env::temp_dir().join(format!(
            "spotlight-tools-{}",
            gtk::glib::uuid_string_random()
        ));
        fs::DirBuilder::new()
            .mode(0o700)
            .create(&path)
            .map_err(|e| e.to_string())?;
        Ok(Self(path))
    }
}
impl Drop for Work {
    fn drop(&mut self) {
        let _ = fs::remove_dir_all(&self.0);
    }
}
pub fn decode_qr(bytes: &[u8]) -> Result<String, String> {
    let work = Work::new()?;
    let path = work.0.join("capture.png");
    fs::write(&path, bytes).map_err(|e| e.to_string())?;
    let text = boosters::run(
        Command::new("zbarimg")
            .args([
                "--quiet",
                "--raw",
                "--set",
                "*.disable",
                "--set",
                "qrcode.enable",
            ])
            .arg(&path),
        15,
    )?;
    if text.trim().is_empty() {
        Err("No QR code found".into())
    } else {
        Ok(text)
    }
}
pub fn palette(path: &Path) -> Result<Vec<String>, String> {
    let (width, height) = image_size(path)?;
    let image = Pixbuf::from_file_at_scale(path, width.min(128), height.min(128), true)
        .map_err(|e| e.to_string())?;
    let pixels = image.read_pixel_bytes();
    let pixels = pixels.as_ref();
    let channels = image.n_channels() as usize;
    let stride = image.rowstride() as usize;
    let mut bins: HashMap<u16, (u64, u64, u64, u64)> = HashMap::new();
    for y in 0..image.height() as usize {
        for x in 0..image.width() as usize {
            let i = y * stride + x * channels;
            if channels == 4 && pixels[i + 3] < 128 {
                continue;
            }
            let (r, g, b) = (pixels[i] as u64, pixels[i + 1] as u64, pixels[i + 2] as u64);
            let key = (((r >> 4) << 8) | ((g >> 4) << 4) | (b >> 4)) as u16;
            let bin = bins.entry(key).or_default();
            bin.0 += 1;
            bin.1 += r;
            bin.2 += g;
            bin.3 += b;
        }
    }
    let mut bins: Vec<_> = bins.into_iter().collect();
    bins.sort_by_key(|(key, bin)| (std::cmp::Reverse(bin.0), *key));
    let mut colors: Vec<(u64, u64, u64)> = Vec::new();
    for (_, (n, r, g, b)) in &bins {
        let c = (r / n, g / n, b / n);
        if colors.iter().all(|p| {
            let d = (p.0 as i64 - c.0 as i64).pow(2)
                + (p.1 as i64 - c.1 as i64).pow(2)
                + (p.2 as i64 - c.2 as i64).pow(2);
            d > 900
        }) {
            colors.push(c);
        }
        if colors.len() == 5 {
            break;
        }
    }
    if colors.is_empty() {
        return Err("The image has no visible colors".into());
    }
    // Flat images may contain fewer than five distinct colors; keep the actual palette.
    Ok(colors
        .iter()
        .map(|(r, g, b)| format!("#{r:02X}{g:02X}{b:02X}"))
        .collect())
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn parses_requested_commands_and_keeps_paths_intact() {
        for text in [
            "pause",
            "next track",
            "play lofi",
            "history youtube",
            "bookmark github",
            "screenshot",
            "compress image 50% /tmp/a b.png",
            "resize 1080p /tmp/x.png",
            "pdf text",
            "image to webp",
            "palette",
        ] {
            assert!(Query::parse(text).is_some(), "{text}");
        }
        assert_eq!(
            Query::parse("compress image 50% /tmp/a b.png"),
            Some(Query::File(Tool::Compress, "/tmp/a b.png".into()))
        );
        assert_eq!(Query::parse("next project"), None);
        assert_eq!(
            Query::parse("compress image 70%"),
            None,
            "Do not silently accept unsupported quality"
        );
    }
    #[test]
    fn local_image_conversion_palette_and_qr() {
        let work = Work::new().unwrap();
        let source = work.0.join("image café [test].png");
        let image = Pixbuf::new(gtk::gdk_pixbuf::Colorspace::Rgb, true, 8, 2048, 1200).unwrap();
        image.fill(0x336699ff);
        image.savev(&source, "png", &[]).unwrap();
        let original = fs::read(&source).unwrap();
        assert_eq!(palette(&source).unwrap(), vec!["#336699"]);
        let compressed = compress_capture(&original).unwrap();
        assert!(compressed.starts_with(b"RIFF"));
        assert_eq!(&compressed[8..12], b"WEBP");
        // Reading WebP back needs the optional gdk-pixbuf WebP loader, which
        // distributions ship separately, so only round-trip when it is there.
        let webp = Pixbuf::formats()
            .iter()
            .any(|format| format.name().as_deref() == Some("webp"));
        if webp {
            let loader = gtk::gdk_pixbuf::PixbufLoader::new();
            use gtk::prelude::*;
            loader.write(&compressed).unwrap();
            loader.close().unwrap();
            let decoded = loader.pixbuf().unwrap();
            assert_eq!((decoded.width(), decoded.height()), (2048, 1200));
        }
        assert_eq!(fs::read(&source).unwrap(), original);
        for tool in [Tool::Compress, Tool::Resize, Tool::Webp] {
            let Outcome::File(output) = transform(tool, &source).unwrap() else {
                panic!("Expected saved image")
            };
            assert_ne!(output, source);
            assert!(output.is_file());
            if tool == Tool::Resize || webp {
                let (_, w, h) = Pixbuf::file_info(&output).unwrap();
                if tool == Tool::Resize {
                    assert!(w <= 1920 && h <= 1080);
                    assert!((w as f64 / h as f64 - 2048. / 1200.).abs() < 0.01);
                }
            }
            let Outcome::File(second) = transform(tool, &source).unwrap() else {
                panic!()
            };
            assert_ne!(output, second);
            assert_eq!(fs::read(&source).unwrap(), original);
        }
        let rows = crate::advanced::fetch(&crate::advanced::Query::Qr("Spotlight QR café".into()))
            .unwrap();
        let Some(Op::Advanced(crate::advanced::Operation::Image { bytes, .. })) =
            rows.into_iter().next().unwrap().operation
        else {
            panic!()
        };
        assert_eq!(decode_qr(&bytes).unwrap().trim(), "Spotlight QR café");
        let invisible = Pixbuf::new(gtk::gdk_pixbuf::Colorspace::Rgb, true, 8, 7, 3).unwrap();
        invisible.fill(0xff000000);
        invisible.savev(&source, "png", &[]).unwrap();
        assert!(palette(&source).is_err());
    }
    #[test]
    fn extracts_real_pdf_text() {
        let work = Work::new().unwrap();
        let path = work.0.join("PDF café.pdf");
        let stream = "BT /F1 18 Tf 50 100 Td (Spotlight PDF fixture) Tj ET";
        let objects=["<< /Type /Catalog /Pages 2 0 R >>".to_string(),"<< /Type /Pages /Kids [3 0 R] /Count 1 >>".into(),"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 300 200] /Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >>".into(),"<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>".into(),format!("<< /Length {} >>\nstream\n{stream}\nendstream",stream.len())];
        let mut pdf = "%PDF-1.4\n".to_string();
        let mut offsets = vec![0];
        for (i, obj) in objects.iter().enumerate() {
            offsets.push(pdf.len());
            pdf.push_str(&format!("{} 0 obj\n{obj}\nendobj\n", i + 1));
        }
        let xref = pdf.len();
        pdf.push_str("xref\n0 6\n0000000000 65535 f \n");
        for offset in offsets.iter().skip(1) {
            pdf.push_str(&format!("{offset:010} 00000 n \n"));
        }
        pdf.push_str(&format!(
            "trailer\n<< /Size 6 /Root 1 0 R >>\nstartxref\n{xref}\n%%EOF\n"
        ));
        fs::write(&path, pdf).unwrap();
        let Outcome::Text(text) = transform(Tool::Pdf, &path).unwrap() else {
            panic!()
        };
        assert!(text.contains("Spotlight PDF fixture"));
    }
    #[test]
    fn extracts_five_colors_and_rejects_bad_music_operations() {
        let work = Work::new().unwrap();
        let source = work.0.join("five.ppm");
        let mut ppm = b"P6\n5 1\n255\n".to_vec();
        ppm.extend_from_slice(&[255, 0, 0, 0, 255, 0, 0, 0, 255, 255, 255, 0, 255, 0, 255]);
        fs::write(&source, ppm).unwrap();
        let colors = palette(&source).unwrap();
        assert_eq!(colors.len(), 5);
        for color in colors {
            assert!(color.starts_with('#'));
        }
        assert!(
            execute(Operation::Music {
                player: "--all-players".into(),
                command: "pause".into()
            })
            .is_err()
        );
        assert!(
            execute(Operation::Music {
                player: "demo".into(),
                command: "invalid".into()
            })
            .is_err()
        );
    }
}

#[cfg(test)]
mod music_fixture {
    use super::*;
    #[test]
    #[ignore = "requires private MPRIS fixture; run tests/music_smoke.py"]
    fn native_mpris_controls() {
        assert_eq!(std::env::var("SPOTLIGHT_MUSIC_FIXTURE").as_deref(), Ok("1"));
        let rows = fetch(&Query::Music("next".into(), "track".into())).unwrap();
        assert_eq!(rows.len(), 1);
        assert!(rows[0].detail.contains("Fixture song"));
        let Some(Op::Local(op)) = rows[0].operation.clone() else {
            panic!()
        };
        assert!(
            matches!(&op,Operation::Music{player,command} if player=="org.mpris.MediaPlayer2.spotlight_fixture" && command=="next")
        );
        execute(op).unwrap();
        let rows = fetch(&Query::Music("controls".into(), "Spotlight Fixture".into())).unwrap();
        assert!(rows.iter().all(|r|!matches!(&r.operation,Some(Op::Local(Operation::Music {command,..})) if command=="previous")));
        let op = rows
            .iter()
            .find_map(|r| match &r.operation {
                Some(Op::Local(op @ Operation::Music { command, .. }))
                    if command == "play-pause" =>
                {
                    Some(op.clone())
                }
                _ => None,
            })
            .unwrap();
        execute(op).unwrap();
        let rows = fetch(&Query::Music("pause".into(), String::new())).unwrap();
        let Some(Op::Local(op)) = rows[0].operation.clone() else {
            panic!()
        };
        execute(op).unwrap();
        assert!(
            execute(Operation::Music {
                player: "org.mpris.MediaPlayer2.spotlight_fixture".into(),
                command: "pause".into()
            })
            .is_err(),
            "Capability changes are checked again before a command"
        );
        let rows = fetch(&Query::Music("play".into(), String::new())).unwrap();
        let Some(Op::Local(op)) = rows[0].operation.clone() else {
            panic!()
        };
        execute(op).unwrap();
        let rows = fetch(&Query::Music("play".into(), "lofi".into())).unwrap();
        assert!(
            matches!(&rows[0].operation,Some(Op::Local(Operation::Open(url))) if url.ends_with("search_query=lofi"))
        );
    }
}

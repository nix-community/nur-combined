use crate::{
    boosters::{self, Entry, Operation as Op, entry, hint},
    core,
};
use gtk::{gio, glib, prelude::*};
use serde_json::Value;
use std::{
    collections::HashSet,
    fs,
    net::IpAddr,
    path::{Path, PathBuf},
    process::Command,
};

#[derive(Clone, Debug, PartialEq, Eq, Hash)]
pub enum Query {
    Ip(bool),
    Stats(String),
    Qr(String),
    Ocr(String),
    Speakers(String),
    Tabs(String),
    Packages {
        manager: String,
        filter: String,
    },
    Services {
        system: bool,
        action: String,
        filter: String,
    },
    Bluetooth {
        action: String,
        filter: String,
    },
    Windows {
        mode: String,
        filter: String,
    },
}
impl Query {
    pub fn parse(text: &str) -> Option<Self> {
        let text = text.trim();
        let lower = text.to_ascii_lowercase();
        if matches!(lower.as_str(), "ip" | "my ip" | "ip local" | "local ip") {
            return Some(Self::Ip(!lower.contains("local")));
        }
        if matches!(lower.as_str(), "battery" | "disk" | "ram" | "uptime") {
            return Some(Self::Stats(lower));
        }
        let (head, tail) = text.split_once(char::is_whitespace).unwrap_or((text, ""));
        let tail = tail.trim();
        let head = head.to_ascii_lowercase();
        if head == "qr" {
            return Some(Self::Qr(tail.into()));
        }
        if head == "generate" && (tail == "qr" || tail.starts_with("qr ")) {
            return Some(Self::Qr(tail[2..].trim().into()));
        }
        if head == "ocr" {
            return Some(Self::Ocr(tail.into()));
        }
        if head == "speakers" || head == "outputs" {
            return Some(Self::Speakers(tail.into()));
        }
        if head == "audio" && tail.starts_with("outputs") {
            return Some(Self::Speakers(tail[7..].trim().into()));
        }
        if head == "tabs" {
            let (browser, rest) = tail.split_once(char::is_whitespace).unwrap_or((tail, ""));
            return Some(Self::Tabs(
                (if matches!(
                    browser.to_ascii_lowercase().as_str(),
                    "chrome" | "chromium" | "brave"
                ) {
                    rest
                } else {
                    tail
                })
                .trim()
                .into(),
            ));
        }
        if matches!(head.as_str(), "close" | "kill")
            && (tail == "window" || tail.starts_with("window "))
        {
            return Some(Self::Windows {
                mode: head,
                filter: tail[6..].trim().into(),
            });
        }
        if head == "quit" && (tail == "app" || tail.starts_with("app ")) {
            return Some(Self::Windows {
                mode: head,
                filter: tail[3..].trim().into(),
            });
        }
        if head == "bluetooth" {
            let (action, filter) = tail.split_once(char::is_whitespace).unwrap_or((tail, ""));
            if matches!(action, "connect" | "disconnect" | "devices") {
                return Some(Self::Bluetooth {
                    action: action.into(),
                    filter: filter.trim().into(),
                });
            }
        }
        if matches!(head.as_str(), "apt" | "pacman" | "flatpak" | "packages") {
            let filter = tail
                .strip_prefix("search ")
                .or_else(|| tail.strip_prefix("-Ss "))
                .or_else(|| tail.strip_prefix("Ss "))
                .unwrap_or(tail);
            return Some(Self::Packages {
                manager: head,
                filter: if matches!(filter, "search" | "-Ss" | "Ss") {
                    String::new()
                } else {
                    filter.into()
                },
            });
        }
        if matches!(head.as_str(), "service" | "services" | "systemctl") {
            let mut system = head == "systemctl";
            let mut tail = tail;
            if let Some(rest) = tail.strip_prefix("--user ") {
                system = false;
                tail = rest;
            } else if tail == "--user" {
                system = false;
                tail = "";
            }
            if let Some(rest) = tail.strip_prefix("--system ") {
                system = true;
                tail = rest;
            } else if tail == "--system" {
                system = true;
                tail = "";
            }
            let (action, filter) = tail.split_once(char::is_whitespace).unwrap_or((tail, ""));
            let (action, filter) = if matches!(action, "status" | "start" | "restart" | "stop") {
                (action.to_string(), filter.trim().to_string())
            } else {
                ("status".into(), tail.into())
            };
            return Some(Self::Services {
                system,
                action,
                filter,
            });
        }
        None
    }
}

#[derive(Clone, Debug)]
pub enum Operation {
    QrInput,
    Image {
        bytes: Vec<u8>,
        title: String,
    },
    OcrClipboard,
    OcrLatest,
    Sink {
        backend: String,
        id: String,
        identity: String,
    },
    Tab {
        port: u16,
        id: String,
    },
    Install {
        manager: String,
        package: String,
        remote: String,
    },
    Service {
        system: bool,
        action: String,
        unit: String,
    },
    Bluetooth {
        address: String,
        connect: bool,
    },
    Window {
        mode: String,
        id: String,
        app: String,
        pid: u32,
        started: u64,
    },
}
impl Operation {
    pub fn confirmation(&self) -> Option<(String, String)> {
        match self {
            Self::Install{manager,package,remote}=>Some((format!("Install {package}?"),format!("Install using {}{}. Required dependencies may also be installed. {}",if manager=="flatpak-system"{"Flatpak (system)"}else if manager=="flatpak"{"Flatpak (user)"}else{manager},if remote.is_empty(){String::new()}else{format!(" from {remote}")},if manager=="flatpak"{"This installs for your user."}else{"Desktop administrator authorization may be required."}))),
            Self::Service{system,action,unit}=>Some((format!("{action} {unit}?"),format!("This changes the {} service. Restarting or stopping it may interrupt work that depends on it.",if *system{"system"}else{"user"}))),
            Self::Window{mode,app,pid,..} if mode=="kill"=>Some((format!("Force quit {app}?"),format!("Send SIGKILL to PID {pid}. All windows sharing this process may close and unsaved work will be lost."))),
            Self::Window{mode,app,..} if mode=="quit"=>Some((format!("Quit {app}?"),"Ask all windows of this application process to close. The app can still show its own save dialogs.".into())),
            _=>None,
        }
    }
}
fn action(
    title: impl Into<String>,
    detail: impl Into<String>,
    badge: &'static str,
    op: Operation,
) -> Entry {
    entry(title, detail, badge, Op::Advanced(op))
}
fn copy(title: impl Into<String>, detail: impl Into<String>, value: String) -> Entry {
    entry(title, detail, "Copy", Op::Copy(value))
}
pub fn fetch(query: &Query) -> Result<Vec<Entry>, String> {
    match query {
        Query::Ip(public) => ip(*public),
        Query::Stats(kind) => stats(kind),
        Query::Qr(text) => qr(text),
        Query::Ocr(source) => {
            if source.is_empty() {
                Ok(vec![
                    action(
                        "OCR clipboard image",
                        "Extract text with Tesseract · Enter to read the clipboard",
                        "OCR",
                        Operation::OcrClipboard,
                    ),
                    action(
                        "OCR latest screenshot",
                        "Read the newest image in your screenshot folders",
                        "OCR",
                        Operation::OcrLatest,
                    ),
                ])
            } else {
                let path = if source == "latest" || source == "screenshot" {
                    latest_screenshot()?
                } else {
                    expand_path(source)
                };
                let text = ocr_file(&path)?;
                Ok(vec![entry(
                    "Extracted text",
                    path.display().to_string(),
                    "OCR",
                    Op::Preview {
                        title: "Extracted text".into(),
                        text,
                        open: None,
                    },
                )])
            }
        }
        Query::Speakers(filter) => speakers(filter),
        Query::Tabs(filter) => tabs(filter),
        Query::Packages { manager, filter } => packages(manager, filter),
        Query::Services {
            system,
            action,
            filter,
        } => services(*system, action, filter),
        Query::Bluetooth { action, filter } => bluetooth(action, filter),
        Query::Windows { mode, filter } => window_actions(mode, filter),
    }
}
fn expand_path(text: &str) -> PathBuf {
    if let Some(s) = text.strip_prefix("~/") {
        core::home().join(s)
    } else {
        PathBuf::from(text)
    }
}
fn human(bytes: u64) -> String {
    for (divisor, unit) in [
        (1_u64 << 40, "TiB"),
        (1 << 30, "GiB"),
        (1 << 20, "MiB"),
        (1 << 10, "KiB"),
    ] {
        if bytes >= divisor {
            return format!("{:.1} {unit}", bytes as f64 / divisor as f64);
        }
    }
    format!("{bytes} B")
}
fn ip(public: bool) -> Result<Vec<Entry>, String> {
    let mut rows = Vec::new();
    match boosters::run(Command::new("ip").args(["-j", "address", "show", "up"]), 4) {
        Ok(body) => {
            let value: Value =
                serde_json::from_str(&body).map_err(|_| "Invalid IP address response")?;
            if let Some(links) = value.as_array() {
                for link in links {
                    for address in link["addr_info"].as_array().into_iter().flatten() {
                        if address["scope"] == "host" {
                            continue;
                        }
                        if let Some(value) = address["local"]
                            .as_str()
                            .filter(|v| v.parse::<IpAddr>().is_ok())
                        {
                            rows.push(copy(
                                value,
                                format!("Local · {}", link["ifname"].as_str().unwrap_or("network")),
                                value.into(),
                            ));
                        }
                    }
                }
            }
        }
        Err(error) => rows.push(hint("Local IP unavailable", error)),
    }
    if public {
        match boosters::run(
            Command::new("curl").args([
                "--fail",
                "--silent",
                "--show-error",
                "--connect-timeout",
                "3",
                "--max-time",
                "5",
                "--max-filesize",
                "128",
                "https://api.ipify.org",
            ]),
            6,
        ) {
            Ok(value) if value.trim().parse::<IpAddr>().is_ok() => rows.insert(
                0,
                copy(value.trim(), "Public IP · ipify", value.trim().into()),
            ),
            _ => rows.push(hint(
                "Public IP unavailable",
                "Check your connection · local addresses are listed separately",
            )),
        }
    }
    if rows.is_empty() {
        rows.push(hint(
            "No active network addresses",
            "Connect a network and use Ctrl+R to refresh",
        ));
    }
    Ok(rows)
}
fn stats(kind: &str) -> Result<Vec<Entry>, String> {
    match kind {
        "ram" => {
            let body = fs::read_to_string("/proc/meminfo").map_err(|e| e.to_string())?;
            let number = |name: &str| {
                body.lines()
                    .find_map(|l| {
                        l.strip_prefix(name)
                            .and_then(|s| s.split_whitespace().next())
                            .and_then(|s| s.parse::<u64>().ok())
                    })
                    .unwrap_or(0)
                    .saturating_mul(1024)
            };
            let total = number("MemTotal:");
            let available = number("MemAvailable:");
            let swap = number("SwapTotal:");
            let free = number("SwapFree:");
            let value = format!(
                "{} / {} RAM",
                human(total.saturating_sub(available)),
                human(total)
            );
            Ok(vec![
                copy(
                    &value,
                    format!("{} available · Enter copies", human(available)),
                    value.clone(),
                ),
                copy(
                    format!(
                        "{} / {} swap",
                        human(swap.saturating_sub(free)),
                        human(swap)
                    ),
                    "Swap usage",
                    format!(
                        "Swap: {} of {}",
                        human(swap.saturating_sub(free)),
                        human(swap)
                    ),
                ),
            ])
        }
        "uptime" => {
            let body = fs::read_to_string("/proc/uptime").map_err(|e| e.to_string())?;
            let seconds = body
                .split_whitespace()
                .next()
                .and_then(|s| s.parse::<f64>().ok())
                .ok_or("Invalid uptime")? as u64;
            let value = format!(
                "{}d {}h {}m uptime",
                seconds / 86400,
                seconds % 86400 / 3600,
                seconds % 3600 / 60
            );
            let load = fs::read_to_string("/proc/loadavg")
                .unwrap_or_default()
                .split_whitespace()
                .take(3)
                .collect::<Vec<_>>()
                .join(" · ");
            Ok(vec![copy(
                &value,
                format!("Load averages: {load}"),
                value.clone(),
            )])
        }
        "disk" => {
            let mut rows = Vec::new();
            for path in [PathBuf::from("/"), core::home()] {
                let file = gio::File::for_path(&path);
                match file.query_filesystem_info(
                    "filesystem::size,filesystem::free,filesystem::used",
                    None::<&gio::Cancellable>,
                ) {
                    Ok(info) => {
                        let size = info.attribute_uint64("filesystem::size");
                        let free = info.attribute_uint64("filesystem::free");
                        let used = if info.has_attribute("filesystem::used") {
                            info.attribute_uint64("filesystem::used")
                        } else {
                            size.saturating_sub(free)
                        };
                        let text =
                            format!("{} / {} · {}", human(used), human(size), path.display());
                        rows.push(copy(
                            &text,
                            format!("{} free · Enter copies", human(free)),
                            text.clone(),
                        ));
                    }
                    Err(e) => rows.push(hint(
                        format!("{} unavailable", path.display()),
                        e.to_string(),
                    )),
                }
            }
            Ok(rows)
        }
        "battery" => {
            let mut rows = Vec::new();
            for entry in fs::read_dir("/sys/class/power_supply")
                .into_iter()
                .flatten()
                .flatten()
            {
                let p = entry.path();
                if fs::read_to_string(p.join("type"))
                    .unwrap_or_default()
                    .trim()
                    != "Battery"
                {
                    continue;
                }
                let read = |name: &str| {
                    fs::read_to_string(p.join(name))
                        .unwrap_or_default()
                        .trim()
                        .to_string()
                };
                let status = read("status");
                let value = format!("{}% · {status}", read("capacity"));
                rows.push(copy(
                    &value,
                    entry.file_name().to_string_lossy().to_string(),
                    value.clone(),
                ));
            }
            if rows.is_empty() {
                rows.push(hint(
                    "No battery detected",
                    "This computer may run on mains power",
                ));
            }
            Ok(rows)
        }
        _ => Err("Unknown system statistic".into()),
    }
}
fn qr(text: &str) -> Result<Vec<Entry>, String> {
    if text.is_empty() {
        return Ok(vec![action(
            "Generate a QR code",
            "Enter opens a text/URL input · or type qr hello",
            "QR",
            Operation::QrInput,
        )]);
    }
    if text.len() > 2048 {
        return Err("QR input is limited to 2,048 UTF-8 bytes".into());
    }
    // ECI 26 marks byte data as UTF-8; without it scanners can misread accented text.
    let segments = [
        qrcodegen::QrSegment::make_eci(26),
        qrcodegen::QrSegment::make_bytes(text.as_bytes()),
    ];
    let code = qrcodegen::QrCode::encode_segments(&segments, qrcodegen::QrCodeEcc::Medium)
        .map_err(|e| e.to_string())?;
    let size = (code.size() + 8) * 6;
    let mut pixels = vec![255u8; (size * size * 3) as usize];
    for y in 0..size {
        for x in 0..size {
            if code.get_module(x / 6 - 4, y / 6 - 4) {
                let offset = ((y * size + x) * 3) as usize;
                pixels[offset..offset + 3].fill(0);
            }
        }
    }
    let pixbuf = gtk::gdk_pixbuf::Pixbuf::from_mut_slice(
        pixels,
        gtk::gdk_pixbuf::Colorspace::Rgb,
        false,
        8,
        size,
        size,
        size * 3,
    );
    let bytes = pixbuf
        .save_to_bufferv("png", &[])
        .map_err(|e| e.to_string())?;
    Ok(vec![action(
        "QR code",
        format!(
            "{} UTF-8 bytes · Enter previews · Copy Image copies the QR",
            text.len()
        ),
        "QR",
        Operation::Image {
            bytes,
            title: "QR code".into(),
        },
    )])
}
pub fn ocr_bytes(bytes: &[u8]) -> Result<String, String> {
    if bytes.len() > 16_777_216 {
        return Err("OCR image exceeds 16 MiB".into());
    }
    let text = boosters::run_input(
        Command::new("tesseract").args(["stdin", "stdout"]),
        30,
        Some(bytes),
    )
    .map_err(|e| format!("OCR needs Tesseract: {e}"))?;
    if text.trim().is_empty() {
        Err("No text was detected in this image".into())
    } else {
        Ok(text)
    }
}
pub fn ocr_file(path: &Path) -> Result<String, String> {
    let meta = fs::metadata(path).map_err(|e| e.to_string())?;
    if !meta.is_file() || meta.len() > 16_777_216 {
        return Err("Choose an image file smaller than 16 MiB".into());
    }
    let (_, w, h) =
        gtk::gdk_pixbuf::Pixbuf::file_info(path).ok_or("OCR needs a supported image file")?;
    if w <= 0 || h <= 0 || i64::from(w) * i64::from(h) > 16_000_000 {
        return Err("OCR image exceeds 16 million pixels".into());
    }
    ocr_bytes(&fs::read(path).map_err(|e| e.to_string())?)
}
pub fn latest_screenshot() -> Result<PathBuf, String> {
    let home = core::home();
    let pictures = glib::user_special_dir(glib::UserDirectory::Pictures)
        .unwrap_or_else(|| home.join("Pictures"));
    let mut candidates = Vec::new();
    for dir in [
        pictures.join("Screenshots"),
        pictures.join("screenshots"),
        home.join("Screenshots"),
        pictures,
    ] {
        for entry in fs::read_dir(&dir)
            .into_iter()
            .flatten()
            .flatten()
            .take(3000)
        {
            let path = entry.path();
            let name = entry.file_name().to_string_lossy().to_lowercase();
            let screenshot_dir = dir
                .file_name()
                .is_some_and(|n| n.to_string_lossy().eq_ignore_ascii_case("screenshots"));
            if !crate::search::image_path(&path)
                || !screenshot_dir && !name.contains("screenshot") && !name.contains("spectacle")
            {
                continue;
            }
            if let Ok(meta) = entry.metadata()
                && meta.is_file()
                && meta.len() <= 16_777_216
                && let Ok(time) = meta.modified()
            {
                candidates.push((time, path));
            }
        }
    }
    candidates.sort_by_key(|a| std::cmp::Reverse(a.0));
    candidates.into_iter().next().map(|(_,p)|p).ok_or_else(||"No screenshot found in Pictures/Screenshots or Screenshots · use ocr /path/to/image.png".into())
}

fn exists(program: &str) -> bool {
    std::env::var_os("PATH")
        .is_some_and(|paths| std::env::split_paths(&paths).any(|dir| dir.join(program).is_file()))
}
fn property(body: &str, name: &str) -> Option<String> {
    body.lines().find_map(|line| {
        let line = line.trim().trim_start_matches('*').trim();
        let (key, value) = line.split_once('=')?;
        (key.trim() == name).then(|| value.trim().trim_matches('"').to_string())
    })
}
fn speakers(filter: &str) -> Result<Vec<Entry>, String> {
    if exists("pactl")
        && let Ok(body) = boosters::run(
            Command::new("pactl").args(["-f", "json", "list", "sinks"]),
            5,
        )
    {
        let sinks: Vec<Value> =
            serde_json::from_str(&body).map_err(|_| "Invalid audio output response")?;
        let default =
            boosters::run(Command::new("pactl").arg("get-default-sink"), 3).unwrap_or_default();
        let mut rows: Vec<_> = sinks
            .into_iter()
            .filter_map(|sink| {
                let name = sink["name"].as_str()?.to_string();
                let description = sink["description"].as_str().unwrap_or(&name).to_string();
                let score = core::score(filter, &format!("{description} {name}"))?;
                let current = default.trim() == name;
                Some((
                    score,
                    action(
                        format!("{}{description}", if current { "✓ " } else { "" }),
                        format!(
                            "{} · Enter sets the default output and moves active streams",
                            sink["state"].as_str().unwrap_or("Available")
                        ),
                        "Audio",
                        Operation::Sink {
                            backend: "pactl".into(),
                            id: name.clone(),
                            identity: name,
                        },
                    ),
                ))
            })
            .collect();
        rows.sort_by_key(|a| std::cmp::Reverse(a.0));
        let mut rows: Vec<_> = rows.into_iter().take(40).map(|(_, r)| r).collect();
        if rows.is_empty() {
            rows.push(hint(
                "No matching audio outputs",
                "Connect headphones, HDMI audio, or a speaker and refresh",
            ));
        }
        return Ok(rows);
    }
    let body = boosters::run(
        Command::new("wpctl")
            .arg("status")
            .env("LC_ALL", "C")
            .env("NO_COLOR", "1"),
        5,
    )
    .map_err(|e| format!("Audio outputs need pactl or WirePlumber: {e}"))?;
    let mut audio = false;
    let mut sinks = false;
    let mut rows = Vec::new();
    for line in body.lines() {
        if line.trim() == "Audio" {
            audio = true;
            continue;
        }
        if line.trim() == "Video" {
            audio = false;
        }
        if !audio {
            continue;
        }
        if line.contains("Sinks:") {
            sinks = true;
            continue;
        }
        if line.contains("Sources:") || line.contains("Filters:") || line.contains("Streams:") {
            sinks = false;
        }
        if !sinks {
            continue;
        }
        let start = line.trim_start_matches(|c: char| !c.is_ascii_digit());
        let Some((id, label)) = start.split_once('.') else {
            continue;
        };
        if id.parse::<u32>().is_err() {
            continue;
        }
        let label = label.split(" [").next().unwrap_or(label).trim();
        if core::score(filter, label).is_none() {
            continue;
        }
        let inspect = boosters::run(Command::new("wpctl").args(["inspect", id]), 3)?;
        let Some(identity) = property(&inspect, "node.name") else {
            continue;
        };
        rows.push(action(
            label,
            "Enter sets the default output for new streams",
            "Audio",
            Operation::Sink {
                backend: "wpctl".into(),
                id: id.into(),
                identity,
            },
        ));
        if rows.len() >= 30 {
            break;
        }
    }
    if rows.is_empty() {
        rows.push(hint(
            "No matching audio outputs",
            "Connect an audio device and refresh",
        ));
    }
    Ok(rows)
}
fn tab_port() -> Result<u16, String> {
    match std::env::var("SPOTLIGHT_CHROME_DEBUG_PORT") {
        Ok(port) => port
            .parse::<u16>()
            .ok()
            .filter(|p| *p > 0)
            .ok_or_else(|| "SPOTLIGHT_CHROME_DEBUG_PORT must be a local TCP port".into()),
        Err(_) => Ok(9222),
    }
}
fn local_browser(path: &str, port: u16) -> Result<String, String> {
    boosters::run(
        Command::new("curl").args([
            "--fail",
            "--silent",
            "--show-error",
            "--noproxy",
            "127.0.0.1",
            "--connect-timeout",
            "1",
            "--max-time",
            "3",
            "--max-filesize",
            "1048576",
            &format!("http://127.0.0.1:{port}{path}"),
        ]),
        4,
    )
}
fn tabs(filter: &str) -> Result<Vec<Entry>, String> {
    if std::env::var_os("SPOTLIGHT_CHROME_DEBUG_PORT").is_none() {
        return crate::localtools::browser("history", filter, "chrom");
    }
    let port = tab_port()?;
    let body = match local_browser("/json/list", port) {
        Ok(body) => body,
        Err(_) => return crate::localtools::browser("history", filter, "chrom"),
    };
    let values: Vec<Value> = serde_json::from_str(&body).map_err(|_| "Invalid browser tab list")?;
    let mut rows: Vec<_> = values
        .into_iter()
        .filter(|v| v["type"] == "page")
        .filter_map(|v| {
            let id = v["id"].as_str()?.to_string();
            if !valid_tab_id(&id) {
                return None;
            }
            let title = v["title"].as_str().unwrap_or("Browser tab");
            let url = v["url"].as_str().unwrap_or("");
            let score = core::score(filter, &format!("{title} {url}"))?;
            Some((
                score,
                action(title, url, "Tab", Operation::Tab { port, id }),
            ))
        })
        .collect();
    rows.sort_by_key(|a| std::cmp::Reverse(a.0));
    let mut rows: Vec<_> = rows.into_iter().take(60).map(|(_, r)| r).collect();
    if rows.is_empty() {
        rows.push(hint(
            "No matching browser tabs",
            "Type tabs chrome followed by part of a title or URL",
        ));
    }
    Ok(rows)
}
fn valid_tab_id(id: &str) -> bool {
    !id.is_empty()
        && id.len() <= 128
        && id
            .bytes()
            .all(|b| b.is_ascii_alphanumeric() || b"-_".contains(&b))
}
fn valid_name(name: &str) -> bool {
    !name.is_empty()
        && !name.starts_with('-')
        && name.len() <= 255
        && name
            .bytes()
            .all(|b| b.is_ascii_alphanumeric() || b"@+._:-".contains(&b))
}
fn package_pattern(term: &str) -> String {
    term.chars()
        .take(32)
        .map(|c| {
            if ".^$*+?()[]{}|\\".contains(c) {
                format!("\\{c}")
            } else {
                c.to_string()
            }
        })
        .collect::<Vec<_>>()
        .join(".*")
}
fn packages(manager: &str, filter: &str) -> Result<Vec<Entry>, String> {
    if filter.len() > 256 {
        return Err("Package searches are limited to 256 bytes".into());
    }
    let manager = if manager == "packages" {
        if exists("apt-cache") {
            "apt"
        } else if exists("pacman") {
            "pacman"
        } else {
            "flatpak"
        }
    } else {
        manager
    };
    if filter.is_empty() {
        return Ok(vec![hint(
            format!("Search {manager} packages"),
            "Type a search term · Enter on a result reviews installation before making changes",
        )]);
    }
    let pattern = package_pattern(filter.split_whitespace().next().unwrap_or(filter));
    let term = pattern.as_str();
    let body = match manager {
        "apt" => boosters::run(
            Command::new("apt-cache")
                .args(["search", "--names-only", "--", term])
                .env("LC_ALL", "C"),
            15,
        ),
        "pacman" => boosters::run(
            Command::new("pacman")
                .args(["-Ss", "--color", "never", "--", term])
                .env("LC_ALL", "C"),
            15,
        ),
        "flatpak" => boosters::run(
            Command::new("flatpak")
                .args([
                    "search",
                    "--columns=application:f,name:f,description:f,version:f,remotes:f",
                    "--",
                    filter,
                ])
                .env("LC_ALL", "C"),
            20,
        ),
        _ => return Err("Choose apt, pacman, or flatpak".into()),
    };
    let mut body = match body {
        Ok(body) => body,
        Err(error) if error.ends_with("exit status: 1") => String::new(),
        Err(error) => return Err(error),
    };
    if manager == "flatpak" && !body.contains('\t') && filter.chars().count() > 1 {
        let first = filter.chars().next().unwrap().to_string();
        body = boosters::run(
            Command::new("flatpak")
                .args([
                    "search",
                    "--columns=application:f,name:f,description:f,version:f,remotes:f",
                    "--",
                    &first,
                ])
                .env("LC_ALL", "C"),
            15,
        )?;
    }
    let mut packages = Vec::<(String, String, String)>::new();
    match manager {
        "apt" => {
            for line in body.lines().take(500) {
                if let Some((name, detail)) = line.split_once(" - ")
                    && valid_name(name)
                {
                    packages.push((name.into(), detail.into(), String::new()));
                }
            }
        }
        "pacman" => {
            let mut lines = body.lines().peekable();
            while let Some(line) = lines.next() {
                if line.starts_with(char::is_whitespace) {
                    continue;
                }
                let Some(first) = line.split_whitespace().next() else {
                    continue;
                };
                let Some((repo, name)) = first.split_once('/') else {
                    continue;
                };
                if !valid_name(name) {
                    continue;
                }
                let description = lines
                    .peek()
                    .filter(|l| l.starts_with(char::is_whitespace))
                    .map(|l| l.trim())
                    .unwrap_or("")
                    .to_string();
                packages.push((
                    name.into(),
                    format!("{repo} · {description}"),
                    String::new(),
                ));
                if packages.len() >= 500 {
                    break;
                }
            }
        }
        "flatpak" => {
            for line in body.lines().take(500) {
                let fields: Vec<_> = line.split('\t').collect();
                if fields.len() < 5 || !valid_name(fields[0]) {
                    continue;
                }
                let remote = fields[4].split(',').next().unwrap_or("").trim();
                if !valid_name(remote) {
                    continue;
                }
                packages.push((
                    fields[0].into(),
                    format!("{} · {} · {}", fields[1], fields[2], fields[3]),
                    remote.into(),
                ));
            }
        }
        _ => {}
    }
    let user_remotes: HashSet<String> = if manager == "flatpak" {
        boosters::run(
            Command::new("flatpak").args(["remotes", "--user", "--columns=name"]),
            5,
        )
        .unwrap_or_default()
        .lines()
        .map(|s| s.trim().to_string())
        .collect()
    } else {
        HashSet::new()
    };
    let mut ranked: Vec<_> = packages
        .into_iter()
        .filter_map(|(name, detail, remote)| {
            core::score(filter, &format!("{name} {detail}")).map(|score| {
                (
                    score,
                    action(
                        &name,
                        format!("{detail} · Enter to review installation"),
                        "Install",
                        Operation::Install {
                            manager: if manager == "flatpak" && !user_remotes.contains(&remote) {
                                "flatpak-system".into()
                            } else {
                                manager.into()
                            },
                            package: name.clone(),
                            remote,
                        },
                    ),
                )
            })
        })
        .collect();
    ranked.sort_by_key(|a| std::cmp::Reverse(a.0));
    let mut rows: Vec<_> = ranked.into_iter().take(50).map(|(_, r)| r).collect();
    if rows.is_empty() {
        rows.push(hint("No matching packages",format!("{manager} · try another search term · package databases are not refreshed automatically")));
    }
    Ok(rows)
}
fn systemctl(system: bool) -> Command {
    let mut c = Command::new("systemctl");
    c.arg(if system { "--system" } else { "--user" })
        .env("LC_ALL", "C");
    c
}
fn valid_unit(unit: &str) -> bool {
    valid_name(unit) && unit.ends_with(".service") && !unit.contains('/')
}
fn services(system: bool, verb: &str, filter: &str) -> Result<Vec<Entry>, String> {
    if filter.len() > 256 {
        return Err("Service filters are limited to 256 bytes".into());
    }
    let body = boosters::run(
        systemctl(system).args([
            "list-units",
            "--type=service",
            "--all",
            "--no-pager",
            "--output=json",
        ]),
        8,
    )?;
    let units: Vec<Value> = serde_json::from_str(&body).map_err(|_| "Invalid service list")?;
    let scope = if system { "System" } else { "User" };
    let prefix = if system { "systemctl" } else { "service" };
    let target = if filter.ends_with(".service") {
        filter.to_string()
    } else {
        format!("{filter}.service")
    };
    let exact = units
        .iter()
        .find(|u| u["unit"].as_str() == Some(target.as_str()));
    if verb == "status" && !filter.is_empty() && exact.is_some() {
        let status = boosters::run(
            systemctl(system).args([
                "show",
                "--no-pager",
                "--property=Id,Description,ActiveState,SubState,MainPID,UnitFileState",
                "--",
                &target,
            ]),
            8,
        )?;
        let mut rows = vec![entry(
            format!("{scope} service · {target}"),
            "Enter opens status details",
            "Status",
            Op::Preview {
                title: target.clone(),
                text: status,
                open: None,
            },
        )];
        for action_name in ["restart", "stop", "start"] {
            rows.push(action(
                format!("{action_name} {target}"),
                format!("{scope} service · confirmation required"),
                "Service",
                Operation::Service {
                    system,
                    action: action_name.into(),
                    unit: target.clone(),
                },
            ));
        }
        return Ok(rows);
    }
    let mut ranked: Vec<_> = units
        .into_iter()
        .filter_map(|u| {
            let unit = u["unit"].as_str()?.to_string();
            if !valid_unit(&unit) {
                return None;
            }
            let desc = u["description"].as_str().unwrap_or("");
            let score = core::score(filter, &format!("{unit} {desc}"))?;
            let detail = format!(
                "{scope} · {} / {} · {desc}",
                u["active"].as_str().unwrap_or("unknown"),
                u["sub"].as_str().unwrap_or("unknown")
            );
            let row = if verb == "status" {
                entry(
                    &unit,
                    detail,
                    "Service",
                    Op::Query(format!("{prefix} status {unit}")),
                )
            } else {
                action(
                    format!("{verb} {unit}"),
                    format!("{detail} · Enter to review"),
                    "Service",
                    Operation::Service {
                        system,
                        action: verb.into(),
                        unit: unit.clone(),
                    },
                )
            };
            Some((score, row))
        })
        .collect();
    ranked.sort_by_key(|a| std::cmp::Reverse(a.0));
    let mut rows: Vec<_> = ranked.into_iter().take(60).map(|(_, r)| r).collect();
    if rows.is_empty() {
        rows.push(hint(
            format!("No matching {} services", scope.to_lowercase()),
            if system {
                "Try systemctl status or systemctl restart <service>"
            } else {
                "Lists user services · use systemctl for system services"
            },
        ));
    }
    Ok(rows)
}
fn bluetooth(verb: &str, filter: &str) -> Result<Vec<Entry>, String> {
    let body = boosters::run(
        Command::new("bluetoothctl")
            .arg("devices")
            .env("NO_COLOR", "1"),
        5,
    )?;
    let connected = boosters::run(
        Command::new("bluetoothctl")
            .args(["devices", "Connected"])
            .env("NO_COLOR", "1"),
        5,
    )
    .unwrap_or_default();
    let connected: HashSet<_> = connected
        .lines()
        .filter_map(|l| {
            l.strip_prefix("Device ")
                .and_then(|l| l.split_once(' '))
                .map(|(a, _)| a.to_ascii_uppercase())
        })
        .collect();
    let mut rows: Vec<_> = body
        .lines()
        .filter_map(|line| {
            let (address, name) = line.strip_prefix("Device ")?.split_once(' ')?;
            if !valid_mac(address) {
                return None;
            }
            let score = core::score(filter, &format!("{name} {address}"))?;
            let current = connected.contains(&address.to_ascii_uppercase());
            let connect = if verb == "devices" {
                !current
            } else {
                verb == "connect"
            };
            Some((
                score,
                action(
                    format!("{} {name}", if connect { "Connect" } else { "Disconnect" }),
                    format!(
                        "{address} · {}",
                        if current {
                            "Connected"
                        } else {
                            "Known device · pair in Bluetooth settings first if needed"
                        }
                    ),
                    "Bluetooth",
                    Operation::Bluetooth {
                        address: address.into(),
                        connect,
                    },
                ),
            ))
        })
        .collect();
    rows.sort_by_key(|a| std::cmp::Reverse(a.0));
    let mut rows: Vec<_> = rows.into_iter().take(50).map(|(_, r)| r).collect();
    if rows.is_empty() {
        rows.push(hint(
            "No matching Bluetooth devices",
            "Lists known devices without scanning · pair a device in Bluetooth settings first",
        ));
    }
    Ok(rows)
}
fn valid_mac(address: &str) -> bool {
    address.len() == 17
        && address.split(':').count() == 6
        && address
            .split(':')
            .all(|p| p.len() == 2 && p.bytes().all(|b| b.is_ascii_hexdigit()))
}
fn window_actions(mode: &str, filter: &str) -> Result<Vec<Entry>, String> {
    let mut rows: Vec<_> = crate::windowing::list()?
        .into_iter()
        .filter_map(|w| {
            let score = core::score(filter, &format!("{} {}", w.app, w.title))?;
            let started = boosters::process_identity(w.pid).unwrap_or(0);
            if mode == "kill" && (w.pid <= 1 || started == 0) {
                return None;
            }
            Some((
                score,
                action(
                    format!(
                        "{} {}",
                        if mode == "close" {
                            "Close"
                        } else if mode == "quit" {
                            "Quit"
                        } else {
                            "Force quit"
                        },
                        w.title
                    ),
                    format!(
                        "{} · PID {}{}",
                        w.app,
                        w.pid,
                        if mode == "kill" {
                            " · unsaved work will be lost"
                        } else if mode == "quit" {
                            " · closes this app process's windows"
                        } else {
                            " · request a normal window close"
                        }
                    ),
                    "Window",
                    Operation::Window {
                        mode: mode.into(),
                        id: w.id,
                        app: w.app,
                        pid: w.pid,
                        started,
                    },
                ),
            ))
        })
        .collect();
    rows.sort_by_key(|a| std::cmp::Reverse(a.0));
    let mut rows: Vec<_> = rows.into_iter().take(60).map(|(_, r)| r).collect();
    if rows.is_empty() {
        rows.push(hint(
            "No matching windows",
            "Search close window <name>, quit app <name>, or kill window <name>",
        ));
    }
    Ok(rows)
}
pub fn execute(operation: Operation) -> Result<String, String> {
    match operation {
        Operation::Sink {
            backend,
            id,
            identity,
        } => {
            if backend == "pactl" {
                let body = boosters::run(
                    Command::new("pactl").args(["-f", "json", "list", "sinks"]),
                    5,
                )?;
                let sinks: Vec<Value> =
                    serde_json::from_str(&body).map_err(|_| "Invalid output list")?;
                if id != identity
                    || !sinks
                        .iter()
                        .any(|s| s["name"].as_str() == Some(id.as_str()))
                {
                    return Err("That audio output disconnected · refresh the list".into());
                }
                boosters::run(Command::new("pactl").args(["set-default-sink", &id]), 5)?;
                let mut failed = 0;
                if let Ok(body) = boosters::run(
                    Command::new("pactl").args(["-f", "json", "list", "sink-inputs"]),
                    5,
                ) && let Ok(inputs) = serde_json::from_str::<Vec<Value>>(&body)
                {
                    for input in inputs.into_iter().take(100) {
                        if let Some(index) = input["index"].as_u64()
                            && boosters::run(
                                Command::new("pactl").args([
                                    "move-sink-input",
                                    &index.to_string(),
                                    &id,
                                ]),
                                3,
                            )
                            .is_err()
                        {
                            failed += 1;
                        }
                    }
                }
                Ok(if failed == 0 {
                    "Audio output switched".into()
                } else {
                    format!("Default output switched; {failed} streams could not be moved")
                })
            } else if backend == "wpctl" && id.parse::<u32>().is_ok() {
                let body = boosters::run(Command::new("wpctl").args(["inspect", &id]), 3)?;
                if property(&body, "node.name").as_deref() != Some(&identity)
                    || !body.contains("Audio/Sink")
                {
                    return Err("Audio device changed · refresh the list".into());
                }
                boosters::run(Command::new("wpctl").args(["set-default", &id]), 5)?;
                Ok("Default output switched for new streams".into())
            } else {
                Err("Invalid audio output".into())
            }
        }
        Operation::Tab { port, id } => {
            if !valid_tab_id(&id) || port == 0 {
                return Err("Invalid browser tab identity".into());
            }
            local_browser(&format!("/json/activate/{id}"), port)?;
            Ok("Activated browser tab".into())
        }
        Operation::Install {
            manager,
            package,
            remote,
        } => {
            if !valid_name(&package) {
                return Err("Invalid package identity".into());
            }
            let message = match manager.as_str() {
                "apt" => boosters::run(
                    Command::new("pkexec").args(["apt-get", "install", "-y", "--", &package]),
                    900,
                )?,
                "pacman" => boosters::run(
                    Command::new("pkexec").args([
                        "pacman",
                        "-S",
                        "--needed",
                        "--noconfirm",
                        "--",
                        &package,
                    ]),
                    900,
                )?,
                "flatpak" | "flatpak-system" => {
                    if !valid_name(&remote) {
                        return Err("Invalid Flatpak remote".into());
                    }
                    boosters::run(
                        Command::new("flatpak").args([
                            "install",
                            if manager == "flatpak" {
                                "--user"
                            } else {
                                "--system"
                            },
                            "--noninteractive",
                            "--",
                            &remote,
                            &package,
                        ]),
                        900,
                    )?
                }
                _ => return Err("Unsupported package manager".into()),
            };
            Ok(format!(
                "Installed {package}{}",
                if message.trim().is_empty() {
                    String::new()
                } else {
                    format!(
                        " · {}",
                        message
                            .lines()
                            .last()
                            .unwrap_or("")
                            .chars()
                            .take(160)
                            .collect::<String>()
                    )
                }
            ))
        }
        Operation::Service {
            system,
            action,
            unit,
        } => {
            if !valid_unit(&unit) || !matches!(action.as_str(), "start" | "restart" | "stop") {
                return Err("Invalid service action".into());
            }
            if system {
                boosters::run(
                    Command::new("pkexec").args(["systemctl", "--system", &action, "--", &unit]),
                    90,
                )?;
            } else {
                boosters::run(systemctl(false).args([&action, "--", &unit]), 90)?;
            }
            Ok(format!("Service action completed: {action} {unit}"))
        }
        Operation::Bluetooth { address, connect } => {
            if !valid_mac(&address) {
                return Err("Invalid Bluetooth device address".into());
            }
            boosters::run(
                Command::new("bluetoothctl").args([
                    "--timeout",
                    "15",
                    if connect { "connect" } else { "disconnect" },
                    &address,
                ]),
                18,
            )?;
            Ok(if connect {
                "Bluetooth device connected"
            } else {
                "Bluetooth device disconnected"
            }
            .into())
        }
        Operation::Window {
            mode,
            id,
            pid,
            started,
            ..
        } => {
            if mode == "kill" {
                let selected = crate::windowing::list()?
                    .into_iter()
                    .find(|w| w.id == id && w.pid == pid)
                    .ok_or("That window has closed or changed")?;
                let _ = selected;
                boosters::signal_process(pid, started, 9)?;
                Ok(format!("Sent SIGKILL to PID {pid}"))
            } else if matches!(mode.as_str(), "quit" | "close") {
                crate::windowing::close_window(&id, pid, mode == "quit")
            } else {
                Err("Invalid window action".into())
            }
        }
        _ => Err("This action must be opened in Spotlight".into()),
    }
}
#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn query_scopes_and_action_identity_validation() {
        assert_eq!(Query::parse("my ip"), Some(Query::Ip(true)));
        assert_eq!(Query::parse("ip local"), Some(Query::Ip(false)));
        assert!(matches!(Query::parse("generate qr hello"),Some(Query::Qr(s))if s=="hello"));
        assert!(
            matches!(Query::parse("pacman Ss firefox"),Some(Query::Packages{filter,..})if filter=="firefox")
        );
        assert!(
            matches!(Query::parse("service restart docker"),Some(Query::Services{system:false,action,..})if action=="restart")
        );
        assert!(matches!(
            Query::parse("systemctl restart docker"),
            Some(Query::Services { system: true, .. })
        ));
        assert!(matches!(
            Query::parse("systemctl --user stop demo"),
            Some(Query::Services { system: false, .. })
        ));
        assert!(
            matches!(Query::parse("bluetooth connect AirPods"),Some(Query::Bluetooth{filter,..})if filter=="AirPods")
        );
        assert!(
            matches!(Query::parse("kill window Firefox"),Some(Query::Windows{mode,..})if mode=="kill")
        );
        assert!(Query::parse("bluetooth").is_none());
        for bad in ["--help", "foo;touch /tmp/bad", "a\nb", "../file"] {
            assert!(!valid_name(bad));
        }
        assert!(valid_unit("demo@work.service"));
        assert!(!valid_unit("../demo.service"));
        assert!(!valid_unit("reboot.target"));
        assert!(valid_mac("AA:BB:CC:11:22:33"));
        assert!(!valid_mac("AA:BB:CC:11:22:zz"));
        assert!(!valid_tab_id("id/../../evil"));
        assert_eq!(package_pattern("frfx"), "f.*r.*f.*x");
        assert_eq!(package_pattern("a+b"), "a.*\\+.*b");
        assert!(
            Operation::Install {
                manager: "apt".into(),
                package: "demo".into(),
                remote: String::new()
            }
            .confirmation()
            .is_some()
        );
        assert!(
            Operation::Service {
                system: false,
                action: "restart".into(),
                unit: "demo.service".into()
            }
            .confirmation()
            .is_some()
        );
    }
    #[test]
    #[ignore = "requires isolated CLI and D-Bus fixtures; run tests/features_smoke.py"]
    fn fixture_backends() {
        let root = PathBuf::from(
            std::env::var_os("SPOTLIGHT_FEATURE_ROOT")
                .expect("Run through tests/features_smoke.py"),
        );
        assert!(
            root.file_name()
                .unwrap()
                .to_string_lossy()
                .starts_with("spotlight-features-")
        );
        assert!(core::data_dir().starts_with(&root));
        assert_eq!(
            std::env::split_paths(&std::env::var_os("PATH").unwrap())
                .next()
                .unwrap(),
            root.join("bin")
        );
        for tool in [
            "curl",
            "ip",
            "pactl",
            "wpctl",
            "apt-cache",
            "pacman",
            "flatpak",
            "pkexec",
            "systemctl",
            "bluetoothctl",
            "dolphin",
        ] {
            assert!(root.join("bin").join(tool).is_file());
        }
        let ips = fetch(&Query::Ip(true)).unwrap();
        assert!(ips.iter().any(|r| r.title == "203.0.113.20"));
        assert!(ips.iter().any(|r| r.title == "192.0.2.10"));
        for kind in ["ram", "disk", "battery", "uptime"] {
            assert!(!fetch(&Query::Stats(kind.into())).unwrap().is_empty());
        }
        let qr = fetch(&Query::Qr("Hello Spotlight café".into())).unwrap();
        let Some(Op::Advanced(Operation::Image { bytes, .. })) = &qr[0].operation else {
            panic!("QR image missing")
        };
        assert!(bytes.starts_with(b"\x89PNG\r\n\x1a\n"));
        fs::write(root.join("qr.png"), bytes).unwrap();
        if exists("zbarimg") {
            let decoded = boosters::run(
                Command::new("zbarimg")
                    .args(["--quiet", "--raw"])
                    .arg(root.join("qr.png")),
                5,
            )
            .unwrap();
            assert_eq!(decoded.trim(), "Hello Spotlight café");
        }
        let text = ocr_file(&root.join("ocr.png")).unwrap();
        assert!(
            text.contains("Spotlight") && text.contains("2026"),
            "{text}"
        );
        let tabs = fetch(&Query::Tabs("Rust".into())).unwrap();
        let Some(Op::Advanced(op)) = tabs[0].operation.clone() else {
            panic!("tab missing")
        };
        execute(op).unwrap();
        let outputs = speakers("Headphones").unwrap();
        let Some(Op::Advanced(op)) = outputs[0].operation.clone() else {
            panic!("sink missing")
        };
        execute(op).unwrap();
        fs::write(root.join("pactl-disabled"), "").unwrap();
        let outputs = speakers("Headphones").unwrap();
        let Some(Op::Advanced(op)) = outputs[0].operation.clone() else {
            panic!("wpctl sink missing")
        };
        execute(op.clone()).unwrap();
        fs::write(root.join("wpctl-changed"), "").unwrap();
        assert!(execute(op).is_err());
        fs::remove_file(root.join("pactl-disabled")).unwrap();
        for manager in ["apt", "pacman", "flatpak"] {
            let rows = packages(manager, "demo").unwrap();
            let Some(Op::Advanced(op)) = rows[0].operation.clone() else {
                panic!("package missing: {manager}: {rows:?}")
            };
            assert!(op.confirmation().is_some());
            execute(op).unwrap();
        }
        assert!(
            packages("flatpak", "dmo")
                .unwrap()
                .iter()
                .any(|r| r.title == "org.example.Demo")
        );
        let rows = services(false, "restart", "demo").unwrap();
        let Some(Op::Advanced(op)) = rows[0].operation.clone() else {
            panic!("service missing")
        };
        execute(op).unwrap();
        assert!(
            services(false, "status", "demo.service")
                .unwrap()
                .iter()
                .any(|r| matches!(r.operation, Some(Op::Preview { .. })))
        );
        let rows = bluetooth("connect", "AirPods").unwrap();
        let Some(Op::Advanced(op)) = rows[0].operation.clone() else {
            panic!("device missing")
        };
        execute(op).unwrap();
        let sample = root.join("file café # & demo.txt");
        let details = crate::fileactions::info(&sample).unwrap();
        assert!(details.contains("text/plain"));
        assert!(details.contains("Size:"));
        crate::fileactions::reveal(&sample).unwrap();
        let trash = root.join("trash-me.txt");
        fs::write(&trash, "disposable test file").unwrap();
        gio::File::for_path(&trash)
            .trash(None::<&gio::Cancellable>)
            .unwrap();
        assert!(!trash.exists());
        assert!(
            fs::read_dir(root.join("data/Trash/files"))
                .unwrap()
                .next()
                .is_some()
        );
        crate::clipboard::clear_history().unwrap();
        assert!(
            execute(Operation::Install {
                manager: "apt".into(),
                package: "--bad".into(),
                remote: "".into()
            })
            .is_err()
        );
        assert!(
            execute(Operation::Service {
                system: true,
                action: "restart".into(),
                unit: "reboot.target".into()
            })
            .is_err()
        );
        println!(
            "Feature backends passed: real QR decode and OCR, IP/stats, tabs, audio and stale IDs, packages, services, Bluetooth, file reveal/info/Trash, and Klipper API."
        );
    }
}

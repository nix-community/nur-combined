use crate::{
    boosters::{self, Entry, Operation as Op, entry, hint},
    core,
};
use std::{
    fs::{self, File, OpenOptions},
    io::{Read, Write},
    os::{
        fd::AsRawFd,
        unix::fs::{DirBuilderExt, MetadataExt, OpenOptionsExt, PermissionsExt},
    },
    path::{Path, PathBuf},
    process::{Command, ExitStatus, Stdio},
    sync::mpsc,
    time::{Duration, Instant},
};

#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum Vault {
    Rbw,
    KeePass,
}
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum FileTool {
    Encrypt,
    Decrypt,
    Checksum,
    Shred,
}
impl FileTool {
    pub fn title(self) -> &'static str {
        match self {
            Self::Encrypt => "Encrypt file",
            Self::Decrypt => "Decrypt file",
            Self::Checksum => "Checksum file · SHA-256",
            Self::Shred => "Shred file permanently",
        }
    }
}
#[derive(Clone, Debug, PartialEq, Eq, Hash)]
pub enum Network {
    Ping(String),
    Dns(String),
    Ports,
    Wifi,
    Routes,
}
#[derive(Clone, Debug, PartialEq, Eq, Hash)]
pub enum Query {
    Password(Option<Vault>, String),
    KeepassSetup,
    Network(Network),
    File(FileTool, String),
    Wallpaper(String),
    Accent(String),
}
#[derive(Clone, Debug)]
pub enum Operation {
    Password(Vault, String),
    KeepassSetup,
    File(FileTool, PathBuf),
    Pick(FileTool),
    Wallpaper(PathBuf),
    Accent(String),
}
pub enum Outcome {
    Secret(Secret),
    Text(String, String),
    File(PathBuf),
    Message(String),
    Wallpaper(PathBuf),
    Accent(String),
}
// Credentials never implement Debug or Serialize and are erased when released.
pub struct Secret(pub Vec<u8>);
impl AsRef<[u8]> for Secret {
    fn as_ref(&self) -> &[u8] {
        &self.0
    }
}
impl Drop for Secret {
    fn drop(&mut self) {
        for byte in &mut self.0 {
            unsafe {
                std::ptr::write_volatile(byte, 0);
            }
        }
    }
}
impl Query {
    pub fn parse(text: &str) -> Option<Self> {
        let text = text.trim();
        let lower = text.to_ascii_lowercase();
        if lower == "keepass setup" {
            return Some(Self::KeepassSetup);
        }
        if lower == "my ports" {
            return Some(Self::Network(Network::Ports));
        }
        if lower == "scan wifi" || lower == "scan wi-fi" {
            return Some(Self::Network(Network::Wifi));
        }
        if lower == "my routes" {
            return Some(Self::Network(Network::Routes));
        }
        let (head, tail) = text.split_once(char::is_whitespace).unwrap_or((text, ""));
        let tail = tail.trim();
        match head.to_ascii_lowercase().as_str() {
            "pass" | "password" => return Some(Self::Password(None, tail.into())),
            "rbw" => return Some(Self::Password(Some(Vault::Rbw), tail.into())),
            "keepass" | "keepassxc" => {
                return Some(Self::Password(Some(Vault::KeePass), tail.into()));
            }
            "ping" => return Some(Self::Network(Network::Ping(tail.into()))),
            "dig" => return Some(Self::Network(Network::Dns(tail.into()))),
            "wallpaper" => return Some(Self::Wallpaper(tail.into())),
            "accent" => return Some(Self::Accent(tail.into())),
            _ => {}
        }
        for (prefix, tool) in [
            ("encrypt file", FileTool::Encrypt),
            ("decrypt file", FileTool::Decrypt),
            ("checksum file", FileTool::Checksum),
            ("shred file", FileTool::Shred),
        ] {
            if lower == prefix || lower.starts_with(&format!("{prefix} ")) {
                return Some(Self::File(tool, text[prefix.len()..].trim().into()));
            }
        }
        None
    }
}
fn action(
    title: impl Into<String>,
    detail: impl Into<String>,
    badge: &'static str,
    op: Operation,
) -> Entry {
    entry(title, detail, badge, Op::System(op))
}
pub fn expand(text: &str) -> PathBuf {
    let text = text.trim().trim_matches('"').trim_matches('\'');
    let path = if let Some(tail) = text.strip_prefix("~/") {
        core::home().join(tail)
    } else {
        PathBuf::from(text)
    };
    if path.is_absolute() {
        path
    } else {
        core::home().join(path)
    }
}
pub fn fetch(query: &Query) -> Result<Vec<Entry>, String> {
    match query {
        Query::Password(backend, name) => {
            if name.is_empty() {
                return Ok(vec![hint(
                    "Copy a password",
                    "pass github · rbw name-or-UUID · keepass Group/Entry · keepass setup",
                )]);
            }
            validate_entry(name)?;
            let mut rows = Vec::new();
            if backend.is_none() || *backend == Some(Vault::Rbw) {
                rows.push(action(format!("Copy password · {name}"), "Bitwarden via rbw · local cached vault · unlock on Enter · clears clipboard after 30s", "Password", Operation::Password(Vault::Rbw, name.clone())));
            }
            if backend.is_none() || *backend == Some(Vault::KeePass) {
                rows.push(action(format!("Copy KeePassXC password · {name}"), "Exact entry path · master password requested on Enter · keepass setup chooses database", "Password", Operation::Password(Vault::KeePass, name.clone())));
            }
            if backend.is_none() && !available("rbw") && available("keepassxc-cli") {
                rows.reverse();
            }
            Ok(rows)
        }
        Query::KeepassSetup => Ok(vec![action(
            "Choose KeePassXC database",
            "Save database and optional key-file paths locally · master password is never saved",
            "Password",
            Operation::KeepassSetup,
        )]),
        Query::Network(network) => network_rows(network),
        Query::File(tool, path) => Ok(vec![action(
            tool.title(),
            match tool {
                FileTool::Shred => format!(
                    "{} · confirmation required · SSD/CoW erasure is not guaranteed",
                    if path.is_empty() {
                        "Choose a file"
                    } else {
                        path
                    }
                ),
                FileTool::Checksum => format!(
                    "{} · SHA-256 · original kept",
                    if path.is_empty() {
                        "Choose a file"
                    } else {
                        path
                    }
                ),
                _ => format!(
                    "{} · passphrase requested on Enter · original kept · existing outputs never replaced",
                    if path.is_empty() {
                        "Choose a file"
                    } else {
                        path
                    }
                ),
            },
            "File vault",
            if path.is_empty() {
                Operation::Pick(*tool)
            } else {
                Operation::File(*tool, expand(path))
            },
        )]),
        Query::Accent(value) => {
            let hex = accent(value)?;
            Ok(vec![action(
                format!("Set accent to {hex}"),
                "Apply KDE accent and Spotlight accent · keeps your other theme colors",
                "Appearance",
                Operation::Accent(hex),
            )])
        }
        Query::Wallpaper(value) => {
            if value.is_empty() {
                return Ok(vec![hint(
                    "Choose a local wallpaper",
                    "wallpaper next · wallpaper ~/Pictures/photo.jpg · cycles ~/Pictures/Wallpapers and installed wallpapers",
                )]);
            }
            if value.eq_ignore_ascii_case("next") {
                let store = core::Store::load()?;
                let paths = wallpapers();
                let path = next_wallpaper(&paths, store.last_wallpaper.as_deref())
                    .ok_or("No local wallpapers found · add images to ~/Pictures/Wallpapers")?;
                return Ok(vec![action(
                    "Next Wallpaper",
                    path.display().to_string(),
                    "Appearance",
                    Operation::Wallpaper(path),
                )]);
            }
            let path = expand(value);
            regular(&path)?;
            Ok(vec![action(
                "Set Wallpaper",
                path.display().to_string(),
                "Appearance",
                Operation::Wallpaper(path),
            )])
        }
    }
}
pub fn accent(value: &str) -> Result<String, String> {
    let hex = match value.to_ascii_lowercase().as_str() {
        "blue" => "#3DAEE9",
        "red" => "#ED5555",
        "green" => "#27AE60",
        "purple" => "#9B59B6",
        "orange" => "#F39C12",
        "pink" => "#E84393",
        "teal" => "#1ABC9C",
        _ => value,
    };
    crate::color::rgb(hex)
        .map_err(|_| "Use accent blue, red, green, purple, orange, pink, teal, or #RRGGBB")?;
    Ok(hex.to_ascii_uppercase())
}
fn validate_entry(name: &str) -> Result<(), String> {
    if name.is_empty() || name.len() > 512 || name.chars().any(char::is_control) {
        return Err("Use an entry name or UUID up to 512 bytes without control characters".into());
    }
    Ok(())
}
fn host(value: &str) -> Result<&str, String> {
    if value.is_empty()
        || value.len() > 253
        || value.starts_with('-')
        || value.starts_with('+')
        || !value
            .bytes()
            .all(|c| c.is_ascii_alphanumeric() || b".-:%_".contains(&c))
    {
        return Err(
            "Enter one hostname or IP address, without options · ping 8.8.8.8 or dig github.com"
                .into(),
        );
    }
    Ok(value)
}
fn network_rows(network: &Network) -> Result<Vec<Entry>, String> {
    let (title, mut command, timeout) = match network {
        Network::Ping(target) => {
            let mut c = Command::new("ping");
            c.args(["-n", "-c", "3", "-W", "1", "-w", "4", "--", host(target)?]);
            ("Ping", c, 6)
        }
        Network::Dns(target) => {
            let mut c = Command::new("dig");
            c.args(["+time=2", "+tries=1", host(target)?]);
            ("DNS lookup", c, 5)
        }
        Network::Ports => {
            let mut c = Command::new("ss");
            c.args(["-lntup"]);
            ("Listening ports", c, 4)
        }
        Network::Wifi => {
            let mut c = Command::new("nmcli");
            c.args([
                "--wait", "8", "--colors", "no", "device", "wifi", "list", "--rescan", "yes",
            ]);
            ("Nearby Wi-Fi", c, 10)
        }
        Network::Routes => {
            let mut c = Command::new("ip");
            c.args(["route", "show"]);
            ("Network routes", c, 4)
        }
    };
    command.env("LC_ALL", "C");
    let report = run(&mut command, timeout, None, None)?;
    let mut body = String::from_utf8_lossy(&report.out).to_string();
    if !report.status.success() {
        body.push_str(&format!(
            "\nCommand exited with {}\n{}",
            report.status,
            String::from_utf8_lossy(&report.err)
        ));
    }
    if body.trim().is_empty() {
        body = "No results returned".into();
    }
    let mut rows = vec![entry(
        title,
        "Enter previews the full report · copy any line below · Ctrl+R refreshes",
        "Network",
        Op::Preview {
            title: title.into(),
            text: body.clone(),
            open: None,
        },
    )];
    rows.extend(
        body.lines()
            .filter(|s| !s.trim().is_empty())
            .take(60)
            .map(|line| {
                entry(
                    line.chars().take(300).collect::<String>(),
                    "Enter copies this line",
                    "Copy",
                    Op::Copy(line.into()),
                )
            }),
    );
    Ok(rows)
}
struct Report {
    status: ExitStatus,
    out: Vec<u8>,
    err: Vec<u8>,
}
fn drain(mut pipe: impl Read + Send + 'static) -> mpsc::Receiver<Vec<u8>> {
    let (tx, rx) = mpsc::channel();
    std::thread::spawn(move || {
        let mut out = Vec::new();
        let mut bytes = [0; 4096];
        while let Ok(n) = pipe.read(&mut bytes) {
            if n == 0 {
                break;
            }
            let keep = n.min(1_048_576usize.saturating_sub(out.len()));
            out.extend_from_slice(&bytes[..keep]);
        }
        let _ = tx.send(out);
    });
    rx
}
fn run(
    command: &mut Command,
    seconds: u64,
    input: Option<Secret>,
    file: Option<File>,
) -> Result<Report, String> {
    let name = command.get_program().to_string_lossy().to_string();
    command.stdin(if let Some(file) = file {
        Stdio::from(file)
    } else if input.is_some() {
        Stdio::piped()
    } else {
        Stdio::null()
    });
    let mut child = command
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .map_err(|_| format!("Could not run {name} · install the tool and check PATH"))?;
    if let Some(input) = input {
        let mut pipe = child.stdin.take().unwrap();
        std::thread::spawn(move || {
            let _ = pipe.write_all(&input.0);
        });
    }
    let out = drain(child.stdout.take().unwrap());
    let err = drain(child.stderr.take().unwrap());
    let deadline = Instant::now() + Duration::from_secs(seconds);
    let status = loop {
        match child.try_wait() {
            Ok(Some(status)) => break status,
            Ok(None) if Instant::now() < deadline => std::thread::sleep(Duration::from_millis(25)),
            _ => {
                let _ = child.kill();
                let _ = child.wait();
                return Err(format!("{name} timed out or was interrupted"));
            }
        }
    };
    Ok(Report {
        status,
        out: out.recv_timeout(Duration::from_secs(1)).unwrap_or_default(),
        err: err.recv_timeout(Duration::from_secs(1)).unwrap_or_default(),
    })
}
pub fn password(
    backend: Vault,
    entry: &str,
    database: Option<&Path>,
    key_file: Option<&Path>,
    master: Option<Secret>,
) -> Result<Outcome, String> {
    validate_entry(entry)?;
    let mut command = match backend {
        Vault::Rbw => {
            let mut c = Command::new("rbw");
            c.args(["get", "--field", "password", "--", entry]);
            c
        }
        Vault::KeePass => {
            let db = database.ok_or("Choose a database with keepass setup first")?;
            regular(db)?;
            let mut c = Command::new("keepassxc-cli");
            c.args(["show", "--quiet", "--attributes", "Password"]);
            if let Some(key) = key_file {
                regular(key)?;
                c.arg("--key-file").arg(key);
            }
            c.arg("--").arg(db).arg(entry);
            c
        }
    };
    // Never surface vault stderr: a backend may include secret data in an error.
    let report = run(&mut command, 90, master, None).map_err(|_| {
        "Password lookup failed · check the installed CLI and unlock your vault".to_string()
    })?;
    if !report.status.success() {
        return Err("Password lookup failed · check the entry name or UUID, vault unlock, and database/key file".into());
    }
    let mut bytes = report.out;
    if bytes.ends_with(b"\n") {
        bytes.pop();
        if bytes.ends_with(b"\r") {
            bytes.pop();
        }
    }
    if bytes.is_empty() || bytes.len() > 65536 || std::str::from_utf8(&bytes).is_err() {
        return Err("The selected entry has no supported text password".into());
    }
    Ok(Outcome::Secret(Secret(bytes)))
}
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Identity {
    dev: u64,
    ino: u64,
    bytes: u64,
    modified: (i64, i64),
    links: u64,
}
fn identity(meta: &fs::Metadata) -> Identity {
    Identity {
        dev: meta.dev(),
        ino: meta.ino(),
        bytes: meta.len(),
        modified: (meta.mtime(), meta.mtime_nsec()),
        links: meta.nlink(),
    }
}
pub fn regular(path: &Path) -> Result<Identity, String> {
    let meta = fs::symlink_metadata(path).map_err(|e| format!("Could not read file: {e}"))?;
    if !meta.is_file() {
        return Err(
            "Choose a regular local file · folders, symbolic links and devices are excluded".into(),
        );
    }
    Ok(identity(&meta))
}
fn open_regular(path: &Path, write: bool) -> Result<File, String> {
    let file = OpenOptions::new()
        .read(true)
        .write(write)
        .custom_flags(libc::O_NOFOLLOW | libc::O_NONBLOCK)
        .open(path)
        .map_err(|e| e.to_string())?;
    if !file.metadata().is_ok_and(|m| m.is_file()) {
        return Err("Choose a regular file".into());
    }
    Ok(file)
}
pub fn shred(path: &Path, expected: &Identity) -> Result<Outcome, String> {
    let file = open_regular(path, true)?;
    let actual = identity(&file.metadata().map_err(|e| e.to_string())?);
    if &actual != expected {
        return Err("File changed since confirmation · select it again".into());
    }
    if actual.links != 1 {
        return Err("Refusing to shred a file with multiple hard links".into());
    }
    // The child overwrites the already-open file, so replacing the path cannot redirect it.
    let report = run(
        Command::new("shred").args(["--iterations=3", "--zero", "--", "/proc/self/fd/0"]),
        120,
        None,
        Some(file),
    )?;
    if !report.status.success() {
        return Err("Shredding failed · the file may be partially overwritten".into());
    }
    let now = regular(path)?;
    if now.dev != expected.dev || now.ino != expected.ino {
        return Err("File was overwritten but its path changed · the replacement was kept".into());
    }
    fs::remove_file(path).map_err(|e| format!("File overwritten but could not be removed: {e}"))?;
    Ok(Outcome::Message(
        "File overwritten and removed · snapshots, backups and SSD copies may remain".into(),
    ))
}
struct Work(PathBuf);
impl Drop for Work {
    fn drop(&mut self) {
        let _ = fs::remove_dir_all(&self.0);
    }
}
pub fn transform(
    tool: FileTool,
    path: &Path,
    passphrase: Option<Secret>,
) -> Result<Outcome, String> {
    regular(path)?;
    if tool == FileTool::Checksum {
        let report = run(
            Command::new("sha256sum").arg("--").arg("/proc/self/fd/0"),
            120,
            None,
            Some(open_regular(path, false)?),
        )?;
        if !report.status.success() {
            return Err("Could not checksum this file".into());
        }
        let hash = String::from_utf8_lossy(&report.out)
            .split_whitespace()
            .next()
            .unwrap_or("")
            .to_string();
        if hash.len() != 64 || !hash.bytes().all(|b| b.is_ascii_hexdigit()) {
            return Err("Invalid SHA-256 result".into());
        }
        return Ok(Outcome::Text(
            "SHA-256 checksum".into(),
            format!("{hash}\n\n{}", path.display()),
        ));
    }
    if !matches!(tool, FileTool::Encrypt | FileTool::Decrypt) {
        return Err("Shredding requires confirmation".into());
    }
    let secret = passphrase.ok_or("Enter a passphrase")?;
    if secret.0.len() < 2
        || !secret.0.ends_with(b"\n")
        || secret.0[..secret.0.len() - 1].contains(&b'\n')
    {
        return Err("Use a nonempty passphrase without line breaks".into());
    }
    let mut name = path.file_name().ok_or("File has no name")?.to_os_string();
    if tool == FileTool::Encrypt {
        name.push(".gpg");
    } else if path.extension().is_some_and(|s| s == "gpg" || s == "pgp") {
        name = path.file_stem().ok_or("Invalid filename")?.into();
    } else {
        name.push(".decrypted");
    }
    let output = path.with_file_name(name);
    if output.exists() || fs::symlink_metadata(&output).is_ok() {
        return Err("Output already exists · move it before running this action".into());
    }
    let folder = path.with_file_name(format!(
        ".spotlight-crypto-{}",
        gtk::glib::uuid_string_random()
    ));
    fs::DirBuilder::new()
        .mode(0o700)
        .create(&folder)
        .map_err(|e| e.to_string())?;
    let work = Work(folder);
    let temporary = work.0.join("output");
    let source = open_regular(path, false)?;
    let fd = source.as_raw_fd();
    let mut command = Command::new("gpg");
    command
        .args([
            "--batch",
            "--no-tty",
            "--no-symkey-cache",
            "--pinentry-mode",
            "loopback",
            "--passphrase-fd",
            "0",
            "--output",
        ])
        .arg(&temporary);
    if tool == FileTool::Encrypt {
        command.args(["--symmetric", "--cipher-algo", "AES256"]);
    } else {
        command.arg("--decrypt");
    }
    // Refer to the parent's open descriptor without making it inheritable.
    command
        .arg("--")
        .arg(format!("/proc/{}/fd/{fd}", std::process::id()));
    let report = run(&mut command, 120, Some(secret), None)?;
    drop(source);
    if !report.status.success() {
        return Err(
            "GPG failed · check the passphrase, input file, and GnuPG setup · original kept".into(),
        );
    }
    fs::set_permissions(&temporary, fs::Permissions::from_mode(0o600))
        .map_err(|e| e.to_string())?;
    File::open(&temporary)
        .and_then(|f| f.sync_all())
        .map_err(|e| e.to_string())?;
    // Linking publishes only a completed result and never replaces an existing destination.
    fs::hard_link(&temporary, &output)
        .map_err(|e| format!("Could not save output without replacing an existing file: {e}"))?;
    Ok(Outcome::File(output))
}
pub fn wallpapers() -> Vec<PathBuf> {
    fn collect(root: &Path, depth: usize, result: &mut Vec<PathBuf>) {
        if depth > 5 || result.len() >= 500 {
            return;
        }
        if let Ok(entries) = fs::read_dir(root) {
            for entry in entries.flatten().take(2000) {
                let path = entry.path();
                let Ok(kind) = entry.file_type() else {
                    continue;
                };
                if kind.is_symlink() {
                    continue;
                }
                if kind.is_dir() {
                    collect(&path, depth + 1, result);
                } else if kind.is_file() && crate::search::image_path(&path) {
                    result.push(path);
                }
                if result.len() >= 500 {
                    break;
                }
            }
        }
    }
    let mut roots = vec![
        core::home().join("Pictures/Wallpapers"),
        core::home().join(".local/share/wallpapers"),
    ];
    if let Some(dirs) = std::env::var_os("XDG_DATA_DIRS") {
        roots.extend(std::env::split_paths(&dirs).map(|p| p.join("wallpapers")));
    } else {
        roots.push("/usr/share/wallpapers".into());
    }
    let mut paths = Vec::new();
    for root in roots {
        collect(&root, 0, &mut paths);
    }
    paths.sort();
    paths.dedup();
    paths
}
pub fn next_wallpaper(paths: &[PathBuf], current: Option<&Path>) -> Option<PathBuf> {
    if paths.is_empty() {
        return None;
    }
    let index = current
        .and_then(|p| paths.iter().position(|v| v == p))
        .map_or(0, |n| (n + 1) % paths.len());
    Some(paths[index].clone())
}
pub fn appearance(op: Operation) -> Result<Outcome, String> {
    match op {
        Operation::Wallpaper(path) => {
            regular(&path)?;
            boosters::run(Command::new("plasma-apply-wallpaperimage").arg(&path), 15)?;
            Ok(Outcome::Wallpaper(path))
        }
        Operation::Accent(hex) => {
            let hex = accent(&hex)?;
            boosters::run(
                Command::new("plasma-apply-colorscheme").args(["--accent-color", &hex]),
                10,
            )?;
            Ok(Outcome::Accent(hex))
        }
        _ => Err("Unsupported appearance action".into()),
    }
}

fn available(name: &str) -> bool {
    std::env::var_os("PATH").is_some_and(|paths| {
        std::env::split_paths(&paths).any(|root| {
            fs::metadata(root.join(name))
                .is_ok_and(|m| m.is_file() && m.permissions().mode() & 0o111 != 0)
        })
    })
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn query_boundaries_and_argument_validation() {
        assert_eq!(
            Query::parse("PASS GitHub personal"),
            Some(Query::Password(None, "GitHub personal".into()))
        );
        assert_eq!(
            Query::parse("checksum file \"~/my file\""),
            Some(Query::File(FileTool::Checksum, "\"~/my file\"".into()))
        );
        for text in [
            "passwordless",
            "encrypt filename",
            "my ports extra",
            "scan wifi extra",
            "accentuate",
            "wallpapers",
        ] {
            assert!(Query::parse(text).is_none(), "{text}");
        }
        for bad in [
            "-c",
            "+trace",
            "github.com @evil",
            "github.com;touch",
            "a\nb",
            "",
            "$(id)",
        ] {
            assert!(host(bad).is_err(), "{bad}");
        }
        for good in ["github.com", "8.8.8.8", "::1", "fe80::1%wlan0"] {
            assert_eq!(host(good).unwrap(), good);
        }
        assert_eq!(accent("blue").unwrap(), "#3DAEE9");
        assert_eq!(accent("#abcdef").unwrap(), "#ABCDEF");
        for bad in ["red;quit", "blue --list-schemes", "#12345g", ""] {
            assert!(accent(bad).is_err());
        }
        assert!(validate_entry("bad\nentry").is_err());
        assert_eq!(next_wallpaper(&[], None), None);
        let paths = vec![PathBuf::from("one"), PathBuf::from("two")];
        assert_eq!(
            next_wallpaper(&paths, Some(Path::new("two"))),
            Some(paths[0].clone())
        );
        assert_eq!(
            next_wallpaper(&paths, Some(Path::new("missing"))),
            Some(paths[0].clone())
        );
    }
    #[test]
    fn file_actions_reject_links_devices_and_stale_confirmation() {
        let root = std::env::temp_dir().join(format!(
            "spotlight-file-vault-{}",
            gtk::glib::uuid_string_random()
        ));
        fs::create_dir(&root).unwrap();
        let file = root.join("original.txt");
        fs::write(&file, "original").unwrap();
        let link = root.join("link");
        std::os::unix::fs::symlink(&file, &link).unwrap();
        assert!(regular(&link).is_err());
        assert!(regular(&root).is_err());
        assert!(regular(Path::new("/dev/null")).is_err());
        let old = regular(&file).unwrap();
        fs::write(&file, "changed content").unwrap();
        assert!(shred(&file, &old).is_err());
        assert_eq!(fs::read_to_string(&file).unwrap(), "changed content");
        fs::hard_link(&file, root.join("hardlink")).unwrap();
        assert!(shred(&file, &regular(&file).unwrap()).is_err());
        assert!(transform(FileTool::Shred, &file, None).is_err());
        assert!(transform(FileTool::Encrypt, &file, Some(Secret(b"\n".to_vec()))).is_err());
        fs::write(root.join("original.txt.gpg"), "existing").unwrap();
        assert!(
            transform(
                FileTool::Encrypt,
                &file,
                Some(Secret(b"passphrase\n".to_vec()))
            )
            .is_err()
        );
        assert_eq!(
            fs::read_to_string(root.join("original.txt.gpg")).unwrap(),
            "existing"
        );
        fs::remove_dir_all(root).unwrap();
    }
    #[test]
    #[ignore = "requires isolated CLI, vault, and GPG fixtures; run tests/systemtools_smoke.py"]
    fn fixture_backends() {
        let root = PathBuf::from(std::env::var_os("SPOTLIGHT_SYSTEMTOOLS_FIXTURE").unwrap());
        for query in [
            Network::Ping("8.8.8.8".into()),
            Network::Dns("github.com".into()),
            Network::Ports,
            Network::Wifi,
            Network::Routes,
        ] {
            let rows = network_rows(&query).unwrap();
            assert!(rows.len() >= 2);
            assert!(
                matches!(&rows[0].operation, Some(Op::Preview { text, .. }) if !text.is_empty())
            );
        }
        let rows = network_rows(&Network::Ping("unreachable.test".into())).unwrap();
        assert!(
            matches!(&rows[0].operation, Some(Op::Preview { text, .. }) if text.contains("100% packet loss"))
        );
        for target in ["-c 99", "github.com;touch", "+trace"] {
            assert!(network_rows(&Network::Dns(target.into())).is_err());
        }
        let Outcome::Secret(secret) =
            password(Vault::Rbw, "GitHub $(literal)", None, None, None).unwrap()
        else {
            panic!("Expected secret")
        };
        assert_eq!(secret.0, b"fixture-only-secret");
        assert!(
            !password(Vault::Rbw, "ambiguous", None, None, None)
                .err()
                .unwrap()
                .contains("SECRET_ERROR_MARKER")
        );
        let db = root.join("database.kdbx");
        let key = root.join("database.key");
        let Outcome::Secret(secret) = password(
            Vault::KeePass,
            "Group/GitHub",
            Some(&db),
            Some(&key),
            Some(Secret(b"master-fixture\n".to_vec())),
        )
        .unwrap() else {
            panic!("Expected secret")
        };
        assert_eq!(secret.0, b"keepass-fixture-secret");
        let source = root.join("sample café.txt");
        fs::write(&source, b"abc").unwrap();
        let Outcome::Text(_, hash) = transform(FileTool::Checksum, &source, None).unwrap() else {
            panic!("Expected hash")
        };
        assert!(
            hash.starts_with("ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad")
        );
        let Outcome::File(encrypted) = transform(
            FileTool::Encrypt,
            &source,
            Some(Secret(b"test encryption password\n".to_vec())),
        )
        .unwrap() else {
            panic!("Expected encrypted file")
        };
        assert_eq!(fs::read(&source).unwrap(), b"abc");
        assert_ne!(fs::read(&encrypted).unwrap(), b"abc");
        assert_eq!(
            fs::metadata(&encrypted).unwrap().permissions().mode() & 0o777,
            0o600
        );
        fs::rename(&source, root.join("original-copy.txt")).unwrap();
        assert!(
            transform(
                FileTool::Decrypt,
                &encrypted,
                Some(Secret(b"wrong password\n".to_vec()))
            )
            .is_err()
        );
        assert!(!source.exists());
        let Outcome::File(decrypted) = transform(
            FileTool::Decrypt,
            &encrypted,
            Some(Secret(b"test encryption password\n".to_vec())),
        )
        .unwrap() else {
            panic!("Expected decrypted file")
        };
        assert_eq!(decrypted, source);
        assert_eq!(fs::read(&decrypted).unwrap(), b"abc");
        assert!(encrypted.exists());
        assert!(!fs::read_dir(&root).unwrap().flatten().any(|e| {
            e.file_name()
                .to_string_lossy()
                .starts_with(".spotlight-crypto-")
        }));
        let disposable = root.join("shred-only-fixture.txt");
        fs::write(&disposable, "destroy this fixture only").unwrap();
        shred(&disposable, &regular(&disposable).unwrap()).unwrap();
        assert!(!disposable.exists());
        appearance(Operation::Wallpaper(root.join("wallpaper.png"))).unwrap();
        appearance(Operation::Accent("blue".into())).unwrap();
        let rows = fetch(&Query::Wallpaper("next".into())).unwrap();
        assert_eq!(rows[0].title, "Next Wallpaper");
    }
}

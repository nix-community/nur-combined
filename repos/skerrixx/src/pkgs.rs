use std::io::Write;
use std::os::unix::fs::{DirBuilderExt, OpenOptionsExt};
use std::path::{Path, PathBuf};
use std::process::Command;
use std::thread;
use std::time::{Duration, SystemTime};

use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
struct PackageCache {
    debian: Option<usize>,
    arch: Option<usize>,
    redhat: Option<usize>,
    void: Option<usize>,
    gentoo: Option<usize>,
    alpine: Option<usize>,
    flatpak: Option<usize>,
    suse: Option<usize>,
    netbsd: Option<usize>,
    termux: Option<usize>,
    timestamp: SystemTime,
}

#[derive(Serialize, Deserialize)]
struct GpuCache {
    gpu: String,
    timestamp: SystemTime,
}

fn count_packages(cmd: &str, args: &[&str]) -> Option<usize> {
    let out = Command::new(cmd).args(args).output().ok()?;
    if !out.status.success() {
        return None;
    }
    let count = String::from_utf8_lossy(&out.stdout)
        .lines()
        .filter(|line| !is_header_line(cmd, line))
        .count();
    if count > 0 { Some(count) } else { None }
}

// Blank lines never count. Additionally, dnf and zypper print banner/column
// rows before their package lists; those are dropped per manager. Managers
// with clean output (pacman, apk, dpkg, ...) are untouched.
fn is_header_line(cmd: &str, line: &str) -> bool {
    let trimmed = line.trim();
    if trimmed.is_empty() {
        return true;
    }
    match cmd {
        "dnf" => is_dnf_header(trimmed),
        "zypper" => is_zypper_header(trimmed),
        _ => false,
    }
}

fn is_dnf_header(line: &str) -> bool {
    line.eq_ignore_ascii_case("Installed Packages") || {
        let mut words = line.split_whitespace();
        matches!(
            (words.next(), words.next()),
            (Some("Name"), Some("Version"))
        )
    }
}

fn is_zypper_header(line: &str) -> bool {
    line.starts_with("Loading repository data")
        || line.starts_with("Reading installed packages")
        || (line.starts_with("S ") && line.contains("Name"))
        || line.starts_with("--+")
        || line.starts_with("---+")
}

fn binary_exists(cmd: &str) -> bool {
    if cmd.contains('/') {
        return std::fs::exists(cmd).unwrap_or(false);
    }
    let path = match std::env::var("PATH") {
        Ok(p) if !p.trim().is_empty() => p,
        _ => return true, // PATH unknown: fall back to trying the spawn (old behavior)
    };
    for dir in path.split(':') {
        if dir.is_empty() {
            continue;
        }
        if std::fs::exists(format!("{}/{}", dir, cmd)).unwrap_or(false) {
            return true;
        }
    }
    false
}

fn count_if_present(cmd: &str, args: &[&str]) -> Option<usize> {
    // skip the fork/exec entirely for managers that aren't installed.
    // output-identical: a missing binary fails the spawn and yields None anyway.
    if !binary_exists(cmd) {
        return None;
    }
    count_packages(cmd, args)
}

// Per-user, private cache directory so counts never leak across accounts and
// the paths are not guessable by other users. Created 0700; files are written
// 0600 with O_NOFOLLOW so a planted symlink can never be followed. Any failure
// degrades to "no cache" rather than panicking.
fn cache_dir() -> Option<PathBuf> {
    let xdg = std::env::var("XDG_CACHE_HOME").ok();
    let home = std::env::var("HOME").ok();
    // SAFETY: getuid(2) has no preconditions and cannot fail.
    let uid = unsafe { libc::getuid() };
    let dir = resolve_cache_base(xdg.as_deref(), home.as_deref(), uid).join("rfetch");
    if std::fs::DirBuilder::new()
        .recursive(true)
        .mode(0o700)
        .create(&dir)
        .is_err()
    {
        return None;
    }
    match std::fs::symlink_metadata(&dir) {
        Ok(meta) if meta.file_type().is_symlink() => None,
        Ok(_) => Some(dir),
        Err(_) => None,
    }
}

fn resolve_cache_base(xdg: Option<&str>, home: Option<&str>, uid: u32) -> PathBuf {
    match xdg.map(str::trim).filter(|v| !v.is_empty()) {
        Some(xdg) => PathBuf::from(xdg),
        None => match home.map(str::trim).filter(|v| !v.is_empty()) {
            Some(home) => PathBuf::from(home).join(".cache"),
            None => PathBuf::from(format!("/tmp/rfetch-{uid}")),
        },
    }
}

fn cache_path() -> Option<PathBuf> {
    cache_dir().map(|dir| dir.join("rfetch_packages.json"))
}

fn write_cache_file(path: &Path, data: &str) {
    let mut options = std::fs::OpenOptions::new();
    options.create(true).write(true).truncate(true).mode(0o600);
    options.custom_flags(libc::O_NOFOLLOW);
    let _ = options
        .open(path)
        .and_then(|mut file| file.write_all(data.as_bytes()));
}

fn read_fresh_cache() -> Option<PackageCache> {
    let data = std::fs::read_to_string(cache_path()?).ok()?;
    let cache: PackageCache = serde_json::from_str(&data).ok()?;
    if cache.timestamp.elapsed().unwrap_or_default() < Duration::from_secs(3600) {
        Some(cache)
    } else {
        None
    }
}

fn gpu_cache_path() -> Option<PathBuf> {
    cache_dir().map(|dir| dir.join("rfetch_gpu.json"))
}

pub fn cached_gpu() -> Option<String> {
    // gpu string lives in its own cache file so it stays warm even when
    // "packages" is hidden. previously both shared one file written only by
    // getform(), so hiding packages starved this fast path: cached_gpu()
    // missed forever and every run paid a full drm probe (~20ms).
    let data = std::fs::read_to_string(gpu_cache_path()?).ok()?;
    let cache: GpuCache = serde_json::from_str(&data).ok()?;
    if cache.timestamp.elapsed().unwrap_or_default() < Duration::from_secs(3600) {
        Some(cache.gpu)
    } else {
        None
    }
}

pub fn fetch_gpu() -> String {
    if let Some(g) = cached_gpu() {
        return g;
    }
    let g = crate::basic::gpu();
    let cache = GpuCache {
        gpu: g.clone(),
        timestamp: SystemTime::now(),
    };
    if let (Some(path), Ok(json)) = (gpu_cache_path(), serde_json::to_string(&cache)) {
        write_cache_file(&path, &json);
    }
    g
}

fn get_installed_packages_parallel() -> String {
    if let Some(cache) = read_fresh_cache() {
        return format_package_string(&cache);
    }

    let debian = thread::spawn(|| count_if_present("dpkg", &["--get-selections"]));
    let arch = thread::spawn(|| count_if_present("pacman", &["-Q"]));
    let redhat = thread::spawn(|| count_if_present("dnf", &["list", "--installed"]));
    let alpine = thread::spawn(|| count_if_present("apk", &["info"]));
    let void = thread::spawn(|| count_if_present("xbps-query", &["-l"]));
    let flatpak = thread::spawn(|| count_if_present("flatpak", &["list"]));
    let gentoo = thread::spawn(|| count_if_present("qlist", &["-Iv"]));
    let suse = thread::spawn(|| count_if_present("zypper", &["se", "-i"]));
    let netbsd = thread::spawn(|| count_if_present("pkg_info", &["-q"]));
    let termux = thread::spawn(|| count_if_present("dpkg-query", &["-f", "${Status}\n", "--show"]));

    let cache = PackageCache {
        debian: debian.join().unwrap_or(None),
        arch: arch.join().unwrap_or(None),
        redhat: redhat.join().unwrap_or(None),
        void: void.join().unwrap_or(None),
        gentoo: gentoo.join().unwrap_or(None),
        alpine: alpine.join().unwrap_or(None),
        flatpak: flatpak.join().unwrap_or(None),
        suse: suse.join().unwrap_or(None),
        netbsd: netbsd.join().unwrap_or(None),
        termux: termux.join().unwrap_or(None),
        timestamp: SystemTime::now(),
    };

    if let (Some(path), Ok(json)) = (cache_path(), serde_json::to_string(&cache)) {
        write_cache_file(&path, &json);
    }

    format_package_string(&cache)
}

fn format_package_string(cache: &PackageCache) -> String {
    let mut parts = Vec::new();

    if let Some(count) = cache.debian {
        parts.push(format!("{} (deb  )", count));
    }
    if let Some(count) = cache.arch {
        parts.push(format!("{} (arch 󰣇 )", count));
    }
    if let Some(count) = cache.redhat {
        parts.push(format!("{} (dnf  )", count));
    }
    if let Some(count) = cache.void {
        parts.push(format!("{} (void  )", count));
    }
    if let Some(count) = cache.gentoo {
        parts.push(format!("{} (gent 󰣨 )", count));
    }
    if let Some(count) = cache.alpine {
        parts.push(format!("{} (alpine  )", count));
    }
    if let Some(count) = cache.flatpak {
        parts.push(format!("{} (flatpak 󰏖 )", count));
    }
    if let Some(count) = cache.suse {
        parts.push(format!("{} (suse  )", count));
    }
    if let Some(count) = cache.netbsd {
        parts.push(format!("{} (netbsd \u{f0240} )", count));
    }
    if let Some(count) = cache.termux {
        parts.push(format!("{} (termux  )", count));
    }

    if parts.is_empty() {
        "none found".to_string()
    } else {
        parts.join(", ")
    }
}

pub fn clear_cache() {
    if let Some(path) = cache_path() {
        let _ = std::fs::remove_file(path);
    }
    if let Some(path) = gpu_cache_path() {
        let _ = std::fs::remove_file(path);
    }
}

pub fn getform() -> String {
    get_installed_packages_parallel()
}

#[cfg(test)]
mod tests {
    use super::*;

    fn empty_cache() -> PackageCache {
        PackageCache {
            debian: None,
            arch: None,
            redhat: None,
            void: None,
            gentoo: None,
            alpine: None,
            flatpak: None,
            suse: None,
            netbsd: None,
            termux: None,
            timestamp: SystemTime::UNIX_EPOCH,
        }
    }

    #[test]
    fn format_package_string_is_none_found_when_everything_is_empty() {
        assert_eq!(format_package_string(&empty_cache()), "none found");
    }

    #[test]
    fn format_package_string_includes_every_populated_manager() {
        let cache = PackageCache {
            debian: Some(1),
            arch: Some(2),
            redhat: Some(3),
            void: Some(4),
            gentoo: Some(5),
            alpine: Some(6),
            flatpak: Some(7),
            suse: Some(8),
            netbsd: Some(9),
            termux: Some(10),
            timestamp: SystemTime::UNIX_EPOCH,
        };
        let out = format_package_string(&cache);
        assert!(out.contains("1 (deb"));
        assert!(out.contains("2 (arch"));
        assert!(out.contains("3 (dnf"));
        assert!(out.contains("4 (void"));
        assert!(out.contains("5 (gent"));
        assert!(out.contains("6 (alpine"));
        assert!(out.contains("7 (flatpak"));
        assert!(out.contains("8 (suse"));
        assert!(out.contains("9 (netbsd"));
        assert!(out.contains("10 (termux"));
        assert_eq!(out.matches(", ").count(), 9);
    }

    #[test]
    fn format_package_string_shows_netbsd_when_populated() {
        let cache = PackageCache {
            netbsd: Some(42),
            ..empty_cache()
        };
        assert!(format_package_string(&cache).contains("42 (netbsd"));
    }

    #[test]
    fn resolve_cache_base_prefers_xdg() {
        assert_eq!(
            resolve_cache_base(Some("/x"), Some("/h"), 1000),
            PathBuf::from("/x")
        );
    }

    #[test]
    fn resolve_cache_base_falls_back_to_home_dot_cache() {
        assert_eq!(
            resolve_cache_base(None, Some("/h"), 1000),
            PathBuf::from("/h/.cache")
        );
    }

    #[test]
    fn resolve_cache_base_falls_back_to_uid_tmpdir_and_ignores_blank_values() {
        assert_eq!(
            resolve_cache_base(None, None, 1000),
            PathBuf::from("/tmp/rfetch-1000")
        );
        assert_eq!(
            resolve_cache_base(Some("  "), Some("  "), 7),
            PathBuf::from("/tmp/rfetch-7")
        );
    }

    #[test]
    fn dnf_headers_are_filtered() {
        assert!(is_dnf_header("Installed Packages"));
        assert!(is_dnf_header("installed packages"));
        assert!(is_dnf_header("Name    Version    Repository"));
        assert!(!is_dnf_header(
            "NetworkManager.x86_64  1:1.46.0-2.fc40  @System"
        ));
    }

    #[test]
    fn zypper_headers_are_filtered() {
        assert!(is_zypper_header("Loading repository data..."));
        assert!(is_zypper_header("Reading installed packages..."));
        assert!(is_zypper_header("S | Name | Summary | Type"));
        assert!(is_zypper_header("---+------+---------+-----"));
        assert!(!is_zypper_header("i | Mesa | 3-D graphics | package"));
    }

    #[test]
    fn header_filtering_keeps_clean_managers_untouched() {
        assert!(!is_header_line("pacman", "linux 6.10.1-arch1-1"));
        assert!(!is_header_line("dpkg", "vim\tinstall"));
        assert!(!is_header_line(
            "dnf",
            "vim-enhanced.x86_64  2:9.1.719-1.fc40  @updates"
        ));
        assert!(!is_header_line(
            "zypper",
            "i+ | vim | Vi IMproved | package"
        ));
        assert!(is_header_line("pacman", ""));
        assert!(is_header_line("pacman", "   "));
    }
}

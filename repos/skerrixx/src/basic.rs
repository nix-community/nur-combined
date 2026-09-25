use crate::internals::identity;
use std::collections::HashSet;
use std::env;
use std::path::Path;
use std::process::Command;

#[path = "logos/mod.rs"]
mod logos;

pub use logos::{display_name_for, get_ascii_art, get_logo_color, known_distros};

pub fn is_termux() -> bool {
    if env::var("TERMUX_VERSION").is_ok() {
        return true;
    }
    if let Ok(prefix) = env::var("PREFIX") {
        if prefix.contains("com.termux") {
            return true;
        }
    }
    std::fs::exists("/data/data/com.termux").unwrap_or(false)
}

/// value of `key` in an os-release style `KEY=VALUE` file, quotes stripped.
///
/// values may be unquoted (`ID=arch`), double-quoted (`ID="arch"`) or
/// single-quoted (`ID='gentoo'`, as Gentoo ships it), per the os-release spec.
fn extract_value(content: &str, key: &str) -> Option<String> {
    let prefix = format!("{}=", key);
    for raw_line in content.lines() {
        let line = raw_line.trim();
        if line.is_empty() || line.starts_with('#') {
            continue;
        }
        if let Some(rest) = line.strip_prefix(&prefix) {
            let v = rest.trim();
            if v.len() >= 2 {
                let b = v.as_bytes();
                if (b[0] == b'"' && b[b.len() - 1] == b'"')
                    || (b[0] == b'\'' && b[b.len() - 1] == b'\'')
                {
                    return Some(v[1..v.len() - 1].to_string());
                }
            }
            // unquoted or unbalanced: strip any stray surrounding quotes
            // (preserves the old double-quote-stripping behavior).
            return Some(v.trim_matches(|c| c == '"' || c == '\'').to_string());
        }
    }
    None
}

fn os_id_or_name() -> String {
    if is_termux() {
        return String::from("android");
    }
    if std::fs::exists("/bedrock/strata/bedrock/etc/os-release").unwrap_or(false) {
        let content = match std::fs::read_to_string("/bedrock/strata/bedrock/etc/os-release") {
            Ok(c) => c,
            Err(_) => return String::from(""),
        };
        return extract_value(&content, "ID")
            .or_else(|| extract_value(&content, "NAME"))
            .unwrap_or_default();
    }
    if std::fs::exists("/etc/os-release").unwrap_or(false) {
        let content = match std::fs::read_to_string("/etc/os-release") {
            Ok(c) => c,
            Err(_) => return String::from(""),
        };
        return extract_value(&content, "ID")
            .or_else(|| extract_value(&content, "NAME"))
            .unwrap_or_default();
    }
    Command::new("uname")
        .arg("s")
        .output()
        .ok()
        .and_then(|out| String::from_utf8(out.stdout).ok())
        .map(|s| s.trim().to_lowercase())
        .unwrap_or_default()
}

/// hot-path replacement for `sysinfo::System`.
///
/// constructing and refreshing a `System` costs ~0.4ms because sysinfo keeps
/// its own bookkeeping and parses far more of /proc than rfetch reads. we only
/// need the cpu brand plus four memory numbers, so parse /proc directly. the
/// derived values are identical to sysinfo's (verified: total = MemTotal,
/// used = MemTotal - MemAvailable, swap = SwapTotal - SwapFree).
pub struct SystemInfo {
    cpu_brand: String,
    mem_total_kb: u64,
    mem_available_kb: u64,
    swap_total_kb: u64,
    swap_free_kb: u64,
}

impl SystemInfo {
    pub fn new() -> Self {
        let (mem_total_kb, mem_available_kb, swap_total_kb, swap_free_kb) =
            read_meminfo().unwrap_or((0, 0, 0, 0));
        Self {
            cpu_brand: read_cpu_brand(),
            mem_total_kb,
            mem_available_kb,
            swap_total_kb,
            swap_free_kb,
        }
    }
}

impl Default for SystemInfo {
    fn default() -> Self {
        Self::new()
    }
}

fn read_meminfo() -> Option<(u64, u64, u64, u64)> {
    let content = std::fs::read_to_string("/proc/meminfo").ok()?;
    let (mut total, mut available, mut free, mut buffers, mut cached) =
        (0u64, 0u64, 0u64, 0u64, 0u64);
    let (mut swap_total, mut swap_free) = (0u64, 0u64);
    for line in content.lines() {
        let Some((key, rest)) = line.split_once(':') else {
            continue;
        };
        let Some(value) = rest
            .split_whitespace()
            .next()
            .and_then(|v| v.parse::<u64>().ok())
        else {
            continue;
        };
        match key {
            "MemTotal" => total = value,
            "MemAvailable" => available = value,
            "MemFree" => free = value,
            "Buffers" => buffers = value,
            "Cached" => cached = value,
            "SwapTotal" => swap_total = value,
            "SwapFree" => swap_free = value,
            _ => {}
        }
    }
    if available == 0 {
        available = free + buffers + cached;
    }
    Some((total, available, swap_total, swap_free))
}

fn read_cpu_brand() -> String {
    let Ok(content) = std::fs::read_to_string("/proc/cpuinfo") else {
        return String::new();
    };
    for line in content.lines() {
        let Some((key, value)) = line.split_once(':') else {
            continue;
        };
        let value = value.trim();
        if value.is_empty() {
            continue;
        }
        match key.trim() {
            "model name" | "Processor" | "cpu model" | "Hardware" => return value.to_string(),
            _ => {}
        }
    }
    String::new()
}

pub fn cpu(info: &SystemInfo) -> String {
    info.cpu_brand.clone()
}

pub fn raw_os_id_or_name() -> String {
    os_id_or_name()
}

pub fn os() -> String {
    logos::display_name_for(&os_id_or_name()).to_string()
}

/// rounded percentage from raw byte counts (0 when total is 0), never from
/// the rounded gib display values.
fn usage_pct(used_bytes: u64, total_bytes: u64) -> u32 {
    if total_bytes == 0 {
        return 0;
    }
    (used_bytes as f64 * 100.0 / total_bytes as f64).round() as u32
}

pub fn ram_info(info: &SystemInfo) -> (String, String, String) {
    let used_bytes = info.mem_total_kb.saturating_sub(info.mem_available_kb) * 1024;
    let total_bytes = info.mem_total_kb * 1024;
    let used_gb = ((used_bytes as f64 / 1024.0 / 1024.0 / 1024.0) * 10.0).ceil() / 10.0;
    let total_gb = ((total_bytes as f64 / 1024.0 / 1024.0 / 1024.0) * 10.0).ceil() / 10.0;
    let pct = usage_pct(used_bytes, total_bytes);
    (used_gb.to_string(), total_gb.to_string(), pct.to_string())
}

pub struct DiskInfo {
    pub name: String,
    pub filesystem: String,
    pub used_gb: f64,
    pub total_gb: f64,
    pub usage_pct: f64,
}

const EXCLUDED_FS: &[&str] = &[
    "tmpfs",
    "devtmpfs",
    "squashfs",
    "overlay",
    "proc",
    "sysfs",
    "cgroup",
    "cgroup2",
    "devpts",
    "hugetlbfs",
    "mqueue",
    "pstore",
    "securityfs",
    "efivarfs",
    "bpf",
    "tracefs",
    "debugfs",
    "configfs",
    "fusectl",
    "autofs",
    "ramfs",
    "nsfs",
    "rpc_pipefs",
    "binfmt_misc",
    "nfsd",
    "selinuxfs",
];

/// `statvfs` reports the same block accounting `df` uses (`f_bfree`, not the
/// user-visible `f_bavail`), so used/total come out identical to `df -B1`.
fn statvfs_sizes(path: &str) -> Option<(u64, u64)> {
    use std::ffi::{CString, OsStr};
    use std::os::unix::ffi::OsStrExt;
    let c = CString::new(OsStr::new(path).as_bytes()).ok()?;
    let mut st: libc::statvfs = unsafe { std::mem::zeroed() };
    if unsafe { libc::statvfs(c.as_ptr(), &mut st) } != 0 {
        return None;
    }
    let frsize = if st.f_frsize != 0 {
        st.f_frsize
    } else {
        st.f_bsize
    } as u64;
    let total = (st.f_blocks as u64).checked_mul(frsize)?;
    let free = (st.f_bfree as u64).checked_mul(frsize)?;
    Some((total, total.checked_sub(free)?))
}

pub fn disks_info() -> Vec<DiskInfo> {
    let gb = 1024.0 * 1024.0 * 1024.0;
    let mut result = Vec::new();

    // read the mount table directly and statvfs each real filesystem. this is
    // what `df` does, minus the ~0.9ms process spawn, and yields the same numbers.
    if let Ok(mounts) = std::fs::read_to_string("/proc/mounts") {
        let mut seen = HashSet::new();
        for line in mounts.lines() {
            let mut parts = line.split_whitespace();
            let source = match parts.next() {
                Some(v) => v,
                None => continue,
            };
            let target = match parts.next() {
                Some(v) => v,
                None => continue,
            };
            let fstype = match parts.next() {
                Some(v) => v,
                None => continue,
            };

            // real filesystems only: block devices, network mounts (host:/export)
            // and zfs datasets (pool/dataset). a source that is a plain directory
            // (bind mount) would just duplicate the stats of its origin mount.
            let real_source = source.starts_with("/dev/")
                || source.contains(':')
                || (!source.is_empty() && !source.starts_with('/'));
            if !real_source {
                continue;
            }
            if fstype.starts_with("fuse.") || fstype == "fuse" || EXCLUDED_FS.contains(&fstype) {
                continue;
            }

            let (total_bytes, used_bytes) = match statvfs_sizes(target) {
                Some(v) => v,
                None => continue,
            };
            if total_bytes == 0 {
                continue;
            }

            let name = source.strip_prefix("/dev/").unwrap_or(source).to_string();
            if !seen.insert(name.clone()) {
                continue;
            }

            let total_gb = total_bytes as f64 / gb;
            let used_gb = used_bytes as f64 / gb;
            let pct = (used_bytes as f64 / total_bytes as f64) * 100.0;

            result.push(DiskInfo {
                name,
                filesystem: fstype.to_string(),
                used_gb: (used_gb * 10.0).round() / 10.0,
                total_gb: (total_gb * 10.0).round() / 10.0,
                usage_pct: (pct * 10.0).round() / 10.0,
            });
        }

        if !result.is_empty() {
            return result;
        }
    }

    result
}

pub fn wmde() -> String {
    let unp_de = match env::var("XDG_CURRENT_DESKTOP") {
        Ok(v) if !v.trim().is_empty() => v,
        _ => return String::from("unknown"),
    };
    match unp_de.to_lowercase().as_str() {
        "gnome" => String::from(" gnome"),
        "kde" | "plasma" => String::from(" kde"),
        "niri" => String::from(" niri"),
        "hyprland" => String::from(" hypr"),
        "xfce" => String::from(" xfce"),
        "sway" => String::from(" sway"),
        "i3" => String::from(" i3"),
        "mango" | "mangowm" => String::from("󱁆 mango"),
        "cinnamon" | "x-cinnamon" => String::from(" cinnamon"),
        _ => format!(" {}", unp_de.to_lowercase()),
    }
}
pub fn kernel() -> String {
    if is_termux() {
        if let Ok(ver) = std::fs::read_to_string("/proc/version") {
            let version = ver.split_whitespace().nth(2).unwrap_or("unknown");
            return format!("󰌽 linux {}", version);
        }
    }
    std::fs::read_to_string("/proc/sys/kernel/osrelease")
        .map(|s| format!("󰌽 linux {}", s.trim()))
        .unwrap_or_else(|_| {
            Command::new("uname")
                .arg("-sr")
                .output()
                .ok()
                .filter(|out| out.status.success())
                .map(|out| String::from_utf8_lossy(&out.stdout).trim().to_string())
                .filter(|s| !s.is_empty())
                .unwrap_or_else(|| "unknown".to_string())
        })
}
pub fn shell() -> String {
    let mut sh_unp = String::from("");
    if let Ok(shell_path) = std::env::var("SHELL") {
        if let Some(name) = Path::new(&shell_path).file_name() {
            sh_unp = name.to_string_lossy().to_string();
        }
    };

    if let Ok(passwd) = std::fs::read_to_string("/etc/passwd") {
        let username = std::env::var("USER").unwrap_or_default();
        // an unset USER would make the prefix ":" below match the wrong entry
        if !username.is_empty() {
            for line in passwd.lines() {
                if line.starts_with(&format!("{}:", username)) {
                    if let Some(shell) = line.split(':').next_back() {
                        sh_unp = Path::new(shell)
                            .file_name()
                            .map(|s| s.to_string_lossy().to_string())
                            .unwrap_or_else(|| "unknown".to_string());
                    }
                }
            }
        }
    };
    if sh_unp.trim().is_empty() {
        sh_unp = String::from("unknown");
    };
    match sh_unp.as_str() {
        "fish" => " fish".to_string(),
        "bash" => " bash".to_string(),
        "zsh" => " zsh".to_string(),
        "sh" => " sh".to_string(),
        _ => " unknown".to_string(),
    }
}

/// terminal display name from the env. TERM_PROGRAM names the emulator itself
/// (e.g. "iTerm.app") while TERM is only a terminfo id (e.g. "xterm-256color"),
/// so TERM is consulted only when TERM_PROGRAM is unset/empty.
fn terminal_name(term_program: Option<&str>, term: Option<&str>) -> Option<String> {
    let raw = term_program
        .map(str::trim)
        .filter(|s| !s.is_empty())
        .or_else(|| term.map(str::trim).filter(|s| !s.is_empty()))?;
    Some(match raw.to_lowercase().as_str() {
        "alacritty" => "󱐋 alacritty".to_string(),
        "xterm-kitty" => " kitty".to_string(),
        "tabby" => " tabby".to_string(),
        "foot" => " foot".to_string(),
        "xterm-256color" => " DE terminal".to_string(),
        "xterm-ghostty" => "󰊠 ghostty".to_string(),
        _ => format!(" {}", raw.to_lowercase()),
    })
}

pub fn terminal() -> String {
    terminal_name(
        std::env::var("TERM_PROGRAM").ok().as_deref(),
        std::env::var("TERM").ok().as_deref(),
    )
    .unwrap_or_default()
}
pub fn gpu() -> String {
    if let Some(name) = gpu_from_sysfs() {
        return name;
    }

    if is_termux() {
        if let Ok(soc) = std::fs::read_to_string("/sys/devices/soc0/soc_id") {
            let id = soc.trim().to_string();
            return format!("SoC (id: {})", id);
        }
        if let Ok(hw) = std::fs::read_to_string("/sys/devices/soc0/machine") {
            return hw.trim().to_string();
        }
    }

    "none found, maybe integrated".to_string()
}

fn read_hex(path: &str) -> Option<u32> {
    let s = std::fs::read_to_string(path).ok()?;
    let s = s.trim();
    let s = s
        .strip_prefix("0x")
        .or_else(|| s.strip_prefix("0X"))
        .unwrap_or(s);
    u32::from_str_radix(s, 16).ok()
}

// the marketing name comes from the same amdgpu.ids table libdrm used, keyed by
// pci (device, revision) id, so we get the exact same string without linking
// libdrm (which every process otherwise had to load at startup).
fn amdgpu_name(device_id: u32, revision_id: u32) -> Option<String> {
    let ids = std::fs::read_to_string("/usr/share/libdrm/amdgpu.ids").ok()?;
    for line in ids.lines() {
        let line = line.trim();
        if line.is_empty() || line.starts_with('#') {
            continue;
        }
        let mut fields = line.split(',');
        let (did, rid) = match (fields.next(), fields.next()) {
            (Some(d), Some(r)) => (d.trim(), r.trim()),
            _ => continue,
        };
        let name = fields.collect::<Vec<_>>().join(",");
        let name = name.trim();
        if name.is_empty() {
            continue;
        }
        if let (Ok(d), Ok(r)) = (u32::from_str_radix(did, 16), u32::from_str_radix(rid, 16)) {
            if d == device_id && r == revision_id {
                return Some(name.to_string());
            }
        }
    }
    None
}

fn nvidia_name() -> Option<String> {
    for e in std::fs::read_dir("/proc/driver/nvidia/gpus")
        .ok()?
        .flatten()
    {
        let info = match std::fs::read_to_string(e.path().join("information")) {
            Ok(i) => i,
            Err(_) => continue,
        };
        for line in info.lines() {
            if let Some(rest) = line.strip_prefix("Model:") {
                let name = rest.trim();
                if !name.is_empty() {
                    return Some(name.to_string());
                }
            }
        }
    }
    None
}

// mirrors gfxinfo's order (amd then nvidia) and the names it produced, but
// straight from sysfs/proc so there is nothing to dlopen or ioctl.
fn gpu_from_sysfs() -> Option<String> {
    let mut amd = None;
    let mut nvidia = None;
    for e in std::fs::read_dir("/sys/class/drm").ok()?.flatten() {
        let name = e.file_name();
        let name = name.to_string_lossy();
        let rest = match name.strip_prefix("card") {
            Some(r) => r,
            None => continue,
        };
        // only "cardN" nodes, skip connectors like card0-DP-1
        if rest.is_empty() || !rest.bytes().all(|b| b.is_ascii_digit()) {
            continue;
        }
        let dev = format!("/sys/class/drm/{}/device", name);
        match read_hex(&format!("{}/vendor", dev)) {
            Some(0x1002) if amd.is_none() => {
                if let (Some(did), Some(rid)) = (
                    read_hex(&format!("{}/device", dev)),
                    read_hex(&format!("{}/revision", dev)),
                ) {
                    // fall back to libdrm's default when the id table misses
                    amd = amdgpu_name(did, rid).or_else(|| Some("AMD Radeon Graphics".to_string()));
                }
            }
            Some(0x10de) if nvidia.is_none() => {
                nvidia = nvidia_name();
            }
            _ => {}
        }
    }
    amd.or(nvidia)
}

pub fn hostusr() -> String {
    format!("{} ( {} )", identity::username(), identity::hostname())
}

pub fn uptime() -> String {
    std::fs::read_to_string("/proc/uptime")
        .ok()
        .and_then(|content| {
            let secs: f64 = content.split_whitespace().next()?.parse().ok()?;
            let total_secs = secs as u64;
            let days = total_secs / 86400;
            let hours = (total_secs % 86400) / 3600;
            let mins = (total_secs % 3600) / 60;
            let mut parts = Vec::new();
            if days > 0 {
                parts.push(format!("{} day{}", days, if days == 1 { "" } else { "s" }));
            }
            if hours > 0 {
                parts.push(format!(
                    "{} hour{}",
                    hours,
                    if hours == 1 { "" } else { "s" }
                ));
            }
            if mins > 0 || parts.is_empty() {
                parts.push(format!(
                    "{} minute{}",
                    mins,
                    if mins == 1 { "" } else { "s" }
                ));
            }
            Some(parts.join(", "))
        })
        .unwrap_or_else(|| {
            Command::new("uptime")
                .arg("-p")
                .output()
                .ok()
                .filter(|out| out.status.success())
                .map(|out| String::from_utf8_lossy(&out.stdout).trim().to_string())
                .filter(|s| !s.is_empty())
                .unwrap_or_else(|| "unknown".to_string())
                .replace("up ", "")
        })
}

/// reads charge from sysfs directly. `starship_battery::Manager` costs ~0.9ms
/// (walks the whole power_supply class, builds typed units) but ends up reading
/// these same `capacity` nodes, so the value is identical.
fn read_battery_percent() -> Option<usize> {
    if let Ok(cap) = std::fs::read_to_string("/sys/class/power_supply/battery/capacity") {
        if let Ok(pct) = cap.trim().parse::<usize>() {
            return Some(pct);
        }
    }
    let entries = std::fs::read_dir("/sys/class/power_supply").ok()?;
    for e in entries.flatten() {
        let dir = e.path();
        let ty = match std::fs::read_to_string(dir.join("type")) {
            Ok(t) => t,
            Err(_) => continue,
        };
        if ty.trim() != "Battery" {
            continue;
        }
        if let Ok(cap) = std::fs::read_to_string(dir.join("capacity")) {
            if let Ok(pct) = cap.trim().parse::<usize>() {
                return Some(pct);
            }
        }
    }
    None
}

pub fn get_battery_charge() -> usize {
    if let Some(pct) = read_battery_percent() {
        return pct;
    }

    // sysfs is the only source rfetch reads, so an empty scan means no battery
    // (or a manager that hides it). report the "no battery" sentinel instead of
    // spawning a dbus probe.
    500
}

// --- os age (time since install) ---

use std::time::{SystemTime, UNIX_EPOCH};

fn birth_time_of(path: &str) -> Option<SystemTime> {
    std::fs::metadata(path).ok()?.created().ok()
}

fn modified_time_of(path: &str) -> Option<SystemTime> {
    std::fs::metadata(path).ok()?.modified().ok()
}

fn stat_birth_fallback(path: &str) -> Option<SystemTime> {
    // `stat -c %W` prints birth as unix secs, 0 if unknown.
    let out = Command::new("stat")
        .arg("-c")
        .arg("%W")
        .arg(path)
        .output()
        .ok()?;
    if !out.status.success() {
        return None;
    }
    let s = String::from_utf8_lossy(&out.stdout).trim().to_string();
    let secs: u64 = s.parse().ok()?;
    if secs == 0 {
        return None;
    }
    UNIX_EPOCH.checked_add(std::time::Duration::from_secs(secs))
}

/// try to parse the first timestamp in /var/log/pacman.log (arch btw).
/// lines look like: [2026-09-07T20:47:00+0200] [PACMAN] Running ...
fn pacman_log_install_time() -> Option<SystemTime> {
    let content = std::fs::read_to_string("/var/log/pacman.log").ok()?;
    for line in content.lines() {
        let line = line.trim();
        if !line.starts_with('[') || line.len() < 11 {
            continue;
        }
        // extract YYYY-MM-DD inside brackets; a malformed line only skips
        // itself, it must not discard a valid timestamp on a later line
        let end = match line.find(']') {
            Some(e) => e,
            None => continue,
        };
        let inner = &line[1..end];
        // inner is like 2026-09-07T20:47:00+0200, take date part
        let date_part = match inner.get(0..10) {
            Some(p) => p,
            None => continue,
        };
        let mut parts = date_part.split('-');
        let y: i32 = match parts.next().and_then(|p| p.parse().ok()) {
            Some(v) => v,
            None => continue,
        };
        let m: u32 = match parts.next().and_then(|p| p.parse().ok()) {
            Some(v) => v,
            None => continue,
        };
        let d: u32 = match parts.next().and_then(|p| p.parse().ok()) {
            Some(v) => v,
            None => continue,
        };
        if !(1..=12).contains(&m) || !(1..=31).contains(&d) {
            continue;
        }
        let days = days_from_civil(y, m, d);
        let secs = days * 86400;
        if secs < 0 {
            continue;
        }
        return UNIX_EPOCH.checked_add(std::time::Duration::from_secs(secs as u64));
    }
    None
}

fn days_from_civil(y: i32, m: u32, d: u32) -> i64 {
    // Howard Hinnant's days_from_civil, days since 1970-01-01
    let y = if m <= 2 { y - 1 } else { y } as i64;
    let m = m as i64;
    let d = d as i64;
    let era = if y >= 0 { y } else { y - 399 } / 400;
    let yoe = y - era * 400;
    let doy = (153 * (m + if m > 2 { -3 } else { 9 }) + 2) / 5 + d - 1;
    let doe = yoe * 365 + yoe / 4 - yoe / 100 + doy;
    era * 146097 + doe - 719468
}

fn civil_from_days(z: i64) -> (i32, u32, u32) {
    // Howard Hinnant's civil_from_days, inverse of above
    let z = z + 719468;
    let era = if z >= 0 { z } else { z - 146096 } / 146097;
    let doe = z - era * 146097;
    let yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365;
    let mut y = yoe + era * 400;
    let doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
    let mp = (5 * doy + 2) / 153;
    let d = doy - (153 * mp + 2) / 5 + 1;
    let m = if mp < 10 { mp + 3 } else { mp - 9 };
    if m <= 2 {
        y += 1;
    }
    (y as i32, m as u32, d as u32)
}

fn format_install_date(t: SystemTime) -> Option<String> {
    let secs = t.duration_since(UNIX_EPOCH).ok()?.as_secs() as i64;
    let days = secs.div_euclid(86400);
    let (y, m, d) = civil_from_days(days);
    Some(format!("{:04}-{:02}-{:02}", y, m, d))
}

fn format_age_duration(secs: u64) -> String {
    // boundaries: <1 min "just now"; minutes below an hour; hours below a day;
    // days below 30; then months (30-day) and years (365-day) with remainder.
    let days = secs / 86400;
    if days == 0 {
        let hours = secs / 3600;
        if hours == 0 {
            let mins = secs / 60;
            if mins < 1 {
                return "just now".to_string();
            }
            if mins == 1 {
                return "1 minute".to_string();
            }
            return format!("{} minutes", mins);
        }
        if hours == 1 {
            return "1 hour".to_string();
        }
        return format!("{} hours", hours);
    }
    if days == 1 {
        return "1 day".to_string();
    }
    if days < 30 {
        return format!("{} days", days);
    }
    if days < 365 {
        let months = days / 30;
        let rem = days % 30;
        let m_word = if months == 1 { "month" } else { "months" };
        if rem == 0 {
            return format!("{} {}", months, m_word);
        }
        let d_word = if rem == 1 { "day" } else { "days" };
        return format!("{} {} {} {}", months, m_word, rem, d_word);
    }
    let years = days / 365;
    let rem = days % 365;
    let months = rem / 30;
    let d = rem % 30;
    let y_word = if years == 1 { "year" } else { "years" };
    let mut s = format!("{} {}", years, y_word);
    if months > 0 {
        s.push_str(&format!(
            " {} {}",
            months,
            if months == 1 { "month" } else { "months" }
        ));
    }
    if d > 0 {
        s.push_str(&format!(" {} {}", d, if d == 1 { "day" } else { "days" }));
    }
    s
}

pub fn os_install_time() -> Option<SystemTime> {
    let mut candidates: Vec<SystemTime> = Vec::new();

    // 1. birth time of / (filesystem creation ~= install). best generic signal.
    if let Some(t) = birth_time_of("/").or_else(|| stat_birth_fallback("/")) {
        candidates.push(t);
    }
    // 2. birth of machine-id files (generated at install)
    for p in ["/etc/machine-id", "/var/lib/dbus/machine-id"] {
        if let Some(t) = birth_time_of(p).or_else(|| stat_birth_fallback(p)) {
            candidates.push(t);
        }
    }
    // 3. birth of pacman log (arch)
    if let Some(t) = birth_time_of("/var/log/pacman.log") {
        candidates.push(t);
    }

    if !candidates.is_empty() {
        // oldest = most likely the install
        candidates.sort();
        return candidates.into_iter().next();
    }

    // 4. fallbacks when btime is unsupported (some fs/kernels return 0/err):
    // mtime of write-once-at-install files
    for p in [
        "/etc/machine-id",
        "/var/lib/dbus/machine-id",
        "/root/anaconda-ks.cfg",
        "/var/log/installer/syslog",
        "/etc/arch-release",
    ] {
        if let Some(t) = modified_time_of(p) {
            candidates.push(t);
        }
    }
    // 5. parse pacman log content (arch btw^2)
    if let Some(t) = pacman_log_install_time() {
        candidates.push(t);
    }

    if candidates.is_empty() {
        return None;
    }
    candidates.sort();
    candidates.into_iter().next()
}

pub fn os_age() -> String {
    let install = match os_install_time() {
        Some(t) => t,
        None => return "unknown".to_string(),
    };
    let now = SystemTime::now();
    let dur = match now.duration_since(install) {
        Ok(d) => d,
        Err(_) => return "unknown".to_string(),
    };
    let age = format_age_duration(dur.as_secs());
    match format_install_date(install) {
        Some(date) => format!("{} (installed {})", age, date),
        None => age,
    }
}

// --- promoted-to-stable hardware gaps: swap / load / processes / boot ---

pub fn swap_info(info: &SystemInfo) -> (String, String, String) {
    let used_bytes = info.swap_total_kb.saturating_sub(info.swap_free_kb) * 1024;
    let total_bytes = info.swap_total_kb * 1024;
    let used_gb = ((used_bytes as f64 / 1024.0 / 1024.0 / 1024.0) * 10.0).ceil() / 10.0;
    let total_gb = ((total_bytes as f64 / 1024.0 / 1024.0 / 1024.0) * 10.0).ceil() / 10.0;
    let pct = usage_pct(used_bytes, total_bytes);
    (used_gb.to_string(), total_gb.to_string(), pct.to_string())
}

pub fn load_avg() -> String {
    if let Ok(content) = std::fs::read_to_string("/proc/loadavg") {
        let mut parts = content.split_whitespace();
        if let (Some(one), Some(five), Some(fifteen)) = (parts.next(), parts.next(), parts.next()) {
            return format!("{}, {}, {}", one, five, fifteen);
        }
    }
    "unknown".to_string()
}

pub fn process_count() -> Option<usize> {
    // counting /proc numeric dirs = processes (threads excluded, unlike loadavg total).
    // getdents64 directly so we skip the OsString read_dir allocates per entry,
    // which is one heap allocation for every pid on every run.
    if let Some(n) = count_proc_pids() {
        if n > 0 {
            return Some(n);
        }
    }
    // fallback: total from /proc/loadavg 4th field ("3/786" -> 786, threads included)
    if let Ok(content) = std::fs::read_to_string("/proc/loadavg") {
        let fourth = content.split_whitespace().nth(3).unwrap_or("");
        if let Some(total) = fourth.split('/').nth(1) {
            if let Ok(v) = total.parse::<usize>() {
                return Some(v);
            }
        }
    }
    None
}

fn count_proc_pids() -> Option<usize> {
    use std::os::unix::io::AsRawFd;
    let dir = std::fs::File::open("/proc").ok()?;
    let fd = dir.as_raw_fd();
    let mut buf = [0u8; 16384];
    let mut n = 0usize;
    loop {
        let nread = unsafe {
            libc::syscall(
                libc::SYS_getdents64,
                fd,
                buf.as_mut_ptr() as *mut libc::c_void,
                buf.len(),
            )
        };
        if nread <= 0 {
            break;
        }
        let end = nread as usize;
        let mut off = 0usize;
        while off + 19 <= end {
            let d = unsafe { &*(buf.as_ptr().add(off) as *const libc::dirent64) };
            let reclen = d.d_reclen as usize;
            if reclen == 0 || off + reclen > end {
                break;
            }
            let name = d.d_name.as_ptr() as *const u8;
            let mut is_pid = false;
            let mut i = 0usize;
            loop {
                let c = unsafe { *name.add(i) };
                if c == 0 {
                    break;
                }
                if !c.is_ascii_digit() {
                    is_pid = false;
                    break;
                }
                is_pid = true;
                i += 1;
                if i >= 256 {
                    is_pid = false;
                    break;
                }
            }
            if is_pid {
                n += 1;
            }
            off += reclen;
        }
    }
    Some(n)
}

fn read_btime() -> Option<u64> {
    let content = std::fs::read_to_string("/proc/stat").ok()?;
    content
        .lines()
        .find_map(|l| l.strip_prefix("btime "))
        .and_then(|v| v.trim().parse().ok())
}

/// formats an epoch timestamp in local time via `localtime_r` so we match what
/// `uptime -s` printed, without paying for a process spawn (~1ms).
fn format_local(ts: u64) -> Option<String> {
    let t = ts as libc::time_t;
    let mut tm: libc::tm = unsafe { std::mem::zeroed() };
    if unsafe { libc::localtime_r(&t, &mut tm) }.is_null() {
        return None;
    }
    Some(format!(
        "{:04}-{:02}-{:02} {:02}:{:02}:{:02}",
        tm.tm_year + 1900,
        tm.tm_mon + 1,
        tm.tm_mday,
        tm.tm_hour,
        tm.tm_min,
        tm.tm_sec
    ))
}

pub fn boot_time() -> String {
    if let Some(ts) = read_btime() {
        if let Some(s) = format_local(ts) {
            return s;
        }
    }
    "unknown".to_string()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn days_from_civil_known_dates() {
        assert_eq!(days_from_civil(1970, 1, 1), 0);
        assert_eq!(days_from_civil(1970, 1, 2), 1);
        assert_eq!(days_from_civil(1969, 12, 31), -1);
        assert_eq!(days_from_civil(2000, 1, 1), 10957);
        assert_eq!(days_from_civil(2026, 9, 7), 20703);
    }

    #[test]
    fn civil_from_days_known_dates() {
        assert_eq!(civil_from_days(0), (1970, 1, 1));
        assert_eq!(civil_from_days(-1), (1969, 12, 31));
        assert_eq!(civil_from_days(10957), (2000, 1, 1));
    }

    #[test]
    fn civil_days_roundtrip() {
        for days in -100_000..=100_000i64 {
            let (y, m, d) = civil_from_days(days);
            assert_eq!(
                days_from_civil(y, m, d),
                days,
                "roundtrip failed for {days}"
            );
        }
    }

    #[test]
    fn format_age_duration_boundaries() {
        assert_eq!(format_age_duration(0), "just now");
        assert_eq!(format_age_duration(59), "just now");
        assert_eq!(format_age_duration(60), "1 minute");
        assert_eq!(format_age_duration(119), "1 minute");
        assert_eq!(format_age_duration(3540), "59 minutes");
        assert_eq!(format_age_duration(3600), "1 hour");
        assert_eq!(format_age_duration(7200), "2 hours");
        assert_eq!(format_age_duration(86_399), "23 hours");
        assert_eq!(format_age_duration(86_400), "1 day");
        assert_eq!(format_age_duration(2 * 86_400), "2 days");
        assert_eq!(format_age_duration(29 * 86_400), "29 days");
        assert_eq!(format_age_duration(30 * 86_400), "1 month");
        assert_eq!(format_age_duration(61 * 86_400), "2 months 1 day");
        assert_eq!(format_age_duration(365 * 86_400), "1 year");
        assert_eq!(format_age_duration(395 * 86_400), "1 year 1 month");
    }

    #[test]
    fn extract_value_reads_key_values() {
        let content = "ID=\"arch\"\nPRETTY_NAME=\"Arch Linux\"\nID_LIKE=arch\n";
        assert_eq!(extract_value(content, "ID").as_deref(), Some("arch"));
        assert_eq!(
            extract_value(content, "PRETTY_NAME").as_deref(),
            Some("Arch Linux")
        );
        assert_eq!(extract_value(content, "ID_LIKE").as_deref(), Some("arch"));
        assert_eq!(extract_value(content, "NAME"), None);
    }

    #[test]
    fn extract_value_strips_single_quotes_gentoo_style() {
        // Gentoo ships ID='gentoo' with single quotes; both must resolve bare.
        let content = "NAME='Gentoo'\nID='gentoo'\nPRETTY_NAME='Gentoo Linux'\n";
        assert_eq!(extract_value(content, "ID").as_deref(), Some("gentoo"));
        assert_eq!(extract_value(content, "NAME").as_deref(), Some("Gentoo"));
        assert_eq!(
            extract_value(content, "PRETTY_NAME").as_deref(),
            Some("Gentoo Linux")
        );
        // unquoted still works
        assert_eq!(
            extract_value("ID=arch\n", "ID").as_deref(),
            Some("arch")
        );
    }

    #[test]
    fn terminal_prefers_term_program() {
        assert_eq!(
            terminal_name(Some("iTerm.app"), Some("xterm-256color")).as_deref(),
            Some("\u{f120} iterm.app")
        );
        assert_eq!(
            terminal_name(None, Some("xterm-256color")).as_deref(),
            Some("\u{f489} DE terminal")
        );
        assert_eq!(
            terminal_name(Some(""), Some("xterm-kitty")).as_deref(),
            Some("\u{eeed} kitty")
        );
        assert_eq!(terminal_name(None, None), None);
        assert_eq!(
            terminal_name(Some("  "), Some("foot")).as_deref(),
            Some("\u{f361} foot")
        );
    }

    #[test]
    fn usage_pct_computed_from_raw_bytes() {
        assert_eq!(usage_pct(0, 0), 0);
        assert_eq!(usage_pct(50, 100), 50);
        assert_eq!(usage_pct(1, 3), 33);
        let gib = 1024u64 * 1024 * 1024;
        assert_eq!(usage_pct(gib + 1, 2 * gib), 50);
    }

    #[test]
    fn ram_info_percent_uses_raw_bytes_not_rounded_display() {
        let gib_kb = 1024u64 * 1024;
        let info = SystemInfo {
            cpu_brand: String::new(),
            mem_total_kb: 2 * gib_kb,
            mem_available_kb: gib_kb - 1,
            swap_total_kb: 0,
            swap_free_kb: 0,
        };
        let (used, total, pct) = ram_info(&info);
        assert_eq!(pct, "50");
        assert_eq!(used, "1.1");
        assert_eq!(total, "2");
    }

    #[test]
    fn swap_info_percent_uses_raw_bytes() {
        let gib_kb = 1024u64 * 1024;
        let info = SystemInfo {
            cpu_brand: String::new(),
            mem_total_kb: 0,
            mem_available_kb: 0,
            swap_total_kb: 4 * gib_kb,
            swap_free_kb: 2 * gib_kb - 1,
        };
        let (used, total, pct) = swap_info(&info);
        assert_eq!(pct, "50");
        assert_eq!(used, "2.1");
        assert_eq!(total, "4");
    }
}

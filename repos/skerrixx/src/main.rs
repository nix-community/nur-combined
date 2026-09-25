mod basic;
mod config;
mod internals;
mod pkgs;
use internals::color::Colorize;
use pkgs::getform;
use std::collections::HashSet;
use std::env;
use std::io::{self, Write};
use std::process::Command;
use std::thread;
use std::time::Duration;

// sentinel for "no battery": keeps this value when the probe is hidden, fails, or no battery exists (basic.rs uses the same number)
const NO_BATTERY: usize = 500;

fn print_usage() {
    eprintln!("Usage: rfetch [options]");
    eprintln!();
    eprintln!("Options:");
    eprintln!("  -d, --distro <distro>   Override the detected distro art/logo");
    eprintln!("  --ascii <path>          Use a custom ascii art file instead of builtin");
    eprintln!("      --ascii-path, --art <path>  (aliases)");
    eprintln!("  -a, --anonymize         Hide username/hostname (for screenshots)");
    eprintln!("  --json                  Machine-readable JSON output (respects hide_info)");
    eprintln!("  -m, --minimal           One-line compact output (fast, skips gpu/disk/pkgs)");
    eprintln!("  --no-art                Show info only, no ascii art");
    eprintln!("  --logo-only             Show ascii art only, no info");
    eprintln!("  --clear-cache           Force rebuild of package/gpu caches");
    eprintln!("  -h, --help              Show this help");
    eprintln!();
    eprintln!("Available distros: {}", basic::known_distros().join(", "));
    eprintln!("\nP.S. This fetch has superpowers. See 'rfetch --super'.")
}

fn expand_path(p: &str) -> String {
    let t = p.trim();
    if t == "~" || t.starts_with("~/") {
        if let Ok(home) = env::var("HOME") {
            return format!("{}{}", home, &t[1..]);
        }
    }
    if let Some(rest) = t.strip_prefix("$HOME") {
        if let Ok(home) = env::var("HOME") {
            return format!("{}{}", home, rest);
        }
    }
    t.to_string()
}

fn load_art_lines(distro_key: &str, ascii_path: Option<&str>) -> Vec<String> {
    if let Some(p) = ascii_path {
        let expanded = expand_path(p);
        match std::fs::read_to_string(&expanded) {
            Ok(content) => {
                return content.lines().map(|l| l.replace('\t', "    ")).collect();
            }
            Err(e) => {
                eprintln!(
                    "rfetch: warning: could not read ascii file {} ({}) - falling back to builtin.",
                    expanded, e
                );
            }
        }
    }
    basic::get_ascii_art(distro_key)
        .lines()
        .map(|l| l.replace('\t', "    "))
        .collect()
}

fn display_hostusr(anonymize: bool) -> String {
    if anonymize {
        "anonymous ( hidden )".to_string()
    } else {
        basic::hostusr()
    }
}

/// cheap targeted system info: only the cpu brand and ram/swap numbers rfetch
/// displays, parsed straight from /proc (see `basic::SystemInfo`).
fn fresh_system() -> basic::SystemInfo {
    basic::SystemInfo::new()
}

fn colorize_infotext(text: &str, color: &str) -> String {
    match color.to_lowercase().as_str() {
        "red" => text.red().to_string(),
        "green" => text.green().to_string(),
        "blue" => text.blue().to_string(),
        "yellow" => text.yellow().to_string(),
        "cyan" => text.cyan().to_string(),
        "magenta" => text.magenta().to_string(),
        "purple" => text.purple().to_string(),
        "black" => text.black().to_string(),
        "white" => text.white().to_string(),
        "bright_black" | "bright-black" | "gray" | "grey" => text.bright_black().to_string(),
        "bright_red" | "bright-red" => text.bright_red().to_string(),
        "bright_green" | "bright-green" => text.bright_green().to_string(),
        "bright_yellow" | "bright-yellow" => text.bright_yellow().to_string(),
        "bright_blue" | "bright-blue" => text.bright_blue().to_string(),
        "bright_magenta" | "bright-magenta" | "bright_purple" | "bright-purple" => {
            text.bright_magenta().to_string()
        }
        "bright_cyan" | "bright-cyan" => text.bright_cyan().to_string(),
        "bright_white" | "bright-white" => text.bright_white().to_string(),
        _ => text.to_string(),
    }
}

fn colorize_ascii_line(line: &str, distro_key: &str, cfg: &config::Config) -> String {
    // logo coloring modes:
    // - true  -> per-distro color (old behavior)
    // - false -> no color
    // - "infotext"/"match" -> same color as the info text (icons included)
    // - "<color>" -> that named color (same names as color_infotext)
    match &cfg.color_ascii {
        config::AsciiColorMode::Enabled(false) => line.to_string(),
        config::AsciiColorMode::Enabled(true) => {
            let (r, g, b) = basic::get_logo_color(distro_key);
            line.truecolor(r, g, b).to_string()
        }
        config::AsciiColorMode::Color(s)
            if matches!(s.to_lowercase().as_str(), "infotext" | "match" | "auto") =>
        {
            colorize_infotext(line, &cfg.color_infotext)
        }
        config::AsciiColorMode::Color(s) => colorize_infotext(line, s),
    }
}

fn random() {
    let chosen = internals::random::random_range(1, 7);
    match chosen {
        1 => {
            let desktop = env::var("XDG_CURRENT_DESKTOP").unwrap_or_else(|_| "rfetch".to_string());
            println!(
                "\"i use {} btw\" - (c) {}",
                desktop,
                internals::identity::username()
            )
        }
        2 => {
            if Command::new("neofetch").arg("--version").output().is_ok() {
                println!("what's neofetch?");
            } else if Command::new("fastfetch").arg("--version").output().is_ok() {
                println!("what's fastfetch?")
            } else if Command::new("hyfetch").arg("--version").output().is_ok() {
                println!("what's hyfetch?")
            } else {
                println!("good boy")
            }
        }
        3 => {
            println!("{}@pc ~ > paru -S opsec", internals::identity::username());
            println!("[paru] error: package opsec isn't found. did you mean rfetch?")
        }
        4 => {
            println!("welcome to rfetch super mode!");
            print!("please wait, installing 47 miners...");
            io::stdout().flush().unwrap();
            thread::sleep(Duration::from_secs(3));
            println!("done");
            println!("thank you for using rfetch!")
        }
        5 => {
            let facts = [
                "i'm gay",
                "🦀",
                "one of its suggested original names is larpfetch",
                "i dont know how to make multicolored ascii, because i'm dumb",
            ];
            println!(
                "fun fact about rfetch: {}",
                facts[internals::random::random_range(0, facts.len())]
            );
        }
        6 => {
            println!(
                "{} is not in the rfetchers file. use virfetch to add yourself",
                internals::identity::username()
            )
        }
        _ => {
            eprintln!("oops")
        }
    }
}

/// parsed CLI options (values and boolean flags). parsing stops at the first
/// help/version/super flag, which is reported as an action instead.
struct CliOptions {
    distro_override: Option<String>,
    clear_cache: bool,
    cli_anonymize: bool,
    json_output: bool,
    minimal_output: bool,
    no_art: bool,
    logo_only: bool,
    cli_ascii_path: Option<String>,
}

/// terminal action requested on the command line (first one wins).
enum CliAction {
    Help,
    Version,
    Super,
}

#[derive(Debug)]
enum CliParseError {
    MissingDistroValue,
    MissingAsciiValue,
}

fn parse_args(args: &[String]) -> Result<(CliOptions, Option<CliAction>), CliParseError> {
    let mut distro_override: Option<String> = None;
    let mut clear_cache = false;
    let mut cli_anonymize = false;
    let mut json_output = false;
    let mut minimal_output = false;
    let mut no_art = false;
    let mut logo_only = false;
    let mut cli_ascii_path: Option<String> = None;
    let mut action: Option<CliAction> = None;
    let mut i = 0;
    while i < args.len() {
        match args[i].as_str() {
            "--distro" | "-d" => {
                i += 1;
                if i >= args.len() {
                    return Err(CliParseError::MissingDistroValue);
                }
                distro_override = Some(args[i].clone());
            }
            "--ascii" | "--ascii-path" | "--art" => {
                i += 1;
                if i >= args.len() {
                    return Err(CliParseError::MissingAsciiValue);
                }
                cli_ascii_path = Some(args[i].clone());
            }
            "--anonymize" | "-a" => {
                cli_anonymize = true;
            }
            "--json" => {
                json_output = true;
            }
            "--minimal" | "-m" => {
                minimal_output = true;
            }
            "--no-art" => {
                no_art = true;
            }
            "--logo-only" => {
                logo_only = true;
            }
            "--clear-cache" => {
                clear_cache = true;
            }
            "--help" | "-h" => {
                action = Some(CliAction::Help);
                break;
            }
            "--super" => {
                action = Some(CliAction::Super);
                break;
            }
            "--version" => {
                action = Some(CliAction::Version);
                break;
            }
            _ => {
                // just print the fetch if a flag is unknown (yeah skerrix youre very good at commenting(yes francy i am indeed awesome at commenting))
            }
        }
        i += 1;
    }
    Ok((
        CliOptions {
            distro_override,
            clear_cache,
            cli_anonymize,
            json_output,
            minimal_output,
            no_art,
            logo_only,
            cli_ascii_path,
        },
        action,
    ))
}

fn main() {
    let args: Vec<String> = env::args().collect();

    let (opts, action) = match parse_args(&args[1..]) {
        Ok(parsed) => parsed,
        Err(CliParseError::MissingDistroValue) => {
            eprintln!("err: --distro / -d requires a value.");
            print_usage();
            std::process::exit(1);
        }
        Err(CliParseError::MissingAsciiValue) => {
            eprintln!("err: --ascii requires a file path.");
            print_usage();
            std::process::exit(1);
        }
    };
    let CliOptions {
        distro_override,
        clear_cache,
        cli_anonymize,
        json_output,
        minimal_output,
        no_art,
        logo_only,
        cli_ascii_path,
    } = opts;

    match action {
        Some(CliAction::Help) => {
            print_usage();
            std::process::exit(0);
        }
        Some(CliAction::Version) => {
            println!(
                "rfetch v{}\nmade with \u{f004}  by \u{e7a8} Skerrixx, \u{f0e7} Francy and \u{1f9ea} Spectr\nthanks to:\n   1. flingo\n   2. tromtom\n   3. those who installed it from the AUR\n   4. those who compiled it from source\n   5. you, for using rfetch!\n   {}\nthis code is licensed with {}. microslop can suck our balls",
                env!("CARGO_PKG_VERSION"),
                "francy is tuff\n".purple().italic(),
                "GPL-3.0".yellow()
            );
            std::process::exit(0);
        }
        Some(CliAction::Super) => {
            random();
            std::process::exit(0);
        }
        None => {}
    }

    if clear_cache {
        pkgs::clear_cache();
        eprintln!("Cache cleared.");
        let wants_display = distro_override.is_some()
            || json_output
            || minimal_output
            || no_art
            || logo_only
            || cli_ascii_path.is_some();
        if !wants_display {
            std::process::exit(0);
        }
    }

    if no_art && logo_only {
        eprintln!("err: --no-art and --logo-only are mutually exclusive.");
        print_usage();
        std::process::exit(1);
    }

    let cfg = config::load_config();

    let distro_key: String = match &distro_override {
        Some(val) => val.clone(),
        None => basic::raw_os_id_or_name(),
    };

    let anonymize = cli_anonymize || cfg.anonymize;
    let ascii_path_opt: Option<String> = cli_ascii_path.or_else(|| cfg.ascii_path.clone());
    let ascii_path_ref: Option<&str> = ascii_path_opt.as_deref();

    // normalized once up front: every `hidden()` check below is then an O(1)
    // lookup. previously each check re-scanned `hide_info` with two
    // lowercase allocations per entry, so hiding more items made *every*
    // check slower (O(checks x hidden)).
    let hidden_set: HashSet<String> = cfg
        .hide_info
        .iter()
        .map(|h| h.trim().to_lowercase())
        .collect();
    let hidden = |key: &str| hidden_set.contains(key);
    // os_age is shown unless *either* "os_age" or "age" is hidden.
    let os_age_hidden = hidden("os_age") || hidden("age");
    // promoted-to-stable (ex-beta): de/wm, shell, terminal are normal hideable rows now.
    let dewm_hidden = hidden("de/wm") || hidden("de_wm") || hidden("de") || hidden("wm");
    let shell_hidden = hidden("shell");
    let term_hidden = hidden("terminal") || hidden("term");
    let boot_hidden = hidden("boot");
    let swap_hidden = hidden("swap");
    let load_hidden = hidden("load") || hidden("loadavg") || hidden("load_avg");
    let procs_hidden = hidden("processes") || hidden("procs") || hidden("proc");

    // --logo-only fast path: no info fetching at all
    if logo_only {
        let art_lines = load_art_lines(&distro_key, ascii_path_ref);
        for line in &art_lines {
            println!("{}", colorize_ascii_line(line, &distro_key, &cfg));
        }
        std::process::exit(0);
    }

    let os_display: String = if distro_override.is_some() {
        basic::display_name_for(&distro_key).to_string()
    } else {
        basic::os()
    };
    let host_display: String = display_hostusr(anonymize);

    // --minimal fast path: skip heavy collectors (pkgs, gpu, disks, battery)
    if minimal_output {
        let cpu_shown = !hidden("cpu");
        let ram_shown = !hidden("ram");
        let swap_shown = !swap_hidden;
        let need_sys = cpu_shown || ram_shown || swap_shown;

        let mut kernel_val = String::new();
        let mut uptime_val = String::new();
        let mut os_age_val = String::new();
        let mut boot_val = String::new();
        let mut load_val = String::new();
        let mut procs_val: Option<usize> = None;
        let mut sys: Option<basic::SystemInfo> = None;

        thread::scope(|s| {
            let h_kernel = if !hidden("kernel") {
                Some(s.spawn(basic::kernel))
            } else {
                None
            };
            let h_uptime = if !hidden("uptime") {
                Some(s.spawn(basic::uptime))
            } else {
                None
            };
            let h_age = if !os_age_hidden {
                Some(s.spawn(basic::os_age))
            } else {
                None
            };
            let h_boot = if !boot_hidden {
                Some(s.spawn(basic::boot_time))
            } else {
                None
            };
            let h_load = if !load_hidden {
                Some(s.spawn(basic::load_avg))
            } else {
                None
            };
            let h_procs = if !procs_hidden {
                Some(s.spawn(basic::process_count))
            } else {
                None
            };
            let h_sys = if need_sys {
                Some(s.spawn(fresh_system))
            } else {
                None
            };

            if let Some(h) = h_kernel {
                kernel_val = h.join().unwrap_or_default();
            }
            if let Some(h) = h_uptime {
                uptime_val = h.join().unwrap_or_default();
            }
            if let Some(h) = h_age {
                os_age_val = h.join().unwrap_or_default();
            }
            if let Some(h) = h_boot {
                boot_val = h.join().unwrap_or_default();
            }
            if let Some(h) = h_load {
                load_val = h.join().unwrap_or_default();
            }
            if let Some(h) = h_procs {
                procs_val = h.join().unwrap_or_default();
            }
            if let Some(h) = h_sys {
                sys = h.join().ok();
            }
        });

        let cpu_val = if cpu_shown {
            sys.as_ref().map(basic::cpu).unwrap_or_default()
        } else {
            String::new()
        };
        let ram_str = if !hidden("ram") {
            if let Some(s) = sys.as_ref() {
                let (used, total, pct) = basic::ram_info(s);
                format!("{} gib / {} gib ({}%)", used, total, pct)
            } else {
                String::new()
            }
        } else {
            String::new()
        };
        let swap_str = if !swap_hidden {
            if let Some(s) = sys.as_ref() {
                let (used, total, pct) = basic::swap_info(s);
                format!("{} gib / {} gib ({}%)", used, total, pct)
            } else {
                String::new()
            }
        } else {
            String::new()
        };
        let user_host = if anonymize {
            "anonymous@hidden".to_string()
        } else {
            format!(
                "{}@{}",
                internals::identity::username(),
                internals::identity::hostname()
            )
        };
        let mut parts: Vec<String> = vec![user_host];
        if !hidden("os") {
            parts.push(format!("os: {}", os_display));
        }
        if !hidden("kernel") && !kernel_val.is_empty() {
            parts.push(format!("kernel: {}", kernel_val));
        }
        if !dewm_hidden {
            parts.push(format!("de/wm: {}", basic::wmde()));
        }
        if !shell_hidden {
            parts.push(format!("shell: {}", basic::shell()));
        }
        {
            let t = basic::terminal();
            if !term_hidden && !t.is_empty() {
                parts.push(format!("term: {}", t));
            }
        }
        if !hidden("uptime") && !uptime_val.is_empty() {
            parts.push(format!("uptime: {}", uptime_val));
        }
        if !boot_hidden && !boot_val.is_empty() {
            parts.push(format!("boot: {}", boot_val));
        }
        if !os_age_hidden && !os_age_val.is_empty() {
            parts.push(format!("age: {}", os_age_val));
        }
        if !hidden("cpu") {
            parts.push(format!("cpu: {}", cpu_val));
        }
        if !hidden("ram") {
            parts.push(format!("ram: {}", ram_str));
        }
        if !swap_hidden {
            parts.push(format!("swap: {}", swap_str));
        }
        if !load_hidden && !load_val.is_empty() {
            parts.push(format!("load: {}", load_val));
        }
        if let Some(n) = procs_val {
            parts.push(format!("processes: {}", n));
        }
        println!("{}", parts.join(" | "));
        std::process::exit(0);
    }

    // full fetch (for --json / --no-art / full). respects hide_info to skip work.
    let mut kernel_val = String::new();
    let mut uptime_val = String::new();
    let mut os_age_val = String::new();
    let mut boot_val = String::new();
    let mut gpu_val = String::new();
    let mut disk_infos = Vec::new();
    let mut battery_charge: usize = NO_BATTERY;
    let mut packages_val: Option<String> = None;
    let mut cpu_val = String::new();
    let mut ram_vals: Option<(String, String, String)> = None;
    let mut swap_vals: Option<(String, String, String)> = None;
    let mut load_val = String::new();
    let mut procs_val: Option<usize> = None;
    let mut wmde_val = String::new();
    let mut shell_val = String::new();
    let mut term_val = String::new();

    // these collectors used to run serially *after* the scope, making their
    // cost additive on top of the slow parallel probes (boot/disk/battery).
    // folding them into the same scope overlaps them with those probes.
    let packages_shown = !hidden("packages");
    let cpu_shown = !hidden("cpu");
    let ram_shown = !hidden("ram");
    let swap_shown = !swap_hidden;
    let need_sys = cpu_shown || ram_shown || swap_shown;

    thread::scope(|s| {
        let h_kernel = if !hidden("kernel") {
            Some(s.spawn(basic::kernel))
        } else {
            None
        };
        let h_uptime = if !hidden("uptime") {
            Some(s.spawn(basic::uptime))
        } else {
            None
        };
        let h_os_age = if !os_age_hidden {
            Some(s.spawn(basic::os_age))
        } else {
            None
        };
        let h_boot = if !boot_hidden {
            Some(s.spawn(basic::boot_time))
        } else {
            None
        };
        let h_gpu = if !hidden("gpu") {
            Some(s.spawn(|| {
                // gpu probing does drm init (~18ms); reuse the 1h gpu cache when fresh.
                // the gpu cache is independent of the package cache, so hiding
                // "packages" no longer starves this fast path (see pkgs::fetch_gpu).
                pkgs::fetch_gpu()
            }))
        } else {
            None
        };
        let h_disks = if !hidden("disk") {
            Some(s.spawn(basic::disks_info))
        } else {
            None
        };
        // battery probing (manager/dbus init) is skipped entirely when hidden;
        // previously it ran on every invocation even with "battery" in hide_info,
        // so hiding it saved zero time.
        let h_battery = if !hidden("battery") {
            Some(s.spawn(basic::get_battery_charge))
        } else {
            None
        };

        let h_packages = if packages_shown {
            Some(s.spawn(getform))
        } else {
            None
        };
        let h_sys = if need_sys {
            Some(s.spawn(move || {
                let sys = fresh_system();
                let cpu_val = if cpu_shown {
                    basic::cpu(&sys)
                } else {
                    String::new()
                };
                let ram = if ram_shown {
                    Some(basic::ram_info(&sys))
                } else {
                    None
                };
                let swap = if swap_shown {
                    Some(basic::swap_info(&sys))
                } else {
                    None
                };
                (cpu_val, ram, swap)
            }))
        } else {
            None
        };
        let h_load = if !load_hidden {
            Some(s.spawn(basic::load_avg))
        } else {
            None
        };
        let h_procs = if !procs_hidden {
            Some(s.spawn(basic::process_count))
        } else {
            None
        };
        let h_wmde = if !dewm_hidden {
            Some(s.spawn(basic::wmde))
        } else {
            None
        };
        let h_shell = if !shell_hidden {
            Some(s.spawn(basic::shell))
        } else {
            None
        };
        let h_term = if !term_hidden {
            Some(s.spawn(basic::terminal))
        } else {
            None
        };

        if let Some(h) = h_kernel {
            kernel_val = h.join().unwrap_or_default();
        }
        if let Some(h) = h_uptime {
            uptime_val = h.join().unwrap_or_default();
        }
        if let Some(h) = h_os_age {
            os_age_val = h.join().unwrap_or_default();
        }
        if let Some(h) = h_boot {
            boot_val = h.join().unwrap_or_default();
        }
        if let Some(h) = h_gpu {
            gpu_val = h.join().unwrap_or_default();
        }
        if let Some(h) = h_disks {
            disk_infos = h.join().unwrap_or_default();
        }
        battery_charge = h_battery
            .map(|h| h.join().unwrap_or(NO_BATTERY))
            .unwrap_or(NO_BATTERY);
        if let Some(h) = h_packages {
            packages_val = Some(h.join().unwrap_or_default());
        }
        if let Some(h) = h_sys {
            let (c, r, sw) = h.join().unwrap_or_default();
            cpu_val = c;
            ram_vals = r;
            swap_vals = sw;
        }
        if let Some(h) = h_load {
            load_val = h.join().unwrap_or_default();
        }
        if let Some(h) = h_procs {
            procs_val = h.join().unwrap_or_default();
        }
        if let Some(h) = h_wmde {
            wmde_val = h.join().unwrap_or_default();
        }
        if let Some(h) = h_shell {
            shell_val = h.join().unwrap_or_default();
        }
        if let Some(h) = h_term {
            term_val = h.join().unwrap_or_default();
        }
    });

    if json_output {
        let user_name = if anonymize {
            "anonymous".to_string()
        } else {
            internals::identity::username()
        };
        let hostname = if anonymize {
            "hidden".to_string()
        } else {
            internals::identity::hostname()
        };
        let mut obj = serde_json::Map::new();
        obj.insert(
            "rfetch".to_string(),
            serde_json::Value::String(env!("CARGO_PKG_VERSION").to_string()),
        );
        obj.insert("user".to_string(), serde_json::Value::String(user_name));
        obj.insert("hostname".to_string(), serde_json::Value::String(hostname));
        obj.insert(
            "distro".to_string(),
            serde_json::Value::String(distro_key.clone()),
        );
        obj.insert(
            "os".to_string(),
            serde_json::Value::String(os_display.clone()),
        );
        if let Some(p) = packages_val.clone() {
            obj.insert("packages".to_string(), serde_json::Value::String(p));
        }
        if !hidden("kernel") {
            obj.insert(
                "kernel".to_string(),
                serde_json::Value::String(kernel_val.clone()),
            );
        }
        if !dewm_hidden {
            obj.insert(
                "de_wm".to_string(),
                serde_json::Value::String(wmde_val.clone()),
            );
        }
        if !shell_hidden {
            obj.insert(
                "shell".to_string(),
                serde_json::Value::String(shell_val.clone()),
            );
        }
        if !term_hidden && !term_val.is_empty() {
            obj.insert(
                "terminal".to_string(),
                serde_json::Value::String(term_val.clone()),
            );
        }
        if !hidden("uptime") {
            obj.insert(
                "uptime".to_string(),
                serde_json::Value::String(uptime_val.clone()),
            );
        }
        if !boot_hidden {
            obj.insert(
                "boot".to_string(),
                serde_json::Value::String(boot_val.clone()),
            );
        }
        if !os_age_hidden {
            obj.insert(
                "os_age".to_string(),
                serde_json::Value::String(os_age_val.clone()),
            );
        }
        if !hidden("cpu") {
            obj.insert(
                "cpu".to_string(),
                serde_json::Value::String(cpu_val.clone()),
            );
        }
        if !hidden("gpu") {
            obj.insert(
                "gpu".to_string(),
                serde_json::Value::String(gpu_val.clone()),
            );
        }
        if let Some((used, total, pct)) = ram_vals.clone() {
            obj.insert(
                "ram".to_string(),
                serde_json::json!({"used_gib": used, "total_gib": total, "pct": pct}),
            );
        }
        if let Some((used, total, pct)) = swap_vals.clone() {
            obj.insert(
                "swap".to_string(),
                serde_json::json!({"used_gib": used, "total_gib": total, "pct": pct}),
            );
        }
        if !load_hidden {
            obj.insert(
                "load".to_string(),
                serde_json::Value::String(load_val.clone()),
            );
        }
        if !procs_hidden {
            match procs_val {
                Some(n) => {
                    obj.insert("processes".to_string(), serde_json::json!(n));
                }
                None => {
                    obj.insert("processes".to_string(), serde_json::Value::Null);
                }
            }
        }
        if !hidden("disk") {
            let arr: Vec<serde_json::Value> = disk_infos.iter().map(|d| {
				serde_json::json!({"name": d.name, "filesystem": d.filesystem, "used_gb": d.used_gb, "total_gb": d.total_gb, "usage_pct": d.usage_pct})
			}).collect();
            obj.insert("disks".to_string(), serde_json::Value::Array(arr));
        }
        if !hidden("battery") {
            if battery_charge != NO_BATTERY {
                obj.insert("battery".to_string(), serde_json::json!(battery_charge));
            } else {
                obj.insert("battery".to_string(), serde_json::Value::Null);
            }
        }
        println!(
            "{}",
            serde_json::to_string_pretty(&serde_json::Value::Object(obj)).unwrap_or_default()
        );
        std::process::exit(0);
    }

    let info_lines: Vec<String> = {
        let mut v = Vec::new();
        v.push(format!(
            "  {}",
            colorize_infotext(&host_display, &cfg.color_infotext)
        ));

        if !hidden("headers") {
            if cfg.style == "boxed" {
                v.push(format!(
                    "  {}",
                    colorize_infotext("╭──────────╮", &cfg.color_infotext)
                ))
            } else {
                v.push(format!(
                    "  {}",
                    colorize_infotext("┏╸ software ", &cfg.color_infotext)
                ))
            }
        }

        let mut software: Vec<String> = Vec::new();
        if !hidden("packages") {
            let pkgs = packages_val.clone().unwrap_or_default();
            if cfg.style == "boxed" {
                software.push(format!("│  pkgs   │ {}", pkgs));
            } else {
                software.push(format!("┃  packages: {}", pkgs));
            }
        }
        if !hidden("os") {
            if cfg.style == "boxed" {
                software.push(format!("│    os   │ {}", os_display));
            } else {
                software.push(format!("┃  os: {}", os_display));
            }
        }

        if !hidden("kernel") {
            if cfg.style == "boxed" {
                software.push(format!("│  kernel │ {}", kernel_val));
            } else {
                software.push(format!("┃  kernel: {}", kernel_val));
            }
        }
        if !dewm_hidden {
            if cfg.style == "boxed" {
                software.push(format!("│ 󰍹 de/wm  │ {}", wmde_val));
            } else {
                software.push(format!("┃ 󰍹 de/wm: {}", wmde_val));
            }
        }
        if !shell_hidden {
            if cfg.style == "boxed" {
                software.push(format!("│  shell  │ {}", shell_val));
            } else {
                software.push(format!("┃  shell: {}", shell_val));
            }
        }
        if !term_hidden && !term_val.is_empty() {
            if cfg.style == "boxed" {
                software.push(format!("│  term   │ {}", term_val));
            } else {
                software.push(format!("┃  terminal: {}", term_val));
            }
        }
        if !hidden("uptime") {
            if cfg.style == "boxed" {
                software.push(format!("│  uptime │ {}", uptime_val));
            } else {
                software.push(format!("┃  uptime: {}", uptime_val));
            }
        }
        if !boot_hidden {
            if cfg.style == "boxed" {
                software.push(format!("│  boot   │ {}", boot_val));
            } else {
                software.push(format!("┃  boot: {}", boot_val));
            }
        }
        if !os_age_hidden {
            if cfg.style == "boxed" {
                software.push(format!("│ 󰃭 age    │ {}", os_age_val));
            } else {
                software.push(format!("┃ 󰃭 age: {}", os_age_val));
            }
        }

        for line in software.iter() {
            v.push(format!(
                "{}{}",
                "  ",
                colorize_infotext(line, &cfg.color_infotext)
            ));
        }

        let has_battery = battery_charge != NO_BATTERY;

        if !hidden("headers") {
            if cfg.style == "boxed" {
                v.push(format!(
                    "  {}",
                    colorize_infotext("├──────────┤", &cfg.color_infotext)
                ))
            } else {
                v.push(format!(
                    "  {}",
                    colorize_infotext("┏╸ hardware ", &cfg.color_infotext)
                ))
            }
        }

        let mut hardware: Vec<String> = Vec::new();
        if !hidden("cpu") {
            if cfg.style == "boxed" {
                hardware.push(format!("│  cpu    │ {}", cpu_val));
            } else {
                hardware.push(format!("┃  cpu: {}", cpu_val));
            }
        }
        if !hidden("gpu") {
            if cfg.style == "boxed" {
                hardware.push(format!("│ 󰢮 gpu    │ {}", gpu_val));
            } else {
                hardware.push(format!("┃ 󰢮 gpu: {}", gpu_val));
            }
        }
        if let Some((used, total, pct)) = ram_vals.clone() {
            if cfg.style == "boxed" {
                hardware.push(format!(
                    "│  ram    │ {} gib / {} gib ({}%)",
                    used, total, pct
                ));
            } else {
                hardware.push(format!("┃  ram: {} gib / {} gib ({}%)", used, total, pct));
            }
        }
        if let Some((used, total, pct)) = swap_vals.clone() {
            if cfg.style == "boxed" {
                hardware.push(format!(
                    "│ 󰍛 swap   │ {} gib / {} gib ({}%)",
                    used, total, pct
                ));
            } else {
                hardware.push(format!("┃ 󰍛 swap: {} gib / {} gib ({}%)", used, total, pct));
            }
        }
        if !load_hidden {
            if cfg.style == "boxed" {
                hardware.push(format!("│  load   │ {}", load_val));
            } else {
                hardware.push(format!("┃  load: {}", load_val));
            }
        }
        if !procs_hidden {
            let procs_str = procs_val
                .map(|n| n.to_string())
                .unwrap_or_else(|| "unknown".to_string());
            if cfg.style == "boxed" {
                hardware.push(format!("│  procs  │ {}", procs_str));
            } else {
                hardware.push(format!("┃  processes: {}", procs_str));
            }
        }
        if !hidden("disk") {
            for disk in disk_infos.iter() {
                if cfg.style == "boxed" {
                    hardware.push(format!(
                        "│  disk   │ ({}, {}): {} gib / {} gib ({}%)",
                        disk.name, disk.filesystem, disk.used_gb, disk.total_gb, disk.usage_pct,
                    ));
                } else {
                    hardware.push(format!(
                        "┃  disk ({}, {}): {} gib / {} gib ({}%)",
                        disk.name, disk.filesystem, disk.used_gb, disk.total_gb, disk.usage_pct,
                    ));
                }
            }
        }
        if has_battery && !hidden("battery") {
            if cfg.style == "boxed" {
                if battery_charge <= 20 {
                    hardware.push(format!("│  batt   │ {}% . charge, maybe?", battery_charge));
                } else {
                    hardware.push(format!("│  batt   │ {}%", battery_charge));
                }
            } else {
                if battery_charge <= 20 {
                    hardware.push(format!("┃  battery: {}% . charge, maybe?", battery_charge));
                } else {
                    hardware.push(format!("┃  battery: {}%", battery_charge));
                }
            }
        }

        for line in hardware.iter() {
            v.push(format!(
                "{}{}",
                "  ",
                colorize_infotext(line, &cfg.color_infotext)
            ));
        }

        if cfg.style == "boxed" {
            v.push(colorize_infotext("  ╰──────────╯", &cfg.color_infotext))
        } else {
            v.push(colorize_infotext("  ┛", &cfg.color_infotext))
        }

        v
    };

    if no_art {
        for line in &info_lines {
            println!("{}", line);
        }
        std::process::exit(0);
    }

    let art_lines: Vec<String> = load_art_lines(&distro_key, ascii_path_ref);
    let art_width = art_lines
        .iter()
        .map(|l| l.chars().count())
        .max()
        .unwrap_or(0);
    let padding = 2usize;
    let left_width = art_width + padding;

    let max_lines = art_lines.len().max(info_lines.len());
    for i in 0..max_lines {
        let left = art_lines.get(i).map(|s| s.as_str()).unwrap_or("");
        let right = info_lines.get(i).map(|s| s.as_str()).unwrap_or("");

        if right.is_empty() {
            if left.is_empty() {
                println!();
            } else {
                println!("{}", colorize_ascii_line(left, &distro_key, &cfg));
            }
        } else {
            if left.is_empty() {
                println!("{:left_width$} {}", "", right);
            } else {
                let visible_w = left.chars().count();
                let pad = left_width.saturating_sub(visible_w);
                let colored_left = colorize_ascii_line(left, &distro_key, &cfg);
                println!("{colored_left}{:pad$} {right}", "");
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn parse(args: &[&str]) -> Result<(CliOptions, Option<CliAction>), CliParseError> {
        let owned: Vec<String> = args.iter().map(|s| s.to_string()).collect();
        parse_args(&owned)
    }

    #[test]
    fn no_args_give_defaults_and_no_action() {
        let (opts, action) = parse(&[]).unwrap();
        assert!(opts.distro_override.is_none());
        assert!(!opts.clear_cache);
        assert!(!opts.cli_anonymize);
        assert!(!opts.json_output);
        assert!(!opts.minimal_output);
        assert!(!opts.no_art);
        assert!(!opts.logo_only);
        assert!(opts.cli_ascii_path.is_none());
        assert!(action.is_none());
    }

    #[test]
    fn distro_flag_takes_the_next_arg_as_value() {
        let (opts, _) = parse(&["--distro", "arch"]).unwrap();
        assert_eq!(opts.distro_override.as_deref(), Some("arch"));
    }

    #[test]
    fn short_distro_flag_works() {
        let (opts, _) = parse(&["-d", "fedora"]).unwrap();
        assert_eq!(opts.distro_override.as_deref(), Some("fedora"));
    }

    #[test]
    fn all_ascii_aliases_take_a_path() {
        for flag in ["--ascii", "--ascii-path", "--art"] {
            let (opts, _) = parse(&[flag, "~/art.txt"]).unwrap();
            assert_eq!(opts.cli_ascii_path.as_deref(), Some("~/art.txt"));
        }
    }

    #[test]
    fn boolean_flags_can_combine() {
        let (opts, _) = parse(&["-a", "--json", "-m", "--no-art", "--clear-cache"]).unwrap();
        assert!(opts.cli_anonymize);
        assert!(opts.json_output);
        assert!(opts.minimal_output);
        assert!(opts.no_art);
        assert!(opts.clear_cache);
    }

    #[test]
    fn logo_only_flag_sets() {
        let (opts, _) = parse(&["--logo-only"]).unwrap();
        assert!(opts.logo_only);
    }

    #[test]
    fn version_action_stops_parsing() {
        let (opts, action) = parse(&["--version", "--distro"]).unwrap();
        assert!(matches!(action, Some(CliAction::Version)));
        assert!(opts.distro_override.is_none());
    }

    #[test]
    fn help_and_super_are_actions() {
        assert!(matches!(parse(&["-h"]).unwrap().1, Some(CliAction::Help)));
        assert!(matches!(
            parse(&["--super"]).unwrap().1,
            Some(CliAction::Super)
        ));
    }

    #[test]
    fn missing_distro_value_is_an_error() {
        assert!(matches!(
            parse(&["--distro"]),
            Err(CliParseError::MissingDistroValue)
        ));
    }

    #[test]
    fn missing_ascii_value_is_an_error() {
        assert!(matches!(
            parse(&["--ascii"]),
            Err(CliParseError::MissingAsciiValue)
        ));
    }

    #[test]
    fn unknown_flags_are_ignored() {
        let (opts, action) = parse(&["--bogus", "--wat"]).unwrap();
        assert!(opts.distro_override.is_none());
        assert!(action.is_none());
    }
}

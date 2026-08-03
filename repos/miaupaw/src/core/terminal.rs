/// Simple internal ANSI color engine for a beautiful terminal experience.
/// No extra dependencies, just pure escape codes.
pub enum Color {
    Red,
    Green,
    Yellow,
    Blue,
    Magenta,
    Cyan,
    White,
    Gray,
    BrightRed,
    BrightYellow,
    Reset,
}

impl Color {
    pub fn as_str(&self) -> &'static str {
        match self {
            Color::Red => "\x1b[31m",
            Color::Green => "\x1b[32m",
            Color::Yellow => "\x1b[33m",
            Color::Blue => "\x1b[34m",
            Color::Magenta => "\x1b[35m",
            Color::Cyan => "\x1b[36m",
            Color::White => "\x1b[37m",
            Color::Gray => "\x1b[90m",
            Color::BrightRed => "\x1b[91m",
            Color::BrightYellow => "\x1b[93m",
            Color::Reset => "\x1b[0m",
        }
    }

    pub fn rgb(r: u8, g: u8, b: u8) -> String {
        format!("\x1b[38;2;{};{};{}m", r, g, b)
    }

    pub fn bg_rgb(r: u8, g: u8, b: u8) -> String {
        format!("\x1b[48;2;{};{};{}m", r, g, b)
    }
}

pub trait Styled {
    fn style(self, color: Color) -> String;
    fn red(self) -> String;
    fn green(self) -> String;
    fn yellow(self) -> String;
    fn blue(self) -> String;
    fn magenta(self) -> String;
    fn cyan(self) -> String;
    fn gray(self) -> String;
    fn bright_red(self) -> String;
    fn bright_yellow(self) -> String;
    fn bold(self) -> String;
    fn rgb(self, r: u8, g: u8, b: u8) -> String;
    fn bg_rgb(self, r: u8, g: u8, b: u8) -> String;
}

impl<T: std::fmt::Display> Styled for T {
    fn style(self, color: Color) -> String {
        format!("{}{}{}", color.as_str(), self, Color::Reset.as_str())
    }

    fn red(self) -> String { self.style(Color::Red) }
    fn green(self) -> String { self.style(Color::Green) }
    fn yellow(self) -> String { self.style(Color::Yellow) }
    fn blue(self) -> String { self.style(Color::Blue) }
    fn magenta(self) -> String { self.style(Color::Magenta) }
    fn cyan(self) -> String { self.style(Color::Cyan) }
    fn gray(self) -> String { self.style(Color::Gray) }
    fn bright_red(self) -> String { self.style(Color::BrightRed) }
    fn bright_yellow(self) -> String { self.style(Color::BrightYellow) }

    fn bold(self) -> String {
        format!("\x1b[1m{}\x1b[22m", self)
    }

    fn rgb(self, r: u8, g: u8, b: u8) -> String {
        format!("{}{}{}", Color::rgb(r, g, b), self, Color::Reset.as_str())
    }

    fn bg_rgb(self, r: u8, g: u8, b: u8) -> String {
        format!("{}{}{}", Color::bg_rgb(r, g, b), self, Color::Reset.as_str())
    }
}

/// Helper to print a luxury divider
pub fn print_divider() {
    eprintln!("{}", "─".repeat(50).gray());
}

// ── Verbosity (Variant A) ───────────────────────────────────────────────────
//
// Three-tier model on the existing log_* API. Gating happens here, callers
// `log_success`/`log_plain`) silenced at Normal, visible at Verbose.
// `Quiet` reserved for a future `--silent`; currently no flag selects it.

use std::sync::atomic::{AtomicU8, Ordering};

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
#[repr(u8)]
pub enum Verbosity {
    /// Only ERROR. Reserved for future --silent. No flag selects this yet.
    Quiet = 0,
    /// ERROR+WARN. INFO-tier silenced. Default for CLI invocations.
    Normal = 1,
    /// Everything. Default for daemon; enabled in CLI by `-v`/`--verbose`.
    Verbose = 2,
}

/// Initial value Verbose preserves legacy behaviour for anything that logs
/// before `set_verbosity` is called (e.g. very early static init). Dispatch
/// flips it after arg parsing.
static VERBOSITY: AtomicU8 = AtomicU8::new(Verbosity::Verbose as u8);

pub fn set_verbosity(v: Verbosity) {
    VERBOSITY.store(v as u8, Ordering::Relaxed);
}

pub fn verbosity() -> Verbosity {
    match VERBOSITY.load(Ordering::Relaxed) {
        0 => Verbosity::Quiet,
        1 => Verbosity::Normal,
        _ => Verbosity::Verbose,
    }
}

/// Whether INFO-tier output should be visible. Public so call sites that
/// emit `eprintln!` directly (with custom colour/format, not via `log_step`)
/// can gate themselves on the same switch.
#[inline]
pub fn info_visible() -> bool {
    matches!(verbosity(), Verbosity::Verbose)
}

#[inline]
fn warn_visible() -> bool {
    // ERROR+WARN visible at Normal and Verbose; only Quiet hides WARN.
    !matches!(verbosity(), Verbosity::Quiet)
}

/// Helper for stylized logs
pub fn log_step(name: &str, msg: &str) {
    if !info_visible() { return; }
    let tag = format!("[{: >10}]", name);
    eprintln!("{} {}", tag.bold(), msg);
}

pub fn log_info(msg: &str) {
    if !info_visible() { return; }
    let tag = format!("[{: >10}]", "Info");
    eprintln!("{} {}", tag.cyan().bold(), msg);
}

pub fn log_warn(msg: &str) {
    if !warn_visible() { return; }
    let tag = format!("[{: >10}]", "Warning");
    eprintln!("{} {}", tag.yellow().bold(), msg);
}

pub fn log_error(msg: &str) {
    let tag = format!("[{: >10}]", "Error");
    eprintln!("{} {}", tag.red().bold(), msg);
}

pub fn log_success(name: &str, msg: &str) {
    if !info_visible() { return; }
    let tag = format!("[{: >10}]", name);
    eprintln!("{} {}", tag.green().bold(), msg);
}

/// Helper for plain logs (bold tag but no color)
pub fn log_plain(name: &str, msg: &str) {
    if !info_visible() { return; }
    let tag = format!("[{: >10}]", name);
    eprintln!("{} {}", tag.bold(), msg);
}

pub fn print_logo() {
    let instant = r#"
  __             __               __  
 |  |-----.-----|  |_.-----.-----|  |_
 |  |     |__ --|   _|  _  |     |   _|
 |__|__|__|_____|____|___._|__|__|____|"#;

    let eyedropper = r#"
  ______                __                                    
 |   ___|--.--.-----.--|  |----.-----.-----.-----.-----.----.
 |   ___|  |  |  -__|  _  |   _|  _  |  _  |  _  |  -__|   _|
 |______|___  |_____|_____|__| |_____|   __|   __|_____|__|  
        |_____|                      |__|  |__|"#;

    let tag = format!("[{: >10}]", "Hello");
    eprintln!("{}", instant.trim_start_matches(['\n', '\r']).cyan().bold());
    eprintln!("{}", eyedropper.trim_start_matches(['\n', '\r']).cyan().bold());
    eprintln!("\n{} {} {}", tag.bold(), "Instant Eyedropper Reborn".green().bold(), env!("CARGO_PKG_VERSION").gray());
}

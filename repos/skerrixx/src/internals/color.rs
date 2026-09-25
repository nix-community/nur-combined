//! ansi color, a drop-in slice of the `colored` crate's `Colorize` api.
//!
//! mirrors `colored`'s runtime call exactly: `CLICOLOR_FORCE` (!= "0") forces
//! color on, `NO_COLOR` (set at all) forces it off, otherwise color only when
//! `CLICOLOR` (!= "0", default on) and stdout is a tty. so piped output stays
//! plain unless you force it, same as before.

use std::fmt;
use std::sync::OnceLock;

/// text already wrapped in an ansi style. prints directly via `Display`, and
/// keeps a couple of chained styles (`italic`).
pub struct Colored(String);

impl fmt::Display for Colored {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(&self.0)
    }
}

impl Colored {
    /// add italic on top of whatever style is already there.
    pub fn italic(self) -> Colored {
        Colored(paint(&self.0, "3"))
    }
}

/// the `Colorize` trait on `&str` and `String`, same method names as `colored`
/// so nothing at the call site changes.
pub trait Colorize {
    fn red(self) -> Colored;
    fn green(self) -> Colored;
    fn blue(self) -> Colored;
    fn yellow(self) -> Colored;
    fn cyan(self) -> Colored;
    fn magenta(self) -> Colored;
    fn purple(self) -> Colored;
    fn black(self) -> Colored;
    fn white(self) -> Colored;
    fn bright_black(self) -> Colored;
    fn bright_red(self) -> Colored;
    fn bright_green(self) -> Colored;
    fn bright_yellow(self) -> Colored;
    fn bright_blue(self) -> Colored;
    fn bright_magenta(self) -> Colored;
    fn bright_cyan(self) -> Colored;
    fn bright_white(self) -> Colored;
    fn truecolor(self, r: u8, g: u8, b: u8) -> Colored;
}

impl Colorize for &str {
    fn red(self) -> Colored {
        Colored(paint(self, "31"))
    }
    fn green(self) -> Colored {
        Colored(paint(self, "32"))
    }
    fn blue(self) -> Colored {
        Colored(paint(self, "34"))
    }
    fn yellow(self) -> Colored {
        Colored(paint(self, "33"))
    }
    fn cyan(self) -> Colored {
        Colored(paint(self, "36"))
    }
    fn magenta(self) -> Colored {
        Colored(paint(self, "35"))
    }
    fn purple(self) -> Colored {
        Colored(paint(self, "35"))
    }
    fn black(self) -> Colored {
        Colored(paint(self, "30"))
    }
    fn white(self) -> Colored {
        Colored(paint(self, "37"))
    }
    fn bright_black(self) -> Colored {
        Colored(paint(self, "90"))
    }
    fn bright_red(self) -> Colored {
        Colored(paint(self, "91"))
    }
    fn bright_green(self) -> Colored {
        Colored(paint(self, "92"))
    }
    fn bright_yellow(self) -> Colored {
        Colored(paint(self, "93"))
    }
    fn bright_blue(self) -> Colored {
        Colored(paint(self, "94"))
    }
    fn bright_magenta(self) -> Colored {
        Colored(paint(self, "95"))
    }
    fn bright_cyan(self) -> Colored {
        Colored(paint(self, "96"))
    }
    fn bright_white(self) -> Colored {
        Colored(paint(self, "97"))
    }
    fn truecolor(self, r: u8, g: u8, b: u8) -> Colored {
        Colored(truecolor(self, r, g, b))
    }
}

impl Colorize for String {
    fn red(self) -> Colored {
        Colored(paint(&self, "31"))
    }
    fn green(self) -> Colored {
        Colored(paint(&self, "32"))
    }
    fn blue(self) -> Colored {
        Colored(paint(&self, "34"))
    }
    fn yellow(self) -> Colored {
        Colored(paint(&self, "33"))
    }
    fn cyan(self) -> Colored {
        Colored(paint(&self, "36"))
    }
    fn magenta(self) -> Colored {
        Colored(paint(&self, "35"))
    }
    fn purple(self) -> Colored {
        Colored(paint(&self, "35"))
    }
    fn black(self) -> Colored {
        Colored(paint(&self, "30"))
    }
    fn white(self) -> Colored {
        Colored(paint(&self, "37"))
    }
    fn bright_black(self) -> Colored {
        Colored(paint(&self, "90"))
    }
    fn bright_red(self) -> Colored {
        Colored(paint(&self, "91"))
    }
    fn bright_green(self) -> Colored {
        Colored(paint(&self, "92"))
    }
    fn bright_yellow(self) -> Colored {
        Colored(paint(&self, "93"))
    }
    fn bright_blue(self) -> Colored {
        Colored(paint(&self, "94"))
    }
    fn bright_magenta(self) -> Colored {
        Colored(paint(&self, "95"))
    }
    fn bright_cyan(self) -> Colored {
        Colored(paint(&self, "96"))
    }
    fn bright_white(self) -> Colored {
        Colored(paint(&self, "97"))
    }
    fn truecolor(self, r: u8, g: u8, b: u8) -> Colored {
        Colored(truecolor(&self, r, g, b))
    }
}

/// wrap `text` in the sgr code, or leave it alone when color is off.
fn paint(text: &str, code: &str) -> String {
    if should_colorize() {
        format!("\u{1b}[{code}m{text}\u{1b}[0m")
    } else {
        text.to_string()
    }
}

/// 24-bit foreground color.
fn truecolor(text: &str, r: u8, g: u8, b: u8) -> String {
    if should_colorize() {
        format!("\u{1b}[38;2;{r};{g};{b}m{text}\u{1b}[0m")
    } else {
        text.to_string()
    }
}

fn stdout_is_terminal() -> bool {
    // SAFETY: isatty(2) has no preconditions; STDOUT_FILENO is always valid.
    unsafe { libc::isatty(libc::STDOUT_FILENO) == 1 }
}

/// the `colored` precedence, split out so it can be tested. `None` = unset.
fn decide(
    clicolor_force: Option<&str>,
    no_color: Option<&str>,
    clicolor: Option<&str>,
    is_tty: bool,
) -> bool {
    if let Some(v) = clicolor_force {
        if v != "0" {
            return true;
        }
    }
    if no_color.is_some() {
        return false;
    }
    let clicolor = clicolor.map(|v| v != "0").unwrap_or(true);
    clicolor && is_tty
}

/// checked once, so we don't re-hit the env/tty on every paint.
fn should_colorize() -> bool {
    static CACHE: OnceLock<bool> = OnceLock::new();
    *CACHE.get_or_init(|| {
        decide(
            std::env::var("CLICOLOR_FORCE").ok().as_deref(),
            std::env::var("NO_COLOR").ok().as_deref(),
            std::env::var("CLICOLOR").ok().as_deref(),
            stdout_is_terminal(),
        )
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn clicolor_force_wins_over_no_color() {
        assert!(decide(Some("1"), Some("1"), None, false));
    }

    #[test]
    fn clicolor_force_zero_is_not_forced() {
        assert!(!decide(Some("0"), None, None, false));
    }

    #[test]
    fn no_color_set_forces_off() {
        assert!(!decide(None, Some("0"), Some("1"), true));
        assert!(!decide(None, Some(""), Some("1"), true));
    }

    #[test]
    fn default_requires_tty() {
        assert!(decide(None, None, None, true));
        assert!(!decide(None, None, None, false));
    }

    #[test]
    fn clicolor_zero_disables_even_on_tty() {
        assert!(!decide(None, None, Some("0"), true));
    }

    #[test]
    fn colored_display_roundtrips() {
        // display must hand back the stored string as-is.
        let c = Colored("plain".to_string());
        assert_eq!(format!("{c}"), "plain");
    }
}

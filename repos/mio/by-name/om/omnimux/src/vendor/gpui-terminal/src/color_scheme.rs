//! Contour / Ghostty color-scheme reporting (DEC mode 2031 + DSR 996/997).
//!
//! Spec: <http://contour-terminal.org/vt-extensions/color-palette-update-notifications/>
//!
//! alacritty_terminal ignores unknown private mode 2031 and does not handle
//! `CSI ? 996 n`, so we observe those sequences beside the VTE parser.

use alacritty_terminal::vte::ansi::Rgb;

/// Tracks Contour mode 2031 and incomplete CSI fragments across PTY batches.
#[derive(Debug, Default)]
pub struct ColorSchemeState {
    notify_enabled: bool,
    pending: Vec<u8>,
}

/// Actions produced when Contour color-scheme CSI is seen on the PTY input path.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ColorSchemeAction {
    /// `CSI ? 2031 h`
    EnableNotify,
    /// `CSI ? 2031 l`
    DisableNotify,
    /// `CSI ? 996 n` — reply with [`dsr_color_scheme`].
    QueryScheme,
    /// `CSI ? 2031 $ p` — reply with [`decrpm_2031`].
    ReportMode2031,
}

impl ColorSchemeState {
    pub fn notify_enabled(&self) -> bool {
        self.notify_enabled
    }

    pub fn set_notify_enabled(&mut self, enabled: bool) {
        self.notify_enabled = enabled;
    }

    /// Observe PTY bytes (still passed unchanged to alacritty). Returns completed actions.
    pub fn feed(&mut self, bytes: &[u8]) -> Vec<ColorSchemeAction> {
        let mut data = std::mem::take(&mut self.pending);
        data.extend_from_slice(bytes);
        let mut actions = Vec::new();
        let mut i = 0;
        while i < data.len() {
            if data[i] != 0x1b {
                i += 1;
                continue;
            }
            if i + 1 >= data.len() {
                self.pending = data[i..].to_vec();
                return actions;
            }
            if data[i + 1] != b'[' {
                i += 1;
                continue;
            }
            // CSI parameters / intermediates until final byte 0x40..=0x7E.
            let mut j = i + 2;
            let mut end = None;
            while j < data.len() {
                let b = data[j];
                if (0x40..=0x7e).contains(&b) {
                    end = Some(j);
                    break;
                }
                // Abort obviously broken / too-long CSI.
                if j - i > 64 {
                    break;
                }
                j += 1;
            }
            let Some(end) = end else {
                self.pending = data[i..].to_vec();
                return actions;
            };
            let csi = &data[i + 2..=end];
            if let Some(action) = parse_color_scheme_csi(csi) {
                actions.push(action);
                match action {
                    ColorSchemeAction::EnableNotify => self.notify_enabled = true,
                    ColorSchemeAction::DisableNotify => self.notify_enabled = false,
                    ColorSchemeAction::QueryScheme | ColorSchemeAction::ReportMode2031 => {}
                }
            }
            i = end + 1;
        }
        self.pending.clear();
        actions
    }
}

/// Contour: `CSI ? 997 ; 1 n` dark, `CSI ? 997 ; 2 n` light.
pub fn dsr_color_scheme(dark: bool) -> String {
    if dark {
        "\x1b[?997;1n".into()
    } else {
        "\x1b[?997;2n".into()
    }
}

/// DECRPM reply for private mode 2031: set=1, reset=2.
pub fn decrpm_2031(enabled: bool) -> String {
    if enabled {
        "\x1b[?2031;1$y".into()
    } else {
        "\x1b[?2031;2$y".into()
    }
}

/// Rec. 601 luminance mid-point on 8-bit RGB (same idea as OSC 11 dark/light).
pub fn is_dark_rgb(rgb: Rgb) -> bool {
    let y = (299u32 * rgb.r as u32 + 587u32 * rgb.g as u32 + 114u32 * rgb.b as u32) / 1000;
    y < 128
}

fn parse_color_scheme_csi(csi: &[u8]) -> Option<ColorSchemeAction> {
    if csi.len() < 2 || csi[0] != b'?' {
        return None;
    }
    let final_byte = *csi.last()?;
    let body = &csi[..csi.len() - 1]; // after '?' … before final (includes intermediates)

    // CSI ? 2031 $ p
    if final_byte == b'p' && body.ends_with(b"$") {
        let params = &body[1..body.len() - 1];
        return if params_contain(params, 2031) {
            Some(ColorSchemeAction::ReportMode2031)
        } else {
            None
        };
    }

    let params = &body[1..];
    match final_byte {
        b'h' if params_contain(params, 2031) => Some(ColorSchemeAction::EnableNotify),
        b'l' if params_contain(params, 2031) => Some(ColorSchemeAction::DisableNotify),
        b'n' if params_eq_single(params, 996) => Some(ColorSchemeAction::QueryScheme),
        _ => None,
    }
}

fn params_contain(params: &[u8], want: u16) -> bool {
    params
        .split(|b| *b == b';')
        .filter_map(|p| std::str::from_utf8(p).ok()?.parse::<u16>().ok())
        .any(|p| p == want)
}

fn params_eq_single(params: &[u8], want: u16) -> bool {
    let mut iter = params
        .split(|b| *b == b';')
        .filter_map(|p| std::str::from_utf8(p).ok()?.parse::<u16>().ok());
    matches!(iter.next(), Some(p) if p == want) && iter.next().is_none()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn enable_disable_2031() {
        let mut s = ColorSchemeState::default();
        assert_eq!(
            s.feed(b"\x1b[?2031h"),
            vec![ColorSchemeAction::EnableNotify]
        );
        assert!(s.notify_enabled());
        assert_eq!(
            s.feed(b"\x1b[?2031l"),
            vec![ColorSchemeAction::DisableNotify]
        );
        assert!(!s.notify_enabled());
    }

    #[test]
    fn query_996() {
        let mut s = ColorSchemeState::default();
        assert_eq!(
            s.feed(b"\x1b[?996n"),
            vec![ColorSchemeAction::QueryScheme]
        );
    }

    #[test]
    fn multi_param_enable() {
        let mut s = ColorSchemeState::default();
        assert_eq!(
            s.feed(b"\x1b[?1000;2031h"),
            vec![ColorSchemeAction::EnableNotify]
        );
        assert!(s.notify_enabled());
    }

    #[test]
    fn split_across_feeds() {
        let mut s = ColorSchemeState::default();
        assert!(s.feed(b"\x1b[?20").is_empty());
        assert_eq!(
            s.feed(b"31h"),
            vec![ColorSchemeAction::EnableNotify]
        );
        assert!(s.notify_enabled());
    }

    #[test]
    fn decrpm() {
        let mut s = ColorSchemeState::default();
        s.set_notify_enabled(true);
        assert_eq!(
            s.feed(b"\x1b[?2031$p"),
            vec![ColorSchemeAction::ReportMode2031]
        );
        assert_eq!(decrpm_2031(true), "\x1b[?2031;1$y");
        assert_eq!(dsr_color_scheme(true), "\x1b[?997;1n");
        assert_eq!(dsr_color_scheme(false), "\x1b[?997;2n");
    }

    #[test]
    fn is_dark_threshold() {
        assert!(is_dark_rgb(Rgb {
            r: 0x1e,
            g: 0x1e,
            b: 0x1e
        }));
        assert!(!is_dark_rgb(Rgb {
            r: 0xff,
            g: 0xff,
            b: 0xff
        }));
    }
}

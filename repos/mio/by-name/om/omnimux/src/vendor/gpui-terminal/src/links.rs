//! URL / OSC 8 hyperlink discovery for Cmd/Ctrl+click.

use alacritty_terminal::grid::Dimensions;
use alacritty_terminal::index::{Column, Point as AlacPoint};
use alacritty_terminal::term::Term;
use std::ops::RangeInclusive;

/// Find an OSC 8 or plain `http(s)://` URL under `point`.
pub fn find_url_at_point<T>(term: &Term<T>, point: AlacPoint) -> Option<String> {
    let grid = term.grid();
    if let Some(link) = grid[point].hyperlink() {
        return Some(sanitize_url(link.uri()));
    }

    let line = point.line;
    let cols = term.columns();
    let mut text = String::with_capacity(cols);
    let mut col_ranges: Vec<RangeInclusive<usize>> = Vec::with_capacity(cols);
    for col in 0..cols {
        let cell = &grid[AlacPoint::new(line, Column(col))];
        let start = text.len();
        text.push_str(cell.c.to_string().as_str());
        // Wide cells may store empty continuations; still track column mapping.
        if text.len() == start {
            text.push(' ');
        }
        col_ranges.push(start..=text.len().saturating_sub(1));
    }

    let click_byte = col_ranges
        .get(point.column.0)
        .map(|r| *r.start())
        .unwrap_or(0);

    find_url_containing(&text, click_byte).map(|url| sanitize_url(&url))
}

pub fn find_urls_in_row<T>(term: &Term<T>, line: alacritty_terminal::index::Line) -> Vec<RangeInclusive<usize>> {
    let grid = term.grid();
    let cols = term.columns();
    
    let mut text = String::with_capacity(cols);
    let mut col_ranges: Vec<RangeInclusive<usize>> = Vec::with_capacity(cols);
    let mut osc8_ranges = Vec::new();
    let mut current_osc8: Option<(String, usize)> = None;

    for col in 0..cols {
        let cell = &grid[AlacPoint::new(line, Column(col))];
        
        if let Some(link) = cell.hyperlink() {
            let uri = sanitize_url(link.uri());
            if let Some((current_uri, start)) = current_osc8.as_ref() {
                if *current_uri != uri {
                    osc8_ranges.push(*start..=col.saturating_sub(1));
                    current_osc8 = Some((uri, col));
                }
            } else {
                current_osc8 = Some((uri, col));
            }
        } else if let Some((_, start)) = current_osc8.take() {
            osc8_ranges.push(start..=col.saturating_sub(1));
        }

        let start = text.len();
        text.push_str(cell.c.to_string().as_str());
        if text.len() == start {
            text.push(' ');
        }
        col_ranges.push(start..=text.len().saturating_sub(1));
    }
    
    if let Some((_, start)) = current_osc8 {
        osc8_ranges.push(start..=cols.saturating_sub(1));
    }

    let mut all_ranges = osc8_ranges;

    let bytes = text.as_bytes();
    let mut i = 0;
    while i < bytes.len() {
        if let Some(rest) = text.get(i..) {
            if let Some(url) = match_url_at(rest) {
                let trimmed = trim_url_punctuation(url);
                let start_byte = i;
                let end_byte = i + trimmed.len();
                
                let mut start_col = None;
                let mut end_col = None;
                for (col, byte_range) in col_ranges.iter().enumerate() {
                    if start_col.is_none() && byte_range.end() >= &start_byte {
                        start_col = Some(col);
                    }
                    if end_col.is_none() && byte_range.start() >= &end_byte {
                        end_col = Some(col.saturating_sub(1));
                        break;
                    }
                }
                
                if let Some(start_col) = start_col {
                    let end_col = end_col.unwrap_or(cols.saturating_sub(1));
                    all_ranges.push(start_col..=end_col);
                }
                
                i += url.len();
                continue;
            }
        }
        i += 1;
    }

    all_ranges
}

fn find_url_containing(line: &str, byte_index: usize) -> Option<String> {
    let bytes = line.as_bytes();
    let mut i = 0;
    while i < bytes.len() {
        if let Some(rest) = line.get(i..) {
            if let Some(url) = match_url_at(rest) {
                let start = i;
                let end = i + url.len();
                if byte_index >= start && byte_index < end {
                    return Some(trim_url_punctuation(url).to_string());
                }
                i = end;
                continue;
            }
        }
        i += 1;
    }
    None
}

fn match_url_at(s: &str) -> Option<&str> {
    let lower = s.as_bytes();
    let scheme_len = if lower.starts_with(b"https://") {
        8
    } else if lower.starts_with(b"http://") {
        7
    } else {
        return None;
    };
    let mut end = scheme_len;
    while end < s.len() {
        let b = s.as_bytes()[end];
        if b.is_ascii_whitespace() || matches!(b, b'<' | b'>' | b'"' | b'\'' | b'`' | b')' | b']' | b'}' | b'|') {
            break;
        }
        end += 1;
    }
    if end <= scheme_len {
        return None;
    }
    Some(&s[..end])
}

fn trim_url_punctuation(url: &str) -> &str {
    url.trim_end_matches(|c| matches!(c, '.' | ',' | ';' | ':' | '!' | '?' | ')' | ']' | '}'))
}

fn sanitize_url(url: &str) -> String {
    trim_url_punctuation(url.trim()).to_string()
}

pub fn is_browser_url(url: &str) -> bool {
    let u = url.trim();
    let lower = u.to_ascii_lowercase();
    
    if lower.contains('\0') || u.chars().any(|c| c.is_control()) {
        return false;
    }

    // Block dangerous schemes
    if lower.starts_with("javascript:") || lower.starts_with("data:") || lower.starts_with("vbscript:") {
        return false;
    }

    // Must have a valid scheme
    if let Some(idx) = lower.find(':') {
        if idx == 0 { return false; }
        let scheme = &lower[..idx];
        scheme.chars().all(|c| c.is_ascii_alphanumeric() || c == '+' || c == '-' || c == '.')
    } else {
        false
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn finds_url_under_cursor() {
        let line = "see https://example.com/path?q=1 and more";
        let idx = line.find("example").unwrap();
        assert_eq!(
            find_url_containing(line, idx).as_deref(),
            Some("https://example.com/path?q=1")
        );
    }

    #[test]
    fn trims_trailing_punctuation() {
        assert_eq!(trim_url_punctuation("https://a.com."), "https://a.com");
    }

    #[test]
    fn rejects_dangerous() {
        assert!(is_browser_url("file:///etc/passwd"));
        assert!(!is_browser_url("javascript:alert(1)"));
        assert!(is_browser_url("https://example.com"));
        assert!(is_browser_url("urn:ietf:params:oauth:grant-type:device_code"));
    }

    #[test]
    fn hyperlink_type_is_available() {
        // Compile-time sanity: alacritty Hyperlink API used by find_url_at_point.
        let _ = std::mem::size_of::<alacritty_terminal::term::cell::Hyperlink>();
    }
}

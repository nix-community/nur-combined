pub fn query(text: &str) -> Option<&str> {
    let text = text.trim();
    let lower = text.to_ascii_lowercase();
    for prefix in ["fonts", "font"] {
        if lower == prefix {
            return Some("");
        }
        if let Some(rest) = lower.strip_prefix(prefix)
            && rest.starts_with(char::is_whitespace)
        {
            return Some(text[prefix.len()..].trim());
        }
    }
    None
}

pub fn css(family: &str) -> String {
    let mut escaped = String::new();
    for c in family.chars() {
        match c {
            '"' => escaped.push_str("\\\""),
            '\\' => escaped.push_str("\\\\"),
            c if c.is_control() => escaped.push_str(&format!("\\{:x} ", c as u32)),
            c => escaped.push(c),
        }
    }
    format!("window {{ font-family: \"{escaped}\", \"Noto Sans\", sans-serif; }}")
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn font_queries_and_css_escaping() {
        assert_eq!(query("fonts"), Some(""));
        assert_eq!(query("font JetBrains Mono"), Some("JetBrains Mono"));
        assert!(query("fontconfig").is_none());
        assert!(css("A\"B\\C\nD").contains("A\\\"B\\\\C\\a D"));
    }
}

//! `key=value` records separated by `;` or newlines. Unknown keys are ignored.

pub fn fields(text: &str) -> impl Iterator<Item = (&str, &str)> {
    text.split(|c| c == ';' || c == '\n').filter_map(|raw| {
        let rec = raw.trim();
        if rec.is_empty() || rec.starts_with('#') {
            return None;
        }
        rec.split_once('=').map(|(key, value)| (key.trim(), value.trim()))
    })
}

pub fn flag(value: &str) -> bool {
    matches!(
        value.trim().to_ascii_lowercase().as_str(),
        "1" | "true" | "yes" | "on"
    )
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn unknown_keys_are_skipped() {
        let got: Vec<_> = fields("a=1;mystery=nope\nb=2").collect();
        assert_eq!(got, vec![("a", "1"), ("mystery", "nope"), ("b", "2")]);
        assert!(flag("1"));
        assert!(!flag("0"));
    }
}

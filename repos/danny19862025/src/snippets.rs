use crate::core::{self, TextItem};
use serde_json::json;
use std::{
    fs,
    io::Write,
    os::unix::fs::{OpenOptionsExt, PermissionsExt},
    path::PathBuf,
};

pub fn validate(trigger: &str, snippets: &[TextItem], index: Option<usize>) -> Result<(), String> {
    if trigger.is_empty() {
        return Ok(());
    }
    if !(2..=64).contains(&trigger.chars().count())
        || trigger.chars().any(|c| c.is_whitespace() || c.is_control())
    {
        return Err("Use a trigger of 2–64 characters without spaces, for example ;sig".into());
    }
    if snippets
        .iter()
        .enumerate()
        .any(|(n, s)| Some(n) != index && s.trigger == trigger)
    {
        return Err("That trigger already belongs to another snippet".into());
    }
    Ok(())
}

// Trigger only a complete word before the cursor; pasted text does not expand.
pub fn expansion<'a>(prefix: &str, snippets: &'a [TextItem]) -> Option<(usize, &'a str)> {
    snippets
        .iter()
        .filter(|s| !s.trigger.is_empty())
        .find_map(|s| {
            let start = prefix.len().checked_sub(s.trigger.len())?;
            let left = prefix.get(..start)?;
            if prefix.get(start..)? == s.trigger
                && left.chars().next_back().is_none_or(|c| c.is_whitespace())
            {
                Some((start, s.value.as_str()))
            } else {
                None
            }
        })
}

#[derive(Debug, PartialEq, Eq)]
pub struct Rendered {
    pub text: String,
    /// Character offset of the first cursor marker, for GTK's Unicode offsets.
    pub cursor: Option<usize>,
}

pub fn render(template: &str, clipboard: &str) -> Rendered {
    let mut text = String::new();
    let mut cursor = None;
    let mut rest = template;
    while let Some((at, marker)) = next_marker(rest) {
        text.push_str(&rest[..at]);
        if marker == "{cursor}" {
            cursor.get_or_insert_with(|| text.chars().count());
        } else {
            text.push_str(clipboard);
        }
        rest = &rest[at + marker.len()..];
    }
    text.push_str(rest);
    Rendered { text, cursor }
}

fn next_marker(text: &str) -> Option<(usize, &'static str)> {
    ["{cursor}", "{clipboard}"]
        .into_iter()
        .filter_map(|marker| text.find(marker).map(|at| (at, marker)))
        .min_by_key(|(at, _)| *at)
}

fn espanso_match(s: &TextItem) -> serde_json::Value {
    let mut vars = vec![
        json!({"name":"spotlight_content", "type":"echo", "inject_vars":false, "params":{"echo":s.value}}),
    ];
    let mut replacement = "{{spotlight_content}}".to_string();
    if next_marker(&s.value).is_some() {
        vars.clear();
        replacement.clear();
        let mut rest = s.value.as_str();
        let mut cursor = false;
        let mut clipboard = false;
        loop {
            let marker = next_marker(rest);
            let literal = marker.map(|(at, _)| &rest[..at]).unwrap_or(rest);
            if !literal.is_empty() {
                let name = format!("spotlight_literal_{}", vars.len());
                vars.push(json!({"name":name,"type":"echo","inject_vars":false,"params":{"echo":literal}}));
                replacement.push_str(&format!("{{{{{name}}}}}"));
            }
            let Some((at, marker)) = marker else {
                break;
            };
            if marker == "{cursor}" {
                if !cursor {
                    replacement.push_str("$|$");
                    cursor = true;
                }
            } else {
                if !clipboard {
                    vars.push(json!({"name":"spotlight_clipboard","type":"clipboard"}));
                    clipboard = true;
                }
                replacement.push_str("{{spotlight_clipboard}}");
            }
            rest = &rest[at + marker.len()..];
        }
    }
    json!({"trigger":s.trigger,"word":true,"replace":replacement,"label":s.name,"vars":vars})
}

pub fn config_path() -> PathBuf {
    std::env::var_os("XDG_CONFIG_HOME")
        .map(PathBuf::from)
        .unwrap_or_else(|| core::home().join(".config"))
        .join("espanso/match/spotlight.yml")
}
pub fn config(snippets: &[TextItem], enabled: bool) -> String {
    // JSON is a YAML subset. Echo variables keep literal {{braces}} in code snippets.
    let matches: Vec<_> = snippets
        .iter()
        .filter(|s| enabled && !s.trigger.is_empty())
        .map(espanso_match)
        .collect();
    format!(
        "# Managed by Spotlight · edit snippets in the launcher\n{}\n",
        serde_json::to_string_pretty(&json!({"matches": matches})).unwrap()
    )
}
pub fn sync_to(path: &std::path::Path, snippets: &[TextItem], enabled: bool) -> Result<(), String> {
    if !enabled && !path.exists() {
        return Ok(());
    }
    let content = config(snippets, enabled);
    if let Ok(old) = fs::read_to_string(path) {
        if !old.starts_with("# Managed by Spotlight ·") {
            return Err(format!(
                "{} already exists and is not managed by Spotlight",
                path.display()
            ));
        }
        if old == content {
            return Ok(());
        }
    }
    let dir = path
        .parent()
        .ok_or("Invalid expansion configuration path")?;
    fs::create_dir_all(dir).map_err(|e| e.to_string())?;
    let tmp = path.with_extension("spotlight-tmp");
    let mut file = fs::OpenOptions::new()
        .write(true)
        .create(true)
        .truncate(true)
        .mode(0o600)
        .open(&tmp)
        .map_err(|e| e.to_string())?;
    file.set_permissions(fs::Permissions::from_mode(0o600))
        .map_err(|e| e.to_string())?;
    file.write_all(content.as_bytes())
        .map_err(|e| e.to_string())?;
    fs::rename(tmp, path).map_err(|e| e.to_string())
}
pub fn sync(snippets: &[TextItem], enabled: bool) -> Result<(), String> {
    sync_to(&config_path(), snippets, enabled)
}

#[cfg(test)]
mod tests {
    use super::*;
    fn snippet() -> TextItem {
        TextItem {
            name: "Signature".into(),
            trigger: ";sig".into(),
            value: "Regards,\nDanny {{code}}".into(),
        }
    }
    #[test]
    fn exact_word_boundary_and_unicode() {
        let snippets = vec![snippet()];
        assert_eq!(
            expansion("é ;sig", &snippets),
            Some((3, snippets[0].value.as_str()))
        );
        assert!(expansion("x;sig", &snippets).is_none());
        assert!(expansion(";si", &snippets).is_none());
        assert!(validate(";sig", &snippets, None).is_err());
        assert!(validate(";sig", &snippets, Some(0)).is_ok());
        assert!(validate("bad trigger", &snippets, None).is_err());
    }
    #[test]
    fn old_data_and_private_sync() {
        let old: TextItem = serde_json::from_str(r#"{"name":"Old","value":"text"}"#).unwrap();
        assert!(old.trigger.is_empty());
        let root = std::env::temp_dir().join(format!("spotlight-snippets-{}", std::process::id()));
        let path = root.join("spotlight.yml");
        sync_to(&path, &[snippet()], true).unwrap();
        assert_eq!(
            fs::metadata(&path).unwrap().permissions().mode() & 0o777,
            0o600
        );
        let text = fs::read_to_string(&path).unwrap();
        let config: serde_json::Value =
            serde_json::from_str(text.lines().skip(1).collect::<Vec<_>>().join("\n").as_str())
                .unwrap();
        assert_eq!(
            config["matches"][0]["vars"][0]["params"]["echo"],
            snippet().value
        );
        assert_eq!(config["matches"][0]["vars"][0]["inject_vars"], false);
        sync_to(&path, &[], false).unwrap();
        assert!(!fs::read_to_string(&path).unwrap().contains(";sig"));
        fs::write(&path, "# personal configuration").unwrap();
        assert!(sync_to(&path, &[snippet()], true).is_err());
        assert_eq!(
            fs::read_to_string(&path).unwrap(),
            "# personal configuration"
        );
        fs::remove_dir_all(root).unwrap();
    }
    #[test]
    fn placeholders_unicode_and_literal_clipboard() {
        let rendered = render(
            "é {clipboard} [{cursor}] {cursor}",
            "{{code}} {cursor} {clipboard}",
        );
        assert_eq!(rendered.text, "é {{code}} {cursor} {clipboard} [] ");
        assert_eq!(
            rendered.cursor,
            Some("é {{code}} {cursor} {clipboard} [".chars().count())
        );
        assert_eq!(
            render("plain {{braces}}", ""),
            Rendered {
                text: "plain {{braces}}".into(),
                cursor: None
            }
        );
        let mut s = snippet();
        s.value = "{{code}} {clipboard} [{cursor}] {cursor}".into();
        let json = espanso_match(&s);
        assert_eq!(json["replace"].as_str().unwrap().matches("$|$").count(), 1);
        let vars = json["vars"].as_array().unwrap();
        assert_eq!(vars.iter().filter(|v| v["type"] == "clipboard").count(), 1);
        assert!(
            vars.iter()
                .filter(|v| v["type"] == "echo")
                .all(|v| v["inject_vars"] == false)
        );
        assert_eq!(vars[0]["params"]["echo"], "{{code}} ");
    }
}

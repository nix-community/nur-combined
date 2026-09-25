use crate::internals::color::Colorize;
use serde::{Deserialize, Serialize};
use std::path::PathBuf;

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(untagged)]
pub enum AsciiColorMode {
    Enabled(bool),
    Color(String),
}

impl Default for AsciiColorMode {
    fn default() -> Self {
        AsciiColorMode::Enabled(true)
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Config {
    #[serde(default = "defacolor", deserialize_with = "deserialize_ascii_color")]
    pub color_ascii: AsciiColorMode,
    #[serde(default = "deficolor")]
    pub color_infotext: String,
    #[serde(default = "defhide")]
    pub hide_info: Vec<String>,
    #[serde(default = "defstyle")]
    pub style: String,
    #[serde(default)]
    pub anonymize: bool,
    #[serde(default)]
    pub ascii_path: Option<String>,
}

fn defacolor() -> AsciiColorMode {
    AsciiColorMode::Enabled(true)
}

// Accepts bool (enabled/disabled), string (color name), or number. A numeric
// value is tolerated as a color name string so a stray number in conf.jsonc
// can no longer break the entire config parse; unknown names simply render
// uncolored at the call site, same as unknown string values.
fn deserialize_ascii_color<'de, D>(deserializer: D) -> Result<AsciiColorMode, D::Error>
where
    D: serde::Deserializer<'de>,
{
    struct AsciiColorVisitor;

    impl<'de> serde::de::Visitor<'de> for AsciiColorVisitor {
        type Value = AsciiColorMode;

        fn expecting(&self, formatter: &mut std::fmt::Formatter) -> std::fmt::Result {
            formatter.write_str("a boolean, string, or number")
        }

        fn visit_bool<E>(self, value: bool) -> Result<AsciiColorMode, E> {
            Ok(AsciiColorMode::Enabled(value))
        }

        fn visit_str<E>(self, value: &str) -> Result<AsciiColorMode, E> {
            Ok(AsciiColorMode::Color(value.to_string()))
        }

        fn visit_string<E>(self, value: String) -> Result<AsciiColorMode, E> {
            Ok(AsciiColorMode::Color(value))
        }

        fn visit_u64<E>(self, value: u64) -> Result<AsciiColorMode, E> {
            Ok(AsciiColorMode::Color(value.to_string()))
        }

        fn visit_i64<E>(self, value: i64) -> Result<AsciiColorMode, E> {
            Ok(AsciiColorMode::Color(value.to_string()))
        }

        fn visit_f64<E>(self, value: f64) -> Result<AsciiColorMode, E> {
            Ok(AsciiColorMode::Color(value.to_string()))
        }
    }

    deserializer.deserialize_any(AsciiColorVisitor)
}

fn deficolor() -> String {
    "white".to_string()
}

fn defstyle() -> String {
    "sectioned".to_string()
}

fn defhide() -> Vec<String> {
    Vec::new()
}

impl Default for Config {
    fn default() -> Self {
        Config {
            color_ascii: defacolor(),
            color_infotext: deficolor(),
            hide_info: defhide(),
            style: defstyle(),
            anonymize: false,
            ascii_path: None,
        }
    }
}

fn config_dir() -> PathBuf {
    if let Ok(xdg) = std::env::var("XDG_CONFIG_HOME") {
        if !xdg.trim().is_empty() {
            return PathBuf::from(xdg).join("rfetch");
        }
    }
    let home = std::env::var("HOME").unwrap_or_else(|_| ".".to_string());
    PathBuf::from(home).join(".config").join("rfetch")
}

pub fn config_path() -> PathBuf {
    config_dir().join("conf.jsonc")
}
fn strip_comments(input: &str) -> String {
    let mut out = String::with_capacity(input.len());
    let mut chars = input.chars().peekable();
    let mut in_string = false;
    let mut in_line_comment = false;
    let mut in_block_comment = false;

    while let Some(c) = chars.next() {
        if in_line_comment {
            if c == '\n' {
                in_line_comment = false;
                out.push(c);
            }
            continue;
        }
        if in_block_comment {
            if c == '*' && chars.peek() == Some(&'/') {
                chars.next();
                in_block_comment = false;
            }
            continue;
        }
        if in_string {
            out.push(c);
            if c == '\\' {
                if let Some(n) = chars.next() {
                    out.push(n);
                }
            } else if c == '"' {
                in_string = false;
            }
            continue;
        }
        match c {
            '"' => {
                in_string = true;
                out.push(c);
            }
            '/' if chars.peek() == Some(&'/') => {
                chars.next();
                in_line_comment = true;
            }
            '/' if chars.peek() == Some(&'*') => {
                chars.next();
                in_block_comment = true;
            }
            ',' => {
                // JSONC: drop a trailing comma only when the next meaningful
                // token (ignoring whitespace and comments) is `}` or `]`.
                let mut ahead = chars.clone();
                if !trailing_comma_ahead(&mut ahead) {
                    out.push(c);
                }
            }
            _ => out.push(c),
        }
    }

    out
}

/// Returns true when the next non-whitespace, non-comment token is `}` or `]`.
/// Does not consume the main stream: the caller passes a cloned lookahead.
fn trailing_comma_ahead(chars: &mut std::iter::Peekable<std::str::Chars<'_>>) -> bool {
    loop {
        match chars.next() {
            Some(c) if c.is_whitespace() => continue,
            Some('}') | Some(']') => return true,
            Some('/') => match chars.next() {
                Some('/') => {
                    for c in chars.by_ref() {
                        if c == '\n' {
                            break;
                        }
                    }
                }
                Some('*') => {
                    let mut prev = None;
                    for c in chars.by_ref() {
                        if prev == Some('*') && c == '/' {
                            break;
                        }
                        prev = Some(c);
                    }
                }
                _ => return false,
            },
            _ => return false,
        }
    }
}

fn default_config_content() -> String {
    "{\n\t\"color_ascii\": true, // options: true (distro color) / false (no color) / \"infotext\" (match color_infotext) / \"<color>\" (e.g. \"red\")\n\t\"color_infotext\": \"white\",\n\t\"hide_info\": [\n\t\t/* \n\t\tuncomment any string below to hide the info about it.\n\t\t*/\n\t\t // \"headers\"\n\t\t // \"packages\"\n\t\t // \"os\"\n\t\t // \"os_age\"\n\t\t // \"kernel\"\n\t\t // \"de/wm\" // (also: \"de_wm\", \"de\", \"wm\")\n\t\t // \"shell\"\n\t\t // \"terminal\" // (also: \"term\")\n\t\t // \"uptime\"\n\t\t // \"boot\"\n\t\t // \"cpu\"\n\t\t // \"gpu\"\n\t\t // \"ram\"\n\t\t // \"swap\"\n\t\t // \"load\" // (also: \"loadavg\", \"load_avg\")\n\t\t // \"processes\" // (also: \"procs\", \"proc\")\n\t\t // \"disk\"\n\t\t // \"battery\" //(only hides it if it's present at all)\n\t],\n\t\"style\": \"sectioned\", // options: sectioned/boxed\n\t\"anonymize\": false, // set true to hide username/hostname for screenshots\n\t\"ascii_path\": null // set to e.g. \"~/.config/rfetch/ascii.txt\" for custom art\n}\n".to_string()
}
pub fn load_config() -> Config {
    let path = config_path();

    if !path.exists() {
        return first_run_setup();
    }

    let content = match std::fs::read_to_string(&path) {
        Ok(c) => c,
        Err(e) => {
            eprintln!(
                "rfetch: warning: could not read config {} ({})",
                path.display(),
                e
            );
            eprintln!("rfetch: using default config.");
            return Config::default();
        }
    };

    match serde_json::from_str::<Config>(&strip_comments(&content)) {
        Ok(cfg) => cfg,
        Err(e) => {
            eprintln!(
                "rfetch: warning: failed to parse {} ({})",
                path.display(),
                e
            );
            eprintln!("rfetch: using default config.");
            Config::default()
        }
    }
}

fn first_run_setup() -> Config {
    eprintln!("welcome!");
    eprintln!(
        "it seems it's your {} time using {}",
        "first".red(),
        "rfetch!".blue()
    );
    eprintln!(
        "\nwe haven't found a rfetch configuration file found at {}.",
        config_path().display()
    );
    eprintln!("\ncreating a default config - screenshot-ready, no setup needed!");
    eprintln!("tip: edit ~/.config/rfetch/conf.jsonc anytime to customize rfetch.\n");
    let cfg = Config::default();

    if let Some(parent) = config_path().parent() {
        if let Err(e) = std::fs::create_dir_all(parent) {
            eprintln!(
                "{}: could not create {} ({})",
                "error".red(),
                parent.display(),
                e
            );
            return cfg;
        }
    }

    match std::fs::write(config_path(), default_config_content()) {
        Ok(_) => {
            eprintln!();
            eprintln!(
                "your config is created! it's located at {}.",
                config_path().display()
            );
            eprintln!("you can edit it anytime to customize rfetch.");
        }
        Err(e) => {
            eprintln!();
            eprintln!(
                "rfetch: error: could not write config {} ({})",
                config_path().display(),
                e
            );
        }
    }

    cfg
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn strip_comments_removes_line_comments() {
        let input = "{\n  \"a\": 1 // line comment\n}";
        assert_eq!(strip_comments(input), "{\n  \"a\": 1 \n}");
    }

    #[test]
    fn strip_comments_removes_block_comments() {
        let input = "{ /* block */ \"a\": 1 }";
        assert_eq!(strip_comments(input), "{  \"a\": 1 }");
    }

    #[test]
    fn strip_comments_removes_inline_trailing_comments() {
        let input = "{\n  \"a\": 1, // trailing comment\n}";
        assert_eq!(strip_comments(input), "{\n  \"a\": 1 \n}");
    }

    #[test]
    fn strip_comments_removes_trailing_commas_in_object_and_array() {
        let input = "{\"a\": 1, \"b\": [1, 2, 3,],}";
        assert_eq!(strip_comments(input), "{\"a\": 1, \"b\": [1, 2, 3]}");
    }

    #[test]
    fn strip_comments_removes_multiline_trailing_commas() {
        let input = "{\n  \"hide_info\": [\n    \"packages\",\n    \"uptime\",\n  ],\n}";
        assert_eq!(
            strip_comments(input),
            "{\n  \"hide_info\": [\n    \"packages\",\n    \"uptime\"\n  ]\n}"
        );
    }

    #[test]
    fn strip_comments_keeps_comment_like_string_content_verbatim() {
        let input = r#"{"a": "x//y", "b": "/*c*/", "c": "a,b,}", "d": "q\"w", "e": "back\\slash"}"#;
        assert_eq!(strip_comments(input), input);
    }

    #[test]
    fn jsonc_with_comments_and_trailing_commas_deserializes_to_config() {
        let jsonc = r#"{
            "color_ascii": "infotext", // comment
            "color_infotext": "white",
            "hide_info": [
                "packages", /* block comment */
                "uptime",
            ],
            "style": "boxed",
            "anonymize": false,
            "ascii_path": null,
        }"#;
        let cfg: Config = serde_json::from_str(&strip_comments(jsonc)).expect("jsonc should parse");
        assert!(matches!(cfg.color_ascii, AsciiColorMode::Color(ref s) if s == "infotext"));
        assert_eq!(cfg.color_infotext, "white");
        assert_eq!(cfg.hide_info, vec!["packages", "uptime"]);
        assert_eq!(cfg.style, "boxed");
        assert!(!cfg.anonymize);
        assert_eq!(cfg.ascii_path, None);
    }

    #[test]
    fn color_ascii_bool_still_parses_as_enabled() {
        let cfg: Config =
            serde_json::from_str(r#"{"color_ascii": false}"#).expect("bool should parse");
        assert!(matches!(cfg.color_ascii, AsciiColorMode::Enabled(false)));
    }

    #[test]
    fn color_ascii_string_still_parses_as_color() {
        let cfg: Config =
            serde_json::from_str(r#"{"color_ascii": "red"}"#).expect("string should parse");
        assert!(matches!(cfg.color_ascii, AsciiColorMode::Color(ref s) if s == "red"));
    }

    #[test]
    fn numeric_color_ascii_no_longer_breaks_parse() {
        let cfg: Config = serde_json::from_str(r#"{"color_ascii": 123}"#)
            .expect("numeric color_ascii should not break the whole config");
        assert!(matches!(cfg.color_ascii, AsciiColorMode::Color(ref s) if s == "123"));
        assert_eq!(cfg.color_infotext, "white");
    }
}

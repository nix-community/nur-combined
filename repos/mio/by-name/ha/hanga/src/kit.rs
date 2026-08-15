//! Named fields from a guest `value`. Dicts are the live API; `key=value;` text
//! is only a fallback so old tests and packs still parse.

#[derive(Clone, Debug, PartialEq)]
pub enum Cell {
    Flag(bool),
    Int(i64),
    Float(f64),
    Text(String),
}

impl Cell {
    pub fn text(&self) -> String {
        match self {
            Cell::Flag(true) => "1".into(),
            Cell::Flag(false) => "0".into(),
            Cell::Int(value) => value.to_string(),
            Cell::Float(value) => value.to_string(),
            Cell::Text(text) => text.clone(),
        }
    }

    pub fn as_text(&self) -> Option<&str> {
        match self {
            Cell::Text(text) => Some(text.as_str()),
            _ => None,
        }
    }

    pub fn as_f32(&self) -> Option<f32> {
        match self {
            Cell::Float(value) => Some(*value as f32),
            Cell::Int(value) => Some(*value as f32),
            Cell::Text(text) => text.parse().ok(),
            Cell::Flag(true) => Some(1.0),
            Cell::Flag(false) => Some(0.0),
        }
    }

    pub fn as_i32(&self) -> Option<i32> {
        match self {
            Cell::Int(value) => Some(*value as i32),
            Cell::Float(value) => Some(*value as i32),
            Cell::Text(text) => text.parse().ok(),
            Cell::Flag(true) => Some(1),
            Cell::Flag(false) => Some(0),
        }
    }

    pub fn as_flag(&self) -> bool {
        match self {
            Cell::Flag(value) => *value,
            Cell::Int(value) => *value != 0,
            Cell::Float(value) => *value != 0.0,
            Cell::Text(text) => flag(text),
        }
    }
}

#[derive(Clone, Debug, Default, PartialEq)]
pub struct Fields {
    pub pairs: Vec<(String, Cell)>,
}

impl Fields {
    pub fn from_text(text: &str) -> Self {
        Self {
            pairs: fields(text)
                .map(|(key, value)| (key.to_string(), Cell::Text(value.to_string())))
                .collect(),
        }
    }

    pub fn is_empty(&self) -> bool {
        self.pairs.is_empty()
    }

    pub fn get(&self, key: &str) -> Option<&Cell> {
        self.pairs
            .iter()
            .rev()
            .find(|(name, _)| name == key)
            .map(|(_, cell)| cell)
    }

    pub fn text(&self, key: &str) -> String {
        self.get(key).map(Cell::text).unwrap_or_default()
    }

    pub fn f32(&self, key: &str, default: f32) -> f32 {
        self.get(key).and_then(Cell::as_f32).unwrap_or(default)
    }

    pub fn i32(&self, key: &str, default: i32) -> i32 {
        self.get(key).and_then(Cell::as_i32).unwrap_or(default)
    }

    pub fn flag(&self, key: &str) -> bool {
        self.get(key).is_some_and(Cell::as_flag)
    }
}

pub fn fields(text: &str) -> impl Iterator<Item = (&str, &str)> {
    text.split(|c| c == ';' || c == '\n').filter_map(|raw| {
        let rec = raw.trim();
        if rec.is_empty() || rec.starts_with('#') {
            return None;
        }
        rec.split_once('=')
            .map(|(key, value)| (key.trim(), value.trim()))
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
        let bag = Fields {
            pairs: vec![
                ("jump".into(), Cell::Float(5.0)),
                ("on".into(), Cell::Flag(true)),
            ],
        };
        assert_eq!(bag.f32("jump", 0.0), 5.0);
        assert!(bag.flag("on"));
    }
}

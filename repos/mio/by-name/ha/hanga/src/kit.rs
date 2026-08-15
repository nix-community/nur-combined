//! Named fields from a guest `value`. Dicts are the live API; `key=value;` text
//! is only a fallback so old tests and packs still parse.
//!
//! `Atom` is a flat kit scalar. `Node` is the JSON-shaped tree (WIT `cell` arena
//! lifted on the host). Do not confuse `Atom` with the WIT `cell` type.

#[derive(Clone, Debug, PartialEq)]
pub enum Atom {
    Flag(bool),
    Int(i64),
    Float(f64),
    Text(String),
}

impl Atom {
    pub fn text(&self) -> String {
        match self {
            Atom::Flag(true) => "1".into(),
            Atom::Flag(false) => "0".into(),
            Atom::Int(value) => value.to_string(),
            Atom::Float(value) => value.to_string(),
            Atom::Text(text) => text.clone(),
        }
    }

    pub fn as_text(&self) -> Option<&str> {
        match self {
            Atom::Text(text) => Some(text.as_str()),
            _ => None,
        }
    }

    pub fn as_f32(&self) -> Option<f32> {
        match self {
            Atom::Float(value) => Some(*value as f32),
            Atom::Int(value) => Some(*value as f32),
            Atom::Text(text) => text.parse().ok(),
            Atom::Flag(true) => Some(1.0),
            Atom::Flag(false) => Some(0.0),
        }
    }

    pub fn as_i32(&self) -> Option<i32> {
        match self {
            Atom::Int(value) => Some(*value as i32),
            Atom::Float(value) => Some(*value as i32),
            Atom::Text(text) => text.parse().ok(),
            Atom::Flag(true) => Some(1),
            Atom::Flag(false) => Some(0),
        }
    }

    pub fn as_flag(&self) -> bool {
        match self {
            Atom::Flag(value) => *value,
            Atom::Int(value) => *value != 0,
            Atom::Float(value) => *value != 0.0,
            Atom::Text(text) => flag(text),
        }
    }
}

#[derive(Clone, Debug, Default, PartialEq)]
pub enum Node {
    #[default]
    Empty,
    Flag(bool),
    Int(i64),
    Float(f64),
    Text(String),
    Items(Vec<Node>),
    Dict(Vec<(String, Node)>),
}

impl Node {
    pub fn get(&self, key: &str) -> Option<&Node> {
        match self {
            Node::Dict(fields) => fields
                .iter()
                .rev()
                .find(|(name, _)| name == key)
                .map(|(_, node)| node),
            _ => None,
        }
    }

    pub fn items(&self) -> &[Node] {
        match self {
            Node::Items(items) => items,
            _ => &[],
        }
    }

    pub fn is_empty(&self) -> bool {
        match self {
            Node::Empty => true,
            Node::Text(text) if text.is_empty() => true,
            Node::Dict(fields) if fields.is_empty() => true,
            Node::Items(items) if items.is_empty() => true,
            _ => false,
        }
    }

    pub fn text(&self) -> String {
        match self {
            Node::Flag(true) => "1".into(),
            Node::Flag(false) => "0".into(),
            Node::Int(value) => value.to_string(),
            Node::Float(value) => value.to_string(),
            Node::Text(text) => text.clone(),
            _ => String::new(),
        }
    }

    pub fn as_f32(&self) -> Option<f32> {
        match self {
            Node::Float(value) => Some(*value as f32),
            Node::Int(value) => Some(*value as f32),
            Node::Text(text) => text.parse().ok(),
            Node::Flag(true) => Some(1.0),
            Node::Flag(false) => Some(0.0),
            _ => None,
        }
    }

    pub fn as_i32(&self) -> Option<i32> {
        match self {
            Node::Int(value) => Some(*value as i32),
            Node::Float(value) => Some(*value as i32),
            Node::Text(text) => text.parse().ok(),
            Node::Flag(true) => Some(1),
            Node::Flag(false) => Some(0),
            _ => None,
        }
    }

    pub fn as_flag(&self) -> bool {
        match self {
            Node::Flag(value) => *value,
            Node::Int(value) => *value != 0,
            Node::Float(value) => *value != 0.0,
            Node::Text(text) => flag(text),
            _ => false,
        }
    }

    pub fn f32(&self, key: &str, default: f32) -> f32 {
        self.get(key).and_then(Node::as_f32).unwrap_or(default)
    }

    pub fn i32(&self, key: &str, default: i32) -> i32 {
        self.get(key).and_then(Node::as_i32).unwrap_or(default)
    }

    pub fn flag(&self, key: &str) -> bool {
        self.get(key).is_some_and(Node::as_flag)
    }

    pub fn entries(&self) -> Vec<(String, Node)> {
        match self {
            Node::Dict(fields) => fields.clone(),
            Node::Text(text) => match Fields::from_text(text).as_node() {
                Node::Dict(fields) => fields,
                _ => Vec::new(),
            },
            _ => Vec::new(),
        }
    }

    pub fn names(&self) -> Vec<String> {
        match self {
            Node::Text(text) => text
                .split(',')
                .map(|n| n.trim().to_string())
                .filter(|n| !n.is_empty())
                .collect(),
            Node::Items(items) => items
                .iter()
                .filter_map(|item| {
                    let name = match item {
                        Node::Text(text) => text.clone(),
                        Node::Dict(_) => item.get("name").map(Node::text).unwrap_or_default(),
                        _ => item.text(),
                    };
                    (!name.is_empty()).then_some(name)
                })
                .collect(),
            _ => Vec::new(),
        }
    }
}

#[derive(Clone, Debug, Default, PartialEq)]
pub struct Fields {
    pub pairs: Vec<(String, Atom)>,
}

impl Fields {
    pub fn from_text(text: &str) -> Self {
        Self {
            pairs: fields(text)
                .map(|(key, value)| (key.to_string(), Atom::Text(value.to_string())))
                .collect(),
        }
    }

    pub fn is_empty(&self) -> bool {
        self.pairs.is_empty()
    }

    pub fn get(&self, key: &str) -> Option<&Atom> {
        self.pairs
            .iter()
            .rev()
            .find(|(name, _)| name == key)
            .map(|(_, cell)| cell)
    }

    pub fn text(&self, key: &str) -> String {
        self.get(key).map(Atom::text).unwrap_or_default()
    }

    pub fn f32(&self, key: &str, default: f32) -> f32 {
        self.get(key).and_then(Atom::as_f32).unwrap_or(default)
    }

    pub fn i32(&self, key: &str, default: i32) -> i32 {
        self.get(key).and_then(Atom::as_i32).unwrap_or(default)
    }

    pub fn flag(&self, key: &str) -> bool {
        self.get(key).is_some_and(Atom::as_flag)
    }

    pub fn as_node(&self) -> Node {
        Node::Dict(
            self.pairs
                .iter()
                .map(|(key, atom)| (key.clone(), Node::from(atom)))
                .collect(),
        )
    }
}

impl From<&Atom> for Node {
    fn from(atom: &Atom) -> Self {
        match atom {
            Atom::Flag(value) => Node::Flag(*value),
            Atom::Int(value) => Node::Int(*value),
            Atom::Float(value) => Node::Float(*value),
            Atom::Text(text) => Node::Text(text.clone()),
        }
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
                ("jump".into(), Atom::Float(5.0)),
                ("on".into(), Atom::Flag(true)),
            ],
        };
        assert_eq!(bag.f32("jump", 0.0), 5.0);
        assert!(bag.flag("on"));
    }

    #[test]
    fn node_walks_lists() {
        let kit = Node::Dict(vec![(
            "tires".into(),
            Node::Items(vec![Node::Text("wheel".into()), Node::Text("pad".into())]),
        )]);
        assert_eq!(kit.get("tires").unwrap().names(), vec!["wheel", "pad"]);
    }
}

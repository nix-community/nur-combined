use serde::{Deserialize, Serialize};
use std::{
    collections::HashMap,
    fs,
    path::{Component, Path, PathBuf},
};

pub fn home() -> PathBuf {
    std::env::var_os("HOME")
        .map(PathBuf::from)
        .unwrap_or_else(|| PathBuf::from("."))
}
pub fn data_dir() -> PathBuf {
    std::env::var_os("XDG_DATA_HOME")
        .map(PathBuf::from)
        .unwrap_or_else(|| home().join(".local/share"))
        .join("spotlight")
}

#[derive(Clone, Serialize, Deserialize)]
pub struct TextItem {
    pub name: String,
    pub value: String,
    #[serde(default)]
    pub trigger: String,
}
#[derive(Default, Serialize, Deserialize)]
#[serde(default)]
pub struct Store {
    pub favorites: Vec<String>,
    pub usage: HashMap<String, u32>,
    pub snippets: Vec<TextItem>,
    pub links: Vec<TextItem>,
    pub notes: Vec<TextItem>,
    pub reminders: Vec<crate::reminder::Reminder>,
    pub ringing_reminders: Vec<crate::reminder::Reminder>,
    pub obsidian_vault: Option<PathBuf>,
    pub obsidian_disabled: bool,
    pub quick_notes: Vec<crate::quicknote::SavedNote>,
    pub selected_font: Option<String>,
    pub theme: crate::theme::Theme,
    pub interface: crate::interface::Preferences,
    pub desktop_snippets: bool,
    pub emoji_skin_tone: Option<u8>,
    pub emoji_tones: HashMap<String, u8>,
    pub window_layouts: HashMap<String, Vec<crate::windowing::Placement>>,
    pub pinned_clips: Vec<crate::clipboard::Pinned>,
    pub project_context: Option<PathBuf>,
    pub dotfiles_repo: Option<PathBuf>,
    pub keepass_database: Option<PathBuf>,
    pub keepass_key_file: Option<PathBuf>,
    pub last_wallpaper: Option<PathBuf>,
    pub commands: crate::customization::Preferences,
}
impl Store {
    pub fn load() -> Result<Self, String> {
        let p = data_dir().join("data.json");
        if !p.exists() {
            return Ok(Self::default());
        }
        serde_json::from_slice(&fs::read(p).map_err(|e| e.to_string())?).map_err(|e| e.to_string())
    }
    pub fn save(&self) -> Result<(), String> {
        use std::os::unix::fs::PermissionsExt;
        let dir = data_dir();
        fs::create_dir_all(&dir).map_err(|e| e.to_string())?;
        fs::set_permissions(&dir, fs::Permissions::from_mode(0o700)).map_err(|e| e.to_string())?;
        let p = dir.join("data.tmp");
        let bytes = serde_json::to_vec_pretty(self).map_err(|e| e.to_string())?;
        fs::write(&p, bytes).map_err(|e| e.to_string())?;
        fs::set_permissions(&p, fs::Permissions::from_mode(0o600)).map_err(|e| e.to_string())?;
        fs::rename(p, dir.join("data.json")).map_err(|e| e.to_string())
    }
}

pub fn score(query: &str, text: &str) -> Option<i32> {
    let q = query.to_lowercase();
    let t = text.to_lowercase();
    if q.is_empty() {
        return Some(0);
    }
    if t == q {
        return Some(1000);
    }
    if t.starts_with(&q) {
        return Some(800 - t.len() as i32);
    }
    if let Some(pos) = t.find(&q) {
        return Some(600 - pos as i32);
    }
    let mut cursor = 0;
    let mut gap = 0;
    for c in q.chars() {
        let pos = t[cursor..].find(c)?;
        gap += pos as i32;
        cursor += pos + c.len_utf8();
    }
    Some(200 - gap)
}

// A bounded expression parser: no eval, subprocess, or arbitrary code execution.
struct Parser {
    chars: Vec<char>,
    pos: usize,
    depth: usize,
}
impl Parser {
    fn ws(&mut self) {
        while self.chars.get(self.pos).is_some_and(|c| c.is_whitespace()) {
            self.pos += 1;
        }
    }
    fn take(&mut self, c: char) -> bool {
        self.ws();
        if self.chars.get(self.pos) == Some(&c) {
            self.pos += 1;
            true
        } else {
            false
        }
    }
    fn expr(&mut self) -> Option<f64> {
        let mut n = self.term()?;
        loop {
            if self.take('+') {
                n += self.term()?;
            } else if self.take('-') {
                n -= self.term()?;
            } else {
                break;
            }
        }
        Some(n)
    }
    fn term(&mut self) -> Option<f64> {
        let mut n = self.unary()?;
        loop {
            if self.take('*') {
                n *= self.unary()?;
            } else if self.take('/') {
                n /= self.unary()?;
            } else {
                break;
            }
        }
        Some(n)
    }
    fn unary(&mut self) -> Option<f64> {
        self.depth += 1;
        if self.depth > 32 {
            return None;
        }
        let result = if self.take('-') {
            self.unary().map(|n| -n)
        } else if self.take('+') {
            self.unary()
        } else {
            self.power()
        };
        self.depth -= 1;
        result
    }
    fn power(&mut self) -> Option<f64> {
        let n = self.atom()?;
        if self.take('^') {
            Some(n.powf(self.unary()?))
        } else {
            Some(n)
        }
    }
    fn atom(&mut self) -> Option<f64> {
        let mut n = if self.take('(') {
            let n = self.expr()?;
            if !self.take(')') {
                return None;
            }
            n
        } else {
            self.ws();
            let start = self.pos;
            while self
                .chars
                .get(self.pos)
                .is_some_and(|c| c.is_ascii_alphabetic())
            {
                self.pos += 1;
            }
            if self.pos > start {
                let word: String = self.chars[start..self.pos].iter().collect();
                match word.as_str() {
                    "pi" => std::f64::consts::PI,
                    "e" => std::f64::consts::E,
                    "sqrt" | "sin" | "cos" | "tan" | "ln" | "log" | "abs" | "round" => {
                        if !self.take('(') {
                            return None;
                        }
                        let v = self.expr()?;
                        if !self.take(')') {
                            return None;
                        }
                        match word.as_str() {
                            "sqrt" => v.sqrt(),
                            "sin" => v.sin(),
                            "cos" => v.cos(),
                            "tan" => v.tan(),
                            "ln" => v.ln(),
                            "log" => v.log10(),
                            "abs" => v.abs(),
                            _ => v.round(),
                        }
                    }
                    _ => return None,
                }
            } else {
                while self
                    .chars
                    .get(self.pos)
                    .is_some_and(|c| c.is_ascii_digit() || *c == '.')
                {
                    self.pos += 1;
                }
                self.chars[start..self.pos]
                    .iter()
                    .collect::<String>()
                    .parse()
                    .ok()?
            }
        };
        if self.take('%') {
            n /= 100.;
        }
        Some(n)
    }
}
fn eval(text: &str) -> Option<f64> {
    if text.len() > 256 {
        return None;
    }
    let mut p = Parser {
        chars: text.chars().collect(),
        pos: 0,
        depth: 0,
    };
    let n = p.expr()?;
    p.ws();
    if p.pos == p.chars.len() && n.is_finite() {
        Some(n)
    } else {
        None
    }
}
fn unit(s: &str) -> Option<(&'static str, f64)> {
    Some(match s {
        "mm" | "millimeter" | "millimeters" | "millimetre" | "millimetres" => ("length", 0.001),
        "cm" | "centimeter" | "centimeters" | "centimetre" | "centimetres" => ("length", 0.01),
        "m" | "meter" | "meters" | "metre" | "metres" => ("length", 1.),
        "km" | "kilometer" | "kilometers" | "kilometre" | "kilometres" => ("length", 1000.),
        "in" | "inch" | "inches" => ("length", 0.0254),
        "ft" | "foot" | "feet" => ("length", 0.3048),
        "yd" | "yard" | "yards" => ("length", 0.9144),
        "mi" | "mile" | "miles" => ("length", 1609.344),
        "g" | "gram" | "grams" => ("mass", 1.),
        "kg" | "kilogram" | "kilograms" => ("mass", 1000.),
        "lb" | "lbs" | "pound" | "pounds" => ("mass", 453.59237),
        "oz" | "ounce" | "ounces" => ("mass", 28.349523125),
        "s" | "sec" | "second" | "seconds" => ("time", 1.),
        "min" | "minute" | "minutes" => ("time", 60.),
        "h" | "hr" | "hour" | "hours" => ("time", 3600.),
        "d" | "day" | "days" => ("time", 86400.),
        "ml" | "milliliter" | "milliliters" | "millilitre" | "millilitres" => ("volume", 0.001),
        "l" | "liter" | "liters" | "litre" | "litres" => ("volume", 1.),
        "m2" | "m²" | "sqm" => ("area", 1.),
        "km2" | "km²" => ("area", 1e6),
        "ft2" | "ft²" | "sqft" => ("area", 0.09290304),
        "acre" | "acres" => ("area", 4046.8564224),
        "ha" | "hectare" | "hectares" => ("area", 10000.),
        "m/s" => ("speed", 1.),
        "km/h" | "kph" | "kmh" => ("speed", 1. / 3.6),
        "mph" => ("speed", 0.44704),
        "b" => ("data", 1.),
        "kb" => ("data", 1000.),
        "mb" => ("data", 1e6),
        "gb" => ("data", 1e9),
        "kib" => ("data", 1024.),
        "mib" => ("data", 1048576.),
        "gib" => ("data", 1073741824.),
        _ => return None,
    })
}
pub fn calculate(text: &str) -> Option<String> {
    let t = text
        .trim()
        .to_lowercase()
        .replace('×', "*")
        .replace('÷', "/")
        .replace('−', "-")
        .replace('°', "")
        .replace("celsius", "c")
        .replace("fahrenheit", "f")
        .replace("kelvin", "k")
        .replace(" in ", " to ");
    let format = |n: f64| {
        let s = format!("{n:.10}");
        s.trim_end_matches('0').trim_end_matches('.').to_string()
    };
    if let Some((lhs, target)) = t.split_once(" to ") {
        let lhs = lhs.trim();
        let at = lhs.find(|c: char| c.is_ascii_alphabetic())?;
        let n = eval(lhs[..at].trim())?;
        let source = lhs[at..].trim();
        let target = target.trim();
        let v = if ["c", "f", "k"].contains(&source) && ["c", "f", "k"].contains(&target) {
            let c = match source {
                "f" => (n - 32.) * 5. / 9.,
                "k" => n - 273.15,
                _ => n,
            };
            match target {
                "f" => c * 9. / 5. + 32.,
                "k" => c + 273.15,
                _ => c,
            }
        } else {
            let (a, x) = unit(source)?;
            let (b, y) = unit(target)?;
            if a != b {
                return None;
            }
            n * x / y
        };
        if !v.is_finite() {
            return None;
        }
        return Some(format!("{} {}", format(v), target));
    }
    if !t.chars().any(|c| c.is_ascii_digit()) && t != "pi" && t != "e" {
        return None;
    }
    eval(&t).map(format)
}

pub fn hidden_path(path: &Path) -> bool {
    path.components().any(
        |part| matches!(part, Component::Normal(name) if name.as_encoded_bytes().starts_with(b".")),
    )
}

pub fn index_files() -> Result<Vec<PathBuf>, String> {
    index_files_in(&home())
}
pub(crate) fn index_files_in(root: &Path) -> Result<Vec<PathBuf>, String> {
    let rules = crate::fileignore::Rules::load(root)?;
    let mut out = Vec::new();
    let mut pending = vec![(root.to_path_buf(), 0u8)];
    while let Some((dir, depth)) = pending.pop() {
        let Ok(entries) = fs::read_dir(dir) else {
            continue;
        };
        for entry in entries.flatten() {
            let name = entry.file_name();
            let s = name.to_string_lossy();
            if s.starts_with('.')
                || ["node_modules", "target", "vendor", "__pycache__"].contains(&s.as_ref())
            {
                continue;
            }
            let Ok(ty) = entry.file_type() else { continue };
            if ty.is_symlink() || rules.excludes(&entry.path(), ty.is_dir()) {
                continue;
            }
            out.push(entry.path());
            if out.len() >= 25000 {
                return Ok(out);
            }
            if ty.is_dir() && depth < 5 {
                pending.push((entry.path(), depth + 1));
            }
        }
    }
    Ok(out)
}
pub fn encode(text: &str) -> String {
    text.bytes()
        .map(|c| {
            if c.is_ascii_alphanumeric() || b"-_.~".contains(&c) {
                (c as char).to_string()
            } else {
                format!("%{c:02X}")
            }
        })
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn arithmetic() {
        for (input, want) in [
            ("2+3*4", "14"),
            ("(2+3)*4", "20"),
            ("2^3^2", "512"),
            ("-2^2", "-4"),
            ("200*15%", "30"),
            ("sqrt(81)", "9"),
            ("10 km to mi", "6.2137119224"),
            ("32 f to c", "0"),
            ("1 gib to mib", "1024 mib"),
            ("10 kilometres in miles", "6.2137119224 miles"),
            ("25 °C to °F", "77 f"),
            ("32 fahrenheit to celsius", "0 c"),
            ("1 litre to ml", "1000 ml"),
            ("100 km/h to mph", "62.1371192237 mph"),
            ("1 acre to m2", "4046.8564224 m2"),
        ] {
            let got = calculate(input).unwrap();
            assert!(got.starts_with(want), "{input}: {got}");
        }
    }
    #[test]
    fn rejects_bad_input() {
        for s in [
            "1/0",
            "sqrt(-1)",
            "exec(1)",
            "2 garbage",
            "1 kg to km",
            "2**3",
            "1e999",
        ] {
            assert!(calculate(s).is_none(), "{s}");
        }
        assert!(calculate(&"(".repeat(1000)).is_none());
    }
    #[test]
    fn fuzzy_unicode() {
        assert!(score("ff", "Firefox").is_some());
        assert!(score("é", "Café").is_some());
        assert!(score("xyz", "Firefox").is_none());
        assert!(score("fire", "Firefox") > score("fire", "Open Firefox"));
    }
    #[test]
    fn url_encoding() {
        assert_eq!(encode("a&b é"), "a%26b%20%C3%A9");
    }
}

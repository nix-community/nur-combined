use std::sync::OnceLock;

pub struct Emoji {
    pub symbol: &'static str,
    pub name: &'static str,
    pub category: String,
    pub keywords: String,
}

// A compact everyday selection, in default browsing order. The picker promotes
// favorites and the user's actual usage ahead of this order.
const EVERYDAY: &[&str] = &[
    "😂",
    "❤️",
    "🤣",
    "👍",
    "😊",
    "🙏",
    "🥰",
    "😍",
    "😘",
    "😁",
    "😀",
    "😄",
    "😃",
    "😅",
    "🥹",
    "😎",
    "🤔",
    "😉",
    "🙌",
    "👏",
    "🎉",
    "🔥",
    "✨",
    "✅",
    "💯",
    "💪",
    "👌",
    "👋",
    "🤝",
    "🤗",
    "🥳",
    "😢",
    "😭",
    "😔",
    "😴",
    "😬",
    "😳",
    "🙄",
    "😮",
    "🤦",
    "🤷",
    "😡",
    "🤯",
    "🫡",
    "👀",
    "💖",
    "💕",
    "💙",
    "💚",
    "💛",
    "💜",
    "🧡",
    "🤍",
    "💔",
    "❌",
    "⚠️",
    "⭐",
    "🌟",
    "🎂",
    "🎁",
    "☕",
    "🍕",
    "🍔",
    "🍎",
    "🎵",
    "🎧",
    "📸",
    "🐶",
    "🐱",
    "🐧",
    "🌞",
    "🌈",
    "🌻",
    "🚀",
    "💻",
    "📱",
    "💡",
    "📝",
    "📅",
    "⏰",
    "📌",
    "📍",
    "🏠",
    "⚡",
    "👎",
    "👩‍💻",
    "👨‍💻",
    "🇦🇺",
    "👍🏻",
    "👍🏼",
    "👍🏽",
    "👍🏾",
    "👍🏿",
];

/// Use Unicode's names and exact sequences for the everyday selection.
pub fn catalog() -> &'static [Emoji] {
    static CATALOG: OnceLock<Vec<Emoji>> = OnceLock::new();
    CATALOG.get_or_init(|| {
        let mut entries = Vec::new();
        let mut group = "";
        let mut subgroup = "";
        for line in include_str!("../assets/emoji-test.txt").lines() {
            if let Some(value) = line.strip_prefix("# group: ") {
                group = value;
            } else if let Some(value) = line.strip_prefix("# subgroup: ") {
                subgroup = value;
            } else if let Some((sequence, description)) = line.split_once('#') {
                let Some((_, status)) = sequence.split_once(';') else {
                    continue;
                };
                if !matches!(status.trim(), "fully-qualified" | "component") {
                    continue;
                }
                // Description is: glyph, emoji version, then the full English name.
                let mut parts = description.trim().splitn(3, ' ');
                let symbol = parts.next().expect("Unicode glyph");
                if !EVERYDAY.contains(&symbol) {
                    continue;
                }
                let _version = parts.next().expect("Unicode emoji version");
                let name = parts.next().expect("Unicode emoji name");
                let category = format!("{group} · {}", subgroup.replace('-', " "));
                let aliases = match symbol {
                    "😀" => "happy smile",
                    "😂" => "laughing tears joy",
                    "🥰" => "love hearts",
                    "😎" => "cool sunglasses",
                    "👍" => "thumbs up yes",
                    "👎" => "thumbs down no",
                    "👋" => "wave hello",
                    "🙏" => "thanks please pray",
                    "🎉" => "celebrate party",
                    "🔥" => "fire hot",
                    "❤️" => "heart love",
                    "✅" => "check done tick",
                    "❌" => "cross cancel",
                    "⚡" => "lightning fast",
                    "🚀" => "rocket launch",
                    "💻" => "computer laptop",
                    "🐧" => "penguin linux",
                    "☕" => "coffee tea",
                    _ => "",
                };
                entries.push(Emoji {
                    symbol,
                    name,
                    keywords: format!("{aliases} {name} {symbol} {category}"),
                    category,
                });
            }
        }
        entries.sort_by_key(|entry| {
            EVERYDAY
                .iter()
                .position(|symbol| *symbol == entry.symbol)
                .unwrap()
        });
        // Preserve useful non-emoji symbols from the original picker.
        for (symbol, name) in [
            ("→", "right arrow"),
            ("←", "left arrow"),
            ("✓", "tick check"),
            ("©", "copyright"),
            ("°", "degree"),
        ] {
            entries.push(Emoji {
                symbol,
                name,
                category: "Text symbols".into(),
                keywords: format!("{name} {symbol} text symbols"),
            });
        }
        entries
    })
}

pub fn base(symbol: &str) -> String {
    symbol
        .chars()
        .filter(|c| !('\u{1f3fb}'..='\u{1f3ff}').contains(c) && *c != '\u{fe0f}')
        .collect()
}
pub fn tone(symbol: &str) -> Option<u8> {
    symbol
        .chars()
        .find(|c| ('\u{1f3fb}'..='\u{1f3ff}').contains(c))
        .map(|c| (c as u32 - 0x1f3fa) as u8)
}
pub fn variant(symbol: &str, preferred: Option<u8>) -> String {
    let Some(preferred) = preferred.filter(|n| (1..=5).contains(n)) else {
        return symbol.into();
    };
    if tone(symbol).is_some() {
        return symbol.into();
    }
    static VARIANTS: OnceLock<Vec<String>> = OnceLock::new();
    let variants = VARIANTS.get_or_init(|| {
        include_str!("../assets/emoji-test.txt")
            .lines()
            .filter_map(|line| {
                let (sequence, description) = line.split_once('#')?;
                if sequence.split_once(';')?.1.trim() != "fully-qualified" {
                    return None;
                }
                let glyph = description.split_whitespace().next()?;
                tone(glyph).map(|_| glyph.to_owned())
            })
            .collect()
    });
    let wanted = base(symbol);
    variants
        .iter()
        .find(|glyph| {
            base(glyph) == wanted
                && glyph
                    .chars()
                    .filter(|c| ('\u{1f3fb}'..='\u{1f3ff}').contains(c))
                    .all(|c| c as u32 == 0x1f3fa + u32::from(preferred))
        })
        .cloned()
        .unwrap_or_else(|| symbol.into())
}
pub fn kaomoji() -> &'static [(&'static str, &'static str)] {
    &[
        ("¯\\_(ツ)_/¯", "shrug whatever"),
        ("(╯°□°)╯︵ ┻━┻", "table flip angry"),
        ("┬─┬ノ( º _ ºノ)", "table unflip calm"),
        ("(づ｡◕‿‿◕｡)づ", "hug love"),
        ("(ಠ_ಠ)", "disapproval stare"),
        ("(ง'̀-'́)ง", "fight determined"),
        ("(｡♥‿♥｡)", "love happy"),
        ("(ᵔᴥᵔ)", "bear cute"),
        ("(=^･ω･^=)", "cat cute"),
        ("(✿◠‿◠)", "smile happy"),
        ("(ಥ﹏ಥ)", "cry sad tears"),
        ("(－‸ლ)", "facepalm"),
        ("ᕕ( ᐛ )ᕗ", "run excited"),
        ("ヽ(•‿•)ノ", "cheer celebrate"),
        ("(☞ﾟヮﾟ)☞", "point finger guns"),
        ("m(_ _)m", "bow sorry apologize"),
    ]
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::collections::HashSet;

    #[test]
    fn everyday_selection_preserves_sequences_and_excludes_unwanted_emoji() {
        let entries = catalog();
        assert_eq!(entries.len(), EVERYDAY.len() + 5);
        assert!(entries.len() < 100);
        assert!(!entries.iter().any(|entry| entry.symbol == "🍆"));
        assert!(!entries.iter().any(|entry| entry.symbol == "🫪"));
        assert_eq!(
            entries
                .iter()
                .map(|e| e.symbol)
                .collect::<HashSet<_>>()
                .len(),
            entries.len()
        );
        for (symbol, name) in [
            ("🐧", "penguin"),
            ("👍🏿", "thumbs up: dark skin tone"),
            ("👩‍💻", "woman technologist"),
            ("🇦🇺", "flag: Australia"),
            ("😀", "grinning face"),
            ("❤️", "red heart"),
        ] {
            assert!(
                entries.iter().any(|e| e.symbol == symbol && e.name == name),
                "Missing {name}"
            );
        }
        assert!(
            entries
                .iter()
                .any(|e| e.symbol == "🐧" && e.keywords.contains("linux"))
        );
    }
    #[test]
    fn validated_tones_and_zwj_sequences() {
        assert_eq!(variant("👩‍💻", Some(3)), "👩🏽‍💻");
        assert_eq!(variant("👋", Some(5)), "👋🏿");
        assert_eq!(variant("❤️", Some(2)), "❤️");
        assert_eq!(variant("👍🏻", Some(5)), "👍🏻");
        assert_eq!(tone("👩🏽‍💻"), Some(3));
        assert_eq!(base("👩🏽‍💻"), base("👩‍💻"));
        assert!(kaomoji().iter().any(|(_, name)| name.contains("shrug")));
    }
}

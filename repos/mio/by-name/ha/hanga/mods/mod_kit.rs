fn kit_get<'a>(text: &'a str, key: &str) -> Option<&'a str> {
    for rec in text.split(|c| c == ';' || c == '\n') {
        let rec = rec.trim();
        if rec.is_empty() || rec.starts_with('#') {
            continue;
        }
        let Some((k, v)) = rec.split_once('=') else {
            continue;
        };
        if k.trim() == key {
            return Some(v.trim());
        }
    }
    None
}

fn kit_f32(text: &str, key: &str, default: f32) -> f32 {
    kit_get(text, key)
        .and_then(|v| v.parse().ok())
        .unwrap_or(default)
}

fn kit_bool(text: &str, key: &str) -> bool {
    matches!(
        kit_get(text, key).unwrap_or("0").to_ascii_lowercase().as_str(),
        "1" | "true" | "yes" | "on"
    )
}

fn wire_empty() -> hanga::engine::host::Payload {
    hanga::engine::host::Payload::Empty
}

fn wire_text(text: impl Into<String>) -> hanga::engine::host::Payload {
    hanga::engine::host::Payload::Text(text.into())
}

fn wire_as_text(payload: &hanga::engine::host::Payload) -> Option<&str> {
    match payload {
        hanga::engine::host::Payload::Text(text) => Some(text.as_str()),
        _ => None,
    }
}

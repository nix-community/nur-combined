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

fn greet_peers() {
    #[cfg(target_arch = "wasm32")]
    {
        for peer in hanga::engine::host::peers() {
            let _ = hanga::engine::host::ask(&peer, "hello", &hanga::engine::host::Payload::Empty);
        }
    }
}

#[allow(dead_code)]
fn host_peers() -> Vec<String> {
    #[cfg(target_arch = "wasm32")]
    {
        hanga::engine::host::peers()
    }
    #[cfg(not(target_arch = "wasm32"))]
    {
        Vec::new()
    }
}

#[allow(dead_code)]
fn beside_peer(name: &str) -> bool {
    host_peers().iter().any(|peer| peer == name)
}

fn host_voxel_at(x: i32, y: i32, z: i32) -> String {
    #[cfg(target_arch = "wasm32")]
    {
        hanga::engine::host::voxel_at(x, y, z)
    }
    #[cfg(not(target_arch = "wasm32"))]
    {
        let _ = (x, y, z);
        "air".into()
    }
}

fn payload_i64(payload: &hanga::engine::host::Payload, key: &str) -> i64 {
    match payload {
        hanga::engine::host::Payload::Bag(fields) => fields
            .iter()
            .find(|field| field.key == key)
            .and_then(|field| match &field.value {
                hanga::engine::host::Atom::Int(v) => Some(*v),
                hanga::engine::host::Atom::Text(t) => t.parse().ok(),
                _ => None,
            })
            .unwrap_or(0),
        _ => 0,
    }
}

fn host_log(level: &str, message: &str) {
    #[cfg(target_arch = "wasm32")]
    hanga::engine::host::log(level, message);
    #[cfg(not(target_arch = "wasm32"))]
    {
        let _ = (level, message);
    }
}

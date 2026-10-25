use spotlight_plugin::{Action, ResultItem};

#[unsafe(no_mangle)]
pub extern "C" fn spotlight_run() {
    let Ok(request) = spotlight_plugin::request() else {
        return;
    };
    let _ = spotlight_plugin::status("Converting text inside the WASM sandbox…");
    for (id, title, text) in [
        ("upper", "Uppercase", request.query.to_uppercase()),
        ("lower", "Lowercase", request.query.to_lowercase()),
        (
            "count",
            "Character count",
            request.query.chars().count().to_string(),
        ),
    ] {
        let _ = spotlight_plugin::emit(ResultItem {
            id: id.into(),
            title: format!("{title}: {}", text.chars().take(180).collect::<String>()),
            subtitle: "Sandboxed Rust plugin · Enter copies".into(),
            icon: Some("insert-text-symbolic".into()),
            action: Some(Action::Copy { text }),
        });
    }
}

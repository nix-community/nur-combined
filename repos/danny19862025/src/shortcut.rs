use gtk::{gio, glib, prelude::*};
pub fn install() -> Result<(), String> {
    let bus = gio::bus_get_sync(gio::BusType::Session, None::<&gio::Cancellable>)
        .map_err(|e| e.to_string())?;
    let call = |name: &str, args: &glib::Variant| {
        bus.call_sync(
            Some("org.kde.kglobalaccel"),
            "/kglobalaccel",
            "org.kde.KGlobalAccel",
            name,
            Some(args),
            None,
            gio::DBusCallFlags::NONE,
            2000,
            None::<&gio::Cancellable>,
        )
        .map_err(|e| e.to_string())
    };
    let key = 0x10000020i32; // Qt::MetaModifier | Qt::Key_Space
    let available = call(
        "isGlobalShortcutAvailable",
        &(key, "spotlight.desktop").to_variant(),
    )?
    .get::<(bool,)>()
    .ok_or("Unexpected shortcut availability response")?
    .0;
    let owner = call("action", &(key,).to_variant())?
        .get::<(Vec<String>,)>()
        .ok_or("Unexpected shortcut owner response")?
        .0;
    let already_ours = owner.first().is_some_and(|s| s == "spotlight.desktop");
    if !available && !already_ours {
        return Err("Meta+Space is already assigned. Choose a shortcut for Spotlight in KDE System Settings → Keyboard → Shortcuts.".into());
    }
    let base = std::env::var_os("XDG_DATA_HOME")
        .map(std::path::PathBuf::from)
        .unwrap_or_else(|| crate::core::home().join(".local/share"));
    std::fs::create_dir_all(base.join("kglobalaccel")).map_err(|e| e.to_string())?;
    std::fs::copy(
        base.join("applications/spotlight.desktop"),
        base.join("kglobalaccel/spotlight.desktop"),
    )
    .map_err(|e| e.to_string())?;
    let id = vec![
        "spotlight.desktop",
        "_launch",
        "Spotlight",
        "Open Spotlight",
    ];
    call("doRegister", &(id.clone(),).to_variant())?;
    call("setShortcut", &(id.clone(), vec![key], 0u32).to_variant())?;
    call("setForeignShortcut", &(id.clone(), vec![key]).to_variant())?;
    let registered = call("shortcut", &(id,).to_variant())?
        .get::<(Vec<i32>,)>()
        .ok_or("Unexpected shortcut response")?
        .0;
    if !registered.contains(&key) {
        return Err("KDE did not register Meta+Space. Assign it in Keyboard → Shortcuts.".into());
    }
    println!("Meta+Space registered for Spotlight.");
    Ok(())
}

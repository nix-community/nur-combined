use gtk::glib;
use std::{
    fs,
    io::Write,
    path::{Path, PathBuf},
};

fn location() -> PathBuf {
    std::env::var_os("XDG_CONFIG_HOME")
        .map(PathBuf::from)
        .filter(|p| p.is_absolute())
        .unwrap_or_else(|| crate::core::home().join(".config"))
        .join("autostart/spotlight.desktop")
}
fn executable() -> Result<PathBuf, String> {
    // A packaged launcher can point at its own wrapper so the autostart entry
    // starts the wrapped process with the environment it needs.
    if let Some(path) = std::env::var_os("SPOTLIGHT_EXECUTABLE") {
        let path = PathBuf::from(path);
        if path.is_absolute() {
            return Ok(path);
        }
    }
    let executable = std::env::current_exe().map_err(|e| e.to_string())?;
    let home = crate::core::home();
    let wrapper = home.join(".local/bin/spotlight");
    if executable == home.join(".local/lib/spotlight/spotlight") && wrapper.is_file() {
        Ok(wrapper)
    } else {
        Ok(executable)
    }
}
fn desktop_entry(executable: &Path) -> Result<String, String> {
    let path = executable.to_str().ok_or("Executable path is not UTF-8")?;
    if !executable.is_absolute() || path.contains(['\n', '\r']) {
        return Err("Autostart requires an absolute executable path without line breaks".into());
    }
    // Desktop Exec quoting is not shell quoting. KeyFile then escapes the value
    // for the desktop file itself (notably the second layer of backslashes).
    let mut quoted = String::from("\"");
    for c in path.chars() {
        match c {
            '%' => quoted.push_str("%%"),
            '"' | '`' | '$' | '\\' => {
                quoted.push('\\');
                quoted.push(c);
            }
            _ => quoted.push(c),
        }
    }
    quoted.push_str("\" --background");
    let file = glib::KeyFile::new();
    for (key, value) in [
        ("Type", "Application"),
        ("Name", "Spotlight"),
        ("Comment", "Keep Spotlight ready for your launcher shortcut"),
        ("Exec", quoted.as_str()),
        ("Icon", "spotlight"),
        ("Terminal", "false"),
        ("StartupNotify", "false"),
        ("X-Spotlight-Managed", "true"),
    ] {
        file.set_string("Desktop Entry", key, value);
    }
    Ok(file.to_data().into())
}
fn configure_at(path: &Path, executable: &Path, enabled: bool) -> Result<(), String> {
    match fs::symlink_metadata(path) {
        Ok(meta) => {
            let file = glib::KeyFile::new();
            if !meta.is_file()
                || file.load_from_file(path, glib::KeyFileFlags::NONE).is_err()
                || file.boolean("Desktop Entry", "X-Spotlight-Managed") != Ok(true)
            {
                return Err(format!(
                    "{} already exists and is not managed by Spotlight; edit it manually",
                    path.display()
                ));
            }
        }
        Err(e) if e.kind() == std::io::ErrorKind::NotFound => {
            if !enabled {
                return Ok(());
            }
        }
        Err(e) => return Err(e.to_string()),
    }
    if !enabled {
        return fs::remove_file(path).map_err(|e| e.to_string());
    }
    let contents = desktop_entry(executable)?;
    fs::create_dir_all(path.parent().unwrap()).map_err(|e| e.to_string())?;
    let temporary = path.with_file_name(format!(".spotlight-{}.tmp", std::process::id()));
    let result = (|| -> std::io::Result<()> {
        use std::os::unix::fs::OpenOptionsExt;
        let mut output = fs::OpenOptions::new()
            .write(true)
            .create_new(true)
            .mode(0o600)
            .open(&temporary)?;
        output.write_all(contents.as_bytes())?;
        output.sync_all()?;
        fs::rename(&temporary, path)
    })();
    if result.is_err() {
        let _ = fs::remove_file(&temporary);
    }
    result.map_err(|e| e.to_string())
}
pub fn configure(enabled: bool) -> Result<(), String> {
    let path = location();
    configure_at(&path, &executable()?, enabled)?;
    println!(
        "{}: {}",
        if enabled {
            "Login autostart enabled"
        } else {
            "Login autostart disabled"
        },
        path.display()
    );
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn safe_and_reversible_desktop_entry() {
        let root = std::env::temp_dir().join(format!("spotlight-autostart-{}", std::process::id()));
        fs::create_dir_all(&root).unwrap();
        let target = root.join("autostart/spotlight.desktop");
        let executable = root.join("space $d `x` \\ \"quote\" 100%/spotlight");
        configure_at(&target, &executable, true).unwrap();
        let file = glib::KeyFile::new();
        file.load_from_file(&target, glib::KeyFileFlags::NONE)
            .unwrap();
        let exec = file.string("Desktop Entry", "Exec").unwrap();
        let args = glib::shell_parse_argv(&exec).unwrap();
        assert_eq!(args.len(), 2);
        assert_eq!(
            args[0].to_str().unwrap().replace("%%", "%"),
            executable.to_str().unwrap()
        );
        assert_eq!(args[1], "--background");
        configure_at(&target, &executable, true).unwrap();
        configure_at(&target, &executable, false).unwrap();
        configure_at(&target, &executable, false).unwrap();
        assert!(!target.exists());
        fs::write(&target, "unrelated entry").unwrap();
        assert!(configure_at(&target, &executable, true).is_err());
        assert!(configure_at(&target, &executable, false).is_err());
        assert_eq!(fs::read_to_string(&target).unwrap(), "unrelated entry");
        fs::remove_dir_all(root).unwrap();
    }
}

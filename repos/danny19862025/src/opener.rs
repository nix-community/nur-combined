use gtk::{gio, prelude::*};

pub fn open(uri: &str) -> Result<(), String> {
    let file = gio::File::for_uri(uri);
    if file.path().is_some_and(|path| path.is_dir()) {
        open_folder(uri)
    } else {
        gio::AppInfo::launch_default_for_uri(uri, None::<&gio::AppLaunchContext>)
            .map_err(|error| error.to_string())
    }
}

fn is_file_manager(app: &gio::DesktopAppInfo) -> bool {
    let categories = app.categories().unwrap_or_default();
    !app.boolean("Terminal")
        && categories
            .split(';')
            .any(|category| category == "FileManager")
        && !categories
            .split(';')
            .any(|category| category == "TerminalEmulator")
}

fn open_folder(uri: &str) -> Result<(), String> {
    // Folder MIME associations can point at terminal launchers (for example Kitty).
    // Ask the desktop file manager to show the folder itself instead.
    let manager =
        gio::bus_get_sync(gio::BusType::Session, None::<&gio::Cancellable>).and_then(|bus| {
            bus.call_sync(
                Some("org.freedesktop.FileManager1"),
                "/org/freedesktop/FileManager1",
                "org.freedesktop.FileManager1",
                "ShowFolders",
                Some(&(vec![uri], "").to_variant()),
                None,
                gio::DBusCallFlags::NONE,
                3000,
                None::<&gio::Cancellable>,
            )
        });
    if manager.is_ok() {
        return Ok(());
    }

    // Desktops without FileManager1 can still launch a registered file manager.
    // Keep the configured default first when it really is a file manager.
    let candidates = gio::AppInfo::default_for_type("inode/directory", false)
        .into_iter()
        .chain(gio::AppInfo::all_for_type("inode/directory"));
    let mut seen = std::collections::HashSet::new();
    let mut last_error = None;
    for app in candidates {
        let Some(id) = app.id() else {
            continue;
        };
        if !seen.insert(id.clone()) {
            continue;
        }
        let Some(desktop) = gio::DesktopAppInfo::new(&id) else {
            continue;
        };
        if !is_file_manager(&desktop) {
            continue;
        }
        match app.launch(&[gio::File::for_uri(uri)], None::<&gio::AppLaunchContext>) {
            Ok(()) => return Ok(()),
            Err(error) => last_error = Some(error.to_string()),
        }
    }
    Err(last_error.unwrap_or_else(|| "No file manager could open this folder. Install or enable a file manager such as Files, Dolphin, or Thunar.".into()))
}

#[cfg(test)]
mod tests {
    use super::*;
    use gtk::glib;
    #[test]
    fn folder_fallback_excludes_terminal_and_disk_tools() {
        let app = |categories: &str, terminal: bool| {
            let key = glib::KeyFile::new();
            key.load_from_data(&format!("[Desktop Entry]\nType=Application\nName=Fixture\nExec=true %U\nCategories={categories}\nTerminal={terminal}\n"), glib::KeyFileFlags::NONE).unwrap();
            gio::DesktopAppInfo::from_keyfile(&key).unwrap()
        };
        assert!(is_file_manager(&app(
            "GNOME;GTK;Utility;Core;FileManager;",
            false
        )));
        assert!(!is_file_manager(&app("System;TerminalEmulator;", false)));
        assert!(!is_file_manager(&app("FileManager;", true)));
        assert!(!is_file_manager(&app(
            "FileManager;TerminalEmulator;",
            false
        )));
        assert!(!is_file_manager(&app("System;Filesystem;", false)));
    }
}

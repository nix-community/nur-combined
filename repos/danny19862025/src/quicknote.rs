use gtk::glib;
use serde::{Deserialize, Serialize};
use std::{
    collections::HashMap,
    fs,
    io::Write,
    path::{Path, PathBuf},
};

#[derive(Clone, Debug)]
pub struct Vault {
    pub path: PathBuf,
    pub name: String,
}

#[derive(Deserialize)]
struct Registry {
    vaults: HashMap<String, RegisteredVault>,
}
#[derive(Deserialize)]
struct RegisteredVault {
    path: PathBuf,
}

pub fn validate_vault(path: &Path) -> Result<PathBuf, String> {
    let path = path
        .canonicalize()
        .map_err(|_| "Vault folder does not exist")?;
    if !path.is_dir() || !path.join(".obsidian").is_dir() {
        return Err("Choose an existing Obsidian vault folder containing .obsidian".into());
    }
    Ok(path)
}

pub fn discover() -> Vec<Vault> {
    let config = std::env::var_os("XDG_CONFIG_HOME")
        .map(PathBuf::from)
        .unwrap_or_else(|| crate::core::home().join(".config"));
    let mut vaults = Vec::new();
    for registry in [
        config.join("obsidian/obsidian.json"),
        crate::core::home().join(".var/app/md.obsidian.Obsidian/config/obsidian/obsidian.json"),
    ] {
        let Some(registry) = fs::read(registry)
            .ok()
            .and_then(|bytes| serde_json::from_slice::<Registry>(&bytes).ok())
        else {
            continue;
        };
        for entry in registry.vaults.values() {
            if let Ok(path) = validate_vault(&entry.path) {
                if vaults.iter().any(|v: &Vault| v.path == path) {
                    continue;
                }
                let name = path
                    .file_name()
                    .unwrap_or_default()
                    .to_string_lossy()
                    .to_string();
                vaults.push(Vault { path, name });
            }
        }
    }
    vaults.sort_by(|a, b| a.path.cmp(&b.path));
    vaults
}

pub fn query(text: &str) -> Option<&str> {
    let text = text.trim();
    let lower = text.to_ascii_lowercase();
    for prefix in ["quick note", "note"] {
        if lower == prefix {
            return Some("");
        }
        if let Some(rest) = lower.strip_prefix(prefix)
            && rest.starts_with(char::is_whitespace)
        {
            return Some(text[prefix.len()..].trim());
        }
    }
    None
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct SavedNote {
    pub title: String,
    pub path: PathBuf,
    pub obsidian: bool,
}

pub fn folder(vault: Option<&Path>, local: &Path) -> Result<PathBuf, String> {
    match vault {
        Some(path) => Ok(validate_vault(path)?.join("Spotlight Quick Notes")),
        None => Ok(local.join("quick-notes")),
    }
}

pub fn save(text: &str, vault: Option<&Path>, local: &Path) -> Result<SavedNote, String> {
    use std::os::unix::fs::{DirBuilderExt, OpenOptionsExt};
    if text.trim().is_empty() {
        return Err("Write a note before saving".into());
    }
    if text.len() > 1024 * 1024 {
        return Err("Quick notes can contain up to 1 MiB of text".into());
    }
    let folder = folder(vault, local)?;
    let root = match vault {
        Some(path) => validate_vault(path)?,
        None => {
            fs::DirBuilder::new()
                .recursive(true)
                .mode(0o700)
                .create(local)
                .map_err(|e| e.to_string())?;
            local.canonicalize().map_err(|e| e.to_string())?
        }
    };
    fs::DirBuilder::new()
        .recursive(true)
        .mode(0o700)
        .create(&folder)
        .map_err(|e| e.to_string())?;
    let folder = folder.canonicalize().map_err(|e| e.to_string())?;
    if !folder.starts_with(&root) {
        return Err("The quick notes folder points outside the selected vault".into());
    }
    let title: String = text
        .lines()
        .find(|line| !line.trim().is_empty())
        .unwrap_or("Quick note")
        .trim_start_matches('#')
        .trim()
        .chars()
        .take(80)
        .collect();
    let title = if title.is_empty() {
        "Quick note".to_string()
    } else {
        title
    };
    let safe: String = title
        .chars()
        .take(48)
        .map(|c| {
            if c.is_alphanumeric() || c == ' ' || c == '-' || c == '_' {
                c
            } else {
                '-'
            }
        })
        .collect();
    let now = glib::DateTime::now_local().map_err(|e| e.to_string())?;
    let stamp = now.format("%Y-%m-%d %H-%M-%S").map_err(|e| e.to_string())?;
    let id = glib::uuid_string_random();
    let path = folder.join(format!("{stamp} {safe} {}.md", &id[..8]));
    let mut file = fs::OpenOptions::new()
        .create_new(true)
        .write(true)
        .mode(0o600)
        .open(&path)
        .map_err(|e| e.to_string())?;
    file.write_all(
        if text.ends_with('\n') {
            text.to_string()
        } else {
            format!("{text}\n")
        }
        .as_bytes(),
    )
    .and_then(|_| file.sync_all())
    .map_err(|e| format!("Could not finish saving {}: {e}", path.display()))?;
    Ok(SavedNote {
        title,
        path,
        obsidian: vault.is_some(),
    })
}

pub fn open_uri(note: &SavedNote) -> String {
    if note.obsidian {
        format!(
            "obsidian://open?path={}",
            crate::core::encode(&note.path.to_string_lossy())
        )
    } else {
        use gtk::prelude::*;
        gtk::gio::File::for_path(&note.path).uri().to_string()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn capture_queries_and_safe_markdown_files() {
        assert_eq!(query("note Call Sam"), Some("Call Sam"));
        assert_eq!(query("Quick Note café & ideas"), Some("café & ideas"));
        assert!(query("notebook").is_none());
        let base =
            std::env::temp_dir().join(format!("spotlight-notes-{}", glib::uuid_string_random()));
        let vault = base.join("My vault");
        fs::create_dir_all(vault.join(".obsidian")).unwrap();
        let note = save("# Idea / ../escape\n\n- café & 🎉\n", Some(&vault), &base).unwrap();
        let second = save("# Idea / ../escape\n\n- café & 🎉\n", Some(&vault), &base).unwrap();
        assert_ne!(note.path, second.path);
        assert!(note.path.starts_with(vault.canonicalize().unwrap()));
        assert_eq!(
            fs::read_to_string(&note.path).unwrap(),
            "# Idea / ../escape\n\n- café & 🎉\n"
        );
        assert!(open_uri(&note).contains("%20"));
        assert!(open_uri(&note).starts_with("obsidian://open?path="));
        assert!(save("", Some(&vault), &base).is_err());
        assert!(save("text", Some(&base), &base).is_err());
        let local = save("local capture", None, &base.join("local")).unwrap();
        assert!(!local.obsidian);
        assert!(local.path.is_file());
        fs::remove_dir_all(base).unwrap();
    }
    #[test]
    fn rejects_a_notes_folder_symlink_outside_the_vault() {
        let base =
            std::env::temp_dir().join(format!("spotlight-link-{}", glib::uuid_string_random()));
        let vault = base.join("vault");
        fs::create_dir_all(vault.join(".obsidian")).unwrap();
        let outside = base.join("outside");
        fs::create_dir(&outside).unwrap();
        std::os::unix::fs::symlink(&outside, vault.join("Spotlight Quick Notes")).unwrap();
        assert!(save("must not escape", Some(&vault), &base).is_err());
        assert_eq!(fs::read_dir(&outside).unwrap().count(), 0);
        fs::remove_dir_all(base).unwrap();
    }
}

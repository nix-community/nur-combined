use crate::{boosters, core, devtools};
use serde_json::json;
use std::{
    fs,
    path::{Path, PathBuf},
    process::Command,
};
fn git(repo: &Path, args: &[&str]) -> Result<String, String> {
    boosters::run(
        Command::new("git")
            .arg("-C")
            .arg(repo)
            .args(args)
            .env("GIT_TERMINAL_PROMPT", "0"),
        20,
    )
    .map(|s| s.trim_end_matches(['\r', '\n']).to_string())
}
pub fn export(repo: &Path, push: bool, store: &core::Store) -> Result<String, String> {
    let repo = repo.canonicalize().map_err(|e| e.to_string())?;
    let top = git(&repo, &["rev-parse", "--show-toplevel"])?;
    if Path::new(&top).canonicalize().ok().as_ref() != Some(&repo) {
        return Err("Choose the root folder of an existing Git clone".into());
    }
    // Resolve all notes before changing the destination; missing notes abort the export.
    let mut quick = Vec::new();
    for note in &store.quick_notes {
        quick.push(json!({"title":note.title,"text":devtools::bounded_text(&note.path)?,"obsidian":note.obsidian}));
    }
    let bytes=serde_json::to_vec_pretty(&json!({"schema_version":1,"snippets":store.snippets,"notes":store.notes,"quicklinks":store.links,"quick_notes":quick})).map_err(|e|e.to_string())?;
    if push {
        verify_private(&repo)?;
    }
    let folder = repo.join("spotlight");
    match fs::symlink_metadata(&folder) {
        Ok(m) if !m.is_dir() || m.file_type().is_symlink() => {
            return Err("The export folder must be a real directory".into());
        }
        Err(e) if e.kind() == std::io::ErrorKind::NotFound => {
            use std::os::unix::fs::DirBuilderExt;
            fs::DirBuilder::new()
                .mode(0o700)
                .create(&folder)
                .map_err(|e| e.to_string())?;
        }
        Err(e) => return Err(e.to_string()),
        _ => {}
    }
    let target = folder.join("export.json");
    if fs::symlink_metadata(&target).is_ok_and(|m| m.file_type().is_symlink()) {
        return Err("The export file cannot be a symbolic link".into());
    }
    let temp = folder.join(format!(".export-{}.tmp", gtk::glib::uuid_string_random()));
    use std::io::Write;
    use std::os::unix::fs::OpenOptionsExt;
    let mut file = fs::OpenOptions::new()
        .write(true)
        .create_new(true)
        .mode(0o600)
        .open(&temp)
        .map_err(|e| e.to_string())?;
    let result = file
        .write_all(&bytes)
        .and_then(|()| file.sync_all())
        .and_then(|()| fs::rename(&temp, &target));
    if let Err(e) = result {
        let _ = fs::remove_file(temp);
        return Err(e.to_string());
    }
    git(&repo, &["add", "--", "spotlight/export.json"])?;
    let changed = !git(
        &repo,
        &[
            "diff",
            "--cached",
            "--name-only",
            "--",
            "spotlight/export.json",
        ],
    )?
    .is_empty();
    if changed {
        git(
            &repo,
            &[
                "commit",
                "--only",
                "-m",
                "Export Spotlight snippets, notes and quicklinks",
                "--",
                "spotlight/export.json",
            ],
        )?;
    }
    if push {
        verify_private(&repo)?;
        git(&repo, &["push", "origin", "HEAD"])?;
    }
    Ok(format!(
        "{}{} · {}",
        if changed {
            "Export committed"
        } else {
            "Export is already up to date"
        },
        if push {
            " and synced to private origin"
        } else {
            " locally"
        },
        target.display()
    ))
}
fn github_repo(url: &str) -> Option<String> {
    let path = url
        .strip_prefix("git@github.com:")
        .or_else(|| url.strip_prefix("https://github.com/"))
        .or_else(|| url.strip_prefix("ssh://git@github.com/"))?
        .trim_end_matches('/')
        .trim_end_matches(".git");
    let parts: Vec<_> = path.split('/').collect();
    if parts.len() != 2
        || parts.iter().any(|p| {
            p.is_empty()
                || p.starts_with('-')
                || !p
                    .bytes()
                    .all(|c| c.is_ascii_alphanumeric() || b"-_.".contains(&c))
        })
    {
        return None;
    }
    Some(path.into())
}
fn verify_private(repo: &Path) -> Result<(), String> {
    let origins = git(repo, &["remote", "get-url", "--push", "--all", "origin"])?;
    let urls: Vec<_> = origins.lines().collect();
    if urls.len() != 1 {
        return Err("Sync requires one private GitHub origin push URL".into());
    }
    let name=github_repo(urls[0]).ok_or("Automatic private-repo verification supports GitHub origins. Export locally for other Git hosts.")?;
    let body = boosters::run(
        Command::new("gh")
            .args([
                "repo",
                "view",
                &format!("https://github.com/{name}"),
                "--json",
                "isPrivate",
            ])
            .current_dir(repo),
        12,
    )?;
    let metadata: serde_json::Value =
        serde_json::from_str(&body).map_err(|_| "Invalid GitHub visibility response")?;
    if metadata["isPrivate"] != true {
        return Err("Origin must be a private GitHub repository before syncing".into());
    }
    Ok(())
}
pub fn expand_path(input: &str) -> PathBuf {
    let input = input.trim();
    if let Some(t) = input.strip_prefix("~/") {
        core::home().join(t)
    } else {
        PathBuf::from(input)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    fn git(repo: &Path, args: &[&str]) -> String {
        boosters::run(Command::new("git").arg("-C").arg(repo).args(args), 5)
            .unwrap()
            .trim_end_matches(['\r', '\n'])
            .to_string()
    }
    #[test]
    fn exports_only_selected_content_and_preserves_other_staged_files() {
        let work = crate::localtools::Work::new().unwrap();
        let repo = work.0.join("dotfiles");
        fs::create_dir(&repo).unwrap();
        git(&repo, &["init", "-b", "main"]);
        git(&repo, &["config", "user.name", "Fixture"]);
        git(&repo, &["config", "user.email", "fixture@example.invalid"]);
        fs::write(repo.join("unrelated"), "original").unwrap();
        git(&repo, &["add", "."]);
        git(&repo, &["commit", "-m", "Initial"]);
        fs::write(repo.join("unrelated"), "staged work").unwrap();
        git(&repo, &["add", "unrelated"]);
        let note = work.0.join("note.md");
        fs::write(&note, "# Quick note\nFixture note content").unwrap();
        let store = core::Store {
            notes: vec![core::TextItem {
                name: "Saved note".into(),
                value: "exported note".into(),
                trigger: String::new(),
            }],
            quick_notes: vec![crate::quicknote::SavedNote {
                title: "Quick".into(),
                path: note,
                obsidian: false,
            }],
            usage: std::collections::HashMap::from([("not-exported-private-history".into(), 5)]),
            ..Default::default()
        };
        export(&repo, false, &store).unwrap();
        let text = fs::read_to_string(repo.join("spotlight/export.json")).unwrap();
        assert!(text.contains("Fixture note content"));
        assert!(text.contains("exported note"));
        assert!(!text.contains("not-exported-private-history"));
        assert!(!text.contains("clipboard"));
        assert_eq!(
            git(&repo, &["diff", "--cached", "--name-only"]),
            "unrelated"
        );
        assert_eq!(git(&repo, &["show", "HEAD:unrelated"]), "original");
        let commits = git(&repo, &["rev-list", "--count", "HEAD"]);
        export(&repo, false, &store).unwrap();
        assert_eq!(git(&repo, &["rev-list", "--count", "HEAD"]), commits);
        use std::os::unix::fs::PermissionsExt;
        assert_eq!(
            fs::metadata(repo.join("spotlight/export.json"))
                .unwrap()
                .permissions()
                .mode()
                & 0o777,
            0o600
        );
    }
    #[test]
    fn validates_private_origin_hosts() {
        assert_eq!(
            github_repo("git@github.com:owner/private.git"),
            Some("owner/private".into())
        );
        assert_eq!(
            github_repo("https://github.com/owner/private"),
            Some("owner/private".into())
        );
        for bad in [
            "https://github.com.evil.test/owner/repo",
            "https://user@github.com/owner/repo",
            "--upload-pack=x",
            "git@elsewhere:owner/repo",
        ] {
            assert!(github_repo(bad).is_none());
        }
    }
}

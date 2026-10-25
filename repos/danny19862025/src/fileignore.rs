use ignore::gitignore::{Gitignore, GitignoreBuilder};
use std::{fs, io::Read, path::Path};

/// One snapshot per indexing/history pass; never read configuration per file.
pub struct Rules(Gitignore);
impl Rules {
    pub fn load(home: &Path) -> Result<Self, String> {
        let path = home.join(".spotlightignore");
        let mut builder = GitignoreBuilder::new(home);
        match fs::File::open(&path) {
            Ok(file) => {
                let mut text = String::new();
                file.take(1024 * 1024 + 1)
                    .read_to_string(&mut text)
                    .map_err(|e| format!("{}: {e}", path.display()))?;
                if text.len() > 1024 * 1024 {
                    return Err(".spotlightignore must be at most 1 MiB".into());
                }
                for (line, rule) in text.lines().enumerate() {
                    builder
                        .add_line(Some(path.clone()), rule)
                        .map_err(|e| format!(".spotlightignore line {}: {e}", line + 1))?;
                }
            }
            Err(e) if e.kind() == std::io::ErrorKind::NotFound => {}
            Err(e) => return Err(format!("{}: {e}", path.display())),
        }
        builder.build().map(Self).map_err(|e| e.to_string())
    }

    pub fn excludes(&self, path: &Path, is_dir: bool) -> bool {
        // Recent documents may live on other disks; home rules only govern home.
        path.starts_with(self.0.path())
            && self.0.matched_path_or_any_parents(path, is_dir).is_ignore()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn home_patterns_and_index_pruning() {
        let root = std::env::temp_dir().join(format!("spotlight-ignore-{}", std::process::id()));
        fs::create_dir_all(root.join("Private/deep")).unwrap();
        fs::create_dir_all(root.join("Projects/nested")).unwrap();
        fs::create_dir_all(root.join("node_modules")).unwrap();
        for name in [
            "keep.txt",
            "drop.log",
            "keep.log",
            "Private/deep/secret.txt",
            "Projects/nested/cache.tmp",
            "Projects/report.txt",
            "node_modules/skip.txt",
        ] {
            fs::write(root.join(name), "fixture").unwrap();
        }
        fs::write(
            root.join(".spotlightignore"),
            "# personal exclusions\n/Private/\n*.log\n!keep.log\n**/*.tmp\n",
        )
        .unwrap();
        let rules = Rules::load(&root).unwrap();
        assert!(rules.excludes(&root.join("Private/deep/secret.txt"), false));
        assert!(!rules.excludes(Path::new("/outside/Private/secret.txt"), false));
        let paths = crate::core::index_files_in(&root).unwrap();
        for name in ["keep.txt", "keep.log", "Projects", "Projects/report.txt"] {
            assert!(paths.contains(&root.join(name)), "{name}");
        }
        for name in [
            "Private",
            "Private/deep/secret.txt",
            "drop.log",
            "Projects/nested/cache.tmp",
            "node_modules",
            ".spotlightignore",
        ] {
            assert!(!paths.contains(&root.join(name)), "{name}");
        }
        // Reloading sees edits; a malformed rule is reported rather than silently ignored.
        fs::write(root.join(".spotlightignore"), "keep.txt\n").unwrap();
        assert!(
            !crate::core::index_files_in(&root)
                .unwrap()
                .contains(&root.join("keep.txt"))
        );
        fs::write(root.join(".spotlightignore"), "[z-a]\n").unwrap();
        assert!(crate::core::index_files_in(&root).is_err());
        fs::remove_dir_all(root).unwrap();
    }
}

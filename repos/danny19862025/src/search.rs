use crate::{
    boosters::{self, Entry, Operation},
    core,
};
use gtk::{gio, glib, prelude::*};
use std::{
    collections::{HashMap, HashSet},
    fs,
    io::{BufRead, BufReader},
    path::{Path, PathBuf},
    process::{Command, Stdio},
    sync::{
        Arc,
        atomic::{AtomicBool, Ordering},
        mpsc,
    },
    time::{Duration, Instant},
};

#[derive(Clone, Debug, PartialEq, Eq, Hash)]
pub enum Query {
    Recent(String),
    Content { scope: String, text: String },
}
impl Query {
    pub fn parse(text: &str) -> Option<Self> {
        if let Some((head, rest)) = text.split_once(char::is_whitespace)
            && matches!(head, "rg" | "content")
        {
            return Some(Self::Content {
                scope: "~".into(),
                text: rest.trim().into(),
            });
        }
        if matches!(text, "rg" | "content") {
            return Some(Self::Content {
                scope: "~".into(),
                text: String::new(),
            });
        }
        if let Some(rest) = text.strip_prefix("in:") {
            let rest = rest.trim();
            let (scope, text) = if let Some(quoted) = rest.strip_prefix('"') {
                quoted
                    .split_once('"')
                    .map(|(p, t)| (p, t.trim()))
                    .unwrap_or((quoted, ""))
            } else {
                rest.split_once(char::is_whitespace).unwrap_or((rest, ""))
            };
            return Some(Self::Content {
                scope: scope.into(),
                text: text.trim().into(),
            });
        }
        let (head, tail) = text.split_once(char::is_whitespace).unwrap_or((text, ""));
        matches!(head.to_ascii_lowercase().as_str(), "recent" | "recents")
            .then(|| Self::Recent(tail.trim().into()))
    }
}
pub fn image_path(path: &Path) -> bool {
    path.extension().and_then(|s| s.to_str()).is_some_and(|s| {
        [
            "png", "jpg", "jpeg", "webp", "gif", "bmp", "tif", "tiff", "avif",
        ]
        .contains(&s.to_ascii_lowercase().as_str())
    })
}
pub fn file_entry(path: PathBuf, badge: &'static str, detail: String) -> Entry {
    Entry {
        title: path
            .file_name()
            .unwrap_or_default()
            .to_string_lossy()
            .into(),
        detail,
        badge,
        operation: Some(Operation::OpenPath(path)),
    }
}
pub fn fetch(query: &Query) -> Result<Vec<Entry>, String> {
    match query {
        Query::Recent(filter) => {
            let (kind, filter) = match filter.split_once(' ').unwrap_or((filter, "")) {
                ("files", rest) => (1, rest),
                ("folders", rest) => (2, rest),
                _ => (0, filter.as_str()),
            };
            let mut rows = Vec::new();
            for (path, time) in recent()? {
                if (kind == 1 && path.is_dir()) || (kind == 2 && !path.is_dir()) {
                    continue;
                }
                if core::score(filter, &path.to_string_lossy()).is_none() {
                    continue;
                }
                let date = glib::DateTime::from_unix_local(time)
                    .ok()
                    .and_then(|d| d.format("%d %b %Y · %H:%M").ok())
                    .map(|s| s.to_string())
                    .unwrap_or_default();
                rows.push(file_entry(
                    path.clone(),
                    "Recent",
                    format!("{date} · {}", path.display()),
                ));
                if rows.len() >= 60 {
                    break;
                }
            }
            if rows.is_empty() {
                rows.push(boosters::hint("No matching recent documents", "Reads XDG recently-used.xbel and KDE RecentDocuments · only existing local files and their folders"));
            }
            Ok(rows)
        }
        Query::Content { scope, text } => {
            if scope.is_empty() || text.is_empty() {
                return Ok(vec![boosters::hint(
                    "Search inside files",
                    "Type rg rust to search home, in: notes rust, or in: \"Documents/My Notes\" phrase",
                )]);
            }
            if text.len() > 512 {
                return Err("Search text is limited to 512 bytes".into());
            }
            content(&roots(scope)?, text)
        }
    }
}
fn roots(scope: &str) -> Result<Vec<PathBuf>, String> {
    if scope.eq_ignore_ascii_case("notes") {
        let store = core::Store::load()?;
        let mut roots = vec![
            core::data_dir().join("quick-notes"),
            core::home().join("Notes"),
            core::home().join("Documents/Notes"),
        ];
        if let Some(vault) = store.obsidian_vault {
            roots.insert(0, vault);
        }
        roots.retain(|p| p.is_dir());
        roots.sort();
        roots.dedup();
        // Avoid searching a nested notes folder twice when a whole vault is included.
        let all = roots.clone();
        roots.retain(|p| {
            !all.iter()
                .any(|parent| parent != p && p.starts_with(parent))
        });
        if roots.is_empty() {
            return Err("No notes folder found · connect an Obsidian vault, create ~/Notes, or use an explicit folder after in:".into());
        }
        return Ok(roots);
    }
    let path = if scope == "~" || scope == "home" || scope == "." {
        core::home()
    } else if let Some(path) = scope.strip_prefix("~/") {
        core::home().join(path)
    } else if Path::new(scope).is_absolute() {
        PathBuf::from(scope)
    } else {
        core::home().join(scope)
    };
    if !path.is_dir() {
        return Err(format!("Folder does not exist: {}", path.display()));
    }
    Ok(vec![path])
}
fn content(roots: &[PathBuf], text: &str) -> Result<Vec<Entry>, String> {
    content_stream(roots, text, &AtomicBool::new(false), &mut |_| {})
}
pub enum Update {
    Match(Box<Entry>),
    Done(Result<Vec<Entry>, String>),
}
pub fn stream(query: &Query, cancel: Arc<AtomicBool>, updates: mpsc::Sender<Update>) {
    let result = (|| {
        let Query::Content { scope, text } = query else {
            return fetch(query);
        };
        if scope.is_empty() || text.is_empty() {
            return fetch(query);
        }
        if text.len() > 512 || text.contains('\0') {
            return Err("Use search text up to 512 bytes without NUL".into());
        }
        if cancel.load(Ordering::Relaxed) {
            return Err("Search cancelled".into());
        }
        content_stream(&roots(scope)?, text, &cancel, &mut |row| {
            let _ = updates.send(Update::Match(Box::new(row)));
        })
    })();
    let _ = updates.send(Update::Done(result));
}
fn content_stream(
    roots: &[PathBuf],
    text: &str,
    cancel: &AtomicBool,
    on_match: &mut impl FnMut(Entry),
) -> Result<Vec<Entry>, String> {
    let deadline = Instant::now() + Duration::from_secs(8);
    let mut rows = Vec::new();
    let mut limited = false;
    for root in roots {
        if cancel.load(Ordering::Relaxed) {
            return Err("Search cancelled".into());
        }
        // Search every root from its own directory. ripgrep matches the
        // exclusion globs against the path it prints, so searching from the
        // root keeps them scoped to the searched tree instead of matching a
        // "build" or "target" directory in the absolute path of the root.
        let mut child = Command::new("rg")
            .current_dir(root)
            .args([
                "--no-config",
                "--json",
                "--line-number",
                "--smart-case",
                "--fixed-strings",
                "--max-filesize",
                "1M",
                "--max-count",
                "3",
                "--max-depth",
                "12",
                "--threads",
                "2",
                "--glob",
                "!**/node_modules/**",
                "--glob",
                "!**/target/**",
                "--glob",
                "!**/vendor/**",
                "--glob",
                "!**/build/**",
                "--glob",
                "!**/dist/**",
                "--",
                text,
                ".",
            ])
            .stdin(Stdio::null())
            .stdout(Stdio::piped())
            .stderr(Stdio::null())
            .spawn()
            .map_err(|e| format!("Content search requires ripgrep (rg): {e}"))?;
        let stdout = child.stdout.take().unwrap();
        let (tx, rx) = mpsc::sync_channel(8);
        std::thread::spawn(move || {
            for line in BufReader::new(stdout).lines().map_while(Result::ok) {
                let Ok(v) = serde_json::from_str::<serde_json::Value>(&line) else {
                    continue;
                };
                if v["type"] == "match" && tx.send(v).is_err() {
                    break;
                }
            }
        });
        while Instant::now() < deadline && !cancel.load(Ordering::Relaxed) {
            match rx.recv_timeout(Duration::from_millis(40)) {
                Ok(v) => {
                    if let Some(row) = content_row(&v, root) {
                        on_match(row.clone());
                        rows.push(row);
                    }
                    if rows.len() >= 100 {
                        limited = true;
                        break;
                    }
                }
                Err(mpsc::RecvTimeoutError::Timeout) => continue,
                Err(mpsc::RecvTimeoutError::Disconnected) => break,
            }
        }
        if Instant::now() >= deadline {
            limited = true;
        }
        // Closing the receiver also releases a bounded reader if the result cap was hit.
        drop(rx);
        if limited || cancel.load(Ordering::Relaxed) {
            let _ = child.kill();
        }
        let status = child.wait().map_err(|e| e.to_string())?;
        if cancel.load(Ordering::Relaxed) {
            return Err("Search cancelled".into());
        }
        if !limited && !status.success() && status.code() != Some(1) {
            return Err("ripgrep could not search this folder · check read permissions".into());
        }
        if limited {
            break;
        }
    }
    if rows.is_empty() {
        rows.push(boosters::hint("No content matches", "Literal text · smart case · hidden, ignored, binary, and files larger than 1 MiB are skipped"));
    }
    if limited {
        rows.push(boosters::hint(
            "Search limit reached",
            "Showing matches collected in 8 seconds, up to 100 lines · narrow the folder or phrase",
        ));
    }
    Ok(rows)
}
fn content_row(v: &serde_json::Value, root: &Path) -> Option<Entry> {
    let data = &v["data"];
    let relative = data["path"]["text"].as_str()?;
    let relative = relative.strip_prefix("./").unwrap_or(relative);
    let path = root.join(relative);
    let line = data["line_number"].as_u64()?;
    let text = data["lines"]["text"]
        .as_str()?
        .trim_end_matches(['\r', '\n']);
    let excerpt: String = text.chars().take(320).collect();
    let preview: String = text.chars().take(4096).collect();
    let name = path.file_name()?.to_string_lossy();
    Some(Entry {
        title: format!("{name}:{line} · {excerpt}"),
        detail: path.display().to_string(),
        badge: "Content",
        operation: Some(Operation::Preview {
            title: format!("{name} · line {line}"),
            text: format!(
                "{}\nLine {line}\n\n{preview}{}",
                path.display(),
                if preview.len() < text.len() {
                    "\n[Long line truncated at 4,096 characters]"
                } else {
                    ""
                }
            ),
            open: Some(gio::File::for_path(&path).uri().to_string()),
        }),
    })
}

// Use GLib's XBEL parser rather than trying to parse XML with string matching.
pub fn recent() -> Result<Vec<(PathBuf, i64)>, String> {
    let rules = crate::fileignore::Rules::load(&core::home())?;
    let dir = std::env::var_os("XDG_DATA_HOME")
        .map(PathBuf::from)
        .unwrap_or_else(|| core::home().join(".local/share"));
    let mut entries = HashMap::new();
    let xbel = dir.join("recently-used.xbel");
    if xbel.is_file() {
        for (path, time) in read_xbel(&xbel)? {
            add_recent(&mut entries, path, time);
        }
    }
    for entry in fs::read_dir(dir.join("RecentDocuments"))
        .into_iter()
        .flatten()
        .flatten()
        .take(1000)
    {
        if entry.path().extension().is_none_or(|s| s != "desktop") {
            continue;
        }
        let file = glib::KeyFile::new();
        if file
            .load_from_file(entry.path(), glib::KeyFileFlags::NONE)
            .is_err()
        {
            continue;
        }
        if let Ok(url) = file.string("Desktop Entry", "URL")
            && let Some(path) = local_uri(&url)
        {
            let time = entry
                .metadata()
                .ok()
                .and_then(|m| m.modified().ok())
                .and_then(|t| t.duration_since(std::time::UNIX_EPOCH).ok())
                .map(|t| t.as_secs() as i64)
                .unwrap_or(0);
            add_recent(&mut entries, path, time);
        }
    }
    let mut entries: Vec<_> = entries
        .into_iter()
        .filter(|(path, _)| !rules.excludes(path, path.is_dir()))
        .collect();
    entries.sort_by(|a, b| b.1.cmp(&a.1).then(a.0.cmp(&b.0)));
    entries.truncate(300);
    Ok(entries)
}
fn local_uri(uri: &str) -> Option<PathBuf> {
    let parsed = glib::Uri::parse(uri, glib::UriFlags::NONE).ok()?;
    if parsed.scheme() != "file"
        || parsed
            .host()
            .is_some_and(|host| !host.is_empty() && host != "localhost")
    {
        return None;
    }
    let path = gio::File::for_uri(uri).path()?;
    path.exists().then_some(path)
}
fn add_recent(entries: &mut HashMap<PathBuf, i64>, path: PathBuf, time: i64) {
    if core::hidden_path(&path) || !path.exists() {
        return;
    }
    if let Some(parent) = path.parent().filter(|p| p.is_dir()) {
        entries
            .entry(parent.into())
            .and_modify(|t| *t = (*t).max(time))
            .or_insert(time);
    }
    entries
        .entry(path)
        .and_modify(|t| *t = (*t).max(time))
        .or_insert(time);
}
fn read_xbel(path: &Path) -> Result<Vec<(PathBuf, i64)>, String> {
    use glib::translate::{ToGlibPtr, from_glib_full};
    if fs::metadata(path).map_err(|e| e.to_string())?.len() > 8_388_608 {
        return Err("Recent-document history is larger than 8 MiB".into());
    }
    struct Bookmark(*mut glib::ffi::GBookmarkFile);
    impl Drop for Bookmark {
        fn drop(&mut self) {
            unsafe {
                glib::ffi::g_bookmark_file_free(self.0);
            }
        }
    }
    unsafe {
        let file = Bookmark(glib::ffi::g_bookmark_file_new());
        let mut error = std::ptr::null_mut();
        if glib::ffi::g_bookmark_file_load_from_file(file.0, path.to_glib_none().0, &mut error) == 0
        {
            let error: glib::Error = from_glib_full(error);
            return Err(format!("Could not read recent-document history: {error}"));
        }
        let uris = glib::StrV::from_glib_full(glib::ffi::g_bookmark_file_get_uris(
            file.0,
            std::ptr::null_mut(),
        ));
        let mut result = Vec::new();
        for uri in uris.iter().take(3000) {
            if glib::ffi::g_bookmark_file_get_is_private(
                file.0,
                uri.to_glib_none().0,
                std::ptr::null_mut(),
            ) != 0
            {
                continue;
            }
            let Some(path) = local_uri(uri) else { continue };
            let visited = glib::ffi::g_bookmark_file_get_visited(
                file.0,
                uri.to_glib_none().0,
                std::ptr::null_mut(),
            );
            let modified = glib::ffi::g_bookmark_file_get_modified(
                file.0,
                uri.to_glib_none().0,
                std::ptr::null_mut(),
            );
            result.push((path, if visited > 0 { visited } else { modified }));
        }
        Ok(result)
    }
}

#[derive(Clone, Copy, PartialEq, Eq)]
struct Stamp {
    bytes: u64,
    modified: std::time::SystemTime,
}
fn stamp(path: &Path) -> Option<Stamp> {
    let m = fs::metadata(path).ok()?;
    Some(Stamp {
        bytes: m.len(),
        modified: m.modified().ok()?,
    })
}
type ThumbResult = (PathBuf, Stamp, Option<Vec<u8>>);
#[derive(Default)]
pub struct Thumbnails {
    cache: HashMap<PathBuf, (Stamp, Option<Vec<u8>>)>,
    pending: HashSet<PathBuf>,
    sender: Option<mpsc::Sender<(PathBuf, Stamp)>>,
    receiver: Option<mpsc::Receiver<ThumbResult>>,
}
impl Thumbnails {
    pub fn request(&mut self, path: &Path) -> Option<Vec<u8>> {
        let now = stamp(path)?;
        if let Some((old, data)) = self.cache.get(path)
            && *old == now
        {
            return data.clone();
        }
        if self.pending.len() >= 96 || !self.pending.insert(path.into()) {
            return None;
        }
        if self.sender.is_none() {
            let (tx, rx) = mpsc::channel::<(PathBuf, Stamp)>();
            let (done, results) = mpsc::channel();
            std::thread::spawn(move || {
                for (path, stamp) in rx {
                    let data = thumbnail(&path, stamp);
                    if done.send((path, stamp, data)).is_err() {
                        break;
                    }
                }
            });
            self.sender = Some(tx);
            self.receiver = Some(results);
        }
        let _ = self.sender.as_ref().unwrap().send((path.into(), now));
        None
    }
    pub fn pending(&self) -> bool {
        !self.pending.is_empty()
    }
    pub fn collect(&mut self) -> Vec<(PathBuf, Option<Vec<u8>>)> {
        let mut changes = Vec::new();
        if let Some(rx) = &self.receiver {
            while let Ok((path, stamp, data)) = rx.try_recv() {
                self.pending.remove(&path);
                if self.cache.len() >= 96 {
                    self.cache.clear();
                }
                self.cache.insert(path.clone(), (stamp, data.clone()));
                changes.push((path, data));
            }
        }
        changes
    }
}
fn thumbnail(path: &Path, info: Stamp) -> Option<Vec<u8>> {
    if info.bytes > 16_777_216 || !image_path(path) {
        return None;
    }
    let (_, width, height) = gtk::gdk_pixbuf::Pixbuf::file_info(path)?;
    if width <= 0 || height <= 0 || i64::from(width) * i64::from(height) > 16_000_000 {
        return None;
    }
    let pixbuf = gtk::gdk_pixbuf::Pixbuf::from_file_at_scale(path, 64, 64, true).ok()?;
    pixbuf.save_to_bufferv("png", &[]).ok()
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn query_scopes_and_content_matches() {
        assert_eq!(
            Query::parse("in: notes rust"),
            Some(Query::Content {
                scope: "notes".into(),
                text: "rust".into()
            })
        );
        assert_eq!(
            Query::parse("in: \"My Notes\" Rust async"),
            Some(Query::Content {
                scope: "My Notes".into(),
                text: "Rust async".into()
            })
        );
        let root = std::env::temp_dir().join(format!("spotlight-content-{}", std::process::id()));
        fs::create_dir_all(&root).unwrap();
        fs::write(root.join("note.md"), "hello\nRust async\n").unwrap();
        fs::write(root.join(".private"), "Rust async").unwrap();
        fs::create_dir_all(root.join("inner/target")).unwrap();
        fs::write(root.join("inner/target/output.txt"), "Rust async").unwrap();
        fs::write(root.join("binary.dat"), b"\0Rust async\0").unwrap();
        fs::write(root.join("large.txt"), "Rust async\n".repeat(110000)).unwrap();
        let rows = content(std::slice::from_ref(&root), "Rust async").unwrap();
        assert_eq!(rows.len(), 1);
        assert!(rows[0].title.starts_with("note.md:2"));
        let cancelled = AtomicBool::new(false);
        let mut streamed = 0;
        let result = content_stream(
            std::slice::from_ref(&root),
            "Rust async",
            &cancelled,
            &mut |_| {
                streamed += 1;
                cancelled.store(true, Ordering::Relaxed);
            },
        );
        assert_eq!(streamed, 1);
        assert_eq!(result.unwrap_err(), "Search cancelled");
        assert_eq!(
            Query::parse("rg Rust async"),
            Some(Query::Content {
                scope: "~".into(),
                text: "Rust async".into()
            })
        );
        assert_eq!(
            content(std::slice::from_ref(&root), "--not-an-option").unwrap()[0].title,
            "No content matches"
        );
        fs::remove_dir_all(root).unwrap();
    }
    #[test]
    fn content_search_scopes_exclusions_to_each_root() {
        let fixture = std::env::temp_dir().join(format!(
            "spotlight-content-ancestors-{}",
            std::process::id()
        ));
        let root = fixture.join("build/target/dist/vendor/node_modules/My Notes");
        fs::create_dir_all(&root).unwrap();
        let note = root.join("café note.md");
        fs::write(&note, "fixture needle\n").unwrap();
        for excluded in ["build", "target", "dist", "vendor", "node_modules"] {
            fs::create_dir_all(root.join(excluded)).unwrap();
            fs::write(root.join(excluded).join("output.txt"), "fixture needle").unwrap();
        }
        let rows = content(std::slice::from_ref(&root), "fixture needle").unwrap();
        assert_eq!(rows.len(), 1);
        assert_eq!(rows[0].detail, note.display().to_string());
        let Some(Operation::Preview { open, .. }) = &rows[0].operation else {
            panic!("Content matches must open the original file");
        };
        assert_eq!(
            open.as_deref(),
            Some(gio::File::for_path(&note).uri().as_str())
        );
        fs::remove_dir_all(fixture).unwrap();
    }
    #[test]
    fn content_search_shares_result_limit_across_roots() {
        let fixture =
            std::env::temp_dir().join(format!("spotlight-content-multiple-{}", std::process::id()));
        let roots = [fixture.join("first"), fixture.join("second")];
        for root in &roots {
            fs::create_dir_all(root).unwrap();
            fs::write(root.join("note.md"), "fixture needle\n").unwrap();
        }
        let rows = content(&roots, "fixture needle").unwrap();
        assert_eq!(rows.len(), 2);
        for (row, root) in rows.iter().zip(&roots) {
            assert_eq!(row.detail, root.join("note.md").display().to_string());
        }
        for n in 0..110 {
            fs::write(roots[1].join(format!("{n}.md")), "fixture needle\n").unwrap();
        }
        // Reaching the cap must stop before attempting another root.
        let mut capped_roots = roots.to_vec();
        capped_roots.push(fixture.join("missing"));
        let mut streamed = 0;
        let rows = content_stream(
            &capped_roots,
            "fixture needle",
            &AtomicBool::new(false),
            &mut |_| streamed += 1,
        )
        .unwrap();
        assert_eq!(streamed, 100);
        assert_eq!(rows.len(), 101);
        assert_eq!(rows.last().unwrap().title, "Search limit reached");
        fs::remove_dir_all(fixture).unwrap();
    }
    #[test]
    fn xbel_recency_private_and_missing_files() {
        let root = std::env::temp_dir().join(format!("spotlight-recent-{}", std::process::id()));
        fs::create_dir_all(&root).unwrap();
        let file = root.join("café & notes.txt");
        fs::write(&file, "text").unwrap();
        let uri = gio::File::for_path(&file).uri().replace('&', "&amp;");
        let path = root.join("recent.xbel");
        fs::write(&path,format!(r#"<?xml version="1.0"?><xbel version="1.0" xmlns:bookmark="http://www.freedesktop.org/standards/desktop-bookmarks" xmlns:mime="http://www.freedesktop.org/standards/shared-mime-info"><bookmark href="{uri}" added="2026-01-01T00:00:00Z" modified="2026-02-01T00:00:00Z" visited="2026-03-01T00:00:00Z"><info><metadata owner="http://freedesktop.org"><mime:mime-type type="text/plain"/></metadata></info></bookmark></xbel>"#)).unwrap();
        let rows = read_xbel(&path).unwrap();
        assert_eq!(rows.len(), 1);
        assert_eq!(rows[0].0, file);
        assert!(rows[0].1 > 1770000000);
        let text = fs::read_to_string(&path)
            .unwrap()
            .replace("<mime:mime-type", "<bookmark:private/><mime:mime-type");
        fs::write(&path, text).unwrap();
        assert!(read_xbel(&path).unwrap().is_empty());
        assert!(local_uri("file://remote-server/home/user/a").is_none());
        fs::remove_dir_all(root).unwrap();
    }
    #[test]
    fn recent_history_excludes_dotfiles_and_hidden_folders() {
        let root =
            std::env::temp_dir().join(format!("spotlight-hidden-recent-{}", std::process::id()));
        fs::create_dir_all(root.join(".config/editor")).unwrap();
        fs::create_dir_all(root.join("Documents")).unwrap();
        let mut entries = HashMap::new();
        for name in [".bashrc", "Documents/.env", ".config/editor/settings.json"] {
            let path = root.join(name);
            fs::write(&path, "fixture").unwrap();
            add_recent(&mut entries, path, 1);
        }
        add_recent(&mut entries, root.join(".config/editor"), 1);
        assert!(
            entries.is_empty(),
            "Hidden history must not add files or parent folders"
        );
        let visible = root.join("Documents/report.txt");
        fs::write(&visible, "fixture").unwrap();
        add_recent(&mut entries, visible.clone(), 2);
        assert_eq!(entries.len(), 2);
        assert_eq!(entries.get(&visible), Some(&2));
        assert_eq!(entries.get(&root.join("Documents")), Some(&2));
        fs::remove_dir_all(root).unwrap();
    }
}

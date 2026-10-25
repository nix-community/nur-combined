use crate::{
    boosters::{self, Entry, Operation as Op, entry, hint},
    core,
};
use gtk::{gio, prelude::*};
use std::{
    collections::{BTreeMap, HashSet},
    fs,
    path::{Path, PathBuf},
    process::{Command, Stdio},
};

#[derive(Clone, Debug, PartialEq, Eq, Hash)]
pub enum Query {
    Projects {
        editor: String,
        filter: String,
    },
    Context(String),
    Ssh(String),
    Env(String),
    Dotenv {
        input: String,
        context: PathBuf,
    },
    Github {
        kind: String,
        input: String,
        context: PathBuf,
    },
}
impl Query {
    pub fn parse(text: &str) -> Option<Self> {
        let (head, tail) = text
            .trim()
            .split_once(char::is_whitespace)
            .unwrap_or((text.trim(), ""));
        let tail = tail.trim();
        Some(match head.to_ascii_lowercase().as_str() {
            "code" | "projects" | "jetbrains" | "idea" | "pycharm" | "webstorm" | "clion"
            | "goland" | "rustrover" | "phpstorm" | "rider" | "rubymine" | "datagrip" => {
                Self::Projects {
                    editor: head.to_ascii_lowercase(),
                    filter: tail.into(),
                }
            }
            "project" => Self::Context(tail.strip_prefix("use ").unwrap_or(tail).into()),
            "ssh" => Self::Ssh(tail.into()),
            "env" | "environment" => Self::Env(tail.into()),
            "dotenv" => Self::Dotenv {
                input: tail.into(),
                context: context(),
            },
            "gh" => {
                let (kind, input) = tail.split_once(char::is_whitespace).unwrap_or((tail, ""));
                if !matches!(kind, "pr" | "issue") {
                    return None;
                }
                Self::Github {
                    kind: kind.into(),
                    input: input
                        .strip_prefix("list ")
                        .unwrap_or(if input == "list" { "" } else { input })
                        .into(),
                    context: context(),
                }
            }
            _ => return None,
        })
    }
}
#[derive(Clone, Debug)]
pub enum Operation {
    OpenProject { editor: String, path: PathBuf },
    UseProject(PathBuf),
    Ssh(String),
    OpenUrl(String),
    Inspect { key: String, path: Option<PathBuf> },
}
#[derive(serde::Deserialize, Debug)]
struct Project {
    editor: String,
    path: String,
}

pub fn context() -> PathBuf {
    std::env::var_os("SPOTLIGHT_PROJECT_DIR")
        .map(PathBuf::from)
        .or_else(|| core::Store::load().ok()?.project_context)
        .or_else(|| std::env::current_dir().ok())
        .filter(|p| p.is_dir())
        .unwrap_or_else(core::home)
}
pub fn project_directory(path: &Path) -> PathBuf {
    if path.is_dir() {
        path.to_path_buf()
    } else {
        path.parent().unwrap_or(path).to_path_buf()
    }
}
fn expand_path(text: &str) -> PathBuf {
    if text == "~" {
        core::home()
    } else if let Some(rest) = text.strip_prefix("~/") {
        core::home().join(rest)
    } else {
        PathBuf::from(text)
    }
}
pub(crate) fn bounded_text(path: &Path) -> Result<String, String> {
    use std::io::Read;
    let file =
        fs::File::open(path).map_err(|e| format!("Could not read {}: {e}", path.display()))?;
    if !file.metadata().is_ok_and(|m| m.is_file()) {
        return Err("Choose a regular file".into());
    }
    let mut text = String::new();
    file.take(1_048_577)
        .read_to_string(&mut text)
        .map_err(|e| e.to_string())?;
    if text.len() > 1_048_576 {
        return Err("File exceeds 1 MiB".into());
    }
    Ok(text)
}
fn projects() -> Result<Vec<(String, PathBuf)>, String> {
    let config = std::env::var_os("XDG_CONFIG_HOME")
        .map(PathBuf::from)
        .unwrap_or_else(|| core::home().join(".config"));
    let result = boosters::run(
        Command::new("python3")
            .arg("-c")
            .arg(include_str!("recent_projects.py"))
            .arg(core::home())
            .arg(config),
        6,
    )?;
    let rows: Vec<Project> =
        serde_json::from_str(&result).map_err(|_| "Invalid editor recent-project metadata")?;
    let mut seen = HashSet::new();
    Ok(rows
        .into_iter()
        .filter_map(|row| {
            let path = if row.path.starts_with("file://") {
                gio::File::for_uri(&row.path).path()?
            } else if row.path.contains("://") {
                return None;
            } else {
                expand_path(&row.path)
            };
            if !path.is_absolute()
                || !path.exists()
                || (!path.is_dir()
                    && path
                        .extension()
                        .is_none_or(|e| e != "code-workspace" && e != "ipr" && e != "sln"))
            {
                return None;
            }
            seen.insert((row.editor.clone(), path.clone()))
                .then_some((row.editor, path))
        })
        .collect())
}
fn ranked_projects(editor: &str, filter: &str, set_context: bool) -> Result<Vec<Entry>, String> {
    let raw = filter.trim_matches('"').trim_matches('\'');
    let direct = expand_path(raw);
    let direct = (set_context && !raw.is_empty() && direct.is_absolute() && direct.is_dir())
        .then_some(direct);
    let mut paths = if direct.is_some() {
        projects().unwrap_or_default()
    } else {
        projects()?
    };
    if let Some(path) = &direct {
        paths.insert(0, ("project".into(), path.clone()));
    }
    let mut rows = paths
        .into_iter()
        .filter_map(|(command, path)| {
            if !matches!(editor, "projects" | "project")
                && !(editor == "code"
                    && matches!(
                        command.as_str(),
                        "code" | "code-insiders" | "codium" | "code-oss"
                    ))
                && !(editor == "jetbrains" && !command.starts_with("code") && command != "codium")
                && editor != command
            {
                return None;
            }
            let score = if command == "project" {
                i32::MAX
            } else {
                core::score(raw, &path.to_string_lossy())?
            };
            let name = path.file_name().unwrap_or_default().to_string_lossy();
            Some((
                score,
                entry(
                    format!("{} {name}", if set_context { "Use" } else { "Open" }),
                    format!("{} · {}", command, path.display()),
                    "Project",
                    Op::Dev(if set_context {
                        Operation::UseProject(project_directory(&path))
                    } else {
                        Operation::OpenProject {
                            editor: command,
                            path,
                        }
                    }),
                ),
            ))
        })
        .collect::<Vec<_>>();
    rows.sort_by_key(|a| std::cmp::Reverse(a.0));
    let mut result: Vec<_> = rows.into_iter().take(40).map(|(_, e)| e).collect();
    if set_context {
        result.insert(
            0,
            hint("Current project context", context().display().to_string()),
        );
    }
    if result.len() == usize::from(set_context) {
        result.push(hint(
            "No matching recent projects",
            "Type code <name>, jetbrains <name>, or project /absolute/path to set context",
        ));
    }
    Ok(result)
}

// OpenSSH-style tokenization; no shell evaluation or Match/ProxyCommand execution.
pub(crate) fn tokens(line: &str) -> Result<Vec<String>, String> {
    let mut result = Vec::new();
    let mut word = String::new();
    let mut quote = None;
    let mut escape = false;
    let mut active = false;
    for c in line.chars() {
        if escape {
            word.push(c);
            escape = false;
            active = true;
            continue;
        }
        if c == '\\' && quote != Some('\'') {
            escape = true;
            continue;
        }
        if let Some(q) = quote {
            if c == q {
                quote = None;
            } else {
                word.push(c);
            }
            active = true;
            continue;
        }
        if c == '"' || c == '\'' {
            quote = Some(c);
            active = true;
        } else if c == '#' && !active {
            break;
        } else if c.is_whitespace() {
            if active {
                result.push(std::mem::take(&mut word));
                active = false;
            }
        } else {
            word.push(c);
            active = true;
        }
    }
    if quote.is_some() || escape {
        return Err("Unclosed quote or escape".into());
    }
    if active {
        result.push(word);
    }
    Ok(result)
}
fn valid_host(host: &str) -> bool {
    !host.is_empty()
        && !host.starts_with('-')
        && host.len() <= 255
        && host
            .bytes()
            .all(|c| c.is_ascii_alphanumeric() || b"._-".contains(&c))
}
fn wildcard(pattern: &str, value: &str) -> bool {
    let (p, v) = (pattern.as_bytes(), value.as_bytes());
    let (mut i, mut j, mut star, mut mark) = (0, 0, None, 0);
    while j < v.len() {
        if i < p.len() && (p[i] == b'?' || p[i] == v[j]) {
            i += 1;
            j += 1;
        } else if i < p.len() && p[i] == b'*' {
            star = Some(i);
            i += 1;
            mark = j;
        } else if let Some(s) = star {
            i = s + 1;
            mark += 1;
            j = mark;
        } else {
            return false;
        }
    }
    while i < p.len() && p[i] == b'*' {
        i += 1;
    }
    i == p.len()
}
fn include_paths(pattern: &str, root: &Path) -> Vec<PathBuf> {
    let pattern = expand_path(pattern);
    let pattern = if pattern.is_absolute() {
        pattern
    } else {
        root.join(pattern)
    };
    let mut paths = vec![PathBuf::from("/")];
    for part in pattern.components().skip(1) {
        let name = part.as_os_str().to_string_lossy();
        let mut next = Vec::new();
        for base in paths {
            if name.contains(['*', '?']) {
                if let Ok(entries) = fs::read_dir(base) {
                    for e in entries.flatten().take(500) {
                        if wildcard(&name, &e.file_name().to_string_lossy()) {
                            next.push(e.path());
                        }
                    }
                }
            } else {
                next.push(base.join(name.as_ref()));
            }
        }
        next.sort();
        next.truncate(100);
        paths = next;
    }
    paths
}
fn ssh_hosts_from(
    path: &Path,
    root: &Path,
    seen: &mut HashSet<PathBuf>,
    hosts: &mut Vec<String>,
    depth: usize,
) {
    if depth > 8 || seen.len() >= 100 || hosts.len() >= 1000 {
        return;
    }
    let Ok(path) = path.canonicalize() else {
        return;
    };
    if !seen.insert(path.clone()) {
        return;
    }
    let Ok(text) = bounded_text(&path) else {
        return;
    };
    for line in text.lines() {
        let line = line.trim();
        let line = if let Some(at) = line.find('=') {
            if !line[..at].contains(char::is_whitespace) {
                format!("{} {}", &line[..at], &line[at + 1..])
            } else {
                line.into()
            }
        } else {
            line.into()
        };
        let Ok(words) = tokens(&line) else {
            continue;
        };
        let Some(key) = words.first() else {
            continue;
        };
        if key.eq_ignore_ascii_case("host") {
            for host in &words[1..] {
                if valid_host(host) && !hosts.contains(host) && hosts.len() < 1000 {
                    hosts.push(host.clone());
                }
            }
        }
        if key.eq_ignore_ascii_case("include") {
            for pattern in &words[1..] {
                for path in include_paths(pattern, root) {
                    ssh_hosts_from(&path, root, seen, hosts, depth + 1);
                }
            }
        }
    }
}
fn ssh_hosts() -> Vec<String> {
    let root = core::home().join(".ssh");
    let mut hosts = Vec::new();
    ssh_hosts_from(
        &root.join("config"),
        &root,
        &mut HashSet::new(),
        &mut hosts,
        0,
    );
    hosts
}
fn ssh_entries(filter: &str) -> Vec<Entry> {
    let mut rows = ssh_hosts()
        .into_iter()
        .filter_map(|host| Some((core::score(filter, &host)?, host)))
        .collect::<Vec<_>>();
    rows.sort_by(|a, b| b.0.cmp(&a.0).then(a.1.cmp(&b.1)));
    let mut rows: Vec<_> = rows
        .into_iter()
        .take(40)
        .map(|(_, host)| {
            entry(
                format!("SSH · {host}"),
                "Open in Konsole · SSH config settings apply",
                "SSH",
                Op::Dev(Operation::Ssh(host)),
            )
        })
        .collect();
    if rows.is_empty() {
        rows.push(hint(
            "No matching SSH aliases",
            "Add named Host entries to ~/.ssh/config; wildcard and negated hosts are excluded",
        ));
    }
    rows
}

fn valid_key(key: &str) -> bool {
    let mut c = key.chars();
    c.next()
        .is_some_and(|c| c.is_ascii_alphabetic() || c == '_')
        && c.all(|c| c.is_ascii_alphanumeric() || c == '_')
}
pub fn parse_dotenv(text: &str) -> Result<BTreeMap<String, String>, String> {
    let mut values = BTreeMap::new();
    let mut lines = text.lines().enumerate();
    while let Some((line_number, line)) = lines.next() {
        let line = line
            .trim()
            .strip_prefix("export ")
            .unwrap_or(line.trim())
            .trim_start();
        if line.is_empty() || line.starts_with('#') {
            continue;
        }
        let Some((key, raw)) = line.split_once('=') else {
            return Err(format!("Expected KEY=value at line {}", line_number + 1));
        };
        let key = key.trim();
        if !valid_key(key) {
            return Err(format!("Invalid variable name at line {}", line_number + 1));
        }
        let raw = raw.trim_start();
        let value = if raw.starts_with(['\'', '"']) {
            let quote = raw.chars().next().unwrap();
            let mut source = raw[1..].to_string();
            let mut value = String::new();
            let mut escaped = false;
            loop {
                let mut end = None;
                for (index, c) in source.char_indices() {
                    if escaped {
                        let decoded = match c {
                            'n' => '\n',
                            'r' => '\r',
                            't' => '\t',
                            '"' => '"',
                            '\\' => '\\',
                            _ => {
                                value.push('\\');
                                c
                            }
                        };
                        value.push(decoded);
                        escaped = false;
                    } else if c == '\\' && quote == '"' {
                        escaped = true;
                    } else if c == quote {
                        end = Some(index + 1);
                        break;
                    } else {
                        value.push(c);
                    }
                }
                if let Some(end) = end {
                    let rest = source[end..].trim();
                    if !rest.is_empty() && !rest.starts_with('#') {
                        return Err(format!(
                            "Unexpected text after quoted value at line {}",
                            line_number + 1
                        ));
                    }
                    break;
                }
                let Some((_, next)) = lines.next() else {
                    return Err(format!("Unclosed quoted value at line {}", line_number + 1));
                };
                value.push('\n');
                source = next.into();
                escaped = false;
            }
            value
        } else {
            let end = raw
                .char_indices()
                .find_map(|(i, c)| {
                    (c == '#' && (i == 0 || raw[..i].ends_with(char::is_whitespace))).then_some(i)
                })
                .unwrap_or(raw.len());
            raw[..end].trim_end().into()
        };
        values.insert(key.into(), value);
    }
    Ok(values)
}
fn dotenv_target(input: &str, context: &Path) -> Result<(PathBuf, String), String> {
    let words = tokens(input)?;
    let mut path = context.join(".env");
    let mut filter = words.join(" ");
    if let Some(first) = words.first()
        && (first.contains('/') || first.starts_with('.') || first.starts_with('~'))
    {
        path = expand_path(first);
        if !path.is_absolute() {
            path = context.join(path);
        }
        if path.is_dir() {
            path = path.join(".env");
        }
        filter = words[1..].join(" ");
    }
    Ok((path, filter))
}
fn environment_entries(
    values: BTreeMap<String, String>,
    filter: &str,
    path: Option<&Path>,
) -> Vec<Entry> {
    let mut rows = values
        .into_keys()
        .filter_map(|key| Some((core::score(filter, &key)?, key)))
        .collect::<Vec<_>>();
    rows.sort_by(|a, b| b.0.cmp(&a.0).then(a.1.cmp(&b.1)));
    let mut rows: Vec<_> = rows
        .into_iter()
        .take(100)
        .map(|(_, key)| {
            entry(
                key.clone(),
                format!(
                    "{} · Enter to inspect value",
                    path.map(|p| p.display().to_string())
                        .unwrap_or_else(|| "Spotlight process environment".into())
                ),
                "Env",
                Op::Dev(Operation::Inspect {
                    key,
                    path: path.map(Path::to_path_buf),
                }),
            )
        })
        .collect();
    if rows.is_empty() {
        rows.push(hint("No matching variables", "Search by variable name"));
    }
    rows
}
fn github(kind: &str, input: &str, context: &Path) -> Result<Vec<Entry>, String> {
    let mut words = tokens(input)?.into_iter();
    let mut repo = None;
    let mut search = Vec::new();
    while let Some(word) = words.next() {
        match word.as_str() {
            "--repo" | "-R" => {
                repo = Some(
                    words
                        .next()
                        .ok_or("Add owner/repository or a local path after --repo")?,
                );
            }
            "--search" => {
                search.push(words.next().ok_or("Add a search query after --search")?);
            }
            _ => search.push(word),
        }
    }
    let mut command = Command::new("gh");
    command.args([
        kind,
        "list",
        "--limit",
        "40",
        "--json",
        "number,title,url,state",
    ]);
    let scope = if let Some(repo) = repo {
        let path = expand_path(&repo);
        if path.is_absolute() && path.is_dir() {
            command.current_dir(&path);
            path.display().to_string()
        } else if valid_repo(&repo) {
            command.args(["--repo", &repo]);
            repo
        } else {
            return Err("Use --repo owner/repository or --repo /absolute/project/path".into());
        }
    } else {
        let root = boosters::run(
            Command::new("git")
                .arg("-C")
                .arg(context)
                .args(["rev-parse", "--show-toplevel"]),
            3,
        )
        .map_err(|_| {
            format!(
                "No repository context at {} · use project /path or --repo owner/repository",
                context.display()
            )
        })?;
        let root = root.trim_end_matches(['\r', '\n']);
        command.current_dir(root);
        root.to_string()
    };
    let search = search.join(" ");
    if !search.is_empty() {
        command.args(["--search", &search]);
    }
    command
        .env_remove("GH_REPO")
        .env("GH_PROMPT_DISABLED", "1")
        .env("GH_PAGER", "cat");
    let result = boosters::run(&mut command, 18)?;
    let json: serde_json::Value =
        serde_json::from_str(&result).map_err(|_| "GitHub CLI returned invalid JSON")?;
    let array = json.as_array().ok_or("GitHub CLI did not return a list")?;
    let mut rows = Vec::new();
    for value in array.iter().take(40) {
        let Some(url) = value["url"].as_str().filter(|u| valid_web_url(u)) else {
            continue;
        };
        let number = value["number"].as_u64().unwrap_or(0);
        let title = value["title"].as_str().unwrap_or("Untitled");
        let state = value["state"].as_str().unwrap_or("");
        rows.push(entry(
            format!("#{number} · {title}"),
            format!("{state} · {scope} · {url}"),
            "GitHub",
            Op::Dev(Operation::OpenUrl(url.into())),
        ));
    }
    if rows.is_empty() {
        rows.push(hint(
            "No matching results",
            format!("{scope} · Try another repository or search query"),
        ));
    }
    Ok(rows)
}
fn valid_repo(repo: &str) -> bool {
    let p: Vec<_> = repo.split('/').collect();
    p.len() == 2
        && p.iter().all(|p| {
            !p.is_empty()
                && !p.starts_with('-')
                && p.bytes()
                    .all(|c| c.is_ascii_alphanumeric() || b"-_.".contains(&c))
        })
}
fn valid_web_url(url: &str) -> bool {
    url.starts_with("https://")
        && !url.chars().any(|c| c.is_whitespace() || c.is_control())
        && url.len() < 4096
        && url[8..]
            .split('/')
            .next()
            .is_some_and(|s| !s.is_empty() && !s.contains('@'))
}
pub fn fetch(query: &Query) -> Result<Vec<Entry>, String> {
    match query {
        Query::Projects { editor, filter } => ranked_projects(editor, filter, false),
        Query::Context(filter) => ranked_projects("project", filter, true),
        Query::Ssh(filter) => Ok(ssh_entries(filter)),
        Query::Env(filter) => Ok(environment_entries(
            std::env::vars_os()
                .map(|(k, _)| (k.to_string_lossy().into_owned(), String::new()))
                .collect(),
            filter,
            None,
        )),
        Query::Dotenv { input, context } => {
            let (path, filter) = dotenv_target(input, context)?;
            Ok(environment_entries(
                parse_dotenv(&bounded_text(&path)?)?,
                &filter,
                Some(&path),
            ))
        }
        Query::Github {
            kind,
            input,
            context,
        } => github(kind, input, context),
    }
}
pub fn inspect(key: &str, path: Option<&Path>) -> Result<String, String> {
    if let Some(path) = path {
        parse_dotenv(&bounded_text(path)?)?
            .remove(key)
            .ok_or_else(|| "Variable no longer exists".into())
    } else {
        std::env::var(key).map_err(|_| "Variable is unset or not valid UTF-8".into())
    }
}
fn spawn(command: &mut Command) -> Result<(), String> {
    command
        .stdin(Stdio::null())
        .stdout(Stdio::null())
        .stderr(Stdio::null());
    let mut child = command.spawn().map_err(|e| {
        format!(
            "Could not start {}: {e}",
            command.get_program().to_string_lossy()
        )
    })?;
    std::thread::spawn(move || {
        let _ = child.wait();
    });
    Ok(())
}
pub fn execute(operation: Operation) -> Result<String, String> {
    match operation {
        Operation::UseProject(path) => {
            if !path.is_dir() {
                return Err("Project directory no longer exists".into());
            }
            Ok(format!("Project context: {}", path.display()))
        }
        Operation::OpenProject { editor, path } => {
            if !path.exists() {
                return Err("Project no longer exists".into());
            }
            let candidates: &[&str] = match editor.as_str() {
                "code" => &["code"],
                "code-insiders" => &["code-insiders"],
                "codium" => &["codium"],
                "code-oss" => &["code-oss"],
                "idea" => &[
                    "idea",
                    "idea-community",
                    "intellij-idea-community",
                    "intellij-idea-ultimate",
                ],
                "pycharm" => &["pycharm", "pycharm-community", "pycharm-professional"],
                "webstorm" => &["webstorm"],
                "clion" => &["clion"],
                "goland" => &["goland"],
                "rustrover" => &["rustrover"],
                "phpstorm" => &["phpstorm"],
                "rider" => &["rider"],
                "rubymine" => &["rubymine"],
                "datagrip" => &["datagrip"],
                _ => return Err("Unknown editor".into()),
            };
            if let Some(command) = candidates
                .iter()
                .find(|c| gtk::glib::find_program_in_path(c).is_some())
            {
                spawn(Command::new(command).arg(&path))?;
            } else if let Some(app) = gio::AppInfo::all().into_iter().find(|a| {
                let name = a.name().to_ascii_lowercase();
                if editor == "idea" {
                    name.contains("intellij")
                } else {
                    name.contains(&editor)
                }
            }) {
                app.launch(
                    &[gio::File::for_path(&path)],
                    None::<&gio::AppLaunchContext>,
                )
                .map_err(|e| e.to_string())?;
            } else {
                return Err(format!(
                    "Install {editor} or enable its command-line launcher"
                ));
            }
            Ok(format!("Opened {} in {editor}", path.display()))
        }
        Operation::Ssh(host) => {
            if !valid_host(&host) || !ssh_hosts().contains(&host) {
                return Err("SSH alias no longer exists in ~/.ssh/config".into());
            }
            spawn(Command::new("konsole").args(["--separate", "-e", "ssh", "--", &host]))?;
            Ok(format!("Opened SSH · {host}"))
        }
        Operation::OpenUrl(url) => {
            if !valid_web_url(&url) {
                return Err("Invalid GitHub result URL".into());
            }
            gio::AppInfo::launch_default_for_uri(&url, None::<&gio::AppLaunchContext>)
                .map_err(|e| e.to_string())?;
            Ok("Opened in browser".into())
        }
        Operation::Inspect { .. } => {
            Err("Environment values must be opened in the inspector".into())
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn dotenv_literals_quotes_and_errors() {
        let values = parse_dotenv("# comment\nexport NAME = café\nEMPTY=\nTOKEN=abc#def\nCOMMENT=value # note\nSINGLE='${HOME} $(touch nope)'\nDOUBLE=\"line\\nnext\\\"\"\nMULTI='first\nsecond'\nNAME=last\n").unwrap();
        assert_eq!(values["NAME"], "last");
        assert_eq!(values["EMPTY"], "");
        assert_eq!(values["TOKEN"], "abc#def");
        assert_eq!(values["COMMENT"], "value");
        assert_eq!(values["SINGLE"], "${HOME} $(touch nope)");
        assert_eq!(values["DOUBLE"], "line\nnext\"");
        assert_eq!(values["MULTI"], "first\nsecond");
        for bad in [
            "NOT AN ASSIGNMENT",
            "1KEY=value",
            "KEY='unclosed",
            "KEY=\"value\" extra",
        ] {
            assert!(parse_dotenv(bad).is_err());
        }
        assert!(
            !parse_dotenv("1KEY=private-secret")
                .unwrap_err()
                .contains("private-secret")
        );
        let (path, filter) =
            dotenv_target("\"/tmp/my project/.env.local\" API", Path::new("/tmp")).unwrap();
        assert_eq!(path, Path::new("/tmp/my project/.env.local"));
        assert_eq!(filter, "API");
    }
    #[test]
    fn ssh_includes_aliases_and_cycles() {
        let root =
            std::env::temp_dir().join(format!("spotlight-ssh-{}", gtk::glib::uuid_string_random()));
        fs::create_dir_all(root.join("hosts")).unwrap();
        fs::write(root.join("config"),"Host=main alias\nHost * !excluded -oProxyCommand=bad\nInclude hosts/*.conf\nMatch exec \"touch must-not-run\"\n").unwrap();
        fs::write(
            root.join("hosts/a.conf"),
            "host \"unicode-safe\" # comment\nInclude config\nHost secondary\n",
        )
        .unwrap();
        let mut hosts = Vec::new();
        ssh_hosts_from(
            &root.join("config"),
            &root,
            &mut HashSet::new(),
            &mut hosts,
            0,
        );
        assert_eq!(hosts, ["main", "alias", "unicode-safe", "secondary"]);
        assert_eq!(
            tokens("Include \"hosts/a b.conf\" # note").unwrap(),
            ["Include", "hosts/a b.conf"]
        );
        fs::remove_dir_all(root).unwrap();
    }
    #[test]
    fn command_boundaries() {
        for query in [
            "code sample",
            "jetbrains sample",
            "project use /tmp",
            "ssh myserver",
            "env PATH",
            "dotenv API",
            "gh pr list",
            "gh issue bug",
        ] {
            assert!(Query::parse(query).is_some(), "{query}");
        }
        for query in [
            "codeium",
            "environmental",
            "sshd",
            "gh repo view owner/repo",
        ] {
            assert!(Query::parse(query).is_none());
        }
        assert!(valid_repo("owner/repo"));
        assert!(!valid_repo("--repo/x"));
        assert!(!valid_web_url("file:///tmp/a"));
        assert!(!valid_web_url("https://user@host/path"));
    }
    #[test]
    #[ignore = "run tests/devtools_smoke.py with private editor/CLI fixtures"]
    fn fixtures() {
        let root = PathBuf::from(std::env::var_os("SPOTLIGHT_DEVTOOLS_ROOT").unwrap());
        assert_eq!(core::home(), root.join("home"));
        let project = root.join("my project café");
        let jetbrains = root.join("JetBrains project");
        let rows = fetch(&Query::parse("code café").unwrap()).unwrap();
        assert_eq!(rows.len(), 1);
        let Some(Op::Dev(Operation::OpenProject { editor, path })) = &rows[0].operation else {
            panic!("Missing Code action")
        };
        assert_eq!(editor, "code");
        assert_eq!(path, &project);
        execute(Operation::OpenProject {
            editor: editor.clone(),
            path: path.clone(),
        })
        .unwrap();
        let workspace = fetch(&Query::parse("code DemoWorkspace").unwrap()).unwrap();
        assert!(
            matches!(&workspace[0].operation,Some(Op::Dev(Operation::OpenProject{path,..})) if path==&root.join("DemoWorkspace.code-workspace"))
        );
        let direct = fetch(&Query::parse("project ~/Projects/demo").unwrap()).unwrap();
        assert!(direct.iter().any(|r|matches!(&r.operation,Some(Op::Dev(Operation::UseProject(path))) if path==&core::home().join("Projects/demo"))));
        let rows = fetch(&Query::parse("jetbrains project").unwrap()).unwrap();
        assert_eq!(rows.len(), 1);
        let Some(Op::Dev(Operation::OpenProject { editor, path })) = &rows[0].operation else {
            panic!("Missing JetBrains action")
        };
        assert_eq!(path, &jetbrains);
        execute(Operation::OpenProject {
            editor: editor.clone(),
            path: path.clone(),
        })
        .unwrap();
        assert!(
            fetch(&Query::parse("code missing").unwrap())
                .unwrap()
                .iter()
                .all(|r| r.operation.is_none())
        );
        assert_eq!(ssh_hosts(), ["myserver", "second", "included"]);
        execute(Operation::Ssh("myserver".into())).unwrap();
        assert!(execute(Operation::Ssh("--bad".into())).is_err());
        let env = fetch(&Query::parse("env SPOTLIGHT_TEST_SECRET").unwrap()).unwrap();
        assert!(!format!("{env:?}").contains("private-fixture-value"));
        assert_eq!(
            inspect("SPOTLIGHT_TEST_SECRET", None).unwrap(),
            "private-fixture-value"
        );
        let dotenv = fetch(&Query::Dotenv {
            input: "".into(),
            context: project.clone(),
        })
        .unwrap();
        assert!(!format!("{dotenv:?}").contains("dotenv-private-value"));
        assert_eq!(
            inspect("API_KEY", Some(&project.join(".env"))).unwrap(),
            "dotenv-private-value"
        );
        let rows = fetch(&Query::Github {
            kind: "pr".into(),
            input: "".into(),
            context: project.clone(),
        })
        .unwrap();
        assert_eq!(rows[0].title, "#12 · Fix café");
        assert!(rows[0].detail.contains(project.to_str().unwrap()));
        assert_eq!(
            fetch(&Query::Github {
                kind: "issue".into(),
                input: "--repo owner/demo --search \"label:bug shell; $(nope)\"".into(),
                context: root.clone()
            })
            .unwrap()
            .len(),
            1
        );
        assert_eq!(
            fetch(&Query::Github {
                kind: "pr".into(),
                input: format!("--repo \"{}\"", project.display()),
                context: root.clone()
            })
            .unwrap()
            .len(),
            1
        );
        assert!(
            fetch(&Query::Github {
                kind: "pr".into(),
                input: "".into(),
                context: root.clone()
            })
            .is_err()
        );
        fs::write(core::home().join(".ssh/config"), "Host second\n").unwrap();
        assert!(execute(Operation::Ssh("myserver".into())).is_err());
    }
}

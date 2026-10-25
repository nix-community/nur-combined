use crate::core;
use serde_json::Value;
use std::{
    fs,
    io::{Read, Write},
    os::unix::fs::MetadataExt,
    path::{Path, PathBuf},
    process::{Command, Stdio},
    time::{Duration, Instant},
};

#[derive(Clone, Debug, PartialEq, Eq, Hash)]
pub enum Query {
    System(crate::systemtools::Query),
    Productivity(crate::productivity::Query),
    Dev(crate::devtools::Query),
    Advanced(crate::advanced::Query),
    Local(crate::localtools::Query),
    Kit(crate::devkit::Query),
    Offline(crate::offline::Query),
    Windows(String),
    Desktops(String),
    Switcher(String),
    Text(crate::texttools::Query),
    Search(crate::search::Query),
    Pim(crate::pim::Kind, String),
    Define(String),
    Kill(String),
    Repos(String, bool),
    Clone(String),
    Containers(String, String),
}
impl Query {
    pub fn parse(text: &str) -> Option<Self> {
        if let Some(query) = crate::systemtools::Query::parse(text) {
            return Some(Self::System(query));
        }
        if let Some(query) = crate::devkit::Query::parse(text) {
            return Some(Self::Kit(query));
        }
        if let Some(query) = crate::localtools::Query::parse(text) {
            return Some(Self::Local(query));
        }
        if let Some(query) = crate::productivity::Query::parse(text) {
            return Some(Self::Productivity(query));
        }
        if let Some(query) = crate::devtools::Query::parse(text) {
            return Some(Self::Dev(query));
        }
        if let Some(query) = crate::advanced::Query::parse(text) {
            return Some(Self::Advanced(query));
        }
        if let Some(query) = crate::offline::parse(text) {
            return Some(Self::Offline(query));
        }
        if let Some(query) = crate::search::Query::parse(text) {
            return Some(Self::Search(query));
        }
        let (head, tail) = text
            .trim()
            .split_once(char::is_whitespace)
            .unwrap_or((text.trim(), ""));
        let tail = tail.trim();
        if let Some(query) = crate::texttools::Query::parse(&head.to_ascii_lowercase(), tail) {
            return Some(Self::Text(query));
        }
        Some(match head.to_ascii_lowercase().as_str() {
            "desktop" | "desktops" => Self::Desktops(tail.into()),
            "switch" | "switcher" => Self::Switcher(tail.into()),
            "window"
                if !["shortcuts", "manager"]
                    .iter()
                    .any(|prefix| tail.starts_with(prefix)) =>
            {
                Self::Windows(tail.into())
            }
            "contacts" | "contact" => Self::Pim(crate::pim::Kind::Contacts, tail.into()),
            "calendar" | "events" => Self::Pim(crate::pim::Kind::Calendar, tail.into()),
            "define" | "dictionary" | "dict" => Self::Define(tail.to_lowercase()),
            "kill" => Self::Kill(tail.to_lowercase()),
            "repos" | "repo" => Self::Repos(tail.into(), false),
            "git" if tail == "clone" => Self::Clone(String::new()),
            "git" if tail.starts_with("clone ") => Self::Clone(tail[6..].trim().into()),
            "git" => Self::Repos(tail.strip_prefix("repos ").unwrap_or(tail).into(), false),
            "gh" if tail == "repo view" || tail.starts_with("repo view ") => {
                Self::Repos(tail[9..].trim().into(), true)
            }
            "docker" | "podman" => Self::Containers(
                head.to_ascii_lowercase(),
                tail.strip_prefix("ps")
                    .filter(|s| s.is_empty() || s.starts_with(' '))
                    .unwrap_or(tail)
                    .trim()
                    .into(),
            ),
            _ => return None,
        })
    }
    pub fn ttl(&self) -> Duration {
        Duration::from_secs(match self {
            Self::Define(_) => 3600,
            Self::Text(_) => 3600,
            Self::Search(_) => 10,
            Self::Pim(..) => 30,
            Self::Repos(..) => 30,
            _ => 3,
        })
    }
}

#[derive(Clone, Debug)]
pub enum Operation {
    System(crate::systemtools::Operation),
    Productivity(crate::productivity::Operation),
    Dev(crate::devtools::Operation),
    Advanced(crate::advanced::Operation),
    Local(crate::localtools::Operation),
    Kit(crate::devkit::Operation),
    Query(String),
    FocusWindow(String),
    SwitchDesktop(String),
    OpenPath(PathBuf),
    Preview {
        title: String,
        text: String,
        open: Option<String>,
    },
    Copy(String),
    Terminate {
        pid: u32,
        started: u64,
    },
    OpenRepo(PathBuf),
    ViewRepo(PathBuf),
    ViewRemote(String),
    Clone(String),
    Container {
        engine: String,
        id: String,
        start: bool,
    },
}
#[derive(Clone, Debug)]
pub struct Entry {
    pub title: String,
    pub detail: String,
    pub badge: &'static str,
    pub operation: Option<Operation>,
}
pub(crate) fn entry(
    title: impl Into<String>,
    detail: impl Into<String>,
    badge: &'static str,
    operation: Operation,
) -> Entry {
    Entry {
        title: title.into(),
        detail: detail.into(),
        badge,
        operation: Some(operation),
    }
}
pub fn hint(title: impl Into<String>, detail: impl Into<String>) -> Entry {
    Entry {
        title: title.into(),
        detail: detail.into(),
        badge: "Info",
        operation: None,
    }
}

// All tool arguments are passed directly, never interpolated into a shell.
// Drain bounded output on separate threads so a noisy child cannot block GTK.
pub fn run(command: &mut Command, seconds: u64) -> Result<String, String> {
    run_input(command, seconds, None)
}

pub fn run_input(
    command: &mut Command,
    seconds: u64,
    input: Option<&[u8]>,
) -> Result<String, String> {
    let program = command.get_program().to_string_lossy().into_owned();
    let mut child = command
        .stdin(if input.is_some() {
            Stdio::piped()
        } else {
            Stdio::null()
        })
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .map_err(|e| format!("Could not run {program}: {e}"))?;
    if let Some(input) = input {
        let input = input.to_vec();
        let mut stdin = child.stdin.take().unwrap();
        std::thread::spawn(move || {
            let _ = stdin.write_all(&input);
        });
    }
    fn drain(mut pipe: impl Read + Send + 'static) -> std::sync::mpsc::Receiver<Vec<u8>> {
        let (tx, rx) = std::sync::mpsc::channel();
        std::thread::spawn(move || {
            let mut result = Vec::new();
            let mut buffer = [0; 4096];
            while let Ok(n) = pipe.read(&mut buffer) {
                if n == 0 {
                    break;
                }
                let keep = n.min(1_048_576usize.saturating_sub(result.len()));
                result.extend_from_slice(&buffer[..keep]);
            }
            let _ = tx.send(result);
        });
        rx
    }
    let stdout = drain(child.stdout.take().unwrap());
    let stderr = drain(child.stderr.take().unwrap());
    let start = Instant::now();
    let status = loop {
        match child.try_wait() {
            Ok(Some(status)) => break status,
            Ok(None) if start.elapsed() < Duration::from_secs(seconds) => {
                std::thread::sleep(Duration::from_millis(30))
            }
            _ => {
                let _ = child.kill();
                let _ = child.wait();
                return Err(format!("{program} timed out or was interrupted"));
            }
        }
    };
    // Browser launchers can leave pipes open in descendants after the CLI exits.
    let remaining = Duration::from_secs(seconds)
        .saturating_sub(start.elapsed())
        .min(Duration::from_secs(2));
    let out = stdout.recv_timeout(remaining).unwrap_or_default();
    let err = stderr.recv_timeout(remaining).unwrap_or_default();
    if !status.success() {
        let detail: String = String::from_utf8_lossy(&err).chars().take(600).collect();
        return Err(format!(
            "{program}: {}",
            if detail.trim().is_empty() {
                status.to_string()
            } else {
                detail.trim().into()
            }
        ));
    }
    String::from_utf8(out).map_err(|_| format!("{program} returned invalid text"))
}

pub fn fetch(query: &Query) -> Result<Vec<Entry>, String> {
    match query {
        Query::System(query) => crate::systemtools::fetch(query),
        Query::Productivity(query) => crate::productivity::fetch(query),
        Query::Dev(query) => crate::devtools::fetch(query),
        Query::Advanced(query) => crate::advanced::fetch(query),
        Query::Local(query) => crate::localtools::fetch(query),
        Query::Kit(query) => crate::devkit::fetch(query),
        Query::Offline(query) => crate::offline::fetch(query),
        Query::Windows(query) => crate::windowing::fetch(query),
        Query::Desktops(query) => crate::windowing::fetch_desktops(query),
        Query::Switcher(query) => crate::windowing::fetch_switcher(query),
        Query::Text(query) => crate::texttools::fetch(query),
        Query::Search(query) => crate::search::fetch(query),
        Query::Pim(kind, text) => crate::pim::fetch(*kind, text),
        Query::Define(word) => definitions(word),
        Query::Kill(filter) => processes(filter),
        Query::Repos(filter, web) => repositories(filter, *web),
        Query::Clone(url) => {
            if url.is_empty() {
                return Ok(vec![hint(
                    "Clone a Git repository",
                    "Type git clone https://host/owner/repo.git · saves in ~/Projects",
                )]);
            }
            let name = clone_name(url)?;
            Ok(vec![entry(
                format!("Clone {name}"),
                format!(
                    "{url} → {}",
                    core::home().join("Projects").join(name).display()
                ),
                "Clone",
                Operation::Clone(url.clone()),
            )])
        }
        Query::Containers(engine, filter) => containers(engine, filter),
    }
}

pub fn process_identity(pid: u32) -> Result<u64, String> {
    let stat = fs::read_to_string(format!("/proc/{pid}/stat"))
        .map_err(|_| "Process has already exited")?;
    if stat
        .rsplit_once(") ")
        .is_some_and(|(_, tail)| tail.starts_with("Z ") || tail.starts_with("X "))
    {
        return Err("Process has already exited".into());
    }
    stat.rsplit_once(") ")
        .and_then(|(_, s)| s.split_whitespace().nth(19))
        .and_then(|s| s.parse().ok())
        .ok_or_else(|| "Could not identify process".into())
}
fn processes(filter: &str) -> Result<Vec<Entry>, String> {
    let uid = fs::metadata("/proc/self").map_err(|e| e.to_string())?.uid();
    let mut found = Vec::new();
    for dir in fs::read_dir("/proc").map_err(|e| e.to_string())?.flatten() {
        let Some(pid) = dir.file_name().to_str().and_then(|s| s.parse::<u32>().ok()) else {
            continue;
        };
        if pid <= 1 || pid == std::process::id() || !dir.metadata().is_ok_and(|m| m.uid() == uid) {
            continue;
        }
        let path = dir.path();
        let Ok(name) = fs::read_to_string(path.join("comm")) else {
            continue;
        };
        let name = name.trim();
        if !filter.is_empty() && !name.to_lowercase().contains(filter) && pid.to_string() != filter
        {
            continue;
        }
        let Ok(started) = process_identity(pid) else {
            continue;
        };
        let command = fs::File::open(path.join("cmdline"))
            .ok()
            .map(|file| {
                let mut bytes = Vec::new();
                let _ = file.take(512).read_to_end(&mut bytes);
                String::from_utf8_lossy(&bytes).replace('\0', " ")
            })
            .unwrap_or_default();
        found.push((
            name.to_lowercase(),
            pid,
            entry(
                format!("Terminate {name} · PID {pid}"),
                format!("SIGTERM · {command}"),
                "Kill",
                Operation::Terminate { pid, started },
            ),
        ));
    }
    found.sort_by(|a, b| a.0.cmp(&b.0).then(a.1.cmp(&b.1)));
    let mut result: Vec<_> = found.into_iter().take(100).map(|(_, _, e)| e).collect();
    if result.is_empty() {
        result.push(hint(
            "No matching processes",
            "Type kill firefox or kill <PID> · only your own processes are listed",
        ));
    }
    Ok(result)
}

fn repo_paths(root: &Path) -> Vec<PathBuf> {
    let mut pending = vec![(root.to_path_buf(), 0)];
    let mut repos = Vec::new();
    let mut visited = 0;
    while let Some((dir, depth)) = pending.pop() {
        visited += 1;
        if visited > 20_000 {
            break;
        }
        if dir.join(".git").exists() {
            repos.push(dir.clone());
        }
        if depth >= 7 {
            continue;
        }
        let Ok(entries) = fs::read_dir(dir) else {
            continue;
        };
        for e in entries.flatten() {
            let name = e.file_name();
            let name = name.to_string_lossy();
            if name.starts_with('.')
                || [
                    "target",
                    "node_modules",
                    "vendor",
                    "__pycache__",
                    "build",
                    "dist",
                ]
                .contains(&name.as_ref())
            {
                continue;
            }
            if e.file_type().is_ok_and(|ty| ty.is_dir()) {
                pending.push((e.path(), depth + 1));
            }
        }
    }
    repos
}
fn repositories(filter: &str, web: bool) -> Result<Vec<Entry>, String> {
    // Search one bounded tree, including repositories outside conventional Projects folders.
    let mut repos: Vec<_> = repo_paths(&core::home())
        .into_iter()
        .filter_map(|path| {
            let name = path.file_name()?.to_string_lossy();
            let score = core::score(filter, &name)
                .or_else(|| core::score(filter, &path.to_string_lossy()))?;
            Some((score, path))
        })
        .collect();
    repos.sort_by(|a, b| b.0.cmp(&a.0).then(a.1.cmp(&b.1)));
    let mut result = Vec::new();
    for (_, path) in repos.into_iter().take(40) {
        let name = path.file_name().unwrap_or_default().to_string_lossy();
        if !web {
            result.push(entry(
                format!("Open {name}"),
                path.display().to_string(),
                "Repo",
                Operation::OpenRepo(path.clone()),
            ));
        }
        result.push(entry(
            format!("GitHub · {name}"),
            format!("gh repo view --web · {}", path.display()),
            "GitHub",
            Operation::ViewRepo(path.clone()),
        ));
    }
    if web && valid_remote_name(filter) {
        result.insert(
            0,
            entry(
                format!("View {filter} on GitHub"),
                "gh repo view --web · requires GitHub CLI",
                "GitHub",
                Operation::ViewRemote(filter.into()),
            ),
        );
    }
    if result.is_empty() {
        result.push(hint(
            "No matching repositories",
            "Type git <name>, repos <name>, gh repo view owner/repo, or git clone <url>",
        ));
    }
    Ok(result)
}
fn valid_remote_name(text: &str) -> bool {
    let parts: Vec<_> = text.split('/').collect();
    parts.len() == 2
        && parts.iter().all(|s| {
            !s.is_empty()
                && !s.starts_with('-')
                && s.bytes()
                    .all(|b| b.is_ascii_alphanumeric() || b"-_.".contains(&b))
        })
}
fn clone_name(url: &str) -> Result<&str, String> {
    if url.chars().any(|c| c.is_whitespace() || c.is_control())
        || !(url.starts_with("https://") || url.starts_with("ssh://") || url.starts_with("git@"))
    {
        return Err("Use an HTTPS, ssh://, or git@host:owner/repo URL without spaces".into());
    }
    let name = url
        .trim_end_matches('/')
        .rsplit(['/', ':'])
        .next()
        .unwrap_or("")
        .trim_end_matches(".git");
    if name.is_empty()
        || name == "."
        || name == ".."
        || name.starts_with('-')
        || !name
            .bytes()
            .all(|b| b.is_ascii_alphanumeric() || b"-_.".contains(&b))
    {
        return Err("The repository URL needs a valid repository name".into());
    }
    Ok(name)
}

fn containers(engine: &str, filter: &str) -> Result<Vec<Entry>, String> {
    let output = run(
        Command::new(engine).args(["ps", "-a", "--no-trunc", "--format", "{{json .}}"]),
        12,
    )?;
    decode_containers(engine, filter, &output)
}
fn decode_containers(engine: &str, filter: &str, output: &str) -> Result<Vec<Entry>, String> {
    let mut result = Vec::new();
    for line in output.lines().filter(|s| !s.trim().is_empty()) {
        let v: Value = serde_json::from_str(line).map_err(|_| "Invalid container list")?;
        let id = v
            .get("ID")
            .or_else(|| v.get("Id"))
            .and_then(Value::as_str)
            .unwrap_or("");
        if id.len() < 12 || !id.bytes().all(|b| b.is_ascii_hexdigit()) {
            continue;
        }
        let names = v
            .get("Names")
            .map(|n| {
                n.as_str().map(str::to_owned).unwrap_or_else(|| {
                    n.as_array()
                        .map(|a| {
                            a.iter()
                                .filter_map(Value::as_str)
                                .collect::<Vec<_>>()
                                .join(", ")
                        })
                        .unwrap_or_default()
                })
            })
            .unwrap_or_default();
        let state = v.get("State").and_then(Value::as_str).unwrap_or("");
        let status = v.get("Status").and_then(Value::as_str).unwrap_or(state);
        let image = v.get("Image").and_then(Value::as_str).unwrap_or("");
        if core::score(filter, &format!("{names} {id} {image}")).is_none() {
            continue;
        }
        let running = state == "running" || (state.is_empty() && status.starts_with("Up"));
        let start = matches!(state, "created" | "exited" | "stopped" | "configured")
            || (state.is_empty()
                && (status.starts_with("Exited") || status.starts_with("Created")));
        let title = format!(
            "{} {names} · {}",
            if running {
                "Stop"
            } else if start {
                "Start"
            } else {
                "Container"
            },
            &id[..12]
        );
        result.push(Entry {
            title,
            detail: format!("{engine} · {status} · {image}"),
            badge: "Container",
            operation: (running || start).then(|| Operation::Container {
                engine: engine.into(),
                id: id.into(),
                start: !running,
            }),
        });
    }
    if result.is_empty() {
        result.push(hint(
            format!("No {engine} containers found"),
            "Lists running and stopped containers · type a name to filter",
        ));
    }
    Ok(result)
}

fn definitions(word: &str) -> Result<Vec<Entry>, String> {
    if word.is_empty() {
        return Ok(vec![hint(
            "Dictionary · English definitions",
            "Type define <word> or dictionary <word> · requires internet",
        )]);
    }
    if word.chars().count() > 80 || !word.chars().all(|c| c.is_alphabetic() || " '-".contains(c)) {
        return Err("Enter an English word or phrase, up to 80 characters".into());
    }
    let url = format!(
        "https://api.dictionaryapi.dev/api/v2/entries/en/{}",
        core::encode(word)
    );
    let output = run(
        Command::new("curl").args([
            "--silent",
            "--show-error",
            "--connect-timeout",
            "5",
            "--max-time",
            "12",
            "--max-filesize",
            "262144",
            &url,
        ]),
        15,
    )?;
    decode_definitions(word, &output)
}
fn decode_definitions(word: &str, output: &str) -> Result<Vec<Entry>, String> {
    let entries: Value =
        serde_json::from_str(output).map_err(|_| "Dictionary returned an invalid response")?;
    if entries.get("title").and_then(Value::as_str) == Some("No Definitions Found") {
        return Err(format!("No definition found for “{word}”"));
    }
    let mut result = Vec::new();
    for e in entries
        .as_array()
        .ok_or("Dictionary unavailable · try again later")?
    {
        let phonetic = e.get("phonetic").and_then(Value::as_str).unwrap_or("");
        for meaning in e
            .get("meanings")
            .and_then(Value::as_array)
            .into_iter()
            .flatten()
        {
            let pos = meaning
                .get("partOfSpeech")
                .and_then(Value::as_str)
                .unwrap_or("");
            for def in meaning
                .get("definitions")
                .and_then(Value::as_array)
                .into_iter()
                .flatten()
                .take(4)
            {
                let Some(text) = def.get("definition").and_then(Value::as_str) else {
                    continue;
                };
                let example = def.get("example").and_then(Value::as_str).unwrap_or("");
                result.push(entry(
                    text,
                    format!("{word} {phonetic} · {pos} · {example} · Free Dictionary API"),
                    "Copy",
                    Operation::Copy(format!("{word} ({pos}): {text}")),
                ));
                if result.len() >= 16 {
                    return Ok(result);
                }
            }
        }
    }
    if result.is_empty() {
        return Err(format!("No definition found for “{word}”"));
    }
    Ok(result)
}

pub fn execute(operation: Operation) -> Result<String, String> {
    match operation {
        Operation::System(_) => Err("This command must be opened in Spotlight".into()),
        Operation::Kit(_) => Err("This action needs the Spotlight window".into()),
        Operation::Local(_) => Err("This command must be opened in Spotlight".into()),
        Operation::Productivity(_) => Err("This command must be opened in Spotlight".into()),
        Operation::Dev(operation) => crate::devtools::execute(operation),
        Operation::Advanced(operation) => crate::advanced::execute(operation),
        Operation::FocusWindow(id) => crate::windowing::focus(&id),
        Operation::SwitchDesktop(id) => crate::windowing::switch_desktop(&id),
        Operation::Terminate { pid, started } => {
            signal_process(pid, started, 15)?;
            Ok(format!("Sent SIGTERM to PID {pid}"))
        }
        Operation::ViewRepo(path) => {
            run(
                Command::new("gh")
                    .args(["repo", "view", "--web"])
                    .current_dir(path),
                20,
            )?;
            Ok("Opened repository on GitHub".into())
        }
        Operation::ViewRemote(name) => {
            if !valid_remote_name(&name) {
                return Err("Invalid GitHub owner/repository".into());
            }
            run(
                Command::new("gh").args(["repo", "view", &name, "--web"]),
                20,
            )?;
            Ok("Opened repository on GitHub".into())
        }
        Operation::Clone(url) => {
            let name = clone_name(&url)?;
            let root = core::home().join("Projects");
            fs::create_dir_all(&root).map_err(|e| e.to_string())?;
            let destination = root.join(name);
            if destination.exists() {
                return Err(format!("Already exists: {}", destination.display()));
            }
            run(
                Command::new("git")
                    .env("GIT_TERMINAL_PROMPT", "0")
                    .env(
                        "GIT_SSH_COMMAND",
                        "ssh -oBatchMode=yes -oStrictHostKeyChecking=yes",
                    )
                    .args(["-c", "credential.interactive=false", "clone", "--", &url])
                    .arg(&destination),
                120,
            )?;
            Ok(format!("Cloned to {}", destination.display()))
        }
        Operation::Container { engine, id, start } => {
            if !["docker", "podman"].contains(&engine.as_str())
                || id.len() < 12
                || !id.bytes().all(|b| b.is_ascii_hexdigit())
            {
                return Err("Invalid container action".into());
            }
            run(
                Command::new(&engine).args([if start { "start" } else { "stop" }, &id]),
                35,
            )?;
            Ok(format!(
                "{} container {}",
                if start { "Started" } else { "Stopped" },
                &id[..12]
            ))
        }
        _ => Err("This operation belongs in the launcher UI".into()),
    }
}
pub fn signal_process(pid: u32, started: u64, signal: i32) -> Result<(), String> {
    if !matches!(signal, 9 | 15)
        || pid <= 1
        || pid == std::process::id()
        || process_identity(pid)? != started
    {
        return Err("Process changed or exited; search again".into());
    }
    let uid = fs::metadata("/proc/self").map_err(|e| e.to_string())?.uid();
    if fs::metadata(format!("/proc/{pid}"))
        .map_err(|e| e.to_string())?
        .uid()
        != uid
    {
        return Err("Only your own processes can be terminated".into());
    }
    let fd = unsafe { pidfd_open(pid as i32, 0) };
    if fd < 0 {
        return Err(std::io::Error::last_os_error().to_string());
    }
    let valid = process_identity(pid).is_ok_and(|s| s == started);
    let sent = valid && unsafe { pidfd_send_signal(fd, signal, std::ptr::null(), 0) } == 0;
    unsafe {
        close(fd);
    }
    if sent {
        Ok(())
    } else {
        Err("Process exited or could not be terminated; search again".into())
    }
}
unsafe extern "C" {
    fn pidfd_open(pid: i32, flags: u32) -> i32;
    fn pidfd_send_signal(fd: i32, signal: i32, info: *const std::ffi::c_void, flags: u32) -> i32;
    fn close(fd: i32) -> i32;
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn command_parsing_and_clone_validation() {
        assert_eq!(
            Query::parse("define café"),
            Some(Query::Define("café".into()))
        );
        assert_eq!(
            Query::parse("kill firefox"),
            Some(Query::Kill("firefox".into()))
        );
        assert_eq!(
            Query::parse("gh repo view owner/repo"),
            Some(Query::Repos("owner/repo".into(), true))
        );
        assert_eq!(
            Query::parse("podman ps web"),
            Some(Query::Containers("podman".into(), "web".into()))
        );
        assert_eq!(
            Query::parse("docker postgres"),
            Some(Query::Containers("docker".into(), "postgres".into()))
        );
        assert_eq!(clone_name("git@github.com:owner/repo.git").unwrap(), "repo");
        for bad in [
            "--upload-pack=evil",
            "https://host/..",
            "https://host/a;evil",
            "https://host/repo\nother",
        ] {
            assert!(clone_name(bad).is_err());
        }
        assert!(Query::parse("killer").is_none());
    }
    #[test]
    fn container_formats_and_states() {
        let id = "a".repeat(64);
        for (names, state, start) in [("\"web\"", "running", false), ("[\"db\"]", "exited", true)] {
            let text =
                format!(r#"{{"ID":"{id}","Names":{names},"State":"{state}","Image":"test"}}"#);
            let entries = decode_containers("podman", "", &text).unwrap();
            assert!(
                matches!(&entries[0].operation, Some(Operation::Container { start: s, .. }) if *s == start)
            );
        }
        let text = format!(r#"{{"ID":"{id}","Names":"paused","State":"paused"}}"#);
        assert!(
            decode_containers("docker", "", &text).unwrap()[0]
                .operation
                .is_none()
        );
        assert!(decode_containers("docker", "", "not-json").is_err());
    }
    #[test]
    fn dictionary_responses() {
        let text = r#"[{"phonetic":"/test/","meanings":[{"partOfSpeech":"noun","definitions":[{"definition":"A trial.","example":"A test."}]}]}]"#;
        let defs = decode_definitions("test", text).unwrap();
        assert_eq!(defs[0].title, "A trial.");
        assert!(defs[0].detail.contains("noun"));
        assert!(decode_definitions("unknown", r#"{"title":"No Definitions Found"}"#).is_err());
        assert!(decode_definitions("test", "[]").is_err());
    }
    #[test]
    fn terminate_only_selected_child_and_reject_stale_pid() {
        let mut child = Command::new("sleep").arg("30").spawn().unwrap();
        let pid = child.id();
        let started = process_identity(pid).unwrap();
        assert!(
            execute(Operation::Terminate {
                pid,
                started: started + 1
            })
            .is_err()
        );
        assert!(child.try_wait().unwrap().is_none());
        execute(Operation::Terminate { pid, started }).unwrap();
        assert!(!child.wait().unwrap().success());
        assert!(
            execute(Operation::Terminate {
                pid: std::process::id(),
                started: 0
            })
            .is_err()
        );
    }
    #[test]
    fn repo_discovery_includes_worktrees_and_skips_output() {
        let root = std::env::temp_dir().join(format!("spotlight-repos-{}", std::process::id()));
        fs::create_dir_all(root.join("real/.git")).unwrap();
        fs::create_dir_all(root.join("worktree")).unwrap();
        fs::write(root.join("worktree/.git"), "gitdir: elsewhere").unwrap();
        fs::create_dir_all(root.join("node_modules/ignored/.git")).unwrap();
        let repos = repo_paths(&root);
        assert_eq!(repos.len(), 2);
        fs::remove_dir_all(root).unwrap();
    }
    #[test]
    fn command_failures_and_deadlines() {
        assert!(
            run(
                Command::new("sh").args(["-c", "echo fixture-error >&2; exit 2"]),
                2
            )
            .unwrap_err()
            .contains("fixture-error")
        );
        let started = Instant::now();
        assert!(run(Command::new("sleep").arg("10"), 0).is_err());
        assert!(started.elapsed() < Duration::from_secs(2));
    }
}

use crate::{
    boosters::{self, Entry, Operation as Op, entry, hint},
    core, devtools,
};
use gtk::prelude::*;
use serde_json::Value;
use std::{
    collections::BTreeSet,
    fs,
    io::{BufRead, BufReader, Read},
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
    Git(String),
    Container {
        engine: String,
        mode: String,
        input: String,
    },
    Http(String, String),
    EnvDiff(String, PathBuf),
}
#[derive(Clone, Debug)]
pub enum Operation {
    Logs {
        engine: String,
        id: String,
        name: String,
    },
    Exec {
        engine: String,
        id: String,
        command: Vec<String>,
    },
    Http(String, String),
    EnvDiff {
        left: PathBuf,
        right: PathBuf,
        key: String,
    },
}
fn action(
    title: impl Into<String>,
    detail: impl Into<String>,
    badge: &'static str,
    op: Operation,
) -> Entry {
    entry(title, detail, badge, Op::Kit(op))
}
impl Query {
    pub fn parse(text: &str) -> Option<Self> {
        let (head, tail) = text
            .trim()
            .split_once(char::is_whitespace)
            .unwrap_or((text.trim(), ""));
        let tail = tail.trim();
        let head = head.to_ascii_lowercase();
        if head == "git" && (tail == "status" || tail.starts_with("status ")) {
            return Some(Self::Git(tail[6..].trim().into()));
        }
        if head == "dotenv" && (tail == "diff" || tail.starts_with("diff ")) {
            return Some(Self::EnvDiff(tail[4..].trim().into(), devtools::context()));
        }
        if ["get", "post", "put", "patch", "delete", "head", "http"].contains(&head.as_str()) {
            return Some(Self::Http(
                if head == "http" {
                    "GET".into()
                } else {
                    head.to_ascii_uppercase()
                },
                tail.into(),
            ));
        }
        if head == "logs" {
            return Some(Self::Container {
                engine: "docker".into(),
                mode: "logs".into(),
                input: tail.into(),
            });
        }
        if ["docker", "podman"].contains(&head.as_str()) {
            let (mode, input) = tail.split_once(char::is_whitespace).unwrap_or((tail, ""));
            if ["logs", "exec"].contains(&mode) {
                return Some(Self::Container {
                    engine: head,
                    mode: mode.into(),
                    input: input.trim().into(),
                });
            }
        }
        None
    }
}
pub fn fetch(query: &Query) -> Result<Vec<Entry>, String> {
    match query {
        Query::Git(filter) => git_dashboard(&core::home().join("Projects"), filter),
        Query::Http(method, url) => Ok(vec![action(
            format!("{method} {}", if url.is_empty() { "request" } else { url }),
            "Open HTTP scratch · edit headers/body, then Send",
            "HTTP",
            Operation::Http(method.clone(), url.clone()),
        )]),
        Query::Container {
            engine,
            mode,
            input,
        } => containers(engine, mode, input),
        Query::EnvDiff(input, context) => env_diff(input, context),
    }
}
pub fn git_dashboard(root: &Path, filter: &str) -> Result<Vec<Entry>, String> {
    if !root.is_dir() {
        return Ok(vec![hint(
            "Projects folder not found",
            root.display().to_string(),
        )]);
    }
    let started = Instant::now();
    let mut stack = vec![root.to_path_buf()];
    let mut repos = Vec::new();
    let mut visits = 0;
    let mut limited = false;
    while let Some(dir) = stack.pop() {
        visits += 1;
        if visits > 100_000 || started.elapsed() > Duration::from_secs(20) {
            limited = true;
            break;
        }
        if dir.join(".git").exists() {
            repos.push(dir.clone());
        }
        if let Ok(entries) = fs::read_dir(&dir) {
            for e in entries.flatten() {
                let name = e.file_name();
                if [
                    ".git",
                    "target",
                    "node_modules",
                    "vendor",
                    "__pycache__",
                    "build",
                    "dist",
                ]
                .contains(&name.to_string_lossy().as_ref())
                {
                    continue;
                }
                if e.file_type().is_ok_and(|t| t.is_dir()) {
                    stack.push(e.path());
                }
            }
        }
    }
    repos.sort();
    let mut rows = Vec::new();
    let mut scanned = 0;
    let mut dirty = 0;
    for repo in repos {
        if started.elapsed() > Duration::from_secs(30) {
            limited = true;
            break;
        }
        scanned += 1;
        let result = boosters::run(
            Command::new("git")
                .args(["--no-optional-locks", "-C"])
                .arg(&repo)
                .args([
                    "status",
                    "--porcelain=v1",
                    "-z",
                    "--branch",
                    "--untracked-files=normal",
                ]),
            4,
        );
        let status = match result {
            Ok(s) => s,
            Err(e) => {
                rows.push(hint(format!("Could not inspect {}", repo.display()), e));
                continue;
            }
        };
        let (branch, changes) = status_text(&status);
        if changes.is_empty() {
            continue;
        }
        dirty += 1;
        if core::score(filter, &repo.to_string_lossy()).is_none() {
            continue;
        }
        let text = format!("{}\n{branch}\n\n{}", repo.display(), changes.join("\n"));
        rows.push(entry(
            repo.strip_prefix(root)
                .unwrap_or(&repo)
                .display()
                .to_string(),
            format!("{} changes · {branch}", changes.len()),
            "Dirty repo",
            Op::Preview {
                title: "Git status".into(),
                text,
                open: Some(gtk::gio::File::for_path(&repo).uri().into()),
            },
        ));
    }
    rows.insert(
        0,
        hint(
            format!("{dirty} dirty repositories · {scanned} checked"),
            format!(
                "{} · tracked and untracked changes · Ctrl+R refreshes",
                root.display()
            ),
        ),
    );
    if limited {
        rows.push(hint(
            "Scan limit reached",
            "Some directories were not checked · scans skip build output and symbolic links",
        ));
    }
    if rows.len() == 1 {
        rows.push(hint(
            if dirty == 0 {
                "All checked repositories are clean"
            } else {
                "No dirty repositories match"
            },
            "Nested repositories and Git worktrees are included",
        ));
    }
    Ok(rows)
}
fn status_text(text: &str) -> (String, Vec<String>) {
    let mut records = text.split('\0');
    let branch = records
        .next()
        .unwrap_or("")
        .trim_start_matches("## ")
        .to_string();
    let mut changes = Vec::new();
    while let Some(record) = records.next() {
        if record.len() < 3 {
            continue;
        }
        let mut row = record
            .chars()
            .flat_map(char::escape_default)
            .collect::<String>();
        if record.as_bytes()[..2].iter().any(|b| b"RC".contains(b))
            && let Some(old) = records.next()
        {
            row.push_str(&format!(
                " ← {}",
                old.chars()
                    .flat_map(char::escape_default)
                    .collect::<String>()
            ));
        }
        changes.push(row);
    }
    (branch, changes)
}
fn valid_engine(engine: &str) -> bool {
    ["docker", "podman"].contains(&engine)
}
fn valid_id(id: &str) -> bool {
    (12..=64).contains(&id.len()) && id.bytes().all(|b| b.is_ascii_hexdigit())
}
fn containers(engine: &str, mode: &str, input: &str) -> Result<Vec<Entry>, String> {
    let (filter, cmd) = input.split_once(" -- ").unwrap_or((input, "sh"));
    let command = devtools::tokens(cmd)?;
    if command.is_empty() {
        return Err("Add a command after --".into());
    }
    let body = boosters::run(
        Command::new(engine).args(["ps", "-a", "--no-trunc", "--format", "{{json .}}"]),
        8,
    )?;
    let mut rows = Vec::new();
    for line in body.lines().filter(|s| !s.trim().is_empty()) {
        let v: Value = serde_json::from_str(line).map_err(|_| "Invalid container list")?;
        let id = v["ID"].as_str().or_else(|| v["Id"].as_str()).unwrap_or("");
        if !valid_id(id) {
            continue;
        }
        let name = v["Names"].as_str().map(str::to_string).unwrap_or_else(|| {
            v["Names"]
                .as_array()
                .into_iter()
                .flatten()
                .filter_map(Value::as_str)
                .collect::<Vec<_>>()
                .join(", ")
        });
        if core::score(filter, &format!("{name} {id} {}", v["Image"])).is_none() {
            continue;
        }
        let running =
            v["State"] == "running" || v["Status"].as_str().is_some_and(|s| s.starts_with("Up"));
        if mode == "exec" && !running {
            continue;
        }
        rows.push(action(
            format!(
                "{} {name}",
                if mode == "logs" {
                    "Tail logs ·"
                } else {
                    "Open shell ·"
                }
            ),
            format!(
                "{engine} · {} · {}",
                &id[..12],
                if mode == "logs" {
                    "last 200 lines + live updates"
                } else {
                    cmd
                }
            ),
            "Container",
            if mode == "logs" {
                Operation::Logs {
                    engine: engine.into(),
                    id: id.into(),
                    name,
                }
            } else {
                Operation::Exec {
                    engine: engine.into(),
                    id: id.into(),
                    command: command.clone(),
                }
            },
        ));
    }
    if rows.is_empty() {
        rows.push(hint(
            "No matching containers",
            if mode == "logs" {
                "Try docker logs nginx or logs nginx"
            } else {
                "Exec requires a running container · docker exec nginx -- /bin/bash"
            },
        ));
    }
    Ok(rows)
}
pub fn exec_container(engine: &str, id: &str, command: &[String]) -> Result<(), String> {
    if !valid_engine(engine) || !valid_id(id) || command.is_empty() {
        return Err("Invalid container command".into());
    }
    let terminals = [
        ("konsole", vec!["--hold", "-e"]),
        ("gnome-terminal", vec!["--"]),
        ("xterm", vec!["-e"]),
    ];
    let (program, args) = terminals
        .into_iter()
        .find(|(p, _)| crate::localtools::available(p))
        .ok_or("Install Konsole, GNOME Terminal or xterm for interactive container exec")?;
    let mut child = Command::new(program)
        .args(args)
        .arg(engine)
        .args(["exec", "-it", id])
        .args(command)
        .stdin(Stdio::null())
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .spawn()
        .map_err(|e| e.to_string())?;
    std::thread::spawn(move || {
        let _ = child.wait();
    });
    Ok(())
}
pub struct LogTail {
    pub receiver: mpsc::Receiver<String>,
    pub cancel: Arc<AtomicBool>,
}
pub fn tail(engine: &str, id: &str) -> Result<LogTail, String> {
    if !valid_engine(engine) || !valid_id(id) {
        return Err("Invalid container identity".into());
    }
    let mut child = Command::new(engine)
        .args(["logs", "--tail", "200", "--follow", "--timestamps", id])
        .stdin(Stdio::null())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .map_err(|e| e.to_string())?;
    let (tx, receiver) = mpsc::sync_channel(128);
    let cancel = Arc::new(AtomicBool::new(false));
    fn drain(pipe: impl Read + Send + 'static, tx: mpsc::SyncSender<String>) {
        std::thread::spawn(move || {
            let mut reader = BufReader::new(pipe);
            loop {
                let mut bytes = Vec::new();
                match reader.by_ref().take(8192).read_until(b'\n', &mut bytes) {
                    Ok(0) | Err(_) => break,
                    Ok(_) => {
                        if tx
                            .send(String::from_utf8_lossy(&bytes).replace('\0', "�"))
                            .is_err()
                        {
                            break;
                        }
                    }
                }
            }
        });
    }
    drain(child.stdout.take().unwrap(), tx.clone());
    drain(child.stderr.take().unwrap(), tx.clone());
    let stopped = cancel.clone();
    std::thread::spawn(move || {
        loop {
            if stopped.load(Ordering::Relaxed) {
                let _ = child.kill();
                let _ = child.wait();
                break;
            }
            match child.try_wait() {
                Ok(Some(status)) => {
                    let _ = tx.try_send(format!("\n[Log stream ended: {status}]\n"));
                    break;
                }
                Err(_) => {
                    let _ = child.kill();
                    let _ = child.wait();
                    break;
                }
                _ => std::thread::sleep(Duration::from_millis(50)),
            }
        }
    });
    Ok(LogTail { receiver, cancel })
}
impl Drop for LogTail {
    fn drop(&mut self) {
        self.cancel.store(true, Ordering::Relaxed);
    }
}
fn path_in(text: &str, context: &Path) -> PathBuf {
    if let Some(rest) = text.strip_prefix("~/") {
        core::home().join(rest)
    } else {
        let p = PathBuf::from(text);
        if p.is_absolute() { p } else { context.join(p) }
    }
}
fn env_paths(input: &str, context: &Path) -> Result<(PathBuf, PathBuf), String> {
    let words = devtools::tokens(input)?;
    if words.len() > 2 {
        return Err("Use dotenv diff [first-file second-file]".into());
    }
    Ok((
        path_in(words.first().map(String::as_str).unwrap_or(".env"), context),
        path_in(
            words.get(1).map(String::as_str).unwrap_or(".env.example"),
            context,
        ),
    ))
}
fn env_values(path: &Path) -> Result<std::collections::BTreeMap<String, String>, String> {
    devtools::parse_dotenv(&devtools::bounded_text(path)?)
}
fn env_diff(input: &str, context: &Path) -> Result<Vec<Entry>, String> {
    let (left, right) = env_paths(input, context)?;
    let a = env_values(&left)?;
    let b = env_values(&right)?;
    let keys: BTreeSet<_> = a.keys().chain(b.keys()).collect();
    let mut rows = Vec::new();
    for key in keys {
        let label = match (a.get(key), b.get(key)) {
            (None, Some(_)) => "Missing from first file",
            (Some(_), None) => "Only in first file",
            (Some(x), Some(y)) if x != y => "Different values",
            _ => continue,
        };
        rows.push(action(
            key,
            label,
            "Env diff",
            Operation::EnvDiff {
                left: left.clone(),
                right: right.clone(),
                key: key.clone(),
            },
        ));
    }
    rows.insert(
        0,
        hint(
            format!("{} differing keys", rows.len()),
            format!(
                "{} ↔ {} · Enter a key to compare values",
                left.display(),
                right.display()
            ),
        ),
    );
    Ok(rows)
}
pub fn env_compare(left: &Path, right: &Path, key: &str) -> Result<String, String> {
    let a = env_values(left)?;
    let b = env_values(right)?;
    Ok(format!(
        "{}\n{key}={}\n\n{}\n{key}={}",
        left.display(),
        a.get(key).map(String::as_str).unwrap_or("<missing>"),
        right.display(),
        b.get(key).map(String::as_str).unwrap_or("<missing>")
    ))
}
#[derive(Clone)]
pub struct Request {
    pub method: String,
    pub url: String,
    pub headers: String,
    pub body: String,
}
pub fn request(req: &Request) -> Result<String, String> {
    if !["GET", "POST", "PUT", "PATCH", "DELETE", "HEAD", "OPTIONS"].contains(&req.method.as_str())
    {
        return Err("Unsupported HTTP method".into());
    }
    let uri = gtk::glib::Uri::parse(req.url.trim(), gtk::glib::UriFlags::NONE)
        .map_err(|e| e.to_string())?;
    if !["http", "https"].contains(&uri.scheme().as_str())
        || uri.host().is_none()
        || uri.userinfo().is_some()
    {
        return Err("Use an HTTP(S) URL; put authentication in the headers field".into());
    }
    if req.body.len() > 1_048_576 || req.headers.len() > 65536 {
        return Err("Request body is limited to 1 MiB and headers to 64 KiB".into());
    }
    let work = crate::localtools::Work::new()?;
    let headers = work.0.join("headers");
    let body = work.0.join("body");
    let mut cmd = Command::new("curl");
    cmd.args([
        "--disable",
        "--silent",
        "--show-error",
        "--connect-timeout",
        "5",
        "--max-time",
        "20",
        "--max-filesize",
        "1048576",
        "--proto",
        "=http,https",
        "--dump-header",
    ])
    .arg(&headers)
    .arg("--output")
    .arg(&body)
    .args([
        "--write-out",
        "%{http_code} · %{time_total}s",
        "--url",
        req.url.trim(),
    ]);
    if req.method == "HEAD" {
        cmd.arg("--head");
    } else {
        cmd.args(["--request", &req.method]);
    }
    for line in req.headers.lines().map(str::trim).filter(|s| !s.is_empty()) {
        let (name, _) = line
            .split_once(':')
            .ok_or("Use one Header: value per line")?;
        if name.is_empty()
            || !name
                .bytes()
                .all(|b| b.is_ascii_alphanumeric() || b"!#$%&'*+-.^_`|~".contains(&b))
        {
            return Err("Invalid HTTP header name".into());
        }
        cmd.args(["--header", line]);
    }
    let result = if req.body.is_empty() {
        boosters::run(&mut cmd, 22)
    } else {
        cmd.args(["--data-binary", "@-"]);
        boosters::run_input(&mut cmd, 22, Some(req.body.as_bytes()))
    };
    let status = result?;
    let head = devtools::bounded_text(&headers)?;
    let bytes = if req.method == "HEAD" {
        Vec::new()
    } else {
        fs::read(&body).unwrap_or_default()
    };
    let text = String::from_utf8_lossy(&bytes).replace('\0', "�");
    let text = serde_json::from_str::<Value>(&text)
        .ok()
        .and_then(|v| serde_json::to_string_pretty(&v).ok())
        .unwrap_or(text);
    Ok(format!(
        "{} {}\n{status}\n\n{head}\n{text}",
        req.method,
        req.url.trim()
    ))
}

#[cfg(test)]
mod tests {
    use super::*;
    fn git(path: &Path, args: &[&str]) -> String {
        boosters::run(Command::new("git").arg("-C").arg(path).args(args), 5).unwrap()
    }
    pub(crate) fn init(path: &Path) {
        fs::create_dir_all(path).unwrap();
        git(path, &["init", "-b", "main"]);
        git(path, &["config", "user.email", "fixture@example.invalid"]);
        git(path, &["config", "user.name", "Spotlight Fixture"]);
        fs::write(path.join("file.txt"), "initial\n").unwrap();
        git(path, &["add", "."]);
        git(path, &["commit", "-m", "Initial fixture"]);
    }
    #[test]
    fn dashboard_and_dotenv_diff_are_read_only() {
        let work = crate::localtools::Work::new().unwrap();
        let root = &work.0;
        let clean = root.join("clean");
        let dirty = root.join("nested/dirty");
        init(&clean);
        init(&dirty);
        fs::write(dirty.join("file.txt"), "changed\n").unwrap();
        fs::write(dirty.join("untracked file"), "new\n").unwrap();
        let index = fs::read(dirty.join(".git/index")).unwrap();
        let rows = git_dashboard(root, "").unwrap();
        assert!(
            rows[0]
                .title
                .starts_with("1 dirty repositories · 2 checked")
        );
        assert_eq!(rows[1].title, "nested/dirty");
        assert!(rows[1].detail.contains("2 changes"));
        assert_eq!(fs::read(dirty.join(".git/index")).unwrap(), index);
        assert!(!dirty.join(".git/index.lock").exists());
        fs::write(
            root.join(".env"),
            "SAME=1\nCHANGED=actual-private-value\nONLY_LOCAL=x\n",
        )
        .unwrap();
        fs::write(
            root.join(".env.example"),
            "SAME=1\nCHANGED=placeholder\nMISSING_LOCAL=x\n",
        )
        .unwrap();
        let rows = env_diff("", root).unwrap();
        assert_eq!(rows.len(), 4);
        assert!(!format!("{rows:?}").contains("actual-private-value"));
        assert!(
            env_compare(&root.join(".env"), &root.join(".env.example"), "CHANGED")
                .unwrap()
                .contains("actual-private-value")
        );
        let (branch, rows) = status_text("## main\0R  renamed\0old name\0?? new\0");
        assert_eq!(branch, "main");
        assert_eq!(rows.len(), 2);
        assert!(rows[0].contains("old name"));
    }
    #[test]
    fn http_receives_error_responses_and_sends_literal_body() {
        use std::io::Write;
        use std::net::TcpListener;
        let listener = TcpListener::bind("127.0.0.1:0").unwrap();
        let address = listener.local_addr().unwrap();
        let server = std::thread::spawn(move || {
            let (mut stream, _) = listener.accept().unwrap();
            let mut reader = BufReader::new(stream.try_clone().unwrap());
            let mut head = String::new();
            let mut len = 0;
            loop {
                let mut line = String::new();
                reader.read_line(&mut line).unwrap();
                if line == "\r\n" {
                    break;
                }
                if line.to_ascii_lowercase().starts_with("content-length:") {
                    len = line
                        .split(':')
                        .nth(1)
                        .unwrap()
                        .trim()
                        .parse::<usize>()
                        .unwrap();
                }
                head.push_str(&line);
            }
            let mut body = vec![0; len];
            reader.read_exact(&mut body).unwrap();
            assert!(head.starts_with("POST /user HTTP/1.1"));
            assert!(head.contains("Authorization: Bearer fixture-token"));
            assert_eq!(
                String::from_utf8(body).unwrap(),
                "{\"text\":\"literal $(nope) & café\"}"
            );
            let body = r#"{"error":"fixture unauthorized"}"#;
            write!(stream,"HTTP/1.1 401 Unauthorized\r\nContent-Type: application/json\r\nContent-Length: {}\r\nConnection: close\r\n\r\n{body}",body.len()).unwrap();
        });
        let result = request(&Request {
            method: "POST".into(),
            url: format!("http://{address}/user"),
            headers: "Authorization: Bearer fixture-token\nContent-Type: application/json".into(),
            body: "{\"text\":\"literal $(nope) & café\"}".into(),
        })
        .unwrap();
        assert!(result.contains("401 Unauthorized"));
        assert!(result.contains("fixture unauthorized"));
        assert!(!result.contains("fixture-token"));
        server.join().unwrap();
        assert!(
            request(&Request {
                method: "GET".into(),
                url: "file:///etc/passwd".into(),
                headers: String::new(),
                body: String::new()
            })
            .is_err()
        );
    }
    #[test]
    fn parses_scoped_commands_without_running_them() {
        for text in [
            "git status",
            "git status spotlight",
            "docker logs nginx",
            "logs nginx",
            "docker exec nginx -- /bin/bash",
            "get https://api.github.com/user",
            "http",
            "dotenv diff",
            "dotenv diff \"/tmp/a b/.env\" .env.example",
        ] {
            assert!(Query::parse(text).is_some(), "{text}");
        }
        assert!(Query::parse("git clone https://example.test/repo").is_none());
        assert!(Query::parse("dotenv API").is_none());
        assert!(!valid_id("--all"));
        assert!(!valid_engine("sh"));
    }
    #[test]
    #[ignore = "requires private CLI fixtures; run tests/devkit_smoke.py"]
    fn fixture_backends() {
        let root =
            PathBuf::from(std::env::var_os("SPOTLIGHT_KIT_ROOT").expect("Use devkit harness"));
        assert!(
            root.file_name()
                .unwrap()
                .to_string_lossy()
                .starts_with("spotlight-devkit-")
        );
        let rows = containers("docker", "logs", "nginx").unwrap();
        assert_eq!(rows.len(), 1);
        let Some(Op::Kit(Operation::Logs { engine, id, .. })) = rows[0].operation.clone() else {
            panic!()
        };
        let tail = tail(&engine, &id).unwrap();
        let mut text = String::new();
        for _ in 0..2 {
            text.push_str(&tail.receiver.recv_timeout(Duration::from_secs(2)).unwrap());
        }
        assert!(text.contains("nginx fixture ready"));
        assert!(text.contains("stderr fixture"));
        let pid: u32 = fs::read_to_string(root.join("tail-pid"))
            .unwrap()
            .parse()
            .unwrap();
        drop(tail);
        let started = Instant::now();
        while Path::new(&format!("/proc/{pid}")).exists() {
            assert!(
                started.elapsed() < Duration::from_secs(3),
                "Tail child was not reaped"
            );
            std::thread::sleep(Duration::from_millis(30));
        }
        let rows = containers(
            "docker",
            "exec",
            "nginx -- /bin/sh -lc 'printf %s literal;no-shell'",
        )
        .unwrap();
        let Some(Op::Kit(Operation::Exec {
            engine,
            id,
            command,
        })) = rows[0].operation.clone()
        else {
            panic!()
        };
        exec_container(&engine, &id, &command).unwrap();
        let started = Instant::now();
        while !root.join("terminal-args.json").exists() {
            assert!(started.elapsed() < Duration::from_secs(3));
            std::thread::sleep(Duration::from_millis(20));
        }
        let args: Vec<String> =
            serde_json::from_str(&fs::read_to_string(root.join("terminal-args.json")).unwrap())
                .unwrap();
        assert_eq!(&args[2..6], &["docker", "exec", "-it", &id]);
        assert_eq!(args.last().unwrap(), "printf %s literal;no-shell");
        assert!(
            containers("docker", "exec", "postgres").unwrap()[0]
                .operation
                .is_none()
        );
        let repo = root.join("private-repo");
        init(&repo);
        git(
            &repo,
            &[
                "remote",
                "add",
                "origin",
                "https://github.com/example/private.git",
            ],
        );
        let store = core::Store {
            notes: vec![core::TextItem {
                name: "fixture".into(),
                value: "private-note-fixture".into(),
                trigger: String::new(),
            }],
            ..Default::default()
        };
        crate::dotfiles::export(&repo, true, &store).unwrap();
        assert_eq!(
            fs::read_to_string(root.join("push-count"))
                .unwrap()
                .lines()
                .count(),
            1
        );
        fs::write(root.join("public-origin"), "").unwrap();
        assert!(crate::dotfiles::export(&repo, true, &store).is_err());
        assert_eq!(
            fs::read_to_string(root.join("push-count"))
                .unwrap()
                .lines()
                .count(),
            1
        );
    }
}

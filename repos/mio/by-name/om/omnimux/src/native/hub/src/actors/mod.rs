use crate::signals::{
    GetSshHosts, ResizeSession, SshHostsResult, StartSession, StopSession, TerminalExit,
    TerminalOutput, WriteSession,
};
use portable_pty::{ChildKiller, CommandBuilder, MasterPty, NativePtySystem, PtySize, PtySystem};
use rinf::{DartSignal, RustSignal};
use std::{
    collections::HashMap,
    io::{Read, Write},
    sync::{mpsc, Arc, Mutex},
};
use tokio::task::spawn_blocking;

struct PtySession {
    master: Box<dyn MasterPty + Send>,
    /// Dropping this closes the dedicated writer thread (recv returns Err).
    write_tx: mpsc::Sender<Vec<u8>>,
    killer: Mutex<Box<dyn ChildKiller + Send + Sync>>,
}

fn send_spawn_failure(session_id: i64, message: String) {
    TerminalOutput {
        session_id,
        data: format!("{message}\r\n").into_bytes(),
    }
    .send_signal_to_dart();

    TerminalExit {
        session_id,
        status: Some(-1),
    }
    .send_signal_to_dart();
}

/// Strip an OpenSSH inline comment (`# ...`) when `#` starts a token.
fn strip_ssh_comment(line: &str) -> &str {
    let mut in_token_start = true;
    for (i, ch) in line.char_indices() {
        if ch == '#' && in_token_start {
            return line[..i].trim_end();
        }
        in_token_start = ch.is_whitespace();
    }
    line
}

fn is_usable_host_token(host: &str) -> bool {
    // Patterns / negation / option-like tokens are not connectable host aliases.
    !host.is_empty()
        && !host.contains('*')
        && !host.contains('?')
        && !host.starts_with('!')
        && !host.starts_with('-')
}

pub async fn create_actors() {
    let sessions: Arc<Mutex<HashMap<i64, PtySession>>> = Arc::new(Mutex::new(HashMap::new()));

    // Handle StartSession
    let sessions_start = sessions.clone();
    tokio::spawn(async move {
        let receiver = StartSession::get_dart_signal_receiver();
        while let Some(signal) = receiver.recv().await {
            let session_id = signal.message.session_id;
            let host = signal.message.host.clone();
            let cols = signal.message.cols;
            let rows = signal.message.rows;
            let enable_tmux_mouse = signal.message.enable_tmux_mouse;
            let sessions = sessions_start.clone();

            spawn_blocking(move || {
                let pty_system = NativePtySystem::default();
                let pair = match pty_system.openpty(PtySize {
                    rows,
                    cols,
                    pixel_width: 0,
                    pixel_height: 0,
                }) {
                    Ok(p) => p,
                    Err(e) => {
                        send_spawn_failure(session_id, format!("Failed to open PTY: {e}"));
                        return;
                    }
                };

                let tmux_cmd = if enable_tmux_mouse {
                    "tmux -u has-session 2>/dev/null && exec tmux -u a \\; set -g mouse on || exec tmux -u new \\; set -g mouse on"
                } else {
                    "tmux -u has-session 2>/dev/null && exec tmux -u a || exec tmux -u new"
                };

                let mut command = if host == "localhost" || host == "127.0.0.1" {
                    let default_shell = if cfg!(target_os = "macos") { "zsh" } else { "sh" };
                    let shell = std::env::var("SHELL").unwrap_or_else(|_| default_shell.to_string());
                    let mut command = CommandBuilder::new(shell);
                    command.arg("-lc");
                    command.arg(tmux_cmd);
                    command
                } else {
                    let mut command = CommandBuilder::new("ssh");
                    command.arg("-t");
                    // OpenSSH getopt: `--` ends option parsing so Host tokens
                    // starting with `-` cannot become ssh flags.
                    command.arg("--");
                    command.arg(host);
                    command.arg(tmux_cmd);
                    command
                };
                // Merges with inherited base env (portable-pty CommandBuilder).
                command.env("TERM", "xterm-256color");
                let nix_home_bin = std::env::var("HOME")
                    .map(|h| format!("{}/.nix-profile/bin", h))
                    .unwrap_or_default();
                let nix_prefix = format!(
                    "/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:{}",
                    nix_home_bin
                );
                if let Ok(path) = std::env::var("PATH") {
                    command.env("PATH", format!("{}:{}", nix_prefix, path));
                } else {
                    command.env("PATH", format!("{}:/usr/bin:/bin:/usr/sbin:/sbin", nix_prefix));
                }

                let child = match pair.slave.spawn_command(command) {
                    Ok(c) => c,
                    Err(e) => {
                        send_spawn_failure(session_id, format!("Failed to spawn process: {e}"));
                        return;
                    }
                };
                drop(pair.slave);

                let killer = child.clone_killer();
                let mut reader = match pair.master.try_clone_reader() {
                    Ok(r) => r,
                    Err(e) => {
                        let _ = child.clone_killer().kill();
                        send_spawn_failure(session_id, format!("Failed to clone PTY reader: {e}"));
                        return;
                    }
                };
                let writer = match pair.master.take_writer() {
                    Ok(w) => w,
                    Err(e) => {
                        let _ = killer.clone_killer().kill();
                        send_spawn_failure(session_id, format!("Failed to take PTY writer: {e}"));
                        return;
                    }
                };

                // One dedicated writer thread per session preserves keystroke order
                // (tokio spawn_blocking tasks are not FIFO across the pool).
                let (write_tx, write_rx) = mpsc::channel::<Vec<u8>>();
                std::thread::spawn(move || {
                    let mut writer = writer;
                    while let Ok(data) = write_rx.recv() {
                        let _ = writer.write_all(&data);
                        let _ = writer.flush();
                    }
                });

                if let Ok(mut sessions_lock) = sessions.lock() {
                    if let Some(old) = sessions_lock.insert(
                        session_id,
                        PtySession {
                            master: pair.master,
                            write_tx,
                            killer: Mutex::new(killer),
                        },
                    ) {
                        if let Ok(mut old_killer) = old.killer.lock() {
                            // portable-pty Unix ChildKiller uses SIGHUP.
                            let _ = old_killer.kill();
                        }
                    }
                } else {
                    drop(write_tx);
                    let _ = killer.clone_killer().kill();
                    send_spawn_failure(session_id, "Failed to register session".to_string());
                    return;
                }

                std::thread::spawn(move || {
                    let mut buffer = [0; 8192];
                    loop {
                        match reader.read(&mut buffer) {
                            Ok(0) => break,
                            Ok(read) => {
                                let data = buffer[..read].to_vec();
                                TerminalOutput { session_id, data }.send_signal_to_dart();
                            }
                            Err(error) if error.kind() == std::io::ErrorKind::Interrupted => {}
                            Err(_) => break,
                        }
                    }
                });

                let mut child = child;
                let sessions_wait = sessions.clone();
                std::thread::spawn(move || {
                    let status = child.wait().ok().map(|s| s.exit_code() as i32);
                    if let Ok(mut sessions_lock) = sessions_wait.lock() {
                        sessions_lock.remove(&session_id);
                    }
                    TerminalExit { session_id, status }.send_signal_to_dart();
                });
            });
        }
    });

    // Handle WriteSession
    let sessions_write = sessions.clone();
    tokio::spawn(async move {
        let receiver = WriteSession::get_dart_signal_receiver();
        while let Some(signal) = receiver.recv().await {
            let write_tx = {
                let Ok(sessions_lock) = sessions_write.lock() else {
                    continue;
                };
                sessions_lock
                    .get(&signal.message.session_id)
                    .map(|session| session.write_tx.clone())
            };
            let Some(write_tx) = write_tx else {
                continue;
            };
            let _ = write_tx.send(signal.message.data);
        }
    });

    // Handle ResizeSession
    let sessions_resize = sessions.clone();
    tokio::spawn(async move {
        let receiver = ResizeSession::get_dart_signal_receiver();
        while let Some(signal) = receiver.recv().await {
            let Ok(sessions_lock) = sessions_resize.lock() else {
                continue;
            };
            if let Some(session) = sessions_lock.get(&signal.message.session_id) {
                let _ = session.master.resize(PtySize {
                    rows: signal.message.rows,
                    cols: signal.message.cols,
                    pixel_width: 0,
                    pixel_height: 0,
                });
            }
        }
    });

    // Handle StopSession
    let sessions_stop = sessions.clone();
    tokio::spawn(async move {
        let receiver = StopSession::get_dart_signal_receiver();
        while let Some(signal) = receiver.recv().await {
            let removed = {
                let Ok(mut sessions_lock) = sessions_stop.lock() else {
                    continue;
                };
                sessions_lock.remove(&signal.message.session_id)
            };
            if let Some(session) = removed {
                if let Ok(mut killer) = session.killer.lock() {
                    let _ = killer.kill();
                }
                // write_tx drop ends the writer thread; master drop hangs up the PTY.
            }
        }
    });

    // Handle GetSshHosts
    tokio::spawn(async move {
        let receiver = GetSshHosts::get_dart_signal_receiver();
        while let Some(_signal) = receiver.recv().await {
            spawn_blocking(|| {
                let mut hosts = vec!["localhost".to_string()];
                let mut visited = std::collections::HashSet::new();
                if let Ok(home) = std::env::var("HOME") {
                    let config_path = std::path::PathBuf::from(home).join(".ssh").join("config");
                    parse_ssh_config(&config_path, &mut hosts, &mut visited);
                }
                SshHostsResult { hosts }.send_signal_to_dart();
            });
        }
    });
}

fn parse_ssh_config(
    config_path: &std::path::Path,
    hosts: &mut Vec<String>,
    visited: &mut std::collections::HashSet<std::path::PathBuf>,
) {
    if visited.contains(config_path) {
        return;
    }
    visited.insert(config_path.to_path_buf());

    let Ok(content) = std::fs::read_to_string(config_path) else {
        return;
    };

    for raw_line in content.lines() {
        let line = strip_ssh_comment(raw_line.trim());
        if line.is_empty() {
            continue;
        }

        let lower = line.to_ascii_lowercase();
        if lower.starts_with("host ") || lower.starts_with("host\t") {
            // Keyword is ASCII "host"; keep original casing for host tokens.
            let rest = line[4..].trim_start();
            for host in rest.split_whitespace() {
                if is_usable_host_token(host) && !hosts.iter().any(|h| h == host) {
                    hosts.push(host.to_string());
                }
            }
        } else if lower.starts_with("include ") || lower.starts_with("include\t") {
            // ssh_config(5): Include may list multiple pathnames (globs, ~, relative).
            let rest = line[7..].trim_start();
            for include_path in rest.split_whitespace() {
                let expanded_path = if include_path.starts_with("~/") {
                    if let Ok(home) = std::env::var("HOME") {
                        std::path::PathBuf::from(home).join(&include_path[2..])
                    } else {
                        std::path::PathBuf::from(include_path)
                    }
                } else if include_path.starts_with('/') {
                    std::path::PathBuf::from(include_path)
                } else if let Ok(home) = std::env::var("HOME") {
                    std::path::PathBuf::from(home)
                        .join(".ssh")
                        .join(include_path)
                } else {
                    std::path::PathBuf::from(include_path)
                };

                if let Some(expanded_str) = expanded_path.to_str() {
                    if let Ok(paths) = glob::glob(expanded_str) {
                        for entry in paths.flatten() {
                            parse_ssh_config(&entry, hosts, visited);
                        }
                    }
                }
            }
        }
    }
}

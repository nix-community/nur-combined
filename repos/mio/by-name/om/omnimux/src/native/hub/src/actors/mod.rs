use crate::signals::{
    GetSshHosts, ResizeSession, SshHostsResult, StartSession, StopSession, TerminalExit,
    TerminalOutput, WriteSession,
};
use portable_pty::{ChildKiller, CommandBuilder, MasterPty, NativePtySystem, PtySize, PtySystem};
use rinf::{DartSignal, RustSignal};
use std::{
    collections::HashMap,
    io::{Read, Write},
    sync::{Arc, Mutex},
};
use tokio::task::spawn_blocking;

struct PtySession {
    master: Box<dyn MasterPty + Send>,
    writer: Arc<Mutex<Box<dyn Write + Send>>>,
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

pub async fn create_actors() {
    let sessions: Arc<Mutex<HashMap<i64, PtySession>>> = Arc::new(Mutex::new(HashMap::new()));

    // Handle StartSession
    let sessions_start = sessions.clone();
    tokio::spawn(async move {
        let mut receiver = StartSession::get_dart_signal_receiver();
        while let Some(signal) = receiver.recv().await {
            let session_id = signal.message.session_id;
            let host = signal.message.host.clone();
            let cols = signal.message.cols;
            let rows = signal.message.rows;
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

                let mut command = if host == "localhost" || host == "127.0.0.1" {
                    let mut command = CommandBuilder::new("sh");
                    command.arg("-lc");
                    command.arg("tmux a || tmux new");
                    command
                } else {
                    let mut command = CommandBuilder::new("ssh");
                    command.arg("-t");
                    // Prevent Host tokens like `-J` from becoming ssh options.
                    command.arg("--");
                    command.arg(host);
                    command.arg("tmux a || tmux new");
                    command
                };
                command.env("TERM", "xterm-256color");

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

                if let Ok(mut sessions_lock) = sessions.lock() {
                    if let Some(old) = sessions_lock.insert(
                        session_id,
                        PtySession {
                            master: pair.master,
                            writer: Arc::new(Mutex::new(writer)),
                            killer: Mutex::new(killer),
                        },
                    ) {
                        if let Ok(mut old_killer) = old.killer.lock() {
                            let _ = old_killer.kill();
                        }
                    }
                } else {
                    let _ = killer.clone_killer().kill();
                    send_spawn_failure(session_id, "Failed to register session".to_string());
                    return;
                }

                // Output reader thread
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

                // Waiter thread
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
        let mut receiver = WriteSession::get_dart_signal_receiver();
        while let Some(signal) = receiver.recv().await {
            let writer = {
                let Ok(sessions_lock) = sessions_write.lock() else {
                    continue;
                };
                sessions_lock
                    .get(&signal.message.session_id)
                    .map(|session| session.writer.clone())
            };
            let Some(writer) = writer else {
                continue;
            };
            let data = signal.message.data;
            spawn_blocking(move || {
                if let Ok(mut w) = writer.lock() {
                    let _ = w.write_all(&data);
                    let _ = w.flush();
                }
            });
        }
    });

    // Handle ResizeSession
    let sessions_resize = sessions.clone();
    tokio::spawn(async move {
        let mut receiver = ResizeSession::get_dart_signal_receiver();
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
        let mut receiver = StopSession::get_dart_signal_receiver();
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
            }
        }
    });

    // Handle GetSshHosts
    tokio::spawn(async move {
        let mut receiver = GetSshHosts::get_dart_signal_receiver();
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

    if let Ok(content) = std::fs::read_to_string(config_path) {
        for line in content.lines() {
            let line = line.trim();
            if line.to_lowercase().starts_with("host ") {
                let host_part = line[5..].trim();
                for host in host_part.split_whitespace() {
                    // Skip patterns and tokens that would look like ssh options.
                    if host.contains('*')
                        || host.contains('?')
                        || host.starts_with('-')
                        || hosts.contains(&host.to_string())
                    {
                        continue;
                    }
                    hosts.push(host.to_string());
                }
            } else if line.to_lowercase().starts_with("include ") {
                let include_path = line[8..].trim();

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

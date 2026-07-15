use crate::signals::*;
use portable_pty::{CommandBuilder, MasterPty, NativePtySystem, PtySize, PtySystem};
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
                        TerminalOutput {
                            session_id,
                            data: format!("Failed to open PTY: {}\r\n", e).into_bytes(),
                        }
                        .send_signal_to_dart();
                        
                        TerminalExit {
                            session_id,
                            status: Some(-1),
                        }
                        .send_signal_to_dart();
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
                    command.arg(host);
                    command.arg("tmux a || tmux new");
                    command
                };
                command.env("TERM", "xterm-256color");

                let mut child = match pair.slave.spawn_command(command) {
                    Ok(c) => c,
                    Err(e) => {
                        TerminalOutput {
                            session_id,
                            data: format!("Failed to spawn SSH process: {}\r\n", e).into_bytes(),
                        }
                        .send_signal_to_dart();
                        
                        TerminalExit {
                            session_id,
                            status: Some(-1),
                        }
                        .send_signal_to_dart();
                        return;
                    }
                };
                drop(pair.slave);

                let mut reader = pair.master.try_clone_reader().unwrap();
                let writer = pair.master.take_writer().unwrap();

                sessions.lock().unwrap().insert(
                    session_id,
                    PtySession {
                        master: pair.master,
                        writer: Arc::new(Mutex::new(writer)),
                    },
                );

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
                std::thread::spawn(move || {
                    let status = child.wait().ok().map(|s| s.exit_code() as i32);
                    if let Ok(mut sessions_lock) = sessions.lock() {
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
            if let Some(session) = sessions_write.lock().unwrap().get(&signal.message.session_id) {
                let writer = session.writer.clone();
                let data = signal.message.data;
                spawn_blocking(move || {
                    if let Ok(mut w) = writer.lock() {
                        let _ = w.write_all(&data);
                        let _ = w.flush();
                    }
                });
            }
        }
    });

    // Handle ResizeSession
    let sessions_resize = sessions.clone();
    tokio::spawn(async move {
        let mut receiver = ResizeSession::get_dart_signal_receiver();
        while let Some(signal) = receiver.recv().await {
            if let Some(session) = sessions_resize.lock().unwrap().get(&signal.message.session_id) {
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
            sessions_stop.lock().unwrap().remove(&signal.message.session_id);
        }
    });

    // Handle GetSshHosts
    tokio::spawn(async move {
        let mut receiver = GetSshHosts::get_dart_signal_receiver();
        while let Some(_signal) = receiver.recv().await {
            spawn_blocking(move || {
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
                    if !host.contains('*') && !host.contains('?') {
                        hosts.push(host.to_string());
                    }
                }
            } else if line.to_lowercase().starts_with("include ") {
                let include_path = line[8..].trim();
                
                // Expand path
                let expanded_path = if include_path.starts_with("~/") {
                    if let Ok(home) = std::env::var("HOME") {
                        std::path::PathBuf::from(home).join(&include_path[2..])
                    } else {
                        std::path::PathBuf::from(include_path)
                    }
                } else if include_path.starts_with('/') {
                    std::path::PathBuf::from(include_path)
                } else {
                    if let Ok(home) = std::env::var("HOME") {
                        std::path::PathBuf::from(home).join(".ssh").join(include_path)
                    } else {
                        std::path::PathBuf::from(include_path)
                    }
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

#![cfg_attr(
    all(not(debug_assertions), target_os = "windows"),
    windows_subsystem = "windows"
)]

use portable_pty::{CommandBuilder, MasterPty, NativePtySystem, PtySize, PtySystem};
use serde::Serialize;
use std::{
    collections::HashMap,
    io::{Read, Write},
    sync::{
        atomic::{AtomicU64, Ordering},
        Mutex,
    },
    thread,
};
use tauri::{Emitter, Manager, State};

struct PtySession {
    master: Box<dyn MasterPty + Send>,
    writer: Mutex<Box<dyn Write + Send>>,
}

struct AppState {
    next_session_id: AtomicU64,
    sessions: Mutex<HashMap<u64, PtySession>>,
}

#[derive(Clone, Serialize)]
struct TerminalOutput {
    session_id: u64,
    data: Vec<u8>,
}

#[derive(Clone, Serialize)]
struct TerminalExit {
    session_id: u64,
    status: Option<i32>,
}

#[tauri::command]
fn create_session_id(state: State<'_, AppState>) -> Result<u64, String> {
    Ok(state.next_session_id.fetch_add(1, Ordering::Relaxed))
}

#[tauri::command]
fn start_session(
    app: tauri::AppHandle,
    state: State<'_, AppState>,
    session_id: u64,
    host: String,
    cols: u16,
    rows: u16,
) -> Result<(), String> {

    let pty_system = NativePtySystem::default();
    let pair = pty_system
        .openpty(PtySize {
            rows,
            cols,
            pixel_width: 0,
            pixel_height: 0,
        })
        .map_err(|error| error.to_string())?;

    let mut command = if host == "localhost" || host == "127.0.0.1" {
        let mut command = CommandBuilder::new("sh");
        command.arg("-lc");
        command.arg("tmux a || tmux new");
        command
    } else {
        let mut command = CommandBuilder::new("ssh");
        command.arg("-t");
        command.arg(host.clone());
        command.arg("tmux a || tmux new");
        command
    };
    command.env("TERM", "xterm-256color");

    let mut child = pair
        .slave
        .spawn_command(command)
        .map_err(|error| error.to_string())?;
    drop(pair.slave);

    let mut reader = pair
        .master
        .try_clone_reader()
        .map_err(|error| error.to_string())?;
    let writer = pair.master.take_writer().map_err(|error| error.to_string())?;

    state
        .sessions
        .lock()
        .map_err(|_| "session lock poisoned".to_string())?
        .insert(
            session_id,
            PtySession {
                master: pair.master,
                writer: Mutex::new(writer),
            },
        );

    let output_app = app.clone();
    thread::spawn(move || {
        let mut buffer = [0; 8192];
        loop {
            match reader.read(&mut buffer) {
                Ok(0) => break,
                Ok(read) => {
                    let data = buffer[..read].to_vec();
                    let _ = output_app.emit(
                        "terminal-output",
                        TerminalOutput {
                            session_id,
                            data,
                        },
                    );
                }
                Err(error) if error.kind() == std::io::ErrorKind::Interrupted => {}
                Err(_) => break,
            }
        }
    });

    let exit_app = app.clone();
    thread::spawn(move || {
        let status = child.wait().ok().map(|status| status.exit_code() as i32);
        if let Some(state) = exit_app.try_state::<AppState>() {
            if let Ok(mut sessions) = state.sessions.lock() {
                sessions.remove(&session_id);
            }
        }
        let _ = exit_app.emit("terminal-exit", TerminalExit { session_id, status });
    });

    Ok(())
}

#[tauri::command]
fn write_session(state: State<'_, AppState>, session_id: u64, data: String) -> Result<(), String> {
    let sessions = state
        .sessions
        .lock()
        .map_err(|_| "session lock poisoned".to_string())?;
    let session = sessions
        .get(&session_id)
        .ok_or_else(|| "session not found".to_string())?;
    let mut writer = session
        .writer
        .lock()
        .map_err(|_| "session writer lock poisoned".to_string())?;
    writer
        .write_all(data.as_bytes())
        .map_err(|error| error.to_string())?;
    writer.flush().map_err(|error| error.to_string())
}

#[tauri::command]
fn resize_session(
    state: State<'_, AppState>,
    session_id: u64,
    cols: u16,
    rows: u16,
) -> Result<(), String> {
    let sessions = state
        .sessions
        .lock()
        .map_err(|_| "session lock poisoned".to_string())?;
    let session = sessions
        .get(&session_id)
        .ok_or_else(|| "session not found".to_string())?;
    session
        .master
        .resize(PtySize {
            rows,
            cols,
            pixel_width: 0,
            pixel_height: 0,
        })
        .map_err(|error| error.to_string())
}

#[tauri::command]
fn stop_session(state: State<'_, AppState>, session_id: u64) -> Result<(), String> {
    state
        .sessions
        .lock()
        .map_err(|_| "session lock poisoned".to_string())?
        .remove(&session_id);
    Ok(())
}

#[tauri::command]
fn get_ssh_hosts() -> Result<Vec<String>, String> {
    let mut hosts = vec!["localhost".to_string()];
    let home = std::env::var("HOME").map_err(|e| e.to_string())?;
    let config_path = std::path::PathBuf::from(home).join(".ssh").join("config");
    
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
            }
        }
    }
    Ok(hosts)
}

fn main() {
    tauri::Builder::default()
        .manage(AppState {
            next_session_id: AtomicU64::new(1),
            sessions: Mutex::new(HashMap::new()),
        })
        .plugin(tauri_plugin_shell::init())
        .invoke_handler(tauri::generate_handler![
            create_session_id,
            start_session,
            write_session,
            resize_session,
            stop_session,
            get_ssh_hosts
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}

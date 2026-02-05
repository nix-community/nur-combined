use rustix::fs::{FlockOperation, flock};
use rustix::io::{FdFlags, fcntl_setfd};
use std::collections::HashSet;
use std::env;
use std::fs::OpenOptions;
use std::os::unix::process::CommandExt;
use std::path::PathBuf;
use std::process::Command;

fn main() {
    let runtime_dir = env::var("XDG_RUNTIME_DIR").unwrap_or_else(|_| String::from("/tmp"));

    let user = env::var("USER").unwrap_or_else(|_| "user".into());
    let lock_dir = PathBuf::from(&runtime_dir).join(format!("shpool-{}-locks", user));

    if !lock_dir.exists() {
        let _ = std::fs::create_dir_all(&lock_dir);
    }

    // === 1. Spawn Mode detection ===
    // Ctrl+Shift+N inherit mother's CWD。
    // if CWD != HOME，highly possible is a new window opened on dir,
    // expect a new shell instead of the session retain by last by this slot.
    let cwd = env::current_dir().unwrap_or_else(|_| PathBuf::from("/"));
    let home = env::var("HOME").ok().map(PathBuf::from);

    // cannot get HOME, fallback
    let is_spawn_mode = match home {
        Some(h) => cwd != h,
        None => true,
    };

    let running_sessions = get_running_sessions();

    let mut slots: Vec<u32> = (1..=20).collect();

    if is_spawn_mode {
        slots.sort_by_key(|&i| {
            if running_sessions.contains(&i.to_string()) {
                1
            } else {
                0
            }
        });
    }

    for &i in &slots {
        let lock_path = lock_dir.join(format!("slot_{}.lock", i));
        let session_name = format!("{}", i); // 建议名字纯数字，简洁

        let file = OpenOptions::new()
            .read(true)
            .write(true)
            .create(true)
            .open(&lock_path);

        if let Ok(f) = file {
            if let Ok(_) = flock(&f, FlockOperation::NonBlockingLockExclusive) {
                if let Err(_) = fcntl_setfd(&f, FdFlags::empty()) {
                    continue;
                }

                if is_spawn_mode && running_sessions.contains(&session_name) {
                    let _ = Command::new("shpool")
                        .arg("kill")
                        .arg(&session_name)
                        .output(); // output() 会等待子进程结束，起到同步作用
                }

                let mut cmd = Command::new("shpool");
                cmd.arg("attach").arg("-f").arg(&session_name);

                cmd.arg("--dir").arg(&cwd);

                let err = cmd.exec();

                panic!("[shpool-mux] FATAL: Failed to exec shpool: {}", err);
            }
        }
    }

    eprintln!("\n[shpool-mux] Error: All 20 slots are locked locally.");
    eprintln!("Press ENTER to exit...");
    let _ = std::io::stdin().read_line(&mut String::new());
}

fn get_running_sessions() -> HashSet<String> {
    let mut set = HashSet::new();
    if let Ok(output) = Command::new("shpool").arg("list").output() {
        let stdout = String::from_utf8_lossy(&output.stdout);
        // NAME    STARTED_AT    STATUS
        // 1       ...           attached
        for line in stdout.lines().skip(1) {
            if let Some(name) = line.split_whitespace().next() {
                set.insert(name.to_string());
            }
        }
    }
    set
}

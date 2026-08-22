use std::io::{Read, Write};
use std::path::PathBuf;
use std::process::{Command, Stdio};
use std::time::Duration;

fn mods_dir() -> Option<PathBuf> {
    if let Ok(dir) = std::env::var("HANGA_MODS") {
        let path = PathBuf::from(dir);
        if path.join("urban_chaos.wasm").is_file() {
            return Some(path);
        }
    }
    let root = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    for profile in ["release", "debug"] {
        let dir = root.join("target/wasm32-unknown-unknown").join(profile);
        if dir.join("urban_chaos.wasm").is_file() {
            return Some(dir);
        }
    }
    None
}

fn hanga_bin() -> PathBuf {
    if let Ok(path) = std::env::var("HANGA_BIN") {
        return PathBuf::from(path);
    }
    if let Some(path) = option_env!("CARGO_BIN_EXE_hanga") {
        return PathBuf::from(path);
    }
    std::env::current_exe()
        .ok()
        .and_then(|exe| exe.parent().map(|dir| dir.join("hanga")))
        .filter(|path| path.is_file())
        .unwrap_or_else(|| PathBuf::from("hanga"))
}

#[test]
fn test_headless_agent_simulation() {
    let mut cmd = Command::new(hanga_bin());
    cmd.args(["--headless", "--agent-client", "--mode=server"])
        .stdin(Stdio::piped())
        .stdout(Stdio::piped());
    if let Some(dir) = mods_dir() {
        cmd.env("HANGA_MODS", dir);
    }
    let mut child = cmd.spawn().expect("Failed to spawn headless server agent client");

    let mut stdin = child.stdin.take().expect("Failed to open stdin");
    let mut stdout = child.stdout.take().expect("Failed to open stdout");

    // Wait for the app to initialize
    std::thread::sleep(Duration::from_secs(2));

    // Send a Look command
    let look_command = b"{\"action\": \"Look\"}\n";
    stdin.write_all(look_command).expect("Failed to write to stdin");
    stdin.flush().expect("Failed to flush stdin");

    std::thread::sleep(Duration::from_millis(500));

    let mut buffer = [0; 1024];
    let bytes_read = stdout.read(&mut buffer).unwrap_or(0);
    let output = String::from_utf8_lossy(&buffer[..bytes_read]);

    println!("Headless Agent Output: {}", output);

    assert!(output.contains("\"status\":\"ok\""));
    assert!(output.contains("\"trust_score\":"));
    assert!(output.contains("\"wanted_level\":"));

    child.kill().expect("Failed to kill child process");
}

#[test]
fn test_pure_engine_headless_subsystems() {
    use hanga::is_action_physically_possible;
    use hanga::TrustLedger;

    let mut ledger = TrustLedger::default();
    assert!(ledger.is_trusted(1));
    assert_eq!(ledger.score(1), 1.0);
    ledger.penalize(1, 0.4);
    assert!((ledger.score(1) - 0.6).abs() < 1e-5);
    assert!(ledger.is_trusted(1));
    ledger.penalize(1, 0.8);
    assert!(!ledger.is_trusted(1));

    assert!(is_action_physically_possible(0.0, 0.0, 0.0, 3.0, 4.0, 0.0, 6.0));
    assert!(!is_action_physically_possible(0.0, 0.0, 0.0, 10.0, 0.0, 0.0, 5.0));
}

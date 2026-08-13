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

#[test]
fn test_agent_client_interaction() {
    // Spawn the agent client directly (avoids cargo run deadlock during cargo test)
    let mut cmd = Command::new(env!("CARGO_BIN_EXE_hanga"));
    cmd.args(["--agent-client"])
        .stdin(Stdio::piped())
        .stdout(Stdio::piped());
    if let Some(dir) = mods_dir() {
        cmd.env("HANGA_MODS", dir);
    }
    let mut child = cmd.spawn().expect("Failed to spawn agent client");

    let mut stdin = child.stdin.take().expect("Failed to open stdin");
    let mut stdout = child.stdout.take().expect("Failed to open stdout");

    // Wait a little bit for the app to initialize
    std::thread::sleep(Duration::from_secs(2));

    // Send a Look command
    let look_command = b"{\"action\": \"Look\"}\n";
    stdin.write_all(look_command).expect("Failed to write to stdin");
    stdin.flush().expect("Failed to flush stdin");

    // Give it a moment to process and print the observation
    std::thread::sleep(Duration::from_millis(500));

    // Read the output (we read a chunk of bytes to see if our JSON observation is there)
    let mut buffer = [0; 1024];
    let bytes_read = stdout.read(&mut buffer).unwrap_or(0);
    let output = String::from_utf8_lossy(&buffer[..bytes_read]);

    println!("Agent Output: {}", output);

    // It should contain the JSON observation
    assert!(output.contains("\"status\":\"ok\""));
    assert!(output.contains("\"trust_score\":"));
    assert!(output.contains("\"wanted_level\":"));
    assert!(output.contains("\"voxel_ahead\":"));
    let named = [
        "air",
        "concrete",
        "asphalt",
        "glass",
        "sidewalk",
        "grass",
        "tile",
        "rail",
    ]
    .iter()
    .any(|name| output.contains(&format!("\"voxel_ahead\":\"{name}\"")));
    assert!(
        named,
        "WASM mod must load a named voxel (build hanga-mods / --target wasm32-unknown-unknown). Got: {output}"
    );

    // Send a MoveForward command
    let move_command = b"{\"action\": \"MoveForward\"}\n";
    stdin.write_all(move_command).expect("Failed to write to stdin");
    stdin.flush().expect("Failed to flush stdin");

    // Send another Look command
    let look_command2 = b"{\"action\": \"Look\"}\n";
    stdin.write_all(look_command2).expect("Failed to write to stdin");
    stdin.flush().expect("Failed to flush stdin");

    std::thread::sleep(Duration::from_millis(500));

    let mut buffer2 = [0; 1024];
    let bytes_read2 = stdout.read(&mut buffer2).unwrap_or(0);
    let output2 = String::from_utf8_lossy(&buffer2[..bytes_read2]);

    println!("Agent Output 2: {}", output2);
    assert!(output2.contains("\"status\":\"ok\""));

    // Kill the process after the test
    child.kill().expect("Failed to kill child process");
}

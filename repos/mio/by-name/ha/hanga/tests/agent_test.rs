use std::io::{Read, Write};
use std::process::{Command, Stdio};
use std::time::Duration;

#[test]
fn test_agent_client_interaction() {
    // Build the binary first to ensure it's up to date and we don't time out waiting for it
    let status = Command::new("cargo")
        .args(["build"])
        .status()
        .expect("Failed to build project");
    assert!(status.success());

    // Spawn the agent client
    let mut child = Command::new("cargo")
        .args(["run", "--", "--agent-client"])
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .spawn()
        .expect("Failed to spawn agent client");

    let mut stdin = child.stdin.take().expect("Failed to open stdin");
    let mut stdout = child.stdout.take().expect("Failed to open stdout");

    // Wait a little bit for the app to initialize
    std::thread::sleep(Duration::from_secs(2));

    // Send a Look command
    let look_command = r#"{"action": "Look"}\n"#;
    stdin.write_all(look_command.as_bytes()).expect("Failed to write to stdin");
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

    // Send a MoveForward command
    let move_command = r#"{"action": "MoveForward"}\n"#;
    stdin.write_all(move_command.as_bytes()).expect("Failed to write to stdin");
    stdin.flush().expect("Failed to flush stdin");

    // Send another Look command
    let look_command2 = r#"{"action": "Look"}\n"#;
    stdin.write_all(look_command2.as_bytes()).expect("Failed to write to stdin");
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

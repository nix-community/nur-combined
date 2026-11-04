use std::{
    io::Write,
    process::{Command, Output, Stdio},
};

fn run(args: &[&str], default_file: Option<&str>, input: &str) -> Output {
    let mut command = Command::new(env!("CARGO_BIN_EXE_ccd-status"));
    command
        .args(args)
        .env_remove("CCD_TOOLS_ACCOUNTS")
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped());
    if let Some(file) = default_file {
        command.env("CCD_TOOLS_ACCOUNTS", file);
    }
    let mut child = command.spawn().unwrap();
    child
        .stdin
        .take()
        .unwrap()
        .write_all(input.as_bytes())
        .unwrap();
    child.wait_with_output().unwrap()
}

#[test]
fn requires_configuration() {
    let output = run(&[], None, "");
    assert!(!output.status.success());
    assert!(String::from_utf8_lossy(&output.stderr).contains("--accounts"));
    assert!(output.stdout.is_empty());
}

#[test]
fn reads_stdin_from_environment_default() {
    let output = run(&[], Some("-"), "Name,Address\n");
    assert!(!output.status.success());
    assert!(String::from_utf8_lossy(&output.stderr).contains("contains no accounts"));
    assert!(output.stdout.is_empty());
}

#[test]
fn explicit_argument_overrides_environment() {
    let output = run(
        &["--accounts", "-"],
        Some("/nonexistent/ccd-accounts.csv"),
        "Name,Address\n",
    );
    assert!(!output.status.success());
    assert!(String::from_utf8_lossy(&output.stderr).contains("contains no accounts"));
    assert!(output.stdout.is_empty());
}

#[test]
fn missing_file_fails_without_a_report() {
    let output = run(&["--accounts", "/nonexistent/ccd-accounts.csv"], None, "");
    assert!(!output.status.success());
    assert!(String::from_utf8_lossy(&output.stderr).contains("cannot open accounts file"));
    assert!(output.stdout.is_empty());
}

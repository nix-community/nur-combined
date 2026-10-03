//! The built `sasso` binary carries its version as a marker the npm CLI reads
//! from the file instead of spawning `--version` (see `VERSION_MARKER` in
//! `src/main.rs` and `markedVersion` in `wasm/npm/cli.mjs`). If the optimiser
//! or the linker ever drops it, every npm CLI with this binary on `PATH` would
//! decline the hand-off, so this checks the file itself.

use std::process::Command;

const BIN: &str = env!("CARGO_BIN_EXE_sasso");

#[test]
fn the_binary_carries_its_version_marker() {
    let bytes = std::fs::read(BIN).expect("read the built binary");
    let marker = format!("\0sasso-cli-version={}\0", env!("CARGO_PKG_VERSION"));
    let found = bytes
        .windows(marker.len())
        .filter(|w| *w == marker.as_bytes())
        .count();
    assert_eq!(found, 1, "{BIN} should carry {marker:?} exactly once");
}

#[test]
fn version_prints_what_the_marker_says() {
    let out = Command::new(BIN)
        .arg("--version")
        .output()
        .expect("run sasso --version");
    assert!(out.status.success());
    assert_eq!(
        String::from_utf8(out.stdout).unwrap(),
        format!("sasso {}\n", env!("CARGO_PKG_VERSION"))
    );
}

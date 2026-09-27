//! End-to-end tests for the dart-sass-compatible CLI surface: the positional
//! grammar (`<input> [output]`), `in:out` pairs (files and directories),
//! parallel compilation, dart's defaults (source maps and an error stylesheet
//! when writing to a file), `--embed-source-map`, `--quiet`/`--quiet-deps`,
//! `--stop-on-error`, and dart's exit codes. Drives the REAL built binary
//! (`env!("CARGO_BIN_EXE_sasso")`).
//!
//! A gated dart-sass differential (opt-in via `SASSO_PARITY=1` + a reachable
//! `$SASS_BIN` that is the dart-sass CLI) runs the same invocation through
//! dart-sass and compares the produced files byte-for-byte.

use std::path::{Path, PathBuf};
use std::process::Command;

const BIN: &str = env!("CARGO_BIN_EXE_sasso");

/// dart-sass exit codes.
const EXIT_USAGE: i32 = 64;
const EXIT_COMPILE: i32 = 65;
const EXIT_IO: i32 = 66;

fn scratch(tag: &str) -> PathBuf {
    let dir = std::env::temp_dir().join(format!("sasso_cli_dc_{tag}_{}_{}", std::process::id(), unique()));
    std::fs::create_dir_all(&dir).expect("create scratch dir");
    dir
}

fn unique() -> u64 {
    use std::sync::atomic::{AtomicU64, Ordering};
    static N: AtomicU64 = AtomicU64::new(0);
    N.fetch_add(1, Ordering::Relaxed)
}

struct Run {
    code: i32,
    stdout: String,
    stderr: String,
}

fn run_bin(bin: &str, cwd: &Path, args: &[&str], stdin: Option<&str>) -> Run {
    run_bin_bytes(bin, cwd, args, stdin.map(str::as_bytes))
}

/// [`run_bin`] with raw bytes on stdin (for input that is not valid UTF-8).
fn run_bin_bytes(bin: &str, cwd: &Path, args: &[&str], stdin: Option<&[u8]>) -> Run {
    use std::io::Write as _;
    use std::process::Stdio;
    let mut cmd = Command::new(bin);
    cmd.args(args)
        .current_dir(cwd)
        .stdout(Stdio::piped())
        .stderr(Stdio::piped());
    cmd.stdin(if stdin.is_some() {
        Stdio::piped()
    } else {
        Stdio::null()
    });
    let mut child = cmd.spawn().expect("spawn");
    if let Some(bytes) = stdin {
        // A child that never reads stdin (a usage error, or an invocation whose
        // input is a file) may exit before this write lands; the resulting
        // closed pipe is not a test failure. Any other write error is.
        if let Err(e) = child.stdin.take().unwrap().write_all(bytes) {
            assert_eq!(
                e.kind(),
                std::io::ErrorKind::BrokenPipe,
                "stdin write failed: {e}"
            );
        }
    }
    let out = child.wait_with_output().expect("wait");
    Run {
        code: out.status.code().unwrap_or(-1),
        stdout: String::from_utf8_lossy(&out.stdout).into_owned(),
        stderr: String::from_utf8_lossy(&out.stderr).into_owned(),
    }
}

fn sasso(cwd: &Path, args: &[&str]) -> Run {
    run_bin(BIN, cwd, args, None)
}

fn write(dir: &Path, name: &str, contents: &str) -> PathBuf {
    let p = dir.join(name);
    if let Some(parent) = p.parent() {
        std::fs::create_dir_all(parent).expect("mkdir -p");
    }
    std::fs::write(&p, contents).expect("write input");
    p
}

fn read(dir: &Path, name: &str) -> String {
    std::fs::read_to_string(dir.join(name)).unwrap_or_else(|e| panic!("read {name}: {e}"))
}

/// The dart-sass CLI binary for the gated differential, if enabled and set to
/// a real executable (the `npx` default of the other parity tests is not a
/// file-writing CLI we can point at a scratch dir reliably).
fn dart_bin() -> Option<String> {
    if std::env::var("SASSO_PARITY").map(|v| v == "0").unwrap_or(true) {
        return None;
    }
    let bin = std::env::var("SASS_BIN").ok()?;
    if bin == "npx" || !Path::new(&bin).is_file() {
        return None;
    }
    // Absolute, so a relative `SASS_BIN` still resolves once the child runs in
    // a scratch directory.
    Some(std::fs::canonicalize(&bin).ok()?.to_string_lossy().into_owned())
}

/// Run the same `args` through dart-sass in a sibling scratch dir seeded with
/// the same `files`, and assert every file in `outputs` matches byte-for-byte.
fn assert_dart_files_match(files: &[(&str, &str)], args: &[&str], outputs: &[&str]) {
    let Some(dart) = dart_bin() else { return };
    let ours = scratch("parity_ours");
    let theirs = scratch("parity_theirs");
    for (name, text) in files {
        write(&ours, name, text);
        write(&theirs, name, text);
    }
    let a = sasso(&ours, args);
    let b = run_bin(&dart, &theirs, args, None);
    assert_eq!(
        a.code, b.code,
        "exit codes differ for {args:?}\nours: {}\ndart: {}",
        a.stderr, b.stderr
    );
    for out in outputs {
        let x = std::fs::read_to_string(ours.join(out)).ok();
        let y = std::fs::read_to_string(theirs.join(out)).ok();
        assert_eq!(x, y, "{out} differs from dart-sass for {args:?}");
    }
    std::fs::remove_dir_all(&ours).ok();
    std::fs::remove_dir_all(&theirs).ok();
}

const GOOD: &str = "$c: red;\na { color: $c; }\n";
const GOOD_CSS: &str = "a {\n  color: red;\n}\n";
const BAD: &str = "a { b: $x }\n";

// ---------------------------------------------------------------------------
// Positional grammar
// ---------------------------------------------------------------------------

#[test]
fn second_positional_is_the_output_file() {
    let dir = scratch("pos");
    write(&dir, "in.scss", GOOD);
    let r = sasso(&dir, &["--no-source-map", "in.scss", "out.css"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(r.stdout, "", "nothing on stdout when writing a file");
    assert_eq!(read(&dir, "out.css"), GOOD_CSS);
    // `--stdin [output]`
    let r = run_bin(
        BIN,
        &dir,
        &["--stdin", "--no-source-map", "from-stdin.css"],
        Some("x { y: z }\n"),
    );
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(read(&dir, "from-stdin.css"), "x {\n  y: z;\n}\n");
    // A stdin entry has no path: dart records its text as a `data:` URI in the
    // map's `sources`, both in a sidecar and inside an embedded map.
    let r = run_bin(BIN, &dir, &["--stdin", "stdin-map.css"], Some("a{b:c}\n"));
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(
        read(&dir, "stdin-map.css.map"),
        "{\"version\":3,\"sourceRoot\":\"\",\"sources\":[\"data:;charset=utf-8,a%7Bb:c%7D%0A\"],\"names\":[],\"mappings\":\"AAAA;EAAE\",\"file\":\"stdin-map.css\"}"
    );
    let r = run_bin(BIN, &dir, &["--stdin", "--embed-source-map"], Some("a{b:c}\n"));
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert!(
        r.stdout
            .contains("%22sources%22:%5B%22data:;charset=utf-8,a%257Bb:c%257D%250A%22%5D"),
        "{}",
        r.stdout
    );
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn dash_positional_reads_stdin() {
    let dir = scratch("dash");
    let r = run_bin(BIN, &dir, &["--no-source-map", "-"], Some("x { y: z }\n"));
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(r.stdout, "x {\n  y: z;\n}\n");
    let r = run_bin(
        BIN,
        &dir,
        &["--no-source-map", "-", "a.css"],
        Some("x { y: z }\n"),
    );
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(read(&dir, "a.css"), "x {\n  y: z;\n}\n");
    let r = run_bin(BIN, &dir, &["--no-source-map", "-:b.css"], Some("x { y: z }\n"));
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(read(&dir, "b.css"), "x {\n  y: z;\n}\n");
    // A `-` INPUT is stdin whatever the final `--[no-]stdin` value (dart).
    let r = run_bin(
        BIN,
        &dir,
        &["--no-source-map", "-", "--no-stdin", "c.css"],
        Some("x { y: z }\n"),
    );
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(read(&dir, "c.css"), "x {\n  y: z;\n}\n");
    // … and `--stdin --no-stdin` is off: the positional is the input.
    write(&dir, "in.scss", GOOD);
    let r = run_bin(
        BIN,
        &dir,
        &["--no-source-map", "--stdin", "--no-stdin", "in.scss"],
        Some("x { y: z }\n"),
    );
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(r.stdout, GOOD_CSS);
    // A `-` in the OUTPUT position is a file called `-`, as in dart; the input
    // is left alone.
    let r = run_bin(
        BIN,
        &dir,
        &["--no-source-map", "in.scss", "-"],
        Some("x { y: z }\n"),
    );
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(read(&dir, "-"), GOOD_CSS);
    assert_eq!(read(&dir, "in.scss"), GOOD);
    // `-:out` is a pair like any other and mixes with file pairs (dart keeps
    // `-` as a source in the same map); the same source twice is an error.
    write(&dir, "b.scss", "p { q: 1 }\n");
    let r = run_bin(
        BIN,
        &dir,
        &["--no-source-map", "-:d.css", "b.scss:bb.css"],
        Some("x { y: z }\n"),
    );
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(read(&dir, "d.css"), "x {\n  y: z;\n}\n");
    assert_eq!(read(&dir, "bb.css"), "p {\n  q: 1;\n}\n");
    let r = run_bin(
        BIN,
        &dir,
        &["--no-source-map", "-:e.css", "-:f.css"],
        Some("x { y: z }\n"),
    );
    assert_eq!(r.code, EXIT_USAGE);
    assert!(r.stderr.contains("Duplicate source \"-\"."), "{}", r.stderr);
    assert!(!dir.join("e.css").exists() && !dir.join("f.css").exists());
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn too_many_positionals_is_a_usage_error() {
    let dir = scratch("pos_err");
    write(&dir, "in.scss", GOOD);
    let r = sasso(&dir, &["in.scss", "a.css", "b.css"]);
    assert_eq!(r.code, EXIT_USAGE);
    assert!(
        r.stderr.contains("Only two positional args may be passed."),
        "{}",
        r.stderr
    );
    let r = run_bin(BIN, &dir, &["--stdin", "a.css", "b.css"], Some("a{b:c}"));
    assert_eq!(r.code, EXIT_USAGE);
    assert!(
        r.stderr.contains("Only one argument is allowed with --stdin."),
        "{}",
        r.stderr
    );
    std::fs::remove_dir_all(&dir).ok();
}

// ---------------------------------------------------------------------------
// `in:out` pairs and directory mode
// ---------------------------------------------------------------------------

#[test]
fn pairs_compile_each_input_to_its_own_output() {
    let dir = scratch("pairs");
    write(&dir, "a.scss", GOOD);
    write(&dir, "b.scss", "b { w: 1px + 1px; }\n");
    let r = sasso(&dir, &["--no-source-map", "a.scss:out/a.css", "b.scss:out/b.css"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(r.stdout, "");
    assert_eq!(
        read(&dir, "out/a.css"),
        GOOD_CSS,
        "missing output dirs are created"
    );
    assert_eq!(read(&dir, "out/b.css"), "b {\n  w: 2px;\n}\n");
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn pairs_get_a_source_map_by_default() {
    let dir = scratch("pairs_map");
    write(&dir, "src/a.scss", GOOD);
    let r = sasso(&dir, &["src/a.scss:out/a.css"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(
        read(&dir, "out/a.css"),
        format!("{GOOD_CSS}\n/*# sourceMappingURL=a.css.map */\n")
    );
    let map = read(&dir, "out/a.css.map");
    assert!(
        map.starts_with("{\"version\":3,\"sourceRoot\":\"\",\"sources\":[\"../src/a.scss\"]"),
        "{map}"
    );
    assert!(map.ends_with(",\"file\":\"a.css\"}"), "{map}");
    // `--no-source-map` opts out: no footer, no sidecar.
    let r = sasso(&dir, &["--no-source-map", "src/a.scss:out/b.css"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(read(&dir, "out/b.css"), GOOD_CSS);
    assert!(!dir.join("out/b.css.map").exists());
    assert_dart_files_match(
        &[("src/a.scss", GOOD)],
        &["src/a.scss:out/a.css"],
        &["out/a.css", "out/a.css.map"],
    );
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn directory_pair_mirrors_the_tree_and_skips_partials() {
    let dir = scratch("dirmode");
    write(&dir, "src/a.scss", GOOD);
    write(&dir, "src/_partial.scss", "$p: 1px;\n");
    write(
        &dir,
        "src/sub/nested.scss",
        "@use \"../partial\";\nb { w: partial.$p; }\n",
    );
    write(&dir, "src/plain.sass", "c\n  d: e\n");
    write(&dir, "src/raw.css", "f{g:h}\n");
    write(&dir, "src/notes.txt", "ignored\n");
    let r = sasso(&dir, &["--no-source-map", "src:out"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(read(&dir, "out/a.css"), GOOD_CSS);
    assert_eq!(read(&dir, "out/sub/nested.css"), "b {\n  w: 1px;\n}\n");
    assert_eq!(
        read(&dir, "out/plain.css"),
        "c {\n  d: e;\n}\n",
        ".sass compiles as indented syntax"
    );
    assert_eq!(
        read(&dir, "out/raw.css"),
        "f {\n  g: h;\n}\n",
        ".css compiles as plain CSS"
    );
    assert!(!dir.join("out/_partial.css").exists(), "partials are skipped");
    assert!(!dir.join("out/notes.css").exists() && !dir.join("out/notes.txt").exists());
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn pairs_cannot_mix_with_positionals_or_stdin() {
    let dir = scratch("pairs_mix");
    write(&dir, "a.scss", GOOD);
    let r = sasso(&dir, &["a.scss:out.css", "a.scss"]);
    assert_eq!(r.code, EXIT_USAGE);
    assert!(
        r.stderr
            .contains("Positional and \":\" arguments may not both be used."),
        "{}",
        r.stderr
    );
    let r = run_bin(BIN, &dir, &["--stdin", "-:out.css"], Some("a{b:c}"));
    assert_eq!(r.code, EXIT_USAGE);
    assert!(
        r.stderr.contains("--stdin may not be used with \":\" arguments."),
        "{}",
        r.stderr
    );
    std::fs::remove_dir_all(&dir).ok();
}

// ---------------------------------------------------------------------------
// Source-map flags on stdout, and `--embed-source-map`
// ---------------------------------------------------------------------------

#[test]
fn stdout_source_map_flags_need_embed_source_map() {
    let dir = scratch("stdout_map");
    write(&dir, "a.scss", GOOD);
    let r = sasso(&dir, &["--source-map", "a.scss"]);
    assert_eq!(r.code, EXIT_USAGE);
    assert!(
        r.stderr
            .contains("When printing to stdout, --source-map requires --embed-source-map."),
        "{}",
        r.stderr
    );
    let r = sasso(&dir, &["--embed-sources", "a.scss"]);
    assert_eq!(r.code, EXIT_USAGE);
    assert!(
        r.stderr
            .contains("When printing to stdout, --embed-sources requires --embed-source-map."),
        "{}",
        r.stderr
    );
    let r = sasso(&dir, &["--embed-source-map", "--no-source-map", "a.scss"]);
    assert_eq!(r.code, EXIT_USAGE);
    assert!(
        r.stderr
            .contains("--embed-source-map isn't allowed with --no-source-map."),
        "{}",
        r.stderr
    );
    // dart's remaining combinations.
    for (args, msg) in [
        (
            vec!["--embed-sources", "--no-source-map", "a.scss", "o.css"],
            "--embed-sources isn't allowed with --no-source-map.",
        ),
        (
            vec!["--source-map-urls=absolute", "--no-source-map", "a.scss", "o.css"],
            "--source-map-urls isn't allowed with --no-source-map.",
        ),
        (
            vec!["--source-map-urls=absolute", "a.scss"],
            "When printing to stdout, --source-map-urls requires --embed-source-map.",
        ),
        (
            vec!["--source-map-urls=relative", "--embed-source-map", "a.scss"],
            "--source-map-urls=relative isn't allowed when printing to stdout.",
        ),
    ] {
        let r = sasso(&dir, &args);
        assert_eq!(r.code, EXIT_USAGE, "{args:?}: {}", r.stderr);
        assert!(r.stderr.contains(msg), "{args:?}: {}", r.stderr);
    }
    // … while the explicit default is fine where a map is written.
    let r = sasso(&dir, &["--source-map-urls=relative", "a.scss", "o.css"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn embedded_map_cannot_close_the_footer_comment() {
    // `--embed-sources` puts the source text into the data: URI; a `*/` in it
    // must not terminate the `/*# sourceMappingURL=… */` comment early.
    let dir = scratch("star_footer");
    write(&dir, "in.scss", "/* end */ a { b: c }\n");
    let r = sasso(
        &dir,
        &["--embed-source-map", "--embed-sources", "in.scss", "out.css"],
    );
    assert_eq!(r.code, 0, "{}", r.stderr);
    let css = read(&dir, "out.css");
    let footer = css.rsplit("/*# sourceMappingURL=").next().unwrap();
    let uri = footer
        .strip_suffix(" */\n")
        .expect("footer closes once, at the very end");
    assert!(
        !uri.contains("*/"),
        "the URI must not contain a comment terminator: {uri}"
    );
    assert!(uri.contains("%2A/"), "dart escapes `*/` as `%2A/`: {uri}");
    assert_dart_files_match(
        &[("in.scss", "/* end */ a { b: c }\n")],
        &["--embed-source-map", "--embed-sources", "in.scss", "out.css"],
        &["out.css"],
    );
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn map_is_written_before_css() {
    // If the sidecar cannot be written, no CSS that points at it may appear.
    let dir = scratch("map_first");
    write(&dir, "in.scss", GOOD);
    std::fs::create_dir_all(dir.join("out.css.map")).unwrap(); // a directory blocks the map
    let r = sasso(&dir, &["in.scss", "out.css"]);
    assert_eq!(r.code, EXIT_IO, "{}", r.stderr);
    assert!(
        !dir.join("out.css").exists(),
        "CSS must not be published without its map"
    );
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn embed_source_map_inlines_a_data_uri() {
    let dir = scratch("embed");
    write(&dir, "src/a.scss", GOOD);
    // To a file: relative sources, a `file` field, and no sidecar.
    let r = sasso(&dir, &["--embed-source-map", "src/a.scss:out/a.css"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    let css = read(&dir, "out/a.css");
    let expected_prefix = format!(
        "{GOOD_CSS}\n/*# sourceMappingURL=data:application/json;charset=utf-8,%7B%22version%22:3,%22sourceRoot%22:%22%22,%22sources%22:%5B%22../src/a.scss%22%5D,%22names%22:%5B%5D,%22mappings%22:%22"
    );
    assert!(css.starts_with(&expected_prefix), "{css}");
    assert!(css.ends_with("%22,%22file%22:%22a.css%22%7D */\n"), "{css}");
    assert!(!dir.join("out/a.css.map").exists(), "no sidecar when embedded");
    // `--embed-sources` rides along inside the data URI.
    let r = sasso(
        &dir,
        &["--embed-source-map", "--embed-sources", "src/a.scss:out/b.css"],
    );
    assert_eq!(r.code, 0, "{}", r.stderr);
    let css = read(&dir, "out/b.css");
    assert!(
        css.contains("%22sourcesContent%22:%5B%22$c:%20red;%5Cna%20%7B%20color:%20$c;%20%7D%5Cn%22%5D"),
        "{css}"
    );
    // To stdout: absolute `file://` sources and no `file` field, like dart.
    let r = sasso(&dir, &["--embed-source-map", "src/a.scss"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert!(
        r.stdout.starts_with(&format!(
            "{GOOD_CSS}\n/*# sourceMappingURL=data:application/json;charset=utf-8,"
        )),
        "{}",
        r.stdout
    );
    assert!(r.stdout.contains("%22sources%22:%5B%22file:///"), "{}", r.stdout);
    assert!(!r.stdout.contains("%22file%22"), "{}", r.stdout);
    assert!(r.stdout.ends_with("%7D */\n"), "{}", r.stdout);
    assert_dart_files_match(
        &[("src/a.scss", GOOD)],
        &["--embed-source-map", "--embed-sources", "src/a.scss:out/a.css"],
        &["out/a.css"],
    );
    std::fs::remove_dir_all(&dir).ok();
}

// ---------------------------------------------------------------------------
// Error handling: error CSS, exit codes, --stop-on-error
// ---------------------------------------------------------------------------

/// dart's error stylesheet for `BAD` compiled from `in.scss` (Unicode glyphs
/// in `content`, ASCII glyphs in the comment).
const BAD_ERROR_CSS: &str = "/* Error: Undefined variable.\n *   ,\n * 1 | a { b: $x }\n *   |        ^^\n *   '\n *   in.scss 1:8  root stylesheet */\n\nbody::before {\n  font-family: \"Source Code Pro\", \"SF Mono\", Monaco, Inconsolata, \"Fira Mono\",\n      \"Droid Sans Mono\", monospace, monospace;\n  white-space: pre;\n  display: block;\n  padding: 1em;\n  margin-bottom: 1em;\n  border-bottom: 2px solid black;\n  content: \"Error: Undefined variable.\\a   \\2577 \\a 1 \\2502  a { b: $x }\\a   \\2502         ^^\\a   \\2575 \\a   in.scss 1:8  root stylesheet\";\n}\n";

#[test]
fn error_css_is_written_for_file_output_by_default() {
    let dir = scratch("errcss");
    write(&dir, "in.scss", BAD);
    let r = sasso(&dir, &["--no-source-map", "in.scss", "out.css"]);
    assert_eq!(r.code, EXIT_COMPILE);
    assert!(
        r.stderr.starts_with("Error: Undefined variable.\n"),
        "{}",
        r.stderr
    );
    assert_eq!(read(&dir, "out.css"), BAD_ERROR_CSS);
    // Non-ASCII in the message is escaped in `content` (dart: `\e9 `), and the
    // comment keeps it raw.
    write(&dir, "uni.scss", "a { b: $é }\n");
    let r = sasso(
        &dir,
        &["--no-source-map", "--style=compressed", "uni.scss", "uni.css"],
    );
    assert_eq!(r.code, EXIT_COMPILE);
    let css = read(&dir, "uni.css");
    assert!(css.contains(" * 1 | a { b: $é }\n"), "{css}");
    assert!(css.contains("a { b: $\\e9  }\\a "), "{css}");
    assert!(
        css.starts_with("/* Error:"),
        "compressed style still writes the expanded error sheet: {css}"
    );
    // `--no-unicode` switches the `content` glyphs to ASCII too.
    let r = sasso(&dir, &["--no-source-map", "--no-unicode", "in.scss", "ascii.css"]);
    assert_eq!(r.code, EXIT_COMPILE);
    assert!(read(&dir, "ascii.css").contains("content: \"Error: Undefined variable.\\a   ,\\a 1 | a { b: $x }\\a   |        ^^\\a   '\\a   in.scss 1:8  root stylesheet\";"));
    assert_dart_files_match(
        &[("in.scss", BAD)],
        &["--no-source-map", "in.scss", "out.css"],
        &["out.css"],
    );
    assert_dart_files_match(
        &[("in.scss", BAD)],
        &["--no-source-map", "--no-unicode", "in.scss", "out.css"],
        &["out.css"],
    );
    // `*/` inside the message must not close the comment (dart: U+2215).
    write(&dir, "star.scss", "@error \"a */ b\";\n");
    let r = sasso(&dir, &["--no-source-map", "star.scss", "star.css"]);
    assert_eq!(r.code, EXIT_COMPILE);
    let css = read(&dir, "star.css");
    assert!(css.contains("/* Error: \"a *\u{2215} b\"\n"), "{css}");
    assert!(css.contains("content: \"Error: \\\"a */ b\\\"\\a "), "{css}");
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn no_error_css_and_stdout_errors_write_nothing() {
    let dir = scratch("noerrcss");
    write(&dir, "in.scss", BAD);
    let r = sasso(&dir, &["--no-source-map", "--no-error-css", "in.scss", "out.css"]);
    assert_eq!(r.code, EXIT_COMPILE);
    assert!(!dir.join("out.css").exists(), "--no-error-css writes no file");
    // To stdout the default is off …
    let r = sasso(&dir, &["in.scss"]);
    assert_eq!(r.code, EXIT_COMPILE);
    assert_eq!(r.stdout, "");
    // … unless asked for explicitly.
    let r = sasso(&dir, &["--error-css", "in.scss"]);
    assert_eq!(r.code, EXIT_COMPILE);
    assert_eq!(r.stdout, BAD_ERROR_CSS);
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn dependency_provenance_is_per_compilation() {
    // The same file can be a dependency of one entry (reached through `-I lp`)
    // and not of another (reached relatively), even within one process: dart
    // decides per compilation, so with `-j 1` the second unit must not inherit
    // the first unit's classification.
    let dir = scratch("deps_per_unit");
    write(&dir, "lp/_dep.scss", "@import \"x\";\n");
    write(&dir, "lp/_x.scss", "q { r: 1; }\n");
    write(&dir, "a.scss", "@import \"dep\";\n");
    write(&dir, "b.scss", "@use \"lp/dep\";\n");
    let r = sasso(
        &dir,
        &[
            "-j",
            "1",
            "--quiet-deps",
            "--no-source-map",
            "-I",
            "lp",
            "a.scss:out/a.css",
            "b.scss:out/b.css",
        ],
    );
    assert_eq!(r.code, 0, "{}", r.stderr);
    // a: its own @import warns, the dependency's @import is silenced.
    // b: `lp/dep` is relative, so its @import "x" warns.
    assert_eq!(
        r.stderr.matches("DEPRECATION WARNING [import]").count(),
        2,
        "{}",
        r.stderr
    );
    std::fs::remove_dir_all(&dir).ok();
}

#[cfg(unix)]
#[test]
fn directory_pair_survives_a_symlink_cycle() {
    let dir = scratch("symlink_cycle");
    write(&dir, "src/a.scss", GOOD);
    write(&dir, "src/sub/b.scss", "b { c: d }\n");
    std::os::unix::fs::symlink("..", dir.join("src/sub/up")).expect("symlink");
    let r = sasso(&dir, &["--no-source-map", "src:out"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(read(&dir, "out/a.css"), GOOD_CSS);
    assert_eq!(read(&dir, "out/sub/b.css"), "b {\n  c: d;\n}\n");
    assert!(
        !dir.join("out/sub/up").exists(),
        "the cycle is visited once, not mirrored"
    );
    // Two names for one directory: the first in sorted order is mirrored, the
    // other skipped — the same way every run, whatever `read_dir` yields.
    std::os::unix::fs::symlink("sub", dir.join("src/zz-alias")).expect("symlink");
    for _ in 0..2 {
        std::fs::remove_dir_all(dir.join("out")).ok();
        let r = sasso(&dir, &["--no-source-map", "src:out"]);
        assert_eq!(r.code, 0, "{}", r.stderr);
        assert!(
            dir.join("out/sub/b.css").exists(),
            "`sub` sorts before `zz-alias` and wins"
        );
        assert!(!dir.join("out/zz-alias").exists());
    }
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn no_css_has_no_side_effects_on_failure_either() {
    let dir = scratch("no_css_fail");
    write(&dir, "bad.scss", BAD);
    write(&dir, "out.css", "old { css: yes }\n");
    let r = sasso(&dir, &["--no-css", "bad.scss:out.css"]);
    assert_eq!(r.code, EXIT_COMPILE);
    assert!(r.stderr.contains("Undefined variable"), "{}", r.stderr);
    assert_eq!(
        read(&dir, "out.css"),
        "old { css: yes }\n",
        "neither replaced nor removed"
    );
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn error_without_error_css_removes_a_stale_output() {
    let dir = scratch("stale");
    write(&dir, "bad.scss", BAD);
    write(&dir, "out.css", "old { css: yes }\n");
    write(&dir, "out.css.map", "old map");
    // dart deletes the stale CSS (not the map) when error CSS is off …
    let r = sasso(
        &dir,
        &["--no-error-css", "--no-source-map", "bad.scss", "out.css"],
    );
    assert_eq!(r.code, EXIT_COMPILE);
    assert!(
        !dir.join("out.css").exists(),
        "stale CSS must not survive a failed build"
    );
    assert!(dir.join("out.css.map").exists(), "the map is left alone");
    // … and overwrites it with the error stylesheet when it is on.
    write(&dir, "out.css", "old { css: yes }\n");
    let r = sasso(&dir, &["--no-source-map", "bad.scss", "out.css"]);
    assert_eq!(r.code, EXIT_COMPILE);
    assert!(read(&dir, "out.css").starts_with("/* Error: Undefined variable."));
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn invalid_utf8_is_a_compile_error_with_error_css() {
    let dir = scratch("utf8");
    std::fs::write(dir.join("bad.scss"), b"a { b: c }\n\xff\xfe\n").unwrap();
    let r = sasso(&dir, &["--no-source-map", "bad.scss", "out.css"]);
    assert_eq!(r.code, EXIT_COMPILE);
    assert!(r.stderr.starts_with("Error: Invalid UTF-8."), "{}", r.stderr);
    let css = read(&dir, "out.css");
    assert!(
        css.starts_with("/* Error: Invalid UTF-8. */\n\nbody::before {"),
        "{css}"
    );
    assert!(css.contains("content: \"Error: Invalid UTF-8.\";"), "{css}");
    // Without error CSS a stale output goes away, like any compile error.
    let r = sasso(
        &dir,
        &["--no-error-css", "--no-source-map", "bad.scss", "out.css"],
    );
    assert_eq!(r.code, EXIT_COMPILE);
    assert!(!dir.join("out.css").exists());
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn missing_input_exits_66() {
    let dir = scratch("missing");
    let r = sasso(&dir, &["nope.scss"]);
    assert_eq!(r.code, EXIT_IO);
    assert_eq!(r.stderr, "Error reading nope.scss: Cannot open file.\n");
    let r = sasso(&dir, &["nope.scss:out.css"]);
    assert_eq!(r.code, EXIT_IO);
    assert!(!dir.join("out.css").exists());
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn stop_on_error_skips_the_rest_but_default_continues() {
    let dir = scratch("stop");
    write(&dir, "bad.scss", BAD);
    write(&dir, "good.scss", GOOD);
    // Default: every pair is attempted, exit 65.
    let r = sasso(
        &dir,
        &[
            "--no-source-map",
            "--no-error-css",
            "bad.scss:out/bad.css",
            "good.scss:out/good.css",
        ],
    );
    assert_eq!(r.code, EXIT_COMPILE);
    assert!(!dir.join("out/bad.css").exists());
    assert_eq!(read(&dir, "out/good.css"), GOOD_CSS);
    // `--stop-on-error` (with one worker, so "the rest" is deterministic).
    std::fs::remove_dir_all(dir.join("out")).ok();
    let r = sasso(
        &dir,
        &[
            "-j",
            "1",
            "--no-source-map",
            "--no-error-css",
            "--stop-on-error",
            "bad.scss:out/bad.css",
            "good.scss:out/good.css",
        ],
    );
    assert_eq!(r.code, EXIT_COMPILE);
    assert!(
        !dir.join("out/good.css").exists(),
        "later units are not started after a failure"
    );
    assert!(r.stderr.contains("Undefined variable"), "{}", r.stderr);
    std::fs::remove_dir_all(&dir).ok();
}

// ---------------------------------------------------------------------------
// Parallelism
// ---------------------------------------------------------------------------

#[test]
fn parallel_pairs_match_sequential_and_report_in_order() {
    let dir = scratch("parallel");
    let mut pairs: Vec<String> = Vec::new();
    for i in 0..24 {
        // Each file warns, so stderr ordering is observable too.
        write(
            &dir,
            &format!("in/f{i:02}.scss"),
            &format!("@warn \"w{i:02}\";\n$n: {i};\n.f{i:02} {{ w: $n * 1px; }}\n"),
        );
        pairs.push(format!("in/f{i:02}.scss:par/f{i:02}.css"));
    }
    // An explicit worker count: on a single-core runner the default would be
    // 1 and `compile_all` would take its sequential path, leaving the
    // scheduler and the ordered result buffering untested.
    let args: Vec<&str> = ["-j", "8", "--no-source-map"]
        .into_iter()
        .chain(pairs.iter().map(String::as_str))
        .collect();
    let par = sasso(&dir, &args);
    assert_eq!(par.code, 0, "{}", par.stderr);
    let seq_pairs: Vec<String> = pairs.iter().map(|p| p.replace(":par/", ":seq/")).collect();
    let mut seq_args = vec!["-j", "1", "--no-source-map"];
    seq_args.extend(seq_pairs.iter().map(String::as_str));
    let seq = sasso(&dir, &seq_args);
    assert_eq!(seq.code, 0, "{}", seq.stderr);
    for i in 0..24 {
        assert_eq!(
            read(&dir, &format!("par/f{i:02}.css")),
            read(&dir, &format!("seq/f{i:02}.css"))
        );
        assert_eq!(
            read(&dir, &format!("par/f{i:02}.css")),
            format!(".f{i:02} {{\n  w: {i}px;\n}}\n")
        );
    }
    // Warnings come out in command-line order regardless of which worker ran what.
    let order: Vec<&str> = par
        .stderr
        .lines()
        .filter(|l| l.starts_with("WARNING: w"))
        .collect();
    let expected: Vec<String> = (0..24).map(|i| format!("WARNING: w{i:02}")).collect();
    assert_eq!(order, expected);
    assert_eq!(par.stderr, seq.stderr);
    std::fs::remove_dir_all(&dir).ok();
}

// ---------------------------------------------------------------------------
// Warnings: --quiet, --quiet-deps
// ---------------------------------------------------------------------------

#[test]
fn quiet_silences_warnings_but_not_errors() {
    let dir = scratch("quiet");
    write(
        &dir,
        "w.scss",
        "@warn \"loud\";\n@debug \"dbg\";\n@import \"dep\";\n",
    );
    write(&dir, "_dep.scss", "a { b: c }\n");
    let r = sasso(&dir, &["w.scss"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert!(
        r.stderr.contains("WARNING: loud")
            && r.stderr.contains("dbg")
            && r.stderr.contains("DEPRECATION WARNING [import]"),
        "{}",
        r.stderr
    );
    let r = sasso(&dir, &["-q", "w.scss"]);
    assert_eq!(r.code, 0);
    assert_eq!(r.stderr, "", "--quiet drops every warning");
    assert_eq!(r.stdout, "a {\n  b: c;\n}\n");
    write(&dir, "bad.scss", BAD);
    let r = sasso(&dir, &["--quiet", "bad.scss"]);
    assert_eq!(r.code, EXIT_COMPILE);
    assert!(
        r.stderr.contains("Error: Undefined variable."),
        "errors still print under --quiet: {}",
        r.stderr
    );
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn quiet_deps_silences_deprecations_from_load_path_files_only() {
    let dir = scratch("quiet_deps");
    // Entry: an @import (deprecation) of a load-path dependency that itself
    // has an @import (deprecation) and a @warn.
    write(&dir, "entry.scss", "@import \"dep\";\n@warn \"from entry\";\n");
    write(&dir, "lp/_dep.scss", "@import \"dep2\";\n@warn \"from dep\";\n");
    write(&dir, "lp/_dep2.scss", "e { f: 2; }\n");
    let all = sasso(&dir, &["-I", "lp", "entry.scss"]);
    assert_eq!(all.code, 0, "{}", all.stderr);
    assert_eq!(
        all.stderr.matches("DEPRECATION WARNING [import]").count(),
        2,
        "{}",
        all.stderr
    );
    let quiet_deps = sasso(&dir, &["--quiet-deps", "-I", "lp", "entry.scss"]);
    assert_eq!(quiet_deps.code, 0, "{}", quiet_deps.stderr);
    // The entry's own deprecation stays; the dependency's goes; @warn from
    // both stays (dart: only COMPILER warnings from dependencies are silenced).
    assert_eq!(
        quiet_deps.stderr.matches("DEPRECATION WARNING [import]").count(),
        1,
        "{}",
        quiet_deps.stderr
    );
    assert!(
        quiet_deps.stderr.contains("entry.scss 1:9"),
        "the remaining deprecation is the entry's: {}",
        quiet_deps.stderr
    );
    assert!(
        quiet_deps.stderr.contains("WARNING: from dep"),
        "{}",
        quiet_deps.stderr
    );
    assert!(
        quiet_deps.stderr.contains("WARNING: from entry"),
        "{}",
        quiet_deps.stderr
    );
    // dart's rule is about how a file was RESOLVED, not where it lives: a
    // relative `@use "lp/…"` from the entry is not a dependency even though
    // the file sits in the load-path directory, so its deprecation prints.
    write(&dir, "rel.scss", "@use \"lp/rel-dep\";\n");
    write(&dir, "lp/_rel-dep.scss", "@import \"dep2\";\n");
    let rel = sasso(&dir, &["--quiet-deps", "-I", "lp", "rel.scss"]);
    assert_eq!(rel.code, 0, "{}", rel.stderr);
    assert_eq!(
        rel.stderr.matches("DEPRECATION WARNING [import]").count(),
        1,
        "a relatively-resolved file is not a dependency: {}",
        rel.stderr
    );
    // Nor is the entry itself, even inside the load path.
    write(&dir, "lp/main.scss", "@import \"dep2\";\n");
    let inside = sasso(&dir, &["--quiet-deps", "-I", "lp", "lp/main.scss"]);
    assert_eq!(inside.code, 0, "{}", inside.stderr);
    assert_eq!(
        inside.stderr.matches("DEPRECATION WARNING [import]").count(),
        1,
        "{}",
        inside.stderr
    );
    std::fs::remove_dir_all(&dir).ok();
}

// ---------------------------------------------------------------------------
// Misc flags
// ---------------------------------------------------------------------------

#[test]
fn quiet_deps_leaves_no_repetition_footer() {
    // The compiler caps repeated deprecations at five per id and reports the
    // rest as "N repetitive deprecation warnings omitted". Under --quiet-deps
    // a dependency's deprecations are dropped BEFORE that count (dart applies
    // quietDeps ahead of its repetition logger), so nothing surfaces.
    let dir = scratch("quiet_deps_footer");
    let mut dep = String::new();
    for i in 1..=8 {
        dep.push_str(&format!("@import \"leaf{i}\";\n"));
        write(
            &dir,
            &format!("lp/_leaf{i}.scss"),
            &format!("l{i} {{ m: {i}; }}\n"),
        );
    }
    write(&dir, "lp/_dep.scss", &dep);
    write(&dir, "entry.scss", "@use \"dep\";\n");
    let loud = sasso(&dir, &["--no-source-map", "-I", "lp", "entry.scss"]);
    assert_eq!(loud.code, 0, "{}", loud.stderr);
    assert!(
        loud.stderr.contains("repetitive deprecation warnings omitted"),
        "{}",
        loud.stderr
    );
    let quiet = sasso(
        &dir,
        &["--no-source-map", "--quiet-deps", "-I", "lp", "entry.scss"],
    );
    assert_eq!(quiet.code, 0, "{}", quiet.stderr);
    assert_eq!(quiet.stderr, "", "no deprecations and no footer");
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn compat_flags_and_no_css() {
    let dir = scratch("misc");
    write(&dir, "u.scss", "a { content: \"é\" }\n");
    let r = sasso(&dir, &["--no-color", "-c", "u.scss"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert!(r.stdout.starts_with("@charset \"UTF-8\";\n"), "{}", r.stdout);
    let r = sasso(&dir, &["--no-charset", "u.scss"]);
    assert_eq!(r.code, 0);
    assert!(
        r.stdout.starts_with("a {"),
        "--no-charset drops the @charset: {}",
        r.stdout
    );
    let r = sasso(&dir, &["--no-css", "u.scss"]);
    assert_eq!(r.code, 0);
    assert_eq!(r.stdout, "", "--no-css compiles but prints nothing");
    let r = sasso(&dir, &["--no-css", "u.scss", "u.css"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert!(
        !dir.join("u.css").exists() && !dir.join("u.css.map").exists(),
        "--no-css writes no files either"
    );
    let r = sasso(&dir, &["--no-css", "u.scss:pair.css"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert!(!dir.join("pair.css").exists());
    let r = sasso(&dir, &["--no-css", "--loop", "2", "u.scss"]);
    assert_eq!(r.code, 0);
    assert_eq!(r.stdout, "");
    assert!(r.stderr.contains("2 compiles in"), "{}", r.stderr);
    let r = sasso(&dir, &["--loop", "2", "u.scss:out.css"]);
    assert_eq!(r.code, EXIT_USAGE, "--loop is stdout-only");
    let r = sasso(&dir, &["--loop", "2", "--embed-source-map", "u.scss"]);
    assert_eq!(r.code, EXIT_USAGE, "--loop has no source-map mode");
    assert!(
        r.stderr.contains("--loop does not generate source maps"),
        "{}",
        r.stderr
    );
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn pair_with_a_second_colon_is_a_usage_error() {
    let dir = scratch("two_colons");
    write(&dir, "a.scss", GOOD);
    let r = sasso(&dir, &["--no-source-map", "a.scss:out.css:wut"]);
    assert_eq!(r.code, EXIT_USAGE);
    assert!(
        r.stderr
            .contains("\"a.scss:out.css:wut\" may only contain one \":\"."),
        "{}",
        r.stderr
    );
    assert!(!dir.join("out.css:wut").exists());
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn bare_directory_positional_compiles_in_place() {
    // dart: `sass dir` is `dir:dir`; a directory with an output, or as the
    // output, "may not be a positional arg".
    let dir = scratch("dir_positional");
    write(&dir, "src/a.scss", GOOD);
    write(&dir, "src/sub/b.scss", "b { c: d }\n");
    write(&dir, "src/_p.scss", "$x: 1;\n");
    let r = sasso(&dir, &["--no-source-map", "src"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(r.stdout, "");
    assert_eq!(read(&dir, "src/a.css"), GOOD_CSS);
    assert_eq!(read(&dir, "src/sub/b.css"), "b {\n  c: d;\n}\n");
    assert!(!dir.join("src/_p.css").exists());
    let r = sasso(&dir, &["--no-source-map", "src", "out"]);
    assert_eq!(r.code, EXIT_USAGE);
    assert!(
        r.stderr
            .contains("Directory \"src\" may not be a positional arg."),
        "{}",
        r.stderr
    );
    std::fs::create_dir_all(dir.join("od")).unwrap();
    let r = sasso(&dir, &["--no-source-map", "src/a.scss", "od"]);
    assert_eq!(r.code, EXIT_USAGE);
    assert!(
        r.stderr.contains("Directory \"od\" may not be a positional arg."),
        "{}",
        r.stderr
    );
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn diagnostics_of_consecutive_units_are_separated_by_a_blank_line() {
    let dir = scratch("separators");
    // Two unreadable inputs: dart prints the two lines with a blank line between.
    let r = sasso(
        &dir,
        &["-j", "1", "--no-source-map", "n1.scss:o1.css", "n2.scss:o2.css"],
    );
    assert_eq!(r.code, EXIT_IO);
    assert_eq!(
        r.stderr,
        "Error reading n1.scss: Cannot open file.\n\nError reading n2.scss: Cannot open file.\n"
    );
    // Two compile errors: one blank line between, none trailing.
    write(&dir, "bad1.scss", BAD);
    write(&dir, "bad2.scss", "c { d: $y }\n");
    let r = sasso(
        &dir,
        &[
            "-j",
            "1",
            "--no-source-map",
            "--no-error-css",
            "bad1.scss:b1.css",
            "bad2.scss:b2.css",
        ],
    );
    assert_eq!(r.code, EXIT_COMPILE);
    assert_eq!(
        r.stderr.matches("\n\nError: Undefined variable.").count(),
        1,
        "{}",
        r.stderr
    );
    assert!(
        r.stderr.ends_with("root stylesheet\n") && !r.stderr.ends_with("\n\n"),
        "{}",
        r.stderr
    );
    // A warning block already ends in a blank line: no extra one is added.
    write(&dir, "warn.scss", "@warn \"hi\";\nz { y: 1 }\n");
    let r = sasso(
        &dir,
        &[
            "-j",
            "1",
            "--no-source-map",
            "--no-error-css",
            "warn.scss:w.css",
            "bad1.scss:b1.css",
        ],
    );
    assert_eq!(r.code, EXIT_COMPILE);
    assert!(
        r.stderr.contains("root stylesheet\n\nError: Undefined variable."),
        "{}",
        r.stderr
    );
    assert!(!r.stderr.contains("\n\n\n"), "{}", r.stderr);
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn invalid_utf8_on_stdin_fails_like_a_file() {
    // dart crashes on invalid UTF-8 from stdin (exit 255, nothing written);
    // sasso treats it as the compile error it is, with the same error-CSS and
    // stale-output handling a file input gets.
    let dir = scratch("stdin_utf8");
    let bad: &[u8] = b"a { b: c }\n\xff\xfe\n";
    let r = run_bin_bytes(BIN, &dir, &["--no-source-map", "--stdin", "out.css"], Some(bad));
    assert_eq!(r.code, EXIT_COMPILE);
    assert_eq!(r.stderr, "Error: Invalid UTF-8.\n");
    assert!(
        read(&dir, "out.css").starts_with("/* Error: Invalid UTF-8. */"),
        "error stylesheet for a file target"
    );
    write(&dir, "stale.css", "old { css: yes }\n");
    let r = run_bin_bytes(
        BIN,
        &dir,
        &["--no-source-map", "--no-error-css", "-:stale.css"],
        Some(bad),
    );
    assert_eq!(r.code, EXIT_COMPILE);
    assert!(
        !dir.join("stale.css").exists(),
        "stale CSS removed like any compile error"
    );
    let r = run_bin_bytes(BIN, &dir, &["--no-source-map", "-"], Some(bad));
    assert_eq!(r.code, EXIT_COMPILE);
    assert_eq!(r.stdout, "");
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn bare_directory_is_file_output_for_flag_validation() {
    // `sasso --source-map dir` etc. are file-output invocations (dart accepts
    // them all); `--loop dir` is not stdout-only and is rejected.
    let dir = scratch("dir_flags");
    write(&dir, "src/a.scss", GOOD);
    for args in [
        vec!["--source-map", "src"],
        vec!["--embed-sources", "src"],
        vec!["--source-map-urls=absolute", "src"],
        vec!["--embed-source-map", "src"],
    ] {
        std::fs::remove_file(dir.join("src/a.css")).ok();
        std::fs::remove_file(dir.join("src/a.css.map")).ok();
        let r = sasso(&dir, &args);
        assert_eq!(r.code, 0, "{args:?}: {}", r.stderr);
        assert!(read(&dir, "src/a.css").contains("sourceMappingURL="), "{args:?}");
    }
    let r = sasso(&dir, &["--loop", "2", "src"]);
    assert_eq!(r.code, EXIT_USAGE, "{}", r.stderr);
    assert!(
        r.stderr.contains("--loop compiles to stdout only"),
        "{}",
        r.stderr
    );
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn double_dash_ends_option_parsing() {
    // dart's argument parser honours `--`: what follows is operands, so an
    // input or output whose name starts with `-` can be named. Pairs and the
    // stdin `-` keep their meaning after it.
    let dir = scratch("double_dash");
    write(&dir, "--theme.scss", GOOD);
    write(&dir, "-dash.scss", "q { r: 1 }\n");
    let r = sasso(&dir, &["--no-source-map", "--", "--theme.scss"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(r.stdout, GOOD_CSS);
    let r = sasso(&dir, &["--no-source-map", "--", "-dash.scss:out.css"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(read(&dir, "out.css"), "q {\n  r: 1;\n}\n");
    let r = run_bin(BIN, &dir, &["--no-source-map", "--", "-"], Some("x { y: z }\n"));
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(r.stdout, "x {\n  y: z;\n}\n");
    // An option-looking token after `--` is an operand: here the output file.
    let r = sasso(&dir, &["--no-source-map", "--", "--theme.scss", "--out.css"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(read(&dir, "--out.css"), GOOD_CSS);
    // Without `--` such a name is still an unknown option.
    let r = sasso(&dir, &["--no-source-map", "--theme.scss"]);
    assert_eq!(r.code, EXIT_USAGE);
    assert!(r.stderr.contains("unknown option --theme.scss"), "{}", r.stderr);
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn source_map_file_and_footer_are_url_encoded() {
    // The map's `file` and the footer's `sourceMappingURL` are URLs: dart
    // percent-encodes the output basename (space, `#`, `%`).
    let dir = scratch("url_encoded_names");
    write(&dir, "in.scss", GOOD);
    let r = sasso(&dir, &["in.scss", "out file#1.css"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    let css = read(&dir, "out file#1.css");
    assert!(
        css.ends_with("\n\n/*# sourceMappingURL=out%20file%231.css.map */\n"),
        "{css}"
    );
    let map = read(&dir, "out file#1.css.map");
    assert!(map.ends_with(",\"file\":\"out%20file%231.css\"}"), "{map}");
    let r = sasso(&dir, &["in.scss", "out%20x.css"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert!(
        read(&dir, "out%20x.css").contains("sourceMappingURL=out%2520x.css.map */"),
        "a literal % is encoded"
    );
    assert!(read(&dir, "out%20x.css.map").ends_with(",\"file\":\"out%2520x.css\"}"));
    assert_dart_files_match(
        &[("in.scss", GOOD)],
        &["in.scss", "out file#1.css"],
        &["out file#1.css", "out file#1.css.map"],
    );
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn empty_stylesheet_to_a_file_is_one_newline() {
    // dart always terminates a CSS file with one newline, an empty stylesheet
    // included; stdout gets nothing for empty output.
    let dir = scratch("empty_file");
    write(&dir, "empty.scss", "");
    write(&dir, "comment.scss", "// nothing to emit\n");
    let r = sasso(&dir, &["--no-source-map", "empty.scss", "e1.css"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(read(&dir, "e1.css"), "\n");
    let r = sasso(
        &dir,
        &["--no-source-map", "--style=compressed", "comment.scss:e2.css"],
    );
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(read(&dir, "e2.css"), "\n");
    let r = sasso(&dir, &["empty.scss", "e3.css"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(read(&dir, "e3.css"), "\n\n/*# sourceMappingURL=e3.css.map */\n");
    let r = sasso(&dir, &["--no-source-map", "empty.scss"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(r.stdout, "", "stdout stays empty for empty output");
    assert_dart_files_match(
        &[("empty.scss", "")],
        &["--no-source-map", "empty.scss", "e1.css"],
        &["e1.css"],
    );
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn equivalent_source_spellings_coalesce_to_the_later_destination() {
    // dart keeps sources in a path-keyed map: `a.scss` and `./a.scss` are one
    // source, compiled once, to the destination named last. An exact repeat
    // is still the `Duplicate source` error.
    let dir = scratch("coalesce");
    write(&dir, "a.scss", GOOD);
    std::fs::create_dir_all(dir.join("sub")).unwrap();
    let r = sasso(
        &dir,
        &[
            "--no-source-map",
            "a.scss:o1.css",
            "./a.scss:o2.css",
            "sub/../a.scss:o3.css",
        ],
    );
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert!(
        !dir.join("o1.css").exists() && !dir.join("o2.css").exists(),
        "earlier destinations are not written"
    );
    assert_eq!(read(&dir, "o3.css"), GOOD_CSS);
    let r = sasso(&dir, &["--no-source-map", "a.scss:o4.css", "a.scss:o5.css"]);
    assert_eq!(r.code, EXIT_USAGE);
    assert!(r.stderr.contains("Duplicate source \"a.scss\"."), "{}", r.stderr);
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn extensions_are_matched_case_sensitively_like_dart() {
    // dart's `Syntax.forPath` and `_isEntrypoint` look at exact lowercase
    // suffixes: `input.CSS` parses as SCSS (Sass constructs allowed), and
    // directory mode skips `UPPER.SCSS`.
    let dir = scratch("ext_case");
    write(&dir, "input.CSS", GOOD);
    let r = sasso(&dir, &["--no-source-map", "input.CSS"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(r.stdout, GOOD_CSS);
    write(&dir, "input.SASS", "a\n  b: c\n");
    let r = sasso(&dir, &["--no-source-map", "input.SASS"]);
    assert_eq!(
        r.code, EXIT_COMPILE,
        "indented content parsed as SCSS fails, as in dart: {}",
        r.stderr
    );
    write(&dir, "dir/UPPER.SCSS", GOOD);
    write(&dir, "dir/Mixed.Sass", "q\n  r: 1\n");
    write(&dir, "dir/plain.CSS", "x { y: z }\n");
    write(&dir, "dir/ok.scss", GOOD);
    let r = sasso(&dir, &["--no-source-map", "dir:out"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    let mut produced: Vec<String> = std::fs::read_dir(dir.join("out"))
        .unwrap()
        .map(|e| e.unwrap().file_name().to_string_lossy().into_owned())
        .collect();
    produced.sort();
    assert_eq!(produced, vec!["ok.css".to_string()]);
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn directory_expanded_files_coalesce_with_explicit_pairs() {
    // dart puts expanded files and explicit pairs in one path-keyed map: a
    // file named both ways compiles once, to the destination named last;
    // two spellings of one directory coalesce too; an exact repeat errors.
    let dir = scratch("dir_coalesce");
    write(&dir, "src/a.scss", GOOD);
    write(&dir, "src/b.scss", "q { r: 1 }\n");
    let r = sasso(&dir, &["--no-source-map", "src:out1", "src/a.scss:out2.css"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert!(
        !dir.join("out1/a.css").exists(),
        "a goes to the later destination only"
    );
    assert_eq!(read(&dir, "out2.css"), GOOD_CSS);
    assert!(dir.join("out1/b.css").exists());
    std::fs::remove_dir_all(dir.join("out1")).ok();
    std::fs::remove_file(dir.join("out2.css")).ok();
    let r = sasso(&dir, &["--no-source-map", "src/a.scss:out2.css", "src:out1"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert!(
        !dir.join("out2.css").exists(),
        "the directory expansion came later and wins"
    );
    assert_eq!(read(&dir, "out1/a.css"), GOOD_CSS);
    let r = sasso(&dir, &["--no-source-map", "src:out3", "./src:out4"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert!(!dir.join("out3").exists() && dir.join("out4/a.css").exists());
    let r = sasso(&dir, &["--no-source-map", "src:out5", "src:out6"]);
    assert_eq!(r.code, EXIT_USAGE);
    assert!(r.stderr.contains("Duplicate source \"src\"."), "{}", r.stderr);
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn directory_mode_skips_css_whose_destination_is_itself() {
    // dart: a `.css` inside an in-place directory compile (`sasso dir`, or
    // `dir:dir`) would only be rewritten onto itself, so it is skipped; the
    // same file compiled to ANOTHER directory is processed like any input.
    let dir = scratch("self_css");
    write(&dir, "src/plain.css", "p{q:2}\n");
    write(&dir, "src/x.scss", "x { y: z }\n");
    let r = sasso(&dir, &["--no-source-map", "src"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(read(&dir, "src/plain.css"), "p{q:2}\n", "left untouched");
    assert_eq!(read(&dir, "src/x.css"), "x {\n  y: z;\n}\n");
    let r = sasso(&dir, &["--no-source-map", "src:src"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(read(&dir, "src/plain.css"), "p{q:2}\n");
    let r = sasso(&dir, &["--no-source-map", "src:out"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(
        read(&dir, "out/plain.css"),
        "p {\n  q: 2;\n}\n",
        "to another directory it compiles"
    );
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn directory_mode_skips_sources_inside_a_nested_output() {
    // dart-sass 1.104.1: a many-to-many compile skips every source file that
    // lies INSIDE the output directory when that directory is nested in the
    // source tree — otherwise `.:css` run twice mirrors `css/` into
    // `css/css/`. Measured against dart-sass 1.104.1.
    let dir = scratch("nested_out");
    write(&dir, "one.scss", "a { b: c }\n");
    write(&dir, "css/stale.scss", "d { e: f }\n");
    write(&dir, "css/deep/deeper.scss", "g { h: i }\n");
    let r = sasso(&dir, &["--no-source-map", ".:css"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(read(&dir, "css/one.css"), "a {\n  b: c;\n}\n");
    assert!(
        !dir.join("css/css").exists(),
        "the output tree was mirrored into itself"
    );
    // The DESTINATION is what counts, not an intermediate directory: with the
    // output one level deeper, `css/stale.scss` is still a source.
    let r = sasso(&dir, &["--no-source-map", ".:css/deep"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(read(&dir, "css/deep/css/stale.css"), "d {\n  e: f;\n}\n");
    assert!(
        !dir.join("css/deep/css/deep").exists(),
        "files under the destination are skipped"
    );
    // A destination EQUAL to the source is not nested: an in-place compile
    // still reaches every file.
    let flat = scratch("nested_out_flat");
    write(&flat, "one.scss", "a { b: c }\n");
    write(&flat, "sub/two.scss", "j { k: l }\n");
    let r = sasso(&flat, &["--no-source-map", ".:."]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(read(&flat, "one.css"), "a {\n  b: c;\n}\n");
    assert_eq!(read(&flat, "sub/two.css"), "j {\n  k: l;\n}\n");
    std::fs::remove_dir_all(&dir).ok();
    std::fs::remove_dir_all(&flat).ok();
}

#[test]
fn directory_mode_skips_only_the_output_directory_itself() {
    // The nested-output skip is a DESCENDANT test, not a string prefix: a
    // sibling whose name merely starts with the destination's (`css2` beside
    // `css`) is still a source. Measured against dart-sass 1.104.1.
    let dir = scratch("nested_sibling");
    write(&dir, "one.scss", "a { b: c }\n");
    write(&dir, "css/inside.scss", "d { e: f }\n");
    write(&dir, "css2/sibling.scss", "g { h: i }\n");
    let r = sasso(&dir, &["--no-source-map", ".:css"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(read(&dir, "css/one.css"), "a {\n  b: c;\n}\n");
    assert_eq!(read(&dir, "css/css2/sibling.css"), "g {\n  h: i;\n}\n");
    assert!(
        !dir.join("css/css").exists(),
        "the output directory itself is still skipped"
    );
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn source_map_sources_name_imported_files_by_path() {
    // dart writes each imported file's path relative to the map, so two
    // partials sharing a basename are two sources; an entry that emits nothing
    // of its own is not listed; a stylesheet with no output has `[]`.
    let dir = scratch("sm_sources");
    write(&dir, "src/sub/_p.scss", "a{b:1}\n");
    write(&dir, "src/other/_p.scss", "c{d:2}\n");
    write(&dir, "src/two.scss", "@import \"sub/p\";\n@import \"other/p\";\n");
    let r = sasso(&dir, &["-q", "src/two.scss", "out/two.css"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(
        read(&dir, "out/two.css.map"),
        "{\"version\":3,\"sourceRoot\":\"\",\"sources\":[\"../src/sub/_p.scss\",\"../src/other/_p.scss\"],\"names\":[],\"mappings\":\"AAAA;EAAE;;;ACAF;EAAE\",\"file\":\"two.css\"}"
    );
    let r = sasso(&dir, &["-q", "--embed-sources", "src/two.scss", "out2/two.css"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert!(
        read(&dir, "out2/two.css.map").ends_with(",\"sourcesContent\":[\"a{b:1}\\n\",\"c{d:2}\\n\"]}"),
        "{}",
        read(&dir, "out2/two.css.map")
    );
    write(&dir, "empty.scss", "");
    let r = sasso(&dir, &["empty.scss", "out/e.css"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert!(
        read(&dir, "out/e.css.map").contains("\"sources\":[],"),
        "{}",
        read(&dir, "out/e.css.map")
    );
    assert_dart_files_match(
        &[
            ("src/sub/_p.scss", "a{b:1}\n"),
            ("src/other/_p.scss", "c{d:2}\n"),
            ("src/two.scss", "@import \"sub/p\";\n@import \"other/p\";\n"),
        ],
        &["-q", "--embed-sources", "src/two.scss", "out/two.css"],
        &["out/two.css", "out/two.css.map"],
    );
    assert_dart_files_match(
        &[("empty.scss", "")],
        &["empty.scss", "out/e.css"],
        &["out/e.css", "out/e.css.map"],
    );
    std::fs::remove_dir_all(&dir).ok();
}

/// The `WARNING:` blocks of a stderr transcript (each with its stack frames),
/// leaving out deprecation warnings — for assertions that are about the
/// frames of runtime warnings only.
fn warning_blocks(stderr: &str) -> Vec<&str> {
    stderr
        .split("\n\n")
        .filter(|block| block.starts_with("WARNING:"))
        .collect()
}

/// The `Error:` block of a stderr transcript: from the last `Error:` header
/// to the end (what a failing compile prints after any warnings).
fn error_block(stderr: &str) -> &str {
    match stderr.rfind("\nError: ") {
        Some(i) => &stderr[i + 1..],
        None => stderr,
    }
}

/// A POSIX-spelled expectation with every named FRAME path respelled the way the
/// platform does: dart renders each one through `p.prettyUri`, so on Windows it
/// is `\`-separated. That is true of the entry stylesheet's frame as much as a
/// loaded file's (#151) — the command line's spelling does not survive into a
/// diagnostic — but NOT of a source-map url, which is `/` on every platform, so
/// the paths are listed rather than replaced blanket.
///
/// `\` and `/` are the same width, so the frames' column alignment is unchanged
/// and one expectation serves both platforms.
fn with_frame_paths(expected: &str, frames: &[&str]) -> String {
    let mut out = expected.to_string();
    if cfg!(windows) {
        for p in frames {
            out = out.replace(p, &p.replace('/', "\\"));
        }
    }
    out
}

/// What part of stderr to compare with dart-sass.
#[derive(Clone, Copy)]
enum Compare {
    /// Byte for byte.
    Full,
    /// Only the final `Error:` block (see [`error_block`]).
    Error,
}

/// Run the same `args` through dart-sass in a sibling scratch dir seeded with
/// the same `files` and assert stderr matches, as far as `what` says.
fn assert_dart_stderr_matches(files: &[(&str, &str)], args: &[&str], what: Compare) {
    let Some(dart) = dart_bin() else { return };
    let ours = scratch("parity_err_ours");
    let theirs = scratch("parity_err_theirs");
    for (name, text) in files {
        write(&ours, name, text);
        write(&theirs, name, text);
    }
    let a = sasso(&ours, args);
    let b = run_bin(&dart, &theirs, args, None);
    assert_eq!(
        a.code, b.code,
        "exit codes differ for {args:?}\nours: {}\ndart: {}",
        a.stderr, b.stderr
    );
    match what {
        Compare::Full => assert_eq!(a.stderr, b.stderr, "stderr differs from dart-sass for {args:?}"),
        Compare::Error => assert_eq!(
            error_block(&a.stderr),
            error_block(&b.stderr),
            "error block differs from dart-sass for {args:?}"
        ),
    }
    std::fs::remove_dir_all(&ours).ok();
    std::fs::remove_dir_all(&theirs).ok();
}

#[test]
fn stack_frames_show_loaded_files_relative_to_the_working_directory() {
    // dart's frames spell a loaded file as its path from the current
    // directory, whether it was reached relatively (`src/sub/_warnme.scss`)
    // or through a load path (`lp/_dep.scss`, and `lp/_leaf.scss` which that
    // file loads) — and the entry by the same rule, not as it was typed
    // (#151, and see `the_entry_frame_is_spelled_as_dart_spells_it`). Same
    // for `@use` and `@import`.
    let used: &[(&str, &str)] = &[
        ("src/sub/_warnme.scss", "@warn \"a\";\n"),
        ("lp/_dep.scss", "@use \"leaf\";\n@warn \"b\";\n"),
        ("lp/_leaf.scss", "@warn \"d\";\n"),
        ("src/rel.scss", "@use \"sub/warnme\";\n@use \"dep\";\n"),
    ];
    let dir = scratch("frames_use");
    for (name, text) in used {
        write(&dir, name, text);
    }
    let r = sasso(&dir, &["--no-source-map", "-I", "lp", "src/rel.scss"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(
        r.stderr,
        with_frame_paths(
            "WARNING: a\n    src/sub/_warnme.scss 1:1  @use\n    src/rel.scss 1:1          root stylesheet\n\n\
             WARNING: d\n    lp/_leaf.scss 1:1  @use\n    lp/_dep.scss 1:1   @use\n    src/rel.scss 2:1   root stylesheet\n\n\
             WARNING: b\n    lp/_dep.scss 2:1  @use\n    src/rel.scss 2:1  root stylesheet\n\n",
            &["src/sub/_warnme.scss", "lp/_leaf.scss", "lp/_dep.scss", "src/rel.scss"],
        )
    );
    assert_dart_stderr_matches(
        used,
        &["--no-source-map", "-I", "lp", "src/rel.scss"],
        Compare::Full,
    );
    std::fs::remove_dir_all(&dir).ok();

    let imported: &[(&str, &str)] = &[
        ("src/sub/_warnme.scss", "@warn \"a\";\n"),
        ("lp/_dep.scss", "@warn \"b\";\n@import \"leaf\";\n"),
        ("lp/_leaf.scss", "@warn \"d\";\n"),
        ("src/rel.scss", "@import \"sub/warnme\";\n@import \"dep\";\n"),
    ];
    let dir = scratch("frames_import");
    for (name, text) in imported {
        write(&dir, name, text);
    }
    let r = sasso(&dir, &["--no-source-map", "-I", "lp", "src/rel.scss"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(
        warning_blocks(&r.stderr),
        [
            "WARNING: a\n    src/sub/_warnme.scss 1:1  @import\n    src/rel.scss 1:9          root stylesheet",
            "WARNING: b\n    lp/_dep.scss 1:1  @import\n    src/rel.scss 2:9  root stylesheet",
            "WARNING: d\n    lp/_leaf.scss 1:1  @import\n    lp/_dep.scss 2:9   @import\n    src/rel.scss 2:9   root stylesheet",
        ]
        .map(|b| with_frame_paths(b, &["src/sub/_warnme.scss", "lp/_leaf.scss", "lp/_dep.scss", "src/rel.scss"]))
    );
    assert_dart_stderr_matches(
        imported,
        &["--no-source-map", "-I", "lp", "src/rel.scss"],
        Compare::Full,
    );
    std::fs::remove_dir_all(&dir).ok();
}

/// A scratch directory as the compiled process will see its own working
/// directory: `getcwd` resolves symlinks, so an argument built from
/// `std::env::temp_dir()` (`/tmp` -> `/private/tmp`, `/var` -> `/private/var`
/// on macOS) names the same file by a path that shares no prefix with the cwd —
/// which relativises to an absolute path and hides whatever the test meant to
/// assert. Windows' verbatim prefix is dropped: `canonicalize` adds one,
/// nothing a user types has it, and it is not part of a root's identity.
///
/// `\\?\UNC\server\share` is unwrapped to `\\server\share` rather than cut at
/// the prefix, which would leave a RELATIVE `UNC\server\share` — the same
/// silent nothing-is-asserted failure this helper exists to prevent, for a
/// scratch directory that lives on a share.
fn resolved(dir: &Path) -> PathBuf {
    let real = std::fs::canonicalize(dir).expect("canonicalize scratch dir");
    let unwrapped = without_verbatim_prefix(&real.to_string_lossy());
    unwrapped.map_or(real, PathBuf::from)
}

/// `\\?\C:\x` -> `C:\x`, `\\?\UNC\server\share\x` -> `\\server\share\x`, and
/// `None` when there is no wrapper to remove — which is every path on a POSIX
/// host, where the original is kept byte for byte.
fn without_verbatim_prefix(p: &str) -> Option<String> {
    match p.strip_prefix(r"\\?\UNC\") {
        Some(share) => Some(format!(r"\\{share}")),
        None => p.strip_prefix(r"\\?\").map(str::to_string),
    }
}

/// The Windows-only half of [`resolved`], which a POSIX run would never reach:
/// the UNC form is not a `\\?\` with a usable path behind it, so cutting the
/// four characters off leaves something relative.
#[test]
fn a_verbatim_prefix_unwraps_to_a_path_that_is_still_absolute() {
    assert_eq!(
        without_verbatim_prefix(r"\\?\C:\Users\you\scratch").as_deref(),
        Some(r"C:\Users\you\scratch")
    );
    assert_eq!(
        without_verbatim_prefix(r"\\?\UNC\nas\share\scratch").as_deref(),
        Some(r"\\nas\share\scratch")
    );
    // Nothing to unwrap: the caller keeps what `canonicalize` gave it.
    assert_eq!(without_verbatim_prefix(r"C:\Users\you\scratch"), None);
    assert_eq!(without_verbatim_prefix("/private/tmp/scratch"), None);
}

#[test]
fn the_entry_frame_is_spelled_as_dart_spells_it() {
    // dart renders EVERY frame through `p.prettyUri` — the entry stylesheet's
    // included — so the spelling on the command line does not reach the
    // transcript: a `./` prefix, a doubled separator, a `..` hop and an
    // absolute path all report the same normalized path from the working
    // directory. sasso used to echo the argument verbatim (#151), which also
    // left the entry `/`-separated on Windows beside `\`-separated
    // dependencies — one warning block, two spellings.
    let files: &[(&str, &str)] = &[
        ("src/_dep.scss", "@warn \"dep\";\n"),
        ("src/entry.scss", "@use \"dep\";\n"),
    ];
    let dir = scratch("entry_spelling");
    for (name, text) in files {
        write(&dir, name, text);
    }
    let dir = resolved(&dir);
    let expected = with_frame_paths(
        "WARNING: dep\n    src/_dep.scss 1:1   @use\n    src/entry.scss 1:1  root stylesheet\n\n",
        &["src/_dep.scss", "src/entry.scss"],
    );
    // Every one of these names the same file from the same directory.
    let typed = [
        "src/entry.scss",
        "./src/entry.scss",
        "src//entry.scss",
        "src/../src/entry.scss",
    ];
    for arg in typed {
        let r = sasso(&dir, &["--no-source-map", arg]);
        assert_eq!(r.code, 0, "{}", r.stderr);
        assert_eq!(r.stderr, expected, "entry spelled {arg:?}");
    }
    // An absolute argument, from the directory that contains it.
    let abs = dir.join("src").join("entry.scss");
    let abs = abs.to_string_lossy().into_owned();
    let r = sasso(&dir, &["--no-source-map", &abs]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(r.stderr, expected, "entry spelled absolutely");
    // And from a sibling directory below it, where the relative spelling of
    // both frames walks up.
    std::fs::create_dir_all(dir.join("out")).expect("mkdir out");
    let r = sasso(&dir.join("out"), &["--no-source-map", &abs]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(
        r.stderr,
        with_frame_paths(
            "WARNING: dep\n    ../src/_dep.scss 1:1   @use\n    ../src/entry.scss 1:1  root stylesheet\n\n",
            &["../src/_dep.scss", "../src/entry.scss"],
        )
    );
    // A directory pair: the entry is not typed at all, it comes out of the
    // walk, and `./src` must not survive into the frame either.
    let r = sasso(&dir, &["--no-source-map", "./src:out"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(r.stderr, expected, "entry from a directory pair");
    for arg in typed {
        assert_dart_stderr_matches(files, &["--no-source-map", arg], Compare::Full);
    }
    assert_dart_stderr_matches(files, &["--no-source-map", "./src:out"], Compare::Full);
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn quiet_deps_survives_a_compile_error_with_error_css() {
    // `--quiet-deps` hands the compiler a `DependencySet` whose mutex used to
    // be allocated lazily on first lock — inside the compile's bump arena, which
    // the compile reset on the way out. The error-CSS re-render (a second
    // compile in the same process) then locked freed memory and aborted with
    // "failed to lock mutex" instead of reporting the error.
    let dir = scratch("quietdeps_err");
    write(&dir, "in.scss", BAD);
    let r = sasso(&dir, &["--quiet-deps", "in.scss", "out.css"]);
    assert_eq!(r.code, EXIT_COMPILE, "{}", r.stderr);
    assert!(
        r.stderr.starts_with("Error: Undefined variable.\n"),
        "{}",
        r.stderr
    );
    assert!(!r.stderr.contains("panicked"), "{}", r.stderr);
    assert!(read(&dir, "out.css").starts_with("/* Error: Undefined variable."));
    // The same with a recorded dependency in the set: the entry loads a
    // load-path file, which then fails.
    write(&dir, "lp/_dep.scss", "b { c: $y }\n");
    write(&dir, "usedep.scss", "@use \"dep\";\n");
    let r = sasso(&dir, &["--quiet-deps", "-I", "lp", "usedep.scss", "dep.css"]);
    assert_eq!(r.code, EXIT_COMPILE, "{}", r.stderr);
    assert!(
        r.stderr.starts_with("Error: Undefined variable.\n"),
        "{}",
        r.stderr
    );
    assert!(
        r.stderr
            .contains(&with_frame_paths("lp/_dep.scss 1:8  @use\n", &["lp/_dep.scss"])),
        "{}",
        r.stderr
    );
    assert!(read(&dir, "dep.css").starts_with("/* Error: Undefined variable."));
    // And several units in one process, the failing one first.
    write(&dir, "good.scss", GOOD);
    let r = sasso(
        &dir,
        &["--quiet-deps", "-j", "1", "in.scss:o1.css", "good.scss:o2.css"],
    );
    assert_eq!(r.code, EXIT_COMPILE, "{}", r.stderr);
    assert!(!r.stderr.contains("panicked"), "{}", r.stderr);
    assert_eq!(
        read(&dir, "o2.css"),
        format!("{GOOD_CSS}\n/*# sourceMappingURL=o2.css.map */\n")
    );
    std::fs::remove_dir_all(&dir).ok();
}

const ORIGIN_DEP: &str = "@mixin m {\n  x: 1;\n  @content;\n  z: 3;\n}\n@function f($v) {\n  @warn \"in f\";\n  @return $v + 1;\n}\n@mixin undef {\n  q: $nope;\n}\n";

#[test]
fn callables_and_content_blocks_run_against_their_defining_file() {
    // dart evaluates a mixin, function, or `@content` block where it was
    // written: the frames name that file (with dart's `@content` member for
    // the block and the `@content;` statement as a call site in the mixin),
    // the source map points into it, and an error inside it renders its
    // source. `@use` here, so stderr has no deprecations and compares whole.
    let used: &[(&str, &str)] = &[
        ("src/_dep.scss", ORIGIN_DEP),
        ("src/use.scss", "@use \"dep\";\n@mixin e {\n  @warn \"in e\";\n  y: 2;\n}\na {\n  @include dep.m {\n    @warn \"in content\";\n    y: dep.f(1);\n  }\n}\n"),
    ];
    let dir = scratch("origin_use");
    for (name, text) in used {
        write(&dir, name, text);
    }
    let r = sasso(&dir, &["src/use.scss", "use.css"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(
        r.stderr,
        with_frame_paths(
            "WARNING: in content\n    src/use.scss 8:5   @content\n    src/_dep.scss 3:3  m()\n    src/use.scss 7:3   root stylesheet\n\n\
             WARNING: in f\n    src/_dep.scss 7:3  f()\n    src/use.scss 9:8   @content\n    src/_dep.scss 3:3  m()\n    src/use.scss 7:3   root stylesheet\n\n",
            &["src/_dep.scss", "src/use.scss"],
        )
    );
    assert_eq!(
        read(&dir, "use.css"),
        "a {\n  x: 1;\n  y: 2;\n  z: 3;\n}\n\n/*# sourceMappingURL=use.css.map */\n"
    );
    assert_eq!(
        read(&dir, "use.css.map"),
        "{\"version\":3,\"sourceRoot\":\"\",\"sources\":[\"src/use.scss\",\"src/_dep.scss\"],\"names\":[],\"mappings\":\"AAKA;ECJE;EDOE;ECLF\",\"file\":\"use.css\"}"
    );
    assert_dart_stderr_matches(used, &["src/use.scss", "use.css"], Compare::Full);
    assert_dart_files_match(used, &["src/use.scss", "use.css"], &["use.css", "use.css.map"]);
    std::fs::remove_dir_all(&dir).ok();

    // The same through a textual `@import`: a mixin the import defined is
    // still evaluated in ITS file.
    let imported: &[(&str, &str)] = &[
        ("src/_dep.scss", ORIGIN_DEP),
        (
            "src/imp.scss",
            "@import \"dep\";\na {\n  @include m {\n    @warn \"in content\";\n    y: f(1);\n  }\n}\n",
        ),
    ];
    let dir = scratch("origin_import");
    for (name, text) in imported {
        write(&dir, name, text);
    }
    let r = sasso(&dir, &["src/imp.scss", "imp.css"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(
        warning_blocks(&r.stderr),
        ["WARNING: in content\n    src/imp.scss 4:5   @content\n    src/_dep.scss 3:3  m()\n    src/imp.scss 3:3   root stylesheet",
         "WARNING: in f\n    src/_dep.scss 7:3  f()\n    src/imp.scss 5:8   @content\n    src/_dep.scss 3:3  m()\n    src/imp.scss 3:3   root stylesheet"]
            .map(|b| with_frame_paths(b, &["src/_dep.scss", "src/imp.scss"]))
    );
    assert_eq!(
        read(&dir, "imp.css.map"),
        "{\"version\":3,\"sourceRoot\":\"\",\"sources\":[\"src/imp.scss\",\"src/_dep.scss\"],\"names\":[],\"mappings\":\"AACA;ECAE;EDGE;ECDF\",\"file\":\"imp.css\"}"
    );
    assert_dart_stderr_matches(imported, &["src/imp.scss", "imp.css"], Compare::Full);
    assert_dart_files_match(
        imported,
        &["src/imp.scss", "imp.css"],
        &["imp.css", "imp.css.map"],
    );
    std::fs::remove_dir_all(&dir).ok();

    // An error inside an imported mixin: the snippet is the mixin's file.
    let failing: &[(&str, &str)] = &[
        ("src/_dep.scss", ORIGIN_DEP),
        ("src/undef.scss", "@import \"dep\";\na {\n  @include undef;\n}\n"),
    ];
    let dir = scratch("origin_error");
    for (name, text) in failing {
        write(&dir, name, text);
    }
    let r = sasso(&dir, &["--no-source-map", "src/undef.scss", "undef.css"]);
    assert_eq!(r.code, EXIT_COMPILE, "{}", r.stderr);
    assert_eq!(
        error_block(&r.stderr),
        with_frame_paths(
            "Error: Undefined variable.\n   ╷\n11 │   q: $nope;\n   │      ^^^^^\n   ╵\n  src/_dep.scss 11:6  undef()\n  src/undef.scss 3:3  root stylesheet\n",
            &["src/_dep.scss", "src/undef.scss"],
        )
    );
    assert!(read(&dir, "undef.css").contains(&with_frame_paths(
        " *   src/_dep.scss 11:6  undef()\n",
        &["src/_dep.scss"]
    )));
    assert_dart_stderr_matches(
        failing,
        &["--no-source-map", "src/undef.scss", "undef.css"],
        Compare::Error,
    );
    assert_dart_files_match(
        failing,
        &["--no-source-map", "src/undef.scss", "undef.css"],
        &["undef.css"],
    );
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn first_class_callables_are_traced_like_direct_ones() {
    // `meta.apply` and `meta.call`: frames inside the body name the callable
    // (`m()`, `f()`), the `meta.call(...)` expression is a call site, and the
    // content block goes back to the includer's file — as dart prints them.
    let files: &[(&str, &str)] = &[
        ("src/_dep.scss", ORIGIN_DEP),
        ("src/apply.scss", "@use \"sass:meta\";\n@use \"dep\";\na {\n  @include meta.apply(meta.get-mixin(\"m\", \"dep\")) {\n    @warn \"apply content\";\n    y: 2;\n  }\n  b: meta.call(meta.get-function(\"f\", $module: \"dep\"), 1);\n}\n"),
    ];
    let dir = scratch("origin_apply");
    for (name, text) in files {
        write(&dir, name, text);
    }
    let r = sasso(&dir, &["src/apply.scss", "apply.css"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(
        r.stderr,
        with_frame_paths(
            "WARNING: apply content\n    src/apply.scss 5:5  @content\n    src/_dep.scss 3:3   m()\n    src/apply.scss 4:3  root stylesheet\n\n\
             WARNING: in f\n    src/_dep.scss 7:3   f()\n    src/apply.scss 8:6  root stylesheet\n\n",
            &["src/_dep.scss", "src/apply.scss"],
        )
    );
    assert_eq!(
        read(&dir, "apply.css.map"),
        "{\"version\":3,\"sourceRoot\":\"\",\"sources\":[\"src/apply.scss\",\"src/_dep.scss\"],\"names\":[],\"mappings\":\"AAEA;ECDE;EDIE;ECFF;EDIA\",\"file\":\"apply.css\"}"
    );
    assert_dart_stderr_matches(files, &["src/apply.scss", "apply.css"], Compare::Full);
    assert_dart_files_match(
        files,
        &["src/apply.scss", "apply.css"],
        &["apply.css", "apply.css.map"],
    );
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn error_inside_a_meta_call_highlights_the_call_expression() {
    // An `@error` attaches at the nearest call boundary; for a function
    // invoked through `meta.call` that is the whole `meta.call(...)`
    // expression, as dart highlights it.
    let files: &[(&str, &str)] = &[(
        "call.scss",
        "@use \"sass:meta\";\n@function f($v) {\n  @error \"boom\";\n}\na {\n  b: meta.call(meta.get-function(\"f\"), 1);\n}\n",
    )];
    let dir = scratch("origin_call_error");
    write(&dir, "call.scss", files[0].1);
    let r = sasso(&dir, &["--no-source-map", "call.scss"]);
    assert_eq!(r.code, EXIT_COMPILE, "{}", r.stderr);
    assert_eq!(
        r.stderr,
        "Error: \"boom\"\n  ╷\n6 │   b: meta.call(meta.get-function(\"f\"), 1);\n  │      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n  ╵\n  call.scss 6:6  root stylesheet\n"
    );
    assert_dart_stderr_matches(files, &["--no-source-map", "call.scss"], Compare::Full);
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn error_in_a_content_block_points_at_the_include() {
    // dart runs a content block as a callable invoked from the `@include`
    // that supplied it: an `@error` raised directly in the block carets that
    // `@include` (the name and arguments only — not the block), while the
    // trace still lists the mixin's `@content;` statement as the `m()` frame.
    // Here the mixin lives in another file; the snippet is the includer's.
    let files: &[(&str, &str)] = &[
        ("src/_cm.scss", "@mixin m {\n  x: 1;\n  @content;\n}\n"),
        (
            "src/cerr.scss",
            "@use \"cm\";\na {\n  @include cm.m {\n    @error \"cross\";\n  }\n}\n",
        ),
    ];
    let dir = scratch("origin_content_error");
    for (name, text) in files {
        write(&dir, name, text);
    }
    let r = sasso(&dir, &["--no-source-map", "src/cerr.scss"]);
    assert_eq!(r.code, EXIT_COMPILE, "{}", r.stderr);
    assert_eq!(
        r.stderr,
        with_frame_paths(
            "Error: \"cross\"\n  ╷\n3 │   @include cm.m {\n  │   ^^^^^^^^^^^^^\n  ╵\n  src/_cm.scss 3:3   m()\n  src/cerr.scss 3:3  root stylesheet\n",
            &["src/_cm.scss", "src/cerr.scss"],
        )
    );
    assert_dart_stderr_matches(files, &["--no-source-map", "src/cerr.scss"], Compare::Full);
    std::fs::remove_dir_all(&dir).ok();

    // Forwarded through a second mixin (`@include inner { @content; }`): the
    // boundary is the innermost `@include` whose mixin is running — `@include
    // inner` — and both `@content` invocations stay in the trace.
    let files: &[(&str, &str)] = &[(
        "err.scss",
        "@mixin inner {\n  i: 1;\n  @content;\n}\n@mixin outer {\n  o: 1;\n  @include inner {\n    @content;\n  }\n}\na {\n  @include outer {\n    @error \"deep\";\n  }\n}\n",
    )];
    let dir = scratch("origin_content_forward");
    write(&dir, "err.scss", files[0].1);
    let r = sasso(&dir, &["--no-source-map", "err.scss"]);
    assert_eq!(r.code, EXIT_COMPILE, "{}", r.stderr);
    assert_eq!(
        r.stderr,
        "Error: \"deep\"\n  ╷\n7 │   @include inner {\n  │   ^^^^^^^^^^^^^^\n  ╵\n  err.scss 8:5   @content\n  err.scss 3:3   inner()\n  err.scss 7:3   outer()\n  err.scss 12:3  root stylesheet\n"
    );
    assert_dart_stderr_matches(files, &["--no-source-map", "err.scss"], Compare::Full);
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn members_forwarded_through_an_import_keep_their_defining_file() {
    // `@import "fwd"` where _fwd.scss `@forward`s _dep.scss: the members
    // become the importer's, but their bodies still belong to _dep.scss —
    // frames name it and the map points into it (dart: sources
    // [impfwd.scss, _dep.scss], mappings `AACA;ECCE;EDCA`).
    let files: &[(&str, &str)] = &[
        ("src/_dep.scss", "@mixin m {\n  @warn \"in m\";\n  x: 1;\n}\n@function f($v) {\n  @warn \"in f\";\n  @return $v;\n}\n"),
        ("src/_fwd.scss", "@forward \"dep\";\n"),
        ("src/impfwd.scss", "@import \"fwd\";\na {\n  @include m;\n  b: f(1);\n}\n"),
    ];
    let dir = scratch("origin_import_forward");
    for (name, text) in files {
        write(&dir, name, text);
    }
    let r = sasso(&dir, &["src/impfwd.scss", "impfwd.css"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(
        warning_blocks(&r.stderr),
        [
            "WARNING: in m\n    src/_dep.scss 2:3    m()\n    src/impfwd.scss 3:3  root stylesheet",
            "WARNING: in f\n    src/_dep.scss 6:3    f()\n    src/impfwd.scss 4:6  root stylesheet",
        ]
        .map(|b| with_frame_paths(b, &["src/_dep.scss", "src/impfwd.scss"]))
    );
    assert_eq!(
        read(&dir, "impfwd.css.map"),
        "{\"version\":3,\"sourceRoot\":\"\",\"sources\":[\"src/impfwd.scss\",\"src/_dep.scss\"],\"names\":[],\"mappings\":\"AACA;ECCE;EDCA\",\"file\":\"impfwd.css\"}"
    );
    assert_dart_stderr_matches(files, &["src/impfwd.scss", "impfwd.css"], Compare::Full);
    assert_dart_files_match(
        files,
        &["src/impfwd.scss", "impfwd.css"],
        &["impfwd.css", "impfwd.css.map"],
    );
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn import_deprecations_fire_when_a_file_is_parsed() {
    // dart-sass warns about `@import` while PARSING a file, so all of a file's
    // import deprecations come before anything its body prints — the entry's
    // three (one nested in a style rule) before `WARNING: top`, `_dep.scss`'s
    // one right after its `@import` frame is entered and before `dep top` —
    // and a file the import cache already parsed warns once, however often it
    // is imported (`_dep.scss` twice here). `--quiet-deps` drops the
    // dependency's but keeps the entry's. A `@use`d module's own `@import`
    // warns under the `@use` frame, before the module body runs.
    let files: &[(&str, &str)] = &[
        ("lp/_leaf.scss", "@warn \"leaf\";\nl { m: 1 }\n"),
        ("lp/_dep.scss", "@warn \"dep top\";\n@import \"leaf\";\n@warn \"dep bottom\";\n"),
        ("lp/_x.scss", "x { y: 1 }\n"),
        ("lp/_mod.scss", "@warn \"mod top\";\n@import \"x\";\n@warn \"mod bottom\";\nm { n: 1 }\n"),
        ("src/main.scss", "@warn \"top\";\n@import \"dep\";\n@warn \"middle\";\na {\n  b {\n    @import \"x\";\n  }\n}\n@import \"dep\";\n@warn \"end\";\n"),
        ("src/usemod.scss", "@use \"mod\";\n@warn \"entry\";\n@import \"dep\";\n"),
    ];
    let dir = scratch("import_dep_parse");
    for (name, text) in files {
        write(&dir, name, text);
    }
    // Every frame below names one of these.
    let frames = |s: &str| {
        with_frame_paths(
            s,
            &[
                "lp/_dep.scss",
                "lp/_leaf.scss",
                "lp/_mod.scss",
                "src/main.scss",
                "src/usemod.scss",
            ],
        )
    };
    let r = sasso(&dir, &["--no-source-map", "-I", "lp", "src/main.scss"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(r.stderr, frames("DEPRECATION WARNING [import]: Sass @import rules are deprecated and will be removed in Dart Sass 3.0.0.\n\nMore info and automated migrator: https://sass-lang.com/d/import\n\n  ╷\n2 │ @import \"dep\";\n  │         ^^^^^\n  ╵\n    src/main.scss 2:9  root stylesheet\n\nDEPRECATION WARNING [import]: Sass @import rules are deprecated and will be removed in Dart Sass 3.0.0.\n\nMore info and automated migrator: https://sass-lang.com/d/import\n\n  ╷\n6 │     @import \"x\";\n  │             ^^^\n  ╵\n    src/main.scss 6:13  root stylesheet\n\nDEPRECATION WARNING [import]: Sass @import rules are deprecated and will be removed in Dart Sass 3.0.0.\n\nMore info and automated migrator: https://sass-lang.com/d/import\n\n  ╷\n9 │ @import \"dep\";\n  │         ^^^^^\n  ╵\n    src/main.scss 9:9  root stylesheet\n\nWARNING: top\n    src/main.scss 1:1  root stylesheet\n\nDEPRECATION WARNING [import]: Sass @import rules are deprecated and will be removed in Dart Sass 3.0.0.\n\nMore info and automated migrator: https://sass-lang.com/d/import\n\n  ╷\n2 │ @import \"leaf\";\n  │         ^^^^^^\n  ╵\n    lp/_dep.scss 2:9   @import\n    src/main.scss 2:9  root stylesheet\n\nWARNING: dep top\n    lp/_dep.scss 1:1   @import\n    src/main.scss 2:9  root stylesheet\n\nWARNING: leaf\n    lp/_leaf.scss 1:1  @import\n    lp/_dep.scss 2:9   @import\n    src/main.scss 2:9  root stylesheet\n\nWARNING: dep bottom\n    lp/_dep.scss 3:1   @import\n    src/main.scss 2:9  root stylesheet\n\nWARNING: middle\n    src/main.scss 3:1  root stylesheet\n\nWARNING: dep top\n    lp/_dep.scss 1:1   @import\n    src/main.scss 9:9  root stylesheet\n\nWARNING: leaf\n    lp/_leaf.scss 1:1  @import\n    lp/_dep.scss 2:9   @import\n    src/main.scss 9:9  root stylesheet\n\nWARNING: dep bottom\n    lp/_dep.scss 3:1   @import\n    src/main.scss 9:9  root stylesheet\n\nWARNING: end\n    src/main.scss 10:1  root stylesheet\n\n"));
    assert_eq!(
        r.stdout,
        "l {\n  m: 1;\n}\n\na b x {\n  y: 1;\n}\n\nl {\n  m: 1;\n}\n"
    );
    let r = sasso(
        &dir,
        &["--no-source-map", "-I", "lp", "--quiet-deps", "src/main.scss"],
    );
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(r.stderr, frames("DEPRECATION WARNING [import]: Sass @import rules are deprecated and will be removed in Dart Sass 3.0.0.\n\nMore info and automated migrator: https://sass-lang.com/d/import\n\n  ╷\n2 │ @import \"dep\";\n  │         ^^^^^\n  ╵\n    src/main.scss 2:9  root stylesheet\n\nDEPRECATION WARNING [import]: Sass @import rules are deprecated and will be removed in Dart Sass 3.0.0.\n\nMore info and automated migrator: https://sass-lang.com/d/import\n\n  ╷\n6 │     @import \"x\";\n  │             ^^^\n  ╵\n    src/main.scss 6:13  root stylesheet\n\nDEPRECATION WARNING [import]: Sass @import rules are deprecated and will be removed in Dart Sass 3.0.0.\n\nMore info and automated migrator: https://sass-lang.com/d/import\n\n  ╷\n9 │ @import \"dep\";\n  │         ^^^^^\n  ╵\n    src/main.scss 9:9  root stylesheet\n\nWARNING: top\n    src/main.scss 1:1  root stylesheet\n\nWARNING: dep top\n    lp/_dep.scss 1:1   @import\n    src/main.scss 2:9  root stylesheet\n\nWARNING: leaf\n    lp/_leaf.scss 1:1  @import\n    lp/_dep.scss 2:9   @import\n    src/main.scss 2:9  root stylesheet\n\nWARNING: dep bottom\n    lp/_dep.scss 3:1   @import\n    src/main.scss 2:9  root stylesheet\n\nWARNING: middle\n    src/main.scss 3:1  root stylesheet\n\nWARNING: dep top\n    lp/_dep.scss 1:1   @import\n    src/main.scss 9:9  root stylesheet\n\nWARNING: leaf\n    lp/_leaf.scss 1:1  @import\n    lp/_dep.scss 2:9   @import\n    src/main.scss 9:9  root stylesheet\n\nWARNING: dep bottom\n    lp/_dep.scss 3:1   @import\n    src/main.scss 9:9  root stylesheet\n\nWARNING: end\n    src/main.scss 10:1  root stylesheet\n\n"));
    let r = sasso(&dir, &["--no-source-map", "-I", "lp", "src/usemod.scss"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(r.stderr, frames("DEPRECATION WARNING [import]: Sass @import rules are deprecated and will be removed in Dart Sass 3.0.0.\n\nMore info and automated migrator: https://sass-lang.com/d/import\n\n  ╷\n3 │ @import \"dep\";\n  │         ^^^^^\n  ╵\n    src/usemod.scss 3:9  root stylesheet\n\nDEPRECATION WARNING [import]: Sass @import rules are deprecated and will be removed in Dart Sass 3.0.0.\n\nMore info and automated migrator: https://sass-lang.com/d/import\n\n  ╷\n2 │ @import \"x\";\n  │         ^^^\n  ╵\n    lp/_mod.scss 2:9     @use\n    src/usemod.scss 1:1  root stylesheet\n\nWARNING: mod top\n    lp/_mod.scss 1:1     @use\n    src/usemod.scss 1:1  root stylesheet\n\nWARNING: mod bottom\n    lp/_mod.scss 3:1     @use\n    src/usemod.scss 1:1  root stylesheet\n\nWARNING: entry\n    src/usemod.scss 2:1  root stylesheet\n\nDEPRECATION WARNING [import]: Sass @import rules are deprecated and will be removed in Dart Sass 3.0.0.\n\nMore info and automated migrator: https://sass-lang.com/d/import\n\n  ╷\n2 │ @import \"leaf\";\n  │         ^^^^^^\n  ╵\n    lp/_dep.scss 2:9     @import\n    src/usemod.scss 3:9  root stylesheet\n\nWARNING: dep top\n    lp/_dep.scss 1:1     @import\n    src/usemod.scss 3:9  root stylesheet\n\nWARNING: leaf\n    lp/_leaf.scss 1:1    @import\n    lp/_dep.scss 2:9     @import\n    src/usemod.scss 3:9  root stylesheet\n\nWARNING: dep bottom\n    lp/_dep.scss 3:1     @import\n    src/usemod.scss 3:9  root stylesheet\n\n"));
    assert_eq!(
        r.stdout,
        "x {\n  y: 1;\n}\n\nm {\n  n: 1;\n}\n\nl {\n  m: 1;\n}\n"
    );
    assert_dart_stderr_matches(
        files,
        &["--no-source-map", "-I", "lp", "src/main.scss"],
        Compare::Full,
    );
    assert_dart_stderr_matches(
        files,
        &["--no-source-map", "-I", "lp", "--quiet-deps", "src/main.scss"],
        Compare::Full,
    );
    assert_dart_stderr_matches(
        files,
        &["--no-source-map", "-I", "lp", "src/usemod.scss"],
        Compare::Full,
    );
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn misplaced_import_is_rejected_like_dart() {
    // dart's parser rejects an `@import` inside a mixin body or a property
    // set — in the entry and in every loaded file — with "This at-rule is not
    // allowed here.", a snippet underlining the rule, and the loader chain
    // as frames (`lp/_hasmixin.scss 2:3  @use`). sasso used to accept it in
    // property sets and in loaded files' mixins, and reported the entry case
    // without position or frames.
    let files: &[(&str, &str)] = &[
        ("lp/_x.scss", "x { y: 1 }\n"),
        ("lp/_hasmixin.scss", "@mixin m {\n  @import \"x\";\n}\n"),
        (
            "propset.scss",
            "a {\n  font: {\n    family: serif;\n    @import \"x\";\n  }\n}\n",
        ),
        ("mixinimp.scss", "@mixin m {\n  @import \"x\";\n}\n"),
        (
            "usemixin.scss",
            "@use \"hasmixin\";\na {\n  @include hasmixin.m;\n}\n",
        ),
        ("impmixin.scss", "@import \"hasmixin\";\na {\n  @include m;\n}\n"),
    ];
    let dir = scratch("misplaced_import");
    for (name, text) in files {
        write(&dir, name, text);
    }
    // The only loaded file any frame here names; the rest are entries.
    let frames = |s: &str| with_frame_paths(s, &["lp/_hasmixin.scss"]);
    let r = sasso(&dir, &["--no-source-map", "-I", "lp", "propset.scss"]);
    assert_eq!(r.code, EXIT_COMPILE, "{}", r.stderr);
    assert_eq!(r.stderr, "Error: This at-rule is not allowed here.\n  ╷\n4 │     @import \"x\";\n  │     ^^^^^^^^^^^\n  ╵\n  propset.scss 4:5  root stylesheet\n");
    assert_dart_stderr_matches(
        files,
        &["--no-source-map", "-I", "lp", "propset.scss"],
        Compare::Full,
    );
    let r = sasso(&dir, &["--no-source-map", "-I", "lp", "mixinimp.scss"]);
    assert_eq!(r.code, EXIT_COMPILE, "{}", r.stderr);
    assert_eq!(r.stderr, "Error: This at-rule is not allowed here.\n  ╷\n2 │   @import \"x\";\n  │   ^^^^^^^^^^^\n  ╵\n  mixinimp.scss 2:3  root stylesheet\n");
    assert_dart_stderr_matches(
        files,
        &["--no-source-map", "-I", "lp", "mixinimp.scss"],
        Compare::Full,
    );
    let r = sasso(&dir, &["--no-source-map", "-I", "lp", "usemixin.scss"]);
    assert_eq!(r.code, EXIT_COMPILE, "{}", r.stderr);
    assert_eq!(r.stderr, frames("Error: This at-rule is not allowed here.\n  ╷\n2 │   @import \"x\";\n  │   ^^^^^^^^^^^\n  ╵\n  lp/_hasmixin.scss 2:3  @use\n  usemixin.scss 1:1      root stylesheet\n"));
    assert_dart_stderr_matches(
        files,
        &["--no-source-map", "-I", "lp", "usemixin.scss"],
        Compare::Full,
    );
    let r = sasso(&dir, &["--no-source-map", "-I", "lp", "impmixin.scss"]);
    assert_eq!(r.code, EXIT_COMPILE, "{}", r.stderr);
    assert_eq!(r.stderr, frames("DEPRECATION WARNING [import]: Sass @import rules are deprecated and will be removed in Dart Sass 3.0.0.\n\nMore info and automated migrator: https://sass-lang.com/d/import\n\n  ╷\n1 │ @import \"hasmixin\";\n  │         ^^^^^^^^^^\n  ╵\n    impmixin.scss 1:9  root stylesheet\n\nError: This at-rule is not allowed here.\n  ╷\n2 │   @import \"x\";\n  │   ^^^^^^^^^^^\n  ╵\n  lp/_hasmixin.scss 2:3  @import\n  impmixin.scss 1:9      root stylesheet\n"));
    assert_dart_stderr_matches(
        files,
        &["--no-source-map", "-I", "lp", "impmixin.scss"],
        Compare::Full,
    );
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn misplaced_import_in_a_function_or_interpolated_at_rule() {
    // Two more places dart's parser rejects an `@import`: a `@function` body
    // (the error keeps its snippet and frame, like the mixin case) and the
    // body of an interpolated at-rule (`@#{"media"} screen { … }`) inside a
    // mixin, which the static check walks like a plain at-rule.
    let files: &[(&str, &str)] = &[
        ("lp/_x.scss", "x { y: 1 }\n"),
        (
            "infn.scss",
            "@function f() {\n  @import \"x\";\n  @return 1;\n}\na { b: f(); }\n",
        ),
        (
            "interp.scss",
            "@mixin m {\n  @#{\"media\"} screen {\n    @import \"x\";\n  }\n}\na {\n  @include m;\n}\n",
        ),
    ];
    let dir = scratch("misplaced_import2");
    for (name, text) in files {
        write(&dir, name, text);
    }
    let r = sasso(&dir, &["--no-source-map", "-I", "lp", "infn.scss"]);
    assert_eq!(r.code, EXIT_COMPILE, "{}", r.stderr);
    assert_eq!(r.stderr, "Error: This at-rule is not allowed here.\n  ╷\n2 │   @import \"x\";\n  │   ^^^^^^^^^^^\n  ╵\n  infn.scss 2:3  root stylesheet\n");
    assert_dart_stderr_matches(
        files,
        &["--no-source-map", "-I", "lp", "infn.scss"],
        Compare::Full,
    );
    let r = sasso(&dir, &["--no-source-map", "-I", "lp", "interp.scss"]);
    assert_eq!(r.code, EXIT_COMPILE, "{}", r.stderr);
    assert_eq!(r.stderr, "Error: This at-rule is not allowed here.\n  ╷\n3 │     @import \"x\";\n  │     ^^^^^^^^^^^\n  ╵\n  interp.scss 3:5  root stylesheet\n");
    assert_dart_stderr_matches(
        files,
        &["--no-source-map", "-I", "lp", "interp.scss"],
        Compare::Full,
    );
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn plain_css_entry_passes_its_imports_through() {
    // A `.css` entry is plain CSS: `@import "theme";` is a CSS import to emit
    // verbatim, not a Sass file to load (dart), and it carries no `[import]`
    // deprecation. (sasso used to run the Sass evaluator over it, warn, and
    // fail with "Can't find stylesheet to import".) A property set, on the
    // other hand, admits no `@import` of any kind — plain-CSS ones included,
    // even under a control directive.
    let files: &[(&str, &str)] = &[
        ("lp/_x.scss", "x { y: 1 }\n"),
        (
            "entry.css",
            "@import \"theme\";\n@import url(other.css);\na { b: c }\n",
        ),
        (
            "propcss.scss",
            "a {\n  font: {\n    family: serif;\n    @import url(x.css);\n  }\n}\n",
        ),
        (
            "propcss2.scss",
            "a {\n  font: {\n    @if true {\n      @import \"x.css\";\n    }\n  }\n}\n",
        ),
    ];
    let dir = scratch("plain_css_entry");
    for (name, text) in files {
        write(&dir, name, text);
    }
    let r = sasso(&dir, &["--no-source-map", "-I", "lp", "entry.css"]);
    assert_eq!(r.code, 0, "{}", r.stderr);
    assert_eq!(r.stderr, "");
    assert_eq!(
        r.stdout,
        "@import \"theme\";\n@import url(other.css);\na {\n  b: c;\n}\n"
    );
    assert_dart_stderr_matches(
        files,
        &["--no-source-map", "-I", "lp", "entry.css"],
        Compare::Full,
    );
    let r = sasso(&dir, &["--no-source-map", "-I", "lp", "propcss.scss"]);
    assert_eq!(r.code, EXIT_COMPILE, "{}", r.stderr);
    assert_eq!(r.stderr, "Error: This at-rule is not allowed here.\n  ╷\n4 │     @import url(x.css);\n  │     ^^^^^^^^^^^^^^^^^^\n  ╵\n  propcss.scss 4:5  root stylesheet\n");
    assert_dart_stderr_matches(
        files,
        &["--no-source-map", "-I", "lp", "propcss.scss"],
        Compare::Full,
    );
    let r = sasso(&dir, &["--no-source-map", "-I", "lp", "propcss2.scss"]);
    assert_eq!(r.code, EXIT_COMPILE, "{}", r.stderr);
    assert_eq!(r.stderr, "Error: This at-rule is not allowed here.\n  ╷\n4 │       @import \"x.css\";\n  │       ^^^^^^^^^^^^^^^\n  ╵\n  propcss2.scss 4:7  root stylesheet\n");
    assert_dart_stderr_matches(
        files,
        &["--no-source-map", "-I", "lp", "propcss2.scss"],
        Compare::Full,
    );
    std::fs::remove_dir_all(&dir).ok();
}

/// `--update` leaves an up-to-date output alone and rebuilds when anything it
/// imports changes (#86, the binary half of #133).
///
/// The partial is two levels down on purpose: one level can pass by accident,
/// and the first version of this passed the "nothing changed" half while
/// failing this one — `FsImporter`'s canonical form is the absolute PATH, not
/// a `file://` URL, so every dependency was dropped on the way to the stat and
/// the list arrived empty.
#[test]
fn update_skips_a_fresh_output_and_rebuilds_on_a_deep_partial() {
    let dir = scratch("update-deps");
    write(&dir, "_deep.scss", "$c: #111;\n");
    write(&dir, "_base.scss", "@import \"deep\";\n.base { color: $c; }\n");
    write(&dir, "entry.scss", "@import \"base\";\n");

    let first = sasso(&dir, &["--no-source-map", "entry.scss:out.css"]);
    assert_eq!(first.code, 0, "{}", first.stderr);
    assert!(read(&dir, "out.css").contains("#111"), "first compile");

    // Nothing changed: the output keeps its mtime, which is what downstream
    // watchers key on and the reason the flag exists.
    let stamp = std::fs::metadata(dir.join("out.css"))
        .and_then(|m| m.modified())
        .expect("stat out.css");
    std::thread::sleep(std::time::Duration::from_millis(1100));
    let second = sasso(&dir, &["--no-source-map", "--update", "entry.scss:out.css"]);
    assert_eq!(second.code, 0, "{}", second.stderr);
    let after = std::fs::metadata(dir.join("out.css"))
        .and_then(|m| m.modified())
        .expect("stat out.css");
    assert_eq!(stamp, after, "--update rewrote an already-current output");

    // A partial two levels down changes: the output is stale and must be built.
    write(&dir, "_deep.scss", "$c: #444;\n");
    std::thread::sleep(std::time::Duration::from_millis(1100));
    let third = sasso(&dir, &["--no-source-map", "--update", "entry.scss:out.css"]);
    assert_eq!(third.code, 0, "{}", third.stderr);
    assert!(
        read(&dir, "out.css").contains("#444"),
        "--update ignored a transitively imported partial: {}",
        read(&dir, "out.css")
    );
}

/// `--update` with `--stdin` is a usage error, as in dart-sass.
///
/// Standard input has no mtime, so "is the output newer than its input" has no
/// honest answer — and the silent answer is the dangerous one. Before this,
/// the freshness loop simply skipped a `None` input, so a stdin unit with no
/// imports had an EMPTY loop, reported fresh, and left the previous run's CSS
/// on disk.
#[test]
fn update_with_stdin_is_a_usage_error() {
    let dir = scratch("update-stdin");
    let r = run_bin(
        BIN,
        &dir,
        &["--stdin", "--update", "out.css"],
        Some(".a { color: red }\n"),
    );
    assert_eq!(r.code, 64, "dart exits 64 here: {}", r.stderr);
    assert!(
        r.stderr.contains("--update is not allowed with --stdin."),
        "dart's wording: {}",
        r.stderr
    );
    assert!(!dir.join("out.css").exists(), "nothing should have been written");
}

/// A `-` INPUT is standard input too, and `--update` accepts it. Only the
/// `--stdin` FLAG is refused.
///
/// That asymmetry looks arbitrary until it is measured: dart-sass 1.104.1
/// exits 64 on `--stdin --update out.css`, and exits 0 on both
/// `--update - out.css` and `--update -:out.css`, compiling standard input
/// each time (2026-09-19). So the answer for a `-` input is not a refusal —
/// it is that the output can never be called fresh, because there is no
/// input mtime to compare it against, so every run rewrites. What makes that
/// true is `output_is_fresh` returning false for a `None` input; a version
/// that skipped the missing input instead looped over an empty dependency
/// list and reported FRESH.
#[test]
fn update_with_a_dash_input_compiles_stdin_every_run() {
    for (tag, args) in [
        ("positional", vec!["--no-source-map", "--update", "-", "out.css"]),
        ("pair", vec!["--no-source-map", "--update", "-:out.css"]),
    ] {
        let dir = scratch(&format!("update-dash-{tag}"));
        let first = run_bin(BIN, &dir, &args, Some(".a { color: #111; }\n"));
        assert_eq!(first.code, 0, "{tag}: dart accepts a `-` input: {}", first.stderr);
        assert!(read(&dir, "out.css").contains("#111"), "{tag}: first compile");

        // No input mtime means no honest "fresh": the second run must write
        // again even though nothing on disk changed.
        let stamp = std::fs::metadata(dir.join("out.css"))
            .and_then(|m| m.modified())
            .expect("stat out.css");
        std::thread::sleep(std::time::Duration::from_millis(1100));
        let second = run_bin(BIN, &dir, &args, Some(".a { color: #222; }\n"));
        assert_eq!(second.code, 0, "{tag}: {}", second.stderr);
        assert!(
            read(&dir, "out.css").contains("#222"),
            "{tag}: --update kept stale CSS for a stdin input: {}",
            read(&dir, "out.css")
        );
        let after = std::fs::metadata(dir.join("out.css"))
            .and_then(|m| m.modified())
            .expect("stat out.css");
        assert_ne!(
            stamp, after,
            "{tag}: --update claimed a stdin-fed output was fresh"
        );
    }
}

/// An output that is an existing DIRECTORY: `--update` skips it silently
/// where a plain compile fails with 66, and that is dart's behaviour, not an
/// oversight in the freshness check.
///
/// Measured 2026-09-19 against dart-sass 1.104.1: `sass --update e.scss:od`
/// exits 0 and writes nothing when `od` is newer than `e.scss`, and exits 66
/// with "Error reading od: illegal operation on a directory." when `od` is
/// older. Both of ours match in both directions, so dart is running the same
/// mtime comparison on the directory that we are. Requiring a regular file
/// before trusting the mtime would be a nicer CLI and a divergence.
#[test]
fn update_with_a_directory_output_matches_dart() {
    // Directory NEWER than the source: nothing is written and the run succeeds.
    let dir = scratch("update-dirout-new");
    write(&dir, "e.scss", ".a { color: red; }\n");
    std::thread::sleep(std::time::Duration::from_millis(1100));
    std::fs::create_dir_all(dir.join("od")).expect("mkdir od");
    let fresh = sasso(&dir, &["--no-source-map", "--update", "e.scss:od"]);
    assert_eq!(fresh.code, 0, "dart exits 0 here: {}", fresh.stderr);
    assert!(
        dir.join("od").is_dir() && std::fs::read_dir(dir.join("od")).into_iter().flatten().count() == 0,
        "the directory should be untouched and empty"
    );

    // Directory OLDER than the source: the write is attempted, and fails.
    let dir = scratch("update-dirout-old");
    std::fs::create_dir_all(dir.join("od")).expect("mkdir od");
    std::thread::sleep(std::time::Duration::from_millis(1100));
    write(&dir, "e.scss", ".a { color: red; }\n");
    let stale = sasso(&dir, &["--no-source-map", "--update", "e.scss:od"]);
    assert_eq!(stale.code, 66, "dart exits 66 here: {}", stale.stderr);
}

/// `--update` with nowhere to write is dart's OTHER usage error, and the one
/// this CLI shipped without: `--update is not allowed when printing to
/// stdout.`, exit 64.
///
/// Found by reading dart's own `test/cli/shared/update.dart`, which has it
/// right next to the `--stdin` case. A run with no destination has no
/// output mtime to compare, so the flag cannot do anything; dart refuses
/// rather than quietly compile to the terminal as if `--update` were absent.
///
/// The boundary matters more than the message. Measured 2026-09-19 against
/// dart-sass 1.104.1: every shape that HAS a destination is accepted —
/// `t.scss out.css`, `t.scss:out.css`, several pairs at once, and even
/// `t.scss:-`, which is a file named `-`. Only the lone positional is
/// refused. `-o` and a bare directory are this CLI's own spellings of a
/// destination, have no dart equivalent to copy, and must stay allowed.
#[test]
fn update_without_a_destination_is_a_usage_error() {
    let dir = scratch("update-no-dest");
    write(&dir, "t.scss", "a {b: c}\n");

    let r = sasso(&dir, &["--no-source-map", "--update", "t.scss"]);
    assert_eq!(r.code, 64, "dart exits 64 here: {}", r.stderr);
    assert!(
        r.stderr
            .contains("--update is not allowed when printing to stdout."),
        "dart's wording: {}",
        r.stderr
    );
    assert!(
        r.stdout.is_empty(),
        "nothing should have been compiled: {}",
        r.stdout
    );

    // Everything that names somewhere to write still works.
    for args in [
        vec!["--no-source-map", "--update", "t.scss", "out.css"],
        vec!["--no-source-map", "--update", "t.scss:out.css"],
        vec!["--no-source-map", "--update", "-o", "out.css", "t.scss"],
    ] {
        std::fs::remove_file(dir.join("out.css")).ok();
        let ok = sasso(&dir, &args);
        assert_eq!(ok.code, 0, "{args:?} names a destination: {}", ok.stderr);
        assert!(read(&dir, "out.css").contains("b: c"), "{args:?} wrote no CSS");
    }
}

/// `--update` narrates: one line per file WRITTEN, on stdout, stamped with
/// the local time to the minute.
///
/// Measured against dart-sass 1.104.1 on 2026-09-19. Everything in this
/// test is a row of that table, and each row is a way the first attempt
/// could have been wrong:
///
///   written          `[YYYY-MM-DD HH:MM:SS] Compiled <src> to <dest>.`
///   skipped          silent — so a no-op `--update` says nothing at all
///   failed           silent — the error is the output, not a compile line
///   --quiet          suppressed
///   several pairs    one line each, in COMMAND-LINE order, not finish order
///   stream           stdout, never stderr: a build script greps for it
///
/// The stamp itself comes from `src/localtime`, which is tested against the
/// whole tz database separately; here only its SHAPE is asserted, because a
/// test that recomputed the expected time would be testing itself.
#[test]
fn update_narrates_each_written_file() {
    let dir = scratch("update-narrate");
    write(&dir, "one.scss", "a {b: c}\n");
    write(&dir, "two.scss", "x {y: z}\n");

    let stamp = regex_lite_stamp; // see the helper below

    // A written file is announced, on stdout.
    let first = sasso(&dir, &["--no-source-map", "--update", "one.scss:one.css"]);
    assert_eq!(first.code, 0, "{}", first.stderr);
    assert!(
        !first.stderr.contains("Compiled"),
        "the line belongs on stdout: {}",
        first.stderr
    );
    let line = first.stdout.trim_end();
    assert!(
        line.ends_with("Compiled one.scss to one.css."),
        "dart's wording: {line:?}"
    );
    // Whether there is a stamp is a RUNTIME question, not `cfg!(unix)`.
    // Windows has no tz database to read, and neither does a nix build
    // sandbox, a scratch container, or a distroless image — all Unix, all
    // without `/etc/localtime`. The first version of this asserted a stamp
    // on every unix and was failed by nix, correctly.
    //
    // So the contract is what gets asserted: the text is always dart's, and
    // a stamp is either absent or well-formed — never malformed, never
    // wrong-shaped, never swallowing the message.
    if line.starts_with('[') {
        assert!(stamp(line), "a stamp must be [YYYY-MM-DD HH:MM:SS]: {line:?}");
    } else {
        assert!(
            line.starts_with("Compiled"),
            "with no local offset the line drops its stamp, not its content: {line:?}"
        );
    }

    // A skipped file is silent — this is what makes a no-op build quiet.
    std::thread::sleep(std::time::Duration::from_millis(1100));
    let again = sasso(&dir, &["--no-source-map", "--update", "one.scss:one.css"]);
    assert_eq!(again.code, 0, "{}", again.stderr);
    assert_eq!(again.stdout, "", "a skip must say nothing: {:?}", again.stdout);

    // Several pairs: one line each, in the order the arguments were given.
    // Jobs finish in whatever order threads finish them in, so this is a
    // real assertion and not a tautology.
    std::fs::remove_file(dir.join("one.css")).ok();
    let both = sasso(
        &dir,
        &[
            "--no-source-map",
            "--update",
            "one.scss:one.css",
            "two.scss:two.css",
        ],
    );
    assert_eq!(both.code, 0, "{}", both.stderr);
    let lines: Vec<&str> = both.stdout.lines().collect();
    assert_eq!(lines.len(), 2, "one line per file: {:?}", both.stdout);
    assert!(
        lines[0].ends_with("Compiled one.scss to one.css."),
        "{:?}",
        lines[0]
    );
    assert!(
        lines[1].ends_with("Compiled two.scss to two.css."),
        "{:?}",
        lines[1]
    );

    // --quiet suppresses it.
    std::fs::remove_file(dir.join("one.css")).ok();
    let quiet = sasso(
        &dir,
        &["--no-source-map", "--quiet", "--update", "one.scss:one.css"],
    );
    assert_eq!(quiet.code, 0, "{}", quiet.stderr);
    assert_eq!(quiet.stdout, "", "--quiet means quiet: {:?}", quiet.stdout);
    assert!(read(&dir, "one.css").contains("b: c"), "but it still compiles");

    // A failure is not announced as a compile.
    write(&dir, "bad.scss", "@use \"nope\";\n");
    let failed = sasso(&dir, &["--no-source-map", "--update", "bad.scss:bad.css"]);
    assert_ne!(failed.code, 0, "a missing module is an error");
    assert!(
        !failed.stdout.contains("Compiled"),
        "a failed compile must not claim success: {:?}",
        failed.stdout
    );
}

/// A stdin source is announced as `stdin`, not as `-`.
///
/// The `Compiled …` line names `unit.source_path()`, which is `None` for
/// standard input, and the `None` arm substitutes the word dart uses. The
/// dash tests either side of this one check CSS and mtimes, and the
/// narration test uses file inputs, so nothing here would have noticed the
/// line printing `-` — measured against dart-sass 1.104.1 on 2026-09-19,
/// which prints `Compiled stdin to o.css.`
#[test]
fn update_narrates_a_stdin_source_as_stdin() {
    let dir = scratch("update-narrate-stdin");
    let r = run_bin(
        BIN,
        &dir,
        &["--no-source-map", "--update", "-:o.css"],
        Some("a {b: c}\n"),
    );
    assert_eq!(r.code, 0, "{}", r.stderr);
    let line = r.stdout.trim_end();
    assert!(
        line.ends_with("Compiled stdin to o.css."),
        "dart names standard input `stdin`, not `-`: {line:?}"
    );
    assert!(
        !line.contains("Compiled - to"),
        "the source path leaked as a dash: {line:?}"
    );
}

/// `[YYYY-MM-DD HH:MM:SS] ` at the start of a line, without pulling in a
/// regex engine for one shape. A wrong-but-plausible stamp is caught by
/// `src/localtime`'s own tests against the tz database; what matters here is
/// that a stamp is present and correctly shaped.
///
/// Seconds included: dart's native build prints them and its dart2js build
/// truncates them away by accident (#190, and `local_stamp`'s docs).
fn regex_lite_stamp(line: &str) -> bool {
    let b = line.as_bytes();
    // `[2026-09-19 13:29:07] ` — the bracket closes at 20, the space follows.
    if b.len() < 22 || b[0] != b'[' || b[20] != b']' || b[21] != b' ' {
        return false;
    }
    let digits = [1, 2, 3, 4, 6, 7, 9, 10, 12, 13, 15, 16, 18, 19];
    let punct = [(5, b'-'), (8, b'-'), (11, b' '), (14, b':'), (17, b':')];
    digits.iter().all(|&i| b[i].is_ascii_digit()) && punct.iter().all(|&(i, c)| b[i] == c)
}

/// `--watch`'s three usage refusals, each measured against dart-sass 1.104.1
/// on 2026-09-20: same wording, same exit code as dart's, and the same shape
/// as `--update`'s two.
#[test]
fn watch_refuses_what_dart_refuses() {
    let dir = scratch("watch_usage");
    write(&dir, "a.scss", ".a { b: 1 }\n");
    for (args, message) in [
        (
            vec!["--watch", "a.scss"],
            "--watch is not allowed when printing to stdout.",
        ),
        (vec!["--watch", "--stdin"], "--watch is not allowed with --stdin."),
        (
            vec!["--poll", "a.scss:a.css"],
            "--poll may not be passed without --watch.",
        ),
    ] {
        let r = sasso(&dir, &args);
        assert_eq!(r.code, 64, "{args:?} should be a usage error: {}", r.stderr);
        assert!(
            r.stderr.contains(message),
            "{args:?}: wanted {message:?}, got {:?}",
            &r.stderr[..r.stderr.len().min(120)],
        );
    }
    // `--poll` and `--no-poll` are accepted WITH `--watch` — they choose
    // between a native watcher and repeated stats, and we only have the
    // second, so both are no-ops rather than errors. Checked through the
    // usage layer alone (a real `--watch` never exits) by pairing them with
    // a second refusal: reaching the stdin message means `--poll` itself got
    // through.
    for flag in ["--poll", "--no-poll"] {
        let r = sasso(&dir, &[flag, "--watch", "--stdin"]);
        assert_eq!(r.code, 64, "{flag}: {}", r.stderr);
        assert!(
            r.stderr.contains("--watch is not allowed with --stdin."),
            "{flag} should be accepted beside --watch, got {:?}",
            &r.stderr[..r.stderr.len().min(120)],
        );
    }
    std::fs::remove_dir_all(&dir).ok();
}

/// A real watch session: it compiles, it notices a dependency change, it
/// reports a break without dying, and it recovers.
///
/// Spawned rather than `sasso()`d because `--watch` never exits — the point
/// of the flag. Timeouts are generous: this asserts that the events HAPPEN,
/// not how fast, which is `bench/watch.md`'s job.
#[test]
fn watch_recompiles_reports_and_recovers() {
    use std::io::Read;
    use std::time::{Duration, Instant};

    let dir = scratch("watch_cycle");
    write(&dir, "src/main.scss", "@use \"v\";\n.a { color: v.$c; }\n");
    write(&dir, "src/_v.scss", "$c: red;\n");

    let mut child = std::process::Command::new(BIN)
        .args(["--no-source-map", "--watch", "src/main.scss", "out.css"])
        .current_dir(&dir)
        .stdout(std::process::Stdio::piped())
        .stderr(std::process::Stdio::piped())
        .spawn()
        .expect("spawn --watch");

    let out = dir.join("out.css");
    let css = || std::fs::read_to_string(&out).unwrap_or_default();
    let until = |pred: &dyn Fn() -> bool| {
        let deadline = Instant::now() + Duration::from_secs(20);
        while Instant::now() < deadline {
            if pred() {
                return true;
            }
            std::thread::sleep(Duration::from_millis(20));
        }
        false
    };

    // A save's CSS arrives from the PROVISIONAL run and its narration from the
    // authoritative one a window later, so a step that waits on the file has
    // not waited for the line. Long enough for the catch-up, short enough to
    // keep the test quick.
    let settle = || std::thread::sleep(Duration::from_millis(400));

    let result = std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| {
        assert!(until(&|| css().contains("red")), "the first compile never landed");
        settle();

        std::fs::write(dir.join("src/_v.scss"), "$c: navy;\n").unwrap();
        assert!(
            until(&|| css().contains("navy")),
            "a changed dependency was never noticed: {:?}",
            css(),
        );
        settle();

        // A break: error CSS replaces the output and the watch keeps running.
        std::fs::write(dir.join("src/_v.scss"), "$c: ;\n").unwrap();
        assert!(
            until(&|| css().starts_with("/* Error:")),
            "a broken dependency produced no error CSS: {:?}",
            css(),
        );
        settle();

        // Fixed back to EXACTLY what it was before the break. The npm CLI had
        // this bug (#159): a cache of the last good CSS matched, the write was
        // skipped, and the page stayed broken.
        std::fs::write(dir.join("src/_v.scss"), "$c: navy;\n").unwrap();
        assert!(
            until(&|| css().contains("navy")),
            "fixing it back to the same value left the error CSS: {:?}",
            css(),
        );
        settle();
    }));

    let _ = child.kill();
    let mut stdout = String::new();
    if let Some(mut pipe) = child.stdout.take() {
        let _ = pipe.read_to_string(&mut stdout);
    }
    let _ = child.wait();
    std::fs::remove_dir_all(&dir).ok();
    if let Err(e) = result {
        std::panic::resume_unwind(e);
    }

    // dart prints the banner before the first compile and one line per file
    // actually written; `--quiet` suppresses the lines but not the banner.
    assert!(
        stdout.starts_with("Sass is watching for changes. Press Ctrl-C to stop.\n\n"),
        "banner missing: {stdout:?}",
    );
    let compiled = stdout.lines().filter(|l| l.contains("Compiled")).count();
    assert!(
        compiled >= 3,
        "one line per successful write — first, change, recovery: {stdout:?}",
    );
    // …and a failed compile is silent on stdout, so the broken save added
    // none of them.
    assert!(
        compiled <= 4,
        "a failed compile must not be narrated, and a provisional run must not \
         narrate a second time: {stdout:?}",
    );
}

/// The output written INTO a directory the watch follows, which is the
/// ordinary layout — `main.scss` and `main.css` side by side.
///
/// The poll follows the directories of everything it loaded, so that a
/// dependency which does not exist YET can arrive. That makes the output's
/// own write a candidate change: creating a file moves its directory's
/// mtime, and a compile that provokes the next compile never stops. The
/// npm CLI needs an explicit "these files are ours" set for the same reason.
///
/// It does not happen, and the reason is worth pinning: the snapshot is
/// taken AFTER the compile, so a write that has already landed is already
/// accounted for, and writing an existing file again does not touch its
/// directory. This checks the whole of that, including the churn that does
/// move a directory's mtime — `--no-error-css` deletes the output on a
/// failure and the next success recreates it.
#[test]
fn watch_does_not_trigger_itself() {
    use std::time::{Duration, Instant};

    let dir = scratch("watch_selftrigger");
    write(&dir, "main.scss", "@use \"v\";\n.a { color: v.$c; }\n");
    write(&dir, "_v.scss", "$c: red;\n");

    let mut child = std::process::Command::new(BIN)
        .args([
            "--no-source-map",
            "--no-error-css",
            "--watch",
            "main.scss",
            "main.css",
        ])
        .current_dir(&dir)
        .stdout(std::process::Stdio::piped())
        .stderr(std::process::Stdio::null())
        .spawn()
        .expect("spawn --watch");

    let out = dir.join("main.css");
    let css = || std::fs::read_to_string(&out).unwrap_or_default();
    let until = |pred: &dyn Fn() -> bool| {
        let deadline = Instant::now() + Duration::from_secs(20);
        while Instant::now() < deadline {
            if pred() {
                return true;
            }
            std::thread::sleep(Duration::from_millis(20));
        }
        false
    };

    let result = std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| {
        assert!(until(&|| css().contains("red")), "the first compile never landed");
        // Break it, so the output is DELETED, then fix it, so it is created
        // again — the sequence that moves the directory's mtime twice.
        std::fs::write(dir.join("_v.scss"), "$c: ;\n").unwrap();
        assert!(
            until(&|| css().is_empty()),
            "--no-error-css should remove the output"
        );
        std::fs::write(dir.join("_v.scss"), "$c: teal;\n").unwrap();
        assert!(until(&|| css().contains("teal")), "and put it back");
        // Now leave it alone. An mtime that moves after this one is the
        // watch answering itself.
        std::thread::sleep(Duration::from_millis(600));
        let settled = std::fs::metadata(&out).and_then(|m| m.modified()).ok();
        std::thread::sleep(Duration::from_secs(2));
        let later = std::fs::metadata(&out).and_then(|m| m.modified()).ok();
        assert_eq!(settled, later, "the watch recompiled with nothing to recompile");
    }));

    let _ = child.kill();
    let _ = child.wait();
    std::fs::remove_dir_all(&dir).ok();
    if let Err(e) = result {
        std::panic::resume_unwind(e);
    }
}

/// A dependency that does not exist yet, in a SUBDIRECTORY.
///
/// Nothing in `sub/` was ever read, so `sub/` is in no compile's dependency
/// list and following the directories of what WAS loaded does not reach it.
/// Creating `sub/_new.scss` then changes a directory nobody is looking at and
/// the watch never recovers — measured before the fix: NEVER SEEN.
///
/// The urls that resolved to nothing are recorded now, and the directory each
/// of them names is followed even though it does not exist. Polling makes
/// that cheap: a missing path stamps as missing, compares equal to itself,
/// and becomes a change the moment it appears.
#[test]
fn watch_recovers_when_a_missing_dependency_arrives_in_a_subdirectory() {
    use std::time::{Duration, Instant};

    let dir = scratch("watch_subdir");
    std::fs::create_dir_all(dir.join("sub")).unwrap();
    write(&dir, "main.scss", "@use \"sub/new\";\n.a { b: 1 }\n");

    let mut child = std::process::Command::new(BIN)
        .args(["--no-source-map", "--watch", "main.scss", "out.css"])
        .current_dir(&dir)
        .stdout(std::process::Stdio::null())
        .stderr(std::process::Stdio::null())
        .spawn()
        .expect("spawn --watch");

    let out = dir.join("out.css");
    let css = || std::fs::read_to_string(&out).unwrap_or_default();
    let until = |pred: &dyn Fn() -> bool| {
        let deadline = Instant::now() + Duration::from_secs(20);
        while Instant::now() < deadline {
            if pred() {
                return true;
            }
            std::thread::sleep(Duration::from_millis(20));
        }
        false
    };

    let result = std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| {
        assert!(
            until(&|| css().starts_with("/* Error:")),
            "the unresolved @use should have produced error CSS: {:?}",
            css(),
        );
        std::thread::sleep(Duration::from_millis(300));
        std::fs::write(dir.join("sub/_new.scss"), "$x: 1;\n").unwrap();
        assert!(
            until(&|| css().contains("b: 1")),
            "the dependency arrived in a directory nothing was following: {:?}",
            css(),
        );
    }));

    let _ = child.kill();
    let _ = child.wait();
    std::fs::remove_dir_all(&dir).ok();
    if let Err(e) = result {
        std::panic::resume_unwind(e);
    }
}

/// `--watch --update`: the freshness check applies to the first compile and
/// never again.
///
/// After that, the output it compares against is one this session wrote — so
/// a provisional run that caught a save half-written, succeeded, and wrote
/// the wrong CSS makes its own output look up to date, and the authoritative
/// run behind it skips the write that would have fixed it. Measured before
/// this: writing `$c: bl` and finishing `ue;` 400 ms into a 680 ms compile
/// left 6 of 6 runs stuck on `color: bl` forever.
///
/// Reproducing that race needs a compile slow enough to write into and an
/// offset inside it, and neither survives a machine of a different speed. So
/// the test asserts the RULE instead, with no race and no clock in it.
///
/// Overwrite the OUTPUT, which makes it the newest file in the tree and so
/// exactly what a freshness check still in force reads as "nothing to do",
/// and then provoke a compile with something the check does not look at: a
/// new file in a watched directory. Nothing here needs a timestamp set by
/// hand — `File::set_modified` is 1.75 and this crate's MSRV is 1.74 — and
/// the two steps cannot race, because overwriting an existing file does not
/// move its directory's mtime and so provokes nothing on its own.
#[test]
fn watch_stops_applying_update_after_the_first_compile() {
    use std::time::{Duration, Instant};

    let dir = scratch("watch_update");
    write(&dir, "main.scss", "@use \"v\";\n.a { color: v.$c; }\n");
    write(&dir, "_v.scss", "$c: red;\n");

    let mut child = std::process::Command::new(BIN)
        .args(["--no-source-map", "--watch", "--update", "main.scss", "out.css"])
        .current_dir(&dir)
        .stdout(std::process::Stdio::null())
        .stderr(std::process::Stdio::null())
        .spawn()
        .expect("spawn --watch --update");

    let out = dir.join("out.css");
    let css = || std::fs::read_to_string(&out).unwrap_or_default();
    let until = |pred: &dyn Fn() -> bool| {
        let deadline = Instant::now() + Duration::from_secs(20);
        while Instant::now() < deadline {
            if pred() {
                return true;
            }
            std::thread::sleep(Duration::from_millis(20));
        }
        false
    };

    let result = std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| {
        assert!(until(&|| css().contains("red")), "the first compile never landed");
        std::thread::sleep(Duration::from_millis(300));

        // Junk, written LAST, so the output is now newer than every input —
        // the state a freshness check can only read as "up to date".
        std::fs::write(&out, "/* stale */\n").unwrap();
        // …and a reason to compile that the freshness check does not look
        // at. A new file in a watched directory moves that directory's
        // mtime; overwriting `out.css` above moved nothing, so these two
        // steps cannot arrive in the wrong order.
        std::fs::write(dir.join("newcomer.scss"), "// hello\n").unwrap();

        assert!(
            until(&|| css().contains("red")),
            "--update's freshness check is still deciding, against an output \
             this watch wrote itself: {:?}",
            css(),
        );
    }));

    let _ = child.kill();
    let _ = child.wait();
    std::fs::remove_dir_all(&dir).ok();
    if let Err(e) = result {
        std::panic::resume_unwind(e);
    }
}

/// A watch whose entry cannot be READ still follows it, so the fix is
/// noticed. Nothing else is left to follow in that state: there are no
/// loaded dependencies, and a compile that never started recorded none.
#[test]
fn watch_recovers_when_the_entry_itself_comes_back() {
    use std::time::{Duration, Instant};

    let dir = scratch("watch_entry_gone");
    write(&dir, "main.scss", ".a { b: 1 }\n");

    let mut child = std::process::Command::new(BIN)
        .args(["--no-source-map", "--watch", "main.scss", "out.css"])
        .current_dir(&dir)
        .stdout(std::process::Stdio::null())
        .stderr(std::process::Stdio::null())
        .spawn()
        .expect("spawn --watch");

    let out = dir.join("out.css");
    let css = || std::fs::read_to_string(&out).unwrap_or_default();
    let until = |pred: &dyn Fn() -> bool| {
        let deadline = Instant::now() + Duration::from_secs(20);
        while Instant::now() < deadline {
            if pred() {
                return true;
            }
            std::thread::sleep(Duration::from_millis(20));
        }
        false
    };

    let result = std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| {
        assert!(
            until(&|| css().contains("b: 1")),
            "the first compile never landed"
        );
        std::thread::sleep(Duration::from_millis(300));
        std::fs::remove_file(dir.join("main.scss")).unwrap();
        std::thread::sleep(Duration::from_millis(500));
        std::fs::write(dir.join("main.scss"), ".a { b: 2 }\n").unwrap();
        assert!(
            until(&|| css().contains("b: 2")),
            "the entry came back and nothing noticed: {:?}",
            css(),
        );
    }));

    let _ = child.kill();
    let _ = child.wait();
    std::fs::remove_dir_all(&dir).ok();
    if let Err(e) = result {
        std::panic::resume_unwind(e);
    }
}

/// A watch whose OUTPUT is one of its own sources.
///
/// `sasso main.scss main.scss` replaces a stylesheet with its own CSS, and
/// dart does that too for a one-shot compile — so it is not ours to change
/// there. Under `--watch` dart declines, and why is visible the moment you
/// try it: the write is a change, the change is a compile, the compile
/// writes again. Measured before this, 2.5 seconds of
/// `--watch main.scss main.scss`:
///
///   dart     Compiled x0   sources untouched
///   npm      Compiled x0   sources untouched
///   binary   Compiled x24  sources DESTROYED
///
/// The same rule covers an output that is a DEPENDENCY rather than the
/// entry (`main.scss _v.scss`), which does not loop but does overwrite a
/// file the compile read.
#[test]
fn watch_declines_to_write_over_a_source() {
    use std::time::Duration;

    for (entry, output) in [("main.scss", "main.scss"), ("main.scss", "_v.scss")] {
        let dir = scratch("watch_selfoutput");
        const SRC: &str = "@use \"v\";\n.a { color: v.$c; }\n";
        const DEP: &str = "$c: red;\n";
        write(&dir, "main.scss", SRC);
        write(&dir, "_v.scss", DEP);

        let mut child = std::process::Command::new(BIN)
            .args(["--no-source-map", "--watch", entry, output])
            .current_dir(&dir)
            .stdout(std::process::Stdio::piped())
            .stderr(std::process::Stdio::null())
            .spawn()
            .expect("spawn --watch");

        std::thread::sleep(Duration::from_millis(1500));
        let _ = child.kill();
        let mut stdout = String::new();
        if let Some(mut pipe) = child.stdout.take() {
            use std::io::Read;
            let _ = pipe.read_to_string(&mut stdout);
        }
        let _ = child.wait();

        let main_now = read(&dir, "main.scss");
        let dep_now = read(&dir, "_v.scss");
        std::fs::remove_dir_all(&dir).ok();

        assert_eq!(main_now, SRC, "{entry} {output}: the entry was overwritten");
        assert_eq!(dep_now, DEP, "{entry} {output}: the dependency was overwritten");
        let compiled = stdout.lines().filter(|l| l.contains("Compiled")).count();
        assert_eq!(
            compiled, 0,
            "{entry} {output}: dart is silent here and writes nothing; we said {compiled} times",
        );
    }
}

/// The output is a SYMLINK to a source: two names, one file, and a lexical
/// comparison sees only the names.
///
/// This is a DELIBERATE divergence from dart, which is why it is here with
/// the measurement rather than folded into the case above.
/// `--watch main.scss out.css` with `out.css -> main.scss`:
///
///   dart     declines 26 times in 29, and DESTROYS the stylesheet 3
///   npm      declines                                          (#168)
///   binary   Compiled x23  the source is DESTROYED             (before)
///
/// The dart row said "Compiled x1, DESTROYED" here until 2026-09-22, from
/// a single run. It has a guard and the guard is RACY: 29 runs, three of
/// them lost the file. So the divergence is not that dart allows this and
/// we do not — it is that dart decides it by a coin toss and we decide it
/// every time. #168 carried the npm half.
#[test]
fn watch_declines_to_write_over_a_source_reached_through_a_symlink() {
    use std::time::Duration;

    let dir = scratch("watch_symlink_out");
    const SRC: &str = "@use \"v\";\n.a { color: v.$c; }\n";
    write(&dir, "main.scss", SRC);
    write(&dir, "_v.scss", "$c: red;\n");
    #[cfg(unix)]
    std::os::unix::fs::symlink(dir.join("main.scss"), dir.join("out.css")).unwrap();
    #[cfg(windows)]
    std::os::windows::fs::symlink_file(dir.join("main.scss"), dir.join("out.css")).unwrap();

    let mut child = std::process::Command::new(BIN)
        .args(["--no-source-map", "--watch", "main.scss", "out.css"])
        .current_dir(&dir)
        .stdout(std::process::Stdio::piped())
        .stderr(std::process::Stdio::null())
        .spawn()
        .expect("spawn --watch");

    std::thread::sleep(Duration::from_millis(1500));
    let _ = child.kill();
    let mut stdout = String::new();
    if let Some(mut pipe) = child.stdout.take() {
        use std::io::Read;
        let _ = pipe.read_to_string(&mut stdout);
    }
    let _ = child.wait();

    let now = read(&dir, "main.scss");
    std::fs::remove_dir_all(&dir).ok();
    assert_eq!(now, SRC, "the stylesheet was overwritten through the symlink");
    let compiled = stdout.lines().filter(|l| l.contains("Compiled")).count();
    assert_eq!(
        compiled, 0,
        "nothing was written, so nothing is narrated: {stdout:?}"
    );
}

/// A deleted dependency is not resurrected through the output symlink, in any
/// of the three shapes a link can take.
///
/// `--watch main.scss <out>` where `<out>` leads to `_v.scss`, then
/// `rm _v.scss`. The compile now fails, and writing the error stylesheet
/// through the link would RECREATE the file the user deleted, with CSS in it —
/// after which the next compile finds it and may well succeed on garbage.
///
/// Measured 2026-09-22, and each shape again on 2026-09-24:
///
/// ```text
///   dart                 _v.scss stays gone
///   npm CLI, before #176 _v.scss RECREATED holding the error stylesheet
///   binary, before #177  _v.scss RECREATED holding the error stylesheet
/// ```
///
/// The three shapes are separate regressions, and the first fix caught only
/// the first of them:
///
/// - `out.css -> _v.scss`, the direct link;
/// - `out.css -> middle.scss -> _v.scss`, where one hop stops at
///   `middle.scss` — a file no compile ever read (r4100984752);
/// - the link reached through a symlinked directory, where the entry and the
///   output name one directory two ways, so a lexical join keys the
///   dependency differently from how it was remembered (r4100984799). Both
///   mixed spellings failed, in both directions.
///
/// Two things had to change for any of it. The guard asked `canonicalize`,
/// which answers NOTHING for a dangling link, so it stepped aside; it follows
/// the link chain now and resolves each hop's directory. And a failed compile
/// reports no dependencies at all, so there was nothing left to recognise
/// `_v.scss` by — the watch remembers every file it has read, across
/// failures, the way the npm CLI keeps its `known` set.
#[test]
#[cfg(unix)]
fn watch_does_not_recreate_a_deleted_dependency_through_the_output_link() {
    use std::time::{Duration, Instant};

    // `@debug` fires when `_v.scss` is EXECUTED, which is the only honest
    // signal that the watch has read it and can remember it. A sleep here
    // would test the uninitialised-watch case on a loaded runner instead.
    const DEP: &str = "$c: red;\n@debug \"the dependency was read\";\n";

    for (shape, links) in [
        ("direct", &[("out.css", "_v.scss")][..]),
        (
            "chained",
            &[("middle.scss", "_v.scss"), ("out.css", "middle.scss")][..],
        ),
    ] {
        let dir = scratch(&format!("watch_deleted_dep_{shape}"));
        write(&dir, "main.scss", "@use \"v\" as v;\n.a { color: v.$c; }\n");
        write(&dir, "_v.scss", DEP);
        for (link, target) in links {
            std::os::unix::fs::symlink(target, dir.join(link)).unwrap();
        }

        let log = dir.join("watch.err");
        let mut child = std::process::Command::new(BIN)
            .args(["--no-source-map", "--watch", "main.scss", "out.css"])
            .current_dir(&dir)
            .stdout(std::process::Stdio::null())
            .stderr(std::process::Stdio::from(std::fs::File::create(&log).unwrap()))
            .spawn()
            .expect("spawn --watch");

        let until = |pred: &dyn Fn() -> bool| {
            let deadline = Instant::now() + Duration::from_secs(20);
            while Instant::now() < deadline {
                if pred() {
                    return true;
                }
                std::thread::sleep(Duration::from_millis(20));
            }
            false
        };
        let logged = |needle: &str| std::fs::read_to_string(&log).unwrap_or_default().contains(needle);

        let read_it = until(&|| logged("the dependency was read"));
        std::fs::remove_file(dir.join("_v.scss")).expect("rm the dependency");
        // The failing compile has to have RUN before the file is judged, or
        // this passes because nothing happened yet.
        let failed = until(&|| logged("Can't find stylesheet to import"));
        // …and the write it would do happens after the diagnostic, so give
        // the round a moment to finish before looking.
        std::thread::sleep(Duration::from_millis(500));

        let _ = child.kill();
        let _ = child.wait();
        let came_back = dir.join("_v.scss").exists();
        let contents = std::fs::read_to_string(dir.join("_v.scss")).unwrap_or_default();
        std::fs::remove_dir_all(&dir).ok();

        assert!(read_it, "{shape}: the first compile never read the dependency");
        assert!(failed, "{shape}: the compile never reported the missing import");
        assert!(
            !came_back,
            "{shape}: the deleted dependency was recreated through the link: {contents:?}"
        );
    }
}

/// The same, where the output link is reached through a SYMLINKED DIRECTORY
/// and the entry names that directory the other way.
///
/// `linkdir -> real`, `real/out.css -> _v.scss`, entry `real/main.scss`,
/// output `linkdir/out.css`. One file, two spellings: the dependency is
/// remembered as `real/_v.scss` and a lexical join names `linkdir/_v.scss`,
/// so the guard saw two different files and wrote (r4100984799). Both mixed
/// orders failed before this; both are checked.
#[test]
#[cfg(unix)]
fn watch_does_not_recreate_a_deleted_dependency_through_a_symlinked_directory() {
    use std::time::{Duration, Instant};

    for (entry, out) in [
        ("real/main.scss", "linkdir/out.css"),
        ("linkdir/main.scss", "real/out.css"),
    ] {
        let dir = scratch("watch_deleted_dep_linkdir");
        std::fs::create_dir_all(dir.join("real")).unwrap();
        write(&dir, "real/main.scss", "@use \"v\" as v;\n.a { color: v.$c; }\n");
        write(
            &dir,
            "real/_v.scss",
            "$c: red;\n@debug \"the dependency was read\";\n",
        );
        std::os::unix::fs::symlink("real", dir.join("linkdir")).unwrap();
        std::os::unix::fs::symlink("_v.scss", dir.join("real/out.css")).unwrap();

        let log = dir.join("watch.err");
        let mut child = std::process::Command::new(BIN)
            .args(["--no-source-map", "--watch", entry, out])
            .current_dir(&dir)
            .stdout(std::process::Stdio::null())
            .stderr(std::process::Stdio::from(std::fs::File::create(&log).unwrap()))
            .spawn()
            .expect("spawn --watch");

        let until = |pred: &dyn Fn() -> bool| {
            let deadline = Instant::now() + Duration::from_secs(20);
            while Instant::now() < deadline {
                if pred() {
                    return true;
                }
                std::thread::sleep(Duration::from_millis(20));
            }
            false
        };
        let logged = |needle: &str| std::fs::read_to_string(&log).unwrap_or_default().contains(needle);

        let read_it = until(&|| logged("the dependency was read"));
        std::fs::remove_file(dir.join("real/_v.scss")).expect("rm the dependency");
        let failed = until(&|| logged("Can't find stylesheet to import"));
        std::thread::sleep(Duration::from_millis(500));

        let _ = child.kill();
        let _ = child.wait();
        let came_back = dir.join("real/_v.scss").exists();
        std::fs::remove_dir_all(&dir).ok();

        assert!(read_it, "{entry} -> {out}: the dependency was never read");
        assert!(failed, "{entry} -> {out}: the missing import was never reported");
        assert!(
            !came_back,
            "{entry} -> {out}: the deleted dependency came back through the link"
        );
    }
}

/// …and where the DEPENDENCY is itself a symlink whose target is deleted.
///
/// ```text
///   _v.scss -> real_v.scss     the dependency, read through a link
///   out.css -> _v.scss         the output link
///   rm real_v.scss             the chain now ends at a deleted file
/// ```
///
/// The importer only ever reports `_v.scss`, the name it opened; the output
/// link resolves all the way to `real_v.scss`. Remembering one of the two
/// leaves the other unrecognised, and the error stylesheet then recreated
/// `real_v.scss` (r4101409155, measured before the fix). So each remembered
/// file contributes BOTH keys: its own name and what it ultimately names.
#[test]
#[cfg(unix)]
fn watch_does_not_recreate_a_deleted_target_of_a_symlinked_dependency() {
    use std::time::{Duration, Instant};

    let dir = scratch("watch_dep_is_a_link");
    write(
        &dir,
        "real_v.scss",
        "$c: red;\n@debug \"the dependency was read\";\n",
    );
    write(&dir, "main.scss", "@use \"v\" as v;\n.a { color: v.$c; }\n");
    std::os::unix::fs::symlink("real_v.scss", dir.join("_v.scss")).unwrap();
    std::os::unix::fs::symlink("_v.scss", dir.join("out.css")).unwrap();

    let log = dir.join("watch.err");
    let mut child = std::process::Command::new(BIN)
        .args(["--no-source-map", "--watch", "main.scss", "out.css"])
        .current_dir(&dir)
        .stdout(std::process::Stdio::null())
        .stderr(std::process::Stdio::from(std::fs::File::create(&log).unwrap()))
        .spawn()
        .expect("spawn --watch");

    let until = |pred: &dyn Fn() -> bool| {
        let deadline = Instant::now() + Duration::from_secs(20);
        while Instant::now() < deadline {
            if pred() {
                return true;
            }
            std::thread::sleep(Duration::from_millis(20));
        }
        false
    };
    let logged = |needle: &str| std::fs::read_to_string(&log).unwrap_or_default().contains(needle);

    let read_it = until(&|| logged("the dependency was read"));
    std::fs::remove_file(dir.join("real_v.scss")).expect("rm the link's target");
    let failed = until(&|| logged("Can't find stylesheet to import"));
    std::thread::sleep(Duration::from_millis(500));

    let _ = child.kill();
    let _ = child.wait();
    let came_back = dir.join("real_v.scss").exists();
    let contents = std::fs::read_to_string(dir.join("real_v.scss")).unwrap_or_default();
    std::fs::remove_dir_all(&dir).ok();

    assert!(read_it, "the dependency was never read");
    assert!(failed, "the missing import was never reported");
    assert!(
        !came_back,
        "the link's deleted target was recreated: {contents:?}"
    );
}

/// …and where the link's target climbs out with `..` through a symlinked
/// holder, which is the one shape the FINAL parent's resolution cannot save.
///
/// ```text
///   sub/linkdir -> ../real        so sub/linkdir IS <cwd>/real
///   real/out.css -> ../x/_v.scss
///
///   resolved holder  <cwd>/real/../x/_v.scss      -> <cwd>/x/_v.scss
///   lexical  holder  <cwd>/sub/linkdir/../x/…     -> <cwd>/sub/x/_v.scss
/// ```
///
/// The dependency is `<cwd>/x/_v.scss`, so only the resolved reading names
/// it; the lexical one names a file in a directory that does not exist. This
/// is why each HOP resolves its own holder rather than only the last one —
/// and it is the case that was missing when the first mutation sweep left
/// that line as the one survivor.
#[test]
#[cfg(unix)]
fn watch_follows_a_link_that_climbs_out_through_a_symlinked_holder() {
    use std::time::{Duration, Instant};

    let dir = scratch("watch_deleted_dep_dotdot");
    for sub in ["real", "sub", "x"] {
        std::fs::create_dir_all(dir.join(sub)).unwrap();
    }
    write(&dir, "x/main.scss", "@use \"v\" as v;\n.a { color: v.$c; }\n");
    write(
        &dir,
        "x/_v.scss",
        "$c: red;\n@debug \"the dependency was read\";\n",
    );
    std::os::unix::fs::symlink("../real", dir.join("sub/linkdir")).unwrap();
    std::os::unix::fs::symlink("../x/_v.scss", dir.join("real/out.css")).unwrap();

    let log = dir.join("watch.err");
    let mut child = std::process::Command::new(BIN)
        .args(["--no-source-map", "--watch", "x/main.scss", "sub/linkdir/out.css"])
        .current_dir(&dir)
        .stdout(std::process::Stdio::null())
        .stderr(std::process::Stdio::from(std::fs::File::create(&log).unwrap()))
        .spawn()
        .expect("spawn --watch");

    let until = |pred: &dyn Fn() -> bool| {
        let deadline = Instant::now() + Duration::from_secs(20);
        while Instant::now() < deadline {
            if pred() {
                return true;
            }
            std::thread::sleep(Duration::from_millis(20));
        }
        false
    };
    let logged = |needle: &str| std::fs::read_to_string(&log).unwrap_or_default().contains(needle);

    let read_it = until(&|| logged("the dependency was read"));
    std::fs::remove_file(dir.join("x/_v.scss")).expect("rm the dependency");
    let failed = until(&|| logged("Can't find stylesheet to import"));
    std::thread::sleep(Duration::from_millis(500));

    let _ = child.kill();
    let _ = child.wait();
    let came_back = dir.join("x/_v.scss").exists();
    // The lexical reading would have written into a directory that does not
    // exist, so its absence is worth asserting too: it says the write was
    // refused rather than merely misdirected.
    let stray = dir.join("sub/x").exists();
    std::fs::remove_dir_all(&dir).ok();

    assert!(read_it, "the dependency was never read");
    assert!(failed, "the missing import was never reported");
    assert!(!came_back, "the deleted dependency came back through the chain");
    assert!(!stray, "the write was misdirected into sub/x rather than refused");
}

/// A dependency DROPPED from the entry stops blocking the output.
///
/// `out.css -> _v.scss`, `main.scss` uses `v`, so the first round declines to
/// write — the output aliases a source. Then `@use "v"` is deleted: nothing
/// reads `_v.scss` any more, and `out.css` is just the user's output again, so
/// the write must go through.
///
/// It did not, once the watch started remembering: the historical key matched
/// forever and the output was never written again — silently, with nothing
/// narrated (r4109667607). So the history is consulted on the FAILURE path
/// only, where `deps` is empty because the compile read nothing. A successful
/// compile's `deps` are the truth.
#[test]
#[cfg(unix)]
fn watch_stops_blocking_the_output_once_the_dependency_is_dropped() {
    use std::time::{Duration, Instant};

    let dir = scratch("watch_dep_dropped");
    write(&dir, "_v.scss", "$c: red;\n");
    write(&dir, "main.scss", "@use \"v\" as v;\n.a { color: v.$c; }\n");
    // The output IS the dependency, by link — so a write lands in `_v.scss`.
    std::os::unix::fs::symlink("_v.scss", dir.join("out.css")).unwrap();

    let mut child = std::process::Command::new(BIN)
        .args(["--no-source-map", "--watch", "main.scss", "out.css"])
        .current_dir(&dir)
        .stdout(std::process::Stdio::null())
        .stderr(std::process::Stdio::null())
        .spawn()
        .expect("spawn --watch");

    let until = |pred: &dyn Fn() -> bool| {
        let deadline = Instant::now() + Duration::from_secs(20);
        while Instant::now() < deadline {
            if pred() {
                return true;
            }
            std::thread::sleep(Duration::from_millis(20));
        }
        false
    };
    let body = || std::fs::read_to_string(dir.join("_v.scss")).unwrap_or_default();

    // The first round must NOT write: the output aliases a live dependency.
    assert!(
        until(&|| body().contains("$c: red")),
        "the fixture is not what the test assumes"
    );
    std::thread::sleep(Duration::from_millis(600));
    let untouched = body();

    // Drop the dependency from the entry.
    write(&dir, "main.scss", ".a { color: blue; }\n");
    let wrote = until(&|| body().contains("color: blue"));

    let _ = child.kill();
    let _ = child.wait();
    let after = body();
    std::fs::remove_dir_all(&dir).ok();

    assert!(
        untouched.contains("$c: red"),
        "the first round wrote over a live dependency: {untouched:?}"
    );
    assert!(wrote, "the write stayed blocked by the stale history: {after:?}");
}

/// …and the legitimate dangling link still works, which is why the guard
/// cannot simply refuse to write through one.
///
/// `out.css -> dist/out.css` before the first build is a common setup, and
/// `dist/out.css` is not a file any compile has read — so the link names
/// nothing the watch knows and the write goes through. dart writes it too
/// (measured 2026-09-24).
#[test]
#[cfg(unix)]
fn watch_writes_through_a_dangling_link_that_names_no_source() {
    use std::time::{Duration, Instant};

    let dir = scratch("watch_dangling_ok");
    write(&dir, "main.scss", ".a { color: red; }\n");
    std::fs::create_dir_all(dir.join("dist")).unwrap();
    std::os::unix::fs::symlink("dist/out.css", dir.join("out.css")).unwrap();

    let mut child = std::process::Command::new(BIN)
        .args(["--no-source-map", "--watch", "main.scss", "out.css"])
        .current_dir(&dir)
        .stdout(std::process::Stdio::null())
        .stderr(std::process::Stdio::null())
        .spawn()
        .expect("spawn --watch");

    // Waited for rather than slept through: the point is that the write
    // HAPPENS, so poll for it.
    let target = dir.join("dist/out.css");
    let deadline = Instant::now() + Duration::from_secs(20);
    let mut written = String::new();
    while Instant::now() < deadline {
        written = std::fs::read_to_string(&target).unwrap_or_default();
        if written.contains("color: red") {
            break;
        }
        std::thread::sleep(Duration::from_millis(20));
    }

    let _ = child.kill();
    let _ = child.wait();
    std::fs::remove_dir_all(&dir).ok();
    assert!(
        written.contains("color: red"),
        "the CSS was not written through the link: {written:?}"
    );
}

/// The alias guard on the FAILURE path: a broken save when the output is
/// one of the sources.
///
/// The success arm declined to write there; `finish_compile_error` did not,
/// so the error stylesheet — or, under `--no-error-css`, a deletion — landed
/// on the entry. Measured before this: `--watch main.scss main.scss`, then
/// break a dependency, and the stylesheet is gone. Skipping the successful
/// write and then destroying the file on the next typo is worse than either
/// alone.
#[test]
fn watch_declines_to_write_error_css_over_a_source() {
    use std::time::Duration;

    for extra in [None, Some("--no-error-css")] {
        let dir = scratch("watch_errorcss_alias");
        const SRC: &str = "@use \"v\";\n.a { color: v.$c; }\n";
        write(&dir, "main.scss", SRC);
        write(&dir, "_v.scss", "$c: red;\n");

        let mut args = vec!["--no-source-map"];
        args.extend(extra);
        args.extend(["--watch", "main.scss", "main.scss"]);
        let mut child = std::process::Command::new(BIN)
            .args(&args)
            .current_dir(&dir)
            .stdout(std::process::Stdio::null())
            .stderr(std::process::Stdio::null())
            .spawn()
            .expect("spawn --watch");

        std::thread::sleep(Duration::from_millis(700));
        // Break it: the compile now fails, and the failure path used to
        // write the error stylesheet at the output — which is the entry.
        std::fs::write(dir.join("_v.scss"), "$c: ;\n").unwrap();
        std::thread::sleep(Duration::from_millis(1200));

        let _ = child.kill();
        let _ = child.wait();
        let now = read(&dir, "main.scss");
        std::fs::remove_dir_all(&dir).ok();
        assert_eq!(
            now, SRC,
            "{args:?}: the entry was overwritten by the failure path"
        );
    }
}

/// A dependency that exists and cannot be READ, then can.
///
/// Two things had to be true for this to work and neither was. The importer
/// reports a permission failure as an error, and the `?` returned before the
/// file's stamp was taken — so nothing followed it. And `chmod` moves no
/// mtime, no length and no byte, so even once followed the stamp was
/// identical before and after. Measured before: the fix was NEVER SEEN, a
/// permanent dead end rather than a delay.
#[cfg(unix)]
#[test]
fn watch_recovers_when_a_dependency_becomes_readable() {
    use std::os::unix::fs::PermissionsExt;
    use std::time::{Duration, Instant};

    let dir = scratch("watch_unreadable");
    write(&dir, "main.scss", "@use \"v\";\n.a { color: v.$c; }\n");
    let dep = write(&dir, "_v.scss", "$c: red;\n");
    std::fs::set_permissions(&dep, std::fs::Permissions::from_mode(0o000)).unwrap();

    let mut child = std::process::Command::new(BIN)
        .args(["--no-source-map", "--watch", "main.scss", "out.css"])
        .current_dir(&dir)
        .stdout(std::process::Stdio::null())
        .stderr(std::process::Stdio::null())
        .spawn()
        .expect("spawn --watch");

    let out = dir.join("out.css");
    let css = || std::fs::read_to_string(&out).unwrap_or_default();
    let until = |pred: &dyn Fn() -> bool| {
        let deadline = Instant::now() + Duration::from_secs(20);
        while Instant::now() < deadline {
            if pred() {
                return true;
            }
            std::thread::sleep(Duration::from_millis(20));
        }
        false
    };

    let result = std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| {
        assert!(
            until(&|| css().starts_with("/* Error:")),
            "an unreadable dependency should fail the compile: {:?}",
            css(),
        );
        std::thread::sleep(Duration::from_millis(300));
        std::fs::set_permissions(&dep, std::fs::Permissions::from_mode(0o644)).unwrap();
        assert!(
            until(&|| css().contains("red")),
            "the dependency became readable and nothing noticed: {:?}",
            css(),
        );
    }));

    let _ = child.kill();
    let _ = child.wait();
    let _ = std::fs::set_permissions(&dep, std::fs::Permissions::from_mode(0o644));
    std::fs::remove_dir_all(&dir).ok();
    if let Err(e) = result {
        std::panic::resume_unwind(e);
    }
}

/// The output aliases a dependency that FAILED to load.
///
/// The alias guard was given the successful loads only, and a dependency
/// that exists and cannot be parsed or read is not one of those — so the
/// failure path wrote the error stylesheet describing the problem on top of
/// the file that had it.
///
/// Invalid UTF-8 rather than a permission bit, because the file has to stay
/// writable for the bug to be reachable at all: a `chmod 000` dependency
/// cannot be overwritten either way, and would pass this test for the wrong
/// reason.
#[test]
fn watch_declines_to_write_over_a_dependency_that_failed_to_load() {
    use std::io::Write;
    use std::time::Duration;

    let dir = scratch("watch_alias_failed");
    write(&dir, "main.scss", "@use \"v\";\n.a { color: v.$c; }\n");
    let dep = dir.join("_v.scss");
    // Valid SCSS, invalid UTF-8: the importer reports an error rather than
    // a miss.
    let bytes: &[u8] = b"$c: \xff\xfe;\n";
    std::fs::File::create(&dep).unwrap().write_all(bytes).unwrap();

    let mut child = std::process::Command::new(BIN)
        .args(["--no-source-map", "--watch", "main.scss", "_v.scss"])
        .current_dir(&dir)
        .stdout(std::process::Stdio::null())
        .stderr(std::process::Stdio::null())
        .spawn()
        .expect("spawn --watch");

    std::thread::sleep(Duration::from_millis(1200));
    let _ = child.kill();
    let _ = child.wait();

    let now = std::fs::read(&dep).unwrap_or_default();
    std::fs::remove_dir_all(&dir).ok();
    assert_eq!(
        now, bytes,
        "the dependency was overwritten by the error stylesheet about it",
    );
}

/// A file arriving at the OUTPUT's own path is still seen.
///
/// `--no-error-css` on a failing compile removes the output, and a removal
/// that really removed something is recorded so the watch does not answer
/// its own write. A removal of a file that was never there must NOT be:
/// `Snapshot::follow` puts a recorded name into the directory's `minus` set
/// and never takes it out, so one bogus record would hide that filename for
/// the rest of the run.
///
/// Reachable because `@use "out"` resolves to `out.css` as a plain CSS
/// module, so the arriving file is both a dependency and the output path.
/// The first unit then declines to write over a file that is its own source
/// — deliberately, and silently — which is why the recompile is observed
/// through a second unit's narration rather than through `out.css`.
#[test]
fn watch_sees_a_file_arrive_at_the_output_path() {
    use std::time::{Duration, Instant};

    let dir = scratch("watch_arrival_at_output");
    write(&dir, "main.scss", "@use \"out\";\n.a { color: red; }\n");
    write(&dir, "other.scss", ".z { color: green; }\n");

    let log = dir.join("log.txt");
    let mut child = std::process::Command::new(BIN)
        .args([
            "--no-source-map",
            "--no-error-css",
            "--watch",
            "main.scss:out.css",
            "other.scss:other.css",
        ])
        .current_dir(&dir)
        .stdout(std::process::Stdio::from(std::fs::File::create(&log).unwrap()))
        .stderr(std::process::Stdio::null())
        .spawn()
        .expect("spawn --watch");

    let compiled = || {
        std::fs::read_to_string(&log)
            .unwrap_or_default()
            .lines()
            .filter(|l| l.contains("Compiled other.scss"))
            .count()
    };
    let until = |pred: &dyn Fn() -> bool| {
        let deadline = Instant::now() + Duration::from_secs(20);
        while Instant::now() < deadline {
            if pred() {
                return true;
            }
            std::thread::sleep(Duration::from_millis(20));
        }
        false
    };

    let result = std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| {
        // main.scss fails — `out.css` does not exist — and `--no-error-css`
        // asks to remove an output that was never there. other.scss compiles.
        assert!(until(&|| compiled() >= 1), "the first compile never landed");
        std::thread::sleep(Duration::from_millis(400));

        // The missing dependency appears, at the output's own path. Nothing
        // else is touched: the only change on disk is that one file.
        std::fs::write(dir.join("out.css"), ".b { color: blue; }\n").unwrap();
        assert!(
            until(&|| compiled() >= 2),
            "the watch went blind to its own output's filename",
        );
    }));

    let _ = child.kill();
    let _ = child.wait();
    std::fs::remove_dir_all(&dir).ok();
    if let Err(e) = result {
        std::panic::resume_unwind(e);
    }
}

/// `--no-error-css` could not remove the stale output: SAID, not adjudicated.
///
/// The exit code answers what went wrong. Under `--no-error-css` there is no
/// output to produce, so a cleanup that fails does not change the verdict on
/// the stylesheet — and dart agrees, twice over. Measured 2026-09-23 against
/// 1.104.1, a stale output whose holding directory is read-only:
///
///   dart     65   says nothing about the removal
///   binary   66   says it                          (before this)
///   npm      65   says it                          (#181)
///
/// dart does ATTEMPT the removal rather than skipping it — with a writable
/// directory all three delete the stale file and all three exit 65 — so this
/// was dart swallowing the failure, not declining to try.
///
/// The message stays. Telling someone their stale output is still there is
/// worth saying; it is making it the run's answer that diverged.
///
/// Read-only DIRECTORY rather than a read-only file: `unlink` asks the
/// directory for permission, not the file, so `chmod 000 out.css` removes
/// perfectly well and would pass this test for the wrong reason.
#[cfg(unix)]
#[test]
fn a_failed_no_error_css_removal_is_reported_but_not_the_verdict() {
    use std::os::unix::fs::PermissionsExt;

    let dir = scratch("no_error_css_removal");
    write(&dir, "bad.scss", ".bad { a: 1px + #fff; }\n");
    std::fs::create_dir_all(dir.join("out")).unwrap();
    std::fs::write(dir.join("out/o.css"), "/* stale */\n").unwrap();
    std::fs::set_permissions(dir.join("out"), std::fs::Permissions::from_mode(0o555)).unwrap();

    let r = sasso(&dir, &["--no-source-map", "--no-error-css", "bad.scss:out/o.css"]);

    // Everything the assertions need, taken before the tree goes. A
    // failing assertion must not leave a scratch directory behind — this
    // one measured six of them in `$TMPDIR` before the cleanup — and the
    // permissions have to be put back first or `remove_dir_all` cannot
    // get into `out/`.
    let survived = dir.join("out/o.css").exists();
    std::fs::set_permissions(dir.join("out"), std::fs::Permissions::from_mode(0o755)).unwrap();
    std::fs::remove_dir_all(&dir).ok();

    assert_eq!(
        r.code, 65,
        "a cleanup that failed became the verdict: {}",
        r.stderr
    );
    assert!(
        r.stderr.contains("Undefined operation"),
        "the compile error is still the story: {}",
        r.stderr,
    );
    assert!(
        r.stderr.contains("cannot remove"),
        "the removal failure is still reported: {}",
        r.stderr,
    );
    assert!(
        survived,
        "the stale output is still there, which is the thing being reported",
    );
}

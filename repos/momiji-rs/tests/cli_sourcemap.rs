//! End-to-end CLI tests for `-o/--output` and `--source-map`, driving the REAL
//! built `sasso` binary (`env!("CARGO_BIN_EXE_sasso")`) via `std::process::Command`.
//!
//! Each test writes its inputs into a unique subdir of `std::env::temp_dir()`,
//! runs the binary, and asserts on the produced files. A small Base64-VLQ
//! `mappings` decoder + declaration-invariant checker is duplicated here (cross-
//! file reuse from `tests/sourcemap.rs` is awkward for integration tests) so the
//! produced `.map` is semantically validated, not just byte-matched.
//!
//! A gated dart-sass differential (opt-in via `SASSO_PARITY=1` + a reachable
//! `$SASS_BIN`) compares the produced `out.css` (incl footer) and the `.map`
//! fields against dart-sass for the same `sass <in> <out>` invocation.

use std::path::{Path, PathBuf};
use std::process::Command;

const BIN: &str = env!("CARGO_BIN_EXE_sasso");

/// Create a fresh unique temp subdir for one test and return its path.
fn scratch(tag: &str) -> PathBuf {
    let dir = std::env::temp_dir().join(format!("sasso_cli_sm_{tag}_{}_{}", std::process::id(), unique()));
    std::fs::create_dir_all(&dir).expect("create scratch dir");
    dir
}

/// A process-monotonic counter so concurrently-run tests get distinct dirs.
fn unique() -> u64 {
    use std::sync::atomic::{AtomicU64, Ordering};
    static N: AtomicU64 = AtomicU64::new(0);
    N.fetch_add(1, Ordering::Relaxed)
}

/// Run the sasso binary in `cwd` with `args`; return (success, stdout, stderr).
fn run(cwd: &Path, args: &[&str]) -> (bool, String, String) {
    let out = Command::new(BIN)
        .args(args)
        .current_dir(cwd)
        .output()
        .expect("spawn sasso");
    (
        out.status.success(),
        String::from_utf8_lossy(&out.stdout).into_owned(),
        String::from_utf8_lossy(&out.stderr).into_owned(),
    )
}

fn write(dir: &Path, name: &str, contents: &str) -> PathBuf {
    let p = dir.join(name);
    if let Some(parent) = p.parent() {
        std::fs::create_dir_all(parent).expect("mkdir -p");
    }
    std::fs::write(&p, contents).expect("write input");
    p
}

// ---- minimal Base64-VLQ `mappings` decoder (mirror of tests/sourcemap.rs) ----

const B64: &[u8; 64] = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

fn b64_val(c: u8) -> i64 {
    B64.iter().position(|&b| b == c).expect("valid base64 digit") as i64
}

fn vlq_decode_all(seg: &str) -> Vec<i64> {
    let bytes = seg.as_bytes();
    let mut out = Vec::new();
    let mut i = 0;
    while i < bytes.len() {
        let mut result: i64 = 0;
        let mut shift = 0;
        loop {
            let d = b64_val(bytes[i]);
            i += 1;
            result |= (d & 0x1f) << shift;
            shift += 5;
            if d & 0x20 == 0 {
                break;
            }
        }
        let mag = result >> 1;
        out.push(if result & 1 == 1 { -mag } else { mag });
    }
    out
}

#[derive(Debug, PartialEq, Eq, Clone, Copy)]
struct Mapping {
    gen_line: u32,
    gen_col: u32,
    src_id: u32,
    src_line: u32,
    src_col: u32,
}

fn decode_mappings(mappings: &str) -> Vec<Mapping> {
    let mut out = Vec::new();
    let (mut s_id, mut s_line, mut s_col) = (0i64, 0i64, 0i64);
    for (gen_line, line) in mappings.split(';').enumerate() {
        let mut gen_col = 0i64;
        for seg in line.split(',') {
            if seg.is_empty() {
                continue;
            }
            let f = vlq_decode_all(seg);
            gen_col += f[0];
            if f.len() >= 4 {
                s_id += f[1];
                s_line += f[2];
                s_col += f[3];
                out.push(Mapping {
                    gen_line: gen_line as u32,
                    gen_col: gen_col as u32,
                    src_id: s_id as u32,
                    src_line: s_line as u32,
                    src_col: s_col as u32,
                });
            }
        }
    }
    out
}

fn at(text: &str, line: u32, col: u32) -> Option<&str> {
    text.lines()
        .nth(line as usize)
        .and_then(|l| l.get(col as usize..))
}

fn leading_ident(s: &str) -> String {
    s.chars()
        .take_while(|c| c.is_ascii_alphanumeric() || *c == '-' || *c == '_')
        .collect()
}

/// For every mapping whose generated position starts with an identifier (a
/// declaration name / at-rule keyword), assert the SOURCE position it points to
/// begins with the same identifier. Returns the count of strictly-verified maps.
fn check_declaration_invariants(sources: &[(&str, &str)], output_css: &str, mappings: &str) -> usize {
    let maps = decode_mappings(mappings);
    let mut strict = 0;
    for m in &maps {
        let src_text = sources
            .get(m.src_id as usize)
            .unwrap_or_else(|| panic!("mapping references missing source id {}", m.src_id))
            .1;
        let gen = at(output_css, m.gen_line, m.gen_col)
            .unwrap_or_else(|| panic!("generated pos {m:?} out of bounds"));
        let src =
            at(src_text, m.src_line, m.src_col).unwrap_or_else(|| panic!("source pos {m:?} out of bounds"));
        let gen_id = leading_ident(gen);
        if gen_id.is_empty() {
            continue;
        }
        assert_eq!(
            gen_id,
            leading_ident(src),
            "mapping {m:?}: generated {gen_id:?} != source {:?}",
            leading_ident(src)
        );
        strict += 1;
    }
    strict
}

/// Pull a top-level string field out of the (hand-built, flat) map JSON.
fn json_field<'a>(json: &'a str, key: &str) -> Option<&'a str> {
    let needle = format!("\"{key}\":\"");
    let start = json.find(&needle)? + needle.len();
    let rest = &json[start..];
    // The map values we read here contain no escaped quotes, so this is safe.
    let end = rest.find('"')?;
    Some(&rest[..end])
}

/// Parse the `sources` JSON array of strings.
fn json_sources(json: &str) -> Vec<String> {
    let key = "\"sources\":[";
    let s = json.find(key).expect("sources field") + key.len();
    let rest = &json[s..];
    let e = rest.find(']').expect("sources close");
    rest[..e]
        .split(',')
        .filter(|t| !t.is_empty())
        .map(|t| t.trim().trim_matches('"').to_string())
        .collect()
}

// =====================================================================
// (a) `-o out.css` with NO --source-map: plain CSS, no footer, no .map.
// =====================================================================

#[test]
fn output_without_source_map_writes_plain_css() {
    // Like dart-sass, file output gets a source map by default; `--no-source-map`
    // opts out.
    let dir = scratch("plain");
    write(&dir, "in.scss", ".a {\n  color: red;\n}\n");
    let (ok, _out, err) = run(&dir, &["--no-source-map", "in.scss", "-o", "out.css"]);
    assert!(ok, "compile failed: {err}");
    let css = std::fs::read_to_string(dir.join("out.css")).expect("out.css");
    assert_eq!(css, ".a {\n  color: red;\n}\n", "plain CSS, no footer");
    assert!(!css.contains("sourceMappingURL"), "no footer expected");
    assert!(!dir.join("out.css.map").exists(), "no .map should be written");
    std::fs::remove_dir_all(&dir).ok();
}

// =====================================================================
// (b) `-o out.css --source-map`: footer + out.css.map; the map decodes and
//     every declaration mapping points at the right source identifier.
// =====================================================================

#[test]
fn source_map_writes_footer_and_sidecar() {
    let dir = scratch("sm");
    let src = ".a {\n  color: red;\n  width: 10px;\n}\n";
    write(&dir, "in.scss", src);
    let (ok, _o, err) = run(&dir, &["--source-map", "in.scss", "-o", "out.css"]);
    assert!(ok, "compile failed: {err}");

    let css = std::fs::read_to_string(dir.join("out.css")).expect("out.css");
    // dart EXPANDED footer: CSS ends in `\n`, footer = `\n/*# … */\n`.
    let expected = ".a {\n  color: red;\n  width: 10px;\n}\n\n/*# sourceMappingURL=out.css.map */\n";
    assert_eq!(css, expected, "expanded footer must match dart byte-for-byte");

    let map = std::fs::read_to_string(dir.join("out.css.map")).expect("out.css.map");
    assert!(map.contains("\"version\":3"));
    assert_eq!(json_field(&map, "file"), Some("out.css"));
    assert_eq!(json_sources(&map), vec!["in.scss".to_string()]);
    assert!(!map.contains("sourcesContent"), "no embed by default");

    // The map's mappings (after the footer is stripped) validate against the CSS.
    let mappings = json_field(&map, "mappings").expect("mappings");
    // Validate against the CSS WITHOUT the footer (the map describes the CSS body).
    let body = css.split("\n/*# sourceMappingURL").next().unwrap();
    let body = format!("{body}\n");
    let strict = check_declaration_invariants(&[("in.scss", src)], &body, mappings);
    assert!(
        strict >= 2,
        "expected color+width strictly verified, got {strict}"
    );
    std::fs::remove_dir_all(&dir).ok();
}

// =====================================================================
// (c) compressed footer has NO leading newline.
// =====================================================================

#[test]
fn compressed_footer_has_no_leading_newline() {
    let dir = scratch("comp");
    write(&dir, "in.scss", ".a {\n  color: red;\n}\n");
    let (ok, _o, err) = run(
        &dir,
        &["--style=compressed", "--source-map", "in.scss", "-o", "out.css"],
    );
    assert!(ok, "compile failed: {err}");
    let css = std::fs::read_to_string(dir.join("out.css")).expect("out.css");
    assert_eq!(
        css, ".a{color:red}/*# sourceMappingURL=out.css.map */\n",
        "compressed footer must have NO leading newline"
    );
    assert!(dir.join("out.css.map").exists());
    std::fs::remove_dir_all(&dir).ok();
}

// =====================================================================
// (d) --embed-sources populates sourcesContent.
// =====================================================================

#[test]
fn embed_sources_populates_sources_content() {
    let dir = scratch("embed");
    let src = ".a {\n  color: red;\n}\n";
    write(&dir, "in.scss", src);
    let (ok, _o, err) = run(
        &dir,
        &["--source-map", "--embed-sources", "in.scss", "-o", "out.css"],
    );
    assert!(ok, "compile failed: {err}");
    let map = std::fs::read_to_string(dir.join("out.css.map")).expect("out.css.map");
    assert!(map.contains("\"sourcesContent\":["), "expected sourcesContent");
    // The embedded content is the entry source verbatim (newlines escaped).
    let escaped = src.replace('\n', "\\n");
    assert!(
        map.contains(&escaped),
        "sourcesContent must hold the entry source.\nmap: {map}"
    );
    std::fs::remove_dir_all(&dir).ok();
}

// =====================================================================
// (e) --source-map to stdout is an error unless the map is embedded (dart).
// =====================================================================

#[test]
fn source_map_without_output_errors() {
    let dir = scratch("err");
    write(&dir, "in.scss", ".a { x: 1px; }\n");
    let (ok, _o, err) = run(&dir, &["--source-map", "in.scss"]);
    assert!(!ok, "expected a non-zero exit");
    assert!(
        err.contains("When printing to stdout, --source-map requires --embed-source-map."),
        "expected dart's stdout/source-map error, got: {err}"
    );
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn output_requires_single_input() {
    let dir = scratch("multi");
    write(&dir, "a.scss", ".a { x: 1px; }\n");
    write(&dir, "b.scss", ".b { y: 2px; }\n");
    let (ok, _o, err) = run(&dir, &["a.scss", "b.scss", "-o", "out.css"]);
    assert!(!ok, "expected a non-zero exit");
    assert!(err.contains("--output requires a single input"), "got: {err}");
    std::fs::remove_dir_all(&dir).ok();
}

// =====================================================================
// (f) the existing stdout path (no -o) is unchanged.
// =====================================================================

#[test]
fn stdout_path_unchanged_with_no_output() {
    let dir = scratch("stdout");
    write(&dir, "in.scss", ".a {\n  color: red;\n}\n");
    let (ok, out, err) = run(&dir, &["in.scss"]);
    assert!(ok, "compile failed: {err}");
    assert_eq!(out, ".a {\n  color: red;\n}\n", "stdout CSS unchanged");
    assert!(!dir.join("in.css").exists(), "no file should be written");
    std::fs::remove_dir_all(&dir).ok();
}

// =====================================================================
// (g) the CLI appends dart-sass's single trailing newline in BOTH styles —
//     to stdout and to a `-o` file. The library API omits it (pinned by
//     `library_api_omits_trailing_newline` in tests/integration.rs); these
//     guard that the CLI front-end re-adds exactly one, matching dart-sass.
// =====================================================================

#[test]
fn cli_appends_single_trailing_newline_both_styles() {
    let dir = scratch("nl");
    write(&dir, "in.scss", ".a {\n  color: red;\n}\n");

    // Expanded + compressed, to stdout.
    let (ok, exp, err) = run(&dir, &["in.scss"]);
    assert!(ok, "expanded compile failed: {err}");
    assert_eq!(
        exp, ".a {\n  color: red;\n}\n",
        "expanded stdout ends with one \\n"
    );

    let (ok, comp, err) = run(&dir, &["--style=compressed", "in.scss"]);
    assert!(ok, "compressed compile failed: {err}");
    assert_eq!(comp, ".a{color:red}\n", "compressed stdout ends with one \\n");

    // Compressed to a `-o` file (no source map): same single trailing newline.
    let (ok, _o, err) = run(
        &dir,
        &[
            "--style=compressed",
            "--no-source-map",
            "in.scss",
            "-o",
            "out.css",
        ],
    );
    assert!(ok, "compressed -o failed: {err}");
    let file = std::fs::read_to_string(dir.join("out.css")).expect("out.css");
    assert_eq!(file, ".a{color:red}\n", "compressed file ends with one \\n");

    std::fs::remove_dir_all(&dir).ok();
}

// =====================================================================
// Source map url forms: relative (output in a subdir) + absolute.
// =====================================================================

#[test]
fn relative_source_url_when_output_in_subdir() {
    let dir = scratch("relurl");
    write(&dir, "src/in.scss", ".a {\n  color: red;\n}\n");
    std::fs::create_dir_all(dir.join("out")).unwrap();
    let (ok, _o, err) = run(&dir, &["--source-map", "src/in.scss", "-o", "out/r.css"]);
    assert!(ok, "compile failed: {err}");
    let map = std::fs::read_to_string(dir.join("out/r.css.map")).expect("map");
    assert_eq!(
        json_sources(&map),
        vec!["../src/in.scss".to_string()],
        "source must be relative to the .map dir"
    );
    assert_eq!(json_field(&map, "file"), Some("r.css"));
    // Footer url is the basename of the sidecar.
    let css = std::fs::read_to_string(dir.join("out/r.css")).unwrap();
    assert!(
        css.contains("sourceMappingURL=r.css.map "),
        "footer url is sidecar basename"
    );
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn absolute_source_url_is_file_scheme() {
    let dir = scratch("absurl");
    write(&dir, "in.scss", ".a {\n  color: red;\n}\n");
    let (ok, _o, err) = run(
        &dir,
        &[
            "--source-map",
            "--source-map-urls=absolute",
            "in.scss",
            "-o",
            "out.css",
        ],
    );
    assert!(ok, "compile failed: {err}");
    let map = std::fs::read_to_string(dir.join("out.css.map")).expect("map");
    let sources = json_sources(&map);
    assert_eq!(sources.len(), 1);
    assert!(
        sources[0].starts_with("file:///") && sources[0].ends_with("/in.scss"),
        "absolute source must be a file:// URL: {:?}",
        sources[0]
    );
    std::fs::remove_dir_all(&dir).ok();
}

// =====================================================================
// Gated dart-sass differential (opt-in: SASSO_PARITY=1 + reachable $SASS_BIN).
// Runs sasso and dart-sass for the SAME `<in> <out>` invocation and asserts the
// out.css (incl footer) is byte-identical and the .map version/file/sources
// agree. The `mappings` SOURCE positions are checked as a superset (dart omits
// some closing-token columns sasso maps in compressed mode — a known, pre-
// existing library granularity difference, not a CLI concern).
// =====================================================================

fn dart_enabled() -> bool {
    std::env::var("SASSO_PARITY").map(|v| v != "0").unwrap_or(false)
}

fn source_positions(maps: &[Mapping]) -> std::collections::BTreeSet<(u32, u32, u32)> {
    maps.iter().map(|m| (m.src_id, m.src_line, m.src_col)).collect()
}

#[test]
fn dart_differential_output_and_map_match() {
    if !dart_enabled() {
        return;
    }
    let Ok(dart) = std::env::var("SASS_BIN") else {
        eprintln!("skipping dart-diff: SASS_BIN unset");
        return;
    };

    // (case, extra flags). Each runs through both binaries with the SAME output
    // path so the footer url + `file` are directly comparable.
    let cases: &[(&str, &[&str])] = &[
        (".a {\n  color: red;\n}\n", &[]),
        (
            ".a {\n  color: red;\n  width: 10px;\n}\n",
            &["--style=compressed"],
        ),
        (
            ".card {\n  color: red;\n  background: blue;\n}\n",
            &["--embed-sources"],
        ),
        (".a {\n  color: red;\n}\n", &["--source-map-urls=absolute"]),
    ];

    for (src, extra) in cases {
        let dir = scratch("diff");
        write(&dir, "in.scss", src);

        // sasso: `--source-map <extra> in.scss -o s.css`
        let mut sargs: Vec<&str> = vec!["--source-map"];
        sargs.extend_from_slice(extra);
        sargs.extend_from_slice(&["in.scss", "-o", "s.css"]);
        let (sok, _so, serr) = run(&dir, &sargs);
        assert!(sok, "sasso failed for {src:?}: {serr}");

        // dart: `--source-map <extra> in.scss d.css`
        let mut dargs: Vec<String> = vec!["--source-map".to_string()];
        dargs.extend(extra.iter().map(|s| s.to_string()));
        dargs.extend(["in.scss".to_string(), "d.css".to_string()]);
        let dstatus = Command::new(&dart)
            .args(&dargs)
            .current_dir(&dir)
            .status()
            .expect("spawn dart");
        if !dstatus.success() {
            eprintln!("skipping dart-diff case (dart failed): {src:?}");
            std::fs::remove_dir_all(&dir).ok();
            continue;
        }

        let s_css = std::fs::read(dir.join("s.css")).unwrap();
        let d_css = std::fs::read(dir.join("d.css")).unwrap();
        // The footer urls differ only by the output basename (s.css.map vs
        // d.css.map); normalize that one token before comparing the bytes.
        let s_css_n = String::from_utf8_lossy(&s_css).replace("s.css.map", "OUT.map");
        let d_css_n = String::from_utf8_lossy(&d_css).replace("d.css.map", "OUT.map");
        assert_eq!(s_css_n, d_css_n, "out.css bytes differ for {src:?} {extra:?}");

        let s_map = std::fs::read_to_string(dir.join("s.css.map")).unwrap();
        let d_map = std::fs::read_to_string(dir.join("d.css.map")).unwrap();
        assert!(s_map.contains("\"version\":3") && d_map.contains("\"version\":3"));
        // `file` differs by basename only; `sources` + sourcesContent must match.
        assert_eq!(json_field(&s_map, "file"), Some("s.css"));
        assert_eq!(json_field(&d_map, "file"), Some("d.css"));
        assert_eq!(
            json_sources(&s_map),
            json_sources(&d_map),
            "sources differ for {src:?} {extra:?}"
        );
        // Every source position dart maps, sasso must also map (superset).
        let s_pos = source_positions(&decode_mappings(json_field(&s_map, "mappings").unwrap()));
        let d_pos = source_positions(&decode_mappings(json_field(&d_map, "mappings").unwrap()));
        for p in &d_pos {
            assert!(
                s_pos.contains(p),
                "dart maps source {p:?} that sasso does not, {src:?} {extra:?}"
            );
        }
        std::fs::remove_dir_all(&dir).ok();
    }
}

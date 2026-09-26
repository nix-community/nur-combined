//! Verification harness for Source Map v3 output — built VERIFICATION-FIRST,
//! before the emit/API phases produce maps, and committed so it runs in CI.
//!
//! Three layers (see the module fns):
//!   1. `decode_mappings` — an independent Base64-VLQ + `mappings` decoder (the
//!      inverse of `src/sourcemap.rs`), used as the oracle machinery.
//!   2. `check_declaration_invariants` — asserts each declaration mapping points
//!      at the SAME leading CSS identifier in the source as appears at the
//!      generated position (a self-checking semantic invariant, no dart needed).
//!   3. The dart-sass differential lives in `tests/parity.rs`-style gated tests
//!      added as the feature lands; here we validate the MACHINERY itself against
//!      a known-good dart-sass map fixture, so later phases can trust it.
//!
//! As Phase B/C/E land, the sasso-output tests call `check_declaration_invariants`
//! on sasso's own (css, map) and decode-diff against dart.

const B64: &[u8; 64] = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

fn b64_val(c: u8) -> i64 {
    B64.iter().position(|&b| b == c).expect("valid base64 digit") as i64
}

/// Decode every Base64-VLQ value packed in one segment string.
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

/// One absolute mapping (all 0-based): generated (line,col) -> source (id,line,col).
#[derive(Debug, PartialEq, Eq, Clone, Copy)]
struct Mapping {
    gen_line: u32,
    gen_col: u32,
    src_id: u32,
    src_line: u32,
    src_col: u32,
}

/// Decode a v3 `mappings` string into absolute mappings (the inverse of
/// `sourcemap::Mappings::encode`). Segments with only a generated column (no
/// source) are skipped — they carry no source position to verify.
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

/// The text on `line` starting at column `col`. NOTE: for ASCII fixtures the
/// UTF-16 source-map column equals the byte column; non-ASCII verification needs
/// a UTF-16->byte conversion (added when those fixtures appear).
fn at(text: &str, line: u32, col: u32) -> Option<&str> {
    text.lines()
        .nth(line as usize)
        .and_then(|l| l.get(col as usize..))
}

/// The leading CSS identifier (property name / keyword) at the start of `s`.
fn leading_ident(s: &str) -> String {
    s.chars()
        .take_while(|c| c.is_ascii_alphanumeric() || *c == '-' || *c == '_')
        .collect()
}

/// Self-checking invariant: for every mapping whose GENERATED position begins
/// with an identifier (a declaration name or at-rule keyword — not a selector,
/// which starts with `.`/`#`/`&`/etc.), the SOURCE position it points to must
/// begin with the same identifier. Selector mappings (non-ident start) are only
/// bounds-checked, since source flattening (`.a .b` <- `.b`) means the generated
/// token is not a literal prefix of the source. Returns the count of strictly
/// verified (identifier-matched) mappings.
fn check_declaration_invariants(sources: &[(&str, &str)], output_css: &str, mappings: &str) -> usize {
    let maps = decode_mappings(mappings);
    let mut strict = 0;
    for m in &maps {
        let src_text = sources
            .get(m.src_id as usize)
            .unwrap_or_else(|| panic!("mapping references missing source id {}", m.src_id))
            .1;
        let gen = at(output_css, m.gen_line, m.gen_col)
            .unwrap_or_else(|| panic!("generated pos {:?} out of bounds", m));
        let src =
            at(src_text, m.src_line, m.src_col).unwrap_or_else(|| panic!("source pos {:?} out of bounds", m));
        let gen_id = leading_ident(gen);
        if gen_id.is_empty() {
            continue; // selector / symbol-leading token: bounds-checked only
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

// --- The dart-sass fixture: ground truth that validates the machinery above. ---
// Produced by: dart-sass 1.101.0 `sass --source-map sm_in.scss sm_out.css`.
const DART_INPUT: &str = ".a {\n  color: red;\n  .b { width: 10px; }\n}\n";
// The library API (`compile_with_source_map().css`) returns no trailing
// newline — matching dart-sass's library API.
const DART_OUTPUT_CSS: &str = ".a {\n  color: red;\n}\n.a .b {\n  width: 10px;\n}";
const DART_MAPPINGS: &str = "AAAA;EACE;;AACA;EAAK";

#[test]
fn decoder_matches_known_dart_map() {
    // Hand-verified decode of dart's mappings for DART_INPUT.
    let got = decode_mappings(DART_MAPPINGS);
    let expect = vec![
        Mapping {
            gen_line: 0,
            gen_col: 0,
            src_id: 0,
            src_line: 0,
            src_col: 0,
        }, // `.a` selector
        Mapping {
            gen_line: 1,
            gen_col: 2,
            src_id: 0,
            src_line: 1,
            src_col: 2,
        }, // `color` decl name
        Mapping {
            gen_line: 3,
            gen_col: 0,
            src_id: 0,
            src_line: 2,
            src_col: 2,
        }, // flattened `.a .b` <- `.b`
        Mapping {
            gen_line: 4,
            gen_col: 2,
            src_id: 0,
            src_line: 2,
            src_col: 7,
        }, // `width` decl name
    ];
    assert_eq!(got, expect);
}

#[test]
fn invariant_checker_accepts_known_good_dart_map() {
    // The machinery must ACCEPT a known-correct map (and strictly verify the two
    // declaration names `color` and `width`).
    let strict = check_declaration_invariants(&[("sm_in.scss", DART_INPUT)], DART_OUTPUT_CSS, DART_MAPPINGS);
    assert_eq!(
        strict, 2,
        "expected to strictly verify the 2 declaration-name mappings"
    );
}

#[test]
fn invariant_checker_rejects_a_corrupted_map() {
    // Sanity: corrupting the source column of the `color` mapping (point it at
    // the wrong place) must make the checker FAIL — proving it actually checks.
    // "EACE" (gen+2,src0,line+1,col+2) -> change col delta so `color` maps to col 0.
    let bad = "AAAA;EACA;;AACA;EAAK"; // second segment col delta 2 -> 0
    let prev = std::panic::take_hook();
    std::panic::set_hook(Box::new(|_| {})); // silence the expected-panic noise
    let result = std::panic::catch_unwind(|| {
        check_declaration_invariants(&[("sm_in.scss", DART_INPUT)], DART_OUTPUT_CSS, bad)
    });
    std::panic::set_hook(prev);
    assert!(
        result.is_err(),
        "checker must reject a map whose source column is wrong"
    );
}

// =====================================================================
// sasso-output tests: compile fixtures with `compile_with_source_map`,
// then validate the produced map with the harness above.
// =====================================================================

use sasso::{
    compile, compile_with_source_map, CanonicalUrl, CanonicalizeContext, Importer, ImporterError,
    ImporterResult, Options, OutputStyle, Syntax,
};

/// The canonical url `FsImporter` keys a resolved file by: the absolute path
/// as it was reached, with the ASCII case folding `absolute_normalized` applies
/// on Windows (dart's `Style.windows` canonicalizes each part, and that
/// filesystem is case-insensitive).
fn canon_key(p: std::path::PathBuf) -> String {
    // `PathBuf::push` does not respell `/` as the platform separator, so a
    // `join("src/sub/_p.scss")` keeps its `/` on Windows while the importer's
    // key, built from the real path, uses `\`. Re-collecting the components
    // respells it the way the platform does.
    let p: std::path::PathBuf = p.components().collect();
    let s = p.to_string_lossy().into_owned();
    #[cfg(windows)]
    let s = s.to_lowercase();
    s
}

/// Compile `src` with a source map and return `(css, decoded_mappings, raw_json)`.
fn sasso_map(src: &str, options: &Options<'_>) -> (String, Vec<Mapping>, String) {
    let r = compile_with_source_map(src, options).expect("compile_with_source_map failed");
    let json = r.source_map.to_json();
    // The `mappings` is the last JSON string in our hand-built JSON.
    let mappings = r.source_map.mappings.clone();
    (r.css, decode_mappings(&mappings), json)
}

#[test]
fn sasso_css_matches_plain_compile() {
    // The map is generated ALONGSIDE the CSS — the CSS must equal `compile`'s.
    for src in [
        DART_INPUT,
        "a { color: red; b { x: 1px; } }\n",
        "@media screen { a { color: red; } }\n",
        "/* hi */\na { color: red; }\n",
    ] {
        let plain = compile(src, &Options::default()).unwrap();
        let r = compile_with_source_map(src, &Options::default()).unwrap();
        assert_eq!(plain, r.css, "css mismatch for {src:?}");
    }
}

#[test]
fn sasso_nested_rule_map_is_valid() {
    // The DART_INPUT fixture: nested rule, two declarations, selector flattening.
    let (css, _maps, json) = sasso_map(DART_INPUT, &Options::default().with_url("sm_in.scss"));
    assert_eq!(css, DART_OUTPUT_CSS, "sasso css must match the dart fixture css");
    let strict = check_declaration_invariants(&[("sm_in.scss", DART_INPUT)], &css, &sasso_mappings(&json));
    assert!(
        strict >= 2,
        "expected to strictly verify >=2 decl names, got {strict}"
    );
    assert!(json.contains("\"version\":3"));
    assert!(json.contains("\"sources\":[\"sm_in.scss\"]"));
    assert!(json.contains("\"file\":\"sm_in.scss\""));
}

#[test]
fn sasso_multiline_decl_block_map_is_valid() {
    // A rule whose declarations span several source lines.
    let src = "\
.card {
  color: red;
  background: blue;
  border: 1px solid green;
}
";
    let (css, _m, json) = sasso_map(src, &Options::default().with_url("in.scss"));
    let strict = check_declaration_invariants(&[("in.scss", src)], &css, &sasso_mappings(&json));
    // color, background, border — three strictly-verified declaration names.
    assert!(strict >= 3, "expected >=3 strict decl mappings, got {strict}");
}

#[test]
fn sasso_media_block_map_is_valid() {
    let src = "\
@media screen {
  .a {
    color: red;
  }
}
";
    let (css, maps, json) = sasso_map(src, &Options::default().with_url("in.scss"));
    let strict = check_declaration_invariants(&[("in.scss", src)], &css, &sasso_mappings(&json));
    assert!(strict >= 1, "expected the `color` decl mapped, got {strict}");
    // The `@media` keyword should map to the source `@` (line 0, col 0).
    assert!(
        maps.iter().any(|m| m.src_line == 0 && m.src_col == 0),
        "expected a mapping at source 0:0 for the @media keyword"
    );
}

#[test]
fn sasso_comment_map_is_valid() {
    let src = "/* a loud comment */\n.a {\n  color: red;\n}\n";
    let (css, maps, json) = sasso_map(src, &Options::default().with_url("in.scss"));
    // The comment's `/*` maps to source 0:0.
    assert!(
        maps.iter().any(|m| m.src_line == 0 && m.src_col == 0),
        "expected the comment `/*` mapped to source 0:0"
    );
    let strict = check_declaration_invariants(&[("in.scss", src)], &css, &sasso_mappings(&json));
    assert!(strict >= 1);
}

#[test]
fn sasso_compressed_map_is_valid() {
    let src = ".a {\n  color: red;\n  width: 10px;\n}\n";
    let opts = Options::default()
        .with_style(OutputStyle::Compressed)
        .with_url("in.scss");
    let (css, maps, _json) = sasso_map(src, &opts);
    assert_eq!(css, ".a{color:red;width:10px}", "compressed css");
    // The two declaration names map to their source columns (both at col 2).
    assert_eq!(
        maps.iter().filter(|m| m.src_col == 2).count(),
        2,
        "both compressed decl names should map to source col 2: {maps:?}"
    );
    // The selector maps to source 0:0.
    assert!(maps
        .iter()
        .any(|m| m.gen_line == 0 && m.src_line == 0 && m.src_col == 0));
}

#[test]
fn sasso_compressed_skips_consecutive_same_source_line() {
    // dart-sass compressed maps every selector/declaration token but SKIPS a
    // token whose source line repeats the IMMEDIATELY PRECEDING mapped token's
    // (compressed packs many tokens onto one output line). It is a consecutive-
    // run skip, NOT a global "one mapping per source line": a source line that
    // recurs non-consecutively (e.g. a bubbled parent selector) is mapped again
    // — see `sasso_compressed_bubbled_media_matches_dart`. These expected
    // strings are byte-exact dart-sass 1.101 output. (Expanded maps every token.)
    let opts = Options::default()
        .with_style(OutputStyle::Compressed)
        .with_url("in.scss");

    // Selector + both decls share source line 0 -> only the selector is mapped.
    let (_c, _m, json) = sasso_map(".a { color: red; width: 1px; }\n", &opts);
    assert_eq!(sasso_mappings(&json), "AAAA");

    // Nested: `.a` (l0), `color` (l1), `.a .b` (l2); the l2 width/height repeat
    // the `.b` source line and are dropped.
    let (_c, _m, json) = sasso_map(
        ".a {\n  color: red;\n  .b { width: 1px; height: 2px; }\n}\n",
        &opts,
    );
    assert_eq!(sasso_mappings(&json), "AAAA,GACE,UACA");
}

#[test]
fn sasso_compressed_bubbled_media_matches_dart() {
    // A `@media` nested in a style rule bubbles a COPY of the parent selector
    // out (`@media screen{.a{...}}`); that copy must map back to the ORIGINAL
    // `.a {` selector's source position (source line 0), NOT the @media's line.
    // Because its source line (0) differs from the neighbouring @media (line 2),
    // the consecutive-same-line skip keeps it AND the following `width` decl, so
    // compressed regains the two segments a naive same-line dedup would drop.
    // Regression guard for the bubbled-selector source-map fix. Expected strings
    // are byte-exact dart-sass 1.101 (`sass in.scss out --style=compressed
    // --source-map`).
    let src = ".a {\n  color: red;\n  @media screen { width: 1px; }\n  height: 2px;\n}\n";

    let (css, _m, json) = sasso_map(
        src,
        &Options::default()
            .with_style(OutputStyle::Compressed)
            .with_url("in.scss"),
    );
    assert_eq!(css, ".a{color:red}@media screen{.a{width:1px}}.a{height:2px}");
    // 7 segments: .a(l0), color(l1), @media(l2), bubbled .a(l0), width(l2),
    // trailing .a(l0), height(l3) — none consecutive-same-line, so none dropped.
    assert_eq!(sasso_mappings(&json), "AAAA,GACE,UACA,cAFF,GAEkB,WAFlB,GAGE");

    // Expanded maps the bubbled selector too (dart parity): the `EAFF` segment
    // at generated line 4 is the bubbled `.a` mapping back to source 0:0.
    let (_c, _m, json) = sasso_map(src, &Options::default().with_url("in.scss"));
    assert_eq!(sasso_mappings(&json), "AAAA;EACE;;AACA;EAFF;IAEkB;;;AAFlB;EAGE");
}

#[test]
fn sasso_supports_header_maps_to_keyword() {
    // dart-sass maps the bubbled `@supports` at-rule HEADER back to the
    // `@supports` keyword's source position; sasso historically emitted the
    // node with `SrcLines::default()` (file 0), dropping that mapping. Regression
    // guard. `.a { @supports (display: grid) { d: grid; } }` -> dart 1.101
    // expanded `AAAK;EAAL;IAAiC` (genline0 = `@supports`@src0:5, genline1 = the
    // bubbled `.a`@src0:0, genline2 = `d:grid`).
    let src = ".a { @supports (display: grid) { d: grid; } }\n";
    let (_c, _m, json) = sasso_map(src, &Options::default().with_url("in.scss"));
    assert_eq!(sasso_mappings(&json), "AAAK;EAAL;IAAiC");

    // Compressed: the header is the only mapping (everything else coalesces onto
    // its source line) -> `AAAK`.
    let (_c, _m, json) = sasso_map(
        src,
        &Options::default()
            .with_style(OutputStyle::Compressed)
            .with_url("in.scss"),
    );
    assert_eq!(sasso_mappings(&json), "AAAK");
}

#[test]
fn sasso_bare_variable_value_maps_to_its_definition() {
    // A declaration whose value is a BARE `$name` gets a SECOND mapping segment,
    // pointing at where that variable was DECLARED — dart serializes the value
    // inside `_buffer.forSpan(node.valueSpanForMap, …)` (serialize.dart:389),
    // and `valueSpanForMap` runs the value expression through `_expressionNode`
    // (evaluate.dart:1414 -> 4538), which resolves a `VariableExpression` to
    // `Environment.getVariableNode` — the node stored when the variable was set.
    // sasso previously emitted no value segment at all, which both lost the
    // mapping AND renumbered every following segment.
    //
    // All expected strings here were produced by RUNNING dart-sass 1.101.6
    // (`sass.compileToResult(path, sourceMap: true)`), not by copying sasso's
    // own output.
    let opts = Options::default().with_url("in.scss");

    // `color: $c` (src 2:9) maps back to the `red` in `$c: red` at src 0:4.
    // Without the fix sasso emitted `AACA;EACE;;AACA;EAAK` — the `,OAFE` segment
    // missing and the two trailing segments shifted.
    let src = "$c: red;\n.a {\n  color: $c;\n  .b { top: 1px; }\n}\n";
    let (_c, _m, json) = sasso_map(src, &opts);
    assert_eq!(sasso_mappings(&json), "AACA;EACE,OAFE;;AAGF;EAAK");

    // Compressed takes the same extra segment (`MAFE`).
    let (_c, _m, json) = sasso_map(
        src,
        &Options::default()
            .with_style(OutputStyle::Compressed)
            .with_url("in.scss"),
    );
    assert_eq!(sasso_mappings(&json), "AACA,GACE,MAFE,IAGF");

    // The resolution is TRANSITIVE: `$b: $a` stores `$a`'s node, so `c: $b`
    // reaches the original `red` (src 0:4), not the `$b` declaration.
    let (_c, _m, json) = sasso_map("$a: red;\n$b: $a;\n.x { c: $b; }\n", &opts);
    assert_eq!(sasso_mappings(&json), "AAEA;EAAK,GAFD");

    // A mixin/function PARAMETER resolves too — to the ARGUMENT at the call
    // site, because `getVariableNode` returns the CURRENT binding: `pad: $p`
    // maps back to the `4px` in `@include m(4px)` (src 1:16).
    let (_c, _m, json) = sasso_map("@mixin m($p) { pad: $p; }\n.a { @include m(4px); }\n", &opts);
    assert_eq!(sasso_mappings(&json), "AACA;EADe,KACC");

    // An argument passed BY NAME resolves the same way — to the `4px` in
    // `@include m($p: 4px)` (src 1:20).
    let (_c, _m, json) = sasso_map("@mixin m($p) { pad: $p; }\n.a { @include m($p: 4px); }\n", &opts);
    assert_eq!(sasso_mappings(&json), "AACA;EADe,KACK");

    // So does one spread from a `...` splat, which carries the SPLAT
    // EXPRESSION's node: `$args` is a bare variable, so `pad: $p` reaches the
    // `(4px,)` its list was declared from (src 1:7), not the `@include`.
    let (_c, _m, json) = sasso_map(
        "@mixin m($p) { pad: $p; }\n$args: (4px,);\n.a { @include m($args...); }\n",
        &opts,
    );
    assert_eq!(sasso_mappings(&json), "AAEA;EAFe,KACR");

    // ONLY a bare variable resolves. Every other expression shape keeps its own
    // span, which sits on the declaration's own source line and is therefore
    // dropped as redundant — so `a: $c` is the only one of these six to gain a
    // segment (`,GAJE`). This is the boundary that makes the rule falsifiable:
    // arithmetic, calls, interpolation, lists and literals must NOT resolve.
    let src = concat!(
        "$c: red;\n",
        "$n: 2;\n",
        "@function f($x) { @return $x; }\n",
        ".a {\n",
        "  a: $c;\n",     // bare variable   -> EXTRA segment
        "  b: $n * 3;\n", // arithmetic      -> none
        "  c: f($n);\n",  // call            -> none
        "  d: #{$c};\n",  // interpolation   -> none
        "  e: $c $c;\n",  // list            -> none
        "  g: red;\n",    // literal         -> none
        "}\n",
    );
    let (_c, _m, json) = sasso_map(src, &opts);
    assert_eq!(sasso_mappings(&json), "AAGA;EACE,GAJE;EAKF;EACA;EACA;EACA;EACA");
}

#[test]
fn sasso_redundant_entry_dropped_across_source_files() {
    // dart's `SourceMapBuffer._addEntry` (util/source_map_buffer.dart:64) drops
    // an entry whose SOURCE LINE and TARGET LINE both repeat the previous
    // entry's. Crucially it compares neither the source FILE nor the column, so
    // two tokens on one generated line collapse even when they come from
    // different files. Verified by running dart-sass 1.101.6 on a two-file
    // compressed fixture: `.q1` (in.scss line 0) then an imported `.p1`
    // (_p.scss line 0) emit ONE segment, not two.
    //
    // sasso used to key this on `(file_id, src_line)`, which kept the second
    // entry. The fix matters here because a declaration now emits a value
    // segment on the SAME generated line as its property name.
    struct TwoFile;
    impl Importer for TwoFile {
        fn canonicalize(
            &self,
            url: &str,
            _ctx: &CanonicalizeContext<'_>,
        ) -> Result<Option<CanonicalUrl>, ImporterError> {
            Ok(Some(CanonicalUrl::new(format!("u:{url}"))))
        }
        fn load(&self, url: &CanonicalUrl) -> Result<Option<ImporterResult>, ImporterError> {
            assert_eq!(url.as_str(), "u:p");
            Ok(Some(ImporterResult {
                contents: ".p1 { a: 1px; }\n.p2 { b: 2px; }\n".to_string(),
                syntax: Syntax::Scss,
                source_map_url: None,
            }))
        }
    }
    let src = ".q1 { c: 3px; }\n@import \"p\";\n.q2 { d: 4px; }\n";
    let (css, _m, json) = sasso_map(
        src,
        &Options::default()
            .with_style(OutputStyle::Compressed)
            .with_url("in.scss")
            .with_importer(&TwoFile),
    );
    assert_eq!(css, ".q1{c:3px}.p1{a:1px}.p2{b:2px}.q2{d:4px}");
    // 3 segments, not 4: `.p1` (file 1, line 0) is dropped as redundant with
    // `.q1` (file 0, line 0) — same source line, same generated line.
    assert_eq!(sasso_mappings(&json), "AAAA,oBCCA,UDCA");
}

#[test]
fn sasso_sources_content_round_trips() {
    let src = ".a { color: red; }\n";
    let opts = Options::default()
        .with_url("in.scss")
        .with_source_map_include_sources(true);
    let r = compile_with_source_map(src, &opts).unwrap();
    assert_eq!(r.source_map.sources, vec!["in.scss".to_string()]);
    assert_eq!(
        r.source_map.sources_content.as_deref(),
        Some(&[src.to_string()][..]),
        "sourcesContent must hold the entry source"
    );
    // Default: no sourcesContent.
    let r2 = compile_with_source_map(src, &Options::default().with_url("in.scss")).unwrap();
    assert!(r2.source_map.sources_content.is_none());
    assert!(!r2.source_map.to_json().contains("sourcesContent"));
}

#[test]
fn sasso_stdin_file_name() {
    // No URL -> the `file` field is "stdin" and the single source is "stdin".
    let r = compile_with_source_map(".a { x: 1px; }\n", &Options::default()).unwrap();
    assert_eq!(r.source_map.file.as_deref(), Some("stdin"));
    assert_eq!(r.source_map.sources, vec!["stdin".to_string()]);
}

/// Extract the `mappings` JSON string value from sasso's hand-built map JSON.
fn sasso_mappings(json: &str) -> String {
    let key = "\"mappings\":\"";
    let start = json.find(key).expect("mappings field") + key.len();
    let rest = &json[start..];
    let end = rest.find('"').expect("mappings close quote");
    rest[..end].to_string()
}

// =====================================================================
// Gated dart-sass differential: compare sasso's map to dart's for the
// SAME input. Opt-in via SASSO_PARITY=1 + a reachable SASS_BIN dart-sass
// (mirrors tests/parity.rs). Decodes BOTH maps and asserts the declaration
// and selector SOURCE positions agree (semantic, not byte, comparison).
// =====================================================================

fn dart_enabled() -> bool {
    std::env::var("SASSO_PARITY").map(|v| v != "0").unwrap_or(false)
}

/// Run dart-sass with `--source-map` over a temp input file and return its
/// decoded mappings + sources, or `None` if dart is unavailable.
fn dart_map(src: &str) -> Option<(Vec<Mapping>, Vec<String>)> {
    use std::io::Write as _;
    let bin = std::env::var("SASS_BIN").ok()?;
    let dir = std::env::temp_dir();
    let stem = format!("sasso_dartdiff_{}", std::process::id());
    let in_path = dir.join(format!("{stem}.scss"));
    let out_path = dir.join(format!("{stem}.css"));
    let map_path = dir.join(format!("{stem}.css.map"));
    std::fs::File::create(&in_path)
        .ok()?
        .write_all(src.as_bytes())
        .ok()?;
    let status = std::process::Command::new(&bin)
        .arg("--source-map")
        .arg(&in_path)
        .arg(&out_path)
        .status()
        .ok()?;
    if !status.success() {
        return None;
    }
    let map_json = std::fs::read_to_string(&map_path).ok()?;
    let mappings = sasso_mappings(&map_json);
    // sources: parse the simple JSON array of strings.
    let sources = {
        let key = "\"sources\":[";
        let s = map_json.find(key)? + key.len();
        let rest = &map_json[s..];
        let e = rest.find(']')?;
        rest[..e]
            .split(',')
            .filter(|t| !t.is_empty())
            .map(|t| t.trim().trim_matches('"').to_string())
            .collect()
    };
    // Best-effort cleanup.
    let _ = std::fs::remove_file(&in_path);
    let _ = std::fs::remove_file(&out_path);
    let _ = std::fs::remove_file(&map_path);
    Some((decode_mappings(&mappings), sources))
}

/// The set of SOURCE positions a map points at (id,line,col) — order- and
/// generated-position-independent. Selector flattening means the GENERATED side
/// differs between impls, but the SOURCE side a declaration/selector points to
/// should agree.
fn source_positions(maps: &[Mapping]) -> std::collections::BTreeSet<(u32, u32, u32)> {
    maps.iter().map(|m| (m.src_id, m.src_line, m.src_col)).collect()
}

#[test]
fn dart_differential_source_positions_agree() {
    if !dart_enabled() {
        return;
    }
    // Each case exercises a different construct.
    let cases = [
        ".a {\n  color: red;\n  .b { width: 10px; }\n}\n",
        "a {\n  color: red;\n}\nb {\n  width: 10px;\n}\n",
        "@media screen {\n  .a {\n    color: red;\n  }\n}\n",
        ".card {\n  color: red;\n  background: blue;\n}\n",
    ];
    for src in cases {
        let Some((dart, _dsrc)) = dart_map(src) else {
            eprintln!("skipping dart-diff: dart-sass unavailable");
            return;
        };
        // sasso: name the entry the same as dart (the temp file's basename is
        // arbitrary, but both maps use src_id 0 for the single entry file).
        let opts = Options::default().with_url("in.scss");
        let r = compile_with_source_map(src, &opts).unwrap();
        let ours = decode_mappings(&r.source_map.mappings);
        let dart_pos = source_positions(&dart);
        let our_pos = source_positions(&ours);
        // Every source position dart maps to, sasso must also map to (sasso may
        // additionally map the closing-token columns dart omits, so this is a
        // superset check on dart's positions).
        for p in &dart_pos {
            assert!(
                our_pos.contains(p),
                "dart maps source {p:?} that sasso does not.\nsrc:\n{src}\nours: {our_pos:?}\ndart: {dart_pos:?}"
            );
        }
    }
}

#[test]
fn sasso_charset_prefix_and_utf16_columns() {
    // Non-ASCII content makes the serializer prepend `@charset "UTF-8";\n`,
    // which shifts every generated line down by one (the leading empty group
    // in `mappings`). The astral `𝕏` is 2 UTF-16 code units, so the following
    // line's columns must still be counted in UTF-16 units. This map is
    // byte-identical to dart-sass 1.x for the same input.
    let src = ".a {\n  content: \"héllo 𝕏\";\n  color: red;\n}\n";
    let r = compile_with_source_map(src, &Options::default().with_url("u_in.scss")).unwrap();
    assert!(
        r.css.starts_with("@charset \"UTF-8\";\n"),
        "expected a charset prefix"
    );
    assert_eq!(
        r.source_map.mappings, ";AAAA;EACE;EACA",
        "charset-shifted + UTF-16 map"
    );
    // The selector is now on generated line 1 (after the @charset line).
    let maps = decode_mappings(&r.source_map.mappings);
    assert!(maps
        .iter()
        .any(|m| m.gen_line == 1 && m.src_line == 0 && m.src_col == 0));
}

#[test]
fn sasso_compressed_astral_char_shifts_the_generated_column_like_dart() {
    // The expanded case above puts the astral char at the end of its line, so
    // every later column is measured from a fresh line. Compressed packs the
    // whole sheet onto generated line 0, which is where the UTF-16 unit count
    // has to be carried ACROSS the 4-byte char: `color` sits 13 units past
    // `content` (`content:"` = 9, `𝕏` = 2, `";` = 2), not 15 bytes past it.
    // Compressed also prefixes a BOM rather than `@charset`, and that BOM is
    // itself one unit, which is why the first segment starts at column 1.
    //
    // Both expected strings are dart-sass 1.104.1's own bytes for this input.
    let src = ".a {\n  content: \"𝕏\";\n  color: red;\n}\n";
    let opts = Options::default()
        .with_style(OutputStyle::Compressed)
        .with_url("in.scss");
    let (css, maps, json) = sasso_map(src, &opts);
    assert!(css.starts_with('\u{feff}'), "expected a BOM: {css:?}");
    assert_eq!(
        maps.iter().map(|m| m.gen_col).collect::<Vec<_>>(),
        vec![1, 4, 17],
        "generated columns in UTF-16 units: {maps:?}"
    );
    assert_eq!(sasso_mappings(&json), "CAAA,GACE,aACA", "dart-sass 1.104.1 map");
}

/// A custom importer that resolves one virtual module and reports a custom
/// `source_map_url` for it (dart-sass `ImporterResult.sourceMapUrl`).
struct SourceMapUrlImporter;

impl Importer for SourceMapUrlImporter {
    fn canonicalize(
        &self,
        url: &str,
        _ctx: &CanonicalizeContext<'_>,
    ) -> Result<Option<CanonicalUrl>, ImporterError> {
        Ok((url == "mod").then(|| CanonicalUrl::new("mod")))
    }

    fn load(&self, canonical: &CanonicalUrl) -> Result<Option<ImporterResult>, ImporterError> {
        if canonical.as_str() == "mod" {
            Ok(Some(ImporterResult {
                // Emit a rule so the module's source position is mapped (and thus
                // appears in the source map's `sources[]`).
                contents: ".m { x: 1px; }".to_string(),
                syntax: Syntax::Scss,
                source_map_url: Some("custom://virtual/mod.scss".to_string()),
            }))
        } else {
            Ok(None)
        }
    }
}

#[test]
fn importer_source_map_url_override_appears_in_sources() {
    // The loaded module's `sources[]` entry uses the importer's source_map_url
    // (not its canonical key), while the entry file keeps its own URL.
    let imp = SourceMapUrlImporter;
    let opts = Options::default().with_importer(&imp).with_url("entry.scss");
    // Both the entry and the module emit a rule, so both are mapped sources.
    let r = compile_with_source_map("@use \"mod\";\n.a { y: 2px; }\n", &opts).unwrap();
    assert!(
        r.source_map
            .sources
            .contains(&"custom://virtual/mod.scss".to_string()),
        "sources should carry the importer's source_map_url override, got {:?}",
        r.source_map.sources
    );
    assert!(
        r.source_map.sources.contains(&"entry.scss".to_string()),
        "the entry file keeps its own URL, got {:?}",
        r.source_map.sources
    );
}

#[test]
fn importer_source_map_url_override_applies_to_import_too() {
    // dart's `ImporterResult.sourceMapUrl` names the loaded file whether it
    // was reached by `@use` or by `@import`.
    let imp = SourceMapUrlImporter;
    let opts = Options::default().with_importer(&imp).with_url("entry.scss");
    let r = compile_with_source_map("@import \"mod\";\n.a { y: 2px; }\n", &opts).unwrap();
    assert_eq!(
        r.source_map.sources,
        ["custom://virtual/mod.scss", "entry.scss"],
        "the imported file is named by the importer's source_map_url"
    );
}

/// A plain-CSS `@import` (a `.css` file reached through `@import "lib"`) is
/// its own source, with its mappings pointing into it: dart-sass writes
/// `sources: [main.scss, lib.css]`, mappings `AAAA;EAAI;;;ACAJ;EACE;;;ADCF;EAAI`.
#[test]
fn plain_css_import_is_its_own_source() {
    let dir = std::env::temp_dir().join(format!("sasso_sm_cssimp_{}", std::process::id()));
    std::fs::create_dir_all(&dir).expect("mkdir");
    std::fs::write(dir.join("lib.css"), "q {\n  r: 1;\n}\n").unwrap();
    let entry = dir.join("main.scss");
    let src = "a { b: c }\n@import \"lib\";\nd { e: f }\n";
    std::fs::write(&entry, src).unwrap();
    let url = entry.to_string_lossy().into_owned();
    let imp = sasso::FsImporter::new(Vec::new());
    let opts = Options::default().with_importer(&imp).with_url(&url);
    let r = compile_with_source_map(src, &opts).unwrap();
    let lib = canon_key(dir.join("lib.css"));
    assert_eq!(
        r.source_map.sources,
        [url.clone(), lib],
        "the css file is a distinct source"
    );
    assert_eq!(r.source_map.mappings, "AAAA;EAAI;;;ACAJ;EACE;;;ADCF;EAAI");
    std::fs::remove_dir_all(&dir).ok();
}

/// Sources are keyed by the file's CANONICAL URL — the absolute path for the
/// filesystem importer — not by its display basename, so two partials that
/// share a basename are two distinct sources, each with its own text, and the
/// mappings point at the right one (dart-sass: `../src/sub/_p.scss`,
/// `../src/other/_p.scss`, mappings `AAAA;EAAE;;;ACAF;EAAE`).
#[test]
fn imports_sharing_a_basename_are_distinct_sources() {
    let dir = std::env::temp_dir().join(format!("sasso_sm_basename_{}", std::process::id()));
    std::fs::create_dir_all(dir.join("src/sub")).unwrap();
    std::fs::create_dir_all(dir.join("src/other")).unwrap();
    std::fs::write(dir.join("src/sub/_p.scss"), "a{b:1}\n").unwrap();
    std::fs::write(dir.join("src/other/_p.scss"), "c{d:2}\n").unwrap();
    let entry = dir.join("src/two.scss");
    let url = entry.to_string_lossy().into_owned();
    let importer = sasso::FsImporter::new(Vec::new());
    let opts = Options::default()
        .with_importer(&importer)
        .with_url(&url)
        .with_source_map_include_sources(true)
        .with_warn_handler(std::rc::Rc::new(|_: &sasso::WarnEvent<'_>| {}));
    let r = compile_with_source_map("@import \"sub/p\";\n@import \"other/p\";\n", &opts).expect("compile");
    let canon = |rel: &str| canon_key(dir.join(rel));
    // The entry emitted nothing of its own, so — as in dart — it is not a source.
    assert_eq!(
        r.source_map.sources,
        vec![canon("src/sub/_p.scss"), canon("src/other/_p.scss")]
    );
    assert_eq!(
        r.source_map.sources_content,
        Some(vec!["a{b:1}\n".to_string(), "c{d:2}\n".to_string()])
    );
    assert_eq!(r.source_map.mappings, "AAAA;EAAE;;;ACAF;EAAE");
    std::fs::remove_dir_all(&dir).ok();
}

/// A stylesheet with no output has no sources at all (dart-sass writes
/// `"sources":[]`), rather than a forced entry.
#[test]
fn empty_stylesheet_has_no_sources() {
    let r = compile_with_source_map("", &Options::default().with_url("e.scss")).expect("compile");
    assert_eq!(r.source_map.sources, Vec::<String>::new());
    assert_eq!(r.source_map.mappings, "");
    let r = compile_with_source_map("// nothing\n$x: 1;\n", &Options::default().with_url("e.scss"))
        .expect("compile");
    assert_eq!(r.source_map.sources, Vec::<String>::new());
}

/// dart-sass keeps a source-map span open while it writes a construct, and every
/// newline inside adds an entry at the start of the new generated line pointing
/// at the same source position (`SourceMapBuffer.writeCharCode`: "so that
/// source map consumers can identify the line-spanning mappings"). A rule maps
/// to its selector's FIRST line (`node.selector.span.start`), not its brace
/// line, and a comment's span opens before its indentation (column 0). Every
/// `mappings` here is byte-identical to dart-sass 1.103.1's for the same input.
#[test]
fn line_spanning_constructs_map_every_generated_line_like_dart() {
    let cases = [
        // A multi-line selector list: both lines map to the selector's start.
        ("a,\nb {\n  color: red;\n}\n", "AAAA;AAAA;EAEE"),
        // The brace on its own line: the rule still maps to the selector line.
        ("a,\nb\n{\n  color: red;\n}\n", "AAAA;AAAA;EAGE"),
        // A nested multi-line comment maps from column 0, each line.
        (
            ".x {\n  /* one\n     two */\n  color: red;\n}\n",
            "AAAA;AACE;AAAA;EAEA",
        ),
        (
            "/* top\n   two */\n.a {\n  color: red;\n}\n",
            "AAAA;AAAA;AAEA;EACE",
        ),
        // A re-indented multi-line custom property value.
        (".x {\n  --v:\n    1px\n    2px;\n}\n", "AAAA;EACE;AAAA;AAAA"),
        // A trailing comment maps after the joining space.
        (".x {\n  a: 1; /* trailing */\n}\n", "AAAA;EACE"),
        // A comment nested two levels deep.
        (
            "@media screen {\n  .a {\n    /* c */\n    color: red;\n  }\n}\n",
            "AAAA;EACE;AACE;IACA",
        ),
        // A nested rule's multi-line selector.
        (".p {\n  a,\n  b {\n    color: red;\n  }\n}\n", "AACE;AAAA;EAEE"),
        // A bubbled `@media` re-emits the multi-line selector, mapped to the
        // original rule's selector.
        (
            "a,\nb {\n  @media screen {\n    color: red;\n  }\n}\n",
            "AAEE;EAFF;AAAA;IAGI",
        ),
        // A block at-rule whose prelude spans lines maps to its `@` line, not
        // its brace line — also when bubbled out of a rule.
        (
            "@media screen,\n  print {\n  a {\n    b: c;\n  }\n}\n",
            "AAAA;EAEE;IACE",
        ),
        (
            "@media screen,\n  print\n{\n  a {\n    b: c;\n  }\n}\n",
            "AAAA;EAGE;IACE",
        ),
        (
            "@supports (display: grid) and\n  (gap: 1px) {\n  a {\n    b: c;\n  }\n}\n",
            "AAAA;EAEE;IACE",
        ),
        (
            ".x {\n  @media screen,\n    print {\n    b: c;\n  }\n}\n",
            "AACE;EADF;IAGI",
        ),
        // An interpolated at-rule NAME changes nothing: the rule carries its
        // own span and maps exactly like the plain spelling.
        ("@media screen {\n  a {\n    b: c;\n  }\n}\n", "AAAA;EACE;IACE"),
        (
            "@#{\"media\"} screen {\n  a {\n    b: c;\n  }\n}\n",
            "AAAA;EACE;IACE",
        ),
        (
            "$n: media;\n@#{$n} screen {\n  a {\n    b: c;\n  }\n}\n",
            "AACA;EACE;IACE",
        ),
    ];
    for (src, expected) in cases {
        let r = compile_with_source_map(src, &Options::default().with_url("in.scss")).expect("compile");
        assert_eq!(
            r.source_map.mappings, expected,
            "mappings for {src:?}\ncss:\n{}",
            r.css
        );
    }
}

/// A passed-through plain-CSS `@import` maps to its URL token — `url(` or the
/// opening quote — at the start of the emitted rule (dart `visitCssImport`);
/// nested in a rule it maps after the indentation. Byte-identical to dart-sass
/// 1.103.1.
#[test]
fn css_import_passthrough_maps_to_its_url() {
    let cases = [
        ("@import \"k.css\";\n", "AAAQ"),
        ("@import url(k.css);\n", "AAAQ"),
        ("@import   \"k.css\";\n", "AAAU"),
        ("@import \"k.css\" screen;\n", "AAAQ"),
        ("@import \"k.css\", \"m.css\";\n", "AAAQ;AAAS"),
        (".x {\n  @import \"k.css\";\n}\n", "AAAA;EACU"),
        // Hoisted above the rules that preceded it, and mapped from there.
        (
            ".x {\n  a: 1;\n}\n@import \"k.css\";\n.y {\n  b: 2;\n}\n",
            "AAGQ;AAHR;EACE;;;AAGF;EACE",
        ),
    ];
    for (src, expected) in cases {
        let r = compile_with_source_map(src, &Options::default().with_url("in.scss")).expect("compile");
        assert_eq!(
            r.source_map.mappings, expected,
            "mappings for {src:?}\ncss:\n{}",
            r.css
        );
    }
}

/// A loaded plain-CSS file that uses CSS nesting keeps its rules nested, and
/// each nested rule maps to its selector — every line of a multi-line list —
/// with the declarations inside mapped too (dart-sass 1.103.1:
/// `AAAA;EACE;AAAA;IAEE;;EAEF;IACE`, sources `[nest.css]`).
#[test]
fn nested_plain_css_rules_map_to_their_selectors() {
    let dir = std::env::temp_dir().join(format!("sasso_sm_cssnest_{}", std::process::id()));
    std::fs::create_dir_all(&dir).expect("mkdir");
    std::fs::write(
        dir.join("nest.css"),
        ".a {\n  > .b,\n  .c {\n    x: 1;\n  }\n  &:hover {\n    y: 2;\n  }\n}\n",
    )
    .unwrap();
    let entry = dir.join("main.scss");
    let url = entry.to_string_lossy().into_owned();
    let imp = sasso::FsImporter::new(Vec::new());
    let opts = Options::default()
        .with_importer(&imp)
        .with_url(&url)
        .with_warn_handler(std::rc::Rc::new(|_: &sasso::WarnEvent<'_>| {}));
    let r = compile_with_source_map("@import \"nest\";\n", &opts).expect("compile");
    assert_eq!(
        r.css,
        ".a {\n  > .b,\n  .c {\n    x: 1;\n  }\n  &:hover {\n    y: 2;\n  }\n}"
    );
    assert_eq!(r.source_map.sources.len(), 1, "{:?}", r.source_map.sources);
    assert!(r.source_map.sources[0].ends_with("nest.css"));
    assert_eq!(r.source_map.mappings, "AAAA;EACE;AAAA;IAEE;;EAEF;IACE");

    // Compressed output maps the nested rule's CHILDREN too: dart visits them
    // like any other rule's (`.a{.b{x:1;y:2}z:3}`, mappings
    // `AAAA,GACE,GACE,IACA,IAEF`), and a nested block's `}` is its own
    // separator — no `;` follows it.
    std::fs::write(
        dir.join("nest2.css"),
        ".a {\n  .b {\n    x: 1;\n    y: 2;\n  }\n  z: 3;\n}\n",
    )
    .unwrap();
    let opts = Options::default()
        .with_importer(&imp)
        .with_url(&url)
        .with_style(OutputStyle::Compressed)
        .with_warn_handler(std::rc::Rc::new(|_: &sasso::WarnEvent<'_>| {}));
    let r = compile_with_source_map("@import \"nest2\";\n", &opts).expect("compile");
    assert_eq!(r.css, ".a{.b{x:1;y:2}z:3}");
    assert_eq!(r.source_map.mappings, "AAAA,GACE,GACE,IACA,IAEF");
    std::fs::remove_dir_all(&dir).ok();
}

/// A block at-rule nested inside an ALREADY-NESTED plain-CSS rule stays where
/// it is (dart `_hasCssNesting`: once the user opts into CSS nesting, at-rules
/// are not bubbled), and it maps to its `@` keyword like any other at-rule —
/// in compressed output too, where its children are serialized through the
/// same mapping-aware path. Both `mappings` below are dart-sass 1.103.1's.
#[test]
fn nested_plain_css_at_rules_map_to_their_keyword() {
    let dir = std::env::temp_dir().join(format!("sasso_sm_cssnestat_{}", std::process::id()));
    std::fs::remove_dir_all(&dir).ok();
    std::fs::create_dir_all(&dir).expect("mkdir");
    let entry = dir.join("main.scss");
    let url = entry.to_string_lossy().into_owned();
    let imp = sasso::FsImporter::new(Vec::new());
    let check = |css_src: &str, name: &str, css: &str, expanded: &str, compressed: &str| {
        std::fs::write(dir.join(format!("{name}.css")), css_src).unwrap();
        let src = format!("@import \"{name}\";\n");
        let opts = Options::default()
            .with_importer(&imp)
            .with_url(&url)
            .with_warn_handler(std::rc::Rc::new(|_: &sasso::WarnEvent<'_>| {}));
        let r = compile_with_source_map(&src, &opts).expect("compile");
        assert_eq!(r.css, css, "expanded css for {name}");
        assert_eq!(r.source_map.mappings, expanded, "expanded mappings for {name}");
        let opts = opts.with_style(OutputStyle::Compressed);
        let r = compile_with_source_map(&src, &opts).expect("compile");
        assert_eq!(
            r.source_map.mappings, compressed,
            "compressed mappings for {name}"
        );
    };
    check(
        ".a {\n  .b {\n    @media screen {\n      x: 1;\n    }\n    y: 2;\n  }\n}\n",
        "nest3",
        ".a {\n  .b {\n    @media screen {\n      x: 1;\n    }\n    y: 2;\n  }\n}",
        "AAAA;EACE;IACE;MACE;;IAEF",
        "AAAA,GACE,GACE,cACE,IAEF",
    );
    // A prelude written over several lines maps from its `@` line.
    check(
        ".a {\n  .b {\n    @media screen,\n    print {\n      x: 1;\n    }\n  }\n}\n",
        "nest4",
        ".a {\n  .b {\n    @media screen, print {\n      x: 1;\n    }\n  }\n}",
        "AAAA;EACE;IACE;MAEE",
        "AAAA,GACE,GACE,oBAEE",
    );
    std::fs::remove_dir_all(&dir).ok();
}

/// The filesystem importer's canonical URL is the absolute, lexically
/// normalized path — dart `p.canonicalize` — with symlinks left unresolved, so
/// a file reached through a linked directory (a pnpm `node_modules/<pkg>`
/// link) is named by the link path in `sources`, as dart-sass 1.103.1 names it
/// (`../link/_lib.scss`, never the `real/` target).
#[cfg(unix)]
#[test]
fn sources_keep_a_symlinked_load_path_unresolved() {
    let dir = std::env::temp_dir().join(format!("sasso_sm_symlink_{}", std::process::id()));
    std::fs::remove_dir_all(&dir).ok();
    std::fs::create_dir_all(dir.join("real")).expect("mkdir");
    std::fs::write(dir.join("real/_lib.scss"), "l {\n  m: 1;\n}\n").unwrap();
    std::os::unix::fs::symlink("real", dir.join("link")).expect("symlink");
    let entry = dir.join("sym.scss");
    let url = entry.to_string_lossy().into_owned();
    let imp = sasso::FsImporter::new(vec![dir.join("link")]);
    let opts = Options::default()
        .with_importer(&imp)
        .with_url(&url)
        .with_warn_handler(std::rc::Rc::new(|_: &sasso::WarnEvent<'_>| {}));
    let r = compile_with_source_map("@import \"lib\";\n", &opts).expect("compile");
    assert_eq!(
        r.source_map.sources,
        vec![dir.join("link/_lib.scss").to_string_lossy().into_owned()]
    );
    assert_eq!(r.source_map.mappings, "AAAA;EACE");
    std::fs::remove_dir_all(&dir).ok();
}

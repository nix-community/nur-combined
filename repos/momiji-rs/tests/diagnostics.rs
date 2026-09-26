//! Byte-exact stderr diagnostics parity against the dart-sass 1.100 fixtures.
//!
//! For each `tests/fixtures/diagnostics/<name>.scss` that ships a captured
//! `<name>.ascii.stderr` (dart-sass `--no-unicode`), run the `sasso` binary
//! from inside that directory with the bare basename and `--no-unicode` (the
//! exact way the fixtures were captured) and assert sasso's stderr is
//! byte-identical.
//!
//! The set of fixtures that currently match is gated by an allow-list so the
//! test stays green while later sub-steps (deprecations, the multi-span
//! renderer, `@import` source-swap) grow it. Each non-matching fixture is
//! listed with the reason it is skipped.

use std::path::Path;
use std::process::Command;

use sasso::{compile, Options};

/// Fixtures whose `--no-unicode` stderr sasso reproduces byte-for-byte today.
const MATCHING: &[&str] = &[
    // @debug — single line, no snippet/frames.
    "debug-string",
    "debug-values",
    // @warn — WARNING: + 4-space frame trace + blank line.
    "warn-plain",
    "warn-interpolated",
    "warn-in-mixin",
    // @error — snippet at the call site, 2-space frame trace.
    "error-plain",
    "error-interpolated",
    "error-in-mixin",
    "error-stack-nested",
    "error-in-function",
    "error-cross-file",
    // The nine members dart REMOVED from `sass:color` (#65): a three-part
    // message whose `Recommendation:` line is built from the call's own
    // arguments. Two fixtures because the paths differ in what they can get
    // wrong — the namespaced one is the message itself, and the one reached
    // through `@use "sass:color" as *` also locks the frame trace and the
    // caret, which spanned a single column for a starred member until #65.
    "error-color-removed-member",
    "error-color-removed-member-star",
    // Compile errors with a positioned span (undefined variable).
    "compile-undefined-variable",
    "compile-undefined-variable-stack",
    "compile-tab-expansion",
    "compile-gutter-alignment",
    // Deprecations (registry sub-step): the fully-static `@import` warning.
    "deprecation-import",
    // The global-built-in family, and the two that ride along with it.
    "deprecation-global-builtin",
    "deprecation-feature-exists",
    "deprecation-call-string",
    // The legacy `sass:color` members, whose suggestions are computed from the
    // call's own arguments.
    "deprecation-color-functions",
    "deprecation-darken",
    // The legacy `if()`, whose suggestion is the arguments written back out.
    "deprecation-if-function",
    // A dropped selector announcing itself: dart omits the rule from the CSS
    // and this warning is the only sign it did. sasso dropped it silently
    // until #119 — 45 rules disappeared from Lichess's build with no notice.
    // Its sibling fixture `deprecation-bogus-combinators` is dart's OTHER
    // message for a trailing combinator, which needs the two-span renderer and
    // stays out of this list.
    "deprecation-bogus-combinators-invalid",
    // The same warning behind a multi-byte selector: the span helper mixes
    // character columns with byte offsets by nature (dart's columns are
    // characters, our Span length is source bytes), and got it wrong the first
    // time — twelve columns late on a CJK selector.
    "deprecation-bogus-combinators-non-ascii",
    // The warning is delayed until after the rule body, so the error path is
    // its own question: dart drops it when that body fails, and keeps it when
    // a LATER rule fails. Both, because gating on success could otherwise be
    // over-broad with nothing to notice.
    "deprecation-bogus-combinators-body-error",
    "deprecation-bogus-combinators-later-error",
    // Four CSS filter calls that must stay silent beside one real Sass colour
    // call that must still warn (#122). Both halves in one fixture on purpose:
    // simply not warning would satisfy the first and fail the second.
    "deprecation-global-builtin-css-filter",
    // The same rule reached through a function reference: fixing only the
    // direct call left `meta.call(meta.get-function("grayscale"), 1)` warning.
    "deprecation-global-builtin-call-ref",
    // `color-module-compat`, which sasso never emitted before #124: all five
    // of dart's shapes in one fixture — a number to `color.grayscale` (through
    // `@use "sass:color" as *`), `color.invert` and `color.opacity`, and a
    // Microsoft filter argument to `color.alpha` in either overload. Two calls
    // that must stay silent ride along, because emitting nothing would satisfy
    // neither half. Byte parity includes dart's missing closing parenthesis in
    // the `opacity` message, which sass-spec locks.
    "deprecation-color-module-compat",
    // The same rule reached through a function reference, the path that stayed
    // silent when only the direct call was fixed for `global-builtin` above.
    "deprecation-color-module-compat-call-ref",
    // And through `@use "sass:color" as *`, where the MICROSOFT half is the one
    // at risk: the global spelling returns that call verbatim before dispatch
    // (dart deprecates nothing for it), and doing the same for the bare name a
    // star import binds skipped the module member this rule belongs to. The
    // star `grayscale` in the fixture above covers the numeric half.
    "deprecation-color-module-compat-star",
];

fn fixtures_dir() -> std::path::PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/fixtures/diagnostics")
}

/// Run sasso from inside the fixtures dir with the bare basename + --no-unicode,
/// returning captured stderr verbatim.
fn run_sasso_stderr(name: &str) -> String {
    let bin = env!("CARGO_BIN_EXE_sasso");
    let out = Command::new(bin)
        .current_dir(fixtures_dir())
        .arg("--no-unicode")
        .arg(format!("{name}.scss"))
        .output()
        .expect("run sasso");
    String::from_utf8_lossy(&out.stderr).into_owned()
}

#[test]
fn diagnostics_match_dart_ascii_fixtures() {
    let dir = fixtures_dir();
    for name in MATCHING {
        let expected = std::fs::read_to_string(dir.join(format!("{name}.ascii.stderr")))
            .unwrap_or_else(|e| panic!("read {name}.ascii.stderr: {e}"));
        let got = run_sasso_stderr(name);
        assert_eq!(got, expected, "stderr mismatch for fixture {name}");
    }
}

/// Sanity: an `@error` exits 65 and a `@warn` exits 0, matching dart-sass.
#[test]
fn diagnostics_exit_codes() {
    let bin = env!("CARGO_BIN_EXE_sasso");
    let dir = fixtures_dir();
    let error_code = Command::new(bin)
        .current_dir(&dir)
        .arg("--no-unicode")
        .arg("error-plain.scss")
        .output()
        .expect("run")
        .status
        .code();
    assert_eq!(error_code, Some(65), "@error must exit 65");

    let warn_code = Command::new(bin)
        .current_dir(&dir)
        .arg("--no-unicode")
        .arg("warn-plain.scss")
        .output()
        .expect("run")
        .status
        .code();
    assert_eq!(warn_code, Some(0), "@warn must exit 0");
}

#[test]
fn invalid_utf8_input_exits_65() {
    let bin = env!("CARGO_BIN_EXE_sasso");
    let dir = std::env::temp_dir().join(format!("sasso_invalid_utf8_{}", std::process::id()));
    let _ = std::fs::remove_dir_all(&dir);
    std::fs::create_dir_all(&dir).expect("create temp dir");
    let input = dir.join("input.scss");
    std::fs::write(&input, b"foo{;\xF6\xFC").expect("write invalid utf8");

    let out = Command::new(bin).arg(&input).output().expect("run");
    let _ = std::fs::remove_dir_all(&dir);

    assert_eq!(out.status.code(), Some(65));
    assert_eq!(String::from_utf8_lossy(&out.stderr), "Error: Invalid UTF-8.\n");
}

/// The rendered diagnostic block for `src`, compiled under `url` so snippets
/// and frames are produced.
fn err_block(src: &str, url: &str) -> String {
    compile(src, &Options::default().with_url(url))
        .expect_err("expected a compile error")
        .to_string()
}

/// The caret line of a rendered block, trimmed — so a span that is one
/// character too long fails instead of passing a substring check.
fn caret_line(block: &str) -> String {
    block
        .lines()
        .find(|l| l.contains('^'))
        .unwrap_or_else(|| panic!("no caret line in:\n{block}"))
        // Drop the gutter (`  \u{2502} `) and the indentation before the run.
        .rsplit('\u{2502}')
        .next()
        .unwrap_or_default()
        .trim()
        .to_string()
}

#[test]
fn a_module_diagnostic_carets_the_construct_it_is_about() {
    // dart spans the whole rule, call or reference a diagnostic is about;
    // sasso drew a single caret (or none at all, leaving the error with no
    // snippet). Every span below was measured against dart-sass 1.103.1.
    let cases = [
        // a failed load carets the whole `@use`/`@forward`
        ("@use \"nope\";\n", "1 \u{2502} @use \"nope\";\n", "^^^^^^^^^^^\n"),
        (
            "@forward \"nope\";\n",
            "1 \u{2502} @forward \"nope\";\n",
            "^^^^^^^^^^^^^^^\n",
        ),
        // a misplaced module rule carets all of itself, trailing space and all
        (
            ".a { b: c }\n@use \"nope\"   ;\n",
            "2 \u{2502} @use \"nope\"   ;\n",
            "^^^^^^^^^^^^^^\n",
        ),
        // an undefined mixin carets the `@include`, args and all
        (
            ".a { @include nope; }\n",
            "1 \u{2502} .a { @include nope; }\n",
            "^^^^^^^^^^^^^\n",
        ),
        (
            ".a { @include nope(1); }\n",
            "1 \u{2502} .a { @include nope(1); }\n",
            "^^^^^^^^^^^^^^^^\n",
        ),
        // an error about the RULE carets all of it — `using` clause and
        // content block included (dart's `span`, not `spanWithoutContent`)
        (
            ".a { @include nope using ($x) { c: $x; } }\n",
            "1 \u{2502} .a { @include nope using ($x) { c: $x; } }\n",
            "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n",
        ),
        (
            ".a { @include nope { c: d; } }\n",
            "1 \u{2502} .a { @include nope { c: d; } }\n",
            "^^^^^^^^^^^^^^^^^^^^^^^\n",
        ),
        // a module rule's span ends at the `;`, the whitespace before it
        // included, `with` clause or not
        (
            "@use \"nope\" with ($x: 1)   ;\n",
            "1 \u{2502} @use \"nope\" with ($x: 1)   ;\n",
            "^^^^^^^^^^^^^^^^^^^^^^^^^^^\n",
        ),
        (
            "@forward \"nope\" with ($x: 1)   ;\n",
            "1 \u{2502} @forward \"nope\" with ($x: 1)   ;\n",
            "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n",
        ),
        // a built-in namespace, and a namespace that is not bound at all
        (
            "@use \"sass:math\";\n.a { b: math.nope(1); }\n",
            "2 \u{2502} .a { b: math.nope(1); }\n",
            "^^^^^^^^^^^^\n",
        ),
        (
            ".a { b: nope.foo(1); }\n",
            "1 \u{2502} .a { b: nope.foo(1); }\n",
            "^^^^^^^^^^^\n",
        ),
        // an unbound namespace on an `@include` carets the whole rule
        (
            ".a { @include nope.pub; }\n",
            "1 \u{2502} .a { @include nope.pub; }\n",
            "^^^^^^^^^^^^^^^^^\n",
        ),
        // a built-in mixin's own failure carets the invocation
        (
            "@use \"sass:meta\";\n.a { @include meta.load-css(\"nope\"); }\n",
            "2 \u{2502} .a { @include meta.load-css(\"nope\"); }\n",
            "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n",
        ),
    ];
    for (src, line, caret) in cases {
        let block = err_block(src, "in.scss");
        assert!(block.contains(line), "{src:?}\n{block}");
        assert_eq!(caret_line(&block), caret.trim(), "{src:?}\n{block}");
    }
    // The mixin is not named in the message — the span says which one it is.
    assert!(
        err_block(".a { @include nope; }\n", "in.scss").starts_with("Error: Undefined mixin.\n"),
        "{}",
        err_block(".a { @include nope; }\n", "in.scss")
    );
    // A missing stylesheet names no url either.
    assert!(
        err_block("@import \"nope\";\n", "in.scss").contains("Error: Can't find stylesheet to import.\n"),
        "{}",
        err_block("@import \"nope\";\n", "in.scss")
    );
}

/// dart raises "Interpolation isn't allowed in plain CSS." at the END of
/// `singleInterpolation`, once the body has parsed and the `}` is consumed: the
/// caret spans the whole `#{…}`, and a body that is invalid on its own terms
/// reports ITSELF instead. sasso rejected the interpolation at its `#` before
/// reading it, which drew a one-column caret and pre-empted those messages.
/// Every span below was measured against dart-sass 1.104.1.
#[test]
fn a_plain_css_interpolation_carets_all_of_itself() {
    let block = |src: &str| {
        compile(
            src,
            &Options::default()
                .with_url("in.css")
                .with_syntax(sasso::Syntax::Css),
        )
        .expect_err("expected a compile error")
        .to_string()
    };
    let cases = [
        // an at-rule's name, whole or in part
        ("@#{\"media\"} (a: 1) { .x { y: z } }\n", "^^^^^^^^^^"),
        ("@med#{\"ia\"} (a: 1) { .x { y: z } }\n", "^^^^^^^"),
        // a media query's type, and a raw operand after `and`
        ("@media #{\"screen\"} { a { b: c } }\n", "^^^^^^^^^^^"),
        ("@media screen and #{\"(a: 1)\"} { a { b: c } }\n", "^^^^^^^^^^^"),
        // a `@supports` function's arguments
        ("@supports selector(#{\"a\"}) { a { b: c } }\n", "^^^^^^"),
        // a loud comment's body
        ("/* #{1} */\n", "^^^^"),
        // a custom callable's body, and a custom property's, inside a string
        ("@function --a() { result: \"#{1}\" }\n", "^^^^"),
        ("a { --x: \"#{1}\" }\n", "^^^^"),
        // a special function's verbatim arguments, and the IE `progid:` form
        ("a { b: element(#{1}) }\n", "^^^^"),
        ("a { b: element(\"#{1}\") }\n", "^^^^"),
        ("a { b: progid:DXImageTransform(#{1}) }\n", "^^^^"),
        // the modern `if()`'s raw operands: in a condition, in its function
        // name, and in a clause value the raw grammar reached first
        ("a { b: if(media(width > #{1}px): red; else: blue) }\n", "^^^^"),
        (
            "a { b: if(me#{\"dia\"}(width > 10px): red; else: blue) }\n",
            "^^^^^^^^",
        ),
        (
            "a { b: if(supports(#{\"color: red\"}): red; else: blue) }\n",
            "^^^^^^^^^^^^^^^",
        ),
        ("a { b: if(media(width > 10px): #{1}; else: blue) }\n", "^^^^"),
        // and an ordinary value, which already erred but with one caret
        ("a { b: #{1} }\n", "^^^^"),
    ];
    for (src, caret) in cases {
        let b = block(src);
        assert!(
            b.starts_with("Error: Interpolation isn't allowed in plain CSS.\n"),
            "{src:?}\n{b}"
        );
        assert_eq!(caret_line(&b), caret, "{src:?}\n{b}");
    }
    // The body reports itself first, so neither of these is the interpolation
    // error at all.
    assert!(
        block("a { b: #{$x} }\n").starts_with("Error: Sass variables aren't allowed in plain CSS.\n"),
        "{}",
        block("a { b: #{$x} }\n")
    );
    assert!(
        block("a { b: #{ } }\n").starts_with("Error: Expected expression.\n"),
        "{}",
        block("a { b: #{ } }\n")
    );
}

#[test]
fn a_namespaced_member_diagnostic_points_at_the_reference() {
    // `ns.$var` carried no position at all, so its "Undefined variable." was
    // reported against line 1 column 1 — the `@use` line, not the reference.
    let dir = std::env::temp_dir().join(format!("sasso_ns_diag_{}", std::process::id()));
    std::fs::create_dir_all(&dir).expect("mkdir");
    std::fs::write(
        dir.join("_lib.scss"),
        "@mixin -priv { a: b; }\n$pub: 1;\n$-pv: 1;\n@mixin -pr\\69 v { a: b; }\n",
    )
    .expect("write");
    let entry = dir.join("in.scss");
    let url = entry.to_string_lossy().into_owned();
    let imp = sasso::FsImporter::new(Vec::new());
    let run = |src: &str| {
        std::fs::write(&entry, src).unwrap();
        compile(src, &Options::default().with_importer(&imp).with_url(&url))
            .expect_err("expected a compile error")
            .to_string()
    };
    let block = run("@use \"lib\";\n.a { b: lib.$nope; }\n");
    assert!(block.contains("2 \u{2502} .a { b: lib.$nope; }\n"), "{block}");
    assert_eq!(caret_line(&block), "^^^^^^^^^", "{block}");
    assert!(block.contains("in.scss 2:9"), "{block}");
    // A namespaced call spans the call; a private member spans its name.
    let block = run("@use \"lib\";\n.a { b: lib.nope(1); }\n");
    assert_eq!(caret_line(&block), "^^^^^^^^^^^", "{block}");
    let block = run("@use \"lib\";\n.a { @include lib.-priv; }\n");
    assert_eq!(caret_line(&block), "^^^^^", "{block}");
    assert!(block.contains("in.scss 2:19"), "{block}");
    // The caret covers the member AS WRITTEN, so an escape inside it counts
    // its source bytes rather than the decoded ones.
    let block = run("@use \"lib\";\n.a { @include lib.-pr\\69 v; }\n");
    assert_eq!(caret_line(&block), "^^^^^^^^", "{block}");
    // A private VARIABLE reference carets the whole `ns.$name`.
    let block = run("@use \"lib\";\n.a { b: lib.$-pv; }\n");
    assert_eq!(caret_line(&block), "^^^^^^^^", "{block}");
    assert!(block.contains("in.scss 2:9"), "{block}");
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn a_span_that_crosses_lines_ends_where_dart_ends_it() {
    // A CRLF terminator is two bytes; counting it as one walked the end of a
    // multi-line span a line too far. dart ends this one on the `}` line.
    let block = err_block(
        ".a {\r\n  @include nope {\r\n    c: d;\r\n  }\r\n}\r\n",
        "in.scss",
    );
    assert!(block.contains("4 \u{2502} \u{2514}   }\n"), "{block}");
    assert!(!block.contains("5 \u{2502}"), "{block}");
    // The same file with LF terminators ends in the same place.
    let lf = err_block(".a {\n  @include nope {\n    c: d;\n  }\n}\n", "in.scss");
    assert_eq!(block.replace("\r", ""), lf);
}

#[test]
fn an_indented_include_carets_its_own_line() {
    // The braces around an indented child block are written by the front end,
    // so the text they enclose is not a source span: the caret stays on the
    // call. (dart spans the children; that needs a reconstruction-to-source
    // mapping the front end does not have.)
    let block = compile(
        ".a\n  @include nope\n    c: d\n",
        &Options::default()
            .with_syntax(sasso::Syntax::Sass)
            .with_url("in.sass"),
    )
    .expect_err("expected a compile error")
    .to_string();
    assert_eq!(caret_line(&block), "^^^^^^^^^^^^^", "{block}");
    assert!(block.contains("in.sass 2:3"), "{block}");
}

#[test]
fn an_escaped_member_name_is_not_private() {
    // dart reads privacy from the LITERAL spelling: `ns.-priv` is private,
    // `ns.\2d priv` is an ordinary member it then fails to find. A private
    // member is not in a module's public view, so the failure is "not found",
    // not "private".
    let dir = std::env::temp_dir().join(format!("sasso_esc_priv_{}", std::process::id()));
    std::fs::create_dir_all(&dir).expect("mkdir");
    std::fs::write(
        dir.join("_lib.scss"),
        "@mixin -priv { a: b; }\n@function -pf() { @return 1; }\n$-pv: 1;\n",
    )
    .expect("write");
    let entry = dir.join("in.scss");
    let url = entry.to_string_lossy().into_owned();
    let imp = sasso::FsImporter::new(Vec::new());
    let run = |src: &str| {
        std::fs::write(&entry, src).unwrap();
        compile(src, &Options::default().with_importer(&imp).with_url(&url))
            .expect_err("expected a compile error")
            .to_string()
    };
    let block = run("@use \"lib\";\n.a { @include lib.\\2d priv; }\n");
    assert!(block.starts_with("Error: Undefined mixin.\n"), "{block}");
    assert_eq!(caret_line(&block), "^^^^^^^^^^^^^^^^^^^^^", "{block}");
    let block = run("@use \"lib\";\n.a { b: lib.$\\2d pv; }\n");
    assert!(block.starts_with("Error: Undefined variable.\n"), "{block}");
    assert_eq!(caret_line(&block), "^^^^^^^^^^^", "{block}");
    let block = run("@use \"lib\";\n.a { b: lib.\\2d pf(); }\n");
    assert!(block.starts_with("Error: Undefined function.\n"), "{block}");
    // A LITERAL private member keeps dart's privacy error.
    let block = run("@use \"lib\";\n.a { @include lib.-priv; }\n");
    assert!(
        block.starts_with("Error: Private members can't be accessed from outside their modules.\n"),
        "{block}"
    );
    // The by-name API reports it missing, with the name it was asked for.
    let block = run(
        "@use \"sass:meta\";\n@use \"lib\";\n.a { b: meta.call(meta.get-function(\"-pf\", $module: \"lib\")); }\n",
    );
    assert!(
        block.starts_with("Error: Function not found: \"-pf\"\n"),
        "{block}"
    );
    assert_eq!(caret_line(&block), "^".repeat(40), "{block}");
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn a_missing_argument_points_at_the_invocation() {
    // dart reports a missing argument against the CALL — its primary span —
    // whichever path made the call, and reads the snippet from the CALLER's
    // file even though the callee's file is the current one by then.
    let dir = std::env::temp_dir().join(format!("sasso_missing_arg_{}", std::process::id()));
    std::fs::create_dir_all(&dir).expect("mkdir");
    std::fs::write(
        dir.join("_lib.scss"),
        "@function f($x) { @return $x; }\n@mixin m($x) { a: $x; }\n",
    )
    .expect("write");
    let entry = dir.join("in.scss");
    let url = entry.to_string_lossy().into_owned();
    let imp = sasso::FsImporter::new(Vec::new());
    let run = |src: &str| {
        std::fs::write(&entry, src).unwrap();
        compile(src, &Options::default().with_importer(&imp).with_url(&url))
            .expect_err("expected a compile error")
            .to_string()
    };
    // A function in the same file: the invocation IS the primary span, and
    // dart's second span points back at the declaration.
    let block = run("@function f($x) { @return $x; }\n.a { b: f(); }\n");
    assert!(block.starts_with("Error: Missing argument $x.\n"), "{block}");
    assert!(block.contains("2 \u{2502} .a { b: f(); }\n"), "{block}");
    assert_eq!(caret_line(&block), "^^^ invocation", "{block}");
    assert!(
        block.contains("1 \u{2502} @function f($x) { @return $x; }\n"),
        "{block}"
    );
    assert!(
        block.contains("\u{2501}\u{2501}\u{2501}\u{2501}\u{2501} declaration"),
        "{block}"
    );
    // A function in ANOTHER file: the snippet is the caller's line, not the
    // definition's.
    let block = run("@use \"lib\";\n.a { b: lib.f(); }\n");
    assert!(block.contains("2 \u{2502} .a { b: lib.f(); }\n"), "{block}");
    assert_eq!(caret_line(&block), "^^^^^^^ invocation", "{block}");
    assert!(block.contains("in.scss 2:9  f()"), "{block}");
    // The same for a mixin.
    let block = run("@use \"lib\";\n.a { @include lib.m; }\n");
    assert!(block.contains("2 \u{2502} .a { @include lib.m; }\n"), "{block}");
    assert_eq!(caret_line(&block), "^^^^^^^^^^^^^^ invocation", "{block}");
    // And through `meta.call`, which invokes a reference.
    let block = run(
        "@use \"sass:meta\";\n@function f($x) { @return $x; }\n.a { b: meta.call(meta.get-function(\"f\")); }\n",
    );
    assert_eq!(
        caret_line(&block),
        format!("{} invocation", "^".repeat(33)),
        "{block}"
    );
    // A built-in re-exported through `@forward` reports like a direct one.
    // It keeps the single-span block: dart points back at a declaration in
    // `sass:math`, which has no source text here to point AT.
    std::fs::write(dir.join("_fwd.scss"), "@forward \"sass:math\";\n").expect("write");
    let block = run("@use \"fwd\";\n.a { b: fwd.div(1); }\n");
    assert_eq!(caret_line(&block), "^^^^^^^^^^", "{block}");
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn a_multi_line_span_uses_the_gutter_at_a_line_edge() {
    // dart (source_span) writes the arm glyph in the GUTTER when the span
    // begins at its line's first non-whitespace character, and likewise when it
    // ends at its line's last; it draws an arrow row only for an end that
    // starts or stops mid-line. The two ends are decided separately.
    let both = err_block(".a {\n  @include nope {\n    c: d;\n  }\n}\n", "in.scss");
    assert!(
        both.contains(
            "2 \u{2502} \u{250c}   @include nope {\n3 \u{2502} \u{2502}     c: d;\n4 \u{2502} \u{2514}   }\n"
        ),
        "{both}"
    );
    assert!(!both.contains('^'), "{both}");
    // Starts mid-line, ends at the line's last character: an opening arrow row
    // and a closing gutter glyph.
    let open = err_block(".a { @include nope {\n    c: d;\n  }\n}\n", "in.scss");
    assert!(
        open.contains("\u{2502} \u{250c}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}^\n"),
        "{open}"
    );
    assert!(open.contains("3 \u{2502} \u{2514}   }\n"), "{open}");
    // Starts at the line's first character, ends mid-line: the mirror image.
    let close = err_block(".a {\n  @include nope {\n    c: d;\n  } x: y;\n}\n", "in.scss");
    assert!(
        close.contains("2 \u{2502} \u{250c}   @include nope {\n"),
        "{close}"
    );
    assert!(
        close.contains("\u{2502} \u{2514}\u{2500}\u{2500}\u{2500}^\n"),
        "{close}"
    );
}

#[test]
fn an_error_at_the_end_of_a_file_points_at_the_last_line_with_content() {
    // dart's scanner never advances into a file's trailing whitespace, so an
    // "expected …" at the end of one points at the end of the last line that
    // says something — trailing spaces on that line included.
    for (src, line, caret_col) in [
        (".a { b: c\n", 1, 10),
        (".a {\n", 1, 5),
        ("@media screen {\n  .a { b: c }\n", 2, 14),
        (".a { b: c; \n\n\n", 1, 12),
    ] {
        let block = err_block(src, "in.scss");
        assert!(block.starts_with("Error: expected \"}\".\n"), "{src:?}\n{block}");
        assert!(
            block.contains(&format!("in.scss {line}:{caret_col}")),
            "{src:?}\n{block}"
        );
        // The snippet shows that line, not the blank one after it.
        assert!(block.contains(&format!("{line} \u{2502} ")), "{src:?}\n{block}");
    }
}

#[test]
fn a_value_that_cannot_start_reports_what_was_expected() {
    // dart names what it WANTED — an expression — whatever it found there: a
    // character that cannot start one, or the end of the file.
    for src in [
        ".a { b: ; }\n",
        ".a { b: 1 + ; }\n",
        ".a { b: ) }\n",
        "@if  { a: b; }\n",
        ".a { b: \n",
        ".a { b: 1 +\n",
    ] {
        let block = err_block(src, "in.scss");
        assert!(
            block.starts_with("Error: Expected expression.\n"),
            "{src:?}\n{block}"
        );
    }
}

/// Every `formatted` warning a compile of `src` produces.
fn warnings(src: &str, url: &str) -> Vec<String> {
    use std::cell::RefCell;
    use std::rc::Rc;
    let seen: Rc<RefCell<Vec<String>>> = Rc::new(RefCell::new(Vec::new()));
    let sink = Rc::clone(&seen);
    let opts =
        Options::default()
            .with_url(url)
            .with_warn_handler(Rc::new(move |ev: &sasso::WarnEvent<'_>| {
                sink.borrow_mut().push(ev.formatted.to_string());
            }));
    let _ = compile(src, &opts);
    let out = seen.borrow().clone();
    out
}

#[test]
fn a_global_builtin_with_a_module_form_is_deprecated() {
    // dart names the member to use and carets the whole call. The mapping is
    // not mechanical — every entry below was measured against dart-sass
    // 1.103.1 — so the table is checked, not just the machinery.
    for (src, replacement, caret) in [
        (".a { b: map-get((x: 1), x); }\n", "map.get", "^^^^^^^^^^^^^^^^^^"),
        (".a { b: nth(1 2 3, 1); }\n", "list.nth", "^^^^^^^^^^^^^"),
        (
            ".a { b: percentage(0.5); }\n",
            "math.percentage",
            "^^^^^^^^^^^^^^^",
        ),
        (
            ".a { b: lighten(#fff, 10%); }\n",
            "color.adjust",
            "^^^^^^^^^^^^^^^^^^",
        ),
        (".a { b: unitless(1); }\n", "math.is-unitless", "^^^^^^^^^^^"),
        (
            ".a { b: comparable(1px, 2px); }\n",
            "math.compatible",
            "^^^^^^^^^^^^^^^^^^^^",
        ),
        (
            ".a { b: list-separator(1 2); }\n",
            "list.separator",
            "^^^^^^^^^^^^^^^^^^^",
        ),
        (
            ".a { b: str-length(\"abc\"); }\n",
            "string.length",
            "^^^^^^^^^^^^^^^^^",
        ),
        (".a { b: type-of(1); }\n", "meta.type-of", "^^^^^^^^^^"),
        (
            ".a { b: selector-parse(\"a\"); }\n",
            "selector.parse",
            "^^^^^^^^^^^^^^^^^^",
        ),
    ] {
        // A legacy colour function carries its own `[color-functions]`
        // deprecation as well; this is about the global one.
        let w: Vec<String> = warnings(src, "in.scss")
            .into_iter()
            .filter(|x| x.contains("[global-builtin]"))
            .collect();
        assert_eq!(w.len(), 1, "{src:?} -> {w:?}");
        assert!(
            w[0].starts_with(&format!(
                "DEPRECATION WARNING [global-builtin]: Global built-in functions are deprecated and will be removed in Dart Sass 3.0.0.\nUse {replacement} instead.\n\nMore info and automated migrator: https://sass-lang.com/d/import\n"
            )),
            "{src:?}\n{}",
            w[0]
        );
        assert!(w[0].contains(caret), "{src:?}\n{}", w[0]);
    }
    // A global dart KEEPS is not deprecated: a CSS function it shares a name
    // with, or one with no module form.
    for src in [
        ".a { b: abs(-1); }\n",
        ".a { b: round(1.5); }\n",
        ".a { b: min(1, 2); }\n",
        ".a { b: rgba(0, 0, 0, 0.5); }\n",
        ".a { b: ie-hex-str(#fff); }\n",
    ] {
        assert!(warnings(src, "in.scss").is_empty(), "{src:?}");
    }
    // The module form itself is never deprecated.
    assert!(warnings(
        "@use \"sass:math\";\n.a { b: math.percentage(0.5); }\n",
        "in.scss"
    )
    .is_empty());
    // The `sass:meta` predicates resolve against evaluator state and return
    // before the generic built-in dispatch: they are deprecated too.
    for (src, replacement) in [
        (
            "$x: 1;\n.a { b: variable-exists(\"x\"); }\n",
            "meta.variable-exists",
        ),
        (
            "$x: 1;\n.a { b: global-variable-exists(\"x\"); }\n",
            "meta.global-variable-exists",
        ),
        (
            "@mixin m {}\n.a { b: mixin-exists(\"m\"); }\n",
            "meta.mixin-exists",
        ),
        (
            ".a { b: function-exists(\"percentage\"); }\n",
            "meta.function-exists",
        ),
    ] {
        let w = warnings(src, "in.scss");
        assert!(
            w.iter()
                .any(|x| x.contains(&format!("Use {replacement} instead."))),
            "{src:?}\n{w:?}"
        );
    }
    // The name is matched EXACTLY: dart resolves these case-sensitively, so an
    // upper-case spelling is plain CSS to it and carries no warning.
    for src in [
        ".a { b: MAP-GET((x: 1), x); }\n",
        ".a { b: Lighten(#fff, 10%); }\n",
        ".a { b: PERCENTAGE(0.5); }\n",
    ] {
        assert!(warnings(src, "in.scss").is_empty(), "{src:?}");
    }
    // The indented syntax reports it too, at its own position.
    let seen: std::rc::Rc<std::cell::RefCell<Vec<String>>> =
        std::rc::Rc::new(std::cell::RefCell::new(Vec::new()));
    let sink = std::rc::Rc::clone(&seen);
    let opts = Options::default()
        .with_syntax(sasso::Syntax::Sass)
        .with_url("in.sass")
        .with_warn_handler(std::rc::Rc::new(move |ev: &sasso::WarnEvent<'_>| {
            sink.borrow_mut().push(ev.formatted.to_string());
        }));
    let _ = compile(".a\n  b: nth(1 2, 1)\n", &opts);
    let w = seen.borrow().clone();
    assert_eq!(w.len(), 1, "{w:?}");
    assert!(w[0].contains("in.sass 2:6"), "{}", w[0]);
}

#[test]
fn a_deprecated_function_reached_indirectly_still_warns() {
    // dart reports the global built-in a `call()` reaches — by name or through
    // a reference — against the INVOCATION, on top of the warnings for `call`
    // and `get-function` themselves. Two `[global-builtin]` warnings can
    // therefore share one span, saying different things.
    let w = warnings(".a { b: call(get-function(\"percentage\"), 0.5); }\n", "in.scss");
    assert_eq!(w.len(), 3, "{w:?}");
    assert!(w[0].contains("Use meta.get-function instead."), "{}", w[0]);
    assert!(w[1].contains("Use meta.call instead."), "{}", w[1]);
    assert!(w[2].contains("Use math.percentage instead."), "{}", w[2]);
    assert!(
        w[1].contains("in.scss 1:9") && w[2].contains("in.scss 1:9"),
        "{w:?}"
    );
    // The string form adds `[call-string]`, with the name it was given.
    let w = warnings(
        "@function foo() { @return 1; }\n.a { b: call(\"foo\"); }\n",
        "in.scss",
    );
    assert_eq!(w.len(), 2, "{w:?}");
    assert!(w[0].contains("Use meta.call instead."), "{}", w[0]);
    assert!(
        w[1].starts_with("DEPRECATION WARNING [call-string]: Passing a string to call() is deprecated and will be illegal in Dart Sass 2.0.0.\n\nRecommendation: call(get-function(\"foo\"))\n"),
        "{}",
        w[1]
    );
    // `feature-exists` is deprecated whichever way it is spelled.
    let w = warnings(".a { b: feature-exists(\"at-error\"); }\n", "in.scss");
    assert_eq!(w.len(), 2, "{w:?}");
    assert!(w[1].starts_with("DEPRECATION WARNING [feature-exists]: The feature-exists() function is deprecated.\n\nMore info: https://sass-lang.com/d/feature-exists\n"), "{}", w[1]);
    let w = warnings(
        "@use \"sass:meta\";\n.a { b: meta.feature-exists(\"at-error\"); }\n",
        "in.scss",
    );
    assert_eq!(w.len(), 1, "{w:?}");
    assert!(w[0].contains("[feature-exists]"), "{}", w[0]);
}

#[test]
fn a_deprecation_follows_the_call_that_is_actually_made() {
    // Whether a call is deprecated depends on what it RESOLVES to, not on how
    // it is spelled. Every expectation here was measured against dart-sass
    // 1.103.1.
    let dir = std::env::temp_dir().join(format!("sasso_dep_resolve_{}", std::process::id()));
    std::fs::create_dir_all(&dir).expect("mkdir");
    std::fs::write(dir.join("_fwdmeta.scss"), "@forward \"sass:meta\";\n").expect("write");
    let entry = dir.join("in.scss");
    let url = entry.to_string_lossy().into_owned();
    let imp = sasso::FsImporter::new(Vec::new());
    let run = |src: &str| {
        std::fs::write(&entry, src).unwrap();
        let seen: std::rc::Rc<std::cell::RefCell<Vec<String>>> =
            std::rc::Rc::new(std::cell::RefCell::new(Vec::new()));
        let sink = std::rc::Rc::clone(&seen);
        let opts = Options::default()
            .with_importer(&imp)
            .with_url(&url)
            .with_warn_handler(std::rc::Rc::new(move |ev: &sasso::WarnEvent<'_>| {
                sink.borrow_mut().push(ev.formatted.to_string());
            }));
        let _ = compile(src, &opts);
        let out = seen.borrow().clone();
        out
    };
    // A built-in module bound to an alias is still that module.
    let w = run("@use \"sass:meta\" as m;\n.a { b: m.feature-exists(\"at-error\"); }\n");
    assert_eq!(w.len(), 1, "{w:?}");
    assert!(w[0].contains("[feature-exists]"), "{}", w[0]);
    // So is one reached through a `@forward`.
    let w = run("@use \"fwdmeta\" as m;\n.a { b: m.feature-exists(\"at-error\"); }\n");
    assert_eq!(w.len(), 1, "{w:?}");
    assert!(w[0].contains("[feature-exists]"), "{}", w[0]);
    // A member exposed by `@use … as *` is that module's, not a global: the
    // function's own deprecation fires, the global-built-in one does not.
    let w = run("@use \"sass:meta\" as *;\n.a { b: feature-exists(\"at-error\"); }\n");
    assert_eq!(w.len(), 1, "{w:?}");
    assert!(w[0].contains("[feature-exists]"), "{}", w[0]);
    // A user `@function` wins over the global, so nothing is deprecated.
    assert!(run("@function type-of($x) { @return 1; }\n.a { b: type-of(2); }\n").is_empty());
    // A deprecated call INSIDE a deprecated one is reported first, as dart
    // reports it.
    let w = run("@use \"sass:meta\";\n.a { b: meta.feature-exists(inspect(\"at-error\")); }\n");
    assert_eq!(w.len(), 2, "{w:?}");
    assert!(w[0].contains("Use meta.inspect instead."), "{}", w[0]);
    assert!(w[1].contains("[feature-exists]"), "{}", w[1]);
    // A plain-CSS reference invokes no Sass built-in.
    assert!(run(
        "@use \"sass:meta\";\n.a { b: meta.call(meta.get-function(\"percentage\", $css: true), 1); }\n"
    )
    .is_empty());
    // `call()`'s recommendation quotes the name as Sass would write it.
    let w = run("@function a\\\"b() { @return 1; }\n.a { b: call(\"a\\\\\\\"b\"); }\n");
    assert!(
        w.iter()
            .any(|x| x.contains("Recommendation: call(get-function('a\\\\\"b'))")),
        "{w:?}"
    );
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn what_a_call_resolves_to_decides_what_is_deprecated() {
    // The underscore spelling reaches the same built-in, so it carries the same
    // deprecation; a reference taken from a module is not the global. Every
    // expectation measured against dart-sass 1.103.1.
    let w = warnings("a { b: map_get((x: 1), x); }\n", "in.scss");
    assert_eq!(w.len(), 1, "{w:?}");
    assert!(w[0].contains("Use map.get instead."), "{}", w[0]);
    // The caret covers the call as written, underscore and all.
    assert!(w[0].contains("^^^^^^^^^^^^^^^^^^"), "{}", w[0]);
    let w = warnings(
        "@use \"sass:meta\";\na { b: meta.feature_exists(\"at-error\"); }\n",
        "in.scss",
    );
    assert_eq!(w.len(), 1, "{w:?}");
    assert!(w[0].contains("[feature-exists]"), "{}", w[0]);
    let w = warnings(
        "@use \"sass:meta\" as *;\na { b: feature_exists(\"at-error\"); }\n",
        "in.scss",
    );
    assert_eq!(w.len(), 1, "{w:?}");
    assert!(w[0].contains("[feature-exists]"), "{}", w[0]);
    // A reference taken THROUGH a module is that module's member: the global
    // spelling is what is deprecated, and this is not it.
    assert!(warnings(
        "@use \"sass:meta\"; @use \"sass:math\";\na { b: meta.call(meta.get-function(\"percentage\", $module: \"math\"), 1); }\n",
        "in.scss",
    )
    .is_empty());
    // The function's OWN deprecation still fires for a module-derived one.
    let w = warnings(
        "@use \"sass:meta\";\na { b: meta.call(meta.get-function(\"feature-exists\", $module: \"meta\"), \"at-error\"); }\n",
        "in.scss",
    );
    assert_eq!(w.len(), 1, "{w:?}");
    assert!(w[0].contains("[feature-exists]"), "{}", w[0]);
    // Taken globally, it is deprecated for being global.
    let w = warnings(
        "@use \"sass:meta\";\na { b: meta.call(meta.get-function(\"percentage\"), 1); }\n",
        "in.scss",
    );
    assert_eq!(w.len(), 1, "{w:?}");
    assert!(w[0].contains("Use math.percentage instead."), "{}", w[0]);
}

#[test]
fn a_host_function_does_not_exempt_a_global_builtin() {
    // dart's `functions` do not shadow a built-in global at all: the built-in
    // runs and still warns (measured against 1.103.1's JS API with a
    // `type-of($v)` host function, which never runs).
    use std::rc::Rc;
    let cb: sasso::HostFunction = Rc::new(|_args: &[u8]| Ok(Vec::new()));
    let seen: Rc<std::cell::RefCell<Vec<String>>> = Rc::new(std::cell::RefCell::new(Vec::new()));
    let sink = Rc::clone(&seen);
    let opts = Options::default()
        .with_url("in.scss")
        .with_function("type-of($v)", cb)
        .with_warn_handler(Rc::new(move |ev: &sasso::WarnEvent<'_>| {
            sink.borrow_mut().push(ev.formatted.to_string());
        }));
    let _ = compile(".a { b: type-of(1); }\n", &opts);
    let w = seen.borrow().clone();
    assert_eq!(w.len(), 1, "{w:?}");
    assert!(w[0].contains("Use meta.type-of instead."), "{}", w[0]);
}

#[test]
fn a_forwarded_builtin_is_reachable_by_call_and_by_reference() {
    // A `@forward "sass:…"` re-exports a built-in module under the forward's
    // own name, and `_`/`-` are interchangeable in BOTH the member and the
    // prefix. Every expectation measured against dart-sass 1.103.1.
    let dir = std::env::temp_dir().join(format!("sasso_fwd_builtin_{}", std::process::id()));
    std::fs::create_dir_all(&dir).expect("mkdir");
    std::fs::write(dir.join("_plain.scss"), "@forward \"sass:map\";\n").expect("write");
    std::fs::write(dir.join("_pref.scss"), "@forward \"sass:map\" as p-*;\n").expect("write");
    std::fs::write(dir.join("_upref.scss"), "@forward \"sass:map\" as p_*;\n").expect("write");
    std::fs::write(
        dir.join("_shown.scss"),
        "@forward \"sass:string\" show to_upper_case;\n",
    )
    .expect("write");
    let entry = dir.join("in.scss");
    let url = entry.to_string_lossy().into_owned();
    let imp = sasso::FsImporter::new(Vec::new());
    let run = |src: &str| -> Result<String, String> {
        std::fs::write(&entry, src).unwrap();
        let opts = Options::default().with_importer(&imp).with_url(&url);
        compile(src, &opts).map_err(|e| e.to_string())
    };
    // The prefix and the member are both read canonically.
    for src in [
        "@use \"pref\" as p; a { b: p.p-get((x: 1), x); }",
        "@use \"pref\" as p; a { b: p.p_get((x: 1), x); }",
        "@use \"upref\" as p; a { b: p.p-get((x: 1), x); }",
        "@use \"upref\" as p; a { b: p.p_get((x: 1), x); }",
    ] {
        assert_eq!(run(src).as_deref(), Ok("a {\n  b: 1;\n}"), "{src}");
    }
    // A `show` list written with underscores accepts either spelling.
    for src in [
        "@use \"shown\" as s; a { b: s.to-upper-case(\"a\"); }",
        "@use \"shown\" as s; a { b: s.to_upper_case(\"a\"); }",
    ] {
        assert_eq!(run(src).as_deref(), Ok("a {\n  b: \"A\";\n}"), "{src}");
    }
    // `get-function($module:)` reaches a forwarded built-in, under the name the
    // forward gives it, and inspects as the MEMBER it is.
    assert_eq!(
        run("@use \"plain\" as f; @use \"sass:meta\";\na { b: meta.inspect(meta.get-function(\"get\", $module: \"f\")); }")
            .as_deref(),
        Ok("a {\n  b: get-function(\"get\");\n}")
    );
    assert_eq!(
        run("@use \"plain\" as f; @use \"sass:meta\";\na { b: meta.call(meta.get-function(\"get\", $module: \"f\"), (x: 1), x); }")
            .as_deref(),
        Ok("a {\n  b: 1;\n}")
    );
    assert_eq!(
        run("@use \"pref\" as p; @use \"sass:meta\";\na { b: meta.inspect(meta.get-function(\"p-get\", $module: \"p\")); }")
            .as_deref(),
        Ok("a {\n  b: get-function(\"get\");\n}")
    );
    // The global alias is not a member of the module, prefixed or not.
    assert!(run(
        "@use \"plain\" as f; @use \"sass:meta\";\na { b: meta.get-function(\"map-get\", $module: \"f\"); }"
    )
    .unwrap_err()
    .contains("Function not found: \"map-get\""));
    assert!(run(
        "@use \"pref\" as p; @use \"sass:meta\";\na { b: meta.get-function(\"get\", $module: \"p\"); }"
    )
    .unwrap_err()
    .contains("Function not found: \"get\""));
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn a_forward_carries_a_builtin_through_every_rule_it_passes() {
    // A `@forward "sass:…"` survives being forwarded again, its `show`/`hide`
    // match the name AS THAT RULE EXPORTS IT, and the members it exposes answer
    // to calls, references and existence queries alike. Every expectation
    // measured against dart-sass 1.103.1.
    let dir = std::env::temp_dir().join(format!("sasso_fwd_chain_{}", std::process::id()));
    std::fs::create_dir_all(&dir).expect("mkdir");
    std::fs::write(dir.join("_inner.scss"), "@forward \"sass:map\";\n").expect("write");
    std::fs::write(dir.join("_outer.scss"), "@forward \"inner\";\n").expect("write");
    std::fs::write(dir.join("_outerq.scss"), "@forward \"inner\" as q-*;\n").expect("write");
    std::fs::write(dir.join("_fmeta.scss"), "@forward \"sass:meta\";\n").expect("write");
    std::fs::write(
        dir.join("_hidepre.scss"),
        "@forward \"sass:map\" as p-* hide p-get;\n",
    )
    .expect("write");
    std::fs::write(
        dir.join("_hidebare.scss"),
        "@forward \"sass:map\" as p-* hide get;\n",
    )
    .expect("write");
    let entry = dir.join("in.scss");
    let url = entry.to_string_lossy().into_owned();
    let imp = sasso::FsImporter::new(Vec::new());
    let run = |src: &str| -> Result<String, String> {
        std::fs::write(&entry, src).unwrap();
        let opts = Options::default().with_importer(&imp).with_url(&url);
        compile(src, &opts).map_err(|e| e.to_string())
    };
    // A built-in forwarded through another module is still public, prefix and
    // all, by call and by reference.
    assert_eq!(
        run("@use \"outer\" as o; a { b: o.get((x: 1), x); }").as_deref(),
        Ok("a {\n  b: 1;\n}")
    );
    assert_eq!(
        run("@use \"outerq\" as o; a { b: o.q-get((x: 1), x); }").as_deref(),
        Ok("a {\n  b: 1;\n}")
    );
    assert_eq!(
        run("@use \"outer\" as o; @use \"sass:meta\";\na { b: meta.inspect(meta.get-function(\"get\", $module: \"o\")); }")
            .as_deref(),
        Ok("a {\n  b: get-function(\"get\");\n}")
    );
    // `show`/`hide` name the member as the rule that wrote them exports it.
    assert!(run("@use \"hidepre\" as p; a { b: p.p-get((x: 1), x); }")
        .unwrap_err()
        .contains("Undefined function."));
    assert_eq!(
        run("@use \"hidebare\" as p; a { b: p.p-get((x: 1), x); }").as_deref(),
        Ok("a {\n  b: 1;\n}")
    );
    // A forwarded `sass:meta` member that resolves against the evaluator still
    // reaches the evaluator.
    assert_eq!(
        run("$x: 1;\n@use \"fmeta\" as f; a { b: f.variable-exists(\"x\"); }").as_deref(),
        Ok("a {\n  b: true;\n}")
    );
    assert_eq!(
        run("@use \"fmeta\" as f; a { b: f.call(f.get-function(\"rgb\"), 1, 2, 3); }").as_deref(),
        Ok("a {\n  b: rgb(1, 2, 3);\n}")
    );
    // Existence queries see exactly what the call and reference paths see.
    assert_eq!(
        run("@use \"inner\" as f; @use \"sass:meta\";\na { b: meta.function-exists(\"get\", $module: \"f\"); }")
            .as_deref(),
        Ok("a {\n  b: true;\n}")
    );
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn a_forwarded_builtin_brings_its_whole_public_face() {
    // A `@forward "sass:…"` re-exports variables and mixins, not only
    // functions; an inner `show`/`hide` names the member in ITS OWN namespace
    // whatever an outer rule renames it to; and a starred user module exposes
    // what it forwards. Measured against dart-sass 1.103.1.
    let dir = std::env::temp_dir().join(format!("sasso_fwd_face_{}", std::process::id()));
    std::fs::create_dir_all(&dir).expect("mkdir");
    std::fs::write(dir.join("_fmath.scss"), "@forward \"sass:math\";\n").expect("write");
    std::fs::write(dir.join("_fmap.scss"), "@forward \"sass:map\";\n").expect("write");
    std::fs::write(
        dir.join("_ishow.scss"),
        "@forward \"sass:map\" as p-* show p-get;\n",
    )
    .expect("write");
    std::fs::write(
        dir.join("_ihide.scss"),
        "@forward \"sass:map\" as p-* hide p-get;\n",
    )
    .expect("write");
    std::fs::write(dir.join("_oshow.scss"), "@forward \"ishow\" as q-*;\n").expect("write");
    std::fs::write(dir.join("_ohide.scss"), "@forward \"ihide\" as q-*;\n").expect("write");
    std::fs::write(dir.join("_novar.scss"), "@forward \"sass:math\" hide $pi;\n").expect("write");
    std::fs::write(dir.join("_onlyvar.scss"), "@forward \"sass:math\" show $pi;\n").expect("write");
    let entry = dir.join("in.scss");
    let url = entry.to_string_lossy().into_owned();
    let imp = sasso::FsImporter::new(Vec::new());
    let run = |src: &str| -> Result<String, String> {
        std::fs::write(&entry, src).unwrap();
        let opts = Options::default().with_importer(&imp).with_url(&url);
        compile(src, &opts).map_err(|e| e.to_string())
    };
    // Variables travel with the forward, namespaced and starred alike, and a
    // `hide $pi` stops them.
    assert_eq!(
        run("@use \"fmath\" as f; a { b: f.$pi; }").as_deref(),
        Ok("a {\n  b: 3.1415926536;\n}")
    );
    assert_eq!(
        run("@use \"fmath\" as *; a { b: $pi; }").as_deref(),
        Ok("a {\n  b: 3.1415926536;\n}")
    );
    assert!(run("@use \"novar\" as f; a { b: f.$pi; }")
        .unwrap_err()
        .contains("Undefined variable."));
    assert_eq!(
        run("@use \"novar\" as f; a { b: f.floor(1.5); }").as_deref(),
        Ok("a {\n  b: 1;\n}")
    );
    // A `show` that names only variables hides every function.
    assert_eq!(
        run("@use \"onlyvar\" as f; a { b: f.$pi; }").as_deref(),
        Ok("a {\n  b: 3.1415926536;\n}")
    );
    assert!(run("@use \"onlyvar\" as f; a { b: f.floor(1.5); }")
        .unwrap_err()
        .contains("Undefined function."));
    // So do mixins: `@forward "sass:meta"` re-exports `load-css`, which then
    // fails on the STYLESHEET, not on the mixin name.
    std::fs::write(dir.join("_fmeta.scss"), "@forward \"sass:meta\";\n").expect("write");
    assert!(
        run("@use \"fmeta\" as f; a { @include f.load-css(\"nope.css\"); }")
            .unwrap_err()
            .contains("Can't find stylesheet to import.")
    );
    // An inner `show`/`hide` keeps naming the member as the INNER rule exports
    // it, even after an outer rule renames it again.
    assert_eq!(
        run("@use \"oshow\" as o; a { b: o.q-p-get((x: 1), x); }").as_deref(),
        Ok("a {\n  b: 1;\n}")
    );
    assert!(run("@use \"ohide\" as o; a { b: o.q-p-get((x: 1), x); }")
        .unwrap_err()
        .contains("Undefined function."));
    // A starred user module exposes what it forwards, to calls and to
    // introspection alike.
    assert_eq!(
        run("@use \"fmap\" as *; a { b: get((x: 1), x); }").as_deref(),
        Ok("a {\n  b: 1;\n}")
    );
    assert_eq!(
        run("@use \"fmap\" as *; @use \"sass:meta\";\na { b: meta.inspect(meta.get-function(\"get\")); }")
            .as_deref(),
        Ok("a {\n  b: get-function(\"get\");\n}")
    );
    assert_eq!(
        run("@use \"fmap\" as *; @use \"sass:meta\";\na { b: meta.function-exists(\"get\"); }").as_deref(),
        Ok("a {\n  b: true;\n}")
    );
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn every_kind_of_starred_member_competes_for_the_bare_name() {
    // `@use … as *` puts user members and built-in members (direct, or
    // forwarded by a starred user module) in ONE namespace: they shadow the
    // global, two DIFFERENT ones under a name is an error, and the same one
    // reached twice is not. Measured against dart-sass 1.103.1.
    let dir = std::env::temp_dir().join(format!("sasso_star_share_{}", std::process::id()));
    std::fs::create_dir_all(&dir).expect("mkdir");
    std::fs::write(dir.join("_fmath.scss"), "@forward \"sass:math\";\n").expect("write");
    std::fs::write(dir.join("_fmap.scss"), "@forward \"sass:map\";\n").expect("write");
    std::fs::write(dir.join("_fmeta.scss"), "@forward \"sass:meta\";\n").expect("write");
    std::fs::write(dir.join("_fstr.scss"), "@forward \"sass:string\";\n").expect("write");
    std::fs::write(dir.join("_upi.scss"), "$pi: USERPI;\n").expect("write");
    std::fs::write(
        dir.join("_uindex.scss"),
        "@function index($a, $b) { @return USER; }\n",
    )
    .expect("write");
    std::fs::write(dir.join("_umix.scss"), "@mixin load-css($x) { u: 1; }\n").expect("write");
    let entry = dir.join("in.scss");
    let url = entry.to_string_lossy().into_owned();
    let imp = sasso::FsImporter::new(Vec::new());
    let run = |src: &str| -> Result<String, String> {
        std::fs::write(&entry, src).unwrap();
        let opts = Options::default().with_importer(&imp).with_url(&url);
        compile(src, &opts).map_err(|e| e.to_string())
    };
    // The SAME member reached two ways is one member, not an ambiguity.
    assert_eq!(
        run("@use \"fmap\" as *; @use \"sass:map\" as *; a { b: get((x: 1), x); }").as_deref(),
        Ok("a {\n  b: 1;\n}")
    );
    assert_eq!(
        run("@use \"fmath\" as *; @use \"sass:math\" as *; a { b: $pi; }").as_deref(),
        Ok("a {\n  b: 3.1415926536;\n}")
    );
    // A user member and a built-in one under the same name are two members.
    for (src, what) in [
        (
            "@use \"uindex\" as *; @use \"sass:string\" as *; a { b: index(\"abc\", \"b\"); }",
            "function",
        ),
        (
            "@use \"upi\" as *; @use \"sass:math\" as *; a { b: $pi; }",
            "variable",
        ),
        (
            "@use \"umix\" as *; @use \"sass:meta\" as *; a { @include load-css(\"nope.css\"); }",
            "mixin",
        ),
    ] {
        let err = run(src).unwrap_err();
        assert!(
            err.contains(&format!("This {what} is available from multiple global modules.")),
            "{src}: {err}"
        );
    }
    // And the introspection predicates see exactly what resolution sees.
    for (src, want) in [
        (
            "@use \"sass:math\" as *; @use \"sass:meta\";\na { b: meta.global-variable-exists(\"pi\"); }",
            "true",
        ),
        (
            "@use \"fmath\" as *; @use \"sass:meta\";\na { b: meta.variable-exists(\"pi\"); }",
            "true",
        ),
        (
            "@use \"sass:meta\" as *; @use \"sass:meta\" as m;\na { b: m.mixin-exists(\"load-css\"); }",
            "true",
        ),
        (
            "@use \"fmeta\" as *; @use \"sass:meta\" as m;\na { b: m.mixin-exists(\"load-css\"); }",
            "true",
        ),
    ] {
        assert_eq!(
            run(src).as_deref(),
            Ok(format!("a {{\n  b: {want};\n}}").as_str()),
            "{src}"
        );
    }
    // A starred built-in mixin is includable and referenceable.
    assert!(
        run("@use \"sass:meta\" as *; a { @include load-css(\"nope.css\"); }")
            .unwrap_err()
            .contains("Can't find stylesheet to import.")
    );
    assert_eq!(
        run("@use \"sass:meta\" as *; a { b: inspect(get-mixin(\"load-css\")); }").as_deref(),
        Ok("a {\n  b: get-mixin(\"load-css\");\n}")
    );
    assert_eq!(
        run("@use \"fmeta\" as f; @use \"sass:meta\";\na { b: meta.inspect(meta.get-mixin(\"load-css\", $module: \"f\")); }")
            .as_deref(),
        Ok("a {\n  b: get-mixin(\"load-css\");\n}")
    );
    // An evaluator-owned `sass:meta` member reached unprefixed still reaches
    // the evaluator.
    assert!(
        run("@use \"sass:meta\" as *; a { b: inspect(module-functions(\"meta\")); }")
            .unwrap_err()
            // dart drops the article in the `module-*` functions only.
            .contains("There is no module with namespace \"meta\".")
    );
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn a_modules_own_member_shadows_the_builtin_it_forwards() {
    // A module that defines a member AND forwards a built-in exporting that
    // name exposes ONE member — its own — namespaced and starred alike; it is
    // not two members competing for the name. And a starred user mixin beside a
    // starred built-in one IS two. Measured against dart-sass 1.103.1.
    let dir = std::env::temp_dir().join(format!("sasso_own_shadow_{}", std::process::id()));
    std::fs::create_dir_all(&dir).expect("mkdir");
    std::fs::write(
        dir.join("_ownfn.scss"),
        "@forward \"sass:string\";\n@function index($a, $b) { @return OWN; }\n",
    )
    .expect("write");
    std::fs::write(dir.join("_ownvar.scss"), "@forward \"sass:math\";\n$pi: OWNPI;\n").expect("write");
    std::fs::write(
        dir.join("_ownmix.scss"),
        "@forward \"sass:meta\";\n@mixin load-css($x) { own: 1; }\n",
    )
    .expect("write");
    std::fs::write(dir.join("_umix.scss"), "@mixin load-css($x) { u: 1; }\n").expect("write");
    let entry = dir.join("in.scss");
    let url = entry.to_string_lossy().into_owned();
    let imp = sasso::FsImporter::new(Vec::new());
    let run = |src: &str| -> Result<String, String> {
        std::fs::write(&entry, src).unwrap();
        let opts = Options::default().with_importer(&imp).with_url(&url);
        compile(src, &opts).map_err(|e| e.to_string())
    };
    for (src, want) in [
        ("@use \"ownfn\" as f; a { b: f.index(\"abc\", \"b\"); }", "OWN"),
        ("@use \"ownfn\" as *; a { b: index(\"abc\", \"b\"); }", "OWN"),
        ("@use \"ownvar\" as f; a { b: f.$pi; }", "OWNPI"),
        ("@use \"ownvar\" as *; a { b: $pi; }", "OWNPI"),
    ] {
        assert_eq!(
            run(src).as_deref(),
            Ok(format!("a {{\n  b: {want};\n}}").as_str()),
            "{src}"
        );
    }
    for src in [
        "@use \"ownmix\" as f; a { @include f.load-css(\"x\"); }",
        "@use \"ownmix\" as *; a { @include load-css(\"x\"); }",
    ] {
        assert_eq!(run(src).as_deref(), Ok("a {\n  own: 1;\n}"), "{src}");
    }
    // Introspection agrees: one member, and it is the module's own.
    assert_eq!(
        run("@use \"ownfn\" as *; @use \"sass:meta\";\na { b: meta.function-exists(\"index\"); }").as_deref(),
        Ok("a {\n  b: true;\n}")
    );
    // Two starred sources for one mixin name ARE two members, whichever asks.
    assert!(
        run("@use \"umix\" as *; @use \"sass:meta\" as *;\na { b: inspect(get-mixin(\"load-css\")); }")
            .unwrap_err()
            .contains("This mixin is available from multiple global modules.")
    );
    // One star and one namespace is one member, so it resolves.
    assert_eq!(
        run("@use \"umix\" as *; @use \"sass:meta\" as m;\na { b: m.inspect(m.get-mixin(\"load-css\")); }")
            .as_deref(),
        Ok("a {\n  b: get-mixin(\"load-css\");\n}")
    );
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn a_builtin_mixin_reference_can_be_taken_and_invoked() {
    // `meta.get-mixin` reaches `load-css`/`apply` through whatever namespace
    // is bound — an alias included — and `meta.apply` then INVOKES the
    // reference it returns. Measured against dart-sass 1.103.1.
    let dir = std::env::temp_dir().join(format!("sasso_builtin_mixin_{}", std::process::id()));
    std::fs::create_dir_all(&dir).expect("mkdir");
    std::fs::write(dir.join("_fmeta.scss"), "@forward \"sass:meta\";\n").expect("write");
    std::fs::write(dir.join("real.css"), "x { loaded: 1; }\n").expect("write");
    let entry = dir.join("in.scss");
    let url = entry.to_string_lossy().into_owned();
    let imp = sasso::FsImporter::new(Vec::new());
    let run = |src: &str| -> Result<String, String> {
        std::fs::write(&entry, src).unwrap();
        let opts = Options::default().with_importer(&imp).with_url(&url);
        compile(src, &opts).map_err(|e| e.to_string())
    };
    // An ALIASED built-in namespace is still that module.
    for src in [
        "@use \"sass:meta\" as m; a { b: m.inspect(m.get-mixin(\"load-css\", $module: \"m\")); }",
        "@use \"sass:meta\"; a { b: meta.inspect(meta.get-mixin(\"load-css\", $module: \"meta\")); }",
    ] {
        assert_eq!(
            run(src).as_deref(),
            Ok("a {\n  b: get-mixin(\"load-css\");\n}"),
            "{src}"
        );
    }
    // And the reference is invocable, however it was obtained.
    for src in [
        "@use \"sass:meta\";\na { @include meta.apply(meta.get-mixin(\"load-css\", $module: \"meta\"), \"real\"); }",
        "@use \"fmeta\" as f;\na { @include f.apply(f.get-mixin(\"load-css\", $module: \"f\"), \"real\"); }",
        "@use \"sass:meta\" as *;\na { @include apply(get-mixin(\"load-css\"), \"real\"); }",
    ] {
        assert_eq!(run(src).as_deref(), Ok("a x {\n  loaded: 1;\n}"), "{src}");
    }
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn a_mixin_reached_through_a_reference_reports_where_it_was_included() {
    // An error raised inside a first-class `load-css` carets the `@include`
    // that reached it, exactly as a direct one does — and a bare `@include`
    // that two starred modules both answer carets the same statement.
    // Measured against dart-sass 1.103.1.
    let dir = std::env::temp_dir().join(format!("sasso_ref_span_{}", std::process::id()));
    std::fs::create_dir_all(&dir).expect("mkdir");
    std::fs::write(dir.join("_umix.scss"), "@mixin load-css($x) { u: 1; }\n").expect("write");
    let entry = dir.join("in.scss");
    let url = entry.to_string_lossy().into_owned();
    let imp = sasso::FsImporter::new(Vec::new());
    let run = |src: &str| -> String {
        std::fs::write(&entry, src).unwrap();
        let opts = Options::default().with_importer(&imp).with_url(&url);
        compile(src, &opts)
            .expect_err("expected a compile error")
            .to_string()
    };
    // The reference and the direct call caret the same statement, `;` included.
    let via_ref = run(
        "@use \"sass:meta\";\na {\n  @include meta.apply(meta.get-mixin(\"load-css\", $module: \"meta\"), \"nope\");\n}\n",
    );
    assert!(
        via_ref.starts_with("Error: Can't find stylesheet to import."),
        "{via_ref}"
    );
    assert_eq!(caret_line(&via_ref).len(), 72, "{via_ref}");
    let direct = run("@use \"sass:meta\";\na {\n  @include meta.load-css(\"nope\");\n}\n");
    assert_eq!(caret_line(&direct).len(), 30, "{direct}");
    // An argument error from the reference reports the same way.
    let bad_arg = run(
        "@use \"sass:meta\";\na {\n  @include meta.apply(meta.get-mixin(\"load-css\", $module: \"meta\"), 1);\n}\n",
    );
    assert!(
        bad_arg.starts_with("Error: $url: 1 is not a string."),
        "{bad_arg}"
    );
    assert_eq!(caret_line(&bad_arg).len(), 67, "{bad_arg}");
    // Two starred modules answering one `@include` caret the include. (dart
    // adds a secondary row per `@use`, which this renderer cannot draw yet.)
    let ambiguous =
        run("@use \"umix\" as *;\n@use \"sass:meta\" as *;\na {\n  @include load-css(\"nope\");\n}\n");
    assert!(
        ambiguous.starts_with("Error: This mixin is available from multiple global modules."),
        "{ambiguous}"
    );
    assert_eq!(caret_line(&ambiguous).len(), 25, "{ambiguous}");
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn a_builtin_mixin_answers_to_its_underscore_spelling() {
    // `_` and `-` are one character in a Sass identifier, for `sass:meta`'s
    // mixins as for everything else — by call, by reference, and by existence
    // query. Measured against dart-sass 1.103.1.
    let dir = std::env::temp_dir().join(format!("sasso_mixin_under_{}", std::process::id()));
    std::fs::create_dir_all(&dir).expect("mkdir");
    std::fs::write(dir.join("_fmeta.scss"), "@forward \"sass:meta\";\n").expect("write");
    std::fs::write(dir.join("real.css"), "x { loaded: 1; }\n").expect("write");
    let entry = dir.join("in.scss");
    let url = entry.to_string_lossy().into_owned();
    let imp = sasso::FsImporter::new(Vec::new());
    let run = |src: &str| -> Result<String, String> {
        std::fs::write(&entry, src).unwrap();
        let opts = Options::default().with_importer(&imp).with_url(&url);
        compile(src, &opts).map_err(|e| e.to_string())
    };
    // Every route to the mixin takes either spelling.
    for src in [
        "@use \"sass:meta\"; a { @include meta.load_css(\"real\"); }",
        "@use \"sass:meta\"; a { @include meta.load-css(\"real\"); }",
        "@use \"sass:meta\" as m; a { @include m.load_css(\"real\"); }",
        "@use \"sass:meta\" as *; a { @include load_css(\"real\"); }",
        "@use \"fmeta\" as f; a { @include f.load_css(\"real\"); }",
    ] {
        assert_eq!(run(src).as_deref(), Ok("a x {\n  loaded: 1;\n}"), "{src}");
    }
    // A reference is stored canonically, so it inspects and compares as one.
    assert_eq!(
        run("@use \"sass:meta\";\na { b: meta.inspect(meta.get-mixin(\"load_css\", $module: \"meta\")); }")
            .as_deref(),
        Ok("a {\n  b: get-mixin(\"load-css\");\n}")
    );
    assert_eq!(
        run("@use \"sass:meta\";\na { b: meta.get-mixin(\"load_css\", $module: \"meta\") == meta.get-mixin(\"load-css\", $module: \"meta\"); }")
            .as_deref(),
        Ok("a {\n  b: true;\n}")
    );
    // And the existence query agrees with both.
    assert_eq!(
        run("@use \"sass:meta\";\na { b: meta.mixin-exists(\"load_css\", $module: \"meta\"); }").as_deref(),
        Ok("a {\n  b: true;\n}")
    );
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn call_by_name_resolves_what_the_name_would_have() {
    // `call("name")` looks the name up exactly as writing it would: a user
    // `@function`, then a member a `@use … as *` exposes (user or built-in),
    // then the global — ambiguity included. Measured against dart-sass 1.103.1.
    let dir = std::env::temp_dir().join(format!("sasso_call_name_{}", std::process::id()));
    std::fs::create_dir_all(&dir).expect("mkdir");
    std::fs::write(dir.join("_fmap.scss"), "@forward \"sass:map\";\n").expect("write");
    std::fs::write(dir.join("_own.scss"), "@function own($x) { @return OWN; }\n").expect("write");
    std::fs::write(
        dir.join("_uindex.scss"),
        "@function index($a, $b) { @return USER; }\n",
    )
    .expect("write");
    let entry = dir.join("in.scss");
    let url = entry.to_string_lossy().into_owned();
    let imp = sasso::FsImporter::new(Vec::new());
    let run = |src: &str| -> Result<String, String> {
        std::fs::write(&entry, src).unwrap();
        let opts = Options::default().with_importer(&imp).with_url(&url);
        compile(src, &opts).map_err(|e| e.to_string())
    };
    for (src, want) in [
        (
            "@use \"sass:map\" as *; @use \"sass:meta\";\na { b: meta.call(\"get\", (x: 1), x); }",
            "1",
        ),
        (
            "@use \"fmap\" as *; @use \"sass:meta\";\na { b: meta.call(\"get\", (x: 1), x); }",
            "1",
        ),
        (
            "@use \"own\" as *; @use \"sass:meta\";\na { b: meta.call(\"own\", 1); }",
            "OWN",
        ),
        (
            "@use \"sass:string\" as *; @use \"sass:meta\";\na { b: meta.call(\"index\", \"abc\", \"b\"); }",
            "2",
        ),
    ] {
        assert_eq!(
            run(src).as_deref(),
            Ok(format!("a {{\n  b: {want};\n}}").as_str()),
            "{src}"
        );
    }
    // Two starred sources for the name is the same error it would be written.
    assert!(run(
        "@use \"uindex\" as *; @use \"sass:string\" as *; @use \"sass:meta\";\na { b: meta.call(\"index\", \"abc\", \"b\"); }"
    )
    .unwrap_err()
    .contains("This function is available from multiple global modules."));
    // A name nothing owns is still left to the plain-CSS dispatcher.
    assert_eq!(
        run("@use \"sass:meta\"; a { b: meta.call(\"nope\", 1); }").as_deref(),
        Ok("a {\n  b: nope(1);\n}")
    );
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn one_span_can_carry_two_call_string_recommendations() {
    // The dedup identity is everything the warning SAYS: `[call-string]`'s
    // message is static and its `Recommendation:` carries the name, so one
    // `call($n)` invoked with two names warns twice. dart prints both.
    let w = warnings(
        "@use \"sass:meta\";\n@function pick($n) { @return meta.call($n, 1); }\n@function a($x) { @return A; }\n@function b($x) { @return B; }\n.x { p: pick(\"a\"); q: pick(\"b\"); }\n",
        "in.scss",
    );
    let recs: Vec<&String> = w.iter().filter(|x| x.contains("[call-string]")).collect();
    assert_eq!(recs.len(), 2, "{w:?}");
    assert!(
        recs[0].contains("Recommendation: call(get-function(\"a\"))"),
        "{}",
        recs[0]
    );
    assert!(
        recs[1].contains("Recommendation: call(get-function(\"b\"))"),
        "{}",
        recs[1]
    );
}

#[test]
fn a_legacy_color_function_suggests_its_replacement() {
    // dart computes the suggestion from the call's OWN arguments: a channel
    // getter names the channel and its space, an adjuster offers the relative
    // `color.scale` (whose percentage depends on where the colour already is)
    // and the absolute `color.adjust`. Every expectation measured against
    // dart-sass 1.103.1.
    let sug = |src: &str| -> Vec<String> {
        warnings(src, "in.scss")
            .into_iter()
            .filter(|w| w.contains("[color-functions]"))
            .collect()
    };
    let one = |src: &str| -> String {
        let w = sug(src);
        assert_eq!(w.len(), 1, "{src}: {w:?}");
        w.into_iter().next().unwrap()
    };
    // Channel getters name the space, because `color.channel` would otherwise
    // default to the colour's own.
    for (name, space) in [
        ("red", "rgb"),
        ("green", "rgb"),
        ("blue", "rgb"),
        ("hue", "hsl"),
        ("saturation", "hsl"),
        ("lightness", "hsl"),
    ] {
        let w = one(&format!("a {{ b: {name}(#abcdef); }}\n"));
        assert!(w.contains(&format!("{name}() is deprecated. Suggestion:")), "{w}");
        assert!(
            w.contains(&format!("color.channel($color, \"{name}\", $space: {space})")),
            "{w}"
        );
    }
    // Through the module it names itself `color.<fn>`, under any namespace.
    for src in [
        "@use \"sass:color\";\na { b: color.whiteness(#abcdef); }\n",
        "@use \"sass:color\" as c;\na { b: c.whiteness(#abcdef); }\n",
        "@use \"sass:color\" as *;\na { b: whiteness(#abcdef); }\n",
    ] {
        let w = one(src);
        assert!(w.contains("color.whiteness() is deprecated."), "{src}: {w}");
        assert!(
            w.contains("color.channel($color, \"whiteness\", $space: hwb)"),
            "{src}: {w}"
        );
    }
    // The adjusters: the scale percentage is the move over the room left in
    // that direction, clamped, and omitted when the move is zero.
    for (src, scale, adjust) in [
        (
            "a { b: lighten(#abcdef, 10%); }\n",
            Some("51%"),
            "$lightness: 10%",
        ),
        (
            "a { b: darken(#abcdef, 10%); }\n",
            Some("-12.4390243902%"),
            "$lightness: -10%",
        ),
        (
            "a { b: saturate(#abcdef, 10%); }\n",
            Some("31.25%"),
            "$saturation: 10%",
        ),
        (
            "a { b: desaturate(#abcdef, 10%); }\n",
            Some("-14.7058823529%"),
            "$saturation: -10%",
        ),
        (
            "a { b: opacify(rgba(1, 2, 3, 0.5), 0.1); }\n",
            Some("$alpha: 20%"),
            "$alpha: 0.1",
        ),
        (
            "a { b: transparentize(rgba(1, 2, 3, 0.5), 0.1); }\n",
            Some("$alpha: -20%"),
            "$alpha: -0.1",
        ),
        // Already at the bound: all the way, however much was asked.
        ("a { b: lighten(#fff, 10%); }\n", Some("100%"), "$lightness: 10%"),
        ("a { b: darken(#000, 10%); }\n", Some("-100%"), "$lightness: -10%"),
        // Past the bound clamps rather than exceeding 100%.
        ("a { b: lighten(#ccc, 50%); }\n", Some("100%"), "$lightness: 50%"),
        // A hue is an angle with no bound, so it never scales.
        ("a { b: adjust-hue(#abcdef, 10deg); }\n", None, "$hue: 10deg"),
        ("a { b: adjust-hue(#abcdef, 0.25turn); }\n", None, "$hue: 90deg"),
        // Moving by nothing drops the scale line entirely.
        ("a { b: saturate(#abcdef, 0%); }\n", None, "$saturation: 0%"),
        // A MISSING alpha is 0, not the opaque 1 the color carries for
        // serialization, so the room left is the whole range: opacifying by
        // 0.2 is 20% of the way up, and transparentizing is all the way down.
        (
            "a { b: opacify(hsl(240 100% 50% / none), 0.2); }\n",
            Some("$alpha: 20%"),
            "$alpha: 0.2",
        ),
        (
            "a { b: transparentize(hsl(240 100% 50% / none), 0.2); }\n",
            Some("$alpha: -100%"),
            "$alpha: -0.2",
        ),
    ] {
        let w = one(src);
        match scale {
            Some(s) => {
                assert!(w.contains("Suggestions:"), "{src}: {w}");
                assert!(w.contains("color.scale($color, "), "{src}: {w}");
                assert!(w.contains(s), "{src}: {w}");
            }
            None => {
                assert!(w.contains("Suggestion:"), "{src}: {w}");
                assert!(!w.contains("color.scale"), "{src}: {w}");
            }
        }
        assert!(
            w.contains(&format!("color.adjust($color, {adjust})")),
            "{src}: {w}"
        );
    }
    // The amount is read as a value, so a unitless one still suggests `%`.
    assert!(one("a { b: lighten(#abcdef, 10); }\n").contains("$lightness: 10%"));
    // Named arguments are read under the parameter name the FUNCTION uses,
    // which is not uniform: `adjust-hue` binds `$degrees`, the rest `$amount`.
    assert!(one("a { b: lighten($color: #abcdef, $amount: 10%); }\n").contains("$lightness: 10%"));
    assert!(one("a { b: adjust-hue($color: #abcdef, $degrees: 10deg); }\n")
        .contains("color.adjust($color, $hue: 10deg)"));
    // `whiteness`/`blackness` are `sass:color`-ONLY, so the bare spelling is a
    // plain CSS function that deprecates nothing — however it is reached.
    assert!(sug("a { b: whiteness(#abcdef); }\n").is_empty());
    assert!(sug("a { b: blackness(#abcdef); }\n").is_empty());
    assert!(sug("@use \"sass:meta\"; a { b: meta.call(\"whiteness\", #abcdef); }\n").is_empty());
    // A user `@function` of a deprecated name is the one that runs.
    assert!(sug("@function lighten($c, $n) { @return MINE; }\na { b: lighten(#abcdef, 10%); }\n").is_empty());
    // Members that were NOT deprecated stay quiet.
    for src in [
        "a { b: alpha(rgba(1, 2, 3, 0.5)); }\n",
        "a { b: mix(#abcdef, #123456); }\n",
        "a { b: grayscale(#abcdef); }\n",
        "a { b: complement(#abcdef); }\n",
        "a { b: invert(#abcdef); }\n",
    ] {
        assert!(sug(src).is_empty(), "{src}");
    }
    // A call whose arguments are rejected warns about nothing: dart raises
    // this from INSIDE the function, after they are validated.
    assert!(sug("a { b: lighten(3, 10%); }\n").is_empty());
    assert!(sug("a { b: lighten(#abcdef, 150%); }\n").is_empty());
    // A first-class reference reaches the same function, so it carries the
    // same deprecation — computed suggestion and all — reported against the
    // INVOCATION.
    let w = one("@use \"sass:meta\";\na { b: meta.call(meta.get-function(\"lighten\"), #abcdef, 10%); }\n");
    assert!(w.contains("lighten() is deprecated. Suggestions:"), "{w}");
    assert!(w.contains("color.scale($color, $lightness: 51%)"), "{w}");
    let w = one("a { b: call(\"darken\", #abcdef, 10%); }\n");
    assert!(
        w.contains("color.scale($color, $lightness: -12.4390243902%)"),
        "{w}"
    );
    // Taken from the MODULE it names itself that way — and `color.whiteness`
    // is reachable only that way.
    let w = one(
        "@use \"sass:meta\"; @use \"sass:color\";\na { b: meta.call(meta.get-function(\"whiteness\", $module: \"color\"), #abcdef); }\n",
    );
    assert!(w.contains("color.whiteness() is deprecated."), "{w}");
    assert!(
        w.contains("color.channel($color, \"whiteness\", $space: hwb)"),
        "{w}"
    );
    // An `hsl()` colour keeps its channels, and the scale percentage divides
    // by the room left in one — so it is read from the colour, not re-derived.
    let w = one("a { b: saturate(hsl(20, 99.9999%, 50%), 0.00001%); }\n");
    assert!(w.contains("$saturation: 9.9999999997%"), "{w}");
    // And the suggestion follows the VALUE, so one call site can warn twice.
    let w = sug(
        "@mixin m($c) { b: lighten($c, 10%); }\na { @include m(#abcdef); }\nd { @include m(#123456); }\n",
    );
    assert_eq!(w.len(), 2, "{w:?}");
    assert!(w[0].contains("$lightness: 51%"), "{}", w[0]);
    assert!(w[1].contains("$lightness: 12.5615763547%"), "{}", w[1]);
}

#[test]
fn the_legacy_if_suggests_the_modern_syntax() {
    // dart raises `[if-function]` when the file is PARSED: for an `if()` nobody
    // runs, once however many times it does run, innermost first, and with no
    // call stack. The suggestion is the three arguments written back out — the
    // AST, not the source text. Measured against dart-sass 1.103.1.
    let sug = |src: &str| -> Vec<String> { warnings(src, "in.scss") };
    let one = |src: &str| -> String {
        let w = sug(src);
        assert_eq!(w.len(), 1, "{src}: {w:?}");
        w.into_iter().next().unwrap()
    };
    assert!(one("a { b: if(true, 1, 2); }\n").contains("Suggestion: if(sass(true): 1; else: 2)"));
    // The AST is written back out, so the text is normalized, not copied.
    for (src, want) in [
        ("a { b: if(true,1+2,3); }\n", "if(sass(true): 1 + 2; else: 3)"),
        ("a { b: if( true , 1 , 2 ); }\n", "if(sass(true): 1; else: 2)"),
        ("a { b: if(true, 1e3, 2); }\n", "if(sass(true): 1000; else: 2)"),
        (
            "a { b: if(true, 1px*2, 3); }\n",
            "if(sass(true): 1px * 2; else: 3)",
        ),
        (
            "a { b: if(true, #ABCDEF, 3); }\n",
            "if(sass(true): #ABCDEF; else: 3)",
        ),
        (
            "a { b: if(true, \"a\\41 b\", 3); }\n",
            "if(sass(true): \"aAb\"; else: 3)",
        ),
        (
            "a { b: if(true, 'he said \"hi\"', 3); }\n",
            "if(sass(true): 'he said \"hi\"'; else: 3)",
        ),
        (
            "$v: 1;\na { b: if(true, \"x#{$v}y\", 3); }\n",
            "if(sass(true): \"x#{$v}y\"; else: 3)",
        ),
        ("a { b: if(true, (1 2), 3); }\n", "if(sass(true): (1 2); else: 3)"),
        (
            "a { b: if(true, (a: 1), 2); }\n",
            "if(sass(true): (a: 1); else: 2)",
        ),
        ("a { b: if(true, [], 2); }\n", "if(sass(true): []; else: 2)"),
        ("a { b: if(true, (), 2); }\n", "if(sass(true): (); else: 2)"),
        // A one-element comma list needs the parens that make it a list, and
        // the trailing comma with them — but inside brackets it needs neither.
        ("a { b: if(true, (1,), 2); }\n", "if(sass(true): ((1,)); else: 2)"),
        ("a { b: if(true, [1,], 2); }\n", "if(sass(true): [1]; else: 2)"),
        (
            "a { b: if(true, (1, 2), 3); }\n",
            "if(sass(true): (1, 2); else: 3)",
        ),
        ("a { b: if(not true, 1, 2); }\n", "if(sass(not true): 1; else: 2)"),
        (
            "$v: 1;\na { b: if($v > 1, 1, 2); }\n",
            "if(sass($v > 1): 1; else: 2)",
        ),
        // A `null` branch is dropped, and a null THEN flips the condition.
        ("a { b: if(true, 1, null); }\n", "if(sass(true): 1)"),
        ("$v: 1;\na { b: if($v, null, 2); }\n", "if(not sass($v): 2)"),
        ("a { b: if(true, null, null); }\n", "if(sass(true): null)"),
    ] {
        let w = one(src);
        assert!(w.contains(&format!("Suggestion: {want}")), "{src}: {w}");
    }
    // No suggestion for a shape the rewrite cannot express — the deprecation
    // still fires.
    for src in [
        "a { b: if($condition: true, $if-true: 1, $if-false: 2); }\n",
        "$a: (true, 1, 2);\na { b: if($a...); }\n",
    ] {
        let w = one(src);
        assert!(w.contains("[if-function]"), "{src}: {w}");
        assert!(!w.contains("Suggestion:"), "{src}: {w}");
    }
    // Innermost first, because dart builds the expression bottom up.
    let w = sug("a { b: if(true, if(false, 1, 2), 3); }\n");
    assert_eq!(w.len(), 2, "{w:?}");
    assert!(w[0].contains("if(sass(false): 1; else: 2)"), "{}", w[0]);
    assert!(
        w[1].contains("if(sass(true): if(false, 1, 2); else: 3)"),
        "{}",
        w[1]
    );
    // PARSE time: it fires for code that never runs, and once for code that
    // runs repeatedly.
    assert_eq!(sug("@mixin m { z: if(true, 1, 2); }\na { q: 1; }\n").len(), 1);
    assert_eq!(
        sug("@if false { a { z: if(true, 1, 2); } }\nb { q: 1; }\n").len(),
        1
    );
    assert_eq!(
        sug("@mixin m($x) { z: if($x, 1, 2); }\na { @include m(true); }\nb { @include m(false); }\n").len(),
        1
    );
    assert_eq!(
        sug("@for $i from 1 through 3 { a#{$i} { z: if(true, 1, 2); } }\n").len(),
        1
    );
    // And it has no call stack: the frame is the file, not the mixin.
    let w = one("@mixin m($x) { z: if($x, 1, 2); }\na { @include m(true); }\n");
    assert_eq!(w.matches("root stylesheet").count(), 1, "{w}");
    assert!(!w.contains("m()"), "{w}");
    // An interpolated string escapes its literal text like any other, so a
    // newline in the source is `\a` in the suggestion rather than a newline in
    // the middle of the diagnostic.
    assert!(one("$x: 1;\na { b: if(true, \"a\\a #{$x}\", 3); }\n")
        .contains("Suggestion: if(sass(true): \"a\\a#{$x}\"; else: 3)"));
    // The single-`=` filter operator is written with spaces, as dart writes it.
    assert!(one("a { b: if(true, alpha(opacity=80), 3); }\n")
        .contains("Suggestion: if(sass(true): alpha(opacity = 80); else: 3)"));
    // A user `@function if` does not take the form over, in dart or here.
    assert_eq!(
        sug("@function if($c, $t, $f) { @return 9; }\na { b: if(true, 1, 2); }\n").len(),
        1
    );
    // It is found wherever an expression can be written.
    for src in [
        "a { z: #{if(true, 1, 2)}; }\n",
        "a#{if(true, x, y)} { q: 1; }\n",
        "@media (min-width: if(true, 1px, 2px)) { a { q: 1; } }\n",
        "@supports (a: if(true, 1, 2)) { b { q: 1; } }\n",
        "@each $i in if(true, 1 2, 3) { a { q: $i; } }\n",
        "@mixin m($p: if(true, 1, 2)) { q: $p; }\na { @include m; }\n",
        "@warn if(true, \"w\", \"v\");\na { q: 1; }\n",
        "/* c #{if(true, 1, 2)} */\n",
        "@import url(if(true, a, b));\n",
        "@mixin m { @content(if(true, 1, 2)); }\na { @include m using ($x) { q: $x; } }\n",
        "%p { q: 1; }\na { @extend #{if(true, \"%p\", \"%p\")}; }\n",
        // A custom at-rule's INTERPOLATED property and its value are
        // SassScript; a literal property's value is verbatim text here (dart
        // parses that one as SassScript too — a separate gap, in the CSS).
        "@function --foo() { #{if(true, x, y)}: 1; }\n",
        "@keyframes #{if(true, fade, none)} { from { o: 0; } }\n",
    ] {
        // `@warn` adds its own output; this is about the deprecation.
        let found: Vec<String> = sug(src)
            .into_iter()
            .filter(|w| w.contains("[if-function]"))
            .collect();
        assert_eq!(found.len(), 1, "{src}: {found:?}");
    }
}

#[test]
fn an_argument_error_shows_the_declaration_it_failed_against() {
    // dart points at TWO places for the argument-binding family: where the
    // call is, and the parameter list it was measured against. Every block
    // below was measured against dart-sass 1.103.1.
    let dir = std::env::temp_dir().join(format!("sasso_decl_span_{}", std::process::id()));
    std::fs::create_dir_all(&dir).expect("mkdir");
    std::fs::write(dir.join("_lib.scss"), "@mixin m($x) { a: $x; }\n").expect("write");
    let entry = dir.join("in.scss");
    let url = entry.to_string_lossy().into_owned();
    let imp = sasso::FsImporter::new(Vec::new());
    let run = |src: &str| -> String {
        std::fs::write(&entry, src).unwrap();
        compile(src, &Options::default().with_importer(&imp).with_url(&url))
            .expect_err("expected a compile error")
            .to_string()
    };
    // The arity message counts what was declared against what was passed, and
    // agrees with itself about the verb.
    for (src, message) in [
        (
            "@function f() { @return 1; }\n.a { b: f(1); }\n",
            "Only 0 arguments allowed, but 1 was passed.",
        ),
        (
            "@function f($x) { @return 1; }\n.a { b: f(1, 2); }\n",
            "Only 1 argument allowed, but 2 were passed.",
        ),
        (
            "@function f($x, $y) { @return 1; }\n.a { b: f(1, 2, 3); }\n",
            "Only 2 arguments allowed, but 3 were passed.",
        ),
    ] {
        let block = run(src);
        assert!(block.starts_with(&format!("Error: {message}\n")), "{block}");
        assert!(block.contains(" declaration\n"), "{block}");
        assert!(caret_line(&block).ends_with(" invocation"), "{block}");
    }
    // `No parameter named` carries it too.
    let block = run("@function f($x) { @return 1; }\n.a { b: f(1, $z: 2); }\n");
    assert!(block.starts_with("Error: No parameter named $z.\n"), "{block}");
    assert!(
        block.contains("\u{2501}\u{2501}\u{2501}\u{2501}\u{2501} declaration"),
        "{block}"
    );
    // A content block a mixin does not take: the call is the primary span,
    // the mixin NAME the secondary — and the trace starts at the caller,
    // because the mixin is never entered.
    let block = run("@mixin m { a: 1; }\n.a { @include m { b: 2; } }\n");
    assert!(
        block.starts_with("Error: Mixin doesn't accept a content block.\n"),
        "{block}"
    );
    assert!(block.contains("\u{2501} declaration"), "{block}");
    assert_eq!(caret_line(&block), "^^^^^^^^^^ invocation", "{block}");
    assert!(!block.contains("m()"), "{block}");
    // A declaration in ANOTHER file gets its own block, headed by its url.
    let block = run("@use \"lib\";\n.a { @include lib.m; }\n");
    assert!(block.contains("\u{250c}\u{2500}\u{2500}> "), "{block}");
    assert!(block.contains("_lib.scss"), "{block}");
    assert!(
        block.contains("\u{2501}\u{2501}\u{2501}\u{2501}\u{2501} declaration"),
        "{block}"
    );
    std::fs::remove_dir_all(&dir).ok();
}

/// Everything up to and including the block's closing gutter glyph — the part
/// that does not name a temporary directory.
fn snippet(block: &str) -> String {
    let lines: Vec<&str> = block.lines().collect();
    let end = lines
        .iter()
        .rposition(|l| l.trim() == "\u{2575}")
        .unwrap_or_else(|| panic!("no closing glyph in:\n{block}"));
    lines[..=end].join("\n")
}

#[test]
fn a_span_that_crosses_lines_draws_an_arm_down_to_its_label() {
    // dart draws an arm beside every line a span covers and hangs the label on
    // the row that closes it — and one such span anywhere indents EVERY line of
    // the diagnostic by the arm column, blank arm included. Each block below is
    // dart-sass 1.103.1's, byte for byte.
    let run = |src: &str| -> String {
        snippet(
            &compile(src, &Options::default().with_url("t.scss"))
                .expect_err("expected a compile error")
                .to_string(),
        )
    };
    // A call that starts mid-line opens with an arrow row; the closing row
    // points at the last spanned character.
    assert_eq!(
        run("@mixin m($x) { a: $x; }\n.a { @include m(\n); }\n"),
        "Error: Missing argument $x.\n  \u{2577}\n\
         1 \u{2502}   @mixin m($x) { a: $x; }\n  \u{2502}          \u{2501}\u{2501}\u{2501}\u{2501}\u{2501} declaration\n\
         2 \u{2502}   .a { @include m(\n  \u{2502} \u{250c}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}^\n\
         3 \u{2502} \u{2502} ); }\n  \u{2502} \u{2514}\u{2500}^ invocation\n  \u{2575}"
    );
    // A call that starts its line puts the arm in the gutter instead; one that
    // also ENDS its line has nothing to point at, so dart draws a flat arm.
    assert_eq!(
        run("@mixin m($x) { a: $x; }\n@include m(\n)\n;\n"),
        "Error: Missing argument $x.\n  \u{2577}\n\
         1 \u{2502}   @mixin m($x) { a: $x; }\n  \u{2502}          \u{2501}\u{2501}\u{2501}\u{2501}\u{2501} declaration\n\
         2 \u{2502} \u{250c} @include m(\n\
         3 \u{2502} \u{2502} )\n  \u{2502} \u{2514}\u{2500}\u{2500}\u{2500} invocation\n  \u{2575}"
    );
    // The DECLARATION crossing lines is the same shape — it just comes first.
    assert_eq!(
        run("@mixin m(\n  $x: 1\n) { a: $x; }\n.a { @include m(1, 2); }\n"),
        "Error: Only 1 argument allowed, but 2 were passed.\n  \u{2577}\n\
         1 \u{2502}   @mixin m(\n  \u{2502} \u{250c}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}^\n\
         2 \u{2502} \u{2502}   $x: 1\n\
         3 \u{2502} \u{2502} ) { a: $x; }\n  \u{2502} \u{2514}\u{2500}^ declaration\n\
         4 \u{2502}   .a { @include m(1, 2); }\n  \u{2502}        ^^^^^^^^^^^^^^^^ invocation\n  \u{2575}"
    );
    // Both crossing lines: two arms, one after the other.
    assert_eq!(
        run("@mixin m(\n  $x: 1\n) { a: $x; }\n.a { @include m(\n  1, 2\n); }\n"),
        "Error: Only 1 argument allowed, but 2 were passed.\n  \u{2577}\n\
         1 \u{2502}   @mixin m(\n  \u{2502} \u{250c}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}^\n\
         2 \u{2502} \u{2502}   $x: 1\n\
         3 \u{2502} \u{2502} ) { a: $x; }\n  \u{2502} \u{2514}\u{2500}^ declaration\n\
         4 \u{2502}   .a { @include m(\n  \u{2502} \u{250c}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}^\n\
         5 \u{2502} \u{2502}   1, 2\n\
         6 \u{2502} \u{2502} ); }\n  \u{2502} \u{2514}\u{2500}^ invocation\n  \u{2575}"
    );
    // An elision and an arm at once: the gutter widens and left-aligns, and the
    // `...` row carries no arm.
    assert_eq!(
        run("@mixin m($x) { a: $x; }\n// pad\n// pad\n.a { @include m(\n); }\n"),
        "Error: Missing argument $x.\n    \u{2577}\n\
         1   \u{2502}   @mixin m($x) { a: $x; }\n    \u{2502}          \u{2501}\u{2501}\u{2501}\u{2501}\u{2501} declaration\n\
         ... \u{2502}\n\
         4   \u{2502}   .a { @include m(\n    \u{2502} \u{250c}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}^\n\
         5   \u{2502} \u{2502} ); }\n    \u{2502} \u{2514}\u{2500}^ invocation\n    \u{2575}"
    );
}

#[test]
fn a_first_class_mixin_reference_carries_the_declaration_too() {
    // `@include meta.apply(…)` reaches the same binding code by another road,
    // and dart gives it the same two spans: the whole `meta.apply` call as the
    // invocation (its content block excluded), the mixin as the declaration.
    let run = |src: &str| -> String {
        compile(src, &Options::default().with_url("t.scss"))
            .expect_err("expected a compile error")
            .to_string()
    };
    let block = run(
        "@use \"sass:meta\";\n@mixin m { a: 1; }\n.a { @include meta.apply(meta.get-mixin(\"m\")) { b: 2; } }\n",
    );
    assert_eq!(
        snippet(&block),
        "Error: Mixin doesn't accept a content block.\n  \u{2577}\n\
         2 \u{2502} @mixin m { a: 1; }\n  \u{2502}        \u{2501} declaration\n\
         3 \u{2502} .a { @include meta.apply(meta.get-mixin(\"m\")) { b: 2; } }\n  \u{2502}      \
         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ invocation\n  \u{2575}"
    );
    // The mixin is never entered, so the trace starts at the caller.
    assert!(!block.contains("  m()"), "{block}");
    // The argument-binding errors carry it as well.
    for (src, message) in [
        (
            "@use \"sass:meta\";\n@mixin m($x) { a: $x; }\n.a { @include meta.apply(meta.get-mixin(\"m\")); }\n",
            "Missing argument $x.",
        ),
        (
            "@use \"sass:meta\";\n@mixin m() { a: 1; }\n.a { @include meta.apply(meta.get-mixin(\"m\"), 1); }\n",
            "Only 0 arguments allowed, but 1 was passed.",
        ),
        (
            "@use \"sass:meta\";\n@mixin m($x: 1) { a: $x; }\n.a { @include meta.apply(meta.get-mixin(\"m\"), $z: 1); }\n",
            "No parameter named $z.",
        ),
    ] {
        let block = run(src);
        assert!(block.starts_with(&format!("Error: {message}\n")), "{block}");
        assert!(block.contains(" declaration\n"), "{block}");
        assert!(caret_line(&block).ends_with(" invocation"), "{block}");
    }
}

#[test]
fn two_spans_on_one_line_stack_their_rows() {
    // A stylesheet written on ONE line puts the call and the declaration it was
    // measured against on that same line. dart prints the line once and stacks
    // the underlines, the primary first — wherever the two sit relative to each
    // other. Both blocks are dart-sass 1.103.1's.
    let run = |src: &str| -> String {
        snippet(
            &compile(src, &Options::default().with_url("t.scss"))
                .expect_err("expected a compile error")
                .to_string(),
        )
    };
    assert_eq!(
        run("@function f($x) { @return 1; } .a { b: f(1, 2); }\n"),
        "Error: Only 1 argument allowed, but 2 were passed.\n  \u{2577}\n1 \u{2502} \
         @function f($x) { @return 1; } .a { b: f(1, 2); }\n  \u{2502}                                        \
         ^^^^^^^ invocation\n  \u{2502}           \
         \u{2501}\u{2501}\u{2501}\u{2501}\u{2501} declaration\n  \u{2575}"
    );
    // The declaration can come AFTER the call on that line; the primary row is
    // still written first.
    assert_eq!(
        run("@mixin caller { @include m; } @mixin m($x) { a: $x; } .a { @include caller; }\n"),
        "Error: Missing argument $x.\n  \u{2577}\n1 \u{2502} \
         @mixin caller { @include m; } @mixin m($x) { a: $x; } .a { @include caller; }\n  \u{2502}                 \
         ^^^^^^^^^^ invocation\n  \u{2502}                                      \
         \u{2501}\u{2501}\u{2501}\u{2501}\u{2501} declaration\n  \u{2575}"
    );
}

#[test]
fn a_span_inside_an_arms_range_writes_its_row_under_its_own_line() {
    // A span that stays within its line can sit INSIDE the lines another span's
    // arm covers. dart writes its row under its own line — before the arm's own
    // rows — with the arm running down the column beside it. Both blocks are
    // dart-sass 1.103.1's.
    let run = |src: &str| -> String {
        snippet(
            &compile(src, &Options::default().with_url("t.scss"))
                .expect_err("expected a compile error")
                .to_string(),
        )
    };
    // The call on the arm's LAST line: its row comes first, then the row that
    // closes the arm and carries `declaration`.
    assert_eq!(
        run("@mixin m(\n  $x: 1\n) { a: $x; } .b { @include m { c: 1; } }\n"),
        "Error: Mixin doesn't accept a content block.\n  \u{2577}\n\
         1 \u{2502}   @mixin m(\n  \u{2502} \u{250c}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}^\n\
         2 \u{2502} \u{2502}   $x: 1\n\
         3 \u{2502} \u{2502} ) { a: $x; } .b { @include m { c: 1; } }\n  \u{2502} \u{2502}                   \
         ^^^^^^^^^^ invocation\n  \u{2502} \u{2514}\u{2500}^ declaration\n  \u{2575}"
    );
    // On the arm's FIRST line the arm has not reached in yet — the `,-…-^` row
    // comes after this one — so the column beside it is still blank.
    assert_eq!(
        run("@mixin caller { @include m { c: 1; } } @mixin m(\n  $x: 1\n) { a: $x; }\n.b { @include caller; }\n"),
        "Error: Mixin doesn't accept a content block.\n  \u{2577}\n\
         1 \u{2502}   @mixin caller { @include m { c: 1; } } @mixin m(\n  \u{2502}                   \
         ^^^^^^^^^^ invocation\n  \u{2502} \u{250c}\
         \u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}\u{2500}^\n\
         2 \u{2502} \u{2502}   $x: 1\n\
         3 \u{2502} \u{2502} ) { a: $x; }\n  \u{2502} \u{2514}\u{2500}^ declaration\n  \u{2575}"
    );
}

/// `grayscale(1, 2)` is an arity error, and dart raises ONLY that — no
/// `global-builtin` warning ahead of it.
///
/// Not a byte-exact fixture: dart renders this one as a two-span error
/// (the invocation, plus the declaration inside `sass:color`), which this
/// renderer cannot draw yet. The captured dart output is checked in beside the
/// input for reference; what is asserted here is the narrower property the
/// #122 fix turns on.
///
/// It is asserted because the review of #122 proposed requiring one argument
/// in `is_plain_css_filter_call`, and doing so makes this call miss the
/// plain-CSS branch, be deprecated as a global built-in, and print a warning
/// dart never prints. Measured, not assumed.
#[test]
fn an_arity_error_on_a_css_filter_does_not_also_deprecate() {
    let stderr = run_sasso_stderr("deprecation-global-builtin-filter-arity");
    // `DEPRECATION WARNING`, not `global-builtin`: the fixture's own FILENAME
    // contains that id and appears in the stack trace, so the obvious
    // assertion passes for the wrong reason — it failed here first.
    assert!(
        !stderr.contains("DEPRECATION WARNING"),
        "grayscale(1, 2) must report its arity error alone, got:\n{stderr}"
    );
    assert!(
        stderr.contains("Error:"),
        "…and it must still be an error, got:\n{stderr}"
    );
}

/// A registered host function is the implementation sasso selects, so a call
/// to it is not the plain-CSS filter overload and must still be deprecated.
///
/// The #122 suppression runs before host dispatch, which is exactly where it
/// could go wrong: `grayscale(1)` looks like the CSS filter right up until you
/// notice a callback is registered under that name and is what actually runs.
/// `with_function`'s contract (src/lib.rs) is that writing a deprecated
/// global's name warns whether or not a custom function of that name exists —
/// the callback taking precedence is sasso's deliberate divergence from dart,
/// and the warning is not part of that divergence.
///
/// The sibling test above covers the same contract for a name with no CSS
/// overload (`type-of`); this one covers a name that has one.
#[test]
fn a_host_override_of_a_filter_name_still_warns() {
    use std::rc::Rc;
    let called: Rc<std::cell::Cell<bool>> = Rc::new(std::cell::Cell::new(false));
    let flag = Rc::clone(&called);
    let cb: sasso::HostFunction = Rc::new(move |_args: &[u8]| {
        flag.set(true);
        Ok(Vec::new())
    });
    let seen: Rc<std::cell::RefCell<Vec<String>>> = Rc::new(std::cell::RefCell::new(Vec::new()));
    let sink = Rc::clone(&seen);
    let opts = Options::default()
        .with_url("in.scss")
        .with_function("grayscale($x)", cb)
        .with_warn_handler(Rc::new(move |ev: &sasso::WarnEvent<'_>| {
            sink.borrow_mut().push(ev.formatted.to_string());
        }));
    let _ = compile(".a { filter: grayscale(1); }\n", &opts);
    let w = seen.borrow().clone();
    assert!(
        called.get(),
        "the registered callback is the implementation that runs"
    );
    assert_eq!(w.len(), 1, "the deprecated global name still warns: {w:?}");
    assert!(w[0].contains("global-builtin"), "{}", w[0]);
}

/// A frame path spelled the way the platform spells it.
///
/// dart writes every frame with the PLATFORM's separator, the entry's
/// included (#151), and so do we — so `src/main.scss` is the right answer on
/// POSIX and `src\main.scss` on Windows. Four tests here hard-coded the
/// POSIX one and passed everywhere except the platform half of this rule
/// exists for.
fn frame_path(rel: &str) -> String {
    if cfg!(windows) {
        rel.replace('/', "\\")
    } else {
        rel.to_string()
    }
}

/// A frame names a file the same way whichever spelling the host handed over.
///
/// The binary passes a path and the JS API passes a `file://` URL — it has to,
/// because its importer bridge resolves relative `@use` against the entry URL —
/// and for three releases the URL went straight into the frame, scheme and all
/// (#153). The two front ends printed different things for the same error, and
/// `file:///Users/…/src/a.scss` is neither pasteable into an editor nor
/// meaningful on anyone else's machine.
///
/// `cwd` is passed explicitly rather than leaning on the process's: this is
/// what the JS bridges do, because `wasm32-unknown-unknown` has no `getcwd` and
/// nothing to relativise against otherwise.
#[test]
fn a_frame_names_a_file_the_same_way_from_either_front_end() {
    let cwd = if cfg!(windows) {
        r"C:\work\proj"
    } else {
        "/work/proj"
    };
    let as_url = "file:///work/proj/src/a.scss";
    let as_path = if cfg!(windows) {
        r"C:\work\proj\src\a.scss"
    } else {
        "/work/proj/src/a.scss"
    };
    let expected = if cfg!(windows) {
        r"src\a.scss 1:8"
    } else {
        "src/a.scss 1:8"
    };

    // On Windows the URL names the C: drive, so both spellings are the same
    // file and the comparison is the point of the test.
    let url = if cfg!(windows) {
        "file:///C:/work/proj/src/a.scss"
    } else {
        as_url
    };

    let from_url = compile("a { b: $x }", &Options::new().with_url(url).with_cwd(cwd)).unwrap_err();
    let from_path = compile("a { b: $x }", &Options::new().with_url(as_path).with_cwd(cwd)).unwrap_err();

    // `Display` prints the rendered block when there is one.
    let rendered = |e: &sasso::Error| e.to_string();
    assert!(
        rendered(&from_url).contains(expected),
        "a file:// url should name a path: {}",
        rendered(&from_url),
    );
    assert_eq!(
        rendered(&from_url),
        rendered(&from_path),
        "the two front ends' spellings must render identically",
    );
    assert!(
        !rendered(&from_url).contains("file://"),
        "no frame should show a scheme: {}",
        rendered(&from_url),
    );
}

/// Without a `cwd` the host knows of, a frame still shows a PATH — just not a
/// relative one. That is the wasm case before the bridges were taught to pass
/// one, and it must degrade to "absolute" rather than back to a URL.
#[test]
fn a_file_url_without_a_cwd_degrades_to_an_absolute_path() {
    let e = compile(
        "a { b: $x }",
        &Options::new().with_url("file:///nowhere/deep/a.scss"),
    )
    .unwrap_err();
    let rendered = e.to_string();
    assert!(!rendered.contains("file://"), "still a URL: {rendered}");
    let expected = if cfg!(windows) {
        r"\nowhere\deep\a.scss"
    } else {
        "/nowhere/deep/a.scss"
    };
    assert!(rendered.contains(expected), "not the path: {rendered}");
}

/// A custom importer's key is not a filesystem path and is not ours to
/// rewrite: dart shows it as it is.
#[test]
fn a_non_file_url_keeps_its_own_spelling() {
    let e = compile(
        "a { b: $x }",
        &Options::new().with_url("data:;charset=utf-8,a").with_cwd("/work"),
    )
    .unwrap_err();
    let rendered = e.to_string();
    assert!(rendered.contains("data:;charset=utf-8,a 1:8"), "{rendered}");
}

/// A custom importer's canonical key is its own identity, not a path. dart
/// shows its last segment, and so did this — until the frame-naming rule was
/// applied to every key rather than to the ones that name a file.
///
/// A RELATIVE key is the case that slipped through: `virtual/foo.scss` has no
/// scheme to decline it by and no root to relativise, so handing it back
/// whole looked like a no-op and was a changed frame.
#[test]
fn a_custom_importers_relative_key_shows_its_last_segment() {
    struct Virtual;
    impl sasso::Importer for Virtual {
        fn canonicalize(
            &self,
            url: &str,
            _ctx: &sasso::CanonicalizeContext<'_>,
        ) -> Result<Option<sasso::CanonicalUrl>, sasso::ImporterError> {
            Ok(Some(sasso::CanonicalUrl::new(format!("virtual/{url}.scss"))))
        }
        fn load(
            &self,
            _canonical: &sasso::CanonicalUrl,
        ) -> Result<Option<sasso::ImporterResult>, sasso::ImporterError> {
            Ok(Some(sasso::ImporterResult {
                contents: "@mixin m {\n  a: $nope;\n}\n".to_string(),
                syntax: sasso::Syntax::Scss,
                source_map_url: None,
            }))
        }
    }

    let importer = Virtual;
    let opts = Options::new()
        .with_url("file:///work/proj/src/main.scss")
        .with_cwd("/work/proj")
        .with_importer(&importer);
    let e = compile("@use \"foo\";\n.a { @include foo.m; }\n", &opts).unwrap_err();
    let rendered = e.to_string();
    assert!(
        rendered.contains(&frame_path("foo.scss 2:6")),
        "the key's last segment, as dart shows it: {rendered}",
    );
    assert!(
        !rendered.contains(&frame_path("virtual/foo.scss")),
        "the whole key is not a frame name: {rendered}",
    );
    // …and the entry is still relativised beside it.
    assert!(rendered.contains(&frame_path("src/main.scss")), "{rendered}");
}

/// The "error in interpolated output" block prints the file in a header of
/// its OWN, so it is a second place a frame becomes text. Left out of the
/// rule, one message contradicted itself: a `file://` URL in the header above
/// the path in the trace below.
#[test]
fn the_interpolated_output_header_names_the_file_like_the_trace() {
    let opts = Options::new()
        .with_url("file:///work/proj/src/main.scss")
        .with_cwd("/work/proj");
    let e = compile("$x: \"y@z\";\n.a#{$x} { c: d; }\n", &opts).unwrap_err();
    let rendered = e.to_string();
    assert!(
        rendered.contains("error in interpolated output"),
        "not the dual-span block: {rendered}",
    );
    assert!(!rendered.contains("file://"), "a URL survived: {rendered}");
    assert_eq!(
        rendered.matches(&frame_path("src/main.scss")).count(),
        2,
        "the header and the trace should both name it: {rendered}",
    );
}

/// The Windows rule, exercised from whatever host runs this.
///
/// The wasm module is built for `wasm32-unknown-unknown`, so the compile-time
/// host style is POSIX in it no matter where node is running — and on Windows
/// node it is handed `C:\work\proj` and `file:///C:/work/proj/…`. Reading
/// those by POSIX rules leaves `/C:/work/proj/src/main.scss` in the frame:
/// not the path, and not what the addon on the same machine prints.
///
/// Nothing on a POSIX developer machine can reach that through the CLI, which
/// is exactly the blind spot `pathstyle` exists for (#146). Here the
/// Windows spelling is handed to the compiler directly, so the rule is
/// checked wherever this test runs.
#[test]
fn a_windows_spelling_is_read_by_windows_rules_on_any_host() {
    let opts = Options::new()
        .with_url("file:///C:/work/proj/src/main.scss")
        .with_cwd(r"C:\work\proj");
    let e = compile("a { b: $x }", &opts).unwrap_err();
    let rendered = e.to_string();
    assert!(
        rendered.contains(r"src\main.scss 1:8"),
        "a Windows cwd and a Windows file URL should give a Windows path: {rendered}",
    );
    assert!(!rendered.contains("/C:/"), "read as a POSIX path: {rendered}");
    assert!(!rendered.contains("file://"), "a URL survived: {rendered}");
}

/// A cross-file `invocation`/`declaration` error draws one header PER FILE,
/// through a third snippet function. Left out of the rule, a single message
/// named the same kind of thing three ways: a URL in the first header, a path
/// in the second, and paths in the trace.
#[test]
fn a_labelled_snippets_headers_name_files_like_the_trace() {
    struct Dep;
    impl sasso::Importer for Dep {
        fn canonicalize(
            &self,
            _url: &str,
            _ctx: &sasso::CanonicalizeContext<'_>,
        ) -> Result<Option<sasso::CanonicalUrl>, sasso::ImporterError> {
            Ok(Some(sasso::CanonicalUrl::new("file:///work/proj/src/_dep.scss")))
        }
        fn load(
            &self,
            _canonical: &sasso::CanonicalUrl,
        ) -> Result<Option<sasso::ImporterResult>, sasso::ImporterError> {
            Ok(Some(sasso::ImporterResult {
                contents: "@mixin m($a) {\n  width: $a;\n}\n".to_string(),
                syntax: sasso::Syntax::Scss,
                source_map_url: None,
            }))
        }
    }

    let importer = Dep;
    let opts = Options::new()
        .with_url("file:///work/proj/src/main.scss")
        .with_cwd("/work/proj")
        .with_importer(&importer);
    let e = compile("@use \"dep\";\n.a { @include dep.m(1, 2); }\n", &opts).unwrap_err();
    let rendered = e.to_string();
    assert!(
        rendered.contains("invocation") && rendered.contains("declaration"),
        "not the labelled block: {rendered}",
    );
    assert!(!rendered.contains("file://"), "a URL survived: {rendered}");
    assert!(rendered.contains(&frame_path("src/main.scss")), "{rendered}");
    assert!(rendered.contains(&frame_path("src/_dep.scss")), "{rendered}");
}

/// The same block, reached through the OTHER of the two call sites.
///
/// `error_with_declaration_at` renders before the callable is entered — a
/// content block handed to a mixin that has no `@content` — so it builds its
/// own two-span block rather than going through `error_at_call`. One test
/// could not cover both: reverting only this site left the first case green.
#[test]
fn the_pre_entry_declaration_block_names_files_like_the_trace() {
    struct Dep;
    impl sasso::Importer for Dep {
        fn canonicalize(
            &self,
            _url: &str,
            _ctx: &sasso::CanonicalizeContext<'_>,
        ) -> Result<Option<sasso::CanonicalUrl>, sasso::ImporterError> {
            Ok(Some(sasso::CanonicalUrl::new("file:///work/proj/src/_dep.scss")))
        }
        fn load(
            &self,
            _canonical: &sasso::CanonicalUrl,
        ) -> Result<Option<sasso::ImporterResult>, sasso::ImporterError> {
            Ok(Some(sasso::ImporterResult {
                contents: "@mixin plain {\n  width: 1px;\n}\n".to_string(),
                syntax: sasso::Syntax::Scss,
                source_map_url: None,
            }))
        }
    }

    let importer = Dep;
    let opts = Options::new()
        .with_url("file:///work/proj/src/main.scss")
        .with_cwd("/work/proj")
        .with_importer(&importer);
    let e = compile(
        "@use \"dep\";\n.a { @include dep.plain { color: red; } }\n",
        &opts,
    )
    .unwrap_err();
    let rendered = e.to_string();
    assert!(
        rendered.contains("content block") && rendered.contains("declaration"),
        "not the pre-entry two-span block: {rendered}",
    );
    assert!(!rendered.contains("file://"), "a URL survived: {rendered}");
    assert!(rendered.contains(&frame_path("src/main.scss")), "{rendered}");
    assert!(rendered.contains(&frame_path("src/_dep.scss")), "{rendered}");
}

/// Both spans in the ENTRY file, where the declaration has no module of its
/// own and falls back to the frame's url — the raw one the host passed.
///
/// `render_labelled_snippet` groups by `(url, source)`, so naming the primary
/// group and not the secondary splits one file into two groups and prints its
/// header twice. The rule has to reach both sides of the pair or neither.
#[test]
fn one_file_gets_one_header_when_both_spans_are_the_entrys() {
    let opts = Options::new()
        .with_url("file:///work/proj/src/main.scss")
        .with_cwd("/work/proj");
    let e = compile(
        "@mixin plain {\n  width: 1px;\n}\n.a { @include plain { color: red; } }\n",
        &opts,
    )
    .unwrap_err();
    let rendered = e.to_string();
    assert!(
        rendered.contains("content block"),
        "not the expected error: {rendered}",
    );
    assert!(!rendered.contains("file://"), "a URL survived: {rendered}");
    // One file, one header. The frame trace names it too, so count headers
    // rather than mentions.
    let headers = rendered.matches("┌──>").count() + rendered.matches(",-->").count();
    assert!(
        headers <= 1,
        "one file should get one header, got {headers}: {rendered}"
    );
}

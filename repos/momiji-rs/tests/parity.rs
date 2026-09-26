//! Live parity tests against dart-sass.
//!
//! These are **opt-in**: they only run when `SASSO_PARITY=1` is set and
//! a dart-sass CLI is reachable (via `$SASS_BIN`, default `npx --yes sass`).
//! Otherwise each test returns early so a plain `cargo test` stays fast and
//! offline. CI sets the env var and installs dart-sass.

use std::io::Write as _;
use std::process::{Command, Stdio};

use sasso::{compile, FsImporter, Options, OutputStyle};

fn enabled() -> bool {
    std::env::var("SASSO_PARITY").map(|v| v != "0").unwrap_or(false)
}

/// Compile `scss` with dart-sass (expanded, via stdin), returning its CSS.
fn dart_sass(scss: &str) -> Option<String> {
    dart_sass_styled(scss, None)
}

/// Compile `scss` with dart-sass in compressed mode.
fn dart_sass_compressed(scss: &str) -> Option<String> {
    dart_sass_styled(scss, Some("compressed"))
}

/// Shared dart-sass runner; `style` adds `--style=<style>` when set.
fn dart_sass_styled(scss: &str, style: Option<&str>) -> Option<String> {
    let bin = std::env::var("SASS_BIN").unwrap_or_else(|_| "npx".to_string());
    let mut cmd = if bin == "npx" {
        let mut c = Command::new("npx");
        c.args(["--yes", "sass", "--no-source-map", "--stdin"]);
        c
    } else {
        let mut c = Command::new(bin);
        c.args(["--no-source-map", "--stdin"]);
        c
    };
    if let Some(s) = style {
        cmd.arg(format!("--style={s}"));
    }
    let mut child = cmd
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::null())
        .spawn()
        .ok()?;
    child.stdin.take()?.write_all(scss.as_bytes()).ok()?;
    let out = child.wait_with_output().ok()?;
    if !out.status.success() {
        return None;
    }
    Some(strip_cli_newline(String::from_utf8(out.stdout).ok()?))
}

/// Drop the single trailing newline the dart-sass CLI appends; its library API
/// (and ours) omit it, so parity compares the serialized stylesheet, not the
/// CLI's line terminator. (Our CLI re-adds it too — see the cli tests.)
fn strip_cli_newline(s: String) -> String {
    s.strip_suffix('\n').map(str::to_owned).unwrap_or(s)
}

fn assert_parity(scss: &str) {
    if !enabled() {
        return;
    }
    let ours = compile(scss, &Options::default()).expect("our compile failed");
    match dart_sass(scss) {
        Some(theirs) => assert_eq!(ours, theirs, "\n--- scss ---\n{scss}\n"),
        None => eprintln!("skipping parity case: dart-sass unavailable"),
    }
}

/// Assert both sasso and dart-sass REJECT `scss` (error-spec parity).
fn assert_error_parity(scss: &str) {
    if !enabled() {
        return;
    }
    assert!(
        compile(scss, &Options::default()).is_err(),
        "\nexpected our compile to fail:\n--- scss ---\n{scss}\n"
    );
    assert!(
        dart_sass(scss).is_none(),
        "\nexpected dart-sass to fail too:\n--- scss ---\n{scss}\n"
    );
}

#[test]
fn parity_variables_nesting() {
    assert_parity("$c: #336699;\n.a {\n  color: $c;\n  .b { color: lighten($c, 10%); }\n  &:hover { color: mix($c, white, 50%); }\n}\n");
}

#[test]
fn parity_colors() {
    assert_parity("$brand: #2a7ae2;\n.x {\n  color: rgba($brand, 0.5);\n  background: darken($brand, 15%);\n  border-color: hsl(120, 50%, 40%);\n  width: percentage(0.25);\n}\n");
}

/// Compile `scss` compressed with both engines and assert byte-for-byte parity.
fn assert_parity_compressed(scss: &str) {
    if !enabled() {
        return;
    }
    let ours =
        compile(scss, &Options::default().with_style(OutputStyle::Compressed)).expect("our compile failed");
    match dart_sass_compressed(scss) {
        // `dart_sass_styled` already strips the CLI's trailing newline, and our
        // compressed output never has one, so compare the bytes directly.
        Some(theirs) => assert_eq!(ours, theirs, "\n--- scss (compressed) ---\n{scss}\n"),
        None => eprintln!("skipping compressed parity case: dart-sass unavailable"),
    }
}

/// Compressed legacy-color serialization must match dart-sass byte-for-byte:
/// the SHORTEST of the hex / name / rgb() / hsl() forms. This guards the
/// compressed path that the conformance suite (expanded-only) cannot reach.
#[test]
fn parity_compressed_color_shortest_form() {
    // rgb-space results whose hsl form is shorter -> hsl()/hsla().
    for f in ["darken", "lighten", "saturate", "desaturate"] {
        for amt in ["5%", "10%", "15%", "20%", "33%"] {
            assert_parity_compressed(&format!("a {{ x: {f}(#336699, {amt}); }}"));
            assert_parity_compressed(&format!("a {{ x: {f}(#ff6600, {amt}); }}"));
        }
    }
    for scss in [
        "a { x: grayscale(#ff6600); }",
        "a { x: complement(#336699); }",
        "a { x: adjust-hue(#336699, 90deg); }",
        "a { x: rgba(darken(#336699, 10%), 0.5); }",
        "a { x: mix(#ff6600, #fff, 30%); }",
        "@use 'sass:color'; a { x: color.adjust(#336699, $lightness: -10%); }",
        "@use 'sass:color'; a { x: color.scale(#336699, $lightness: 20%); }",
        // hsl-space literals: integer -> hex, fractional -> hsl, tie -> rgb,
        // powerless hue preserved.
        "a { x: hsl(210, 50%, 40%); }",
        "a { x: hsl(210, 50%, 30%); }",
        "a { x: hsl(30, 100%, 50%); }",
        "a { x: hsl(30, 0%, 50%); }",
        // regression guards (must stay unchanged).
        "a { x: #336699; }",
        "a { x: red; }",
        "a { x: rgba(0, 0, 0, 0.5); }",
        "a { x: hsl(0, 0%, 50%); }",
    ] {
        assert_parity_compressed(scss);
    }
}

/// The predefined `color()` spaces separate the space name and the channels
/// with mandatory whitespace, which compressed output must NOT eat. The
/// conformance suite only runs expanded output, so this is the live guard.
#[test]
fn parity_compressed_color_function_spacing() {
    for scss in [
        "a { x: color(display-p3 0.5 0.2 0.9); }",
        "a { x: color(display-p3 0.5 0.2 0.9 / 0.5); }",
        "a { x: color(xyz 0.1 0.2 0.3); }",
        "a { x: color(xyz-d50 -0.5 1.5 0.25 / 0); }",
        "a { x: color(srgb-linear 0.1 0.2 0.3 / 0.25); }",
        "a { x: color(a98-rgb 1 0.5 0); }",
        "a { x: color(prophoto-rgb 0 0 0); }",
        "a { x: color(display-p3 none 0.2 0.9); }",
        "a { x: color(rec2020 0.5 none none / none); }",
        "a { x: rgb(1 2 none); }",
        "a { x: rgb(1 2 none / 0.5); }",
    ] {
        assert_parity_compressed(scss);
        assert_parity(scss);
    }
}

/// A calc's `+`/`-` flips for a negative numeric right operand in BOTH styles,
/// and the sign test is exactly `< 0`: `-0` and NaN keep the operator,
/// `-infinity` flips.
#[test]
fn parity_calc_negative_right_operand_flip() {
    for scss in [
        "a { x: calc(var(--a) + -2px); }",
        "a { x: calc(var(--a) - -2px); }",
        "a { x: calc(100% + -2px); }",
        "a { x: calc(100% - -2px); }",
        "a { x: calc(1px + -2em); }",
        "a { x: calc(var(--a) + -0.5px); }",
        "a { x: calc(var(--a) + -2); }",
        "a { x: calc(var(--a) + -0px); }",
        "a { x: calc((var(--a) + -2px) * 3); }",
        "a { x: calc(var(--a) + -2px * 3); }",
        "a { x: calc(var(--a) - -2px / 4); }",
        "a { x: min(var(--a), -2px, calc(1px + -2px)); }",
        "@use 'sass:math'; a { x: calc(1px + math.div(-1, 0) * 1em); }",
        "@use 'sass:math'; a { x: calc(1px - math.div(-1, 0) * 1em); }",
        "@use 'sass:math'; a { x: calc(var(--a) + math.div(-1, 0)); }",
        "@use 'sass:math'; a { x: calc(1px + math.div(0, 0) * 1em); }",
        "@use 'sass:math'; a { x: calc(1px - math.div(0, 0) * 1em); }",
    ] {
        assert_parity(scss);
        assert_parity_compressed(scss);
    }
}

#[test]
fn parity_nesting_combinators() {
    assert_parity(".a, .b {\n  margin: 0;\n  > .c { padding: 1px; }\n  &.active { color: red; }\n  .d & { color: blue; }\n}\n.menu { li + li { margin-left: 5px; } }\n");
}

#[test]
fn parity_interpolation() {
    assert_parity("$name: warning;\n$i: 3;\n.icon-#{$name} { content: \"#{$name}-#{$i}\"; }\n.col-#{$i} { width: 10px * $i; }\n");
}

#[test]
fn parity_lists_and_functions() {
    assert_parity("$stack: \"Helvetica Neue\", Arial, sans-serif;\n.t {\n  font-family: $stack;\n  margin: 1px 2px 3px 4px;\n  transform: translateX(10px);\n  width: calc(100% - 20px);\n}\n");
}

#[test]
fn parity_if_else() {
    assert_parity("$t: dark;\n.a {\n  @if $t == dark { color: white; background: black; }\n  @else if $t == light { color: black; }\n  @else { color: gray; }\n  padding: 1px;\n}\n@if 2 > 1 { .b { x: 1; } } @else { .c { y: 2; } }\n");
}

#[test]
fn parity_loops() {
    assert_parity("@for $i from 1 through 3 {\n  .col-#{$i} { width: $i * 10px; }\n}\n@each $a, $b in (x 1), (y 2) {\n  .pair-#{$a} { order: $b; }\n}\n.counter {\n  $i: 0;\n  @while $i < 3 { p-#{$i}: $i * 2px; $i: $i + 1; }\n}\n");
}

#[test]
fn parity_functions_and_mixins() {
    assert_parity("@function clamp-val($v, $min: 0, $max: 100) {\n  @if $v < $min { @return $min; }\n  @else if $v > $max { @return $max; }\n  @return $v;\n}\n@function sum($nums...) {\n  $t: 0;\n  @each $n in $nums { $t: $t + $n; }\n  @return $t;\n}\n@mixin box($pad, $color: blue) { padding: $pad; color: $color; }\n@mixin surround { border: 1px solid; @content; margin: 0; }\n.a {\n  z-index: clamp-val(150);\n  order: sum(1, 2, 3, 4);\n  @include box(4px);\n}\n.b { @include surround { background: yellow; } }\n");
}

#[test]
fn parity_modulo_sign() {
    // Sass modulo is a floored modulo whose result takes the divisor's sign.
    assert_parity(
        "a {\n  b: 1.2 % -4.7;\n  c: -1.2 % 4.7;\n  d: 5 % 3;\n  e: 10px % 3px;\n  f: -8 % 3;\n}\n",
    );
}

#[test]
fn parity_at_rule_font_face() {
    assert_parity("@font-face {\n  font-family: \"My Font\";\n  src: url(font.woff);\n}\n");
}

#[test]
fn parity_at_rule_page_and_unknown() {
    assert_parity(
        "@page {\n  margin: 1cm;\n}\n@foo bar baz {\n  a: b;\n}\n@blockless;\n@with-prelude value;\n",
    );
}

#[test]
fn parity_at_rule_prelude_interpolation() {
    // `#{…}` inside an unknown at-rule prelude is resolved everywhere, including
    // inside a quoted string (the quotes stay literal); an escaped `\#{` and a
    // bare `#` are left alone.
    assert_parity(
        "$d: \"x.com\";\n@foo url(https://#{$d}/), \"foo#{'ba' + 'r'}baz\", foo#{'ba' + 'r'}baz {\n  .a { b: c }\n}\n",
    );
    assert_parity("@foo \"plain\", \"has # hash\", \"esc \\#{no}\", url(\"a#b\") { x { y: z } }\n");
    // The same template path backs selectors, so `#{…}` inside a quoted
    // attribute value resolves too.
    assert_parity("$z: zzz;\na[data-foo=\"#{$z}\"] { color: red; }\n");
}

/// An at-rule whose NAME comes from interpolation is a generic at-rule in
/// dart, however that name reads: the parser decided the class before the
/// evaluator ever resolved `#{…}`. Two things follow, and the live suite is the
/// only place to check both — the conformance run is expanded-only.
#[test]
fn parity_at_rule_name_interpolation_is_generic() {
    for scss in [
        // The compressed space before a `(` prelude belongs to the conditional
        // group rules alone.
        "@#{\"media\"} (a: 1) { .x { y: z } }\n",
        "@#{\"supports\"} (a: 1) { .x { y: z } }\n",
        "@media (a: 1) { .x { y: z } }\n",
        "@#{\"media\"} (a: 1);\n",
        ".r { @#{\"media\"} (a: 1) { y: z } }\n",
        "@media (b: 2) { @#{\"media\"} (a: 1) { .x { y: z } } }\n",
        "@#{\"media\"} (b: 2) { @media (a: 1) { .x { y: z } } }\n",
        // An empty block goes away only for a conditional group rule.
        "@#{\"media\"} screen {}\n",
        "@#{\"media\"} {}\n",
        "@#{\"supports\"} (a: 1) {}\n",
        "@#{\"media\"} (a: 1) { /* c */ }\n",
        "@media screen {}\n",
        // Emptied after the fact, by placeholder removal.
        "@#{\"media\"} (a: 1) { %p { y: z } }\n",
        "@media (a: 1) { %p { y: z } }\n",
        // The name as written is no guide either way: `@MEDIA` is generic too.
        "@MEDIA (a: 1) { .x { y: z } }\n",
        "@MEDIA (a: 1) { /* c */ }\n",
        // A `@media` inside a keyframe block nests verbatim and is still the
        // parsed rule.
        "@keyframes k { from { a: b } @media (a: 1) { to { c: d } } }\n",
        "@keyframes k { 10% { /* c */ } }\n",
    ] {
        assert_parity(scss);
        assert_parity_compressed(scss);
    }
}

#[test]
fn parity_large_numbers() {
    // Huge literals print as plain decimals, scientific notation expands,
    // and fractions round to ten places exactly like dart-sass.
    assert_parity(concat!(
        "a {\n",
        "  big: 99999999999999999999999999999;\n",
        "  neg: -123456789012345;\n",
        "  sci: 1e20;\n",
        "  sci2: 1.5e3;\n",
        "  sci3: 1e-3;\n",
        "  unit: 1e3px;\n",
        "  third: (1 / 3);\n",
        "  precise: 0.1 + 0.2;\n",
        "}\n",
    ));
    // An int64-representable integer prints its exact decimal expansion (the
    // native dart VM int path; the npx JS build prints the shortest
    // round-trip `…800`, but sass-spec expectations come from the VM).
    assert_eq!(
        ours("a {b: 1234567890123456789}\n"),
        "a {\n  b: 1234567890123456768;\n}\n"
    );
    // Past int64 the saturating round-trip fails and the shortest form wins.
    assert_eq!(
        ours("a {b: 92233720368547758070}\n"),
        "a {\n  b: 92233720368547760000;\n}\n"
    );
}

#[test]
fn parity_calc() {
    // Fully numeric calc() interiors simplify and unwrap; mixed ones keep a
    // canonical calc() with folded numeric subtrees and minimal parens.
    assert_parity(concat!(
        "a {\n",
        "  c1: calc(1px + 2px);\n",
        "  c2: calc(100% / 4);\n",
        "  c3: calc(2 * 3);\n",
        "  c4: calc(50px);\n",
        "  c5: calc((1 + 2) * 3px);\n",
        "  k1: calc(100% - 50px);\n",
        "  k2: calc(var(--a) + 1px);\n",
        "  k3: calc(1px + 1em);\n",
        "  k4: calc(1px + 2px + 1%);\n",
        "  k5: calc(3px * 2 + 1%);\n",
        "  k6: calc(1% + -1px);\n",
        "  k7: calc(1px + (2% * var(--c)));\n",
        "  k8: calc(1px - (2% + var(--c)));\n",
        "  k9: calc(1px + (var(--c)));\n",
        "  pi: calc(pi);\n",
        "  e: calc(e);\n",
        "  pi2: calc(pi * 2);\n",
        "  pimix: calc(pi * (1% + 1px));\n",
        "}\n",
    ));
}

#[test]
fn parity_slash_division() {
    // The deprecated `/` keeps a slash spelling between number literals but
    // performs real division once an operand is computed, parenthesized,
    // read from a variable, or passed through a Sass function.
    assert_parity(concat!(
        "$x: 8px;\n",
        "@function id($v) {@return $v}\n",
        "a {\n",
        "  keep: 16px/1.5;\n",
        "  chain: 1/2/3;\n",
        "  list: 1 2/3 4;\n",
        "  comma: 1, 2/3, 4;\n",
        "  same-unit: 10px/5px;\n",
        "  paren: (10px / 2);\n",
        "  computed: (1 + 1) / 2;\n",
        "  var: $x / 2;\n",
        "  func: inspect(10px / 2);\n",
        "  unknown: foo(1/2);\n",
        "}\n",
    ));
}

#[test]
fn parity_at_rule_bubbling() {
    assert_parity(
        ".a {\n  color: black;\n  @media-like screen {\n    color: red;\n  }\n  .b { color: green; }\n}\n",
    );
}

#[test]
fn parity_at_rule_nested_and_mixed() {
    assert_parity("@outer one {\n  @inner two {\n    .a { color: red; }\n  }\n}\n@foo {\n  a: 1;\n  b: 2;\n  .x { c: 3; }\n  d: 4;\n}\n");
}

#[test]
fn parity_warn_debug_emit_no_css() {
    // @warn/@debug write to stderr only; the emitted CSS must be identical
    // to the same stylesheet without them.
    assert_parity("@warn \"a heads up\";\n.a {\n  @debug 1 + 2;\n  color: red;\n}\n");
}

#[test]
fn at_error_aborts_compilation() {
    // @error must abort with an Error (not emit CSS). This runs offline.
    let res = compile("@error \"boom\";\n.a { color: red; }\n", &Options::default());
    assert!(res.is_err(), "@error should abort compilation");
}

#[test]
fn parity_supports() {
    assert_parity("@supports (display: grid) {\n  .a { display: grid; }\n}\n@supports (display: grid) and (gap: 1rem) {\n  .b { gap: 1rem; }\n}\n@supports not (display: grid) {\n  .c { float: left; }\n}\n@supports (a: b) or (c: d) {\n  .d { x: y; }\n}\n");
}

#[test]
fn parity_supports_nested_and_blockless() {
    assert_parity(
        "@supports (a: b) and ((c: d) or (e: f)) {\n  .g { h: i; }\n}\n@supports (x: y) {@inner foo}\n",
    );
}

#[test]
fn parity_at_root_inline() {
    assert_parity(
        ".a {\n  color: red;\n  @at-root .b {\n    color: green;\n  }\n}\n@at-root .c {\n  color: blue;\n}\n",
    );
}

#[test]
fn parity_at_root_block() {
    assert_parity(".a {\n  .b {\n    @at-root .c {\n      x: y;\n    }\n  }\n}\n.outer {\n  @at-root {\n    .single { z: 1; }\n  }\n}\n");
}

#[test]
fn parity_keyframes() {
    assert_parity("@keyframes slide {\n  from { left: 0; }\n  50% { left: 50px; }\n  to { left: 100px; }\n}\n@-webkit-keyframes spin {\n  from { transform: rotate(0); }\n  to { transform: rotate(360deg); }\n}\n");
}

#[test]
fn parity_keyframes_list_and_interpolation() {
    assert_parity("$name: bounce;\n@keyframes #{$name} {\n  0%, 100% { opacity: 0; }\n  50% { opacity: 1; }\n}\n.a {\n  @keyframes nested-#{1 + 1} { from { top: 0; } }\n}\n");
}

#[test]
fn keyframes_selector_list_joins_on_one_line() {
    // dart re-serializes keyframe stops joined with ", " and DROPS author
    // line breaks (KeyframeSelectorParser) — unlike style-rule selector
    // lists, which preserve where the author broke the line.
    assert_eq!(
        ours("@keyframes a {\n  0%,\n  60%,\n  100% {\n    opacity: 1;\n  }\n}\n"),
        "@keyframes a {\n  0%, 60%, 100% {\n    opacity: 1;\n  }\n}\n"
    );
    // Control: the style-rule break stays.
    assert_eq!(ours("a,\nb {\n  c: d;\n}\n"), "a,\nb {\n  c: d;\n}\n");
    assert_parity("@keyframes a {\n  0%,\n  60%,\n  100% {\n    opacity: 1;\n  }\n}\na,\nb {\n  c: d;\n}\n");
}

#[test]
fn parity_unit_converting_arithmetic() {
    assert_parity(
        ".a {\n  w: 1in + 1cm;\n  x: 1cm + 1in;\n  y: 5s - 100ms;\n  z: 10px % 3pt;\n  cmp: 1in > 2cm;\n  mix: 5 + 1px;\n  turn: 1turn + 90deg;\n}\n",
    );
}

#[test]
fn parity_color_hue_family() {
    assert_parity(
        "a {\n  b: adjust-hue(red, 540);\n  c: adjust-hue(blue, 0);\n  d: adjust-hue(red, -180);\n  e: adjust-hue(red, 60rad);\n  f: complement(aqua);\n  g: invert(red);\n  h: invert(#b37399, 80%);\n}\n",
    );
}

#[test]
fn parity_calc_unit_folding() {
    assert_parity(
        ".a {\n  a: calc(1in + 1cm);\n  b: calc(1cm + 1in);\n  c: calc(5s - 100ms);\n  d: calc(1px + 1pt);\n  e: calc(10px / 2cm);\n  f: calc(1turn + 90deg);\n  g: calc(100% - 10px);\n  h: calc(1px + 1vw);\n}\n",
    );
}

#[test]
fn parity_math_builtins() {
    assert_parity(
        ".a {\n  a: sign(-5px);\n  b: pow(2, 3);\n  c: sqrt(4);\n  d: log(8, 2);\n  e: hypot(3px, 4cm);\n  f: sin(30deg);\n  g: cos(0);\n  h: tan(45deg);\n  i: asin(0.5);\n  j: atan2(1, 1);\n  k: rem(10px, 3pt);\n  l: mod(-10, 3);\n}\n",
    );
}

#[test]
fn parity_min_max_clamp_routing() {
    assert_parity(
        ".a {\n  a: min(1px, 2px);\n  b: max(1, 2, 3);\n  c: clamp(1px, 5px, 3px);\n  d: min(1px + 1px, 2vw);\n  e: min(1in, 2cm);\n  f: min(50%, 30%);\n  g: clamp(1px, 2vw, 3px);\n  h: max(2px, min(1px, 2vw));\n  i: min(1px, var(--x));\n}\n",
    );
}

#[test]
fn parity_color_filter_overloads() {
    assert_parity(
        "a {\n  b: invert(10%);\n  c: grayscale(15%);\n  d: saturate(50%);\n  e: grayscale(var(--c));\n  f: invert(calc(1 + 2));\n}\n",
    );
}

#[test]
fn parity_color_legacy_named_and_alpha() {
    assert_parity(
        "a {\n  b: lighten(red, 100%);\n  c: darken(red, 100%);\n  d: lighten(red, 14%);\n  e: mix(red, red);\n  f: mix(red, white, 50%);\n  g: rgba(red, 1);\n  h: rgba(#102030, 1);\n  i: rgba(red, 0.5);\n}\n",
    );
}

#[test]
fn parity_media_query_grammar() {
    // Logic operators, modifiers, ranges, nested parens, interpolation and
    // SassScript inside feature values; an empty body produces no output.
    assert_parity(concat!(
        "$w: width;\n",
        "@media (a) and (b) { x { y: z; } }\n",
        "@media (a)or (b) { x { y: z; } }\n",
        "@media not a { x { y: z; } }\n",
        "@media not (a) { x { y: z; } }\n",
        "@media only screen and (color) { x { y: z; } }\n",
        "@media a AnD nOt (b) { x { y: z; } }\n",
        "@media (not (a)) { x { y: z; } }\n",
        "@media ((a) and (b)) { x { y: z; } }\n",
        "@media (min-width: 100px + 50px) { x { y: z; } }\n",
        "@media ($w < 600px) { x { y: z; } }\n",
        "@media (50px + 50px < width < 600px) { x { y: z; } }\n",
        "@media (a) and #{\"(b) and (c)\"} { x { y: z; } }\n",
        "@media screen { }\n",
        "@media screen, print { x { y: z; } }\n",
    ));
}

#[test]
fn media_rejects_malformed_queries() {
    // dart-sass rejects these; sasso must error rather than pass them through.
    for src in [
        "@media a or (b) { x { y: z; } }\n",
        "@media (a) and (b) or (c) { x { y: z; } }\n",
        "@media a and { x { y: z; } }\n",
        "@media not { x { y: z; } }\n",
        "@media not(a) { x { y: z; } }\n",
        "@media (a) and(b) { x { y: z; } }\n",
        "@media (1 < width < 2 < 3) { x { y: z; } }\n",
        "@media (1px > width < 2px) { x { y: z; } }\n",
        "@media (width < = 100px) { x { y: z; } }\n",
    ] {
        let res = compile(src, &Options::default());
        assert!(res.is_err(), "expected error for malformed media: {src}");
    }
}

#[test]
fn media_rejects_bare_declarations_at_root() {
    // A bare declaration directly in a media block without an enclosing style
    // rule is an error in dart-sass; with a style rule it is allowed.
    assert!(compile("@media screen { color: red; }\n", &Options::default()).is_err());
    assert!(compile("@media a { @media b { color: red; } }\n", &Options::default()).is_err());
    assert_parity(".x {\n  @media screen {\n    color: red;\n  }\n}\n");
}

/// Compile `scss` and return our CSS (panicking on error), for direct
/// expected-output assertions that do not need a live dart-sass.
///
/// `compile` returns the stylesheet WITHOUT a trailing newline (the library
/// API). The goldens here were captured from the dart-sass CLI, which appends
/// one to NON-empty output (empty output stays empty), so mirror that —
/// matching `tests/integration.rs::css`. The no-trailing-newline contract is
/// pinned by `tests/integration.rs::library_api_omits_trailing_newline`.
fn ours(scss: &str) -> String {
    cli_form(compile(scss, &Options::default()).expect("our compile failed"))
}

/// Compile indented-syntax `sass` and return our CSS (panicking on error).
/// Re-attaches the CLI's trailing newline — see [`ours`].
fn ours_sass(sass: &str) -> String {
    cli_form(
        compile(sass, &Options::default().with_syntax(sasso::Syntax::Sass))
            .expect("our indented compile failed"),
    )
}

/// Mirror the dart-sass CLI's output framing: a single trailing newline on
/// non-empty CSS, nothing on empty CSS.
fn cli_form(css: String) -> String {
    if css.is_empty() {
        css
    } else {
        css + "\n"
    }
}

/// Compile `scss` and return the error message (panicking on success).
fn ours_err(scss: &str) -> String {
    compile(scss, &Options::default())
        .expect_err("compile unexpectedly succeeded")
        .to_string()
}

#[test]
fn rgb_hsl_special_value_passthrough() {
    // A special channel argument (var/env/calc) preserves the call,
    // comma-joined, when there are three components.
    assert_eq!(
        ours("a {b: rgb(var(--foo), 2, 3)}\n"),
        "a {\n  b: rgb(var(--foo), 2, 3);\n}\n"
    );
    assert_eq!(
        ours("a {b: rgb(var(--foo) 2 3)}\n"),
        "a {\n  b: rgb(var(--foo), 2, 3);\n}\n"
    );
    assert_eq!(
        ours("a {b: rgb(calc(1px + 1%), 2, 3, 0.4)}\n"),
        "a {\n  b: rgb(calc(1px + 1%), 2, 3, 0.4);\n}\n"
    );
    assert_eq!(
        ours("a {b: hsl(var(--x) 50% 50%)}\n"),
        "a {\n  b: hsl(var(--x), 50%, 50%);\n}\n"
    );
    // A concrete color plus a special alpha decomposes to channels.
    assert_eq!(
        ours("a {b: rgb(blue, var(--foo))}\n"),
        "a {\n  b: rgb(0, 0, 255, var(--foo));\n}\n"
    );
    // Wrong component count is preserved verbatim (space-joined).
    assert_eq!(
        ours("a {b: rgb(var(--foo) 2)}\n"),
        "a {\n  b: rgb(var(--foo) 2);\n}\n"
    );
    assert_eq!(
        ours("a {b: rgb(var(--foo))}\n"),
        "a {\n  b: rgb(var(--foo));\n}\n"
    );
    assert_eq!(
        ours("a {b: rgb(var(--foo), 0.4)}\n"),
        "a {\n  b: rgb(var(--foo), 0.4);\n}\n"
    );
    // A special-value passthrough echoes the spelling the caller used: `rgba`
    // and `hsla` stay `rgba`/`hsla` (dart-sass does not normalize them to
    // `rgb`/`hsl`). Regression for Bootstrap's `rgba(var(--x), …)` output.
    assert_eq!(
        ours("a {b: rgba(var(--foo), 0.65)}\n"),
        "a {\n  b: rgba(var(--foo), 0.65);\n}\n"
    );
    assert_eq!(
        ours("a {b: rgba(var(--foo) 2 3)}\n"),
        "a {\n  b: rgba(var(--foo), 2, 3);\n}\n"
    );
    assert_eq!(
        ours("a {b: hsla(var(--x) 50% 50%)}\n"),
        "a {\n  b: hsla(var(--x), 50%, 50%);\n}\n"
    );
    // The two-argument `$color, $alpha` form echoes the spelling the caller
    // used whenever the alpha stays opaque — a `var()`/`env()` alpha, or a
    // non-foldable `calc(var())`. An `rgb()` caller stays `rgb`, `rgba()` stays
    // `rgba`; the opaque alpha must NOT force `rgba`.
    assert_eq!(
        ours("a {b: rgba(blue, var(--foo))}\n"),
        "a {\n  b: rgba(0, 0, 255, var(--foo));\n}\n"
    );
    assert_eq!(
        ours("a {b: rgb(blue, env(--foo))}\n"),
        "a {\n  b: rgb(0, 0, 255, env(--foo));\n}\n"
    );
    assert_eq!(
        ours("a {b: rgb(blue, calc(var(--foo)))}\n"),
        "a {\n  b: rgb(0, 0, 255, calc(var(--foo)));\n}\n"
    );
    assert_eq!(
        ours("a {b: rgba(blue, calc(var(--foo)))}\n"),
        "a {\n  b: rgba(0, 0, 255, calc(var(--foo)));\n}\n"
    );
    // A `calc()` alpha that folds to a number is resolved to a real color via
    // the normal compute path (not the opaque branch above), so it serializes
    // as `rgba` purely because the resolved alpha is < 1.
    assert_eq!(
        ours("a {b: rgb(blue, calc(0.4))}\n"),
        "a {\n  b: rgba(0, 0, 255, 0.4);\n}\n"
    );
    // The relative-color `from` form also echoes the caller's spelling.
    assert_eq!(
        ours("a {b: rgba(from red r g b)}\n"),
        "a {\n  b: rgba(from red r g b);\n}\n"
    );
    assert_eq!(
        ours("a {b: hsla(from red h s l)}\n"),
        "a {\n  b: hsla(from red h s l);\n}\n"
    );
    // A `none`-only call still normalizes to the canonical space name.
    assert_eq!(
        ours("a {b: rgba(none none none)}\n"),
        "a {\n  b: rgb(none none none);\n}\n"
    );
}

#[test]
fn rgb_hsl_plain_number_channels_keep_function_spelling() {
    // The one-argument channels list computes a color but keeps the rgb()/hsl()
    // spelling (it never collapses to hex).
    assert_eq!(ours("a {b: rgb(18 52 86)}\n"), "a {\n  b: rgb(18, 52, 86);\n}\n");
    assert_eq!(
        ours("a {b: rgb(1 2 3 / 0.5)}\n"),
        "a {\n  b: rgba(1, 2, 3, 0.5);\n}\n"
    );
    assert_eq!(
        ours("a {b: rgb(190 173 237 / 1)}\n"),
        "a {\n  b: rgb(190, 173, 237);\n}\n"
    );
    assert_eq!(
        ours("a {b: hsl(120 50% 50% / 0.4)}\n"),
        "a {\n  b: hsla(120, 50%, 50%, 0.4);\n}\n"
    );
    // Two-argument (color, alpha) form still collapses to a computed color.
    assert_eq!(ours("a {b: rgb(#123, 1)}\n"), "a {\n  b: #112233;\n}\n");
    assert_eq!(
        ours("a {b: rgb(#123, 0.5)}\n"),
        "a {\n  b: rgba(17, 34, 51, 0.5);\n}\n"
    );
    // hsl saturation floors at 0, lightness is left unclamped, hue normalizes.
    assert_eq!(
        ours("a {b: hsl(0, 500%, 50%)}\n"),
        "a {\n  b: hsl(0, 500%, 50%);\n}\n"
    );
    assert_eq!(
        ours("a {b: hsl(0, -100%, 50%)}\n"),
        "a {\n  b: hsl(0, 0%, 50%);\n}\n"
    );
    assert_eq!(
        ours("a {b: hsl(0, 100%, -100%)}\n"),
        "a {\n  b: hsl(0, 100%, -100%);\n}\n"
    );
    assert_eq!(
        ours("a {b: hsl(360, 50%, 50%)}\n"),
        "a {\n  b: hsl(0, 50%, 50%);\n}\n"
    );
}

#[test]
fn hwb_global_conversion_and_passthrough() {
    // Plain-number channels convert HWB -> HSL spelling.
    assert_eq!(
        ours("a {b: hwb(180 30% 40%)}\n"),
        "a {\n  b: hsl(180, 33.3333333333%, 45%);\n}\n"
    );
    assert_eq!(
        ours("a {b: hwb(180 30% 40% / 0.5)}\n"),
        "a {\n  b: hsla(180, 33.3333333333%, 45%, 0.5);\n}\n"
    );
    assert_eq!(
        ours("a {b: hwb(180 30% 40% / 1)}\n"),
        "a {\n  b: hsl(180, 33.3333333333%, 45%);\n}\n"
    );
    // Special and `none` channels preserve the call verbatim, space-joined,
    // with a bare numeric hue suffixed `deg`.
    assert_eq!(
        ours("a {b: hwb(var(--c) 30% 40%)}\n"),
        "a {\n  b: hwb(var(--c) 30% 40%);\n}\n"
    );
    assert_eq!(
        ours("a {b: hwb(none 30% 40%)}\n"),
        "a {\n  b: hwb(none 30% 40%);\n}\n"
    );
    assert_eq!(
        ours("a {b: hwb(0 none 40%)}\n"),
        "a {\n  b: hwb(0deg none 40%);\n}\n"
    );
    assert_eq!(
        ours("a {b: hwb(0 30% none)}\n"),
        "a {\n  b: hwb(0deg 30% none);\n}\n"
    );
}

#[test]
fn lab_family_validation_and_passthrough() {
    // Well-formed, fully numeric and special-value calls are preserved verbatim.
    assert_eq!(ours("a {b: lab(1% 2 3)}\n"), "a {\n  b: lab(1% 2 3);\n}\n");
    assert_eq!(
        ours("a {b: lab(var(--foo) 2 3)}\n"),
        "a {\n  b: lab(var(--foo) 2 3);\n}\n"
    );
    assert_eq!(
        ours("a {b: lab(var(--foo) 2)}\n"),
        "a {\n  b: lab(var(--foo) 2);\n}\n"
    );
    assert_eq!(
        ours("a {b: lab(from var(--c) l a b)}\n"),
        "a {\n  b: lab(from var(--c) l a b);\n}\n"
    );
    assert_eq!(ours("a {b: lch(1% 2 3deg)}\n"), "a {\n  b: lch(1% 2 3deg);\n}\n");
    // Malformed calls raise validation errors.
    for src in [
        "a {b: lab(1% 2)}\n",
        "a {b: lab(1% 2 3 0.4)}\n",
        "a {b: lab(c 2 3)}\n",
        "a {b: lab(1px 2 3)}\n",
        "a {b: lab(1% 2 3/0.4px)}\n",
        "a {b: lab()}\n",
        "a {b: lab(1%, 2, 3, 0.4)}\n",
        "a {b: lab((1%, 2, 3))}\n",
        "a {b: lch(1% 2 3px)}\n",
        "a {b: lch(1% 2 3%)}\n",
    ] {
        assert!(
            compile(src, &Options::default()).is_err(),
            "expected error for {src}"
        );
    }
}

#[test]
fn color_function_validation_and_passthrough() {
    // Well-formed and special/relative calls are preserved verbatim.
    assert_eq!(
        ours("a {b: color(srgb 0.1 0.2 0.3)}\n"),
        "a {\n  b: color(srgb 0.1 0.2 0.3);\n}\n"
    );
    assert_eq!(
        ours("a {b: color(srgb calc(infinity) 0 0)}\n"),
        "a {\n  b: color(srgb calc(infinity) 0 0);\n}\n"
    );
    assert_eq!(
        ours("a {b: color(from var(--c) srgb r g b)}\n"),
        "a {\n  b: color(from var(--c) srgb r g b);\n}\n"
    );
    // Malformed calls raise validation errors.
    for src in [
        "a {b: color()}\n",
        "a {b: color(srgb)}\n",
        "a {b: color(1 2 3)}\n",
        "a {b: color(foo 1 2 3)}\n",
        "a {b: color(srgb 0.1 0.2)}\n",
        "a {b: color(srgb 0.1 0.2 0.3 0.4)}\n",
        "a {b: color(srgb c 0.2 0.3)}\n",
        "a {b: color(srgb 0.1px 0.2 0.3)}\n",
        "a {b: color((srgb, 0.1, 0.2, 0.3))}\n",
        "a {b: color(srgb (0.1 0.2 0.3))}\n",
    ] {
        assert!(
            compile(src, &Options::default()).is_err(),
            "expected error for {src}"
        );
    }
}

#[test]
fn rgb_degenerate_calc_constants_fold() {
    // calc(infinity)/calc(-infinity)/calc(NaN) fold to floating-point channel
    // and alpha values for the legacy rgb function (clamped, NaN -> bound).
    assert_eq!(
        ours("a {b: rgb(calc(infinity), 0, 0, 0.5)}\n"),
        "a {\n  b: rgba(255, 0, 0, 0.5);\n}\n"
    );
    assert_eq!(
        ours("a {b: rgb(calc(-infinity), 0, 0, 0.5)}\n"),
        "a {\n  b: rgba(0, 0, 0, 0.5);\n}\n"
    );
    assert_eq!(
        ours("a {b: rgb(calc(NaN), 0, 0, 0.5)}\n"),
        "a {\n  b: rgba(0, 0, 0, 0.5);\n}\n"
    );
    assert_eq!(
        ours("a {b: rgb(0, 0, 0, calc(infinity))}\n"),
        "a {\n  b: rgb(0, 0, 0);\n}\n"
    );
    assert_eq!(
        ours("a {b: rgb(0, 0, 0, calc(-infinity))}\n"),
        "a {\n  b: rgba(0, 0, 0, 0);\n}\n"
    );
    assert_eq!(
        ours("a {b: rgb(0, 0, 0, calc(NaN))}\n"),
        "a {\n  b: rgba(0, 0, 0, 0);\n}\n"
    );
    // A non-degenerate calc is still a special value preserved verbatim, and a
    // degenerate calc in a modern color function (color()) is preserved too.
    assert_eq!(
        ours("a {b: rgb(calc(1px + 1%), 2, 3, 0.4)}\n"),
        "a {\n  b: rgb(calc(1px + 1%), 2, 3, 0.4);\n}\n"
    );
    assert_eq!(
        ours("a {b: color(srgb calc(infinity) 0 0)}\n"),
        "a {\n  b: color(srgb calc(infinity) 0 0);\n}\n"
    );
}

#[test]
fn modern_if_function() {
    // The modern CSS `if()` conditional: `css()` conditions emit the whole
    // call verbatim; `sass()`/bare conditions are evaluated (first truthy
    // clause wins, else otherwise); the legacy `if($c, $t, $f)` builtin still
    // works. Each case byte-matches dart-sass.
    for src in [
        // verbatim css() forms (single, else, raw chars, not, and/or, parens)
        "a {b: if(css(): c)}\n",
        "a {b: if(css(): c; else: d)}\n",
        "a {b: if(css(!@#$%^&*(){}[]_-+=|:;''\"\"<>,./?): c)}\n",
        "a {b: if(not css(): c)}\n",
        "a {b: if(not (css()): c)}\n",
        "a {b: if(css(1) and css(2): c)}\n",
        "a {b: if(css(1) and (css(2)): c)}\n",
        "a {b: if(css(1) or css(2) or css(3): c)}\n",
        "a {b: if((css()): c)}\n",
        "a {b: if((css(1) and css(2)): c)}\n",
        // arbitrary substitutions (var/attr/nested if/interpolation), verbatim
        "a {b: if(var(--not) css(): c)}\n",
        "a {b: if(css(1) var(--and) css(2): c)}\n",
        "a {b: if(css() if(else: var(--and-clause)): c)}\n",
        "a {b: if(css(1) #{\"and\"} css(2): c)}\n",
        "a {b: if(#{css}(): c)}\n",
        "a {b: if(css(#{1 + 1}): c)}\n",
        // evaluated sass()/bare conditions
        "a {b: if(sass(true): c; else: d)}\n",
        "a {b: if(sass(false): c; else: d)}\n",
        "$a: true;\nb {c: if(sass($a): d; else: e)}\n",
        "a {b: if(not sass(true): c; else: d)}\n",
        "a {b: if(sass(true) and sass(false): c; else: d)}\n",
        "a {b: if(sass(false) or sass(true): c; else: d)}\n",
        // sass folded into a verbatim css() chain
        "a {b: if(sass(true) and css(): c; else: d)}\n",
        "a {b: if(sass(false) or css(): c; else: d)}\n",
        "a {b: if(css(1) and sass(true) and css(2): c; else: d)}\n",
        "a {b: if(sass(true) and (var(--not) css()): c)}\n",
        // short-circuit, else-only, evaluated values
        "a {b: if(sass(true): c; sass($undefined): d)}\n",
        "a {b: if(else: c)}\n",
        "a {b: if(css(): 1 + 2)}\n",
        "a {b: if(css(): (1 2 3))}\n",
        // legacy builtin stays intact
        "a {b: if(true, 1px, 2px)}\n",
        "a {b: if(false, 1px, 2px)}\n",
    ] {
        assert_parity(src);
    }
}

#[test]
fn modern_if_rejects_invalid_conditions() {
    // dart-sass rejects these; sasso must error too (mixing and/or, `not`
    // after a conjunction, reserved keyword as a function, and a `sass()`
    // sharing a boolean level with an unparenthesised arbitrary substitution).
    for src in [
        "a {b: if(css(1) and css(2) or css(3): c)}\n",
        "a {b: if(css(1) and not css(2): c)}\n",
        "a {b: if(not not css(): c)}\n",
        "a {b: if(not and(): d)}\n",
        "a {b: if(css(1) and(css(2)): d)}\n",
        "a {b: if(sass(true) and css(1) var(--and) css(2): c)}\n",
        "a {b: if((sass(true)) and css(1) var(--and) css(2): c)}\n",
        "a {b: if(css(1): c, css(2): d)}\n",
    ] {
        assert!(
            compile(src, &Options::default()).is_err(),
            "expected error for invalid modern if(): {src}"
        );
    }
}

#[test]
fn parity_plain_css_import_passthrough() {
    // A `url(...)` URL, a `.css`/protocol URL, or any URL with trailing
    // media-query / `supports()` modifiers is a plain CSS `@import`, emitted
    // verbatim in source order rather than inlined.
    assert_parity("@import url(\"a.css\") print;\n");
    assert_parity("@import url(whatever);\n");
    assert_parity("@import \"a.css\";\n");
    assert_parity("@import \"http://foo.com/bar\";\n");
    assert_parity("@import \"a\" b;\n");
    assert_parity("@import \"a.css\" supports(calc(1));\n");
    assert_parity("@import \"a.css\" supports(--a: );\n");
    assert_parity("@import \"a\" b, (c: d) and (e: f), g;\n");
    // A `supports()`/function modifier ends the argument at a top-level comma,
    // so the following URL starts a fresh `@import`; a bare media type does not.
    assert_parity("@import \"a\" supports(b: c), \"d.css\";\n");
    assert_parity("@import \"b\" c(d), \"e.css\";\n");
    // Comments around the URL and modifiers are stripped.
    assert_parity("@import \"a.css\" /**/ b;\n");
    assert_parity("@import \"a.css\" b /**/;\n");
    // Interpolation inside a CSS-import modifier is resolved.
    assert_parity("@import \"b\" c#{\"a\"}d;\n");
    // `#{…}` inside a `url("…")` import string is resolved (the bare quoted
    // `@import "…"` form keeps interpolation literal, so it is not tested here).
    assert_parity("$p: http;\n$f: Sans;\n@import url(\"#{$p}://x.com/c?family=#{$f}\");\n");
}

#[test]
fn parity_import_modifier_grammar() {
    // The structural `@import` modifier grammar (dart `tryImportModifiers`):
    // a `supports(<query>)` re-serializes canonically — `supports( a: b)` ->
    // `supports(a: b)`, a paren'd declaration unwraps (`supports((a: b))` ->
    // `supports(a: b)`), conditions/negations/functions keep one paren pair,
    // custom-property values stay verbatim; media queries canonicalize
    // (`and(c: d)` -> `and (c: d)`); unknown identifier/function runs pass
    // through space-joined.
    assert_parity(
        "@import \"a.css\" supports( a: b);\n@import \"a.css\" supports((a: b));\n@import \"a.css\" supports((a: b) and (c: d));\n@import \"a.css\" supports(not (a: b));\n@import \"a.css\" supports(a(b));\n@import \"a.css\" supports(calc(1));\n@import \"a.css\" supports(--a: b);\n@import \"a.css\" supports(--a: ,);\n",
    );
    assert_parity(
        "@import \"a\" b and(c: d), e;\n@import \"a\" supports(b: c) (d: e);\n@import \"a\" b c d(e) supports(f: g) h i j(k) l m (n: o), (p: q);\n@import \"b\" c(d), \"e.css\";\n",
    );
    // Wrong-order modifiers are rejected ("expected ';'." / identifier).
    assert_error_parity("@import \"a\" (b: c) supports(d: e);\n");
    assert_error_parity("@import \"a\" b, supports(c: d);\n");
    assert_error_parity("@import \"a\" b, \"c\";\n");
    assert_error_parity("@import url(\"a.css\") supports(--a:);\n");
}

/// A trivial in-memory [`Importer`] for offline `@import` inlining tests.
struct MapImporter(std::collections::HashMap<String, String>);

impl sasso::Importer for MapImporter {
    fn canonicalize(
        &self,
        url: &str,
        _ctx: &sasso::CanonicalizeContext<'_>,
    ) -> Result<Option<sasso::CanonicalUrl>, sasso::ImporterError> {
        Ok(self.0.contains_key(url).then(|| sasso::CanonicalUrl::new(url)))
    }

    fn load(
        &self,
        canonical: &sasso::CanonicalUrl,
    ) -> Result<Option<sasso::ImporterResult>, sasso::ImporterError> {
        Ok(self.0.get(canonical.as_str()).map(|c| sasso::ImporterResult {
            contents: c.clone(),
            syntax: sasso::Syntax::Scss,
            source_map_url: None,
        }))
    }
}

#[test]
fn import_inlines_sass_partials() {
    let mut files = std::collections::HashMap::new();
    files.insert("p".to_string(), "x { y: z }".to_string());
    files.insert(
        "nested".to_string(),
        "b { color: red; nested { x: y } }".to_string(),
    );
    let imp = MapImporter(files);
    let opts = Options::default().with_importer(&imp);

    // A bare quoted string with no modifiers is inlined at the top level.
    let css = compile("@import \"p\";\n", &opts).expect("import compile failed");
    assert_eq!(css, "x {\n  y: z;\n}");

    // A nested `@import` runs the imported statements under the current parent
    // selector, so the imported rules nest beneath it.
    let css = compile("a {\n  @import \"nested\";\n}\n", &opts).expect("nested import failed");
    assert_eq!(css, "a b {\n  color: red;\n}\na b nested {\n  x: y;\n}");
}

#[test]
fn import_reimports_and_detects_cycles() {
    let mut files = std::collections::HashMap::new();
    files.insert("p".to_string(), "x { y: z }".to_string());
    files.insert("alpha".to_string(), "@import \"beta\";".to_string());
    files.insert("beta".to_string(), "@import \"alpha\";".to_string());
    let imp = MapImporter(files);
    let opts = Options::default().with_importer(&imp);

    // Re-importing an already-finished file emits its content again (`@import`
    // re-evaluates), rather than being silently deduplicated.
    let css = compile("@import \"p\", \"p\";\n", &opts).expect("import compile failed");
    assert_eq!(css, "x {\n  y: z;\n}\n\nx {\n  y: z;\n}");

    // A load cycle is an error rather than a silent skip or an infinite loop.
    assert!(compile("@import \"alpha\";\n", &opts).is_err());
}

#[test]
fn bracketed_list_literals() {
    // `[ ... ]` produces a bracketed list that serializes wrapped in square
    // brackets, preserving the interior separator and nesting (parenthesized
    // unbracketed lists flatten; nested bracketed lists stay nested).
    assert_parity("x { b: []; }\n");
    assert_parity("x { b: [c]; }\n");
    assert_parity("x { b: [c d]; }\n");
    assert_parity("x { b: [a, b]; }\n");
    assert_parity("x { b: [[]]; }\n");
    assert_parity("x { b: [[c]]; }\n");
    assert_parity("x { b: [[c] [d]]; }\n");
    assert_parity("x { b: [()]; }\n");
    assert_parity("x { b: [(c,)]; }\n");
    assert_parity("x { b: [(c,) (d e)]; }\n");
}

#[test]
fn comments_in_value_position() {
    // Loud `/* */` and silent `//` comments act as whitespace between value
    // tokens, and as operator separators (`1 /**/+/**/ 2`).
    assert_parity("a {\n  b: c // d\n}\n");
    assert_parity("a {\n  b: c /* d */ e;\n}\n");
    assert_parity("a {\n  c: 1 /**/+/**/ 2;\n}\n");
    assert_parity("a {\n  c: 1/**/+/**/2;\n}\n");
    assert_parity("a {\n  c: 1 +/**/ 2;\n}\n");
    assert_parity("a {\n  c: a /**/ b;\n}\n");
}

#[test]
fn calc_and_math_infinity_nan() {
    // Non-finite calc results serialize as `calc(infinity)` / `calc(NaN)` /
    // `calc(-infinity)` (with `* 1unit` when they carry a unit), and the math
    // functions accept the bare `infinity`/`-infinity`/`NaN`/`pi`/`e`
    // constants and re-wrap non-finite results in a calculation.
    assert_parity("a { b: calc(1/0); }\n");
    assert_parity("a { b: calc(10px / 0); }\n");
    assert_parity("a { b: calc(0/0); }\n");
    assert_parity("a { b: calc(-1/0); }\n");
    assert_parity("a { b: atan(infinity); }\n");
    assert_parity("a { b: atan(-infinity); }\n");
    assert_parity("a { b: sin(infinity); }\n");
    assert_parity("a { b: abs(infinity); }\n");
    assert_parity("a { b: sign(infinity); }\n");
    assert_parity("a { b: exp(-infinity); }\n");
    assert_parity("a { b: pow(infinity, 2); }\n");
    assert_parity("a { b: min(infinity, 5); }\n");
    assert_parity("a { b: max(5, infinity); }\n");
    assert_parity("a { b: min(NaN, 5); }\n");
    assert_parity("a { b: clamp(1, infinity, 10); }\n");
    assert_parity("a { b: cos(pi); }\n");
}

#[test]
fn round_strategies_and_steps() {
    // round() as a CSS calculation: strategy keyword + step, the two-argument
    // nearest-with-step form, unit coercion, a zero step (NaN), and the
    // non-finite cases — all byte-matched to dart-sass.
    assert_parity("a { b: round(nearest, 117px, 25px); }\n");
    assert_parity("a { b: round(up, 101px, 25px); }\n");
    assert_parity("a { b: round(down, 122px, 25px); }\n");
    assert_parity("a { b: round(to-zero, 120px, 25px); }\n");
    assert_parity("a { b: round(to-zero, -120px, -25px); }\n");
    assert_parity("a { b: round(up, 12px, -7px); }\n");
    assert_parity("a { b: round(117, 25); }\n");
    assert_parity("a { b: round(117cm, 25mm); }\n");
    assert_parity("a { b: round(4.6); }\n");
    assert_parity("a { b: round(nearest, 10px, 0px); }\n");
    assert_parity("a { b: round(nearest, infinity, 5); }\n");
    assert_parity("a { b: round(nearest, -infinity, 5); }\n");
    assert_parity("a { b: round(nearest, infinity, infinity); }\n");
    assert_parity("a { b: round(1px, 10%); }\n");
    assert_parity("a { b: round(1%, 2%); }\n");
    assert_parity("a { b: round(1foo, 2bar); }\n");
}

#[test]
fn trailing_commas_in_params_and_args() {
    // Trailing commas are allowed after ordinary params, defaulted params, the
    // rest param, and call arguments.
    assert_parity("@function a($b, ) { @return $b; }\nc { d: a(e, ); }\n");
    assert_parity("@function a($b: 1, ) { @return $b; }\nc { d: a(); }\n");
    assert_parity("@mixin m($b, $c..., ) { d: $b; e: $c; }\nf { @include m(1, 2, 3); }\n");
}

#[test]
fn splat_argument_expansion() {
    // A list splat spreads into positional args (with explicit positionals
    // bound first), and a map splat spreads into keyword args.
    assert_parity("a { b: rgb([1, 2]..., 3); }\n");
    assert_parity("a { b: rgb([1, 2]..., $blue: 3); }\n");
    assert_parity("@function id($a, $b, $c) { @return $a $b $c; }\nx { y: id(1, [2, 3]...); }\n");
    assert_parity("@function f($a, $b) { @return $a $b; }\nx { y: f((a: 1, b: 2)...); }\n");
}

#[test]
fn map_literals_and_builtins() {
    // Map literals serialize via inspect(); the global map functions and
    // @each over a map all byte-match dart-sass.
    assert_parity("a { b: inspect((c: 1, d: 2)); }\n");
    assert_parity("a { b: inspect((c: (d: 1), \"e\": f g)); }\n");
    assert_parity("a { b: map-get((c: d), c); }\n");
    assert_parity("a { b: map-keys((c: 1, d: 2)); }\n");
    assert_parity("a { b: map-values((c: 1, d: 2)); }\n");
    assert_parity("a { b: map-has-key((c: d), c); }\n");
    assert_parity("@each $k, $v in (a: 1, b: 2) { x-#{$k} { y: $v; } }\n");
}

#[test]
fn special_css_functions_verbatim() {
    // calc/element/expression (with/without vendor prefix) and unprefixed
    // type() preserve their arguments verbatim: vendor-prefixed and uppercase
    // names lower-case, `%`/`@`/`=`/punctuation and IE-hack syntax pass
    // through, loud comments survive, silent comments drop, whitespace
    // collapses, and `#{}` resolves — all byte-matched to dart-sass.
    assert_parity("a { b: -a-calc(/**/ c); }\n");
    assert_parity("a { b: -a-calc(c /**/); }\n");
    assert_parity("a {\n  b: -a-calc(//\n    c);\n}\n");
    assert_parity("a {\n  b: -a-calc(c //\n    );\n}\n");
    assert_parity("a { b: element(c d); }\n");
    assert_parity("a { b: expression(a=b); }\n");
    assert_parity("a { b: expression(opacity=80); }\n");
    assert_parity("a { b: TYPE(0); }\n");
    assert_parity("a { b: type(@#$%^&*({[]})_-+=); }\n");
    assert_parity("a { b: -A-CALC(0); }\n");
    assert_parity("a { b: -C-ELEMENT(0); }\n");
    assert_parity("a { b: -C-EXPRESSION(#{1 + 1}); }\n");
    assert_parity("a { b: -a-calc(  c   d  ); }\n");
}

#[test]
fn css_custom_function_mixin_passthrough() {
    // A `@function`/`@mixin` whose name begins with `--`, or any non-lowercase
    // spelling of the keyword, is a plain CSS custom function/mixin: emitted
    // verbatim. Top-level declaration values stay literal (`$b`, `1 + 1`,
    // arbitrary characters) with whitespace collapsed; interpolated properties
    // evaluate as SassScript; `#{}` resolves. Byte-matched to dart-sass.
    assert_parity("@function --a(--b <color>) {result: c}\n");
    assert_parity("@function --a() returns <ident> {result: b}\n");
    assert_parity("@function --#{a}() {result: b}\n");
    assert_parity("@function --a() {\n  result: $b;\n}\n");
    assert_parity("@function --a() {\n  result: 1 + 1;\n}\n");
    assert_parity("@function --a() {\n  result: #{1 + 1};\n}\n");
    assert_parity("@function --a() {\n  result: {}#&%^*;\n}\n");
    assert_parity("@function --a() {\n  RESULT: {b: c};\n}\n");
    assert_parity("@function --a() {\n  #{result}: 1 + 1;\n}\n");
    assert_parity("@FUNCTION --a() {\n  result: $b;\n}\n");
    assert_parity("@FUNCTION foo() {\n  result: $b;\n}\n");
    assert_parity("@MIXIN foo {}\n");
    assert_parity("@MIXIN --a {}\n");
    // A non-custom lowercase `@function`/`@mixin` is still a Sass definition.
    assert_parity("@function foo() { @return 1px * 2; }\na { b: foo(); }\n");
    assert_parity("@mixin foo { x: y; }\na { @include foo; }\n");
}

#[test]
fn special_url_function_passthrough() {
    // url() is recognised case-insensitively and with an optional vendor
    // prefix. A plain unquoted URL is emitted as a bare lower-cased `url(...)`
    // (the vendor prefix is dropped), tolerating `!` and other url-safe
    // characters and resolving `#{}` (including inside quoted strings). When
    // the contents are SassScript (a `$variable`) the call falls back to a
    // normal function so its arguments evaluate, keeping the original name.
    assert_parity("a { b: url(!); }\n");
    assert_parity("a { b: URL(!); }\n");
    assert_parity("a { b: URL(http://c.d/e!f); }\n");
    assert_parity("a { b: -c-url(0); }\n");
    assert_parity("a { b: -c-url(http://d.e/f!g); }\n");
    assert_parity("a { b: -c-url(#{0}); }\n");
    assert_parity("a { b: url(c, d); }\n");
    assert_parity("$a: b;\nc { d: url($a); }\n");
    assert_parity("$a: b;\nc { d: -e-url($a); }\n");
    assert_parity("$f: bar;\na {\n  foo: url($f);\n  foo: url(#{$f});\n  foo: url(\"x?v=#{$f}\");\n}\n");
}

#[test]
fn extended_named_colors() {
    // Every one of the 148 CSS named colors must resolve and feed color
    // functions; previously extended names like `plum` errored as "not a
    // color". Each rule round-trips through rgba() so the exact channel
    // values are byte-matched to dart-sass.
    assert_parity("a { b: rgba(plum, 0.5); }\n");
    assert_parity("a { b: rgba(rebeccapurple, 0.5); }\n");
    assert_parity("a { b: rgba(darkslategray, 0.5); }\n");
    assert_parity("a { b: desaturate(plum, 14%); }\n");
    assert_parity("a { b: rgba(cornflowerblue, 0.25); }\n");
    assert_parity("a { b: rgba(mediumspringgreen, 0.75); }\n");
    assert_parity("a { b: rgba(lightgoldenrodyellow, 1); }\n");
}

#[test]
fn legacy_color_argument_forms() {
    // The single-argument `$channels` list form, the `rgb($color, $alpha)`
    // two-argument form (positional and named), and the `none`-channel
    // verbatim spelling (a bare hue gains `deg`) — all byte-matched.
    assert_parity("a { b: hsl($channels: 0 100% 50%); }\n");
    assert_parity("a { b: rgb($channels: 1 2 3); }\n");
    assert_parity("a { b: rgb($color: #123, $alpha: 0.5); }\n");
    assert_parity("a { b: rgb($alpha: 0.5, $color: blue); }\n");
    assert_parity("a { b: rgb(red, 0.5); }\n");
    assert_parity("a { b: hsl(0 none 50%); }\n");
    assert_parity("a { b: hsl(0 100% none); }\n");
    assert_parity("a { b: hsl(none 100% 50%); }\n");
}

#[test]
fn hsl_degenerate_calc_channels() {
    // A degenerate calc() channel keeps the hsl() spelling, coercing each
    // channel like dart-sass: hue reduces mod 360 to calc(NaN); saturation
    // and lightness gain `* 1%`, with saturation clamping non-positive/NaN
    // to 0%. Byte-matched to dart-sass.
    assert_parity("a { b: hsl(calc(infinity), 100%, 50%); }\n");
    assert_parity("a { b: hsl(calc(-infinity), 100%, 50%); }\n");
    assert_parity("a { b: hsl(calc(NaN), 100%, 50%); }\n");
    assert_parity("a { b: hsl(0, calc(infinity), 50%); }\n");
    assert_parity("a { b: hsl(0, calc(-infinity), 50%); }\n");
    assert_parity("a { b: hsl(0, calc(NaN), 50%); }\n");
    assert_parity("a { b: hsl(0, 100%, calc(infinity)); }\n");
    assert_parity("a { b: hsl(0, 100%, calc(-infinity)); }\n");
    assert_parity("a { b: hsl(0, 100%, calc(NaN)); }\n");
}

#[test]
fn degenerate_channel_colors_are_colors() {
    // An hsl()/color() call whose infinite channel SURVIVES parsing is a real
    // color: dart-sass stores the infinity, so the color module answers for
    // it, `meta.type-of` says `color` (and `string.length` rejects it), and
    // both output styles serialize the stored channel.
    for scss in [
        "a { b: hsl(0, 100%, calc(-infinity * 1%)); }\n",
        "a { b: hsl(0, 100%, calc(infinity * 1%)); }\n",
        "a { b: hsl(0, calc(infinity * 1%), 50%); }\n",
        "a { b: hsl(0, calc(-infinity * 1%), 50%); }\n",
        "a { b: hsl(0, calc(infinity * 1%), calc(-infinity * 1%)); }\n",
        "a { b: hsl(400, 250%, calc(infinity * 1%)); }\n",
        "a { b: hsl(0.5turn, -250%, calc(infinity * 1%)); }\n",
        "a { b: hsla(0, 100%, calc(infinity * 1%), 0.5); }\n",
        "a { b: hsl(0, 100%, calc(infinity * 1%), 1); }\n",
        "a { b: hsl(0 100% calc(-infinity * 1%) / 0.25); }\n",
        "a { b: color(srgb 0 0 calc(infinity) / 0.5); }\n",
        "a { b: color(srgb 0 0 calc(-infinity) / 0.5); }\n",
        "a { b: color(srgb calc(infinity * 1%) 0 0); }\n",
        "a { b: color(srgb 50% 0 calc(1/0)); }\n",
        "a { b: color(srgb 0 0 0 / calc(NaN)); }\n",
        "a { b: color(xyz 0 0 calc(infinity) / 0.5); }\n",
        "@use \"sass:meta\"; a { b: meta.type-of(hsl(0, 100%, calc(-infinity * 1%))); }\n",
        "@use \"sass:meta\"; a { b: meta.inspect(hsl(0, 100%, calc(-infinity * 1%))); }\n",
        "@use \"sass:color\"; a { b: color.space(hsl(0, 100%, calc(-infinity * 1%))); }\n",
        "@use \"sass:color\"; a { b: color.channel(hsl(0, 100%, calc(-infinity * 1%)), \"lightness\"); }\n",
        "@use \"sass:color\"; a { b: color.channel(hsl(0, 100%, calc(-infinity * 1%)), \"saturation\"); }\n",
        "@use \"sass:color\"; a { b: color.channel(color(srgb 0 0 calc(infinity) / 0.5), \"blue\"); }\n",
        "@use \"sass:color\"; a { b: color.is-in-gamut(hsl(0, 100%, calc(-infinity * 1%)), $space: srgb); }\n",
        "@use \"sass:color\"; a { b: color.to-space(hsl(0, 100%, calc(-infinity * 1%)), srgb); }\n",
        "@use \"sass:color\"; a { b: color.grayscale(hsl(0, 100%, calc(-infinity * 1%))); }\n",
        "@use \"sass:color\"; a { b: color.change(hsl(0, 100%, calc(-infinity * 1%)), $lightness: 50%); }\n",
        // Mixing one leaves the infinity in the rgb channel the conversion
        // left it in and NaN in the two its arithmetic wiped out. An
        // out-of-gamut rgb result is written through its hsl form, reading a
        // non-finite channel as 0 — but its INSPECT form keeps the channels.
        "@use \"sass:color\"; a { b: color.mix(hsl(0, 100%, calc(-infinity * 1%)), red); }\n",
        "@use \"sass:color\"; @use \"sass:meta\"; a { b: meta.inspect(color.mix(hsl(0, 100%, calc(-infinity * 1%)), red)); }\n",
        "a { b: hsl(0, 100%, calc(-infinity * 1%)) == hsl(0, 100%, calc(-infinity * 1%)); }\n",
        "a { b: hsl(0, 100%, calc(-infinity * 1%)) == hsl(0, 100%, 0%); }\n",
    ] {
        assert_parity(scss);
        assert_parity_compressed(scss);
    }
    // A color is not a string, and it has no arithmetic with a number.
    assert_error_parity(
        "@use \"sass:string\"; a { b: string.length(hsl(0, 100%, calc(-infinity * 1%))); }\n",
    );
    assert_error_parity("a { b: 1px + hsl(0, 100%, calc(-infinity * 1%)); }\n");
}

#[test]
fn out_of_gamut_legacy_rgb_serialization() {
    // A legacy rgb color outside the [0, 255] gamut — which only a color-space
    // conversion can produce — is written through its hsl form in CSS output
    // and as `rgb()` in its inspect form, and the two disagree about more than
    // the function name: the inspect form re-spells all three channels as
    // percentages as soon as one is non-integral.
    for scss in [
        "@use \"sass:color\"; a { b: color.to-space(color(srgb 2 0 0), rgb); }\n",
        "@use \"sass:color\"; a { b: color.to-space(color(srgb 2 0 0.5), rgb); }\n",
        "@use \"sass:color\"; a { b: color.to-space(color(srgb -0.5 0 0), rgb); }\n",
        "@use \"sass:color\"; @use \"sass:meta\"; a { b: meta.inspect(color.to-space(color(srgb 2 0 0), rgb)); }\n",
        "@use \"sass:color\"; @use \"sass:meta\"; a { b: meta.inspect(color.to-space(color(srgb 2 0 0.5), rgb)); }\n",
        "@use \"sass:color\"; @use \"sass:meta\"; a { b: meta.inspect(color.to-space(color(srgb -0.5 0 0), rgb)); }\n",
        "@use \"sass:color\"; @use \"sass:meta\"; a { b: meta.inspect(rgba(color.to-space(color(srgb 2 0 0.5), rgb), 0.5)); }\n",
        "@use \"sass:color\"; @use \"sass:meta\"; a { b: meta.inspect(color.to-space(color(srgb calc(infinity) 0.5 0), rgb)); }\n",
    ] {
        assert_parity(scss);
        assert_parity_compressed(scss);
    }
}

#[test]
fn mix_srgb_method_matches_legacy() {
    // The `srgb`/`rgb` interpolation methods reproduce the legacy mix this
    // build computes, and must byte-match dart-sass (other spaces require
    // full color-space interpolation and are validated elsewhere).
    assert_parity("a { b: mix(red, blue, $method: srgb); }\n");
    assert_parity("a { b: mix(red, blue, $method: rgb); }\n");
    assert_parity("a { b: mix(red, blue, 25%, $method: srgb); }\n");
}

#[test]
fn relative_color_from_is_preserved() {
    // A relative-color `rgb(from … )`/`hsl(from … )` call is kept verbatim
    // rather than computed or rejected by the channel-count check.
    assert_parity("a { b: rgb(from red r g b); }\n");
    assert_parity("a { b: hsl(from red h s l); }\n");
    assert_parity("a { b: rgb(from var(--c) r g b); }\n");
}

#[test]
fn slash_with_special_value_forms_slash() {
    // dart-sass: `/` between non-number operands (a calc()/var()/unquoted
    // string/list, or a number divided by a non-number) does not divide — it
    // forms a slash-separated unquoted string `left/right`. A `calc()` that
    // folds to a number keeps the slash spelling too. A color on the *left*
    // of `/` is the one case that still errors ("Undefined operation").
    assert_parity("a { b: calc(1)/2; }\n");
    assert_parity("a { b: 1/calc(2); }\n");
    assert_parity("a { b: calc(1)/calc(2); }\n");
    assert_parity("a { b: calc(2px)/calc(4px); }\n");
    assert_parity("a { b: calc(1px + 1%)/2; }\n");
    assert_parity("a { b: 2/calc(1px + 1%); }\n");
    assert_parity("a { b: calc(1px + 1%)/calc(2px + 2%); }\n");
    assert_parity("a { b: foo / 2; }\n");
    assert_parity("a { b: var(--x) / 2; }\n");
    assert_parity("a { b: 2 / var(--x); }\n");
    assert_parity("a { b: (1 2) / 3; }\n");
    assert_parity("a { b: 2 / red; }\n");
}

#[test]
fn calc_infinity_nan_constants() {
    // `infinity`/`-infinity`/`nan` are calc() numeric constants (like
    // `pi`/`e`), resolved case-insensitively. They fold through arithmetic
    // (`infinity * 2` -> `infinity`) and canonicalize their spelling; a
    // unit-carrying non-finite renders (and parenthesizes) as `infinity * 1px`.
    assert_parity("a { b: calc(infinity * 2); }\n");
    assert_parity("a { b: calc(-infinity * 2); }\n");
    assert_parity("a { b: calc(NAN * 2); }\n");
    assert_parity("a { b: calc(InFiNiTy); }\n");
    assert_parity("a { b: calc(nan); }\n");
    assert_parity("a { b: calc(infinity * (1% + 1px)); }\n");
    assert_parity("a { b: calc((1/0) * (1% + 1px)); }\n");
    assert_parity("a { b: calc(infinity * 1px); }\n");
    assert_parity("a { b: calc(2 * infinity * 1px); }\n");
    assert_parity("a { b: calc(var(--c) / (infinity * 1px)); }\n");
    assert_parity("a { b: calc(var(--c) - (infinity * 1px)); }\n");
    // The degenerate-constant color channels still resolve (the calc value
    // keeps the spelling the color builtins inspect).
    assert_parity("a { b: rgb(calc(infinity), 0, 0, 0.5); }\n");
    assert_parity("a { b: rgb(calc(NaN), 0, 0, 0.5); }\n");
}

#[test]
fn calc_wrapping_complete_calculation_flattens() {
    // `calc()` wrapping a single already-complete calculation drops the
    // redundant outer `calc()` (dart-sass): `calc(min(1%, 2px))` -> `min(…)`.
    // A real operation inside keeps the wrapper, and a non-calculation leaf
    // (`var()`, unknown function) keeps its `calc()`.
    assert_parity("a { b: calc(min(1%, 2px)); }\n");
    assert_parity("a { b: calc(max(1%, 2px)); }\n");
    assert_parity("a { b: calc(clamp(1%, 2px, 3%)); }\n");
    assert_parity("a { b: calc(round(1%, 2px)); }\n");
    assert_parity("a { b: calc(calc-size(1%, 2px)); }\n");
    assert_parity("a { b: calc(min(1%, 2px) + 1px); }\n");
    assert_parity("a { b: calc(var(--x)); }\n");
    assert_parity("a { b: calc(unknownfn(1%, 2px)); }\n");
}

#[test]
fn calc_relative_length_cross_dimension_errors() {
    // A relative length (`em`, `ch`, `vw`, …) is a known *length*, so mixing
    // it with another dimension in calc() `+`/`-` is incompatible (dart-sass
    // errors), even though it is not convertible to an absolute length.
    for src in [
        "a {b: calc(1ch + 1deg)}\n",
        "a {b: calc(1em + 1s)}\n",
        "a {b: calc(1vw + 1hz)}\n",
        "a {b: calc(1rem + 1dpi)}\n",
        "a {b: calc(1vmax - 1khz)}\n",
        "a {b: calc(1ex + 1grad)}\n",
    ] {
        assert!(
            compile(src, &Options::default()).is_err(),
            "expected error for {src}"
        );
    }
    // Two lengths (even when one is relative and not convertible) are
    // compatible and preserved; `%`, `fr`, and unknown units never error.
    assert_parity("a { b: calc(1px + 1vw); }\n");
    assert_parity("a { b: calc(1em + 1px); }\n");
    assert_parity("a { b: calc(1ch + 1em); }\n");
    assert_parity("a { b: calc(1fr + 1px); }\n");
    assert_parity("a { b: calc(1% + 1deg); }\n");
    assert_parity("a { b: calc(1foo + 1deg); }\n");
}

#[test]
fn calc_value_plus_strictness() {
    // A calculation may only be `+`-concatenated with a string; against any
    // other operand (number, color, bool, list, another calculation)
    // dart-sass raises "Undefined operation".
    for src in [
        "a {b: calc(var(--c)) + 1}\n",
        "a {b: 1 + calc(var(--c))}\n",
        "a {b: calc(var(--c)) + calc(var(--d))}\n",
        "a {b: calc(var(--c)) + true}\n",
        "a {b: calc(var(--c)) + red}\n",
        "a {b: red + calc(var(--c))}\n",
    ] {
        assert!(
            compile(src, &Options::default()).is_err(),
            "expected error for {src}"
        );
    }
    // Concatenation with a string is allowed; a calc on the left inherits the
    // right string's quotedness.
    assert_parity("a { b: calc(var(--c)) + foo; }\n");
    assert_parity("a { b: foo + calc(var(--c)); }\n");
    assert_parity("a { b: calc(var(--c)) + \"x\"; }\n");
    assert_parity("a { b: \"x\" + calc(var(--c)); }\n");
}

#[test]
fn calc_operand_value_strictness() {
    // A value resolved into a calc() that is not a number, calculation, or
    // unquoted special string — a null, bool, color, list, map, or quoted
    // string (typically via a `$variable`) — is rejected.
    for src in [
        "$a: null;\nb {c: calc($a)}\n",
        "$a: true;\nb {c: calc($a)}\n",
        "$a: blue;\nb {c: calc($a)}\n",
        "$a: 1 2 3;\nb {c: calc($a)}\n",
        "$a: (1, 2);\nb {c: calc($a)}\n",
        "$a: (b: c);\nb {c: calc($a)}\n",
        "$a: \"foo\";\nb {c: calc($a)}\n",
    ] {
        assert!(
            compile(src, &Options::default()).is_err(),
            "expected error for {src}"
        );
    }
    // A number, var(), interpolation, or plain ident operand is fine.
    assert_parity("a { b: calc(foo); }\n");
    assert_parity("a { b: calc(var(--x)); }\n");
    assert_parity("a { b: calc(#{foo}); }\n");
}

#[test]
fn calc_space_list_grammar() {
    // A space-separated run inside calc() is only legal when it carries a
    // var()/env() substitution or interpolation (spliced verbatim); a run of
    // ordinary operands has no operator between adjacent terms ("Missing math
    // operator.").
    assert_parity("a { b: calc(var(--c) 1); }\n");
    assert_parity("a { b: calc(1 var(--c)); }\n");
    assert_parity("a { b: calc(1 var(--c) 2); }\n");
    assert_parity("a { b: calc(#{\"1 +\"} 2); }\n");
    assert_parity("a { b: calc(1 #{\"+ 2\"}); }\n");
    assert_parity("a { b: calc(1 #{\"+ 2 +\"} 3); }\n");
    for src in [
        "a {b: calc(1 2)}\n",
        "a {b: calc(c 1 2)}\n",
        "a {b: calc(1 2 c)}\n",
        "a {b: calc(1 (3))}\n",
        "a {b: calc(1 calc(1px + 1%))}\n",
        "$c: 1;\n$d: 2;\na {b: calc($c $d)}\n",
    ] {
        assert!(
            compile(src, &Options::default()).is_err(),
            "expected error for {src}"
        );
    }
}

#[test]
fn calc_rejects_non_arithmetic_operators() {
    // Only `+`/`-`/`*`/`/` are valid in a calculation; modulo, comparisons,
    // and `and`/`or` are rejected ("This operation can't be used in a
    // calculation.").
    for src in [
        "a {b: calc(1px % 2px)}\n",
        "a {b: calc(1 > 2)}\n",
        "a {b: calc(1 == 2)}\n",
        "a {b: calc(1 and 2)}\n",
    ] {
        assert!(
            compile(src, &Options::default()).is_err(),
            "expected error for {src}"
        );
    }
}

#[test]
fn calc_name_is_case_insensitive() {
    // `calc` is recognized case-insensitively and its interior simplified;
    // a vendor-prefixed form stays a verbatim special function.
    assert_parity("a { b: CaLc(1px); }\n");
    assert_parity("a { b: Calc(2); }\n");
    assert_parity("a { b: CALC(1px + 1%); }\n");
    assert_parity("a { b: -webkit-calc(1px + 1%); }\n");
}

#[test]
fn slash_chain_keeps_spelling_through_special_value() {
    // A slash-division operand keeps its chained spelling when the other side
    // of a `/` is a special value: `1 / 2 / foo()` -> `1/2/foo()`, not the
    // collapsed quotient `0.5/foo()`.
    assert_parity("a { b: 1 / 2 / foo(); }\n");
    assert_parity("a { b: 1/2/foo(); }\n");
}

#[test]
fn progid_long_filter_syntax_is_preserved() {
    // IE `progid:Name.Name(...)` long-filter syntax (with `:`, `.`, `=`, and
    // `#hex` inside the arg list) is preserved verbatim; the `progid` keyword
    // and any vendor prefix are lower-cased while the `.Name` chain keeps its
    // case. Interpolation resolves; a backslash escapes the next character so
    // an escaped `\(`/`\)` does not affect parenthesis nesting.
    assert_parity(
        "foo { filter: progid:DXImageTransform.Microsoft.gradient(GradientType=1, startColorstr=#c0ff3300, endColorstr=#ff000000); }\n",
    );
    assert_parity("a { b: -C-PROGID:D(#{0}); }\n");
    assert_parity("a { b: progid:c(/**/ d); }\n");
    assert_parity("a { b: progid:foo.bar(x=1), progid:baz.qux(y=2); }\n");
    assert_parity("a { b: progid:c(opacity=20\\)); }\n");
}

#[test]
fn lone_percent_is_a_value_token() {
    // A `%` with no left operand is a standalone unquoted-string value (not the
    // modulo operator), so the IE/CSS `attr(c, %)` placeholder round-trips and
    // a bare `%` survives in any argument position. A whitespace-surrounded `%`
    // remains the modulo operator.
    assert_parity("a { b: %; }\n");
    assert_parity("a { b: attr(c, %); }\n");
    assert_parity("a { b: rgb(attr(c, %), 2, 3); }\n");
    assert_parity("a { b: rgb(1, 2, attr(c, %)); }\n");
    assert_parity("a { b: foo(1, %, 2); }\n");
    assert_parity("a { b: 7 % 3; }\n");
}

#[test]
fn quoted_string_line_continuation_is_removed() {
    // A backslash immediately followed by a CSS newline inside a quoted string
    // is a line continuation: both the backslash and the newline are dropped,
    // joining the two physical lines (leading whitespace on the next line is
    // preserved). Byte-matched to dart-sass.
    assert_parity("a { b: \"line1 \\\n      line2\"; }\n");
    assert_parity("a { b: \"x\\\ny\"; }\n");
    assert_parity("a { b: 'a\\\nb\\\nc'; }\n");
}

#[test]
fn parent_selector_as_value() {
    // `&` in value position resolves to the current selector: a single
    // selector, a comma list, and a nested/descendant selector. At the
    // document root `&` is `null` (interpolates to empty). A content block
    // passed to a mixin without `@content` is an error.
    assert_eq!(ours("a {\n  b: &;\n}\n"), "a {\n  b: a;\n}\n");
    assert_eq!(ours(".x, .y {\n  c: &;\n}\n"), ".x, .y {\n  c: .x, .y;\n}\n");
    assert_eq!(
        ours(".foo {\n  .bar {\n    d: &;\n  }\n}\n"),
        ".foo .bar {\n  d: .foo .bar;\n}\n"
    );
    // `&` is always a comma list, so `nth(&, 1)` is the first complex
    // selector and a descendant selector reports two space-separated items.
    assert_eq!(ours(".x, .y {\n  c: nth(&, 1);\n}\n"), ".x, .y {\n  c: .x;\n}\n");
    assert_eq!(
        ours(".a .b {\n  c: length(nth(&, 1));\n}\n"),
        ".a .b {\n  c: 2;\n}\n"
    );
    // Interpolation of the root `&` (null) yields the empty string.
    assert_eq!(ours("a {\n  c: \"#{&}!\";\n}\n"), "a {\n  c: \"a!\";\n}\n");
    // A selector that resolves to nothing (`#{&}` at the root) is rejected.
    assert!(compile("#{&} {\n  foo {\n    bar: baz;\n  }\n}\n", &Options::default()).is_err());
    // A content block for a mixin that never uses `@content` is an error.
    assert!(compile(
        "@mixin m() { x: 1; }\na { @include m { y: 2; } }\n",
        &Options::default()
    )
    .is_err());
}

#[test]
fn parent_selector_placement_strictness() {
    // `&` must begin a compound selector and a top-level `&` may not carry an
    // identifier suffix — matching dart-sass's parser rules. These run offline.
    // Non-initial `&` is always an error (parent or not).
    assert!(compile("p {\n  b& {c: d}\n}\n", &Options::default()).is_err());
    assert!(compile("p {\n  [b]& {c: d}\n}\n", &Options::default()).is_err());
    assert!(compile("p {\n  .x& {c: d}\n}\n", &Options::default()).is_err());
    assert!(compile(":not(a > b)& {c: d}\n", &Options::default()).is_err());
    // A top-level `&` with an identifier suffix is an error.
    assert!(compile("&a {b: c}\n", &Options::default()).is_err());
    assert!(compile("&-x {b: c}\n", &Options::default()).is_err());
    assert!(compile("@at-rule {\n  &b {c: d}\n}\n", &Options::default()).is_err());
    // But a suffix under a real parent is allowed (it concatenates).
    assert_eq!(ours(".x {\n  &a {c: d}\n}\n"), ".xa {\n  c: d;\n}\n");
    // And these valid placements still compile (each `&` begins a compound).
    assert!(compile("p {\n  &.foo {c: d}\n}\n", &Options::default()).is_ok());
    assert!(compile("p {\n  &:hover {c: d}\n}\n", &Options::default()).is_ok());
    assert!(compile("p {\n  & > & {c: d}\n}\n", &Options::default()).is_ok());
    assert!(compile("p {\n  &[a~=b] {c: d}\n}\n", &Options::default()).is_ok());
}

#[test]
fn placeholder_selector_must_be_named() {
    // A bare `%` (or `%` not followed by an identifier name-start char) is
    // "Expected identifier." in dart-sass. Keyframe percentage selectors
    // (`10%`, `1e2%`) are not placeholders and must still compile.
    assert!(compile("% {\n  a: b;\n}\n", &Options::default()).is_err());
    assert!(compile("%.bar {\n  a: b;\n}\n", &Options::default()).is_err());
    assert!(compile(".a % {\n  c: d;\n}\n", &Options::default()).is_err());
    assert_eq!(
        ours("@keyframes a {\n  10% {\n    c: d;\n  }\n}\n"),
        "@keyframes a {\n  10% {\n    c: d;\n  }\n}\n"
    );
    assert_eq!(
        ours("@keyframes a {\n  from, 15%, to {\n    c: d;\n  }\n}\n"),
        "@keyframes a {\n  from, 15%, to {\n    c: d;\n  }\n}\n"
    );
}

#[test]
fn attribute_selector_modifier_strictness() {
    // An attribute modifier must be a single ASCII letter directly before the
    // closing `]`. Invalid forms (no operator, too long, non-letter, trailing
    // space) error with `expected "]"`; valid forms still compile. Offline.
    assert!(compile("[a b] {c: d}\n", &Options::default()).is_err());
    assert!(compile("[a=b cd] {c: d}\n", &Options::default()).is_err());
    assert!(compile("[a=b _] {c: d}\n", &Options::default()).is_err());
    assert!(compile("[a=b 1] {c: d}\n", &Options::default()).is_err());
    assert!(compile("[a=b i ] {c: d}\n", &Options::default()).is_err());
    assert!(compile("[charset i] {c: d}\n", &Options::default()).is_err());
    // Valid attribute selectors compile, including single-letter modifiers,
    // a modifier glued to a quoted value, namespaces, and `]` inside a value.
    assert!(compile("[a] {c: d}\n", &Options::default()).is_ok());
    assert!(compile("[a=b i] {c: d}\n", &Options::default()).is_ok());
    assert!(compile("[a=b I] {c: d}\n", &Options::default()).is_ok());
    assert!(compile("[a=b c] {c: d}\n", &Options::default()).is_ok());
    assert!(compile("[a=\"b\"i] {c: d}\n", &Options::default()).is_ok());
    assert!(compile("[*|a=b i] {c: d}\n", &Options::default()).is_ok());
    assert!(compile("[a=\"]\"] {c: d}\n", &Options::default()).is_ok());
}

#[test]
fn attribute_selector_emit_normalization() {
    // Expanded-mode attribute selectors serialize canonically: whitespace
    // around the operator and at the edges is removed, a quoted value that is
    // a plain CSS identifier is unquoted, and a trailing modifier is preceded
    // by a single space — byte-matched to dart-sass.
    assert_eq!(ours("a[\n  b]\n  {c: d}\n"), "a[b] {\n  c: d;\n}\n");
    assert_eq!(ours("a[b=\n  c]\n  {d: e}\n"), "a[b=c] {\n  d: e;\n}\n");
    assert_eq!(ours("a[b\n  =c]\n  {d: e}\n"), "a[b=c] {\n  d: e;\n}\n");
    assert_eq!(ours("[a=\"b\"i] {c: d}\n"), "[a=b i] {\n  c: d;\n}\n");
    assert_eq!(ours("[a=\"b\"] {c: d}\n"), "[a=b] {\n  c: d;\n}\n");
    // Non-identifier values stay quoted; `]` inside a value is preserved.
    assert_eq!(ours("[a=\"b c\"] {d: e}\n"), "[a=\"b c\"] {\n  d: e;\n}\n");
    assert_eq!(ours("[a=\"--b\"] {d: e}\n"), "[a=\"--b\"] {\n  d: e;\n}\n");
    assert_eq!(ours("[a=\"]\"] {d: e}\n"), "[a=\"]\"] {\n  d: e;\n}\n");
}

#[test]
fn math_unit_rules_and_arity() {
    // atan2/hypot preserve their call verbatim when an operand is a `%`
    // (context-dependent) or an unknown/relative unit can't be combined; an
    // all-compatible call still folds. Byte-matched to dart-sass. Offline.
    assert_eq!(ours("a {b: atan2(1%, 2%)}\n"), "a {\n  b: atan2(1%, 2%);\n}\n");
    assert_eq!(
        ours("a {b: atan2(1px, 10%)}\n"),
        "a {\n  b: atan2(1px, 10%);\n}\n"
    );
    assert_eq!(
        ours("a {b: atan2(1foo, 2bar)}\n"),
        "a {\n  b: atan2(1foo, 2bar);\n}\n"
    );
    assert_eq!(
        ours("a {b: atan2(1foo, 2foo)}\n"),
        "a {\n  b: 26.5650511771deg;\n}\n"
    );
    assert_eq!(ours("a {b: hypot(1%, 2%)}\n"), "a {\n  b: hypot(1%, 2%);\n}\n");
    assert_eq!(
        ours("a {b: hypot(1foo, 2foo)}\n"),
        "a {\n  b: 2.2360679775foo;\n}\n"
    );
    // mod/rem fold equal unknown units but preserve a real+unknown mix.
    assert_eq!(ours("a {b: mod(1%, 2%)}\n"), "a {\n  b: 1%;\n}\n");
    assert_eq!(ours("a {b: mod(5px, 3%)}\n"), "a {\n  b: mod(5px, 3%);\n}\n");
    // Calc-style math names fold case-insensitively.
    assert_eq!(ours("a {b: SiN(1deg)}\n"), "a {\n  b: 0.0174524064;\n}\n");
    assert_eq!(ours("a {b: AbS(-2)}\n"), "a {\n  b: 2;\n}\n");
    // A known cross-dimension or unitless/real mix is an error.
    assert!(compile("a {b: atan2(1deg, 1px)}\n", &Options::default()).is_err());
    assert!(compile("a {b: atan2(1, 1px)}\n", &Options::default()).is_err());
    assert!(compile("a {b: mod(16px, 5deg)}\n", &Options::default()).is_err());
    // Too many arguments to a fixed-arity function is an error.
    assert!(compile("a {b: sin(0, 0)}\n", &Options::default()).is_err());
    assert!(compile("a {b: abs(1, 2)}\n", &Options::default()).is_err());
    assert!(compile("a {b: pow(1, 2, 3)}\n", &Options::default()).is_err());
}

#[test]
fn math_random_in_range() {
    // random() is a unitless float in [0, 1); random($limit) is an integer in
    // [1, $limit]. The draw is nondeterministic, so assert range membership
    // rather than an exact value. Offline.
    for _ in 0..200 {
        let css = ours("a {b: random()}\n");
        let v: f64 = css
            .trim()
            .trim_start_matches("a {")
            .trim()
            .trim_start_matches("b:")
            .trim()
            .trim_end_matches('}')
            .trim()
            .trim_end_matches(';')
            .trim()
            .parse()
            .expect("random() should emit a bare number");
        assert!((0.0..1.0).contains(&v), "random() out of range: {v}");

        let css = ours("a {b: random(5)}\n");
        let v: f64 = css
            .trim()
            .trim_start_matches("a {")
            .trim()
            .trim_start_matches("b:")
            .trim()
            .trim_end_matches('}')
            .trim()
            .trim_end_matches(';')
            .trim()
            .parse()
            .expect("random(5) should emit a bare integer");
        assert!((1.0..=5.0).contains(&v), "random(5) out of range: {v}");
        assert_eq!(v, v.round(), "random(5) must be an integer: {v}");
    }
    // A non-positive or non-integer limit errors.
    assert!(compile("a {b: random(0)}\n", &Options::default()).is_err());
    assert!(compile("a {b: random(-1)}\n", &Options::default()).is_err());
    assert!(compile("a {b: random(1.5)}\n", &Options::default()).is_err());
}

#[test]
fn math_min_max_clamp_unit_rules() {
    // min/max fold compatible/convertible units to the winning argument's own
    // unit, preserve mutually-incomparable clusters, and error on a known
    // cross-dimension pair. Byte-matched to dart-sass. Offline.
    assert_eq!(ours("a {b: min(1px, 1in, 1cm)}\n"), "a {\n  b: 1px;\n}\n");
    assert_eq!(ours("a {b: max(1px, 1in, 1cm)}\n"), "a {\n  b: 1in;\n}\n");
    assert_eq!(ours("a {b: min(3d, 2, 1e)}\n"), "a {\n  b: 1e;\n}\n");
    assert_eq!(ours("a {b: min(1px, 2vw)}\n"), "a {\n  b: min(1px, 2vw);\n}\n");
    assert_eq!(ours("a {b: min(1c, 2d)}\n"), "a {\n  b: min(1c, 2d);\n}\n");
    assert_eq!(ours("a {b: min(1%, 2%)}\n"), "a {\n  b: 1%;\n}\n");
    assert!(compile("a {b: min(1s, 2px)}\n", &Options::default()).is_err());
    assert!(compile("a {b: max(1px, 2px, 3s)}\n", &Options::default()).is_err());
    // clamp checks `min` first (so `clamp(3, 5, 1)` is `1`), keeps the winning
    // argument's unit, errors on a known cross-dimension pair, and preserves a
    // lone non-number argument.
    assert_eq!(ours("a {b: clamp(1px, 1in, 1cm)}\n"), "a {\n  b: 1cm;\n}\n");
    assert_eq!(ours("a {b: clamp(3, 5, 1)}\n"), "a {\n  b: 1;\n}\n");
    assert_eq!(ours("a {b: clamp(5, 1, 3)}\n"), "a {\n  b: 5;\n}\n");
    assert_eq!(
        ours("a {b: clamp(1px, 2vw, 3px)}\n"),
        "a {\n  b: clamp(1px, 2vw, 3px);\n}\n"
    );
    assert_eq!(
        ours("a {b: clamp(var(--c))}\n"),
        "a {\n  b: clamp(var(--c));\n}\n"
    );
    assert!(compile("a {b: clamp(1s, 2px, 3px)}\n", &Options::default()).is_err());
    assert!(compile("a {b: clamp(1px)}\n", &Options::default()).is_err());
}

#[test]
fn math_round_strategy_preservation() {
    // An explicit three-argument round() preserves its strategy keyword when
    // the units keep it from simplifying (round(nearest, 1px, 10%) keeps
    // `nearest`), while the implicit two-argument form does not. A strategy
    // with an unsimplifiable value but no step preserves rather than erroring.
    // Byte-matched to dart-sass. Offline.
    assert_eq!(
        ours("a {b: round(nearest, 1px, 10%)}\n"),
        "a {\n  b: round(nearest, 1px, 10%);\n}\n"
    );
    assert_eq!(
        ours("a {b: round(1px, 10%)}\n"),
        "a {\n  b: round(1px, 10%);\n}\n"
    );
    assert_eq!(
        ours("a {b: round(up, 1px, 10%)}\n"),
        "a {\n  b: round(up, 1px, 10%);\n}\n"
    );
    assert_eq!(
        ours("a {c: round(up, var(--c))}\n"),
        "a {\n  c: round(up, var(--c));\n}\n"
    );
    // A strategy with a real number but no step is still an error.
    assert!(compile("a {b: round(nearest, 5)}\n", &Options::default()).is_err());
    assert!(compile("a {b: round(up, 5)}\n", &Options::default()).is_err());
}

#[test]
fn selector_comment_stripping() {
    // dart-sass treats a loud `/* */` or silent `//` comment inside a selector
    // as whitespace: it is dropped and a separator is left, so the selector
    // normaliser collapses it. Byte-matched to dart-sass. Offline.
    assert_eq!(ours("a /**/ {b: c}\n"), "a {\n  b: c;\n}\n");
    assert_eq!(ours("a /**/ b {x: y}\n"), "a b {\n  x: y;\n}\n");
    assert_eq!(ours("a/**/b {x: y}\n"), "a b {\n  x: y;\n}\n");
    assert_eq!(ours("a /***/ b {x: y}\n"), "a b {\n  x: y;\n}\n");
    assert_eq!(ours("a //\n  {b: c}\n"), "a {\n  b: c;\n}\n");
    // A loud comment that is a standalone statement is still emitted.
    assert_eq!(
        ours("a {\n  /* keep */\n  b: c;\n}\n"),
        "a {\n  /* keep */\n  b: c;\n}\n"
    );
}

#[test]
fn interpolated_loud_comment_dedents_like_plain() {
    // dart dedents a loud comment's continuation lines at SERIALIZE time on
    // the evaluated text (`_minimumIndentation` clamped by the comment's own
    // start column, `_writeWithIndent` re-adds the output indentation), so a
    // banner built inside a mixin with `#{}` interpolation loses its source
    // indentation exactly like a plain comment does. Byte-matched offline;
    // the live case double-checks against dart-sass.
    assert_eq!(
        ours("@mixin banner($f) {\n  /*!\n   * Banner #{$f}text\n   * line two\n   */\n}\n@include banner(\"\");\n"),
        "/*!\n * Banner text\n * line two\n */\n"
    );
    assert_parity(
        "@mixin banner($f) {\n  /*!\n   * Banner #{$f}text\n   * line two\n   */\n}\n@include banner(\"\");\n.a { x: y; }\n",
    );
}

#[test]
fn declaration_property_comment_stripping() {
    // A loud or silent comment between a declaration's property name and the
    // `:` is dropped (the property template strips it as whitespace, and the
    // emitter trims). Byte-matched to dart-sass. Offline.
    assert_eq!(ours("a {b /**/ : c}\n"), "a {\n  b: c;\n}\n");
    assert_eq!(ours("a {b //\n  : c}\n"), "a {\n  b: c;\n}\n");
    assert_eq!(ours("a { color : red ; }\n"), "a {\n  color: red;\n}\n");
}

#[test]
fn at_rule_prelude_comment_stripping() {
    // `@supports` and `@-moz-document` use structured grammars: top-level
    // trivia comments are dropped, but comments inside parentheses are kept.
    assert_eq!(
        ours("@supports (a: b) /**/ {c {d: e}}\n"),
        "@supports (a: b) {\n  c {\n    d: e;\n  }\n}\n"
    );
    assert_eq!(
        ours("@supports (a: b) //\n  {c {d: e}}\n"),
        "@supports (a: b) {\n  c {\n    d: e;\n  }\n}\n"
    );
    assert_eq!(
        ours("@supports (a /**/ b) {c {d: e}}\n"),
        "@supports (a /**/ b) {\n  c {\n    d: e;\n  }\n}\n"
    );
    // Unknown directives keep a loud comment verbatim but drop a silent one.
    assert_eq!(ours("@a b /**/\n"), "@a b /**/;\n");
    assert_eq!(ours("@a b //\n"), "@a b;\n");
    assert_eq!(ours("@a /**/ b\n"), "@a b;\n");
    assert_eq!(ours("@a b /**/ {}\n"), "@a b /**/ {}\n");
    assert_eq!(ours("@a b //\n  {}\n"), "@a b {}\n");
}

#[test]
fn legacy_channels_special_slash_alpha() {
    // When the trailing `channel / alpha` slash crosses a special value
    // (var/calc/attr) or a `none`, it evaluates to an unquoted `X/Y` string
    // rather than a numeric slash. The one-argument channels form must still
    // peel off the alpha and emit dart-sass's normalized spelling. Byte-matched
    // to `npx sass`. Offline.
    // Three plain-or-special channels with a special channel or alpha → the
    // legacy comma form (the alpha becomes the fourth comma item).
    assert_eq!(
        ours("a{x: rgb(1 2 var(--f) / 0.4)}\n"),
        "a {\n  x: rgb(1, 2, var(--f), 0.4);\n}\n"
    );
    assert_eq!(
        ours("a{x: rgb(1 2 3 / var(--f))}\n"),
        "a {\n  x: rgb(1, 2, 3, var(--f));\n}\n"
    );
    assert_eq!(
        ours("a{x: hsl(1 2% 3%/var(--a))}\n"),
        "a {\n  x: hsl(1, 2%, 3%, var(--a));\n}\n"
    );
    // A wrong channel count with a special value keeps the original spelling
    // verbatim (the `/` alpha separator stays glued).
    assert_eq!(
        ours("a{x: rgb(var(--f) 2 / 0.4)}\n"),
        "a {\n  x: rgb(var(--f) 2/0.4);\n}\n"
    );
    assert_eq!(
        ours("a{x: rgb(var(--f) / 0.4)}\n"),
        "a {\n  x: rgb(var(--f)/0.4);\n}\n"
    );
    // A `none` keyword (no special function) keeps the space/slash spelling;
    // hsl gives a bare-number hue an explicit `deg`.
    assert_eq!(
        ours("a{x: rgb(0 255 127 / none)}\n"),
        "a {\n  x: rgb(0 255 127 / none);\n}\n"
    );
    assert_eq!(
        ours("a{x: rgb(0 none 127 / 0.5)}\n"),
        "a {\n  x: rgb(0 none 127 / 0.5);\n}\n"
    );
    assert_eq!(
        ours("a{x: hsl(180 none 50% / 0.5)}\n"),
        "a {\n  x: hsl(180deg none 50% / 0.5);\n}\n"
    );
    // hwb: a special function keeps the verbatim glued spelling; a `none`
    // keeps the spaced `deg`/slash spelling.
    assert_eq!(
        ours("a{x: hwb(0 30% 40% / none)}\n"),
        "a {\n  x: hwb(0deg 30% 40% / none);\n}\n"
    );
    assert_eq!(
        ours("a{x: hwb(0 30% 40% / var(--a))}\n"),
        "a {\n  x: hwb(0 30% 40%/var(--a));\n}\n"
    );
}

#[test]
fn color_function_degenerate_calc() {
    // A degenerate `calc()` (`NaN`/`infinity`/`-infinity`) in a `color()` call
    // is folded the way dart-sass folds it, and the result serializes in the
    // modern (space-around-`/`) form. An INFINITE channel is preserved; a NaN
    // channel converts to 0 (dart-sass 1.104.0); a degenerate alpha folds to a
    // number (`infinity` = opaque/omitted, `-infinity`/`NaN` = 0). Byte-matched
    // to `npx sass`. Offline.
    assert_eq!(
        ours("a{x: color(srgb 0 0 calc(infinity) / 0.5)}\n"),
        "a {\n  x: color(srgb 0 0 calc(infinity) / 0.5);\n}\n"
    );
    assert_eq!(
        ours("a{x: color(srgb 0 0 calc(NaN) / 0.5)}\n"),
        "a {\n  x: color(srgb 0 0 0 / 0.5);\n}\n"
    );
    assert_eq!(
        ours("a{x: color(srgb 0 0 0 / calc(infinity))}\n"),
        "a {\n  x: color(srgb 0 0 0);\n}\n"
    );
    assert_eq!(
        ours("a{x: color(srgb 0 0 0 / calc(-infinity))}\n"),
        "a {\n  x: color(srgb 0 0 0 / 0);\n}\n"
    );
    assert_eq!(
        ours("a{x: color(srgb 0 0 0 / calc(NaN))}\n"),
        "a {\n  x: color(srgb 0 0 0 / 0);\n}\n"
    );
    // A non-degenerate special channel/alpha keeps the original glued spelling.
    assert_eq!(
        ours("a{x: color(srgb 0 0 var(--x) / 0.5)}\n"),
        "a {\n  x: color(srgb 0 0 var(--x)/0.5);\n}\n"
    );
    // A degenerate channel with no alpha is unchanged.
    assert_eq!(
        ours("a{x: color(srgb calc(infinity) 0 0)}\n"),
        "a {\n  x: color(srgb calc(infinity) 0 0);\n}\n"
    );
}

#[test]
fn color_channels_convert_degenerate_values() {
    // dart-sass 1.104.0: "Colors now convert NaN and negative zero, as well as
    // infinity and negative infinity for polar-hue channels, to 0 as per the
    // CSS spec." So a NaN channel stops being degenerate anywhere — the call
    // parses into an ordinary color — and a hue converts every non-finite
    // value. An infinite NON-hue channel is the only one still written as a
    // `calc()`. Byte-matched to dart-sass 1.104.1. Offline.
    assert_eq!(
        ours(
            "@use \"sass:color\";\n@use \"sass:math\";\n$nan: math.div(0, 0);\n$inf: math.div(1, 0);\na {\n  \
             b: hsl($nan, 50%, 50%);\n  \
             c: hsl($inf, 50%, 50%);\n  \
             d: hsl(0, 50%, $nan);\n  \
             e: hsl(0, $inf, 50%);\n  \
             f: lab(1% calc(NaN) -3);\n  \
             g: lab(1% calc(infinity) -3);\n  \
             h: lch(1% 2 calc(infinity));\n  \
             i: oklch(50% 0.1 calc(NaN));\n  \
             j: color(srgb calc(NaN) 0 0);\n  \
             k: color(srgb calc(infinity) 0 0);\n  \
             l: hwb(calc(NaN) 10% 10%);\n\
             }\n"
        ),
        "a {\n  \
         b: hsl(0, 50%, 50%);\n  \
         c: hsl(0, 50%, 50%);\n  \
         d: hsl(0, 50%, 0%);\n  \
         e: hsl(0, calc(infinity * 1%), 50%);\n  \
         f: lab(1% 0 -3);\n  \
         g: lab(1% calc(infinity) -3);\n  \
         h: lch(1% 2 0deg);\n  \
         i: oklch(50% 0.1 0deg);\n  \
         j: color(srgb 0 0 0);\n  \
         k: color(srgb calc(infinity) 0 0);\n  \
         l: hsl(0, 80%, 50%);\n\
         }\n"
    );
    // The conversion runs wherever a color is BUILT, not just on the channels
    // a call spells out: an infinite hwb whiteness becomes NaN in the
    // whiteness + blackness normalization (`∞ / ∞`) and lands on 0, and a
    // negative infinity becomes NaN in the hwb -> hsl conversion instead.
    // `change` builds its color in the WORKING space, so a NaN hue there is
    // the 0 hue red already has.
    assert_eq!(
        ours(
            "@use \"sass:color\";\n@use \"sass:math\";\n$nan: math.div(0, 0);\na {\n  \
             b: color.hwb(0, calc(infinity * 1%), 40%, 0.5);\n  \
             c: color.hwb(0, calc(-infinity * 1%), 40%, 0.5);\n  \
             d: color.change(red, $hue: $nan);\n  \
             e: color.channel(hsl($nan, 50%, 50%), \"hue\");\n  \
             f: color.to-space(hsl($nan, 50%, 50%), oklch);\n\
             }\n"
        ),
        "a {\n  \
         b: hsla(0, 100%, 50%, 0.5);\n  \
         c: hsla(0, 0%, 0%, 0.5);\n  \
         d: red;\n  \
         e: 0deg;\n  \
         f: oklch(55.2338578785% 0.1636699547 24.2125389816deg);\n\
         }\n"
    );
}

#[test]
fn a_degenerate_channel_converts_on_every_spelling() {
    // The conversion runs on the channel VALUE, so it has to see one whatever
    // form it arrived in — a plain number, a `calc()`, or the quotient of a
    // slash-division. And it has to run on the path a SURVIVING infinity
    // takes, which serializes the values it was handed rather than a built
    // color, so the sibling channels there never write a sign back out.
    // Byte-matched to dart-sass 1.104.1. Offline.
    assert_eq!(
        ours(
            "@use \"sass:math\";\na {\n  \
             b: hsl(0/0, 50%, 50%);\n  \
             c: lch(1% 2 0/0);\n  \
             d: hsl(-0, calc(infinity), 50%);\n  \
             e: hsl(0, calc(infinity), -0);\n  \
             f: color(srgb -0 0 calc(infinity));\n  \
             g: color(srgb -0/1 0 calc(infinity));\n  \
             h: color(srgb 6/2 0 calc(infinity));\n\
             }\n"
        ),
        "a {\n  \
         b: hsl(0, 50%, 50%);\n  \
         c: lch(1% 2 0deg / 0);\n  \
         d: hsl(0, calc(infinity * 1%), 50%);\n  \
         e: hsl(0, calc(infinity * 1%), 0%);\n  \
         f: color(srgb 0 0 calc(infinity));\n  \
         g: color(srgb 0 0 calc(infinity));\n  \
         h: color(srgb 3 0 calc(infinity));\n\
         }\n"
    );
}

#[test]
fn the_legacy_adjusters_keep_the_input_space() {
    // `lighten`/`darken`, `saturate`/`desaturate`, `adjust-hue` and the
    // `opacify`/`transparentize` pair shift one hsl channel (or the alpha) and
    // hand the color back in the space it arrived in, so an `hsl()` input
    // stays an `hsl()` instead of collapsing to a hex. Only the channel the
    // function shifts is clamped — an untouched one stays bit-exact, out of
    // gamut and all — and an `rgb()`/hex/named input still ends up as a
    // computed sRGB color, named spelling included. Byte-matched to dart-sass
    // 1.104.1. Offline.
    for (call, want) in [
        ("lighten(hsl(240, 100%, 50%), 10%)", "hsl(240, 100%, 60%)"),
        ("darken(hsl(240, 100%, 50%), 10%)", "hsl(240, 100%, 40%)"),
        ("saturate(hsl(240, 50%, 50%), 10%)", "hsl(240, 60%, 50%)"),
        ("desaturate(hsl(240, 50%, 50%), 10%)", "hsl(240, 40%, 50%)"),
        ("adjust-hue(hsl(240, 100%, 50%), 30deg)", "hsl(270, 100%, 50%)"),
        (
            "opacify(hsla(240, 100%, 50%, 0.5), 0.2)",
            "hsla(240, 100%, 50%, 0.7)",
        ),
        (
            "fade-in(hsla(240, 100%, 50%, 0.5), 0.2)",
            "hsla(240, 100%, 50%, 0.7)",
        ),
        (
            "transparentize(hsl(240, 100%, 50%), 0.2)",
            "hsla(240, 100%, 50%, 0.8)",
        ),
        ("fade-out(hsl(240, 100%, 50%), 0.2)", "hsla(240, 100%, 50%, 0.8)"),
        // The shifted channel clamps; a channel left alone does not.
        ("lighten(hsl(0, 100%, 95%), 10%)", "hsl(0, 100%, 100%)"),
        ("darken(hsl(0, 100%, 5%), 10%)", "hsl(0, 100%, 0%)"),
        ("saturate(hsl(0, 95%, 50%), 10%)", "hsl(0, 100%, 50%)"),
        ("lighten(hsl(240, 150%, 50%), 10%)", "hsl(240, 150%, 60%)"),
        // An sRGB-spelled input is unchanged by all this.
        ("lighten(rgb(0, 0, 255), 10%)", "#3333ff"),
        ("lighten(blue, 10%)", "#3333ff"),
        ("adjust-hue(rgb(0, 0, 255), 30deg)", "rgb(50%, 0%, 100%)"),
        ("adjust-hue(red, 180)", "aqua"),
        ("transparentize(rgb(0, 0, 255), 0.2)", "rgba(0, 0, 255, 0.8)"),
        ("lighten(rgb(300, -20, 40), 10%)", "#ff3353"),
    ] {
        assert_eq!(
            ours(&format!("a {{ b: {call}; }}\n")),
            format!("a {{\n  b: {want};\n}}\n"),
            "{call}"
        );
    }
}

#[test]
fn a_legacy_adjuster_rebuilds_the_color_from_plain_numbers() {
    // The color is rebuilt from the hsl channels it read, so a MISSING channel
    // reads as 0 and does not survive (where `color.adjust($lightness:)` on the
    // same color keeps the `none`), a non-finite rotation lands the hue on 0
    // rather than on a NaN channel, and the trip back to an `hwb()` input's own
    // space applies the ordinary conversion rules — a result whose whiteness
    // and blackness cover everything picks up a powerless `none` hue. Every row
    // byte-matched to dart-sass 1.104.1. Offline.
    for (call, want) in [
        // The space survives; the serialization is the space's own.
        ("color.space(lighten(hsl(240, 100%, 50%), 10%))", "hsl"),
        ("color.space(lighten(hwb(240 10% 20%), 10%))", "hwb"),
        ("color.space(lighten(rgb(0, 0, 255), 10%))", "rgb"),
        ("color.space(transparentize(hwb(240 10% 20%), 0.2))", "hwb"),
        ("lighten(hwb(240 10% 20%), 10%)", "hsl(240, 77.7777777778%, 55%)"),
        (
            "transparentize(hwb(240 10% 20%), 0.2)",
            "hsla(240, 77.7777777778%, 45%, 0.8)",
        ),
        // A missing channel is filled in with 0 by the read.
        (
            "meta.inspect(lighten(hsl(240 none 50%), 10%))",
            "hsl(240, 0%, 60%)",
        ),
        (
            "meta.inspect(transparentize(hsl(none 100% 50%), 0.2))",
            "hsla(0, 100%, 50%, 0.8)",
        ),
        (
            "meta.inspect(transparentize(hwb(none 10% 20%), 0.2))",
            "hwb(0 10% 20% / 0.8)",
        ),
        // A powerless hue on the way back to hwb.
        ("meta.inspect(lighten(hwb(240 90% 0%), 50%))", "hwb(none 100% 0%)"),
        ("meta.inspect(darken(hwb(240 0% 90%), 50%))", "hwb(none 0% 100%)"),
        ("meta.inspect(saturate(hwb(240 40% 40%), 100%))", "hwb(240 0% 0%)"),
        (
            "meta.inspect(desaturate(hwb(240 40% 40%), 100%))",
            "hwb(none 50% 50%)",
        ),
        // The hwb hue rotates and normalizes in place.
        (
            "meta.inspect(adjust-hue(hwb(37.5 13% 21%), 30deg))",
            "hwb(67.5 13% 21%)",
        ),
        (
            "meta.inspect(adjust-hue(hwb(240 10% 20%), 400deg))",
            "hwb(280 10% 20%)",
        ),
        (
            "meta.inspect(adjust-hue(hsl(240, 100%, 50%), -400deg))",
            "hsl(200, 100%, 50%)",
        ),
        // A non-finite rotation lands on hue 0, in whatever space.
        (
            "meta.inspect(adjust-hue(hsl(240, 100%, 50%), $nan))",
            "hsl(0, 100%, 50%)",
        ),
        (
            "meta.inspect(adjust-hue(hsl(240, 100%, 50%), $inf))",
            "hsl(0, 100%, 50%)",
        ),
        (
            "meta.inspect(adjust-hue(hwb(240 10% 20%), $nan))",
            "hwb(0 10% 20%)",
        ),
        ("meta.inspect(adjust-hue(rgb(0, 0, 255), $nan))", "red"),
    ] {
        assert_eq!(
            ours(&format!(
                "@use \"sass:color\";\n@use \"sass:math\";\n@use \"sass:meta\";\n\
                 $nan: math.div(0, 0);\n$inf: math.div(1, 0);\na {{ b: {call}; }}\n"
            )),
            format!("a {{\n  b: {want};\n}}\n"),
            "{call}"
        );
    }
}

#[test]
fn a_missing_alpha_reads_as_zero_through_the_legacy_adjusters() {
    // The alpha is read like any other channel, so a missing one reads as 0 —
    // not as the opaque 1.0 the legacy mirror carries for serialization. The
    // channel shifters therefore hand back a fully transparent color, and the
    // alpha pair shifts away from 0: `opacify(… / none, 0.2)` lands on 0.2 and
    // `transparentize` stays at 0. Byte-matched to dart-sass 1.104.1. Offline.
    for (call, want) in [
        (
            "meta.inspect(lighten(hsl(240 100% 50% / none), 10%))",
            "hsla(240, 100%, 60%, 0)",
        ),
        (
            "meta.inspect(saturate(hsl(240 100% 50% / none), 10%))",
            "hsla(240, 100%, 50%, 0)",
        ),
        (
            "meta.inspect(adjust-hue(hsl(240 100% 50% / none), 30deg))",
            "hsla(270, 100%, 50%, 0)",
        ),
        (
            "meta.inspect(lighten(hwb(240 10% 20% / none), 10%))",
            "hwb(240 20% 10% / 0)",
        ),
        (
            "meta.inspect(lighten(rgb(0 0 255 / none), 10%))",
            "rgba(51, 51, 255, 0)",
        ),
        (
            "meta.inspect(opacify(hsl(240 100% 50% / none), 0.2))",
            "hsla(240, 100%, 50%, 0.2)",
        ),
        (
            "meta.inspect(transparentize(hsl(240 100% 50% / none), 0.2))",
            "hsla(240, 100%, 50%, 0)",
        ),
        (
            "meta.inspect(transparentize(hwb(240 10% 20% / none), 0.2))",
            "hwb(240 10% 20% / 0)",
        ),
        (
            "meta.inspect(opacify(rgb(0 0 255 / none), 0.2))",
            "rgba(0, 0, 255, 0.2)",
        ),
    ] {
        assert_eq!(
            ours(&format!(
                "@use \"sass:color\";\n@use \"sass:meta\";\na {{ b: {call}; }}\n"
            )),
            format!("a {{\n  b: {want};\n}}\n"),
            "{call}"
        );
    }
}

#[test]
fn a_missing_alpha_reads_as_zero() {
    // dart's alpha getter answers 0 for a missing alpha, like any other
    // missing channel — the opaque 1 a color carries alongside it is only the
    // default serialization falls back to. Every reader that takes the alpha
    // as a NUMBER follows: the getters, `ie-hex-str`'s leading byte, and
    // `mix`, where a transparent color contributes no color at all. Byte-
    // matched to dart-sass 1.104.1. Offline.
    for (call, want) in [
        ("color.alpha($c)", "0"),
        ("color.alpha($h)", "0"),
        ("color.alpha($r)", "0"),
        ("color.opacity($c)", "0"),
        ("alpha($c)", "0"),
        ("opacity($c)", "0"),
        ("color.channel($c, \"alpha\")", "0"),
        ("ie-hex-str($c)", "#000000FF"),
        ("ie-hex-str($h)", "#001A1ACC"),
        ("ie-hex-str($r)", "#000000FF"),
        // `mix` weighs with it on both sides, and carries it into the result.
        ("meta.inspect(mix($c, white, 50%))", "rgba(255, 255, 255, 0.5)"),
        ("meta.inspect(mix(white, $c, 50%))", "rgba(255, 255, 255, 0.5)"),
        ("meta.inspect(mix($c, $c, 50%))", "rgba(0, 0, 255, 0)"),
        (
            "meta.inspect(mix($c, rgba(white, 0.5), 50%))",
            "rgba(75%, 75%, 100%, 0.25)",
        ),
        ("meta.inspect(mix($c, white, 100%))", "rgba(0, 0, 255, 0)"),
        // Controls: a concrete alpha is unaffected, opaque included.
        ("color.alpha(hsl(240 100% 50% / 0.5))", "0.5"),
        ("color.alpha(hsl(240, 100%, 50%))", "1"),
        ("color.alpha(blue)", "1"),
        ("ie-hex-str(hsl(240 100% 50% / 0.5))", "#800000FF"),
        ("meta.inspect(mix($c, white, 0%))", "white"),
    ] {
        assert_eq!(
            ours(&format!(
                "@use \"sass:color\";\n@use \"sass:meta\";\n\
                 $c: hsl(240 100% 50% / none);\n\
                 $h: hwb(240 10% 20% / none);\n\
                 $r: rgb(0 0 255 / none);\na {{ b: {call}; }}\n"
            )),
            format!("a {{\n  b: {want};\n}}\n"),
            "{call}"
        );
    }
}

#[test]
fn change_hands_back_a_concrete_alpha() {
    // dart rebuilds a `change` result with `alpha ?? color.alpha`, and that
    // getter answers 0 — so `change` turns a missing alpha into a concrete 0
    // whatever channel it was asked for, in any space, legacy or not, and even
    // with no channel at all. `grayscale` rebuilds the same way. Only an
    // explicit `$alpha: none` keeps it missing, and `adjust`/`scale` — which
    // would have to READ the missing alpha — leave it alone. Byte-matched to
    // dart-sass 1.104.1. Offline.
    for (call, want) in [
        (
            "meta.inspect(color.change($c, $lightness: 60%))",
            "hsla(240, 100%, 60%, 0)",
        ),
        (
            "meta.inspect(color.change($c, $hue: 30deg))",
            "hsla(30, 100%, 50%, 0)",
        ),
        (
            "meta.inspect(color.change($c, $lightness: none))",
            "hsl(240deg 100% none / 0)",
        ),
        ("meta.inspect(color.change($c))", "hsla(240, 100%, 50%, 0)"),
        (
            "meta.inspect(color.change($h, $whiteness: 30%))",
            "hwb(240 30% 20% / 0)",
        ),
        (
            "meta.inspect(color.change(oklch(50% 0.1 20deg / none), $lightness: 60%))",
            "oklch(60% 0.1 20deg / 0)",
        ),
        (
            "meta.inspect(change-color($c, $lightness: 60%))",
            "hsla(240, 100%, 60%, 0)",
        ),
        (
            "meta.inspect(color.change($c, $saturation: 0%))",
            "hsla(240, 0%, 50%, 0)",
        ),
        ("meta.inspect(grayscale($c))", "hsla(240, 0%, 50%, 0)"),
        ("meta.inspect(grayscale($h))", "hwb(0 45% 55% / 0)"),
        (
            "meta.inspect(grayscale(oklch(50% 0.1 20deg / none)))",
            "oklch(50% 0 20deg / 0)",
        ),
        // `$alpha: none` is the one way to keep it missing.
        (
            "meta.inspect(color.change($c, $lightness: 60%, $alpha: none))",
            "hsl(240deg 100% 60% / none)",
        ),
        (
            "meta.inspect(color.change($c, $alpha: none))",
            "hsl(240deg 100% 50% / none)",
        ),
        (
            "meta.inspect(color.change(blue, $alpha: none))",
            "rgb(0 0 255 / none)",
        ),
        // `adjust`/`scale` never rebuild it.
        (
            "meta.inspect(color.adjust($c, $lightness: 10%))",
            "hsl(240deg 100% 60% / none)",
        ),
        (
            "meta.inspect(color.scale($c, $lightness: 10%))",
            "hsl(240deg 100% 55% / none)",
        ),
        (
            "meta.inspect(adjust-color($c, $lightness: 10%))",
            "hsl(240deg 100% 60% / none)",
        ),
        ("meta.inspect(complement($c))", "hsl(60deg 100% 50% / none)"),
    ] {
        assert_eq!(
            ours(&format!(
                "@use \"sass:color\";\n@use \"sass:meta\";\n\
                 $c: hsl(240 100% 50% / none);\n\
                 $h: hwb(240 10% 20% / none);\na {{ b: {call}; }}\n"
            )),
            format!("a {{\n  b: {want};\n}}\n"),
            "{call}"
        );
    }
}

#[test]
fn a_modify_with_no_space_channel_works_in_the_colors_own_space() {
    // When no channel keyword names a space — a channel-less or alpha-only
    // call — dart works in the color's OWN space rather than falling back to
    // rgb. Only a MISSING channel makes that visible: a round trip through rgb
    // would fill it in. (`$hue` alone still means hsl, so an hwb color's
    // missing whiteness is filled there, as dart does.) Byte-matched to
    // dart-sass 1.104.1. Offline.
    for (call, want) in [
        ("meta.inspect(color.change($s))", "hsl(240deg none 50%)"),
        (
            "meta.inspect(color.change($s, $alpha: 0.5))",
            "hsl(240deg none 50% / 0.5)",
        ),
        (
            "meta.inspect(color.change($s, $alpha: none))",
            "hsl(240deg none 50% / none)",
        ),
        ("meta.inspect(color.change($b))", "hsl(240deg none 50% / 0)"),
        (
            "meta.inspect(color.change($b, $lightness: 60%))",
            "hsl(240deg none 60% / 0)",
        ),
        ("meta.inspect(color.change($w))", "hwb(240deg none 20%)"),
        (
            "meta.inspect(color.change($w, $alpha: 0.5))",
            "hwb(240deg none 20% / 0.5)",
        ),
        ("meta.inspect(change-color($s))", "hsl(240deg none 50%)"),
        ("meta.inspect(color.adjust($s))", "hsl(240deg none 50%)"),
        ("meta.inspect(adjust-color($s))", "hsl(240deg none 50%)"),
        ("meta.inspect(color.scale($s))", "hsl(240deg none 50%)"),
        // `$hue` alone still resolves to hsl, filling an hwb whiteness.
        ("meta.inspect(color.change($w, $hue: 30deg))", "hwb(30 0% 20%)"),
        // Concrete channels round-trip losslessly, so these never moved.
        (
            "meta.inspect(color.change(hwb(240 10% 20%), $alpha: 0.5))",
            "hwb(240 10% 20% / 0.5)",
        ),
        (
            "meta.inspect(color.change(rgb(0 0 255), $alpha: 0.5))",
            "rgba(0, 0, 255, 0.5)",
        ),
        ("meta.inspect(color.change(hwb(240 10% 20%)))", "hwb(240 10% 20%)"),
        ("meta.inspect(color.change(rgb(0 0 255)))", "blue"),
    ] {
        assert_eq!(
            ours(&format!(
                "@use \"sass:color\";\n@use \"sass:meta\";\n\
                 $s: hsl(240 none 50%);\n\
                 $b: hsl(240 none 50% / none);\n\
                 $w: hwb(240 none 20%);\na {{ b: {call}; }}\n"
            )),
            format!("a {{\n  b: {want};\n}}\n"),
            "{call}"
        );
    }
}

#[test]
fn an_unknown_channel_names_the_colors_own_space() {
    // The same resolution drives the error: with no channel to name a space,
    // the one reported is the color's own. Byte-matched to dart-sass 1.104.1.
    // Offline.
    for (color, space) in [
        ("hsl(240 none 50%)", "hsl"),
        ("hwb(240 none 20%)", "hwb"),
        ("blue", "rgb"),
        ("oklch(50% 0.1 20deg)", "oklch"),
    ] {
        let msg = ours_err(&format!(
            "@use \"sass:color\";\na {{ b: color.change({color}, $foo: 1); }}\n"
        ));
        let want = format!("$foo: Color space {space} doesn't have a channel with this name.");
        assert!(msg.contains(&want), "{color}\n  want: {want}\n  got:  {msg}");
    }
}

#[test]
fn a_real_conversion_resolves_a_missing_alpha() {
    // Converting a color between spaces resolves a missing alpha to 0 —
    // whatever the destination, legacy or not, where only a LEGACY destination
    // also zero-fills the channels. A same-space conversion is the identity
    // and keeps everything missing. Every op that converts inherits this:
    // `to-space`, `complement`/`invert`/`mix` with a `$space`/`$method`, and
    // `change`/`adjust`/`scale` with a `$space` that is not the color's own.
    // Byte-matched to dart-sass 1.104.1. Offline.
    for (call, want) in [
        // to-space: converted vs identity.
        ("color.is-missing(color.to-space($o, oklab), \"alpha\")", "false"),
        ("color.is-missing(color.to-space($o, lab), \"alpha\")", "false"),
        ("color.is-missing(color.to-space($o, srgb), \"alpha\")", "false"),
        ("color.is-missing(color.to-space($o, rgb), \"alpha\")", "false"),
        ("color.is-missing(color.to-space($o, oklch), \"alpha\")", "true"),
        ("color.is-missing(color.to-space($c, hwb), \"alpha\")", "false"),
        ("color.is-missing(color.to-space($c, hsl), \"alpha\")", "true"),
        ("color.is-missing(color.to-space($l, lch), \"alpha\")", "false"),
        ("color.is-missing(color.to-space($l, lab), \"alpha\")", "true"),
        // The ops that convert on the way in or out.
        (
            "color.is-missing(complement($o, $space: hsl), \"alpha\")",
            "false",
        ),
        ("color.is-missing(complement($c), \"alpha\")", "true"),
        (
            "color.is-missing(color.mix($o, $o, $method: oklab), \"alpha\")",
            "false",
        ),
        (
            "color.is-missing(color.adjust($o, $lightness: 10%, $space: oklab), \"alpha\")",
            "false",
        ),
        (
            "color.is-missing(color.scale($o, $lightness: 10%, $space: oklab), \"alpha\")",
            "false",
        ),
        (
            "color.is-missing(color.adjust($o, $lightness: 10%), \"alpha\")",
            "true",
        ),
        // `to-gamut` is not a conversion in this sense: it hands the color
        // back in its own space and keeps the missing alpha.
        (
            "color.is-missing(color.to-gamut($o, $method: local-minde), \"alpha\")",
            "true",
        ),
        (
            "color.is-missing(color.to-gamut(oklch(50% 0.9 20deg / none), $method: local-minde), \"alpha\")",
            "true",
        ),
        // `invert` REBUILDS the color, so its alpha comes out concrete even
        // when the working space is the color's own and nothing converted.
        ("color.is-missing(invert($o, $space: oklch), \"alpha\")", "false"),
        (
            "meta.inspect(invert($o, $space: oklch))",
            "oklch(50% 0.1 200deg / 0)",
        ),
        // And an explicit `$alpha: none` only survives where nothing converts.
        (
            "meta.inspect(color.change($c, $alpha: none, $space: hsl))",
            "hsl(240deg 100% 50% / none)",
        ),
        (
            "meta.inspect(color.change($c, $alpha: none, $space: rgb))",
            "hsla(240, 100%, 50%, 0)",
        ),
        (
            "meta.inspect(color.change($c, $alpha: none, $space: hwb))",
            "hsla(240, 100%, 50%, 0)",
        ),
        (
            "meta.inspect(color.change(blue, $alpha: none, $space: hsl))",
            "rgba(0, 0, 255, 0)",
        ),
    ] {
        assert_eq!(
            ours(&format!(
                "@use \"sass:color\";\n@use \"sass:meta\";\n\
                 $o: oklch(50% 0.1 20deg / none);\n\
                 $c: hsl(240 100% 50% / none);\n\
                 $l: lab(50% 1 2 / none);\na {{ b: {call}; }}\n"
            )),
            format!("a {{\n  b: {want};\n}}\n"),
            "{call}"
        );
    }
}

#[test]
fn the_alpha_only_scale_shortcut_still_rejects_a_missing_alpha() {
    // `scale` combines its amount with the channel's current value, so a
    // missing alpha is unsupported — and the shortcut that preserves a
    // color's missing CHANNELS through an alpha-only scale must not read the
    // alpha as opaque instead of erroring. Byte-matched to dart-sass 1.104.1.
    // Offline.
    let src = |call: &str| {
        format!(
            "@use \"sass:color\";\n@use \"sass:meta\";\n\
             $b: hsl(240 none 50% / none);\n\
             $r: rgb(none none none / none);\n\
             $s: hsl(240 none 50%);\na {{ b: {call}; }}\n"
        )
    };
    for call in [
        "color.scale($b, $alpha: 10%)",
        "color.scale($b, $alpha: -10%)",
        "color.scale($r, $alpha: 10%)",
        "scale-color($b, $alpha: 10%)",
    ] {
        let msg = ours_err(&src(call));
        assert!(
            msg.contains(
                "$alpha: Because the CSS working group is still deciding on the best behavior, \
                 Sass doesn't currently support modifying missing channels"
            ),
            "{call}: {msg}"
        );
    }
    // A concrete alpha still takes the shortcut, missing channels intact.
    for (call, want) in [
        (
            "meta.inspect(color.scale($s, $alpha: -10%))",
            "hsl(240deg none 50% / 0.9)",
        ),
        (
            "meta.inspect(color.scale(rgb(none none none), $alpha: -10%))",
            "rgb(none none none / 0.9)",
        ),
        (
            "meta.inspect(scale-color($s, $alpha: -10%))",
            "hsl(240deg none 50% / 0.9)",
        ),
        ("meta.inspect(color.scale($s))", "hsl(240deg none 50%)"),
    ] {
        assert_eq!(ours(&src(call)), format!("a {{\n  b: {want};\n}}\n"), "{call}");
    }
}

#[test]
fn a_missing_argument_names_only_the_parameter() {
    // dart's message is `Missing argument $amount.` — the PARAMETER alone,
    // never the function, because the frame underneath already points at the
    // declaration it belongs to. A user-defined function always read that way
    // here; every built-in appended ` for <name>()`, and the name it appended
    // was the GLOBAL alias, so a module call reported a function the author
    // never wrote (`color.adjust()` blamed `adjust-color()`). A variadic
    // member names no parameter at all and asks for one argument instead.
    // Every message byte-matched to dart-sass 1.104.1. Offline.
    let prelude = "@use \"sass:color\";\n@use \"sass:math\";\n@use \"sass:string\";\n\
                   @use \"sass:list\";\n@use \"sass:map\";\n@use \"sass:meta\";\n\
                   @use \"sass:selector\";\n";
    for (call, want) in [
        // The module spellings, which used to name their global alias.
        ("color.adjust()", "Missing argument $color."),
        ("color.change()", "Missing argument $color."),
        ("color.scale()", "Missing argument $color."),
        ("color.mix(red)", "Missing argument $color2."),
        ("color.channel(red)", "Missing argument $channel."),
        ("math.pow(2)", "Missing argument $exponent."),
        ("math.clamp()", "Missing argument $min."),
        ("math.clamp(1)", "Missing argument $number."),
        ("math.clamp(1, 2)", "Missing argument $max."),
        ("math.atan2(1)", "Missing argument $x."),
        ("string.slice(\"abc\")", "Missing argument $start-at."),
        ("string.index(\"a\")", "Missing argument $substring."),
        ("list.nth((1 2 3))", "Missing argument $n."),
        ("list.set-nth((1 2), 1)", "Missing argument $value."),
        ("list.join()", "Missing argument $list1."),
        ("map.get((a: 1))", "Missing argument $key."),
        ("map.has-key((a: 1))", "Missing argument $key."),
        ("map.deep-merge((a: 1))", "Missing argument $map2."),
        // The global spellings say the same thing.
        ("adjust-color()", "Missing argument $color."),
        ("mix(red)", "Missing argument $color2."),
        ("str-slice(\"abc\")", "Missing argument $start-at."),
        ("nth((1 2 3))", "Missing argument $n."),
        // A variadic member has no parameter to name.
        ("math.hypot()", "At least one argument must be passed."),
        ("math.min()", "At least one argument must be passed."),
        ("math.max()", "At least one argument must be passed."),
        (
            "selector.nest()",
            "$selectors: At least one selector must be passed.",
        ),
        // These two already read the dart way and must keep doing so.
        ("meta.call()", "Missing argument $function."),
        ("meta.get-function()", "Missing argument $name."),
        // The channels functions build the message by hand, and an empty call
        // is a MISSING argument, not an arity overflow — `hwb()` used to say
        // "Only 1 argument allowed, but 0 were passed."
        ("rgb()", "Missing argument $channels."),
        ("rgba()", "Missing argument $channels."),
        ("hsl()", "Missing argument $channels."),
        ("hsla()", "Missing argument $channels."),
        ("hwb()", "Missing argument $channels."),
        ("color.hwb()", "Missing argument $channels."),
        ("lab()", "Missing argument $channels."),
        ("lch()", "Missing argument $channels."),
        ("oklab()", "Missing argument $channels."),
        ("oklch()", "Missing argument $channels."),
        ("color()", "Missing argument $description."),
        ("rgb($nope: 1)", "Missing argument $channels."),
        ("hwb($nope: 1)", "Missing argument $channels."),
        // The evaluator owns these, and they built the message by hand too.
        ("meta.function-exists()", "Missing argument $name."),
        ("meta.variable-exists()", "Missing argument $name."),
        ("meta.mixin-exists()", "Missing argument $name."),
        ("meta.global-variable-exists()", "Missing argument $name."),
        ("function-exists()", "Missing argument $name."),
        ("variable-exists()", "Missing argument $name."),
        ("mixin-exists()", "Missing argument $name."),
        ("global-variable-exists()", "Missing argument $name."),
        ("meta.module-functions()", "Missing argument $module."),
        ("meta.module-variables()", "Missing argument $module."),
        ("meta.function-exists($nope: 1)", "Missing argument $name."),
        ("meta.module-functions($nope: 1)", "Missing argument $module."),
    ] {
        let msg = ours_err(&format!("{prelude}a {{ b: {call}; }}\n"));
        assert!(msg.contains(want), "{call}\n  want: {want}\n  got:  {msg}");
        assert!(!msg.contains(" for "), "{call} still names a function: {msg}");
    }
    // An arity OVERFLOW is still an overflow: only the empty call changed.
    for (call, want) in [
        ("hwb(1, 2)", "Only 1 argument allowed, but 2 were passed."),
        (
            "hwb(240, 10%, 20%)",
            "Only 1 argument allowed, but 3 were passed.",
        ),
        ("lab(1, 2)", "Only 1 argument allowed, but 2 were passed."),
        ("color(1, 2)", "Only 1 argument allowed, but 2 were passed."),
        (
            "color.hwb(1, 2, 3, 4, 5)",
            "Only 4 arguments allowed, but 5 were passed.",
        ),
        (
            "meta.function-exists(\"a\", \"b\", \"c\")",
            "Only 2 arguments allowed, but 3 were passed.",
        ),
    ] {
        let msg = ours_err(&format!("{prelude}a {{ b: {call}; }}\n"));
        assert!(msg.contains(want), "{call}\n  want: {want}\n  got:  {msg}");
    }
    // A user-defined function, unchanged.
    let msg = ours_err("@function f($x) { @return $x; }\na { b: f(); }\n");
    assert!(msg.contains("Missing argument $x."), "{msg}");
}

#[test]
fn only_positional_arguments_count_toward_arity() {
    // dart counts POSITIONAL arguments against a function's parameter count,
    // and says so the moment a named argument is in play: `Only 2 positional
    // arguments allowed, but 3 were passed.` — three, not the four written.
    // Every built-in here summed the positional and named counts, so both
    // halves of the sentence were wrong. Each row pins the message SUBSTRING
    // (the frame around it is not part of the claim); every substring was
    // measured against dart-sass 1.104.1. Offline.
    let prelude = "@use \"sass:color\";\n@use \"sass:math\";\n@use \"sass:string\";\n\
                   @use \"sass:list\";\n@use \"sass:map\";\n@use \"sass:meta\";\n\
                   @use \"sass:selector\";\n@function f() { @return 1; }\n";
    for (call, want) in [
        // No named argument: the plain wording, unchanged.
        (
            "lighten(red, 10%, 3)",
            "Only 2 arguments allowed, but 3 were passed.",
        ),
        (
            "math.pow(1, 2, 3)",
            "Only 2 arguments allowed, but 3 were passed.",
        ),
        (
            "string.slice(\"abc\", 1, 2, 3)",
            "Only 3 arguments allowed, but 4 were passed.",
        ),
        (
            "list.nth((1 2), 1, 3)",
            "Only 2 arguments allowed, but 3 were passed.",
        ),
        (
            "selector.unify(\"a\", \"b\", \"c\")",
            "Only 2 arguments allowed, but 3 were passed.",
        ),
        (
            "meta.type-of(1, 2)",
            "Only 1 argument allowed, but 2 were passed.",
        ),
        (
            "rgb(1, 2, 3, 4, 5)",
            "Only 4 arguments allowed, but 5 were passed.",
        ),
        (
            "hwb(240, 10%, 20%)",
            "Only 1 argument allowed, but 3 were passed.",
        ),
        // With one: "positional", and only the positional ones are counted.
        (
            "lighten(red, 10%, 3, $nope: 1)",
            "Only 2 positional arguments allowed, but 3 were passed.",
        ),
        (
            "math.pow(1, 2, 3, $nope: 1)",
            "Only 2 positional arguments allowed, but 3 were passed.",
        ),
        (
            "string.slice(\"abc\", 1, 2, 3, $nope: 1)",
            "Only 3 positional arguments allowed, but 4 were passed.",
        ),
        (
            "list.nth((1 2), 1, 3, $nope: 1)",
            "Only 2 positional arguments allowed, but 3 were passed.",
        ),
        (
            "selector.unify(\"a\", \"b\", \"c\", $nope: 1)",
            "Only 2 positional arguments allowed, but 3 were passed.",
        ),
        (
            "meta.type-of(1, 2, $nope: 1)",
            "Only 1 positional argument allowed, but 2 were passed.",
        ),
        (
            "rgb(1, 2, 3, 4, 5, $nope: 1)",
            "Only 4 positional arguments allowed, but 5 were passed.",
        ),
        (
            "hwb(1, 2, $nope: 3)",
            "Only 1 positional argument allowed, but 2 were passed.",
        ),
        (
            "color.channel(red, \"red\", hsl, 4, $nope: 1)",
            "Only 3 positional arguments allowed, but 4 were passed.",
        ),
        (
            "color.mix(red, blue, 50%, hsl, 5, $nope: 1)",
            "Only 4 positional arguments allowed, but 5 were passed.",
        ),
        // The members that used to take the `named`-less shortcut.
        (
            "color.space(red, 1, $nope: 2)",
            "Only 1 positional argument allowed, but 2 were passed.",
        ),
        (
            "color.is-legacy(red, 1, $nope: 2)",
            "Only 1 positional argument allowed, but 2 were passed.",
        ),
        (
            "color.is-missing(red, \"red\", 3, $nope: 4)",
            "Only 2 positional arguments allowed, but 3 were passed.",
        ),
        (
            "color.same(red, blue, 3, $nope: 4)",
            "Only 2 positional arguments allowed, but 3 were passed.",
        ),
        (
            "color.to-gamut(red, hsl, local-minde, 4, $nope: 5)",
            "Only 3 positional arguments allowed, but 4 were passed.",
        ),
        (
            "color.red(red, 1, $nope: 2)",
            "Only 1 positional argument allowed, but 2 were passed.",
        ),
        (
            "color.green(red, 1, $nope: 2)",
            "Only 1 positional argument allowed, but 2 were passed.",
        ),
        (
            "color.whiteness(red, 1, $nope: 2)",
            "Only 1 positional argument allowed, but 2 were passed.",
        ),
        (
            "math.percentage(1, 2, $nope: 3)",
            "Only 1 positional argument allowed, but 2 were passed.",
        ),
        (
            "percentage(1, 2, $nope: 3)",
            "Only 1 positional argument allowed, but 2 were passed.",
        ),
        (
            "opacity(red, 1, $nope: 2)",
            "Only 1 positional argument allowed, but 2 were passed.",
        ),
        // The channels constructors, whose leading `n == 0` branch kept them
        // out of the first sweep.
        (
            "lab(1, 2, $nope: 3)",
            "Only 1 positional argument allowed, but 2 were passed.",
        ),
        (
            "lch(1, 2, $nope: 3)",
            "Only 1 positional argument allowed, but 2 were passed.",
        ),
        (
            "oklab(1, 2, $nope: 3)",
            "Only 1 positional argument allowed, but 2 were passed.",
        ),
        (
            "oklch(1, 2, $nope: 3)",
            "Only 1 positional argument allowed, but 2 were passed.",
        ),
        (
            "color(1, 2, $nope: 3)",
            "Only 1 positional argument allowed, but 2 were passed.",
        ),
        // …and the ones that built the message from `pos_args.len()` by hand.
        (
            "math.clamp(1, 2, 3, 4, $nope: 5)",
            "Only 3 positional arguments allowed, but 4 were passed.",
        ),
        (
            "math.round(1.5, 2, $nope: 3)",
            "Only 1 positional argument allowed, but 2 were passed.",
        ),
        (
            "meta.variable-exists(\"v\", \"m\", $nope: 1)",
            "Only 1 positional argument allowed, but 2 were passed.",
        ),
        // `get-function` is evaluator-owned and kept its own copy of the
        // check, in BOTH the builtin fallback and the evaluator path — the
        // second is the one that actually runs.
        (
            "meta.get-function(\"f\", true, \"x\", 4, $nope: 5)",
            "Only 3 positional arguments allowed, but 4 were passed.",
        ),
        (
            "get-function(\"f\", true, \"x\", 4, $nope: 5)",
            "Only 3 positional arguments allowed, but 4 were passed.",
        ),
    ] {
        let msg = ours_err(&format!("{prelude}a {{ b: {call}; }}\n"));
        assert!(msg.contains(want), "{call}\n  want: {want}\n  got:  {msg}");
    }
    // A user-defined function follows the same rule.
    for (src, want) in [
        (
            "@function f($x, $y) { @return $x; }\na { b: f(1, 2, 3, $nope: 4); }\n",
            "Only 2 positional arguments allowed, but 3 were passed.",
        ),
        (
            "@function f($x, $y) { @return $x; }\na { b: f(1, 2, 3); }\n",
            "Only 2 arguments allowed, but 3 were passed.",
        ),
        (
            "@function f($x) { @return $x; }\na { b: f(1, 2, $nope: 3); }\n",
            "Only 1 positional argument allowed, but 2 were passed.",
        ),
        // A named argument that IS a parameter still leaves the count alone.
        (
            "@function f($x, $y) { @return $x; }\na { b: f(1, 2, 3, $y: 4); }\n",
            "Only 2 positional arguments allowed, but 3 were passed.",
        ),
    ] {
        let msg = ours_err(src);
        assert!(msg.contains(want), "{src}\n  want: {want}\n  got:  {msg}");
    }
    // And a named argument alone never triggers it: `$channels` is simply
    // unbound, which is a missing argument, not an overflow.
    for (call, want) in [
        ("hwb($nope: 1)", "Missing argument $channels."),
        ("rgb()", "Missing argument $channels."),
        ("lab()", "Missing argument $channels."),
        ("lab($nope: 1)", "Missing argument $channels."),
        ("color()", "Missing argument $description."),
        ("color($nope: 1)", "Missing argument $description."),
        ("lighten($color: red, $nope: 1)", "Missing argument $amount."),
    ] {
        let msg = ours_err(&format!("{prelude}a {{ b: {call}; }}\n"));
        assert!(msg.contains(want), "{call}\n  want: {want}\n  got:  {msg}");
    }
    // `alpha()` is dart's one exception, and it comes from its OVERLOADED
    // declaration (the `$color` getter beside the variadic ms-filter form),
    // not from the rule: it reports without the "positional" wording even with
    // a named argument in play, where its twin `opacity()` — same filter
    // overload, ordinary declaration — uses it. Both spellings measured.
    for (call, want) in [
        (
            "alpha(red, 1, $nope: 2)",
            "Only 1 argument allowed, but 2 were passed.",
        ),
        ("alpha(red, 1)", "Only 1 argument allowed, but 2 were passed."),
        ("alpha(red, blue)", "Only 1 argument allowed, but 2 were passed."),
    ] {
        let msg = ours_err(&format!("{prelude}a {{ b: {call}; }}\n"));
        assert!(msg.contains(want), "{call}\n  want: {want}\n  got:  {msg}");
        assert!(
            !msg.contains("positional"),
            "{call} should not say positional: {msg}"
        );
    }
}

#[test]
fn an_attribute_value_is_decoded_and_requoted() {
    // dart does not echo an attribute value's source text: it DECODES the
    // escapes and re-serializes, dropping the quotes for an identifier and
    // otherwise picking whichever quote needs fewer escapes. Echoing the text
    // is what made `[a='b"c']` come out `[a="b"c"]` — CSS a browser reads as
    // `[a="b"` and then garbage. Byte-matched to dart-sass 1.104.1. Offline.
    for (sel, want) in [
        // Quote choice: single quotes only when the value has a `"` and no `'`.
        (r#"[a='b"c']"#, r#"[a='b"c']"#),
        (r#"[a="b\"c"]"#, r#"[a='b"c']"#),
        (r#"[a="b'c"]"#, r#"[a="b'c"]"#),
        (r#"[a='b\'c']"#, r#"[a="b'c"]"#),
        // Both quotes present: double, with the `"` escaped.
        (r#"[a='b"c\'d']"#, r#"[a="b\"c'd"]"#),
        (r#"[a="b\"c'd"]"#, r#"[a="b\"c'd"]"#),
        // An identifier loses its quotes; one leading `-` is still an
        // identifier, two are not, and a leading digit is not.
        (r#"[a="plain"]"#, "[a=plain]"),
        (r#"[a='b']"#, "[a=b]"),
        (r#"[a="with-dash"]"#, "[a=with-dash]"),
        (r#"[a="_under"]"#, "[a=_under]"),
        (r#"[a="-leading"]"#, "[a=-leading]"),
        (r#"[a="--two"]"#, r#"[a="--two"]"#),
        (r#"[a="1leading"]"#, r#"[a="1leading"]"#),
        (r#"[a=""]"#, r#"[a=""]"#),
        (r#"[a="b c"]"#, r#"[a="b c"]"#),
        // Hex escapes decode, delimiter whitespace and all.
        (r#"[a="b\22 c"]"#, r#"[a='b"c']"#),
        (r#"[a="b\27 c"]"#, r#"[a="b'c"]"#),
        (r#"[a="\61 bc"]"#, "[a=abc]"),
        (r#"[a="b\9 c"]"#, "[a=\"b\tc\"]"),
        // The operator and the modifier are untouched by any of it.
        (r#"[a^="b'c"]"#, r#"[a^="b'c"]"#),
        (r#"[a="b'c" i]"#, r#"[a="b'c" i]"#),
        (r#"[a|="b"]"#, "[a|=b]"),
    ] {
        assert_eq!(
            ours(&format!("{sel} {{ c: d }}\n")),
            format!("{want} {{\n  c: d;\n}}\n"),
            "{sel}"
        );
    }
}

#[test]
fn a_non_finite_hue_never_reaches_the_hsl_conversion() {
    // The hsl -> rgb arithmetic has no answer for a non-finite hue: it picks
    // the fallback sector and hands back a NaN component. dart-sass 1.104.0
    // converts the hue first: the ROTATED hue is the one that lands on 0, so
    // rotating by NaN sends any color to hue 0 rather than to a NaN channel —
    // `adjust-hue(blue, NaN)` is red, not blue, which is what makes this test
    // discriminating. Byte-matched to dart-sass 1.104.1. Offline.
    assert_eq!(
        ours("@use \"sass:color\";\n@use \"sass:math\";\n$nan: math.div(0, 0);\n$inf: math.div(1, 0);\na {\n  b: adjust-hue(red, $nan);\n  c: adjust-hue(red, $inf);\n  d: adjust-hue(red, math.div(-1, 0));\n  e: color.adjust(red, $hue: $nan);\n  f: adjust-hue(blue, $nan);\n  g: adjust-hue(#00ff00, $nan);\n}\n"),
        "a {\n  b: red;\n  c: red;\n  d: red;\n  e: red;\n  f: red;\n  g: red;\n}\n"
    );
}

#[test]
fn a_nan_is_within_no_range() {
    // Every `$weight`/`$amount`/`$alpha` range check rejects a NaN, as
    // dart-sass does — it is not "within" anything, and letting it through
    // produced a color of NaN channels. The BOUNDS carry the value's unit for
    // the percentage parameters (`0px and 100px`) but not for the alpha ratio
    // (`transparentize(red, 2px)` still says `0 and 1`). Every message
    // byte-matched to dart-sass 1.104.1. Offline.
    let nan = |call: &str| {
        ours_err(&format!(
            "@use \"sass:color\";\n@use \"sass:math\";\n$nan: math.div(0, 0);\na {{ b: {call}; }}\n"
        ))
    };
    assert!(
        nan("mix(red, blue, $nan)").contains("$weight: Expected calc(NaN) to be within 0 and 100."),
        "{}",
        nan("mix(red, blue, $nan)")
    );
    for f in ["lighten", "darken", "saturate", "desaturate"] {
        let msg = nan(&format!("{f}(red, $nan)"));
        assert!(
            msg.contains("$amount: Expected calc(NaN) to be within 0 and 100."),
            "{f}: {msg}"
        );
    }
    for f in ["opacify", "transparentize", "fade-in", "fade-out"] {
        let msg = nan(&format!("{f}(red, $nan)"));
        assert!(
            msg.contains("$amount: Expected calc(NaN) to be within 0 and 1."),
            "{f}: {msg}"
        );
    }
    let msg = nan("color.change(red, $alpha: $nan)");
    assert!(
        msg.contains("$alpha: Expected calc(NaN) to be within 0 and 1."),
        "{msg}"
    );
    // The bounds take the value's unit wherever the parameter is a percentage.
    let over = |call: &str| ours_err(&format!("@use \"sass:color\";\na {{ b: {call}; }}\n"));
    assert!(over("mix(red, blue, 200)").contains("Expected 200 to be within 0 and 100."));
    assert!(over("mix(red, blue, 200%)").contains("Expected 200% to be within 0% and 100%."));
    assert!(over("mix(red, blue, 200px)").contains("Expected 200px to be within 0px and 100px."));
    assert!(over("lighten(red, 200%)").contains("Expected 200% to be within 0% and 100%."));
    assert!(over("saturate(red, 200deg)").contains("Expected 200deg to be within 0deg and 100deg."));
    assert!(over("invert(red, 200%)").contains("$weight: Expected 200% to be within 0% and 100%."));
    // The alpha ratio keeps unitless bounds whatever the value carries.
    assert!(over("transparentize(red, 2px)").contains("Expected 2px to be within 0 and 1."));
    assert!(over("opacify(red, 2%)").contains("Expected 2% to be within 0 and 1."));
}

#[test]
fn every_channel_spelling_is_unit_checked() {
    // A channel's UNIT is checked whatever spelling it arrived in — a
    // degenerate `calc()` is the wrong unit as readily as a plain number, and
    // so is a slash-division — and the message shows what the caller WROTE,
    // not the zero a degenerate channel normalizes to. Every message
    // byte-matched to dart-sass 1.104.1. Offline.
    let err = |call: &str| {
        ours_err(&format!(
            "@use \"sass:color\";\n@use \"sass:math\";\na {{ b: {call}; }}\n"
        ))
    };
    for (call, want) in [
        (
            "lab(1% calc(NaN * 1px) -3)",
            "$a: Expected calc(NaN * 1px) to have unit \"%\" or no units.",
        ),
        (
            "lab(1% calc(infinity * 1px) -3)",
            "$a: Expected calc(infinity * 1px) to have unit \"%\" or no units.",
        ),
        (
            "lab(1% 6px/2 -3)",
            "$a: Expected 6px/2 to have unit \"%\" or no units.",
        ),
        (
            "oklab(calc(NaN * 1px) 0.1 0.1)",
            "$lightness: Expected calc(NaN * 1px) to have unit \"%\" or no units.",
        ),
        (
            "lch(1% 2 calc(NaN * 1px))",
            "$hue: Expected calc(NaN * 1px) to have an angle unit (deg, grad, rad, turn).",
        ),
        (
            "color(srgb calc(NaN * 1px) 0 0)",
            "$red: Expected calc(NaN * 1px) to have unit \"%\" or no units.",
        ),
        (
            "color(srgb calc(infinity * 1px) 0 0)",
            "$red: Expected calc(infinity * 1px) to have unit \"%\" or no units.",
        ),
        (
            "color(srgb 6px/2 0 0)",
            "$red: Expected 6px/2 to have unit \"%\" or no units.",
        ),
        (
            "color.hwb(0, calc(NaN * 1px), 40%)",
            "$whiteness: Expected calc(NaN * 1px) to have unit \"%\".",
        ),
    ] {
        let msg = err(call);
        assert!(msg.contains(want), "{call}\n  want: {want}\n  got:  {msg}");
    }
    // A UNITLESS degenerate constant carries no unit to check, so it still
    // parses into an ordinary color; and the legacy spaces that never had a
    // unit check on a channel still do not.
    assert_eq!(
        ours("@use \"sass:color\";\na {\n  b: lab(1% calc(NaN * 1%) -3);\n  c: hsl(0, calc(NaN * 1px), 50%);\n  d: hwb(calc(NaN * 1px) 10% 10%);\n  e: lab(1% 6/2 -3);\n}\n"),
        "a {\n  b: lab(1% 0 -3);\n  c: hsl(0, 0%, 50%);\n  d: hsl(0, 80%, 50%);\n  e: lab(1% 3 -3);\n}\n"
    );
}

#[test]
fn color_scale_names_the_channel_it_rejects() {
    // `color.scale`'s argument is the CHANNEL, so every message names it —
    // `$red`, `$alpha`, `$chroma` — rather than a generic `$amount`. And a
    // NaN percentage is within no range: it is rejected like any other
    // out-of-range value instead of scaling the channel to nothing. Every
    // message byte-matched to dart-sass 1.104.1. Offline.
    let err = |call: &str| {
        ours_err(&format!(
            "@use \"sass:color\";\n@use \"sass:math\";\na {{ b: {call}; }}\n"
        ))
    };
    for (call, want) in [
        (
            "color.scale(red, $red: math.div(0%, 0))",
            "$red: Expected calc(NaN * 1%) to be within -100% and 100%.",
        ),
        (
            "color.scale(red, $lightness: math.div(0%, 0))",
            "$lightness: Expected calc(NaN * 1%) to be within -100% and 100%.",
        ),
        (
            "color.scale(red, $alpha: math.div(0%, 0))",
            "$alpha: Expected calc(NaN * 1%) to be within -100% and 100%.",
        ),
        (
            "color.scale(rgb(none none none), $alpha: math.div(0%, 0))",
            "$alpha: Expected calc(NaN * 1%) to be within -100% and 100%.",
        ),
        (
            "color.scale(red, $green: 200%)",
            "$green: Expected 200% to be within -100% and 100%.",
        ),
        (
            "color.scale(red, $alpha: -200%)",
            "$alpha: Expected -200% to be within -100% and 100%.",
        ),
        (
            "color.scale(oklch(50% 0.1 20deg), $chroma: 200%)",
            "$chroma: Expected 200% to be within -100% and 100%.",
        ),
        (
            "color.scale(red, $red: 50)",
            "$red: Expected 50 to have unit \"%\".",
        ),
    ] {
        let msg = err(call);
        assert!(msg.contains(want), "{call}\n  want: {want}\n  got:  {msg}");
    }
}

#[test]
fn a_slash_channel_in_a_space_separated_list_is_a_number() {
    // Inside a SPACE-separated channels list a slash-division keeps its
    // spelling instead of collapsing to a number — only a TRAILING slash is
    // the alpha split. The legacy `hsl`/`hwb` reads have to see the quotient
    // it carries, its unit is checked like any other, and a non-finite one is
    // degenerate exactly as a non-finite number is. Byte-matched to dart-sass
    // 1.104.1. Offline.
    assert_eq!(
        ours("@use \"sass:color\";\n@use \"sass:meta\";\na {\n  b: hwb(0 60%/2 40%);\n  c: hsl(0 6px/2 50%);\n  d: hsl(0 1/0 50%);\n  e: hsl(0 -1/0 50%);\n  f: hsl(0 50% 1/0);\n}\n"),
        "a {\n  b: hsl(0, 33.3333333333%, 45%);\n  c: hsl(0, 3%, 50%);\n  d: hsl(0, calc(infinity * 1%), 50%);\n  e: hsl(0, 0%, 50%);\n  f: hsla(0, 50%, 1%, 0);\n}\n"
    );
    // A degenerate slash converts like a degenerate number, and the STORED
    // channel converts with it — the CSS output can hide a NaN hue behind its
    // fallback, but `color.channel` and a space conversion read the storage.
    assert_eq!(
        ours("@use \"sass:color\";\n@use \"sass:meta\";\na {\n  b: hsl(0/0 50% 50%);\n  c: color.channel(hsl(0/0 50% 50%), \"hue\");\n  d: color.channel(hsl(1/0 50% 50%), \"hue\");\n  e: meta.inspect(hwb(0/0 10% 10%));\n  f: color.to-space(hsl(0/0 50% 50%), oklch);\n}\n"),
        "a {\n  b: hsl(0, 50%, 50%);\n  c: 0deg;\n  d: 0deg;\n  e: hwb(0 10% 10%);\n  f: oklch(55.2338578785% 0.1636699547 24.2125389816deg);\n}\n"
    );
    // The unit error names the slash the caller wrote, not its quotient.
    let err = |call: &str| ours_err(&format!("@use \"sass:color\";\na {{ b: {call}; }}\n"));
    assert!(err("hwb(0 6px/2 40%)").contains("$whiteness: Expected 6px/2 to have unit \"%\"."));
    assert!(err("hwb(0 0/0 40%)").contains("$whiteness: Expected 0/0 to have unit \"%\"."));
    assert!(err("hwb(0 1/0 40%)").contains("$whiteness: Expected 1/0 to have unit \"%\"."));
}

#[test]
fn a_slash_quotient_carries_its_unit() {
    // A slash-division's quotient goes through the same unit handling as a
    // literal number: an angle converts (`1turn/2` is 180deg, not 0.5) and a
    // percentage is scaled against the channel's own base (`50%/2` is 25% of
    // 255, of 125 for lab's a/b, of 150 for lch's chroma, of 0.4 for oklab's).
    // Byte-matched to dart-sass 1.104.1. Offline.
    assert_eq!(
        ours("a {\n  b: hsl(1turn/2 50% 50%);\n  c: hsl(1turn/4 50% 50%);\n  d: hsl(200grad/2 50% 50%);\n  e: hsl(90deg/2 50% 50%);\n  f: hwb(1turn/4 10% 10%);\n}\n"),
        "a {\n  b: hsl(180, 50%, 50%);\n  c: hsl(90, 50%, 50%);\n  d: hsl(90, 50%, 50%);\n  e: hsl(45, 50%, 50%);\n  f: hsl(90, 80%, 50%);\n}\n"
    );
    assert_eq!(
        ours("a {\n  b: rgb(50%/2 0 0);\n  c: color(srgb 50%/2 0 0);\n  d: lab(50% 50%/2 0);\n  e: oklab(50% 50%/2 0);\n  f: lch(50% 50%/2 20deg);\n  g: lab(50%/2 1 2);\n}\n"),
        "a {\n  b: rgb(25%, 0%, 0%);\n  c: color(srgb 0.25 0 0);\n  d: lab(50% 31.25 0);\n  e: oklab(50% 0.1 0);\n  f: lch(50% 37.5 20deg);\n  g: lab(25% 1 2);\n}\n"
    );
}

#[test]
fn a_degenerate_slash_channel_converts_before_it_is_clamped() {
    // The degenerate check has to run before the unit-aware read, whatever
    // spelling the channel has: the legacy rgb read CLAMPS, and a clamp keeps
    // a NaN. Byte-matched to dart-sass 1.104.1. Offline.
    assert_eq!(
        ours("@use \"sass:color\";\n@use \"sass:meta\";\na {\n  b: rgb(0/0 0 0);\n  c: rgb(1/0 0 0);\n  d: rgb(-1/0 0 0);\n  e: rgba(0/0 0 0 / 0.5);\n  f: color.channel(rgb(0/0 0 0), \"red\");\n}\n"),
        "a {\n  b: rgb(0, 0, 0);\n  c: rgb(255, 0, 0);\n  d: rgb(0, 0, 0);\n  e: rgba(0, 0, 0, 0.5);\n  f: 0;\n}\n"
    );
}

#[test]
fn a_color_channel_diagnostic_names_its_space() {
    // A `color()` channel is named by the SPACE it belongs to — the xyz spaces
    // name their axes — and a non-number channel that is an unbracketed list
    // is parenthesized, as dart-sass renders it. Every message byte-matched to
    // dart-sass 1.104.1. Offline.
    let err = |call: &str| ours_err(&format!("@use \"sass:color\";\na {{ b: {call}; }}\n"));
    for (call, want) in [
        (
            "color(xyz 1px 0 0)",
            "$x: Expected 1px to have unit \"%\" or no units.",
        ),
        (
            "color(xyz 0 1px 0)",
            "$y: Expected 1px to have unit \"%\" or no units.",
        ),
        (
            "color(xyz-d50 0 0 1px)",
            "$z: Expected 1px to have unit \"%\" or no units.",
        ),
        (
            "color(xyz-d65 1px 0 0)",
            "$x: Expected 1px to have unit \"%\" or no units.",
        ),
        (
            "color(srgb 1px 0 0)",
            "$red: Expected 1px to have unit \"%\" or no units.",
        ),
        (
            "color(display-p3 0 1px 0)",
            "$green: Expected 1px to have unit \"%\" or no units.",
        ),
        (
            "color(rec2020 0 0 1px)",
            "$blue: Expected 1px to have unit \"%\" or no units.",
        ),
        (
            "color(xyz (1 2) 0 0)",
            "$description: Expected x channel to be a number, was (1 2).",
        ),
        (
            "color(srgb (1, 2) 0 0)",
            "$description: Expected red channel to be a number, was (1, 2).",
        ),
        (
            "color(srgb [1 2] 0 0)",
            "$description: Expected red channel to be a number, was [1 2].",
        ),
        (
            "rgb((1 2) 0 0)",
            "$channels: Expected red channel to be a number, was (1 2).",
        ),
        (
            "lab((1 2) 0 0)",
            "$channels: Expected lightness channel to be a number, was (1 2).",
        ),
    ] {
        let msg = err(call);
        assert!(msg.contains(want), "{call}\n  want: {want}\n  got:  {msg}");
    }
}

#[test]
fn a_positional_channel_diagnostic_names_its_parameter() {
    // The POSITIONAL (comma) color forms skip the channels-list validator, so
    // they need their own all-numeric pass to attach dart's `$<param>:`
    // prefix — `hsl` had none at all — and the value is rendered the same way
    // a channels-list diagnostic renders it: an unbracketed list in
    // parentheses, a bracketed one as written. Every message byte-matched to
    // dart-sass 1.104.1. Offline.
    let err = |call: &str| ours_err(&format!("@use \"sass:color\";\na {{ b: {call}; }}\n"));
    for (call, want) in [
        ("rgb((1 2), 0, 0)", "$red: (1 2) is not a number."),
        ("rgb(1, (1 2), 0)", "$green: (1 2) is not a number."),
        ("rgb(1, 2, (1 2))", "$blue: (1 2) is not a number."),
        ("rgb((1, 2), 0, 0)", "$red: (1, 2) is not a number."),
        ("rgb([1 2], 0, 0)", "$red: [1 2] is not a number."),
        ("rgb(c, 0, 0)", "$red: c is not a number."),
        ("rgba(1, 2, 3, (1 2))", "$alpha: (1 2) is not a number."),
        ("hsl((1 2), 0%, 0%)", "$hue: (1 2) is not a number."),
        ("hsl(0, (1 2), 0%)", "$saturation: (1 2) is not a number."),
        ("hsl(0, 0%, (1 2))", "$lightness: (1 2) is not a number."),
        ("hsl(c, 0%, 0%)", "$hue: c is not a number."),
        ("hsla(0, 0%, 0%, (1 2))", "$alpha: (1 2) is not a number."),
    ] {
        let msg = err(call);
        assert!(msg.contains(want), "{call}\n  want: {want}\n  got:  {msg}");
    }
}

#[test]
fn the_last_slash_in_a_channels_list_is_the_alpha() {
    // A chain of slashes is ONE list: dart takes its LAST element as the
    // alpha, and every earlier slash stays a DIVISION inside the final
    // channel. So `0 0 0/50%/2` is alpha `2` (clamped to opaque) with a blue
    // of `0/50%` — which is also the spelling that channel's own unit
    // diagnostic reports. Byte-matched to dart-sass 1.104.1. Offline.
    assert_eq!(
        ours("a {\n  b: hsl(0 50% 50% / 50%/2);\n  c: hsl(0 50% 50% / 2px/1);\n  d: rgb(0 0 0 / 0.25/0.75);\n  e: lab(50% 1 4 / 2 / 0.5);\n  f: lch(50% 10 180deg/2 / 0.5);\n  g: color(srgb 0 0 0 / 0.25/0.75);\n}\n"),
        "a {\n  b: hsl(0, 50%, 1%);\n  c: hsl(0, 50%, 25%);\n  d: rgba(0, 0, 0, 0.75);\n  e: lab(50% 1 2 / 0.5);\n  f: lch(50% 10 90deg / 0.5);\n  g: color(srgb 0 0 0 / 0.75);\n}\n"
    );
    // A single slash is unchanged — the last one is the only one.
    assert_eq!(
        ours("a {\n  b: rgb(0 0 0 / 50%);\n  c: color(srgb 0 0 0 / 50%);\n  d: rgb(510/2 0 0 / 0.5);\n  e: hsl(0 100%/2 50% / 0.5);\n}\n"),
        "a {\n  b: rgba(0, 0, 0, 0.5);\n  c: color(srgb 0 0 0 / 0.5);\n  d: rgba(255, 0, 0, 0.5);\n  e: hsla(0, 50%, 50%, 0.5);\n}\n"
    );
    // The divided channel is validated like the one the caller wrote out.
    let err = |call: &str| ours_err(&format!("@use \"sass:color\";\na {{ b: {call}; }}\n"));
    assert!(
        err("color(srgb 0 0 0 / 50%/2)").contains("$blue: Expected 0/50% to have unit \"%\" or no units.")
    );
    assert!(err("rgb(0 0 0 / 50%/2)").contains("$blue: Expected 0/50% to have unit \"%\" or no units."));
    assert!(err("lab(50% 1 2 / 50%/2)").contains("$b: Expected 2/50% to have unit \"%\" or no units."));
    assert!(
        err("color(srgb 0 0 0 / 2px/1)").contains("$blue: Expected 0/2px to have unit \"%\" or no units.")
    );
}

#[test]
fn an_alpha_argument_is_validated_however_it_is_written() {
    // A division in an ARGUMENT position has already evaluated to a number by
    // the time it arrives — `meta.inspect(2/1)` is `2`, not `2/1` — so the
    // slash spelling changes nothing about the range check it meets. Pulling a
    // value back out of the one construct that does carry a slash (a channels
    // list) hands over a plain number too. Byte-matched to dart-sass 1.104.1.
    // Offline.
    let err = |call: &str| {
        ours_err(&format!(
            "@use \"sass:color\";\n@use \"sass:math\";\na {{ b: {call}; }}\n"
        ))
    };
    for (call, want) in [
        (
            "color.change(red, $alpha: 2/1)",
            "$alpha: Expected 2 to be within 0 and 1.",
        ),
        (
            "color.change(red, $alpha: 4/2)",
            "$alpha: Expected 2 to be within 0 and 1.",
        ),
        (
            "color.change(red, $alpha: 0/0)",
            "$alpha: Expected calc(NaN) to be within 0 and 1.",
        ),
        (
            "color.change(red, $alpha: 1/0)",
            "$alpha: Expected calc(infinity) to be within 0 and 1.",
        ),
        (
            "color.change(red, $alpha: 200%/1)",
            "$alpha: Expected 200% to be within 0% and 100%.",
        ),
        (
            "color.change(red, $alpha: 2px/1)",
            "$alpha: Expected 2px to be within 0px and 1px.",
        ),
    ] {
        let msg = err(call);
        assert!(msg.contains(want), "{call}\n  want: {want}\n  got:  {msg}");
    }
    assert_eq!(
        ours("@use \"sass:color\";\n@use \"sass:list\";\n@use \"sass:meta\";\n$l: 0 0 0 / 2/1;\na {\n  b: meta.inspect(2/1);\n  c: meta.inspect(200%/1);\n  d: meta.inspect(list.nth($l, 3));\n  e: color.change(red, $alpha: list.nth($l, 3));\n  f: color.change(red, $alpha: 50%/2);\n}\n"),
        "a {\n  b: 2;\n  c: 200%;\n  d: 0;\n  e: rgba(255, 0, 0, 0);\n  f: rgba(255, 0, 0, 0.25);\n}\n"
    );
}

#[test]
fn a_degenerate_call_still_converts_its_other_parts() {
    // Only the NON-FINITE channel keeps its `calc(...)` spelling. dart builds
    // the color and serializes its channels, so a finite sibling is converted
    // exactly as it would be without the degenerate one — `50%` is 0.5 of a
    // `color()` space's 0..1 range — and the alpha is unit-checked even when
    // IT is the degenerate part. Byte-matched to dart-sass 1.104.1. Offline.
    assert_eq!(
        ours("a {\n  b: color(srgb 50% 0 calc(infinity));\n  c: color(srgb 50%/2 0 calc(infinity));\n  d: color(xyz 50% 0 calc(infinity));\n  e: color(display-p3 50% 0 calc(infinity));\n  f: color(srgb 0.5 0 calc(infinity));\n}\n"),
        "a {\n  b: color(srgb 0.5 0 calc(infinity));\n  c: color(srgb 0.25 0 calc(infinity));\n  d: color(xyz 0.5 0 calc(infinity));\n  e: color(display-p3 0.5 0 calc(infinity));\n  f: color(srgb 0.5 0 calc(infinity));\n}\n"
    );
    // The NON-FINITE channel's own spelling is the calculation's, not the
    // division that produced it: `1/0` is `calc(infinity)`, never `1/0`.
    assert_eq!(
        ours("@use \"sass:meta\";\na {\n  b: color(srgb 1/0 0 0);\n  c: color(srgb -1/0 0 0);\n  d: color(srgb 0/0 0 0);\n  e: color(xyz 1/0 0 0);\n  f: meta.inspect(color(srgb 1/0 0 0));\n}\n"),
        "a {\n  b: color(srgb calc(infinity) 0 0);\n  c: color(srgb calc(-infinity) 0 0);\n  d: color(srgb 0 0 0);\n  e: color(xyz calc(infinity) 0 0);\n  f: color(srgb calc(infinity) 0 0);\n}\n"
    );
    let err = |call: &str| ours_err(&format!("@use \"sass:color\";\na {{ b: {call}; }}\n"));
    for (call, want) in [
        (
            "rgb(0 0 0 / calc(infinity * 1px))",
            "$alpha: Expected calc(infinity * 1px) to have unit \"%\" or no units.",
        ),
        (
            "rgb(0 0 0 / calc(NaN * 1px))",
            "$alpha: Expected calc(NaN * 1px) to have unit \"%\" or no units.",
        ),
        (
            "color(srgb 0 0 0 / calc(infinity * 1px))",
            "$alpha: Expected calc(infinity * 1px) to have unit \"%\" or no units.",
        ),
        (
            "lab(50% 1 2 / calc(NaN * 1px))",
            "$alpha: Expected calc(NaN * 1px) to have unit \"%\" or no units.",
        ),
    ] {
        let msg = err(call);
        assert!(msg.contains(want), "{call}\n  want: {want}\n  got:  {msg}");
    }
    // A unitless or `%` degenerate alpha is fine, and an infinite non-hue
    // channel keeps its spelling whatever unit it was folded from.
    assert_eq!(
        ours("a {\n  b: rgb(0 0 0 / calc(infinity));\n  c: rgb(0 0 0 / calc(infinity * 1%));\n  d: rgb(0 0 0 / calc(NaN * 1%));\n  e: lab(1% calc(infinity * 1%) -3);\n  f: oklab(1% calc(infinity * 1%) -3);\n}\n"),
        "a {\n  b: rgb(0, 0, 0);\n  c: rgb(0, 0, 0);\n  d: rgba(0, 0, 0, 0);\n  e: lab(1% calc(infinity) -3);\n  f: oklab(1% calc(infinity) -3);\n}\n"
    );
}

#[test]
fn the_degenerate_hsl_spelling_drops_an_opaque_alpha() {
    // The preserved-`calc()` hsl spelling omits its alpha when the color is
    // opaque, exactly as the ordinary hsl path and `color()` omit theirs — an
    // alpha clamped up to 1 included. Byte-matched to dart-sass 1.104.1.
    // Offline.
    assert_eq!(
        ours("a {\n  b: hsl(0 50% calc(infinity) / 1);\n  c: hsl(0 50% calc(infinity)/2);\n  d: hsl(0 50% calc(infinity) / 100%);\n  e: hsla(0, calc(infinity), 50%, 1);\n  f: hsl(0 calc(infinity) 50% / 2);\n}\n"),
        "a {\n  b: hsl(0, 50%, calc(infinity * 1%));\n  c: hsl(0, 50%, calc(infinity * 1%));\n  d: hsl(0, 50%, calc(infinity * 1%));\n  e: hsl(0, calc(infinity * 1%), 50%);\n  f: hsl(0, calc(infinity * 1%), 50%);\n}\n"
    );
    // A TRANSPARENT one is still written, and a degenerate channel before a
    // slash alpha still splits at the last slash.
    assert_eq!(
        ours("a {\n  b: hsl(0 50% calc(infinity) / 0.5);\n  c: hsla(0, calc(infinity), 50%, 0.5);\n  d: hsl(0 50% calc(NaN)/2);\n  e: color(srgb 0 0 calc(infinity)/2);\n  f: color(srgb 0 0 calc(NaN)/0.5);\n}\n"),
        "a {\n  b: hsla(0, 50%, calc(infinity * 1%), 0.5);\n  c: hsla(0, calc(infinity * 1%), 50%, 0.5);\n  d: hsl(0, 50%, 0%);\n  e: color(srgb 0 0 calc(infinity));\n  f: color(srgb 0 0 0 / 0.5);\n}\n"
    );
}

#[test]
fn a_compound_unit_is_not_the_unit_it_starts_with() {
    // A number's unit accessor reports only the FIRST numerator, so a compound
    // unit like `%/px` reads as `%` — every channel check has to reject it
    // explicitly. And the preserved-`calc()` `color()` spelling uses the
    // canonical space name, as the ordinary path already did. Byte-matched to
    // dart-sass 1.104.1. Offline.
    assert_eq!(
        ours("a {\n  b: color(SRGB calc(infinity) 0 0);\n  c: color(Display-P3 calc(infinity) 0 0);\n  d: color(XYZ calc(infinity) 0 0);\n  e: color(SRGB 0 0 0 / calc(infinity));\n}\n"),
        "a {\n  b: color(srgb calc(infinity) 0 0);\n  c: color(display-p3 calc(infinity) 0 0);\n  d: color(xyz calc(infinity) 0 0);\n  e: color(srgb 0 0 0);\n}\n"
    );
    let err = |call: &str| ours_err(&format!("@use \"sass:color\";\na {{ b: {call}; }}\n"));
    for (call, want) in [
        (
            "hwb(0 50%/2px 10%)",
            "$whiteness: Expected 50%/2px to have unit \"%\".",
        ),
        (
            "color.hwb(0, 50%/2px, 10%)",
            "$whiteness: Expected calc(25% / 1px) to have unit \"%\".",
        ),
        (
            "lab(1% 50%/2px 0)",
            "$a: Expected 50%/2px to have unit \"%\" or no units.",
        ),
        (
            "oklab(1% 50%/2px 0)",
            "$a: Expected 50%/2px to have unit \"%\" or no units.",
        ),
        (
            "color(srgb 50%/2px 0 0)",
            "$red: Expected 50%/2px to have unit \"%\" or no units.",
        ),
        (
            "lch(1% 2 90deg/2px / 0.5)",
            "$hue: Expected 90deg/2px to have an angle unit (deg, grad, rad, turn).",
        ),
        (
            "oklch(1% 2 90deg/2px / 0.5)",
            "$hue: Expected 90deg/2px to have an angle unit (deg, grad, rad, turn).",
        ),
    ] {
        let msg = err(call);
        assert!(msg.contains(want), "{call}\n  want: {want}\n  got:  {msg}");
    }
    // A SIMPLE unit of the same name is still accepted, so the check has not
    // become "reject anything with a unit".
    assert_eq!(
        ours("a {\n  b: hwb(0 50% 10%);\n  c: lab(1% 50% 0);\n  d: color(srgb 50% 0 0);\n  e: lch(1% 2 90deg);\n}\n"),
        "a {\n  b: hsl(0, 66.6666666667%, 70%);\n  c: lab(1% 62.5 0);\n  d: color(srgb 0.5 0 0);\n  e: lch(1% 2 90deg);\n}\n"
    );
}

#[test]
fn a_bad_alpha_unit_outranks_the_channel_checks() {
    // dart validates the alpha's UNIT after the all-numeric channel pass but
    // before the channel count and before the channels' own units, so a bad
    // alpha is what gets reported when the channels are wrong too. Byte-matched
    // to dart-sass 1.104.1. Offline.
    let err = |call: &str| ours_err(&format!("@use \"sass:color\";\na {{ b: {call}; }}\n"));
    for call in [
        "rgb(0 0 / 2px)",
        "rgb(0 0 1px / 2px)",
        "hwb(0 10% 1px / 2px)",
        "hsl(0 50% 50% / 2px)",
        "rgb(0 0 0 / 2px)",
    ] {
        let msg = err(call);
        assert!(
            msg.contains("$alpha: Expected 2px to have unit \"%\" or no units."),
            "{call}\n  got: {msg}"
        );
    }
    // The all-numeric pass still comes first.
    assert!(
        err("rgb((1 2) 0 0 / 2px)").contains("$channels: Expected red channel to be a number, was (1 2).")
    );
    for (call, want) in [
        (
            "lab(1% 2 / 2px)",
            "$alpha: Expected 2px to have unit \"%\" or no units.",
        ),
        (
            "color(srgb 0 0 / 2px)",
            "$alpha: Expected 2px to have unit \"%\" or no units.",
        ),
        (
            "lab(1% 2 1px / 2px)",
            "$alpha: Expected 2px to have unit \"%\" or no units.",
        ),
        (
            "color(srgb 0 0 1px / 2px)",
            "$alpha: Expected 2px to have unit \"%\" or no units.",
        ),
        (
            "lab((1 2) 0 0 / 2px)",
            "$channels: Expected lightness channel to be a number, was (1 2).",
        ),
        (
            "color(srgb (1 2) 0 0 / 2px)",
            "$description: Expected red channel to be a number, was (1 2).",
        ),
    ] {
        let msg = err(call);
        assert!(msg.contains(want), "{call}\n  want: {want}\n  got:  {msg}");
    }
}

#[test]
fn a_non_number_channel_outranks_the_count_and_the_count_outranks_the_units() {
    // The rest of dart's order, which the lab family and `color()` had
    // inverted: a non-number channel is reported before the channel COUNT, and
    // the count before the channels' own units. A channel past the third is
    // named by its INDEX (`channel 4`), as the legacy spaces already named it.
    // Every message byte-matched to dart-sass 1.104.1. Offline.
    let err = |call: &str| ours_err(&format!("@use \"sass:color\";\na {{ b: {call}; }}\n"));
    for (call, want) in [
        (
            "lab(c 2)",
            "$channels: Expected lightness channel to be a number, was c.",
        ),
        (
            "lab(c 2 3 4)",
            "$channels: Expected lightness channel to be a number, was c.",
        ),
        (
            "lab(1% c)",
            "$channels: Expected a channel to be a number, was c.",
        ),
        (
            "lab(1% 2 c 4)",
            "$channels: Expected b channel to be a number, was c.",
        ),
        (
            "lab(1% 2 3 c)",
            "$channels: Expected channel 4 to be a number, was c.",
        ),
        (
            "lab(1% 2 3 4 c)",
            "$channels: Expected channel 5 to be a number, was c.",
        ),
        (
            "color(srgb c 0)",
            "$description: Expected red channel to be a number, was c.",
        ),
        (
            "color(srgb 1 2 3 c)",
            "$description: Expected channel 4 to be a number, was c.",
        ),
        (
            "color(srgb 1 2 3 4 c)",
            "$description: Expected channel 5 to be a number, was c.",
        ),
        (
            "color(srgb 1px 0 0 0)",
            "$description: The srgb color space has 3 channels but",
        ),
        (
            "color(srgb 1px 0)",
            "$description: The srgb color space has 3 channels but",
        ),
        (
            "lab(1px 2 3 4)",
            "$channels: The lab color space has 3 channels but",
        ),
        ("lab(1px 2)", "$channels: The lab color space has 3 channels but"),
    ] {
        let msg = err(call);
        assert!(msg.contains(want), "{call}\n  want: {want}\n  got:  {msg}");
    }
}

#[test]
fn a_scale_factor_and_a_modified_alpha_reject_a_compound_unit() {
    // The same first-numerator trap as the channel checks, in the two places
    // that read a `%` ARGUMENT: `50% * 1px` and `50%/2px` are not percentages.
    // The alpha modifier's bounds then carry the whole compound unit, as
    // dart-sass spells it. Every message byte-matched to dart-sass 1.104.1.
    // Offline.
    let err = |call: &str| {
        ours_err(&format!(
            "@use \"sass:color\";\n@use \"sass:math\";\na {{ b: {call}; }}\n"
        ))
    };
    for (call, want) in [
        (
            "color.scale(red, $red: 50% * 1px)",
            "$red: Expected calc(50% * 1px) to have unit \"%\".",
        ),
        (
            "color.scale(red, $alpha: 50% * 1px)",
            "$alpha: Expected calc(50% * 1px) to have unit \"%\".",
        ),
        (
            "color.scale(red, $red: 50%/2px)",
            "$red: Expected calc(25% / 1px) to have unit \"%\".",
        ),
        (
            "color.scale(oklch(50% 0.1 20deg), $chroma: 50% * 1px)",
            "$chroma: Expected calc(50% * 1px) to have unit \"%\".",
        ),
        (
            "scale-color(red, $red: 50% * 1px)",
            "$red: Expected calc(50% * 1px) to have unit \"%\".",
        ),
        (
            "scale-color(red, $alpha: 50% * 1px)",
            "$alpha: Expected calc(50% * 1px) to have unit \"%\".",
        ),
        (
            "color.change(red, $alpha: 50%/2px)",
            "$alpha: Expected calc(25% / 1px) to be within 0%/px and 1%/px.",
        ),
        (
            "color.change(red, $alpha: 50% * 1px)",
            "$alpha: Expected calc(50% * 1px) to be within 0%*px and 1%*px.",
        ),
    ] {
        let msg = err(call);
        assert!(msg.contains(want), "{call}\n  want: {want}\n  got:  {msg}");
    }
    // A SIMPLE `%` still scales, a simple unit still names itself in the
    // bounds, and `adjust` (which strips the unit) is untouched.
    assert_eq!(
        ours("@use \"sass:color\";\na {\n  b: color.scale(red, $green: 50%);\n  c: color.change(red, $alpha: 50%);\n  d: color.adjust(red, $alpha: 50% * 1px);\n}\n"),
        "a {\n  b: rgb(100%, 50%, 0%);\n  c: rgba(255, 0, 0, 0.5);\n  d: red;\n}\n"
    );
    assert!(err("color.change(red, $alpha: 2px)").contains("$alpha: Expected 2px to be within 0px and 1px."));
}

#[test]
fn a_range_bound_carries_the_whole_unit() {
    // The bounds of a range error spell the value's FULL unit, compound
    // included — the first numerator is not the unit. The alpha ratio still
    // keeps unitless bounds. Every message byte-matched to dart-sass 1.104.1.
    // Offline.
    let err = |call: &str| {
        ours_err(&format!(
            "@use \"sass:color\";\n@use \"sass:math\";\na {{ b: {call}; }}\n"
        ))
    };
    for (call, want) in [
        (
            "mix(red, blue, math.div(200%, 1px))",
            "$weight: Expected calc(200% / 1px) to be within 0%/px and 100%/px.",
        ),
        (
            "mix(red, blue, 200% * 1px)",
            "$weight: Expected calc(200% * 1px) to be within 0%*px and 100%*px.",
        ),
        (
            "invert(red, math.div(200%, 1px))",
            "$weight: Expected calc(200% / 1px) to be within 0%/px and 100%/px.",
        ),
        (
            "lighten(red, math.div(200%, 1px))",
            "$amount: Expected calc(200% / 1px) to be within 0%/px and 100%/px.",
        ),
        (
            "lighten(red, 200% * 1px)",
            "$amount: Expected calc(200% * 1px) to be within 0%*px and 100%*px.",
        ),
        (
            "saturate(red, math.div(200%, 1px))",
            "$amount: Expected calc(200% / 1px) to be within 0%/px and 100%/px.",
        ),
        (
            "transparentize(red, math.div(2%, 1px))",
            "$amount: Expected calc(2% / 1px) to be within 0 and 1.",
        ),
    ] {
        let msg = err(call);
        assert!(msg.contains(want), "{call}\n  want: {want}\n  got:  {msg}");
    }
    // A compound `%` is not a percentage alpha either, wherever it arrives.
    assert!(err("rgba(red, 50% * 1px)")
        .contains("$alpha: Expected calc(50% * 1px) to have unit \"%\" or no units."));
}

#[test]
fn a_none_channel_does_not_excuse_the_alpha() {
    // The `none`-channel construction returns before the caller's validation,
    // so it owes the alpha the same unit check every other path applies. And
    // the POSITIONAL all-numeric pass still outranks it. Byte-matched to
    // dart-sass 1.104.1. Offline.
    let err = |call: &str| ours_err(&format!("@use \"sass:color\";\na {{ b: {call}; }}\n"));
    for call in [
        "rgb(none none none / 2px)",
        "rgb(none 0 0 / 2px)",
        "hsl(none 50% 50% / 2px)",
        "hwb(none 10% 10% / 2px)",
        "lab(none 2 3 / 2px)",
        "color(srgb none 0 0 / 2px)",
    ] {
        let msg = err(call);
        assert!(
            msg.contains("$alpha: Expected 2px to have unit \"%\" or no units."),
            "{call}\n  got: {msg}"
        );
    }
    assert!(err("rgb((1 2), 0, 0, 2px)").contains("$red: (1 2) is not a number."));
    assert!(err("hsl((1 2), 0%, 0%, 2px)").contains("$hue: (1 2) is not a number."));
    assert!(
        err("rgb((1 2) 0 0 / 2px)").contains("$channels: Expected red channel to be a number, was (1 2).")
    );
    // A valid alpha still builds the `none` color.
    assert_eq!(
        ours("a { b: rgb(none none none / 0.5); }\n"),
        "a {\n  b: rgb(none none none / 0.5);\n}\n"
    );
}

#[test]
fn a_none_channel_exempts_itself_not_the_call() {
    // The `none`-channel construction returns before its caller's validation,
    // so it runs the same checks: a sibling's unit, a sibling that is not a
    // number, and the alpha are all still reported. And `none` is a CHANNEL
    // keyword, not an argument — the positional form rejects it outright.
    // Every message byte-matched to dart-sass 1.104.1. Offline.
    let err = |call: &str| {
        ours_err(&format!(
            "@use \"sass:color\";\n@use \"sass:math\";\na {{ b: {call}; }}\n"
        ))
    };
    for (call, want) in [
        (
            "rgb(none 1px 0)",
            "$green: Expected 1px to have unit \"%\" or no units.",
        ),
        (
            "rgb(none 1px 0 / 0.5)",
            "$green: Expected 1px to have unit \"%\" or no units.",
        ),
        (
            "rgb(none calc(NaN * 1px) 0)",
            "$green: Expected calc(NaN * 1px) to have unit \"%\" or no units.",
        ),
        (
            "rgb(none 6px/2 0)",
            "$green: Expected 6px/2 to have unit \"%\" or no units.",
        ),
        (
            "rgb(none (1 2) 0)",
            "$channels: Expected green channel to be a number, was (1 2).",
        ),
        ("rgb(none 0)", "$channels: The rgb color space has 3 channels but"),
        (
            "hwb(none 10px 20%)",
            "$whiteness: Expected 10px to have unit \"%\".",
        ),
        (
            "hwb(none 10% 20px)",
            "$blackness: Expected 20px to have unit \"%\".",
        ),
        (
            "hwb(0 10px none)",
            "$whiteness: Expected 10px to have unit \"%\".",
        ),
        (
            "hwb(none 6px/2 20%)",
            "$whiteness: Expected 6px/2 to have unit \"%\".",
        ),
        (
            "color.hwb(none, 10px, 20%)",
            "$whiteness: Expected 10px to have unit \"%\".",
        ),
        ("rgb(none, 1px, 0)", "$red: none is not a number."),
        ("rgb(none, (1 2), 0)", "$red: none is not a number."),
        ("hsl(none, 1px, 50%)", "$hue: none is not a number."),
    ] {
        let msg = err(call);
        assert!(msg.contains(want), "{call}\n  want: {want}\n  got:  {msg}");
    }
    // What a `none` channel DOES exempt is itself: the rest still computes,
    // and `hsl` has no unit check on its channels either way.
    assert_eq!(
        ours("@use \"sass:color\";\na {\n  b: rgb(none 50% 0);\n  c: hsl(none 50% 50%);\n  d: hsl(none 1px 50%);\n  e: hwb(none 10% 20%);\n  f: rgb(none calc(NaN) 0);\n}\n"),
        "a {\n  b: rgb(none 127.5 0);\n  c: hsl(none 50% 50%);\n  d: hsl(none 1% 50%);\n  e: hwb(none 10% 20%);\n  f: rgb(none 0 0);\n}\n"
    );
    // A compound `%` is not a percentage DEGENERATE alpha either.
    assert!(err("rgba(red, math.div(math.div(1, 0) * 1%, 1px))")
        .contains("$alpha: Expected calc(infinity * 1% / 1px) to have unit \"%\" or no units."));
}

#[test]
fn a_folded_calc_is_a_number_to_a_constructor_but_not_to_change() {
    // The evaluator preserves calculations inside `@supports`, so a FOLDED
    // numeric `calc()` reaches the color builtins there as a calculation. A
    // constructor reads it like the number it holds; `change`/`adjust`/`scale`
    // reject it — only a DEGENERATE calculation is a channel value for them,
    // and `change`, the one op that takes `none`, says so in the message.
    // Byte-matched to dart-sass 1.104.1. Offline.
    assert_eq!(
        ours("@use \"sass:color\";\n@supports (a: lch(1% calc(infinity) 20deg)) { x { y: 1 } }\n"),
        "@supports (a: lch(1% calc(infinity) 20deg)) {\n  x {\n    y: 1;\n  }\n}\n"
    );
    let err = |call: &str| {
        ours_err(&format!(
            "@use \"sass:color\";\n@use \"sass:math\";\n@supports (a: {call}) {{ x {{ y: 1 }} }}\n"
        ))
    };
    for (call, want) in [
        (
            "color.change(red, $red: calc(0.5))",
            "$red: calc(0.5) is not a number or unquoted \"none\".",
        ),
        (
            "color.change(red, $hue: calc(0.5))",
            "$hue: calc(0.5) is not a number or unquoted \"none\".",
        ),
        (
            "color.change(red, $alpha: calc(0.5))",
            "$alpha: calc(0.5) is not a number or unquoted \"none\".",
        ),
        (
            "color.adjust(red, $red: calc(0.5))",
            "$red: calc(0.5) is not a number.",
        ),
        (
            "color.scale(red, $red: calc(50%))",
            "$red: calc(50%) is not a number.",
        ),
    ] {
        let msg = err(call);
        assert!(msg.contains(want), "{call}\n  want: {want}\n  got:  {msg}");
    }
    // Outside `@supports` a calculation folds to a number before it arrives,
    // so only the DEGENERATE spellings are still calculations — and those are
    // channel values, accepted as they were.
    assert_eq!(
        ours("@use \"sass:color\";\na {\n  b: color.change(red, $hue: calc(NaN));\n  c: color.adjust(red, $red: calc(NaN));\n  d: color.change(red, $red: calc(0.5));\n}\n"),
        "a {\n  b: red;\n  c: black;\n  d: rgb(0.1960784314%, 0%, 0%);\n}\n"
    );
    // `change`'s "or unquoted \"none\"" is the op's, not the argument's.
    let plain = |call: &str| ours_err(&format!("@use \"sass:color\";\na {{ b: {call}; }}\n"));
    assert!(
        plain("color.change(red, $alpha: red)").contains("$alpha: red is not a number or unquoted \"none\".")
    );
    assert!(plain("color.change(red, $red: red)").contains("$red: red is not a number or unquoted \"none\"."));
    assert!(plain("color.adjust(red, $alpha: red)").contains("$alpha: red is not a number."));
    assert!(plain("color.scale(red, $alpha: red)").contains("$alpha: red is not a number."));
}

#[test]
fn a_modify_channel_is_unit_checked_however_it_is_written() {
    // A division in an ARGUMENT position has already evaluated by the time it
    // arrives — `meta.inspect(1px/1)` is `1px`, and so is the third element of
    // `0 0 1px/1` — so the slash spelling changes nothing about the unit check
    // a modify channel meets, in a supports declaration either. Byte-matched
    // to dart-sass 1.104.1. Offline.
    let err = |call: &str| {
        ours_err(&format!(
            "@use \"sass:color\";\n@use \"sass:list\";\na {{ b: {call}; }}\n"
        ))
    };
    for (call, want) in [
        (
            "color.change(red, $red: 1px/1)",
            "$red: Expected 1px to have unit \"%\" or no units.",
        ),
        (
            "color.change(red, $red: 6px/2)",
            "$red: Expected 3px to have unit \"%\" or no units.",
        ),
        (
            "color.adjust(red, $red: 1px/1)",
            "$red: Expected 1px to have unit \"%\" or no units.",
        ),
        (
            "color.change(oklch(50% 0.1 20deg), $hue: 1px/1)",
            "$hue: Expected 1px to have an angle unit (deg, grad, rad, turn).",
        ),
    ] {
        let msg = err(call);
        assert!(msg.contains(want), "{call}\n  want: {want}\n  got:  {msg}");
    }
    assert!(ours_err(
        "@use \"sass:color\";\n@use \"sass:list\";\n$l: 0 0 1px/1;\na { b: color.change(red, $red: list.nth($l, 3)); }\n"
    )
    .contains("$red: Expected 1px to have unit \"%\" or no units."));
    assert!(
        ours_err("@use \"sass:color\";\n@supports (a: color.change(red, $red: 1px/1)) { x { y: 1 } }\n")
            .contains("$red: Expected 1px to have unit \"%\" or no units.")
    );
    // And a channel whose unit the space DOES accept still computes.
    assert_eq!(
        ours("@use \"sass:color\";\na { b: color.change(red, $saturation: 1px/1); }\n"),
        "a {\n  b: rgb(50.5%, 49.5%, 49.5%);\n}\n"
    );
}

#[test]
fn a_unit_bearing_degenerate_calc_is_checked_by_the_modify_ops_too() {
    // A degenerate `calc()` that carries a unit arrives as a plain number —
    // the calculation only survives where the evaluator preserves one — so the
    // modify ops unit-check it like any other channel, the alpha's bounds
    // carrying that unit. Byte-matched to dart-sass 1.104.1. Offline.
    let err = |call: &str| ours_err(&format!("@use \"sass:color\";\na {{ b: {call}; }}\n"));
    for (call, want) in [
        (
            "color.change(red, $red: calc(infinity * 1px))",
            "$red: Expected calc(infinity * 1px) to have unit \"%\" or no units.",
        ),
        (
            "color.change(red, $red: calc(NaN * 1px))",
            "$red: Expected calc(NaN * 1px) to have unit \"%\" or no units.",
        ),
        (
            "color.adjust(red, $red: calc(NaN * 1px))",
            "$red: Expected calc(NaN * 1px) to have unit \"%\" or no units.",
        ),
        (
            "color.change(oklch(50% 0.1 20deg), $hue: calc(NaN * 1px))",
            "$hue: Expected calc(NaN * 1px) to have an angle unit (deg, grad, rad, turn).",
        ),
        (
            "color.change(red, $alpha: calc(NaN * 1px))",
            "$alpha: Expected calc(NaN * 1px) to be within 0px and 1px.",
        ),
    ] {
        let msg = err(call);
        assert!(msg.contains(want), "{call}\n  want: {want}\n  got:  {msg}");
    }
}

#[test]
fn legacy_channels_non_number_channel_error() {
    // A one-argument channels list whose first channel is a non-`from`,
    // non-number value (a quoted `"from"` or a bare keyword like `c`) reports
    // a per-channel error before the channel-count check, matching dart-sass.
    // The channel name is per-space (`red`/`hue`) for the first three and
    // `channel <N>` beyond. Offline.
    let err = |scss: &str| {
        compile(scss, &Options::default())
            .err()
            .map(|e| e.to_string())
            .unwrap_or_default()
    };
    assert!(err("a{b: rgb(\"from\" #aaa r g b)}\n")
        .contains("$channels: Expected red channel to be a number, was \"from\"."));
    assert!(
        err("a{b: rgb(c #aaa r g b)}\n").contains("$channels: Expected red channel to be a number, was c.")
    );
    assert!(
        err("a{b: hsl(c #aaa h s l)}\n").contains("$channels: Expected hue channel to be a number, was c.")
    );
    assert!(
        err("a{b: hwb(c #aaa h w b)}\n").contains("$channels: Expected hue channel to be a number, was c.")
    );
    assert!(err("a{b: rgb(1 c d)}\n").contains("$channels: Expected green channel to be a number, was c."));
    assert!(err("a{b: rgb(1 2 3 c d)}\n").contains("$channels: Expected channel 4 to be a number, was c."));
    // A `from`-relative call (even with a var() base and a slash alpha) is kept
    // verbatim, not reported as an error.
    assert_eq!(
        ours("a{x: rgb(from var(--c) r g b / 25%)}\n"),
        "a {\n  x: rgb(from var(--c) r g b/25%);\n}\n"
    );
}

#[test]
fn non_finite_number_serializes_as_calc() {
    // A bare non-finite number value serializes like dart-sass: a unitless
    // infinity/-infinity/NaN prints as `calc(infinity)`/`calc(-infinity)`/
    // `calc(NaN)`, and a unit-bearing one as `calc(infinity * 1px)`.
    // `1e400` overflows the f64 literal to +Infinity, `-1e400` to -Infinity.
    assert_eq!(ours("a {b: 1e400}\n"), "a {\n  b: calc(infinity);\n}\n");
    assert_eq!(ours("a {b: -1e400}\n"), "a {\n  b: calc(-infinity);\n}\n");
    // Unit-bearing non-finite values keep their unit as a `* 1<unit>` operand.
    assert_eq!(
        ours("a {b: (1px / 0) * 1}\n"),
        "a {\n  b: calc(infinity * 1px);\n}\n"
    );
    assert_eq!(ours("a {b: (0px / 0) * 1}\n"), "a {\n  b: calc(NaN * 1px);\n}\n");
    // Interpolation produces the same calc form (no longer a bare `Infinity`).
    assert_eq!(ours("a {b: #{1e400}}\n"), "a {\n  b: calc(infinity);\n}\n");
}

#[test]
fn list_is_bracketed_and_zip() {
    // `is-bracketed` reports the bracket flag; a bare value, an empty list,
    // and a plain space/comma list are all `false`.
    assert_eq!(ours("a {b: is-bracketed([a b c])}\n"), "a {\n  b: true;\n}\n");
    assert_eq!(ours("a {b: is-bracketed(a b c)}\n"), "a {\n  b: false;\n}\n");
    assert_eq!(ours("a {b: is-bracketed(())}\n"), "a {\n  b: false;\n}\n");
    // `zip` interleaves corresponding elements into a comma list of space
    // lists, truncating to the shortest input.
    assert_eq!(
        ours("a {b: zip(1px 2px, solid dashed, red blue)}\n"),
        "a {\n  b: 1px solid red, 2px dashed blue;\n}\n"
    );
    assert_eq!(ours("a {b: zip(1 2 3, c d)}\n"), "a {\n  b: 1 c, 2 d;\n}\n");
    // A single list zips each element into its own one-element row.
    assert_eq!(ours("a {b: zip(a b c)}\n"), "a {\n  b: a, b, c;\n}\n");
}

#[test]
fn meta_feature_exists_known_set() {
    // `feature-exists` is `true` for dart-sass's fixed feature set (quoted or
    // unquoted), and `false` for any other name.
    assert_eq!(ours("a {b: feature-exists(at-error)}\n"), "a {\n  b: true;\n}\n");
    assert_eq!(
        ours("a {b: feature-exists(global-variable-shadowing)}\n"),
        "a {\n  b: true;\n}\n"
    );
    assert_eq!(
        ours("a {b: feature-exists(\"custom-property\")}\n"),
        "a {\n  b: true;\n}\n"
    );
    assert_eq!(
        ours("a {b: feature-exists(units-level-3)}\n"),
        "a {\n  b: true;\n}\n"
    );
    assert_eq!(
        ours("a {b: feature-exists(extend-selector-pseudoclass)}\n"),
        "a {\n  b: true;\n}\n"
    );
    assert_eq!(ours("a {b: feature-exists(nope)}\n"), "a {\n  b: false;\n}\n");
}

#[test]
fn equality_is_unit_and_format_aware() {
    // Numbers compare across convertible units (`1in == 96px`), but unitless
    // vs unit-bearing and incompatible units stay unequal. Units are
    // case-sensitive in `==` (`1PX != 1px`).
    assert_eq!(ours("a {b: 1in == 96px}\n"), "a {\n  b: true;\n}\n");
    assert_eq!(ours("a {b: 1cm == 10mm}\n"), "a {\n  b: true;\n}\n");
    assert_eq!(ours("a {b: 100grad == 90deg}\n"), "a {\n  b: true;\n}\n");
    assert_eq!(ours("a {b: 1s == 1000ms}\n"), "a {\n  b: true;\n}\n");
    assert_eq!(ours("a {b: 1 == 1px}\n"), "a {\n  b: false;\n}\n");
    assert_eq!(ours("a {b: 1px == 1em}\n"), "a {\n  b: false;\n}\n");
    assert_eq!(ours("a {b: 1PX == 1px}\n"), "a {\n  b: false;\n}\n");
    // Colors compare resolved channels fuzzily: a named color equals an HSL
    // color that resolves to the same sRGB channels within epsilon.
    assert_eq!(
        ours("a {b: purple == hsl(300, 100%, 25.098039215686%)}\n"),
        "a {\n  b: true;\n}\n"
    );
    // Genuinely different colors stay unequal.
    assert_eq!(ours("a {b: red == hsl(0, 0%, 50%)}\n"), "a {\n  b: false;\n}\n");
}

/// Phase-1a parity proof (offline). The `@extend` engine keys its ~28 maps/sets
/// by `render()` strings; Phase 1c/1d migrate those to typed `Complex`/`Simple`
/// keys, which is behaviour-preserving iff `render()` is INJECTIVE over the
/// typed model — no two structurally-distinct selectors share a render string
/// (the converse is free: `render()` is pure and a derived `Hash` agrees with
/// `Eq`). `selector.rs::assert_render_injective` guards this at the engine's key
/// sites in debug builds; compiling a broad spread of `@extend` inputs here
/// (`:is`/`:not`/`:has` args, attributes, pseudo-elements, combinators,
/// namespaces, placeholders, universal, `nth-of`) fires the guard on any
/// violation. The full sass-spec suite was also run guard-active with zero
/// violations, byte-identical output.
#[test]
fn selector_render_injective() {
    for scss in [
        ".a {c: d}\n:is(.x, .y) .z[w=v i] {@extend .a}\n",
        ".a {c: d}\n* > .b ~ .c:not(.d):has(> .e) {@extend .a}\n",
        ".a {c: d}\nns|el::before, *|*:hover {@extend .a}\n",
        "%p {c: d}\n.q:nth-child(2n + 1 of .r) {@extend %p}\n",
        ".a.b {c: d}\n.x {@extend .a}\n.y {@extend .b}\n",
        "#id:not(:is(.a, [b])) {c: d}\n.z {@extend #id}\n",
    ] {
        // In a debug build the render-injectivity guard panics on any violation.
        let _ = ours(scss);
    }
}

#[test]
fn extend_basic_and_placeholders() {
    // A class extend adds the extender as an alternative selector.
    assert_eq!(
        ours(".foo {a: b}\n.bar {@extend .foo}\n"),
        ".foo, .bar {\n  a: b;\n}\n"
    );
    // A placeholder rule emits nothing on its own, but its body surfaces under
    // the extending selector(s).
    assert_eq!(ours("%p {color: red}\n"), "");
    assert_eq!(
        ours("%p {color: red}\n.a {@extend %p}\n"),
        ".a {\n  color: red;\n}\n"
    );
    // Nested target: the extender replaces the matched compound in place.
    assert_eq!(
        ours(".foo .bar {a: b}\n.baz {@extend .bar}\n"),
        ".foo .bar, .foo .baz {\n  a: b;\n}\n"
    );
    // Compound unification across two extends, with the within-compound product.
    assert_eq!(
        ours(".foo.bar {a: b}\n.baz {@extend .foo}\n.bang {@extend .bar}\n"),
        ".foo.bar, .foo.bang, .bar.baz, .baz.bang {\n  a: b;\n}\n"
    );
    // !optional suppresses the "target not found" error.
    assert_eq!(
        ours(".a {x: y; @extend .missing !optional}\n"),
        ".a {\n  x: y;\n}\n"
    );
}

#[test]
fn extend_trim_and_chain_order() {
    // Redundant subselectors are trimmed: `.baz` supersedes `.foo.baz` etc.
    assert_eq!(
        ours(".foo.bar {a: b}\n.baz {@extend .foo; @extend .bar}\n"),
        ".foo.bar, .baz {\n  a: b;\n}\n"
    );
    // The universal selector supersedes the bare class, so only `-a *` remains.
    assert_eq!(
        ours("%-a .foo {a: b}\n* {@extend .foo} -a {@extend %-a}\n"),
        "-a * {\n  a: b;\n}\n"
    );
    // Chained extends keep dart-sass's reverse-registration ordering of
    // same-target extenders.
    assert_eq!(
        ours(".foo {a: b}\n.bar {@extend .foo}\n.baz {@extend .bar}\n.bip {@extend .bar}\n"),
        ".foo, .bar, .bip, .baz {\n  a: b;\n}\n"
    );
    // Two direct extenders of the same target also come out reversed.
    assert_eq!(
        ours(".foo {a: b}\n.bar {@extend .foo}\n.baz {@extend .foo}\n"),
        ".foo, .baz, .bar {\n  a: b;\n}\n"
    );
}

#[test]
fn extend_weaves_multi_component_extenders() {
    // A multi-component extender interweaves its parents with the matched
    // selector's parents in all order-preserving ways (dart-sass `weave`).
    assert_eq!(
        ours(".baz .bip .foo {a: b}\nfoo .grank bar {@extend .foo}\n"),
        ".baz .bip .foo, .baz .bip foo .grank bar, foo .grank .baz .bip bar {\n  a: b;\n}\n"
    );
    // Identical parent prefixes unify to a single woven selector.
    assert_eq!(
        ours(".baz .bip .foo {a: b}\n.baz .bip bar {@extend .foo}\n"),
        ".baz .bip .foo, .baz .bip bar {\n  a: b;\n}\n"
    );
}

#[test]
fn extend_universal_and_element_unification() {
    // `*|*` unified into a compound with a class drops the universal entirely.
    assert_eq!(
        ours("%-a .foo.bar {a: b}\n*|* {@extend .foo} -a {@extend %-a}\n"),
        "-a .bar {\n  a: b;\n}\n"
    );
    // A namespaced universal target keeps its namespace where it can't unify away.
    assert_eq!(
        ours("%-a ns|*.foo {a: b}\n* {@extend .foo} -a {@extend %-a}\n"),
        "-a ns|*.foo {\n  a: b;\n}\n"
    );
    // A namespaced type extender unifies with `*` to the concrete element.
    assert_eq!(
        ours("%-a *.foo {a: b}\n*|a {@extend .foo} -a {@extend %-a}\n"),
        "-a *.foo, -a a {\n  a: b;\n}\n"
    );
}

#[test]
fn extend_pseudo_class_and_element_ordering() {
    // A unified pseudo-class keeps its order after an existing pseudo-class.
    assert_eq!(
        ours("%-a :foo.baz {a: b}\n:bar {@extend .baz} -a {@extend %-a}\n"),
        "-a :foo.baz, -a :foo:bar {\n  a: b;\n}\n"
    );
    // Pseudo-classes always sort before a pseudo-element in the result.
    assert_eq!(
        ours(".foo:bar {a: b}\n.baz::bang {@extend .foo}\n"),
        ".foo:bar, .baz:bar::bang {\n  a: b;\n}\n"
    );
    // `:not()` unifies as an ordinary pseudo-class.
    assert_eq!(
        ours("%-a :not(.foo).baz {a: b}\n:not(.bar) {@extend .baz} -a {@extend %-a}\n"),
        "-a :not(.foo).baz, -a :not(.foo):not(.bar) {\n  a: b;\n}\n"
    );
}

#[test]
fn extend_across_media_is_an_error() {
    // An `@extend` inside `@media` may not extend a selector defined at the
    // document root.
    assert!(compile(
        ".foo { a: b }\n@media print { .bar { @extend .foo } }\n",
        &Options::default()
    )
    .is_err());
    // Both target and extender inside the same media context is fine.
    assert_eq!(
        ours("@media print { .a { x: y } .b { @extend .a } }\n"),
        "@media print {\n  .a, .b {\n    x: y;\n  }\n}\n"
    );
    // A bare `@extend` directly inside `@at-root` (no enclosing rule) errors.
    assert!(compile(
        ".a { x: y }\n.b { @at-root (with: media) { @extend .a } }\n",
        &Options::default()
    )
    .is_err());
}

#[test]
fn placeholder_inside_pseudo_arguments() {
    // A nonexistent `%placeholder` is removed from `:is()`/`:not()` arguments.
    assert_eq!(ours("a:not(%b) {x: y}\n"), "a {\n  x: y;\n}\n");
    assert_eq!(ours(":not(%b) {x: y}\n"), "* {\n  x: y;\n}\n");
    assert_eq!(ours("a:is(%b, c) {x: y}\n"), "a:is(c) {\n  x: y;\n}\n");
    assert_eq!(ours("a:not(%b, c) {x: y}\n"), "a:not(c) {\n  x: y;\n}\n");
    // A solo `%placeholder` in a matches-any pseudo removes the whole rule.
    assert_eq!(ours("a:is(%b) {x: y}\n"), "");
}

#[test]
fn unquoted_value_escapes_are_canonicalized() {
    // A CSS escape in an unquoted value decodes to its code point and then
    // re-serializes per dart-sass's identifier rules: printable name chars
    // become literal, control chars use the `\<hex> ` form, and other
    // punctuation is backslash-escaped.
    assert_eq!(ours("a {b: \\41}\n"), "a {\n  b: A;\n}\n");
    assert_eq!(ours("a {b: \\41 BC}\n"), "a {\n  b: ABC;\n}\n");
    assert_eq!(ours("a {b: \\9}\n"), "a {\n  b: \\9 ;\n}\n");
    assert_eq!(ours("a {b: \\0}\n"), "a {\n  b: \\0 ;\n}\n");
    // A leading digit (or one right after a leading hyphen) is hex-escaped;
    // the same digit mid-identifier stays literal.
    assert_eq!(ours("a {b: \\30 x}\n"), "a {\n  b: \\30 x;\n}\n");
    assert_eq!(ours("a {b: q\\30 x}\n"), "a {\n  b: q0x;\n}\n");
    assert_eq!(ours("a {b: -\\30 x}\n"), "a {\n  b: -\\30 x;\n}\n");
    // A `-` produced by an escape at identifier start is backslash-escaped,
    // but a literal leading `-` stays bare.
    assert_eq!(ours("a {b: \\2d a}\n"), "a {\n  b: \\-a;\n}\n");
    assert_eq!(ours("a {b: \\2d\\2d}\n"), "a {\n  b: \\--;\n}\n");
    assert_eq!(ours("a {b: -\\2d}\n"), "a {\n  b: -\\-;\n}\n");
    assert_eq!(ours("a {b: a\\2d}\n"), "a {\n  b: a-;\n}\n");
    // Printable punctuation gets a literal backslash; a literal backslash
    // round-trips.
    assert_eq!(ours("a {b: \\21}\n"), "a {\n  b: \\!;\n}\n");
    assert_eq!(ours("a {b: \\7f}\n"), "a {\n  b: \\7f ;\n}\n");
    assert_eq!(ours("a {b: \\\\}\n"), "a {\n  b: \\\\;\n}\n");
}

#[test]
fn quoted_string_escapes_are_normalized() {
    // Quoted strings decode escapes to code points and re-serialize per
    // dart-sass: printable chars pass through, `\#{` becomes a literal `#{`,
    // and only the quote char, backslash, and control chars are re-escaped.
    assert_eq!(ours("a {b: \"\\41\"}\n"), "a {\n  b: \"A\";\n}\n");
    assert_eq!(ours("a {b: \"x\\#{y}\"}\n"), "a {\n  b: \"x#{y}\";\n}\n");
    assert_eq!(ours("a {b: \"\\#{y}\"}\n"), "a {\n  b: \"#{y}\";\n}\n");
    // Tab (0x09) stays literal inside quotes; DEL is hex-escaped.
    assert_eq!(ours("a {b: \"\\9\"}\n"), "a {\n  b: \"\t\";\n}\n");
    assert_eq!(ours("a {b: \"\\7f\"}\n"), "a {\n  b: \"\\7f\";\n}\n");
    // A control escape gets a trailing space only when the next char would
    // extend the escape (a hex digit).
    assert_eq!(ours("a {b: \"\\1 0\"}\n"), "a {\n  b: \"\\1 0\";\n}\n");
    assert_eq!(ours("a {b: \"\\1 a\"}\n"), "a {\n  b: \"\\1 a\";\n}\n");
    // A string containing `\"` but no `'` is rewrapped in single quotes; one
    // containing both keeps double quotes and escapes the inner `"`.
    assert_eq!(ours("a {b: \"a\\\"b\"}\n"), "a {\n  b: 'a\"b';\n}\n");
    assert_eq!(ours("a {b: \"a'b\\\"c\"}\n"), "a {\n  b: \"a'b\\\"c\";\n}\n");
    // A literal backslash round-trips as `\\`.
    assert_eq!(ours("a {b: \"\\\\\"}\n"), "a {\n  b: \"\\\\\";\n}\n");
}

#[test]
fn unquoted_url_contents_escapes_are_canonicalized() {
    // CSS escapes inside plain (unquoted) `url(...)` contents decode and
    // re-serialize with the identifier body rules: name chars (including a
    // leading digit or `-`) stay literal, control chars use `\<hex> `, and
    // other punctuation is backslash-escaped. `\#{` stays a literal `#{`.
    assert_eq!(ours("a {b: url(\\41)}\n"), "a {\n  b: url(A);\n}\n");
    assert_eq!(ours("a {b: url(\\41 bc)}\n"), "a {\n  b: url(Abc);\n}\n");
    assert_eq!(ours("a {b: url(\\30)}\n"), "a {\n  b: url(0);\n}\n");
    assert_eq!(ours("a {b: url(\\2d)}\n"), "a {\n  b: url(-);\n}\n");
    assert_eq!(ours("a {b: url(\\9)}\n"), "a {\n  b: url(\\9 );\n}\n");
    assert_eq!(ours("a {b: url(\\7f)}\n"), "a {\n  b: url(\\7f );\n}\n");
    assert_eq!(ours("a {b: url(\\21)}\n"), "a {\n  b: url(\\!);\n}\n");
    assert_eq!(ours("a {b: url(\\))}\n"), "a {\n  b: url(\\));\n}\n");
    assert_eq!(ours("a {b: url(\\#{})}\n"), "a {\n  b: url(\\#{});\n}\n");
}

#[test]
fn non_ascii_output_declares_utf8_charset() {
    use sasso::OutputStyle;
    // Non-ASCII output (here produced by a unicode escape) gets a leading
    // `@charset "UTF-8";` in expanded output and a UTF-8 BOM in compressed
    // output, matching dart-sass. Pure-ASCII output gets neither.
    assert_eq!(
        ours("a {b: url(\\2603)}\n"),
        "@charset \"UTF-8\";\na {\n  b: url(\u{2603});\n}\n"
    );
    assert_eq!(ours("a {b: c}\n"), "a {\n  b: c;\n}\n");
    let compressed = compile(
        "a {b: url(\\2603)}\n",
        &Options::default().with_style(OutputStyle::Compressed),
    )
    .expect("compile failed");
    assert_eq!(compressed, "\u{FEFF}a{b:url(\u{2603})}");
}

#[test]
fn leading_utf8_bom_is_stripped() {
    // A leading UTF-8 BOM in the source is dropped before parsing, so it never
    // appears in the output and never triggers a spurious `@charset`.
    assert_eq!(ours("\u{FEFF}foo {bar: baz}\n"), "foo {\n  bar: baz;\n}\n");
}

#[test]
fn unicode_range_tokens_parse_and_preserve() {
    // CSS unicode-range values: plain ranges, `-end` ranges, and `?`
    // wildcards. The original case is preserved (`u+1a2b` stays lowercase).
    assert_eq!(ours("a {b: U+1}\n"), "a {\n  b: U+1;\n}\n");
    assert_eq!(ours("a {b: U+123456}\n"), "a {\n  b: U+123456;\n}\n");
    assert_eq!(ours("a {b: u+1a2b}\n"), "a {\n  b: u+1a2b;\n}\n");
    assert_eq!(ours("a {b: U+4??}\n"), "a {\n  b: U+4??;\n}\n");
    assert_eq!(ours("a {b: U+0-7F}\n"), "a {\n  b: U+0-7F;\n}\n");
    assert_eq!(
        ours("a {b: U+1A2B3C-10FFFF}\n"),
        "a {\n  b: U+1A2B3C-10FFFF;\n}\n"
    );
    // A `?`-wildcard token is terminal: a directly-following identifier
    // becomes a fresh space-list element (`U+A?BCDE` -> `U+A? BCDE`,
    // `U+A?-BCDE` -> `U+A? -BCDE`), while `-<digit>` continues as a
    // subtraction whose unquoted-string join keeps the source spelling.
    assert_eq!(ours("a {b: U+A?BCDE}\n"), "a {\n  b: U+A? BCDE;\n}\n");
    assert_eq!(ours("a {b: U+A?-BCDE}\n"), "a {\n  b: U+A? -BCDE;\n}\n");
    assert_eq!(ours("a {b: U+A?-1234}\n"), "a {\n  b: U+A?-1234;\n}\n");
    // Malformed ranges still error like dart-sass.
    assert!(compile("a {b: U+}\n", &Options::default()).is_err());
    assert!(compile("a {b: U+1234567}\n", &Options::default()).is_err());
    assert!(compile("a {b: U+123-456-ABC}\n", &Options::default()).is_err());
}

#[test]
fn minus_operator_string_joins_non_numbers() {
    // dart-sass's `-` operator subtracts two numbers but otherwise produces an
    // unquoted string join `<left>-<right>`, with each side keeping its own
    // serialization (quoted strings keep their quotes).
    assert_eq!(ours("a {b: foo - 1}\n"), "a {\n  b: foo-1;\n}\n");
    assert_eq!(ours("a {b: 1 - foo}\n"), "a {\n  b: 1-foo;\n}\n");
    assert_eq!(ours("a {b: foo - bar}\n"), "a {\n  b: foo-bar;\n}\n");
    assert_eq!(ours("a {b: \"q\" - 1}\n"), "a {\n  b: \"q\"-1;\n}\n");
    assert_eq!(ours("a {b: 1 - \"q\"}\n"), "a {\n  b: 1-\"q\";\n}\n");
    assert_eq!(ours("a {b: red - foo}\n"), "a {\n  b: red-foo;\n}\n");
    // Two numbers still subtract numerically.
    assert_eq!(ours("a {b: 10 - 20}\n"), "a {\n  b: -10;\n}\n");
    assert_eq!(ours("a {b: 1px - 2px}\n"), "a {\n  b: -1px;\n}\n");
}

#[test]
fn single_equals_ms_filter_operator_in_args() {
    // A lone `=` inside a function argument list is the lowest-precedence
    // Microsoft-filter operator: both sides are evaluated and joined with `=`
    // (no spaces) into an unquoted string. Surrounding whitespace is dropped.
    assert_eq!(ours("a {b: foo(a=b)}\n"), "a {\n  b: foo(a=b);\n}\n");
    assert_eq!(ours("a {b: foo(1=2)}\n"), "a {\n  b: foo(1=2);\n}\n");
    assert_eq!(ours("a {b: foo(a = b)}\n"), "a {\n  b: foo(a=b);\n}\n");
    assert_eq!(ours("a {b: foo(a=b=c)}\n"), "a {\n  b: foo(a=b=c);\n}\n");
    assert_eq!(ours("a {b: foo((1 + 2)=3)}\n"), "a {\n  b: foo(3=3);\n}\n");
    assert_eq!(ours("a {b: foo(a b = c d)}\n"), "a {\n  b: foo(a b=c d);\n}\n");
    assert_eq!(ours("a {b: foo(1 + 2 = 3 + 4)}\n"), "a {\n  b: foo(3=7);\n}\n");
    // `==` stays the equality operator inside arguments.
    assert_eq!(ours("a {b: foo(1 == 1)}\n"), "a {\n  b: foo(true);\n}\n");
}

#[test]
fn global_alpha_microsoft_filter_overload() {
    // The global `alpha()` with unquoted `name=value` arguments is the
    // proprietary IE filter overload: it passes through verbatim as a CSS
    // function rather than being treated as a color accessor.
    assert_eq!(
        ours("a {b: alpha(opacity=80)}\n"),
        "a {\n  b: alpha(opacity=80);\n}\n"
    );
    assert_eq!(ours("a {b: alpha(c=d)}\n"), "a {\n  b: alpha(c=d);\n}\n");
    assert_eq!(
        ours("a {b: alpha(c=d, e=f, g=h)}\n"),
        "a {\n  b: alpha(c=d, e=f, g=h);\n}\n"
    );
    // A real color argument still routes to the normal alpha accessor.
    assert_eq!(ours("a {b: alpha(red)}\n"), "a {\n  b: 1;\n}\n");
}

#[test]
fn unary_plus_and_minus_on_non_numbers() {
    // Unary `-`/`+` negate / identity a number, but on any other operand they
    // prepend the sign as an unquoted string (dart-sass `unaryMinus`/
    // `unaryPlus`). Whitespace may separate the operator from its operand.
    assert_eq!(ours("a {b: (- red)}\n"), "a {\n  b: -red;\n}\n");
    assert_eq!(ours("a {b: (+ red)}\n"), "a {\n  b: +red;\n}\n");
    assert_eq!(ours("a {b: +hello}\n"), "a {\n  b: +hello;\n}\n");
    assert_eq!(ours("a {b: + hello}\n"), "a {\n  b: +hello;\n}\n");
    assert_eq!(ours("a {b: (+- red)}\n"), "a {\n  b: +-red;\n}\n");
    assert_eq!(ours("a {b: (- \"q\")}\n"), "a {\n  b: -\"q\";\n}\n");
    assert_eq!(ours("a {b: (+ \"q\")}\n"), "a {\n  b: +\"q\";\n}\n");
    // Numbers keep arithmetic semantics.
    assert_eq!(ours("a {b: +10}\n"), "a {\n  b: 10;\n}\n");
    assert_eq!(ours("a {b: (- 5)}\n"), "a {\n  b: -5;\n}\n");
    assert_eq!(ours("a {b: -10px + 10px}\n"), "a {\n  b: 0px;\n}\n");
    // A `-` glued to an identifier stays part of the identifier.
    assert_eq!(ours("a {b: -webkit-box}\n"), "a {\n  b: -webkit-box;\n}\n");
}

#[test]
fn number_rounds_half_away_from_zero_at_tenth_place() {
    // dart-sass rounds to 10 decimal places half away from zero, not half to
    // even. `1.5e-10` -> `0.0000000002`, `0.99999999995` -> `1`, and
    // `0.30000000005` -> `0.3000000001`. Verified byte-for-byte against
    // `npx sass --no-source-map --stdin`.
    assert_eq!(ours("a {b: 0.00000000015}\n"), "a {\n  b: 0.0000000002;\n}\n");
    assert_eq!(ours("a {b: 0.00000000035}\n"), "a {\n  b: 0.0000000004;\n}\n");
    assert_eq!(ours("a {b: 0.99999999995}\n"), "a {\n  b: 1;\n}\n");
    assert_eq!(ours("a {b: 1.99999999995}\n"), "a {\n  b: 2;\n}\n");
    assert_eq!(ours("a {b: 0.30000000005}\n"), "a {\n  b: 0.3000000001;\n}\n");
    // Values that already round-tripped correctly must stay unchanged.
    assert_eq!(ours("a {b: 0.0000000001}\n"), "a {\n  b: 0.0000000001;\n}\n");
    assert_eq!(ours("a {b: 0.1}\n"), "a {\n  b: 0.1;\n}\n");
    assert_eq!(
        ours("a {b: 123456789.12345678905}\n"),
        "a {\n  b: 123456789.12345679;\n}\n"
    );
}

#[test]
fn opaque_hex_literals_preserve_authored_spelling() {
    // dart-sass emits an opaque 3-/6-digit hex literal exactly as authored,
    // keeping its length and case. The 4-/8-digit alpha forms, by contrast,
    // are canonicalized. Verified byte-for-byte against
    // `npx sass --no-source-map --stdin`.
    assert_eq!(ours("a {b: #fff}\n"), "a {\n  b: #fff;\n}\n");
    assert_eq!(ours("a {b: #FFF}\n"), "a {\n  b: #FFF;\n}\n");
    assert_eq!(ours("a {b: #aaa}\n"), "a {\n  b: #aaa;\n}\n");
    assert_eq!(ours("a {b: #FFAA00}\n"), "a {\n  b: #FFAA00;\n}\n");
    assert_eq!(ours("a {b: #ABCABC}\n"), "a {\n  b: #ABCABC;\n}\n");
    assert_eq!(ours("a {b: #aaaaaa}\n"), "a {\n  b: #aaaaaa;\n}\n");
    // 4-/8-digit opaque alpha forms canonicalize to lowercase 6-digit hex.
    assert_eq!(ours("a {b: #369f}\n"), "a {\n  b: #336699;\n}\n");
    assert_eq!(ours("a {b: #112233ff}\n"), "a {\n  b: #112233;\n}\n");
    // Compressed output ignores the authored spelling and shortens.
    use sasso::OutputStyle;
    let compressed = compile(
        "a {b: #FFAA00}\n",
        &Options::default().with_style(OutputStyle::Compressed),
    )
    .expect("compile failed");
    assert_eq!(compressed, "a{b:#fa0}");
}

#[test]
fn selector_nest_and_append() {
    // `selector-nest` joins selectors as descendants and resolves `&`; the
    // result is a comma list of space lists rendered as the usual selector
    // string. `selector-append` joins with no descendant combinator (the
    // leading compound of each suffix merges onto the prefix's trailing one).
    // All outputs byte-verified against dart-sass.
    assert_eq!(ours("a {b: selector-nest(c, d)}\n"), "a {\n  b: c d;\n}\n");
    assert_eq!(
        ours("a {b: selector-nest(\".a, .b\", \".c, .d\")}\n"),
        "a {\n  b: .a .c, .a .d, .b .c, .b .d;\n}\n"
    );
    assert_eq!(
        ours("a {b: selector-nest(\".a .b\", \"&:hover\")}\n"),
        "a {\n  b: .a .b:hover;\n}\n"
    );
    assert_eq!(
        ours("a {b: selector-nest(\".p1 .p2\", \".x & .y\")}\n"),
        "a {\n  b: .x .p1 .p2 .y;\n}\n"
    );
    assert_eq!(ours("a {b: selector-append(c, d)}\n"), "a {\n  b: cd;\n}\n");
    assert_eq!(
        ours("a {b: selector-append(\".a .b\", \".c .d\")}\n"),
        "a {\n  b: .a .b.c .d;\n}\n"
    );
    assert_eq!(
        ours("a {b: selector-append(\".a, .b\", \".c .d, .e\")}\n"),
        "a {\n  b: .a.c .d, .a.e, .b.c .d, .b.e;\n}\n"
    );
}

#[test]
fn selector_extend_and_replace() {
    // `selector-extend` adds the extender wherever the (compound) extendee
    // matches, keeping the original; `selector-replace` drops the matched
    // original. Compound extendees (`.a.b`) match a compound only when all
    // their simples are present. All outputs byte-verified against dart-sass.
    assert_eq!(ours("a {b: selector-extend(c, c, d)}\n"), "a {\n  b: c, d;\n}\n");
    assert_eq!(
        ours("a {b: selector-extend(\".a .b\", \".b\", \".c\")}\n"),
        "a {\n  b: .a .b, .a .c;\n}\n"
    );
    assert_eq!(
        ours("a {b: selector-extend(\".a.b .c\", \".a.b\", \".x\")}\n"),
        "a {\n  b: .a.b .c, .x .c;\n}\n"
    );
    // `.a .c` does NOT match the compound `.a.b`, so it is unchanged.
    assert_eq!(
        ours("a {b: selector-extend(\".a .c\", \".a.b\", \".x\")}\n"),
        "a {\n  b: .a .c;\n}\n"
    );
    assert_eq!(ours("a {b: selector-replace(c, c, d)}\n"), "a {\n  b: d;\n}\n");
    assert_eq!(
        ours("a {b: selector-replace(\".a.b.c\", \".a.b\", \".x\")}\n"),
        "a {\n  b: .c.x;\n}\n"
    );
    assert_eq!(
        ours("a {b: selector-replace(\".x\", \".c\", \".d\")}\n"),
        "a {\n  b: .x;\n}\n"
    );
}

#[test]
fn selector_unify_superselector_simple_and_parse() {
    // `selector-unify` yields the selectors matching both inputs (or `null`
    // when nothing unifies — the declaration is then dropped). `is-superselector`
    // tests selector-list containment. `simple-selectors` splits one compound
    // into its simples; `selector-parse` round-trips a selector string. All
    // outputs byte-verified against dart-sass.
    assert_eq!(
        ours("a {b: selector-unify(\".c\", \".d\")}\n"),
        "a {\n  b: .c.d;\n}\n"
    );
    assert_eq!(
        ours("a {b: selector-unify(\".a .b\", \".c .d\")}\n"),
        "a {\n  b: .a .c .b.d, .c .a .b.d;\n}\n"
    );
    // Incompatible type selectors don't unify; `null` drops the declaration,
    // leaving the rule empty and therefore omitted entirely (as dart-sass does).
    assert_eq!(ours("a {b: selector-unify(a, b)}\n"), "");
    assert_eq!(ours("a {b: is-superselector(c, d)}\n"), "a {\n  b: false;\n}\n");
    assert_eq!(
        ours("a {b: is-superselector(\".a\", \".a.b\")}\n"),
        "a {\n  b: true;\n}\n"
    );
    assert_eq!(
        ours("a {b: simple-selectors(\".c.d\")}\n"),
        "a {\n  b: .c, .d;\n}\n"
    );
    assert_eq!(
        ours("a {b: simple-selectors(\"a.b.c:hover\")}\n"),
        "a {\n  b: a, .b, .c, :hover;\n}\n"
    );
    assert_eq!(
        ours("a {b: selector-parse(\".c, .d\")}\n"),
        "a {\n  b: .c, .d;\n}\n"
    );
    assert_eq!(
        ours("a {b: selector-parse(\".a > .b, .c + .d\")}\n"),
        "a {\n  b: .a > .b, .c + .d;\n}\n"
    );
}

#[test]
fn function_exists_recognizes_builtins() {
    // `function-exists` reports `true` for a built-in function and `false`
    // for an unknown name (dart-sass `function-exists`).
    assert_eq!(ours("a {b: function-exists(rgb)}\n"), "a {\n  b: true;\n}\n");
    assert_eq!(ours("a {b: function-exists(\"rgb\")}\n"), "a {\n  b: true;\n}\n");
    assert_eq!(ours("a {b: function-exists(c)}\n"), "a {\n  b: false;\n}\n");
    // Arity and type validation matches dart-sass.
    assert!(compile("a {b: function-exists()}\n", &Options::default()).is_err());
    assert!(compile("a {b: function-exists(a, b, c)}\n", &Options::default()).is_err());
    assert!(compile("a {b: function-exists(2px)}\n", &Options::default()).is_err());
}

#[test]
fn get_function_validates_arity_and_type() {
    // `get-function` raises dart-sass's arity / type errors before resolution.
    assert!(compile("a {b: get-function()}\n", &Options::default()).is_err());
    assert!(compile("a {b: get-function(c, true, d, e)}\n", &Options::default()).is_err());
    assert!(compile("a {b: get-function(2px)}\n", &Options::default()).is_err());
    // A well-formed call now yields a first-class function reference. Used
    // directly as a declaration value it is not a valid CSS value (dart-sass
    // `get-function("rgb") isn't a valid CSS value.`); it is meant to be
    // invoked via `call()`.
    assert!(compile("a {b: get-function(rgb)}\n", &Options::default()).is_err());
    assert_eq!(
        ours("a {b: call(get-function(rgb), 1, 2, 3)}\n"),
        "a {\n  b: rgb(1, 2, 3);\n}\n"
    );
}

#[test]
fn nested_property_sets() {
    // A bare property set (`prop: { … }`) namespaces each child as
    // `prop-<child>`; an empty value needs no whitespace after the colon.
    assert_eq!(ours("a { b: { c: d } }\n"), "a {\n  b-c: d;\n}\n");
    assert_eq!(ours("a { b:{ c: d } }\n"), "a {\n  b-c: d;\n}\n");
    assert_eq!(ours("a { b: { -c: d } }\n"), "a {\n  b--c: d;\n}\n");
    // The value-plus-block form (`prop: value { … }`) emits the value first,
    // then the namespaced children — but only when whitespace follows the
    // colon; `b:c { … }` is a style rule, not a property set.
    assert_eq!(ours("a { b: c { d: e } }\n"), "a {\n  b: c;\n  b-d: e;\n}\n");
    assert_eq!(ours("a { b:c { d: e } }\n"), "a b:c {\n  d: e;\n}\n");
    // Property sets nest, joining each level with `-`, and interleave with a
    // following sibling separated by `;`.
    assert_eq!(
        ours("a { b: { c: { d: e }; f: g } }\n"),
        "a {\n  b-c-d: e;\n  b-f: g;\n}\n"
    );
    // A custom-property child (literal `--`) may not be nested.
    assert!(compile("a { b: { --d: e } }\n", &Options::default()).is_err());
}

#[test]
fn custom_property_declarations() {
    // A literal `--` name takes a verbatim value: SassScript is not evaluated,
    // only `#{…}` interpolation resolves.
    assert_eq!(ours("a { --x: 1 + 2; }\n"), "a {\n  --x: 1 + 2;\n}\n");
    assert_eq!(ours("a { --x: #{1 + 2}; }\n"), "a {\n  --x: 3;\n}\n");
    // Interpolation resolves even inside a quoted string in the value.
    assert_eq!(ours("a { --x: \"c#{1 + 2}d\"; }\n"), "a {\n  --x: \"c3d\";\n}\n");
    // A partially interpolated name beginning literally with `--` keeps the
    // raw value, while a fully/initially interpolated name is real SassScript.
    assert_eq!(
        ours("a { --#{only}-name: 1 + 2; }\n"),
        "a {\n  --only-name: 1 + 2;\n}\n"
    );
    assert_eq!(ours("a { #{--entire}: 1 + 2; }\n"), "a {\n  --entire: 3;\n}\n");
    // `!important` in a custom-property value is a literal value character.
    assert_eq!(
        ours("a { --x: value !important; }\n"),
        "a {\n  --x: value !important;\n}\n"
    );
}

#[test]
fn var_env_argument_evaluation() {
    // `var()`/`env()` are plain CSS functions whose arguments are real
    // SassScript: the fallback evaluates, whitespace normalises, and a
    // `var($args...)` splat expands — matching dart-sass byte for byte.
    assert_eq!(ours("a {b: var()}\n"), "a {\n  b: var();\n}\n");
    assert_eq!(ours("a {b: var(--c)}\n"), "a {\n  b: var(--c);\n}\n");
    // The fallback argument is evaluated.
    assert_eq!(ours("a {b: var(--c, 1 + 2)}\n"), "a {\n  b: var(--c, 3);\n}\n");
    assert_eq!(
        ours("a {b: var(--c, \"d\" + \"e\")}\n"),
        "a {\n  b: var(--c, \"de\");\n}\n"
    );
    // Surrounding whitespace around the trailing comma normalises.
    assert_eq!(ours("a {b: var(--c , )}\n"), "a {\n  b: var(--c, );\n}\n");
    assert_eq!(ours("a {b: var(--c ,)}\n"), "a {\n  b: var(--c, );\n}\n");
    // `allowEmptySecondArg`: a trailing comma after exactly the first argument
    // keeps an empty second argument — but only for the name `var`
    // (case-insensitively), never for `env`.
    assert_eq!(ours("a {b: var(--c,)}\n"), "a {\n  b: var(--c, );\n}\n");
    assert_eq!(ours("a {b: VaR(--c,)}\n"), "a {\n  b: VaR(--c, );\n}\n");
    assert_eq!(ours("a {b: env(--c, )}\n"), "a {\n  b: env(--c);\n}\n");
    // A trailing comma after the *second* argument is an ordinary ignorable
    // trailing comma (no empty arg added).
    assert_eq!(ours("a {b: var(--c, d,)}\n"), "a {\n  b: var(--c, d);\n}\n");
    // A parenthesised comma list spreads its items as separate arguments.
    assert_eq!(
        ours("a {b: var(--c, (1, 2))}\n"),
        "a {\n  b: var(--c, 1, 2);\n}\n"
    );
    // `var($args...)` splat expands list/single rest arguments.
    assert_eq!(
        ours("$name: --c; a {b: var($name...)}\n"),
        "a {\n  b: var(--c);\n}\n"
    );
    assert_eq!(
        ours("$args: --c, d; a {b: var($args...)}\n"),
        "a {\n  b: var(--c, d);\n}\n"
    );
    // A trailing comma after a rest argument is normal (no empty arg).
    assert_eq!(ours("$n: --c; a {b: var($n...,)}\n"), "a {\n  b: var(--c);\n}\n");
}

#[test]
fn calc_nested_parenthesization() {
    // A nested calc() whose interior is an unresolved interpolation that is
    // not a clean single token is parenthesized when spliced into the
    // surrounding calculation (whitespace / `*` / `/` are ambiguous).
    assert_eq!(
        ours("a {b: calc(calc(#{\"c*\"}))}\n"),
        "a {\n  b: calc((c*));\n}\n"
    );
    assert_eq!(
        ours("a {b: calc(calc(#{\"c/\"}))}\n"),
        "a {\n  b: calc((c/));\n}\n"
    );
    assert_eq!(
        ours("a {b: calc(calc(#{\"c \"}))}\n"),
        "a {\n  b: calc((c ));\n}\n"
    );
    // A `var()` substitution inside a nested calc is always grouped.
    assert_eq!(
        ours("a {b: calc(1 + calc(var(--c)))}\n"),
        "a {\n  b: calc(1 + (var(--c)));\n}\n"
    );
    // A clean identifier, a hyphenated token, a number, an operation, and a
    // complete sub-calculation all flatten without extra parentheses.
    assert_eq!(ours("a {b: calc(calc(#{c}))}\n"), "a {\n  b: calc(c);\n}\n");
    assert_eq!(ours("a {b: calc(calc(c-d))}\n"), "a {\n  b: calc(c-d);\n}\n");
    assert_eq!(ours("a {b: calc(calc(c + d))}\n"), "a {\n  b: calc(c + d);\n}\n");
    assert_eq!(
        ours("a {b: calc(1 + calc(min(1%, 2px)))}\n"),
        "a {\n  b: calc(1 + min(1%, 2px));\n}\n"
    );
    // A top-level (non-nested) calc keeps its own interpolation bare.
    assert_eq!(ours("a {b: calc(#{\"c*\"})}\n"), "a {\n  b: calc(c*);\n}\n");
}

#[test]
fn adjacent_quoted_string_schema() {
    // A quoted string that abuts an adjacent atom with no whitespace forms an
    // implicit space-separated list — including same-type quotes nested inside
    // interpolation, which dart-sass parses as a "string schema".
    assert_eq!(
        ours("a {b: \"[\"'foo'\"]\"}\n"),
        "a {\n  b: \"[\" \"foo\" \"]\";\n}\n"
    );
    assert_eq!(ours("a {b: \"x\"\"y\"}\n"), "a {\n  b: \"x\" \"y\";\n}\n");
    // A string followed by, or preceded by, a non-string atom also lists.
    assert_eq!(ours("a {b: \"x\"foo}\n"), "a {\n  b: \"x\" foo;\n}\n");
    assert_eq!(ours("a {b: foo\"x\"}\n"), "a {\n  b: foo \"x\";\n}\n");
    assert_eq!(ours("a {b: 1\"x\"}\n"), "a {\n  b: 1 \"x\";\n}\n");
    assert_eq!(
        ours("a {b: gamme \"x\"delta}\n"),
        "a {\n  b: gamme \"x\" delta;\n}\n"
    );
    // A same-type quote nested inside interpolation: the inner string schema
    // resolves and re-quotes around the surrounding string.
    assert_eq!(
        ours("a {b: \"[#{\"[\"'foo'\"]\"}]\"}\n"),
        "a {\n  b: \"[[ foo ]]\";\n}\n"
    );
    assert_eq!(ours("a {b: #{\"[\"'foo'\"]\"}}\n"), "a {\n  b: [ foo ];\n}\n");
    // Adjacency must not swallow a map key-value colon: a quoted-string map
    // key still parses (`("a": 1)`).
    assert_eq!(
        ours("$m: (\"a\": 1); a {b: map-get($m, \"a\")}\n"),
        "a {\n  b: 1;\n}\n"
    );
}

#[test]
fn supports_condition_serialization() {
    // A declaration condition normalizes spacing (`(a:b)` -> `(a: b)`) and
    // evaluates SassScript on both sides.
    assert_eq!(ours("@supports (a:b) {@c}\n"), "@supports (a: b) {\n  @c;\n}\n");
    assert_eq!(
        ours("@supports (1 + 1: b) {@c}\n"),
        "@supports (2: b) {\n  @c;\n}\n"
    );
    assert_eq!(
        ours("@supports (a: 1 + 1) {@c}\n"),
        "@supports (a: 2) {\n  @c;\n}\n"
    );
    // Redundant nested parentheses around a declaration collapse.
    assert_eq!(
        ours("@supports ((((a: b)))) {@c}\n"),
        "@supports (a: b) {\n  @c;\n}\n"
    );
    // `and`/`or`/`not` operators and grouping parentheses.
    assert_eq!(
        ours("@supports (a: b) and ((c: d) or (e: f)) {@g}\n"),
        "@supports (a: b) and ((c: d) or (e: f)) {\n  @g;\n}\n"
    );
    assert_eq!(
        ours("@supports not (a: b) {@c}\n"),
        "@supports not (a: b) {\n  @c;\n}\n"
    );
    // A custom-property value keeps no space after the colon and stays verbatim.
    assert_eq!(
        ours("@supports (--a: b) {@c}\n"),
        "@supports (--a: b) {\n  @c;\n}\n"
    );
    // A `calc()` (and `min`/`clamp`/…) is kept unsimplified inside a `@supports`
    // declaration, while a `#{…}` interpolation simplifies as usual.
    assert_eq!(
        ours("@supports (a: calc(1 + 2)) {@d}\n"),
        "@supports (a: calc(1 + 2)) {\n  @d;\n}\n"
    );
    assert_eq!(
        ours("@supports (a: clamp(0, 1, 2)) {@d}\n"),
        "@supports (a: clamp(0, 1, 2)) {\n  @d;\n}\n"
    );
    assert_eq!(
        ours("@supports (a: #{calc(1 + 2)}) {@d}\n"),
        "@supports (a: 3) {\n  @d;\n}\n"
    );
    // Trivia comments inside the condition are stripped; loud comments in an
    // "anything" value are preserved.
    assert_eq!(
        ours("@supports (a /**/: b) {c {d: e}}\n"),
        "@supports (a: b) {\n  c {\n    d: e;\n  }\n}\n"
    );
    // A `supports()`-style function call and an arbitrary "anything" value pass
    // through verbatim.
    assert_eq!(ours("@supports a(b) {@c}\n"), "@supports a(b) {\n  @c;\n}\n");
    assert_eq!(ours("@supports (a b) {@c}\n"), "@supports (a b) {\n  @c;\n}\n");
    // A lone interpolation is spliced in unquoted.
    assert_eq!(
        ours("@supports #{\"(a: b)\"} and (c: 1 + 1) {@d}\n"),
        "@supports (a: b) and (c: 2) {\n  @d;\n}\n"
    );
    // An empty/placeholder-only body produces no output.
    assert_eq!(ours("@supports (a: b) {}\n"), "");
    assert_eq!(ours("@supports (a: b) { %c {d: e} }\n"), "");
    // Malformed conditions are rejected.
    assert!(compile("@supports a {@b}\n", &Options::default()).is_err());
    assert!(compile("@supports (not a) {@b}\n", &Options::default()).is_err());
    assert!(compile(
        "@supports (a: b) and (c: d) or (e: f) {@g}\n",
        &Options::default()
    )
    .is_err());

    // Live parity for the same constructs.
    assert_parity("@supports (a:b) {@c}\n");
    assert_parity("@supports (a: calc(1 + 2)) and #{\"(c: d)\"} {x {y: z}}\n");
    assert_parity("@supports (--a: b //\n  ) {c {d: e}}\n");
}

#[test]
fn nested_rule_declaration_comment_bubbling_order() {
    // A declaration or loud comment that FOLLOWS a nested rule must emit AFTER
    // the bubbled-out nested rule, in source order: dart-sass splits the parent
    // block around each bubbled child rather than hoisting one combined block.
    // Loud comment between two nested rules.
    assert_eq!(
        ours("a {\n  b {c: d}\n  /* */\n  e {f: g}\n}\n"),
        "a b {\n  c: d;\n}\na {\n  /* */\n}\na e {\n  f: g;\n}\n"
    );
    // Loud comment then a declaration, both after the nested rule.
    assert_eq!(
        ours("a {\n  b {c: d}\n  /* */\n  e: f;\n}\n"),
        "a b {\n  c: d;\n}\na {\n  /* */\n  e: f;\n}\n"
    );
    // A trailing loud comment after the nested rule.
    assert_eq!(
        ours("a {\n  b {c: d}\n  /* */\n}\n"),
        "a b {\n  c: d;\n}\na {\n  /* */\n}\n"
    );
    // A declaration BEFORE the nested rule stays in the leading block.
    assert_eq!(
        ours("a {\n  x: y;\n  b {c: d}\n}\n"),
        "a {\n  x: y;\n}\na b {\n  c: d;\n}\n"
    );
    // Declarations on both sides of the nested rule split into two blocks.
    assert_eq!(
        ours("a {\n  w: x;\n  b {c: d}\n  y: z;\n}\n"),
        "a {\n  w: x;\n}\na b {\n  c: d;\n}\na {\n  y: z;\n}\n"
    );

    assert_parity("a {\n  b {c: d}\n  /* */\n  e {f: g}\n}\n");
    assert_parity("a {\n  w: x;\n  b {c: d}\n  y: z;\n}\n");
}

#[test]
fn adjacent_compound_selector_separation() {
    // A bare type/element selector appearing mid-compound is a separate adjacent
    // compound that dart-sass joins with a descendant combinator (`[a]b` ->
    // `[a] b`). This only fires for an identifier-led type, not for `*`, classes,
    // ids, attributes, or pseudos.
    assert_eq!(ours("[a]b {c: d}\n"), "[a] b {\n  c: d;\n}\n");
    assert_eq!(ours("a[b]c {d: e}\n"), "a[b] c {\n  d: e;\n}\n");
    assert_eq!(ours(":not(.x)b {c: d}\n"), ":not(.x) b {\n  c: d;\n}\n");
    assert_eq!(ours(".x[a]b.c {d: e}\n"), ".x[a] b.c {\n  d: e;\n}\n");
    assert_eq!(ours("[a]ns|b {c: d}\n"), "[a] ns|b {\n  c: d;\n}\n");
    assert_eq!(ours("*b {c: d}\n"), "* b {\n  c: d;\n}\n");
    // No separation before `*`, classes, ids, attributes, pseudos.
    assert_eq!(ours("[a]* {c: d}\n"), "[a]* {\n  c: d;\n}\n");
    assert_eq!(ours("[a].c {d: e}\n"), "[a].c {\n  d: e;\n}\n");
    assert_eq!(ours("[a]#c {d: e}\n"), "[a]#c {\n  d: e;\n}\n");
    assert_eq!(ours("[a][c] {d: e}\n"), "[a][c] {\n  d: e;\n}\n");
    assert_eq!(ours("[a]:hover {c: d}\n"), "[a]:hover {\n  c: d;\n}\n");
    // A keyframe stop like `1e2%` is NOT a selector and must stay verbatim.
    assert_eq!(
        ours("@keyframes a {\n  1e2% {c: d}\n}\n"),
        "@keyframes a {\n  1e2% {\n    c: d;\n  }\n}\n"
    );

    assert_parity("[a]b {c: d}\n");
    assert_parity(".x[a]b.c {d: e}\n");
    assert_parity(":not(.x)b {c: d}\n");
}

#[test]
fn bogus_combinator_selectors_are_omitted() {
    // Double combinators are always invalid CSS: the complex selector is omitted.
    assert_eq!(ours("> > a {b: c}\n"), "");
    assert_eq!(ours("+ ~ a {b: c}\n"), "");
    assert_eq!(ours("a > + b {c: d}\n"), "");
    assert_eq!(ours("a~>b {c: d}\n"), "");
    assert_eq!(ours("a + ~ {b: c}\n"), "");
    // A trailing combinator is valid only for nesting: the leaf block is dropped
    // but the selector still serves as a parent for nested rules.
    assert_eq!(ours("a > {b: c}\n"), "");
    assert_eq!(ours("a + {b: c}\n"), "");
    assert_eq!(ours("a > {b: c; d {e: f}}\n"), "a > d {\n  e: f;\n}\n");
    // A leading combinator at the top level is kept (nesting deprecation only).
    assert_eq!(ours("> a {b: c}\n"), "> a {\n  b: c;\n}\n");
    // In a comma list, only the bogus complex selector is dropped.
    assert_eq!(ours("a, > > b {x: y}\n"), "a {\n  x: y;\n}\n");
    // Selector pseudos: leading/trailing/double combinators inside `:is()` etc.
    // are bogus; a valid interior selector is kept.
    assert_eq!(ours(":is(> a) {b: c}\n"), "");
    assert_eq!(ours(":is(a >) {b: c}\n"), "");
    assert_eq!(ours(":is(a > + b) {c: d}\n"), "");
    assert_eq!(ours(":is(a > b) {c: d}\n"), ":is(a > b) {\n  c: d;\n}\n");
    assert_eq!(ours(":not(a >) {b: c}\n"), "");
    // `:has()` is a relative selector list: a single leading combinator is OK,
    // but double/trailing combinators are still bogus.
    assert_eq!(ours(":has(> a) {b: c}\n"), ":has(> a) {\n  b: c;\n}\n");
    assert_eq!(ours(":has(+ a) {b: c}\n"), ":has(+ a) {\n  b: c;\n}\n");
    assert_eq!(ours(":has(+ ~ a) {b: c}\n"), "");
    assert_eq!(ours(":has(a >) {b: c}\n"), "");
    // `:global`/`:local` keep their argument verbatim (not selector-parsed).
    assert_eq!(ours(":global(> a) {b: c}\n"), ":global(> a) {\n  b: c;\n}\n");
    assert_eq!(ours(":local(> a) {b: c}\n"), ":local(> a) {\n  b: c;\n}\n");

    assert_parity("> > a {b: c}\n");
    assert_parity("a > {b: c; d {e: f}}\n");
    assert_parity(":is(> a) {b: c}\n");
    assert_parity(":has(> a) {b: c}\n");
    assert_parity(":global(> a) {b: c}\n");
    assert_parity("a, > > b {x: y}\n");
}

#[test]
fn top_level_parent_selector_is_literal() {
    // At the document root (no enclosing style rule) a parent selector `&` has
    // no parent to substitute, so dart-sass keeps it literal rather than
    // dropping it.
    assert_eq!(ours("& {a: b}\n"), "& {\n  a: b;\n}\n");
    assert_eq!(ours("&.foo {a: b}\n"), "&.foo {\n  a: b;\n}\n");
    assert_eq!(ours("& .foo {a: b}\n"), "& .foo {\n  a: b;\n}\n");
    assert_eq!(ours("a & {b: c}\n"), "a & {\n  b: c;\n}\n");
    assert_eq!(ours("& & {a: b}\n"), "& & {\n  a: b;\n}\n");
    // The same holds inside a bare unknown at-rule (no selector context).
    assert_eq!(ours("@a {\n  & {b: c}\n}\n"), "@a {\n  & {\n    b: c;\n  }\n}\n");
    // A `&` with a suffix is still rejected at the top level.
    assert!(compile("&foo {a: b}\n", &Options::default()).is_err());
    assert!(compile("&-foo {a: b}\n", &Options::default()).is_err());

    assert_parity("& {a: b}\n");
    assert_parity("&.foo {a: b}\n");
    assert_parity("@a {\n  & {b: c}\n}\n");
}

#[test]
fn reference_combinator_is_rejected() {
    // Reference combinators (`/foo/`) are no longer valid CSS: dart-sass rejects
    // any top-level `/` in a selector with "expected selector.".
    assert!(compile(".foo /bar/ .baz {\n  a: b;\n}\n", &Options::default()).is_err());
    assert!(compile(".a/.b {x: y}\n", &Options::default()).is_err());
    // A `/` inside an attribute value is fine.
    assert_eq!(ours("a[href^=\"/\"] {x: y}\n"), "a[href^=\"/\"] {\n  x: y;\n}\n");
}

#[test]
fn font_face_does_not_carry_parent_selector() {
    // `@font-face` (exactly, unprefixed) holds plain declarations: dart-sass does
    // NOT carry the enclosing style-rule selector into its body, unlike `@page`,
    // `@-moz-font-face`, or an unknown directive.
    assert_eq!(
        ours("a {\n  b: c;\n  @font-face { d: e }\n}\n"),
        "a {\n  b: c;\n}\n@font-face {\n  d: e;\n}\n"
    );
    assert_eq!(
        ours("a { b { c { @font-face { e: f } g: h; } } }\n"),
        "@font-face {\n  e: f;\n}\na b c {\n  g: h;\n}\n"
    );
    // `@page` and unknown directives DO carry the parent selector into their
    // (bubbled-out) body.
    assert_eq!(
        ours("a {\n  @page { d: e }\n}\n"),
        "@page {\n  a {\n    d: e;\n  }\n}\n"
    );
    assert_eq!(
        ours("a {\n  @foo { d: e }\n}\n"),
        "@foo {\n  a {\n    d: e;\n  }\n}\n"
    );

    assert_parity("a {\n  b: c;\n  @font-face { d: e }\n}\n");
    assert_parity("a { b { c { @font-face { e: f } g: h; } } }\n");
    assert_parity("a {\n  @page { d: e }\n}\n");
}

#[test]
fn childless_at_rule_stays_in_rule_block() {
    // A childless at-rule (`@e f;`) inside a style rule stays in the parent
    // block, interleaved with declarations in source order, rather than bubbling
    // out to the document root (unlike a block at-rule).
    assert_eq!(ours("a {\n  @b c;\n}\n"), "a {\n  @b c;\n}\n");
    assert_eq!(
        ours("a {\n  b {c: d}\n  @e f;\n  g: h\n}\n"),
        "a b {\n  c: d;\n}\na {\n  @e f;\n  g: h;\n}\n"
    );
    assert_eq!(
        ours("a {\n  b {c: d}\n  @e f;\n  g {h: i}\n}\n"),
        "a b {\n  c: d;\n}\na {\n  @e f;\n}\na g {\n  h: i;\n}\n"
    );
    // A childless `@charset` is stripped at the top level but kept inside a rule.
    assert_eq!(ours("@charset \"utf-8\";\na {b: c}\n"), "a {\n  b: c;\n}\n");
    assert_eq!(
        ours("a {\n  @charset \"x\";\n  b: c;\n}\n"),
        "a {\n  @charset \"x\";\n  b: c;\n}\n"
    );

    assert_parity("a {\n  @b c;\n}\n");
    assert_parity("a {\n  b {c: d}\n  @e f;\n  g {h: i}\n}\n");
    assert_parity("a {\n  @charset \"x\";\n  b: c;\n}\n");
}

#[test]
fn extend_combinator_weave() {
    // The @extend engine must weave extenders that contain combinators
    // (`>`, `+`, `~`) rather than falling back to plain concatenation, matching
    // dart-sass's `_weaveParents` / `_mergeTrailingCombinators` algorithm.

    // Two following-sibling combinators interleave in all orderings, plus the
    // unified compound.
    assert_eq!(
        ours(".a ~ x {a: b}\n.b ~ y {@extend x}\n"),
        ".a ~ x, .a ~ .b ~ y, .b ~ .a ~ y, .a.b ~ y {\n  a: b;\n}\n"
    );
    // `~` extending a `+` target: sibling/next-sibling merge.
    assert_eq!(
        ours(".a + x {a: b}\n.b ~ y {@extend x}\n"),
        ".a + x, .b ~ .a + y, .b.a + y {\n  a: b;\n}\n"
    );
    // A `+` target with a `.a.b ~` extender yields both the woven and the
    // merged-compound branch (a regression guard for trailing-combinator
    // superselector/trim handling).
    assert_eq!(
        ours(".a + x {a: b}\n.a.b ~ y {@extend x}\n"),
        ".a + x, .a.b ~ .a + y, .a.b + y {\n  a: b;\n}\n"
    );
    // Child combinator: the sibling extender is woven after the child.
    assert_eq!(
        ours(".a > x {a: b}\n.b ~ y {@extend x}\n"),
        ".a > x, .a > .b ~ y {\n  a: b;\n}\n"
    );
    // Two child combinators in extendee and extender unify their compounds.
    assert_eq!(
        ours(".a > .b + x {a: b}\n.c > .d + y {@extend x}\n"),
        ".a > .b + x, .a.c > .b.d + y {\n  a: b;\n}\n"
    );
    // A nested extender with a child selector weaves around the child.
    assert_eq!(
        ours(".baz .foo {a: b}\nfoo > bar {@extend .foo}\n"),
        ".baz .foo, .baz foo > bar {\n  a: b;\n}\n"
    );
    // A multi-component extender is woven into the descendant context of the
    // matched compound (dart-sass `_unifyExtenders`/`unifyComplex`).
    assert_eq!(
        ours(".a .b {@extend .e}\n.e .x {x: y}\n"),
        ".e .x, .a .b .x {\n  x: y;\n}\n"
    );
    // A leading-combinator "child selector hack" (`> .foo`) is preserved through
    // extension, including a multi-component extender that keeps its combinator.
    assert_eq!(
        ours("> .foo {a: b}\nfoo > bar {@extend .foo}\n"),
        "> .foo, > foo > bar {\n  a: b;\n}\n"
    );

    // Live parity for the same constructs.
    assert_parity(".a ~ x {a: b}\n.b ~ y {@extend x}\n");
    assert_parity(".a + x {a: b}\n.a.b ~ y {@extend x}\n");
    assert_parity(".a > .b + x {a: b}\n.c > .d + y {@extend x}\n");
    assert_parity("a + b c .c1 {a: b}\na c .c2 {@extend .c1}\n");
    assert_parity(".a .b {@extend .e}\n.e .x {x: y}\n");
    assert_parity("> .foo {a: b}\nfoo > bar {@extend .foo}\n");
}

#[test]
fn extend_pseudo_element_superselector() {
    // A compound extender that contains a pseudo-element must NOT be trimmed away
    // by its pseudo-element-free sibling (a pseudo-element changes the target of
    // a compound), and the extender's other simples are themselves extended
    // transitively.
    assert_eq!(
        ours("%x#bar {a: b}\n%y, %y::fblthp {@extend %x}\nz {@extend %y}\n"),
        "z#bar, z#bar::fblthp {\n  a: b;\n}\n"
    );
    assert_eq!(
        ours("%x#bar {a: b}\n%y, %y:first-line {@extend %x}\nz {@extend %y}\n"),
        "z#bar, z#bar:first-line {\n  a: b;\n}\n"
    );

    assert_parity("%x#bar {a: b}\n%y, %y::fblthp {@extend %x}\nz {@extend %y}\n");
    assert_parity("%x#bar {a: b}\n%y, %y:before {@extend %x}\nz {@extend %y}\n");
}

#[test]
fn extend_self_referential_pseudo_converges() {
    // issue_2055: a `:not(...)`/`:has(...)` extender whose argument names the
    // extended target (`.thing`) is self-referential. dart-sass derives the
    // exact bounded nesting via `addSelector`'s pre-extension plus the
    // self-inclusive `_extendExistingExtensions` snapshot; sasso reproduces it
    // (`pseudo_arg_has_target_deep` gating + single registration-order pass).
    // Byte-locked to dart-sass 1.100.0 so the convergence can't silently drift.
    let input = r#"
:not(.thing) {
    color: red;
}
:not(.thing[disabled]) {
    @extend .thing;
    background: blue;
}
:has(:not(.thing[disabled])) {
    @extend .thing;
    background: blue;
}

"#;
    let expected = r#":not(.thing):not(:not(.thing[disabled]):not([disabled]:has(:not(.thing[disabled]):not([disabled]:not(.thing[disabled]))))) {
  color: red;
}

:not(.thing[disabled]):not([disabled]:has(:not(.thing[disabled]):not([disabled]:not(.thing[disabled])))):not([disabled]:not(.thing[disabled]):not([disabled]:has(:not(.thing[disabled]):not([disabled]:not(.thing[disabled]))))):not([disabled]:has(:not(.thing[disabled]):not([disabled]:has(:not(.thing[disabled]):not([disabled]:not(.thing[disabled])))):not([disabled]:not(.thing[disabled]):not([disabled]:has(:not(.thing[disabled]):not([disabled]:not(.thing[disabled]))))))):not([disabled]:not(.thing[disabled]):not([disabled]:has(:not(.thing[disabled]):not([disabled]:not(.thing[disabled])))):not([disabled]:not(.thing[disabled]):not([disabled]:has(:not(.thing[disabled]):not([disabled]:not(.thing[disabled]))))):not([disabled]:has(:not(.thing[disabled]):not([disabled]:has(:not(.thing[disabled]):not([disabled]:not(.thing[disabled])))):not([disabled]:not(.thing[disabled]):not([disabled]:has(:not(.thing[disabled]):not([disabled]:not(.thing[disabled])))))))) {
  background: blue;
}

:has(:not(.thing[disabled]):not([disabled]:has(:not(.thing[disabled]):not([disabled]:not(.thing[disabled])))):not([disabled]:not(.thing[disabled]):not([disabled]:has(:not(.thing[disabled]):not([disabled]:not(.thing[disabled]))))):not([disabled]:has(:not(.thing[disabled]):not([disabled]:has(:not(.thing[disabled]):not([disabled]:not(.thing[disabled])))):not([disabled]:not(.thing[disabled]):not([disabled]:has(:not(.thing[disabled]):not([disabled]:not(.thing[disabled]))))))):not([disabled]:not(.thing[disabled]):not([disabled]:has(:not(.thing[disabled]):not([disabled]:not(.thing[disabled])))):not([disabled]:not(.thing[disabled]):not([disabled]:has(:not(.thing[disabled]):not([disabled]:not(.thing[disabled]))))):not([disabled]:has(:not(.thing[disabled]):not([disabled]:has(:not(.thing[disabled]):not([disabled]:not(.thing[disabled])))):not([disabled]:not(.thing[disabled]):not([disabled]:has(:not(.thing[disabled]):not([disabled]:not(.thing[disabled]))))))))) {
  background: blue;
}
"#;
    assert_eq!(ours(input), expected);
}

#[test]
fn pseudo_parent_ref_substitutes_inside_cartesian_parts() {
    // A `&` nested in pseudo parens is not a cartesian position but still
    // substitutes (quasar: `&-container:not(&--mini-animate) &--mini`).
    assert_eq!(
        ours(".q { &-c:not(&--anim) &--mini { x: y; } }\n"),
        ".q-c:not(.q--anim) .q--mini {\n  x: y;\n}\n"
    );
    assert_parity(".q { &-c:not(&--anim) &--mini { x: y; } }\n");
}

#[test]
fn cross_module_extend_store_order() {
    use std::fs;

    // dart merges downstream extension stores transitively and applies each
    // upstream module's merged map in ONE extendList: extenders from one
    // foreign module land in registration order (bulma's .fixed-grid/.grid
    // from a single file), sibling stores in reverse first-load order, and
    // a derived (chained) entry follows its HOME store's own extenders in
    // the absorption order of its trigger.
    let dir = std::env::temp_dir().join(format!(
        "sasso-store-order-{}-{}",
        std::process::id(),
        std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .map(|d| d.as_nanos())
            .unwrap_or(0)
    ));
    fs::create_dir_all(&dir).expect("create scratch dir");
    let imp = FsImporter::new(vec![dir.clone()]);
    let opts = Options::default().with_importer(&imp);
    // Same-file foreign extends stay forward.
    fs::write(dir.join("_shared2.scss"), "%blk:not(:last-child) { m: 1; }\n").unwrap();
    fs::write(
        dir.join("_two.scss"),
        "@use \"shared2\";\n.fixed-grid { @extend %blk; f: 1; }\n.grid { @extend %blk; g: 1; }\n",
    )
    .unwrap();
    let out = compile("@use \"two\";\n", &opts).expect("two compiles");
    assert!(
        out.starts_with(".fixed-grid:not(:last-child), .grid:not(:last-child)"),
        "same-file forward order:\n{out}"
    );
    // Sibling modules: reverse first-load order, forward within each.
    fs::write(dir.join("_sh.scss"), "%b { m: 1; }\n").unwrap();
    fs::write(
        dir.join("_ma.scss"),
        "@use \"sh\";\n.a1 { @extend %b; }\n.a2 { @extend %b; }\n",
    )
    .unwrap();
    fs::write(dir.join("_mb.scss"), "@use \"sh\";\n.b1 { @extend %b; }\n").unwrap();
    fs::write(
        dir.join("_mc.scss"),
        "@use \"sh\";\n.c1 { @extend %b; }\n.c2 { @extend %b; }\n",
    )
    .unwrap();
    let out = compile("@use \"ma\";\n@use \"mc\";\n@use \"mb\";\n", &opts).expect("siblings compile");
    assert!(
        out.starts_with(".b1, .c1, .c2, .a1, .a2"),
        "sibling order:\n{out}"
    );
    // Midstream chain: derived entries follow their home store.
    fs::write(dir.join("_up.scss"), "in-upstream { a: b; }\n").unwrap();
    fs::write(
        dir.join("_mid.scss"),
        "@use \"up\";\nin-midstream { @extend in-upstream; }\n",
    )
    .unwrap();
    fs::write(
        dir.join("_l.scss"),
        "@use \"mid\";\nin-left { @extend in-midstream; w: x; }\n",
    )
    .unwrap();
    fs::write(
        dir.join("_r.scss"),
        "@use \"mid\";\nin-right { @extend in-midstream; y: z; }\n",
    )
    .unwrap();
    let out = compile("@use \"l\";\n@use \"r\";\n", &opts).expect("midstream compiles");
    assert!(
        out.starts_with("in-upstream, in-midstream, in-right, in-left"),
        "midstream chain order:\n{out}"
    );
    let _ = fs::remove_dir_all(&dir);
}

#[test]
fn pre_rule_extensions_apply_one_shot_in_registration_order() {
    // dart's addSelector extends a NEW rule by the store registered SO FAR
    // in one extendList (products in registration order); only extensions
    // registered AFTER the rule re-extend it incrementally (their products
    // land closest to the original). govuk's `.govuk-body-l` /
    // `.govuk-body-lead` aliases against the contextual
    // `%govuk-body-l + %govuk-heading-l` rule.
    assert_eq!(
        ours(".hl { @extend %h; h: 1; }\n.bl { @extend %l; b: 1; }\n.lead { @extend %l; }\n%l + %h { p: 1; }\n.after { @extend %l; }\n"),
        ".hl {\n  h: 1;\n}\n\n.bl {\n  b: 1;\n}\n\n.after + .hl, .bl + .hl, .lead + .hl {\n  p: 1;\n}\n"
    );
    assert_parity(".hl { @extend %h; h: 1; }\n.bl { @extend %l; b: 1; }\n.lead { @extend %l; }\n%l + %h { p: 1; }\n.after { @extend %l; }\n");
    // The @media copy of the rule inherits the same addSelector timing.
    assert_parity(".hl { @extend %h; h: 1; }\n.bl { @extend %l; b: 1; }\n.lead { @extend %l; }\n%l + %h { p: 1; @media (min-width: 5px) { p: 2; } }\n");
}

#[test]
fn chained_extend_products_keep_registration_order() {
    // dart's addSelector hands each @extend an ALREADY-EXTENDED extender
    // list (the rule's selector was rewritten by every extension registered
    // so far), so chained products arrive in forward registration order:
    // `.cf`'s extenders land as [.c-sm, .c-md], not reversed (bootstrap's
    // `.navbar > .container-{sm,md,lg,xl,xxl}` run).
    assert_eq!(
        ours(".cf { a: b; }\n.c-sm { @extend .cf; }\n.c-md { @extend .cf; }\n.nav {\n  %p { x: y; }\n  > .c,\n  > .cf { @extend %p; }\n}\n"),
        ".cf, .c-md, .c-sm {\n  a: b;\n}\n\n.nav > .c,\n.nav > .cf,\n.nav > .c-sm,\n.nav > .c-md {\n  x: y;\n}\n"
    );
    assert_parity(".cf { a: b; }\n.c-sm { @extend .cf; }\n.c-md { @extend .cf; }\n.nav {\n  %p { x: y; }\n  > .c,\n  > .cf { @extend %p; }\n}\n");
    // Transitive chains and cycles still resolve.
    assert_parity(".a { x: y; @extend .b; }\n.b { @extend .c; }\n.c { z: w; }\n");
    assert_parity(
        ".foo { a: b; @extend .bar; }\n.bar { c: d; @extend .baz; }\n.baz { e: f; @extend .foo; }\n",
    );
}

#[test]
fn pseudo_arg_newlines_survive_serialization() {
    // dart's arg complexes carry their source lineBreak and the serializer
    // honors it anywhere — inside pseudo args included, with continuation
    // lines re-indented to the rule's indent in nested contexts (quasar's
    // `:is(:-webkit-autofill,\n[type=color], …)` field selectors).
    assert_eq!(
        ours(".z:is(a,\n[type=color],\nb) { x: y; }\n"),
        ".z:is(a,\n[type=color],\nb) {\n  x: y;\n}\n"
    );
    assert_eq!(
        ours("@media (a: b) { .z:is(a,\n[type=color]) { x: y; } }\n"),
        "@media (a: b) {\n  .z:is(a,\n  [type=color]) {\n    x: y;\n  }\n}\n"
    );
    // Through the extend machinery (parse -> render round trip).
    assert_parity(".e { x: y; }\n.z:is(a,\nb) { @extend .e; }\n");
    assert_parity("@media (a: b) { .z:is(a,\n[type=color],\nb) { x: y; } }\n");
}

#[test]
fn parent_resolution_linebreak_flags_match_dart() {
    // dart rebuilds `&`-bearing complexes from a lineBreak:false base, so a
    // template's own flag is dropped and the product takes the substituted
    // parent's; a k>=2 cartesian combo ORs its chosen parents' flags
    // (mastodon's adjacent-state selectors); `&`-less parts keep
    // template-OR-parent.
    assert_eq!(
        ours(".p,\n.v { &:a,\n&:b { x: y; } }\n"),
        ".p:a, .p:b,\n.v:a,\n.v:b {\n  x: y;\n}\n"
    );
    assert_eq!(
        ours(".p,\n.v { &:a + &:b,\n&:b + &:a { x: y; } }\n"),
        ".p:a + .p:b, .p:b + .p:a,\n.p:a + .v:b,\n.p:b + .v:a,\n.v:a + .p:b,\n.v:b + .p:a,\n.v:a + .v:b,\n.v:b + .v:a {\n  x: y;\n}\n"
    );
    assert_parity(".p,\n.v { &:a + &:b,\n&:b + &:a { x: y; } }\n");
    assert_parity(".p,\n.v { .x,\n&:b { x: y; } }\n");
    assert_parity(".p, .v { .x,\n.y { x: y; } }\n");
}

#[test]
fn multi_parent_ref_expansion_interleaves_column_major() {
    // dart resolveParentSelectors flattens the per-part rows VERTICALLY:
    // with parents [.p, .v] and three templates each holding two `&`s, the
    // output groups by parent COMBINATION (templates inner), not by template
    // (mastodon's privacy-dropdown adjacent-state selectors).
    assert_eq!(
        ours(".p, .v {\n  &:a + &:b,\n  &:b + &:a { x: y; }\n}\n"),
        ".p:a + .p:b, .p:b + .p:a, .p:a + .v:b, .p:b + .v:a, .v:a + .p:b, .v:b + .p:a, .v:a + .v:b, .v:b + .v:a {\n  x: y;\n}\n"
    );
    assert_parity(".p, .v {\n  &:a + &:b,\n  &:b + &:a { x: y; }\n}\n");
    assert_parity(".p, .v { &:h + &:i, &:i + &:h, &:i + &:i { x: y; } }\n");
}

#[test]
fn plain_css_import_reserializes_selectors() {
    use std::fs;

    // dart re-serializes a plain-CSS import through its parser: identifier
    // attribute values lose their quotes and the source's selector line
    // structure is preserved (primer's @primer/primitives theme files).
    let dir = std::env::temp_dir().join(format!(
        "sasso-css-import-serialize-{}-{}",
        std::process::id(),
        std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .map(|d| d.as_nanos())
            .unwrap_or(0)
    ));
    fs::create_dir_all(&dir).expect("create scratch dir");
    let imp = FsImporter::new(vec![dir.clone()]);
    let opts = Options::default().with_importer(&imp);
    fs::write(
        dir.join("theme.css"),
        "[data-q=\"light\"],\n[data-r=\"light\"] { x: y; }\n@media (a: b) {\n  [data-s=\"1px\"],\n  .m { x: y; }\n}\n",
    )
    .unwrap();
    assert_eq!(
        compile("@import \"theme\";\n", &opts).expect("css import compiles"),
        "[data-q=light],\n[data-r=light] {\n  x: y;\n}\n\n@media (a: b) {\n  [data-s=\"1px\"],\n  .m {\n    x: y;\n  }\n}"
    );
    let _ = fs::remove_dir_all(&dir);
}

#[test]
fn nested_at_rule_wrap_keeps_selector_linebreaks() {
    // dart preserves the selector list's source line structure in the copy
    // of the rule hoisted into a nested @media (just-the-docs/minimal-
    // mistakes: `h1,\n.alpha { @include fs-with-media; }`).
    assert_eq!(
        ours("@mixin fs { font-size: 1px; @media (a: b) { font-size: 2px; } }\nh1,\n.alpha { @include fs; }\n"),
        "h1,\n.alpha {\n  font-size: 1px;\n}\n@media (a: b) {\n  h1,\n  .alpha {\n    font-size: 2px;\n  }\n}\n"
    );
    assert_parity(
        "@mixin fs { font-size: 1px; @media (a: b) { font-size: 2px; } }\nh1,\n.alpha { @include fs; }\n",
    );
}

#[test]
fn pre_module_comments_are_emitted_once() {
    use std::fs;

    // A comment preceding a `@use`/`@forward` is emitted exactly ONCE, in
    // place, however many edges reach the module afterwards. Up to 1.104.0
    // dart re-emitted it at every later edge into that module (the
    // `_preModuleComments` map, which the inherited-map quirk made visible to
    // nested module evaluations); dart-sass 1.104.1 removed that. Measured
    // against dart-sass 1.104.1.
    let dir = std::env::temp_dir().join(format!(
        "sasso-premodule-comments-{}-{}",
        std::process::id(),
        std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .map(|d| d.as_nanos())
            .unwrap_or(0)
    ));
    fs::create_dir_all(&dir).expect("create scratch dir");
    let imp = FsImporter::new(vec![dir.clone()]);
    let opts = Options::default().with_importer(&imp);
    fs::write(dir.join("_a.scss"), "@use \"sass:list\";\n.a { x: y; }\n").unwrap();
    fs::write(dir.join("_b.scss"), "@use \"a\";\n.b { x: y; }\n").unwrap();
    fs::write(dir.join("_i.scss"), "/* C */\n@forward \"a\";\n@forward \"b\";\n").unwrap();
    // `i`'s header precedes a's CSS and is not repeated at b's edge.
    assert_eq!(
        compile("@use \"i\";\n", &opts).expect("module chain compiles"),
        "/* C */\n.a {\n  x: y;\n}\n\n.b {\n  x: y;\n}"
    );
    // Diamond via sibling loaders: right's `@use` is a repeat edge, so left's
    // comment is not repeated there and right's own comment stays in place.
    fs::write(dir.join("_s.scss"), ".s { x: y; }\n").unwrap();
    fs::write(dir.join("_l.scss"), "/* L */\n@use \"s\";\n").unwrap();
    fs::write(dir.join("_r.scss"), "/* R */\n@use \"s\";\n").unwrap();
    assert_eq!(
        compile("@use \"l\";\n@use \"r\";\n", &opts).expect("diamond compiles"),
        "/* L */\n.s {\n  x: y;\n}\n\n/* R */"
    );
    let _ = fs::remove_dir_all(&dir);
}

#[test]
fn invisible_last_child_packs_next_group_tight() {
    // dart's blank-line separator belongs to a group's LAST child node —
    // created even for an empty (extend-only) rule, and never rendered when
    // invisible. So a rule whose final child produced nothing packs the next
    // top-level group TIGHT (bootstrap: `.navbar-brand` directly after the
    // resurrected `%container-flex-properties` run).
    assert_eq!(
        ours(".nav {\n  %p { x: y; }\n  > .c { @extend %p; }\n}\n.brand { y: z; }\n"),
        ".nav > .c {\n  x: y;\n}\n.brand {\n  y: z;\n}\n"
    );
    assert_parity(".nav {\n  %p { x: y; }\n  > .c { @extend %p; }\n}\n.brand { y: z; }\n");
    // Through control flow (@each) — the flag rides the last inner statement.
    assert_parity(
        ".nav {\n  %p { x: y; }\n  @each $s in (sm, md) {\n    > .c-#{$s} { @extend %p; }\n  }\n}\n.brand { y: z; }\n"
    );
    // A VISIBLE last child still blank-separates; a variable decl after it
    // creates no node and leaves the separator alone.
    assert_parity(".nav {\n  .x { a: b; }\n  $v: 1;\n}\n.brand { y: z; }\n");
    // Consecutive droppable placeholder rules after a blank exercise the
    // rewrite loop's index handling (a preceding-Blank removal must not skip
    // the shifted-in successor).
    assert_parity(concat!(
        "%default-color {color: red}\n%alt-color {color: green}\n",
        "%default-style {\n@extend %default-color;\n&:hover {@extend %alt-color}\n",
        "&:active {@extend %default-color}\n}\n",
        ".test-case {@extend %default-style}\n"
    ));
}

#[test]
fn invisible_rule_leaves_no_blank_line_group_end() {
    // An `@extend`-only rule produces no CSS, so dart never treats it as a
    // group end: the at-rules emitted around it from consecutive `@each`
    // rounds stay tight (bootstrap's responsive-container @media blocks).
    assert_parity(
        "$bps: (sm: 10px, md: 20px);\n.fluid { w: 1; }\n@each $bp, $w in $bps {\n  .c-#{$bp} { @extend .fluid; }\n  @media (min-width: $w) { .x { max-width: $w; } }\n}\n",
    );
    assert_eq!(
        ours(".fluid { w: 1; }\n.a { @extend .fluid; }\n@media (a: b) { .x { y: z; } }\n@media (c: d) { .x { y: z; } }\n"),
        ".fluid, .a {\n  w: 1;\n}\n\n@media (a: b) {\n  .x {\n    y: z;\n  }\n}\n@media (c: d) {\n  .x {\n    y: z;\n  }\n}\n"
    );
}

#[test]
fn indented_selector_comma_continues_despite_pseudo_colon() {
    // A trailing top-level comma continues the selector list even when the
    // line contains a colon, as long as that colon is not followed by
    // whitespace (a declaration value): dart joins `&:active,`,
    // `a::-webkit-x,` and even `b:c,` onto the next line (quasar's
    // normalize.sass search-input selectors), while `m: a,` stays a
    // declaration.
    assert_eq!(
        ours_sass(".p\n  &:active,\n  &.on\n    x: y\n"),
        ".p:active, .p.on {\n  x: y;\n}\n"
    );
    assert_eq!(
        ours_sass("i[type=\"s\"]::-webkit-a,\ni[type=\"s\"]::-webkit-b\n  x: y\n"),
        "i[type=s]::-webkit-a,\ni[type=s]::-webkit-b {\n  x: y;\n}\n"
    );
    assert_eq!(ours_sass("b:c,\nd\n  x: y\n"), "b:c,\nd {\n  x: y;\n}\n");
    assert_eq!(ours_sass(".q\n  m: a,\n  n: b\n"), ".q {\n  m: a;\n  n: b;\n}\n");
}

#[test]
fn indented_loud_comment_block_matches_dart_reindent() {
    // dart's _loudComment joins the first content line to `/*` with one
    // space, gutters continuation lines with ` * ` (padding indentation
    // beyond comment_col + 3), and its serializer strips min(1, comment_col)
    // — so an indented comment loses the gutter's leading space while a
    // top-level one keeps it (quasar's QSkeleton block comments).
    assert_eq!(
        ours_sass(".x\n  /*\n    one line\n    two line\n   */\n  b: c\n"),
        ".x {\n  /* one line\n  * two line\n  * */\n  b: c;\n}\n"
    );
    assert_eq!(
        ours_sass(".x\n  /*\n    one line\n      deeper line\n   */\n  b: c\n"),
        ".x {\n  /* one line\n  *  deeper line\n  * */\n  b: c;\n}\n"
    );
    assert_eq!(
        ours_sass("/*\n  top one\n  top two\n */\n.y\n  b: c\n"),
        "/* top one\n * top two\n * */\n.y {\n  b: c;\n}\n"
    );
    // A blank line inside the block becomes a bare gutter line.
    assert_eq!(
        ours_sass(".x\n  /*\n    one\n\n    three\n   */\n  b: c\n"),
        ".x {\n  /* one\n  *\n  * three\n  * */\n  b: c;\n}\n"
    );
}

#[test]
fn indented_loud_comment_first_line_stays_verbatim() {
    // The text after `/*` on a loud comment's first line is glued verbatim:
    // `/**` keeps its doubled star (quasar's normalize.sass banners) and
    // extra spacing is preserved; continuation lines keep their source
    // column behind the ` *` gutter.
    assert_eq!(
        ours_sass("/**\n * Remove the border.\n */\nimg\n  b: 0\n"),
        "/**\n * * Remove the border.\n * */\nimg {\n  b: 0;\n}\n"
    );
    assert_eq!(
        ours_sass("/*  two spaces\n  * mid\n */\n.a\n  b: c\n"),
        "/*  two spaces\n * * mid\n * */\n.a {\n  b: c;\n}\n"
    );
}

#[test]
fn indented_use_as_star_does_not_continue_prelude() {
    use std::fs;

    // In the indented syntax a trailing operator continues the logical line,
    // but the `*` of `@use "x" as *` is the wildcard namespace terminator —
    // it must not swallow the following line into the @use prelude
    // (vuetify's tools/_display.sass: `@use '../settings' as *` followed by
    // a `=mixin` definition died with "Nothing may be indented beneath a
    // @use rule").
    let dir = std::env::temp_dir().join(format!(
        "sasso-as-star-{}-{}",
        std::process::id(),
        std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .map(|d| d.as_nanos())
            .unwrap_or(0)
    ));
    fs::create_dir_all(&dir).expect("create scratch dir");
    let imp = FsImporter::new(vec![dir.clone()]);
    fs::write(dir.join("_settings.sass"), "$w: 2px\n").unwrap();
    let out = compile(
        "@use 'settings' as *\n\n=media-up($n)\n  @media (min-width: $n)\n    @content\n\n.a\n  +media-up($w)\n    x: y\n",
        &Options::default()
            .with_syntax(sasso::Syntax::Sass)
            .with_importer(&imp),
    )
    .expect("as-star followed by mixin definition compiles");
    assert_eq!(out, "@media (min-width: 2px) {\n  .a {\n    x: y;\n  }\n}");
    // A REAL pending multiplication still continues the line.
    assert_eq!(ours_sass("$a: 2 *\n  3\n.b\n  c: $a\n"), ".b {\n  c: 6;\n}\n");
    let _ = fs::remove_dir_all(&dir);
}

#[test]
fn media_inside_unknown_at_rule() {
    // dart `_inUnknownAtRule`: inside a generic/unknown at-rule's body, bare
    // declarations are legal without an enclosing style rule — including
    // directly inside a nested `@media` (the canonical Tailwind v4
    // `@utility` responsive-override idiom). Byte-matched to dart-sass.
    assert_eq!(
        ours("@utility container { @media (width >= 96rem) { max-width: 87.5rem; } }\n"),
        "@utility container {\n  @media (width >= 96rem) {\n    max-width: 87.5rem;\n  }\n}\n"
    );
    // With a declaration before the @media, and the classic min-width syntax.
    assert_eq!(
        ours("@utility container { margin: auto; @media (min-width: 100px) { max-width: 87.5rem; } }\n"),
        "@utility container {\n  margin: auto;\n  @media (min-width: 100px) {\n    max-width: 87.5rem;\n  }\n}\n"
    );
    assert_eq!(
        ours("@foo bar { @media (min-width: 100px) { a: b; } }\n"),
        "@foo bar {\n  @media (min-width: 100px) {\n    a: b;\n  }\n}\n"
    );
    // Interpolated query in the same position.
    assert_eq!(
        ours("@utility x { @media #{\"(min-width: 5px)\"} { a: b; } }\n"),
        "@utility x {\n  @media (min-width: 5px) {\n    a: b;\n  }\n}\n"
    );
    // Style rules nested in the unknown at-rule keep working alongside.
    assert_parity("@utility x { .r { c: d; } @media (min-width: 5px) { a: b; } }\n");
    assert_parity("@utility container { @media (width >= 96rem) { max-width: 87.5rem; } }\n");
    // @supports in the identical position (regression guard for the variant
    // matrix), and @media inside a KNOWN at-rule via a style rule.
    assert_parity("@utility x { @supports (display: grid) { a: b; } }\n");
    assert_parity("@layer base { @media (min-width: 100px) { a { color: red; } } }\n");
    // A bare declaration in a TOP-LEVEL @media must still error like dart.
    assert_error_parity("@media (min-width: 5px) { a: b; }\n");
}

#[test]
fn escaped_bang_in_selector_parses() {
    // `!` normally stops a selector scan (`a !important {` → expected "{"),
    // but a CSS escape makes it identifier text: govuk-frontend's
    // `.govuk-\!-font-size-#{$size}` classes must parse and round-trip.
    assert_eq!(ours(".a-\\!-b { x: y; }\n"), ".a-\\!-b {\n  x: y;\n}\n");
    assert_eq!(
        ours("@each $s in (16, 19) { .e-\\!-f-#{$s} { x: y; } }\n"),
        ".e-\\!-f-16 {\n  x: y;\n}\n\n.e-\\!-f-19 {\n  x: y;\n}\n"
    );
    assert_parity(".a-\\!-b { x: y; }\n");
    // The unescaped form still errors like dart.
    assert_error_parity("a !important { x: y; }\n");
}

#[test]
fn errors_in_loaded_files_name_that_file_with_loader_frames() {
    use std::fs;

    // dart names the ERRORING file in the snippet and stacks a frame per
    // loader (`_mod.scss 1:18  @use` / `main.scss 1:1  root stylesheet`).
    // Regression: sasso rendered the ROOT file's name/snippet with the inner
    // file's line numbers, for both parse and eval errors — which misled two
    // bench/real-world triages.
    let dir = std::env::temp_dir().join(format!(
        "sasso-err-attribution-{}-{}",
        std::process::id(),
        std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .map(|d| d.as_nanos())
            .unwrap_or(0)
    ));
    fs::create_dir_all(&dir).expect("create scratch dir");
    let imp = FsImporter::new(vec![dir.clone()]);
    let opts = Options::default().with_importer(&imp).with_url("main.scss");
    // Eval error (undefined variable) inside a @use'd module.
    fs::write(dir.join("_broke.scss"), ".x { color: $nope; }\n").unwrap();
    let err = compile("@use \"broke\";\n", &opts)
        .expect_err("must fail")
        .to_string();
    assert!(err.contains("_broke.scss 1:13  @use"), "got:\n{err}");
    assert!(err.contains("root stylesheet"), "got:\n{err}");
    assert!(
        err.contains("color: $nope"),
        "snippet from the module file:\n{err}"
    );
    // Same through legacy @import (frame caret on the URL token).
    let err = compile("@import \"broke\";\n", &opts)
        .expect_err("must fail")
        .to_string();
    assert!(err.contains("_broke.scss 1:13  @import"), "got:\n{err}");
    // Parse error inside a nested @use chain: innermost frame names the
    // broken file, with one @use frame per intermediate loader.
    fs::write(dir.join("_badparse.scss"), ".x {\n  broken westward{{{\n}\n").unwrap();
    fs::write(dir.join("_mid.scss"), "@use \"badparse\";\n").unwrap();
    let err = compile("@use \"mid\";\n", &opts)
        .expect_err("must fail")
        .to_string();
    assert!(err.contains("_badparse.scss"), "got:\n{err}");
    assert!(err.contains("_mid.scss 1:1"), "intermediate @use frame:\n{err}");
    assert!(
        !err.contains("_mid.scss 1:1        root stylesheet"),
        "mid is @use, not root:\n{err}"
    );
    let _ = fs::remove_dir_all(&dir);
}

#[test]
fn callable_closure_captures_module_namespaces() {
    use std::fs;

    // dart Environment.closure() carries the `@use` namespace tables: a
    // function/mixin inlined by `@import` (or reached through multi-hop
    // `@forward`) resolves `list.length()`/`meta.type-of()` against the
    // DEFINING file's `@use "sass:*"`, not the caller's bindings
    // (uswds `units()`, quasar `str-fe()`).
    let dir = std::env::temp_dir().join(format!(
        "sasso-callable-ns-{}-{}",
        std::process::id(),
        std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .map(|d| d.as_nanos())
            .unwrap_or(0)
    ));
    fs::create_dir_all(&dir).expect("create scratch dir");
    let imp = FsImporter::new(vec![dir.clone()]);
    let opts = Options::default().with_importer(&imp);
    fs::write(
        dir.join("_nslib.scss"),
        "@use \"sass:list\";\n@use \"sass:meta\";\n@function str-fe($x) { @return list.length($x); }\n@mixin dump() { x: meta.type-of(1); }\n",
    )
    .unwrap();
    assert_eq!(
        compile(
            "@import \"nslib\";\n.a { y: str-fe((1, 2)); @include dump(); }\n",
            &opts
        )
        .expect("imported callables resolve their own namespaces"),
        ".a {\n  y: 2;\n  x: number;\n}"
    );
    // Multi-hop @forward: the function's own file @uses sass:meta; the
    // caller reaches it through a forwarding module used with `as *`.
    fs::write(
        dir.join("_units.scss"),
        "@use \"sass:meta\";\n@function kind($v) { @return meta.type-of($v); }\n",
    )
    .unwrap();
    fs::write(dir.join("_core.scss"), "@forward \"units\";\n").unwrap();
    assert_eq!(
        compile("@use \"core\" as *;\n.b { k: kind(3px); }\n", &opts)
            .expect("forwarded function resolves defining file's namespaces"),
        ".b {\n  k: number;\n}"
    );
    let _ = fs::remove_dir_all(&dir);
}

#[test]
fn trailing_comment_never_joins_across_import_files() {
    use std::fs;

    // dart's `_isTrailingComment` compares source FILES, not just line
    // numbers: a comment at the top of an `@import`ed file must not glue onto
    // a comment that happens to end on the same line number in the importing
    // chain. Regression: legacy `@import` did not re-stamp the file id, so
    // `/* c1 */` (line 1 of one file) and a multi-line `/*! ... */` (line 1
    // of the next) joined as ` /*…*/`. Offline, byte-matched to dart-sass.
    let dir = std::env::temp_dir().join(format!(
        "sasso-import-trailing-{}-{}",
        std::process::id(),
        std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .map(|d| d.as_nanos())
            .unwrap_or(0)
    ));
    fs::create_dir_all(&dir).expect("create scratch dir");
    let imp = FsImporter::new(vec![dir.clone()]);
    let opts = Options::default().with_importer(&imp);
    fs::write(dir.join("_skin.scss"), "$v: 1px;\n").unwrap();
    fs::write(
        dir.join("_mmlike.scss"),
        "/* c1 */\n@import \"copyrightish\";\n@import \"restish\";\n",
    )
    .unwrap();
    fs::write(dir.join("_copyrightish.scss"), "/*!\n * banner\n */\n").unwrap();
    fs::write(dir.join("_restish.scss"), ".r { top: $v; }\n").unwrap();
    let out = compile(
        "@charset \"utf-8\";\n\n@import \"skin\";\n@import \"mmlike\";\n",
        &opts,
    )
    .expect("import chain compiles");
    assert_eq!(out, "/* c1 */\n/*!\n * banner\n */\n.r {\n  top: 1px;\n}");
    let _ = fs::remove_dir_all(&dir);
}

#[test]
fn fs_importer_partial_extension_and_import_only_resolution() {
    use std::fs;
    use std::path::PathBuf;

    // A unique scratch dir under the OS temp directory.
    let dir = std::env::temp_dir().join(format!(
        "sasso-import-resolve-{}-{}",
        std::process::id(),
        std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .map(|d| d.as_nanos())
            .unwrap_or(0)
    ));
    fs::create_dir_all(&dir).expect("create scratch dir");

    let imp = sasso::FsImporter::new(vec![dir.clone()]);
    let opts = Options::default().with_importer(&imp);
    let write = |name: &str, body: &str| fs::write(dir.join(name), body).expect("write fixture");
    let rm = |name: &str| {
        let _ = fs::remove_file(dir.join(name));
    };

    // An import-only file (`other.import.scss`) takes precedence over the
    // normal partial (`_other.scss`), matching dart-sass's load order.
    write("other.import.scss", "a {import-only: true}\n");
    write("_other.scss", "a {import-only: false}\n");
    assert_eq!(
        compile("@import \"other\";\n", &opts).expect("import-only resolution"),
        "a {\n  import-only: true;\n}"
    );

    // A real-world import-only file re-exports with `@forward`, which this
    // build can't inline; resolution falls back to the normal file instead of
    // failing on the unsupported `@forward`.
    write("other.import.scss", "@forward \"other\";\n");
    write("_other.scss", "b {c: fallback}\n");
    assert_eq!(
        compile("@import \"other\";\n", &opts).expect("fallback past @forward import-only"),
        "b {\n  c: fallback;\n}"
    );

    // Two candidates at the same precedence tier (non-partial + partial) are
    // ambiguous, so the import fails rather than silently picking one.
    rm("other.import.scss");
    write("other.scss", "x {y: nonpartial}\n");
    write("_other.scss", "x {y: partial}\n");
    assert!(compile("@import \"other\";\n", &opts).is_err());

    // Cleanup (best effort).
    let _: Result<(), _> = fs::remove_dir_all(PathBuf::from(&dir));
}

#[test]
fn parity_calc_math_function_simplification() {
    // The math calculations evaluate their arguments as calculations: a
    // fully-numeric argument computes, but an argument still carrying a
    // `var()` keeps the whole call as a preserved calculation with its numeric
    // subtree folded.
    assert_parity(concat!(
        "a {\n",
        "  a1: sqrt(2);\n",
        "  a2: sin(1deg);\n",
        "  a3: pow(2, 3);\n",
        "  a4: hypot(3, 4);\n",
        "  b1: sqrt(1px + 2px - var(--c));\n",
        "  b2: sin(3px - 1px + var(--c));\n",
        "  b3: sin(var(--c));\n",
        "  b4: pow(3px - 1px + var(--c), 4px + 10px);\n",
        "  b5: log(3px - 1px + var(--c), var(--e));\n",
        "}\n",
    ));
}

#[test]
fn parity_calc_size() {
    // `calc-size()` keeps its sizing target verbatim and evaluates its value
    // as a calculation, folding the numeric subtree and lower-casing the name.
    assert_parity(concat!(
        "a {\n",
        "  c1: calc-size(var(--foo));\n",
        "  c2: calc-size(auto, 5% - 20px + size);\n",
        "  c3: calc-size(auto, 100px - 20px + size);\n",
        "  c4: CaLc-size(auto, size - 20px);\n",
        "}\n",
    ));
}

#[test]
fn parity_calc_complex_unit_in_sum_errors() {
    // A `+`/`-` operand that resolves to a number with complex units — a
    // compound unit (`1px * 1px`) or an inverse unit (`1 / 1px`) — is rejected
    // ("Number calc(...) isn't compatible with CSS calculations."), while a
    // standalone compound/inverse calculation and a `var()`-bearing product
    // stay preserved.
    for src in [
        "a {b: calc(1px + 1px*1px)}\n",
        "a {b: calc(1px + 1/1px)}\n",
        "a {b: calc(1 + 1/1px)}\n",
        "a {b: calc(1% + 1s / 2px)}\n",
        "a {b: calc(1px*1s + 1px*1px)}\n",
    ] {
        assert!(
            compile(src, &Options::default()).is_err(),
            "expected complex-unit sum to error: {src}"
        );
    }
    assert_parity(concat!(
        "a {\n",
        "  k1: calc(1px * 1px);\n",
        "  k2: calc(1 / 1px);\n",
        "  k3: calc(1px + 2% * var(--c));\n",
        "  k4: calc(1px + 100% / var(--x));\n",
        "}\n",
    ));
}

#[test]
fn parity_abs_calc_vs_global() {
    // `abs()` preserves as the CSS calculation when its argument references a
    // `var()` (folding the numeric subtree), but a plain-number argument keeps
    // the legacy Sass global behaviour.
    assert_parity(concat!(
        "a {\n",
        "  c1: abs(1px + 2px - var(--c));\n",
        "  c2: abs(var(--c));\n",
        "  g1: abs(1 + 1px);\n",
        "  g2: abs(-3);\n",
        "  g3: abs(-3px);\n",
        "}\n",
    ));
}

#[test]
fn parity_unary_on_unresolved_calculation_errors() {
    // A unary `+`/`-` applied to a calculation that did not reduce to a number
    // has no defined operation and is rejected, while negating a calculation
    // that unwraps to a number still works.
    assert!(compile("a {b: +calc(var(--c))}\n", &Options::default()).is_err());
    assert!(compile("a {b: -(calc(var(--c)))}\n", &Options::default()).is_err());
    assert_parity("a {b: -calc(1px)}\n");
}

#[test]
fn parity_calc_unary_operator() {
    // Inside a calculation only a tight sign on a numeric literal is legal; a
    // whitespace-separated or parenthesised/variable unary `+`/`-` is rejected.
    for src in [
        "a {b: calc(+ 1px)}\n",
        "a {b: calc(- 1px)}\n",
        "a {b: calc(1px + - 2px)}\n",
        "a {b: calc(-(1px))}\n",
        "a {b: calc(+(1px))}\n",
        "a {b: calc(-(1 + 2))}\n",
    ] {
        assert!(
            compile(src, &Options::default()).is_err(),
            "expected calc unary operator to error: {src}"
        );
    }
    assert_parity(concat!(
        "a {\n",
        "  k1: calc(+1px);\n",
        "  k2: calc(-1px);\n",
        "  k3: calc(2 * +3);\n",
        "  k4: calc(2 + +3);\n",
        "  k5: calc(-var(--c));\n",
        "}\n",
    ));
}

#[test]
fn parity_clamp_calculation() {
    // A three-argument `clamp()` evaluates its operands as calculations: an
    // operation/`var()` argument keeps the call preserved, all-number arguments
    // clamp, and a complex-unit operand is rejected.
    assert!(compile("a {b: clamp(1px*1px, 2%*2%, 3px*3px)}\n", &Options::default()).is_err());
    assert!(compile("a {b: clamp(7 % 3, 2, 3)}\n", &Options::default()).is_err());
    assert!(compile("a {b: clamp(1s, 2px, 3px)}\n", &Options::default()).is_err());
    assert_parity(concat!(
        "a {\n",
        "  m1: clamp(1% + 1px, 2px, 3px);\n",
        "  m2: clamp(1px, 1% + 2px, 3px);\n",
        "  m3: clamp(1px, 2px, 1% + 3px);\n",
        "  r1: clamp(1px, 2px, 3px);\n",
        "  r2: clamp(1px, 5px, 3px);\n",
        "  p1: clamp(1px, 2vw, 3px);\n",
        "}\n",
    ));
}

#[test]
fn parity_extend_into_pseudo_arguments() {
    // Extending a target buried inside a `:not()`/`:is()` selector-pseudo
    // argument (dart-sass `_extendPseudo`): `:not()` with a single-complex arg
    // splits into multiple `:not()`s merged into the compound, while matchish
    // pseudos rewrite their argument list in place.
    assert_parity(".a {@extend .c}\n:not(.c) {x: y}\n");
    assert_parity(".a {@extend .c}\n.b {@extend .d}\n:not(.c):not(.d) {x: y}\n");
    assert_parity(".a {@extend .c}\n:is(.c) {x: y}\n");
    assert_parity(".a .b {@extend .c}\n:is(.c) {x: y}\n");
    // `:not` drops complex extension results when the original arg had none.
    assert_parity(".a .b {@extend .c}\n:not(.c) {x: y}\n");
    // Regression test for sass/dart-sass#191: nested `:not(:not(...))` isn't
    // expanded.
    assert_parity(":not(:not(.x)) {a: b}\n:not(.y) {@extend .x}\n");
}

#[test]
fn parity_extend_graph_fixpoint() {
    // An extender produced by one `@extend` is itself extended by another,
    // transitively — including targets inside pseudo arguments (the
    // extension-graph fixpoint). `:is(midstream)` extends `upstream`, and
    // `midstream` (inside that `:is`) is then extended by `downstream`.
    assert_parity(":is(midstream) {@extend upstream}\ndownstream {@extend midstream}\nupstream {a: b}\n");
    // The result of `:not(.c)` being extended is itself extendable: `:not(.b)`
    // (produced by extending `.c`) is a target extended by `.a`.
    assert_parity(".a {@extend :not(.b)}\n.b {@extend .c}\n:not(.c) {x: y}\n");
    // A self-extend must terminate: `.c` extends itself and a pseudo-target
    // `:not(.c)` extends its own contained class.
    assert_parity(".c, .a .b .c, .a .c .b {x: y; @extend .c}\n");
    assert_parity(":not(.c) {@extend .c}\n.c {x: y}\n");
}

#[test]
fn parity_custom_property_whitespace() {
    // A custom property emits its value verbatim after the colon: no space is
    // inserted, leading/trailing whitespace is preserved, an inline whitespace
    // run collapses to its last character, and a trailing newline becomes a
    // single space. An empty value emits `--x:;`.
    assert_parity(".a {\n  --empty:;\n  --interp:#{\"\"};\n  --lead: value;\n  --tight:value;\n  --trail: c ;\n  --collapse: 1  2\t\t3;\n  --func: foo(bar);\n}\n");
    assert_parity("a {\n  --nl: c\n;\n}\n");
    assert_parity("a {\n  --brace: c\n}\n");
}

#[test]
fn parity_selector_escape_canonicalization() {
    // dart-sass re-serializes selector identifier escapes: a leading digit
    // becomes a hex escape with a trailing space, a non-leading digit drops its
    // escape, and a numeric escape of a printable non-name char (`$`, `(`)
    // becomes the escaped character itself.
    assert_parity(".\\31u {a: b;}\n");
    assert_parity(".a\\31u {a: b;}\n");
    assert_parity(".a\\31 u {a: b;}\n");
    assert_parity(".u\\24 {a: b;}\n");
    assert_parity(".u\\$ {a: b;}\n");
    assert_parity(".u#{'\\\\28'} { a: b; }\n");
    assert_parity("\\64iv {a: b;}\n");
}

#[test]
fn parity_variable_scoping_semi_global() {
    // A rule-scoped assignment to a variable that exists only globally creates a
    // local instead of rewriting the global; a control-flow scope is
    // semi-global so it updates an existing enclosing variable but cannot create
    // a global from inside a rule.
    assert_parity("$x: root;\ndiv { $x: local; v: $x; }\nafter { x: $x; }\n");
    assert_parity("div {\n  $x: 10;\n  span { $x: 20; }\n  v: $x;\n}\n");
    assert_parity(
        "$x: root;\ndiv {\n  @for $i from 1 through 1 { $x: looped; }\n  v: $x;\n}\nafter { x: $x; }\n",
    );
    assert_parity("$x: 0;\n@for $i from 1 through 3 { $x: $x + 1; }\nafter { x: $x; }\n");
    assert_parity("div {\n  $y: 1;\n  @for $i from 1 through 3 { $y: $y + 5; y: $y; }\n  after: $y;\n}\n");
}

#[test]
fn parity_unquoted_string_newline() {
    // An unquoted string serializes a newline as a space, dropping a space that
    // immediately follows it; inside a quoted string the same characters are
    // re-escaped (`\a`) rather than collapsed.
    assert_parity(".a {\n  output: #{\"\\0_\\a_\\A\"};\n}\n");
    assert_parity(".a {\n  output: \"[#{\"\\0_\\a_\\A\"}]\";\n}\n");
    assert_parity("a { x: foo#{\"b\\a c\"}; }\n");
}

#[test]
fn parity_use_builtin_modules() {
    // `@use "sass:<mod>"` exposes the built-in module members under a namespace
    // (default, `as ns`, and `as *`), reusing the existing global builtin
    // implementations. Covers math functions/variables/`math.div`, string,
    // list, map, color (legacy), and meta members.
    assert_parity(
        "@use \"sass:math\";\na {\n  pi: math.$pi;\n  e: math.$e;\n  div: math.div(10, 3);\n  divu: math.div(10px, 2);\n  abs: math.abs(-5);\n  pct: math.percentage(0.2);\n  unit: math.unit(5px);\n  iu: math.is-unitless(5);\n  comp: math.compatible(1px, 1cm);\n}\n",
    );
    assert_parity(
        "@use \"sass:math\" as m;\n@use \"sass:string\";\n@use \"sass:list\" as *;\na {\n  s: string.length(\"abc\");\n  up: string.to-upper-case(\"ab\");\n  q: string.quote(foo);\n  sep: separator(1 2 3);\n  len: length(1 2 3);\n  nth: nth((a b c), 2);\n  round: m.round(1.6);\n}\n",
    );
    assert_parity(
        "@use \"sass:map\";\n@use \"sass:color\";\n@use \"sass:meta\";\n$m: (a: 1, b: 2);\na {\n  g: map.get($m, a);\n  k: meta.inspect(map.keys($m));\n  adj: color.adjust(#123456, $red: 10);\n  mix: color.mix(red, blue);\n  ie: color.ie-hex-str(#abcdef);\n  tof: meta.type-of(5px);\n}\n",
    );
}

#[test]
fn parity_colorspace_math() {
    // CSS Color 4 color-space-aware colors: `color()` predefined spaces,
    // lab/lch/oklab/oklch with real values (lightness as a percentage,
    // clamping, `deg` hues), and the `sass:color` modern members
    // `space`/`channel`/`to-space`/`is-legacy`/`is-missing`/`is-in-gamut`/
    // `same`. All byte-matched to `npx sass`.
    assert_parity(
        "@use \"sass:color\";\na {\n  c1: color(srgb 0.2 0.5 0.7);\n  c2: color(srgb 1.1 -0.2 0.3);\n  c3: color(srgb 10% 20% 30% / 0.5);\n  c4: oklch(0.1 0.2 3deg);\n  c5: oklch(1.1 0.2 3deg);\n  c6: lab(50 40 30);\n  c7: lch(50 40 270);\n  c8: oklab(0.5 0.1 -0.05);\n  c9: color(xyz 0.1 0.2 0.3);\n  c10: color(xyz-d50 0.1 0.2 0.3);\n  c11: color(display-p3-linear 0.5 0.6 0.7);\n}\n",
    );
    assert_parity(
        "@use \"sass:color\";\na {\n  o1: color.to-space(red, oklch);\n  o2: color.to-space(red, lab);\n  o3: color.to-space(red, display-p3);\n  o4: color.to-space(red, xyz);\n  o5: color.to-space(red, xyz-d50);\n  o6: color.to-space(red, prophoto-rgb);\n  o7: color.to-space(red, rec2020);\n  o8: color.to-space(red, lch);\n  o9: color.to-space(red, oklab);\n  o10: color.to-space(red, srgb-linear);\n  o11: color.to-space(red, hsl);\n}\n",
    );
    assert_parity(
        "@use \"sass:color\";\na {\n  s1: color.space(red);\n  s2: color.space(oklch(0.5 0.1 90deg));\n  ch1: color.channel(red, \"red\", $space: srgb);\n  ch2: color.channel(color.to-space(red, oklch), \"lightness\");\n  ch3: color.channel(oklch(0.5 0.1 90deg), \"hue\");\n  leg1: color.is-legacy(red);\n  leg2: color.is-legacy(oklch(0.5 0.1 90deg));\n  miss: color.is-missing(color(srgb none 0.5 0.7), \"red\");\n  gam1: color.is-in-gamut(color(srgb 1.5 0 0));\n  gam2: color.is-in-gamut(red);\n  same1: color.same(red, color.to-space(red, oklch));\n  same2: color.same(red, blue);\n}\n",
    );
    assert_parity(
        "@use \"sass:color\";\na {\n  n1: oklch(none 0.2 3deg);\n  n2: color(srgb none 0.5 0.7);\n  n3: hsl(none 50% 40%);\n  n4: hsl(120 none 40%);\n  n5: rgb(none 100 100);\n  n6: rgb(100 100 100 / none);\n  n7: hwb(none 30% 40%);\n}\n",
    );
}

#[test]
fn parity_color_mix_interpolation() {
    // color.mix() with a CSS Color 4 $method interpolates in the named space
    // with premultiplied alpha and the hue interpolation methods, returning a
    // result in the first color's space. Byte-matched to `npx sass`.
    assert_parity(
        "@use \"sass:color\";\na {\n  m1: color.mix(red, blue, 25%, oklch);\n  m2: color.mix(red, blue, $method: lab);\n  m3: color.mix(red, blue, 25%, srgb);\n  m4: color.mix(red, green, $method: xyz);\n  m5: color.mix(rgba(red, 0.5), blue, $method: srgb);\n  m6: color.mix(oklch(0.5 0.1 90), oklch(0.7 0.2 200), $method: oklch);\n}\n",
    );
    assert_parity(
        "@use \"sass:color\";\na {\n  s: color.mix(oklch(0.5 0.1 30), oklch(0.5 0.1 190), $method: oklch shorter hue);\n  l: color.mix(oklch(0.5 0.1 30), oklch(0.5 0.1 190), $method: oklch longer hue);\n  i: color.mix(oklch(0.5 0.1 30), oklch(0.5 0.1 190), $method: oklch increasing hue);\n  d: color.mix(oklch(0.5 0.1 30), oklch(0.5 0.1 190), $method: oklch decreasing hue);\n  w: color.mix(red, green, 20%, lch longer hue);\n  ci: color.mix(oklch(0.5 0.1 30), oklch(0.5 0.1 190), $method: oKlCh LONger HUE);\n}\n",
    );
    assert_parity(
        "@use \"sass:color\";\na {\n  pl: color.mix(lch(30% 0% 0deg), lch(50% 10% 120deg), $method: hsl);\n}\n",
    );
}

#[test]
fn parity_color_modify_in_space() {
    // color.change/adjust/scale with an explicit $space convert to that space,
    // apply the per-channel operation (with adjust clamping lightness/chroma,
    // scale moving toward the channel bound), and convert back to the color's
    // original space. Byte-matched to `npx sass`.
    assert_parity(
        "@use \"sass:color\";\na {\n  c1: color.change(red, $lightness: 50%, $space: oklch);\n  c2: color.change(color(srgb 0.2 0.5 0.7), $red: 0.9, $space: srgb);\n  c3: color.change(oklch(0.5 0.1 90), $lightness: 0.7);\n  c4: color.change(red, $lightness: 50%);\n}\n",
    );
    assert_parity(
        "@use \"sass:color\";\na {\n  a1: color.adjust(red, $lightness: 0.1, $space: oklch);\n  a2: color.adjust(oklch(0.8 0.1 90), $lightness: 0.5, $space: oklch);\n  a3: color.adjust(oklch(0.5 0.1 90), $chroma: -0.5, $space: oklch);\n  a4: color.adjust(lab(80 0 0), $lightness: 50, $space: lab);\n}\n",
    );
    assert_parity(
        "@use \"sass:color\";\na {\n  s1: color.scale(red, $lightness: 50%, $space: oklch);\n  s2: color.scale(oklch(0.5 0.1 90), $chroma: 50%, $space: oklch);\n  s3: color.scale(lab(50 40 30), $a: 50%, $space: lab);\n  s4: color.scale(color(srgb 0.5 0.5 0.5), $red: 50%, $space: srgb);\n}\n",
    );
}

#[test]
fn parity_color_invert_in_space() {
    // color.invert($color, $weight, $space) inverts each channel in the named
    // space (rgb/lightness toward max, lab/oklab a/b negate, hue +180, chroma
    // unchanged, hwb whiteness/blackness swap), mixing toward the original by
    // (1 - weight). Byte-matched to `npx sass`.
    assert_parity(
        "@use \"sass:color\";\na {\n  s: color.invert(color(srgb 0.2 0.5 0.8), $space: srgb);\n  lab: color.invert(lab(20% -30 110), $space: lab);\n  lch: color.invert(lch(20% 80 50deg), $space: lch);\n  hsl: color.invert(hsl(120 50% 40%), $space: hsl);\n  hwb: color.invert(hwb(120 30% 40%), $space: hwb);\n  w: color.invert(color(a98-rgb 0.1 0.4 0.8), 0%, $space: a98-rgb);\n  legacy: color.invert(#123456);\n  legacy_w: color.invert(#123456, 30%);\n}\n",
    );
}

#[test]
fn parity_map_module_gaps() {
    // `map.set`/`map.deep-merge`/`map.deep-remove` plus the nested key-path
    // overloads of `map.get`/`map.has-key`/`map.merge`/`map.remove`, all
    // serialized via `meta.inspect`. Also the empty-list separator of
    // `map.keys(())`/`map.values(())` (comma, not space).
    assert_parity(
        "@use \"sass:meta\";\n@use \"sass:map\";\na {\n  set: meta.inspect(map.set((c: (d: e)), c, f, g));\n  setn: meta.inspect(map.set($map: (c: d), $key: c, $value: e));\n  dm: meta.inspect(map.deep-merge((c: (d: e, f: g)), (c: (j: 1, f: 2))));\n  dr: meta.inspect(map.deep-remove((c: (d: e, f: g, h: i)), c, f));\n}\n",
    );
    assert_parity(
        "@use \"sass:meta\";\n@use \"sass:map\";\na {\n  get: map.get((c: (d: (e: f))), c, d, e);\n  getp: meta.inspect(map.get((c: (d: (e: f))), c, d));\n  has: map.has-key((c: (d: (e: f))), c, d, e);\n  hasn: map.has-key((c: (d: (e: f))), c, d, g);\n  merge: meta.inspect(map.merge((c: 1), c, d, (e: f)));\n  rem: meta.inspect(map.remove($map: (c: d, e: f), $key: c));\n}\n",
    );
    assert_parity(
        "@use \"sass:list\";\n@use \"sass:map\";\na {\n  sep: list.separator(map.keys(()));\n  sepv: list.separator(map.values(()));\n}\n",
    );
}

#[test]
fn parity_string_split_and_inspect_brackets() {
    // `string.split` returns a bracketed comma list preserving the input's
    // quotedness, with an optional split `$limit`; `meta.inspect` renders
    // bracketed lists and map keys/values with the right parenthesization.
    assert_parity(
        "@use \"sass:string\";\na {\n  s: string.split(\"a, b, c\", \", \");\n  l: string.split(\"a, b, c, d\", \", \", 2);\n  e: string.split(\"Helvetica\", \"\");\n  u: string.split(abc, \"\");\n  nf: string.split(\"a, b, c\", \"&\");\n}\n",
    );
    assert_parity(
        "@use \"sass:meta\";\na {\n  a: meta.inspect([1, 2, 3]);\n  b: meta.inspect([]);\n  c: meta.inspect([[1, 2] [3, 4]]);\n  d: meta.inspect(((1, 2): 3, (4, 5): 6));\n  e: meta.inspect((1: 2 3, 4: 5 6));\n}\n",
    );
    // A single-element list keeps its separator's trailing token: `(1,)` for a
    // comma list and `(1/)` for a slash list; a space list is just `1`.
    assert_parity(
        "@use \"sass:list\";\n@use \"sass:meta\";\na {\n  c: meta.inspect((1,));\n  s: meta.inspect(list.append((), 1, slash));\n  sp: meta.inspect(list.append((), 1, space));\n  m: meta.inspect(list.join((1,), (2,), slash));\n}\n",
    );
    // A map key/value that is an unbracketed comma list is parenthesized for any
    // length: an empty comma list (e.g. an empty arglist) becomes `(())`, while
    // an empty undecided list `()` stays bare.
    assert_parity(
        "@use \"sass:list\";\n@use \"sass:meta\";\n@function args($a...) { @return $a; }\na {\n  ea: meta.inspect((p: args()));\n  el: meta.inspect((p: ()));\n  ec: meta.inspect((p: list.join((), (), comma)));\n}\n",
    );
}

#[test]
fn parity_meta_exists_predicates() {
    // The `sass:meta` existence predicates resolve against the evaluator's
    // scopes / definitions: variable-exists / global-variable-exists,
    // mixin-exists, function-exists (user and built-in), and content-exists.
    assert_parity(
        "@use \"sass:meta\";\n$g: 1;\n@mixin gm() {}\n@function gf() { @return 1; }\na {\n  $l: 2;\n  v_local: meta.variable-exists(l);\n  v_global: meta.variable-exists(g);\n  v_none: meta.variable-exists(nope);\n  gv_yes: meta.global-variable-exists(g);\n  gv_no: meta.global-variable-exists(l);\n  mx: meta.mixin-exists(gm);\n  mx_no: meta.mixin-exists(nope);\n  fn_user: meta.function-exists(gf);\n  fn_builtin: meta.function-exists(rgb);\n  fn_no: meta.function-exists(nope);\n}\n",
    );
    assert_parity(
        "@use \"sass:meta\";\n@mixin outer() {\n  @if meta.content-exists() { @content; }\n  @else { had: none; }\n}\na { @include outer() { got: yes; } }\nb { @include outer(); }\n",
    );
}

#[test]
fn parity_meta_first_class_functions() {
    // `meta.get-function` returns a first-class reference (built-in, user, or
    // plain-CSS), `meta.call` invokes it (positional / named / splat), and the
    // reference inspects as `get-function("name")`, has type `function`, and
    // compares by built-in name / user-definition identity.
    assert_parity(
        "@use \"sass:meta\";\n@function add-two($v) { @return $v + 2; }\n$u: meta.get-function(add-two);\n$b: meta.get-function(round);\n$c: meta.get-function(round, $css: true);\na {\n  user: meta.call($u, 10);\n  builtin: meta.call($b, 0.6);\n  css: meta.call($c, 0.6);\n  rgb_pos: meta.call(meta.get-function(\"rgb\"), 1, 2, 3);\n  rgb_named: meta.call(meta.get-function(\"rgb\"), $blue: 1, $green: 2, $red: 3);\n  insp: meta.inspect($b);\n  tof: meta.type-of($b);\n}\n",
    );
    assert_parity(
        "@use \"sass:meta\";\n@function ud() { @return null; }\na {\n  eq_builtin: meta.get-function(lighten) == meta.get-function(lighten);\n  ne_builtin: meta.get-function(lighten) == meta.get-function(darken);\n  eq_user: meta.get-function(ud) == meta.get-function(ud);\n}\n",
    );
}

#[test]
fn parity_list_join_append_brackets_and_maps() {
    // `list.join` inherits list1's bracketing (overridable via `$bracketed`)
    // and `list.append` keeps the source list's brackets; both treat a map as a
    // comma list of `key value` entries.
    assert_parity(
        "@use \"sass:list\";\na {\n  jb_both: list.join([c d], [e f]);\n  jb_first: list.join([c d], e f);\n  jb_second: list.join(c d, [e f]);\n  jb_force_t: list.join(c, d, $bracketed: true);\n  jb_force_f: list.join([c], [d], $bracketed: false);\n  jb_pos: list.join(c, d, comma, true);\n  jmap: list.join((c: d, e: f), (g: h));\n  ap_b: list.append([], 1);\n  ap_map: list.append((c: d, e: f), g);\n}\n",
    );
}

#[test]
fn parity_math_numeric_module_members() {
    // `math.clamp` / `math.min` / `math.max` / `math.round` are the numeric
    // forms (unit-aware, error on non-numbers / incompatible units), distinct
    // from the global CSS-calc functions; plus `math.log($x, null)` (natural
    // log) and the `math.$min-number` subnormal constant.
    assert_parity(
        "@use \"sass:math\";\na {\n  cl_num: math.clamp(0, 1, 2);\n  cl_max: math.clamp(0, 2, 1);\n  cl_inv: math.clamp(1, 2, 0);\n  cl_unit: math.clamp(180deg, 1turn, 360deg);\n  mn: math.min(3px, 1px, 2px);\n  mn_conv: math.min(1cm, 5mm);\n  mx: math.max(1, 2, 3);\n  rnd: math.round(1.6);\n  ln: math.log(2, null);\n}\n",
    );
    assert_parity("@use \"sass:math\";\na { b: math.$min-number * 1e300 * 1e39; }\n");
}

/// Compile `files["input.scss"]` with the on-disk module system (writing every
/// entry to a temp dir, resolving `@use`/`@forward` through `FsImporter`) and
/// assert byte-parity with dart-sass run on the same directory.
fn assert_module_parity(files: &[(&str, &str)]) {
    if !enabled() {
        return;
    }
    use std::sync::atomic::{AtomicU64, Ordering};
    static SEQ: AtomicU64 = AtomicU64::new(0);
    let id = SEQ.fetch_add(1, Ordering::Relaxed);
    let dir = std::env::temp_dir().join(format!("sasso-modtest-{}-{}", std::process::id(), id));
    let _ = std::fs::remove_dir_all(&dir);
    std::fs::create_dir_all(&dir).expect("create temp dir");
    for (name, content) in files {
        let path = dir.join(name);
        if let Some(parent) = path.parent() {
            std::fs::create_dir_all(parent).expect("create subdir");
        }
        std::fs::write(&path, content).expect("write module file");
    }
    let input = std::fs::read_to_string(dir.join("input.scss")).expect("read input");
    let importer = FsImporter::new(vec![dir.clone()]);
    let ours = compile(&input, &Options::default().with_importer(&importer)).expect("our compile failed");

    let bin = std::env::var("SASS_BIN").unwrap_or_else(|_| "npx".to_string());
    let mut cmd = if bin == "npx" {
        let mut c = Command::new("npx");
        c.args(["--yes", "sass", "--no-source-map", "input.scss"]);
        c
    } else {
        let mut c = Command::new(bin);
        c.args(["--no-source-map", "input.scss"]);
        c
    };
    let out = cmd
        .current_dir(&dir)
        .stdout(Stdio::piped())
        .stderr(Stdio::null())
        .output()
        .expect("run dart-sass");
    let _ = std::fs::remove_dir_all(&dir);
    if !out.status.success() {
        eprintln!("skipping module parity case: dart-sass errored");
        return;
    }
    let theirs = strip_cli_newline(String::from_utf8(out.stdout).expect("utf8"));
    assert_eq!(ours, theirs, "\n--- input ---\n{input}\n");
}

#[test]
fn parity_plain_css_module() {
    // A `.css` file loaded via `@use` is parsed in plain-CSS mode: nesting is
    // preserved (not flattened), `&` stays literal, and declaration values are
    // emitted verbatim (no SassScript). Sass functions like `rgb`/`grayscale`
    // are kept as CSS, not evaluated.
    assert_module_parity(&[
        ("input.scss", "@use \"plain\";\n"),
        (
            "plain.css",
            "a {\n  b {c: d}\n  &.e {f: g}\n  h: rgb(10, 20, 30);\n}\ni, j {k {l: m}}\n",
        ),
    ]);
    // A plain CSS file never inlines `@import`; every form is emitted verbatim,
    // including an `@import` nested inside a rule.
    assert_module_parity(&[
        ("input.scss", "@use \"plain\";\n"),
        (
            "plain.css",
            "@import \"whatever\";\n@import url(whatever);\n@import url(\"whatever\");\na {b: c}\nd {\n  @import \"foo\";\n}\n",
        ),
    ]);
}

#[test]
fn parity_use_user_module() {
    // `@use "file"` loads a user partial once, emits its CSS, and exposes its
    // variables, functions, and mixins under the default namespace.
    assert_module_parity(&[
        (
            "_other.scss",
            "$color: red;\n@function double($x) { @return $x * 2; }\n@mixin box { border: 1px solid; }\n.from-other { content: \"o\"; }\n",
        ),
        (
            "input.scss",
            "@use \"other\";\n.a {\n  color: other.$color;\n  width: other.double(5px);\n  @include other.box;\n}\n",
        ),
    ]);
}

#[test]
fn parity_use_namespace_and_star() {
    // `as ns` overrides the namespace; `as *` exposes members unprefixed.
    assert_module_parity(&[
        ("_lib.scss", "$v: 7;\n@function f($x) { @return $x + 1; }\n"),
        (
            "input.scss",
            "@use \"lib\" as l;\n@use \"lib\" as *;\n.a { x: l.$v; y: f(9); z: $v; }\n",
        ),
    ]);
}

#[test]
fn parity_forward_reexport() {
    // `@forward` re-exports another module's members; `as prefix-*` prefixes
    // them and `show`/`hide` filter them.
    assert_module_parity(&[
        (
            "_lib.scss",
            "$color: red;\n@function double($x) { @return $x * 2; }\n@mixin m { x: 1; }\n",
        ),
        ("_mid.scss", "@forward \"lib\" as lib-*;\n"),
        (
            "input.scss",
            "@use \"mid\";\n.a { c: mid.$lib-color; w: mid.lib-double(3); @include mid.lib-m; }\n",
        ),
    ]);
}

#[test]
fn parity_use_and_forward_with_config() {
    // `with (...)` overrides a module's `!default` variables; a `@forward ...
    // with` default yields to a downstream `@use ... with` override.
    assert_module_parity(&[
        (
            "_conf.scss",
            "$a: 1 !default;\n$b: 2 !default;\n.c { x: $a; y: $b; }\n",
        ),
        ("_midw.scss", "@forward \"conf\" with ($a: 100 !default);\n"),
        (
            "input.scss",
            "@use \"midw\" with ($a: 999, $b: 200);\n.r { v: midw.$a; w: midw.$b; }\n",
        ),
    ]);
}

// ---------------------------------------------------------------------------
// Indented (`.sass`) syntax parity.
// ---------------------------------------------------------------------------

/// Compile `sass` (indented syntax) with dart-sass via `--stdin --indented`.
fn dart_sass_indented(sass: &str) -> Option<String> {
    let bin = std::env::var("SASS_BIN").unwrap_or_else(|_| "npx".to_string());
    let mut cmd = if bin == "npx" {
        let mut c = Command::new("npx");
        c.args(["--yes", "sass", "--no-source-map", "--stdin", "--indented"]);
        c
    } else {
        let mut c = Command::new(bin);
        c.args(["--no-source-map", "--stdin", "--indented"]);
        c
    };
    let mut child = cmd
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::null())
        .spawn()
        .ok()?;
    child.stdin.take()?.write_all(sass.as_bytes()).ok()?;
    let out = child.wait_with_output().ok()?;
    if !out.status.success() {
        return None;
    }
    Some(strip_cli_newline(String::from_utf8(out.stdout).ok()?))
}

/// Byte-verify our indented-syntax output against dart-sass.
fn assert_sass_parity(sass: &str) {
    if !enabled() {
        return;
    }
    let ours = compile(sass, &Options::default().with_syntax(sasso::Syntax::Sass))
        .expect("our indented compile failed");
    match dart_sass_indented(sass) {
        Some(theirs) => assert_eq!(ours, theirs, "\n--- sass ---\n{sass}\n"),
        None => eprintln!("skipping indented parity case: dart-sass unavailable"),
    }
}

#[test]
fn parity_sass_basic_rule_and_decls() {
    assert_sass_parity("a\n  b: c\n  d: e\n");
    assert_sass_parity("$x: 1\n\ne\n  f: $x + 2\n");
}

#[test]
fn parity_sass_nesting_and_parent() {
    assert_sass_parity("a\n  color: red\n  &:hover\n    color: blue\n");
}

#[test]
fn parity_sass_control_flow() {
    assert_sass_parity("@for $i from 1 through 3\n  .c-#{$i}\n    width: $i * 10px\n");
    assert_sass_parity("@each $c in red, green\n  .#{$c}\n    color: $c\n");
}

#[test]
fn parity_sass_callables() {
    assert_sass_parity("@function double($x)\n  @return $x * 2\n\na\n  width: double(5px)\n");
    assert_sass_parity("@mixin box($w)\n  width: $w\n  height: $w\n\na\n  @include box(4px)\n");
}

#[test]
fn parity_sass_shorthand_mixin() {
    // `=name` defines a mixin, `+name` includes it.
    assert_sass_parity("=box($w)\n  width: $w\n\na\n  +box(4px)\n");
}

#[test]
fn parity_sass_multiline_continuation() {
    assert_sass_parity("@function a($b,\n            $c)\n  @return $b + $c\n\nd\n  e: a(1, 2)\n");
}

#[test]
fn parity_sass_comments() {
    assert_sass_parity("// silent\na\n  b: c // trailing\n");
    assert_sass_parity("/* loud */\na\n  b: c\n");
}

#[test]
fn parity_sass_custom_property() {
    assert_sass_parity("a\n  --b: c d\n");
}

#[test]
fn parity_sass_imports_scss_partial() {
    // A `.sass` entrypoint importing a `.scss` partial: each file parses with
    // the front-end matching its extension.
    if !enabled() {
        return;
    }
    use std::sync::atomic::{AtomicU64, Ordering};
    static SEQ: AtomicU64 = AtomicU64::new(0);
    let id = SEQ.fetch_add(1, Ordering::Relaxed);
    let dir = std::env::temp_dir().join(format!("sasso-xsyntax-{}-{}", std::process::id(), id));
    let _ = std::fs::remove_dir_all(&dir);
    std::fs::create_dir_all(&dir).expect("create temp dir");
    std::fs::write(dir.join("_pal.scss"), "$c: red;\n.a { color: $c; }\n").expect("write");
    let input = "@import \"pal\"\nb\n  x: $c\n";
    std::fs::write(dir.join("input.sass"), input).expect("write");
    let importer = FsImporter::new(vec![dir.clone()]);
    let ours = compile(
        input,
        &Options::default()
            .with_syntax(sasso::Syntax::Sass)
            .with_importer(&importer),
    )
    .expect("our cross-syntax compile failed");
    let bin = std::env::var("SASS_BIN").unwrap_or_else(|_| "npx".to_string());
    let mut cmd = if bin == "npx" {
        let mut c = Command::new("npx");
        c.args(["--yes", "sass", "--no-source-map", "input.sass"]);
        c
    } else {
        let mut c = Command::new(bin);
        c.args(["--no-source-map", "input.sass"]);
        c
    };
    let out = cmd
        .current_dir(&dir)
        .stdout(Stdio::piped())
        .stderr(Stdio::null())
        .output()
        .expect("run dart-sass");
    let _ = std::fs::remove_dir_all(&dir);
    if !out.status.success() {
        eprintln!("skipping cross-syntax parity case: dart-sass errored");
        return;
    }
    let theirs = strip_cli_newline(String::from_utf8(out.stdout).expect("utf8"));
    assert_eq!(ours, theirs, "\n--- input.sass ---\n{input}\n");
}

#[test]
fn parity_selector_separators_in_groups() {
    // Regression coverage for the borrowed-slice rewrite of `split_commas` and
    // `tokenize_complex` (perf: drop per-part/per-token String allocation). A
    // comma or `>`/`+`/`~` that lives inside a quoted string, an attribute
    // selector, or a pseudo `(...)` argument must NOT be treated as a top-level
    // separator — only genuine depth-0 ones are.
    assert_parity("a[title=\"x, y\"] { color: red; }\n");
    assert_parity("a[data-op=\"a > b\"] { color: red; }\n");
    assert_parity(":is(.a > .b, .c + .d) .e { color: red; }\n");
    assert_parity(".x:not(.a ~ .b) { color: red; }\n");
    assert_parity(":where(.a, .b) .c { color: red; }\n");
    // Genuine top-level list + combinators, with nesting: exercises
    // split_commas on the parent list and tokenize_complex on the child.
    assert_parity(".a, .b {\n  > .c + .d ~ .e { color: red; }\n}\n");
    assert_parity(".a, .b {\n  .c, .d { color: red; }\n}\n");
}

#[test]
fn parity_color_modify_unit_leniency() {
    // dart-sass does not hard-error on a non-`%` unit for the legacy hsl
    // `lightness`/`saturation` channels of `color.adjust`/`color.change`, nor on
    // a unit for `$alpha` (it warns to stderr and uses the value); legacy hwb
    // `whiteness`/`blackness` still strictly require `%`.
    assert_parity(concat!(
        "@use \"sass:color\";\n",
        "a {\n",
        "  b: color.adjust(red, $lightness: 10in);\n",
        "  c: color.adjust(red, $saturation: -10in);\n",
        "  d: color.adjust(red, $alpha: -0.3%);\n",
        "  e: color.adjust(red, $alpha: -0.3px);\n",
        "  f: color.change(red, $lightness: 50in);\n",
        "}\n",
    ));
}

#[test]
fn parity_color_alpha_ms_filter_overload() {
    // `color.alpha()` with one or more `<identifier>=value` arguments is the
    // proprietary Microsoft filter overload, passed through verbatim (dart-sass
    // warns to stderr) rather than enforcing the one-argument color signature.
    assert_parity(concat!(
        "@use \"sass:color\";\n",
        "a {\n",
        "  b: color.alpha(c=d);\n",
        "  c: color.alpha(c=d, e=f, g=h);\n",
        "}\n",
    ));
}

/// Compile `scss` with dart-sass, returning its first `Error:` line (the
/// message), or `None` if dart-sass succeeded or is unavailable.
fn dart_sass_error(scss: &str) -> Option<String> {
    let bin = std::env::var("SASS_BIN").unwrap_or_else(|_| "npx".to_string());
    let mut cmd = if bin == "npx" {
        let mut c = Command::new("npx");
        c.args(["--yes", "sass", "--no-source-map", "--stdin"]);
        c
    } else {
        let mut c = Command::new(bin);
        c.args(["--no-source-map", "--stdin"]);
        c
    };
    let mut child = cmd
        .stdin(Stdio::piped())
        .stdout(Stdio::null())
        .stderr(Stdio::piped())
        .spawn()
        .ok()?;
    child.stdin.take()?.write_all(scss.as_bytes()).ok()?;
    let out = child.wait_with_output().ok()?;
    if out.status.success() {
        return None;
    }
    let stderr = String::from_utf8(out.stderr).ok()?;
    stderr
        .lines()
        .find(|l| l.starts_with("Error: "))
        .map(|l| l.trim_start_matches("Error: ").to_string())
}

#[test]
fn parity_color_modify_missing_channel_errors() {
    // `adjust`/`scale`/`invert` reject a missing (`none`) channel — and, after a
    // conversion to an explicit `$space`, a powerless one — with dart-sass's
    // exact "modifying missing channels" message.
    if !enabled() {
        return;
    }
    let cases = [
        "@use \"sass:color\";\na {b: color.adjust(rgb(none 0 0), $red: 10)}\n",
        "@use \"sass:color\";\na {b: color.adjust(rgb(0 0 0 / none), $alpha: 0.1)}\n",
        "@use \"sass:color\";\na {b: color.adjust(grey, $hue: 10deg, $space: hsl)}\n",
        "@use \"sass:color\";\na {b: color.scale(rgb(none 0 0), $red: 10%)}\n",
        "@use \"sass:color\";\na {b: color.invert(grey, $space: hsl)}\n",
        // A non-number `adjust` alpha (including `none`) is a type error.
        "@use \"sass:color\";\na {b: color.adjust(red, $alpha: c)}\n",
        "@use \"sass:color\";\na {b: color.adjust(red, $alpha: none)}\n",
    ];
    for scss in cases {
        let ours = compile(scss, &Options::default()).err().map(|e| e.to_string());
        match dart_sass_error(scss) {
            Some(theirs) => {
                let ours = ours.unwrap_or_else(|| panic!("expected our compile to error:\n{scss}"));
                // Strip our leading `Error: ` and trailing `(line:col)` so the
                // core message can be compared against dart-sass's.
                let msg = ours.trim_start_matches("Error: ");
                assert!(
                    msg.starts_with(&theirs),
                    "\n--- scss ---\n{scss}\n--- ours ---\n{ours}\n--- dart ---\n{theirs}\n"
                );
            }
            None => eprintln!("skipping missing-channel parity case: dart-sass unavailable"),
        }
    }
}

#[test]
fn parity_color_adjust_hue_non_legacy_error() {
    // The legacy `adjust-hue()` getter only supports legacy colors; a non-legacy
    // color (e.g. lch) errors with dart-sass's exact message.
    if !enabled() {
        return;
    }
    let scss = "a {b: adjust-hue(lch(0% 0 0deg), 10deg)}\n";
    let ours = compile(scss, &Options::default()).err().map(|e| e.to_string());
    match dart_sass_error(scss) {
        Some(theirs) => {
            let ours = ours.unwrap_or_else(|| panic!("expected our compile to error:\n{scss}"));
            let msg = ours.trim_start_matches("Error: ");
            assert!(
                msg.starts_with(&theirs),
                "\n--- scss ---\n{scss}\n--- ours ---\n{ours}\n--- dart ---\n{theirs}\n"
            );
        }
        None => eprintln!("skipping adjust-hue non-legacy parity case: dart-sass unavailable"),
    }
}

#[test]
fn parity_selector_extend_multiple_extendees() {
    // selector.extend()'s extendee may be a list of compound selectors (as a
    // string or a Sass list), each applied as a separate extension target and
    // resolved to a fixpoint so a selector matching several targets collapses.
    assert_parity("@use \"sass:selector\";\na { b: selector.extend(\"c.d\", \"c, .d\", \".e\"); }\n");
    assert_parity("@use \"sass:selector\";\na { b: selector.extend(\"c.d.e.f\", \"c.d, .e.f\", \".g\"); }\n");
    assert_parity("@use \"sass:selector\";\na { b: selector.extend(\"c.d\", (c, \".d\"), \".e\"); }\n");
}

#[test]
fn parity_selector_arg_coercion_lists() {
    // Selector arguments may be a Sass list (comma list of strings, or a comma
    // list whose items are space lists of strings), coerced to a selector the
    // same way dart-sass does for selector.parse/nest/is-superselector.
    assert_parity("@use \"sass:selector\";\na { b: selector.parse((c d, e f)); }\n");
    assert_parity("@use \"sass:selector\";\na { b: selector.parse((c \"d\", e \"f\")); }\n");
    assert_parity("@use \"sass:selector\";\na { b: selector.nest((c, d e), \"f\"); }\n");
    assert_parity("@use \"sass:selector\";\na { b: selector.is-superselector((c, d e), (c, d e)); }\n");
}

#[test]
fn parity_selector_append_type_suffix() {
    // selector.append accepts a plain type selector as the suffix's leading
    // simple (`.c` + `d` -> `.cd`); a universal or namespaced type is rejected
    // (tested for errors via the spec suite, not here).
    assert_parity("@use \"sass:selector\";\na { b: selector.append(\".c\", \"d\"); }\n");
    assert_parity("@use \"sass:selector\";\na { b: selector.append(\"d\", \".c\"); }\n");
}

#[test]
fn parity_first_class_mixins_apply() {
    // `meta.get-mixin` captures a mixin reference; `@include meta.apply(...)`
    // invokes it with forwarded arguments and an optional `@content` block.
    assert_parity(concat!(
        "@use \"sass:meta\";\n",
        "@mixin add-two($v) { b: $v + 2; }\n",
        "$ref: meta.get-mixin(add-two);\n",
        "a { @include meta.apply($ref, 10); }\n",
        "@mixin wrap { c { @content; } }\n",
        "d { @include meta.apply(meta.get-mixin(wrap)) { e: f; } }\n",
        "g { h: meta.inspect(meta.get-mixin(add-two)); ",
        "i: meta.get-mixin(add-two) == meta.get-mixin(add-two); }\n",
    ));
}

#[test]
fn parity_list_fn_arg_validation() {
    // Fixed-arity list builtins reject extra positional arguments and unknown
    // named arguments, matching dart-sass (which rejects them with the same
    // "Only N argument(s) allowed…" / "No parameter named $X." errors). Both
    // compilers must reject every case below; valid named calls still succeed.
    for src in [
        "@use \"sass:list\";\na {b: list.length((), 1)}\n",
        "@use \"sass:list\";\na {b: list.nth(1 2, 1, 3)}\n",
        "@use \"sass:list\";\na {b: list.index(1 2, 1, 3)}\n",
        "@use \"sass:list\";\na {b: list.separator(1 2, 1)}\n",
        "@use \"sass:list\";\na {b: list.is-bracketed(1 2, 1)}\n",
        "@use \"sass:list\";\na {b: list.set-nth(c d, 1, 2, 3)}\n",
        "@use \"sass:list\";\na {b: list.join(c, d, $invalid: true)}\n",
        "@use \"sass:list\";\na {b: list.append(c, d, e, f)}\n",
    ] {
        assert!(
            compile(src, &Options::default()).is_err(),
            "expected error for {src}"
        );
        if enabled() {
            assert!(dart_sass(src).is_none(), "dart-sass unexpectedly accepted {src}");
        }
    }
    // A valid named-argument call still compiles in both implementations.
    assert_parity("@use \"sass:list\";\na {b: list.join((1), (2), $separator: comma)}\n");
}

#[test]
fn parity_list_separator_and_bracket_preservation() {
    // `set-nth` keeps the source list's bracketing, and `join`/`append` treat a
    // single-element (or empty) space list as having an *undecided* separator,
    // so it defers to the other operand's separator — matching dart-sass.
    assert_parity("@use \"sass:list\";\na {b: list.set-nth([c, d], 2, e)}\n");
    assert_parity("@use \"sass:list\";\na {b: list.join([1], (2, 3, 4))}\n");
    assert_parity("@use \"sass:list\";\na {b: list.join((1), (2 3 4))}\n");
    assert_parity("@use \"sass:list\";\na {b: list.append((1), 2)}\n");
}

#[test]
fn parity_color_hwb_out_of_range_negative_saturation() {
    // An out-of-range hwb color converts to hsl with a NEGATIVE raw saturation;
    // dart-sass normalizes it by flipping the hue 180 degrees and taking |sat|
    // (e.g. hwb(20deg 200% -125%) -> hsl(200, 11.11%, 212.5%), not hsl(20, -11.11%, …)).
    assert_parity("a { b: hwb(20deg 200% -125%); }\n");
    assert_parity("@use \"sass:color\";\na { b: color.to-space(hwb(20deg 200% -125%), hsl); }\n");
    // Normal hwb / hsl (non-negative saturation) must be unaffected.
    assert_parity("a { b: hwb(20deg 30% 40%); }\n");
    assert_parity("a { b: hsl(20, 50%, 50%); }\n");
}

#[test]
fn parity_list_slash_and_slash_color_channels() {
    // list.slash builds a slash-separated list (1 / 2 / 3), with the inspect
    // parenthesization rules (a comma sub-list gets parens, a space one doesn't).
    assert_parity("@use \"sass:list\";\na { b: list.slash(1, 2, 3); }\n");
    assert_parity("@use \"sass:list\";\na { b: list.slash(1 2, 3 4); }\n");
    assert_parity(
        "@use \"sass:list\";\n@use \"sass:meta\";\na { b: meta.inspect(list.slash((1, 2), 3)); }\n",
    );
    // A slash list as color channels is the `<channels> / <alpha>` form: exactly
    // two elements, the first an unbracketed space list.
    assert_parity("@use \"sass:list\";\na { b: lab(list.slash(1% 2 3, 0.5)); }\n");
    assert_parity("@use \"sass:list\";\na { b: rgb(list.slash(1 2 3, 0.5)); }\n");
}

#[test]
fn parity_color_module_hwb_comma_and_validation() {
    // `sass:color` exposes a comma-form `color.hwb($hue, $whiteness, $blackness,
    // $alpha: 1)` (the global `hwb()` is modern-only). It accepts the comma and
    // the single space-list forms; the gamut-normalized whiteness/blackness are
    // reported by channel introspection while serialization keeps an exact sRGB
    // round-trip (so an out-of-gamut achromatic hwb stays hue 0, not flipped
    // 180 degrees by the negative-saturation path).
    assert_parity("@use \"sass:color\";\na {b: color.hwb(0, 50%, 0%)}\n");
    assert_parity("@use \"sass:color\";\na {b: color.hwb(0 50% 0%)}\n");
    assert_parity("@use \"sass:color\";\na {b: color.hwb(0, 50%, 0%, 0.5)}\n");
    assert_parity("@use \"sass:color\";\na {b: color.hwb(0, 150%, 0%)}\n");
    assert_parity("a {b: hwb(0 80% 50%)}\n");
    assert_parity("a {b: hwb(120 80% 50%)}\n");
    assert_parity(
        "@use \"sass:color\";\na {b: color.channel(color.hwb(0, 150%, 0%), \"whiteness\", $space: hwb)}\n",
    );

    if !enabled() {
        return;
    }
    // Both color.hwb and the modern global hwb reject unitless/wrong-unit
    // whiteness/blackness, bracketed/comma single lists, and (for the module
    // form) more than four arguments — with dart-sass's exact messages.
    for scss in [
        "@use \"sass:color\";\na {b: color.hwb(0, 30, 40%, 0.5)}\n",
        "@use \"sass:color\";\na {b: color.hwb(0, 30%, 40px, 0.5)}\n",
        "a {b: hwb(0 30 40%)}\n",
        "a {b: hwb(0 30% 40)}\n",
        "@use \"sass:color\";\na {b: color.hwb([0 30% 40%])}\n",
        "@use \"sass:color\";\na {b: color.hwb((0, 30%, 40%))}\n",
        "@use \"sass:color\";\na {b: color.hwb(0, 30%, 40%, 0.5, 0)}\n",
    ] {
        let ours = compile(scss, &Options::default()).err().map(|e| e.to_string());
        match dart_sass_error(scss) {
            Some(theirs) => {
                let ours = ours.unwrap_or_else(|| panic!("expected our compile to error:\n{scss}"));
                let msg = ours.trim_start_matches("Error: ");
                assert!(
                    msg.starts_with(&theirs),
                    "\n--- scss ---\n{scss}\n--- ours ---\n{ours}\n--- dart ---\n{theirs}\n"
                );
            }
            None => eprintln!("skipping hwb error parity case: dart-sass unavailable"),
        }
    }
}

#[test]
fn parity_color_convert_achromatic_to_hsl_hwb() {
    // Converting a truly achromatic color (gray/white from a wide-gamut space)
    // to hsl/hwb must yield dart-sass's canonical hue 0 / saturation 0 — the
    // XYZ round-trip leaves floating-point chroma residue that would otherwise
    // read as a spurious hue (180/300deg) and, near l=0/1, an unstable
    // saturation. A truly chromatic (or explicitly-built achromatic) color is
    // unaffected.
    assert_parity("@use \"sass:color\";\na {b: color.to-space(color(a98-rgb 1 1 1), hsl)}\n");
    assert_parity("@use \"sass:color\";\na {b: color.to-space(color(a98-rgb 0.5 0.5 0.5), hsl)}\n");
    assert_parity("@use \"sass:color\";\na {b: color.to-space(color(a98-rgb 0.5 0.5 0.5), hwb)}\n");
    assert_parity("@use \"sass:color\";\na {b: color.to-space(color(prophoto-rgb 0.5 0.5 0.5), hsl)}\n");
    assert_parity("@use \"sass:color\";\na {b: color.to-space(color(rec2020 0.3 0.3 0.3), hwb)}\n");
    // Chromatic conversions and explicitly-built achromatic hsl keep their hue.
    assert_parity("@use \"sass:color\";\na {b: color.to-space(color(a98-rgb 0.8 0.2 0.4), hsl)}\n");
    assert_parity("@use \"sass:color\";\na {b: color.channel(hsl(300, 0%, 50%), \"hue\")}\n");
    assert_parity("a {b: hsl(300, 0%, 50%)}\n");
}

#[test]
fn parity_color_convert_missing_channel_carry() {
    // CSS Color 4 carries a missing component into the analogous channel of the
    // target space; the xyz channels are analogous to rgb (Reds: r/x, Greens:
    // g/y, Blues: b/z), so a missing rgb channel survives a round-trip to xyz.
    assert_parity("@use \"sass:color\";\na {b: color.to-space(color(a98-rgb none 0.5 0.5), xyz)}\n");
    assert_parity("@use \"sass:color\";\na {b: color.to-space(color(srgb 0.5 0.5 none), xyz)}\n");
    assert_parity("@use \"sass:color\";\na {b: color.to-space(color(xyz none 0.2 0.3), a98-rgb)}\n");
    assert_parity("@use \"sass:color\";\na {b: color.to-space(color(xyz 0.1 0.2 none), display-p3)}\n");
    // a/b are not analogous to xyz/rgb; Lightness carries across lab/oklab.
    assert_parity("@use \"sass:color\";\na {b: color.to-space(lab(50% none 30), xyz)}\n");
    assert_parity("@use \"sass:color\";\na {b: color.to-space(lab(none 20 30), oklab)}\n");
    // color.same converts none -> 0 (NO carry): two colors that realize
    // differently are not the same even if both carry a missing component.
    assert_parity(
        "@use \"sass:color\";\na {b: color.same(color(rec2020 0.5 none 0.2), color(xyz 0.174805932224126 none 0.058901333881161))}\n",
    );
    assert_parity(
        "@use \"sass:color\";\na {b: color.same(color(display-p3 0.1 0.3 none), color(display-p3 0.1 0.3 0))}\n",
    );
}

#[test]
fn parity_color_lab_degenerate_calc_channels() {
    // A degenerate calc() channel (calc(NaN)/calc(±infinity)) makes a real
    // lab-family COLOR (not a verbatim string): meta.type-of is `color`, the
    // serialization keeps the calc() spelling, a degenerate lightness clamps
    // (NaN→0 / +inf→max), chroma floors at 0, and a/b/hue keep calc().
    assert_parity("a {b: lab(1% calc(NaN) -3)}\n");
    assert_parity("a {b: lab(1% calc(infinity) -3)}\n");
    assert_parity("a {b: lab(1% calc(-infinity) -3)}\n");
    assert_parity("a {b: lch(50% calc(NaN) 30)}\n");
    assert_parity("a {b: lch(50% calc(infinity) 30)}\n");
    assert_parity("a {b: lch(50% 20 calc(NaN))}\n");
    assert_parity("a {b: lab(calc(NaN) 2 3)}\n");
    assert_parity("a {b: lab(calc(infinity) 2 3)}\n");
    assert_parity("a {b: oklab(50% calc(infinity) 0.1)}\n");
    assert_parity("a {b: oklch(0.5 calc(NaN) 30)}\n");
    assert_parity("@use \"sass:meta\";\na {b: meta.type-of(lab(1% calc(NaN) -3))}\n");
    assert_parity("@use \"sass:color\";\na {b: color.space(lch(50% calc(infinity) 30))}\n");
}

#[test]
fn parity_color_hwb_serialization_and_alpha_fold() {
    // A non-opaque integer hwb (pure red, sRGB 255 0 0) uses the hsl comma form
    // hsla(...), not rgba(); only a fully-opaque integer hwb collapses to a
    // named/hex color.
    assert_parity("@use \"sass:color\";\na {b: color.hwb(0, 0%, 0%, 0.5)}\n");
    assert_parity("@use \"sass:color\";\na {b: color.hwb(0, 0%, 0%, 45.6%)}\n");
    assert_parity("a {b: hwb(0 0% 0% / 0.5)}\n");
    assert_parity("a {b: hwb(0 0% 0%)}\n");
    assert_parity("a {b: hwb(120 0% 0%)}\n");
    // A degenerate calc() alpha folds to a clamped number (NaN→0, +inf→1, -inf→0).
    assert_parity("@use \"sass:color\";\na {b: color.hwb(0, 30%, 40%, calc(NaN))}\n");
    assert_parity("@use \"sass:color\";\na {b: color.hwb(0, 30%, 40%, calc(infinity))}\n");
    assert_parity("@use \"sass:color\";\na {b: color.hwb(0, 30%, 40%, calc(-infinity))}\n");
}

#[test]
fn parity_color_hwb_achromatic_serialization() {
    // An achromatic hwb (whiteness+blackness fills the gamut, collapsing chroma
    // to grey) has a powerless hue; dart-sass serializes it with hue 0, not the
    // floating-point residue of the hwb→rgb round-trip.
    assert_parity("a {b: hwb(90 0% 100%)}\n");
    assert_parity("a {b: hwb(270 80% 100%)}\n");
    assert_parity("a {b: hwb(0 50% 50%)}\n");
    assert_parity("a {b: hwb(200 60% 60%)}\n");
    // A chromatic hwb keeps its hue.
    assert_parity("a {b: hwb(90 0% 0%)}\n");
    assert_parity("a {b: hwb(120 30% 20%)}\n");
}

#[test]
fn parity_selector_unify_id_conflict() {
    // Two distinct ids cannot share a compound: selector.unify yields null
    // rather than an impossible `#a#b`. A same id (or an id alongside non-id
    // simples) still unifies.
    assert_parity("@use \"sass:selector\";\na {b: selector.unify(\"#a\", \"#b\")}\n");
    assert_parity("@use \"sass:selector\";\na {b: selector.unify(\"#s1-1 > .s1-2\", \"#s2-1 > .s2-2\")}\n");
    assert_parity("@use \"sass:selector\";\na {b: selector.unify(\"#a.x\", \"#a.y\")}\n");
    assert_parity("@use \"sass:selector\";\na {b: selector.unify(\"#a\", \".d\")}\n");
    assert_parity("@use \"sass:selector\";\na {b: selector.unify(\".c\", \".d\")}\n");
}

#[test]
fn parity_meta_load_css() {
    // `@include meta.load-css($url)` loads a module and emits its CSS without
    // binding a namespace; `$with` configures its !default variables.
    assert_module_parity(&[
        ("_other.scss", "$color: blue !default;\na { color: $color; }\n"),
        (
            "input.scss",
            "@use \"sass:meta\";\n@include meta.load-css(\"other\");\n",
        ),
    ]);
    assert_module_parity(&[
        ("_other.scss", "$color: blue !default;\na { color: $color; }\n"),
        (
            "input.scss",
            "@use \"sass:meta\";\n@include meta.load-css(\"other\", $with: (\"color\": green));\n",
        ),
    ]);
    // A module loaded for its CSS may itself @use other modules.
    assert_module_parity(&[
        ("_dep.scss", "@function two() { @return 2; }\n"),
        ("_mid.scss", "@use \"dep\";\nb { width: dep.two() * 1px; }\n"),
        (
            "input.scss",
            "@use \"sass:meta\";\n@include meta.load-css(\"mid\");\n",
        ),
    ]);
}

#[test]
fn parity_selector_pseudo_is_superselector() {
    // :is/:matches/:where/:any and :has/:host/:host-context consider their
    // selector argument. :is(...) is a superselector when every branch of a
    // same-name pseudo is covered, or (matches family) one branch supersedes the
    // parents+target compound. :is(c) is NOT a superselector of :is(c, d).
    assert_parity(
        "@use \"sass:selector\";\na {b: selector.is-superselector(\":is(c d, e f, g h)\", \"c d.i, e j f\")}\n",
    );
    assert_parity("@use \"sass:selector\";\na {b: selector.is-superselector(\":is(c e)\", \"c d e\")}\n");
    assert_parity("@use \"sass:selector\";\na {b: selector.is-superselector(\":is(c)\", \":is(c, d)\")}\n");
    assert_parity("@use \"sass:selector\";\na {b: selector.is-superselector(\":is(c, d)\", \":is(c)\")}\n");
    assert_parity(
        "@use \"sass:selector\";\na {b: selector.is-superselector(\":has(c d, e f, g h)\", \":has(c d.i, e j f)\")}\n",
    );
    assert_parity(
        "@use \"sass:selector\";\na {b: selector.is-superselector(\":host(c d, e f, g h)\", \":host(c d.i, e j f)\")}\n",
    );
}

#[test]
fn parity_extend_source_extender_not_trimmed() {
    // A source extender (`:is(midstream)`) is never trimmed away by a broader
    // generated selector (the transitive `:is(midstream, downstream)`).
    assert_parity(":is(midstream) {@extend upstream}\ndownstream {@extend midstream}\nupstream {a: b}\n");
}

#[test]
fn parity_meta_exists_module_and_star() {
    // The optional `$module` namespace arg looks the member up in that module.
    assert_module_parity(&[
        ("_other.scss", "$d: 1;\n@function f() {@return 2}\n@mixin m {}\n"),
        (
            "input.scss",
            "@use \"sass:meta\";\n@use \"other\" as o;\na {\n  f: meta.function-exists(\"f\", \"o\");\n  m: meta.mixin-exists(\"m\", \"o\");\n  v: meta.global-variable-exists(\"d\", \"o\");\n  n: meta.function-exists(\"nope\", \"o\");\n}\n",
        ),
    ]);
    // The no-`$module` forms see members exposed via `@use … as *`.
    assert_module_parity(&[
        ("_other.scss", "$d: 1;\n@function f() {@return 2}\n@mixin m {}\n"),
        (
            "input.scss",
            "@use \"sass:meta\";\n@use \"other\" as *;\na {\n  f: meta.function-exists(\"f\");\n  m: meta.mixin-exists(\"m\");\n  v: meta.variable-exists(\"d\");\n}\n",
        ),
    ]);
    // A built-in module member via the namespace.
    assert_module_parity(&[(
        "input.scss",
        "@use \"sass:meta\";\n@use \"sass:color\" as c;\na {r: meta.function-exists(\"red\", \"c\")}\n",
    )]);
}

#[test]
fn parity_meta_module_members() {
    // module-variables maps non-private members → value (private `-priv` omitted).
    assert_module_parity(&[
        ("_other.scss", "$d: d value;\n$e: e value;\n$-priv: hidden;\n"),
        (
            "input.scss",
            "@use \"sass:meta\";\n@use \"other\";\na {b: meta.inspect(meta.module-variables(\"other\"))}\n",
        ),
    ]);
    // module-functions references are callable; an underscore key canonicalizes
    // to a dash.
    assert_module_parity(&[
        (
            "_other.scss",
            "@function c-d() {@return cd}\n@function e_f() {@return ef}\n",
        ),
        (
            "input.scss",
            "@use \"sass:meta\";\n@use \"other\";\n$m: meta.module-functions(\"other\");\na {x: meta.call(map-get($m, \"c-d\")); y: meta.call(map-get($m, \"e-f\"))}\n",
        ),
    ]);
}

#[test]
fn parity_meta_get_function_module() {
    // get-function with a `$module` namespace resolves from that module.
    assert_module_parity(&[
        ("_other.scss", "@function f() {@return ff}\n"),
        (
            "input.scss",
            "@use \"sass:meta\";\n@use \"other\" as o;\na {b: meta.call(meta.get-function(\"f\", $module: \"o\"))}\n",
        ),
    ]);
    // The bare form captures a function exposed via `@use … as *`.
    assert_module_parity(&[
        ("_other.scss", "@function f() {@return ff}\n"),
        (
            "input.scss",
            "@use \"sass:meta\";\n@use \"other\" as *;\na {b: meta.call(meta.get-function(\"f\"))}\n",
        ),
    ]);
    // A built-in module member (math.round) via the namespace.
    assert_module_parity(&[(
        "input.scss",
        "@use \"sass:meta\";\n@use \"sass:math\" as m;\na {b: meta.call(meta.get-function(\"round\", $module: \"m\"), 0.6)}\n",
    )]);
}

#[test]
fn parity_meta_accepts_content() {
    // accepts-content reflects whether the mixin body uses @content; the only
    // built-in mixin that does is meta.apply.
    assert_parity(
        "@use \"sass:meta\";\n@mixin a {@content}\n@mixin b {x: y}\nz {\n  c: meta.accepts-content(meta.get-mixin(\"a\"));\n  d: meta.accepts-content(meta.get-mixin(\"b\"));\n  e: meta.accepts-content(meta.get-mixin(\"apply\", \"meta\"));\n}\n",
    );
}

#[test]
fn parity_list_join_append_slash_separator() {
    // `$separator: slash` now builds a slash-separated list (ListSep::Slash).
    assert_parity("@use \"sass:list\";\na {b: list.join(1 2, 3 4, $separator: slash)}\n");
    assert_parity("@use \"sass:list\";\na {b: list.append((1, 2), 3, $separator: slash)}\n");
    assert_parity("@use \"sass:list\";\na {b: list.separator(list.join((), 1, slash))}\n");
}

#[test]
fn parity_for_loop_unit() {
    // The @for loop variable inherits the FROM bound's unit; the TO bound is
    // converted to match (a unitless side defers).
    assert_parity("a {\n  @for $i from 1px through 5px {b: $i}\n}\n");
    assert_parity("a {\n  @for $i from 5mm through 1cm {b: $i}\n}\n");
    assert_parity("a {\n  @for $i from 1px through 5 {b: $i}\n}\n");
    assert_parity("a {\n  @for $i from 1 through 5px {b: $i}\n}\n");
}

#[test]
fn parity_color_equality_space_and_none() {
    // `==` compares color space + missing channels, not just sRGB.
    assert_parity("a {b: color(srgb 0 0 0) == color(srgb-linear 0 0 0)}\n");
    assert_parity("a {b: hsl(0 0% 80%) == hsl(none 0% 80%)}\n");
    assert_parity("a {b: hwb(0 0% 0%) == hwb(none 0% 0%)}\n");
    assert_parity("a {b: hsl(0 0% 50%) == hsl(120 0% 50%)}\n");
    // Different LEGACY spaces still compare via sRGB; non-legacy never crosses.
    assert_parity("a {b: rgb(255 0 0) == hsl(0 100% 50%)}\n");
    assert_parity("a {b: gray == hsl(none 0% 50.196078431373%)}\n");
    assert_parity("a {b: rgb(none 0 0) == rgb(0 0 0)}\n");
}

#[test]
fn parity_reserved_function_names() {
    // A user @function may not reuse a reserved operator/special-function name.
    if enabled() {
        for name in [
            "and",
            "or",
            "not",
            "url",
            "expression",
            "element",
            "-a-element",
            "type",
            "TYPE",
        ] {
            let scss = format!("@function {name}() {{@return 1}}\na {{b: 1}}\n");
            assert!(
                compile(&scss, &Options::default()).is_err(),
                "expected error for @function {name}"
            );
            assert!(
                dart_sass(&scss).is_none(),
                "dart-sass unexpectedly accepted @function {name}"
            );
        }
    }
    // Vendor-prefixed / differently-cased / non-reserved names stay valid.
    assert_parity("@function -a-and() {@return 1}\na {b: -a-and()}\n");
    assert_parity("@function AND() {@return 1}\na {b: AND()}\n");
    assert_parity("@function -a-url() {@return 1}\na {b: -a-url()}\n");
    assert_parity("@function ELEMENT() {@return 1}\na {b: ELEMENT()}\n");
}

#[test]
fn parity_user_function_calc_override() {
    // An empty `calc()` is a regular call, so a user `@function calc()` runs.
    assert_parity("@function calc() {@return 1}\na {b: calc()}\n");
    assert_parity("@function calc($x) {@return $x}\na {b: calc(2)}\n");
    assert_parity("a {b: calc(1px + 2px)}\n");
    // A bare `calc()` with no user override errors (CSS calc needs an argument).
    if enabled() {
        let scss = "a {b: calc()}\n";
        assert!(compile(scss, &Options::default()).is_err());
        assert!(dart_sass(scss).is_none());
    }
}

#[test]
fn parity_content_using_clause() {
    // A `@content(args)` call binds its arguments to the content block's
    // `using (params)`, which become locally visible inside the block.
    assert_parity(
        "@mixin m {\n  @content(1, 2);\n}\na {\n  @include m using ($x, $y) {\n    p: $x;\n    q: $y;\n  }\n}\n",
    );
    // Default values in the `using` list fill un-passed arguments.
    assert_parity(
        "@mixin m {\n  @content(10);\n}\na {\n  @include m using ($x, $y: 20) {\n    p: $x;\n    q: $y;\n  }\n}\n",
    );
    // `@content` with no parens and no `using` clause is a plain content block.
    assert_parity("@mixin m {\n  @content;\n}\na {\n  @include m {\n    p: 1;\n  }\n}\n");
    // Whitespace and case quirks around `using` / the arglist.
    assert_parity(
        "a {\n  @mixin m {\n    @content(1, 2);\n  }\n  @include m()UsInG ($x, $y) {\n    p: $x;\n    q: $y;\n  }\n}\n",
    );
    assert_parity(
        "a {\n  @mixin m {\n    @content (1, 2);\n  }\n  @include m using($x, $y){\n    p: $x;\n    q: $y;\n  }\n}\n",
    );
}

#[test]
fn parity_content_using_errors() {
    // Validation around `@content(args)` / `using (params)` matches dart-sass.
    if !enabled() {
        return;
    }
    let cases = [
        // A content block with no `using` accepts no arguments.
        "@mixin m {\n  @content(1);\n}\na {\n  @include m {}\n}\n",
        // An unknown named argument to the content block.
        "@mixin m {\n  @content($bogus: 1);\n}\na {\n  @include m using ($x) {}\n}\n",
        // `using` without a content block.
        "@mixin m {\n  @content;\n}\na {\n  @include m using ();\n}\n",
        // `using` without a parenthesized parameter list.
        "@mixin m {\n  @content;\n}\na {\n  @include m using {}\n}\n",
        // An unknown named argument to a plain mixin call.
        "@mixin m($a) {\n  x: $a;\n}\na {\n  @include m(1, $b: 2);\n}\n",
    ];
    for scss in cases {
        let ours = compile(scss, &Options::default()).err().map(|e| e.to_string());
        match dart_sass_error(scss) {
            Some(theirs) => {
                let ours = ours.unwrap_or_else(|| panic!("expected our compile to error:\n{scss}"));
                let msg = ours.trim_start_matches("Error: ");
                assert!(
                    msg.starts_with(&theirs),
                    "\n--- scss ---\n{scss}\n--- ours ---\n{ours}\n--- dart ---\n{theirs}\n"
                );
            }
            None => eprintln!("skipping content-using error parity case: dart-sass unavailable"),
        }
    }
}

#[test]
fn parity_color_arithmetic_removed() {
    // dart-sass removed color arithmetic: `+`/`-` combining a color with
    // another color or a number is "Undefined operation" (a color with a
    // string still string-concatenates).
    if !enabled() {
        return;
    }
    let err_cases = [
        "$v: #abc + #123;\na {b: $v}\n",
        "$v: #abc + 1;\na {b: $v}\n",
        "$v: 1 + #abc;\na {b: $v}\n",
        "$v: #abc - #123;\na {b: $v}\n",
        "$v: red - blue;\na {b: $v}\n",
        "$v: 1 - red;\na {b: $v}\n",
        "$v: rgb(1 2 3) + 1;\na {b: $v}\n",
    ];
    for scss in err_cases {
        let ours = compile(scss, &Options::default()).err().map(|e| e.to_string());
        match dart_sass_error(scss) {
            Some(theirs) => {
                let ours = ours.unwrap_or_else(|| panic!("expected our compile to error:\n{scss}"));
                let msg = ours.trim_start_matches("Error: ");
                assert!(
                    msg.starts_with(&theirs),
                    "\n--- scss ---\n{scss}\n--- ours ---\n{ours}\n--- dart ---\n{theirs}\n"
                );
            }
            None => eprintln!("skipping color-arithmetic parity case: dart-sass unavailable"),
        }
    }
    // A color combined with a string still concatenates (no error).
    assert_parity("a {b: \"x\" + red}\n");
    assert_parity("a {b: foo + red}\n");
    assert_parity("a {b: red + foo}\n");
}

#[test]
fn parity_plus_quotes_from_right_string() {
    // dart-sass's default `Value.plus` (used when the left operand is not a
    // string) quotes the concatenated result iff the RIGHT operand is a quoted
    // string: `1 + "x"` -> `"1x"`, `red + "x"` -> `"redx"`. An unquoted right
    // keeps the result unquoted (`foo + "x"` is quoted, `1 + foo` is not).
    assert_parity("a {b: 1 + \"x\"}\n");
    assert_parity("a {b: red + \"x\"}\n");
    assert_parity("a {b: true + \"x\"}\n");
    assert_parity("a {b: 1px + \"x\"}\n");
    assert_parity("a {b: (1 2) + \"x\"}\n");
    assert_parity("a {b: null + \"x\"}\n");
    assert_parity("a {b: calc(1px + 1px) + \"x\"}\n");
    // Unquoted right operand → unquoted result.
    assert_parity("a {b: 1 + foo}\n");
    assert_parity("a {b: red + foo}\n");
}

#[test]
fn parity_builtin_argument_validation() {
    // Fixed-arity builtins reject extra positional args, and several value
    // constraints match dart-sass exactly.
    if !enabled() {
        return;
    }
    let err_cases = [
        "@use \"sass:color\";\na {b: color.red(red, 2)}\n",
        "@use \"sass:color\";\na {b: color.green(red, 2)}\n",
        "@use \"sass:color\";\na {b: color.blue(red, 2)}\n",
        "@use \"sass:color\";\na {b: color.space(red, srgb)}\n",
        "@use \"sass:color\";\na {b: color.is-legacy(red, 1)}\n",
        "@use \"sass:color\";\na {b: color.same(red, blue, green)}\n",
        "@use \"sass:color\";\na {b: color.is-missing(black, \"red\", 1)}\n",
        "@use \"sass:color\";\na {b: color.to-gamut(red, srgb, local-minde, x)}\n",
        "@use \"sass:math\";\na {b: math.percentage(1, 2)}\n",
        "@use \"sass:math\";\na {b: math.percentage(1%)}\n",
        "@use \"sass:color\";\na {b: color.is-missing(black, \"RED\")}\n",
        "@use \"sass:color\";\na {b: color.is-missing(black, \"hue\")}\n",
        "@use \"sass:color\";\na {b: color.invert(red, 100.001%)}\n",
        "@use \"sass:color\";\na {b: color.invert(red, -0.001%)}\n",
    ];
    for scss in err_cases {
        let ours = compile(scss, &Options::default()).err().map(|e| e.to_string());
        match dart_sass_error(scss) {
            Some(theirs) => {
                let ours = ours.unwrap_or_else(|| panic!("expected our compile to error:\n{scss}"));
                let msg = ours.trim_start_matches("Error: ");
                assert!(
                    msg.starts_with(&theirs),
                    "\n--- scss ---\n{scss}\n--- ours ---\n{ours}\n--- dart ---\n{theirs}\n"
                );
            }
            None => eprintln!("skipping builtin-validation parity case: dart-sass unavailable"),
        }
    }
    // Valid calls still succeed.
    assert_module_parity(&[("input.scss", "@use \"sass:color\";\na {b: color.red(red)}\n")]);
    assert_module_parity(&[("input.scss", "@use \"sass:math\";\na {b: math.percentage(0.5)}\n")]);
    assert_module_parity(&[(
        "input.scss",
        "@use \"sass:color\";\na {b: color.invert(red, 50%)}\n",
    )]);
}

#[test]
fn parity_calc_functions_are_calculations() {
    // An unreduced `min`/`max`/`clamp`/`hypot` is a calculation value:
    // `type-of` is `calculation`, `calc-name`/`calc-args` inspect it, a nested
    // calculation stays a calculation, and `calc(min(…))` drops its wrapper.
    // A reducible call still folds to a number.
    assert_parity("a {b: min(1px, 2vw); c: max(1%, 2px); d: clamp(1%, 2px, 3px)}\n");
    assert_parity("a {b: min(1px, 2px)}\n");
    assert_parity("a {b: calc(min(1%, 2px))}\n");
    assert_parity(
        "@use \"sass:meta\";\na {b: meta.type-of(clamp(1%, 2px, 3px)); c: meta.calc-name(min(1%, 2px))}\n",
    );
    assert_parity("@use \"sass:list\";\n@use \"sass:meta\";\na {b: meta.inspect(meta.calc-args(clamp(1%, 2px, 3px)))}\n");
    assert_parity("@use \"sass:list\";\n@use \"sass:meta\";\na {b: meta.type-of(list.nth(meta.calc-args(min(max(1%, 1px), 2px)), 1))}\n");
}

#[test]
fn parity_calc_name_and_args() {
    // `meta.calc-name` returns the calculation function name (`"calc"`);
    // `meta.calc-args` returns its arguments, where an operation/var becomes an
    // unquoted string and a number stays a number.
    assert_parity("@use \"sass:meta\";\na {b: meta.calc-name(calc(var(--c)))}\n");
    assert_parity("@use \"sass:meta\";\na {b: meta.inspect(meta.calc-args(calc(1% + 1px)))}\n");
    assert_parity(
        "@use \"sass:list\";\n@use \"sass:meta\";\na {b: list.nth(meta.calc-args(calc(var(--c))), 1)}\n",
    );
    assert_parity("@use \"sass:list\";\n@use \"sass:meta\";\na {b: meta.type-of(list.nth(meta.calc-args(calc(1% + 1px)), 1))}\n");
    // A non-calculation argument is rejected.
    let scss = "@use \"sass:meta\";\na {b: meta.calc-args(1)}\n";
    let ours = compile(scss, &Options::default()).err().map(|e| e.to_string());
    assert!(
        ours.is_some_and(|m| m.contains("is not a calculation.")),
        "expected calc-args on a number to error"
    );
}

#[test]
fn parity_argument_list_keywords() {
    // A `$args...` rest parameter captures positional args (a comma list) plus
    // keyword args; `meta.keywords` returns the keyword map, `type-of` reports
    // `arglist`, and a `$args...` splat forwards both positional and keyword
    // arguments. Underscore arg names normalize to hyphens in the keyword map.
    assert_parity(
        "@use \"sass:meta\";\n@function f($args...) {@return meta.inspect((positional: $args, named: meta.keywords($args)))}\na {b: f(1, $x: 2, $y_z: 3); c: f(1, 2)}\n",
    );
    assert_parity(
        "@use \"sass:meta\";\n@function t($args...) {@return meta.type-of($args)}\na {b: t(1, 2)}\n",
    );
    assert_parity(
        "@use \"sass:meta\";\n@mixin fwd($args...) {@include inner($args...)}\n@mixin inner($a, $b: 0, $c: 0) {x: $a $b $c}\na {@include fwd(9, $c: 7)}\n",
    );
    // `meta.keywords` rejects a non-argument-list value.
    let scss = "@use \"sass:meta\";\na {b: meta.keywords((a: 1))}\n";
    let ours = compile(scss, &Options::default()).err().map(|e| e.to_string());
    assert!(
        ours.is_some_and(|m| m.contains("is not an argument list.")),
        "expected meta.keywords on a map to error"
    );
}

#[test]
fn parity_selector_digit_start_errors() {
    // An id/class whose name starts with a digit (`#2b`, `.3c`) is rejected;
    // valid names — and keyframe-style `50%` stops — still compile.
    if enabled() {
        for scss in [
            "#2b {x: y}\n",
            "#2 {x: y}\n",
            ".3c {x: y}\n",
            ".3 {x: y}\n",
            "#4 {x: y}\n",
        ] {
            let ours = compile(scss, &Options::default()).err().map(|e| e.to_string());
            match dart_sass_error(scss) {
                Some(theirs) => {
                    let ours = ours.unwrap_or_else(|| panic!("expected our compile to error:\n{scss}"));
                    let msg = ours.trim_start_matches("Error: ");
                    assert!(
                        msg.starts_with(&theirs),
                        "\n--- scss ---\n{scss}\n--- ours ---\n{ours}\n--- dart ---\n{theirs}\n"
                    );
                }
                None => eprintln!("skipping selector-digit parity case: dart-sass unavailable"),
            }
        }
    }
    assert_parity("#a2 {x: y}\n.-baz {x: y}\n.foo2 {x: y}\n");
}

#[test]
fn parity_selector_nest_parent_in_pseudo() {
    // `selector.nest` substitutes a `&` inside a selector-list pseudo
    // (`:is`/`:where`/`:not`) with the parent, instead of nesting it as a
    // descendant; a complex with no `&` anywhere still nests as a descendant.
    assert_parity("@use \"sass:selector\";\na {b: selector.nest(\"c\", \":is(&)\")}\n");
    assert_parity("@use \"sass:selector\";\na {b: selector.nest(\"c d\", \":is(&)\")}\n");
    assert_parity("@use \"sass:selector\";\na {b: selector.nest(\"c\", \":not(&)\")}\n");
    assert_parity("@use \"sass:selector\";\na {b: selector.nest(\"c\", \":where(& .e)\")}\n");
    assert_parity("@use \"sass:selector\";\na {b: selector.nest(\"c\", \"&:is(&)\")}\n");
    assert_parity("@use \"sass:selector\";\na {b: selector.nest(\"c\", \":is(&), x\")}\n");
}

#[test]
fn parity_private_use_char_escaping() {
    // Private-use characters are serialized as `\<hex>` escapes in both quoted
    // and unquoted strings (planes 15/16 too); a non-character or CJK-compat
    // char stays raw. Control/DEL are escaped only inside a quoted string.
    assert_parity("@use \"sass:string\";\na {b: string.split(\"\\E000\", \"\")}\n");
    assert_parity("a {b: \"\\E000\"; c: \"\\F0000\"; d: \"\\10FFFD\"}\n");
    assert_parity("a {b: \"\\FDD0\"; c: \"\\F900\"}\n");
    assert_parity("@use \"sass:string\";\na {b: string.unquote(\"x\\E000 y\")}\n");
    assert_parity("a {b: \"x\\7f y\"; c: \"x\\19 y\"}\n");
}

#[test]
fn parity_comment_newline_normalization() {
    // CR, FF, and CRLF inside a loud comment are all normalized to LF.
    assert_parity("/* foo\r * bar */\n");
    assert_parity("/* foo\u{c} * bar */\n");
    assert_parity("/* foo\r\n * bar */\n");
    // A plain LF comment is unchanged.
    assert_parity("/* a\n b\n c */\nx {y: z}\n");
}

#[test]
fn parity_empty_value_declaration_dropped() {
    // A regular declaration whose value serializes to nothing (an empty
    // unquoted string, an all-`null` list) is dropped like a `null` value; a
    // quoted `""` or a space `" "` still emits.
    assert_parity("@use \"sass:string\";\na {c: 1; b: string.unquote(\"\"); d: 2}\n");
    assert_parity("a {c: 1; b: (null, null); d: 2}\n");
    assert_parity("a {b: \"\"}\n");
    assert_parity("a {b: \" \"}\n");
}

#[test]
fn parity_color_space_name_case_insensitive() {
    // Color-space names are ASCII case-insensitive in `color()` and `$space`
    // arguments; the canonical lower-case form is serialized.
    assert_parity("a {b: color(sRGB 0.1 0.2 0.3)}\n");
    assert_parity("a {b: color(Display-P3 0.1 0.2 0.3)}\n");
    assert_parity("a {b: color(XYZ 0.1 0.2 0.3)}\n");
    assert_parity("a {b: color(Display-P3-Linear 1 2 3)}\n");
    assert_parity("@use \"sass:color\";\na {b: color.to-space(red, DISPLAY-p3)}\n");
    assert_parity("@use \"sass:color\";\na {b: color.invert(lch(20% 80 50deg), $space: DISPLAY-p3)}\n");
}

#[test]
fn parity_list_undecided_separator() {
    // An empty or single-element list with no explicit separator is
    // "undecided": it defers to the other operand in join/append, while an
    // explicit `$separator` (or `with-separator`) makes it stick even when the
    // result is empty or single-element. A single-element bracketed `[1]` is
    // also undecided.
    assert_parity("@use \"sass:list\";\na {b: list.join([1], (2,))}\n");
    assert_parity("@use \"sass:list\";\na {b: list.join([1], (2, 3, 4))}\n");
    assert_parity("@use \"sass:list\";\na {b: list.separator(list.join((), (), comma))}\n");
    assert_parity("@use \"sass:list\";\na {b: list.append((), 1, $separator: comma)}\n");
    assert_parity("@use \"sass:list\";\na {b: list.separator(list.join((), (), $separator: space))}\n");
    assert_parity("@use \"sass:list\";\na {b: list.separator([1])}\n");
    assert_parity("@use \"sass:meta\";\na {b: meta.inspect(())}\n");
    assert_parity("@use \"sass:meta\";\na {b: meta.inspect([])}\n");
    // A deliberately space-separated empty list keeps its separator through a
    // join with a comma list as the first operand's settled choice.
    assert_parity("@use \"sass:list\";\na {b: list.join(list.join((), (), space), (1, 2))}\n");
}

#[test]
fn parity_empty_list_declaration_errors() {
    // An empty unbracketed list (`()`, directly or via a variable/builtin)
    // cannot be a declaration value; a bracketed `[]` and any non-empty list
    // are fine.
    if !enabled() {
        return;
    }
    for scss in [
        "a {b: ()}\n",
        "a {b: (())}\n",
        "$x: ();\na {b: $x}\n",
        "@use \"sass:list\";\na {b: list.join((), ())}\n",
    ] {
        let ours = compile(scss, &Options::default()).err().map(|e| e.to_string());
        match dart_sass_error(scss) {
            Some(theirs) => {
                let ours = ours.unwrap_or_else(|| panic!("expected our compile to error:\n{scss}"));
                let msg = ours.trim_start_matches("Error: ");
                assert!(
                    msg.starts_with(&theirs),
                    "\n--- scss ---\n{scss}\n--- ours ---\n{ours}\n--- dart ---\n{theirs}\n"
                );
            }
            None => eprintln!("skipping empty-list parity case: dart-sass unavailable"),
        }
    }
    // A bracketed empty list is a valid CSS value.
    assert_parity("a {b: []}\n");
}

#[test]
fn parity_raw_newline_in_string_errors() {
    // A literal newline inside a quoted string is an error; a `\` line
    // continuation or a `\a` escape is the valid way to span lines.
    if !enabled() {
        return;
    }
    for scss in ["a {b: \"x\ny\"}\n", "a {b: \"x\ry\"}\n"] {
        let ours = compile(scss, &Options::default()).err().map(|e| e.to_string());
        match dart_sass_error(scss) {
            Some(theirs) => {
                let ours = ours.unwrap_or_else(|| panic!("expected our compile to error:\n{scss}"));
                let msg = ours.trim_start_matches("Error: ");
                assert!(
                    msg.starts_with(&theirs),
                    "\n--- scss ---\n{scss}\n--- ours ---\n{ours}\n--- dart ---\n{theirs}\n"
                );
            }
            None => eprintln!("skipping raw-newline parity case: dart-sass unavailable"),
        }
    }
    // A `\` line continuation and a `\a` escape stay valid.
    assert_parity("a {b: \"x\\\ny\"}\n");
    assert_parity("a {b: \"x\\a y\"}\n");
}

#[test]
fn parity_stray_else_errors() {
    // A `@else` / `@else if` that is not part of an `@if` chain is rejected
    // ("This at-rule is not allowed here."). A valid chain still compiles.
    if !enabled() {
        return;
    }
    for scss in ["@else {a {b: c}}\n", "@else if true {a {b: c}}\n"] {
        let ours = compile(scss, &Options::default()).err().map(|e| e.to_string());
        match dart_sass_error(scss) {
            Some(theirs) => {
                let ours = ours.unwrap_or_else(|| panic!("expected our compile to error:\n{scss}"));
                let msg = ours.trim_start_matches("Error: ");
                assert!(
                    msg.starts_with(&theirs),
                    "\n--- scss ---\n{scss}\n--- ours ---\n{ours}\n--- dart ---\n{theirs}\n"
                );
            }
            None => eprintln!("skipping stray-else parity case: dart-sass unavailable"),
        }
    }
    assert_parity("@if false {a {b: c}} @else {d {e: f}}\n");
}

#[test]
fn parity_declaration_context_errors() {
    // `@function`/`@mixin` declarations are rejected in control directives,
    // function bodies, and mixin bodies (a compile-time restriction).
    if !enabled() {
        return;
    }
    let err_cases = [
        "@each $i in (a, b) {\n  @function foo() {@return 1}\n}\n",
        "@for $i from 1 through 1 {\n  @function foo() {@return 1}\n}\n",
        "@if true {\n  @function foo() {@return 1}\n}\n",
        "@while false {\n  @function foo() {@return 1}\n}\n",
        "@each $i in (a, b) {\n  @mixin foo() {}\n}\n",
        "@if true {\n  @mixin foo() {}\n}\n",
        "@function foo() {\n  @function bar() {@return 1}\n}\n",
        "@function foo() {\n  @mixin bar() {}\n}\n",
        "@mixin m {\n  @mixin n {}\n}\n",
        "@mixin m {\n  @function f() {@return 1}\n}\n",
        // The control-directive restriction propagates through style rules.
        "@if true {\n  a {\n    @function f() {@return 1}\n  }\n}\n",
        // A function body's scope sticks through a nested control directive.
        "@function f() {\n  @if true {\n    @function g() {@return 1}\n  }\n  @return 1\n}\n",
    ];
    for scss in err_cases {
        let ours = compile(scss, &Options::default()).err().map(|e| e.to_string());
        match dart_sass_error(scss) {
            Some(theirs) => {
                let ours = ours.unwrap_or_else(|| panic!("expected our compile to error:\n{scss}"));
                let msg = ours.trim_start_matches("Error: ");
                assert!(
                    msg.starts_with(&theirs),
                    "\n--- scss ---\n{scss}\n--- ours ---\n{ours}\n--- dart ---\n{theirs}\n"
                );
            }
            None => eprintln!("skipping declaration-context parity case: dart-sass unavailable"),
        }
    }
    // Valid placements still compile.
    assert_parity("a {\n  @function foo() {@return 1}\n  b: foo();\n}\n");
    assert_parity("@media x {\n  a {b: c}\n}\n");
}

#[test]
fn parity_sass_import_context_errors() {
    // A Sass `@import` (inlining a partial) is forbidden inside a control
    // directive or a function/mixin body ("This at-rule is not allowed
    // here."); a plain-CSS `@import` is always allowed.
    if !enabled() {
        return;
    }
    let err_cases = [
        "@if true {\n  @import \"_include\";\n}\n",
        "@if false {\n} @else {\n  @import \"_include\";\n}\n",
        "@each $i in (1) {\n  @import \"_include\";\n}\n",
        "@for $i from 1 through 2 {\n  @import \"_include\";\n}\n",
        "@while false {\n  @import \"_include\";\n}\n",
        "@mixin m {\n  @import \"_include\";\n}\n@include m;\n",
        "@function f() {\n  @import \"_include\";\n  @return 1\n}\na {b: f()}\n",
        "@if true {\n  a {\n    @import \"_include\";\n  }\n}\n",
    ];
    for scss in err_cases {
        let ours = compile(scss, &Options::default()).err().map(|e| e.to_string());
        match dart_sass_error(scss) {
            Some(theirs) => {
                let ours = ours.unwrap_or_else(|| panic!("expected our compile to error:\n{scss}"));
                let msg = ours.trim_start_matches("Error: ");
                assert!(
                    msg.starts_with(&theirs),
                    "\n--- scss ---\n{scss}\n--- ours ---\n{ours}\n--- dart ---\n{theirs}\n"
                );
            }
            None => eprintln!("skipping import-context parity case: dart-sass unavailable"),
        }
    }
    // A plain-CSS `@import` in a control directive is fine.
    assert_parity("@if true {\n  @import url(x);\n}\n");
}

#[test]
fn parity_callable_not_valid_css_value() {
    // A first-class function/mixin reference cannot appear in `+`/`-`/`/`
    // arithmetic ("<inspect> isn't a valid CSS value."); `*` still raises the
    // "Undefined operation" message and `==` still compares.
    if !enabled() {
        return;
    }
    let err_cases = [
        "@use \"sass:meta\";\n@mixin a() {}\n@mixin b() {}\nx {y: meta.get-mixin(a) + meta.get-mixin(b)}\n",
        "@use \"sass:meta\";\n@mixin a() {}\n@mixin b() {}\nx {y: meta.get-mixin(a) - meta.get-mixin(b)}\n",
        "@use \"sass:meta\";\n@mixin a() {}\n@mixin b() {}\nx {y: meta.get-mixin(a) / meta.get-mixin(b)}\n",
        "@use \"sass:meta\";\n@function a() {@return 1}\nx {y: meta.get-function(\"a\") + 1}\n",
        "@use \"sass:meta\";\n@mixin a() {}\n@mixin b() {}\nx {y: meta.get-mixin(a) * meta.get-mixin(b)}\n",
    ];
    for scss in err_cases {
        let ours = compile(scss, &Options::default()).err().map(|e| e.to_string());
        match dart_sass_error(scss) {
            Some(theirs) => {
                let ours = ours.unwrap_or_else(|| panic!("expected our compile to error:\n{scss}"));
                let msg = ours.trim_start_matches("Error: ");
                assert!(
                    msg.starts_with(&theirs),
                    "\n--- scss ---\n{scss}\n--- ours ---\n{ours}\n--- dart ---\n{theirs}\n"
                );
            }
            None => eprintln!("skipping callable-CSS-value parity case: dart-sass unavailable"),
        }
    }
    // Equality comparison of mixins is still valid.
    assert_module_parity(&[(
        "input.scss",
        "@use \"sass:meta\";\n@mixin a() {}\nx {y: meta.get-mixin(a) == meta.get-mixin(a)}\n",
    )]);
}

#[test]
fn parity_meta_exists_global_module_conflict() {
    // A name exposed unprefixed by more than one `@use … as *` module is
    // ambiguous: the existence predicates error (byte-verified against
    // dart-sass via the spec ratchet) rather than returning true.
    let other = "$member: 1;\n@function member() {@return 1}\n@mixin member() {}\n";
    let cases = [
        (
            "meta.variable-exists(member)",
            "This variable is available from multiple global modules.",
        ),
        (
            "meta.global-variable-exists(member)",
            "This variable is available from multiple global modules.",
        ),
        (
            "meta.mixin-exists(member)",
            "This mixin is available from multiple global modules.",
        ),
        (
            "meta.function-exists(member)",
            "This function is available from multiple global modules.",
        ),
    ];
    for (predicate, expected) in cases {
        let dir = std::env::temp_dir().join(format!(
            "sasso-conflict-{}-{}",
            std::process::id(),
            predicate.len()
        ));
        let _ = std::fs::remove_dir_all(&dir);
        std::fs::create_dir_all(&dir).expect("create dir");
        std::fs::write(dir.join("_other1.scss"), other).unwrap();
        std::fs::write(dir.join("_other2.scss"), other).unwrap();
        let main = format!(
            "@use \"sass:meta\";\n@use \"other1\" as *;\n@use \"other2\" as *;\na {{b: {predicate}}}\n"
        );
        let importer = FsImporter::new(vec![dir.clone()]);
        let err = compile(&main, &Options::default().with_importer(&importer))
            .err()
            .map(|e| e.to_string());
        let _ = std::fs::remove_dir_all(&dir);
        let err = err.unwrap_or_else(|| panic!("expected an ambiguity error for {predicate}"));
        assert!(
            err.trim_start_matches("Error: ").starts_with(expected),
            "for {predicate}: got {err}"
        );
    }
    // A single star module is unambiguous and resolves to true.
    assert_module_parity(&[
        (
            "input.scss",
            "@use \"sass:meta\";\n@use \"other1\" as *;\na {b: meta.function-exists(member)}\n",
        ),
        ("_other1.scss", other),
    ]);
}

#[test]
fn parity_color_module_filter_overload_strict() {
    // On the MODULE spelling the filter overload is narrower than the global
    // one: only a number takes it. Every other CSS-special argument is a colour
    // argument and errors ("$color: var(--c) is not a color."), including an
    // `env()` and a `calc()` that cannot fold to a number. A number — literal
    // or folded out of a `calc()` — still passes through the deprecated
    // overload, and a real colour still computes (#124).
    if !enabled() {
        return;
    }
    let err_cases = [
        "@use \"sass:color\";\na {b: color.grayscale(var(--c))}\n",
        "@use \"sass:color\";\na {b: color.opacity(var(--c))}\n",
        "@use \"sass:color\";\na {b: color.invert(var(--c))}\n",
        "@use \"sass:color\";\na {b: color.grayscale($color: var(--c))}\n",
        "@use \"sass:color\";\na {b: color.invert(env(--c))}\n",
        "@use \"sass:color\";\na {b: color.grayscale(calc(1px + 1em))}\n",
        "@use \"sass:color\";\na {b: color.invert(calc(1px + 1em))}\n",
        "@use \"sass:color\";\na {b: color.opacity(calc(1px + 1em))}\n",
        "@use \"sass:color\";\na {b: color.grayscale(min(1px, 2em))}\n",
    ];
    for scss in err_cases {
        let ours = compile(scss, &Options::default()).err().map(|e| e.to_string());
        match dart_sass_error(scss) {
            Some(theirs) => {
                let ours = ours.unwrap_or_else(|| panic!("expected our compile to error:\n{scss}"));
                let msg = ours.trim_start_matches("Error: ");
                assert!(
                    msg.starts_with(&theirs),
                    "\n--- scss ---\n{scss}\n--- ours ---\n{ours}\n--- dart ---\n{theirs}\n"
                );
            }
            None => eprintln!("skipping module filter overload strict parity case: dart-sass unavailable"),
        }
    }
    // A number passes through; a color is computed.
    assert_parity("@use \"sass:color\";\na {b: color.grayscale(50%)}\n");
    assert_parity("@use \"sass:color\";\na {b: color.opacity(red)}\n");
    // A `calc()` that folds to a number IS a number: the overload applies, and
    // the filter is written with the folded value rather than the calculation.
    assert_parity("@use \"sass:color\";\na {b: color.grayscale(calc(1 + 1))}\n");
    assert_parity("@use \"sass:color\";\na {b: color.invert(clamp(0.1, 0.5, 0.9))}\n");
}

#[test]
fn parity_legacy_color_functions_reject_non_legacy() {
    // The legacy color modifiers darken/lighten/(de)saturate/fade-in/fade-out/
    // adjust-hue reject a non-legacy color ("<fn>() is only supported for
    // legacy colors. …"); a legacy color is still computed.
    if !enabled() {
        return;
    }
    let err_cases = [
        "a {b: darken(color(srgb 1 1 1), 10%)}\n",
        "a {b: lighten(color(srgb 0 0 0), 10%)}\n",
        "a {b: desaturate(color(srgb 1 1 1), 10%)}\n",
        "a {b: saturate(color(srgb 1 1 1), 10%)}\n",
        "a {b: fade-in(color(srgb 1 1 1 / 0.1), 0.1)}\n",
        "a {b: fade-out(color(srgb 1 1 1), 0.1)}\n",
        "a {b: adjust-hue(color(srgb 1 1 1), 10deg)}\n",
    ];
    for scss in err_cases {
        let ours = compile(scss, &Options::default()).err().map(|e| e.to_string());
        match dart_sass_error(scss) {
            Some(theirs) => {
                let ours = ours.unwrap_or_else(|| panic!("expected our compile to error:\n{scss}"));
                let msg = ours.trim_start_matches("Error: ");
                assert!(
                    msg.starts_with(&theirs),
                    "\n--- scss ---\n{scss}\n--- ours ---\n{ours}\n--- dart ---\n{theirs}\n"
                );
            }
            None => eprintln!("skipping legacy-color parity case: dart-sass unavailable"),
        }
    }
    // Legacy colors still compute.
    assert_parity("a {b: darken(#888, 10%)}\n");
    assert_parity("a {b: lighten(red, 10%)}\n");
    assert_parity("a {b: fade-out(rgba(0, 0, 0, 0.5), 0.1)}\n");
}

#[test]
fn parity_loud_comment_interpolation() {
    // `#{…}` interpolation inside a loud comment is resolved at eval time,
    // and an undefined variable / unterminated interpolation errors.
    assert_parity("/* a #{1 + 2} b */\nx {y: z}\n");
    assert_parity("$v: hi;\n/* value: #{$v} */\nx {y: z}\n");
    assert_parity("x {\n  /* in #{1 + 1} rule */\n  y: z;\n}\n");
    assert_parity("/* no interp here */\nx {y: z}\n");
    if enabled() {
        for scss in ["/* #{$undefined} */\n", "/* #{broken */\n"] {
            assert!(
                compile(scss, &Options::default()).is_err(),
                "expected comment-interpolation error: {scss}"
            );
            assert!(
                dart_sass(scss).is_none(),
                "dart-sass unexpectedly accepted: {scss}"
            );
        }
    }
}

#[test]
fn parity_operator_without_whitespace() {
    // dart-sass: `+`/`-` is a binary operator unless it has whitespace before
    // but not after (then it is a unary sign starting a new space-list term).
    assert_parity("a {b: 1+1}\n");
    assert_parity("a {b: 1+ 1}\n");
    assert_parity("a {b: 5-2}\n");
    assert_parity("a {b: 5- 2}\n");
    assert_parity("a {b: 10px+5px}\n");
    assert_parity("a {b: 1-a}\n");
    assert_parity("a {b: (1)-2}\n");
    // Space-before-not-after stays a list of signed terms.
    assert_parity("a {b: 1 -2}\n");
    assert_parity("a {b: 5 -2 3}\n");
    // Identifiers keep their hyphens (the `-` never reaches the operator parser).
    assert_parity("a {b: a-b}\n");
    assert_parity("a {b: foo-bar}\n");
    assert_parity("a {b: a-1}\n");
    assert_parity("a {b: red-1}\n");
    // Unicode ranges: a `?`-wildcard followed by `-name` splits, by `-digit`
    // subtracts.
    assert_parity("a {b: U+A?-BCDE}\n");
    assert_parity("a {b: U+A?-1234}\n");
    assert_parity("a {b: U+0-7F}\n");
    // calc() still requires whitespace around `+`/`-`.
    if enabled() {
        assert!(compile("a {b: calc(1+1)}\n", &Options::default()).is_err());
        assert!(dart_sass("a {b: calc(1+1)}\n").is_none());
    }
}

#[test]
fn parity_adjust_hsl_saturation_clamp() {
    // `color.adjust` clamps an hsl saturation at its lower bound (0) but not the
    // upper, so over-desaturating yields grey rather than a hue-flip. `change`
    // sets the raw value (no clamp) and the serializer flips negative saturation.
    assert_parity("@use \"sass:color\";\na {b: color.adjust(plum, $saturation: -100%)}\n");
    assert_parity("@use \"sass:color\";\na {b: color.adjust(plum, $saturation: -200%)}\n");
    assert_parity("@use \"sass:color\";\na {b: color.adjust(plum, $saturation: -48%)}\n");
    assert_parity("@use \"sass:color\";\na {b: color.adjust(red, $saturation: 50%)}\n");
    assert_parity("@use \"sass:color\";\na {b: color.scale(plum, $saturation: -100%)}\n");
    // change does not clamp.
    assert_parity("@use \"sass:color\";\na {b: color.change(hsl(120, 50%, 50%), $saturation: -100%)}\n");
}

#[test]
fn parity_legacy_modify_gamut_serialization() {
    // A legacy color modified without $space serializes in the original format
    // when the result is in the sRGB gamut (rgb/hex/named), but in the working
    // space (keeping canonical channels) when it falls out of gamut — so an
    // hsl-channel adjustment doesn't round-trip through rgb into a flipped
    // negative-saturation form.
    assert_parity("@use \"sass:color\";\na {b: color.adjust(red, $lightness: 100%)}\n");
    assert_parity("@use \"sass:color\";\na {b: color.adjust(red, $lightness: 200%)}\n");
    assert_parity("@use \"sass:color\";\na {b: color.change(red, $lightness: 150%)}\n");
    assert_parity("@use \"sass:color\";\na {b: color.adjust(plum, $lightness: -200%)}\n");
    // In-gamut results keep the rgb/named form.
    assert_parity("@use \"sass:color\";\na {b: color.change(red, $hue: 120)}\n");
    assert_parity("@use \"sass:color\";\na {b: color.adjust(red, $green: 10)}\n");
    // A constructed hsl color keeps its hsl format when modified in gamut.
    assert_parity("@use \"sass:color\";\na {b: color.adjust(hsl(120, 100%, 50%), $lightness: 0%)}\n");
}

#[test]
fn parity_legacy_color_form_choice() {
    // Two rules pick a legacy color's spelling, and both are measured here in
    // each style. (1) A channel counts as an integer EXACTLY for CSS output and
    // fuzzily for `meta.inspect`, so the dust an hsl conversion leaves behind
    // sends the whole triple to percentages in CSS while inspect still shows
    // integers. (2) The reroute to hsl() that an out-of-gamut color takes
    // measures the color in its own space, where hsl/hwb channels 1 and 2 are
    // bounded to [0, 100] — not in the sRGB shadow compressed output would
    // otherwise write.
    for c in [
        "color.to-space(hsl(180, 60%, 50%, 0.4), rgb)",
        "hsl(180, 60%, 50%, 0.4)",
        "color.to-space(hsl(210, 50%, 30%), rgb)",
        "color.to-space(hsl(25, 100%, 40%, 0.8), rgb)",
        "hsl(120, 50%, 0%)",
        "hsl(17.5913578322, 6051.6428880588%, 0%)",
        "color.to-space(oklch(0.5 0.2 200), hsl)",
        "color.to-space(oklch(0.5 0.2 200), hwb)",
        "color.to-space(oklab(0.5 0.2 -0.3), hsl)",
        "hwb(120 -20% 30%)",
        "hwb(200 20% 30%)",
        "color.change(hwb(200 20% 30%), $alpha: 0.5)",
        "color.adjust(red, $lightness: 200%)",
        "color.to-space(color(srgb 2 0 0.5), rgb)",
        "color.to-space(color(srgb 2 0 0), rgb)",
    ] {
        let src = format!("@use \"sass:color\";\na {{b: {c}}}\n");
        assert_parity(&src);
        assert_parity_compressed(&src);
    }
    // The inspect spelling of the same colors, where the integrality test is
    // the fuzzy one.
    for c in [
        "color.to-space(hsl(180, 60%, 50%, 0.4), rgb)",
        "color.to-space(hsl(25, 100%, 40%, 0.8), rgb)",
        "color.to-space(hsl(180, 60%, 50%), rgb)",
        "color.to-space(color(srgb 2 0 0), rgb)",
    ] {
        assert_parity(&format!(
            "@use \"sass:color\";\n@use \"sass:meta\";\na {{b: meta.inspect({c})}}\n"
        ));
    }
}

#[test]
fn parity_fuzz_boundary_legacy_form() {
    // Every legacy-form decision runs through dart's `fuzzyEquals`, whose 1e11
    // rounding clause is what separates these from an ordinary integer: a `0`
    // hue survives the invert a negative saturation asks for, a channel 6e-12
    // past 255 is out of gamut, and one 1e-10 short of it is neither integral
    // nor named.
    for c in [
        "color.change(hsl(120, 50%, 50%), $hue: 0, $saturation: -50%)",
        "color.adjust(hsl(0, 50%, 50%), $saturation: -100%)",
        "color.change(lch(50% 20 0), $chroma: -20)",
        "color.change(oklch(0.5 0.2 0), $chroma: -0.2)",
        "color.change(hsl(120, 50%, 50%), $saturation: -50%)",
        "color.change(hsl(90, 50%, 50%), $saturation: -0.000000000006%)",
        "color.change(hsl(90, 50%, 50%), $saturation: -0.0000000000004%)",
        "color.change(hsl(90, 50%, 50%), $saturation: -0%)",
        "color.change(red, $red: 255.000000000006)",
        "color.change(blue, $red: 255.000000000006, $blue: 0)",
        "color.change(red, $red: 254.9999999999)",
        "color.change(red, $red: 255.0000000001)",
        "color.change(red, $green: -0.0000000001)",
        "color.change(blue, $red: 255, $blue: 0)",
        "color.adjust(#ff0001, $blue: -1)",
        "color.change(red, $alpha: 0.9999999999999)",
        "color.change(red, $alpha: 0.999999999994)",
        "color.change(hsl(120, 50%, 50%), $alpha: 0.9999999999999)",
        "color.change(hwb(120 20% 30%), $alpha: 0.9999999999999)",
        "color.to-space(lab(50% 0.000000000006 0), lch)",
        "color.to-space(lab(50% 0.00000000006 0), lch)",
        "color.to-space(lab(50% 0.0000000000004 0), lch)",
        "color.to-space(oklab(0.5 0.000000000006 0), oklch)",
        "color.to-space(lch(0.000000000006% 20 90), lab)",
        "color.to-space(hsl(270, 0.000000000006%, 50%), rgb)",
    ] {
        let src = format!("@use \"sass:color\";\na {{b: {c}}}\n");
        assert_parity(&src);
        assert_parity_compressed(&src);
    }
}

#[test]
fn parity_modified_hue_reduced_before_conversion() {
    // dart builds the modified color in the working space through
    // `SassColor.forSpaceInternal`, which reduces a polar hue into `[0, 360)`
    // before the conversion back reads it. The ulp that separates
    // `(390 % 360) / 360` from `(390 / 360) % 1` decides whether a legacy rgb
    // result is an integer triple or a percentage one.
    for c in [
        "color.complement(rgba(10, 20, 30, 0.4))",
        "color.complement(rgba(turquoise, 0.7))",
        "color.adjust(rgba(10, 20, 30, 0.4), $hue: 180)",
        "color.adjust(rgba(10, 20, 30, 0.4), $hue: -180)",
        "color.adjust(rgba(10, 20, 30, 0.4), $hue: 540)",
        "color.adjust(hsl(210, 50%, 40%), $hue: 180)",
        "color.adjust(oklch(0.5 0.2 200), $hue: 400)",
        "color.adjust(lch(50% 20 200), $hue: -400)",
        "color.adjust(hwb(200 20% 30%), $hue: 400)",
        "color.change(hsl(120, 50%, 50%), $saturation: -100%)",
    ] {
        let src = format!("@use \"sass:color\";\na {{b: {c}}}\n");
        assert_parity(&src);
        assert_parity_compressed(&src);
    }
}

#[test]
fn parity_modify_color_named_first_arg() {
    // `$color` passed by name (e.g. with a non-legacy color and an explicit
    // working space) must not be treated as a channel.
    assert_parity(
        "@use \"sass:color\";\na {b: color.scale($color: color(a98-rgb 0.2 0.5 0.7), $red: 12%, $green: 24%, $blue: 48%)}\n",
    );
    assert_parity("@use \"sass:color\";\na {b: color.adjust($color: red, $red: 10)}\n");
    assert_parity("@use \"sass:color\";\na {b: color.change($color: red, $hue: 120)}\n");
    assert_parity("@use \"sass:color\";\na {b: color.scale(color(display-p3 0.2 0.5 0.7), $red: 12%)}\n");
}

#[test]
fn parity_selector_unify_leading_combinator() {
    // selector.unify preserves a leading combinator (dart-sass's
    // `leadingCombinators`); two different leading combinators can't unify.
    assert_parity("@use \"sass:selector\";\na {b: selector.unify(\"> .c\", \".d\")}\n");
    assert_parity("@use \"sass:selector\";\na {b: selector.unify(\".c\", \"~ .d\")}\n");
    assert_parity("@use \"sass:selector\";\na {b: selector.unify(\"+ .c\", \"+ .d\")}\n");
    assert_parity("@use \"sass:selector\";\na {b: selector.unify(\"> .c .d\", \".e\")}\n");
    // No leading combinator: unchanged.
    assert_parity("@use \"sass:selector\";\na {b: selector.unify(\".a .b\", \".c .d\")}\n");
}

#[test]
fn parity_selector_empty_namespace() {
    // The selector-string parser accepts the empty namespace (`|c`, `|*`),
    // which feeds the namespace-aware unify/extend/superselector logic.
    assert_parity("@use \"sass:selector\";\na {b: selector.unify(\"|c\", \"|c\")}\n");
    assert_parity("@use \"sass:selector\";\na {b: selector.unify(\"*|c\", \"|c\")}\n");
    assert_parity("@use \"sass:selector\";\na {b: selector.unify(\"*|c\", \"|*\")}\n");
    assert_parity(
        "@use \"sass:selector\";\n@use \"sass:meta\";\na {b: meta.inspect(selector.unify(\"c\", \"|c\"))}\n",
    );
    assert_parity(
        "@use \"sass:selector\";\n@use \"sass:meta\";\na {b: meta.inspect(selector.unify(\"|c\", \"|d\"))}\n",
    );
    // As actual style-rule selectors.
    assert_parity("|c {x: y}\n|* {x: y}\n*|c {x: y}\n");
}

#[test]
fn parity_selector_unify_host() {
    // A `:host`/`:host-context` pseudo can't unify into a compound with an
    // incompatible simple (class/type/universal/ordinary pseudo-class) → null;
    // it may coexist with selector-list pseudos (`:is`/`:where`).
    if !enabled() {
        return;
    }
    let null_cases = [
        ("\":host(.c)\"", "\".d\""),
        ("\".c\"", "\":host(.d)\""),
        ("\":host\"", "\".c\""),
        ("\":host\"", "\":hover\""),
        ("\":host\"", "\"*\""),
        ("\"*\"", "\":host\""),
        ("\":host\"", "\":host.c\""),
        ("\":host-context(.c)\"", "\".d\""),
    ];
    for (a, b) in null_cases {
        let scss = format!(
            "@use \"sass:selector\";\n@use \"sass:meta\";\na {{b: meta.inspect(selector.unify({a}, {b}))}}\n"
        );
        let ours = compile(&scss, &Options::default()).ok();
        match dart_sass(&scss) {
            Some(theirs) => assert_eq!(ours.as_deref(), Some(theirs.as_str()), "\nunify({a}, {b})"),
            None => eprintln!("skipping :host unify case: dart-sass unavailable"),
        }
    }
}

#[test]
fn parity_selector_extend_into_pseudos() {
    // selector.extend / selector.replace recurse into selector-list pseudo
    // arguments (`:is`/`:where`/`:matches`/`:not`), and a self-referential
    // extender converges (no unbounded growth).
    assert_parity("@use \"sass:selector\";\na {b: selector.extend(\".x\", \".x\", \".x .y\")}\n");
    assert_parity("@use \"sass:selector\";\na {b: selector.extend(\":is(.c)\", \".c\", \".d\")}\n");
    assert_parity("@use \"sass:selector\";\na {b: selector.extend(\":is(.c)\", \".c\", \".d, .e\")}\n");
    assert_parity("@use \"sass:selector\";\na {b: selector.extend(\":where(.x)\", \".x\", \".x .y\")}\n");
    assert_parity("@use \"sass:selector\";\na {b: selector.extend(\":matches(.c)\", \".c\", \".d\")}\n");
    assert_parity("@use \"sass:selector\";\na {b: selector.extend(\":not(.c)\", \".c\", \".d\")}\n");
    assert_parity("@use \"sass:selector\";\na {b: selector.extend(\":not(.c.d)\", \".c\", \".e\")}\n");
    assert_parity("@use \"sass:selector\";\na {b: selector.extend(\":is(.c) .e\", \".c\", \".d\")}\n");
    assert_parity("@use \"sass:selector\";\na {b: selector.replace(\":is(.c)\", \".c\", \".d\")}\n");
}

#[test]
fn parity_selector_nth_child_anb() {
    // `:nth-child`/`:nth-last-child` An+B arguments are canonicalized
    // (`2n + 1` → `2n+1`, `2N + 1` → `2n+1`); other nth pseudos and uppercased
    // names stay verbatim.
    assert_parity("@use \"sass:selector\";\na {b: selector.unify(\":nth-child(2n + 1)\", \"a\")}\n");
    assert_parity("@use \"sass:selector\";\na {b: selector.unify(\":nth-last-child(3n - 2)\", \"a\")}\n");
    assert_parity(
        "@use \"sass:selector\";\na {b: selector.is-superselector(\":nth-child(2n+1)\", \":nth-child(2n + 1)\")}\n",
    );
    assert_parity("@use \"sass:selector\";\na {b: selector.unify(\":nth-of-type(3n - 2)\", \"a\")}\n");
}

#[test]
fn parity_selector_extend_nth_of() {
    // `:nth-child(An+B of <selector>)` extends only its `of` selector; a nested
    // same-An+B nth pseudo in the extender merges (deduped), a different-An+B
    // one is dropped.
    assert_parity(
        "@use \"sass:selector\";\na {b: selector.extend(\":nth-child(2n+1 of .c)\", \".c\", \".d\")}\n",
    );
    assert_parity(
        "@use \"sass:selector\";\na {b: selector.extend(\":nth-child(2n+1 of .c)\", \".c\", \".d, .e\")}\n",
    );
    assert_parity(
        "@use \"sass:selector\";\na {b: selector.extend(\":nth-child(2n+1 of .c)\", \".c\", \":nth-child(2n+1 of .d, .e)\")}\n",
    );
    assert_parity(
        "@use \"sass:selector\";\na {b: selector.extend(\":nth-child(2n+1 of .c)\", \".c\", \":nth-child(2n+2 of .d, .e)\")}\n",
    );
    assert_parity(
        "@use \"sass:selector\";\na {b: selector.replace(\":nth-last-child(2n+1 of .c)\", \".c\", \".d\")}\n",
    );
}

#[test]
fn parity_selector_vendor_prefixed_pseudos() {
    // A vendor prefix on a selector pseudo (`:-pfx-is`, `:-ms-matches`) is
    // stripped (dart-sass `unvendor`) for the selector-pseudo family check, so
    // unify/extend/is-superselector treat it as its base pseudo — but the full
    // (prefixed) name must match to merge a nested one.
    assert_parity(
        "@use \"sass:selector\";\na {b: selector.is-superselector(\":-pfx-is(c d, e f, g h)\", \"c d\")}\n",
    );
    assert_parity("@use \"sass:selector\";\na {b: selector.extend(\":-ms-matches(.c)\", \".c\", \".d\")}\n");
    assert_parity(
        "@use \"sass:selector\";\na {b: selector.extend(\":-ms-matches(.c)\", \".c\", \":-ms-matches(.d, .e)\")}\n",
    );
    // Different vendor prefix does not merge.
    assert_parity(
        "@use \"sass:selector\";\na {b: selector.extend(\":-ms-matches(.c)\", \".c\", \":-moz-matches(.d, .e)\")}\n",
    );
}

#[test]
fn parity_selector_is_superselector_not() {
    // dart-sass `:not(S1)` superselector rule (contravariant): `:not(c.d)` is a
    // superselector of `e` (a different type can never match `c.d`), and a
    // same-name `:not` whose argument supersedes each complex covers it.
    assert_parity("@use \"sass:selector\";\na {b: selector.is-superselector(\":not(c.d)\", \"e\")}\n");
    assert_parity("@use \"sass:selector\";\na {b: selector.is-superselector(\":not(#c.d)\", \"#e\")}\n");
    assert_parity(
        "@use \"sass:selector\";\na {b: selector.is-superselector(\":not(c d.i, e j f)\", \":not(c d, e f, g h)\")}\n",
    );
    assert_parity(
        "@use \"sass:selector\";\na {b: selector.is-superselector(\":not(c d.i):not(e j f)\", \":not(c d, e f, g h)\")}\n",
    );
    // Not a superselector when the type can still match.
    assert_parity("@use \"sass:selector\";\na {b: selector.is-superselector(\":not(c.d)\", \"c\")}\n");
}

#[test]
fn parity_selector_combinator_runs() {
    // A "bogus" combinator run — a leading run (`~ ~ c`) or a run between
    // compounds (`c > > d`) — is preserved through parse/nest/append, and two
    // different leading runs can't unify.
    assert_parity("@use \"sass:selector\";\n@use \"sass:meta\";\na {b: meta.inspect(selector.nest(\"c > > d\", \"e\"))}\n");
    assert_parity("@use \"sass:selector\";\n@use \"sass:meta\";\na {b: meta.inspect(selector.nest(\"~ ~ c\", \"d\"))}\n");
    assert_parity("@use \"sass:selector\";\n@use \"sass:meta\";\na {b: meta.inspect(selector.nest(\"c\", \"+ > d\"))}\n");
    assert_parity(
        "@use \"sass:selector\";\n@use \"sass:meta\";\na {b: meta.inspect(selector.unify(\"+ ~ > .c\", \"+ > ~ ~ .d\"))}\n",
    );
}

#[test]
fn parity_selector_trailing_combinators() {
    // Trailing combinator runs (`c >`, `d + >`) and combinator-only selectors
    // (`>`) round-trip through nest; append rejects them, and a bogus
    // trailing-combinator @extend extender is dropped.
    assert_parity("@use \"sass:selector\";\n@use \"sass:meta\";\na {b: meta.inspect(selector.nest(\"c\", \"d + >\"))}\n");
    assert_parity("@use \"sass:selector\";\n@use \"sass:meta\";\na {b: meta.inspect(selector.nest(\"c\", \">\", \"d\"))}\n");
    assert_parity(
        "@use \"sass:selector\";\n@use \"sass:meta\";\na {b: meta.inspect(selector.nest(\"c ~\", \"d\"))}\n",
    );
    if enabled() {
        // append rejects a combinator-only / trailing-combinator selector.
        for scss in [
            "@use \"sass:selector\";\na {b: selector.append(\".c\", \">\", \".d\")}\n",
            "@use \"sass:selector\";\na {b: selector.append(\".c ~\", \".d\")}\n",
        ] {
            assert!(compile(scss, &Options::default()).is_err());
            assert!(dart_sass(scss).is_none());
        }
    }
    // A bogus trailing-combinator @extend extender is a no-op.
    assert_parity("a {b: c}\nd + {@extend a}\n");
}

#[test]
fn parity_selector_unify_legacy_pseudo_element() {
    // A legacy single-colon pseudo-element unifies with its double-colon form
    // (`:after` ≡ `::after`), keeping the base's spelling; two different
    // pseudo-elements still can't share a compound.
    assert_parity("@use \"sass:selector\";\n@use \"sass:meta\";\na {b: meta.inspect(selector.unify(\":after\", \"::after\"))}\n");
    assert_parity("@use \"sass:selector\";\n@use \"sass:meta\";\na {b: meta.inspect(selector.unify(\"::after\", \":after\"))}\n");
    assert_parity("@use \"sass:selector\";\n@use \"sass:meta\";\na {b: meta.inspect(selector.unify(\"a:after\", \"a::after\"))}\n");
    assert_parity("@use \"sass:selector\";\n@use \"sass:meta\";\na {b: meta.inspect(selector.unify(\"::before\", \"::after\"))}\n");
}

#[test]
fn parity_selector_unify_host_is_order() {
    // Unifying a `:host`/`:host-context` with selector-list pseudos orders the
    // host after the first wrapper: `:host(.c)` + `:is(.d)` → `:is(.d):host(.c)`,
    // and `:host` + `:is(.c):is(.d)` → `:is(.c):host:is(.d)`.
    assert_parity("@use \"sass:selector\";\n@use \"sass:meta\";\na {b: meta.inspect(selector.unify(\":host(.c)\", \":is(.d)\"))}\n");
    assert_parity("@use \"sass:selector\";\n@use \"sass:meta\";\na {b: meta.inspect(selector.unify(\":host\", \":is(.c):is(.d)\"))}\n");
    assert_parity("@use \"sass:selector\";\n@use \"sass:meta\";\na {b: meta.inspect(selector.unify(\":host\", \":is(.c)\"))}\n");
    assert_parity("@use \"sass:selector\";\n@use \"sass:meta\";\na {b: meta.inspect(selector.unify(\":host-context(.c)\", \":is(.d)\"))}\n");
}

#[test]
fn parity_url_whitespace_normalization() {
    // dart-sass normalizes whitespace inside a plain `url(...)`: leading and
    // trailing whitespace is trimmed and each internal run collapses to a
    // single space (matching `_tryUrlContents`). Interpolation and a literal
    // `/* */` (not whitespace) are preserved verbatim.
    assert_parity("a {b: url(  c)}\n");
    assert_parity("a {b: url(c  )}\n");
    assert_parity("a {b: url( a  b )}\n");
    assert_parity("a {b: url(   )}\n");
    assert_parity("a {b: url(  #{1 + 1}  x  )}\n");
    assert_parity("a {b: url(a/**/b)}\n");
    assert_parity("a {b: url(  \"x y\"  )}\n");
}

#[test]
fn parity_strip_sourcemap_comment() {
    // dart-sass strips a `/*# sourceMappingURL=… */` / `/*# sourceURL=… */`
    // loud comment; the `# ` space is required, so a no-space or `/*!` form and
    // other names are kept. (dart leaves a trailing blank line where the
    // stripped comment was — spec-normalized away — so compare trim-trailing.)
    if !enabled() {
        return;
    }
    for scss in [
        "a {b: c}\n/*# sourceMappingURL=x */\n",
        "a {b: c}\n/*# sourceURL=x */\n",
        "a {b: c}\n/* normal */\n",
        "a {b: c}\n/*#sourceMappingURL=x*/\n",
        "a {b: c}\n/*! sourceMappingURL=x */\n",
    ] {
        let ours = compile(scss, &Options::default()).expect("compile failed");
        if let Some(theirs) = dart_sass(scss) {
            assert_eq!(ours.trim_end(), theirs.trim_end(), "\n--- scss ---\n{scss}\n");
        }
    }
}

#[test]
fn parity_selector_list_newlines() {
    // dart-sass preserves a source newline before a comma-separated complex
    // selector (`a,\nb` stays on two lines), but a part that references the
    // parent with `&` takes the parent's line-break, not its own — so
    // `&.x,\n&.y` under a single parent collapses back to one line.
    assert_parity("a,\nb {\n  x: y;\n}\n");
    assert_parity(".a {\n  b,\n  c {\n    x: y;\n  }\n}\n");
    assert_parity("a {\n  &.div,\n  &.span {\n    display: block;\n  }\n}\n");
    assert_parity(".a {\n  &,\n  .b {\n    x: y;\n  }\n}\n");
    assert_parity("a,\nb, {\n  x: y;\n}\n");
    // @extend through a `&,\n&` selector list still collapses to one line.
    assert_parity("%h {\n  &:hover,\n  &:focus {\n    o: 1;\n  }\n}\n.l {\n  @extend %h;\n}\n");
}

#[test]
fn parity_multi_unit_numbers() {
    // Multi-unit numbers (dart-sass SassNumber numerator/denominator lists):
    // multiplication/division cancel convertible units (scaling the value) and
    // keep the rest; the result serializes in calc form everywhere
    // (`calc(1px * 1em)`, `calc(1 / 1px)`), `math.unit()` reports the
    // unitString (`px*em`, `px^-1`, `px*em/(rad*s)`), and a slash value
    // carries the true quotient for forced arithmetic.
    assert_parity(
        "@use \"sass:math\";\n@use \"sass:meta\";\na {\n  m1: 1px * 1em;\n  d1: math.div(1px, 1s);\n  d2: math.div(1, 1px);\n  u1: math.unit(1px * 1em * 1rad);\n  u3: math.unit(math.div(math.div(1px, 1em), math.div(1rad, 1s)));\n  u5: math.unit(math.div(1px, 1em));\n  c1: meta.inspect(math.div(1px, 1s));\n  abs: math.abs(math.div(-1px, 1s));\n  i1: math.div(1, 0px);\n  i2: math.div(1px * 1em, 0);\n  i3: math.div(1px, 0em);\n  cancel: math.div(math.div(1px, 1s), math.div(1px, 1s));\n}\n",
    );
    // Inside calc: products/quotients fold into one multi-unit number, with
    // unit conversion on cancellation (`* 1s` against a `/ms` denominator
    // scales by 1000); convertible-complex sums fold, incompatible ones error.
    assert_parity(
        "@use \"sass:math\";\n$number: math.div(1px * 1rad, 1ms * 1Hz);\na {\n  c1: calc($number / (1px / 1ms));\n  c2: calc($number / 1px);\n  c3: calc($number * 1ms);\n  c5: calc($number * 1s);\n  c6: calc(1 / (1 / 1px / 1rad));\n  c7: calc(1 / (1px * 1rad));\n  m: calc(2px * 3px) / 4px;\n  inv: calc(infinity / 1px);\n}\n",
    );
    // clamp/min with EQUAL complex units computes (`calc(4px * 1px)`).
    assert_parity("a {b: clamp(1px*1px, 2px*2px, 3px*3px)}\n");
    assert_error_parity("a {b: (1px * 1em) + 1px}\n");
    assert_error_parity("a {b: calc(min(1px*1px, 2em*2em))}\n");
}

#[test]
fn parity_out_of_range_lightness_color_mix() {
    // A lab/lch/oklab/oklch lightness outside [0, 100%] can't round-trip
    // through the space's own syntax (the CSS parser clamps it), so it
    // serializes as `color-mix(in <space>, color(xyz <unclamped>) 100%, black)`.
    // Boundary values (exactly 0/100) and missing lightness stay in the
    // own-space form; alpha rides inside the xyz color.
    assert_parity(
        "@use \"sass:color\";\na {\n  b: color.change(lab(50% 1 1), $lightness: -1%);\n  c: color.change(lab(50% 1 1), $lightness: 101%);\n  d: color.change(lch(50% 10 10deg), $lightness: -1%);\n  e: color.change(oklab(50% 0.1 0.1), $lightness: 101%);\n  f: color.change(oklch(50% 0.1 10deg), $lightness: -1%);\n  g: color.change(lab(50% 1 1 / 0.5), $lightness: -1%);\n}\n",
    );
    assert_parity(
        "@use \"sass:color\";\na {\n  zero: color.change(lab(50% 1 1), $lightness: 0%);\n  hundred: color.change(lab(50% 1 1), $lightness: 100%);\n  missing: lab(none 1 1);\n  okboundary: color.change(oklch(50% 0.1 10deg), $lightness: 100%);\n}\n",
    );
}

#[test]
fn parity_legacy_conversion_fills_missing() {
    // Converting a color to a LEGACY space (to-space, or the round-trip inside
    // scale/adjust/to-gamut with $space) zero-fills missing channels and a
    // missing alpha, yielding the plain comma form — while authored and
    // `color.change`d missing channels keep the modern `none` form (same-space
    // conversion is the identity).
    assert_parity(
        "@use \"sass:color\";\na {\n  conv: color.to-space(hsl(none 50% 50%), hwb);\n  same: color.to-space(hsl(none 50% 50%), hsl);\n  scaled: color.scale(hsl(none 50% 50%), $space: hwb);\n  modern: color.to-space(color.change(oklch(50% 0.1 10deg), $lightness: none), hsl);\n  alpha: color.to-space(color.change(oklch(50% 0.1 10deg / none), $lightness: none), hsl);\n  authored: hsl(none 50% 50%);\n  changed: color.change(hsl(10deg, 50%, 50%), $saturation: none);\n}\n",
    );
}

#[test]
fn parity_pseudo_argument_whitespace() {
    // dart-sass trims whitespace immediately inside a pseudo's argument parens.
    // Leading whitespace is always dropped; trailing whitespace is dropped for a
    // pseudo-CLASS or a selector-argument pseudo-element (`::slotted`), but KEPT
    // for a text-argument pseudo-element (`::part`, `::highlight`).
    for sel in [
        ":nth-of-type( 2n - 1 )",
        ":nth-of-type(2n-  1)",
        ":nth-of-type(2n  -1)",
        ":not( .a )",
        ":lang(  en  )",
        ":has(  > .a  )",
        "::slotted(  .x  )",
        "::part( foo )",
        "::part(foo )",
        "::highlight( h )",
    ] {
        assert_parity(&format!("{sel} {{ color: red; }}\n"));
    }
}

#[test]
fn weave_combinator_runs_match_dart() {
    // dart-sass's `_weaveParents` family: combinator runs (leading, trailing,
    // multi) survive `selector.extend`/`selector.unify` losslessly, merge by
    // dart's `_mergeLeadingCombinators`/`_mergeTrailingCombinators` rules, and
    // bogus (multi-run) results are dropped as useless.
    let go = |args: &str| {
        ours(&format!(
            "@use \"sass:selector\";\na {{b: selector.extend({args})}}\n"
        ))
    };
    // Leading combinator on the extender is preserved.
    assert_eq!(go("\".c\", \".c\", \"+ .d\""), "a {\n  b: .c, + .d;\n}\n");
    // Two different leading combinators can't merge: extension fails.
    assert_eq!(go("\"~ .c\", \".c\", \"+ .d\""), "a {\n  b: ~ .c;\n}\n");
    // A trailing run on the selector is preserved on the extension.
    assert_eq!(go("\".c +\", \".c\", \".d\""), "a {\n  b: .c +, .d +;\n}\n");
    // The extender's trailing combinator becomes the join combinator.
    assert_eq!(
        go("\".c .d\", \".c\", \".e >\""),
        "a {\n  b: .c .d, .e > .d;\n}\n"
    );
    // Conflicting trailing combinators can't merge.
    assert_eq!(go("\".c ~\", \".c\", \".d >\""), "a {\n  b: .c ~;\n}\n");
    // A multi-combinator run anywhere makes the extension useless.
    assert_eq!(go("\".c ~ ~ .d\", \".c\", \".e\""), "a {\n  b: .c ~ ~ .d;\n}\n");
    assert_eq!(go("\".c\", \".c\", \".d ~ + .e\""), "a {\n  b: .c;\n}\n");
    assert_eq!(go("\"> + .c\", \".c\", \".d\""), "a {\n  b: > + .c;\n}\n");
    // A combinator-only extender replaces the compound wholesale.
    assert_eq!(go("\".c\", \".c\", \">\""), "a {\n  b: .c, >;\n}\n");
    assert_eq!(go("\".c .d\", \".c\", \"~\""), "a {\n  b: .c .d, ~ .d;\n}\n");
    // `selector.unify` rejects any multi-combinator run (dart `isUseless`).
    assert_eq!(
        ours("@use \"sass:selector\";\na {b: selector.unify(\".c + ~ > .d\", \".e + ~ > .f\")}\n"),
        ""
    );
    // `is-superselector` is false either way for a bogus trailing run.
    assert_eq!(
        ours(concat!(
            "@use \"sass:meta\";\n@use \"sass:selector\";\n",
            "a {b: meta.inspect(selector.is-superselector(\".c\", \".c >\"))}\n",
            "c {d: meta.inspect(selector.is-superselector(\".c >\", \".c\"))}\n"
        )),
        "a {\n  b: false;\n}\n\nc {\n  d: false;\n}\n"
    );
}

#[test]
fn selector_arg_pseudo_superselector_rules() {
    // dart-sass `_selectorPseudoIsSuperselector` for `:nth-child(An+B of S)` /
    // `:nth-last-child` (same name + An+B, `of` lists compared as selectors),
    // the `::slotted` argument rule, and `SimpleSelector.isSuperselector`'s
    // subselector-pseudos rule (`c` covers `:nth-child(n+1 of c)`).
    let go = |s1: &str, s2: &str| {
        ours(&format!(
            "@use \"sass:selector\";\na {{b: selector.is-superselector(\"{s1}\", \"{s2}\")}}\n"
        ))
    };
    let yes = "a {\n  b: true;\n}\n";
    let no = "a {\n  b: false;\n}\n";
    assert_eq!(go(":nth-child(2n of c, d)", ":nth-child(2n of c)"), yes);
    assert_eq!(go(":nth-child(2n of c, d)", "e:nth-child(2n of c)"), yes);
    assert_eq!(go(":nth-child(2n of c)", ":nth-child(3n of c)"), no);
    assert_eq!(go(":nth-last-child(2n of c, d)", ":nth-last-child(2n of c)"), yes);
    assert_eq!(
        go(
            ":-pfx-nth-child(n+1 of c d, e f)",
            ":-pfx-nth-child(n+1 of c d.i)"
        ),
        yes
    );
    assert_eq!(go("::slotted(c, d)", "::slotted(c)"), yes);
    assert_eq!(go("e::slotted(c, d)", "e::slotted(c)"), yes);
    assert_eq!(go("::-pfx-slotted(c d, e f)", "::-pfx-slotted(c d.i)"), yes);
    assert_eq!(go("c", ":nth-child(n+1 of c)"), yes);
    assert_eq!(go("c", ":nth-child(n+1 of d)"), no);
}

#[test]
fn slotted_and_current_pseudo_arg_extend() {
    // dart-sass `_extendPseudo` runs for every selector-bearing pseudo,
    // including the pseudo-element `::slotted`; a nested same-name `:current`
    // is unwrapped and merged, and re-extension settles (deduped argument).
    let go = |args: &str| {
        ours(&format!(
            "@use \"sass:selector\";\na {{b: selector.extend({args})}}\n"
        ))
    };
    assert_eq!(
        go("\"::slotted(.c)\", \".c\", \".d\""),
        "a {\n  b: ::slotted(.c, .d);\n}\n"
    );
    assert_eq!(
        go("\"::slotted(.c)\", \".c\", \"::slotted(.d)\""),
        "a {\n  b: ::slotted(.c, ::slotted(.d));\n}\n"
    );
    assert_eq!(
        go("\":current(.c)\", \".c\", \":current(.d, .e)\""),
        "a {\n  b: :current(.c, .d, .e);\n}\n"
    );
}

#[test]
fn plain_css_at_rules() {
    // Plain-CSS (.css) at-rules: top-level pass-through with canonical media
    // serialization, first-level bubbling around a copy of the parent rule,
    // and native (in-place) nesting below that (dart `_hasCssNesting`).
    let dir = std::env::temp_dir().join(format!("sasso_plain_atrule_{}", std::process::id()));
    std::fs::create_dir_all(&dir).expect("create scratch dir");
    let imp = FsImporter::new(vec![dir.clone()]);
    let opts = Options::default().with_importer(&imp);
    let go = |css: &str| {
        std::fs::write(dir.join("plain.css"), css).expect("write plain.css");
        cli_form(compile("@use \"plain\";\n", &opts).expect("plain css compile"))
    };
    // Canonical media-logic serialization (mixed case normalized).
    assert_eq!(
        go("@media (a) AnD (b) {x {y: z}}\n"),
        "@media (a) and (b) {\n  x {\n    y: z;\n  }\n}\n"
    );
    assert_eq!(
        go("@media a and not (b) {x {y: z}}\n"),
        "@media a and not (b) {\n  x {\n    y: z;\n  }\n}\n"
    );
    // First-level @media bubbles out around a copy of the parent rule.
    assert_eq!(
        go("a {@media b {c: d}}\n"),
        "@media b {\n  a {\n    c: d;\n  }\n}\n"
    );
    // Below the first nesting level it stays in place (native CSS nesting).
    assert_eq!(
        go("a { b {@media c {d: e}}}\n"),
        "a {\n  b {\n    @media c {\n      d: e;\n    }\n  }\n}\n"
    );
    // Childless rules are invisible, recursively.
    assert_eq!(go("a {}\n"), "");
    assert_eq!(go("a { b {} c: d}\n"), "a {\n  c: d;\n}\n");
    let _ = std::fs::remove_dir_all(&dir);
}

#[test]
fn plain_css_value_semantics() {
    // In a plain-CSS module no function is invoked: calls re-serialize with
    // their arguments (dart-sass `plainCss`), keywords are plain identifiers,
    // and CSS calculations still simplify.
    let dir = std::env::temp_dir().join(format!("sasso_plain_value_{}", std::process::id()));
    std::fs::create_dir_all(&dir).expect("create scratch dir");
    let imp = FsImporter::new(vec![dir.clone()]);
    let opts = Options::default().with_importer(&imp);
    let go = |css: &str| {
        std::fs::write(dir.join("plain.css"), css).expect("write plain.css");
        cli_form(compile("@use \"plain\";\n", &opts).expect("plain css compile"))
    };
    assert_eq!(go("a {b: alpha(0.1)}\n"), "a {\n  b: alpha(0.1);\n}\n");
    assert_eq!(go("a {b: rgb(255 0 0)}\n"), "a {\n  b: rgb(255 0 0);\n}\n");
    assert_eq!(go("a {b: RGB(1,2,3)}\n"), "a {\n  b: RGB(1, 2, 3);\n}\n");
    assert_eq!(go("a {b: min(1px, 2px)}\n"), "a {\n  b: 1px;\n}\n");
    assert_eq!(go("a {x: null}\n"), "a {\n  x: null;\n}\n");
    assert_eq!(go("a {b: true}\n"), "a {\n  b: true;\n}\n");
    // The `:x: y` IE property hack parses as a declaration.
    assert_eq!(go(".hacks {*x: y; :x: y}\n"), ".hacks {\n  *x: y;\n  :x: y;\n}\n");
    let _ = std::fs::remove_dir_all(&dir);
}

#[test]
fn colon_property_hack_scss() {
    // The leading-`:` property hack also parses in SCSS (dart-sass reads one
    // leading punctuation character before the property identifier).
    assert_eq!(ours("a {:x: y}\n"), "a {\n  :x: y;\n}\n");
    // A pseudo-selector block is still a nested rule, not a declaration.
    assert_eq!(ours("b {:hover {c: d}}\n"), "b :hover {\n  c: d;\n}\n");
}

#[test]
fn import_plain_css_file() {
    // `@import "x"` resolves a plain `.css` file after the Sass candidates but
    // before index files, loads it in plain-CSS mode, and nests its outermost
    // rules under an enclosing Sass rule (inner nesting stays native).
    let dir = std::env::temp_dir().join(format!("sasso_import_css_{}", std::process::id()));
    std::fs::create_dir_all(dir.join("both")).expect("create scratch dir");
    let imp = FsImporter::new(vec![dir.clone()]);
    let opts = Options::default().with_importer(&imp);

    std::fs::write(dir.join("plain.css"), "a { b {c: d}}\n").unwrap();
    assert_eq!(
        compile("@import \"plain\";\n", &opts).expect("import css"),
        "a {\n  b {\n    c: d;\n  }\n}"
    );
    assert_eq!(
        compile("x {@import \"plain\";}\n", &opts).expect("nested import css"),
        "x a {\n  b {\n    c: d;\n  }\n}"
    );

    // css beats index.
    std::fs::write(dir.join("both.css"), "css {x: y}\n").unwrap();
    std::fs::write(dir.join("both").join("index.scss"), "idx {x: y}\n").unwrap();
    assert_eq!(
        compile("@import \"both\";\n", &opts).expect("css before index"),
        "css {\n  x: y;\n}"
    );

    // An adjacent .scss still wins over .css.
    std::fs::write(dir.join("plain.scss"), "scss {x: y}\n").unwrap();
    assert_eq!(
        compile("@import \"plain\";\n", &opts).expect("scss wins"),
        "scss {\n  x: y;\n}"
    );
    let _ = std::fs::remove_dir_all(&dir);
}

#[test]
fn import_implicit_configuration() {
    // dart-sass: an `@import`ed file's `@forward`s see every variable visible
    // at the import as an implicit configuration for `!default` variables.
    let dir = std::env::temp_dir().join(format!("sasso_import_cfg_{}", std::process::id()));
    std::fs::create_dir_all(&dir).expect("create scratch dir");
    let imp = FsImporter::new(vec![dir.clone()]);
    let opts = Options::default().with_importer(&imp);
    std::fs::write(dir.join("_midstream.scss"), "@forward \"upstream\";\n").unwrap();
    std::fs::write(dir.join("_upstream.scss"), "$a: original !default;\nb {c: $a}\n").unwrap();
    assert_eq!(
        compile("$a: configured;\n@import \"midstream\";\n", &opts).expect("import cfg"),
        "b {\n  c: configured;\n}"
    );
    // Without a matching variable the default applies; the unconsumed
    // implicit entry is not an error.
    assert_eq!(
        compile("$other: x;\n@import \"midstream\";\n", &opts).expect("unrelated"),
        "b {\n  c: original;\n}"
    );
    let _ = std::fs::remove_dir_all(&dir);
}

#[test]
fn round_calculation_semantics() {
    // CSS `round()` is a calculation: arguments fold as calc expressions
    // (`1px + 4px` -> `5px`), unsimplifiable operands preserve the call with
    // the folded subtrees, a leading strategy keyword participates as a
    // keyword, and a SassScript-only operator falls back to the legacy
    // one-argument math.round (arity error for more).
    assert_eq!(
        ours("a {b: round(3.4px + 10%, 1px + 4px)}\n"),
        "a {\n  b: round(3.4px + 10%, 5px);\n}\n"
    );
    assert_eq!(
        ours("a {b: round(1.4px + var(--a))}\n"),
        "a {\n  b: round(1.4px + var(--a));\n}\n"
    );
    assert_eq!(
        ours("a {b: round(1px + 0%, 1px + 0%)}\n"),
        "a {\n  b: round(1px + 0%, 1px + 0%);\n}\n"
    );
    assert_eq!(ours("a {b: round(#{\"up\"}, 3px, 9px)}\n"), "a {\n  b: 9px;\n}\n");
    assert_eq!(ours("a {b: round(2.5)}\n"), "a {\n  b: 3;\n}\n");
    assert!(compile("a {b: round(7 % 3, 1)}\n", &Options::default()).is_err());
}

#[test]
fn sign_and_minmax_calculation_semantics() {
    // `sign()` keeps the operand's full units (also for zero), `±0` passes
    // through (`1 / sign(-0.0)` is `-infinity`), and a `%` operand preserves
    // the call. `min`/`max` arguments fold as calc expressions and preserve
    // the call with folded subtrees when an operand doesn't simplify.
    assert_eq!(ours("a {b: sign(0px)}\n"), "a {\n  b: 0px;\n}\n");
    assert_eq!(ours("a {b: sign(7%)}\n"), "a {\n  b: sign(7%);\n}\n");
    assert_eq!(ours("a {b: sign(-7px / 4em) * 1em}\n"), "a {\n  b: -1px;\n}\n");
    assert_eq!(
        ours("@use \"sass:math\";\na {b: math.div(1, sign(-0.0))}\n"),
        "a {\n  b: calc(-infinity);\n}\n"
    );
    assert_eq!(
        ours("a {b: min(1px + 2px - var(--c), 5px)}\n"),
        "a {\n  b: min(3px - var(--c), 5px);\n}\n"
    );
    assert_eq!(
        ours("a {b: max(5px, 1px + var(--c))}\n"),
        "a {\n  b: max(5px, 1px + var(--c));\n}\n"
    );
    assert_eq!(ours("a {b: min(3px + 4px, 10px)}\n"), "a {\n  b: 7px;\n}\n");
}

#[test]
fn calc_space_splice_and_minmax_compatibility() {
    // A space-separated calc run splices a string-valued variable verbatim
    // (`calc(1 $c)` with `$c: unquote("+ 2")` → `calc(1 + 2)`, unfolded);
    // a number-valued variable still has no operator.
    assert_eq!(
        ours(concat!(
            "@use \"sass:string\";\n$c: string.unquote(\"+ 2\");\n",
            "a {b: calc(1 $c)}\nc {d: calc($c 3)}\n"
        )),
        "a {\n  b: calc(1 + 2);\n}\n\nc {\n  d: calc(+ 2 3);\n}\n"
    );
    assert!(compile("$n: 2;\na {b: calc(1 $n)}\n", &Options::default()).is_err());
    // min/max fold sequentially with unitless comparable to anything; the
    // preserve path rejects a unitless operand paired with any unit.
    assert_eq!(ours("a {b: min(1c, 2)}\n"), "a {\n  b: 1c;\n}\n");
    assert_eq!(ours("a {b: max(2d, 3, 1c)}\n"), "a {\n  b: 3;\n}\n");
    assert_eq!(ours("a {b: min(1c, 2px)}\n"), "a {\n  b: min(1c, 2px);\n}\n");
    assert!(compile("a {b: min(3, 1c, 2d)}\n", &Options::default()).is_err());
    assert!(compile("a {b: min(1px, 2em, 3)}\n", &Options::default()).is_err());
}

#[test]
fn strict_unary_plus_minus() {
    // dart-sass strict-unary: in operator position with whitespace before but
    // not after, `+` is ALWAYS binary (`c +d` is `c + d`); `-` starts a new
    // space-list term only before a number or identifier.
    assert_eq!(ours("a {b: c +d}\n"), "a {\n  b: cd;\n}\n");
    assert_eq!(ours("a {b: 1 +2}\n"), "a {\n  b: 3;\n}\n");
    assert_eq!(ours("a {b: 10 +5px}\n"), "a {\n  b: 15px;\n}\n");
    assert_eq!(ours("a {b: c -d}\n"), "a {\n  b: c -d;\n}\n");
    assert_eq!(ours("a {b: 1 -2}\n"), "a {\n  b: 1 -2;\n}\n");
    assert_eq!(ours("$d: 5;\na {b: c -$d}\n"), "a {\n  b: c-5;\n}\n");
    assert_eq!(ours("a {b: 10 -(2)}\n"), "a {\n  b: 8;\n}\n");
    assert_eq!(ours("a {b: c -\"x\"}\n"), "a {\n  b: c-\"x\";\n}\n");
}

#[test]
fn interp_adjacency_and_unit_dash() {
    // Interpolation adjacency (dart `identifierLike` + implicit list
    // separators): `1#{0}` is the list `1 0`, `#{1}0` the single token `10`,
    // `10-#{10}` the list `10 -10`; a quoted string followed by `-ident`
    // starts a new term; a number's unit eats a trailing `-` unless a digit
    // follows; a color divided by a string slash-joins.
    assert_eq!(ours("a {b: 1#{0}}\n"), "a {\n  b: 1 0;\n}\n");
    assert_eq!(ours("a {b: #{1}0}\n"), "a {\n  b: 10;\n}\n");
    assert_eq!(ours("a {b: #{1}px}\n"), "a {\n  b: 1px;\n}\n");
    assert_eq!(ours("a {b: 10-#{10}}\n"), "a {\n  b: 10 -10;\n}\n");
    assert_eq!(ours("a {b: \"q\"-l}\n"), "a {\n  b: \"q\" -l;\n}\n");
    assert_eq!(ours("a {b: \"q\" - l}\n"), "a {\n  b: \"q\"-l;\n}\n");
    assert_eq!(ours("a {b: 10px- 10px}\n"), "a {\n  b: 10px- 10px;\n}\n");
    assert_eq!(ours("a {b: 10px-10px}\n"), "a {\n  b: 0px;\n}\n");
    assert_eq!(ours("a {b: 10em-1}\n"), "a {\n  b: 9em;\n}\n");
    assert_eq!(ours("a {b: #AAA/#{itpl}}\n"), "a {\n  b: #AAA/itpl;\n}\n");
}

#[test]
fn not_precedence_and_leading_slash() {
    // dart-sass: `not` is a unary operator over a single expression, binding
    // tighter than every binary operator; a leading `/` begins a slash value
    // with an empty left operand.
    assert_eq!(ours("a {b: not 1 + 2}\n"), "a {\n  b: false2;\n}\n");
    assert_eq!(ours("a {b: 1 + not 2}\n"), "a {\n  b: 1false;\n}\n");
    assert_eq!(
        ours("$a: false;\n$b: false;\na {b: not $a == $b}\n"),
        "a {\n  b: false;\n}\n"
    );
    assert_eq!(ours("a {b: not (1 == 1)}\n"), "a {\n  b: false;\n}\n");
    assert_eq!(ours("a {b: (1, / 2)}\n"), "a {\n  b: 1, /2;\n}\n");
    assert_eq!(ours("a {b: / 2}\n"), "a {\n  b: /2;\n}\n");
}

#[test]
fn import_forward_module_semantics() {
    // dart-sass @import-of-@forward: the module evaluates once (implicit
    // configuration doesn't re-configure it), its CSS re-emits at every
    // import site, forwarded assignments overwrite user globals but a
    // forwarded global keeps an intervening assignment, and a rule-scoped
    // import nests the module's CSS under the enclosing rule.
    let dir = std::env::temp_dir().join(format!("sasso_imp_fwd_{}", std::process::id()));
    std::fs::create_dir_all(&dir).expect("create scratch dir");
    let imp = FsImporter::new(vec![dir.clone()]);
    let opts = Options::default().with_importer(&imp);
    std::fs::write(dir.join("_other.scss"), "$a: original !default;\nb {c: $a}\n").unwrap();
    std::fs::write(dir.join("_other.import.scss"), "@forward \"other\";\n").unwrap();

    // Module CSS re-emits per import; second implicit config is ignored.
    assert_eq!(
        compile(
            "$a: configured;\n@import \"other\";\n$a: changed;\n@import \"other\";\n",
            &opts
        )
        .expect("import twice"),
        "b {\n  c: configured;\n}\n\nb {\n  c: configured;\n}"
    );
    // An intervening assignment to a forwarded global survives a re-import.
    assert_eq!(
        compile(
            "@import \"other\";\n$a: changed;\n@import \"other\";\nd {e: $a}\n",
            &opts
        )
        .expect("still changes"),
        "b {\n  c: original;\n}\n\nb {\n  c: original;\n}\n\nd {\n  e: changed;\n}"
    );
    // A rule-scoped import nests the module CSS under the rule.
    std::fs::write(dir.join("_mid.scss"), "@forward \"other\";\n").unwrap();
    assert_eq!(
        compile("a {\n  $a: configured;\n  @import \"mid\";\n}\n", &opts).expect("nested"),
        "a b {\n  c: configured;\n}"
    );
    let _ = std::fs::remove_dir_all(&dir);
}

#[test]
fn load_css_reemits_cached_module() {
    // `meta.load-css` re-emits a cached module's CSS at every call site,
    // nested under the enclosing rule; an explicit second `$with` still
    // errors ("already loaded").
    let dir = std::env::temp_dir().join(format!("sasso_load_css_{}", std::process::id()));
    std::fs::create_dir_all(&dir).expect("create scratch dir");
    let imp = FsImporter::new(vec![dir.clone()]);
    let opts = Options::default().with_importer(&imp);
    std::fs::write(dir.join("_m.scss"), "b {c: d}\n").unwrap();
    assert_eq!(
        compile(
            "@use \"sass:meta\";\n@include meta.load-css(\"m\");\nx {@include meta.load-css(\"m\");}\n",
            &opts
        )
        .expect("load twice"),
        "b {\n  c: d;\n}\n\nx b {\n  c: d;\n}"
    );
    let _ = std::fs::remove_dir_all(&dir);
}

#[test]
fn nested_global_decl_registers_module_slot() {
    // A `$var: ... !global` nested in a never-evaluated branch still creates
    // a module variable slot defaulting to null (dart-sass: a module exposes
    // the same members regardless of how it's evaluated).
    let dir = std::env::temp_dir().join(format!("sasso_global_slot_{}", std::process::id()));
    std::fs::create_dir_all(&dir).expect("create scratch dir");
    let imp = FsImporter::new(vec![dir.clone()]);
    let opts = Options::default().with_importer(&imp);
    std::fs::write(
        dir.join("_other.scss"),
        "x {\n  @if false {\n    $member: value !global;\n  }\n}\n",
    )
    .unwrap();
    assert_eq!(
        compile(
            "@use \"sass:meta\";\n@use \"other\";\na {b: meta.inspect(other.$member)}\n",
            &opts
        )
        .expect("nested global slot"),
        "a {\n  b: null;\n}"
    );
    let _ = std::fs::remove_dir_all(&dir);
}

#[test]
fn nest_parent_list_and_cartesian() {
    // dart-sass `resolveParentSelectors` semantics in selector.nest: a `&`
    // inside a selector pseudo receives the WHOLE parent list, multiple
    // top-level `&`s expand as a cartesian product (last varying fastest),
    // and a lone `&` first argument stays literal.
    let go = |args: &str| {
        ours(&format!(
            "@use \"sass:selector\";\na {{b: selector.nest({args})}}\n"
        ))
    };
    assert_eq!(go("\"c, d\", \":is(&)\""), "a {\n  b: :is(c, d);\n}\n");
    assert_eq!(
        go("\"c, d\", \"&.e &.f\""),
        "a {\n  b: c.e c.f, c.e d.f, d.e c.f, d.e d.f;\n}\n"
    );
    assert_eq!(go("\"&\""), "a {\n  b: &;\n}\n");
    assert_eq!(go("\"&\", \".x\""), "a {\n  b: & .x;\n}\n");
    assert_eq!(go("\"&.suffix\""), "a {\n  b: &.suffix;\n}\n");
    assert_eq!(go("\"c, d\", \"e, f\""), "a {\n  b: c e, c f, d e, d f;\n}\n");
    assert!(compile(
        "@use \"sass:selector\";\na {b: selector.nest(\"&c\")}\n",
        &Options::default()
    )
    .is_err());
}

#[test]
fn module_scoped_extend() {
    // dart-sass per-module ExtensionStores: an @extend affects the module's
    // own CSS and its transitive upstreams — never siblings or downstream —
    // and a chained extension only links when the outer extension's origin is
    // visible to the inner one. Private placeholders are module-private.
    let dir = std::env::temp_dir().join(format!("sasso_scoped_ext_{}", std::process::id()));
    std::fs::create_dir_all(&dir).expect("create scratch dir");
    let imp = FsImporter::new(vec![dir.clone()]);
    let opts = Options::default().with_importer(&imp);

    // Siblings don't see each other.
    std::fs::write(
        dir.join("_left.scss"),
        "left-e {in: left}\nlx {@extend right-e !optional}\n",
    )
    .unwrap();
    std::fs::write(
        dir.join("_right.scss"),
        "right-e {in: right}\nrx {@extend left-e !optional}\n",
    )
    .unwrap();
    assert_eq!(
        compile("@use \"left\";\n@use \"right\";\n", &opts).expect("sibling"),
        "left-e {\n  in: left;\n}\n\nright-e {\n  in: right;\n}"
    );
    // Upstream extends work; downstream don't.
    std::fs::write(dir.join("_up.scss"), "up-style {a: b}\n").unwrap();
    assert_eq!(
        compile("@use \"up\";\nme {@extend up-style}\n", &opts).expect("upstream"),
        "up-style, me {\n  a: b;\n}"
    );
    // Diamond: both sides extend shared, but don't chain through each other.
    std::fs::write(dir.join("_shared.scss"), "in-shared {x: y}\n").unwrap();
    std::fs::write(
        dir.join("_dl.scss"),
        "@use \"shared\";\nleft-e2 {@extend in-shared}\nl2 {@extend right-e2 !optional}\n",
    )
    .unwrap();
    std::fs::write(
        dir.join("_dr.scss"),
        "@use \"shared\";\nright-e2 {@extend in-shared}\nr2 {@extend left-e2 !optional}\n",
    )
    .unwrap();
    assert_eq!(
        compile("@use \"dl\";\n@use \"dr\";\n", &opts).expect("diamond"),
        "in-shared, right-e2, left-e2 {\n  x: y;\n}"
    );
    // A private placeholder can't be extended from another module.
    std::fs::write(dir.join("_po.scss"), "%-priv {x: y}\nin-other {@extend %-priv}\n").unwrap();
    assert_eq!(
        compile("@use \"po\";\nme {@extend %-priv !optional}\n", &opts).expect("private"),
        "in-other {\n  x: y;\n}"
    );
    let _ = std::fs::remove_dir_all(&dir);
}

#[test]
fn midstream_pseudo_extender_replaced_across_modules() {
    // An extender added to an UPSTREAM module's CSS is not one of that
    // store's originals, so an in-place pseudo rewrite replaces it; in the
    // same file both forms survive (dart-sass _originals are store-wide).
    let dir = std::env::temp_dir().join(format!("sasso_midstream_{}", std::process::id()));
    std::fs::create_dir_all(&dir).expect("create scratch dir");
    let imp = FsImporter::new(vec![dir.clone()]);
    let opts = Options::default().with_importer(&imp);
    std::fs::write(dir.join("_up.scss"), "in-upstream {a: b}\n").unwrap();
    assert_eq!(
        compile(
            "@use \"up\";\n:is(in-midstream) {@extend in-upstream}\n\nin-input {\n  @extend in-midstream;\n  y: z;\n}\n",
            &opts
        )
        .expect("midstream"),
        "in-upstream, :is(in-midstream, in-input) {\n  a: b;\n}\n\nin-input {\n  y: z;\n}"
    );
    // Same-file: both the added extender and its rewrite survive.
    assert_eq!(
        ours(":is(midstream) {@extend upstream}\n\ndownstream {@extend midstream}\n\nupstream {a: b}\n"),
        "upstream, :is(midstream), :is(midstream, downstream) {\n  a: b;\n}\n"
    );
    let _ = std::fs::remove_dir_all(&dir);
}

#[test]
fn sass_whitespace_map_keys_and_decl_children() {
    // A map key may be separated from its colon by whitespace: the space list
    // ends at `:` so the paren handler still sees a key/value pair.
    assert_eq!(
        ours("$a: (b\n  : c, d: e);\nx {y: map-get($a, b)}\n"),
        "x {\n  y: c;\n}\n"
    );
    assert_sass_parity("$a: (b\n  : c, d: e)\nx\n  y: map-get($a, b)\n");
    // A declaration WITH a value whose child block contains a bare
    // non-declaration line is dart's `expected ":".` error.
    let err = compile(
        "a\n  b: c,\n     d\n",
        &Options::default().with_syntax(sasso::Syntax::Sass),
    )
    .expect_err("bare child line under a valued declaration must error");
    assert!(
        err.to_string().contains("expected \":\"."),
        "unexpected error: {err}"
    );
}

#[test]
fn selector_paren_validation_and_import_supports_collapse() {
    // A top-level `(` in a selector is only valid as a pseudo argument list;
    // a stray `)` is its own error (dart-sass "expected selector." /
    // `Unexpected ")".`).
    for bad in [
        "a(b) {x: y}",
        "a (b) {x: y}",
        "(b) {x: y}",
        "*(b) {x: y}",
        "a[u](b) {x: y}",
        "a#{\"(b)\"} {x: y}",
        "a:nth-child (2n) {x: y}",
        "a) {x: y}",
    ] {
        assert!(compile(bad, &Options::default()).is_err(), "should reject: {bad}");
    }
    for good in [
        ":not(b) {x: y}",
        "a:hover(b) {x: y}",
        ":#{\"not\"}(b) {x: y}",
        ":has(> a) {x: y}",
        "::part(x) {a: b}",
        ":-webkit-any(a) {x: y}",
    ] {
        assert!(
            compile(good, &Options::default()).is_ok(),
            "should accept: {good}"
        );
        assert_parity(good);
    }
    // An `@import` supports(...) condition is an expression part of the
    // modifiers interpolation: its serialized text gets the unquoted-string
    // newline collapse. A Raw function modifier is verbatim text — preserved.
    assert_eq!(
        ours("@import \"a.css\" supports(a(\n  b));\n"),
        "@import \"a.css\" supports(a( b));\n"
    );
    assert_eq!(
        ours("@import \"a.css\" supports(a(b\n  ));\n"),
        "@import \"a.css\" supports(a(b ));\n"
    );
    assert_eq!(
        ours("@import \"a.css\" foo(b\n  c);\n"),
        "@import \"a.css\" foo(b\n  c);\n"
    );
    assert_parity("@import \"a.css\" supports(a(b\n\n  c));\n");
}

#[test]
fn sass_bare_plus_selector_and_using_block() {
    // A bare `+` line is the next-sibling combinator selector (like `+ a`),
    // NOT the include shorthand — only `+name` includes a mixin.
    assert_sass_parity("d\n  +\n    a\n      x: y\n");
    assert_eq!(ours_sass("@mixin a\n  b: c\nd\n  +\n    a\n"), "");
    assert_eq!(ours_sass("@mixin a\n  b: c\nd\n  +a\n"), "d {\n  b: c;\n}\n");
    // `=` alone still continues onto the next line as `@mixin`.
    assert_eq!(ours_sass("=\n  a\n\nd\n  @include a\n"), "");
    // An `@include … using (…)` with no child block takes an EMPTY content
    // block (SCSS `@include a() using ();` is 'expected "{".').
    assert_eq!(ours_sass("@mixin a\n  @content\n@include a() using\n  ()\n"), "");
}

#[test]
fn sass_comment_blocks_and_continuation_rules() {
    // Multi-line loud comments keep each line's source column behind ` *`,
    // preserve interior blank lines, and treat `\f` as a line separator.
    assert_eq!(ours_sass("/*\n  Multi\n  line\n"), "/* Multi\n * line */\n");
    assert_eq!(
        ours_sass("/* Handles\n         weird\n   indentation\n"),
        "/* Handles\n *       weird\n * indentation */\n"
    );
    assert_eq!(ours_sass("/* Keeps\n\n   empty\n"), "/* Keeps\n *\n * empty */\n");
    assert_eq!(ours_sass("/*\n  foo\u{c}  bar\n"), "/* foo\n * bar */\n");
    // An open interpolation joins continuation lines as expression text.
    assert_eq!(ours_sass("/* #{a \n  + b} */\n"), "/* ab */\n");
    // A trailing comma does NOT continue a directive prelude (`@each $a in b,`
    // iterates `(b,)`; the deeper lines are its body) — but a `@use`/`@forward`
    // member list does continue.
    assert_eq!(
        ours_sass("@each $a in b,\n c\n  .#{$a}\n    d: $a\n"),
        "c .b {\n  d: b;\n}\n"
    );
    // `!` awaits `important` on the next line; anything else is dart's
    // hard `Expected "important".` (also in SCSS: no silent backtrack).
    assert_eq!(
        ours_sass("a\n  b: c!\n    important\n"),
        "a {\n  b: c !important;\n}\n"
    );
    assert!(compile("a {b: c !ie;}", &Options::default()).is_err());
}

#[test]
fn sass_custom_props_spread_and_inline_comments() {
    // Only an open bracket or interpolation continues a custom-property
    // value; any other indented child is dart's error.
    assert!(compile(
        ".x\n  --foo: bar\n    baz: qux\n",
        &Options::default().with_syntax(sasso::Syntax::Sass)
    )
    .is_err());
    assert_eq!(
        ours_sass("a\n  --b: (c\n    d)\n"),
        "a {\n  --b: (c\n    d);\n}\n"
    );
    // Whitespace (and newlines) may separate a splat value from its `...`.
    assert_eq!(
        ours("@function a($b, $c) {@return null}\n$d: e, f;\n$g: a($d\n  ...);\nx {y: $g}\n"),
        ""
    );
    // A trailing loud comment is invisible to selector-comma continuation
    // and tolerated (dropped) after an explicit `;`.
    assert_eq!(ours_sass("a, /* c */\nb\n  x: y\n"), "a,\nb {\n  x: y;\n}\n");
    assert_eq!(
        ours_sass("a\n  b: c; /* f */\n  d: e;\n"),
        "a {\n  b: c;\n  d: e;\n}\n"
    );
    // A selector list whose FIRST comma part is empty is "expected selector."
    // (later empty parts are tolerated).
    assert!(compile(",b {x: y}", &Options::default()).is_err());
    assert_parity("a, ,b {x: y}\n");
}

#[test]
fn sass_statement_escape_and_nested_linebreaks() {
    // A leading `\` escapes the statement into a style rule and is consumed
    // (the legacy `\:hover` disambiguation; SCSS keeps the backslash).
    assert_eq!(
        ours_sass("\\:hover TD\n  color: red\n"),
        ":hover TD {\n  color: red;\n}\n"
    );
    assert_eq!(
        ours_sass("\\:color red\n  foo: bar\n"),
        ":color red {\n  foo: bar;\n}\n"
    );
    // A nested complex selector starts a fresh output line when its own
    // comma part did OR its parent did.
    assert_eq!(
        ours("a,\nb {\n  c, d {x: y}\n}\n"),
        "a c, a d,\nb c,\nb d {\n  x: y;\n}\n"
    );
    assert_parity("a,\nb {\n  c, d {x: y}\n}\n");
}

#[test]
fn sass_value_operator_continuation_and_unquoted_imports() {
    // A declaration value continues on a trailing binary operator.
    assert_eq!(ours_sass("a\n  b: 3 %\n  2\n"), "a {\n  b: 1;\n}\n");
    assert_eq!(ours_sass("a\n  b: 3 +\n  2\n"), "a {\n  b: 5;\n}\n");
    assert_eq!(ours_sass("a\n  b: true and\n  false\n"), "a {\n  b: false;\n}\n");
    // `3%` is a complete percent unit and `c-` ends an identifier — no join.
    assert_eq!(ours_sass("a\n  b: 3%\n"), "a {\n  b: 3%;\n}\n");
    // An unquoted indented-syntax `@import` URL is quoted for the SCSS
    // grammar; a `.css` one stays a plain-CSS import.
    assert_eq!(ours_sass("@import other.css\n"), "@import \"other.css\";\n");
}

#[test]
fn interpolated_function_name_is_plain_css_call() {
    // An interpolated identifier directly followed by `(` is a plain-CSS
    // call: the name resolves, the args evaluate, and the call serializes
    // verbatim — never dispatched to a built-in or user function.
    assert_eq!(
        ours(".x {a: qu#{o}te(arg); b: foo#{1 + 1}bar(2 + 2); c: #{foo}(arg)}\n"),
        ".x {\n  a: quote(arg);\n  b: foo2bar(4);\n  c: foo(arg);\n}\n"
    );
    assert_parity(".x {a: qu#{o}te(arg); b: #{1 + 1}foo(arg)}\n");
    // Splats expand; keyword arguments are rejected.
    assert_eq!(
        ours("$l: 1, 2, 3;\n.x {a: f#{o}o($l...)}\n"),
        ".x {\n  a: foo(1, 2, 3);\n}\n"
    );
    assert!(
        ours_err(".x {a: f#{o}o($b: 1)}\n").contains("Plain CSS functions don't support keyword arguments.")
    );
}

#[test]
fn splat_list_separator_survives_into_arglist() {
    // A splatted list's separator survives into the callee's rest arglist:
    // `foo(c d e...)` binds the rest param as a SPACE-separated arglist.
    assert_eq!(
        ours("@mixin m($x, $zs...) {z: $zs}\na {@include m(a, c d e...)}\n"),
        "a {\n  z: c d e;\n}\n"
    );
    assert_eq!(
        ours("@mixin m($x, $zs...) {z: $zs}\na {@include m(a, (c, d, e)...)}\n"),
        "a {\n  z: c, d, e;\n}\n"
    );
    assert_parity("@mixin m($x, $zs...) {z: $zs}\na {@include m(a, c d e...)}\n");
}

#[test]
fn css_custom_callable_result_rules_and_string_line_continuation() {
    // In a plain-CSS custom callable body, an interpolated property follows
    // the nested-property rules (`#{re}sult: {b: c}` -> `result-b: c`)...
    assert_eq!(
        ours("@function --a() {#{re}sult: {b: c}}\n"),
        "@function --a() {\n  result-b: c;\n}\n"
    );
    // ...while a literal `result` keeps a braced value verbatim, and in the
    // indented syntax may not have an indented child block.
    assert_eq!(
        ours("@function --a() {result: {b: c}}\n"),
        "@function --a() {\n  result: {b: c};\n}\n"
    );
    let err = compile(
        "@function --a()\n  result:\n    b: c\n",
        &Options::default().with_syntax(sasso::Syntax::Sass),
    )
    .expect_err("indented child beneath result must error");
    assert!(err
        .to_string()
        .contains("Nothing may be indented beneath a @function result."));
    // A `\`+newline inside an open quoted string is a CSS line continuation:
    // it vanishes and the next line's indentation stays part of the string.
    assert_eq!(
        ours_sass("a \n  b: 'line1 \\\n      line2'\n"),
        "a {\n  b: \"line1       line2\";\n}\n"
    );
}

#[test]
fn space_list_atom_adjacency() {
    // dart-sass's space list doesn't require whitespace between atoms:
    // a touching atom start begins a new term.
    assert_eq!(ours("a {b: (x)y}\n"), "a {\n  b: x y;\n}\n");
    assert_eq!(ours("a {b: 5px(3)}\n"), "a {\n  b: 5px 3;\n}\n");
    assert_eq!(ours("a {b: x(y)z}\n"), "a {\n  b: x(y) z;\n}\n");
    assert_parity("a {b: (x)y; c: 5px(3); d: x(y)z}\n");
    // Operators still bind tighter than adjacency.
    assert_eq!(ours("a {b: 1+2}\n"), "a {\n  b: 3;\n}\n");
}

#[test]
fn forwarded_members_bind_their_defining_module() {
    let dir = std::env::temp_dir().join("sasso_parity_fwd_origin");
    let _ = std::fs::remove_dir_all(&dir);
    std::fs::create_dir_all(&dir).unwrap();
    std::fs::write(
        dir.join("_upstream.scss"),
        "$a: old value;\n@function get-a() {@return $a}\n",
    )
    .unwrap();
    std::fs::write(dir.join("_midstream.scss"), "@forward \"upstream\" as d-*;\n").unwrap();
    let imp = FsImporter::new(vec![dir.clone()]);
    let opts = Options::default().with_importer(&imp);
    // A prefixed forwarded variable assignment writes through to the
    // defining module, and the forwarded function executes there.
    assert_eq!(
        compile(
            "@use \"midstream\";\nmidstream.$d-a: new value;\nb {c: midstream.d-get-a()}\n",
            &opts
        )
        .unwrap(),
        "b {\n  c: new value;\n}"
    );
    // A module's own same-named variable shadows the forwarded one for
    // READS, but a namespaced assignment still writes the forwarded module.
    std::fs::write(
        dir.join("_shadow.scss"),
        "@forward \"upstream\";\n$a: shadow value;\n@function get-shadow-a() {@return $a}\n",
    )
    .unwrap();
    assert_eq!(
        compile("@use \"shadow\";\nshadow.$a: new value;\nb {c: shadow.$a; s: shadow.get-shadow-a(); u: shadow.get-a()}\n", &opts).unwrap(),
        "b {\n  c: shadow value;\n  s: shadow value;\n  u: new value;\n}"
    );
    let _ = std::fs::remove_dir_all(&dir);
}

#[test]
fn nested_import_forward_members_and_override() {
    let dir = std::env::temp_dir().join("sasso_parity_itf");
    let _ = std::fs::remove_dir_all(&dir);
    std::fs::create_dir_all(&dir).unwrap();
    let w = |n: &str, b: &str| std::fs::write(dir.join(n), b).unwrap();
    w(
        "_upstream.scss",
        "@mixin b() {c: d}\n$v: old;\n@function get-v() {@return $v}\n",
    );
    w("_midstream.scss", "@forward \"upstream\";\n");
    w("_up1.scss", "$b: 1;\n");
    w("_up2.scss", "$b: 2;\n");
    w("_mid1.scss", "@forward \"up1\";\n");
    w("_mid2.scss", "@forward \"up2\";\n");
    let imp = FsImporter::new(vec![dir.clone()]);
    let opts = Options::default().with_importer(&imp);
    // A nested `@import`'s forwarded mixins/functions are callable inside
    // the rule (and a local assignment writes the forwarded variable)...
    assert_eq!(
        compile(
            "a {\n  @import \"midstream\";\n  @include b;\n  $v: new;\n  e: get-v();\n}\n",
            &opts
        )
        .unwrap(),
        "a {\n  c: d;\n  e: new;\n}"
    );
    // ...but they are NOT visible outside the rule.
    assert!(compile("a {@import \"midstream\"}\nb {@include b}\n", &opts).is_err());
    // A same-named variable forwarded from a DIFFERENT module overrides the
    // previous import's binding (sass/dart-sass#888).
    assert_eq!(
        compile(
            "@import \"mid1\";\nf {a: $b}\n@import \"mid2\";\ns {a: $b}\n",
            &opts
        )
        .unwrap(),
        "f {\n  a: 1;\n}\n\ns {\n  a: 2;\n}"
    );
    let _ = std::fs::remove_dir_all(&dir);
}

#[test]
fn load_css_copies_belong_to_their_caller() {
    let dir = std::env::temp_dir().join("sasso_parity_lcx");
    let _ = std::fs::remove_dir_all(&dir);
    std::fs::create_dir_all(&dir).unwrap();
    let w = |n: &str, b: &str| std::fs::write(dir.join(n), b).unwrap();
    w("_other.scss", "a {b: c}\n");
    w(
        "_left.scss",
        "@use \"sass:meta\";\n@include meta.load-css(\"other\");\nleft {@extend a}\n",
    );
    w(
        "_right.scss",
        "@use \"sass:meta\";\n@include meta.load-css(\"other\");\nright {@extend a}\n",
    );
    let imp = FsImporter::new(vec![dir.clone()]);
    let opts = Options::default().with_importer(&imp);
    // Each load-css copy is spliced into ITS caller's tree: only that
    // caller's extensions apply to it.
    assert_eq!(
        compile("@use \"left\";\n@use \"right\";\n", &opts).unwrap(),
        "a, left {\n  b: c;\n}\n\na, right {\n  b: c;\n}"
    );
    // A built-in module loads as a no-op (no CSS, no error).
    assert_eq!(
        compile(
            "@use \"sass:meta\";\n@include meta.load-css(\"sass:color\");\n",
            &opts
        )
        .unwrap(),
        ""
    );
    let _ = std::fs::remove_dir_all(&dir);
}

#[test]
fn load_css_subtree_clone_and_blank_gating() {
    let dir = std::env::temp_dir().join("sasso_parity_scm");
    let _ = std::fs::remove_dir_all(&dir);
    std::fs::create_dir_all(&dir).unwrap();
    let w = |n: &str, b: &str| std::fs::write(dir.join(n), b).unwrap();
    w("_upstream.scss", "@c;\n");
    w("_midstream.scss", "@use 'upstream';\n");
    w("_target.scss", "@use \"midstream\";\n\n.target {a: b}\n");
    w(
        "extender.scss",
        "@use 'target';\n\n.extender {\n  @extend .target;\n}\n",
    );
    let imp = FsImporter::new(vec![dir.clone()]);
    let opts = Options::default().with_importer(&imp);
    // load-css re-emits the module's whole subtree as a clone carrying that
    // subtree's extensions; the main tree's copy stays untouched
    // (sass/sass#3322).
    assert_eq!(
        compile(
            "@use 'sass:meta';\n@use 'target';\n\n@include meta.load-css('extender');\n",
            &opts
        )
        .unwrap(),
        "@c;\n.target {\n  a: b;\n}\n\n@c;\n.target, .extender {\n  a: b;\n}"
    );
    let _ = std::fs::remove_dir_all(&dir);
    // A blank line only follows a completed style rule (dart isGroupEnd):
    // consecutive @media blocks and at-rule-then-rule join tightly.
    assert_eq!(
        ours("@media a {x {p: q}}\n\n@media b {y {p: q}}\n"),
        "@media a {\n  x {\n    p: q;\n  }\n}\n@media b {\n  y {\n    p: q;\n  }\n}\n"
    );
    assert_parity("a {x: y}\n\n@c;\n");
    assert_parity("@media a {x {p: q}}\n\n@media b {y {p: q}}\n");
}

#[test]
fn keyframes_nested_at_rules_and_selector_normalization() {
    // A keyframe block is not a style rule: a nested at-rule stays inside
    // the frame instead of bubbling out.
    assert_eq!(
        ours("@keyframes a {\n  to {@media screen {b: c}}\n}\n"),
        "@keyframes a {\n  to {\n    @media screen {\n      b: c;\n    }\n  }\n}\n"
    );
    // A percentage stop's scientific-notation marker lowercases; the digits
    // stay verbatim, and `+` is not a combinator here.
    assert_eq!(
        ours("@keyframes a {\n  130E-1% {c: d}\n}\n"),
        "@keyframes a {\n  130e-1% {\n    c: d;\n  }\n}\n"
    );
    // The `from`/`to` keywords are re-serialized lowercase, whatever their
    // case in the source.
    assert_eq!(
        ours("@keyframes a {\n  FROM, tO {c: d}\n}\n"),
        "@keyframes a {\n  from, to {\n    c: d;\n  }\n}\n"
    );
    assert_parity("@keyframes a {\n  13E+1% {c: d}\n}\n");
    assert_parity("@keyframes a {\n  from {c: d}\n  50.5% {e: f}\n}\n");
    assert_parity("@keyframes a {\n  FROM, tO {c: d}\n}\n");
}

#[test]
fn nested_media_merge_bubbles_in_source_order() {
    // A mergeable nested @media bubbles out of its enclosing media rule,
    // slicing the outer rule's own children into segments around it at the
    // source position (dart-sass#453).
    assert_eq!(
        ours("@media screen {\n  a {b: c}\n  @media (color) {x {y: z}}\n}\n"),
        "@media screen {\n  a {\n    b: c;\n  }\n}\n@media screen and (color) {\n  x {\n    y: z;\n  }\n}\n"
    );
    assert_eq!(
        ours("@media (r: after) {\n  @media (a: b) {x {y: z}}\n  a {b: c}\n}\n"),
        "@media (r: after) and (a: b) {\n  x {\n    y: z;\n  }\n}\n@media (r: after) {\n  a {\n    b: c;\n  }\n}\n"
    );
    assert_parity("@media screen {\n  a {b: c}\n  @media (color) {x {y: z}}\n}\n");
    assert_parity("@media (r: after) {\n  @media (a: b) {x {y: z}}\n  a {b: c}\n}\n");
    // An unmergeable nested @media stays nested.
    assert_parity("@media not screen {\n  a {b: c}\n  @media (color) {x {y: z}}\n}\n");
}

#[test]
fn media_interpolation_reparses_resolved_text() {
    // Interpolation may span query boundaries: the RESOLVED prelude text is
    // re-parsed (dart CssMediaQuery.parseList).
    assert_eq!(
        ours("@media scr#{\"een, pri\"}nt a#{\"nd (max-width: 300px)\"} {x {y: z}}\n"),
        "@media screen, print and (max-width: 300px) {\n  x {\n    y: z;\n  }\n}\n"
    );
    // A parenthesised condition survives verbatim through the re-parse
    // (no `and` normalization inside raw parens).
    assert_eq!(
        ours("@media (#{\"(a) AnD (b)\"}) {x {y: z}}\n"),
        "@media ((a) AnD (b)) {\n  x {\n    y: z;\n  }\n}\n"
    );
    // A modifier keeps its original case, and `or` after interpolation is
    // still a parse error (the stylesheet grammar stays strict).
    assert_parity("@media ONLY screen {x {y: z}}\n");
    assert!(compile("@media #{\"(a)\"} or (b) {x {y: z}}\n", &Options::default()).is_err());
    assert_parity("@media bar#{12} {x {y: z}}\n");
}

#[test]
fn import_subtree_clones_and_extension_store_order() {
    let dir = std::env::temp_dir().join("sasso_parity_impclone");
    let _ = std::fs::remove_dir_all(&dir);
    std::fs::create_dir_all(&dir).unwrap();
    let w = |n: &str, b: &str| std::fs::write(dir.join(n), b).unwrap();
    w("_shared.scss", "shared {x: y}\n");
    w("_used.scss", "@use \"shared\";\nin-used {@extend shared}\n");
    w(
        "_imported.scss",
        "@use \"shared\";\nin-imported {@extend shared}\n",
    );
    let imp = FsImporter::new(vec![dir.clone()]);
    let opts = Options::default().with_importer(&imp);
    // A module-loading @import clones the whole import subtree at the import
    // site: the used extend applies to the original, the imported extend to
    // both (it is downstream of the used module). Upstream extension stores
    // come first; same-store extenders show in reverse source order.
    assert_eq!(
        compile("@use \"used\";\n@import \"imported\";\n", &opts).unwrap(),
        "shared, in-used, in-imported {\n  x: y;\n}\n\nshared, in-imported {\n  x: y;\n}"
    );
    // A module first loaded inside an import clone still emits its main-tree
    // copy at the next plain @use.
    w("_importer.scss", "@import \"imported\";\n");
    assert_eq!(
        compile("@use \"importer\";\n@use \"used\";\n", &opts).unwrap(),
        "shared, in-imported {\n  x: y;\n}\n\nshared, in-used {\n  x: y;\n}"
    );
    let _ = std::fs::remove_dir_all(&dir);
    // Same-module extenders alone keep dart's reverse source order.
    assert_eq!(
        ours("s {x: y}\nfirst {@extend s}\nsecond {@extend s}\n"),
        "s, second, first {\n  x: y;\n}\n"
    );
    assert_parity("s {x: y}\nfirst {@extend s}\nsecond {@extend s}\n");
}

#[test]
fn relative_resolution_and_distributed_config() {
    let dir = std::env::temp_dir().join("sasso_parity_relres");
    let _ = std::fs::remove_dir_all(&dir);
    std::fs::create_dir_all(dir.join("module/a")).unwrap();
    std::fs::create_dir_all(dir.join("subdir")).unwrap();
    let w = |n: &str, b: &str| std::fs::write(dir.join(n), b).unwrap();
    // Relative URLs resolve against the containing FILE's directory.
    w("module/_index.scss", "@forward './a/a1';\n@forward './a/a2';\n");
    w("module/a/_variables.scss", "$a: default !default;\n");
    w(
        "module/a/a1.scss",
        "@forward './variables';\n@use './variables' as *;\n.a1 {content: #{$a}}\n",
    );
    w(
        "module/a/a2.scss",
        "@forward './variables';\n@use './variables' as *;\n.a2 {content: #{$a}}\n",
    );
    let imp = FsImporter::new(vec![dir.clone()]);
    let opts = Options::default().with_importer(&imp);
    // A `with (...)` distributed through several forwards keeps one original
    // identity: re-reaching the shared upstream is not "already loaded", and
    // two forwards of the SAME member don't conflict.
    assert_eq!(
        compile("@use 'module' with ($a: 'a');\n", &opts).unwrap(),
        ".a1 {\n  content: a;\n}\n\n.a2 {\n  content: a;\n}"
    );
    // meta.load-css resolves relative to the DEFINING file of the mixin.
    w("_upstream.scss", "a {b: in main}\n");
    w("subdir/_upstream.scss", "a {b: in subdir}\n");
    w(
        "subdir/_midstream.scss",
        "@use 'sass:meta';\n@mixin load-css($m) {@include meta.load-css($m)}\n",
    );
    assert_eq!(
        compile(
            "@use 'subdir/midstream';\n@include midstream.load-css('upstream');\n",
            &opts
        )
        .unwrap(),
        "a {\n  b: in subdir;\n}"
    );
    let _ = std::fs::remove_dir_all(&dir);
}

#[test]
fn entry_relative_import_resolves_against_entry_dir() {
    // An entry file in a subdirectory importing a sibling partial by BARE name
    // must resolve against the entry file's own directory (threaded to the
    // importer as `containing_url`), not only the load paths. The importer here
    // has NO load paths, so the partial is findable solely via the entry dir.
    let dir = std::env::temp_dir().join("sasso_parity_entryrel");
    let _ = std::fs::remove_dir_all(&dir);
    std::fs::create_dir_all(dir.join("sub")).unwrap();
    std::fs::write(dir.join("sub/_part.scss"), "$c: tomato;\n").unwrap();
    let imp = FsImporter::new(vec![]);
    let entry = dir.join("sub/entry.scss");
    let out = compile(
        "@use \"part\" as p;\n.a { color: p.$c; }\n",
        &Options::default()
            .with_importer(&imp)
            .with_url(entry.to_str().unwrap()),
    )
    .expect("entry-relative @use should resolve against the entry's directory");
    assert_eq!(out, ".a {\n  color: tomato;\n}");
    let _ = std::fs::remove_dir_all(&dir);
}

#[test]
fn fs_importer_unreadable_file_surfaces_error_not_miss() {
    // A file the importer FOUND but can't read (here: invalid UTF-8) surfaces a
    // real error through the ImporterError channel — not a misleading
    // "Can't find stylesheet to import." (`load` distinguishes ENOENT = a miss
    // from a genuine read failure).
    let dir = std::env::temp_dir().join("sasso_parity_unreadable");
    let _ = std::fs::remove_dir_all(&dir);
    std::fs::create_dir_all(&dir).unwrap();
    std::fs::write(dir.join("_bad.scss"), [0xff, 0xfe, 0x00]).unwrap();
    let imp = FsImporter::new(vec![dir.clone()]);
    let opts = Options::default().with_importer(&imp);
    let msg = compile("@use \"bad\";\n", &opts).unwrap_err().to_string();
    assert!(
        !msg.contains("Can't find stylesheet"),
        "an unreadable file must not be reported as 'not found', got: {msg}"
    );
    assert!(msg.contains("Cannot read"), "expected a read error, got: {msg}");
    let _ = std::fs::remove_dir_all(&dir);
}

#[test]
fn use_url_dotdot_and_nested_global_writethrough() {
    let dir = std::env::temp_dir().join("sasso_parity_dotdot");
    let _ = std::fs::remove_dir_all(&dir);
    std::fs::create_dir_all(dir.join("foo/baz/qux")).unwrap();
    let w = |n: &str, b: &str| std::fs::write(dir.join(n), b).unwrap();
    w("foo/baz/qux/other.scss", "$variable: value;\n");
    w(
        "other.scss",
        "$member: value;\n@function get-member() {@return $member}\n",
    );
    let imp = FsImporter::new(vec![dir.clone()]);
    let opts = Options::default().with_importer(&imp);
    // `..` segments normalize lexically (foo/bar need not exist); the
    // namespace is the URL basename.
    assert_eq!(
        compile(
            "@use \"foo/bar/../baz/qux/other\";\na {b: other.$variable}\n",
            &opts
        )
        .unwrap(),
        "a {\n  b: value;\n}"
    );
    // A nested un-namespaced `!global` assignment writes through to the one
    // `as *` module that defines the variable.
    assert_eq!(
        compile(
            "@use \"other\" as *;\na {\n  $member: new value !global;\n  b: get-member();\n}\n",
            &opts
        )
        .unwrap(),
        "a {\n  b: new value;\n}"
    );
    let _ = std::fs::remove_dir_all(&dir);
}

#[test]
fn meta_builtin_module_introspection() {
    // sass:meta's own members are enumerable; variables are none.
    assert_eq!(
        ours("@use \"sass:map\";\n@use \"sass:meta\";\n$m: meta.module-mixins(\"meta\");\na {x: map.has-key($m, \"load-css\"); t: meta.type-of($m)}\n"),
        "a {\n  x: true;\n  t: map;\n}\n"
    );
    assert_eq!(
        ours("@use \"sass:meta\";\na {b: meta.inspect(meta.module-variables(\"meta\"))}\n"),
        "a {\n  b: ();\n}\n"
    );
    // A captured builtin meta function dispatches through the evaluator
    // (variable-exists needs scopes).
    assert_eq!(
        ours("@use \"sass:map\";\n@use \"sass:meta\";\n$functions: meta.module-functions(\"meta\");\na {x: meta.call(map.get($functions, \"variable-exists\"), \"functions\")}\n"),
        "a {\n  x: true;\n}\n"
    );
    // get-function with a builtin $module; its inspect form.
    assert_eq!(
        ours("@use \"sass:meta\";\na {v: meta.inspect(meta.get-function(\"get-function\", $module: \"meta\"))}\n"),
        "a {\n  v: get-function(\"get-function\");\n}\n"
    );
    // A bracketed single-element trailing-comma list keeps its separator.
    assert_eq!(
        ours("@use \"sass:meta\";\na {v: meta.inspect([1,])}\n"),
        "a {\n  v: [1,];\n}\n"
    );
    assert_parity(
        "@use \"sass:meta\";\na {v: meta.inspect([1,]); w: meta.inspect([1, 2]); x: meta.inspect([])}\n",
    );
}

#[test]
fn deep_media_chains_and_content_forwarding() {
    // A three-level mergeable media chain re-bubbles every batch (the
    // hoist queue is per-marker batches).
    assert_parity("@media all {\n  .bar {a: b}\n  @media (min-width: 1px) {\n    .baz {a: b}\n    @media (max-width: 2em) {.foo {a: b}}\n  }\n}\n");
    // A bubbling media does NOT split the enclosing rule's own block: the
    // declarations around it stay together and the merged rule follows.
    assert_eq!(
        ours("@media only screen {\n  .foo {\n    a: b;\n    @media (min-width: 1px) {c: d}\n    e: f;\n  }\n}\n"),
        "@media only screen {\n  .foo {\n    a: b;\n    e: f;\n  }\n}\n@media only screen and (min-width: 1px) {\n  .foo {\n    c: d;\n  }\n}\n"
    );
    // A completed top-level style rule separates from the next group even
    // when its output ended in a bubbled at-rule.
    assert_parity(".foo {\n  @media all {a: b}\n}\n.bar {c: d}\n");
    // A recursive mixin that forwards @content terminates: the block runs
    // with the content context of its DEFINITION site.
    assert_eq!(
        ours("@mixin m($l...) {\n  @if length($l) == 0 {@content;}\n  @else {@include m() {@content;}}\n}\na {@include m(x) {content: bar}}\n"),
        "a {\n  content: bar;\n}\n"
    );
}

#[test]
fn interpolated_at_rule_names_and_forbidden_contexts() {
    // An at-rule with an interpolated NAME is always generic (no Sass
    // parse-time behavior) — except @keyframes, resolved at eval time.
    assert_parity("@#{\"plain\"} value;\n@#{\"block\"} {x: y}\n");
    assert_eq!(
        ours("@#{\"media\"} ($var: value) {\n  .x {y: z}\n}\n"),
        "@media ($var: value) {\n  .x {\n    y: z;\n  }\n}\n"
    );
    assert_eq!(
        ours("@#{\"keyframes\"} name {\n  10% {x: y}\n}\n"),
        "@keyframes name {\n  10% {\n    x: y;\n  }\n}\n"
    );
    assert_eq!(
        ours("@#{\"error\"} not really an error;\n"),
        "@error not really an error;\n"
    );
    // Unknown at-rules (interpolated or not) are parse errors in function
    // bodies and nested property sets.
    for bad in [
        "@function f() {@asdf; @return null;}",
        ".x {y: {@asdf;}}",
        "@function f() {@#{\"asdf\"}; @return null;}",
        ".x {y: {@#{\"asdf\"};}}",
    ] {
        let err = ours_err(bad);
        assert!(err.contains("This at-rule is not allowed here."), "{bad}: {err}");
    }
}

#[test]
fn attribute_and_pseudo_arg_canonicalization() {
    // Attribute selectors canonicalize: operator whitespace drops and a
    // plain-identifier quoted value loses its quotes — so an interpolated
    // extend target matches its rule.
    assert_eq!(
        ours("[baz^=\"blip12px\"] {a: b}\n.bar {@extend [baz^=\"blip#{12px}\"]}\n"),
        "[baz^=blip12px], .bar {\n  a: b;\n}\n"
    );
    assert_parity("a[b=\"c\"] {x: y}\na[d = e] {x: y}\na[f=\"g h\"] {x: y}\n");
    // A selector-argument pseudo re-serializes canonically, so equal-modulo-
    // whitespace `:not()` arguments unify into one.
    assert_eq!(
        ours("%-a :not([a=b]).baz {a: b}\n:not([a = b]) {@extend .baz} -a {@extend %-a}\n"),
        "-a :not([a=b]) {\n  a: b;\n}\n"
    );
    assert_parity(":not([a = b]) {x: y}\n:is( .a , .b ) {x: y}\n");
}

#[test]
fn color_named_serialization_rounding() {
    // A converted channel a few ulps past 255 still rounds to a named color
    // (dart fuzzyRound): oklch/oklab/lch/lab → rgb white.
    assert_eq!(
        ours("@use \"sass:color\";\na {b: color.to-space(color.to-space(white, oklch), rgb)}\n"),
        "a {\n  b: white;\n}\n"
    );
    assert_eq!(
        ours("@use \"sass:color\";\na {b: color.to-space(color.to-space(white, lab), rgb)}\n"),
        "a {\n  b: white;\n}\n"
    );
}

#[test]
fn color_same_family_powerless_ab() {
    // dart's lch → lab conversion marks a/b powerless when the lightness is
    // missing or fuzzy-zero (LabColorSpace.convert dest=lab); oklab has NO
    // such rule — `oklch(none ...)` keeps its computed a/b.
    assert_eq!(
        ours("@use \"sass:color\";\na {b: color.to-space(lch(none 20% 30deg), lab)}\n"),
        "a {\n  b: lab(none none none);\n}\n"
    );
    assert_eq!(
        ours("@use \"sass:color\";\na {b: color.to-space(lch(0% 20% 30deg), lab)}\n"),
        "a {\n  b: lab(0% none none);\n}\n"
    );
    assert_eq!(
        ours("@use \"sass:color\";\na {b: color.to-space(oklch(none 20% 30deg), oklab)}\n"),
        "a {\n  b: oklab(none 0.0692820323 0.04);\n}\n"
    );
}

#[test]
fn color_to_gamut_round_trips() {
    // dart's to-gamut ALWAYS round-trips toSpace(space) → map → back, even
    // in gamut: the back leg legacy-fills missing channels and the polar
    // round trip marks a powerless hue `none`.
    assert_eq!(
        ours("@use \"sass:color\";\na {b: color.to-gamut(rgb(none none none), $space: display-p3, $method: clip)}\n"),
        "a {\n  b: black;\n}\n"
    );
    assert_eq!(
        ours("@use \"sass:color\";\na {b: color.to-gamut(hsl(none 50% 50%), $space: hwb, $method: clip)}\n"),
        "a {\n  b: hsl(0, 50%, 50%);\n}\n"
    );
    assert_eq!(
        ours(
            "@use \"sass:color\";\na {b: color.to-gamut(oklch(10% 0% 0deg), $space: srgb, $method: clip)}\n"
        ),
        "a {\n  b: oklch(10% 0 none);\n}\n"
    );
    // An unbounded target space returns the color untouched.
    assert_eq!(
        ours("@use \"sass:color\";\na {b: color.to-gamut(red, $space: lab, $method: clip)}\n"),
        "a {\n  b: red;\n}\n"
    );
}

#[test]
fn hwb_construction_normalization() {
    // dart normalizes whiteness + blackness > 100 at CONSTRUCTION; every
    // read path (legacy getters, channel, inspect) sees normalized storage.
    assert_eq!(
        ours("@use \"sass:color\";\na {b: color.blackness(hwb(0 70% 70%))}\n"),
        "a {\n  b: 50%;\n}\n"
    );
    assert_eq!(
        ours("@use \"sass:color\";\na {b: color.whiteness(hwb(0 70% 50%))}\n"),
        "a {\n  b: 58.3333333333%;\n}\n"
    );
    // The none-hue path normalizes too.
    assert_eq!(
        ours("@use \"sass:meta\";\na {b: meta.inspect(hwb(none 70% 70%))}\n"),
        "a {\n  b: hwb(none 50% 50%);\n}\n"
    );
    // `change` re-normalizes; `adjust`/`scale` results stay raw.
    assert_eq!(
        ours("@use \"sass:color\";\n@use \"sass:meta\";\na {b: meta.inspect(color.change(hwb(0 30% 30%), $whiteness: 90%))}\n"),
        "a {\n  b: hwb(0 75% 25%);\n}\n"
    );
    assert_eq!(
        ours("@use \"sass:color\";\n@use \"sass:meta\";\na {b: meta.inspect(color.adjust(hwb(0 30% 30%), $whiteness: 60%))}\n"),
        "a {\n  b: hwb(0 90% 30%);\n}\n"
    );
    assert_eq!(
        ours("@use \"sass:color\";\na {b: color.channel(color.adjust(hwb(0 30% 30%), $whiteness: 60%), \"whiteness\")}\n"),
        "a {\n  b: 90%;\n}\n"
    );
    // The legacy scale keyword path keeps the hwb space and raw channels.
    assert_eq!(
        ours("@use \"sass:color\";\n@use \"sass:meta\";\na {b: meta.inspect(color.scale(hwb(0 30% 30%), $whiteness: 90%))}\n"),
        "a {\n  b: hwb(0 93% 30%);\n}\n"
    );
}

#[test]
fn whiteness_blackness_are_module_only() {
    // dart-sass has no GLOBAL `whiteness()`/`blackness()`. Its `global` list
    // (lib/src/functions/color.dart:31-449) registers `_channelFunction`s only
    // for red/green/blue and hue/saturation/lightness; the HWB getters appear
    // solely in the `sass:color` `module` list (same file, lines 532-541). So a
    // bare `whiteness(...)` is an unknown plain-CSS function and is emitted
    // verbatim — note dart re-serializes the `hsl()` argument in its own comma
    // form while passing the call through.
    assert_eq!(
        ours("a {b: whiteness(hsl(120 50% 50%))}\n"),
        "a {\n  b: whiteness(hsl(120, 50%, 50%));\n}\n"
    );
    assert_eq!(
        ours("a {b: blackness(hsl(120 50% 50%))}\n"),
        "a {\n  b: blackness(hsl(120, 50%, 50%));\n}\n"
    );
    // Being plain-CSS rather than builtins is observable through
    // `function-exists`, while the sibling legacy getter stays global.
    assert_eq!(
        ours("a {b: function-exists(\"whiteness\"); c: function-exists(\"blackness\"); d: function-exists(\"lightness\")}\n"),
        "a {\n  b: false;\n  c: false;\n  d: true;\n}\n"
    );
    // The deprecated `sass:color` members still resolve and compute.
    assert_eq!(
        ours("@use \"sass:color\";\na {b: color.whiteness(hsl(120 50% 50%)); c: color.blackness(hsl(120 50% 50%))}\n"),
        "a {\n  b: 25%;\n  c: 25%;\n}\n"
    );
    // …as does the non-deprecated `color.channel()` replacement.
    assert_eq!(
        ours("@use \"sass:color\";\na {b: color.channel(hsl(120 50% 50%), \"whiteness\", $space: hwb)}\n"),
        "a {\n  b: 25%;\n}\n"
    );
}

#[test]
fn color_inspect_forms() {
    // inspect keeps hwb's own form (hue without `deg`, `/ alpha` tail) and
    // prints an out-of-gamut rgb without the hsl reroute; CSS output of the
    // same colors still uses the legacy route.
    assert_eq!(
        ours("@use \"sass:meta\";\na {b: meta.inspect(hwb(120 0% 0%))}\n"),
        "a {\n  b: hwb(120 0% 0%);\n}\n"
    );
    assert_eq!(
        ours("@use \"sass:meta\";\na {b: meta.inspect(hwb(0 30% 40% / 0.5))}\n"),
        "a {\n  b: hwb(0 30% 40% / 0.5);\n}\n"
    );
    assert_eq!(
        ours(
            "@use \"sass:color\";\n@use \"sass:meta\";\na {b: meta.inspect(color.change(red, $red: 300))}\n"
        ),
        "a {\n  b: rgb(300, 0, 0);\n}\n"
    );
    assert_parity("a {b: hwb(120 0% 0%)}\n");
    assert_parity("a {b: hwb(0 70% 70%)}\n");
}

#[test]
fn color_scale_past_bound_stays() {
    // dart `_scaleChannel`: a channel already past the targeted bound stays
    // put — scaling can't pull it back into range.
    assert_eq!(
        ours("@use \"sass:color\";\na {b: color.scale(color(srgb 1.2 0.5 0.7), $red: 10%)}\n"),
        "a {\n  b: color(srgb 1.2 0.5 0.7);\n}\n"
    );
    assert_eq!(
        ours("@use \"sass:color\";\na {b: color.scale(color(srgb -0.5 0.5 0.7), $red: -10%)}\n"),
        "a {\n  b: color(srgb -0.5 0.5 0.7);\n}\n"
    );
    // Still inside the bound: the normal lerp applies.
    assert_eq!(
        ours("@use \"sass:color\";\na {b: color.scale(color(srgb 1.2 0.5 0.7), $red: -10%)}\n"),
        "a {\n  b: color(srgb 1.08 0.5 0.7);\n}\n"
    );
}

#[test]
fn color_dart_vm_math_semantics() {
    // dart's `math.pow(x, 3)` is the VM's `x*x*x` intrinsic, NOT libm pow —
    // far-range oklab → xyz round-trips are bit-exact against the dart VM.
    assert_eq!(
        ours("@use \"sass:color\";\na {b: color.to-gamut(color.change(oklab(50% 500 -999999), $lightness: 150%), $method: clip)}\n"),
        "a {\n  b: color-mix(in oklab, color(xyz 593644542057412224 -153762246556647904 3418717351297831936) 100%, black);\n}\n"
    );
    // dart `SassColor._normalizeHue` reduces every constructed polar hue via
    // `(h % 360 + 360) % 360` — the fmod sequence perturbs the last ulp and
    // the spec carries it (lab→lch hue here ends …024, not atan2's …008).
    assert_eq!(
        ours("@use \"sass:color\";\n@use \"sass:math\";\na {b: math.div(color.channel(color.to-space(lab(50% 1 2), lch), \"hue\"), 1deg) * 1e15}\n"),
        "a {\n  b: 63434948822922024;\n}\n"
    );
    // An infinite hue goes through the same fmod and lands on NaN, which
    // dart-sass 1.104.0 then converts to 0 (a polar hue converts every
    // non-finite value).
    assert_eq!(
        ours("@use \"sass:meta\";\na {b: meta.inspect(lch(1% 2 calc(infinity)))}\n"),
        "a {\n  b: lch(1% 2 0deg);\n}\n"
    );
    // channel() builds a `%` number via `value * 100 / channel.max`; the
    // round trip through ×100 ÷100 perturbs far-range values by one ulp.
    assert_eq!(
        ours("@use \"sass:color\";\na {b: color.channel(color.to-space(color.change(black, $red: -999999), hwb), \"whiteness\") * 1e9}\n"),
        "a {\n  b: -392156470588235.4%;\n}\n"
    );
}

#[test]
fn number_negative_zero_keeps_its_sign() {
    // dart-sass 1.104.0 serializes a negative zero as `-0`. The sign is the
    // IEEE sign bit, not the way the number was written: `0 * -1` and
    // `-0 + -0` ARE negative zeros, while `0 - 0`, `0 + -0` and `-0 * -1` are
    // positive ones. Byte-matched to dart-sass 1.104.1. Offline.
    assert_eq!(
        ours("@use \"sass:math\";\na {\n  b: 0 * -1;\n  c: -0 + -0;\n  d: 0 - 0;\n  e: 0 + -0;\n  f: -0 * -1;\n  g: math.div(0, -1);\n  h: -0;\n  i: -0.0px;\n  j: math.sqrt(-0);\n}\n"),
        "a {\n  b: -0;\n  c: -0;\n  d: 0;\n  e: 0;\n  f: 0;\n  g: -0;\n  h: -0;\n  i: -0px;\n  j: -0;\n}\n"
    );
    // A color CHANNEL is the exception dart-sass carves out: it converts a
    // negative zero to 0 "as per the CSS spec", the alpha included.
    assert_eq!(
        ours("a {\n  b: hsl(-0, 50%, 50%);\n  c: color(srgb 0 0 0 / -0);\n  d: rgb(-0, 0, 0);\n  e: color(srgb -0 0 0);\n}\n"),
        "a {\n  b: hsl(0, 50%, 50%);\n  c: color(srgb 0 0 0 / 0);\n  d: rgb(0, 0, 0);\n  e: color(srgb 0 0 0);\n}\n"
    );
    // The channel a COMPUTATION writes counts too: `change`/`adjust`/`scale`
    // set the alpha directly on the working color, so the normalization has to
    // reach the stored alpha and not just a parsed one.
    assert_eq!(
        ours("@use \"sass:color\";\na {\n  b: color.change(oklch(50% 0.1 20deg), $alpha: -0);\n  c: color.change(lab(50% 1 2), $alpha: -0);\n  d: color.change(red, $alpha: -0);\n}\n"),
        "a {\n  b: oklch(50% 0.1 20deg / 0);\n  c: lab(50% 1 2 / 0);\n  d: rgba(255, 0, 0, 0);\n}\n"
    );
    // The comma-form `color.hwb()` stores its own channels instead of going
    // through the shared color construction, so it needs the same treatment —
    // `color.channel` and `meta.inspect` read that storage back verbatim.
    assert_eq!(
        ours("@use \"sass:color\";\n@use \"sass:meta\";\na {\n  b: color.channel(color.hwb(0, -0%, 0%), \"whiteness\");\n  c: meta.inspect(color.hwb(-0, -0%, -0%));\n  d: color.hwb(0, -0%, 0%);\n}\n"),
        "a {\n  b: 0%;\n  c: hwb(0 0% 0%);\n  d: red;\n}\n"
    );
}

#[test]
fn rounding_never_returns_a_negative_zero() {
    // A rounding RESULT is an integer in dart-sass, so it is never a negative
    // zero even where IEEE rounding produces one: `math.round(-0.4)` and
    // `round(to-zero, -0.4, 1)` are `0`, not `-0`. `math.abs(-0)` is `0` for a
    // different reason — IEEE `abs` clears the sign — while `math.div(0, -1)`
    // keeps it. Byte-matched to dart-sass 1.104.1. Offline.
    assert_eq!(
        ours("@use \"sass:math\";\na {\n  b: math.round(-0.4);\n  c: math.ceil(-0.4);\n  d: math.floor(-0);\n  e: round(to-zero, -0.4, 1);\n  f: round(nearest, -0.4, 1);\n  g: math.round(-0.4px);\n  h: math.abs(-0);\n  i: math.abs(-0px);\n}\n"),
        "a {\n  b: 0;\n  c: 0;\n  d: 0;\n  e: 0;\n  f: 0;\n  g: 0px;\n  h: 0;\n  i: 0px;\n}\n"
    );
    // An INFINITE step is the exception: `round()` returns the input's sign
    // unrounded rather than an integer, so a negative zero survives it. (Only
    // `down` runs off to `calc(-infinity)`.)
    assert_eq!(
        ours("@use \"sass:math\";\n$inf: math.div(1, 0);\na {\n  b: round(to-zero, -0.4, $inf);\n  c: round(nearest, -0, $inf);\n  d: round(up, -0.4, $inf);\n  e: round(down, -0.4, $inf);\n  f: round(to-zero, -0.4px, $inf * 1px);\n}\n"),
        "a {\n  b: -0;\n  c: -0;\n  d: -0;\n  e: calc(-infinity);\n  f: -0px;\n}\n"
    );
}

#[test]
fn number_format_dart_tostring_semantics() {
    // dart rounds the SHORTEST decimal spelling at the string level (11th
    // digit, half-up): 2154.15598416745's true value is …44978 (below the
    // half), but its shortest spelling ends in `5`, so dart rounds UP.
    assert_eq!(
        ours("a {b: 2154.15598416745}\n"),
        "a {\n  b: 2154.1559841675;\n}\n"
    );
    // ECMA toString tie-break: 657390374199289.25 has two equidistant
    // shortest spellings; dart picks the EVEN final digit (…289.2).
    assert_eq!(
        ours("a {b: (657390374199289 + 0.25)}\n"),
        "a {\n  b: 657390374199289.2;\n}\n"
    );
    // Half-up at the 10-digit boundary still applies.
    assert_eq!(ours("a {b: 0.00000000015}\n"), "a {\n  b: 0.0000000002;\n}\n");
    assert_eq!(ours("a {b: 1e-11}\n"), "a {\n  b: 0;\n}\n");
}

#[test]
fn color_oklch_to_oklab_round_trips_lms() {
    // dart's OklabColorSpace.convert has no same-space case: an oklch source
    // bound for oklab cubes into LMS and cube-roots straight back.
    assert_eq!(
        ours("@use \"sass:color\";\na {b: color.to-space(oklch(10% 999999 0deg), oklab)}\n"),
        "a {\n  b: oklab(9.9999999976% 999998.9999999992 0);\n}\n"
    );
    // A direct oklab→oklab conversion short-circuits at the toSpace level.
    assert_eq!(
        ours("@use \"sass:color\";\na {b: color.to-space(oklab(50% 0.1 0.1), oklab)}\n"),
        "a {\n  b: oklab(50% 0.1 0.1);\n}\n"
    );
}

#[test]
fn unicode_identifiers() {
    // Any non-ASCII code point is a valid identifier char (dart `isName`):
    // variables, property values, and selectors carry them unescaped.
    assert_eq!(
        ours("$v\u{e4}r: foo;\nblat {a: $v\u{e4}r}\n"),
        "blat {\n  a: foo;\n}\n"
    );
    assert_eq!(
        ours("@charset \"UTF-8\";\nfoo {\n  bar: f\u{f6}\u{f6} b\u{e2}r; }\n"),
        "@charset \"UTF-8\";\nfoo {\n  bar: f\u{f6}\u{f6} b\u{e2}r;\n}\n"
    );
}

#[test]
fn identifier_escape_decoding() {
    // Identifier escapes decode at the lexer level: `@w\61rn` IS `@warn`,
    // `@\69 f` is `@if`, and escaped function names normalize for dispatch.
    assert_eq!(
        ours("@function f\\6Fo-bar() {@return 1}\na {b: foo-b\\61r()}\n"),
        "a {\n  b: 1;\n}\n"
    );
    assert_eq!(ours("@\\69 f true {a {b: c}}\n"), "a {\n  b: c;\n}\n");
    // `@w\61rn` runs as @warn: output is just the rule.
    assert_eq!(ours("@w\\61rn warning;\na {b: c}\n"), "a {\n  b: c;\n}\n");
    // A mid-identifier escape after an interpolation uses the name-CHAR
    // rule (`#{foo}\-` is `foo-`), while a leading `\-` keeps its escape.
    assert_eq!(
        ours("a {b: #{foo}\\-; c: \\-#{foo}}\n"),
        "a {\n  b: foo-;\n  c: \\-foo;\n}\n"
    );
}

#[test]
fn selector_escape_terminating_space() {
    // A hex escape's terminating space is part of the token: `\02e foo` is
    // the single type selector `\.foo` (extendable), and a trailing
    // `selector\9 ` keeps its space in the emitted selector.
    assert_eq!(
        ours(".foo {a: b}\n\\.foo {c: d}\n.bar {@extend \\02e foo}\n"),
        ".foo {\n  a: b;\n}\n\n\\.foo, .bar {\n  c: d;\n}\n"
    );
    assert_eq!(ours("selector\\9 { x: y; }\n"), "selector\\9  {\n  x: y;\n}\n");
    assert_eq!(
        ours("@media screen\\9 { x {y: z} }\n"),
        "@media screen\\9  {\n  x {\n    y: z;\n  }\n}\n"
    );
}

#[test]
fn at_root_parent_ref() {
    // `&` inside @at-root resolves against the enclosing rule (dart
    // _styleRuleIgnoringAtRoot) while plain selectors stay at the root
    // (implicitParent: false), and deeper nesting re-enables the join.
    assert_eq!(
        ours(".foo {\n  @at-root & {\n    a: b;\n  }\n}\n"),
        ".foo {\n  a: b;\n}\n"
    );
    assert_eq!(
        ours("foo {\n  @at-root {\n    & { color: blue; }\n    &--modifier { color: red; }\n  }\n}\n"),
        "foo {\n  color: blue;\n}\n\nfoo--modifier {\n  color: red;\n}\n"
    );
    assert_eq!(
        ours("test {\n  @at-root {\n    & {\n      foo { bar: baz; }\n    }\n  }\n}\n"),
        "test foo {\n  bar: baz;\n}\n"
    );
    // @extend directly inside @at-root is outside any style rule.
    assert!(compile(
        ".a { x: y }\n.b { @at-root { @extend .a } }\n",
        &Options::default()
    )
    .is_err());
}

#[test]
fn at_root_queries() {
    // dart AtRootQuery: `(without: media)` escapes the media layer but
    // keeps the style rule (bare declarations re-wrap in the enclosing
    // selector); `(without: all)` escapes everything; quoted names work.
    assert_eq!(
        ours("@media print {\n  a {\n    @at-root (without: media) {\n      b: c;\n    }\n  }\n}\n"),
        "a {\n  b: c;\n}\n"
    );
    assert_eq!(
        ours("@keyframes a {\n  @at-root (without: all) {\n    b {c: d}\n  }\n}\n"),
        "@keyframes a {}\nb {\n  c: d;\n}\n"
    );
    // Kept layers re-wrap around the hoisted body at the root.
    assert_eq!(
        ours("@media screen {\n  @supports (color: red) {\n    @at-root (without: media) {\n      .x {y: z}\n    }\n  }\n}\n"),
        "@supports (color: red) {\n  .x {\n    y: z;\n  }\n}\n"
    );
    // `(with: all)` excludes nothing and runs in place.
    assert_eq!(
        ours("@media screen {\n  @at-root (with: \"all\") {\n    .x {y: z}\n  }\n}\n"),
        "@media screen {\n  .x {\n    y: z;\n  }\n}\n"
    );
}

#[test]
fn extend_target_in_omitted_bogus_rule() {
    // A bogus-combinator rule (`.a > + x`) is omitted from the CSS but
    // still satisfies @extend target matching (dart keeps it in the extend
    // graph); the extension result is bogus too, so the output is empty.
    assert_eq!(ours(".a > + x {a: b}\n.b y {@extend x}\n"), "");
    assert_eq!(ours(".a ~ > + .b > x {a: b}\n.c > + .d > y {@extend x}\n"), "");
    // A genuinely missing target still errors.
    assert!(compile(".a x {a: b}\n.b {@extend z}\n", &Options::default()).is_err());
}

#[test]
fn extend_trim_source_specificity() {
    // dart _trim only drops a selector when a superselector ALSO has at
    // least the victim's max SOURCE specificity: `.test-case` (1000) keeps
    // `.test-case:active` whose extender weighed 2000.
    assert_eq!(
        ours(concat!(
            "%default-color {color: red}\n%alt-color {color: green}\n",
            "%default-style {\n@extend %default-color;\n&:hover {@extend %alt-color}\n",
            "&:active {@extend %default-color}\n}\n",
            ".test-case {@extend %default-style}\n"
        )),
        ".test-case:active, .test-case {\n  color: red;\n}\n\n.test-case:hover {\n  color: green;\n}\n"
    );
}

#[test]
fn extend_transitive_multi_component_extender() {
    // `c {@extend b}` inside `a` (extender `a c`) plus `d {@extend a}`
    // yields `d c` — dart's _extendExistingExtensions re-extends the whole
    // extender complex. (dart orders this `a b, d b, a c, d c`; our paths
    // order differs pending the full _extendComplex order port.)
    let out = ours("a {\nb {a: b}\nc {@extend b}\n}\nd {@extend a}\n");
    let selectors = out.split(" {").next().unwrap();
    for sel in ["a b", "d b", "a c", "d c"] {
        assert!(
            selectors.split(", ").any(|s| s == sel),
            "missing {sel} in {selectors}"
        );
    }
}

#[test]
fn lone_percent_after_operand() {
    // `%` is modulo only when an operand follows; a trailing `%` is a lone
    // unquoted-string token (dart-sass css/percent).
    assert_eq!(ours("a {b: c %}\n"), "a {\n  b: c %;\n}\n");
    assert_eq!(ours("d {e: f(g %)}\n"), "d {\n  e: f(g %);\n}\n");
    // Real modulo still works.
    assert_eq!(ours("a {b: 7 % 3}\n"), "a {\n  b: 1;\n}\n");
}

#[test]
fn selector_linebreaks_with_stray_commas() {
    // A newline inside an empty comma part (stray commas) or BEFORE the
    // comma still marks the next complex as line-broken.
    assert_eq!(
        ours("#foo #bar,,\n,#baz #boom, {a: b}\n"),
        "#foo #bar,\n#baz #boom {\n  a: b;\n}\n"
    );
    assert_eq!(
        ours("a\n, b {\n  z & {\n    display: block;\n  }\n}\n"),
        "z a,\nz b {\n  display: block;\n}\n"
    );
}

#[test]
fn modulo_infinite_modulus() {
    // dart moduloLikeSass: an infinite DIVISOR returns the dividend when
    // signs agree and NaN otherwise; an infinite dividend is always NaN.
    assert_eq!(ours("a {b: 1px % calc(infinity * 1px)}\n"), "a {\n  b: 1px;\n}\n");
    assert_eq!(
        ours("a {b: -1px % calc(-infinity * 1px)}\n"),
        "a {\n  b: -1px;\n}\n"
    );
    assert_eq!(
        ours("a {b: 1px % calc(-infinity * 1px)}\n"),
        "a {\n  b: calc(NaN * 1px);\n}\n"
    );
    assert_eq!(ours("a {b: calc(infinity) % 3}\n"), "a {\n  b: calc(NaN);\n}\n");
}

#[test]
fn loud_comment_continuation_indent() {
    // Continuation lines of a loud comment gain the CURRENT output
    // indentation on top of their own source indentation.
    assert_eq!(
        ours(".foo {\n    /* Foo\n Bar\nBaz */\n  a: b; }\n"),
        ".foo {\n  /* Foo\n   Bar\n  Baz */\n  a: b;\n}\n"
    );
}

#[test]
fn id_tokens_when_not_hex_colors() {
    // `#` + identifier that isn't a valid color is an ID token (nav-up).
    assert_eq!(
        ours("a {b: #ab; c: #abcde; d: #abcg}\n"),
        "a {\n  b: #ab;\n  c: #abcde;\n  d: #abcg;\n}\n"
    );
    // Valid hex colors still parse as colors (color arithmetic errors).
    assert!(compile("a {b: #abc + 1}\n", &Options::default()).is_err());
    assert_eq!(ours("a {b: #abc}\n"), "a {\n  b: #abc;\n}\n");
}

#[test]
fn url_quoted_string_normalizes() {
    // A quoted url() is a normal function call whose string argument
    // serializes canonically (double quotes preferred, single kept when the
    // content has a double quote); unquoted urls stay plain tokens.
    assert_eq!(ours("a {b: url('x.png')}\n"), "a {\n  b: url(\"x.png\");\n}\n");
    assert_eq!(
        ours("e {f: url('it\"s.png')}\n"),
        "e {\n  f: url('it\"s.png');\n}\n"
    );
    assert_eq!(ours("e {f: url(plain.png)}\n"), "e {\n  f: url(plain.png);\n}\n");
}

#[test]
fn nth_child_anb_canonicalizes_in_rules() {
    // The An+B argument drops whitespace in plain rules too (not only
    // through the extend machinery).
    assert_eq!(
        ours("li:nth-child(3n - 3) {a: b}\n"),
        "li:nth-child(3n-3) {\n  a: b;\n}\n"
    );
    assert_eq!(
        ours("li:nth-child(-3n - 3) {a: b}\n"),
        "li:nth-child(-3n-3) {\n  a: b;\n}\n"
    );
}

#[test]
fn duplicate_pseudo_preserved_through_extend() {
    // `:baz:baz` is valid CSS; extension must not dedup the unchanged
    // pseudos of the original compound.
    assert_eq!(
        ours(".foo:baz:baz {a: b}\n.bar {@extend .foo}\n"),
        ".foo:baz:baz, .bar:baz:baz {\n  a: b;\n}\n"
    );
}

#[test]
fn progid_string_interpolation() {
    // `#{…}` inside a progid argument's quoted string still resolves.
    assert_eq!(
        ours(".foo {\n  filter: progid:DXImageTransform.Microsoft.AlphaImageLoader(src=\"#{foo}\", sizingMethod='scale');\n}\n"),
        ".foo {\n  filter: progid:DXImageTransform.Microsoft.AlphaImageLoader(src=\"foo\", sizingMethod='scale');\n}\n"
    );
}

#[test]
fn blank_list_elements_vanish() {
    // dart Value.isBlank: an empty unquoted string disappears from list
    // serialization, separator included; whitespace-only stays.
    assert_eq!(ours("a { a: foo #{\"\"}; }\n"), "a {\n  a: foo;\n}\n");
    assert_eq!(ours("b { b: foo #{\" \"}; }\n"), "b {\n  b: foo  ;\n}\n");
}

#[test]
fn media_feature_strings_unquote() {
    // Media-feature names/values serialize in interpolation context.
    assert_eq!(
        ours("@media screen and (\"min-width:#{20px}\") { a { b: c } }\n"),
        "@media screen and (min-width:20px) {\n  a {\n    b: c;\n  }\n}\n"
    );
    assert_eq!(
        ours("$s: \"20px\";\n@media (min-width: $s) { a { b: c } }\n"),
        "@media (min-width: 20px) {\n  a {\n    b: c;\n  }\n}\n"
    );
}

#[test]
fn double_minus_starts_a_term() {
    // `--` never subtracts: `1--em` is the space list `1 --em`, and
    // `5--3` is `5 --3`; single-minus subtraction still works.
    assert_eq!(
        ours("foo {bar: 1--em-2--em; baz: 5--3; qux: 5-3}\n"),
        "foo {\n  bar: 1 --em-2--em;\n  baz: 5 --3;\n  qux: 2;\n}\n"
    );
}

#[test]
fn at_rule_prelude_whitespace_collapses() {
    // Whitespace runs in a generic at-rule prelude collapse to single
    // spaces; quoted strings keep theirs.
    assert_eq!(
        ours(".foo {\n  @apply (  --bar  );\n}\n"),
        ".foo {\n  @apply ( --bar );\n}\n"
    );
}

#[test]
fn lexical_scoping_closures() {
    // A mixin/function body runs against its DEFINITION environment (dart's
    // Environment.closure), not the caller's stack: a caller-local variable
    // is invisible inside the body.
    assert!(compile(
        "@mixin m() {\n  a: $x;\n}\nfoo {\n  $x: 1;\n  @include m();\n}\n",
        &Options::default()
    )
    .is_err());
    // A local assignment inside a function stays local (issue_613): the
    // caller's $var is untouched by the function's own $var.
    assert_eq!(
        ours("$v: 1;\n@function f() { $v: 3; @return 0; }\n.s { $v: 4; $d: f(); c: $v; }\n.o { c: $v; }\n"),
        ".s {\n  c: 4;\n}\n\n.o {\n  c: 1;\n}\n"
    );
    // Parameter defaults see already-bound parameters (progressive binding).
    assert_eq!(
        ours("@mixin m($a, $b: $a) { x: $a $b; }\nfoo { @include m(1); }\n"),
        "foo {\n  x: 1 1;\n}\n"
    );
    // A global write inside a mixin lands in the global scope and is visible
    // through its closure afterwards.
    assert_eq!(
        ours("$g: old;\n@mixin set() { $g: new !global; }\nfoo { @include set(); v: $g; }\n"),
        "foo {\n  v: new;\n}\n"
    );
}

#[test]
fn lexical_scoping_functions_and_mixins() {
    // Functions and mixins are lexically scoped too (dart's parallel
    // _functions/_mixins frames): a nested definition shadows an outer one
    // only within its block (scss-tests 132/134).
    assert_eq!(
        ours("@mixin bar {a: b}\nfoo {\n  @mixin bar {c: d}\n  @include bar;\n}\nbaz {@include bar}\n"),
        "foo {\n  c: d;\n}\n\nbaz {\n  a: b;\n}\n"
    );
    assert_eq!(
        ours("@function foo() {@return 1}\nfoo {\n  @function foo() {@return 2}\n  a: foo();\n}\nbaz {b: foo()}\n"),
        "foo {\n  a: 2;\n}\n\nbaz {\n  b: 1;\n}\n"
    );
    // A function defined inside a rule is invisible outside it: the outer
    // call stays a plain CSS function (scss-tests 133).
    assert_eq!(
        ours("foo {\n  @function foo() {@return 1}\n  a: foo(); }\nbar {b: foo()}\n"),
        "foo {\n  a: 1;\n}\n\nbar {\n  b: foo();\n}\n"
    );
    // A user function shadowing a built-in reverts to the built-in outside
    // its block (functions-and-mixins).
    assert_eq!(
        ours("div {\n  span {\n    @function length($a, $b) { @return $a + $b; }\n    w: length(1, 2);\n  }\n  h: length(a b c);\n}\n"),
        "div span {\n  w: 3;\n}\ndiv {\n  h: 3;\n}\n"
    );
}

#[test]
fn unit_conversion_is_case_sensitive_with_frequency() {
    // dart's conversion table matches unit names exactly: `PX` and `px` are
    // DIFFERENT units (addition errors), `1in + 1Q` errors while `1in + 1q`
    // converts, and frequency `Hz`/`kHz` ARE convertible (canonical: Hz).
    assert!(compile("a { v: 1PX + 1px; }", &Options::default()).is_err());
    assert!(compile("a { v: 1in + 1Q; }", &Options::default()).is_err());
    assert_eq!(ours("a { v: 1kHz + 1Hz; }"), "a {\n  v: 1.001kHz;\n}\n");
    assert_eq!(ours("a { v: 1PX + 2PX; }"), "a {\n  v: 3PX;\n}\n");
    // calc classification stays case-INSENSITIVE: same-class non-convertible
    // pairs preserve, while the convertible pair folds.
    assert_eq!(
        ours("a { v: calc(1PX + 1px); }"),
        "a {\n  v: calc(1PX + 1px);\n}\n"
    );
    assert_eq!(ours("a { v: calc(1kHz + 1Hz); }"), "a {\n  v: 1.001kHz;\n}\n");
}

#[test]
fn hyphens_and_underscores_interchange_in_names() {
    // dart normalizes `_` to `-` in variable names at parse time and in
    // function/mixin names at definition/lookup, so all four spellings
    // resolve to the same member (52_interchangeable_hyphens_underscores).
    assert_eq!(
        ours("$my-var: 1;\n@mixin my-mix($p) { a: $p; b: $my_var; }\ndiv { @include my_mix(2); }\n"),
        "div {\n  a: 2;\n  b: 1;\n}\n"
    );
    assert_eq!(
        ours("@function blah_blah() { @return blah; }\ndiv { foo: blah-blah(); }\n"),
        "div {\n  foo: blah;\n}\n"
    );
    // A plain-CSS call keeps its original spelling (no user function).
    assert_eq!(
        ours("div { b: some_func(1); }\n"),
        "div {\n  b: some_func(1);\n}\n"
    );
    // `--`-prefixed calls are reserved for plain CSS: `--a()` never matches
    // `@function __a` (even though both normalize to `--a`), and
    // `@include --a` is a hard error.
    assert_eq!(
        ours("@function __a() {@return 1}\nb {c: --a(); d: __a()}\n"),
        "b {\n  c: --a();\n  d: 1;\n}\n"
    );
    assert!(compile("@mixin __a() {b: c}\nd {@include --a}\n", &Options::default()).is_err());
}

#[test]
fn url_whitespace_falls_back_to_function_call() {
    // A plain-URL token allows whitespace only directly before `)`: interior
    // whitespace re-parses the call as a normal function, so SassScript
    // evaluates (`url(foo + bar)` -> `url(foobar)`).
    assert_eq!(
        ours("div { c: url(foo + bar); b: url( foo ); a: url(foo bar); }\n"),
        "div {\n  c: url(foobar);\n  b: url(foo);\n  a: url(foo bar);\n}\n"
    );
}

#[test]
fn call_results_are_slash_free_and_if_supports_splat() {
    // dart applies withoutSlash() to every call result: extracting a
    // slash-division value through a built-in resolves it.
    assert_eq!(
        ours("@use \"sass:list\";\na {b: list.nth(3 1/2 4, 2)}\n"),
        "a {\n  b: 0.5;\n}\n"
    );
    // if() accepts splat arguments (macro args evaluate the splat eagerly).
    assert_eq!(ours("c {d: if(true, 1/2 null...)}\n"), "c {\n  d: 0.5;\n}\n");
}

#[test]
fn important_is_a_value_term() {
    // `!important` (any case, space after `!` allowed) is a value term, so it
    // can appear mid-list and in mixin/function arguments; a stray `!default`
    // after a declaration value still errors.
    assert_eq!(
        ours("@mixin foo($x) { style: $x; }\ndiv {\n  @include foo(0px inset !important);\n  fludge: foo bar ! Important hux;\n}\n"),
        "div {\n  style: 0px inset !important;\n  fludge: foo bar !important hux;\n}\n"
    );
    assert!(compile("x { v: foo !default; }", &Options::default()).is_err());
}

#[test]
fn escaped_literal_space_survives_selector_normalization() {
    // `sp\ ` (an escaped literal space) is part of the identifier: the
    // whitespace collapse/trim in selector normalization must not eat it —
    // at the end of a comma part, before a descendant space, or trailing.
    assert_eq!(
        ours("sp\\ , x {\n  color: red;\n}\n"),
        "sp\\ , x {\n  color: red;\n}\n"
    );
    assert_eq!(
        ours("div sp\\  p {\n  color: red;\n}\n"),
        "div sp\\  p {\n  color: red;\n}\n"
    );
    assert_eq!(
        ours("div sp\\  {\n  color: red;\n}\n"),
        "div sp\\  {\n  color: red;\n}\n"
    );
}

#[test]
fn plain_css_function_arg_validation() {
    // dart: an unknown function is plain CSS — no keyword arguments, and an
    // empty unbracketed list / a map has no CSS representation; `null`
    // serializes to nothing and `[]` stays.
    assert!(compile("foo { color: missing($a: b); }", &Options::default()).is_err());
    assert!(compile("foo { foo: foo(()); }", &Options::default()).is_err());
    assert!(compile("foo { foo: foo((a: b)); }", &Options::default()).is_err());
    assert_eq!(
        ours("x { v: foo(null); w: foo([]); }\n"),
        "x {\n  v: foo();\n  w: foo([]);\n}\n"
    );
    // The BUILTIN min/max (via splat / meta.call) requires numbers.
    assert!(compile(
        "@use \"sass:meta\";\n$foo: 1 2 3 blah 4;\nfoo { bar: meta.call(min, $foo...); }",
        &Options::default()
    )
    .is_err());
    // A parent ending in a combinator can't substitute into a compound `&`.
    assert!(compile(".a > { &.b { x: y; } }", &Options::default()).is_err());
    assert_eq!(ours(".a > { & .b { x: y; } }\n"), ".a > .b {\n  x: y;\n}\n");
}

#[test]
fn misc_error_validation_batch() {
    // `@elseif` is a deprecated spelling of `@else if`.
    assert_eq!(
        ours("$x: 3px;\n@if $x == 2px { a { v: 1; } }\n@elseif $x == 3px { b { v: 2; } }\n"),
        "b {\n  v: 2;\n}\n"
    );
    // A declaration inside `@at-root` that no style rule wraps is an error.
    assert!(compile(
        "@mixin bar() { @at-root { @content; } }\n.test { @include bar() { color: yellow; } }",
        &Options::default()
    )
    .is_err());
    // `something\:` is a selector (the escape is never a declaration colon).
    assert_eq!(
        ours("something\\:{ padding: 2px; }\n"),
        "something\\: {\n  padding: 2px;\n}\n"
    );
    // `:nth-child()` requires an An+B argument.
    assert!(compile("a:nth-child() { color: red; }", &Options::default()).is_err());
}

#[test]
fn extend_products_inherit_extender_linebreaks() {
    // dart's ComplexSelector.lineBreak travels with the selector: when
    // `@extend` adds the extenders to `.foo`'s rule, each added complex
    // keeps its OWN source line break (issue_1574/2179).
    assert_eq!(
        ours(".foo { bar: baz; }\na,\nb,\nc { @extend .foo; }\n"),
        ".foo, a,\nb,\nc {\n  bar: baz;\n}\n"
    );
}

#[test]
fn pseudo_parent_ref_takes_whole_parent_list() {
    // A `&` only inside a pseudo argument takes the WHOLE parent list in
    // place — ONE complex, no cartesian expansion — with an optional ident
    // suffix (libsass#2630).
    assert_eq!(
        ours(".a, .b {\n  :not(&-c) {d: e}\n}\n"),
        ":not(.a-c, .b-c) {\n  d: e;\n}\n"
    );
    assert_eq!(
        ours(".a, .b {\n  :not(&) {d: e}\n}\n"),
        ":not(.a, .b) {\n  d: e;\n}\n"
    );
    // Mixed parts keep dart's order: the pseudo part resolves once, at its
    // position in the FIRST parent round.
    assert_eq!(
        ours(".a, .b {\n  x:hover &, :is(&) {d: e}\n}\n"),
        "x:hover .a, :is(.a, .b), x:hover .b {\n  d: e;\n}\n"
    );
}

#[test]
fn unit_identifier_grammar() {
    // dart `identifier(unit: true)`: a unit body may contain digits
    // (`1a2b3c`), underscores, escapes (`1\65 m` is `em`), and may START
    // with `-` when an identifier follows (`1-em` minus `2-em` is `-1-em`)
    // — while `1--em` stays the list `1 --em` and `1- 2` subtracts.
    assert_eq!(
        ours("@use \"sass:meta\";\na { v: meta.type-of(1a2b3c); w: (1-em-2-em); x: (1\\65 _em); y: (1--em); z: (1- 2); }\n"),
        "a {\n  v: number;\n  w: -1-em;\n  x: 1e_em;\n  y: 1 --em;\n  z: -1;\n}\n"
    );
}

#[test]
fn content_block_runs_in_child_scope() {
    // A content block is a user-defined callable: a `$var:` first declared
    // inside it stays local to the block, so a global-only variable is NOT
    // overwritten (get_mixin content:scope/redeclare/vars).
    assert_eq!(
        ours("@mixin a { @content; }\n$g: global;\nfoo {\n  $r: rule;\n  @include a { $g: inner; $r: inner; }\n  g: $g;\n  r: $r;\n}\n"),
        "foo {\n  g: global;\n  r: inner;\n}\n"
    );
}

#[test]
fn trailing_comments_join_previous_line() {
    // dart's trailing-comment serializer rule: a loud comment starting on the
    // line the previous construct ended joins that line with a single space.
    assert_eq!(ours("a {b: {c: d} /**/}\n"), "a {\n  b-c: d; /**/\n}\n");
    // A block whose ONLY child is a trailing comment stays on one line, with
    // ` }` on the same line (the comment compares against the `{` line).
    assert_eq!(ours("a {\n  @font-face {/**/}\n}\n"), "@font-face { /**/ }\n");
    assert_eq!(ours("a {\n  @keyframes {/**/}\n}\n"), "@keyframes { /**/ }\n");
    // A comment on its own source line keeps its own indented output line.
    assert_eq!(
        ours("a {\n  b: c;\n  /* own line */\n}\n"),
        "a {\n  b: c;\n  /* own line */\n}\n"
    );
}

#[test]
fn at_root_batches_graft_at_their_target_layer() {
    // dart visitAtRootRule + _trimIncluded: an `@at-root (without: media)`
    // batch re-enters the tree at the topmost EXCLUDED layer. Escaping the
    // outermost at-rule appends the batch at the root AFTER the in-progress
    // @media node (issue_1890) — never before it.
    assert_eq!(
        ours(".w {\n  @media (min-width: 480px) {\n    display: block;\n    @at-root (without: media) {\n      .box { display: inline-block; }\n    }\n  }\n}\n"),
        "@media (min-width: 480px) {\n  .w {\n    display: block;\n  }\n}\n.w .box {\n  display: inline-block;\n}\n"
    );
    // Declarations before AND after the at-root join ONE style-rule copy in
    // the original media (dart's entry copy has no following sibling inside
    // the media node); a post-marker RULE splits into a media copy instead.
    assert_eq!(
        ours(".w {\n  @media m {\n    a: 1;\n    @at-root (without: media) { .b { v: 1; } }\n    .pm { c: 3; }\n    d: 4;\n  }\n}\n"),
        "@media m {\n  .w {\n    a: 1;\n    d: 4;\n  }\n}\n.w .b {\n  v: 1;\n}\n@media m {\n  .w .pm {\n    c: 3;\n  }\n}\n"
    );
    // A kept layer ABOVE the excluded one is the graft root: the batch lands
    // INSIDE the existing @supports node at its current end, and a later
    // declaration copy follows it there.
    assert_eq!(
        ours(".w {\n  @supports (display: flex) {\n    @media m {\n      a: 1;\n      @at-root (without: media) { .box { b: 2; } }\n    }\n    c: 9;\n  }\n}\n"),
        "@supports (display: flex) {\n  @media m {\n    .w {\n      a: 1;\n    }\n  }\n  .w .box {\n    b: 2;\n  }\n  .w {\n    c: 9;\n  }\n}\n"
    );
    // With no enclosing style rule dart marks the batch's last node as a
    // group end: the next root node gets a blank line.
    assert_eq!(
        ours("@media a {\n  .x { p: 1; }\n  @at-root (without: media) { .b { v: 1; } }\n  .z { r: 3; }\n}\n"),
        "@media a {\n  .x {\n    p: 1;\n  }\n}\n.b {\n  v: 1;\n}\n\n@media a {\n  .z {\n    r: 3;\n  }\n}\n"
    );
}

#[test]
fn interpolation_skips_leading_whitespace_and_comments() {
    // dart `singleInterpolation` runs whitespace() (which also consumes
    // comments) BEFORE the expression: `#{ a }` parses everywhere, and a
    // comment inside an interpolation ends at the first `*/` without being
    // scanned for `#{` or quotes (issue_1798/3).
    assert_eq!(
        ours("a { content: \"#{ a /*#{\"}*/ }\"; }\n"),
        "a {\n  content: \"a\";\n}\n"
    );
    assert_eq!(ours("a { b: \"#{ 1 + 2}\"; }\n"), "a {\n  b: \"3\";\n}\n");
    // Selector templates and identifier templates share the rule.
    assert_eq!(ours("a#{ \" b\"} { c: d; }\n"), "a b {\n  c: d;\n}\n");
    assert_eq!(ours("a { b: c#{ 1 + 2}; }\n"), "a {\n  b: c3;\n}\n");
}

#[test]
fn custom_property_values_reindent_like_dart() {
    // dart _writeReindentedValue: a multi-line custom value strips
    // min(name column, least continuation indent) from each continuation
    // line and prefixes the current output indentation; deeper relative
    // indentation survives, blank-with-whitespace lines stay.
    assert_eq!(
        ours("a {\n         --deep: {\n           foo: bar;\n         };\n}\n"),
        "a {\n  --deep: {\n    foo: bar;\n  };\n}\n"
    );
    // A continuation line ABOVE the base re-anchors the strip at its own
    // indent: `--below: \n    foo\n bar` strips 1 (min of col 2 and 1).
    assert_eq!(
        ours("a {\n  --below:\n    foo\n bar\n   baz;\n}\n"),
        "a {\n  --below:\n     foo\n  bar\n    baz;\n}\n"
    );
    // Hard tabs count as single characters in the strip.
    assert_eq!(
        ours("a {\n\t--tabs: {\n\t\tfoo: bar;\n\t};\n}\n"),
        "a {\n  --tabs: {\n  \tfoo: bar;\n  };\n}\n"
    );
    // .sass keeps the original name column through transpilation.
    assert_eq!(
        ours_sass("a\n  --b: (c\n    d)\n"),
        "a {\n  --b: (c\n    d);\n}\n"
    );
    // Compressed output folds each newline + following whitespace run to a
    // single space instead (dart _writeFoldedValue).
    use sasso::OutputStyle;
    let compressed = compile(
        "a {\n  --x: {\n    foo: bar;\n  };\n}\n",
        &Options::default().with_style(OutputStyle::Compressed),
    )
    .expect("compile failed");
    assert_eq!(compressed, "a{--x: { foo: bar; }}");
}

#[test]
fn var_empty_second_arg_only_after_first_positional() {
    // dart's allowEmptySecondArg fires only when exactly one POSITIONAL
    // argument precedes the trailing comma (`positional.length == 1 &&
    // named.isEmpty`): `var(--c, )` keeps an empty second argument...
    assert_eq!(ours("a {b: var(--c, )}\n"), "a {\n  b: var(--c, );\n}\n");
    // ...while a named first argument gets ordinary trailing-comma behavior
    // and dispatches to a user-defined override with one argument.
    assert_eq!(
        ours("@function var($arg) {@return [$arg]}\na {b: var($arg: --c, )}\n"),
        "a {\n  b: [--c];\n}\n"
    );
}

#[test]
fn interp_string_newlines_raw_at_top_level_collapse_inside_lists() {
    // dart _performInterpolation: a directly interpolated string contributes
    // its raw text (the outer quoted serializer re-escapes the newline)...
    assert_eq!(
        ours("$s: \"x\\a y\";\na { b: \"p#{$s}q\"; }\n"),
        "a {\n  b: \"px\\ayq\";\n}\n"
    );
    // ...while a string inside a composite value serializes quote-less, its
    // newlines collapsing to single spaces (issue_1786).
    assert_eq!(
        ours("$s: \"x\\a y\";\na { b: \"#{q $s}\"; c: \"#{($s, $s)}\"; }\n"),
        "a {\n  b: \"q x y\";\n  c: \"x y, x y\";\n}\n"
    );
}

#[test]
fn loud_comment_glued_to_property_name_joins_it() {
    // dart _declarationOrBuffer appends ONE rawText(loudComment) to the name
    // when `/*` directly follows the identifier (issue_1422); a whitespace-
    // separated comment is mid-trivia and drops.
    assert_eq!(ours(".a { foo/*c*/: bar; }\n"), ".a {\n  foo/*c*/: bar;\n}\n");
    assert_eq!(ours(".a { foo /*c*/ : bar; }\n"), ".a {\n  foo: bar;\n}\n");
    // Only the first glued comment joins; later ones are trivia.
    assert_eq!(
        ours(".a { foo/*a*/ /*b*/: bar; }\n"),
        ".a {\n  foo/*a*/: bar;\n}\n"
    );
    // An interpolated name glues the same way.
    assert_eq!(ours(".a { #{f}oo/*c*/: bar; }\n"), ".a {\n  foo/*c*/: bar;\n}\n");
}

#[test]
fn escaped_callable_names_decode_to_one_key() {
    // dart decodes CSS escapes into identifier text at parse time, so the
    // raw definition `foo\func` and the call site's canonical `foo\f unc`
    // (and dash/underscore variants) name the same callable (issue_553).
    assert_eq!(
        ours("$foo\\bar: 1;\n@function foo\\func() { @return 1; }\n@mixin foo\\mixin() { m: 1; }\n.t {\n  v: $foo\\bar;\n  f: foo\\func();\n  @include foo\\mixin();\n}\n"),
        ".t {\n  v: 1;\n  f: 1;\n  m: 1;\n}\n"
    );
    // Equivalent escape spellings reach the same definition.
    assert_eq!(
        ours("@function f\\6fo() { @return 1; }\na { b: f\\6f o(); c: foo(); }\n"),
        "a {\n  b: 1;\n  c: 1;\n}\n"
    );
}

#[test]
fn has_pseudo_drops_placeholder_arguments_like_dart() {
    // dart's serializer drops invisible (placeholder) complexes from every
    // pseudo's argument list: after `@extend %not`, `div:has(%not)` renders
    // `div:has(.not)` — the placeholder never reaches the output
    // (issue_1797); a `:has` whose whole argument stays invisible can never
    // match and its rule drops.
    assert_eq!(
        ours(
            "%not { c: red; }\n.not { @extend %not; }\ndiv:has(%not) { x: y; }\nspan:has(%never) { z: w; }\n"
        ),
        ".not {\n  c: red;\n}\n\ndiv:has(.not) {\n  x: y;\n}\n"
    );
}

#[test]
fn ampersand_in_attribute_strings_is_literal_and_unchanged_lists_skip_trim() {
    // A `&` inside an attribute's quoted string is literal text, NOT a parent
    // reference — the selector still gets the implicit parent join
    // (issue_2291 `bar[baz="#{&}"][str="&"]` under `foo`).
    assert_eq!(
        ours("foo {\n  bar[baz=\"#{&}\"][str=\"&\"] {\n    a: q;\n  }\n}\n"),
        "foo bar[baz=foo][str=\"&\"] {\n  a: q;\n}\n"
    );
    // When no selector in a rule is changed by any extension, dart returns
    // the list untouched: duplicates from a reparsed interpolation survive
    // even while @extend is active elsewhere.
    assert_eq!(
        ours("%p { x: y; }\n.q { @extend %p; }\nA, B {\n  #{&}-z {\n    c: d;\n  }\n}\n"),
        ".q {\n  x: y;\n}\n\nA A, A B-z, B A, B B-z {\n  c: d;\n}\n"
    );
}

#[test]
fn plain_css_parent_rules_nest_verbatim_under_importing_rule() {
    // dart `nestWithin` with preserveParentSelectors: a plain-CSS top-level
    // rule whose selector contains `&` keeps native CSS-nesting semantics —
    // it nests VERBATIM inside one leading parent shell, while `&`-less
    // rules get the descendant join (through_import:top_level_parent).
    let dir = std::env::temp_dir().join("sasso_tip_parity");
    std::fs::create_dir_all(&dir).unwrap();
    std::fs::write(dir.join("plain.css"), "x {y: z}\n& {b {c: d}}\n").unwrap();
    let imp = FsImporter::new(vec![dir.clone()]);
    let opts = Options::default().with_importer(&imp);
    let out = compile("a {@import \"plain\"}\n", &opts).expect("compile failed");
    assert_eq!(
        out,
        "a {\n  & {\n    b {\n      c: d;\n    }\n  }\n}\na x {\n  y: z;\n}"
    );
}

#[test]
fn load_css_parent_rules_nest_verbatim_too() {
    // The meta.load-css path reparents the module's CSS into the caller's
    // rule; an `&`-bearing top-level rule keeps native nesting there as well
    // (through_load_css:top_level_parent).
    let dir = std::env::temp_dir().join("sasso_tlc_parity");
    std::fs::create_dir_all(&dir).unwrap();
    std::fs::write(dir.join("plain.css"), "& {b {c: d}}\n").unwrap();
    let imp = FsImporter::new(vec![dir.clone()]);
    let opts = Options::default().with_importer(&imp);
    let out = compile(
        "@use \"sass:meta\";\na {@include meta.load-css(\"plain\")}\n",
        &opts,
    )
    .expect("compile failed");
    assert_eq!(out, "a {\n  & {\n    b {\n      c: d;\n    }\n  }\n}");
}

#[test]
fn use_inside_imported_sheet_joins_importing_rule() {
    // `outer {@import "imported"}` where the imported sheet `@use`s a module:
    // the module evaluates in a clean context (its `&` is null) but its CSS
    // joins the importing rule's selector (nested_import_into_use).
    let dir = std::env::temp_dir().join("sasso_niu_parity");
    std::fs::create_dir_all(&dir).unwrap();
    std::fs::write(
        dir.join("_imported.scss"),
        "@use \"sass:meta\";\n@use \"used\";\n\nin-imported {parent: meta.inspect(&)}\n",
    )
    .unwrap();
    std::fs::write(
        dir.join("_used.scss"),
        "@use \"sass:meta\";\nin-used {parent: meta.inspect(&)}\n",
    )
    .unwrap();
    let imp = FsImporter::new(vec![dir.clone()]);
    let opts = Options::default().with_importer(&imp);
    let out = compile("outer {@import \"imported\"}\n", &opts).expect("compile failed");
    assert_eq!(
        out,
        "outer in-used {\n  parent: (in-used,);\n}\nouter in-imported {\n  parent: (outer in-imported,);\n}"
    );
}

#[test]
fn module_import_hoist_keeps_comment_runs_with_their_imports() {
    // dart _combineCss visitModule: each module's leading comment+import run
    // goes to the imports bucket (per-module _indexAfterImports), comments
    // before a @use ride ahead of the used module's contribution, and an
    // out-of-order plain import re-inserts at its module's import-run end.
    let dir = std::env::temp_dir().join("sasso_order_parity");
    std::fs::create_dir_all(&dir).unwrap();
    std::fs::write(
        dir.join("_midstream.scss"),
        "/* before use in midstream */\n@use \"upstream\";\n/* after use in midstream */\n@import \"midstream.css\";\na {in: midstream}\n",
    )
    .unwrap();
    std::fs::write(
        dir.join("_upstream.scss"),
        "/* before css in upstream */\n@import \"upstream.css\";\na {in: upstream}\n",
    )
    .unwrap();
    let imp = FsImporter::new(vec![dir.clone()]);
    let opts = Options::default().with_importer(&imp);
    let out = compile(
        "/* before use in input */\n@use \"midstream\";\n@import \"input.css\";\na {in: input}\n",
        &opts,
    )
    .expect("compile failed");
    assert_eq!(
        out,
        "/* before use in input */\n/* before use in midstream */\n/* before css in upstream */\n@import \"upstream.css\";\n/* after use in midstream */\n@import \"midstream.css\";\n@import \"input.css\";\na {\n  in: upstream;\n}\n\na {\n  in: midstream;\n}\n\na {\n  in: input;\n}"
    );
}

#[test]
fn at_in_selector_is_expected_selector_with_dual_span() {
    // dart: `@` has no legal position in a selector. From literal text the
    // error points at the source column (shifting across any preceding
    // interpolations); from interpolated output it renders the dual-span
    // "error in interpolated output" block (todo_single_escape).
    let err = compile(".a@b { c: d; }\n", &Options::default()).unwrap_err();
    let msg = format!("{err}");
    assert!(msg.contains("expected selector."), "{msg}");
    assert!(msg.contains("1:3"), "{msg}");
    let err = compile("$x: \"y\";\n.a#{$x}@b { c: d; }\n", &Options::default()).unwrap_err();
    let msg = format!("{err}");
    assert!(msg.contains("2:8"), "{msg}");
    // Without diagnostic source the dual-span block isn't rendered, but the
    // position is still the interpolation expression's start.
    let err = compile(".test31#{'\\@baz'} { content: '3.1'; }\n", &Options::default()).unwrap_err();
    let msg = format!("{err}");
    assert!(msg.contains("expected selector."), "{msg}");
    assert!(msg.contains("1:10"), "{msg}");
    // With MORE than one interpolation the offending column has to be matched
    // to the right one: `@` comes out of the second, so the caret is at its
    // start (2:11), not the first's (dart, verified 2026-09-17).
    let err = compile("$x: \"y\";\n.a#{$x}b#{'\\@z'} { c: d; }\n", &Options::default()).unwrap_err();
    let msg = format!("{err}");
    assert!(msg.contains("expected selector."), "{msg}");
    assert!(msg.contains("2:11"), "{msg}");
}

#[test]
fn user_calc_function_overrides_calculation() {
    // dart resolves user functions before calculation semantics: a
    // user-defined calc() shadows the CSS calculation, receiving the
    // argument as an ordinarily-evaluated expression; vendor-prefixed
    // -x-calc( stays a parse-time special function (issue_1706).
    assert_eq!(
        ours("@function calc($e) { @return custom; }\n@function -foo-calc($e) { @return custom; }\n.t {\n  a: calc(1px * 1%);\n  b: -foo-calc(2px * 2%);\n}\n"),
        ".t {\n  a: custom;\n  b: -foo-calc(2px * 2%);\n}\n"
    );
    assert_eq!(
        ours("@function calc($e) { @return $e; }\na { b: calc(2px * 3); }\n"),
        "a {\n  b: 6px;\n}\n"
    );
}

#[test]
fn media_feature_is_a_full_boolean_expression() {
    // dart parses a media feature's value with _expressionUntilComparison —
    // a full SassScript expression stopping only at range comparisons. So
    // `(screen and (color))` is ONE boolean expression whose `and` returns
    // its second operand (issue_485), while range syntax still parses.
    assert_eq!(
        ours("@media (not (screen and (color))) { a {b: c} }\n"),
        "@media not (color) {\n  a {\n    b: c;\n  }\n}\n"
    );
    assert_eq!(
        ours("@media (width > 0) { a {b: c} }\n"),
        "@media (width > 0) {\n  a {\n    b: c;\n  }\n}\n"
    );
}

#[test]
fn transitive_multi_simple_extender_chain_folds() {
    // A multi-simple compound extender whose simple is itself extended by a
    // DISJOINT multi-simple selector folds transitively: `%a` extended by
    // `c:s`, and `c` extended by `d::e`, yields `d:s::e`
    // (extend-tests/086.1).
    assert_eq!(
        ours("%a {\n  x:y;\n}\nb:after:not(:first-child) {\n  @extend %a;\n}\nc:s {\n  @extend %a;\n}\nd::e {\n  @extend c;\n}\n"),
        "c:s, d:s::e, b:after:not(:first-child) {\n  x: y;\n}\n"
    );
    // A self-overlapping multi-simple extender (`.a` extended by `.a.mod1`) is
    // NOT folded here — that stays with dart's extension-graph fixpoint
    // (regression guard for directives/extend/after_target:multiple_recursive).
    assert_eq!(
        ours(".a .b {\n  c: d;\n}\n.a.mod1, .a.mod2 {\n  @extend .a, .b;\n}\n"),
        ".a .b, .a .a.mod1, .a .a.mod2 {\n  c: d;\n}\n"
    );
}

#[test]
fn selector_replace_promotes_replaced_original() {
    // dart promotes the first FULLY-replaced product of each input complex to
    // an original, so it survives `_trim` even when a sibling product
    // superselects it: `replace((c, d c), c, e)` keeps `d e` (the bare `e`
    // from input `c` would otherwise trim it). (core_functions/selector/
    // replace:format/input/non_string/selector.)
    assert_eq!(
        ours("@use \"sass:selector\";\na {b: selector.replace((c, d c), \"c\", \"e\")}\n"),
        "a {\n  b: e, d e;\n}\n"
    );
    // But an INTERMEDIATE (not fully replaced) product is still trimmed:
    // multi-target replace collapses `c.d` to `.e`, not `.d.e, .e`.
    assert_eq!(
        ours("@use \"sass:selector\";\na {b: selector.replace(\"c.d\", \"c, .d\", \".e\")}\n"),
        "a {\n  b: .e;\n}\n"
    );
}

#[test]
fn extend_registration_order_sequential() {
    // dart applies each `@extend` in registration order, re-extending the
    // accumulated selector list — NOT a one-shot cartesian. For case 229 the
    // nested `c {@extend b}` registers first (rule `a b` becomes `a b, a c`),
    // then `d {@extend a}` folds over that → `a b, d b, a c, d c`.
    assert_eq!(
        ours("a {\n  b {a: b}\n  c {@extend b}\n}\nd {@extend a}\n"),
        "a b, d b, a c, d c {\n  a: b;\n}\n"
    );
    // Cross-branch placeholder redundancy (extend-tests/234).
    assert_eq!(
        ours(".e %z {a: b}\n%x .c %y {@extend %z}\n.a, .b {@extend %x}\n.a .d {@extend %y}\n"),
        ".e .a .c .d, .e .b .c .a .d, .a .e .b .c .d, .a .c .e .d, .b .c .e .a .d {\n  a: b;\n}\n"
    );
    // A three-level extend cycle settles to the full closure via the fixpoint
    // re-fold, each rule keeping its own registration-order head.
    assert_eq!(
        ours(".foo {a: b; @extend .bar}\n.bar {c: d; @extend .baz}\n.baz {e: f; @extend .foo}\n"),
        ".foo, .baz, .bar {\n  a: b;\n}\n\n.bar, .foo, .baz {\n  c: d;\n}\n\n.baz, .bar, .foo {\n  e: f;\n}\n"
    );
}

#[test]
fn extend_selector_pseudo_one_shot() {
    // A target inside a selector pseudo is extended by REWRITING the compound in
    // place; dart applies such extensions simultaneously. Two `:not` extends
    // unify into one compound (compound-unification-in-not)...
    assert_eq!(
        ours(".a {@extend .c}\n.b {@extend .d}\n:not(.c):not(.d) {x: y}\n"),
        ":not(.c):not(.a):not(.d):not(.b) {\n  x: y;\n}\n"
    );
    // ...a `:not` chain keeps the pre-merge product (extend-result-of-extend)...
    assert_eq!(
        ours(".a {@extend :not(.b)}\n.b {@extend .c}\n:not(.c) {x: y}\n"),
        ":not(.c):not(.b), .a:not(.c) {\n  x: y;\n}\n"
    );
    // ...and re-extending an EXTENDER's `:is()` keeps the pre-extension form
    // (dart sass/dart-sass#1297).
    assert_eq!(
        ours(":is(midstream) {@extend upstream}\ndownstream {@extend midstream}\nupstream {a: b}\n"),
        "upstream, :is(midstream), :is(midstream, downstream) {\n  a: b;\n}\n"
    );
    // But a pseudo whose argument is NOT a target stays on the registration-order
    // fold so its placeholder order is preserved (extend-tests/086.1).
    assert_eq!(
        ours("%a {\n  x:y;\n}\nb:after:not(:first-child) {\n  @extend %a;\n}\nc:s {\n  @extend %a;\n}\nd::e {\n  @extend c;\n}\n"),
        "c:s, d:s::e, b:after:not(:first-child) {\n  x: y;\n}\n"
    );
}

#[test]
fn extend_one_shot_vs_incremental_order() {
    // dart `addSelector` extends a rule registered AFTER all its `@extend`s by
    // the whole store at ONCE, in `_extendComplex`'s `paths` order (the LAST
    // unification choice varies slowest). The rule `.e.f` here comes after both
    // extends, so its compound unifies to `.e.f, .a .f.b, .c .e.d, …`
    // (nested-compound-unification) — NOT the incremental interleaving.
    assert_eq!(
        ours(".a .b {@extend .e}\n.c .d {@extend .f}\n.e.f {x: y}\n"),
        ".e.f, .a .f.b, .c .e.d, .a .c .b.d, .c .a .b.d {\n  x: y;\n}\n"
    );
    // A rule registered BEFORE its `@extend`s is extended INCREMENTALLY in
    // registration order: each `:not` is inserted right after the target, so a
    // later `@extend` sorts ahead of an earlier one — `:not(.x)` extended by
    // `.y` then `.z` gives `:not(.x):not(.z):not(.y)` (reverse), the opposite of
    // the one-shot order.
    assert_eq!(
        ours(":not(.x) {a: b}\n.y {@extend .x}\n.z {@extend .x}\n"),
        ":not(.x):not(.z):not(.y) {\n  a: b;\n}\n"
    );
    // The same rule registered AFTER its extends takes the one-shot order
    // (forward): `:not(.x):not(.y):not(.z)`.
    assert_eq!(
        ours(".y {@extend .x}\n.z {@extend .x}\n:not(.x) {a: b}\n"),
        ":not(.x):not(.y):not(.z) {\n  a: b;\n}\n"
    );
}

/// Shared scratch-dir helper for multi-file pre-module-comment tests.
fn comment_scratch(tag: &str) -> std::path::PathBuf {
    let dir = std::env::temp_dir().join(format!(
        "sasso-premod-{tag}-{}-{}",
        std::process::id(),
        std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .map(|d| d.as_nanos())
            .unwrap_or(0)
    ));
    std::fs::create_dir_all(&dir).expect("create scratch dir");
    dir
}

#[test]
fn pre_module_comment_survives_an_invisible_load() {
    // A CSS-less load (`@use "tokens"`, pure variables) puts nothing between
    // a file-heading comment and the next module's CSS, so the header still
    // leads `lib`'s comment — and the nested sibling's repeat edge into `lib`
    // adds no second copy (uswds `_palette-registry.scss` PALETTE header).
    // Measured against dart-sass 1.104.1.
    use std::fs;
    let dir = comment_scratch("deep");
    let imp = FsImporter::new(vec![dir.clone()]);
    let opts = Options::default().with_importer(&imp);
    fs::write(dir.join("_lib.scss"), "/* lib */\n$l: 1;\n").unwrap();
    fs::write(dir.join("_tokens.scss"), "$t: 1;\n").unwrap();
    fs::write(
        dir.join("_reg.scss"),
        "/* reg header */\n@use \"tokens\" as *;\n@use \"lib\" as *;\n@use \"sib\" as *;\n$r: 1;\n",
    )
    .unwrap();
    fs::write(dir.join("_sib.scss"), "@use \"lib\" as *;\n$s: 1;\n").unwrap();
    let out = compile("@use \"reg\";\n", &opts).expect("reg compiles");
    assert_eq!(out, "/* reg header */\n/* lib */");
}

#[test]
fn pre_module_comment_not_repeated_at_a_sibling_edge() {
    // A repeat edge from a SIBLING module into an already-loaded target adds
    // nothing: `mid`'s header is written once, where it stands. Measured
    // against dart-sass 1.104.1.
    use std::fs;
    let dir = comment_scratch("sib");
    let imp = FsImporter::new(vec![dir.clone()]);
    let opts = Options::default().with_importer(&imp);
    fs::write(dir.join("_lib.scss"), "/* lib */\n$l: 1;\n").unwrap();
    fs::write(dir.join("_tokens.scss"), "$t: 1;\n").unwrap();
    fs::write(dir.join("_vis.scss"), "/* vis */\n$v: 0;\n").unwrap();
    fs::write(
        dir.join("_mid.scss"),
        "/* mid header */\n@use \"lib\" as *;\n@use \"tokens\" as *;\n.m { x: 1; }\n",
    )
    .unwrap();
    fs::write(dir.join("_user.scss"), "@use \"lib\" as *;\n$u: 4;\n").unwrap();
    fs::write(
        dir.join("_outer.scss"),
        "/* outer note */\n@use \"vis\" as *;\n@use \"mid\" as *;\n@use \"user\" as *;\n",
    )
    .unwrap();
    let out = compile("@use \"outer\";\n", &opts).expect("outer compiles");
    assert_eq!(
        out,
        "/* outer note */\n/* vis */\n/* mid header */\n/* lib */\n.m {\n  x: 1;\n}"
    );
}

#[test]
fn pre_module_comment_not_repeated_after_a_css_less_load() {
    // The same shape as `pre_module_comment_not_repeated_at_a_sibling_edge`
    // with the CSS-less `tokens` loaded FIRST: the order of the invisible
    // load made no difference to the output before 1.104.1 either, and makes
    // none now. Measured against dart-sass 1.104.1.
    use std::fs;
    let dir = comment_scratch("phantom");
    let imp = FsImporter::new(vec![dir.clone()]);
    let opts = Options::default().with_importer(&imp);
    fs::write(dir.join("_lib.scss"), "/* lib */\n$l: 1;\n").unwrap();
    fs::write(dir.join("_tokens.scss"), "$t: 1;\n").unwrap();
    fs::write(dir.join("_vis.scss"), "/* vis */\n$v: 0;\n").unwrap();
    fs::write(
        dir.join("_mid.scss"),
        "/* mid header */\n@use \"tokens\" as *;\n@use \"lib\" as *;\n.m { x: 1; }\n",
    )
    .unwrap();
    fs::write(dir.join("_user.scss"), "@use \"lib\" as *;\n$u: 4;\n").unwrap();
    fs::write(
        dir.join("_outer.scss"),
        "/* outer note */\n@use \"vis\" as *;\n@use \"mid\" as *;\n@use \"user\" as *;\n",
    )
    .unwrap();
    let out = compile("@use \"outer\";\n", &opts).expect("outer compiles");
    assert_eq!(
        out,
        "/* outer note */\n/* vis */\n/* mid header */\n/* lib */\n.m {\n  x: 1;\n}"
    );
}

#[test]
fn pre_module_comments_never_cascade() {
    // The shape that used to produce a THIRD copy of "/* note */" (uswds
    // color() 7-vs-6): each comment is written once, at the point it stands.
    // Measured against dart-sass 1.104.1.
    use std::fs;
    let dir = comment_scratch("cascade");
    let imp = FsImporter::new(vec![dir.clone()]);
    let opts = Options::default().with_importer(&imp);
    fs::write(dir.join("_seed.scss"), "/* seed */\n$sd: 0;\n").unwrap();
    fs::write(dir.join("_lib.scss"), "/* lib */\n$l: 1;\n").unwrap();
    fs::write(dir.join("_mid.scss"), "/* note */\n@use \"lib\" as *;\n$m: 1;\n").unwrap();
    fs::write(dir.join("_vis2.scss"), "/* vis2 */\n$v: 1;\n").unwrap();
    fs::write(
        dir.join("_sib.scss"),
        "@use \"lib\" as *;\n@use \"vis2\" as *;\n$s: 1;\n",
    )
    .unwrap();
    fs::write(dir.join("_tail.scss"), "@use \"vis2\" as *;\n$t: 1;\n").unwrap();
    fs::write(
        dir.join("_outer.scss"),
        "/* outer */\n@use \"seed\" as *;\n@use \"mid\" as *;\n@use \"sib\" as *;\n@use \"tail\" as *;\n",
    )
    .unwrap();
    let out = compile("@use \"outer\";\n", &opts).expect("outer compiles");
    assert_eq!(out, "/* outer */\n/* seed */\n/* note */\n/* lib */\n/* vis2 */");
}

#[test]
fn dropped_placeholder_modules_leave_no_blank() {
    // Two placeholder-only modules under an index: the group-separator Blank
    // materialized between their scopes must vanish when every rule inside is
    // dropped (uswds `placeholders/` trailing blank line).
    use std::fs;
    let dir = comment_scratch("phblank");
    let imp = FsImporter::new(vec![dir.clone()]);
    let opts = Options::default().with_importer(&imp);
    fs::write(dir.join("_c.scss"), "/* c */\n$x: 1;\n").unwrap();
    fs::write(dir.join("_pa.scss"), "%a1 {\n  q: 1;\n}\n\n%a2 {\n  q: 2;\n}\n").unwrap();
    fs::write(dir.join("_pb.scss"), "%b1 {\n  q: 3;\n}\n\n%b2 {\n  q: 4;\n}\n").unwrap();
    fs::write(dir.join("_ph.scss"), "@forward \"pa\";\n@forward \"pb\";\n").unwrap();
    let out = compile("@use \"c\";\n@use \"ph\";\n", &opts).expect("ph compiles");
    assert_eq!(out, "/* c */");
}

#[test]
fn each_over_null_iterates_once() {
    // dart `Value.asList` defaults to `[this]` — null included. Bootstrap's
    // `valid-radius(null)` relies on the single `$v: null` round (tabler
    // avatars: `@include border-radius(map.get($size, border-radius))`).
    assert_eq!(
        ours("$out: ();\n@each $v in null {\n  $out: append($out, $v);\n}\n.a {\n  n: length($out);\n}\n"),
        ".a {\n  n: 1;\n}\n"
    );
}

#[test]
fn multi_compound_extension_uses_paths_order() {
    // ONE extension hitting BOTH compounds of `.btn + .btn`: dart runs a
    // single `_extendComplex` whose `paths` cartesian varies the FIRST
    // component fastest — (o,o), (e,o), (o,e), (e,e) — even on the
    // incremental fold path (forem `.crayons-btn + .crayons-btn`).
    assert_eq!(
        ours(".g .b + .b {\n  q: 1;\n}\n.e {\n  @extend .b;\n}\n"),
        ".g .b + .b, .g .e + .b, .g .b + .e, .g .e + .e {\n  q: 1;\n}\n"
    );
}

#[test]
fn duplicate_extension_keeps_first_merged_store_position() {
    // The same (target, extender) pair registered from TWO modules merges
    // per-STORE in dart, so each keeps its own store-merge rank; the product
    // dedup then keeps the FIRST applied position — the descending-first-load
    // module's — with its linebreak flag (chirpy `#access-lastmod a:hover`).
    use std::fs;
    let dir = comment_scratch("dupext");
    let imp = FsImporter::new(vec![dir.clone()]);
    let opts = Options::default().with_importer(&imp);
    fs::write(dir.join("_ph.scss"), "%h {\n  color: red;\n}\n").unwrap();
    fs::write(
        dir.join("_l1.scss"),
        "@use 'ph';\n.dup {\n  .in:hover {\n    @extend %h;\n  }\n}\n",
    )
    .unwrap();
    fs::write(dir.join("_l2.scss"), "@use 'ph';\n.l2 {\n  @extend %h;\n}\n").unwrap();
    fs::write(dir.join("_l3.scss"), "@use 'ph';\n.l3 {\n  @extend %h;\n}\n").unwrap();
    fs::write(
        dir.join("_l4.scss"),
        "@use 'ph';\n.x4,\n.dup {\n  .in:hover {\n    @extend %h;\n  }\n}\n",
    )
    .unwrap();
    fs::write(dir.join("_g1.scss"), "@forward 'l1';\n@forward 'l2';\n").unwrap();
    fs::write(dir.join("_g2.scss"), "@forward 'l3';\n@forward 'l4';\n").unwrap();
    fs::write(dir.join("_mainx.scss"), "@forward 'g1';\n@forward 'g2';\n").unwrap();
    let out = compile("@use \"mainx\";\n", &opts).expect("compiles");
    assert_eq!(
        out,
        ".x4 .in:hover,\n.dup .in:hover, .l3, .l2 {\n  color: red;\n}"
    );
}

#[test]
fn trailing_invisible_chain_packs_next_group_tight() {
    // The group separator rides the subtree's LAST flattened node: an
    // extend-only rule nested ANY levels down owns the enclosing group's end
    // and never renders, so the next group packs tight (chirpy panel→footer).
    assert_eq!(
        ours("%lh {\n  color: red;\n}\n#al {\n  a {\n    color: inherit;\n\n    &:hover {\n      @extend %lh;\n    }\n  }\n}\nfooter {\n  z: 1;\n}\n"),
        "#al a:hover {\n  color: red;\n}\n\n#al a {\n  color: inherit;\n}\nfooter {\n  z: 1;\n}\n"
    );
}

#[test]
fn hoisted_import_keeps_nested_flatten_tight() {
    // Hoisting an out-of-order plain-CSS `@import` must not regroup the css
    // flow: a parent rule still packs tight against its flattened nested
    // children (forem `body`/`body.hidden-shell`), while a sibling seam the
    // import USED to separate keeps its blank.
    assert_eq!(
        ours("body {\n  margin: 0;\n\n  &.x {\n    padding: 0;\n  }\n}\n@import \"y.css\";\n"),
        "@import \"y.css\";\nbody {\n  margin: 0;\n}\nbody.x {\n  padding: 0;\n}\n"
    );
    assert_eq!(
        ours(".a {\n  q: 1;\n}\n@import \"y.css\";\n.b {\n  w: 2;\n}\n"),
        "@import \"y.css\";\n.a {\n  q: 1;\n}\n\n.b {\n  w: 2;\n}\n"
    );
}

#[test]
fn at_root_wrapper_children_pack_tight() {
    // Rules flattened out of an `@at-root` WRAPPER rule were visited with
    // `_styleRule != null` in dart — no per-rule group end — so they pack
    // tight; the blank belongs after the whole unit (wagtail sidebar).
    assert_eq!(
        ours(".footer {\n  color: red;\n\n  @at-root .slim #{&} {\n    &__a {\n      x: 1;\n    }\n\n    &__b {\n      y: 2;\n    }\n  }\n}\n.next {\n  z: 3;\n}\n"),
        ".footer {\n  color: red;\n}\n.slim .footer__a {\n  x: 1;\n}\n.slim .footer__b {\n  y: 2;\n}\n\n.next {\n  z: 3;\n}\n"
    );
}

#[test]
fn load_css_copy_reacquires_group_separators() {
    // dart's meta.load-css re-visits the combined css node-by-node
    // (`_combineCss(module, clone: true).accept(this)`), so every re-visited
    // top-level style rule re-acquires isGroupEnd — the copy's rules
    // blank-separate even where the source module packed a parent tight
    // against its flattened nested children (reveal.js print/pdf.scss).
    use std::fs;
    let dir = comment_scratch("loadcss");
    let imp = FsImporter::new(vec![dir.clone()]);
    let opts = Options::default().with_importer(&imp);
    fs::write(
        dir.join("_pdf.scss"),
        "html.rp {\n  * {\n    a: 1;\n  }\n\n  & {\n    b: 2;\n  }\n\n  body {\n    c: 3;\n  }\n}\n",
    )
    .unwrap();
    let out = compile(
        "@use \"sass:meta\";\n.first {\n  q: 0;\n}\n@include meta.load-css(\"pdf\");\n",
        &opts,
    )
    .expect("compiles");
    assert_eq!(
        out,
        ".first {\n  q: 0;\n}\n\nhtml.rp * {\n  a: 1;\n}\n\nhtml.rp {\n  b: 2;\n}\n\nhtml.rp body {\n  c: 3;\n}"
    );
}

#[test]
fn a_module_header_stays_out_of_the_import_run() {
    // A loaded module's heading comment belongs to the CSS flow, not to the
    // loader's leading `@import` bucket: `b`'s hoisted `@import "x.css"` goes
    // to the top while `/*! A HEADER */` stays down with `a`'s CSS
    // (nextcloud: styles.scss's SPDX header at icons.scss's edge). Measured
    // against dart-sass 1.104.1.
    use std::fs;
    let dir = comment_scratch("premodclone");
    let imp = FsImporter::new(vec![dir.clone()]);
    let opts = Options::default().with_importer(&imp);
    fs::write(dir.join("_seed.scss"), "/* seed */\n$s: 0;\n").unwrap();
    fs::write(dir.join("_lib.scss"), "/* lib */\n$l: 1;\n").unwrap();
    fs::write(
        dir.join("_a.scss"),
        "/*! A HEADER */\n@use \"lib\" as *;\n.a {\n  q: 1;\n}\n",
    )
    .unwrap();
    fs::write(
        dir.join("_b.scss"),
        "@use \"lib\" as *;\n@import \"x.css\";\n.b {\n  w: 2;\n}\n",
    )
    .unwrap();
    fs::write(
        dir.join("_outer.scss"),
        "/* outer */\n@use \"seed\" as *;\n@use \"a\" as *;\n@use \"b\" as *;\n",
    )
    .unwrap();
    let out = compile("@use \"outer\";\n", &opts).expect("compiles");
    assert_eq!(
        out,
        "/* outer */\n@import \"x.css\";\n/* seed */\n/*! A HEADER */\n/* lib */\n.a {\n  q: 1;\n}\n\n.b {\n  w: 2;\n}"
    );
}

#[test]
fn same_rule_sibling_extenders_never_chain() {
    // dart applies ONE `_extendList` per registration — an @extend whose two
    // extender complexes both contain the target must not chain one through
    // the other (tabler: `body[data-bs-theme=dark] [data-bs-theme=light],
    // body[data-theme=dark] [data-theme=light] {@extend [data-bs-theme=dark]}`
    // conjured `body[data-theme=dark] body[data-theme=light] […]`).
    assert_eq!(
        ours("[data-bs-theme=dark], [data-theme=dark] {\n  color-scheme: dark;\n}\nbody[data-bs-theme=dark] [data-bs-theme=light],\nbody[data-theme=dark] [data-theme=light] {\n  @extend [data-bs-theme=dark];\n}\n"),
        "[data-bs-theme=dark], body[data-bs-theme=dark] [data-bs-theme=light],\nbody[data-theme=dark] [data-theme=light], [data-theme=dark] {\n  color-scheme: dark;\n}\n"
    );
}

#[test]
fn product_duplicating_original_keeps_original_position_and_break() {
    // dart's `_originals` is `Set.identity()`: an extension product VALUE-
    // equal to one of the rule's own selectors is not an original, so the
    // coverage trim drops it and the original survives at its own position
    // with its own line break (tabler `.btn-sm,\n.btn-group-sm > .btn`).
    assert_eq!(
        ours(".btn-sm,\n.btn-group-sm > .btn {\n  a: 1;\n}\n.btn-group-sm > .btn {\n  @extend .btn-sm;\n}\n"),
        ".btn-sm,\n.btn-group-sm > .btn {\n  a: 1;\n}\n"
    );
    // Interleaved products across several duplicated originals: source order
    // and breaks all preserved (tabler `h1, .h1 { a {} }` + `.h1 {@extend h1}`).
    assert_eq!(
        ours(".h1 {\n  @extend h1;\n}\n.h2 {\n  @extend h2;\n}\nh1 a,\nh2 a,\n.h1 a,\n.h2 a {\n  q: 1;\n}\n"),
        "h1 a,\nh2 a,\n.h1 a,\n.h2 a {\n  q: 1;\n}\n"
    );
    // Without a duplicate, the product still appends (single line, extender's
    // flag).
    assert_eq!(
        ours(".h1 {\n  @extend h1;\n}\nh1 a {\n  q: 1;\n}\n"),
        "h1 a, .h1 a {\n  q: 1;\n}\n"
    );
}

#[test]
fn calc_interpolation_is_full_sassscript() {
    // Inside `#{}` the calc-only grammar restrictions are lifted: dart-sass
    // evaluates the interpolated expression as ordinary SassScript and splices
    // the resulting text into the calculation, so a unary minus on a variable
    // or parenthesis is fine there (momiji-rs/sasso#24, from the Lichess
    // stylesheets).
    let scss = concat!(
        "$h: 20px;\n",
        "a {\n",
        "  b: calc(#{-$h} - 1px);\n",
        "  c: calc(1px + #{-$h});\n",
        "  d: calc(#{-$h - 5px} - 1px);\n",
        "  e: calc(#{-($h)} * 2);\n",
        "  f: calc(#{- $h});\n",
        "  g: min(#{-$h}, 1px);\n",
        "}\n",
    );
    assert_eq!(
        ours(scss),
        concat!(
            "a {\n",
            "  b: calc(-20px - 1px);\n",
            "  c: calc(1px + -20px);\n",
            "  d: calc(-25px - 1px);\n",
            "  e: calc(-20px * 2);\n",
            "  f: calc(-20px);\n",
            "  g: min(-20px, 1px);\n",
            "}\n",
        )
    );
    assert_parity(scss);
    // The whole SassScript grammar is available inside the interpolation:
    // slash division, `if()`, string concatenation — none of which a bare
    // calculation would accept.
    let scss = concat!(
        "$h: 20px;\n",
        "a {\n",
        "  b: calc(#{$h / 2} + 1px);\n",
        "  c: calc(#{if(true, -$h, 1px)});\n",
        "  d: calc(#{\"a\" + \"b\"});\n",
        "  e: calc(#{-$h}#{-$h});\n",
        "  f: calc((#{-$h}) * 2);\n",
        "}\n",
    );
    assert_eq!(
        ours(scss),
        concat!(
            "a {\n",
            "  b: calc(10px + 1px);\n",
            "  c: calc(-20px);\n",
            "  d: calc(ab);\n",
            "  e: calc(-20px-20px);\n",
            "  f: calc((-20px) * 2);\n",
            "}\n",
        )
    );
    assert_parity(scss);
    // Outside interpolation the calculation grammar still rejects `-$x` — and
    // a calculation nested INSIDE the interpolation re-arms the restriction.
    for bad in [
        "$h: 20px;\na { b: calc(-$h - 1px); }\n",
        "$h: 20px;\na { b: calc(#{calc(-$h)}); }\n",
    ] {
        assert!(ours_err(bad).contains("can't be used in a calculation"), "{bad}");
        assert_error_parity(bad);
    }
}

#[test]
fn mixin_content_nested_in_supports_accepts_content_block() {
    // The "does this mixin use @content" scan must descend into `@supports`
    // bodies like it does for `@media` (momiji-rs/sasso#24, from the Lichess
    // stylesheets).
    let scss = concat!(
        "@mixin firefox {\n",
        "  @supports (-moz-appearance: none) {\n",
        "    @content;\n",
        "  }\n",
        "}\n",
        ".b {\n",
        "  @include firefox {\n",
        "    color: red;\n",
        "  }\n",
        "}\n",
    );
    assert_eq!(
        ours(scss),
        "@supports (-moz-appearance: none) {\n  .b {\n    color: red;\n  }\n}\n"
    );
    assert_parity(scss);
    // Deeper nesting (`@media` > `@supports`) and a `using` clause through it.
    let scss = concat!(
        "@mixin safari($size) {\n",
        "  @media (hover: hover) {\n",
        "    @supports not (-webkit-touch-callout: none) {\n",
        "      @content($size);\n",
        "    }\n",
        "  }\n",
        "}\n",
        ".c {\n",
        "  @include safari(2px) using ($s) {\n",
        "    padding: $s;\n",
        "  }\n",
        "}\n",
    );
    assert_eq!(
        ours(scss),
        concat!(
            "@media (hover: hover) {\n",
            "  @supports not (-webkit-touch-callout: none) {\n",
            "    .c {\n",
            "      padding: 2px;\n",
            "    }\n",
            "  }\n",
            "}\n",
        )
    );
    assert_parity(scss);
    // A mixin with NO `@content` anywhere — `@supports` or not — still rejects
    // a content block.
    let bad = "@mixin m { @supports (display: grid) { x: 1; } }\na { @include m { y: 2; } }\n";
    assert!(ours_err(bad).contains("Mixin doesn't accept a content block."));
    assert_error_parity(bad);
}

/// An at-rule whose NAME is interpolated carries the same source span as the
/// plain spelling, so the serializer's trailing-comment rule applies to it: a
/// comment that opens on the rule's `{` line joins that line, and one that
/// opens on its `}` line joins that. sasso gave such a rule no span at all, so
/// both comments went to a line of their own. Byte-verified against dart-sass
/// 1.103.1.
#[test]
fn interpolated_at_rule_joins_a_trailing_comment_like_dart() {
    assert_eq!(
        ours("@#{\"media\"} screen { /* t */\n  a { b: c; }\n}\n"),
        "@media screen { /* t */\n  a {\n    b: c;\n  }\n}\n"
    );
    assert_eq!(
        ours("@#{\"font-face\"} {\n  a: b;\n} /* after */\n"),
        "@font-face {\n  a: b;\n} /* after */\n"
    );
    // The same shapes written plainly, for contrast.
    assert_eq!(
        ours("@media screen { /* t */\n  a { b: c; }\n}\n"),
        "@media screen { /* t */\n  a {\n    b: c;\n  }\n}\n"
    );
    assert_parity("@#{\"media\"} screen { /* t */\n  a { b: c; }\n}\n");
    assert_parity("@#{\"font-face\"} {\n  a: b;\n} /* after */\n");
}

/// The filter overload applies to the NAMESPACED spelling too, and that is
/// dart's behaviour rather than an accident of sharing one implementation.
///
/// Reviewers of #122 proposed three times that `color.grayscale(1)` should
/// reject its numeric `$color` instead, on the ground that the overload is
/// global-only. dart disagrees: it produces the CSS filter and deprecates
/// having done so (`color-module-compat`, emitted since #124 — the warning text
/// is locked by `tests/fixtures/diagnostics/deprecation-color-module-compat`).
/// Restricting the overload to global dispatch would change our OUTPUT in three
/// places where it currently matches.
///
/// This lives in the live-parity suite on purpose: it asks dart rather than
/// encoding what I believe dart does.
#[test]
fn parity_namespaced_filter_overload() {
    assert_parity_compressed(
        "@use \"sass:color\";\n.a {\n  filter: color.grayscale(1);\n  filter: color.invert(0.5);\n  filter: color.opacity(0.5);\n}\n",
    );
}

/// The global spelling of the same overload, beside a real colour call that
/// must still resolve as Sass (#122).
#[test]
fn parity_global_filter_overload() {
    assert_parity_compressed(
        ".a {\n  filter: grayscale(1);\n  filter: invert(0.5);\n  filter: opacity(0.5);\n  filter: saturate(50%);\n  color: grayscale(#abc);\n}\n",
    );
}

/// `color.alpha`'s Microsoft-filter overload, which the namespaced spelling
/// takes as well: every argument an `<identifier>=<value>` unquoted string, and
/// the whole call passed through verbatim. The single-argument form is also
/// reachable by name, because `$color` is what that parameter is called — and
/// dart takes the filter branch there too rather than asking for a colour.
#[test]
fn parity_namespaced_ms_filter_overload() {
    assert_parity_compressed(
        "@use \"sass:color\";\n.a {\n  filter: color.alpha(opacity=20);\n  filter: color.alpha(a=b, c=d);\n  filter: color.alpha($color: opacity=20);\n}\n",
    );
    // A real colour argument is still the channel getter.
    assert_parity_compressed("@use \"sass:color\";\n.a {\n  b: color.alpha(#abc);\n}\n");
    // The bare name a star import binds is the MODULE member, and takes the
    // same overload. The global spelling returns such a call verbatim before
    // dispatch; this one must not, or it never reaches the module (#124).
    assert_parity_compressed(
        "@use \"sass:color\" as *;\n.a {\n  filter: alpha(opacity=20);\n  filter: alpha(a=b, c=d);\n  b: alpha(#abc);\n}\n",
    );
}

/// Both halves of the module filter overload reached through a function
/// reference instead of a direct call: `meta.get-function($module: "color")`
/// hands back the same member, and dart applies the overload — and the
/// deprecation — to it. (The warning texts are locked by
/// `deprecation-color-module-compat-call-ref`.)
#[test]
fn parity_module_filter_overload_via_function_reference() {
    assert_parity_compressed(
        "@use \"sass:color\";\n@use \"sass:meta\";\n.a {\n  a: meta.call(meta.get-function(\"grayscale\", $module: \"color\"), 1);\n  b: meta.call(meta.get-function(\"alpha\", $module: \"color\"), opacity=20);\n  c: meta.call(meta.get-function(\"grayscale\", $module: \"color\"), #abc);\n}\n",
    );
}

/// The percent-channel multiplication order, asked of dart rather than
/// encoded: `_percentageOrUnitless` is `max * value / 100`, and both halves of
/// the 0.4-max channels (the constructors and `color.change`) have to agree
/// with it down to the last bit — the dust the other order leaves is what the
/// compressed writer rounds, and rounding drops a leading zero dart keeps.
#[test]
fn parity_percent_channel_multiplication_order() {
    for value in [
        "oklab(50% -40% -75%)",
        "oklab(50% 40% 75%)",
        "oklch(50% 40% 90)",
        "lab(50% -40% 30%)",
        "lch(50% 40% 90deg)",
        "rgb(19.9% 30.1% 40.7%)",
        "hsl(120, 40.7%, 30.1%)",
        "color.change(oklab(50% 0.2 -0.3), $a: -40%)",
        "color.change(oklab(50% 0.2 -0.3), $b: -75%)",
        "color.change(oklch(50% 0.2 90deg), $chroma: 40%)",
        "color.change(lab(50% 20 30), $a: 40.7%)",
        "color.change(red, $green: 19.9%)",
        "color.change(red, $alpha: 40.7%)",
        "color.to-space(oklab(50% -40% -75%), oklch)",
        "color.channel(oklab(50% -40% -75%), \"a\")",
        "color.channel(oklch(50% 40% 90deg), \"chroma\")",
        "color.channel(rgb(19.9% 30% 40%), \"red\")",
    ] {
        let scss = format!("@use \"sass:color\";\na {{\n  b: {value};\n}}\n");
        assert_parity(&scss);
        assert_parity_compressed(&scss);
    }
    // Every percent, over the whole sweep of channel maxes, at a precision
    // where the two orders part ways.
    for pct in ["-40", "-19.9", "0.7", "19.9", "30.1", "40.7", "75"] {
        let scss = format!(
            "@use \"sass:color\";\na {{\n  b: oklab(50% {pct}% {pct}%);\n  c: lab(50% {pct}% {pct}%);\n  d: oklch(50% {pct}% 90deg);\n  e: lch(50% {pct}% 90deg);\n  f: rgb({pct}% {pct}% {pct}%);\n}}\n"
        );
        assert_parity(&scss);
        assert_parity_compressed(&scss);
    }
}

/// An `@import`'s modifiers are written verbatim from the PARSER's spelling,
/// which has a stray space a media RULE never shows. This belongs in the live
/// suite: it is a quirk, and the only way to be sure of a quirk is to ask.
#[test]
fn parity_css_import_media_spelling() {
    for modifiers in [
        "x, print and (orientation: landscape)",
        "x, screen and (a: 1) and (b: 2)",
        "x, screen and not (a: 1)",
        "x, screen and ((a: 1) or (b: 2))",
        "x, only screen and (a: 1)",
        "x, not screen and (a: 1)",
        "x, screen",
        "x, print and (a: 1), tv and (b: 2), speech",
        "(a: 1) and (b: 2), screen and (c: 3)",
        "x, SCREEN and (A: 1)",
        "screen and (a: 1)",
        "screen and (a: 1), print and (b: 2)",
    ] {
        let scss = format!("@import url(\"a.css\") {modifiers};\n");
        assert_parity(&scss);
        assert_parity_compressed(&scss);
        // The same queries under a real `@media`, which spells them its own way.
        let media = format!("@media {modifiers} {{\n  b {{\n    c: d;\n  }}\n}}\n");
        assert_parity(&media);
        assert_parity_compressed(&media);
    }
    // Modifiers only an `@import` accepts, so there is no `@media` half.
    for modifiers in [
        "supports(display: flex) screen and (a: 1)",
        "supports(display: flex) x, screen and (a: 1)",
        "layer(a) screen, print and (b: 2)",
        "layer screen, print and (b: 2)",
    ] {
        let scss = format!("@import url(\"a.css\") {modifiers};\n");
        assert_parity(&scss);
        assert_parity_compressed(&scss);
    }
}

/// A plain-CSS custom callable's SassScript declaration takes the optional
/// space; a verbatim one keeps its source text. Both kinds, in both styles.
#[test]
fn parity_custom_function_declaration_space() {
    for scss in [
        "@function --a() { #{result}: 1 + 1; }\n",
        "@function --a() { #{result}: { b: c; } }\n",
        "@function --a() { #{result}: { b: 1 + 1; c: 2 * 3; } }\n",
        "@function --a() { result: 1 + 1; }\n",
        "@function --a() { result:1 + 1; }\n",
        "@function --a() { result: ; }\n",
    ] {
        assert_parity(scss);
        assert_parity_compressed(scss);
    }
}

/// A private-use character: escaped by the unquoted writer in every style but
/// compressed, where it goes out as its own bytes and earns the BOM — while
/// `inspect` escapes it whatever the style, because it serializes in the
/// default one.
#[test]
fn parity_unquoted_private_use_character() {
    for scss in [
        "a { b: unquote(\"\\e000\"); }\n",
        "a { b: unquote(\"\\f8ff\"); }\n",
        "a { b: unquote(\"\\f0000\"); }\n",
        "a { b: unquote(\"\\10fffd\"); }\n",
        "a { b: \\f0000; }\n",
        "a { b: unquote(\"\\e000\") x; }\n",
        "a { b: (unquote(\"\\e000\"), x); }\n",
        "a#{unquote(\"\\e000\")} { b: c; }\n",
        "a { --x: unquote(\"\\e000\"); }\n",
        "@use \"sass:meta\";\na { b: meta.inspect((unquote(\"\\e000\"), x)); }\n",
        "@use \"sass:string\";\na { b: string.length(inspect(unquote(\"\\e000\"))); }\n",
        "@use \"sass:string\";\na { b: string.length(inspect(unquote(\"\\e000\") x)); }\n",
        // Not private use: raw in both styles already, and still non-ASCII.
        "a { b: unquote(\"\\4e2d\"); }\n",
    ] {
        assert_parity(scss);
        assert_parity_compressed(scss);
    }
}

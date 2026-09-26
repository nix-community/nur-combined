//! Library-level golden tests.
//!
//! Every expected string here was produced by dart-sass 1.100 (expanded,
//! unless noted) and verified byte-for-byte. They run without any external
//! tool, so they gate the parser/evaluator/emitter on every `cargo test`.

use std::collections::HashMap;

use sasso::{
    compile, CanonicalUrl, CanonicalizeContext, Importer, ImporterError, ImporterResult, Options,
    OutputStyle, Syntax,
};

// `compile` returns the stylesheet WITHOUT a trailing newline (byte-for-byte
// what dart-sass's library API returns). The expanded goldens below were
// captured from the dart-sass CLI, which appends one to NON-empty output (empty
// output stays empty), so mirror that here. The library's no-trailing-newline
// contract is pinned by `library_api_omits_trailing_newline`.
fn css(input: &str) -> String {
    let out = compile(input, &Options::default()).expect("compile should succeed");
    if out.is_empty() {
        out
    } else {
        out + "\n"
    }
}

// Compressed goldens were captured from the library API directly (no trailing
// newline), so this helper compares against `compile` verbatim.
fn css_compressed(input: &str) -> String {
    compile(input, &Options::default().with_style(OutputStyle::Compressed)).expect("compile should succeed")
}

/// The library API (`compile`) must not emit a trailing newline in either
/// style — that matches dart-sass's library API (`compileString().css`) and is
/// what the wasm `compileString().css` and the Ruby gem return. The single
/// newline the dart-sass CLI appends is re-added only by the CLI front-ends
/// (`src/main.rs`, `wasm/npm/cli.mjs`), guarded by the CLI tests.
#[test]
fn library_api_omits_trailing_newline() {
    for input in [
        ".a { color: red; }",
        ".a { color: red; }\n",
        "$c: blue;\n.a {\n  color: $c;\n  .b { width: 10px; }\n}\n",
        ".a { color: red; }\n.b { color: blue; }\n",
        // non-ASCII -> expanded prepends `@charset`, which must not reintroduce
        // a trailing newline at the end.
        ".a { content: \"café\"; }",
    ] {
        let expanded = compile(input, &Options::default()).expect("compile");
        assert!(
            !expanded.ends_with('\n'),
            "expanded library output must not end with a newline: {expanded:?}"
        );
        let compressed =
            compile(input, &Options::default().with_style(OutputStyle::Compressed)).expect("compile");
        assert!(
            !compressed.ends_with('\n'),
            "compressed library output must not end with a newline: {compressed:?}"
        );
    }
}

/// An in-memory importer for `@import` tests.
struct MemImporter(HashMap<String, String>);

impl Importer for MemImporter {
    fn canonicalize(
        &self,
        url: &str,
        _ctx: &CanonicalizeContext<'_>,
    ) -> Result<Option<CanonicalUrl>, ImporterError> {
        Ok(self.0.contains_key(url).then(|| CanonicalUrl::new(url)))
    }

    fn load(&self, canonical: &CanonicalUrl) -> Result<Option<ImporterResult>, ImporterError> {
        Ok(self.0.get(canonical.as_str()).map(|c| ImporterResult {
            contents: c.clone(),
            syntax: Syntax::Scss,
            source_map_url: None,
        }))
    }
}

#[test]
fn variables_nesting_and_colors() {
    let out = css("$c: #336699;\n.a {\n  color: $c;\n  .b { color: lighten($c, 10%); }\n  &:hover { color: mix($c, white, 50%); }\n}\n");
    assert_eq!(
        out,
        ".a {\n  color: #336699;\n}\n.a .b {\n  color: rgb(25%, 50%, 75%);\n}\n.a:hover {\n  color: rgb(60%, 70%, 80%);\n}\n"
    );
}

#[test]
fn color_function_set() {
    let out = css("$brand: #2a7ae2;\n.x {\n  color: rgba($brand, 0.5);\n  background: darken($brand, 15%);\n  border-color: hsl(120, 50%, 40%);\n  width: percentage(0.25);\n}\n");
    assert_eq!(
        out,
        ".x {\n  color: rgba(42, 122, 226, 0.5);\n  background: rgb(8.9993518068%, 33.8251498947%, 66.0986874088%);\n  border-color: hsl(120, 50%, 40%);\n  width: 25%;\n}\n"
    );
}

#[test]
fn rgb_and_hsl_literals_preserve_form() {
    assert_eq!(
        css(".x { color: rgb(51, 153, 51); }"),
        ".x {\n  color: rgb(51, 153, 51);\n}\n"
    );
    assert_eq!(
        css(".x { color: hsl(120, 50%, 40%); }"),
        ".x {\n  color: hsl(120, 50%, 40%);\n}\n"
    );
}

#[test]
fn unknown_identifiers_pass_through() {
    let out = css(".x { color: red; border-color: rebeccapurple; display: block; }");
    assert_eq!(
        out,
        ".x {\n  color: red;\n  border-color: rebeccapurple;\n  display: block;\n}\n"
    );
}

#[test]
fn nesting_combinators_and_parent_ref() {
    let out = css(".a, .b {\n  margin: 0;\n  > .c { padding: 1px; }\n  &.active { color: red; }\n  .d & { color: blue; }\n}\n");
    assert_eq!(
        out,
        ".a, .b {\n  margin: 0;\n}\n.a > .c, .b > .c {\n  padding: 1px;\n}\n.a.active, .b.active {\n  color: red;\n}\n.d .a, .d .b {\n  color: blue;\n}\n"
    );
}

#[test]
fn blank_line_between_top_level_groups() {
    // Separate top-level rules are blank-separated; a parent and its bubbled
    // children are not.
    assert_eq!(
        css(".a{color:red} .b{color:blue}"),
        ".a {\n  color: red;\n}\n\n.b {\n  color: blue;\n}\n"
    );
    assert_eq!(
        css(".a{color:red; .b{color:blue}}"),
        ".a {\n  color: red;\n}\n.a .b {\n  color: blue;\n}\n"
    );
}

#[test]
fn interpolation_in_selectors_and_values() {
    let out = css("$name: warning;\n$i: 3;\n.icon-#{$name} { content: \"#{$name}-#{$i}\"; }\n.col-#{$i} { width: 10px * $i; }\n");
    assert_eq!(
        out,
        ".icon-warning {\n  content: \"warning-3\";\n}\n\n.col-3 {\n  width: 30px;\n}\n"
    );
}

#[test]
fn unit_arithmetic() {
    assert_eq!(css(".a { width: 8px * 2; }"), ".a {\n  width: 16px;\n}\n");
    assert_eq!(css(".a { width: 10px + 5px; }"), ".a {\n  width: 15px;\n}\n");
    assert_eq!(css(".a { margin: 2 * 3em; }"), ".a {\n  margin: 6em;\n}\n");
}

/// A numeric literal's unit is interned per stylesheet and shared by every
/// value the literal evaluates to, so which spellings are the SAME unit is now
/// load-bearing. Two units are the same exactly when their decoded names match
/// character for character: an escape decodes first (`1\\65 m` is `em`), and
/// case is part of the name (`PX` is not `px`). Every expectation below was
/// measured against dart-sass 1.104.1.
#[test]
fn a_units_identity_is_its_decoded_spelling() {
    // An escaped unit is the unit it decodes to, and adds to it.
    assert_eq!(css("a { b: 1\\65 m + 1em; }"), "a {\n  b: 2em;\n}\n");
    assert_eq!(css("a { b: 1rem + 1\\72 em; }"), "a {\n  b: 2rem;\n}\n");
    // Case is part of the name: these are two different units, kept as
    // written, and adding them is an error.
    assert_eq!(css("a { b: 1PX; c: 1px; }"), "a {\n  b: 1PX;\n  c: 1px;\n}\n");
    let err = compile("a { b: 1PX + 1px; }", &Options::default()).unwrap_err();
    assert!(err.message.contains("incompatible units"), "{}", err.message);
    // The decoded name is what `math.unit()` reports, escape or not.
    assert_eq!(
        css("@use \"sass:math\"; a { b: math.unit(1\\72 em); c: math.unit(1\\50 X); }"),
        "a {\n  b: \"rem\";\n  c: \"PX\";\n}\n"
    );
    // `e`/`E` after the digits is an exponent, not a unit, in either case.
    assert_eq!(css("a { b: 1e3; c: 1E3; }"), "a {\n  b: 1000;\n  c: 1000;\n}\n");
    // The same literal evaluated many times keeps its unit; the sharing is
    // invisible.
    assert_eq!(
        css("@for $i from 1 through 3 { .c-#{$i} { w: 2px * $i; } }"),
        ".c-1 {\n  w: 2px;\n}\n\n.c-2 {\n  w: 4px;\n}\n\n.c-3 {\n  w: 6px;\n}\n"
    );
}

#[test]
fn lists_round_trip() {
    let out = css("$stack: \"Helvetica Neue\", Arial, sans-serif;\n.t { font-family: $stack; margin: 1px 2px 3px 4px; }\n");
    assert_eq!(
        out,
        ".t {\n  font-family: \"Helvetica Neue\", Arial, sans-serif;\n  margin: 1px 2px 3px 4px;\n}\n"
    );
}

#[test]
fn default_and_important_flags() {
    // !default does not override an existing binding.
    let out = css("$c: red;\n$c: blue !default;\n.a { color: $c; background: red !important; }");
    assert_eq!(out, ".a {\n  color: red;\n  background: red !important;\n}\n");
}

#[test]
fn comments_loud_preserved_silent_dropped() {
    // A loud comment starting on the line the previous declaration ends joins
    // that line (dart-sass's trailing-comment serializer rule).
    let out = css("// silent\n.a { color: red; /* inline */ }\n/* trailing */");
    assert_eq!(out, ".a {\n  color: red; /* inline */\n}\n\n/* trailing */\n");
}

#[test]
fn null_value_omits_declaration() {
    assert_eq!(css(".a { color: null; width: 1px; }"), ".a {\n  width: 1px;\n}\n");
}

#[test]
fn import_inlining() {
    let mut files = HashMap::new();
    files.insert(
        "parts/base".to_string(),
        "$pad: 8px;\nbody { margin: 0; padding: $pad * 2; }".to_string(),
    );
    let importer = MemImporter(files);
    let out = compile(
        "@import \"parts/base\";\n.wrap { padding: 4px; }",
        &Options::default().with_importer(&importer),
    )
    .expect("compile");
    assert_eq!(
        out,
        "body {\n  margin: 0;\n  padding: 16px;\n}\n\n.wrap {\n  padding: 4px;\n}"
    );
}

#[test]
fn css_import_passes_through() {
    // dart-sass packs a passed-through CSS `@import` tight against the
    // following rule, with no blank-line separator.
    let out = css("@import \"https://fonts.example/x.css\";\n.a { color: red; }");
    assert_eq!(
        out,
        "@import \"https://fonts.example/x.css\";\n.a {\n  color: red;\n}\n"
    );
}

#[test]
fn preserves_css_functions_verbatim() {
    let out = css(".a { width: calc(100% - 20px); transform: translateX(10px); }");
    assert_eq!(
        out,
        ".a {\n  width: calc(100% - 20px);\n  transform: translateX(10px);\n}\n"
    );
}

/// A directory-relative in-memory importer: resolves a relative URL against the
/// directory of `ctx.containing_url` (the root for the entry), with dart's
/// partial (`_name`) fallback. Unlike [`MemImporter`] (which keys by the
/// verbatim URL) this models the *directory-relative* resolution that
/// `containing_url` drives — the axis exercised by issue #8.
struct DirImporter(HashMap<String, String>);

impl DirImporter {
    fn dirname(p: &str) -> &str {
        match p.rfind('/') {
            Some(0) => "/",
            Some(i) => &p[..i],
            None => "",
        }
    }
    /// The partial spelling: `/sub/mod` -> `/sub/_mod`, `/dep` -> `/_dep`.
    fn as_partial(p: &str) -> String {
        match p.rfind('/') {
            Some(i) => format!("{}/_{}", &p[..i], &p[i + 1..]),
            None => format!("_{p}"),
        }
    }
}

impl Importer for DirImporter {
    fn canonicalize(
        &self,
        url: &str,
        ctx: &CanonicalizeContext<'_>,
    ) -> Result<Option<CanonicalUrl>, ImporterError> {
        let base = ctx
            .containing_url
            .map(|c| Self::dirname(c.as_str()))
            .unwrap_or("");
        let joined = format!("{}/{}", base.trim_end_matches('/'), url);
        for cand in [joined.clone(), Self::as_partial(&joined)] {
            if self.0.contains_key(&cand) {
                return Ok(Some(CanonicalUrl::new(&cand)));
            }
        }
        Ok(None)
    }

    fn load(&self, canonical: &CanonicalUrl) -> Result<Option<ImporterResult>, ImporterError> {
        Ok(self.0.get(canonical.as_str()).map(|c| ImporterResult {
            contents: c.clone(),
            syntax: Syntax::Scss,
            source_map_url: None,
        }))
    }
}

#[test]
fn first_class_mixin_load_css_resolves_against_defining_module() {
    // Regression test for issue #8: a relative `meta.load-css` inside a mixin
    // captured via `meta.get-mixin` and invoked with `meta.apply` from another
    // file must resolve the URL against the *defining* module's directory, not
    // the caller's. Two `_dep` partials exist — `/sub/_dep` (correct, next to
    // the mixin) and `/_dep` (wrong, next to the entry) — so a caller-relative
    // resolution picks the wrong file and is observable in the output.
    let mut files = HashMap::new();
    files.insert(
        "/sub/_mod".to_string(),
        "@use \"sass:meta\";\n@mixin go { @include meta.load-css(\"dep\"); }\n\
         $m: meta.get-mixin(\"go\");\n"
            .to_string(),
    );
    files.insert(
        "/sub/_dep".to_string(),
        ".loaded { x: from-sub-dep; }\n".to_string(),
    );
    files.insert(
        "/_dep".to_string(),
        ".loaded { x: from-ROOT-WRONG; }\n".to_string(),
    );
    let importer = DirImporter(files);
    let out = compile(
        "@use \"sub/mod\";\n@use \"sass:meta\";\n.out { @include meta.apply(mod.$m); }\n",
        &Options::default().with_url("/entry").with_importer(&importer),
    )
    .expect("compile");
    // Byte-for-byte dart-sass 1.101 (resolves "dep" against /sub). The library
    // API omits the trailing newline the CLI adds.
    assert_eq!(out, ".out .loaded {\n  x: from-sub-dep;\n}");
}

/// A [`DirImporter`] that counts calls per url, and can be told to fail every
/// `load` after the first.
struct CountingImporter {
    inner: DirImporter,
    canonicalized: std::cell::RefCell<HashMap<String, usize>>,
    loaded: std::cell::RefCell<HashMap<String, usize>>,
    /// When true, the SECOND and later `load` of any url returns an error --
    /// standing in for a file that becomes unreadable mid-compile.
    poison_reload: bool,
}

impl CountingImporter {
    fn new(files: HashMap<String, String>, poison_reload: bool) -> Self {
        CountingImporter {
            inner: DirImporter(files),
            canonicalized: std::cell::RefCell::new(HashMap::new()),
            loaded: std::cell::RefCell::new(HashMap::new()),
            poison_reload,
        }
    }
    fn count(map: &std::cell::RefCell<HashMap<String, usize>>, key: &str) -> usize {
        *map.borrow().get(key).unwrap_or(&0)
    }
}

impl Importer for CountingImporter {
    fn canonicalize(
        &self,
        url: &str,
        ctx: &CanonicalizeContext<'_>,
    ) -> Result<Option<CanonicalUrl>, ImporterError> {
        *self
            .canonicalized
            .borrow_mut()
            .entry(url.to_string())
            .or_insert(0) += 1;
        self.inner.canonicalize(url, ctx)
    }

    fn load(&self, canonical: &CanonicalUrl) -> Result<Option<ImporterResult>, ImporterError> {
        let key = canonical.as_str().to_string();
        let seen = {
            let mut counts = self.loaded.borrow_mut();
            let n = counts.entry(key.clone()).or_insert(0);
            *n += 1;
            *n
        };
        if self.poison_reload && seen > 1 {
            return Err(ImporterError {
                message: format!("load #{seen} of {key}"),
            });
        }
        self.inner.load(canonical)
    }
}

/// The `@use` graph for the two tests below: `shared` is reached three times --
/// directly by the entry and through each of `a` and `b`.
fn diamond_files() -> HashMap<String, String> {
    let mut files = HashMap::new();
    files.insert(
        "/_shared".to_string(),
        "$w: 4px;\n.shared { x: 1; }\n".to_string(),
    );
    files.insert(
        "/_a".to_string(),
        "@use \"shared\";\n.a { width: shared.$w; }\n".to_string(),
    );
    files.insert(
        "/_b".to_string(),
        "@use \"shared\";\n.b { width: shared.$w; }\n".to_string(),
    );
    files
}

const DIAMOND_ENTRY: &str = "@use \"shared\";\n@use \"a\";\n@use \"b\";\n.entry { width: shared.$w; }\n";

/// Byte-for-byte dart-sass 1.104.1 on the same graph written to disk, minus
/// the single trailing newline the CLI adds and the library API does not.
const DIAMOND_CSS: &str =
    ".shared {\n  x: 1;\n}\n\n.a {\n  width: 4px;\n}\n\n.b {\n  width: 4px;\n}\n\n.entry {\n  width: 4px;\n}";

/// An importer's `load` runs **once per canonical url**, not once per `@use`
/// edge, while `canonicalize` still runs on every edge.
///
/// That split is the contract of the module cache, and both halves matter.
/// Skipping the repeat `load` is the point: a module already in the cache
/// re-emits nothing and re-parses nothing, so reading its text again is a
/// syscall spent on a string that is dropped -- dart-sass's `ImportCache`
/// memoizes at the same granularity. Keeping `canonicalize` per edge is what
/// makes that safe: dependency provenance for `--quiet-deps` is recorded there
/// (`src/importer.rs`), so a cache hit must not skip it.
#[test]
fn a_repeat_use_edge_canonicalizes_again_but_does_not_reload() {
    let importer = CountingImporter::new(diamond_files(), false);
    let out = compile(
        DIAMOND_ENTRY,
        &Options::default().with_url("/entry").with_importer(&importer),
    )
    .expect("compile");
    assert_eq!(out, DIAMOND_CSS);
    assert_eq!(
        CountingImporter::count(&importer.canonicalized, "shared"),
        3,
        "canonicalize runs per edge: the entry, /_a and /_b each `@use \"shared\"`"
    );
    assert_eq!(
        CountingImporter::count(&importer.loaded, "/_shared"),
        1,
        "load runs once per canonical url"
    );
}

/// The observable consequence of the above: a module that becomes unreadable
/// after its first load still compiles, because nothing reads it again.
///
/// This is dart-sass's behaviour too (`ImportCache` caches the loaded
/// stylesheet, not just the canonical url), and it is pinned here because the
/// alternative -- re-reading per edge and failing -- is what this repo did
/// before, so a revert would be silent without a test.
#[test]
fn a_module_that_becomes_unreadable_after_its_first_load_still_compiles() {
    let importer = CountingImporter::new(diamond_files(), true);
    let out = compile(
        DIAMOND_ENTRY,
        &Options::default().with_url("/entry").with_importer(&importer),
    )
    .expect("a cached module is never re-read, so the poisoned reload is never reached");
    assert_eq!(out, DIAMOND_CSS);
}

#[test]
fn compressed_output() {
    let out = css_compressed(".a { color: #336699; width: 10px; .b { color: #2a7ae2; } }");
    assert_eq!(out, ".a{color:#369;width:10px}.a .b{color:#2a7ae2}");
}

/// Compressed legacy colors are emitted in the SHORTEST equivalent form
/// (hex / name / rgb() / hsl()), matching dart-sass 1.101.0. Every expected
/// string below was produced by dart-sass 1.101.0 (`--style=compressed`).
/// This is the offline regression gate for the color-serialization fix; the
/// live cross-check lives in tests/parity.rs (compressed parity battery).
#[test]
fn compressed_color_picks_shortest_form() {
    let case = |scss: &str| css_compressed(&format!("a{{x:{scss}}}"));

    // --- fractional triples: percentages, with hsl only when it wins by more
    // --- than the two-character handicap dart gives it -----------------------
    assert_eq!(case("darken(#336699,10%)"), "a{x:rgb(15%,30%,45%)}");
    assert_eq!(case("lighten(#336699,10%)"), "a{x:rgb(25%,50%,75%)}");
    assert_eq!(case("saturate(#336699,10%)"), "a{x:rgb(16%,40%,64%)}");
    assert_eq!(case("grayscale(#ff6600)"), "a{x:hsl(0,0%,50%)}");
    assert_eq!(
        css_compressed("@use 'sass:color';a{x:color.mix(#ff6600,#fff,30%)}"),
        "a{x:rgb(100%,82%,70%)}"
    );
    assert_eq!(
        css_compressed("@use 'sass:color';a{x:color.adjust(#336699,$lightness:-10%)}"),
        "a{x:rgb(15%,30%,45%)}"
    );
    // Non-opaque: rgba() vs hsla(); the percentage rgba form wins.
    assert_eq!(case("rgba(darken(#336699,10%),.5)"), "a{x:rgba(15%,30%,45%,.5)}");

    // --- results whose rgb form is shorter (or equal) -> stays rgb/hex ------
    // The percentage form wins under dart's two-character hsl handicap.
    assert_eq!(case("saturate(#888,20%)"), "a{x:rgb(62.6666666667%,44%,44%)}");
    // A hue rotation that lands on integers collapses to hex.
    assert_eq!(case("adjust-hue(#336699,90deg)"), "a{x:#939}");

    // --- hsl-space literals also pick the shortest form --------------------
    // Integer-rgb-equivalent hsl collapses to hex.
    assert_eq!(case("hsl(210,50%,40%)"), "a{x:#369}");
    // A fractional-rgb hsl literal serializes through rgb like every legacy
    // color (dart `_writeLegacyColor`): the percent rgb form wins under the
    // two-character hsl handicap.
    assert_eq!(case("hsl(210,50%,30%)"), "a{x:rgb(15%,30%,45%)}");
    assert_eq!(case("hsl(30,100%,50%)"), "a{x:rgb(100%,50%,0%)}");
    // A powerless (zero-saturation) hue collapses to the rgb round-trip's 0:
    // compressed serialization derives the hsl candidate from the rgb triple,
    // so the authored hue does not participate.
    assert_eq!(case("hsl(30,0%,50%)"), "a{x:hsl(0,0%,50%)}");

    // --- regression guards: unchanged cases -------------------------------
    assert_eq!(case("#336699"), "a{x:#369}");
    assert_eq!(case("red"), "a{x:red}");
    assert_eq!(case("rgba(0,0,0,.5)"), "a{x:rgba(0,0,0,.5)}");
    assert_eq!(case("hsl(0,0%,50%)"), "a{x:hsl(0,0%,50%)}");
}

/// Compressed style drops a leading zero from a POSITIVE number whose spelling
/// is short enough for dart's direct number writer — it looks for a literal
/// `0.` prefix on the rendered string, which a minus sign has already pushed
/// out of the way. A spelling long enough to go through `_writeRounded` follows
/// a different rule; `fmt_num_compressed_leading_zero_follows_the_writer` in
/// `src/value.rs` covers all three regimes. Measured against dart-sass 1.103.1,
/// re-measured against 1.104.1 on 2026-09-19.
#[test]
fn compressed_keeps_the_zero_on_a_negative_decimal() {
    let v = |scss: &str| css_compressed(&format!("a{{x:{scss}}}"));
    assert_eq!(v("0.5px"), "a{x:.5px}");
    assert_eq!(v("-0.5px"), "a{x:-0.5px}");
    assert_eq!(v("-0.25%"), "a{x:-0.25%}");
    assert_eq!(v("-0.5"), "a{x:-0.5}");
    // Computed, not just written that way.
    assert_eq!(v("-1px * 0.1"), "a{x:-0.1px}");
    assert_eq!(v("1px -0.5px"), "a{x:1px -0.5px}");
    // Zero itself has no fraction to shorten — but it does keep its SIGN
    // (dart-sass 1.104.0), which the leading-zero rule must not eat.
    assert_eq!(v("0px"), "a{x:0px}");
    assert_eq!(v("-0.0px"), "a{x:-0px}");
    assert_eq!(v("-0"), "a{x:-0}");
    // A spelling that `_writeRounded` has to shorten loses the zero either way.
    assert_eq!(v("-0.00123456789px"), "a{x:-.0012345679px}");
    // One that it merely passes through keeps the zero either way.
    assert_eq!(v("0.0123456789px"), "a{x:0.0123456789px}");
}

/// A percent channel is `max * value / 100` in dart (`_percentageOrUnitless`),
/// and the ORDER of that multiplication is observable: `0.4 * -40 / 100` is
/// exactly -0.16 where `-40 / 100 * 0.4` is -0.16000000000000003. The dust
/// reaches the output, where the rounding writer shortens the spelling — and a
/// shortened spelling loses the leading zero the exact one keeps (`-.16` for
/// `-0.16`). Measured against dart-sass 1.104.1 on 2026-09-21.
#[test]
fn a_percent_channel_multiplies_in_darts_order() {
    let both = |value: &str, expanded: &str, compressed: &str| {
        let src = format!("@use \"sass:color\";\na {{b: {value}}}\n");
        assert_eq!(css(&src), format!("a {{\n  b: {expanded};\n}}\n"), "{value}");
        assert_eq!(css_compressed(&src), format!("a{{b:{compressed}}}"), "{value}");
    };
    // The channels whose max is 0.4 — oklab's `a`/`b` and oklch's chroma — are
    // where the dust is large enough to survive the writer. The constructor and
    // `color.change` reach the same multiplication.
    both(
        "oklab(50% -40% -75%)",
        "oklab(50% -0.16 -0.3)",
        "oklab(.5 -0.16 -0.3)",
    );
    both(
        "color.change(oklab(50% 0.2 -0.3), $a: -40%)",
        "oklab(50% -0.16 -0.3)",
        "oklab(.5 -0.16 -0.3)",
    );
    both("oklch(50% 40% 90)", "oklch(50% 0.16 90deg)", "oklch(.5 .16 90)");
    both("color.channel(oklab(50% -40% -75%), \"a\")", "-0.16", "-0.16");
    both("color.channel(oklch(50% 40% 90deg), \"chroma\")", "0.16", ".16");
    // Converting out of the space carries the exact value with it.
    both(
        "color.to-space(oklab(50% -40% -75%), oklch)",
        "oklch(50% 0.34 241.9275130641deg)",
        "oklch(.5 .34 241.9275130641)",
    );
    // The lab/lch maxes (125 and 150) and the legacy 0-255 channels take the
    // same order; their dust never reaches the tenth decimal, so these pin the
    // arithmetic rather than a byte that used to differ.
    both("lab(50% -40% 30%)", "lab(50% -50 37.5)", "lab(50 -50 37.5)");
    both("lch(50% 40% 90deg)", "lch(50% 60 90deg)", "lch(50 60 90)");
    both(
        "color.change(lab(50% 20 30), $a: 40.7%)",
        "lab(50% 50.875 30)",
        "lab(50 50.875 30)",
    );
    both("color.channel(rgb(19.9% 30% 40%), \"red\")", "50.745", "50.745");
    both(
        "color.channel(color.change(red, $green: 19.9%), \"green\")",
        "50.745",
        "50.745",
    );
}

/// The lightness of a `lab()`/`lch()`/`oklab()`/`oklch()` color is written as a
/// percentage in expanded output and as the channel's own stored number when
/// compressed — the same digits for lab/lch, whose lightness runs 0–100, and
/// the unscaled 0–1 value for oklab/oklch. A hue drops its `deg` for the same
/// reason: an unadorned number already means degrees everywhere a hue is
/// accepted. Measured against dart-sass 1.104.1 on 2026-09-19.
#[test]
fn compressed_color_channels_drop_percent_and_deg() {
    let v = |scss: &str| css_compressed(&format!("a{{x:{scss}}}"));
    assert_eq!(v("lab(50% 10 -20)"), "a{x:lab(50 10 -20)}");
    assert_eq!(v("lab(0% 0 0)"), "a{x:lab(0 0 0)}");
    assert_eq!(v("lab(0.5% 0 0)"), "a{x:lab(.5 0 0)}");
    assert_eq!(v("lch(50% 30 120deg)"), "a{x:lch(50 30 120)}");
    assert_eq!(v("lch(50% 30 400)"), "a{x:lch(50 30 40)}");
    // oklab/oklch lightness is stored 0–1, so dropping the `%` also divides by
    // a hundred — which can make the compressed form LONGER, and dart-sass
    // writes it anyway rather than picking the shorter spelling.
    assert_eq!(v("oklab(50% 0.1 -0.1)"), "a{x:oklab(.5 .1 -0.1)}");
    assert_eq!(v("oklab(1% 0 0)"), "a{x:oklab(.01 0 0)}");
    assert_eq!(v("oklch(70% 0.1 200)"), "a{x:oklch(.7 .1 200)}");
    assert_eq!(v("oklch(100% 0 0)"), "a{x:oklch(1 0 0)}");
    // With an alpha, and with a missing channel (`none` is not a number and
    // has no unit to drop).
    assert_eq!(v("lab(50% 10 -20 / 0.5)"), "a{x:lab(50 10 -20/.5)}");
    assert_eq!(v("lch(50% 30 none)"), "a{x:lch(50 30 none)}");
    assert_eq!(v("oklch(none 0.1 200)"), "a{x:oklch(none .1 200)}");
    // A legacy space reaches the modern form only through a missing channel;
    // there its hue drops `deg` too, while saturation/whiteness keep their `%`.
    assert_eq!(v("hsl(120deg none 50%)"), "a{x:hsl(120 none 50%)}");
    assert_eq!(v("hwb(120deg 20% none)"), "a{x:hwb(120 20% none)}");
    // Expanded output keeps every unit.
    let e = |scss: &str| css(&format!("a{{x:{scss}}}"));
    assert_eq!(e("lab(50% 10 -20)"), "a {\n  x: lab(50% 10 -20);\n}\n");
    assert_eq!(e("oklch(70% 0.1 200)"), "a {\n  x: oklch(70% 0.1 200deg);\n}\n");
}

/// A degenerate color CHANNEL — an infinity that survives parsing — builds a
/// real color, not a verbatim string: dart-sass stores the infinity in the
/// channel and serializes it from there. So `meta.type-of` answers `color`,
/// `color.channel` hands the infinity back, and compressed output drops the
/// spaces around the `*` and the `/` the way it does for every other value.
/// Measured against dart-sass 1.104.1.
#[test]
fn degenerate_color_channels_build_a_real_color() {
    let v = |scss: &str| css_compressed(&format!("a{{x:{scss}}}"));
    let e = |scss: &str| css(&format!("a{{x:{scss}}}"));
    // hsl(): the infinity lives in the saturation or lightness channel, and
    // the legacy comma form carries the channel's `%` into the calc() constant.
    assert_eq!(
        e("hsl(0, 100%, calc(-infinity * 1%))"),
        "a {\n  x: hsl(0, 100%, calc(-infinity * 1%));\n}\n"
    );
    assert_eq!(
        v("hsl(0, 100%, calc(-infinity * 1%))"),
        "a{x:hsl(0,100%,calc(-infinity*1%))}"
    );
    assert_eq!(
        v("hsl(0, calc(infinity * 1%), 50%)"),
        "a{x:hsl(0,calc(infinity*1%),50%)}"
    );
    // A NEGATIVE infinite saturation floors at 0, which leaves an ordinary
    // color behind — so compressed output picks the shortest legacy spelling
    // for it, as for any other color.
    assert_eq!(v("hsl(0, calc(-infinity * 1%), 50%)"), "a{x:hsl(0,0%,50%)}");
    // An alpha keeps the `hsla()` spelling; an OPAQUE one is still dropped.
    assert_eq!(
        v("hsla(0, 100%, calc(infinity * 1%), 0.5)"),
        "a{x:hsla(0,100%,calc(infinity*1%),.5)}"
    );
    assert_eq!(
        v("hsl(0, 100%, calc(infinity * 1%), 1)"),
        "a{x:hsl(0,100%,calc(infinity*1%))}"
    );
    // The hue still reduces modulo 360, and the modern space-separated call
    // builds the same color as the comma one.
    assert_eq!(
        v("hsl(400, 100%, calc(infinity * 1%))"),
        "a{x:hsl(40,100%,calc(infinity*1%))}"
    );
    assert_eq!(
        v("hsl(0 100% calc(-infinity * 1%) / 0.25)"),
        "a{x:hsla(0,100%,calc(-infinity*1%),.25)}"
    );
    // color(): the channel keeps its `calc(infinity)`, only the `/` compresses.
    assert_eq!(
        v("color(srgb 0 0 calc(infinity) / 0.5)"),
        "a{x:color(srgb 0 0 calc(infinity)/.5)}"
    );
    // A `%` channel is a percentage OF the channel's 0–1 range, and a
    // percentage of an infinity is still infinite — the unit does not survive.
    assert_eq!(
        e("color(srgb calc(infinity * 1%) 0 0)"),
        "a {\n  x: color(srgb calc(infinity) 0 0);\n}\n"
    );
    // A degenerate ALPHA folds to a number: `NaN` and `-infinity` to 0.
    assert_eq!(v("color(srgb 0 0 0 / calc(NaN))"), "a{x:color(srgb 0 0 0/0)}");
    // Being colors, they answer the color module rather than the string one.
    assert_eq!(
        css("@use \"sass:meta\";\na {x: meta.type-of(hsl(0, 100%, calc(-infinity * 1%)))}"),
        "a {\n  x: color;\n}\n"
    );
    assert_eq!(
        css("@use \"sass:color\";\na {x: color.channel(hsl(0, 100%, calc(-infinity * 1%)), \"lightness\")}"),
        "a {\n  x: calc(-infinity * 1%);\n}\n"
    );
    assert_eq!(
        css("@use \"sass:color\";\na {x: color.space(hsl(0, 100%, calc(-infinity * 1%)))}"),
        "a {\n  x: hsl;\n}\n"
    );
    // Mixing one keeps the infinity in the rgb channel the conversion left it
    // in and NaN in the two its arithmetic wiped out; an out-of-gamut rgb
    // result is written through its hsl form, where a non-finite channel reads
    // as 0.
    assert_eq!(
        css("@use \"sass:color\";\na {x: color.mix(hsl(0, 100%, calc(-infinity * 1%)), red)}"),
        "a {\n  x: hsl(0, 0%, 0%);\n}\n"
    );
}

/// `meta.inspect` of an OUT-OF-GAMUT legacy rgb color skips the hsl reroute
/// CSS output takes, and writes the channels by the rules CSS output uses for
/// a legacy triple: plain numbers while all three are integers — in gamut or
/// not — percentages as soon as one is not, and a non-finite channel, which
/// converting an infinite one produces, as a `%`-unit `calc()` constant.
/// Measured against dart-sass 1.104.1.
#[test]
fn inspecting_an_out_of_gamut_legacy_rgb_color() {
    let i = |scss: &str| {
        css(&format!(
            "@use \"sass:color\";\n@use \"sass:meta\";\na {{x: meta.inspect({scss})}}"
        ))
    };
    let rgb = |scss: &str| format!("color.to-space({scss}, rgb)");
    assert_eq!(i(&rgb("color(srgb 2 0 0)")), "a {\n  x: rgb(510, 0, 0);\n}\n");
    assert_eq!(
        i(&rgb("color(srgb 2 0 0.5)")),
        "a {\n  x: rgb(200%, 0%, 50%);\n}\n"
    );
    assert_eq!(
        i(&rgb("color(srgb -0.5 0 0)")),
        "a {\n  x: rgb(-50%, 0%, 0%);\n}\n"
    );
    // The alpha of an `rgba()` form is a plain number either way.
    assert_eq!(
        i(&format!("rgba({}, 0.5)", rgb("color(srgb 2 0 0.5)"))),
        "a {\n  x: rgba(200%, 0%, 50%, 0.5);\n}\n"
    );
    // A non-finite channel alongside two finite ones: the `calc()` constant
    // carries the `%` the percentage spelling gives the others.
    assert_eq!(
        i(&rgb("color(srgb calc(infinity) 0.5 0)")),
        "a {\n  x: rgb(calc(infinity * 1%), 50%, 0%);\n}\n"
    );
    assert_eq!(
        i("color.mix(hsl(0, 100%, calc(-infinity * 1%)), red)"),
        "a {\n  x: rgb(calc(-infinity * 1%), calc(NaN * 1%), calc(NaN * 1%));\n}\n"
    );
    // CSS output of the same color takes the hsl reroute, where a fuzzy-zero
    // saturation nulls the hue instead of leaking the one an out-of-gamut gray
    // converts to (`hsl(345, 0%, 100%)`).
    assert_eq!(
        css("@use \"sass:color\";\na {x: color.to-space(color(srgb 2 0 0.5), rgb)}"),
        "a {\n  x: hsl(0, 0%, 100%);\n}\n"
    );
}

/// dart tests a legacy rgb triple's integrality EXACTLY for CSS output and
/// FUZZILY for `meta.inspect` (`_asInt`, serialize.dart), so one color has two
/// spellings: `color.to-space(hsl(180, 60%, 50%, 0.4), rgb)` has channels
/// 50.999999999999986, 203.99999999999997 and 204 — percentages as CSS,
/// integers under inspect. Measured against dart-sass 1.104.1.
#[test]
fn a_legacy_rgb_triple_is_integral_exactly_for_css_and_fuzzily_for_inspect() {
    let c = "color.to-space(hsl(180, 60%, 50%, 0.4), rgb)";
    assert_eq!(
        css(&format!("@use \"sass:color\";\na {{x: {c}}}")),
        "a {\n  x: rgba(20%, 80%, 80%, 0.4);\n}\n"
    );
    assert_eq!(
        css(&format!(
            "@use \"sass:color\";\n@use \"sass:meta\";\na {{x: meta.inspect({c})}}"
        )),
        "a {\n  x: rgba(51, 204, 204, 0.4);\n}\n"
    );
    // Compressed output applies the exact rule too: the dust keeps this color
    // off hex, so the percentage form wins on length.
    assert_eq!(
        css_compressed(&format!("@use \"sass:color\";\na{{x:{c}}}")),
        "a{x:rgba(20%,80%,80%,.4)}"
    );
    // The same color authored as hsl(): compressed serializes it through the
    // very same conversion, so it reaches the very same spelling.
    assert_eq!(
        css_compressed("a{x:hsl(180, 60%, 50%, 0.4)}"),
        "a{x:rgba(20%,80%,80%,.4)}"
    );
    // A channel that is EXACTLY integral needs no fuzz to stay a plain number.
    assert_eq!(
        css("a {x: rgba(10, 20, 30, 0.4)}"),
        "a {\n  x: rgba(10, 20, 30, 0.4);\n}\n"
    );
    assert_eq!(css_compressed("a{x:hsl(120, 50%, 0%)}"), "a{x:#000}");
}

/// The reroute to `hsl()` that an out-of-gamut legacy color takes measures the
/// color in ITS OWN space (dart `SassColor.isInGamut`: hsl and hwb bound
/// channels 1 and 2 to [0, 100], rgb bounds all three to [0, 255]), not in the
/// sRGB shadow the compressed writer would otherwise serialize. An oklch color
/// converted to hsl carries a 655% saturation over a shadow that is ordinary
/// black, so measuring the shadow would print `#000`. Measured against
/// dart-sass 1.104.1 (`--style=compressed`).
#[test]
fn an_out_of_gamut_legacy_color_is_measured_in_its_own_space() {
    let v = |scss: &str| css_compressed(&format!("@use \"sass:color\";\na{{x:{scss}}}"));
    assert_eq!(
        v("hsl(17.5913578322, 6051.6428880588%, 0%)"),
        "a{x:hsl(17.5913578322,6051.6428880588%,0%)}"
    );
    assert_eq!(
        v("color.to-space(oklch(0.5 0.2 200), hsl)"),
        "a{x:hsl(183.9676958721,655.5972854828%,7.4482455068%)}"
    );
    // hwb is bounded the same way, and writes through hsl once it is out.
    assert_eq!(
        v("color.to-space(oklch(0.5 0.2 200), hwb)"),
        "a{x:hsl(183.9676958721,655.5972854828%,7.4482455068%)}"
    );
    assert_eq!(v("hwb(120 -20% 30%)"), "a{x:hsl(120,180%,25%)}");
    assert_eq!(v("color.adjust(red, $lightness: 200%)"), "a{x:hsl(0,100%,250%)}");
    // An IN-gamut hwb still serializes through rgb, alpha and all.
    assert_eq!(v("hwb(200 20% 30%)"), "a{x:rgb(20%,53.3333333333%,70%)}");
    assert_eq!(
        v("color.change(hwb(200 20% 30%), $alpha: 0.5)"),
        "a{x:rgba(20%,53.3333333333%,70%,.5)}"
    );
    // An rgb color is bounded by [0, 255], and a fuzzy-zero saturation nulls
    // the hue the conversion hands back.
    assert_eq!(
        v("color.to-space(color(srgb 2 0 0.5), rgb)"),
        "a{x:hsl(0,0%,100%)}"
    );
}

/// dart's serializer opens with `fuzzyEquals(color.alpha, 1)`, so the opacity
/// test is the same fuzzy comparison as every other legacy-form decision: an
/// alpha 1e-13 short of 1 is opaque, and one 6e-12 short is not. Measured
/// against dart-sass 1.104.1.
#[test]
fn the_opacity_test_is_dart_s_fuzzy_comparison() {
    let v = |scss: &str| css(&format!("@use \"sass:color\";\na {{x: {scss}}}"));
    assert_eq!(
        v("color.change(red, $alpha: 0.9999999999999)"),
        "a {\n  x: red;\n}\n"
    );
    assert_eq!(
        v("color.change(hsl(120, 50%, 50%), $alpha: 0.9999999999999)"),
        "a {\n  x: hsl(120, 50%, 50%);\n}\n"
    );
    // 6e-12 short: the 1e11 rounding disagrees, so the color is translucent --
    // and its alpha still PRINTS as 1, which is dart's output too.
    assert_eq!(
        v("color.change(red, $alpha: 0.999999999994)"),
        "a {\n  x: rgba(255, 0, 0, 1);\n}\n"
    );
}

/// A hue is powerless -- a missing channel -- when the saturation or chroma a
/// conversion produced is `fuzzyEquals` to zero, which is not the same as being
/// within the epsilon of it. Measured against dart-sass 1.104.1.
#[test]
fn a_powerless_hue_is_decided_by_dart_s_fuzz_not_by_an_epsilon() {
    let v = |scss: &str| css(&format!("@use \"sass:color\";\na {{x: {scss}}}"));
    let missing = |c: &str| v(&format!("color.is-missing(color.to-space({c}), \"hue\")"));
    for c in [
        "lab(50% 0.000000000006 0), lch",
        "lab(50% 0.00000000006 0), lch",
        "oklab(0.5 0.000000000006 0), oklch",
    ] {
        assert_eq!(missing(c), "a {\n  x: false;\n}\n", "{c}");
    }
    assert_eq!(missing("lab(50% 0.0000000000004 0), lch"), "a {\n  x: true;\n}\n");
    // The hue the compressed writer derives for its hsl bid follows the same
    // rule, and keeping it is what makes the rgb form the shorter one.
    assert_eq!(
        css_compressed(
            "@use \"sass:color\";\na {x: color.change(hsl(90, 50%, 50%), $saturation: -0.000000000006%)}"
        ),
        "a{x:rgb(50%,50%,50%)}"
    );
}

/// dart's `_normalizeHue` pattern-matches a `0` hue (and any non-finite one)
/// BEFORE applying the 180 degrees a negative saturation or chroma asks for, so
/// the invert leaves a zero hue alone -- reducing `0 + 360 + 180` instead would
/// turn red into cyan. Whether the magnitude counts as negative is dart's
/// `fuzzyLessThan(channel1, 0)`, which needs both clauses of `fuzzyEquals`: a
/// saturation of -6e-12 is not zero to dart, so it DOES invert. Measured
/// against dart-sass 1.104.1.
#[test]
fn a_zero_hue_survives_the_invert_a_negative_saturation_asks_for() {
    let v = |scss: &str| css(&format!("@use \"sass:color\";\na {{x: {scss}}}"));
    assert_eq!(
        v("color.change(hsl(120, 50%, 50%), $hue: 0, $saturation: -50%)"),
        "a {\n  x: hsl(0, 50%, 50%);\n}\n"
    );
    assert_eq!(
        v("color.adjust(hsl(0, 50%, 50%), $saturation: -100%)"),
        "a {\n  x: hsl(0, 0%, 50%);\n}\n"
    );
    assert_eq!(
        v("color.change(lch(50% 20 0), $chroma: -20)"),
        "a {\n  x: lch(50% 20 0deg);\n}\n"
    );
    // A hue that is NOT zero takes the offset, as it always did.
    assert_eq!(
        v("color.change(hsl(120, 50%, 50%), $saturation: -50%)"),
        "a {\n  x: hsl(300, 50%, 50%);\n}\n"
    );
    // Inside the epsilon but not inside the 1e11 rounding: still negative.
    assert_eq!(
        v("color.change(hsl(90, 50%, 50%), $saturation: -0.000000000006%)"),
        "a {\n  x: hsl(270, 0%, 50%);\n}\n"
    );
    // Below the rounding, and for a negative zero: not negative at all.
    assert_eq!(
        v("color.change(hsl(90, 50%, 50%), $saturation: -0.0000000000004%)"),
        "a {\n  x: hsl(90, 0%, 50%);\n}\n"
    );
    assert_eq!(
        v("color.change(hsl(90, 50%, 50%), $saturation: -0%)"),
        "a {\n  x: hsl(90, 0%, 50%);\n}\n"
    );
}

/// Every legacy-form decision is made with dart's `fuzzyEquals`, so a channel
/// 6e-12 past 255 is OUT of gamut (and writes hsl), and one 1e-10 short of 255
/// is neither integral nor named (and writes percentages). A looser tolerance
/// anywhere upstream decides the form before the serializer's exact rules run.
/// Measured against dart-sass 1.104.1.
#[test]
fn a_channel_inside_the_fuzz_but_past_the_bound_is_out_of_gamut() {
    let v = |scss: &str| css(&format!("@use \"sass:color\";\na {{x: {scss}}}"));
    assert_eq!(
        v("color.change(red, $red: 255.000000000006)"),
        "a {\n  x: hsl(0, 100%, 50%);\n}\n"
    );
    assert_eq!(
        v("color.change(blue, $red: 255.000000000006, $blue: 0)"),
        "a {\n  x: hsl(0, 100%, 50%);\n}\n"
    );
    assert_eq!(
        v("color.change(red, $red: 254.9999999999)"),
        "a {\n  x: rgb(100%, 0%, 0%);\n}\n"
    );
    assert_eq!(
        v("color.change(red, $green: -0.0000000001)"),
        "a {\n  x: hsl(360, 100.0000000001%, 50%);\n}\n"
    );
    // A triple that IS exactly the named color still gets the name.
    assert_eq!(
        v("color.change(blue, $red: 255, $blue: 0)"),
        "a {\n  x: red;\n}\n"
    );
    assert_eq!(v("color.adjust(#ff0001, $blue: -1)"), "a {\n  x: red;\n}\n");
}

/// A modified color is built in the WORKING space before it converts back, and
/// dart's construction reduces a polar hue into `[0, 360)` on the way (dart
/// `SassColor.forSpaceInternal` -> `_normalizeHue`). Only the conversion can
/// observe it -- `(390 % 360) / 360` is exactly `1/12` where `(390 / 360) % 1`
/// is an ulp short -- and one ulp in a channel is the whole difference between
/// an integer triple and a percentage one. Measured against dart-sass 1.104.1.
#[test]
fn a_modified_hue_is_reduced_before_the_conversion_back() {
    let v = |scss: &str| css(&format!("@use \"sass:color\";\na {{x: {scss}}}"));
    for c in [
        "color.complement(rgba(10, 20, 30, 0.4))",
        "color.adjust(rgba(10, 20, 30, 0.4), $hue: 180)",
        "color.adjust(rgba(10, 20, 30, 0.4), $hue: -180)",
        "color.adjust(rgba(10, 20, 30, 0.4), $hue: 540)",
    ] {
        assert_eq!(v(c), "a {\n  x: rgba(30, 20, 10, 0.4);\n}\n", "{c}");
    }
    // The hue a polar RESULT keeps is reduced too, as it always was.
    assert_eq!(
        v("color.adjust(hsl(210, 50%, 40%), $hue: 180)"),
        "a {\n  x: hsl(30, 50%, 40%);\n}\n"
    );
    assert_eq!(
        v("color.adjust(oklch(0.5 0.2 200), $hue: 400)"),
        "a {\n  x: oklch(50% 0.2 240deg);\n}\n"
    );
}

/// `color()`'s space name and its three channels are separated by MANDATORY
/// whitespace — `color(display-p3 .5 .2 .9)` is an identifier followed by three
/// numbers, so compressing those spaces away yields `color(display-p3.5.2.9)`,
/// which no browser parses as a color. Only the `/` before the alpha may lose
/// its spaces. Measured against dart-sass 1.104.1 (`--style=compressed`).
#[test]
fn compressed_color_function_keeps_its_mandatory_spaces() {
    let v = |scss: &str| css_compressed(&format!("a{{x:{scss}}}"));
    assert_eq!(
        v("color(display-p3 0.5 0.2 0.9)"),
        "a{x:color(display-p3 .5 .2 .9)}"
    );
    assert_eq!(
        v("color(display-p3 0.5 0.2 0.9 / 0.5)"),
        "a{x:color(display-p3 .5 .2 .9/.5)}"
    );
    assert_eq!(v("color(xyz 0.1 0.2 0.3)"), "a{x:color(xyz .1 .2 .3)}");
    assert_eq!(
        v("color(srgb-linear 0.1 0.2 0.3 / 0.25)"),
        "a{x:color(srgb-linear .1 .2 .3/.25)}"
    );
    assert_eq!(v("color(a98-rgb 1 0.5 0)"), "a{x:color(a98-rgb 1 .5 0)}");
    assert_eq!(v("color(prophoto-rgb 0 0 0)"), "a{x:color(prophoto-rgb 0 0 0)}");
    // A missing channel is the literal `none`, which needs its spaces just as
    // much as a number does.
    assert_eq!(
        v("color(display-p3 none 0.2 0.9)"),
        "a{x:color(display-p3 none .2 .9)}"
    );
    assert_eq!(
        v("color(rec2020 0.5 none none / none)"),
        "a{x:color(rec2020 .5 none none/none)}"
    );
    // The legacy spaces reach the modern space-separated form only through a
    // missing channel, and they already spelled their separators correctly.
    assert_eq!(v("rgb(1 2 none)"), "a{x:rgb(1 2 none)}");
    assert_eq!(v("rgb(1 2 none / 0.5)"), "a{x:rgb(1 2 none/.5)}");
}

/// A negative numeric right operand flips a calc's `+`/`-`, in EVERY output
/// style: dart-sass performs the flip when it builds the operation
/// (`SassCalculation._operateInternal` negates the operand and swaps the
/// operator when `right.value < 0`), so serialization never sees the `+ -n`
/// form. `< 0` is the whole test — it excludes `-0` and NaN, and includes
/// `-infinity`. Measured against dart-sass 1.104.1.
#[test]
fn calc_flips_a_negative_right_operand_in_every_style() {
    let v = |scss: &str| css_compressed(&format!("a{{x:{scss}}}"));
    let e = |scss: &str| css(&format!("a {{ x: {scss}; }}"));
    // `@use` has to lead the stylesheet, so the math cases get their own pair.
    let vm = |scss: &str| css_compressed(&format!("@use 'sass:math';a{{x:{scss}}}"));
    let em = |scss: &str| css(&format!("@use 'sass:math';\na {{ x: {scss}; }}\n"));

    // Compressed used to skip the flip entirely.
    assert_eq!(v("calc(var(--a) + -2px)"), "a{x:calc(var(--a) - 2px)}");
    assert_eq!(v("calc(var(--a) - -2px)"), "a{x:calc(var(--a) + 2px)}");
    assert_eq!(v("calc(100% + -2px)"), "a{x:calc(100% - 2px)}");
    assert_eq!(v("calc(var(--a) + -0.5px)"), "a{x:calc(var(--a) - .5px)}");
    assert_eq!(v("calc(var(--a) + -2)"), "a{x:calc(var(--a) - 2)}");
    assert_eq!(e("calc(var(--a) + -2px)"), "a {\n  x: calc(var(--a) - 2px);\n}\n");

    // `-0` keeps its sign and its operator: dart tests `< 0`, which `-0` fails.
    assert_eq!(v("calc(var(--a) + -0px)"), "a{x:calc(var(--a) + -0px)}");
    assert_eq!(
        e("calc(var(--a) + -0px)"),
        "a {\n  x: calc(var(--a) + -0px);\n}\n"
    );

    // `-infinity` DOES flip, and inside a calculation it renders as a `*` chain
    // rather than a `calc()` constant — with no parentheses, because a
    // `*`-precedence child of `+`/`-` never needs them.
    assert_eq!(
        em("calc(1px + math.div(-1, 0) * 1em)"),
        "a {\n  x: calc(1px - infinity * 1em);\n}\n"
    );
    assert_eq!(
        em("calc(1px - math.div(-1, 0) * 1em)"),
        "a {\n  x: calc(1px + infinity * 1em);\n}\n"
    );
    assert_eq!(
        vm("calc(1px + math.div(-1, 0) * 1em)"),
        "a{x:calc(1px - infinity*1em)}"
    );
    assert_eq!(
        em("calc(var(--a) + math.div(-1, 0))"),
        "a {\n  x: calc(var(--a) - infinity);\n}\n"
    );
    // NaN never compares `< 0`, so it never flips.
    assert_eq!(
        em("calc(1px + math.div(0, 0) * 1em)"),
        "a {\n  x: calc(1px + NaN * 1em);\n}\n"
    );
    assert_eq!(vm("calc(1px + math.div(0, 0) * 1em)"), "a{x:calc(1px + NaN*1em)}");
}

/// Compressed style drops comments — except the LOUD ones, which open `/*!`
/// and are how a stylesheet keeps its licence header. Measured against
/// dart-sass 1.103.1.
#[test]
fn compressed_keeps_loud_comments() {
    // Written verbatim, newlines and all, with no separator of its own.
    assert_eq!(css_compressed("/*! head */\n.a { b: 1; }"), "/*! head */.a{b:1}");
    assert_eq!(
        css_compressed("/*!\n * line\n */\n.a { b: 1; }"),
        "/*!\n * line\n */.a{b:1}"
    );
    assert_eq!(
        css_compressed("/*! one */\n/*! two */\n.a { b: 1; }"),
        "/*! one *//*! two */.a{b:1}"
    );
    assert_eq!(css_compressed(".a { b: 1; }\n/*! tail */"), ".a{b:1}/*! tail */");
    assert_eq!(
        css_compressed(".a { b: 1; }\n/*! mid */\n.c { d: 1; }"),
        ".a{b:1}/*! mid */.c{d:1}"
    );
    // Inside a rule it takes the pending `;` and needs none of its own.
    assert_eq!(
        css_compressed(".a { b: 1; /*! c */ d: 2; }"),
        ".a{b:1;/*! c */d:2}"
    );
    assert_eq!(css_compressed(".a { /*! c */ b: 1; }"), ".a{/*! c */b:1}");
    assert_eq!(css_compressed(".a { b: 1; /*! c */ }"), ".a{b:1;/*! c */}");
    // A rule that holds nothing else is still emitted around it — but one
    // holding only a QUIET comment is not.
    assert_eq!(css_compressed(".a { /*! c */ }"), ".a{/*! c */}");
    assert_eq!(css_compressed(".a { /* c */ }"), "");
    assert_eq!(
        css_compressed(".a { /*! c */ .b { d: 1; } }"),
        ".a{/*! c */}.a .b{d:1}"
    );
    // And inside an at-rule body.
    assert_eq!(
        css_compressed("@media (a: 1) { /*! c */ .a { b: 1; } }"),
        "@media(a: 1){/*! c */.a{b:1}}"
    );
    // Interpolation resolves first, as in expanded output.
    assert_eq!(
        css_compressed("$x: 1;\n/*! v#{$x} */\n.a { b: 1; }"),
        "/*! v1 */.a{b:1}"
    );
}

/// A CSS escape is a TOKEN, and the whitespace that terminates a numeric one
/// belongs to it: `.\31  .b` is the class `1` and then a descendant combinator,
/// so compressing either space away changes which selector it is. Measured
/// against dart-sass 1.103.1.
#[test]
fn compressed_selectors_keep_an_escapes_terminator() {
    let sel = |scss: &str| css_compressed(&format!("{scss}{{a:1}}"));
    // The terminator survives; the structural space beside it is what goes.
    assert_eq!(sel(".\\31  > .b"), ".\\31 >.b{a:1}");
    assert_eq!(sel(".\\31  .b"), ".\\31  .b{a:1}");
    assert_eq!(sel(".\\31 .b"), ".\\31 .b{a:1}");
    assert_eq!(sel(".\\31 "), ".\\31 {a:1}");
    // Including at the end of a selector-list component, where trimming the
    // part would have eaten it.
    assert_eq!(sel(":not(.\\31 , .b)"), ":not(.\\31 ,.b){a:1}");
    assert_eq!(sel(":not(.a, .\\31 )"), ":not(.a,.\\31 ){a:1}");
    assert_eq!(sel(":is(.\\31 , .b) > .c"), ":is(.\\31 ,.b)>.c{a:1}");
    // A non-hex escape is one character and carries no terminator.
    assert_eq!(sel(".a\\ b > .c"), ".a\\ b>.c{a:1}");
    assert_eq!(sel(".a\\9 b .c"), ".a\\9 b .c{a:1}");
    // A hex digit after the terminator still belongs to the next token.
    assert_eq!(sel(".\\31 a .b"), ".\\31 a .b{a:1}");
}

/// `::slotted()` takes a selector list like `:not()` and friends — and the
/// dispatch is CASE-SENSITIVE, which is dart's own behaviour: `:NOT(.a, .b)`
/// keeps its comma space. Both measured against dart-sass 1.103.1.
#[test]
fn compressed_selector_pseudo_dispatch_matches_dart() {
    let sel = |scss: &str| css_compressed(&format!("{scss}{{a:1}}"));
    assert_eq!(sel("::slotted(.b, .c)"), "::slotted(.b,.c){a:1}");
    assert_eq!(sel(".x:-moz-any(.b, .c)"), ".x:-moz-any(.b,.c){a:1}");
    // dart compares the unvendored name verbatim, so an upper-case spelling is
    // opaque to it and keeps the space. Mirrored, not tidied.
    assert_eq!(sel(".x:NOT(.b, .c)"), ".x:NOT(.b, .c){a:1}");
    assert_eq!(sel(".x:Where(.b, .c)"), ".x:Where(.b, .c){a:1}");
    // An opaque argument keeps its space whatever the case.
    assert_eq!(sel(".x:LANG(en, fr)"), ".x:LANG(en, fr){a:1}");
}

/// A comment is loud by what it SAYS, not by how it was spelled: dart resolves
/// interpolation first, so `/*#{"!"} x */` is kept when compressing. Measured
/// against dart-sass 1.103.1.
#[test]
fn compressed_loudness_is_decided_after_interpolation() {
    assert_eq!(
        css_compressed("/*#{\"!\"} normal */\n.a { b: 1; }"),
        "/*! normal */.a{b:1}"
    );
    // A `!` that is not the first character is not loud.
    assert_eq!(css_compressed("/* !late */\n.a { b: 1; }"), ".a{b:1}");
}

/// The CSS `@import` writes no space before its url when compressing, and a
/// `url(…)` wrapper is unwrapped to save its four bytes. The modifiers keep the
/// spaces they hold between themselves. Measured against dart-sass 1.103.1.
#[test]
fn compressed_css_import_loses_its_prelude_space() {
    assert_eq!(
        css_compressed("@import \"x.css\";\n.a { b: 1; }"),
        "@import\"x.css\";.a{b:1}"
    );
    assert_eq!(
        css_compressed("@import url(x.css);\n.a { b: 1; }"),
        "@import\"x.css\";.a{b:1}"
    );
    assert_eq!(
        css_compressed("@import url(\"x.css\");\n.a { b: 1; }"),
        "@import\"x.css\";.a{b:1}"
    );
    // A plain quoted url is written exactly as it was spelled.
    assert_eq!(
        css_compressed("@import 'x.css';\n.a { b: 1; }"),
        "@import'x.css';.a{b:1}"
    );
    // Only the ONE separator before the modifiers goes.
    assert_eq!(
        css_compressed("@import \"x.css\" screen, print;\n.a { b: 1; }"),
        "@import\"x.css\"screen, print;.a{b:1}"
    );
    assert_eq!(
        css_compressed("@import \"x.css\" layer(a) supports(display: grid) screen;\n.a { b: 1; }"),
        "@import\"x.css\"layer(a) supports(display: grid) screen;.a{b:1}"
    );
    // Nested in a rule and in an at-rule body.
    assert_eq!(
        css_compressed(".a { @import url(x.css); }"),
        ".a{@import\"x.css\"}"
    );
    assert_eq!(
        css_compressed("@media screen { @import \"x.css\"; }"),
        "@media screen{@import\"x.css\"}"
    );
    // Expanded output is untouched: the source form survives.
    let expanded = |scss: &str| compile(scss, &Options::default()).expect("compile");
    assert_eq!(
        expanded("@import url(x.css);\n.a { b: 1; }"),
        "@import url(x.css);\n.a {\n  b: 1;\n}"
    );
}

/// An `@import`'s modifiers are ONE string, spelled by the PARSER and written
/// verbatim by `visitCssImport`: the media-rule serializer never runs, so the
/// compressed comma form never reaches them — and dart's `_mediaQuery` writes
/// the space that would separate a media type from the next identifier BEFORE
/// it learns that identifier is `and`, then writes the whole `" and "` anyway,
/// leaving TWO spaces. Measured against dart-sass 1.104.1 on 2026-09-21.
#[test]
fn a_css_imports_media_list_keeps_the_parsers_spelling() {
    let both = |scss: &str, expanded: &str, compressed: &str| {
        assert_eq!(css(scss), format!("{expanded}\n"), "{scss}");
        assert_eq!(css_compressed(scss), compressed, "{scss}");
    };
    // Everything after the first comma goes through `_mediaQueryList`, where a
    // bare media type collects the stray space.
    both(
        "@import url(\"a.css\") x, print and (orientation: landscape);\n",
        "@import url(\"a.css\") x, print  and (orientation: landscape);",
        "@import\"a.css\"x, print  and (orientation: landscape)",
    );
    // Only the FIRST `and` doubles: the rest come from the logic sequence.
    both(
        "@import url(\"a.css\") x, screen and (a: 1) and (b: 2);\n",
        "@import url(\"a.css\") x, screen  and (a: 1) and (b: 2);",
        "@import\"a.css\"x, screen  and (a: 1) and (b: 2)",
    );
    both(
        "@import url(\"a.css\") x, screen and not (a: 1);\n",
        "@import url(\"a.css\") x, screen  and not (a: 1);",
        "@import\"a.css\"x, screen  and not (a: 1)",
    );
    // A modifier absorbs the stray space, `not` included, because the parser
    // has already written it before reading the second identifier.
    both(
        "@import url(\"a.css\") x, only screen and (a: 1);\n",
        "@import url(\"a.css\") x, only screen and (a: 1);",
        "@import\"a.css\"x, only screen and (a: 1)",
    );
    both(
        "@import url(\"a.css\") x, not screen and (a: 1);\n",
        "@import url(\"a.css\") x, not screen and (a: 1);",
        "@import\"a.css\"x, not screen and (a: 1)",
    );
    // A type with no conditions has nothing to be separated from, and a query
    // that opens on a condition has no type. The media type's own case is kept.
    both(
        "@import url(\"a.css\") x, screen;\n",
        "@import url(\"a.css\") x, screen;",
        "@import\"a.css\"x, screen",
    );
    both(
        "@import url(\"a.css\") (a: 1) and (b: 2), screen and (c: 3);\n",
        "@import url(\"a.css\") (a: 1) and (b: 2), screen  and (c: 3);",
        "@import\"a.css\"(a: 1) and (b: 2), screen  and (c: 3)",
    );
    both(
        "@import url(\"a.css\") x, SCREEN and (A: 1);\n",
        "@import url(\"a.css\") x, SCREEN  and (A: 1);",
        "@import\"a.css\"x, SCREEN  and (A: 1)",
    );
    // Before any comma the modifier loop joins identifiers with ONE space, so
    // the same query written first is spelled the ordinary way.
    both(
        "@import url(\"a.css\") screen and (a: 1);\n",
        "@import url(\"a.css\") screen and (a: 1);",
        "@import\"a.css\"screen and (a: 1)",
    );
    // A REAL `@media` rule re-serializes from its parsed queries, so it has one
    // space here and the compressed comma form the import cannot have.
    both(
        "@media x, screen and (a: 1) { b { c: d } }\n",
        "@media x, screen and (a: 1) {\n  b {\n    c: d;\n  }\n}",
        "@media x,screen and (a: 1){b{c:d}}",
    );
}

/// A `@supports` DECLARATION is not a value: dart writes its calculations
/// verbatim, spaces and all, in both styles — `calc-size` included. Measured
/// against dart-sass 1.103.1.
#[test]
fn compressed_supports_declarations_keep_their_calculation_spaces() {
    for (scss, want) in [
        (
            "@supports (width: calc-size(auto, var(--y))) { .a { b: 1; } }",
            "@supports(width: calc-size(auto, var(--y))){.a{b:1}}",
        ),
        (
            "@supports (width: clamp(1px, var(--y), 2px)) { .a { b: 1; } }",
            "@supports(width: clamp(1px, var(--y), 2px)){.a{b:1}}",
        ),
        (
            "@supports (width: min(1px, var(--y))) { .a { b: 1; } }",
            "@supports(width: min(1px, var(--y))){.a{b:1}}",
        ),
    ] {
        assert_eq!(css_compressed(scss), want, "{scss}");
    }
    // The same calculations as VALUES do lose the space.
    assert_eq!(
        css_compressed(".a { b: calc-size(auto, var(--y)); }"),
        ".a{b:calc-size(auto,var(--y))}"
    );
}

/// A module's own trailing `;` is dropped by looking at its last VISIBLE
/// child. Several kinds of node write nothing at all when compressing — a
/// blank, a control-only marker (what a stripped `/*# sourceMappingURL */`
/// leaves behind), a comment that is not loud, a rule holding only dropped
/// comments — and none of them may hide the node that really wrote the last
/// byte. Every block below was measured against dart-sass 1.103.1.
#[test]
fn compressed_finds_a_modules_last_visible_child() {
    let dir = std::env::temp_dir().join(format!("sasso_tail_{}", std::process::id()));
    std::fs::create_dir_all(&dir).expect("mkdir");
    let imp = sasso::FsImporter::new(vec![dir.clone()]);
    let run = |name: &str, module: &str, entry: &str| -> String {
        std::fs::write(dir.join(format!("_{name}.scss")), module).unwrap();
        compile(
            entry,
            &Options::default()
                .with_importer(&imp)
                .with_style(OutputStyle::Compressed),
        )
        .expect("compile")
    };
    // A childless at-rule writes its own `;`, and it comes off when it is last
    // — behind any number of nodes that write nothing.
    for (name, module) in [
        ("tail_plain", "@namespace \"x\";\n"),
        ("tail_blank", "@namespace \"x\";\n\n\n"),
        ("tail_quiet", "@namespace \"x\";\n/* quiet */\n"),
        ("tail_map", "@namespace \"x\";\n/*# sourceMappingURL=x.map */\n"),
        (
            "tail_empty_rule",
            "@namespace \"x\";\n.e { /* only a comment */ }\n",
        ),
        ("tail_empty_at", "@namespace \"x\";\n@media a {}\n"),
    ] {
        assert_eq!(
            run(name, module, &format!("@use \"{name}\";")),
            "@namespace \"x\"",
            "{name}"
        );
    }
    // A node that DOES write keeps the separator, loud comments included.
    assert_eq!(
        run(
            "tail_loud",
            "@namespace \"x\";\n/*! loud */\n",
            "@use \"tail_loud\";"
        ),
        "@namespace \"x\";/*! loud */"
    );
    assert_eq!(
        run(
            "tail_after",
            "@namespace \"x\";\n",
            "@use \"tail_after\";\n.z { y: 1; }"
        ),
        "@namespace \"x\";.z{y:1}"
    );
    // And a passed-through `@import` behind an invisible tail, the other node
    // kind that carries its own terminator.
    assert_eq!(
        run(
            "tail_import",
            "@import \"z.css\";\n/* quiet */\n",
            "@use \"tail_import\";"
        ),
        "@import\"z.css\""
    );
    // A MODULE is only as visible as its contents: `meta.load-css` of a
    // stylesheet that is all comments writes nothing, and splicing it in after
    // the at-rule must not hide it.
    std::fs::write(dir.join("_all_comments.scss"), "/* quiet */\n").unwrap();
    std::fs::write(dir.join("_nothing.scss"), "\n").unwrap();
    for loaded in ["all_comments", "nothing"] {
        assert_eq!(
            run(
                "tail_load",
                &format!("@use \"sass:meta\";\n@namespace \"x\";\n@include meta.load-css(\"{loaded}\");\n"),
                "@use \"tail_load\";",
            ),
            "@namespace \"x\"",
            "{loaded}"
        );
    }
    // One that DOES write keeps the separator.
    std::fs::write(dir.join("_writes.scss"), ".w { v: 1; }\n").unwrap();
    assert_eq!(
        run(
            "tail_load2",
            "@use \"sass:meta\";\n@namespace \"x\";\n@include meta.load-css(\"writes\");\n",
            "@use \"tail_load2\";",
        ),
        "@namespace \"x\";.w{v:1}"
    );
    std::fs::remove_dir_all(&dir).ok();
}

/// An `@import` inside a rule of a LOADED plain-CSS file is a CSS import like
/// any other, and compressed output spells it with no gap. Measured against
/// dart-sass 1.103.1.
#[test]
fn compressed_nested_plain_css_import_loses_its_gap() {
    let dir = std::env::temp_dir().join(format!("sasso_nested_import_{}", std::process::id()));
    std::fs::create_dir_all(&dir).expect("mkdir");
    let imp = sasso::FsImporter::new(vec![dir.clone()]);
    let run = |name: &str, css: &str| -> String {
        std::fs::write(dir.join(format!("{name}.css")), css).unwrap();
        compile(
            &format!("@use \"{name}\";"),
            &Options::default()
                .with_importer(&imp)
                .with_style(OutputStyle::Compressed),
        )
        .expect("compile")
    };
    assert_eq!(
        run("v1", ".a {\n  @import url(x.css);\n}\n"),
        ".a{@import\"x.css\"}"
    );
    assert_eq!(
        run("v2", ".a {\n  @import \"x.css\";\n}\n"),
        ".a{@import\"x.css\"}"
    );
    assert_eq!(
        run("v3", "@import url(x.css);\n.a { b: 1; }\n"),
        "@import\"x.css\";.a{b:1}"
    );
    std::fs::remove_dir_all(&dir).ok();
}

/// A call sasso cannot dispatch becomes a STRING, and dart builds one with the
/// DEFAULT style whatever the output style is — so its arguments keep their
/// leading zeros. That holds for a name written out AND for one that arrives
/// through interpolation, which reaches the same unquoted-string form by
/// another path. Measured against dart-sass 1.103.1.
#[test]
fn compressed_plain_css_calls_keep_their_arguments_default_style() {
    let v = |scss: &str| css_compressed(&format!("$o: o;\na{{x:{scss}}}"));
    // An interpolated name, part of it and all of it.
    assert_eq!(v("f#{$o}o(0.5)"), "a{x:foo(0.5)}");
    assert_eq!(v("f#{$o}o(0.5, -0.5px)"), "a{x:foo(0.5, -0.5px)}");
    assert_eq!(v("#{\"fo\" + $o}(0.5)"), "a{x:foo(0.5)}");
    assert_eq!(v("1px f#{$o}o(0.5)"), "a{x:1px foo(0.5)}");
    assert_eq!(v("f#{$o}o(inner(0.5))"), "a{x:foo(inner(0.5))}");
    // And a name written out, which took the other path.
    assert_eq!(v("foo(0.5)"), "a{x:foo(0.5)}");
    assert_eq!(v("translate(0.5px)"), "a{x:translate(0.5px)}");
    // Expanded output is the same string either way.
    let e = |scss: &str| compile(&format!("$o: o;\na{{x:{scss}}}"), &Options::default()).expect("compile");
    assert_eq!(e("f#{$o}o(0.5)"), "a {\n  x: foo(0.5);\n}");
    assert_eq!(e("foo(0.5)"), "a {\n  x: foo(0.5);\n}");
}

/// An ESCAPE is one token, so an escaped delimiter is part of an identifier
/// and not structure: `.a\,b` is ONE class whose name contains a comma, and
/// `\&` is an ampersand rather than a parent reference. Every expectation
/// below was measured against dart-sass 1.103.1.
#[test]
fn an_escaped_delimiter_is_not_selector_structure() {
    let css = |scss: &str| compile(scss, &Options::default()).expect("compile");
    // The comma does not split the selector list — and the class keeps its
    // escape, rather than decoding to a replacement character.
    assert_eq!(css(".a\\,b { c: 1; }"), ".a\\,b {\n  c: 1;\n}");
    assert_eq!(css(".\\, { a: 1; }"), ".\\, {\n  a: 1;\n}");
    assert_eq!(css("#a\\,b { c: 1; }"), "#a\\,b {\n  c: 1;\n}");
    assert_eq!(css("a\\,b { c: 1; }"), "a\\,b {\n  c: 1;\n}");
    assert_eq!(css(".a\\,b, .c { d: 1; }"), ".a\\,b, .c {\n  d: 1;\n}");
    // Nested, where the parent is substituted into the child.
    assert_eq!(css(".x { .a\\,b { c: 1; } }"), ".x .a\\,b {\n  c: 1;\n}");
    assert_eq!(css(".a\\,b { .c { d: 1; } }"), ".a\\,b .c {\n  d: 1;\n}");
    assert_eq!(css(".x { &\\,y { c: 1; } }"), ".x\\,y {\n  c: 1;\n}");
    // An escaped `&` is a character, not the parent.
    assert_eq!(css(".x { .a\\&b { c: 1; } }"), ".x .a\\&b {\n  c: 1;\n}");
    assert_eq!(css("\\&a { b: 1; }"), "\\&a {\n  b: 1;\n}");
    // `@extend` matches the same identifier through the same scanners.
    assert_eq!(
        css("%p { a: 1; }\n.x\\,y { @extend %p; }"),
        ".x\\,y {\n  a: 1;\n}"
    );
    assert_eq!(
        css(".a\\,b { c: 1; }\n.d { @extend .a\\,b; }"),
        ".a\\,b, .d {\n  c: 1;\n}"
    );
    // A HEX escape of the same character behaves the same way — and is
    // rewritten to the canonical spelling, as dart does.
    assert_eq!(css(".a\\2c b { c: 1; }"), ".a\\,b {\n  c: 1;\n}");
    assert_eq!(css(".a\\2c b, .c { d: 1; }"), ".a\\,b, .c {\n  d: 1;\n}");
    // The CARTESIAN path — two or more top-level `&`s, where the part is cut
    // into segments and rebuilt once per parent — walks the same text again.
    assert_eq!(css(".p { & .a\\,b & { c: 1; } }"), ".p .a\\,b .p {\n  c: 1;\n}");
    assert_eq!(
        css(".p { & .a\\,b & .c { d: 1; } }"),
        ".p .a\\,b .p .c {\n  d: 1;\n}"
    );
    assert_eq!(
        css(".p, .q { & .a\\,b & { c: 1; } }"),
        ".p .a\\,b .p, .p .a\\,b .q, .q .a\\,b .p, .q .a\\,b .q {\n  c: 1;\n}"
    );
    assert_eq!(css(".p { & .a\\&b & { c: 1; } }"), ".p .a\\&b .p {\n  c: 1;\n}");
    assert_eq!(css(".p { & & .a\\, { c: 1; } }"), ".p .p .a\\, {\n  c: 1;\n}");
    // A quote that ends EARLY is the same mistake one level down: `\"` does
    // not close a `"`-quoted attribute value, and a quote left open would
    // swallow the `]` after it and hide every top-level `&` that follows —
    // so the part would look like it had one. (The value below holds both
    // quote characters, which is what keeps dart from re-quoting it and lets
    // the expansion be compared on its own.)
    assert_eq!(
        css(".p, .q { & [data-x=\"a\\\"b'c\"] & { d: 1; } }"),
        ".p [data-x=\"a\\\"b'c\"] .p, .p [data-x=\"a\\\"b'c\"] .q, \
         .q [data-x=\"a\\\"b'c\"] .p, .q [data-x=\"a\\\"b'c\"] .q {\n  d: 1;\n}"
    );
    assert_eq!(
        css(".p, .q { & [data-x=\"a\\\"&b'c\"] & { d: 1; } }"),
        ".p [data-x=\"a\\\"&b'c\"] .p, .p [data-x=\"a\\\"&b'c\"] .q, \
         .q [data-x=\"a\\\"&b'c\"] .p, .q [data-x=\"a\\\"&b'c\"] .q {\n  d: 1;\n}"
    );
    // An `&` inside a quoted value is text, not a reference, whichever quote
    // holds it.
    assert_eq!(
        css(".p, .q { [data-x=\"a&b\"] { c: 1; } }"),
        ".p [data-x=\"a&b\"], .q [data-x=\"a&b\"] {\n  c: 1;\n}"
    );
    // An `&` inside an ATTRIBUTE is text too, and two more scanners were
    // reading it as a reference. The check that a parent ending in a
    // combinator is not glued to a `&` rejected a selector it has no business
    // rejecting:
    assert_eq!(
        css("p > { & [data-x=\"&.x\"] { d: 1; } }"),
        "p > [data-x=\"&.x\"] {\n  d: 1;\n}"
    );
    // …while the pseudo-argument substitution expanded the parents INTO the
    // attribute value instead of leaving the part to the normal path.
    assert_eq!(
        css(".p, .q { :not([data=\"&\"]) { c: 1; } }"),
        ".p :not([data=\"&\"]), .q :not([data=\"&\"]) {\n  c: 1;\n}"
    );
    assert_eq!(
        css(".p, .q { :not([data=\"&-c\"]) { c: 1; } }"),
        ".p :not([data=\"&-c\"]), .q :not([data=\"&-c\"]) {\n  c: 1;\n}"
    );
    assert_eq!(
        css(".p, .q { :is([data=\"&\"]) { c: 1; } }"),
        ".p :is([data=\"&\"]), .q :is([data=\"&\"]) {\n  c: 1;\n}"
    );
    // A REAL pseudo-argument `&` still expands in place, one complex.
    assert_eq!(
        css(".p, .q { :not(&-c) { d: 1; } }"),
        ":not(.p-c, .q-c) {\n  d: 1;\n}"
    );
    // And a parent that really IS glued to a suffix is still rejected.
    assert!(compile("p > { &.x { d: 1; } }", &Options::default()).is_err());
    // An escaped BRACKET or PAREN must not move the depth counters, which is
    // what the comma split and the `&` counting are steered by. Without that,
    // the list comma below is swallowed and the whole thing is ONE selector —
    // and nothing above would notice.
    // Nesting is what makes the failure visible: with the counter moved, the
    // comma is swallowed and the list is ONE selector — whose own text reads
    // the same, so only the LENGTH gives it away.
    for esc in ["\\[", "\\(", "\\]", "\\)", "\\,"] {
        assert_eq!(
            css(&format!(".a{esc}b, .c {{ & .d {{ e: 1; }} }}")),
            format!(".a{esc}b .d, .c .d {{\n  e: 1;\n}}"),
            "{esc}"
        );
    }
    // A REAL attribute or pseudo after the escape still counts, so its own
    // comma stays inside it — an escaped CLOSER that had decremented the
    // counter would let that comma split the list instead.
    assert_eq!(
        css(".a\\]b[x=\",\"], .c { d: 1; }"),
        ".a\\]b[x=\",\"], .c {\n  d: 1;\n}"
    );
    assert_eq!(
        css(".a\\)b:not(.x, .y), .c { d: 1; }"),
        ".a\\)b:not(.x, .y), .c {\n  d: 1;\n}"
    );
    // The same invariant decides whether the SECOND top-level `&` is seen, so
    // each of the four takes the cartesian path with two parents.
    for esc in ["\\[", "\\(", "\\]", "\\)"] {
        assert_eq!(
            css(&format!(".p, .q {{ & .a{esc}b & {{ c: 1; }} }}")),
            format!(".p .a{esc}b .p, .p .a{esc}b .q, .q .a{esc}b .p, .q .a{esc}b .q {{\n  c: 1;\n}}"),
            "{esc}"
        );
    }
    // …and with a real attribute after the escaped one.
    assert_eq!(
        css(".p, .q { & .a\\[b[x=\"y\"] & { c: 1; } }"),
        ".p .a\\[b[x=y] .p, .p .a\\[b[x=y] .q, \
         .q .a\\[b[x=y] .p, .q .a\\[b[x=y] .q {\n  c: 1;\n}"
    );
    // And whether the parent substitution finds the `&` at all.
    assert_eq!(css(".p { .a\\[b & { c: 1; } }"), ".a\\[b .p {\n  c: 1;\n}");
    // Everything above holds when compressing, where the same text is walked
    // again to take the spaces out.
    assert_eq!(css_compressed(".a\\,b, .c { d: 1; }"), ".a\\,b,.c{d:1}");
    assert_eq!(
        css_compressed(".x { .a\\&b > .c { d: 1; } }"),
        ".x .a\\&b>.c{d:1}"
    );
}

/// A part with two or more top-level `&`s is cut at the references and rebuilt
/// from the text between them, so every cut has to land on a CHARACTER
/// boundary: `.ü` is two bytes and an emoji four. Every expectation below was
/// measured against dart-sass 1.104.1.
#[test]
fn a_cartesian_part_is_cut_on_character_boundaries() {
    // Non-ASCII output carries dart's `@charset` prologue; these cases are
    // about the expansion, so it is taken off here.
    let sel = |scss: &str| -> String {
        let out = compile(scss, &Options::default()).expect("compile");
        out.strip_prefix("@charset \"UTF-8\";\n")
            .expect("non-ASCII output opens with the charset prologue")
            .to_string()
    };
    assert_eq!(
        sel(".p, .q { & .ü & { c: 1; } }"),
        ".p .ü .p, .p .ü .q, .q .ü .p, .q .ü .q {\n  c: 1;\n}"
    );
    assert_eq!(
        sel(".p { & .日本語-クラス & { c: 2; } }"),
        ".p .日本語-クラス .p {\n  c: 2;\n}"
    );
    // An escape and a multi-byte character in the same segment.
    assert_eq!(
        sel(".p, .q { & .a\\,ü & { c: 3; } }"),
        ".p .a\\,ü .p, .p .a\\,ü .q, .q .a\\,ü .p, .q .a\\,ü .q {\n  c: 3;\n}"
    );
    // A `&` inside a quoted attribute value is text, not a cut — and the
    // characters around it are still counted in bytes.
    assert_eq!(
        sel(".p, .q { & [data-x=\"ü&é\"] & { c: 4; } }"),
        ".p [data-x=\"ü&é\"] .p, .p [data-x=\"ü&é\"] .q, \
         .q [data-x=\"ü&é\"] .p, .q [data-x=\"ü&é\"] .q {\n  c: 4;\n}"
    );
    // A four-byte character before the second reference, and a trailing
    // segment after it.
    assert_eq!(sel(".p { & .🎉 & .é { c: 5; } }"), ".p .🎉 .p .é {\n  c: 5;\n}");
    // Non-ASCII PARENTS, substituted into every cartesian position.
    assert_eq!(
        sel(".ü, .é { & & { c: 6; } }"),
        ".ü .ü, .ü .é, .é .ü, .é .é {\n  c: 6;\n}"
    );
    // One reference is not a cut at all: it takes the substitution path.
    assert_eq!(sel(".ü { &-é { c: 7; } }"), ".ü-é {\n  c: 7;\n}");
}

/// Compressed output drops anything that writes nothing — a rule or at-rule
/// whose body is only comments, however deep it nests, and the separator such
/// an item would otherwise have taken. Measured against dart-sass 1.103.1.
#[test]
fn compressed_drops_what_writes_nothing() {
    assert_eq!(css_compressed("@media x { /* c */ }"), "");
    assert_eq!(css_compressed("@media x { .a { /* c */ } }"), "");
    assert_eq!(css_compressed("@supports (a: 1) { /* c */ }"), "");
    assert_eq!(css_compressed(".a { /* c */ }"), "");
    assert_eq!(css_compressed(".a { .b { /* c */ } }"), "");
    // A declaration before one of those keeps no trailing separator.
    assert_eq!(css_compressed(".a { c: 1; @media x { /* d */ } }"), ".a{c:1}");
    assert_eq!(
        css_compressed("@media x { .a { b: 1; } .c { /* d */ } }"),
        "@media x{.a{b:1}}"
    );
    // Anything that DOES write keeps its wrapper.
    assert_eq!(css_compressed("@media x { /*! c */ }"), "@media x{/*! c */}");
    assert_eq!(css_compressed("@media x { .a { b: 1; } }"), "@media x{.a{b:1}}");
    // Expanded output keeps them all, as dart does — on one line when they
    // were written that way, and over three when they were not.
    let expanded = |scss: &str| compile(scss, &Options::default()).expect("compile");
    assert_eq!(expanded("@media x { /* c */ }"), "@media x { /* c */ }");
    assert_eq!(expanded(".a { /* c */ }"), ".a { /* c */ }");
    assert_eq!(expanded("@media x {\n  /* c */\n}"), "@media x {\n  /* c */\n}");
    assert_eq!(expanded(".a {\n  /* c */\n}"), ".a {\n  /* c */\n}");
}

/// ...but an at-rule that is NOT `@media`/`@supports` survives an empty block.
/// dart-sass `_isInvisible` returns false for a `CssAtRule` on purpose —
/// "because we don't know the semantics of unknown rules, we can't guarantee
/// that (for example) `@foo {}` isn't meaningful" — while `@media`/`@supports`
/// have their own AST classes and are invisible when every child is. Measured
/// against dart-sass 1.104.1.
#[test]
fn compressed_keeps_an_empty_at_rule_that_is_not_media_or_supports() {
    // Authored empty, and unchanged by compression apart from the space.
    for scss in [
        "@foo {}",
        "@font-face {}",
        "@page {}",
        "@page :first {}",
        "@keyframes {}",
        "@keyframes k {}",
        "@layer a {}",
        "@container c {}",
        "@a b {}",
    ] {
        assert_eq!(css_compressed(scss), scss.replace(" {}", "{}"), "{scss}");
    }
    // Emptied by compression: the comment goes, the at-rule stays.
    assert_eq!(css_compressed("@foo { /* c */ }"), "@foo{}");
    assert_eq!(
        css_compressed("@keyframes k { 10% { /* c */ } }"),
        "@keyframes k{}"
    );
    assert_eq!(css_compressed("@foo { .a { /* c */ } }"), "@foo{}");
    // Emptied by `@extend`, which moves the only rule's content into the
    // earlier block (sass-spec `198_test_extend_within_disparate_...`).
    assert_eq!(
        css_compressed(
            "@foo {.a {b: c}}
@foo {.d {@extend .a}}"
        ),
        "@foo{.a,.d{b:c}}@foo{}"
    );
    // A surviving at-rule keeps its `@media` parent alive with it; an at-rule
    // child that writes nothing does not.
    assert_eq!(
        css_compressed("@media (a: b) { @foo { /* c */ } }"),
        "@media(a: b){@foo{}}"
    );
    assert_eq!(css_compressed("@media (a: b) { @media print { /* c */ } }"), "");
    assert_eq!(
        css_compressed("@supports (a: b) { @foo { /* c */ } }"),
        "@supports(a: b){@foo{}}"
    );
    // What survives is decided by the node class, not the name: a
    // capitalized `@MEDIA` and an interpolated `@#{"media"}` are both the
    // generic at-rule dart parses them as, and both survive.
    assert_eq!(css_compressed("@MEDIA screen { /* c */ }"), "@MEDIA screen{}");
    assert_eq!(
        css_compressed("@#{\"media\"} screen { /* c */ }"),
        "@media screen{}"
    );
    assert_eq!(css_compressed("@#{\"supports\"} (a: 1) {}"), "@supports (a: 1){}");
    // Separators: an empty at-rule ends in `}`, which separates it from
    // whatever follows, and it leaves no trailing `;` behind.
    assert_eq!(css_compressed(".a { b: c } @foo {}"), ".a{b:c}@foo{}");
    assert_eq!(css_compressed("@foo {} .a { b: c }"), "@foo{}.a{b:c}");
    assert_eq!(css_compressed("@foo { .a { /* c */ } } @bar {}"), "@foo{}@bar{}");
}

/// A value is verbatim text and can end in a `;` of its own, which dart keeps
/// — so what may be dropped is decided by the NODE that wrote the last byte,
/// never by the byte. Measured against dart-sass 1.103.1.
#[test]
fn compressed_keeps_a_semicolon_that_belongs_to_a_value() {
    let v = "$v: \";\";\n";
    assert_eq!(
        css_compressed(&format!("{v}.a {{ --x: #{{$v}}; }}")),
        ".a{--x: ;}"
    );
    assert_eq!(
        css_compressed(&format!("{v}@font-face {{ --x: #{{$v}}; }}")),
        "@font-face{--x: ;}"
    );
    assert_eq!(
        css_compressed(&format!("{v}@font-face {{ src: #{{$v}}; }}")),
        "@font-face{src:;}"
    );
    assert_eq!(
        css_compressed(&format!("{v}@font-face {{ a: 1; --x: #{{$v}}; }}")),
        "@font-face{a:1;--x: ;}"
    );
    assert_eq!(
        css_compressed(&format!("{v}@media a {{ @font-face {{ --x: #{{$v}}; }} }}")),
        "@media a{@font-face{--x: ;}}"
    );
}

/// An at-rule whose NAME is interpolated is generic in dart — it never reaches
/// the serializer's `@import` path — so it keeps the gap a real CSS `@import`
/// loses. Measured against dart-sass 1.103.1.
#[test]
fn compressed_interpolated_at_rule_names_keep_their_gap() {
    assert_eq!(
        css_compressed("@#{\"import\"} \"x.css\";\n.a { b: 1; }"),
        "@import \"x.css\";.a{b:1}"
    );
    // Written literally, the same rule loses it.
    assert_eq!(
        css_compressed("@import \"x.css\";\n.a { b: 1; }"),
        "@import\"x.css\";.a{b:1}"
    );
    // And inside a style rule, where the import is an item rather than a node.
    assert_eq!(
        css_compressed(".a { @import url(x.css); }"),
        ".a{@import\"x.css\"}"
    );
    assert_eq!(
        css_compressed(".a { @#{\"import\"} \"x.css\"; }"),
        ".a{@import \"x.css\"}"
    );
}

/// `::cue` and `::cue-region` take a selector list by the grammar, but dart's
/// serializer does not treat them as one — their commas keep the space, and so
/// does `::part`'s. Recorded so the compressor's table is not "fixed" into a
/// divergence. Measured against dart-sass 1.103.1.
#[test]
fn compressed_leaves_the_pseudo_elements_dart_leaves() {
    let sel = |scss: &str| css_compressed(&format!("{scss}{{a:1}}"));
    assert_eq!(sel("::cue(.b, .c)"), "::cue(.b, .c){a:1}");
    assert_eq!(sel("::cue-region(.b, .c)"), "::cue-region(.b, .c){a:1}");
    assert_eq!(sel("::part(b, c)"), "::part(b, c){a:1}");
}

/// dart writes a statement's `;` as a SEPARATOR, so compressed output never
/// ends with one — at the end of the stylesheet or before a `}`. Measured
/// against dart-sass 1.103.1.
#[test]
fn compressed_output_never_ends_with_a_semicolon() {
    assert_eq!(css_compressed("@import \"x.css\";"), "@import\"x.css\"");
    assert_eq!(
        css_compressed("@import \"x.css\" screen;"),
        "@import\"x.css\"screen"
    );
    assert_eq!(css_compressed("@namespace \"x\";"), "@namespace \"x\"");
    assert_eq!(css_compressed("@unknown foo;"), "@unknown foo");
    assert_eq!(
        css_compressed("@media a { @unknown foo; }"),
        "@media a{@unknown foo}"
    );
    assert_eq!(css_compressed(".a { b: 1; }"), ".a{b:1}");
    assert_eq!(
        css_compressed("@font-face { src: url(x); }"),
        "@font-face{src:url(x)}"
    );
}

/// A private-use character is escaped in expanded output and written RAW when
/// compressing — dart trades the escape for the character once bytes are what
/// matter. Measured against dart-sass 1.103.1; the UNQUOTED writer and the
/// `inspect` string were measured against 1.104.1 on 2026-09-21.
#[test]
fn compressed_writes_private_use_characters_raw() {
    let expanded = |scss: &str| compile(scss, &Options::default()).expect("compile");
    // U+E028 is private use: escaped when expanded, raw when compressed — and
    // the raw character makes the output non-ASCII, which brings the BOM that
    // compressed style writes in place of `@charset`.
    assert_eq!(
        expanded(".a::before { content: \"\\e028\"; }"),
        ".a::before {\n  content: \"\\e028\";\n}"
    );
    assert_eq!(
        css_compressed(".a::before { content: \"\\e028\"; }"),
        "\u{feff}.a::before{content:\"\u{e028}\"}"
    );
    // Written raw in the source, it comes out the same way round.
    assert_eq!(
        expanded(".a::before { content: \"\u{e028}\"; }"),
        ".a::before {\n  content: \"\\e028\";\n}"
    );
    assert_eq!(
        css_compressed(".a::before { content: \"\u{e028}\"; }"),
        "\u{feff}.a::before{content:\"\u{e028}\"}"
    );
    // Both edges of the BMP range, and the SUPPLEMENTARY private-use planes
    // (U+F0000-U+10FFFF), whose characters are four UTF-8 bytes rather than
    // three — the branch the escape used to hide.
    assert_eq!(
        css_compressed(".a::before { content: \"\\e000\"; }"),
        "\u{feff}.a::before{content:\"\u{e000}\"}"
    );
    assert_eq!(
        css_compressed(".a::before { content: \"\\f8ff\"; }"),
        "\u{feff}.a::before{content:\"\u{f8ff}\"}"
    );
    assert_eq!(
        css_compressed(".a::before { content: \"\\f0000\"; }"),
        "\u{feff}.a::before{content:\"\u{f0000}\"}"
    );
    assert_eq!(
        css_compressed(".a::before { content: \"\\10fffd\"; }"),
        "\u{feff}.a::before{content:\"\u{10fffd}\"}"
    );
    // A character that is NOT private use is raw in both styles already, and a
    // control character stays escaped in both.
    assert_eq!(
        css_compressed(".a::before { content: \"\\4e2d\"; }"),
        "\u{feff}.a::before{content:\"\u{4e2d}\"}"
    );
    assert_eq!(
        css_compressed(".a::before { content: \"\\1\"; }"),
        ".a::before{content:\"\\1\"}"
    );
    // `inspect` and error messages keep the escape whatever the style, because
    // they are not CSS output.
    assert_eq!(
        css_compressed(".a { b: inspect(\"\\e028\"); }"),
        ".a{b:\"\\e028\"}"
    );
    // The UNQUOTED writer follows the same rule as the quoted one, in both the
    // BMP range and the supplementary planes.
    assert_eq!(expanded("a { b: unquote(\"\\e000\"); }"), "a {\n  b: \\e000;\n}");
    assert_eq!(
        css_compressed("a { b: unquote(\"\\e000\"); }"),
        "\u{feff}a{b:\u{e000}}"
    );
    assert_eq!(css_compressed("a { b: \\f0000; }"), "\u{feff}a{b:\u{f0000}}");
    assert_eq!(
        css_compressed("a { b: unquote(\"\\e000\") x; }"),
        "\u{feff}a{b:\u{e000} x}"
    );
    // `inspect` escapes INSIDE the string it hands back, because it serializes
    // in the default style wherever it is called from. So the value written
    // here is ASCII — no BOM — and it is five characters long, not one.
    assert_eq!(
        css_compressed("@use \"sass:meta\";\na { b: meta.inspect((unquote(\"\\e000\"), x)); }"),
        "a{b:\\e000, x}"
    );
    assert_eq!(
        css_compressed("@use \"sass:string\";\na { b: string.length(inspect(unquote(\"\\e000\"))); }"),
        "a{b:5}"
    );
}

/// Compressed style drops the whitespace AROUND A COMBINATOR and the space
/// after a SELECTOR LIST's comma — and nothing else. Every expectation below
/// was measured against dart-sass 1.103.1 (`--style=compressed`).
#[test]
fn compressed_selectors_lose_only_structural_whitespace() {
    let sel = |scss: &str| css_compressed(&format!("{scss}{{a:1}}"));
    // The three combinators, on both sides.
    assert_eq!(sel(".a > .b"), ".a>.b{a:1}");
    assert_eq!(sel(".a + .b"), ".a+.b{a:1}");
    assert_eq!(sel(".a ~ .b"), ".a~.b{a:1}");
    assert_eq!(sel(".a .b > .c + .d ~ .e"), ".a .b>.c+.d~.e{a:1}");
    assert_eq!(sel("* > *"), "*>*{a:1}");
    // A descendant combinator IS a space; it stays.
    assert_eq!(sel(".a .b"), ".a .b{a:1}");
    // A combinator that opens a relative selector loses its trailing space.
    assert_eq!(sel(":has(+ .b)"), ":has(+.b){a:1}");
    assert_eq!(sel(":has(> .a, + .b)"), ":has(>.a,+.b){a:1}");
    // A SELECTOR-list comma loses its space; an opaque argument keeps it.
    assert_eq!(sel(":not(.b, .c)"), ":not(.b,.c){a:1}");
    assert_eq!(sel(":where(.a, .b) .c"), ":where(.a,.b) .c{a:1}");
    assert_eq!(sel(":is(:not(.a, .b), .c) > .d"), ":is(:not(.a,.b),.c)>.d{a:1}");
    assert_eq!(sel(":host-context(.a, .b)"), ":host-context(.a,.b){a:1}");
    assert_eq!(sel(":lang(en, fr)"), ":lang(en, fr){a:1}");
    // `:nth-child()` carries an An+B, and only its `of` tail is a list.
    assert_eq!(sel(":nth-child(2n + 1)"), ":nth-child(2n+1){a:1}");
    assert_eq!(
        sel(":nth-child(2n + 1 of .a, .b)"),
        ":nth-child(2n+1 of .a,.b){a:1}"
    );
    // Quoted and escaped text is not selector structure.
    assert_eq!(sel("[a=\"x > y\"]"), "[a=\"x > y\"]{a:1}");
    assert_eq!(sel(":not([a=\"x, y\"], .b)"), ":not([a=\"x, y\"],.b){a:1}");
    assert_eq!(sel(".a\\+b"), ".a\\+b{a:1}");
    assert_eq!(sel(".a\\:b > .c"), ".a\\:b>.c{a:1}");
    // A nested rule and an `@extend` rewrite go through the same writer.
    assert_eq!(css_compressed(".a { > .b { c: 1; } }"), ".a>.b{c:1}");
    assert_eq!(
        css_compressed("%p { a: 1; }\n.x > .y { @extend %p; }"),
        ".x>.y{a:1}"
    );
}

/// A preserved CSS calculation — one that keeps a `var()` or `env()` and so
/// cannot fold to a number — separates its arguments with a bare comma when
/// compressing, like any other value. Measured against dart-sass 1.103.1.
#[test]
fn compressed_preserved_calculations_drop_the_argument_space() {
    let v = |scss: &str| css_compressed(&format!("a{{x:{scss}}}"));
    assert_eq!(v("clamp(0.5px, var(--y), 2px)"), "a{x:clamp(.5px,var(--y),2px)}");
    assert_eq!(
        v("clamp(1px, env(safe-area), 2px)"),
        "a{x:clamp(1px,env(safe-area),2px)}"
    );
    assert_eq!(v("min(1px, var(--y))"), "a{x:min(1px,var(--y))}");
    assert_eq!(v("mod(var(--y), 2px)"), "a{x:mod(var(--y),2px)}");
    assert_eq!(v("pow(var(--y), 2)"), "a{x:pow(var(--y),2)}");
    assert_eq!(v("calc-size(auto, var(--y))"), "a{x:calc-size(auto,var(--y))}");
    assert_eq!(
        v("calc(1px + clamp(1px, var(--y), 2px))"),
        "a{x:calc(1px + clamp(1px,var(--y),2px))}"
    );
    // `round()` preserved because its operands' UNITS cannot combine is a
    // calculation like any other, not an unquoted string carrying one spelling
    // for both styles: `[measured]` against dart-sass 1.104.1, including the
    // strategy keyword, which the implicit-`nearest` two-argument form omits.
    assert_eq!(v("round(1px, 2bar)"), "a{x:round(1px,2bar)}");
    assert_eq!(v("round(1px, 10%)"), "a{x:round(1px,10%)}");
    assert_eq!(v("round(nearest, 1px, 10%)"), "a{x:round(nearest,1px,10%)}");
    assert_eq!(v("round(up, 1px, 2bar)"), "a{x:round(up,1px,2bar)}");
    assert_eq!(v("round(to-zero, 1foo, 2bar)"), "a{x:round(to-zero,1foo,2bar)}");
    assert_eq!(v("round(1px, var(--y))"), "a{x:round(1px,var(--y))}");
    assert_eq!(
        v("calc(1px + round(1px, 2bar))"),
        "a{x:calc(1px + round(1px,2bar))}"
    );
    // Expanded keeps every space, and the value's TYPE is what dart reports.
    let expanded = |scss: &str| compile(scss, &Options::default()).expect("compile");
    assert_eq!(
        expanded("a { x: round(nearest, 1px, 10%) }"),
        "a {\n  x: round(nearest, 1px, 10%);\n}"
    );
    assert_eq!(
        expanded("@use \"sass:meta\"; a { x: meta.type-of(round(1px, 2bar)) }"),
        "a {\n  x: calculation;\n}"
    );
    // A `@supports` declaration is not a value: dart writes it verbatim, space
    // and all, in both styles.
    assert_eq!(
        css_compressed("@supports (width: clamp(1px, var(--y), 2px)) { .a { b: 1; } }"),
        "@supports(width: clamp(1px, var(--y), 2px)){.a{b:1}}"
    );
}

/// An at-rule whose name arrives through interpolation is a generic
/// `CssAtRule` in dart, whatever the name spells: the PARSER decides the class,
/// and by then `@#{"media"}` is not a `@media` rule. That is observable twice,
/// both times making the conditional rule the less visible one — the compressed
/// space before a `(` prelude, and the empty block that only a conditional rule
/// takes with it. `[measured]` against dart-sass 1.104.1.
#[test]
fn an_interpolated_at_rule_name_is_a_generic_at_rule() {
    // The space before `(`: dropped for a parsed `@media`/`@supports`, kept for
    // the interpolated spelling of either.
    assert_eq!(
        css_compressed("@media (a: 1) { .x { y: z } }"),
        "@media(a: 1){.x{y:z}}"
    );
    assert_eq!(
        css_compressed("@#{\"media\"} (a: 1) { .x { y: z } }"),
        "@media (a: 1){.x{y:z}}"
    );
    assert_eq!(
        css_compressed("@supports (a: 1) { .x { y: z } }"),
        "@supports(a: 1){.x{y:z}}"
    );
    assert_eq!(
        css_compressed("@#{\"supports\"} (a: 1) { .x { y: z } }"),
        "@supports (a: 1){.x{y:z}}"
    );
    // Wherever the node ends up: childless, bubbled out of a style rule, and
    // nested inside a real `@media`.
    // A childless one is generic by construction: a conditional group rule
    // always has a block (`@media (a: 1);` is "expected \"{\"" in both
    // engines), so nothing childless can drop the space.
    assert_eq!(css_compressed("@#{\"media\"} (a: 1);"), "@media (a: 1)");
    assert_eq!(
        css_compressed(".r { @#{\"media\"} (a: 1) { y: z } }"),
        "@media (a: 1){.r{y:z}}"
    );
    assert_eq!(
        css_compressed("@media (b: 2) { @#{\"media\"} (a: 1) { .x { y: z } } }"),
        "@media(b: 2){@media (a: 1){.x{y:z}}}"
    );
    // The empty block survives in BOTH styles, because `_isInvisible`
    // short-circuits on a generic at-rule.
    assert_eq!(css_compressed("@#{\"media\"} screen {}"), "@media screen{}");
    assert_eq!(css_compressed("@#{\"media\"} {}"), "@media{}");
    assert_eq!(
        css_compressed("@#{\"media\"} (a: 1) { /* c */ }"),
        "@media (a: 1){}"
    );
    assert_eq!(css("@#{\"media\"} screen {}"), "@media screen {}\n");
    assert_eq!(css("@#{\"supports\"} (a: 1) {}"), "@supports (a: 1) {}\n");
    // A parsed one, for contrast: emptied means gone.
    assert_eq!(css_compressed("@media screen {}"), "");
    assert_eq!(css("@media screen {}"), "");
    // A placeholder-only body is emptied after the fact, by `@extend`, and the
    // same split follows.
    assert_eq!(css_compressed("@media (a: 1) { %p { y: z } }"), "");
    assert_eq!(
        css_compressed("@#{\"media\"} (a: 1) { %p { y: z } }"),
        "@media (a: 1){}"
    );
}

#[test]
fn compressed_at_rule_prelude_spacing() {
    // dart-sass 1.101 compressed: `@media`/`@supports` drop the space before a
    // prelude that begins with `(`; within a `@media` query the space before
    // `and`/`or` is dropped after a `)` and the comma between queries loses its
    // space — but `@supports` conditions and other at-rules (`@container`) keep
    // their spaces, and an identifier media type keeps its `and` space.
    assert_eq!(
        css_compressed("@media (min-width: 1px) { a { x: 1 } }"),
        "@media(min-width: 1px){a{x:1}}"
    );
    assert_eq!(
        css_compressed("@media (a: 1) and (b: 2) { a { x: 1 } }"),
        "@media(a: 1)and (b: 2){a{x:1}}"
    );
    assert_eq!(
        css_compressed("@media (a: 1), (b: 2) { a { x: 1 } }"),
        "@media(a: 1),(b: 2){a{x:1}}"
    );
    assert_eq!(
        css_compressed("@media screen and (a: 1) { a { x: 1 } }"),
        "@media screen and (a: 1){a{x:1}}"
    );
    // @supports drops the leading `(` space but does NOT tighten `and`/`or`.
    assert_eq!(
        css_compressed("@supports (display: grid) { a { x: 1 } }"),
        "@supports(display: grid){a{x:1}}"
    );
    assert_eq!(
        css_compressed("@supports (a: 1) and (b: 2) { a { x: 1 } }"),
        "@supports(a: 1) and (b: 2){a{x:1}}"
    );
    // @container (and other at-rules) keep the space even before `(`.
    assert_eq!(
        css_compressed("@container (min-width: 1px) { a { x: 1 } }"),
        "@container (min-width: 1px){a{x:1}}"
    );
}

#[test]
fn comparison_and_logical_operators() {
    assert_eq!(css(".a { x: if(3 > 2, big, small); }"), ".a {\n  x: big;\n}\n");
    assert_eq!(css(".a { x: 1 + 2 == 3; }"), ".a {\n  x: true;\n}\n");
    assert_eq!(css(".a { x: not false; }"), ".a {\n  x: true;\n}\n");
    assert_eq!(css(".a { x: 1 == 1px; }"), ".a {\n  x: false;\n}\n");
    assert_eq!(css(".a { x: if(true and false, y, n); }"), ".a {\n  x: n;\n}\n");
    assert_eq!(css(".a { x: if(2 <= 2 or false, y, n); }"), ".a {\n  x: y;\n}\n");
}

#[test]
fn if_function_is_lazy() {
    // The branch not taken is never evaluated — referencing an undefined
    // variable there must not error.
    assert_eq!(css(".a { x: if(true, ok, $undefined); }"), ".a {\n  x: ok;\n}\n");
    // Named arguments.
    assert_eq!(
        css(".a { x: if($condition: false, $if-true: a, $if-false: b); }"),
        ".a {\n  x: b;\n}\n"
    );
}

#[test]
fn at_if_else_chain() {
    // Inside a rule the matched branch's declarations join the block.
    assert_eq!(
        css("$t: dark;\n.a { @if $t == dark { color: white; } @else { color: black; } padding: 1px; }"),
        ".a {\n  color: white;\n  padding: 1px;\n}\n"
    );
    // @else if.
    assert_eq!(
        css("$n: 2;\n.a { @if $n == 1 { x: a; } @else if $n == 2 { x: b; } @else { x: c; } }"),
        ".a {\n  x: b;\n}\n"
    );
    // A top-level @if yields a top-level group.
    assert_eq!(css("@if 2 > 1 { .b { y: 1; } }"), ".b {\n  y: 1;\n}\n");
    // A false branch contributes nothing.
    assert_eq!(
        css(".a { @if false { x: 1; } color: red; }"),
        ".a {\n  color: red;\n}\n"
    );
}

#[test]
fn at_for_loop() {
    assert_eq!(
        css("@for $i from 1 through 3 { .c#{$i} { w: $i * 10px; } }"),
        ".c1 {\n  w: 10px;\n}\n\n.c2 {\n  w: 20px;\n}\n\n.c3 {\n  w: 30px;\n}\n"
    );
    // Exclusive `to` stops one short.
    assert_eq!(
        css("@for $i from 1 to 3 { .c#{$i} { x: $i; } }"),
        ".c1 {\n  x: 1;\n}\n\n.c2 {\n  x: 2;\n}\n"
    );
}

#[test]
fn at_each_loop() {
    assert_eq!(
        css("@each $n in a, b { .i-#{$n} { content: \"#{$n}\"; } }"),
        ".i-a {\n  content: \"a\";\n}\n\n.i-b {\n  content: \"b\";\n}\n"
    );
    // Destructuring across nested lists.
    assert_eq!(
        css("@each $k, $v in (a 1), (b 2) { .#{$k} { order: $v; } }"),
        ".a {\n  order: 1;\n}\n\n.b {\n  order: 2;\n}\n"
    );
}

#[test]
fn at_while_loop() {
    assert_eq!(
        css(".x { $i: 0; @while $i < 3 { p-#{$i}: $i; $i: $i + 1; } }"),
        ".x {\n  p-0: 0;\n  p-1: 1;\n  p-2: 2;\n}\n"
    );
}

#[test]
fn at_function_and_return() {
    assert_eq!(
        css("@function double($n) { @return $n * 2; }\n.a { width: double(8px); }"),
        ".a {\n  width: 16px;\n}\n"
    );
    // Control flow + @return, keyword args, defaults.
    assert_eq!(
        css("@function cap($v, $max: 100) { @if $v > $max { @return $max; } @return $v; }\n.a { x: cap(150); y: cap(50, $max: 60); }"),
        ".a {\n  x: 100;\n  y: 50;\n}\n"
    );
    // Rest parameter + @each accumulation.
    assert_eq!(
        css("@function sum($n...) { $t: 0; @each $x in $n { $t: $t + $x; } @return $t; }\n.a { order: sum(1, 2, 3, 4); }"),
        ".a {\n  order: 10;\n}\n"
    );
}

#[test]
fn at_mixin_include_content() {
    assert_eq!(
        css("@mixin box($pad, $color: blue) { padding: $pad; color: $color; }\n.a { @include box(4px); }\n.b { @include box(8px, red); }"),
        ".a {\n  padding: 4px;\n  color: blue;\n}\n\n.b {\n  padding: 8px;\n  color: red;\n}\n"
    );
    // @content injects the include's block into the mixin body.
    assert_eq!(
        css("@mixin surround { border: 1px; @content; margin: 0; }\n.a { @include surround { background: yellow; } }"),
        ".a {\n  border: 1px;\n  background: yellow;\n  margin: 0;\n}\n"
    );
}

#[test]
fn a_reused_scope_table_is_empty_and_a_captured_one_is_untouched() {
    // A block's variable table is recycled when the block closes and nothing
    // captured it, so the next block to open gets a table that has already
    // held someone else's bindings. Two things have to hold for that to be
    // invisible: a reused table must read as empty, and a table a closure
    // still holds must not be reused at all.
    //
    // The sheet exercises both against a stream of opening and closing blocks
    // — a loop that rebinds its variables every iteration into ONE scope, a
    // `@content` block that reads the loop's bindings from inside a rule that
    // pushed and popped scopes of its own, and a mixin whose closure holds its
    // defining block's table while sibling rules come and go. Verified against
    // dart-sass 1.104.1.
    assert_eq!(
        css(concat!(
            "@mixin wrap($n) {\n  .w-#{$n} { @content; }\n}\n",
            "@each $name, $step in (a: 1, b: 2) {\n",
            "  $scaled: $step * 10;\n",
            "  .row-#{$name} {\n    $inner: $scaled + 1;\n    width: $inner * 1px;\n  }\n",
            "  @include wrap($name) { order: $scaled; }\n}\n",
            "@for $i from 1 through 3 {\n  $doubled: $i * 2;\n",
            "  .col-#{$i} {\n",
            "    @if $i > 1 {\n      $doubled: $doubled + 100;\n      margin: $doubled * 1px;\n",
            "    } @else {\n      margin: $doubled * 1px;\n    }\n  }\n}\n",
            ".outer {\n  $shared: 3;\n  @mixin local { pad: $shared * 1px; }\n",
            "  .a { @include local; }\n",
            "  .b {\n    $shared: 9;\n    @include local;\n  }\n",
            "  .c { @include local; }\n}\n",
        )),
        concat!(
            ".row-a {\n  width: 11px;\n}\n\n",
            ".w-a {\n  order: 10;\n}\n\n",
            ".row-b {\n  width: 21px;\n}\n\n",
            ".w-b {\n  order: 20;\n}\n\n",
            ".col-1 {\n  margin: 2px;\n}\n\n",
            ".col-2 {\n  margin: 104px;\n}\n\n",
            ".col-3 {\n  margin: 106px;\n}\n\n",
            // `$shared: 9` in `.b` assigns the enclosing block's variable
            // rather than declaring a new one, so `.c` reads 9 as well: the
            // mixin's closure and the block share one table, and it is that
            // sharing which keeps the table out of the pool.
            ".outer .a {\n  pad: 3px;\n}\n",
            ".outer .b {\n  pad: 9px;\n}\n",
            ".outer .c {\n  pad: 9px;\n}\n",
        )
    );
}

#[test]
fn a_nested_declaration_sees_its_blocks_later_siblings() {
    // A block's function/mixin frame is SHARED with the closure of every
    // callable declared in it, so a callable can name a sibling written after
    // it (dart-sass `Environment.closure()`). Both cases fail if a declaration
    // captures a snapshot of the frame instead.
    assert_eq!(
        css(".a {\n  @function first($n) { @return second($n) + 1; }\n  @function second($n) { @return $n * 2; }\n  order: first(3);\n}"),
        ".a {\n  order: 7;\n}\n"
    );
    // Mutual recursion between two mixins declared in a style rule.
    assert_eq!(
        css(".b {\n  @mixin ping($n) { @if $n > 0 { @include pong($n - 1); } @else { done: true; } }\n  @mixin pong($n) { @include ping($n); }\n  @include ping(3);\n}"),
        ".b {\n  done: true;\n}\n"
    );
}

#[test]
fn undefined_variable_is_an_error() {
    let err = compile(".a { color: $missing; }", &Options::default()).unwrap_err();
    assert!(err.message.contains("Undefined variable"));
}

#[test]
fn incompatible_units_error() {
    // dart-sass wording: "<a> and <b> have incompatible units." Mixing a
    // known unit (px) with an unknown/relative one (em) is incompatible.
    let err = compile(".a { width: 1px + 1em; }", &Options::default()).unwrap_err();
    assert!(err.message.contains("incompatible units"));
}

#[test]
fn hex_color_validation_matches_dart() {
    // A `#` followed by a digit is a hex color or an error — never a silent
    // hash-identifier. These all match dart-sass byte-for-byte.

    // Valid 3/4/6/8-digit forms (digit- and letter-start alike).
    assert_eq!(css("a{color:#000}"), "a {\n  color: #000;\n}\n");
    assert_eq!(css("a{color:#abc}"), "a {\n  color: #abc;\n}\n");
    assert_eq!(css("a{color:#000000}"), "a {\n  color: #000000;\n}\n");
    assert_eq!(css("a{color:#abcd12}"), "a {\n  color: #abcd12;\n}\n");
    assert_eq!(css("a{color:#0000}"), "a {\n  color: rgba(0, 0, 0, 0);\n}\n");
    assert_eq!(css("a{color:#00000000}"), "a {\n  color: rgba(0, 0, 0, 0);\n}\n");

    // A digit-start run of an invalid length (or a non-hex char before a valid
    // length) is "Expected hex digit." — sasso used to accept these verbatim.
    for bad in [
        "a{color:#0}",
        "a{color:#00}",
        "a{color:#00000}",
        "a{color:#0000000}",
        "a{color:#0g}",
        "a{color:#00g}",
        "a{color:#12g}",
    ] {
        let err = compile(bad, &Options::default()).unwrap_err();
        assert!(
            err.message.contains("Expected hex digit"),
            "{bad} should error, got {}",
            err.message
        );
    }

    // A valid digit-start color followed by a name char keeps the color and
    // leaves the rest as a trailing token (`#000g` -> `#000` + `g`).
    assert_eq!(css("a{color:#000g}"), "a {\n  color: #000 g;\n}\n");
    assert_eq!(css("a{color:#000000g}"), "a {\n  color: #000000 g;\n}\n");

    // A name-start `#` that isn't a whole valid hex is a `#…` identifier string.
    assert_eq!(css("a{color:#abcde}"), "a {\n  color: #abcde;\n}\n");
    assert_eq!(css("a{color:#abcg}"), "a {\n  color: #abcg;\n}\n");
    assert_eq!(css("a{color:#xyz}"), "a {\n  color: #xyz;\n}\n");
}

#[test]
fn rejects_lenient_parser_forms_like_dart() {
    let err = |src: &str| compile(src, &Options::default()).unwrap_err().message;

    // Duplicate @mixin/@function parameter (dart treats `-`/`_` as identical).
    assert_eq!(
        err("@mixin m($a,$a){x:$a}a{@include m(1,2)}"),
        "Duplicate parameter."
    );
    assert_eq!(
        err("@function f($a,$a){@return $a}a{x:f(1,2)}"),
        "Duplicate parameter."
    );
    assert_eq!(
        err("@mixin m($a-b,$a_b){x:$a-b}c{@include m(1,2)}"),
        "Duplicate parameter."
    );
    assert!(compile("@mixin ok($a,$b){x:$a}a{@include ok(1,2)}", &Options::default()).is_ok());

    // A committed exponent (`e` then a sign or digit) requires a digit.
    for bad in ["a{b:1e-}", "a{b:1e-x}", "a{b:1e++5}", "a{b:1e--5}"] {
        assert_eq!(err(bad), "Expected digit.", "{bad}");
    }
    assert_eq!(css("a{b:1e5}"), "a {\n  b: 100000;\n}\n");
    assert_eq!(css("a{b:1e+2}"), "a {\n  b: 100;\n}\n");
    assert_eq!(css("a{b:1em}"), "a {\n  b: 1em;\n}\n"); // `e` + letter is a unit

    // A module namespace must be a real identifier (not digit-leading).
    assert_eq!(err("@use \"sass:math\" as 0;a{b:1}"), "Expected identifier.");
    assert_eq!(err("@forward \"sass:math\" as 9-*;"), "Expected identifier.");
}

#[test]
fn rgb_hsl_argument_validation_matches_dart() {
    let err = |src: &str| compile(src, &Options::default()).unwrap_err().message;

    // Each rgb channel must be unitless or `%` (dart names the offending param).
    assert_eq!(
        err("a{b:rgb(1px,2,3)}"),
        "$red: Expected 1px to have unit \"%\" or no units."
    );
    assert_eq!(
        err("a{b:rgb(2,1px,3)}"),
        "$green: Expected 1px to have unit \"%\" or no units."
    );
    assert_eq!(
        err("a{b:rgb(1,2,3px)}"),
        "$blue: Expected 3px to have unit \"%\" or no units."
    );

    // A 2-arg comma call is the legacy `rgb($color, $alpha)` — $color must be a
    // color, so a space-list (modern channels shape) is rejected.
    assert_eq!(err("a{color:rgb(1 2 3, 0.5)}"), "$color: (1 2 3) is not a color.");
    // Parenthesized by the LIST, not by its length: a one-element space list
    // is `(1)` too, so the separator can never be read as the sentence's own
    // punctuation. See `a_value_embedded_in_a_message_is_parenthesized`.
    assert_eq!(
        err("@use \"sass:list\";a{color:rgb(list.append((), 1), 0.5)}"),
        "$color: (1) is not a color."
    );
    assert_eq!(err("a{color:hsl(1 2% 3%, 0.5)}"), "Missing argument $lightness.");

    // Valid forms still compile (legacy, modern space-list, slash-alpha, var()).
    for ok in [
        "a{color:rgb(255 0 0)}",
        "a{color:rgb(1,2,3)}",
        "a{color:rgb(1 2 3 / 0.5)}",
        "a{color:hsl(120, 50%, 40%)}",
        "a{color:rgb(1, var(--foo))}",
    ] {
        assert!(compile(ok, &Options::default()).is_ok(), "{ok}");
    }
}

#[test]
fn unknown_channel_errors_render_the_color_with_inspect() {
    let err = |src: &str| compile(src, &Options::default()).unwrap_err().message;
    let call = |src: &str| format!("@use \"sass:color\";a{{b:{src}}}");

    // dart builds these messages by interpolating the color into a string,
    // which routes through `Value.toString()` => `serializeValue(inspect: true)`
    // (lib/src/value.dart:439). So the color renders with INSPECT semantics, not
    // CSS-output semantics: `hwb(...)` keeps its own form instead of collapsing
    // to the `hsl(...)` it would be written as in a declaration.
    // All expectations below were produced by running dart-sass 1.101.6.
    assert_eq!(
        err(&call("color.is-missing(hwb(200 20% 30%), \"red\")")),
        "$channel: Color hwb(200 20% 30%) doesn't have a channel named \"red\"."
    );
    assert_eq!(
        err(&call("color.is-powerless(hwb(200 20% 30%), \"red\")")),
        "$channel: Color hwb(200 20% 30%) doesn't have a channel named \"red\"."
    );
    // `color.channel()` words its message differently (unquoted channel, "has no
    // channel named"), but renders the color the same way.
    assert_eq!(
        err(&call("color.channel(hwb(200 20% 30% / 0.5), \"zzz\")")),
        "$channel: Color hwb(200 20% 30% / 0.5) has no channel named zzz."
    );

    // A non-legacy space is unaffected by the reroute but must keep its own
    // canonical inspect form (percent lightness, `deg` hue).
    assert_eq!(
        err(&call("color.is-missing(oklch(0.5 0.1 200), \"red\")")),
        "$channel: Color oklch(50% 0.1 200deg) doesn't have a channel named \"red\"."
    );

    // A plain legacy sRGB color serializes identically under both renderers,
    // including its authored hex spelling.
    assert_eq!(
        err(&call("color.is-missing(#336699, \"zzz\")")),
        "$channel: Color #336699 doesn't have a channel named \"zzz\"."
    );
}

#[test]
fn static_placement_and_serialization_match_dart() {
    let err = |src: &str| compile(src, &Options::default()).unwrap_err().message;

    // @content only inside a @mixin declaration (caught even in dead branches).
    assert_eq!(
        err("@content;"),
        "@content is only allowed within mixin declarations."
    );
    assert_eq!(
        err("@if true{@content}"),
        "@content is only allowed within mixin declarations."
    );
    assert!(compile("@mixin m{@content}\na{@include m{x:y}}", &Options::default()).is_ok());

    // @function bodies forbid style rules / declarations / @extend statically.
    assert_eq!(
        err("@function f(){ @if false { a { color:red } } @return 1 } x{y:f()}"),
        "@function rules may not contain style rules."
    );
    assert_eq!(
        err("@function f(){ @if false { color: red } @return 1 } x{y:f()}"),
        "@function rules may not contain declarations."
    );

    // @extend must be lexically within a style rule (dead branches caught too).
    assert_eq!(
        err("@if false { @extend .foo; }"),
        "@extend may only be used within style rules."
    );
    assert!(compile("a{x:1}b{@extend a}", &Options::default()).is_ok());

    // A map or empty list is not a valid CSS value in any serialization context.
    assert_eq!(err("a{b: -(a:1)}"), "(a: 1) isn't a valid CSS value.");
    assert_eq!(err("a{b: #{(a:1)}}"), "(a: 1) isn't a valid CSS value.");
    assert_eq!(err("a{b: #{()}}"), "() isn't a valid CSS value.");
    assert_eq!(err("a{b: 1 + ()}"), "() isn't a valid CSS value.");
    assert_eq!(css("a{b: #{1 2 3}}"), "a {\n  b: 1 2 3;\n}\n"); // a non-empty list is fine
}

#[test]
fn selector_pseudo_grammar_matches_dart() {
    let err = |src: &str| compile(src, &Options::default()).unwrap_err().message;

    // Empty/garbage functional-pseudo and An+B arguments, and bare colon runs.
    assert_eq!(err("a:not(){x:y}"), "expected selector.");
    assert_eq!(err("a:nth-child(2n+3 foo){x:y}"), "Expected \"of\".");
    assert_eq!(err("a:::before{x:y}"), "Expected identifier.");
    for bad in [
        "a:nth-child(2n+){x:y}",
        "a:nth-child(of){x:y}",
        "a:nth-child(2x){x:y}",
    ] {
        assert!(compile(bad, &Options::default()).is_err(), "{bad}");
    }

    // Valid pseudos / An+B / interpolation / unknown-pseudo args still compile.
    for ok in [
        "a:nth-child(2n+1){x:y}",
        "a:nth-child(odd){x:y}",
        "a:nth-child(-n+3){x:y}",
        "a:nth-child(2n of .a){x:y}",
        "a:not(.a, .b){x:y}",
        "a:is(h1, h2){x:y}",
        "a:has(> .x){x:y}",
        "a::before{x:y}",
        "a:lang(en){x:y}",
        "$n: 3;\na:nth-child(#{$n}){x:y}",
        "a:nth-of-type(){x:y}", // dart accepts this; sasso no longer over-rejects
    ] {
        assert!(compile(ok, &Options::default()).is_ok(), "{ok}");
    }
}

#[test]
fn selector_bang_and_extend_leading_comma_match_dart() {
    let err = |src: &str| compile(src, &Options::default()).unwrap_err().message;

    // A top-level `!` is not valid in a selector — dart stops there and fails
    // to find the `{`. A `!` inside an attribute value or string is fine.
    assert_eq!(err("a !important {b:c}"), "expected \"{\".");
    assert_eq!(err("div !default {color:red}"), "expected \"{\".");
    assert!(compile("[data-x=\"a!b\"]{c:d}", &Options::default()).is_ok());
    assert_eq!(
        css("a{color:red !important}"),
        "a {\n  color: red !important;\n}\n"
    );

    // @extend rejects a leading empty component but allows a trailing comma.
    assert_eq!(err("a{x:1}.x{@extend ,a}"), "expected selector.");
    assert!(compile("a{x:1}.x{@extend a,}", &Options::default()).is_ok());
}

#[test]
fn at_charset_and_at_root_query_match_dart() {
    let err = |src: &str| compile(src, &Options::default()).unwrap_err().message;

    // @charset takes exactly one quoted string.
    assert_eq!(err("@charset utf-8;a{b:1}"), "Expected string.");
    assert_eq!(err("@charset;a{b:1}"), "Expected string.");
    assert!(compile("@charset \"utf-8\";a{b:1}", &Options::default()).is_ok());
    assert!(compile("@charset \"utf-8\" \"extra\";a{b:1}", &Options::default()).is_err());

    // @at-root (...) query grammar: with|without : <expr>.
    assert_eq!(
        err("@at-root (foo) {a{b:c}}"),
        "Expected \"with\" or \"without\"."
    );
    assert_eq!(err("@at-root (with) {a{b:c}}"), "expected \":\".");
    assert_eq!(err("@at-root (with:) {a{b:c}}"), "Expected expression.");
    assert_eq!(err("@at-root (with: rule) junk {a{b:c}}"), "expected \"{\".");
    for ok in [
        "@at-root (with: rule) {a{b:c}}",
        "@at-root (without: media) {a{b:c}}",
        "@at-root (with: a b) {a{b:c}}",
        "@at-root {a{b:c}}",
        "@at-root .x {a{b:c}}",
    ] {
        assert!(compile(ok, &Options::default()).is_ok(), "{ok}");
    }
}

#[test]
fn at_root_group_separation_matches_dart() {
    // dart-sass treats an @at-root-hoisted chunk as its own top-level group and
    // separates the RESUMED parent rule with one blank line (isGroupEnd), but
    // ONLY when the chunk ends in a style rule. Bare-@at-root siblings separate;
    // a nested-@at-root chain and a rule + its OWN bubbled @media stay
    // contiguous. Every expected string is byte-exact dart-sass 1.101.

    // Resume after a single @at-root rule -> one blank before the resumed rule.
    assert_eq!(
        css(".a {\n  x: 1;\n  @at-root .b {\n    y: 2;\n  }\n  z: 3;\n}\n"),
        ".a {\n  x: 1;\n}\n.b {\n  y: 2;\n}\n\n.a {\n  z: 3;\n}\n"
    );
    // Bare @at-root with multiple rules: blank between siblings AND before resume.
    assert_eq!(
        css(".a {\n  x: 1;\n  @at-root {\n    .b { y: 2; }\n    .c { w: 4; }\n  }\n  z: 3;\n}\n"),
        ".a {\n  x: 1;\n}\n.b {\n  y: 2;\n}\n\n.c {\n  w: 4;\n}\n\n.a {\n  z: 3;\n}\n"
    );
    // Nested @at-root chain stays contiguous: NO blank between .b and .c.
    assert_eq!(
        css(".a {\n  x: 1;\n  @at-root .b {\n    y: 2;\n    @at-root .c { w: 4; }\n  }\n  z: 3;\n}\n"),
        ".a {\n  x: 1;\n}\n.b {\n  y: 2;\n}\n.c {\n  w: 4;\n}\n\n.a {\n  z: 3;\n}\n"
    );
    // A rule + its OWN bubbled @media stays contiguous: NO blank between them.
    assert_eq!(
        css(".parent {\n  color: red;\n  @at-root .top {\n    color: green;\n    @media screen { color: blue; }\n  }\n}\n"),
        ".parent {\n  color: red;\n}\n.top {\n  color: green;\n}\n@media screen {\n  .top {\n    color: blue;\n  }\n}\n"
    );
    // No resume after the @at-root -> no trailing blank.
    assert_eq!(
        css(".a {\n  x: 1;\n  @at-root .b { y: 2; }\n}\n"),
        ".a {\n  x: 1;\n}\n.b {\n  y: 2;\n}\n"
    );
}

// --- scoped-arena escape safety (perf #5) ----------------------------------
//
// `compile` brackets its work in a bump-arena scope (when `ScopedAlloc` is the
// global allocator) and resets the arena on return. A caller's `Importer` runs
// inside that scope, so if it stashed the passed `&str` path or otherwise kept
// allocations made during the call, those would dangle after the reset. The
// evaluator therefore `pause()`s the arena around each importer callback so the
// importer's own allocations go to the system allocator and survive the compile.
//
// This integration test exercises that boundary: a caching importer copies every
// requested path into a `RefCell<Vec<String>>` *it owns* (a `path.to_string()`
// — an allocation made during the importer callback). After `compile` returns we
// assert those cached strings are still readable and correct. Under `ScopedAlloc`
// this proves they were NOT arena-allocated (an arena allocation would have been
// reclaimed by the post-compile reset); under the default allocator it is still a
// useful correctness regression guard for the pause/resume wiring.

use std::cell::RefCell;

/// An importer that caches every path it is asked to resolve, owning the cached
/// `String`s itself. Serves both `@import` and `@use`/`@forward`.
struct CachingImporter {
    files: HashMap<String, String>,
    /// Paths requested, copied into importer-owned storage during the callback.
    requested: RefCell<Vec<String>>,
}

impl Importer for CachingImporter {
    fn canonicalize(
        &self,
        url: &str,
        _ctx: &CanonicalizeContext<'_>,
    ) -> Result<Option<CanonicalUrl>, ImporterError> {
        // Record the request in importer-owned state. This allocation happens
        // *inside* the importer callback; the pause/resume boundary must keep it
        // on the system allocator so it outlives the compile's arena reset.
        self.requested.borrow_mut().push(url.to_string());
        Ok(self.files.contains_key(url).then(|| CanonicalUrl::new(url)))
    }

    fn load(&self, canonical: &CanonicalUrl) -> Result<Option<ImporterResult>, ImporterError> {
        Ok(self.files.get(canonical.as_str()).map(|src| ImporterResult {
            contents: src.clone(),
            syntax: Syntax::Scss,
            source_map_url: None,
        }))
    }
}

#[test]
fn importer_cached_strings_survive_compile_reset() {
    let mut files = HashMap::new();
    files.insert(
        "partial".to_string(),
        "$pad: 8px;\nbody { padding: $pad; }".to_string(),
    );
    files.insert("mod".to_string(), "$gap: 4px;".to_string());
    let importer = CachingImporter {
        files,
        requested: RefCell::new(Vec::new()),
    };

    // Drive both importer entry points: `@use` -> resolve_module_with_syntax,
    // `@import` -> resolve_with_syntax.
    let out = compile(
        "@use \"mod\";\n@import \"partial\";\n.a { margin: mod.$gap; }",
        &Options::default().with_importer(&importer),
    )
    .expect("compile should succeed");

    assert_eq!(out, "body {\n  padding: 8px;\n}\n\n.a {\n  margin: 4px;\n}");

    // After the compile returns (and, under ScopedAlloc, the arena has been
    // reset) the importer-owned cache must still be intact and correct. If the
    // `path.to_string()` allocations had landed in the arena, this would read
    // freed/reused memory.
    let requested = importer.requested.borrow();
    assert!(
        requested.iter().any(|p| p == "mod"),
        "expected `mod` to have been requested; got {requested:?}"
    );
    assert!(
        requested.iter().any(|p| p == "partial"),
        "expected `partial` to have been requested; got {requested:?}"
    );
    // Every cached string is still valid UTF-8 with its original content.
    for p in requested.iter() {
        assert!(!p.is_empty());
        assert!(p == "mod" || p == "partial", "unexpected cached path {p:?}");
    }
}

#[test]
fn default_assignment_does_not_eval_rhs_when_already_set() {
    // A guarded (`!default`) declaration whose target already holds a non-null
    // value must NOT evaluate its right-hand side. dart-sass short-circuits
    // before evaluation, so an otherwise-erroring expression is fine here.
    // This mirrors Bootstrap's `$form-check-padding-start: $w + .5em !default`
    // after a Shopware-style override sets `$w: 1rem` and the var to `1.5rem`,
    // where `1rem + .5em` would be an "incompatible units" error if evaluated.
    let out = css(concat!(
        "$w: 1rem !default;\n",
        "$p: 1.5rem !default;\n",
        "$w: 1em !default;\n",
        "$p: $w + .5em !default;\n",
        ".a { width: $w; padding: $p; }\n",
    ));
    assert_eq!(out, ".a {\n  width: 1rem;\n  padding: 1.5rem;\n}\n");
}

#[test]
fn rgba_hsla_special_value_passthrough_keeps_name() {
    // When an rgb()/hsl() call can't resolve to a concrete color because a
    // channel is a CSS `var()`, dart-sass preserves the call AND the exact
    // function name the caller wrote. We previously normalized `rgba`/`hsla`
    // down to `rgb`/`hsl`. (Bootstrap relies on `rgba(var(--x), …)`.)
    assert_eq!(
        css(".a { color: rgba(var(--bs-body-color-rgb), 0.65); }\n"),
        ".a {\n  color: rgba(var(--bs-body-color-rgb), 0.65);\n}\n"
    );
    assert_eq!(
        css(".a { color: hsla(var(--h), 50%, 50%, 0.5); }\n"),
        ".a {\n  color: hsla(var(--h), 50%, 50%, 0.5);\n}\n"
    );
    // A genuine `rgb()`/`hsl()` call keeps its name too (unchanged behavior).
    assert_eq!(
        css(".a { color: rgb(var(--y), 0.5); }\n"),
        ".a {\n  color: rgb(var(--y), 0.5);\n}\n"
    );
    // A `none`-only call normalizes to the canonical space name, not the alias.
    assert_eq!(
        css(".a { color: rgba(none none none); }\n"),
        ".a {\n  color: rgb(none none none);\n}\n"
    );
}

#[test]
fn a_custom_property_value_reads_an_escape_as_one_token() {
    // dart-sass captures a custom-property value with
    // `_interpolatedDeclarationValue`, which consumes a `\` escape whole and
    // re-serializes it canonically (`escape(identifierStart: true)`). An
    // escaped delimiter is therefore literal text: it neither opens a bracket
    // nor a string, and it never terminates the declaration.
    assert_eq!(
        css(".a { --x: \\{; }\n.b { c: d; }\n"),
        ".a {\n  --x: \\{;\n}\n\n.b {\n  c: d;\n}\n"
    );
    assert_eq!(css(".a { --x: \\\"; }\n"), ".a {\n  --x: \\\";\n}\n");
    assert_eq!(css(".a { --x: a\\;b; }\n"), ".a {\n  --x: a\\;b;\n}\n");
    // Canonical re-serialization: a name-start char loses the escape, a digit
    // and a control character keep the hex form, `-` and `{` take the short
    // form, and an invalid code point becomes U+FFFD.
    assert_eq!(css(".a { --x: \\61 b; }\n"), ".a {\n  --x: ab;\n}\n");
    assert_eq!(css(".a { --x: \\7b; }\n"), ".a {\n  --x: \\{;\n}\n");
    assert_eq!(css(".a { --x: \\30 z; }\n"), ".a {\n  --x: \\30 z;\n}\n");
    assert_eq!(css(".a { --x: \\9 z; }\n"), ".a {\n  --x: \\9 z;\n}\n");
    assert_eq!(css(".a { --x: \\2d z; }\n"), ".a {\n  --x: \\-z;\n}\n");
    assert_eq!(
        css(".a { --x: \\d800 z; }\n"),
        "@charset \"UTF-8\";\n.a {\n  --x: \u{fffd}z;\n}\n"
    );
    // The same reader serves a `@supports` custom declaration and the body of
    // a plain-CSS custom `@function`.
    assert_eq!(
        css("@supports (--x: \\61 b) { a { b: c } }\n"),
        "@supports (--x: ab) {\n  a {\n    b: c;\n  }\n}\n"
    );
    assert_eq!(
        css("@function --f() { result: \\{; }\n"),
        "@function --f() {\n  result: \\{;\n}\n"
    );
}

#[test]
fn a_custom_property_value_matches_its_brackets() {
    // dart-sass matches each closer against the bracket it opened, so `(]` is
    // an error rather than a pair that cancels out; a closer with no opener
    // ends the value, and the declaration then wants its `;`.
    let err = |src: &str| {
        let e = compile(src, &Options::default()).expect_err("expected a compile error");
        (e.to_string(), e.line, e.col)
    };
    let (msg, line, col) = err(".a { --x: (] ; }\n");
    assert!(msg.contains("expected \")\"."), "{msg}");
    assert_eq!((line, col), (1, 12));
    let (msg, line, col) = err(".a { --x: ]; }\n");
    assert!(msg.contains("expected \";\"."), "{msg}");
    assert_eq!((line, col), (1, 11));
    // An escape after the backslash is required, as in an identifier.
    let (msg, line, col) = err(".a { --x: a\\\n b; }\n");
    assert!(msg.contains("Expected escape sequence."), "{msg}");
    assert_eq!((line, col), (1, 13));
}

#[test]
fn a_plain_css_custom_at_rule_body_matches_its_brackets() {
    // The body of a plain-CSS custom `@function`/`@mixin` captures each value
    // the way a custom property does, so a mismatched closer is an error, an
    // unclosed opener names the bracket it wanted, and a closer with no opener
    // ends the value (the body then wants its `;`).
    let err = |src: &str| {
        let e = compile(src, &Options::default()).expect_err("expected a compile error");
        (e.to_string(), e.line, e.col)
    };
    let (msg, line, col) = err("@function --f() { result: (]; }\n");
    assert!(msg.contains("expected \")\"."), "{msg}");
    assert_eq!((line, col), (1, 28));
    let (msg, line, col) = err("@function --f() { result: (; }\n");
    assert!(msg.contains("expected \")\"."), "{msg}");
    assert_eq!((line, col), (1, 30));
    let (msg, line, col) = err("@function --f() { result: ]; }\n");
    assert!(msg.contains("expected \";\"."), "{msg}");
    assert_eq!((line, col), (1, 27));
    // A balanced value still captures whole, `;` and all.
    assert_eq!(
        css("@function --f() { result: (a; b); other: c; }\n"),
        "@function --f() {\n  result: (a; b);\n  other: c;\n}\n"
    );
}

#[test]
fn an_import_url_token_drops_its_padding_and_decodes_escapes() {
    // dart reads `url(…)` in an `@import` with `_tryUrlContents`: the
    // whitespace after the `(` and before the `)` is not part of the token,
    // and a `\` escape is consumed whole and written back canonically
    // (`escape()`, so a name character loses its backslash). The value reader
    // already did both; the import reader kept the text verbatim.
    assert_eq!(css("@import url(  x.css  );\n"), "@import url(x.css);\n");
    assert_eq!(
        css("@import url(\n  http://x/y.css\n);\n"),
        "@import url(http://x/y.css);\n"
    );
    assert_eq!(css("@import url(\\61 b.css);\n"), "@import url(ab.css);\n");
    assert_eq!(css("@import url(\\2d x.css);\n"), "@import url(-x.css);\n");
    assert_eq!(css("@import url(\\30 x.css);\n"), "@import url(0x.css);\n");
    // A control character keeps its hex form, and an escaped space keeps its
    // backslash — neither is a name character.
    assert_eq!(css("@import url(\\9 x.css);\n"), "@import url(\\9 x.css);\n");
    assert_eq!(css("@import url(\\ x.css);\n"), "@import url(\\ x.css);\n");
    // An escaped paren is still url content, and a quoted url keeps its
    // padding (it is a string, not a url token).
    assert_eq!(
        css("@import url(foo\\)bar.css);\n"),
        "@import url(foo\\)bar.css);\n"
    );
    assert_eq!(
        css("@import url(\"  x.css  \");\n"),
        "@import url(\"  x.css  \");\n"
    );
    // Several imports on one line keep their own padding rules.
    assert_eq!(
        css("@import url(x.css ), url(y.css);\n"),
        "@import url(x.css);\n@import url(y.css);\n"
    );
}

#[test]
fn a_backslash_before_a_newline_is_only_an_escape_inside_a_string() {
    // dart's `escape()` fails on a newline, so a backslash "line continuation"
    // is an error everywhere a CSS escape may appear — a value, a selector, a
    // property name, an at-rule prelude. Only the string reader drops the pair
    // first, which is what makes it legal inside quotes.
    let err = |src: &str| {
        let e = compile(src, &Options::default()).expect_err("expected a compile error");
        (e.to_string(), e.line, e.col)
    };
    for (src, line, col) in [
        (".a { b: c\\\n  d; }\n", 1, 11),
        (".a,\\\n.b { c: d; }\n", 1, 5),
        (".a { b\\\nc: d; }\n", 1, 8),
        ("@media screen\\\nand (min-width: 0) { .a { b: c } }\n", 1, 15),
        (".a { b: url(foo\\\nbar.css); }\n", 1, 17),
    ] {
        let (msg, l, c) = err(src);
        assert!(msg.contains("Expected escape sequence."), "{src:?}: {msg}");
        assert_eq!((l, c), (line, col), "for {src:?}");
    }
    // Inside a quoted string the pair IS a line continuation: it vanishes, and
    // the next line's indentation stays content.
    assert_eq!(css(".a { b: \"x\\\ny\"; }\n"), ".a {\n  b: \"xy\";\n}\n");
    assert_eq!(css("[a=\"x\\\ny\"] { c: d; }\n"), "[a=xy] {\n  c: d;\n}\n");
    assert_eq!(
        css("@media (min-width: 0) and (x: \"a\\\nb\") { .a { b: c } }\n"),
        "@media (min-width: 0) and (x: ab) {\n  .a {\n    b: c;\n  }\n}\n"
    );
}

#[test]
fn an_import_url_that_is_not_a_url_token_is_a_function_call() {
    // dart `dynamicUrl`: when `url(…)` does not read as a plain url token, the
    // call is an ordinary function whose arguments EVALUATE. sasso emitted the
    // SassScript verbatim, so a variable reached the CSS.
    assert_eq!(css("@import url(foo + bar);\n"), "@import url(foobar);\n");
    assert_eq!(
        css("$v: x;\n@import url($v + \".css\");\n"),
        "@import url(x.css);\n"
    );
    // A quoted argument is a function call too, so it keeps its own text.
    assert_eq!(
        css("@import url(\"  x.css  \");\n"),
        "@import url(\"  x.css  \");\n"
    );
    // Interpolation inside that string still resolves.
    assert_eq!(
        css("$p: http;\n@import url(\"#{$p}://x/y.css\");\n"),
        "@import url(\"http://x/y.css\");\n"
    );
    // A plain url token still takes the token path (no evaluation, padding
    // dropped, escapes decoded).
    assert_eq!(css("@import url(  x.css  );\n"), "@import url(x.css);\n");
}

#[test]
fn interpolation_resolves_inside_a_quoted_verbatim_value() {
    // A verbatim value's TEXT is copied, but `#{…}` is not part of that text —
    // dart resolves it inside a quoted string as well as outside one. The
    // custom-property reader already did; the `@supports` and plain-CSS custom
    // callable readers copied the string whole.
    assert_eq!(
        css("$v: x;\n@supports (--a: \"#{$v}\") { .a { b: c } }\n"),
        "@supports (--a: \"x\") {\n  .a {\n    b: c;\n  }\n}\n"
    );
    assert_eq!(
        css("$v: x;\n@function --f() { result: \"#{$v}\"; }\n"),
        "@function --f() {\n  result: \"x\";\n}\n"
    );
    assert_eq!(
        css("$v: x;\n.a { --x: \"#{$v}\"; }\n"),
        ".a {\n  --x: \"x\";\n}\n"
    );
    // The string's own escapes stay verbatim, line continuation included — a
    // verbatim value is not re-serialized the way a SassScript string is.
    assert_eq!(
        css(".a { --x: \"a\\\nb\"; }\n"),
        ".a {\n  --x: \"a\\\n  b\";\n}\n"
    );
    assert_eq!(
        css("@supports (--a: \"x\\\ny\") { .a { b: c } }\n"),
        "@supports (--a: \"x\\ y\") {\n  .a {\n    b: c;\n  }\n}\n"
    );
}
/// A plain-CSS custom `@function`'s declaration takes dart's OPTIONAL space
/// after the colon when its value is SassScript — the one byte a minifier
/// exists to drop — while a VERBATIM value keeps whatever the source wrote, in
/// both styles. Measured against dart-sass 1.104.1 on 2026-09-21.
#[test]
fn a_custom_functions_script_value_takes_the_optional_space() {
    let both = |scss: &str, expanded: &str, compressed: &str| {
        assert_eq!(css(scss), format!("{expanded}\n"), "{scss}");
        assert_eq!(css_compressed(scss), compressed, "{scss}");
    };
    // An interpolated property makes the value SassScript.
    both(
        "@function --a() { #{result}: 1 + 1; }\n",
        "@function --a() {\n  result: 2;\n}",
        "@function --a(){result:2}",
    );
    both(
        "@function --a() { #{result}: { b: c; } }\n",
        "@function --a() {\n  result-b: c;\n}",
        "@function --a(){result-b:c}",
    );
    // A verbatim value is source text: the space after its colon is not dart's
    // to drop.
    both(
        "@function --a() { result: 1 + 1; }\n",
        "@function --a() {\n  result: 1 + 1;\n}",
        "@function --a(){result: 1 + 1}",
    );
}

#[test]
fn a_form_feed_is_a_newline_to_the_escape_reader() {
    // dart's `isNewline` counts U+000C, so a backslash cannot escape it — in a
    // verbatim value as in an ordinary one.
    let err = |src: &str| {
        let e = compile(src, &Options::default()).expect_err("expected a compile error");
        (e.to_string(), e.line, e.col)
    };
    let (msg, line, col) = err(".a { --x: c\\\u{c}d; }\n");
    assert!(msg.contains("Expected escape sequence."), "{msg}");
    assert_eq!((line, col), (1, 13));
    let (msg, _, _) = err(".a { b: c\\\u{c}d; }\n");
    assert!(msg.contains("Expected escape sequence."), "{msg}");
    // Inside a string it is a line continuation, and the pair vanishes.
    assert_eq!(css(".a { b: \"c\\\u{c}d\"; }\n"), ".a {\n  b: \"cd\";\n}\n");
}

#[test]
fn a_hex_escape_terminator_is_one_line_break() {
    // One whitespace character terminates a hex escape. dart takes a CRLF
    // whole where the text is captured VERBATIM — `--x: \61` + CRLF + `b` is
    // `ab`, with no line break left in the value — and only the `\r` where the
    // text is parsed as SassScript, so the `\n` still separates two
    // identifiers.
    assert_eq!(css(".a { --x: \\61\r\nb; }\n"), ".a {\n  --x: ab;\n}\n");
    assert_eq!(css(".a { b: \\61\r\nb; }\n"), ".a {\n  b: a b;\n}\n");
    // A lone LF or CR terminates the escape in both.
    assert_eq!(css(".a { --x: \\61\nb; }\n"), ".a {\n  --x: ab;\n}\n");
    assert_eq!(css(".a { --x: \\61\rb; }\n"), ".a {\n  --x: ab;\n}\n");
    assert_eq!(css(".a { b: \\61\nb; }\n"), ".a {\n  b: ab;\n}\n");
    assert_eq!(css(".a { b: \\61\rb; }\n"), ".a {\n  b: ab;\n}\n");
}

#[test]
fn a_quoted_string_is_serialized_with_the_quote_it_needs() {
    // dart `_visitQuotedString`: single quotes when the text contains a `"`
    // and no `'`, and the chosen quote and every backslash escaped. `inspect`
    // wrapped the text in `"` unconditionally, so a string containing a quote
    // or a backslash came out as INVALID CSS (`b: "a"b";`).
    assert_eq!(
        css("@use \"sass:meta\";\n.a { b: meta.inspect(\"a\\\"b\"); }\n"),
        ".a {\n  b: 'a\"b';\n}\n"
    );
    assert_eq!(
        css("@use \"sass:meta\";\n.a { b: meta.inspect(\"a\\\\b\"); }\n"),
        ".a {\n  b: \"a\\\\b\";\n}\n"
    );
    assert_eq!(
        css("@use \"sass:meta\";\n.a { b: meta.inspect(\"it \\\"broke\\\"\"); }\n"),
        ".a {\n  b: 'it \"broke\"';\n}\n"
    );
    // Inside a collection, and for a string that needs both quote kinds.
    assert_eq!(
        css("@use \"sass:meta\";\n.a { b: meta.inspect((x: \"a\\\"b\")); }\n"),
        ".a {\n  b: (x: 'a\"b');\n}\n"
    );
    // `@error` renders its value through the same serializer.
    let e = compile("@error \"a\\\"b\";\n", &Options::default()).expect_err("an @error");
    assert!(e.to_string().contains("'a\"b'"), "{e}");
    let e = compile("@error 'it \"broke\"';\n", &Options::default()).expect_err("an @error");
    assert!(e.to_string().contains("'it \"broke\"'"), "{e}");
}

#[test]
fn an_unquoted_import_url_written_back_is_quoted_like_a_string() {
    // The indented syntax writes a plain-CSS import's bare url back QUOTED.
    // The url is text, so its backslashes are escaped and a url containing a
    // `"` takes single quotes — dart serializes it as any other string.
    let sass = |src: &str| compile(src, &Options::default().with_syntax(Syntax::Sass)).expect("compile");
    assert_eq!(
        sass("@import h\\74 tps://x/y.css\n"),
        "@import \"h\\\\74 tps://x/y.css\";"
    );
    assert_eq!(sass("@import foo\\\"bar.css\n"), "@import 'foo\\\\\"bar.css';");
    assert_eq!(sass("@import \\\\x.css\n"), "@import \"\\\\\\\\x.css\";");
    // A url with neither stays as it was.
    assert_eq!(sass("@import foo.css\n"), "@import \"foo.css\";");
}

#[test]
fn a_builtin_answers_to_its_underscore_spelling() {
    // `_` and `-` are one character in a Sass identifier, so a global built-in
    // is reached either way — as it already is for user members and module
    // members. Measured against dart-sass 1.103.1.
    assert_eq!(css("a { b: str_index(\"abc\", \"b\"); }"), "a {\n  b: 2;\n}\n");
    assert_eq!(css("a { b: to_upper_case(\"abc\"); }"), "a {\n  b: \"ABC\";\n}\n");
    assert_eq!(css("a { b: type_of(1); }"), "a {\n  b: number;\n}\n");
    assert_eq!(css("a { b: map_get((x: 1), x); }"), "a {\n  b: 1;\n}\n");
    // The stateful `sass:meta` members resolve the same way, globally and
    // through the module.
    assert_eq!(
        css("$x: 1; a { b: variable_exists(\"x\"); }"),
        "a {\n  b: true;\n}\n"
    );
    assert_eq!(
        css("@use \"sass:meta\"; a { b: meta.function_exists(\"rgb\"); }"),
        "a {\n  b: true;\n}\n"
    );
    // A name that is no built-in keeps the spelling it was written with: it is
    // a plain CSS function, not a Sass one.
    assert_eq!(css("a { b: my_own_fn(1); }"), "a {\n  b: my_own_fn(1);\n}\n");
    // A reference is stored canonically, as dart stores it.
    assert_eq!(
        css("@use \"sass:meta\"; a { b: meta.inspect(meta.get-function(\"map_get\")); }"),
        "a {\n  b: get-function(\"map-get\");\n}\n"
    );
}

#[test]
fn a_module_member_reference_is_not_its_global_alias() {
    // `meta.get-function($module:)` yields the MODULE's function: dart keeps
    // the member's own name, does not compare it equal to the global alias,
    // and dispatches it through the module. Measured against dart-sass 1.103.1.
    assert_eq!(
        css("@use \"sass:meta\"; @use \"sass:map\";\na { b: meta.inspect(meta.get-function(\"get\", $module: \"map\")); }"),
        "a {\n  b: get-function(\"get\");\n}\n"
    );
    assert_eq!(
        css("@use \"sass:meta\"; @use \"sass:map\";\na { b: meta.get-function(\"get\", $module: \"map\") == meta.get-function(\"map-get\"); }"),
        "a {\n  b: false;\n}\n"
    );
    assert_eq!(
        css("@use \"sass:meta\"; @use \"sass:map\";\na { b: meta.call(meta.get-function(\"get\", $module: \"map\"), (x: 1), x); }"),
        "a {\n  b: 1;\n}\n"
    );
    // `color.scale` is not the global `scale-color`, so the reference has to
    // carry the module to reach the right function at all.
    assert_eq!(
        css("@use \"sass:meta\"; @use \"sass:color\";\na { b: meta.inspect(meta.get-function(\"scale\", $module: \"color\")); }"),
        "a {\n  b: get-function(\"scale\");\n}\n"
    );
    assert_eq!(
        css("@use \"sass:meta\"; @use \"sass:color\";\na { b: meta.call(meta.get-function(\"scale\", $module: \"color\"), #abcdef, $lightness: 50%); }"),
        "a {\n  b: #d5e6f7;\n}\n"
    );
    // A member a `@use "sass:…" as *` exposes unprefixed is that module's too.
    assert_eq!(
        css(
            "@use \"sass:map\" as *; @use \"sass:meta\";\na { b: meta.inspect(meta.get-function(\"get\")); }"
        ),
        "a {\n  b: get-function(\"get\");\n}\n"
    );
}

#[test]
fn every_global_is_referenceable_by_name() {
    // The `sass:meta` predicates that resolve against evaluator state are
    // globals like any other: `get-function` finds them, and invoking the
    // reference runs them. Measured against dart-sass 1.103.1.
    assert_eq!(
        css(
            "$x: 1;\n@use \"sass:meta\";\na { b: meta.call(meta.get-function(\"variable-exists\"), \"x\"); }"
        ),
        "a {\n  b: true;\n}\n"
    );
    assert_eq!(
        css("@use \"sass:meta\";\na { b: meta.call(meta.get-function(\"call\"), meta.get-function(\"rgb\"), 1, 2, 3); }"),
        "a {\n  b: rgb(1, 2, 3);\n}\n"
    );
    for name in ["keywords", "content-exists", "get-function", "mixin-exists"] {
        assert_eq!(
            css(&format!(
                "@use \"sass:meta\";\na {{ b: meta.inspect(meta.get-function(\"{name}\")); }}"
            )),
            format!("a {{\n  b: get-function(\"{name}\");\n}}\n")
        );
    }
    // A name that is no function at all is reported as the string it was asked
    // for, quoting and all.
    let err = compile(
        "@use \"sass:meta\"; a { b: meta.get-function(\"a\\\"b\"); }",
        &Options::default(),
    )
    .unwrap_err()
    .to_string();
    assert!(err.contains("Function not found: 'a\"b'"), "{err}");
}

#[test]
fn a_starred_builtin_member_shadows_the_global_of_that_name() {
    // `@use "sass:…" as *` exposes the module's members unprefixed, and they
    // WIN over the global of the same name: `index` is `string.index` after
    // `@use "sass:string" as *`, not the list one. Measured against dart-sass
    // 1.103.1.
    assert_eq!(
        css("@use \"sass:string\" as *; a { b: index(\"abc\", \"b\"); }"),
        "a {\n  b: 2;\n}\n"
    );
    assert_eq!(
        css("@use \"sass:list\" as *; a { b: index(\"abc\" \"b\", \"b\"); }"),
        "a {\n  b: 2;\n}\n"
    );
    assert!(compile(
        "@use \"sass:string\" as *; a { b: index(\"abc\" \"b\", \"b\"); }",
        &Options::default()
    )
    .unwrap_err()
    .to_string()
    .contains("is not a string."));
    // Exposure from two starred modules is ambiguous, however it is reached.
    for src in [
        "@use \"sass:list\" as *; @use \"sass:string\" as *; a { b: index(\"abc\", \"b\"); }",
        "@use \"sass:list\" as *; @use \"sass:string\" as *; @use \"sass:meta\";\na { b: meta.get-function(\"index\"); }",
        "@use \"sass:list\" as *; @use \"sass:string\" as *; @use \"sass:meta\";\na { b: meta.function-exists(\"index\"); }",
    ] {
        let err = compile(src, &Options::default()).unwrap_err().to_string();
        assert!(
            err.contains("This function is available from multiple global modules."),
            "{src}: {err}"
        );
    }
    // A module that does not have the member leaves the global alone.
    assert_eq!(
        css("@use \"sass:map\" as *; @use \"sass:meta\";\na { b: meta.function-exists(\"get\"); }"),
        "a {\n  b: true;\n}\n"
    );
}

#[test]
fn a_reference_invoked_by_name_is_looked_up_canonically() {
    // `call("string")` never goes through `get-function`, so the name arrives
    // exactly as written — and `_` is `-` in a Sass identifier, including for
    // the `sass:meta` members the evaluator owns. Measured against dart-sass
    // 1.103.1.
    assert_eq!(
        css("$x: 1; a { b: call(\"variable_exists\", \"x\"); }"),
        "a {\n  b: true;\n}\n"
    );
    assert_eq!(
        css("a { b: call(\"str_index\", \"abc\", \"b\"); }"),
        "a {\n  b: 2;\n}\n"
    );
    assert_eq!(
        css("@use \"sass:meta\"; $x: 1; a { b: meta.call(\"variable_exists\", \"x\"); }"),
        "a {\n  b: true;\n}\n"
    );
    // A starred module's member is still stored canonically.
    assert_eq!(
        css("@use \"sass:string\" as *; @use \"sass:meta\";\na { b: meta.inspect(meta.get-function(\"to_upper_case\")); }"),
        "a {\n  b: get-function(\"to-upper-case\");\n}\n"
    );
}

/// The message of a compile error that must happen, under the default options.
fn compile_err(src: &str) -> String {
    err_message(compile(src, &Options::default()).expect_err("expected a compile error"))
}

/// A compile error's MESSAGE. The library's `Display` appends the
/// ` (line:column)` the CLI draws as a snippet instead; it is dropped here so a
/// multi-line message can be compared whole (the spans themselves are pinned
/// byte-for-byte by `tests/diagnostics.rs`).
fn err_message(err: impl std::fmt::Display) -> String {
    let rendered = err.to_string();
    let Some(open) = rendered.rfind(" (") else {
        return rendered;
    };
    let tail = &rendered[open + 2..];
    let is_position = tail.ends_with(')')
        && tail[..tail.len() - 1].split_once(':').is_some_and(|(l, c)| {
            !l.is_empty() && !c.is_empty() && l.bytes().chain(c.bytes()).all(|b| b.is_ascii_digit())
        });
    if is_position {
        rendered[..open].to_string()
    } else {
        rendered
    }
}

#[test]
fn a_value_embedded_in_a_message_is_parenthesized() {
    // dart's `Value.toString()` — the spelling a diagnostic gives a value it
    // embeds whole — is `inspect()` plus one rule: an unbracketed, non-empty
    // list is wrapped in parentheses, so its separator is never read as the
    // sentence's own punctuation. `inspect()` already parenthesizes the
    // one-element comma and slash forms, which must not be wrapped twice; a
    // bracketed list carries its own delimiters; and the empty list is `()`
    // either way. Measured against dart-sass 1.104.1.
    let cases = [
        // the shape that used to differ per message: a one-element SPACE list
        ("@use \"sass:list\"; @error list.append((), 1);", "(1)"),
        ("@error (1,);", "(1,)"),
        ("@error (1 2);", "(1 2)"),
        ("@error (1, 2);", "(1, 2)"),
        ("@error [1];", "[1]"),
        ("@error [1 2];", "[1 2]"),
        ("@error ();", "()"),
        // a string keeps its quotes, as `inspect()` gives them
        ("@error \"q\";", "\"q\""),
        ("@error a;", "a"),
        ("@error (a: 1);", "(a: 1)"),
        ("@error null;", "null"),
    ];
    for (src, wanted) in cases {
        assert_eq!(compile_err(src), format!("Error: {wanted}"), "{src}");
    }
}

#[test]
fn a_removed_sass_color_member_recommends_color_adjust() {
    // dart REMOVED nine members from `sass:color`, but did not make them
    // unknown: each still exists as a member, and calling it reports a
    // three-part message naming the `color.adjust` that replaces it. The
    // channel and the sign are per member, and the `Recommendation:` line is
    // built from the call's OWN arguments (the global `[color-functions]`
    // deprecation prints a `$color` placeholder instead). Measured against
    // dart-sass 1.104.1.
    let members = [
        ("adjust-hue", "$hue: 10%"),
        ("darken", "$lightness: -10%"),
        ("desaturate", "$saturation: -10%"),
        ("fade-in", "$alpha: 10%"),
        ("fade-out", "$alpha: -10%"),
        ("lighten", "$lightness: 10%"),
        ("opacify", "$alpha: 10%"),
        ("saturate", "$saturation: 10%"),
        ("transparentize", "$alpha: -10%"),
    ];
    for (member, channel) in members {
        assert_eq!(
            compile_err(&format!(
                "@use \"sass:color\";\n.a {{ b: color.{member}(#abcdef, 10%); }}"
            )),
            format!(
                "Error: The function {member}() isn't in the sass:color module.\n\n\
                 Recommendation: color.adjust(#abcdef, {channel})\n\n\
                 More info: https://sass-lang.com/documentation/functions/color#{member}"
            )
        );
    }
}

#[test]
fn a_removed_sass_color_member_is_reached_by_every_dispatch_path() {
    // The members have to be real members, not a special case in one call
    // path: they answer to the `sass:meta` predicates, and — the visible half —
    // a `@use "sass:color" as *` binds them OVER the global of the same name,
    // so `saturate(…)` stops working where the global still warns and
    // succeeds. Measured against dart-sass 1.104.1.
    let wanted = "Error: The function lighten() isn't in the sass:color module.\n\n\
                  Recommendation: color.adjust(#abcdef, $lightness: 10%)\n\n\
                  More info: https://sass-lang.com/documentation/functions/color#lighten";
    for src in [
        // namespaced
        "@use \"sass:color\";\n.a { b: color.lighten(#abcdef, 10%); }",
        // named arguments, in either order
        "@use \"sass:color\";\n.a { b: color.lighten($amount: 10%, $color: #abcdef); }",
        // through the star import, where the member shadows the global
        "@use \"sass:color\" as *;\n.a { b: lighten(#abcdef, 10%); }",
        // and through a reference, which is what `meta.call` dispatches
        "@use \"sass:color\"; @use \"sass:meta\";\n\
         .a { b: meta.call(meta.get-function(\"lighten\", $module: \"color\"), #abcdef, 10%); }",
    ] {
        assert_eq!(compile_err(src), wanted, "{src}");
    }
    // A member is visible to the predicates before it is called, both under
    // its module and through the star, and its reference carries its own name.
    assert_eq!(
        css("@use \"sass:color\"; @use \"sass:meta\";\na { b: meta.function-exists(\"lighten\", $module: \"color\"); }"),
        "a {\n  b: true;\n}\n"
    );
    assert_eq!(
        css("@use \"sass:color\" as *; @use \"sass:meta\";\na { b: meta.function-exists(\"lighten\"); }"),
        "a {\n  b: true;\n}\n"
    );
    assert_eq!(
        css("@use \"sass:color\"; @use \"sass:meta\";\na { b: meta.inspect(meta.get-function(\"lighten\", $module: \"color\")); }"),
        "a {\n  b: get-function(\"lighten\");\n}\n"
    );
    // The GLOBAL spellings are untouched: they still compute a color (behind
    // the `global-builtin` and `color-functions` deprecations).
    assert_eq!(css("a { b: saturate(#abcdef, 10%); }"), "a {\n  b: #a6cdf4;\n}\n");
    // The same name under the star is the module member, so the call fails.
    assert!(
        compile_err("@use \"sass:color\" as *;\n.a { b: saturate(#abcdef, 10%); }")
            .starts_with("Error: The function saturate() isn't in the sass:color module.\n")
    );
}

#[test]
fn a_forwarded_removed_sass_color_member_keeps_its_own_name() {
    // A `@forward` re-exports the removed members like any other, and a prefix
    // renames the way one is CALLED without renaming what the message is
    // about: the member reached as `c-lighten` still reports `lighten()`.
    // Measured against dart-sass 1.104.1.
    let mut files = HashMap::new();
    files.insert("fwd".to_string(), "@forward \"sass:color\";".to_string());
    files.insert("pre".to_string(), "@forward \"sass:color\" as c-*;".to_string());
    files.insert(
        "shown".to_string(),
        "@forward \"sass:color\" show lighten;".to_string(),
    );
    let importer = MemImporter(files);
    let opts = Options::default().with_importer(&importer);
    for src in [
        "@use \"fwd\" as f;\n.a { b: f.lighten(#abcdef, 10%); }",
        "@use \"fwd\" as *;\n.a { b: lighten(#abcdef, 10%); }",
        "@use \"pre\" as f;\n.a { b: f.c-lighten(#abcdef, 10%); }",
        "@use \"shown\" as f;\n.a { b: f.lighten(#abcdef, 10%); }",
    ] {
        let err = err_message(compile(src, &opts).expect_err("a forwarded member must fail"));
        assert_eq!(
            err,
            "Error: The function lighten() isn't in the sass:color module.\n\n\
             Recommendation: color.adjust(#abcdef, $lightness: 10%)\n\n\
             More info: https://sass-lang.com/documentation/functions/color#lighten",
            "{src}"
        );
    }
    // A prefix renames a removed member like any other…
    let err = err_message(
        compile("@use \"pre\" as f;\n.a { b: f.c-darken(#abcdef, 10%); }", &opts)
            .expect_err("a prefixed member must fail"),
    );
    assert!(
        err.starts_with("Error: The function darken() isn't in the sass:color module.\n"),
        "{err}"
    );
    // …and `show` filters one out like any other, leaving it undefined.
    let err = err_message(
        compile("@use \"shown\" as f;\n.a { b: f.darken(#abcdef, 10%); }", &opts)
            .expect_err("a hidden member is undefined"),
    );
    assert_eq!(err, "Error: Undefined function.");
}

#[test]
fn a_removed_sass_color_member_checks_its_arity_before_it_reports() {
    // Arity comes first, so a call that could not have worked anyway is
    // reported as the wrong call it is — with the member's own parameter names,
    // which are `$color, $amount` for all nine. (The GLOBAL `adjust-hue` binds
    // `$degrees`; it is a different function and is not touched here.)
    // Measured against dart-sass 1.104.1.
    let cases = [
        ("color.lighten(#abcdef)", "Missing argument $amount."),
        ("color.adjust-hue(#abcdef)", "Missing argument $amount."),
        ("color.lighten()", "Missing argument $color."),
        ("color.lighten($amount: 10%)", "Missing argument $color."),
        (
            "color.lighten(#abcdef, 1, 2)",
            "Only 2 arguments allowed, but 3 were passed.",
        ),
        (
            "color.lighten(#abcdef, 1, 2, $x: 3)",
            "Only 2 positional arguments allowed, but 3 were passed.",
        ),
    ];
    for (call, wanted) in cases {
        assert_eq!(
            compile_err(&format!("@use \"sass:color\";\n.a {{ b: {call}; }}")),
            format!("Error: {wanted}"),
            "{call}"
        );
    }
}

#[test]
fn a_removed_sass_color_member_spells_its_arguments_as_a_diagnostic_does() {
    // Neither argument is VALIDATED — the recommendation is a suggestion, not
    // a call — and the amount is negated TEXTUALLY, without arithmetic and
    // without converting a unit the `color-functions` deprecation folds to
    // degrees. Both values are spelled the way a diagnostic spells a whole
    // value, so an unbracketed list is parenthesized. Measured against
    // dart-sass 1.104.1.
    let cases = [
        // a `-` written in front of what was there, not `10%` negated
        ("color.darken(#abcdef, -10%)", "#abcdef, $lightness: --10%"),
        // the evaluated value, though: `1 + 1` is `2` before the `-`
        ("color.darken(#abcdef, 1 + 1)", "#abcdef, $lightness: -2"),
        // no unit conversion: `0.5turn` stays `0.5turn`, never `180deg`
        ("color.adjust-hue(#abcdef, 0.5turn)", "#abcdef, $hue: 0.5turn"),
        // no type checking either, on either argument
        ("color.lighten(\"nope\", foo)", "\"nope\", $lightness: foo"),
        // and a list is parenthesized, including a one-element space list
        (
            "color.lighten(list.append((), 1), (1, 2))",
            "(1), $lightness: (1, 2)",
        ),
    ];
    for (call, wanted) in cases {
        let err = compile_err(&format!(
            "@use \"sass:color\"; @use \"sass:list\";\n.a {{ b: {call}; }}"
        ));
        assert!(
            err.contains(&format!("\nRecommendation: color.adjust({wanted})\n")),
            "{call}: {err}"
        );
    }
}

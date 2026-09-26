//! Plain-CSS files reached through `@use`/`@import` are emitted the way
//! dart-sass emits them: nothing of the file's own `@charset` survives (the
//! output's `@charset` is re-derived from its content), and nested rules keep
//! the selector list's source line structure.

use std::cell::RefCell;
use std::path::PathBuf;
use std::rc::Rc;

use sasso::{compile, FsImporter, Options, WarnEvent};

fn scratch(tag: &str) -> PathBuf {
    let dir = std::env::temp_dir().join(format!("sasso_plaincss_{tag}_{}", std::process::id()));
    std::fs::create_dir_all(&dir).expect("mkdir");
    dir
}

/// Compile `src` as an entry in `dir`, swallowing warnings (the `@import`
/// deprecation), and return the CSS.
fn compile_in(dir: &std::path::Path, name: &str, src: &str) -> String {
    let entry = dir.join(name);
    std::fs::write(&entry, src).unwrap();
    let url = entry.to_string_lossy().into_owned();
    let imp = FsImporter::new(Vec::new());
    let sink: Rc<RefCell<Vec<String>>> = Rc::new(RefCell::new(Vec::new()));
    let seen = Rc::clone(&sink);
    let opts = Options::default()
        .with_importer(&imp)
        .with_url(&url)
        .with_warn_handler(Rc::new(move |ev: &WarnEvent<'_>| {
            seen.borrow_mut().push(ev.message.to_string());
        }));
    compile(src, &opts).expect("compile")
}

#[test]
fn a_loaded_files_charset_is_dropped() {
    // dart: the `@charset` of a loaded `.css` (or `.scss`) file never appears
    // in the output; the output's own `@charset "UTF-8";` comes from its
    // non-ASCII content, and an all-ASCII output has none.
    let dir = scratch("charset");
    std::fs::write(
        dir.join("_theme.css"),
        "@charset \"utf-8\";\n.t { color: red; }\n",
    )
    .unwrap();
    std::fs::write(
        dir.join("_lib.scss"),
        "@charset \"utf-8\";\n.s { content: \"é\"; }\n",
    )
    .unwrap();
    assert_eq!(
        compile_in(&dir, "use.scss", "@use \"theme\";\n@use \"lib\";\na { b: c }\n"),
        "@charset \"UTF-8\";\n.t {\n  color: red;\n}\n\n.s {\n  content: \"é\";\n}\n\na {\n  b: c;\n}"
    );
    assert_eq!(
        compile_in(
            &dir,
            "imp.scss",
            "a { b: c }\n@import \"theme\";\n@import \"lib\";\n"
        ),
        "@charset \"UTF-8\";\na {\n  b: c;\n}\n\n.t {\n  color: red;\n}\n\n.s {\n  content: \"é\";\n}"
    );
    assert_eq!(
        compile_in(&dir, "only.scss", "@import \"theme\";\n"),
        ".t {\n  color: red;\n}"
    );
    // Only the file's top-level `@charset` goes: one inside an at-rule or a
    // style rule is kept verbatim, as dart keeps it.
    std::fs::write(
        dir.join("_nested.css"),
        "@media (min-width: 1px) {\n  @charset \"utf-8\";\n  .t { color: red; }\n}\n.u { @charset \"utf-8\"; color: blue; }\n",
    )
    .unwrap();
    assert_eq!(
        compile_in(&dir, "usenested.scss", "@use \"nested\";\n"),
        "@media (min-width: 1px) {\n  @charset \"utf-8\";\n  .t {\n    color: red;\n  }\n}\n.u {\n  @charset \"utf-8\";\n  color: blue;\n}"
    );
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn nested_rules_keep_their_selector_lines() {
    // dart keeps a plain-CSS file's selector lists as written — a complex
    // selector that started on its own line still does, re-indented, and
    // runs of spaces collapse — for nested rules just like top-level ones
    // (the Lichess `recap` bundle, via the swiper stylesheet).
    let dir = scratch("sel");
    std::fs::write(
        dir.join("_sel.css"),
        "a,\nb {\n  x: 1;\n}\nc, d {\n  x: 2;\n}\n.p {\n  q: 3;\n  e,\n  f {\n    y: 1;\n  }\n  g, h {\n    y: 2;\n  }\n  i,   j,\n    k {\n    y: 3;\n  }\n}\n",
    )
    .unwrap();
    let expected = "a,\nb {\n  x: 1;\n}\n\nc, d {\n  x: 2;\n}\n\n.p {\n  q: 3;\n  e,\n  f {\n    y: 1;\n  }\n  g, h {\n    y: 2;\n  }\n  i, j,\n  k {\n    y: 3;\n  }\n}";
    assert_eq!(compile_in(&dir, "use.scss", "@use \"sel\";\n"), expected);
    assert_eq!(compile_in(&dir, "imp.scss", "@import \"sel\";\n"), expected);
    // A `&` part is no different: dart keeps the line it was written on
    // (`.child,\n  & {`), whether the module stands alone or is imported
    // under a Sass parent (its own top level joins the parent; the nested
    // rules stay native).
    std::fs::write(
        dir.join("_amp.css"),
        ".p {\n  .child,\n  & {\n    y: 1;\n  }\n  &,\n  .kid {\n    y: 2;\n  }\n  .a, &.b,\n  .c {\n    y: 3;\n  }\n}\n",
    )
    .unwrap();
    let body = "\n  .child,\n  & {\n    y: 1;\n  }\n  &,\n  .kid {\n    y: 2;\n  }\n  .a, &.b,\n  .c {\n    y: 3;\n  }\n}";
    assert_eq!(
        compile_in(&dir, "useamp.scss", "@use \"amp\";\n"),
        format!(".p {{{body}")
    );
    assert_eq!(
        compile_in(&dir, "nestamp.scss", "x {\n  @import \"amp\";\n}\n"),
        format!("x .p {{{body}")
    );
    std::fs::remove_dir_all(&dir).ok();
}

/// The same, in COMPRESSED style — which is the only thing that tells a value
/// dart kept TYPED from one it kept as text.
fn compile_compressed_in(dir: &std::path::Path, name: &str, src: &str) -> String {
    let entry = dir.join(name);
    std::fs::write(&entry, src).unwrap();
    let url = entry.to_string_lossy().into_owned();
    let imp = FsImporter::new(Vec::new());
    let opts = Options::default()
        .with_importer(&imp)
        .with_url(&url)
        .with_style(sasso::OutputStyle::Compressed);
    compile(src, &opts).expect("compile")
}

/// Compile `src` as an entry in `dir` expecting failure, and return the error's
/// message.
fn compile_err_in(dir: &std::path::Path, name: &str, src: &str) -> String {
    let entry = dir.join(name);
    std::fs::write(&entry, src).unwrap();
    let url = entry.to_string_lossy().into_owned();
    let imp = FsImporter::new(Vec::new());
    let opts = Options::default().with_importer(&imp).with_url(&url);
    compile(src, &opts).expect_err("compile should fail").message
}

/// A value in a loaded `.css` file is a VALUE, not frozen text: dart parses it
/// and re-serializes it for the output style, so compressing shortens its
/// numbers, its hex colours and its list separators. Every expectation below
/// was measured against dart-sass 1.103.1.
#[test]
fn a_loaded_files_values_serialize_for_the_output_style() {
    let dir = scratch("values");
    let case = |file: &str, decl: &str, expanded: &str, compressed: &str| {
        std::fs::write(dir.join(format!("_{file}.css")), format!(".a {{ b: {decl}; }}\n")).unwrap();
        let src = format!("@use \"{file}\";\n");
        assert_eq!(
            compile_in(&dir, &format!("entry_{file}.scss"), &src),
            format!(".a {{\n  b: {expanded};\n}}"),
            "expanded {decl}"
        );
        assert_eq!(
            compile_compressed_in(&dir, &format!("entry_{file}_c.scss"), &src),
            format!(".a{{b:{compressed}}}"),
            "compressed {decl}"
        );
    };
    // Numbers shorten, in a list and behind `!important` as well.
    case("num", "0.5px", "0.5px", ".5px");
    case("neg", "-0.5px", "-0.5px", "-0.5px");
    case("list", "1px 0.5px", "1px 0.5px", "1px .5px");
    case("clist", "1px, 0.5px", "1px, 0.5px", "1px,.5px");
    // Hex colours take their shortest form.
    case("hex6", "#cccccc", "#cccccc", "#ccc");
    case("hex6u", "#CCCCCC", "#CCCCCC", "#ccc");
    case("hex8", "#ccccccff", "#cccccc", "#ccc");
    case("hexname", "#ff0000", "#ff0000", "red");
    case(
        "shorthand",
        "1px solid #cccccc",
        "1px solid #cccccc",
        "1px solid #ccc",
    );
    // A calculation is a calculation.
    case(
        "calc",
        "calc(100% - 2 * var(--x))",
        "calc(100% - 2 * var(--x))",
        "calc(100% - 2*var(--x))",
    );
}

/// A colour KEYWORD is a Sass value, not a CSS one — dart's CSS parser leaves
/// `white` an identifier, so it keeps its own spelling (and its case) instead
/// of compressing to `#fff`. Measured against dart-sass 1.103.1.
#[test]
fn a_loaded_files_colour_keywords_stay_identifiers() {
    let dir = scratch("keywords");
    let case = |file: &str, decl: &str, want: &str| {
        std::fs::write(dir.join(format!("_{file}.css")), format!(".a {{ b: {decl}; }}\n")).unwrap();
        let src = format!("@use \"{file}\";\n");
        assert_eq!(
            compile_compressed_in(&dir, &format!("entry_{file}.scss"), &src),
            format!(".a{{b:{want}}}"),
            "{decl}"
        );
    };
    // The keyword survives; only the LIST around it compresses.
    for (i, (decl, want)) in [
        ("white", "white"),
        ("black", "black"),
        ("magenta", "magenta"),
        ("rebeccapurple", "rebeccapurple"),
        ("transparent", "transparent"),
        ("WHITE", "WHITE"),
        ("1px solid white", "1px solid white"),
        ("white, black", "white,black"),
    ]
    .iter()
    .enumerate()
    {
        case(&format!("kw{i}"), decl, want);
    }
    // Written as SCSS the same keyword IS a colour, and compresses.
    let dir2 = scratch("keywords_scss");
    assert_eq!(
        compile_compressed_in(&dir2, "s.scss", ".a { b: white; }"),
        ".a{b:#fff}"
    );
}

/// A function call in a loaded `.css` file becomes a STRING, and dart builds
/// that string with the DEFAULT style whatever the output style is — so its
/// arguments keep their leading zeros and their `, ` even when compressing,
/// while the separator is normalised from the source. Measured against
/// dart-sass 1.103.1.
#[test]
fn a_loaded_files_function_call_serializes_in_the_default_style() {
    let dir = scratch("calls");
    let case = |file: &str, decl: &str, want: &str| {
        std::fs::write(dir.join(format!("_{file}.css")), format!(".a {{ b: {decl}; }}\n")).unwrap();
        let src = format!("@use \"{file}\";\n");
        assert_eq!(
            compile_compressed_in(&dir, &format!("entry_{file}.scss"), &src),
            format!(".a{{b:{want}}}"),
            "{decl}"
        );
    };
    case("rgb", "rgb(255,255,255)", "rgb(255, 255, 255)");
    case("rgba", "rgba(0, 0, 0, 0.15)", "rgba(0, 0, 0, 0.15)");
    case("unk", "unknownfn(0.5px,2px)", "unknownfn(0.5px, 2px)");
    case("nest", "nested(inner(0.5), 2)", "nested(inner(0.5), 2)");
    case("tr", "translate(0.5px,-0.5px)", "translate(0.5px, -0.5px)");
}

/// A nested plain-CSS rule holding nothing that survives compression — a
/// comment, or another such rule — is not written at all, and neither is the
/// rule left empty around it. (`swiper-bundle.css` ships exactly this.)
/// Measured against dart-sass 1.103.1.
#[test]
fn a_loaded_files_comment_only_rule_vanishes_when_compressed() {
    let dir = scratch("emptyrule");
    let case = |file: &str, css: &str, want: &str| {
        std::fs::write(dir.join(format!("_{file}.css")), css).unwrap();
        assert_eq!(
            compile_compressed_in(
                &dir,
                &format!("entry_{file}.scss"),
                &format!("@use \"{file}\";\n")
            ),
            want,
            "{css}"
        );
    };
    case("only", ".a {\n  .b {\n    /* c */\n  }\n}\n", "");
    case(
        "deep",
        ".a {\n  .b {\n    .c {\n      /* c */\n    }\n  }\n}\n",
        "",
    );
    case("at", ".a {\n  @media x {\n    /* c */\n  }\n}\n", "");
    // A sibling that DOES write keeps its rule.
    case(
        "sibling",
        ".a {\n  c: 1;\n  .b {\n    /* c */\n  }\n}\n",
        ".a{c:1}",
    );
    // And a LOUD comment writes, so everything around it stays.
    case("loud", ".a {\n  .b {\n    /*! c */\n  }\n}\n", ".a{.b{/*! c */}}");
}

/// An at-rule is not invisible just because its block writes nothing: dart's
/// `_isInvisible` short-circuits on an unknown at-rule on purpose ("we can't
/// guarantee that (for example) `@foo {}` isn't meaningful"), so only `@media`
/// and `@supports` — which have their own AST classes — go away. The plain-CSS
/// path builds its own nodes and so needs the rule of its own. Every
/// expectation measured against dart-sass 1.104.1.
#[test]
fn a_loaded_files_empty_at_rule_survives_unless_it_is_media_or_supports() {
    let dir = scratch("emptyat");
    let case = |file: &str, css: &str, expanded: &str, compressed: &str| {
        std::fs::write(dir.join(format!("_{file}.css")), css).unwrap();
        let entry = format!("@use \"{file}\";\n");
        assert_eq!(
            compile_in(&dir, &format!("e_{file}.scss"), &entry),
            expanded,
            "expanded: {css}"
        );
        assert_eq!(
            compile_compressed_in(&dir, &format!("c_{file}.scss"), &entry),
            compressed,
            "compressed: {css}"
        );
    };
    // The first level bubbles out, and an empty block takes no copy of its
    // parent selectors with it.
    case("bub", ".a { @foo {} }\n", "@foo {}", "@foo{}");
    case("media", ".b { @media x {} }\n", "", "");
    case("supports", ".c { @supports (a: b) {} }\n", "", "");
    case("layer", ".l { @layer a {} }\n", "@layer a {}", "@layer a{}");
    // Deeper levels keep native CSS nesting, so the at-rule stays in place.
    case(
        "deep",
        ".d { .e { @foo {} } }\n",
        ".d {\n  .e {\n    @foo {}\n  }\n}",
        ".d{.e{@foo{}}}",
    );
    case("deepmedia", ".d { .e { @media x {} } }\n", "", "");
    case(
        "two",
        ".i { @foo {} @bar {} }\n",
        "@foo {}\n@bar {}",
        "@foo{}@bar{}",
    );
    // A block emptied by compression is still written when compressed, and
    // still holds its contents when expanded.
    case(
        "cmt",
        ".g { @foo { /* c */ } }\n",
        // KNOWN GAP: dart writes the one-child rule on one line here
        // (`.g { /* c */ }`); the copy of the parent this path synthesizes has
        // no source lines, which is what that join is decided on.
        "@foo {\n  .g {\n    /* c */\n  }\n}",
        "@foo{}",
    );
    // KNOWN GAP: dart splits the parent rule around a bubbled at-rule, keeping
    // its source position (`@foo {}` then `.f { color: red }`); this path emits
    // the whole parent first and the bubbled at-rules after it. Pre-existing,
    // and visible with a non-empty block too.
    case(
        "sibling",
        ".f { @foo {} color: red }\n",
        ".f {\n  color: red;\n}\n\n@foo {}",
        ".f{color:red}@foo{}",
    );
}

/// `@keyframes` has its own statement in the AST, and the plain-CSS rule-body
/// paths used to drop it — losing the whole at-rule, contents and all. It
/// hoists out of the first level like any other block at-rule (with no copy of
/// the parent selectors, since its block holds keyframe selectors rather than
/// declarations) and stays in place below that. Measured against dart-sass
/// 1.104.1.
#[test]
fn a_loaded_files_nested_keyframes_is_kept() {
    let dir = scratch("nestedkf");
    let case = |file: &str, css: &str, expanded: &str, compressed: &str| {
        std::fs::write(dir.join(format!("_{file}.css")), css).unwrap();
        let entry = format!("@use \"{file}\";\n");
        assert_eq!(
            compile_in(&dir, &format!("e_{file}.scss"), &entry),
            expanded,
            "expanded: {css}"
        );
        assert_eq!(
            compile_compressed_in(&dir, &format!("c_{file}.scss"), &entry),
            compressed,
            "compressed: {css}"
        );
    };
    case(
        "kf",
        ".h { @keyframes k { from { a: b } } }\n",
        "@keyframes k {\n  from {\n    a: b;\n  }\n}",
        "@keyframes k{from{a:b}}",
    );
    case(
        "empty",
        ".h { @keyframes k {} }\n",
        "@keyframes k {}",
        "@keyframes k{}",
    );
    case(
        "deep",
        ".h { .j { @keyframes k { from { a: b } } } }\n",
        ".h {\n  .j {\n    @keyframes k {\n      from {\n        a: b;\n      }\n    }\n  }\n}",
        ".h{.j{@keyframes k{from{a:b}}}}",
    );
    // And inside another at-rule's body, which is a third dispatcher: dropping
    // it there emptied the enclosing `@media`, so the whole rule vanished.
    case(
        "media",
        "@media screen { @keyframes k { from { a: b } } }\n",
        "@media screen {\n  @keyframes k {\n    from {\n      a: b;\n    }\n  }\n}",
        "@media screen{@keyframes k{from{a:b}}}",
    );
    case(
        "mediaempty",
        "@media screen { @keyframes k {} }\n",
        "@media screen {\n  @keyframes k {}\n}",
        "@media screen{@keyframes k{}}",
    );
    case(
        "supports",
        "@supports (a: b) { @keyframes k { from { a: b } } }\n",
        "@supports (a: b) {\n  @keyframes k {\n    from {\n      a: b;\n    }\n  }\n}",
        "@supports(a: b){@keyframes k{from{a:b}}}",
    );
    case(
        "generic",
        "@foo { @keyframes k { from { a: b } } }\n",
        "@foo {\n  @keyframes k {\n    from {\n      a: b;\n    }\n  }\n}",
        "@foo{@keyframes k{from{a:b}}}",
    );
    case(
        "genericdeep",
        "@foo { .a { @keyframes k { from { a: b } } } }\n",
        "@foo {\n  @keyframes k {\n    from {\n      a: b;\n    }\n  }\n}",
        "@foo{@keyframes k{from{a:b}}}",
    );

    // A FRAME is not a style rule, and nothing inside one bubbles: dart keeps
    // every at-rule where the frame put it. Hoisting out of a frame moved it out
    // of the animation and wrapped the frame selector around its body.
    case(
        "framegeneric",
        "@keyframes k { from { @foo { a: b } } }\n",
        "@keyframes k {\n  from {\n    @foo {\n      a: b;\n    }\n  }\n}",
        "@keyframes k{from{@foo{a:b}}}",
    );
    case(
        "frameempty",
        "@keyframes k { from { @foo {} } }\n",
        "@keyframes k {\n  from {\n    @foo {}\n  }\n}",
        "@keyframes k{from{@foo{}}}",
    );
    case(
        "framemedia",
        "@keyframes k { from { @media x { a: b } } }\n",
        "@keyframes k {\n  from {\n    @media x {\n      a: b;\n    }\n  }\n}",
        "@keyframes k{from{@media x{a:b}}}",
    );
    case(
        "framekf",
        "@keyframes k { from { @keyframes j { to { a: b } } } }\n",
        "@keyframes k {\n  from {\n    @keyframes j {\n      to {\n        a: b;\n      }\n    }\n  }\n}",
        "@keyframes k{from{@keyframes j{to{a:b}}}}",
    );
    case(
        "framefn",
        "@keyframes k { from { @function --f(--a) { result: 1 } } }\n",
        "@keyframes k {\n  from {\n    @function --f(--a) {\n      result: 1 ;\n    }\n  }\n}",
        "@keyframes k{from{@function --f(--a){result: 1 }}}",
    );
    // A declaration before it is not split away from it either.
    case(
        "framesplit",
        "@keyframes k { from { a: b; @foo { c: d } } }\n",
        "@keyframes k {\n  from {\n    a: b;\n    @foo {\n      c: d;\n    }\n  }\n}",
        "@keyframes k{from{a:b;@foo{c:d}}}",
    );
    case(
        "framepct",
        "@keyframes k { 50% { @foo { a: b } } }\n",
        "@keyframes k {\n  50% {\n    @foo {\n      a: b;\n    }\n  }\n}",
        "@keyframes k{50%{@foo{a:b}}}",
    );
    case(
        "framelist",
        "@keyframes k { from, to { @foo { a: b } } }\n",
        "@keyframes k {\n  from, to {\n    @foo {\n      a: b;\n    }\n  }\n}",
        "@keyframes k{from,to{@foo{a:b}}}",
    );
    // Inside an at-rule body, and below the bubbling level, the frame is read by
    // the other two dispatchers -- same answer.
    case(
        "framemediaouter",
        "@media p { @keyframes k { from { @foo { a: b } } } }\n",
        "@media p {\n  @keyframes k {\n    from {\n      @foo {\n        a: b;\n      }\n    }\n  }\n}",
        "@media p{@keyframes k{from{@foo{a:b}}}}",
    );
    case(
        "framedeep",
        ".a { .b { @keyframes k { from { @foo { a: b } } } } }\n",
        ".a {\n  .b {\n    @keyframes k {\n      from {\n        @foo {\n          a: b;\n        }\n      }\n    }\n  }\n}",
        ".a{.b{@keyframes k{from{@foo{a:b}}}}}",
    );
}

/// A `@keyframes` frame's selector is a list of keyframe STOPS, not of CSS
/// selectors: dart re-serializes the stops joined with `", "`, which drops the
/// author's line breaks, lowercases `from`/`to` and a percentage's exponent
/// marker, and leaves `+5%` alone instead of reading `+` as a combinator.
#[test]
fn a_loaded_files_keyframe_stops_serialize_as_stops() {
    let dir = scratch("kfstops");

    // A line break between stops does not survive, at every depth.
    std::fs::write(dir.join("_p.css"), "@keyframes k { 0%,\n50% { a: b } }\n").unwrap();
    assert_eq!(
        compile_in(&dir, "list", "@use \"p\";"),
        "@keyframes k {\n  0%, 50% {\n    a: b;\n  }\n}"
    );
    std::fs::write(
        dir.join("_deep.css"),
        ".a { .b { @keyframes k { 0%,\n50% { a: b } } } }\n",
    )
    .unwrap();
    assert_eq!(
        compile_in(&dir, "deep", "@use \"deep\";"),
        ".a {\n  .b {\n    @keyframes k {\n      0%, 50% {\n        a: b;\n      }\n    }\n  }\n}"
    );

    // `from`/`to` and the exponent marker lowercase; the digits do not change.
    std::fs::write(dir.join("_case.css"), "@keyframes k { FROM, tO { a: b } }\n").unwrap();
    assert_eq!(
        compile_in(&dir, "case", "@use \"case\";"),
        "@keyframes k {\n  from, to {\n    a: b;\n  }\n}"
    );
    std::fs::write(dir.join("_exp.css"), "@keyframes k { 130E-1%, 1E+1% { a: b } }\n").unwrap();
    assert_eq!(
        compile_in(&dir, "exp", "@use \"exp\";"),
        "@keyframes k {\n  130e-1%, 1e+1% {\n    a: b;\n  }\n}"
    );
    std::fs::write(dir.join("_keep.css"), "@keyframes k { 1.0% { a: b } }\n").unwrap();
    assert_eq!(
        compile_in(&dir, "keep", "@use \"keep\";"),
        "@keyframes k {\n  1.0% {\n    a: b;\n  }\n}"
    );

    // `+5%` is a stop, not a sibling combinator: no space is inserted.
    std::fs::write(dir.join("_plus.css"), "@keyframes k { +5% { a: b } }\n").unwrap();
    assert_eq!(
        compile_in(&dir, "plus", "@use \"plus\";"),
        "@keyframes k {\n  +5% {\n    a: b;\n  }\n}"
    );

    // Same in a bubbled `@keyframes`, in a nested one, and in compressed.
    std::fs::write(
        dir.join("_bubble.css"),
        ".a { @keyframes k { TO,\n130E-1% { a: b } } }\n",
    )
    .unwrap();
    assert_eq!(
        compile_in(&dir, "bubble", "@use \"bubble\";"),
        "@keyframes k {\n  to, 130e-1% {\n    a: b;\n  }\n}"
    );
    std::fs::write(
        dir.join("_media.css"),
        "@media p { @keyframes k { From,\nTO { a: b } } }\n",
    )
    .unwrap();
    assert_eq!(
        compile_in(&dir, "media", "@use \"media\";"),
        "@media p {\n  @keyframes k {\n    from, to {\n      a: b;\n    }\n  }\n}"
    );
    assert_eq!(
        compile_compressed_in(&dir, "mediac", "@use \"media\";"),
        "@media p{@keyframes k{from,to{a:b}}}"
    );

    // KNOWN GAP: the stop grammar is `from` | `to` | `<number>%`, and dart
    // rejects anything else in a frame (`@keyframes k {foo {a: b}}` is
    // `Expected "to" or "from".`, `&` and `[a=b]` are `Expected number.`,
    // `50 %` is `expected "%".`). Neither evaluator checks that yet; the
    // plain-CSS side rejects only the Sass-only selector forms, with its own
    // message.
    std::fs::write(dir.join("_bogus.css"), "@keyframes k { foo { a: b } }\n").unwrap();
    assert_eq!(
        compile_in(&dir, "bogus", "@use \"bogus\";"),
        "@keyframes k {\n  foo {\n    a: b;\n  }\n}"
    );
}

/// A style rule inside a keyframe block is an error, in a loaded `.css` file
/// exactly as in SCSS -- dart's plain-CSS parser refuses it, so producing output
/// for it was wrong at every depth. Measured against dart-sass 1.104.1.
#[test]
fn a_loaded_files_style_rule_in_a_keyframe_block_is_an_error() {
    let dir = scratch("framerule");
    let case = |file: &str, css: &str| {
        std::fs::write(dir.join(format!("_{file}.css")), css).unwrap();
        let entry = format!("@use \"{file}\";\n");
        assert_eq!(
            compile_err_in(&dir, &format!("e_{file}.scss"), &entry),
            "Style rules may not be used within keyframe blocks.",
            "source: {css}"
        );
    };
    case("top", "@keyframes k { from { .x { a: b } } }\n");
    // A frame selector in the inner position is still a style rule there.
    case("frame", "@keyframes k { from { to { a: b } } }\n");
    case("inrule", ".a { @keyframes k { from { .x { a: b } } } }\n");
    case("deep", ".a { .b { @keyframes k { from { .x { a: b } } } } }\n");
    case("inat", "@media p { @keyframes k { from { .x { a: b } } } }\n");
}

/// A plain-CSS custom `@function` has its own statement too, and every one of
/// the three body dispatchers dropped it for the same reason. In a style rule
/// it bubbles out with a copy of the parent selectors, like the block at-rules
/// do; deeper down it stays where it is, with no copy. Its body is raw text,
/// spacing and all, which is why `result: 1 ;` keeps that gap. Measured against
/// dart-sass 1.104.1.
#[test]
fn a_loaded_files_custom_function_is_kept_in_every_body() {
    let dir = scratch("customfn");
    let case = |file: &str, css: &str, expanded: &str, compressed: &str| {
        std::fs::write(dir.join(format!("_{file}.css")), css).unwrap();
        let entry = format!("@use \"{file}\";\n");
        assert_eq!(
            compile_in(&dir, &format!("e_{file}.scss"), &entry),
            expanded,
            "expanded: {css}"
        );
        assert_eq!(
            compile_compressed_in(&dir, &format!("c_{file}.scss"), &entry),
            compressed,
            "compressed: {css}"
        );
    };
    case(
        "top",
        "@function --f(--a) { result: 1 }\n",
        "@function --f(--a) {\n  result: 1 ;\n}",
        "@function --f(--a){result: 1 }",
    );
    case(
        "media",
        "@media screen { @function --f(--a) { result: 1 } }\n",
        "@media screen {\n  @function --f(--a) {\n    result: 1 ;\n  }\n}",
        "@media screen{@function --f(--a){result: 1 }}",
    );
    case(
        "generic",
        "@foo { @function --f(--a) { result: 1 } }\n",
        "@foo {\n  @function --f(--a) {\n    result: 1 ;\n  }\n}",
        "@foo{@function --f(--a){result: 1 }}",
    );

    // In a style rule it bubbles to where the rule was, taking a copy of the
    // parent selectors: the body holds declarations, so they need a rule to
    // live in.
    case(
        "rule",
        ".a { @function --f(--a) { result: 1 } }\n",
        "@function --f(--a) {\n  .a {\n    result: 1 ;\n  }\n}",
        "@function --f(--a){.a{result: 1 }}",
    );
    case(
        "rulevar",
        ".a { @function --f(--a) { result: var(--a) } }\n",
        "@function --f(--a) {\n  .a {\n    result: var(--a) ;\n  }\n}",
        "@function --f(--a){.a{result: var(--a) }}",
    );
    // Nothing to wrap means no copy of the parent, but the at-rule survives:
    // `@function` is not one of the two that vanish on an empty block.
    case(
        "ruleempty",
        ".a { @function --f(--a) {} }\n",
        "@function --f(--a) {}",
        "@function --f(--a){}",
    );
    case(
        "ruletwo",
        ".a { @function --f(--a) { result: 1 } @function --g(--b) { result: 2 } }\n",
        "@function --f(--a) {\n  .a {\n    result: 1 ;\n  }\n}\n@function --g(--b) {\n  .a {\n    result: 2 ;\n  }\n}",
        "@function --f(--a){.a{result: 1 }}@function --g(--b){.a{result: 2 }}",
    );
    // One level deeper it is native CSS nesting: it stays put, and takes no
    // copy of anything.
    case(
        "ruledeep",
        ".a { .b { @function --f(--a) { result: 1 } } }\n",
        ".a {\n  .b {\n    @function --f(--a) {\n      result: 1 ;\n    }\n  }\n}",
        ".a{.b{@function --f(--a){result: 1 }}}",
    );
    case(
        "ruledeepempty",
        ".a { .b { @function --f(--a) {} } }\n",
        ".a {\n  .b {\n    @function --f(--a) {}\n  }\n}",
        ".a{.b{@function --f(--a){}}}",
    );
    // Bubbling inside an at-rule body stops at that body.
    case(
        "mediarule",
        "@media x { .a { @function --f(--a) { result: 1 } } }\n",
        "@media x {\n  @function --f(--a) {\n    .a {\n      result: 1 ;\n    }\n  }\n}",
        "@media x{@function --f(--a){.a{result: 1 }}}",
    );
    case(
        "genericrule",
        "@foo { .a { @function --f(--a) { result: 1 } } }\n",
        "@foo {\n  @function --f(--a) {\n    .a {\n      result: 1 ;\n    }\n  }\n}",
        "@foo{@function --f(--a){.a{result: 1 }}}",
    );
    // KNOWN GAP: bubbling out of a first-level rule loses the at-rule's source
    // position, so a following declaration does not split the parent. dart
    // emits `@function --f(--a){.a{result: 1 }}.a{color:red}` -- the same gap
    // the `sibling` case in
    // `a_loaded_files_empty_at_rule_survives_unless_it_is_media_or_supports`
    // pins, and it is not specific to `@function`.
    case(
        "rulesibling",
        ".a { @function --f(--a) { result: 1 } color: red }\n",
        ".a {\n  color: red;\n}\n\n@function --f(--a) {\n  .a {\n    result: 1 ;\n  }\n}",
        ".a{color:red}@function --f(--a){.a{result: 1 }}",
    );
}

/// A loaded `.css` file reaches the same selector scanners: its list is cut by
/// the comma split, and whether a rule keeps NATIVE CSS NESTING is decided by
/// asking whether the part references its parent. An escaped delimiter must
/// not answer either question. Every expectation measured against dart-sass
/// 1.103.1.
#[test]
fn a_loaded_files_escaped_selectors_are_not_structure() {
    let dir = scratch("escaped");
    let load = |css: &str| std::fs::write(dir.join("_vendor.css"), css).unwrap();

    // Through `@use`, where the split is all that runs.
    load(".a\\,b, .c { d: 1; }\n");
    assert_eq!(
        compile_in(&dir, "use.scss", "@use \"vendor\";\n"),
        ".a\\,b, .c {\n  d: 1;\n}"
    );
    load(".a\\[b, .c { d: 1; }\n");
    assert_eq!(
        compile_in(&dir, "use2.scss", "@use \"vendor\";\n"),
        ".a\\[b, .c {\n  d: 1;\n}"
    );
    load(".a\\&b { c: 1; }\n");
    assert_eq!(
        compile_in(&dir, "use3.scss", "@use \"vendor\";\n"),
        ".a\\&b {\n  c: 1;\n}"
    );

    // Through `@import` INSIDE a rule, where a part that references its parent
    // keeps native nesting and one that does not gets the descendant join. An
    // escaped `&` is not a reference, so it takes the join.
    load(".a\\&b { c: 1; }\n");
    assert_eq!(
        compile_in(&dir, "imp.scss", ".p { @import \"vendor\"; }\n"),
        ".p .a\\&b {\n  c: 1;\n}"
    );
    // A REAL `&` still keeps it, and one file can hold both.
    load(".a\\&b { c: 1; }\n& .d { e: 1; }\n");
    assert_eq!(
        compile_in(&dir, "imp2.scss", ".p { @import \"vendor\"; }\n"),
        ".p {\n  & .d {\n    e: 1;\n  }\n}\n.p .a\\&b {\n  c: 1;\n}"
    );
    // The comma split runs on this path too, so the list keeps its length.
    load(".a\\,b, .c { d: 1; }\n");
    assert_eq!(
        compile_in(&dir, "imp3.scss", ".p { @import \"vendor\"; }\n"),
        ".p .a\\,b, .p .c {\n  d: 1;\n}"
    );
    // And an `&` inside an attribute is text, not a reference.
    load("[x=\"&\"] { c: 1; }\n");
    assert_eq!(
        compile_in(&dir, "imp4.scss", ".p { @import \"vendor\"; }\n"),
        ".p [x=\"&\"] {\n  c: 1;\n}"
    );
    std::fs::remove_dir_all(&dir).ok();
}

/// A loaded `.css` file has NO interpolation: dart's plain-CSS parser rejects
/// every `#{…}` it reaches, so nothing interpolated ever becomes a node. Our
/// parser rejected it in a value, a selector and a keyframes name but not in an
/// at-rule's NAME, a media query, a `@supports` condition, a loud comment or a
/// custom callable's body — where an interpolated at-rule was silently dropped
/// instead. Every message below was measured against dart-sass 1.104.1.
#[test]
fn interpolation_in_a_loaded_file_is_an_error() {
    let dir = scratch("interp");
    let case = |file: &str, css: &str| {
        std::fs::write(dir.join(format!("_{file}.css")), css).unwrap();
        assert_eq!(
            compile_err_in(&dir, &format!("e_{file}.scss"), &format!("@use \"{file}\";\n")),
            "Interpolation isn't allowed in plain CSS.",
            "source: {css}"
        );
    };

    // An at-rule NAME, which used to parse into a node the plain-CSS evaluator
    // had no arm for — so the whole rule vanished without a word.
    case("name", "@#{\"media\"} (a: 1) { .x { y: z } }\n");
    case("namepart", "@med#{\"ia\"} (a: 1) { .x { y: z } }\n");
    case("nameempty", "@#{\"media\"} screen {}\n");
    case("namechildless", "@#{\"foo\"} bar;\n");
    case("nameinrule", ".a { @#{\"foo\"} { b: c } }\n");
    case("nameinat", "@media p { @#{\"foo\"} { .x { y: z } } }\n");
    // A media query: the type/modifier identifier and a raw operand after
    // `not` or `and`, which used to compile as if the interpolation were text.
    case("mediatype", "@media #{\"screen\"} { a { b: c } }\n");
    case("medianot", "@media not #{\"(a: 1)\"} { a { b: c } }\n");
    case("mediaand", "@media screen and #{\"(a: 1)\"} { a { b: c } }\n");
    // A `@supports` condition, raw or inside a function's arguments.
    case("supportsraw", "@supports #{\"(a: 1)\"} { a { b: c } }\n");
    case("supportsfn", "@supports selector(#{\"a\"}) { a { b: c } }\n");
    // A loud comment's body, at the top level and inside a rule.
    case("comment", "/* #{1} */\n");
    case("commentinrule", "a { /* #{1} */ b: c }\n");
    // A plain-CSS custom callable's body, bare and inside a string.
    case("customfn", "@function --a() { result: #{1} }\n");
    case("customfnstr", "@function --a() { result: \"#{1}\" }\n");
    // A custom property's value inside a string (the bare form already erred).
    case("custompropstr", "a { --x: \"#{1}\" }\n");
    // A special function's verbatim argument list — `element()`,
    // `expression()`, a vendor-prefixed spelling, and the IE `progid:` form —
    // bare and inside a quoted string.
    case("special", "a { b: element(#{1}) }\n");
    case("specialstr", "a { b: element(\"#{1}\") }\n");
    case("specialexpr", "a { b: expression(#{1}) }\n");
    case("specialprefix", "a { b: -moz-element(#{1}) }\n");
    case("specialprogid", "a { b: progid:DXImageTransform(#{1}) }\n");
    // The modern CSS `if()`'s raw operands, which are read verbatim: inside a
    // condition's parentheses (nested ones too), in the function name that
    // precedes them, and in a clause's value after a raw condition.
    case("ifraw", "a { b: if(media(width > #{1}px): red; else: blue) }\n");
    case(
        "ifrawnested",
        "a { b: if(media((width > #{1}px)): red; else: blue) }\n",
    );
    case(
        "ifrawname",
        "a { b: if(me#{\"dia\"}(width > 10px): red; else: blue) }\n",
    );
    case("ifrawstyle", "a { b: if(style(--x: #{1}): red; else: blue) }\n");
    case(
        "ifrawsupports",
        "a { b: if(supports(#{\"color: red\"}): red; else: blue) }\n",
    );
    case(
        "ifrawwhole",
        "a { b: if(media(#{\"width > 10px\"}): red; else: blue) }\n",
    );
    case("ifvalue", "a { b: if(media(width > 10px): #{1}; else: blue) }\n");
    // The positions that already rejected, pinned so they stay rejected.
    case("value", "a { b: #{1} }\n");
    case("urlfn", "a { b: url(#{1}) }\n");
    case("calcfn", "a { b: calc(#{1} + 1px) }\n");
    case("ifcond", "a { b: if(#{1}: red; else: blue) }\n");
    case("iflegacy", "a { b: if(#{1}, red, blue) }\n");
    case("valuestr", "a { b: \"#{1}\" }\n");
    case("selector", "#{\"a\"} { b: c }\n");
    case("keyframesname", "@keyframes #{\"k\"} { from { a: b } }\n");
    case("framestop", "@keyframes k { #{\"from\"} { a: b } }\n");

    // dart rejects at the END of its `singleInterpolation`, so a body that is
    // itself invalid reports ITSELF first — the interpolation error never gets
    // the chance.
    std::fs::write(dir.join("_var.css"), "@#{$x} { a { b: c } }\n").unwrap();
    assert_eq!(
        compile_err_in(&dir, "e_var.scss", "@use \"var\";\n"),
        "Sass variables aren't allowed in plain CSS."
    );
    std::fs::write(dir.join("_empty.css"), "@#{ } { a { b: c } }\n").unwrap();
    assert_eq!(
        compile_err_in(&dir, "e_empty.scss", "@use \"empty\";\n"),
        "Expected expression."
    );

    // Inside the modern `if()`'s raw grammar the rejection has to escape the
    // fallback to the legacy `if($c, $t, $f)` argument parse, which would
    // otherwise report the `>` it reads verbatim as an operator.
    std::fs::write(
        dir.join("_ifvar.css"),
        "a { b: if(media(width > #{$x}px): red; else: blue) }\n",
    )
    .unwrap();
    assert_eq!(
        compile_err_in(&dir, "e_ifvar.scss", "@use \"ifvar\";\n"),
        "Sass variables aren't allowed in plain CSS."
    );
    std::fs::write(
        dir.join("_ifempty.css"),
        "a { b: if(media(width > #{ }px): red; else: blue) }\n",
    )
    .unwrap();
    assert_eq!(
        compile_err_in(&dir, "e_ifempty.scss", "@use \"ifempty\";\n"),
        "Expected expression."
    );

    // SCSS is untouched: the same file is an interpolated at-rule name there.
    std::fs::write(dir.join("_sass.scss"), "@#{\"media\"} (a: 1) { .x { y: z } }\n").unwrap();
    assert_eq!(
        compile_in(&dir, "e_sass.scss", "@use \"sass\";\n"),
        "@media (a: 1) {\n  .x {\n    y: z;\n  }\n}"
    );
    std::fs::write(
        dir.join("_sassif.scss"),
        "a { b: if(me#{\"dia\"}(width > #{10}px): red; else: blue) }\n",
    )
    .unwrap();
    assert_eq!(
        compile_in(&dir, "e_sassif.scss", "@use \"sassif\";\n"),
        "a {\n  b: if(media(width > 10px): red; else: blue);\n}"
    );
    std::fs::remove_dir_all(&dir).ok();
}

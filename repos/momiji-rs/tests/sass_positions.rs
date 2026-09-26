//! Indented-syntax (`.sass`) positions: every line and column a diagnostic or
//! a source map reports is a position in the `.sass` file itself.
//!
//! The front-end reconstructs SCSS from the indentation-structured source and
//! hands it to the shared parser, so what it reconstructs decides what every
//! `Pos` means. The reconstruction is position-preserving — one output line per
//! source line, the source indentation kept, a block's `}` riding on its last
//! line — and the two constructs that cannot be rewritten without moving
//! columns (the `=`/`+` mixin shorthands, unquoted `@import` urls) are read by
//! the parser in place instead.
//!
//! Every expectation here was taken from dart-sass 1.103.1 on the same input.

use std::cell::RefCell;
use std::rc::Rc;

use sasso::{compile, compile_with_source_map, Options, OutputStyle, Syntax, WarnEvent};

/// Compile indented source, with diagnostics enabled under `url`.
fn sass(src: &str, url: &str) -> Result<String, sasso::Error> {
    compile(src, &Options::default().with_syntax(Syntax::Sass).with_url(url))
}

/// The rendered diagnostic block of the error `src` raises.
fn sass_err(src: &str, url: &str) -> String {
    sass(src, url).expect_err("expected a compile error").to_string()
}

/// Every `formatted` warning block `src` produces.
fn sass_warnings(src: &str, url: &str) -> Vec<String> {
    let seen: Rc<RefCell<Vec<String>>> = Rc::new(RefCell::new(Vec::new()));
    let sink = Rc::clone(&seen);
    let opts = Options::default()
        .with_syntax(Syntax::Sass)
        .with_url(url)
        .with_warn_handler(Rc::new(move |ev: &WarnEvent<'_>| {
            sink.borrow_mut().push(ev.formatted.to_string());
        }));
    compile(src, &opts).expect("compile");
    let out = seen.borrow().clone();
    out
}

/// The `mappings` of an indented source compiled under `url`.
fn sass_mappings(src: &str, url: &str) -> String {
    let opts = Options::default().with_syntax(Syntax::Sass).with_url(url);
    compile_with_source_map(src, &opts)
        .expect("compile")
        .source_map
        .mappings
}

#[test]
fn an_error_points_at_its_sass_line_and_column() {
    // The column is the one in the `.sass` file: the reconstruction keeps each
    // statement's own indentation rather than re-indenting by nesting depth.
    assert_eq!(
        sass_err(".a\n  .b\n    color: $undefined\n", "a.sass"),
        "Error: Undefined variable.\n  \u{2577}\n3 \u{2502}     color: $undefined\n  \
         \u{2502}            ^^^^^^^^^^\n  \u{2575}\n  a.sass 3:12  root stylesheet"
    );
}

#[test]
fn closed_blocks_and_comments_do_not_shift_later_lines() {
    // Each source line maps to one output line: a finished block, a blank line
    // and a multi-line comment all leave the lines after them where they were.
    let cases = [
        // A nested block, then a blank line, then the error.
        (
            ".a\n  color: red\n\n.b\n  .c\n    color: blue\n\n.d\n  color: $u\n",
            (9, 10),
        ),
        // A multi-line selector list.
        (".a,\n.b\n  color: red\n.d\n  color: $u\n", (5, 10)),
        // A multi-line loud comment.
        ("/* one\n   two\n   three */\n.d\n  color: $u\n", (5, 10)),
        // The simplest shape of all.
        (".a\n  color: red\n.d\n  color: $u\n", (4, 10)),
        // A silent comment emits nothing, but still occupies its line —
        // including when it is a block's only child, or its last.
        ("a\n  // c\n.b\n  x: $u\n", (4, 6)),
        ("a\n  // c\n\n.b\n  x: $u\n", (5, 6)),
        ("a\n  b: c\n  // x\n.d\n  y: $u\n", (5, 6)),
        ("a\n  // x\n  b: c\n.d\n  y: $u\n", (5, 6)),
        ("a\n  // x\n  // y\n.d\n  z: $u\n", (5, 6)),
        ("a\n  b: c\n    // deep\n.d\n  y: $u\n", (5, 6)),
        ("// top\na\n  b: c\n.d\n  y: $u\n", (5, 6)),
    ];
    for (src, (line, col)) in cases {
        let e = sass(src, "in.sass").expect_err("expected an error");
        assert_eq!((e.line, e.col), (line, col), "for {src:?}");
    }
}

#[test]
fn a_warning_points_at_its_sass_column() {
    let w = sass_warnings(".a\n  .b\n    @warn \"hi\"\n", "b.sass");
    assert_eq!(w.len(), 1);
    assert!(w[0].contains("b.sass 3:5"), "{}", w[0]);
}

/// A scratch directory holding `_foo.sass`, for the import tests.
fn scratch(tag: &str) -> std::path::PathBuf {
    let dir = std::env::temp_dir().join(format!("sasso_sass_pos_{tag}_{}", std::process::id()));
    std::fs::create_dir_all(&dir).expect("mkdir");
    std::fs::write(dir.join("_foo.sass"), "l\n  m: 1\n").expect("write");
    dir
}

#[test]
fn an_unquoted_import_url_carries_its_own_span() {
    // dart reads an unquoted url with the whole-value reader, so the
    // deprecation carets exactly the url token — `foo`, not the quoted
    // rewrite the front-end used to produce (two bytes longer).
    let dir = scratch("span");
    let src = "@import foo\n.a\n  color: red\n";
    let entry = dir.join("c.sass");
    std::fs::write(&entry, src).unwrap();
    let url = entry.to_string_lossy().into_owned();
    let imp = sasso::FsImporter::new(Vec::new());
    let seen: Rc<RefCell<Vec<String>>> = Rc::new(RefCell::new(Vec::new()));
    let sink = Rc::clone(&seen);
    let opts = Options::default()
        .with_syntax(Syntax::Sass)
        .with_importer(&imp)
        .with_url(&url)
        .with_warn_handler(Rc::new(move |ev: &WarnEvent<'_>| {
            sink.borrow_mut().push(ev.formatted.to_string());
        }));
    let css = compile(src, &opts).expect("compile");
    assert_eq!(css, "l {\n  m: 1;\n}\n\n.a {\n  color: red;\n}");
    let w = seen.borrow();
    assert_eq!(w.len(), 1);
    assert!(
        w[0].contains("1 \u{2502} @import foo\n  \u{2502}         ^^^\n"),
        "{}",
        w[0]
    );
    assert!(w[0].contains("c.sass 1:9"), "{}", w[0]);
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn an_unquoted_import_url_runs_to_the_comma() {
    // dart's `SassParser.importArgument` reads to the next top-level comma,
    // spaces included: `@import foo screen` is ONE url named `foo screen`
    // (dart carets all ten characters), not a url plus a media modifier.
    let dir = scratch("comma");
    let src = "@import foo screen\n";
    let entry = dir.join("e.sass");
    std::fs::write(&entry, src).unwrap();
    let url = entry.to_string_lossy().into_owned();
    let imp = sasso::FsImporter::new(Vec::new());
    let opts = Options::default()
        .with_syntax(Syntax::Sass)
        .with_importer(&imp)
        .with_url(&url)
        .with_warn_handler(Rc::new(|_: &WarnEvent<'_>| {}));
    let e = compile(src, &opts).expect_err("expected an error");
    // The whole token is the url, so that is what cannot be found: dart carets
    // all ten characters at 1:9 and names none of them in the message.
    assert_eq!(e.message, "Can't find stylesheet to import.");
    assert_eq!((e.line, e.col), (1, 9));
    let block = e.to_string();
    assert!(block.contains("\u{2502}         ^^^^^^^^^^\n"), "{block}");
    // An escaped `url(` is still a url FUNCTION, so the import is plain CSS —
    // and the name is re-emitted in dart's canonical lowercase spelling,
    // however it was written. (A vendor-prefixed name is NOT a url token here:
    // dart rejects `@import -c-url(…)`, unlike in a value position.)
    assert_eq!(
        sass("@import u\\72l(//cdn/x.css)\n", "d.sass").unwrap(),
        "@import url(//cdn/x.css);"
    );
    assert_eq!(
        sass("@import URL(//cdn/x.css)\n", "d.sass").unwrap(),
        "@import url(//cdn/x.css);"
    );
    // An escaped `)` inside an import's url is CONTENT, not the delimiter —
    // the url used to end there and lose its tail to comment stripping.
    assert_eq!(
        sass("@import url(foo\\)//cdn/x.css)\n", "d.sass").unwrap(),
        "@import url(foo\\)//cdn/x.css);"
    );
    assert_eq!(
        sass("@import u\\72l(foo\\)//cdn/x.css)\n", "d.sass").unwrap(),
        "@import url(foo\\)//cdn/x.css);"
    );
    // An ESCAPED `\\#{` is literal text, so the path is STATIC: dart reads the
    // whole `foo\\#{bar}.scss` as one url — its deprecation carets all fifteen
    // characters, and it then reports the url as not found. sasso used to
    // reject the line as a dynamic path instead.
    let src2 = "@import foo\\#{bar}.scss\n";
    std::fs::write(&entry, src2).unwrap();
    let e = compile(src2, &opts).expect_err("expected an error");
    assert!(
        e.message.contains("Can't find stylesheet to import"),
        "{}",
        e.message
    );
    assert!(!e.message.contains("dynamic"), "{}", e.message);
    // The at-rule KEYWORD may be escaped; the parser decodes it, so the line
    // analysis must too, or `@im\\70ort` is taken for an unknown at-rule and
    // its unquoted url is truncated at the `//`.
    assert_eq!(
        sass("@im\\70ort http://x/y.css\n", "d.sass").unwrap(),
        "@import \"http://x/y.css\";"
    );
    // The keyword's escapes are decoded before the arguments are scanned, so a
    // quoted url is still seen as quoted and its trailing comment is dropped.
    std::fs::write(&entry, "@im\\70ort \"foo\" // c\n.a\n  b: c\n").unwrap();
    let css = compile("@im\\70ort \"foo\" // c\n.a\n  b: c\n", &opts).expect("compile");
    assert_eq!(css, "l {\n  m: 1;\n}\n\n.a {\n  b: c;\n}");
    // An explicit `;` ends the url, so a trailing silent comment after it is
    // a comment — dart imports `foo` from `@import foo; // t`.
    std::fs::write(&entry, "@import foo; // t\n").unwrap();
    let css = compile("@import foo; // t\n", &opts).expect("compile");
    assert_eq!(css, "l {\n  m: 1;\n}");
    // Two comma-separated urls are two imports.
    std::fs::write(dir.join("_bar.sass"), "n\n  o: 2\n").unwrap();
    let src = "@import foo, bar\n";
    std::fs::write(&entry, src).unwrap();
    let css = compile(src, &opts).expect("compile");
    assert_eq!(css, "l {\n  m: 1;\n}\n\nn {\n  o: 2;\n}");
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn a_css_import_url_is_written_back_quoted() {
    // A `.css`/protocol url is a plain-CSS import, emitted with its text
    // verbatim inside quotes, as dart emits it.
    assert_eq!(
        sass("@import other.css\n", "c.sass").unwrap(),
        "@import \"other.css\";"
    );
    assert_eq!(
        sass("@import http://x/y.css\n", "d.sass").unwrap(),
        "@import \"http://x/y.css\";"
    );
    assert_eq!(
        sass("@import url(http://x/y.css)\n", "d.sass").unwrap(),
        "@import url(http://x/y.css);"
    );
}

#[test]
fn a_double_slash_inside_a_url_is_not_a_comment() {
    // dart scans `url(` and its contents as one token; only the exact `url`
    // function qualifies, so `my-url(//y)` really does start a comment.
    assert_eq!(
        sass(".a\n  b: url(http://x/y)\n", "a.sass").unwrap(),
        ".a {\n  b: url(http://x/y);\n}"
    );
    assert_eq!(
        sass(".a\n  background: url(//cdn/x.png)\n", "a.sass").unwrap(),
        ".a {\n  background: url(//cdn/x.png);\n}"
    );
    assert_eq!(
        sass(".a\n  b: URL(//y)\n", "a.sass").unwrap(),
        ".a {\n  b: url(//y);\n}"
    );
    assert!(sass(".a\n  b: my-url(//y)\n", "a.sass").is_err());
    // A VENDOR-PREFIXED url is a url token too — the shared value parser reads
    // `-c-url(` as one and emits it bare — while `my-url(` above is not.
    assert_eq!(
        sass("a\n  b: -c-url(//cdn/x)\n  d: red\n", "a.sass").unwrap(),
        "a {\n  b: url(//cdn/x);\n  d: red;\n}"
    );
    // The name is matched the way the value parser matches it, escapes and
    // all: `u\\72l(` is `url(`, so its `//` is url text too.
    assert_eq!(
        sass("a\n  b: u\\72l(//cdn/x)\n  c: red\n", "a.sass").unwrap(),
        "a {\n  b: url(//cdn/x);\n  c: red;\n}"
    );
    // An escaped `)` is url CONTENT and does not close the token.
    assert_eq!(
        sass("a\n  b: url(foo\\)//cdn)\n", "a.sass").unwrap(),
        "a {\n  b: url(foo\\)//cdn);\n}"
    );
    // A declaration AFTER one is still its own statement: the line scanners
    // that decide where a logical line ends must skip the url token too, or
    // `url(http://x/y)` reads as an unterminated paren and swallows the next
    // line (`b: url(http://x/y) c;` / `: red;`).
    assert_eq!(
        sass(".a\n  b: url(http://x/y)\n  c: red\n", "a.sass").unwrap(),
        ".a {\n  b: url(http://x/y);\n  c: red;\n}"
    );
    assert_eq!(
        sass(".a\n  b: url(//x/y)\n  c: red\n", "a.sass").unwrap(),
        ".a {\n  b: url(//x/y);\n  c: red;\n}"
    );
    // A `url(` may be left OPEN at the end of its line — the indented syntax
    // continues it — and its contents stay verbatim across the join, so the
    // `//` in a protocol url is still not a comment (four sass-spec cases).
    assert_eq!(
        sass("a\n  b: url(\n    c)\n", "a.sass").unwrap(),
        "a {\n  b: url(c);\n}"
    );
    assert_eq!(
        sass("a\n  b: url(c\n    )\n", "a.sass").unwrap(),
        "a {\n  b: url(c);\n}"
    );
    assert_eq!(
        sass("a\n  b: url(\n    http://x/y)\n  d: red\n", "a.sass").unwrap(),
        "a {\n  b: url(http://x/y);\n  d: red;\n}"
    );
    // A `\\`+newline inside a quoted string is a CSS line continuation, which
    // SCSS spells the same way — so it is kept rather than collapsed, and a
    // diagnostic on the continuation line reports THERE (dart: 3:5).
    assert_eq!(
        sass(".a\n  b: \"foo\\\n  bar\"\n", "b.sass").unwrap(),
        ".a {\n  b: \"foo  bar\";\n}"
    );
    let e = sass(".a\n  b: \"foo\\\n  #{$undef}\"\n", "b.sass").expect_err("expected an error");
    assert_eq!((e.line, e.col), (3, 5));
    // A trailing `//` is still a comment, inside and outside a string.
    assert_eq!(sass(".a\n  b: c // t\n", "a.sass").unwrap(), ".a {\n  b: c;\n}");
    assert_eq!(
        sass(".a\n  b: \"http://x\" // t\n", "a.sass").unwrap(),
        ".a {\n  b: \"http://x\";\n}"
    );
    assert_eq!(
        sass(".a\n  b: url(x) // t\n", "a.sass").unwrap(),
        ".a {\n  b: url(x);\n}"
    );
}

#[test]
fn source_maps_point_into_the_sass_file() {
    // Every `mappings` string here is dart-sass 1.103.1's for the same input.
    let cases = [
        (".a\n  color: red\n", "AAAA;EACE"),
        // A silent comment, a blank line, a multi-line selector list and a
        // loud comment — none of them shift a later mapping.
        (
            "// silent\n.a\n  color: red\n\n  .b,\n  .c\n    /* loud */\n    width: 1px\n",
            "AACA;EACE;;AAEA;AAAA;AAEE;EACA",
        ),
        // The mixin shorthands: `+mx(1)`'s ARGUMENT maps to its own column,
        // which rewriting `+mx` to `@include mx` would have moved by eight.
        ("=mx($x)\n  m: $x\n.d\n  +mx(1)\n", "AAEA;EADE,GAEI"),
        // A parent reference and a bubbled `@media`.
        (
            ".a\n  &:hover\n    x: 1\n@media screen\n  .b\n    y: 2\n",
            "AACE;EACE;;;AACJ;EACE;IACE",
        ),
        // A custom property.
        (".a\n  --v: 1px\n  b: c\n", "AAAA;EACE;EACA"),
        // A top-level multi-line comment.
        ("/* one\n   two */\n.a\n  b: c\n", "AAAA;AAAA;AAEA;EACE"),
        // The legacy escaped-selector marker is not part of the selector:
        // dart maps `\:hover` to the `:`, one column past the `\`.
        (".a\n  \\:hover\n    b: c\n", "AACG;EACC"),
        (".a\n  :hover\n    b: c\n", "AACE;EACE"),
    ];
    for (src, expected) in cases {
        assert_eq!(sass_mappings(src, "in.sass"), expected, "for {src:?}");
    }
}

#[test]
fn the_shorthands_still_compile_to_what_they_stand_for() {
    // Reading `=`/`+` in the parser rather than rewriting them upstream must
    // not change what they mean.
    assert_eq!(
        sass("=a\n  b: c\nd\n  +a\n", "x.sass").unwrap(),
        "d {\n  b: c;\n}"
    );
    assert_eq!(
        sass("=a($x)\n  b: $x\nd\n  +a(1)\n", "x.sass").unwrap(),
        "d {\n  b: 1;\n}"
    );
    assert_eq!(
        sass("=a\n  @content\nd\n  +a\n    e: f\n", "x.sass").unwrap(),
        "d {\n  e: f;\n}"
    );
    // A bare `+` is the next-sibling combinator, not an include.
    assert_eq!(
        sass("d\n  +\n    a\n      x: y\n", "x.sass").unwrap(),
        "d + a {\n  x: y;\n}"
    );
    // A `+name` include with `using`, and a namespaced one.
    assert_eq!(
        sass("=a\n  @content(1)\nd\n  +a using ($v)\n    e: $v\n", "x.sass").unwrap(),
        "d {\n  e: 1;\n}"
    );
}

#[test]
fn the_shorthand_keeps_the_rules_the_keyword_has() {
    // `=--name` is the plain-CSS mixin spelling dart reserves: rejected here
    // exactly as `@mixin --name` is, pointing at the name (dart: 1:2).
    let e = sass("=--a\n  b: c\n", "b.sass").expect_err("expected an error");
    assert_eq!((e.line, e.col), (1, 2));
    assert!(
        e.message.contains("beginning with -- are forbidden"),
        "{}",
        e.message
    );
    // A mixin whose NAME is the keyword the shorthand stands for still works:
    // the prelude is everything after the sigil, with no keyword to strip.
    assert_eq!(
        sass("=mixin\n  b: c\n.d\n  +mixin\n", "x.sass").unwrap(),
        ".d {\n  b: c;\n}"
    );
    assert_eq!(
        sass("=include\n  b: c\n.d\n  +include\n", "x.sass").unwrap(),
        ".d {\n  b: c;\n}"
    );
}

#[test]
fn an_escaped_keyword_is_the_keyword_it_spells() {
    // The parser decodes an escaped at-rule keyword, so the line analysis must
    // too: `@fu\\6e ction --a()` is a plain-CSS custom function, whose
    // `result:` may not have anything indented beneath it. Reading the name
    // with a raw identifier scan stopped at the backslash, missed the `--`,
    // and emitted `result: 1 { nested: 2; } ;` — invalid CSS.
    let e =
        sass("@fu\\6e ction --a()\n  result: 1\n    nested: 2\n", "b.sass").expect_err("expected an error");
    assert_eq!((e.line, e.col), (3, 5));
    assert!(
        e.message
            .contains("Nothing may be indented beneath a @function result"),
        "{}",
        e.message
    );
}

#[test]
fn a_comment_opening_on_a_bare_line_still_opens() {
    // dart drops blank lines between a BARE `/*` and the comment's first text,
    // while a blank BETWEEN two body lines is kept. The renderer's first entry
    // used to be that blank, so the `/*` was never emitted and the whole
    // reconstruction stopped being valid SCSS.
    assert_eq!(sass("/*\n\n  a\n", "c.sass").unwrap(), "/* a */");
    assert_eq!(sass("/*\n\n\n  a\n", "c.sass").unwrap(), "/* a */");
    assert_eq!(sass("/*\n\n  a\n  b\n", "c.sass").unwrap(), "/* a\n * b */");
    assert_eq!(
        sass("/*\n\n  a\n  */\n.z\n  y: 1\n", "c.sass").unwrap(),
        "/* a\n * */\n.z {\n  y: 1;\n}"
    );
    // A blank AFTER content is still part of the comment.
    assert_eq!(sass("/*\n  a\n\n  b\n", "c.sass").unwrap(), "/* a\n *\n * b */");
    assert_eq!(sass("/* x\n\n  a\n", "c.sass").unwrap(), "/* x\n *\n * a */");
}

#[test]
fn an_escaped_keyword_still_spans_its_prelude() {
    // `@use` may put its url on the next indented line, and dart accepts that.
    // The prelude was derived by stripping the DECODED name from the RAW
    // spelling, so an escaped keyword left `us\\65` as the prelude, the
    // directive looked complete, and the url was rejected as an indented
    // child. (`@import` is the opposite case — dart rejects a continuation
    // there — which is why only `@use` shows the bug.)
    let dir = scratch("usecont");
    let entry = dir.join("c.sass");
    let url = entry.to_string_lossy().into_owned();
    let imp = sasso::FsImporter::new(Vec::new());
    let opts = Options::default()
        .with_syntax(Syntax::Sass)
        .with_importer(&imp)
        .with_url(&url)
        .with_warn_handler(Rc::new(|_: &WarnEvent<'_>| {}));
    for src in ["@use\n  \"foo\"\n", "@us\\65\n  \"foo\"\n", "@use \"foo\"\n"] {
        std::fs::write(&entry, src).unwrap();
        assert_eq!(
            compile(src, &opts).expect("compile"),
            "l {\n  m: 1;\n}",
            "for {src:?}"
        );
    }
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn an_invalid_escape_resolves_like_the_parser_resolves_it() {
    // A surrogate escape becomes U+FFFD, so `@import\\D800` is NOT `@import`:
    // it is a generic at-rule, which may own a block. Stopping the decode at
    // the invalid code point reported the name's prefix and applied
    // `@import`'s "nothing may be indented" rule to it.
    assert_eq!(
        sass("@import\\D800 foo\n  a: b\n", "f.sass").unwrap(),
        "@charset \"UTF-8\";\n@import\u{FFFD}foo {\n  a: b;\n}"
    );
}

#[test]
fn a_multi_line_directive_prelude_keeps_its_own_lines() {
    // A prelude continuation is joined ON ITS OWN LINE, not with a space, so a
    // diagnostic inside it points at the line it was written on, as dart does.
    let cases = [
        "@each $a in\n  $undef\n  .x\n    y: 1\n",
        "$v:\n  $undef\n",
        "@if 1 ==\n  $undef\n  .x\n    y: 1\n",
    ];
    for src in cases {
        let e = sass(src, "in.sass").expect_err("expected an error");
        assert_eq!((e.line, e.col), (2, 3), "for {src:?}");
        assert!(e.message.contains("Undefined variable"), "{}", e.message);
    }
    // The prelude still reads the same text: a trailing comma does NOT
    // continue it (`@each $a in b,` iterates the one-element list `(b,)` and
    // the deeper lines are its body), exactly as dart-sass 1.103.1 reads it.
    assert_eq!(
        sass("@each $a in b,\n c\n  .#{$a}\n    d: $a\n", "in.sass").unwrap(),
        "c .b {\n  d: b;\n}"
    );
}

#[test]
fn a_custom_property_keeps_its_own_spacing() {
    // A custom property's value is emitted verbatim, so the whitespace after
    // the colon is part of it: dart writes `--v:1px` with no space, and
    // collapses a run of them to one. The front-end used to normalize every
    // spelling to `: `, which changed the CSS.
    assert_eq!(sass(".a\n  --v:1px\n", "a.sass").unwrap(), ".a {\n  --v:1px;\n}");
    assert_eq!(
        sass(".a\n  --v: 1px\n", "a.sass").unwrap(),
        ".a {\n  --v: 1px;\n}"
    );
    assert_eq!(
        sass(".a\n  --v:  1px\n", "a.sass").unwrap(),
        ".a {\n  --v: 1px;\n}"
    );
    assert_eq!(
        sass(".a\n  --v:   1px\n", "a.sass").unwrap(),
        ".a {\n  --v: 1px;\n}"
    );
    assert_eq!(
        sass(".a\n  --v:1px 2px\n", "a.sass").unwrap(),
        ".a {\n  --v:1px 2px;\n}"
    );
    assert_eq!(
        sass(".a\n  --v:#{1 + 1}\n", "a.sass").unwrap(),
        ".a {\n  --v:2;\n}"
    );
    // Whitespace BEFORE the colon is part of the line too: trimming it moved
    // the value a column left (dart reports 2:10 here, not 2:9).
    assert_eq!(
        sass(".a\n  --v : 1px\n", "a.sass").unwrap(),
        ".a {\n  --v: 1px;\n}"
    );
    let e = sass(".a\n  --v :#{$undef}\n", "f.sass").expect_err("expected an error");
    assert_eq!((e.line, e.col), (2, 10));
}

#[test]
fn compressed_output_is_unaffected_by_the_line_padding() {
    // The reconstruction pads with blank lines; compressed output has none.
    let opts = Options::default()
        .with_syntax(Syntax::Sass)
        .with_style(OutputStyle::Compressed)
        .with_url("in.sass");
    let css = compile("// c\n.a\n  b: c\n\n.d\n  e: f\n", &opts).expect("compile");
    assert_eq!(css, ".a{b:c}.d{e:f}");
}

#[test]
fn a_brace_inside_a_string_does_not_close_an_interpolation() {
    // The front-end scans a line to decide where a value ends. A `}` inside a
    // STRING is value text, not the end of the interpolation around it — and
    // the `//` that follows is inside the string too, not a comment. dart-sass
    // reads `.a` / `  b: #{"} // not a comment"}` as one declaration whose
    // value is `} // not a comment`.
    assert_eq!(
        sass(".a\n  b: #{\"} // not a comment\"}\n", "a.sass").expect("compile"),
        ".a {\n  b: } // not a comment;\n}"
    );
    // The same in a custom property, whose value is captured verbatim.
    assert_eq!(
        sass(".a\n  --x: #{\"}\"}y\n", "a.sass").expect("compile"),
        ".a {\n  --x: }y;\n}"
    );
    // (A `}` interpolated into a SELECTOR is an error in dart too — "expected
    // selector", against the interpolated output — so there is nothing to
    // preserve there.)
}

#[test]
fn an_escaped_delimiter_in_a_custom_value_is_literal_text() {
    // `\{` is an escaped brace — a complete custom-property value, not an open
    // block. Counting it as a bracket left the value "open", so every later
    // line was swallowed into it and the file ended mid-declaration.
    assert_eq!(
        sass(".a\n  --x: \\{\n.b\n  c: d\n", "a.sass").expect("compile"),
        ".a {\n  --x: \\{;\n}\n\n.b {\n  c: d;\n}"
    );
    // An escaped quote does not open a string either, and an escaped `;` is
    // part of the value rather than its terminator.
    assert_eq!(
        sass(".a\n  --x: \\\"\n.b\n  c: d\n", "a.sass").expect("compile"),
        ".a {\n  --x: \\\";\n}\n\n.b {\n  c: d;\n}"
    );
    assert_eq!(
        sass(".a\n  --x: a\\;b\n.b\n  c: d\n", "a.sass").expect("compile"),
        ".a {\n  --x: a\\;b;\n}\n\n.b {\n  c: d;\n}"
    );
    // A hex escape is one token however long it is, and dart re-serializes it
    // canonically: `\61 b` is the identifier `ab`.
    assert_eq!(
        sass(".a\n  --x: \\61 b\n", "a.sass").expect("compile"),
        ".a {\n  --x: ab;\n}"
    );
}

#[test]
fn a_mismatched_closer_in_a_custom_value_reaches_the_parser() {
    // `(]` is an error in dart, reported at the `]`. The front-end decides
    // where a custom value ENDS, and a net-depth count made `(]` look closed,
    // so an indented line under it was reported as a stray child instead.
    let e = sass(".a\n  --x: (]\n    b: c\n", "a.sass").expect_err("expected an error");
    assert_eq!((e.line, e.col), (2, 9));
    assert!(e.message.contains("expected \")\"."), "{}", e.message);
    // The same line with nothing under it reports identically.
    let e = sass(".a\n  --x: (]\n", "a.sass").expect_err("expected an error");
    assert_eq!((e.line, e.col), (2, 9));
    // A closer with NO opener ends the value where it stands, so the next line
    // is its own statement rather than a continuation.
    let e = sass(".a\n  --x: ]\n  b: c\n", "a.sass").expect_err("expected an error");
    assert_eq!((e.line, e.col), (2, 8));
    // A balanced multi-line value still joins.
    assert_eq!(
        sass(".a\n  --x: (1,\n    2)\n", "a.sass").expect("compile"),
        ".a {\n  --x: (1,\n    2);\n}"
    );
}

#[test]
fn an_import_url_spanning_lines_keeps_its_url() {
    // The url token's padding is not part of the url, so a `url(` opened on
    // one line and closed on another is the same import dart emits.
    assert_eq!(
        sass("@import url(\n  http://x/y.css\n)\n", "a.sass").expect("compile"),
        "@import url(http://x/y.css);"
    );
}

#[test]
fn a_backslash_continuation_is_not_a_line_wrap() {
    // The front-end used to drop a trailing backslash and join the next line
    // with a space, so `b: c\` + `d` compiled as `b: c d`. dart has no such
    // wrap: the backslash is an escape, and a newline is not something it can
    // escape, so the pair has to reach the parser for it to say so.
    for (src, line, col) in [
        (".a\n  b: c\\\n  d\n", 2, 8),
        (".a\n  b: c\\\n    d\n", 2, 8),
        ("@each $a in 1,\\\n  2\n  .x\n    y: $a\n", 1, 16),
        ("@import url(foo\\\nbar.css)\n", 1, 17),
    ] {
        let e = sass(src, "a.sass").expect_err("expected an error");
        assert_eq!((e.line, e.col), (line, col), "for {src:?}");
        assert!(e.message.contains("Expected escape sequence."), "{}", e.message);
    }
    // Inside a quoted string it stays a CSS line continuation, and the next
    // line's indentation is part of the string.
    assert_eq!(
        sass(".a\n  b: \"x\\\n  y\"\n", "a.sass").expect("compile"),
        ".a {\n  b: \"x  y\";\n}"
    );
}

#[test]
fn two_statements_on_one_line_point_at_the_second() {
    // dart carets the statement that should not be there — the first character
    // after the `;` — where sasso pointed at the `;` itself.
    for (src, line, col) in [
        (".a\n  b: c; d: e\n", 2, 9),
        (".a\n  b: c;d: e\n", 2, 8),
        (".a\n  b: c ; d: e\n", 2, 10),
        (".a\n  b: \"x;y\"; d: e\n", 2, 13),
        ("@import foo;bar\n", 1, 13),
        // An escaped `;` separates statements for dart too — the escape does
        // not hide it from the indented syntax's one-statement-per-line rule.
        ("@import foo\\;bar\n", 1, 14),
    ] {
        let e = sass(src, "a.sass").expect_err("expected an error");
        assert_eq!((e.line, e.col), (line, col), "for {src:?}");
        assert!(
            e.message.contains("multiple statements on one line"),
            "{}",
            e.message
        );
    }
    // A `;` with only whitespace or a loud comment after it is still one
    // statement.
    assert_eq!(
        sass(".a\n  b: c;\n", "a.sass").expect("compile"),
        ".a {\n  b: c;\n}"
    );
    assert_eq!(
        sass(".a\n  b: c;  \n", "a.sass").expect("compile"),
        ".a {\n  b: c;\n}"
    );
}

#[test]
fn a_custom_value_continues_past_a_trailing_backslash() {
    // The front-end decides where a custom-property value ends. A line ending
    // in an unpaired backslash always continues: inside a string that is a
    // legal CSS line continuation, and anywhere else it is the error dart
    // reports for one — either way the pair belongs to the parser, not to a
    // front-end that cut the value off at the line break.
    assert_eq!(
        sass(".a\n  --x: \"a\\\n    b\"\n", "a.sass").expect("compile"),
        ".a {\n  --x: \"a\\\n    b\";\n}"
    );
    let e = sass(".a\n  --x: c\\\n    d\n", "a.sass").expect_err("expected an error");
    assert_eq!((e.line, e.col), (2, 10));
    assert!(e.message.contains("Expected escape sequence."), "{}", e.message);
    // An EVEN number of backslashes is a complete value: the last one is
    // escaped, not an escape.
    let e = sass(".a\n  --x: c\\\\\n    d\n", "a.sass").expect_err("expected an error");
    assert!(
        e.message
            .contains("Nothing may be indented beneath a custom property"),
        "{}",
        e.message
    );
}

#[test]
fn a_second_statement_after_a_continuation_reports_its_own_line() {
    // A logical line can span several source lines — a bracket continuation
    // keeps its line breaks — so the `;` that splits it can be far below the
    // line the statement started on. It used to report the statement's first
    // line with a column counting every character before the `;`.
    let e = sass(".a\n  b: (\n    c\n  ); d: e\n", "a.sass").expect_err("expected an error");
    assert_eq!((e.line, e.col), (4, 6));
    assert!(
        e.message.contains("multiple statements on one line"),
        "{}",
        e.message
    );
    // A statement that occupies one line is unchanged.
    let e = sass(".a\n  b: c; d: e\n", "a.sass").expect_err("expected an error");
    assert_eq!((e.line, e.col), (2, 9));
}

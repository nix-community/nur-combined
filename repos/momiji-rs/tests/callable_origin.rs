//! A mixin, function, or `@content` block runs against the file that wrote
//! it (dart-sass evaluates a callable where it was defined): its output maps
//! to that file, and its diagnostics name that file and render its source —
//! whether it was reached through `@use`, a textual `@import`, or a
//! first-class reference. A content block belongs to the file of the
//! `@include` that wrote it, not to the mixin's.

use std::cell::RefCell;
use std::path::PathBuf;
use std::rc::Rc;

use sasso::{
    compile, compile_with_source_map, CanonicalUrl, CanonicalizeContext, FsImporter, Importer, ImporterError,
    ImporterResult, Options, Syntax, WarnEvent,
};

const DEP: &str = "@mixin m {\n  x: 1;\n  @content;\n  z: 3;\n}\n@function f($v) {\n  @warn \"in f\";\n  @return $v + 1;\n}\n@mixin undef {\n  q: $nope;\n}\n";
const IMP: &str = "@import \"dep\";\na {\n  @include m {\n    @warn \"in content\";\n    y: f(1);\n  }\n}\n";

fn scratch(tag: &str) -> PathBuf {
    let dir = std::env::temp_dir().join(format!("sasso_origin_{tag}_{}", std::process::id()));
    std::fs::create_dir_all(dir.join("src")).expect("mkdir");
    std::fs::write(dir.join("src/_dep.scss"), DEP).unwrap();
    dir
}

/// The canonical url `FsImporter` keys a resolved file by: the absolute path
/// as it was reached, with the ASCII case folding `absolute_normalized` applies
/// on Windows (dart's `Style.windows` canonicalizes each part, and that
/// filesystem is case-insensitive).
fn canon_key(p: std::path::PathBuf) -> String {
    // `PathBuf::push` does not respell `/` as the platform separator, so a
    // `join("src/imp.scss")` keeps its `/` on Windows while the importer's key,
    // built from the real path, uses `\`. Re-collecting the components respells
    // it the way the platform does.
    let p: std::path::PathBuf = p.components().collect();
    let s = p.to_string_lossy().into_owned();
    #[cfg(windows)]
    let s = s.to_lowercase();
    s
}

fn canon(dir: &std::path::Path, rel: &str) -> String {
    canon_key(dir.join(rel))
}

/// A path fragment as a LOADED file's frame spells it: the importer reached the
/// file through the filesystem, so on Windows it is `\`-separated. An ENTRY is
/// echoed as it was given instead — the urls here are built with a `/` and keep
/// it — so entry fragments are deliberately NOT respelled.
fn loaded(frag: &str) -> String {
    if cfg!(windows) {
        frag.replace('/', "\\")
    } else {
        frag.to_string()
    }
}

#[test]
fn imported_callable_output_maps_to_its_file_and_content_to_the_includers() {
    // dart: sources [imp.scss, _dep.scss], mappings `AACA;ECAE;EDGE;ECDF` —
    // `x: 1` and `z: 3` in the mixin's file, `y: f(1)` (the content block)
    // back in the entry.
    let dir = scratch("map");
    let entry = dir.join("src/imp.scss");
    std::fs::write(&entry, IMP).unwrap();
    let url = entry.to_string_lossy().into_owned();
    let imp = FsImporter::new(Vec::new());
    let opts = Options::default().with_importer(&imp).with_url(&url);
    let r = compile_with_source_map(IMP, &opts).unwrap();
    assert_eq!(r.css, "a {\n  x: 1;\n  y: 2;\n  z: 3;\n}");
    assert_eq!(r.source_map.sources, [url.clone(), canon(&dir, "src/_dep.scss")]);
    assert_eq!(r.source_map.mappings, "AACA;ECAE;EDGE;ECDF");
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn warn_events_inside_callables_carry_the_defining_file() {
    let dir = scratch("warn");
    let entry = dir.join("src/imp.scss");
    std::fs::write(&entry, IMP).unwrap();
    let url = entry.to_string_lossy().into_owned();
    // (message, url, path, formatted) per non-deprecation event.
    type Seen = Vec<(String, String, String, String)>;
    let seen: Rc<RefCell<Seen>> = Rc::new(RefCell::new(Vec::new()));
    let sink = Rc::clone(&seen);
    let imp = FsImporter::new(Vec::new());
    let opts = Options::default()
        .with_importer(&imp)
        .with_url(&url)
        .with_warn_handler(Rc::new(move |ev: &WarnEvent<'_>| {
            if !ev.deprecation {
                sink.borrow_mut().push((
                    ev.message.to_string(),
                    ev.url.to_string(),
                    ev.path.to_string(),
                    ev.formatted.to_string(),
                ));
            }
        }));
    compile(IMP, &opts).expect("compile");
    let events = seen.borrow();
    let dep = canon(&dir, "src/_dep.scss");
    // The content block's `@warn` is the entry's: path = entry, and the
    // innermost frame is the `@content` member in the entry, then the
    // `@content;` statement in the mixin (m(), line 3), then the include.
    let content = events.iter().find(|e| e.0 == "in content").expect("content warn");
    assert_eq!(content.2, url);
    assert_eq!(content.1, url, "display url of the entry is its url as given");
    // (Frames are column-aligned, so match the fields, not the padding.)
    assert!(
        content.3.contains("src/imp.scss 4:5") && content.3.contains("  @content\n"),
        "{}",
        content.3
    );
    assert!(
        content.3.contains(&loaded("src/_dep.scss 3:3")) && content.3.contains("  m()\n"),
        "{}",
        content.3
    );
    // The function's `@warn` is the dependency's: path = its resolved file,
    // url = its display path, member f().
    let f = events.iter().find(|e| e.0 == "in f").expect("f warn");
    assert_eq!(f.2, dep);
    assert!(
        std::path::Path::new(&f.1).ends_with("src/_dep.scss"),
        "url {:?}",
        f.1
    );
    assert!(
        f.3.contains(&loaded("src/_dep.scss 7:3")) && f.3.contains("  f()\n"),
        "{}",
        f.3
    );
    drop(events);
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn error_inside_an_imported_mixin_renders_its_source() {
    // dart: the snippet shows `q: $nope;` from _dep.scss with the frame
    // `_dep.scss 11:6  undef()`, then the include site in the entry.
    let dir = scratch("err");
    let entry = dir.join("src/undef.scss");
    let src = "@import \"dep\";\na {\n  @include undef;\n}\n";
    std::fs::write(&entry, src).unwrap();
    let url = entry.to_string_lossy().into_owned();
    let imp = FsImporter::new(Vec::new());
    let opts = Options::default().with_importer(&imp).with_url(&url);
    let err = compile(src, &opts).expect_err("undefined variable").to_string();
    assert!(err.starts_with("Error: Undefined variable.\n"), "{err}");
    assert!(err.contains("11 │   q: $nope;\n"), "{err}");
    assert!(
        err.contains(&loaded("src/_dep.scss 11:6")) && err.contains("  undef()\n"),
        "{err}"
    );
    assert!(
        err.contains("src/undef.scss 3:3") && err.trim_end().ends_with("  root stylesheet"),
        "{err}"
    );
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn meta_call_resolves_namespaces_at_the_definition_site() {
    // A function invoked through `meta.call` runs against its own `@use`
    // namespaces (dart: `b: 7px`), not the caller's — which has no `math`.
    let dir = scratch("call_ns");
    std::fs::write(
        dir.join("src/_lib.scss"),
        "@use \"sass:math\";\n@use \"sass:string\" as s;\n@function half($v) {\n  @return math.div($v, 2) + s.length(\"ab\");\n}\n",
    )
    .unwrap();
    let entry = dir.join("src/main.scss");
    let src = "@use \"sass:meta\";\n@use \"lib\";\na {\n  b: meta.call(meta.get-function(\"half\", $module: \"lib\"), 10px);\n}\n";
    std::fs::write(&entry, src).unwrap();
    let url = entry.to_string_lossy().into_owned();
    let imp = FsImporter::new(Vec::new());
    let opts = Options::default().with_importer(&imp).with_url(&url);
    assert_eq!(compile(src, &opts).expect("compile"), "a {\n  b: 7px;\n}");
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn members_forwarded_through_an_import_keep_their_namespaces() {
    // `@import "fwd"` over `@forward "dep"`: the members join the importer's
    // scope, but their bodies still resolve `math.div` and the `h.` alias
    // through _dep.scss's own `@use`s (dart: `b: 11px; padding: 2px 2px`).
    let dir = scratch("fwd_ns");
    std::fs::write(
        dir.join("src/_helpers.scss"),
        "$unit: 1px;\n@function twice($v) {\n  @return $v * 2;\n}\n",
    )
    .unwrap();
    std::fs::write(
        dir.join("src/_lib.scss"),
        "@use \"sass:math\";\n@use \"helpers\" as h;\n$scale: 3;\n@function half($v) {\n  @return math.div($v, 2) + h.twice(h.$unit) * $scale;\n}\n@mixin pad($v) {\n  padding: math.div($v, 2) h.twice(1px);\n}\n",
    )
    .unwrap();
    std::fs::write(dir.join("src/_fwd.scss"), "@forward \"lib\";\n").unwrap();
    let entry = dir.join("src/main.scss");
    let src = "@import \"fwd\";\na {\n  b: half(10px);\n  @include pad(4px);\n}\n";
    std::fs::write(&entry, src).unwrap();
    let url = entry.to_string_lossy().into_owned();
    let imp = FsImporter::new(Vec::new());
    let opts = Options::default()
        .with_importer(&imp)
        .with_url(&url)
        .with_warn_handler(Rc::new(|_: &WarnEvent<'_>| {}));
    assert_eq!(
        compile(src, &opts).expect("compile"),
        "a {\n  b: 11px;\n  padding: 2px 2px;\n}"
    );
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn url_less_entry_keeps_its_identity_across_callables() {
    // An entry compiled without `Options::url` has the empty display url and
    // path. Its content block passed to a module mixin, and its own mixin
    // included from inside an imported file, still run as the entry: their
    // `@warn` events report the entry's empty `url`/`path`, not the module's.
    let dir = scratch("nourl");
    std::fs::write(
        dir.join("src/_mod.scss"),
        "@mixin m {\n  x: 1;\n  @content;\n}\n@mixin call-back {\n  @include from-entry;\n}\n",
    )
    .unwrap();
    let src = "@use \"mod\";\n@mixin from-entry {\n  @warn \"entry mixin\";\n  y: 2;\n}\na {\n  @include mod.m {\n    @warn \"entry content\";\n  }\n}\n";
    // (message, url, path) per non-deprecation event.
    type Seen = Vec<(String, String, String)>;
    let seen: Rc<RefCell<Seen>> = Rc::new(RefCell::new(Vec::new()));
    let sink = Rc::clone(&seen);
    let imp = FsImporter::new(vec![dir.join("src")]);
    let opts =
        Options::default()
            .with_importer(&imp)
            .with_warn_handler(Rc::new(move |ev: &WarnEvent<'_>| {
                if !ev.deprecation {
                    sink.borrow_mut()
                        .push((ev.message.to_string(), ev.url.to_string(), ev.path.to_string()));
                }
            }));
    let css = compile(src, &opts).expect("compile");
    assert_eq!(css, "a {\n  x: 1;\n}");
    let events = seen.borrow();
    let content = events
        .iter()
        .find(|e| e.0 == "entry content")
        .expect("content warn");
    assert_eq!(
        (content.1.as_str(), content.2.as_str()),
        ("", ""),
        "content block is the entry's"
    );
    drop(events);
    // The other direction: the entry's mixin, included from inside an
    // imported file's mixin, runs as the entry again.
    std::fs::write(
        dir.join("src/_imp.scss"),
        "@mixin call-back {\n  z: 3;\n  @include from-entry;\n}\n",
    )
    .unwrap();
    let src2 = "@import \"imp\";\n@mixin from-entry {\n  @warn \"entry mixin\";\n  y: 2;\n}\na {\n  @include call-back;\n}\n";
    seen.borrow_mut().clear();
    let css = compile(src2, &opts).expect("compile");
    assert_eq!(css, "a {\n  z: 3;\n  y: 2;\n}");
    let events = seen.borrow();
    let mixin = events
        .iter()
        .find(|e| e.0 == "entry mixin")
        .expect("entry mixin warn");
    assert_eq!(
        (mixin.1.as_str(), mixin.2.as_str()),
        ("", ""),
        "entry mixin is the entry's"
    );
    drop(events);
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn module_callables_know_whether_they_are_a_mixin() {
    // `meta.content-exists()` answers for the include at hand inside a
    // `@use`d module's mixin (dart: `has: content` / `has: none`), and errors
    // inside a module function even when a mixin with a content block called
    // it — the same rules as the direct include and call paths.
    let dir = scratch("in_mixin");
    std::fs::write(
        dir.join("src/_lib.scss"),
        "@use \"sass:meta\";\n@mixin m {\n  @if meta.content-exists() {\n    has: content;\n    @content;\n  } @else {\n    has: none;\n  }\n}\n@function probe() {\n  @return meta.content-exists();\n}\n",
    )
    .unwrap();
    let entry = dir.join("src/main.scss");
    let url = entry.to_string_lossy().into_owned();
    let imp = FsImporter::new(Vec::new());
    let opts = Options::default().with_importer(&imp).with_url(&url);
    let src = "@use \"lib\";\na {\n  @include lib.m {\n    b: 1;\n  }\n}\nc {\n  @include lib.m;\n}\n";
    std::fs::write(&entry, src).unwrap();
    assert_eq!(
        compile(src, &opts).expect("compile"),
        "a {\n  has: content;\n  b: 1;\n}\n\nc {\n  has: none;\n}"
    );
    let src = "@use \"lib\";\n@mixin wrap {\n  x: lib.probe();\n  @content;\n}\na {\n  @include wrap {\n    b: 1;\n  }\n}\n";
    std::fs::write(&entry, src).unwrap();
    let err = compile(src, &opts).expect_err("not in a mixin").to_string();
    assert!(
        err.starts_with("Error: content-exists() may only be called within a mixin.\n"),
        "{err}"
    );
    // Match the frame with its whitespace collapsed: the trace pads its
    // location column to the widest frame, and which frame that is depends on
    // where the scratch tree sits relative to the process's working directory.
    // A build sandbox that puts $TMPDIR above the cwd (Nix uses /build and
    // /build/source) renders this frame relative and the entry's absolute, so
    // the gap here is not always two spaces.
    let frame = err
        .lines()
        .find(|l| l.contains("_lib.scss 11:11"))
        .map(|l| l.split_whitespace().collect::<Vec<_>>().join(" "))
        .unwrap_or_default();
    assert!(frame.ends_with("_lib.scss 11:11 probe()"), "{err}");
    std::fs::remove_dir_all(&dir).ok();
}

/// Two virtual modules whose canonical URLs share a last segment, so both
/// display as `foo` in diagnostics.
struct SameNameImporter;

impl Importer for SameNameImporter {
    fn canonicalize(
        &self,
        url: &str,
        _ctx: &CanonicalizeContext<'_>,
    ) -> Result<Option<CanonicalUrl>, ImporterError> {
        Ok(match url {
            "a" => Some(CanonicalUrl::new("custom://a/foo")),
            "b" => Some(CanonicalUrl::new("custom://b/foo")),
            _ => None,
        })
    }

    fn load(&self, canonical: &CanonicalUrl) -> Result<Option<ImporterResult>, ImporterError> {
        let contents = match canonical.as_str() {
            "custom://a/foo" => {
                "@mixin ma {\n  p: $nope;\n}\n@mixin boom {\n  @error \"boom\";\n}\n@mixin need($x) {\n  p: $x;\n}\n"
            }
            "custom://b/foo" => {
                "@use \"a\";\n@mixin mb {\n\n\n  q: $nope;\n}\n@mixin via-a {\n\n\n\n\n  @include a.boom;\n}\n@mixin via-ma {\n  @include a.ma;\n}\n@mixin via-need {\n  @include a.need;\n}\n"
            }
            _ => return Ok(None),
        };
        Ok(Some(ImporterResult {
            contents: contents.to_string(),
            syntax: Syntax::Scss,
            source_map_url: None,
        }))
    }
}

#[test]
fn custom_importer_modules_sharing_a_display_name_render_their_own_source() {
    // The display name `foo` is ambiguous; the callable's origin carries its
    // own source, so an error inside `a.ma` shows A's text (line 2), not B's,
    // even though B was registered under `foo` last.
    let imp = SameNameImporter;
    let opts = Options::default().with_importer(&imp).with_url("entry.scss");
    let err = compile("@use \"a\";\n@use \"b\";\nx {\n  @include a.ma;\n}\n", &opts)
        .expect_err("undefined variable")
        .to_string();
    assert!(err.contains("2 │   p: $nope;\n"), "{err}");
    assert!(err.contains("foo 2:6"), "{err}");
    assert!(!err.contains("q: $nope"), "{err}");
    // And the other way round: an `@error` in A's mixin, included from B's
    // mixin, attaches at B's `@include a.boom` (line 12 of B) — the frame
    // carries B's text, so the snippet is B's line, not A's.
    let err = compile("@use \"b\";\nx {\n  @include b.via-a;\n}\n", &opts)
        .expect_err("boom")
        .to_string();
    assert!(err.starts_with("Error: \"boom\"\n"), "{err}");
    assert!(err.contains("12 │   @include a.boom;\n"), "{err}");
    assert!(err.contains("foo 12:3"), "{err}");
    // Nested: B loads A while B itself displays as `foo`, so A is evaluated
    // (and its callables capture their origin) with the loader already named
    // `foo`. A's mixin must still carry A's text: `p: $nope` on A's line 2,
    // not B's line 2.
    let opts = Options::default().with_importer(&imp).with_url("entry.scss");
    let err = compile("@use \"b\";\nx {\n  @include b.via-ma;\n}\n", &opts)
        .expect_err("undefined variable")
        .to_string();
    assert!(err.contains("2 │   p: $nope;\n"), "{err}");
    assert!(err.contains("foo 2:6"), "{err}");
    assert!(!err.contains("@mixin mb"), "{err}");
}

#[test]
fn using_defaults_evaluate_where_the_block_was_written() {
    // `@include dep.m using ($x, $y: $caller)`: `@content(1)` supplies `$x` from
    // the mixin, and the default for `$y` evaluates in the INCLUDER's file —
    // dart: `b: 3` — so a default naming the module's own `$inner` is an
    // undefined variable there, reported under the `@content` member.
    let dir = scratch("using_defaults");
    std::fs::write(
        dir.join("src/_dep.scss"),
        "$inner: 100;\n@mixin m {\n  @content(1);\n}\n",
    )
    .unwrap();
    let entry = dir.join("src/main.scss");
    let url = entry.to_string_lossy().into_owned();
    let imp = FsImporter::new(Vec::new());
    let opts = Options::default().with_importer(&imp).with_url(&url);
    let src = "@use \"dep\";\n$caller: 2;\na {\n  @include dep.m using ($x, $y: $caller) {\n    b: $x + $y;\n  }\n}\n";
    std::fs::write(&entry, src).unwrap();
    assert_eq!(compile(src, &opts).expect("compile"), "a {\n  b: 3;\n}");
    let src = "@use \"dep\";\na {\n  @include dep.m using ($x, $y: $inner) {\n    b: $x + $y;\n  }\n}\n";
    std::fs::write(&entry, src).unwrap();
    let err = compile(src, &opts).expect_err("undefined variable").to_string();
    assert!(err.starts_with("Error: Undefined variable.\n"), "{err}");
    assert!(
        err.contains("3 │   @include dep.m using ($x, $y: $inner) {\n"),
        "{err}"
    );
    assert!(
        err.contains("main.scss 3:33") && err.contains("  @content\n"),
        "{err}"
    );
    std::fs::remove_dir_all(&dir).ok();
}

#[test]
fn a_cross_module_capture_renders_its_own_module_source() {
    // A mixin captured from another module with `meta.get-mixin($module:)` and
    // invoked through `meta.apply` runs against the file it was WRITTEN in,
    // which it carries with it. Both modules here display as `foo`, so a
    // snippet fetched by that display name would come from whichever was
    // registered last — B's line 2 instead of A's.
    let imp = SameNameImporter;
    let opts = Options::default().with_importer(&imp).with_url("entry.scss");
    let src = "@use \"sass:meta\";\n@use \"a\";\n@use \"b\";\nx {\n  @include meta.apply(meta.get-mixin(\"ma\", $module: \"a\"));\n}\n";
    let err = compile(src, &opts).expect_err("undefined variable").to_string();
    assert!(err.contains("2 │   p: $nope;\n"), "{err}");
    assert!(!err.contains("@mixin mb"), "{err}");
    assert!(err.contains("foo 2:6"), "{err}");
}

#[test]
fn a_two_span_error_keeps_files_that_share_a_display_name_apart() {
    // `Missing argument` points at the call AND at the declaration it was
    // measured against. Here they are in DIFFERENT files that both display as
    // `foo`, so grouping the two spans by display name alone would draw the
    // declaration against the caller's lines. Each keeps its own block and its
    // own text. (The block SHAPE is locked against dart by
    // `tests/diagnostics.rs`; a custom importer is not reproducible in the dart
    // CLI, so this test locks only the identity.)
    let imp = SameNameImporter;
    let opts = Options::default().with_importer(&imp).with_url("entry.scss");
    let err = compile("@use \"b\";\nx {\n  @include b.via-need;\n}\n", &opts)
        .expect_err("missing argument")
        .to_string();
    assert!(err.starts_with("Error: Missing argument $x.\n"), "{err}");
    // Two blocks, each headed by the name the two files share.
    assert_eq!(err.matches("\u{250c}\u{2500}\u{2500}> foo\n").count(), 2, "{err}");
    // The invocation is B's line 18, the declaration A's line 7 — and each is
    // rendered from ITS file, so neither block shows the other's text.
    assert!(err.contains("18 \u{2502}   @include a.need;\n"), "{err}");
    assert!(err.contains("7 \u{2502} @mixin need($x) {\n"), "{err}");
    assert!(!err.contains("@mixin via-need"), "{err}");
}

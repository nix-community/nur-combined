//! `WarnEvent::path`: the stylesheet a diagnostic came from, as an identity —
//! for a file the importer loaded, the importer's canonical URL (the resolved
//! absolute path with `FsImporter`); for the entry stylesheet, `Options::url`
//! exactly as supplied. That is what a CLI needs to tell a load-path
//! dependency from the entry (dart-sass `--quiet-deps`), since
//! `WarnEvent::url` is dart's short display form (a load-path file's basename).

use std::cell::RefCell;
use std::path::PathBuf;
use std::rc::Rc;

use sasso::{compile, FsImporter, Options, WarnEvent};

/// The canonical url `FsImporter` keys a resolved file by: the absolute path
/// as it was reached, with the ASCII case folding `absolute_normalized` applies
/// on Windows (dart's `Style.windows` canonicalizes each part, and that
/// filesystem is case-insensitive).
fn canon_key(p: std::path::PathBuf) -> String {
    // `PathBuf::push` does not respell `/` as the platform separator, so a
    // `join("lp/_dep.scss")` keeps its `/` on Windows while the importer's key,
    // built from the real path, uses `\`. Re-collecting the components respells
    // it the way the platform does.
    let p: std::path::PathBuf = p.components().collect();
    let s = p.to_string_lossy().into_owned();
    #[cfg(windows)]
    let s = s.to_lowercase();
    s
}

fn scratch() -> PathBuf {
    let dir = std::env::temp_dir().join(format!("sasso_warn_path_{}", std::process::id()));
    std::fs::create_dir_all(dir.join("lp")).expect("mkdir");
    dir
}

#[test]
fn warn_event_path_is_the_resolved_file_path() {
    let dir = scratch();
    let entry = dir.join("entry.scss");
    std::fs::write(&entry, "@import \"dep\";\n@warn \"from entry\";\n").unwrap();
    std::fs::write(
        dir.join("lp/_dep.scss"),
        "@import \"dep2\";\n@warn \"from dep\";\n",
    )
    .unwrap();
    std::fs::write(dir.join("lp/_dep2.scss"), "e { f: 2; }\n").unwrap();

    // (message, deprecation?, url, path) per event.
    type Seen = Vec<(String, bool, String, String)>;
    let seen: Rc<RefCell<Seen>> = Rc::new(RefCell::new(Vec::new()));
    let sink = Rc::clone(&seen);
    let importer = FsImporter::new(vec![dir.join("lp")]);
    let url = entry.to_string_lossy().into_owned();
    let opts = Options::default()
        .with_importer(&importer)
        .with_url(&url)
        .with_warn_handler(Rc::new(move |ev: &WarnEvent<'_>| {
            sink.borrow_mut().push((
                ev.message.to_string(),
                ev.deprecation,
                ev.url.to_string(),
                ev.path.to_string(),
            ));
        }));
    let src = std::fs::read_to_string(&entry).unwrap();
    compile(&src, &opts).expect("compile");
    let events = seen.borrow();

    let dep_canon = canon_key(dir.join("lp/_dep.scss"));
    // The entry's own @import deprecation: path is the entry (as given).
    let entry_dep = events
        .iter()
        .find(|(m, d, _, _)| *d && m.contains("@import"))
        .expect("entry deprecation");
    assert_eq!(entry_dep.3, url, "entry deprecation carries the entry path");
    // The dependency's @import deprecation: display url is the file's path,
    // path is the resolved file.
    let dep_dep = events
        .iter()
        .filter(|(m, d, _, _)| *d && m.contains("@import"))
        .nth(1)
        .expect("dependency deprecation");
    // The display url is dart's `prettyUri`: the path from the current directory
    // (or absolute when that would be longer) — not a bare basename.
    assert!(
        std::path::Path::new(&dep_dep.2).ends_with("lp/_dep.scss") && dep_dep.2 != "_dep.scss",
        "display url is the file's path, got {:?}",
        dep_dep.2
    );
    assert_eq!(dep_dep.3, dep_canon, "path is the resolved load-path file");
    // @warn from the dependency and from the entry.
    let w_dep = events
        .iter()
        .find(|(m, ..)| m == "from dep")
        .expect("@warn from dep");
    assert_eq!(w_dep.3, dep_canon);
    // A `@warn` event carries the same display url as its stack frame.
    assert_eq!(w_dep.2, dep_dep.2, "@warn url is the file's display path");
    let w_entry = events
        .iter()
        .find(|(m, ..)| m == "from entry")
        .expect("@warn from entry");
    assert_eq!(w_entry.3, url);
    drop(events);
    std::fs::remove_dir_all(&dir).ok();
}

/// `FsImporter::dependencies()`: dart's rule is about how a file was resolved.
/// Through a load path -> dependency; relatively from a dependency ->
/// dependency; relatively from the entry -> not one, even inside the load-path
/// directory.
#[test]
fn fs_importer_tracks_load_path_dependencies() {
    let dir = std::env::temp_dir().join(format!("sasso_dep_set_{}", std::process::id()));
    std::fs::create_dir_all(dir.join("lp")).expect("mkdir");
    let entry = dir.join("entry.scss");
    // `@use` first (must precede other rules), then the load-path import.
    std::fs::write(&entry, "@use \"lp/rel\";\n@import \"dep\";\n").unwrap();
    std::fs::write(dir.join("lp/_rel.scss"), "q { r: 1; }\n").unwrap();
    std::fs::write(dir.join("lp/_dep.scss"), "@import \"dep-child\";\n").unwrap();
    std::fs::write(dir.join("lp/_dep-child.scss"), "s { t: 1; }\n").unwrap();

    let importer = FsImporter::new(vec![dir.join("lp")]);
    let deps = importer.dependencies();
    let url = entry.to_string_lossy().into_owned();
    let opts = Options::default()
        .with_importer(&importer)
        .with_url(&url)
        .with_warn_handler(Rc::new(|_: &WarnEvent<'_>| {}));
    compile(&std::fs::read_to_string(&entry).unwrap(), &opts).expect("compile");

    let canon = |rel: &str| canon_key(dir.join(rel));
    assert!(
        !deps.is_dependency(&canon("lp/_rel.scss")),
        "resolved relative to the entry"
    );
    assert!(
        deps.is_dependency(&canon("lp/_dep.scss")),
        "resolved through the load path"
    );
    assert!(
        deps.is_dependency(&canon("lp/_dep-child.scss")),
        "loaded relatively FROM a dependency"
    );
    assert!(!deps.is_dependency(&url), "the entry is never a dependency");
    std::fs::remove_dir_all(&dir).ok();
}

/// `with_quiet_deps` is per compilation: reusing one importer (and its set)
/// for a second compile must not carry over what the first one classified.
#[test]
fn quiet_deps_record_is_per_compilation_even_with_a_reused_importer() {
    let dir = std::env::temp_dir().join(format!("sasso_dep_reuse_{}", std::process::id()));
    std::fs::create_dir_all(dir.join("lp")).expect("mkdir");
    std::fs::write(dir.join("lp/_dep.scss"), "@import \"leaf\";\n").unwrap();
    std::fs::write(dir.join("lp/_leaf.scss"), "q { r: 1; }\n").unwrap();
    let a = dir.join("a.scss");
    let b = dir.join("b.scss");
    std::fs::write(&a, "@import \"dep\";\n").unwrap(); // via the load path: a dependency
    std::fs::write(&b, "@use \"lp/dep\";\n").unwrap(); // relative: not one

    let importer = FsImporter::new(vec![dir.join("lp")]);
    let deps = importer.dependencies();
    let seen: Rc<RefCell<Vec<String>>> = Rc::new(RefCell::new(Vec::new()));
    let sink = Rc::clone(&seen);
    let handler: sasso::WarnHandler = Rc::new(move |ev: &WarnEvent<'_>| {
        if ev.deprecation {
            sink.borrow_mut().push(ev.path.to_string());
        }
    });
    let dep_canon = canon_key(dir.join("lp/_dep.scss"));

    let url_a = a.to_string_lossy().into_owned();
    let opts_a = Options::default()
        .with_importer(&importer)
        .with_url(&url_a)
        .with_quiet_deps(deps.clone())
        .with_warn_handler(Rc::clone(&handler));
    compile(&std::fs::read_to_string(&a).unwrap(), &opts_a).expect("compile a");
    assert!(
        deps.is_dependency(&dep_canon),
        "reached through the load path in compile a"
    );
    assert_eq!(
        seen.borrow().len(),
        1,
        "only a's own @import warns; the dependency's is silenced"
    );

    seen.borrow_mut().clear();
    let url_b = b.to_string_lossy().into_owned();
    let opts_b = Options::default()
        .with_importer(&importer)
        .with_url(&url_b)
        .with_quiet_deps(deps.clone())
        .with_warn_handler(Rc::clone(&handler));
    compile(&std::fs::read_to_string(&b).unwrap(), &opts_b).expect("compile b");
    assert!(
        !deps.is_dependency(&dep_canon),
        "compile b starts from an empty record"
    );
    assert_eq!(
        *seen.borrow(),
        vec![dep_canon.clone()],
        "the relatively-loaded file's @import warns in compile b"
    );
    std::fs::remove_dir_all(&dir).ok();
}

/// The evaluator caches textual `@import` resolution per (url, base dir), so
/// the importer — where provenance is recorded — is skipped on a hit. A file
/// first imported from a non-dependency and later from a dependency must still
/// become a dependency on that second, cached load.
#[test]
fn dependency_provenance_survives_the_import_cache() {
    let dir = std::env::temp_dir().join(format!("sasso_dep_cache_{}", std::process::id()));
    std::fs::create_dir_all(dir.join("lp")).expect("mkdir");
    std::fs::write(dir.join("lp/_a.scss"), "@import \"x\";\n").unwrap(); // reached relatively: not a dependency
    std::fs::write(dir.join("lp/_b.scss"), "@import \"x\";\n").unwrap(); // reached through -I lp: a dependency
    std::fs::write(dir.join("lp/_x.scss"), "q { r: 1; }\n").unwrap();
    let entry = dir.join("entry.scss");
    std::fs::write(&entry, "@import \"lp/a\";\n@import \"b\";\n").unwrap();
    let importer = FsImporter::new(vec![dir.join("lp")]);
    let deps = importer.dependencies();
    let url = entry.to_string_lossy().into_owned();
    let opts = Options::default()
        .with_importer(&importer)
        .with_url(&url)
        .with_quiet_deps(deps.clone())
        .with_warn_handler(Rc::new(|_: &WarnEvent<'_>| {}));
    compile(&std::fs::read_to_string(&entry).unwrap(), &opts).expect("compile");
    let canon = |rel: &str| canon_key(dir.join(rel));
    assert!(!deps.is_dependency(&canon("lp/_a.scss")));
    assert!(deps.is_dependency(&canon("lp/_b.scss")));
    assert!(
        deps.is_dependency(&canon("lp/_x.scss")),
        "x was loaded from b (a dependency) via the import cache"
    );
    std::fs::remove_dir_all(&dir).ok();
}

/// A warn handler may run a nested `compile` with the same importer and set.
/// The nested compile starts from an empty record and, when it ends, hands the
/// outer compile's record back — so the outer compile's later dependency
/// deprecations are still silenced and its record is not polluted.
#[test]
fn quiet_deps_record_is_reentrant_across_a_nested_compile() {
    let dir = std::env::temp_dir().join(format!("sasso_dep_nested_{}", std::process::id()));
    std::fs::create_dir_all(dir.join("lp")).expect("mkdir");
    // Outer dependency: warns (which triggers the nested compile), THEN imports.
    std::fs::write(dir.join("lp/_dep.scss"), "@warn \"nest\";\n@import \"leaf\";\n").unwrap();
    std::fs::write(dir.join("lp/_leaf.scss"), "q { r: 1; }\n").unwrap();
    // Nested entry: reaches a different dependency.
    std::fs::write(dir.join("lp/_other.scss"), "@import \"leaf\";\n").unwrap();
    let inner_entry = dir.join("inner.scss");
    std::fs::write(&inner_entry, "@import \"other\";\n").unwrap();
    let outer_entry = dir.join("outer.scss");
    std::fs::write(&outer_entry, "@import \"dep\";\n").unwrap();

    let importer = Rc::new(FsImporter::new(vec![dir.join("lp")]));
    let deps = importer.dependencies();
    let outer_deprecations: Rc<RefCell<Vec<String>>> = Rc::new(RefCell::new(Vec::new()));
    let sink = Rc::clone(&outer_deprecations);
    let nested_importer = Rc::clone(&importer);
    let nested_deps = deps.clone();
    let nested_url = inner_entry.to_string_lossy().into_owned();
    let nested_src = std::fs::read_to_string(&inner_entry).unwrap();
    let handler: sasso::WarnHandler = Rc::new(move |ev: &WarnEvent<'_>| {
        if ev.deprecation {
            sink.borrow_mut().push(ev.path.to_string());
        } else if ev.message == "nest" {
            let opts = Options::default()
                .with_importer(&*nested_importer)
                .with_url(&nested_url)
                .with_quiet_deps(nested_deps.clone())
                .with_warn_handler(Rc::new(|_: &WarnEvent<'_>| {}));
            compile(&nested_src, &opts).expect("nested compile");
        }
    });
    let url = outer_entry.to_string_lossy().into_owned();
    let opts = Options::default()
        .with_importer(&*importer)
        .with_url(&url)
        .with_quiet_deps(deps.clone())
        .with_warn_handler(handler);
    compile(&std::fs::read_to_string(&outer_entry).unwrap(), &opts).expect("outer compile");

    let canon = |rel: &str| canon_key(dir.join(rel));
    // Only the outer entry's own @import reached the handler: dep's @import
    // (fired AFTER the nested compile returned) was still silenced.
    assert_eq!(*outer_deprecations.borrow(), vec![url.clone()]);
    assert!(
        deps.is_dependency(&canon("lp/_dep.scss")),
        "outer record intact after the nested compile"
    );
    assert!(
        !deps.is_dependency(&canon("lp/_other.scss")),
        "the nested compile's record did not leak into the outer one"
    );
    std::fs::remove_dir_all(&dir).ok();
}

/// The per-compilation scope is entered before parsing, so a compile that
/// fails early (a syntax error) still starts the record empty rather than
/// leaving the previous compile's files visible.
#[test]
fn quiet_deps_record_is_scoped_even_when_the_compile_fails_early() {
    let dir = std::env::temp_dir().join(format!("sasso_dep_fail_{}", std::process::id()));
    std::fs::create_dir_all(dir.join("lp")).expect("mkdir");
    std::fs::write(dir.join("lp/_dep.scss"), "q { r: 1; }\n").unwrap();
    let importer = FsImporter::new(vec![dir.join("lp")]);
    let deps = importer.dependencies();
    let silent: sasso::WarnHandler = Rc::new(|_: &WarnEvent<'_>| {});
    let opts = Options::default()
        .with_importer(&importer)
        .with_url("ok.scss")
        .with_quiet_deps(deps.clone())
        .with_warn_handler(Rc::clone(&silent));
    compile("@import \"dep\";\n", &opts).expect("compile ok");
    let dep_canon = canon_key(dir.join("lp/_dep.scss"));
    assert!(deps.is_dependency(&dep_canon));
    let opts = Options::default()
        .with_importer(&importer)
        .with_url("broken.scss")
        .with_quiet_deps(deps.clone())
        .with_warn_handler(silent);
    assert!(compile("a { b: c ", &opts).is_err(), "a parse error");
    assert!(
        !deps.is_dependency(&dep_canon),
        "the failed compile still started its record empty"
    );
    std::fs::remove_dir_all(&dir).ok();
}

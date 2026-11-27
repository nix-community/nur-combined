//! `sasso_macros::include!` end to end: these constants are compiled by the
//! macro while this test crate builds, so a broken expansion fails the build.

static EXPANDED: &str = sasso_macros::include!(
    "tests/fixtures/scss/main.scss",
    load_paths = ["tests/fixtures/scss/lib"]
);

static COMPRESSED: &str = sasso_macros::include!(
    "tests/fixtures/scss/main.scss",
    style = "compressed",
    load_paths = ["tests/fixtures/scss/lib"],
);

const INDENTED: &str = sasso_macros::include!(r"tests/fixtures/scss/indented.sass");

#[test]
fn expands_to_the_compiled_css() {
    assert_eq!(EXPANDED, ".button {\n  color: #3366cc;\n  padding: 8px;\n}");
}

#[test]
fn style_option_compresses() {
    assert_eq!(COMPRESSED, ".button{color:#36c;padding:8px}");
}

#[test]
fn sass_extension_selects_the_indented_syntax() {
    assert_eq!(INDENTED, ".b {\n  color: blue;\n}");
}

#[test]
fn matches_the_library_compile() {
    let dir = std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/fixtures/scss");
    let importer = sasso_core::FsImporter::new(vec![dir.join("lib")]);
    let entry = dir.join("main.scss");
    let url = entry.to_string_lossy().into_owned();
    let source = std::fs::read_to_string(&entry).unwrap();
    let options = sasso_core::Options::new().with_importer(&importer).with_url(&url);
    assert_eq!(EXPANDED, sasso_core::compile(&source, &options).unwrap());
}

/// The expansion resolves in the caller's scope, so every name it uses must
/// be one the caller cannot rebind: a module that shadows a primitive or a
/// standard macro still gets its CSS.
mod shadowed_names {
    #[allow(non_camel_case_types, dead_code)]
    type u8 = u16;
    #[allow(unused_macros)]
    macro_rules! include_bytes {
        ($($t:tt)*) => {
            &[0u16]
        };
    }
    pub static CSS: &str = sasso_macros::include!("tests/fixtures/scss/indented.sass");
}

#[test]
fn expansion_ignores_names_the_caller_shadows() {
    assert_eq!(shadowed_names::CSS, ".b {\n  color: blue;\n}");
}

//! `sasso::include!`, through the re-export users write. The macro itself is
//! tested in `macros/tests`; this checks that `sasso` hands it out under the
//! `macro` feature and that the expansion compiles from a crate that names
//! only `sasso`.
#![cfg(feature = "macro")]

static GRID: &str = sasso::include!("tests/fixtures/include/grid.scss");
static GRID_MIN: &str = sasso::include!("tests/fixtures/include/grid.scss", style = "compressed");

#[test]
fn include_is_reexported() {
    assert_eq!(GRID, ".grid {\n  gap: 3px;\n}");
    assert_eq!(GRID_MIN, ".grid{gap:3px}");
}

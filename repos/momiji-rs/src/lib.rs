//! `sasso` — a pure-Rust SCSS → CSS compiler.
//!
//! A small, zero-dependency, embeddable Sass engine aiming at byte-exact
//! parity with **current** dart-sass on the subset it implements (e.g.
//! computed colors serialize as `rgb(25%, 50%, 75%)`, not rounded
//! hex). It is sandbox-friendly: `@import` resolution goes through a
//! caller-supplied [`Importer`], so an embedder controls all file access.
//!
//! # Example
//!
//! ```
//! use sasso::{compile, Options};
//!
//! let css = compile("$c: #333; a { color: $c; &:hover { color: $c; } }", &Options::default()).unwrap();
//! assert!(css.contains("a {"));
//! assert!(css.contains("a:hover {"));
//! ```
//!
//! # At compile time
//!
//! With the `macro` feature, [`include!`] compiles a stylesheet while your
//! crate builds and expands to the CSS as a `&'static str`; a Sass error
//! fails the build:
//!
//! ```toml
//! [dependencies]
//! sasso = { version = "0.22", features = ["macro"] }
//! ```
//!
//! ```ignore
//! static CSS: &str = sasso::include!("static/main.scss");
//! ```
//!
//! ## Scope
//!
//! This covers a large slice of Sass: variables (`!default`/`!global`),
//! nesting and the `&` parent selector, `#{}` interpolation, `//` and
//! `/* */` comments, unit arithmetic, the color functions, control flow,
//! mixins/functions, `@extend`, `@import`, and the `@use`/`@forward` module
//! system. Both input syntaxes are supported — the brace/semicolon SCSS
//! syntax and the indented `.sass` syntax (selected via [`Options::with_syntax`]
//! or, in the CLI, the input file's extension) — parsing into the same AST and
//! sharing the evaluator and emitter. The north-star target is 100% of the
//! official `sass-spec` suite, tracked by the harness in `spec/`.

// The compiler is `sasso-core` (`/core`); this crate is its public face, plus
// the CLI binary. The split exists for `include!`: see `core/Cargo.toml`.
pub use sasso_core::*;

#[cfg(feature = "macro")]
pub use sasso_macros::include;

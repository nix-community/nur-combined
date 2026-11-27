# sasso-core

The compiler behind [sasso](https://crates.io/crates/sasso), a pure-Rust SCSS
to CSS compiler.

Depend on `sasso` instead: it re-exports this crate's whole API unchanged and
adds `sasso::include!` (the `macro` feature). This crate exists only so that
macro, which runs the compiler at build time, and `sasso` can both depend on
the compiler without depending on each other.

Licensed under either of MIT or Apache-2.0, at your option.

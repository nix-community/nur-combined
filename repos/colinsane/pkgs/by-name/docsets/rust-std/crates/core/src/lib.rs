// see: <https://github.com/rust-lang/rfcs/issues/2324#issuecomment-502437904>
// to generate docs for `std::` and `core::`, one would expect to just run `cargo docset` from a
// rust source checkout, but that doesn't work because of weird (in)stability guarantees/feature
// gating. instead, generate docs by just... shipping an empty library that re-exports the lib.
//
// *sigh*

#[doc(inline)]
pub use core::*;

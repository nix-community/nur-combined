//! home for the little helpers that stand in for the convenience crates we cut.
//!
//! each module mirrors just the slice of a third-party crate that rfetch
//! actually used, so the call sites stay comfy without the dependency.
//! linux only, std + libc only.

pub mod color;
pub mod identity;
pub mod random;

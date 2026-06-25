//! This module holds everything related to configuring the output of bun2nix
#[cfg(target_arch = "wasm32")]
use wasm_bindgen::prelude::*;

/// # Lockfile conversion options
///
/// Config options for generating a bun.nix file
#[cfg_attr(target_arch = "wasm32", wasm_bindgen(getter_with_clone))]
#[derive(Debug, Clone)]
pub struct Options {
    /// The prefix to use when copying workspace or file packages
    pub copy_prefix: String,
}

#[cfg(target_arch = "wasm32")]
#[cfg_attr(target_arch = "wasm32", wasm_bindgen)]
impl Options {
    /// # New Options
    ///
    /// Constructor for `bun2nix` options
    #[wasm_bindgen(constructor)]
    pub fn new(copy_prefix: String) -> Self {
        Self { copy_prefix }
    }
}

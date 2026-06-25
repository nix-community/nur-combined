//! Library for implementing parsing and conversion of [Bun](https://bun.sh/) lock files into a
//! [Nix](https://en.wikipedia.org/wiki/Nix_(package_manager)) expression.

#![warn(missing_docs)]

pub mod error;
pub mod lockfile;
pub mod nix_expression;
pub mod options;
pub mod package;

pub use error::{Error, Result};
pub use lockfile::Lockfile;
use nix_expression::NixExpression;
pub use options::Options;
pub use package::Package;

#[cfg(target_arch = "wasm32")]
use wasm_bindgen::prelude::*;

/// # Convert Bun Lockfile to a Nix expression
///
/// Takes a string input of the contents of a bun lockfile and converts it into a ready to use Nix expression which fetches the packages
#[cfg_attr(target_arch = "wasm32", wasm_bindgen)]
#[cfg_attr(target_arch = "wasm32", no_mangle)]
pub fn convert_lockfile_to_nix_expression(contents: String, options: Options) -> Result<String> {
    let lockfile = contents.parse::<Lockfile>()?;

    if lockfile.lockfile_version != 1 {
        return Err(Error::UnsupportedLockfileVersion(lockfile.lockfile_version));
    };

    let mut packages = lockfile.packages();
    packages.sort();
    packages.dedup_by(|a, b| a.name == b.name);

    NixExpression::new(packages)?.render_with_options(options)
}

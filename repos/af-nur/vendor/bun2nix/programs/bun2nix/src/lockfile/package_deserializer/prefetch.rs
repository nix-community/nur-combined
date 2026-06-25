use crate::error::{Error, Result};

use log::warn;
use serde::{Deserialize, Serialize};
use std::process::Command;

/// # Package Prefetch
///
/// Represents the result of a `nix flake prefetch`
/// for a given package we don't know the hash for
#[derive(Debug, Deserialize, Serialize)]
pub struct Prefetch {
    pub hash: String,
}

impl Prefetch {
    /// # Prefetch Package
    ///
    /// Prefetch a package as a url and calculate it's
    /// sha256
    pub fn prefetch_package(url: &str) -> Result<Self> {
        cfg_if::cfg_if! {
            if #[cfg(target_arch = "wasm32")] {
                return Err(Error::UnsupportedWASMCliAction(url.to_owned()));
            } else {
                warn!(
                        "
Hash was not already known for `{url}`.

This must be prefetched and hashed by `bun2nix` via
`nix flake prefetch`. While this does have some caching
if you care about install speed, try looking for an alternative
install for this package from npm.

See:
- https://nix.dev/manual/nix/2.28/command-ref/new-cli/nix3-flake-prefetch.html
- https://github.com/oven-sh/bun/issues/19519

Disable these warnings with `RUST_LOG=error` or `RUST_LOG=off`
            "
                    );

                let cmd_res = Command::new("nix")
                    .args([
                        "--extra-experimental-features",
                        "nix-command flakes",
                        "flake",
                        "prefetch",
                        url,
                        "--json",
                    ])
                    .output()
                    .map_err(Error::FetchingFailed)?;

                let stdout = str::from_utf8(&cmd_res.stdout).map_err(Error::InvalidUtf8String)?;

                if !cmd_res.status.success() {
                    let stderr = str::from_utf8(&cmd_res.stderr).map_err(Error::InvalidUtf8String)?;
                    return Err(Error::FetchingError(stderr.to_string()));
                }

                Ok(serde_json::from_str(stdout)?)
            }
        }
    }
}

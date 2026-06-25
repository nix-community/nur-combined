//! Errors which may occur during the running of this program
//!
//! This module contains two items:
//! - A giant unified error type `Error`
//! - An alias for `std::result::Result<T, E>` with that error for convenience

use std::{io, str::Utf8Error};
use thiserror::Error;

/// Result alias for Errors which occur in `bun2nix`
pub type Result<T> = std::result::Result<T, Error>;

#[allow(missing_docs)]
#[derive(Error, Debug)]
/// Errors which occur in `bun2nix`
pub enum Error {
    #[error(
        "Failed to parse lockfile as JSONC (specified here: https://github.com/oven-sh/bun/issues/11863): \n{0}.

Please make sure your bun lockfile is formatted correctly, try deleting it and running `bun install` again to produce a fresh one"
    )]
    ParseJsonc(#[from] jsonc_parser::errors::ParseError),
    #[error("Failed to parse lockfile related JSON as rust type: \n{0}")]
    ParseRustType(#[from] serde_json::Error),
    #[error(
        "Failed to parse empty lockfile, make sure you are providing a file with text contents"
    )]
    NoJsoncValue,
    #[error("Missing @ for package name and version declaration.

Make sure all versions in your bun lockfile are formatted properly or try deleting it and running `bun install` to produce a fresh one"
    )]
    NoAtInPackageIdentifier,
    #[error( "Unsupported lockfile version: '{0}'.

Consider updating your local package or contributing to `bun2nix` if this version hasn't been supported yet"
    )]
    UnsupportedLockfileVersion(u8),
    #[error("Error while fetching package from it's source: \n{0}")]
    FetchingFailed(io::Error),
    #[error("\nConsole error while fetching package from it's source: \n\n{0}")]
    FetchingError(String),
    #[error("An invalid utf8 string was returned from stdin while fetching a package: {0}")]
    InvalidUtf8String(Utf8Error),
    #[error("A workspace package was missing the `workspace:` specifier")]
    MissingWorkspaceSpecifier,
    #[error("A file package was missing the `file:` specifier")]
    MissingFileSpecifier,
    #[error("A git url was missing it's ref")]
    MissingGitRef,
    #[error("A github url was formatted incorrectly")]
    ImproperGithubUrl,
    #[error("Unexpected package entry length: \n{0}")]
    UnexpectedPackageEntryLength(usize),
    #[error("Failed to render template: '\n{0}'")]
    TemplateError(#[from] askama::Error),
    #[error(
        "Hash was not already known for `{0}`.

This must be prefetched and hashed by `bun2nix` via
`nix flake prefetch`. However, you are using the wasm
cli, which does not support this as a child process
needs to be spawned.

Please switch to the native cli instead to use this dependency.
"
    )]
    UnsupportedWASMCliAction(String),
    #[error("IO Error Occurred: \n{0}

Make sure that the bun lockfile path you gave points to a valid path.

Try changing the file path to point to one, or create one with `bun install` on a version of bun above v1.2.

See https://bun.sh/docs/install/lockfile to find out more information about the textual lockfile.

Try `bun2nix -h` for help.
    ")]
    ReadLockfileError(#[from] io::Error),
}

#[cfg(target_arch = "wasm32")]
use wasm_bindgen::JsValue;

#[cfg(target_arch = "wasm32")]
impl From<Error> for JsValue {
    fn from(err: Error) -> JsValue {
        JsValue::from_str(&err.to_string())
    }
}

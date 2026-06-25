//! This module holds the implementation for data about a given nix fetcher type

use std::{fmt::Debug, hash::Hash};

use askama::Template;
use serde::{Deserialize, Serialize};

use crate::{
    Options,
    error::{Error, Result},
};

#[derive(Debug, Serialize, Deserialize, Clone, Eq, Ord, PartialEq, PartialOrd, Hash, Template)]
/// # Package Fetcher
///
/// Nix-translated fetcher for a given package
pub enum Fetcher {
    /// A package which must be retrieved with nix's `pkgs.fetchurl`
    #[template(path = "fetchurl.nix_template")]
    FetchUrl {
        /// The url to fetch the package from
        url: String,
        /// The hash of the downloaded results
        /// This can be derived from the bun lockfile
        hash: String,
        /// Optional explicit filename (used for non-default registries to ensure .tgz extension)
        name: Option<String>,
    },
    /// A package which must be retrieved with nix's `pkgs.fetchgit`
    #[template(path = "fetchgit.nix_template")]
    FetchGit {
        /// The url to fetch the package from
        url: String,
        /// The commit ref to fetch
        rev: String,
        /// The hash of the downloaded results
        /// This must be calculated via nix-prefetch
        hash: String,
    },
    /// A package which must be retrieved with nix's `pkgs.fetchFromGitHub`
    #[template(path = "fetchgithub.nix_template")]
    FetchGitHub {
        /// The owner of the repo to fetch from
        owner: String,
        /// The repo to fetch
        repo: String,
        /// The git ref to fetch
        rev: String,
        /// The hash of the downloaded results
        /// This must be calculated via nix-prefetch
        hash: String,
    },
    /// A package which must be retrieved with nix's `pkgs.fetchtarball`
    #[template(path = "fetchtarball.nix_template")]
    FetchTarball {
        /// The url to fetch the package from
        url: String,
        /// The hash of the downloaded results
        /// This must be calculated via nix-prefetch
        hash: String,
    },
    /// A package can be a path copied to the store directly
    #[template(path = "copy-to-store.nix_template")]
    CopyToStore {
        /// The path from the root to copy to the store
        path: String,
    },
}

/// The default NPM registry URL
pub const DEFAULT_REGISTRY: &str = "https://registry.npmjs.org/";

impl Fetcher {
    /// # From NPM Package Name
    ///
    /// Initialize a fetcher from an npm identifier and
    /// it's hash, optionally using an explicit tarball URL
    ///
    /// ## Arguments
    /// * `ident` - The package identifier (e.g., "@types/node@1.0.0")
    /// * `hash` - The integrity hash of the package
    /// * `tarball_url` - Optional explicit tarball URL from bun.lock. If provided
    ///   and non-empty, used directly. Otherwise, URL is constructed from the
    ///   default npmjs.org registry.
    pub fn new_npm_package(ident: &str, hash: String, tarball_url: Option<&str>) -> Result<Self> {
        let url = Self::to_npm_url(ident, tarball_url)?;

        // For non-default registries, explicitly set the filename to ensure .tgz extension
        let name = tarball_url
            .filter(|u| !u.is_empty())
            .map(|_| Self::extract_tgz_filename(ident));

        Ok(Self::FetchUrl { url, hash, name })
    }

    /// Extract a .tgz filename from a package identifier
    fn extract_tgz_filename(ident: &str) -> String {
        // Handle scoped packages like @scope/name@version
        if let Some((_, name_and_ver)) = ident.split_once("/")
            && let Some((name, ver)) = name_and_ver.split_once("@")
        {
            return format!("{}-{}.tgz", name, ver);
        }
        // Handle unscoped packages like name@version
        if let Some((name, ver)) = ident.split_once("@") {
            return format!("{}-{}.tgz", name, ver);
        }
        // Fallback
        format!("{}.tgz", ident)
    }

    /// # NPM url converter
    ///
    /// Produce a url needed to fetch from the npm api from a package
    ///
    /// ## Usage
    ///```rust
    /// use bun2nix::package::Fetcher;
    ///
    /// // Default registry (empty or None tarball_url)
    /// let npm_identifier = "@alloc/quick-lru@5.2.0";
    ///
    /// assert_eq!(
    ///     Fetcher::to_npm_url(npm_identifier, None).unwrap(),
    ///     "https://registry.npmjs.org/@alloc/quick-lru/-/quick-lru-5.2.0.tgz"
    /// );
    ///
    /// assert_eq!(
    ///     Fetcher::to_npm_url(npm_identifier, Some("")).unwrap(),
    ///     "https://registry.npmjs.org/@alloc/quick-lru/-/quick-lru-5.2.0.tgz"
    /// );
    ///
    /// // Explicit tarball URL (used directly)
    /// assert_eq!(
    ///     Fetcher::to_npm_url(npm_identifier, Some("https://npm.pkg.github.com/@alloc/quick-lru/-/quick-lru-5.2.0.tgz")).unwrap(),
    ///     "https://npm.pkg.github.com/@alloc/quick-lru/-/quick-lru-5.2.0.tgz"
    /// );
    /// ```
    pub fn to_npm_url(ident: &str, tarball_url: Option<&str>) -> Result<String> {
        // If an explicit tarball URL is provided, use it directly
        if let Some(url) = tarball_url {
            if !url.is_empty() {
                return Ok(url.to_string());
            }
        }

        // Otherwise, construct the URL from the default registry
        let Some((user, name_and_ver)) = ident.split_once("/") else {
            let Some((name, ver)) = ident.split_once("@") else {
                return Err(Error::NoAtInPackageIdentifier);
            };

            return Ok(format!(
                "{}{}/-/{}-{}.tgz",
                DEFAULT_REGISTRY, name, name, ver
            ));
        };

        let Some((name, ver)) = name_and_ver.split_once("@") else {
            return Err(Error::NoAtInPackageIdentifier);
        };

        Ok(format!(
            "{}{}/{}/-/{}-{}.tgz",
            DEFAULT_REGISTRY, user, name, name, ver
        ))
    }
}

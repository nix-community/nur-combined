use crate::{
    Package,
    error::{Error, Result},
    package::Fetcher,
};

mod prefetch;
pub use prefetch::Prefetch;

type Values = Vec<serde_json::Value>;

/// # Package Deserializer
///
/// Deserializes a given bun lockfile entry line into it's
/// name and nix fetcher implementation
#[derive(Debug)]
pub struct PackageDeserializer {
    /// The name for the package
    pub name: String,

    /// The list of serde json values for the tuple in question
    pub values: Values,
}

impl PackageDeserializer {
    /// # Deserialize package
    ///
    /// Deserialize a given package from it's lockfile representation
    pub fn deserialize_package(name: String, values: Values) -> Result<Package> {
        let arity = values.len();
        let deserializer = Self { name, values };

        match arity {
            1 => deserializer.deserialize_workspace_package(),
            2 => deserializer.deserialize_tarball_or_file_package(),
            3 => deserializer.deserialize_git_or_github_package(),
            4 => deserializer.deserialize_npm_package(),
            x => Err(Error::UnexpectedPackageEntryLength(x)),
        }
    }

    /// # Deserialize an NPM Package
    ///
    /// Deserialize an npm package from it's bun lockfile representation
    ///
    /// This is found in the source as a tuple of arity 4:
    /// `[identifier, tarball_url, metadata, hash]`
    ///
    /// The tarball_url field is empty for the default registry (registry.npmjs.org),
    /// or contains the exact URL to the package tarball for non-default registries.
    pub fn deserialize_npm_package(mut self) -> Result<Package> {
        // The bun.lock format for npm packages is:
        // [identifier, tarball_url, metadata, hash]
        // - identifier: "name@version"
        // - tarball_url: "" for default registry, or exact URL to tarball
        // - metadata: object with dependencies, bin, etc.
        // - hash: integrity hash (sha512-...)

        let npm_identifier_raw = swap_remove_value(&mut self.values, 0);
        // After swap_remove(0): [hash, tarball_url, meta]

        let hash = swap_remove_value(&mut self.values, 0);
        // After swap_remove(0): [meta, tarball_url]

        // Get the tarball URL from what's now at index 1
        // (originally at index 1, but the metadata swapped in at index 0)
        let tarball_url = self
            .values
            .get(1)
            .and_then(|v| v.as_str())
            .filter(|s| !s.is_empty());

        debug_assert!(
            hash.contains("sha512-"),
            "Expected hash to be in sri format and contain sha512"
        );

        let fetcher = Fetcher::new_npm_package(&npm_identifier_raw, hash, tarball_url)?;

        Ok(Package::new(npm_identifier_raw, fetcher))
    }

    /// # Deserialize a Git or Github Package
    ///
    /// Deserialize a git or github package from it's bun lockfile representation
    ///
    /// This is found in the source as a tuple of arity 3
    pub fn deserialize_git_or_github_package(mut self) -> Result<Package> {
        let mut id = swap_remove_value(&mut self.values, 0);

        let at_pos = id.rfind('@').ok_or(Error::NoAtInPackageIdentifier)?;
        id.drain(..=at_pos);

        if id.starts_with("github:") {
            Self::deserialize_github_package(id)
        } else {
            Self::deserialize_git_package(id)
        }
    }

    /// # Deserialize a Github Package
    ///
    /// Deserialize a github package from it's bun lockfile representation
    ///
    /// This is found in the source as a tuple of arity 3
    pub fn deserialize_github_package(id: String) -> Result<Package> {
        let (url, rev) = split_once_owned(id, '#').ok_or(Error::MissingGitRef)?;

        let prefetch_url = format!("{}?ref={}", &url, &rev);
        let prefetch = Prefetch::prefetch_package(&prefetch_url)?;

        let (owner_with_pre, repo) = split_once_owned(url, '/').ok_or(Error::ImproperGithubUrl)?;
        let owner = drop_prefix(owner_with_pre, "github:");

        let id_with_ver = format!("github:{}-{}-{}", &owner, &repo, &rev);

        let fetcher = Fetcher::FetchGitHub {
            owner,
            repo,
            rev,
            hash: prefetch.hash,
        };

        Ok(Package::new(id_with_ver, fetcher))
    }

    /// # Deserialize a Git Package
    ///
    /// Deserialize a git package from it's bun lockfile representation
    ///
    /// This is found in the source as a tuple of arity 3
    pub fn deserialize_git_package(id: String) -> Result<Package> {
        let git_url = drop_prefix(id, "git+");
        let (url, rev) = split_once_owned(git_url, '#').ok_or(Error::MissingGitRef)?;

        let prefetch_url = format!("git+{}?rev={}", &url, &rev);
        let prefetch = Prefetch::prefetch_package(&prefetch_url)?;

        let id_with_rev = format!("git:{}", &rev);

        let fetcher = Fetcher::FetchGit {
            url,
            rev,
            hash: prefetch.hash,
        };

        Ok(Package::new(id_with_rev, fetcher))
    }

    /// # Deserialize a tarball or file package
    ///
    /// Deserialize a tarball or file package from it's bun
    /// lockfile representation
    ///
    /// These are grouped together as both lockfile
    /// representations are a tupe of arity 2, hence
    /// paths starting with `http` are considered
    /// tarballs
    pub fn deserialize_tarball_or_file_package(mut self) -> Result<Package> {
        let id = swap_remove_value(&mut self.values, 0);
        let path = Self::drain_after_substring(id, "@").ok_or(Error::NoAtInPackageIdentifier)?;

        if path.starts_with("http") {
            Self::deserialize_tarball_package(path)
        } else {
            Self::deserialize_file_package(self.name, path)
        }
    }

    /// # Deserialize a file package
    ///
    /// Deserialize a file package from it's bun lockfile representation
    ///
    /// This is found in the source as a tuple of arity 2
    ///
    /// Handles both explicit `file:` prefix and inferred local paths.
    /// Bun strips the `file:` prefix for local tarballs in the packages section,
    /// so we need to infer local paths from `./` prefixes.
    ///
    /// See:
    /// - https://github.com/oven-sh/bun/blob/7ebfdf97a872908aeacce7af7eba21658b265ad7/src/install/dependency.zig#L514-L517
    /// - https://github.com/oven-sh/bun/blob/7ebfdf97a872908aeacce7af7eba21658b265ad7/src/install/resolution.zig#L46-L59
    pub fn deserialize_file_package(name: String, path: String) -> Result<Package> {
        debug_assert!(
            !path.contains("http"),
            "File path can never contain http, because then it would be a tarball"
        );

        // Strip prefix: explicit "file:" or implicit "./" (Bun strips file: for local tarballs)
        let path = path
            .strip_prefix("file:")
            .or_else(|| path.strip_prefix("./"))
            .ok_or(Error::MissingFileSpecifier)?;

        Ok(Package::new(
            name,
            Fetcher::CopyToStore {
                path: path.to_string(),
            },
        ))
    }

    /// # Deserialize a tarball package
    ///
    /// Deserialize a tarball package from it's bun lockfile representation
    ///
    /// This is found in the source as a tuple of arity 2
    pub fn deserialize_tarball_package(url: String) -> Result<Package> {
        debug_assert!(url.contains("http"), "Expected tarball url to contain http");

        let prefetch = Prefetch::prefetch_package(&url)?;

        let name = format!("tarball:{}", url);
        let fetcher = Fetcher::FetchTarball {
            url,
            hash: prefetch.hash,
        };

        Ok(Package::new(name, fetcher))
    }

    /// # Deserialize a workspace package
    ///
    /// Deserialize a workspace package from it's bun lockfile representation
    ///
    /// This is found in the source as a tuple of arity 2
    pub fn deserialize_workspace_package(mut self) -> Result<Package> {
        let id = swap_remove_value(&mut self.values, 0);
        let path = Self::drain_after_substring(id, "workspace:")
            .ok_or(Error::MissingWorkspaceSpecifier)?;

        Ok(Package::new(self.name, Fetcher::CopyToStore { path }))
    }

    fn drain_after_substring(mut input: String, sub: &str) -> Option<String> {
        let pos = input.rfind(sub)? + sub.len();

        Some(input.drain(pos..).collect())
    }
}

/// # Swap Remove `Value`
///
/// Remove a value from a serde_json `Values` array, and take ownership
/// of it in a fast way by swapping in the final value of the array.
///
///```rust
/// use bun2nix::lockfile::swap_remove_value;
/// use serde_json::json;
///
/// let mut values = vec![
///  json!("@types/bun@1.2.4"),
///  json!({}),
///  json!([]),
///  json!("sha512-QtuV5OMR8/rdKJs213iwXDpfVvnskPXY/S0ZiFbsTjQZycuqPbMW8Gf/XhLfwE5njW8sxI2WjISURXPlHypMFA==")
/// ];
///
/// assert_eq!(
///     swap_remove_value(&mut values, 0),
///     "@types/bun@1.2.4"
/// );
/// assert_eq!(
///     swap_remove_value(&mut values, 0),
///     "sha512-QtuV5OMR8/rdKJs213iwXDpfVvnskPXY/S0ZiFbsTjQZycuqPbMW8Gf/XhLfwE5njW8sxI2WjISURXPlHypMFA=="
/// );
/// ```
pub fn swap_remove_value(values: &mut Values, index: usize) -> String {
    let mut value = values.swap_remove(index).to_string();

    debug_assert!(value.starts_with('"'), "Value should start with a quote");
    debug_assert!(value.ends_with('"'), "Value should end with a quote");

    value.drain(1..value.len() - 1).collect()
}

/// # Split Once (Owned)
///
/// Variant of `String::split_once` which consumes the original string and produces
/// two owned values as an output (without a new allocation).
///
///```rust
/// use bun2nix::lockfile::split_once_owned;
///
/// let input = "hello#world".to_owned();
///
/// assert_eq!(
///     split_once_owned(input, '#'),
///     Some(("hello".to_owned(), "world".to_owned()))
/// );
/// ```
pub fn split_once_owned(mut input: String, char: char) -> Option<(String, String)> {
    let split_pos = input.find(char)?;

    let mut first: String = input.drain(..=split_pos).collect();
    first.pop();

    Some((first, input))
}

/// # Drop Prefix
///
/// Consumes an owned string with a known prefix and returns an owned
/// value without that prefix (reuses the old allocation).
///
///```rust
/// use bun2nix::lockfile::drop_prefix;
///
/// let input = "hello:world".to_owned();
///
/// assert_eq!(
///     drop_prefix(input, "hello:"),
///     "world"
/// );
/// ```
pub fn drop_prefix(mut input: String, prefix: &str) -> String {
    if input.starts_with(prefix) {
        input.drain(..prefix.len());
    }

    input
}

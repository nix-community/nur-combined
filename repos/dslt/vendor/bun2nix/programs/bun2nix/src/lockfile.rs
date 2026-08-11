//! This module holds everything related to deserialization of the bun lockfile, including type
//! mappings and custom deserialization methods

use std::{collections::HashMap, str::FromStr};

use log::warn;
use serde::{Deserialize, Deserializer, Serialize};
use serde_json::Value;

use crate::{
    Package,
    error::{Error, Result},
};

mod package_deserializer;
mod package_visitor;
pub use package_deserializer::{
    PackageDeserializer, drop_prefix, split_once_owned, swap_remove_value,
};
pub use package_visitor::PackageVisitor;

#[derive(Serialize, Deserialize, Debug)]
#[serde(rename_all = "camelCase")]
/// # Bun Lockfile
///
/// A model of the fields that exist in a bun lockfile in order to serve as a deserialization
/// target.
///
/// ## Usage
///
/// A bun lockfile can be deserialized from a string as follows:
///
/// ```rust
/// use bun2nix::Lockfile;
///
/// let lockfile = r#"
/// {
///   "lockfileVersion": 1,
///   "workspaces": {
///     "": {
///       "name": "examples",
///       "devDependencies": {
///         "@types/bun": "1.2.4",
///       },
///       "peerDependencies": {
///         "typescript": "^5",
///       },
///     },
///   },
///   "packages": {
///     "@types/bun": ["@types/bun@1.2.4", "", { "dependencies": { "bun-types": "1.2.4" } }, "sha512-QtuV5OMR8/rdKJs213iwXDpfVvnskPXY/S0ZiFbsTjQZycuqPbMW8Gf/XhLfwE5njW8sxI2WjISURXPlHypMFA=="],
///
///     "@types/node": ["@types/node@22.13.5", "", { "dependencies": { "undici-types": "~6.20.0" } }, "sha512-+lTU0PxZXn0Dr1NBtC7Y8cR21AJr87dLLU953CWA6pMxxv/UDc7jYAY90upcrie1nRcD6XNG5HOYEDtgW5TxAg=="],
///
///     "@types/ws": ["@types/ws@8.5.14", "", { "dependencies": { "@types/node": "*" } }, "sha512-bd/YFLW+URhBzMXurx7lWByOu+xzU9+kb3RboOteXYDfW+tr+JZa99OyNmPINEGB/ahzKrEuc8rcv4gnpJmxTw=="],
///
///     "bun-types": ["bun-types@1.2.4", "", { "dependencies": { "@types/node": "*", "@types/ws": "~8.5.10" } }, "sha512-nDPymR207ZZEoWD4AavvEaa/KZe/qlrbMSchqpQwovPZCKc7pwMoENjEtHgMKaAjJhy+x6vfqSBA1QU3bJgs0Q=="],
///
///     "typescript": ["typescript@5.7.3", "", { "bin": { "tsc": "bin/tsc", "tsserver": "bin/tsserver" } }, "sha512-84MVSjMEHP+FQRPy3pX9sTVV/INIex71s9TL2Gm5FG/WG1SqXeKyZ0k7/blY/4FdOzI12CBy1vGc4og/eus0fw=="],
///
///     "undici-types": ["undici-types@6.20.0", "", {}, "sha512-Ny6QZ2Nju20vw1SRHe3d9jVu6gJ+4e3+MMpqu7pqE5HT6WsTSlce++GQmK5UXS8mzV8DSYHrQH+Xrf2jVcuKNg=="],
///   }
/// }
/// "#;
///
/// let value: Lockfile = lockfile.parse().unwrap();
///
/// assert!(value.lockfile_version == 1);
/// ```
pub struct Lockfile {
    /// The version field of the bun lockfile
    pub lockfile_version: u8,

    /// The workspaces declaration in the bun lockfile
    #[serde(default)]
    pub workspaces: HashMap<String, Workspace>,

    /// The list of all packages needed by the lockfile
    #[serde(deserialize_with = "Lockfile::deserialize_packages")]
    pub packages: Vec<Package>,
}

impl Lockfile {
    /// # Lockfile Packages
    ///
    /// Consume the parsed lockfile and output it's packages set
    pub fn packages(self) -> Vec<Package> {
        self.packages
    }

    /// # Lockfile Workspaces
    ///
    /// Get a reference to the lockfile's workspaces
    pub fn workspaces(&self) -> &HashMap<String, Workspace> {
        &self.workspaces
    }

    /// # Has Workspaces
    ///
    /// Check if the lockfile has any non-root workspaces
    pub fn has_workspaces(&self) -> bool {
        self.workspaces.iter().any(|(key, _)| !key.is_empty())
    }

    /// # Parse to Value
    ///
    /// Parse the lockfile into a serde json value
    pub fn parse_to_value(lockfile: &str) -> Result<Value> {
        jsonc_parser::parse_to_serde_value(lockfile, &Default::default())?
            .ok_or(Error::NoJsoncValue)
    }

    /// # Deserialize Packages
    ///
    /// Use the `PackagesVisitor` to deserialize the packages into a list of packages
    pub fn deserialize_packages<'de, D>(data: D) -> std::result::Result<Vec<Package>, D::Error>
    where
        D: Deserializer<'de>,
    {
        data.deserialize_map(PackageVisitor)
    }
}

impl FromStr for Lockfile {
    type Err = Error;

    fn from_str(lockfile: &str) -> std::result::Result<Self, Self::Err> {
        let value = Self::parse_to_value(lockfile)?;

        Ok(serde_json::from_value(value)?)
    }
}

type Dependencies = HashMap<String, String>;

#[derive(Default, Serialize, Deserialize, Debug)]
#[serde(rename_all = "camelCase", default)]
/// # Lockfile workspace
///
/// A model of the fields that exist in a given workspace
pub struct Workspace {
    /// The name of the workspace
    pub name: Option<String>,

    /// Dependencies of the workspace
    #[serde(default, deserialize_with = "Workspace::deserialize_dependencies")]
    pub dependencies: Dependencies,

    /// Dev dependencies of the workspace
    #[serde(default, deserialize_with = "Workspace::deserialize_dependencies")]
    pub dev_dependencies: Dependencies,
}

impl Workspace {
    /// # Deserialize Dependencies
    ///
    /// Wraps the default deserialization method in order to add checking for unresolved deps
    pub fn deserialize_dependencies<'de, D>(data: D) -> std::result::Result<Dependencies, D::Error>
    where
        D: Deserializer<'de>,
    {
        Ok(Dependencies::deserialize(data)?
            .into_iter()
            .map(|(name, version)| {
                if version == "latest" {
                    warn!(
                        "
The provided bun lockfile contains an unlocked dependency.

This looks something like:
```json
dependencies: {{
    \"{name}\": \"latest\"
}}
```
As a result, this may not be able to be used as a base to do reproducible
installs off of.

You may fix this by running `bun install` again and allowing
it to pin a specific version, manually inserting a version instead
of \"latest\" or removing the dependency if it is unused.
                "
                    );
                };

                (name, version)
            })
            .collect())
    }
}

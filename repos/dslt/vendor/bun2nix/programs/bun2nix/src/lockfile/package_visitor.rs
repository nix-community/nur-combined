use std::fmt;

use serde::de::{self, MapAccess, Visitor};

use super::PackageDeserializer;
use crate::Package;

/// # Package Visitor
///
/// Used for a custom serde deserialize method as the most ergonomic rust package data type does
/// not match the type in the lockfile directly
pub struct PackageVisitor;

impl<'de> Visitor<'de> for PackageVisitor {
    type Value = Vec<Package>;

    fn expecting(&self, formatter: &mut fmt::Formatter) -> fmt::Result {
        formatter.write_str("a map of package names to tuples")
    }

    fn visit_map<M>(self, mut map: M) -> std::result::Result<Self::Value, M::Error>
    where
        M: MapAccess<'de>,
    {
        let mut packages = Vec::new();

        while let Some((name, values)) = map.next_entry::<String, Vec<serde_json::Value>>()? {
            let pkg = PackageDeserializer::deserialize_package(name, values).map_err(|err| {
                de::Error::custom(format!("Failed to deserialize package: {}", err))
            })?;

            packages.push(pkg);
        }

        Ok(packages)
    }
}

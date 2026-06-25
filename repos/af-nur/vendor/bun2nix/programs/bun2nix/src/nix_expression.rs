//! This module handles construction of the rendered nix code as the output

mod nix_escaper;

pub use nix_escaper::NixEscaper;

use crate::{Options, error::Result};
use askama::Template;
use std::{any::Any, collections::HashMap};

use crate::Package;

/// # Nix Expression
///
/// A chunk of nix code to be written to stdout or a file
#[derive(Template)]
#[template(path = "output.nix_template")]
pub struct NixExpression {
    packages: Vec<Package>,
}

impl NixExpression {
    /// # New Nix Expression
    ///
    /// Produce a new, ready to render, nix expression from a package list
    pub fn new(packages: Vec<Package>) -> Result<Self> {
        Ok(Self { packages })
    }

    /// # Render with options
    ///
    /// Renders a `NixExpression` with the supplied config options
    pub fn render_with_options(self, options: Options) -> Result<String> {
        let mut values: HashMap<&str, Box<dyn Any>> = HashMap::new();
        values.insert("options", Box::new(options));

        Ok(self.render_with_values(&values)?)
    }
}

//! Main entry point for the `bun2nix` command line tool, which makes calls to the library for the
//! majority of the actual processing

#![warn(missing_docs)]

use bun2nix::{Options, Result, convert_lockfile_to_nix_expression};
use log::error;

use std::{
    fs::{self, File},
    io::Write,
    path::PathBuf,
};

use clap::Parser;
use env_logger::Env;

/// Convert Bun (v1.2+) packages to Nix expressions
#[derive(Debug, Parser)]
#[command(version, about, long_about = None)]
pub struct Cli {
    /// The Bun (v1.2+) lockfile to use to produce the Nix expression.
    #[arg(short, long, default_value = "./bun.lock")]
    lock_file: PathBuf,

    /// The output file to write to -
    /// if no file location is provided, print to stdout instead.
    #[arg(short, long)]
    output_file: Option<PathBuf>,

    /// The prefix to use when copying workspace or file packages
    #[arg(short, long, default_value = "./")]
    copy_prefix: String,
}

fn main() {
    let log_env = Env::default().default_filter_or("warn");
    env_logger::Builder::from_env(log_env).init();

    match run() {
        Ok(()) => (),
        Err(err) => {
            error!("\n{err}\n");

            std::process::exit(1)
        }
    }
}

fn run() -> Result<()> {
    let cli = Cli::parse();

    let lockfile = fs::read_to_string(&cli.lock_file)?;

    let nix = convert_lockfile_to_nix_expression(
        lockfile,
        Options {
            copy_prefix: cli.copy_prefix,
        },
    )?;

    if let Some(output_file) = cli.output_file {
        let mut output = File::create(output_file)?;
        write!(output, "{nix}")?;
    } else {
        println!("{nix}");
    }

    Ok(())
}

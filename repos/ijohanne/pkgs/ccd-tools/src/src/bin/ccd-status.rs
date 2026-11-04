use std::io::{self, Write};

use anyhow::{Context, Result};
use ccd_tools::{AccountsArgs, Explorer, render_report};
use chrono::Local;
use clap::Parser;

#[derive(Parser)]
#[command(version, about = "Report named Concordium mainnet account balances")]
struct Args {
    #[command(flatten)]
    accounts: AccountsArgs,
}

fn run() -> Result<()> {
    let args = Args::parse();
    let accounts = args.accounts.load()?;
    let explorer = Explorer::new()?;
    let date = Local::now().date_naive();
    // Print only complete reports, so a failed lookup cannot look like success.
    let balances = accounts
        .iter()
        .map(|account| {
            explorer
                .balance(&account.address)
                .with_context(|| format!("cannot query account {:?}", account.name))
                .map(|balance| (account.name.as_str(), balance))
        })
        .collect::<Result<Vec<_>>>()?;
    io::stdout()
        .lock()
        .write_all(render_report(date, &balances).as_bytes())?;
    Ok(())
}

fn main() -> std::process::ExitCode {
    match run() {
        Ok(()) => std::process::ExitCode::SUCCESS,
        Err(error) => {
            eprintln!("ccd-status: {error:#}");
            std::process::ExitCode::FAILURE
        }
    }
}

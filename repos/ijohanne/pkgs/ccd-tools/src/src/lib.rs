use std::{io::Read, time::Duration};

use anyhow::{Context, Result, anyhow, bail, ensure};
use chrono::NaiveDate;
use reqwest::blocking::Client;
use scraper::{ElementRef, Html, Selector};

/// Common runtime configuration, flattened into each command's CLI arguments.
#[derive(clap::Args)]
pub struct AccountsArgs {
    /// CSV file with Name,Address rows (optional header); use - for stdin
    #[arg(long, env = "CCD_TOOLS_ACCOUNTS", value_name = "FILE")]
    pub accounts: std::path::PathBuf,
}

impl AccountsArgs {
    pub fn load(&self) -> Result<Vec<Account>> {
        if self.accounts.as_os_str() == "-" {
            read_accounts(std::io::stdin().lock())
        } else {
            let file = std::fs::File::open(&self.accounts).context("cannot open accounts file")?;
            read_accounts(file)
        }
    }
}

const ORIGIN: &str = "https://ccdexplorer.io";
const MICRO_CCD: u64 = 1_000_000;

#[derive(Debug)]
pub struct Account {
    pub name: String,
    pub address: String,
}

/// Shared input for all ccd-tools binaries. Secret contents stay in memory.
pub fn read_accounts(reader: impl Read) -> Result<Vec<Account>> {
    let mut csv = csv::ReaderBuilder::new()
        .has_headers(false)
        .trim(csv::Trim::All)
        .from_reader(reader);
    let mut accounts = Vec::new();
    for (index, record) in csv.records().enumerate() {
        let record = record.with_context(|| format!("invalid CSV record {}", index + 1))?;
        ensure!(
            record.len() == 2,
            "CSV record {} must contain Name,Address",
            index + 1
        );
        if index == 0
            && record[0].eq_ignore_ascii_case("name")
            && record[1].eq_ignore_ascii_case("address")
        {
            continue;
        }
        ensure!(
            !record[0].is_empty() && !record[0].chars().any(char::is_control),
            "invalid name in CSV record {}",
            index + 1
        );
        ensure!(
            valid_account_id(&record[1]),
            "invalid address in CSV record {} (use a full account address or numeric index)",
            index + 1
        );
        accounts.push(Account {
            name: record[0].into(),
            address: record[1].into(),
        });
    }
    ensure!(!accounts.is_empty(), "accounts file contains no accounts");
    Ok(accounts)
}

fn valid_account_id(value: &str) -> bool {
    (!value.is_empty() && value.bytes().all(|c| c.is_ascii_digit()) && value.parse::<u64>().is_ok())
        || (value.len() == 50
            && value.bytes().all(|c| {
                b"123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz".contains(&c)
            }))
}

#[derive(Debug, PartialEq, Eq)]
pub struct Balance {
    /// Amounts are integer microCCD, avoiding floating-point balance arithmetic.
    pub total: u64,
    pub staked: u64,
}

impl Balance {
    pub fn available(&self) -> Result<u64> {
        self.total
            .checked_sub(self.staked)
            .context("staked amount exceeds account balance")
    }
}

pub struct Explorer {
    client: Client,
}

impl Explorer {
    pub fn new() -> Result<Self> {
        Ok(Self {
            client: Client::builder()
                .user_agent(concat!("ccd-tools/", env!("CARGO_PKG_VERSION")))
                .connect_timeout(Duration::from_secs(10))
                .timeout(Duration::from_secs(30))
                .build()?,
        })
    }

    fn get(&self, path: &str) -> Result<String> {
        let response = self
            .client
            .get(format!("{ORIGIN}{path}"))
            .send()
            .map_err(|e| anyhow!("CCDExplorer request failed: {}", e.without_url()))?
            .error_for_status()
            .map_err(|e| anyhow!("CCDExplorer HTTP error: {}", e.without_url()))?;
        let mut body = String::new();
        response
            .take(4 * 1024 * 1024 + 1)
            .read_to_string(&mut body)?;
        ensure!(
            body.len() <= 4 * 1024 * 1024,
            "CCDExplorer response is too large"
        );
        Ok(body)
    }

    pub fn balance(&self, address: &str) -> Result<Balance> {
        ensure!(
            valid_account_id(address),
            "invalid account address or index"
        );
        let page = Html::parse_document(&self.get(&format!("/mainnet/account/{address}"))?);
        let validator = if page
            .select(&selector("#pills-validator-tab"))
            .next()
            .is_some()
        {
            // Validator stake is loaded lazily by CCDExplorer's browser UI.
            let canonical = canonical_address(&page)?;
            Some(Html::parse_fragment(&self.get(&format!(
                "/account/validator-tab-content/mainnet/{canonical}"
            ))?))
        } else {
            None
        };
        parse_balance(&page, validator.as_ref())
    }
}

fn parse_balance(page: &Html, validator: Option<&Html>) -> Result<Balance> {
    let total = amount_row(page.root_element(), &["account balance"])?
        .context("CCDExplorer page has no Account Balance row")?;
    let staked = if page
        .select(&selector("#pills-validator-tab"))
        .next()
        .is_some()
    {
        let validator = validator.context("missing CCDExplorer validator details")?;
        amount_row(validator.root_element(), &["own stake", "staked"])?
            .context("CCDExplorer validator details have no Own Stake row")?
    } else if page
        .select(&selector("#pills-delegation-tab"))
        .next()
        .is_some()
    {
        let delegation = page
            .select(&selector("#pills-delegation"))
            .next()
            .context("missing CCDExplorer delegation details")?;
        amount_row(delegation, &["amount", "staked"])?
            .context("CCDExplorer delegation details have no Amount row")?
    } else {
        // The balance row was verified above; an account with no staking tab has no stake.
        0
    };
    let balance = Balance { total, staked };
    balance.available()?;
    Ok(balance)
}

fn selector(css: &str) -> Selector {
    Selector::parse(css).expect("static CSS selector")
}

fn canonical_address(page: &Html) -> Result<String> {
    let td = selector("td");
    for row in page.select(&selector("tr")) {
        let mut cells = row.select(&td);
        if cells
            .next()
            .is_some_and(|cell| normalized_label(cell) == "address")
        {
            let cell = cells.next().context("missing account address cell")?;
            for link in cell.select(&selector("a[href]")) {
                if let Some(address) = link
                    .value()
                    .attr("href")
                    .and_then(|href| href.strip_prefix("/mainnet/account/"))
                    && address.len() == 50
                    && valid_account_id(address)
                {
                    return Ok(address.into());
                }
            }
        }
    }
    bail!("CCDExplorer page has no canonical account address")
}

fn normalized_label(cell: ElementRef<'_>) -> String {
    cell.text()
        .collect::<String>()
        .split_whitespace()
        .collect::<Vec<_>>()
        .join(" ")
        .trim_end_matches(':')
        .to_ascii_lowercase()
}

fn amount_row(root: ElementRef<'_>, labels: &[&str]) -> Result<Option<u64>> {
    let td = selector("td");
    for row in root.select(&selector("tr")) {
        let mut cells = row.select(&td);
        if cells
            .next()
            .is_some_and(|cell| labels.contains(&normalized_label(cell).as_str()))
        {
            let value = cells.next().context("missing CCD amount cell")?;
            return parse_amount(&value.text().collect::<String>()).map(Some);
        }
    }
    Ok(None)
}

fn parse_amount(text: &str) -> Result<u64> {
    let value: String = text.chars().filter(|c| !c.is_whitespace()).collect();
    let value = value
        .strip_prefix('Ͼ')
        .unwrap_or(&value)
        .trim_end_matches("CCD");
    let (whole, fraction) = value.split_once('.').unwrap_or((value, ""));
    let groups: Vec<_> = whole.split(',').collect();
    ensure!(
        groups.len() == 1 || (groups[0].len() <= 3 && groups.iter().skip(1).all(|g| g.len() == 3)),
        "invalid CCD thousands grouping"
    );
    let whole = groups.concat();
    ensure!(
        !whole.is_empty()
            && whole.bytes().all(|c| c.is_ascii_digit())
            && fraction.len() <= 6
            && fraction.bytes().all(|c| c.is_ascii_digit()),
        "invalid CCD amount"
    );
    let whole: u64 = whole.parse().context("CCD amount overflow")?;
    let fraction: u64 = format!("{fraction:0<6}").parse()?;
    whole
        .checked_mul(MICRO_CCD)
        .and_then(|w| w.checked_add(fraction))
        .context("CCD amount overflow")
}

/// At most two decimals, with k/m/b/t suffixes. Keep small nonzero amounts visible.
pub fn format_ccd(amount: u64) -> String {
    let units = [
        (1_u64, ""),
        (1_000, "k"),
        (1_000_000, "m"),
        (1_000_000_000, "b"),
        (1_000_000_000_000, "t"),
    ];
    for (index, &(unit, suffix)) in units.iter().enumerate() {
        let divisor = u128::from(unit) * u128::from(MICRO_CCD);
        let hundredths = (u128::from(amount) * 100 + divisor / 2) / divisor;
        if hundredths >= 100_000 && index + 1 < units.len() {
            continue;
        }
        if amount > 0 && hundredths == 0 {
            return "<0.01".into();
        }
        let decimal = format!("{}.{:02}", hundredths / 100, hundredths % 100);
        return format!(
            "{}{suffix}",
            decimal.trim_end_matches('0').trim_end_matches('.')
        );
    }
    unreachable!()
}

pub fn render_report(date: NaiveDate, accounts: &[(&str, Balance)]) -> String {
    let mut report = format!("CCD Status Report {}:\n", date.format("%d/%m/%Y"));
    for (name, balance) in accounts {
        report.push_str(&format!(
            "{name}, staked {}, available {}\n",
            format_ccd(balance.staked),
            format_ccd(balance.available().expect("validated balance"))
        ));
    }
    report
}

#[cfg(test)]
mod tests {
    use super::*;

    const ADDRESS: &str = "3d4tsSiBrJXn2aiNHdfqMq2b9oGttoKn2LDCZbHHMm1WZi2c95";

    #[test]
    fn csv_supports_header_quotes_whitespace_and_indices() {
        let csv = format!("Name,Address\r\n\"Savings, joint\", {ADDRESS}\r\nValidator,76933\r\n");
        let accounts = read_accounts(csv.as_bytes()).unwrap();
        assert_eq!(accounts.len(), 2);
        assert_eq!(accounts[0].name, "Savings, joint");
        assert_eq!(accounts[0].address, ADDRESS);
        assert_eq!(
            read_accounts(b"Savings,76933\n".as_slice()).unwrap().len(),
            1
        );
    }

    #[test]
    fn csv_rejects_empty_malformed_and_unsafe_records() {
        for input in [
            "",
            "Name,Address\n",
            ",76933",
            "Savings,",
            "Savings,76933,extra",
            "Savings,../../account",
            "Savings,https://example.com",
            "\"Name\nInjected\",76933",
        ] {
            assert!(read_accounts(input.as_bytes()).is_err(), "{input:?}");
        }
    }

    #[test]
    fn parses_split_spans_and_decimal_micro_ccd_exactly() {
        let page = Html::parse_document(include_str!("../tests/fixtures/validator.html"));
        let validator =
            Html::parse_fragment(include_str!("../tests/fixtures/validator-details.html"));
        assert_eq!(canonical_address(&page).unwrap(), ADDRESS);
        let balance = parse_balance(&page, Some(&validator)).unwrap();
        assert_eq!(
            balance,
            Balance {
                total: 47_342_463_644_448,
                staked: 47_000_000_000_000
            }
        );
        assert_eq!(balance.available().unwrap(), 342_463_644_448);
        // Pool Total Stake and Delegated rows must never be counted as own stake.
        assert!(parse_balance(&page, None).is_err());
    }

    #[test]
    fn parses_delegation_and_unstaked_accounts() {
        let page = Html::parse_document(include_str!("../tests/fixtures/delegator.html"));
        let balance = parse_balance(&page, None).unwrap();
        assert_eq!(balance.staked, 45_464_357_000_000);
        assert_eq!(balance.available().unwrap(), 5_051_881_519_893);
        let page = Html::parse_document(
            "<table><tr><td>Account Balance</td><td>Ͼ12.000001</td></tr></table>",
        );
        assert_eq!(
            parse_balance(&page, None).unwrap(),
            Balance {
                total: 12_000_001,
                staked: 0
            }
        );
    }

    #[test]
    fn fails_on_missing_or_invalid_balances() {
        for value in [
            "-1",
            "NaN",
            "1.1234567",
            "1,23",
            "unknown",
            "18446744073709551615",
        ] {
            assert!(parse_amount(value).is_err(), "{value}");
        }
        assert!(parse_balance(&Html::parse_document("<h1>Not found</h1>"), None).is_err());
        assert!(
            Balance {
                total: 0,
                staked: 1
            }
            .available()
            .is_err()
        );
        let page = Html::parse_document(
            "<table><tr><td>Account Balance</td><td>1</td></tr></table><button id='pills-delegation-tab'></button>",
        );
        assert!(parse_balance(&page, None).is_err());
    }

    #[test]
    fn compact_numbers_round_promote_and_preserve_small_amounts() {
        for (amount, expected) in [
            (0, "0"),
            (1, "<0.01"),
            (10_000, "0.01"),
            (999_000_000, "999"),
            (999_999_000, "1k"),
            (1_234_560_000, "1.23k"),
            (999_999_000_000, "1m"),
            (47_000_000_000_000, "47m"),
            (342_463_644_448, "342.46k"),
            (1_250_000_000_000_000, "1.25b"),
            (1_000_000_000_000_000_000, "1t"),
        ] {
            assert_eq!(format_ccd(amount), expected);
        }
    }

    #[test]
    fn report_matches_requested_format_and_preserves_order() {
        let date = NaiveDate::from_ymd_opt(2026, 11, 4).unwrap();
        assert_eq!(
            render_report(
                date,
                &[
                    (
                        "Savings",
                        Balance {
                            total: 47_342_463_644_448,
                            staked: 47_000_000_000_000
                        }
                    ),
                    (
                        "Wallet",
                        Balance {
                            total: 12_500_000,
                            staked: 0
                        }
                    )
                ]
            ),
            "CCD Status Report 04/11/2026:\nSavings, staked 47m, available 342.46k\nWallet, staked 0, available 12.5\n"
        );
    }
}

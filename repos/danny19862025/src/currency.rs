use serde::Deserialize;
use std::{
    collections::{HashMap, HashSet},
    process::Command,
    time::Instant,
};

pub type Pair = (String, String);
#[derive(Default)]
pub struct State {
    pub cache: HashMap<Pair, (Instant, Result<Rate, String>)>,
    pub pending: HashSet<Pair>,
}

#[derive(Debug, PartialEq)]
pub struct Query {
    pub amount: f64,
    pub pair: Pair,
}

pub fn parse(text: &str) -> Option<Query> {
    let normalized = text.trim().to_ascii_uppercase().replace(" IN ", " TO ");
    let (left, target) = normalized.split_once(" TO ")?;
    let left = left.trim();
    let target = target.trim();
    let at = left.len().checked_sub(3)?;
    let source = left.get(at..)?;
    if target.len() != 3
        || !source
            .bytes()
            .chain(target.bytes())
            .all(|b| b.is_ascii_uppercase())
    {
        return None;
    }
    let amount: f64 = left.get(..at)?.trim().parse().ok()?;
    amount.is_finite().then(|| Query {
        amount,
        pair: (source.into(), target.into()),
    })
}

#[derive(Clone, Debug, Deserialize)]
pub struct Rate {
    pub date: String,
    pub base: String,
    pub quote: String,
    pub rate: f64,
}

pub fn decode(bytes: &[u8], pair: &Pair) -> Result<Rate, String> {
    let rate: Rate = serde_json::from_slice(bytes).map_err(|_| "Invalid exchange-rate response")?;
    if rate.base != pair.0
        || rate.quote != pair.1
        || !rate.rate.is_finite()
        || rate.rate <= 0.
        || rate.date.len() != 10
        || !rate.date.bytes().enumerate().all(|(i, b)| {
            if i == 4 || i == 7 {
                b == b'-'
            } else {
                b.is_ascii_digit()
            }
        })
    {
        return Err("Invalid exchange-rate response".into());
    }
    Ok(rate)
}

pub fn fetch(pair: &Pair) -> Result<Rate, String> {
    let url = format!("https://api.frankfurter.dev/v2/rate/{}/{}", pair.0, pair.1);
    let output = Command::new("curl")
        .args([
            "--fail",
            "--silent",
            "--show-error",
            "--connect-timeout",
            "5",
            "--max-time",
            "12",
            "--max-filesize",
            "65536",
            &url,
        ])
        .output()
        .map_err(|_| "Currency conversion requires curl")?;
    if !output.status.success() {
        return Err(
            "Rate unavailable · check your connection and currency codes · retry in 30s".into(),
        );
    }
    decode(&output.stdout, pair)
}

pub fn convert(query: &Query, rate: f64) -> Option<String> {
    let amount = query.amount * rate;
    amount
        .is_finite()
        .then(|| format!("{amount:.2} {}", query.pair.1))
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn currency_queries_and_conversion() {
        for input in ["100 USD to AUD", "100usd in aud", " 100 usd to aud "] {
            let q = parse(input).unwrap();
            assert_eq!(q.pair, ("USD".into(), "AUD".into()));
            assert_eq!(convert(&q, 1.5).as_deref(), Some("150.00 AUD"));
        }
        for input in [
            "usd to aud",
            "NaN usd to aud",
            "100 usd to aud/evil",
            "2+2",
            "100 usd to au",
        ] {
            assert!(parse(input).is_none(), "{input}");
        }
    }
    #[test]
    fn validates_provider_response() {
        let pair = ("USD".into(), "AUD".into());
        let good = br#"{"date":"2026-10-15","base":"USD","quote":"AUD","rate":1.5}"#;
        assert_eq!(decode(good, &pair).unwrap().rate, 1.5);
        assert!(decode(good, &("EUR".into(), "AUD".into())).is_err());
        assert!(
            decode(
                br#"{"date":"2026-10-15","base":"USD","quote":"AUD","rate":-1}"#,
                &pair
            )
            .is_err()
        );
        assert!(decode(br#"{"message":"invalid currency"}"#, &pair).is_err());
    }
}

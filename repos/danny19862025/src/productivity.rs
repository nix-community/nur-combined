use crate::{
    boosters::{self, Entry, Operation as Op, entry, hint},
    core, localai, pluginstore,
};
use gtk::glib;
use std::{
    path::PathBuf,
    process::Command,
    sync::{Arc, atomic::AtomicBool},
};
#[derive(Clone, Debug, PartialEq, Eq, Hash)]
pub enum Query {
    Ai(String),
    Meet(String),
    Store(String),
}
impl Query {
    pub fn parse(text: &str) -> Option<Self> {
        let (head, tail) = text
            .trim()
            .split_once(char::is_whitespace)
            .unwrap_or((text.trim(), ""));
        Some(match head.to_ascii_lowercase().as_str() {
            "ai" => Self::Ai(tail.trim().into()),
            "meet" => Self::Meet(tail.trim().into()),
            "store" => Self::Store(tail.trim().into()),
            _ => return None,
        })
    }
}
#[derive(Clone, Debug)]
pub enum Operation {
    Context(String),
    SummarizeClipboard,
    Plugin(pluginstore::Plugin),
}
pub fn fetch(query: &Query) -> Result<Vec<Entry>, String> {
    match query {
        Query::Store(filter) => pluginstore::entries(filter),
        Query::Meet(input) => meeting(input),
        Query::Ai(input) if input == "models" => {
            let value = localai::request("models", "", "", Arc::new(AtomicBool::new(false)))?;
            let mut rows = Vec::new();
            for name in value["models"]
                .as_array()
                .into_iter()
                .flatten()
                .filter_map(|v| v.as_str())
            {
                rows.push(hint(
                    name,
                    "Installed local model · select a model in Settings → General",
                ));
            }
            if rows.is_empty() {
                rows.push(hint(
                    "No local models installed",
                    "Install a local text model with Ollama first",
                ));
            }
            Ok(rows)
        }
        Query::Ai(input) if input == "summarize clipboard" => Ok(vec![entry(
            "Summarize clipboard locally",
            "Enter to read clipboard text · local Ollama only · no model downloads",
            "Local AI",
            Op::Productivity(Operation::SummarizeClipboard),
        )]),
        Query::Ai(input) => Ok(vec![entry(
            "Ask local AI with context",
            "Review selected project, window titles and todos before sending · local Ollama only",
            "Local AI",
            Op::Productivity(Operation::Context(
                input
                    .strip_prefix("ask ")
                    .or_else(|| input.strip_prefix("context "))
                    .unwrap_or(if input == "context" { "" } else { input })
                    .into(),
            )),
        )]),
    }
}
pub fn helper(name: &str) -> Result<PathBuf, String> {
    let beside = std::env::current_exe()
        .ok()
        .and_then(|p| p.parent().map(|p| p.join(name)));
    [
        beside,
        Some(core::home().join(".local/lib/spotlight").join(name)),
    ]
    .into_iter()
    .flatten()
    .find(|p| p.is_file())
    .ok_or_else(|| {
        format!("Missing {name} · install the optional calendar helpers from docs/PIM.md")
    })
}
pub fn duration(text: &str) -> Result<i64, String> {
    let unit = text
        .chars()
        .next_back()
        .ok_or("Use a duration such as 2h or 30m")?;
    let number = text[..text.len() - unit.len_utf8()]
        .parse::<i64>()
        .map_err(|_| "Use a duration such as 2h or 30m")?;
    if !(0..=10080).contains(&number) {
        return Err("Duration is out of range".into());
    }
    number
        .checked_mul(match unit {
            'm' => 60,
            'h' => 3600,
            'd' => 86400,
            _ => return Err("Use m, h, or d for minutes, hours, or days".into()),
        })
        .ok_or_else(|| "Duration is out of range".into())
}
pub fn first_slot(earliest: i64, end: i64, length: i64, busy: &[(i64, i64)]) -> Option<i64> {
    if earliest >= end || length <= 0 {
        return None;
    }
    let mut intervals = busy.to_vec();
    intervals.sort_unstable();
    let mut candidate = earliest;
    for (start, finish) in intervals {
        if finish <= candidate || finish <= start {
            continue;
        }
        if start >= candidate.checked_add(length)? {
            return (candidate.checked_add(length)? <= end).then_some(candidate);
        }
        candidate = candidate.max(finish);
    }
    (candidate.checked_add(length)? <= end).then_some(candidate)
}
fn meeting(input: &str) -> Result<Vec<Entry>, String> {
    let words: Vec<_> = input.split_whitespace().collect();
    if words.len() != 2 && words.len() != 4 {
        return Ok(vec![hint(
            "Find a free meeting slot",
            "meet in 2h · meet in 2h for 45m · defaults to a 30-minute slot",
        )]);
    }
    if words[0] != "in" || (words.len() == 4 && words[2] != "for") {
        return Err("Use meet in 2h or meet in 2h for 45m".into());
    }
    let offset = duration(words[1])?;
    let length = if words.len() == 4 {
        duration(words[3])?
    } else {
        1800
    };
    if offset > 7 * 86400 || !(300..=28800).contains(&length) {
        return Err("Start within seven days and choose a meeting of 5 minutes to 8 hours".into());
    }
    let earliest = (glib::DateTime::now_utc()
        .map_err(|e| e.to_string())?
        .to_unix()
        + offset
        + 299)
        / 300
        * 300;
    let end = earliest + 7 * 86400;
    let records = boosters::run(
        Command::new(helper("spotlight-pim")?).arg("calendar-busy"),
        10,
    )?;
    let records: serde_json::Value =
        serde_json::from_str(&records).map_err(|_| "Invalid cached Akonadi calendar response")?;
    if !records.is_array() {
        return Err("Invalid cached Akonadi calendar response".into());
    }
    let request=serde_json::to_vec(&serde_json::json!({"items":records,"start":earliest,"end":end,"timezone":glib::TimeZone::local().identifier().to_string()})).map_err(|e|e.to_string())?;
    let result = boosters::run_input(
        &mut Command::new(helper("spotlight-freebusy")?),
        7,
        Some(&request),
    )?;
    let result: serde_json::Value =
        serde_json::from_str(&result).map_err(|_| "Invalid calendar recurrence response")?;
    let mut busy = Vec::new();
    for span in result["busy"]
        .as_array()
        .ok_or("Missing busy calendar intervals")?
    {
        let start = span
            .get(0)
            .and_then(|v| v.as_i64())
            .ok_or("Invalid busy interval")?;
        let end = span
            .get(1)
            .and_then(|v| v.as_i64())
            .ok_or("Invalid busy interval")?;
        busy.push((start, end));
    }
    let Some(start) = first_slot(earliest, end, length, &busy) else {
        return Ok(vec![hint(
            "No free slot found",
            "No matching slot in the following seven days of cached Akonadi events",
        )]);
    };
    let start = glib::DateTime::from_unix_local(start).map_err(|e| e.to_string())?;
    let end = start
        .add_seconds(length as f64)
        .map_err(|e| e.to_string())?;
    let label = start
        .format("%a %d %b %Y · %H:%M %Z")
        .map_err(|e| e.to_string())?;
    Ok(vec![entry(
        format!("Free · {label}"),
        format!(
            "{} minutes · cached Akonadi calendars · Enter for details",
            length / 60
        ),
        "Free/busy",
        Op::Preview {
            title: "Available meeting slot".into(),
            text: format!(
                "Start: {label}\nEnd: {}\nDuration: {} minutes\n\nBased on cached Akonadi calendars. Open KOrganizer to synchronize changes. No event was created. Search covers all hours, with a seven-day horizon.",
                end.format("%a %d %b %Y · %H:%M %Z")
                    .map_err(|e| e.to_string())?,
                length / 60
            ),
            open: None,
        },
    )])
}
#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn merged_busy_and_boundaries() {
        assert_eq!(
            first_slot(
                100,
                500,
                30,
                &[(90, 150), (140, 170), (170, 200), (250, 300)]
            ),
            Some(200)
        );
        assert_eq!(first_slot(100, 150, 50, &[]), Some(100));
        assert_eq!(first_slot(100, 149, 50, &[]), None);
        assert_eq!(first_slot(100, 300, 30, &[(130, 160)]), Some(100));
        assert_eq!(duration("2h").unwrap(), 7200);
        assert!(duration("-2h").is_err());
        assert!(duration("2.5h").is_err());
        assert!(Query::parse("storehouse").is_none());
    }
}

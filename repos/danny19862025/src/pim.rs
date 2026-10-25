use crate::{
    boosters::{self, Entry, Operation},
    core,
};
use gtk::{gio, glib, prelude::*};
use serde::Deserialize;
use std::{
    collections::HashSet,
    fs,
    io::Read,
    path::{Path, PathBuf},
    process::Command,
};

#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum Kind {
    Contacts,
    Calendar,
}
#[derive(Deserialize)]
struct NativeItem {
    payload: String,
    collection: String,
    uri: String,
}
pub fn fetch(kind: Kind, query: &str) -> Result<Vec<Entry>, String> {
    if query.len() > 512 {
        return Err("Contact and calendar search text is limited to 512 bytes".into());
    }
    let helper = helper_path();
    let mut rows = Vec::new();
    let mut status = None;
    let mut desktop_calendar = false;
    if kind == Kind::Calendar && !std::env::args().any(|a| a == "--smoke-test") {
        match crate::calendar::desktop_events(query) {
            Ok(events) => {
                desktop_calendar = true;
                for event in events {
                    rows.extend(parse(kind, &event.payload, &event.collection, None));
                }
            }
            Err(error) => status = Some(format!("Desktop calendar unavailable: {error}")),
        }
    }
    if let Some(helper) = helper {
        match boosters::run(
            Command::new(helper).arg(if kind == Kind::Contacts {
                "contacts"
            } else {
                "calendar"
            }),
            10,
        ) {
            Ok(output) => {
                let items: Vec<NativeItem> =
                    serde_json::from_str(&output).map_err(|_| "Invalid Akonadi bridge response")?;
                for item in items.into_iter().take(2000) {
                    let uri = item.uri.starts_with("akonadi:").then_some(item.uri);
                    rows.extend(parse(kind, &item.payload, &item.collection, uri.as_deref()));
                }
            }
            Err(error) if !desktop_calendar => status = Some(error),
            Err(_) => {}
        }
    } else if !desktop_calendar && status.is_none() {
        status = Some("Desktop calendar bridge is unavailable · see docs/PIM.md".into());
    }
    // Also read the local vCard/iCalendar resources configured by KAddressBook/Akonadi.
    let mut seen = HashSet::new();
    let started = std::time::Instant::now();
    let mut bytes = 0usize;
    for path in resource_files(kind) {
        if started.elapsed() > std::time::Duration::from_secs(3) || bytes > 16_777_216 {
            break;
        }
        if !seen.insert(path.clone()) {
            continue;
        }
        let Ok(file) = fs::File::open(&path) else {
            continue;
        };
        let mut body = String::new();
        if file.take(2_097_153).read_to_string(&mut body).is_err() || body.len() > 2_097_152 {
            continue;
        }
        bytes += body.len();
        let uri = gio::File::for_path(&path).uri();
        rows.extend(parse(kind, &body, &path.display().to_string(), Some(&uri)));
        if rows.len() >= 4000 {
            break;
        }
    }
    let mut ranked: Vec<_> = rows
        .into_iter()
        .filter_map(|row| {
            let score = core::score(query, &format!("{} {}", row.title, row.detail))?;
            Some((score, row))
        })
        .collect();
    ranked.sort_by(|a, b| b.0.cmp(&a.0).then(a.1.title.cmp(&b.1.title)));
    let mut unique = HashSet::new();
    let mut results: Vec<_> = ranked
        .into_iter()
        .map(|(_, row)| row)
        .filter(|row| {
            unique.insert((
                row.title.clone(),
                row.detail
                    .split(" · Source:")
                    .next()
                    .unwrap_or("")
                    .to_owned(),
            ))
        })
        .take(60)
        .collect();
    if results.is_empty() {
        results.push(boosters::hint(if kind == Kind::Contacts { "No matching contacts" } else { "No matching calendar events" }, status.as_deref().unwrap_or("Searches cached Akonadi items and configured local resources · open your PIM app to sync")));
    } else if let Some(status) = status {
        results.push(boosters::hint("Local resources only", status));
    }
    Ok(results)
}
fn helper_path() -> Option<PathBuf> {
    let binary = std::env::current_exe().ok()?;
    [
        binary.parent()?.join("spotlight-pim"),
        core::home().join(".local/lib/spotlight/spotlight-pim"),
    ]
    .into_iter()
    .find(|p| p.is_file())
}
fn resource_files(kind: Kind) -> Vec<PathBuf> {
    let data = glib::user_data_dir();
    let config = glib::user_config_dir();
    let mut roots = if kind == Kind::Contacts {
        vec![
            data.join("contacts"),
            data.join("kaddressbook"),
            core::data_dir().join("contacts"),
        ]
    } else {
        vec![
            data.join("local-mail/calendar"),
            data.join("korganizer"),
            data.join("calendar"),
            core::data_dir().join("calendars"),
        ]
    };
    for e in fs::read_dir(&config)
        .into_iter()
        .flatten()
        .flatten()
        .take(3000)
    {
        let name = e.file_name();
        let name = name.to_string_lossy();
        let relevant = if kind == Kind::Contacts {
            name.starts_with("akonadi_contacts_resource_")
                || name.starts_with("akonadi_vcard_resource_")
                || name.starts_with("akonadi_vcarddir_resource_")
        } else {
            name.starts_with("akonadi_ical_resource_")
                || name.starts_with("akonadi_icaldir_resource_")
                || name.starts_with("akonadi_davgroupware_resource_")
        };
        if !relevant || !name.ends_with("rc") {
            continue;
        }
        let key = glib::KeyFile::new();
        if key
            .load_from_file(e.path(), glib::KeyFileFlags::KEEP_TRANSLATIONS)
            .is_err()
        {
            continue;
        }
        for group in key.groups().iter() {
            for keyname in [
                "Path",
                "Path[$e]",
                "File",
                "File[$e]",
                "Directory",
                "Directory[$e]",
                "Url",
                "Url[$e]",
            ] {
                let Ok(value) = key.string(group, keyname) else {
                    continue;
                };
                let path = if value.starts_with("file:") {
                    gio::File::for_uri(&value).path()
                } else if let Some(path) = value
                    .strip_prefix("$HOME/")
                    .or_else(|| value.strip_prefix("~/"))
                {
                    Some(core::home().join(path))
                } else if Path::new(value.as_str()).is_absolute() {
                    Some(PathBuf::from(value.as_str()))
                } else {
                    None
                };
                if let Some(path) = path {
                    roots.push(path);
                }
            }
        }
    }
    let mut files = Vec::new();
    let mut pending: Vec<_> = roots.into_iter().map(|p| (p, 0)).collect();
    let mut visited = 0;
    while let Some((path, depth)) = pending.pop() {
        visited += 1;
        if visited > 6000 || files.len() >= 2000 {
            break;
        }
        if path.is_file() {
            let ext = path.extension().and_then(|s| s.to_str()).unwrap_or("");
            if (kind == Kind::Contacts && ext.eq_ignore_ascii_case("vcf"))
                || (kind == Kind::Calendar
                    && ["ics", "ical"].iter().any(|s| ext.eq_ignore_ascii_case(s)))
            {
                files.push(path);
            }
        } else if path.is_dir() && depth < 4 {
            for e in fs::read_dir(path).into_iter().flatten().flatten() {
                if e.file_type().is_ok_and(|t| !t.is_symlink()) {
                    pending.push((e.path(), depth + 1));
                }
            }
        }
    }
    files
}
fn unescape(text: &str) -> String {
    let mut result = String::new();
    let mut chars = text.chars();
    while let Some(c) = chars.next() {
        if c == '\\' {
            match chars.next() {
                Some('n' | 'N') => result.push('\n'),
                Some(c) => result.push(c),
                None => result.push('\\'),
            }
        } else {
            result.push(c);
        }
    }
    result
}
fn parse(kind: Kind, text: &str, source: &str, uri: Option<&str>) -> Vec<Entry> {
    let mut lines: Vec<String> = Vec::new();
    for line in text.lines().take(30000) {
        let line = line.trim_end_matches('\r');
        if line.starts_with([' ', '\t'])
            && let Some(previous) = lines.last_mut()
        {
            previous.push_str(&line[1..]);
        } else {
            lines.push(line.into());
        }
    }
    let (start, end) = if kind == Kind::Contacts {
        ("BEGIN:VCARD", "END:VCARD")
    } else {
        ("BEGIN:VEVENT", "END:VEVENT")
    };
    let mut result = Vec::new();
    let mut fields: Vec<(String, String)> = Vec::new();
    let mut active = false;
    let mut nested = 0;
    for line in lines {
        if line.eq_ignore_ascii_case(start) {
            active = true;
            fields.clear();
            nested = 0;
            continue;
        }
        if line.eq_ignore_ascii_case(end) && active {
            let values = |key: &str| {
                fields
                    .iter()
                    .filter(|(k, _)| k == key)
                    .take(20)
                    .map(|(_, v)| v.clone())
                    .collect::<Vec<_>>()
            };
            let first = |key: &str| values(key).into_iter().next().unwrap_or_default();
            let title = if kind == Kind::Contacts {
                let name = first("FN");
                if name.is_empty() {
                    first("N").replace(';', " ").trim().into()
                } else {
                    name
                }
            } else {
                first("SUMMARY")
            };
            let title: String = title
                .chars()
                .filter(|c| !c.is_control())
                .take(240)
                .collect();
            if !title.is_empty() {
                let detail = if kind == Kind::Contacts {
                    format!(
                        "{} · {} · {}",
                        values("EMAIL").join(", "),
                        values("TEL").join(", "),
                        first("ORG").replace(';', " ")
                    )
                } else {
                    format!(
                        "{} · {} · {}",
                        date(&first("DTSTART")),
                        first("LOCATION"),
                        first("DESCRIPTION").lines().next().unwrap_or("")
                    )
                };
                let display = fields
                    .iter()
                    .filter(|(k, _)| {
                        if kind == Kind::Contacts {
                            [
                                "FN", "N", "EMAIL", "TEL", "ORG", "TITLE", "ADR", "NOTE", "URL",
                            ]
                            .contains(&k.as_str())
                        } else {
                            [
                                "SUMMARY",
                                "DTSTART",
                                "DTEND",
                                "LOCATION",
                                "DESCRIPTION",
                                "RRULE",
                                "STATUS",
                                "ORGANIZER",
                            ]
                            .contains(&k.as_str())
                        }
                    })
                    .map(|(k, v)| format!("{k}: {v}"))
                    .take(32)
                    .collect::<Vec<_>>()
                    .join("\n\n");
                let display: String = display.chars().take(8192).collect();
                result.push(Entry {
                    title: title.clone(),
                    detail: format!("{detail} · Source: {source}"),
                    badge: if kind == Kind::Contacts {
                        "Contact"
                    } else {
                        "Event"
                    },
                    operation: Some(Operation::Preview {
                        title,
                        text: format!("{display}\n\nSource: {source}"),
                        open: uri.map(str::to_owned),
                    }),
                });
            }
            active = false;
            continue;
        }
        if !active {
            continue;
        }
        if line.starts_with("BEGIN:") {
            nested += 1;
            continue;
        }
        if line.starts_with("END:") {
            nested -= 1;
            continue;
        }
        if nested > 0 {
            continue;
        }
        let Some((key, value)) = line.split_once(':') else {
            continue;
        };
        let base = key
            .split(';')
            .next()
            .unwrap_or(key)
            .rsplit('.')
            .next()
            .unwrap_or(key)
            .to_ascii_uppercase();
        let mut value = unescape(value);
        if (base == "DTSTART" || base == "DTEND")
            && let Some(tz) = key.split(';').find_map(|p| p.strip_prefix("TZID="))
        {
            value = format!("{value} ({tz})");
        }
        fields.push((base, value.chars().take(4096).collect()));
    }
    result
}
fn date(value: &str) -> String {
    if value.len() >= 8 && value.as_bytes()[..8].iter().all(u8::is_ascii_digit) {
        let rest = &value[8..];
        if let Some(rest) = rest.strip_prefix('T')
            && rest.len() >= 4
            && rest.as_bytes()[..4].iter().all(u8::is_ascii_digit)
        {
            return format!(
                "{}-{}-{} {}:{}{}",
                &value[..4],
                &value[4..6],
                &value[6..8],
                &rest[..2],
                &rest[2..4],
                if rest.ends_with('Z') {
                    " UTC"
                } else {
                    rest.get(6..).unwrap_or("")
                }
            );
        }
        return format!(
            "{}-{}-{} (all day)",
            &value[..4],
            &value[4..6],
            &value[6..8]
        );
    }
    value.into()
}
#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn vcard_and_calendar_unfolding_and_fields() {
        let rows = parse(
            Kind::Contacts,
            "BEGIN:VCARD\r\nVERSION:3.0\r\nFN:Danny Ex\r\n ample\r\nEMAIL;TYPE=HOME:danny@example.test\r\nTEL:+61 123\r\nNOTE:Hello\\nworld\r\nEND:VCARD",
            "Test",
            None,
        );
        assert_eq!(rows[0].title, "Danny Example");
        assert!(rows[0].detail.contains("danny@example.test"));
        let rows = parse(
            Kind::Calendar,
            "BEGIN:VCALENDAR\nBEGIN:VEVENT\nSUMMARY:Rust meetup\nDTSTART;TZID=Australia/Sydney:20261020T180000\nLOCATION:Room\\, one\nBEGIN:VALARM\nDESCRIPTION:Alarm\nEND:VALARM\nDESCRIPTION:Discuss Rust\nEND:VEVENT\nEND:VCALENDAR",
            "Work",
            Some("akonadi:?item=1"),
        );
        assert_eq!(rows[0].title, "Rust meetup");
        assert!(rows[0].detail.contains("2026-10-20 18:00"));
        assert!(rows[0].detail.contains("Australia/Sydney"));
        assert!(rows[0].detail.contains("Room, one"));
        assert_eq!(date("20261020"), "2026-10-20 (all day)");
        assert!(parse(Kind::Calendar, "BEGIN:VEVENT\nSUMMARY:incomplete", "", None).is_empty());
    }
}

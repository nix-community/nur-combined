use gtk::glib;
use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, PartialEq)]
pub enum Draft {
    Timer(u64),
    Pomodoro(u64),
    AlarmAfter(u64),
    Alarm { hour: i32, minute: i32 },
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Reminder {
    pub id: String,
    pub title: String,
    pub due: i64,
    pub alarm: bool,
    #[serde(default)]
    pub pomodoro: bool,
}

fn duration(text: &str) -> Option<u64> {
    let text = text.trim();
    if let Ok(minutes) = text.parse::<f64>() {
        return seconds(minutes * 60.);
    }
    let mut input = text;
    let mut total = 0.;
    while !input.trim().is_empty() {
        input = input.trim_start();
        let end = input
            .find(|c: char| !c.is_ascii_digit() && c != '.')
            .unwrap_or(input.len());
        let value: f64 = input[..end].parse().ok()?;
        input = input[end..].trim_start();
        let end = input
            .find(|c: char| !c.is_ascii_alphabetic())
            .unwrap_or(input.len());
        let factor = match &input[..end] {
            "s" | "sec" | "secs" | "second" | "seconds" => 1.,
            "m" | "min" | "mins" | "minute" | "minutes" => 60.,
            "h" | "hr" | "hrs" | "hour" | "hours" => 3600.,
            "d" | "day" | "days" => 86400.,
            _ => return None,
        };
        total += value * factor;
        input = &input[end..];
    }
    seconds(total)
}

fn seconds(value: f64) -> Option<u64> {
    (value.is_finite() && (1.0..=31_536_000.0).contains(&value)).then(|| value.round() as u64)
}

pub fn parse(text: &str) -> Option<Result<Draft, &'static str>> {
    let input = text.trim().to_ascii_lowercase();
    if input == "pomodoro" {
        return Some(Ok(Draft::Pomodoro(1500)));
    }
    if let Some(rest) = input.strip_prefix("pomodoro ") {
        return Some(
            duration(rest)
                .filter(|s| *s <= 86400)
                .map(Draft::Pomodoro)
                .ok_or("Try pomodoro 25m · maximum 24 hours"),
        );
    }
    let (alarm, mut rest) = [
        ("set a timer", false),
        ("set timer", false),
        ("timer", false),
        ("set an alarm", true),
        ("set alarm", true),
        ("alarm", true),
    ]
    .into_iter()
    .find_map(|(prefix, alarm)| {
        let rest = input.strip_prefix(prefix)?;
        (rest.is_empty() || rest.starts_with(char::is_whitespace)).then_some((alarm, rest.trim()))
    })?;
    let relative_alarm = alarm && (rest.starts_with("after ") || rest.starts_with("in "));
    for prefix in ["for ", "after ", "at ", "in "] {
        if let Some(value) = rest.strip_prefix(prefix) {
            rest = value.trim();
            break;
        }
    }
    if relative_alarm {
        return Some(
            duration(rest)
                .map(Draft::AlarmAfter)
                .ok_or("Try alarm in 5 minutes or alarm after 30 seconds"),
        );
    }
    if !alarm {
        return Some(
            duration(rest)
                .map(Draft::Timer)
                .ok_or("Try timer 5m, timer 1h30m, or timer 30 seconds"),
        );
    }
    let clock = rest.replace(' ', "");
    let (clock, am_pm) = if let Some(value) = clock.strip_suffix("am") {
        (value, Some(false))
    } else if let Some(value) = clock.strip_suffix("pm") {
        (value, Some(true))
    } else {
        (clock.as_str(), None)
    };
    let parsed = (|| {
        let (hour, minute) = clock.split_once(':').unwrap_or((clock, "00"));
        if hour.is_empty()
            || !hour
                .bytes()
                .chain(minute.bytes())
                .all(|b| b.is_ascii_digit())
            || minute.len() != 2
        {
            return None;
        }
        let mut hour: i32 = hour.parse().ok()?;
        let minute: i32 = minute.parse().ok()?;
        if !(0..60).contains(&minute) {
            return None;
        }
        if let Some(pm) = am_pm {
            if !(1..=12).contains(&hour) {
                return None;
            }
            hour = hour % 12 + if pm { 12 } else { 0 };
        } else if !(0..24).contains(&hour) {
            return None;
        }
        Some(Draft::Alarm { hour, minute })
    })();
    Some(parsed.ok_or("Try alarm 7:30 am or alarm 18:45 · next occurrence in your local time"))
}

pub fn duration_label(seconds: u64) -> String {
    let (h, m, s) = (seconds / 3600, seconds / 60 % 60, seconds % 60);
    let mut parts = Vec::new();
    if h > 0 {
        parts.push(format!("{h}h"));
    }
    if m > 0 {
        parts.push(format!("{m}m"));
    }
    if s > 0 || parts.is_empty() {
        parts.push(format!("{s}s"));
    }
    parts.join(" ")
}

impl Draft {
    pub fn label(&self) -> String {
        match self {
            Self::Pomodoro(seconds) => format!("Pomodoro · {}", duration_label(*seconds)),
            Self::Timer(seconds) => format!("Timer · {}", duration_label(*seconds)),
            Self::AlarmAfter(seconds) => format!("Alarm · in {}", duration_label(*seconds)),
            Self::Alarm { hour, minute } => format!("Alarm · {hour:02}:{minute:02}"),
        }
    }

    pub fn create(&self, now: &glib::DateTime) -> Result<Reminder, String> {
        let due = match self {
            Self::Timer(seconds) | Self::Pomodoro(seconds) | Self::AlarmAfter(seconds) => now
                .to_unix()
                .checked_add(*seconds as i64)
                .ok_or("Timer is too long")?,
            Self::Alarm { hour, minute } => {
                let mut date = glib::DateTime::new(
                    &now.timezone(),
                    now.year(),
                    now.month(),
                    now.day_of_month(),
                    *hour,
                    *minute,
                    0.,
                )
                .map_err(|_| "Could not set this local alarm time")?;
                if date.to_unix() <= now.to_unix() {
                    let tomorrow = now
                        .add_days(1)
                        .map_err(|_| "Could not set tomorrow's alarm")?;
                    date = glib::DateTime::new(
                        &tomorrow.timezone(),
                        tomorrow.year(),
                        tomorrow.month(),
                        tomorrow.day_of_month(),
                        *hour,
                        *minute,
                        0.,
                    )
                    .map_err(|_| "Could not set tomorrow's alarm")?;
                }
                date.to_unix()
            }
        };
        Ok(Reminder {
            id: glib::uuid_string_random().to_string(),
            title: self.label(),
            due,
            alarm: matches!(self, Self::AlarmAfter(_) | Self::Alarm { .. }),
            pomodoro: matches!(self, Self::Pomodoro(_)),
        })
    }
}

pub fn take_due(reminders: &mut Vec<Reminder>, now: i64) -> Vec<Reminder> {
    let mut due = Vec::new();
    reminders.retain(|reminder| {
        if reminder.due <= now {
            due.push(reminder.clone());
            false
        } else {
            true
        }
    });
    due
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn timer_and_alarm_queries() {
        assert_eq!(parse("pomodoro"), Some(Ok(Draft::Pomodoro(1500))));
        assert_eq!(parse("pomodoro 25m"), Some(Ok(Draft::Pomodoro(1500))));
        assert!(parse("pomodoro 0").unwrap().is_err());
        assert!(parse("pomodoro 25h").unwrap().is_err());
        assert!(parse("pomodorox").is_none());
        let old: Reminder =
            serde_json::from_str(r#"{"id":"old","title":"Timer","due":100,"alarm":false}"#)
                .unwrap();
        assert!(!old.pomodoro);
        let now = glib::DateTime::now_utc().unwrap();
        let p = Draft::Pomodoro(1500).create(&now).unwrap();
        assert!(p.pomodoro);
        assert!(!p.alarm);
        assert_eq!(p.due - now.to_unix(), 1500);
        for (input, seconds) in [
            ("timer 5m", 300),
            ("set timer for 30 seconds", 30),
            ("timer 1h30m", 5400),
            ("timer 0.5 minutes", 30),
            ("timer 5", 300),
        ] {
            assert_eq!(parse(input), Some(Ok(Draft::Timer(seconds))));
        }
        assert_eq!(
            parse("alarm in 5 minutes"),
            Some(Ok(Draft::AlarmAfter(300)))
        );
        assert_eq!(
            parse("alarm after 30 seconds"),
            Some(Ok(Draft::AlarmAfter(30)))
        );
        for (input, hour, minute) in [
            ("alarm 7:30 am", 7, 30),
            ("set alarm at 6:45pm", 18, 45),
            ("alarm 12 am", 0, 0),
            ("alarm 12 pm", 12, 0),
            ("alarm 23:59", 23, 59),
        ] {
            assert_eq!(parse(input), Some(Ok(Draft::Alarm { hour, minute })));
        }
        for input in [
            "timer 0",
            "timer -5m",
            "timer 1e99",
            "timer 5 bananas",
            "alarm 24:00",
            "alarm 0am",
            "alarm 12:99",
        ] {
            assert!(parse(input).unwrap().is_err(), "{input}");
        }
        assert!(parse("alarmist").is_none());
        assert!(parse("Firefox").is_none());
    }
    #[test]
    fn deadlines_roll_over_and_expire_only_once() {
        let now = glib::DateTime::from_iso8601("2026-10-15T20:00:00+11:00", None).unwrap();
        let alarm = Draft::Alarm {
            hour: 7,
            minute: 30,
        }
        .create(&now)
        .unwrap();
        let local = glib::DateTime::from_unix_utc(alarm.due)
            .unwrap()
            .to_timezone(&now.timezone())
            .unwrap();
        assert_eq!(
            (local.day_of_month(), local.hour(), local.minute()),
            (16, 7, 30)
        );
        let timer = Draft::Timer(5).create(&now).unwrap();
        let mut active = vec![timer, alarm];
        assert!(take_due(&mut active, now.to_unix() + 4).is_empty());
        assert_eq!(take_due(&mut active, now.to_unix() + 5).len(), 1);
        assert!(take_due(&mut active, now.to_unix() + 6).is_empty());
        let restored: Vec<Reminder> =
            serde_json::from_str(&serde_json::to_string(&active).unwrap()).unwrap();
        assert_eq!(restored[0].due, active[0].due);
    }
}

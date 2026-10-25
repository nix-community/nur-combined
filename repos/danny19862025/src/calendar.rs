use crate::{boosters, core};
use gtk::{glib, prelude::*};
use serde::{Deserialize, Serialize};
use std::{
    cell::{Cell, RefCell},
    fs,
    io::Write,
    path::Path,
    process::Command,
    rc::Rc,
    sync::mpsc,
    time::Duration,
};

#[derive(Clone, Debug, PartialEq)]
pub struct Draft {
    pub title: String,
    pub year: i32,
    pub month: i32,
    pub day: i32,
    pub time: Option<(i32, i32)>,
    pub minutes: u32,
    pub location: String,
}

impl Default for Draft {
    fn default() -> Self {
        let now = glib::DateTime::now_local().unwrap();
        Self {
            title: String::new(),
            year: now.year(),
            month: now.month(),
            day: now.day_of_month(),
            time: None,
            minutes: 60,
            location: String::new(),
        }
    }
}

fn date(year: i32, month: i32, day: i32) -> Result<glib::DateTime, String> {
    if !(1900..=9998).contains(&year) {
        return Err("Use a year from 1900 to 9998".into());
    }
    glib::DateTime::new(&glib::TimeZone::utc(), year, month, day, 12, 0, 0.)
        .map_err(|_| "Choose a valid calendar date".into())
}

pub fn parse_date(text: &str) -> Result<(i32, i32, i32), String> {
    let text = text.trim().to_ascii_lowercase().replace(',', " ");
    let parts: Vec<_> = text.split_whitespace().collect();
    let parsed = if parts.len() == 1 && text.contains('-') {
        let parts: Vec<i32> = text
            .split('-')
            .map(str::parse)
            .collect::<Result<_, _>>()
            .map_err(|_| "Use July 13 2027 or 2027-07-13")?;
        if parts.len() != 3 {
            return Err("Use July 13 2027 or 2027-07-13".into());
        }
        (parts[0], parts[1], parts[2])
    } else if parts.len() == 3 {
        let month = |word: &str| {
            [
                "january",
                "february",
                "march",
                "april",
                "may",
                "june",
                "july",
                "august",
                "september",
                "october",
                "november",
                "december",
            ]
            .iter()
            .position(|m| word == *m || word == &m[..3])
            .map(|i| i as i32 + 1)
        };
        let day = |word: &str| {
            let number = ["st", "nd", "rd", "th"]
                .iter()
                .find_map(|suffix| word.strip_suffix(suffix))
                .unwrap_or(word);
            number.parse::<i32>().ok()
        };
        let year = parts[2]
            .parse::<i32>()
            .map_err(|_| "Include a four-digit year")?;
        if let (Some(month), Some(day)) = (month(parts[0]), day(parts[1])) {
            (year, month, day)
        } else if let (Some(day), Some(month)) = (day(parts[0]), month(parts[1])) {
            (year, month, day)
        } else {
            return Err("Use July 13 2027, 13 July 2027, or 2027-07-13".into());
        }
    } else {
        return Err("Use July 13 2027, 13 July 2027, or 2027-07-13".into());
    };
    date(parsed.0, parsed.1, parsed.2)?;
    Ok(parsed)
}

pub fn parse_time(text: &str) -> Result<(i32, i32), String> {
    let text = text.trim().to_ascii_lowercase().replace(' ', "");
    let (clock, pm) = if let Some(clock) = text.strip_suffix("am") {
        (clock, Some(false))
    } else if let Some(clock) = text.strip_suffix("pm") {
        (clock, Some(true))
    } else {
        (text.as_str(), None)
    };
    let (h, m) = clock.split_once(':').unwrap_or((clock, "00"));
    let invalid = || "Use a time such as 9:30 am or 18:00".to_string();
    if h.is_empty() || m.len() != 2 || !h.bytes().chain(m.bytes()).all(|b| b.is_ascii_digit()) {
        return Err(invalid());
    }
    let mut hour: i32 = h.parse().map_err(|_| invalid())?;
    let minute: i32 = m.parse().map_err(|_| invalid())?;
    if !(0..60).contains(&minute) {
        return Err(invalid());
    }
    if let Some(pm) = pm {
        if !(1..=12).contains(&hour) {
            return Err(invalid());
        }
        hour = hour % 12 + if pm { 12 } else { 0 };
    } else if !(0..24).contains(&hour) {
        return Err(invalid());
    }
    Ok((hour, minute))
}

pub fn parse(text: &str) -> Option<Result<Draft, String>> {
    let input = text.trim();
    let lower = input.to_ascii_lowercase();
    let rest = [
        "add calendar event",
        "create calendar event",
        "calendar event",
        "create event",
        "add event",
        "new event",
        "event",
    ]
    .into_iter()
    .find_map(|prefix| {
        lower
            .strip_prefix(prefix)
            .filter(|rest| rest.is_empty() || rest.starts_with(char::is_whitespace))
            .map(|_| input[prefix.len()..].trim())
    })?;
    Some((|| {
        if rest.len() > 1024 {
            return Err("Keep the event text under 1,024 bytes".into());
        }
        if rest.is_empty() {
            return Ok(Draft::default());
        }
        let lower = rest.to_ascii_lowercase();
        let (title, when) = if lower.starts_with("on ") {
            ("", &rest[3..])
        } else if let Some(at) = lower.rfind(" on ") {
            (rest[..at].trim(), &rest[at + 4..])
        } else {
            ("", rest)
        };
        let lower = when.to_ascii_lowercase();
        let (day, time) = if let Some(at) = lower.rfind(" at ") {
            (&when[..at], Some(parse_time(&when[at + 4..])?))
        } else {
            (when, None)
        };
        let (year, month, day) = parse_date(day)?;
        Ok(Draft {
            title: title.into(),
            year,
            month,
            day,
            time,
            ..Draft::default()
        })
    })())
}

fn escape(text: &str) -> String {
    text.replace('\\', "\\\\")
        .replace("\r\n", "\n")
        .replace('\r', "\n")
        .replace('\n', "\\n")
        .replace(';', "\\;")
        .replace(',', "\\,")
}

fn fold(line: &str) -> String {
    let mut out = String::new();
    let mut width = 0;
    for ch in line.chars() {
        if width + ch.len_utf8() > 75 {
            out.push_str("\r\n ");
            width = 1;
        }
        out.push(ch);
        width += ch.len_utf8();
    }
    out.push_str("\r\n");
    out
}

impl Draft {
    pub fn label(&self) -> String {
        let day = date(self.year, self.month, self.day)
            .unwrap()
            .format("%a, %d %b %Y")
            .unwrap();
        match self.time {
            Some((h, m)) => format!("{day} · {h:02}:{m:02} · local time"),
            None => format!("{day} · All day"),
        }
    }

    pub fn ical(&self) -> Result<String, String> {
        if self.title.trim().is_empty() {
            return Err("Enter an event title".into());
        }
        if self.title.len() > 1024 || self.location.len() > 4096 {
            return Err("The title or location is too long".into());
        }
        if self.title.chars().any(char::is_control)
            || self.location.chars().any(|c| c.is_control() && c != '\n')
        {
            return Err("Remove control characters from the event".into());
        }
        let day = date(self.year, self.month, self.day)?;
        let mut lines = vec![
            "BEGIN:VEVENT".into(),
            format!("UID:{}@spotlight.local", glib::uuid_string_random()),
            format!(
                "DTSTAMP:{}",
                glib::DateTime::now_utc()
                    .map_err(|e| e.to_string())?
                    .format("%Y%m%dT%H%M%SZ")
                    .unwrap()
            ),
            format!("SUMMARY:{}", escape(self.title.trim())),
        ];
        if let Some((hour, minute)) = self.time {
            if !(1..=1440).contains(&self.minutes) {
                return Err("Use a duration from 1 to 1,440 minutes".into());
            }
            let start = glib::DateTime::new(
                &glib::TimeZone::local(),
                self.year,
                self.month,
                self.day,
                hour,
                minute,
                0.,
            )
            .map_err(|_| "Choose a valid local time")?;
            if start.hour() != hour || start.minute() != minute {
                return Err(
                    "This local time does not exist because the clocks change; choose another time"
                        .into(),
                );
            }
            let end = start
                .add_minutes(self.minutes as i32)
                .map_err(|e| e.to_string())?;
            for (key, value) in [("DTSTART", start), ("DTEND", end)] {
                lines.push(format!(
                    "{key}:{}",
                    value
                        .to_utc()
                        .map_err(|e| e.to_string())?
                        .format("%Y%m%dT%H%M%SZ")
                        .unwrap()
                ));
            }
        } else {
            lines.push(format!(
                "DTSTART;VALUE=DATE:{}",
                day.format("%Y%m%d").unwrap()
            ));
            lines.push(format!(
                "DTEND;VALUE=DATE:{}",
                day.add_days(1)
                    .map_err(|e| e.to_string())?
                    .format("%Y%m%d")
                    .unwrap()
            ));
        }
        if !self.location.trim().is_empty() {
            lines.push(format!("LOCATION:{}", escape(self.location.trim())));
        }
        lines.extend(["STATUS:CONFIRMED".into(), "END:VEVENT".into()]);
        Ok(lines.iter().map(|line| fold(line)).collect())
    }
}

#[derive(Clone, Debug, Deserialize, Serialize)]
pub struct Calendar {
    pub id: String,
    pub name: String,
    #[serde(default)]
    pub default: bool,
}

#[derive(Deserialize)]
pub struct Event {
    pub payload: String,
    pub collection: String,
}

pub fn desktop(request: serde_json::Value) -> Result<String, String> {
    boosters::run_input(
        Command::new("python3").args(["-c", include_str!("../native/calendar.py")]),
        12,
        Some(request.to_string().as_bytes()),
    )
}

pub fn desktop_events(query: &str) -> Result<Vec<Event>, String> {
    serde_json::from_str(&desktop(
        serde_json::json!({"operation": "search", "query": query}),
    )?)
    .map_err(|_| "Invalid desktop calendar response".into())
}

fn save_local(ical: &str, root: &Path) -> Result<(), String> {
    use std::os::unix::fs::{DirBuilderExt, OpenOptionsExt};
    fs::DirBuilder::new()
        .recursive(true)
        .mode(0o700)
        .create(root)
        .map_err(|e| e.to_string())?;
    let path = root.join(format!("{}.ics", glib::uuid_string_random()));
    let body = format!(
        "BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:-//Spotlight//Calendar//EN\r\nCALSCALE:GREGORIAN\r\n{ical}END:VCALENDAR\r\n"
    );
    let mut file = fs::OpenOptions::new()
        .write(true)
        .create_new(true)
        .mode(0o600)
        .open(&path)
        .map_err(|e| e.to_string())?;
    file.write_all(body.as_bytes())
        .and_then(|_| file.sync_all())
        .map_err(|e| {
            let _ = fs::remove_file(&path);
            format!("Could not save the event: {e}")
        })
}

pub fn save(draft: &Draft, calendar: &Calendar) -> Result<String, String> {
    let ical = draft.ical()?;
    if calendar.id == "spotlight-local" {
        save_local(&ical, &core::data_dir().join("calendars"))?;
    } else {
        desktop(serde_json::json!({"operation": "create", "calendar": calendar.id, "ical": ical}))
            .map_err(|error| if error.contains("timed out") {
                "Could not confirm whether the event was saved. Check the selected calendar before trying again.".to_string()
            } else { error })?;
    }
    Ok(format!(
        "Added {} · {} · {}",
        draft.title.trim(),
        draft.label(),
        calendar.name
    ))
}

pub fn editor(
    parent: &gtk::ApplicationWindow,
    draft: Draft,
    saved: impl Fn(String, String) + 'static,
) -> gtk::Window {
    let dialog = gtk::Window::builder()
        .title("Add Calendar Event")
        .transient_for(parent)
        .modal(true)
        .default_width(520)
        .build();
    let panel = gtk::Box::new(gtk::Orientation::Vertical, 12);
    panel.add_css_class("editor");
    let heading = gtk::Label::new(Some("Add Calendar Event"));
    heading.add_css_class("guide-title");
    heading.set_xalign(0.);
    panel.append(&heading);
    let entry = |name: &str, placeholder: &str, value: &str| {
        let e = gtk::Entry::builder()
            .placeholder_text(placeholder)
            .text(value)
            .build();
        e.set_widget_name(name);
        e.update_property(&[gtk::accessible::Property::Label(placeholder)]);
        e
    };
    let title = entry("event-title", "Event title", &draft.title);
    panel.append(&title);
    let date_entry = entry(
        "event-date",
        "Date · YYYY-MM-DD",
        &format!("{:04}-{:02}-{:02}", draft.year, draft.month, draft.day),
    );
    date_entry.set_tooltip_text(Some("July 13 2027, 13 July 2027, or 2027-07-13"));
    panel.append(&date_entry);
    let all_day = gtk::CheckButton::with_label("All day");
    all_day.set_active(draft.time.is_none());
    all_day.set_widget_name("event-all-day");
    panel.append(&all_day);
    let times = gtk::Box::new(gtk::Orientation::Horizontal, 10);
    let (h, m) = draft.time.unwrap_or((9, 0));
    let time = entry(
        "event-time",
        "Start time · local",
        &format!("{h:02}:{m:02}"),
    );
    time.set_hexpand(true);
    times.append(&time);
    let minutes = gtk::SpinButton::with_range(1., 1440., 15.);
    minutes.set_value(draft.minutes as f64);
    minutes.set_widget_name("event-duration");
    minutes.set_tooltip_text(Some("Duration in minutes"));
    times.append(&minutes);
    times.append(&gtk::Label::new(Some("minutes")));
    times.set_sensitive(!all_day.is_active());
    panel.append(&times);
    let timing = times.downgrade();
    all_day.connect_toggled(move |b| {
        if let Some(t) = timing.upgrade() {
            t.set_sensitive(!b.is_active());
        }
    });
    let location = entry("event-location", "Location (optional)", &draft.location);
    panel.append(&location);
    let destination = gtk::Label::new(Some("Save to calendar"));
    destination.set_xalign(0.);
    panel.append(&destination);
    let calendars = gtk::DropDown::from_strings(&["Loading calendars…"]);
    calendars.set_widget_name("event-calendar");
    calendars.set_sensitive(false);
    panel.append(&calendars);
    let status = gtk::Label::new(Some("Review the event, then choose Add Event."));
    status.set_widget_name("event-status");
    status.set_wrap(true);
    status.set_xalign(0.);
    status.add_css_class("subtitle");
    panel.append(&status);
    for field in [&title, &date_entry, &time, &location] {
        let notice = status.clone();
        field.connect_changed(move |_| notice.set_text("Review the event, then choose Add Event."));
    }
    let notice = status.clone();
    calendars.connect_selected_notify(move |selector| {
        let local = selector
            .selected_item()
            .and_downcast::<gtk::StringObject>()
            .is_some_and(|name| name.string() == "Spotlight (local only)");
        notice.set_text(if local {
            "Local calendar · saved on this computer only."
        } else {
            "Review the event, then choose Add Event."
        });
    });
    let actions = gtk::Box::new(gtk::Orientation::Horizontal, 8);
    actions.set_halign(gtk::Align::End);
    let cancel = gtk::Button::with_label("Cancel");
    let save = gtk::Button::with_label("Add Event");
    save.set_widget_name("event-save");
    save.add_css_class("accent");
    save.set_sensitive(false);
    actions.append(&cancel);
    actions.append(&save);
    panel.append(&actions);
    dialog.set_child(Some(&panel));
    let choices = Rc::new(RefCell::new(Vec::<Calendar>::new()));
    let saving = Rc::new(Cell::new(false));
    let busy = Rc::clone(&saving);
    dialog.connect_close_request(move |_| {
        if busy.get() {
            glib::Propagation::Stop
        } else {
            glib::Propagation::Proceed
        }
    });
    let (tx, rx) = mpsc::channel();
    let test = std::env::args().any(|a| a == "--smoke-test");
    std::thread::spawn(move || {
        let result = if test {
            Ok(Vec::new())
        } else {
            desktop(serde_json::json!({"operation": "calendars"}))
                .and_then(|s| serde_json::from_str::<Vec<Calendar>>(&s).map_err(|e| e.to_string()))
        };
        let _ = tx.send(result);
    });
    let weak = dialog.downgrade();
    let options = Rc::clone(&choices);
    let selector = calendars.clone();
    let button = save.clone();
    let notice = status.clone();
    glib::timeout_add_local(Duration::from_millis(60), move || {
        if weak.upgrade().is_none() {
            return glib::ControlFlow::Break;
        }
        let result = match rx.try_recv() {
            Ok(r) => r,
            Err(mpsc::TryRecvError::Empty) => return glib::ControlFlow::Continue,
            Err(_) => Err("Could not load desktop calendars".into()),
        };
        let mut loaded = result.unwrap_or_default();
        let selected = loaded.iter().position(|c| c.default).unwrap_or(0);
        if loaded.is_empty() {
            notice.set_text("Spotlight local calendar · events stay on this computer. Desktop calendars are unavailable.");
        }
        loaded.push(Calendar {
            id: "spotlight-local".into(),
            name: "Spotlight (local only)".into(),
            default: false,
        });
        selector.set_model(Some(&gtk::StringList::new(
            &loaded.iter().map(|c| c.name.as_str()).collect::<Vec<_>>(),
        )));
        selector.set_selected(selected as u32);
        selector.set_sensitive(true);
        button.set_sensitive(true);
        *options.borrow_mut() = loaded;
        glib::ControlFlow::Break
    });
    let weak = dialog.downgrade();
    cancel.connect_clicked(move |_| {
        if let Some(d) = weak.upgrade() {
            d.close();
        }
    });
    let weak = dialog.downgrade();
    let saved = Rc::new(saved);
    let busy = Rc::clone(&saving);
    let weak_panel = panel.downgrade();
    save.connect_clicked(move |_| {
        if busy.get() {
            return;
        }
        let read = || -> Result<(Draft, Calendar), String> {
            let (year, month, day) = parse_date(&date_entry.text())?;
            minutes.update();
            let draft = Draft {
                title: title.text().to_string(),
                year,
                month,
                day,
                time: if all_day.is_active() {
                    None
                } else {
                    Some(parse_time(&time.text())?)
                },
                minutes: minutes.value_as_int() as u32,
                location: location.text().to_string(),
            };
            draft.ical()?;
            let calendar = choices
                .borrow()
                .get(calendars.selected() as usize)
                .cloned()
                .ok_or("Choose a calendar")?;
            Ok((draft, calendar))
        };
        let (draft, calendar) = match read() {
            Ok(r) => r,
            Err(e) => {
                status.set_text(&e);
                return;
            }
        };
        let (Some(dialog), Some(panel)) = (weak.upgrade(), weak_panel.upgrade()) else {
            return;
        };
        panel.set_sensitive(false);
        busy.set(true);
        status.set_text("Adding event…");
        let (tx, rx) = mpsc::channel();
        std::thread::spawn(move || {
            let result = self::save(&draft, &calendar).map(|message| (message, draft.title));
            let _ = tx.send(result);
        });
        let weak = dialog.downgrade();
        let status = status.clone();
        let panel = panel.clone();
        let saved = Rc::clone(&saved);
        let busy = Rc::clone(&busy);
        glib::timeout_add_local(Duration::from_millis(60), move || {
            let Some(dialog) = weak.upgrade() else {
                return glib::ControlFlow::Break;
            };
            match rx.try_recv() {
                Ok(Ok((message, title))) => {
                    busy.set(false);
                    dialog.close();
                    saved(message, title);
                    glib::ControlFlow::Break
                }
                Ok(Err(error)) => {
                    busy.set(false);
                    panel.set_sensitive(true);
                    status.set_text(&error);
                    glib::ControlFlow::Break
                }
                Err(mpsc::TryRecvError::Empty) => glib::ControlFlow::Continue,
                Err(_) => {
                    busy.set(false);
                    panel.set_sensitive(true);
                    status.set_text(
                        "Calendar worker stopped; check your calendar before trying again",
                    );
                    glib::ControlFlow::Break
                }
            }
        });
    });
    let keys = gtk::EventControllerKey::new();
    let weak = dialog.downgrade();
    let submit = save.downgrade();
    keys.connect_key_pressed(move |_, key, _, mods| {
        if key == gtk::gdk::Key::Escape {
            if let Some(dialog) = weak.upgrade() {
                dialog.close();
            }
            return glib::Propagation::Stop;
        }
        if key == gtk::gdk::Key::Return && mods.contains(gtk::gdk::ModifierType::CONTROL_MASK) {
            if let Some(button) = submit.upgrade().filter(|b| b.is_sensitive()) {
                button.emit_clicked();
            }
            return glib::Propagation::Stop;
        }
        glib::Propagation::Proceed
    });
    dialog.add_controller(keys);
    dialog
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn natural_event_dates_and_times() {
        let draft = parse("event on july 13 2027").unwrap().unwrap();
        assert_eq!(
            (draft.year, draft.month, draft.day, draft.time),
            (2027, 7, 13, None)
        );
        assert!(draft.title.is_empty());
        for query in [
            "add event Birthday café 🎉 on July 13, 2027 at 6pm",
            "EVENT Birthday café 🎉 ON 13 July 2027 AT 18:00",
            "calendar event Birthday café 🎉 on 2027-07-13 at 6:00 pm",
        ] {
            let draft = parse(query).unwrap().unwrap();
            assert_eq!(draft.title, "Birthday café 🎉");
            assert_eq!(
                (draft.year, draft.month, draft.day, draft.time),
                (2027, 7, 13, Some((18, 0)))
            );
        }
        assert!(parse("event").unwrap().unwrap().title.is_empty());
        assert!(parse("calendar Rust").is_none());
        assert!(parse("eventual").is_none());
        for query in [
            "event on February 29 2027",
            "event on July 32 2027",
            "event on 2027-13-01",
            "event on July 13 2027 at 25:00",
            "event on July 13 2027 at 0pm",
            "event Birthday",
            "event on July 13foo 2027",
        ] {
            assert!(parse(query).unwrap().is_err(), "{query}");
        }
        assert!(parse("event on February 29th 2028").unwrap().is_ok());
        assert_eq!(parse_time("12 am").unwrap(), (0, 0));
        assert_eq!(parse_time("12:30pm").unwrap(), (12, 30));
    }

    #[test]
    fn calendar_encoding_and_exclusive_end_dates() {
        let mut draft = parse("event Birthday on December 31 2027")
            .unwrap()
            .unwrap();
        draft.title = format!("Café, friends; party \\ {}", "🎉".repeat(40));
        draft.location = "Room, one; two\nAnother floor".into();
        let ical = draft.ical().unwrap();
        assert!(ical.contains("DTSTART;VALUE=DATE:20271231\r\n"));
        assert!(ical.contains("DTEND;VALUE=DATE:20280101\r\n"));
        assert!(ical.contains("SUMMARY:Café\\, friends\\; party \\\\"));
        assert!(ical.contains("LOCATION:Room\\, one\\; two\\nAnother floor\r\n"));
        assert!(ical.split("\r\n").all(|line| line.len() <= 75));
        let root =
            std::env::temp_dir().join(format!("spotlight-calendar-{}", glib::uuid_string_random()));
        save_local(&ical, &root).unwrap();
        save_local(&ical, &root).unwrap();
        assert_eq!(
            fs::read_dir(&root).unwrap().count(),
            2,
            "Saving does not overwrite another event"
        );
        let path = fs::read_dir(&root).unwrap().next().unwrap().unwrap().path();
        let stored = fs::read_to_string(&path).unwrap();
        assert!(stored.starts_with("BEGIN:VCALENDAR\r\nVERSION:2.0\r\n"));
        use std::os::unix::fs::PermissionsExt;
        assert_eq!(
            fs::metadata(path).unwrap().permissions().mode() & 0o777,
            0o600
        );
        fs::remove_dir_all(root).unwrap();
        draft.title = "Injected\r\nBEGIN:VEVENT".into();
        assert!(draft.ical().is_err());
    }

    #[test]
    fn timed_events_preserve_local_time_and_duration() {
        let mut draft = parse("event Meeting on July 13 2027 at 3:30pm")
            .unwrap()
            .unwrap();
        draft.minutes = 90;
        let ical = draft.ical().unwrap();
        let start = glib::DateTime::new(&glib::TimeZone::local(), 2027, 7, 13, 15, 30, 0.)
            .unwrap()
            .to_utc()
            .unwrap();
        let end = start.add_minutes(90).unwrap();
        assert!(ical.contains(&format!(
            "DTSTART:{}\r\n",
            start.format("%Y%m%dT%H%M%SZ").unwrap()
        )));
        assert!(ical.contains(&format!(
            "DTEND:{}\r\n",
            end.format("%Y%m%dT%H%M%SZ").unwrap()
        )));
        draft.minutes = 0;
        assert!(draft.ical().is_err());
        draft.title.clear();
        assert!(draft.ical().is_err());
    }
}

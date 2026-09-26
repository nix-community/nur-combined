//! Local wall-clock time, with no dependencies and no `unsafe`.
//!
//! `--update` and `--watch` each print one line per file they write, and
//! dart-sass stamps it with the local time:
//!
//! ```text
//! [2026-09-19 12:58:07] Compiled src/one.scss to out/one.css.
//! ```
//!
//! `std` gives UTC seconds and nothing else — no calendar, no timezone — so
//! that stamp has to come from somewhere. The options, measured on
//! 2026-09-19:
//!
//! | route | dependencies | `unsafe` |
//! |---|---|---|
//! | `jiff` | 2 crates | none of ours |
//! | `chrono` | 5 crates | none of ours |
//! | `time` | 8 crates | none of ours |
//! | declaring `localtime_r` ourselves | none | yes |
//! | reading the tz database ourselves | none | none |
//!
//! This is the last row. It is not an exotic choice: it is what `jiff` does
//! internally (it reads `/usr/share/zoneinfo` rather than calling libc), and
//! what the `tz-rs` crate exists to provide. Calling `localtime_r` directly
//! is the route the ecosystem has been moving away from since
//! RUSTSEC-2020-0159, and it would also be the second exception to this
//! crate's one-audited-`unsafe`-module rule, with no way to check it under
//! Miri.
//!
//! # Shape
//!
//! Four modules, split so that only one of them can fail in a way that
//! depends on the machine it runs on:
//!
//! - [`civil`] — calendar arithmetic. Pure.
//! - [`posix`] — the POSIX TZ string. Pure.
//! - [`tzif`] — the TZif binary format. Pure, borrows its input, allocates
//!   nothing, never panics on malformed bytes.
//! - [`sys`] — reads `/etc/localtime` or `$TZ`. The only I/O, and the only
//!   platform `cfg`.
//!
//! Nothing here refers to anything else in sasso, by design: if this grows
//! past being a timestamp for one log line it should leave and become its
//! own crate, and that should be a move rather than a rewrite.
//!
//! # Windows
//!
//! There is no TZif file to read, so [`local_stamp`] returns `None` and the
//! caller prints the line without its bracket. Correct-but-absent beats
//! present-but-wrong, and the alternatives — FFI to `GetLocalTime`, or
//! embedding the whole tz database as `jiff` does at ~427 KB — are both too
//! much for one line. Worth revisiting when there is Windows CI to test it
//! on (#85).
//!
//! # How this is known to be right
//!
//! The reader agrees with Python's `zoneinfo` on **every zone the system
//! ships, at twelve instants each** — 598 zones, 7176 checks, on macOS and
//! on Linux/glibc (2026-09-19). The instants are chosen to be awkward: DST
//! transition seconds, half-hour and 45-minute zones, the southern
//! hemisphere, 1906, 1944, 2065 in both summer and winter, and 2100.
//!
//! That sweep found a bug in the reference rather than in the reader: for
//! the three Greenland zones, whose footer uses angle-bracket abbreviations
//! (`<-02>2<-01>,M3.5.0/-1,M10.5.0/0`), macOS's own `date` stops applying
//! the footer past 2037 and reports standard time all year. `zoneinfo`
//! agrees with us.
//!
//! That sweep is `#[ignore]`d — it needs the host's zoneinfo and a Python to
//! disagree with, neither of which the everyday suite should depend on — and
//! CI opts in with `cargo test --bin sasso -- --ignored`. What runs on every
//! `cargo test` are the vendored-fixture tests, which need no oracle, no
//! tzdata on the host, and give the same answer in five years when these
//! zones' rules have moved on.

// `civil` is wanted everywhere a stamp is printed — it turns "UTC seconds
// plus an offset" into a date, and that arithmetic is the same whoever
// supplied the offset. The other three read the tz database, which only a
// POSIX machine has, and on any other target they would be dead code that
// `-D warnings` is right to reject.
pub(crate) mod civil;
#[cfg(unix)]
pub(crate) mod posix;
#[cfg(unix)]
pub(crate) mod sys;
#[cfg(unix)]
pub(crate) mod tzif;

#[cfg(unix)]
use std::sync::OnceLock;

/// What the machine says about its zone, resolved at most once per process.
///
/// A directory build asks for a timestamp once per written file — thousands
/// of times for a large tree — and re-reading `/etc/localtime` each time
/// would be silly. Parsing, by contrast, is left per call: it is a header
/// read and a binary search over a borrowed slice, with no allocation, so
/// caching the parse would buy nothing and would need a self-referential
/// struct to hold it.
///
/// The consequence worth stating: a change to the machine's timezone, or to
/// `TZ`, is not picked up by a running `--watch`. Neither is it by dart.
#[cfg(unix)]
fn loaded() -> &'static sys::Loaded {
    static CACHE: OnceLock<sys::Loaded> = OnceLock::new();
    CACHE.get_or_init(sys::load)
}

/// The UTC offset in seconds east of Greenwich at `unix_secs`, or `None`
/// when no zone can be determined at all.
///
/// `Some(0)` and `None` are different answers and the distinction is the
/// point: `TZ=` asks for UTC and gets it, while a machine that has a local
/// zone we cannot read (Windows) gets nothing, so the caller prints no
/// time rather than a confident wrong one.
#[cfg(unix)]
pub(crate) fn local_offset_at(unix_secs: i64) -> Option<i64> {
    match loaded() {
        sys::Loaded::Utc => Some(0),
        sys::Loaded::Tzif(bytes) => tzif::TimeZone::parse(bytes)?.offset_at(unix_secs),
        sys::Loaded::Nothing => None,
    }
}

/// The same question on Windows, asked of the platform instead of a file.
///
/// A safe-API crate rather than our own FFI, and chrono rather than the three
/// smaller-looking alternatives: the
/// `[target.'cfg(windows)'.dependencies]` comment in `Cargo.toml` has the
/// measured table and why each of the others is disqualified. `clock`
/// resolves to the Windows API here, so nothing is embedded in the binary.
///
/// `None` if the instant falls outside chrono's range, which a stamp of
/// `now()` never does — but it is the caller's existing "print no time rather
/// than a wrong one" path, so it costs nothing to stay honest about it.
#[cfg(all(windows, feature = "cli-clock"))]
pub(crate) fn local_offset_at(unix_secs: i64) -> Option<i64> {
    use chrono::{DateTime, Local, Offset};
    let utc = DateTime::from_timestamp(unix_secs, 0)?;
    Some(i64::from(
        utc.with_timezone(&Local).offset().fix().local_minus_utc(),
    ))
}

/// Everything else: the two wasm targets, and a Windows build that opted out
/// of `cli-clock`.
///
/// No clock to ask and no file to read, so the caller prints the line without
/// its bracket — the behaviour the whole module had on Windows before #189.
/// A wasm build has no business reading a host clock anyway.
#[cfg(not(any(unix, all(windows, feature = "cli-clock"))))]
pub(crate) fn local_offset_at(_unix_secs: i64) -> Option<i64> {
    None
}

/// dart-sass's stamp for `unix_secs`: `[YYYY-MM-DD HH:MM:SS]`, local time to
/// the second. `None` when the local offset cannot be determined, which the
/// caller renders as no stamp at all rather than as a wrong one.
///
/// # Why seconds, when `sass` from npm prints none
///
/// dart-sass builds the stamp by stripping a fixed SEVEN characters off
/// `DateTime.now().toString()` (`sass.dart.js` around the `"Compiled "`
/// line):
///
/// ```js
///   nowStr = DateTime.now().toString();
///   timestamp = nowStr.substring(0, nowStr.length - 7);
/// ```
///
/// Seven is `.` plus six microsecond digits, which is what the Dart VM
/// prints. dart2js prints three fractional digits, so on the npm build the
/// slice eats `:SS` as well:
///
/// ```text
///   VM       2026-09-22 23:36:00.123456   len 26   -> 2026-09-22 23:36:00
///   dart2js  2026-09-22 23:36:00.123      len 23   -> 2026-09-22 23:36
/// ```
///
/// So the two distributions of ONE dart version disagree, and the shorter
/// one is a truncation bug rather than a format: the code intends to drop a
/// fractional part and keep the seconds. Measured on macOS, same machine,
/// same second (#190):
///
/// ```text
///   dart native (macos-arm64 release)   [2026-09-22 23:36:00]
///   dart npm    (dart2js)               [2026-09-22 23:36]
/// ```
///
/// sasso matched the npm build, because every dart measurement in this repo
/// is taken against it. It matches dart's INTENT now, which is also what a
/// Windows user sees, and what `brew install sass` gives you.
pub(crate) fn local_stamp(unix_secs: i64) -> Option<String> {
    Some(format_stamp(&civil::civil_from_unix(
        unix_secs + local_offset_at(unix_secs)?,
    )))
}

/// The bracket itself, split out so the fixture test below asserts against
/// THIS rather than against a second `format!` written to match it. The two
/// had to agree by inspection before; now there is only one.
fn format_stamp(c: &civil::Civil) -> String {
    format!(
        "[{:04}-{:02}-{:02} {:02}:{:02}:{:02}]",
        c.year, c.month, c.day, c.hour, c.minute, c.second
    )
}

/// Seconds since the Unix epoch, or 0 if the system clock predates it.
pub(crate) fn now() -> i64 {
    std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|d| d.as_secs() as i64)
        .unwrap_or(0)
}

#[cfg(all(test, unix))]
mod tests {
    use super::*;

    /// End to end against vendored bytes, so the expected strings can be
    /// written down rather than computed by the code under test.
    #[test]
    fn the_stamp_reads_as_dart_writes_it() {
        const LORD_HOWE: &[u8] = include_bytes!("../../tests/fixtures/tz/Australia_Lord_Howe");
        let tz = tzif::TimeZone::parse(LORD_HOWE).expect("parse");

        // 2026-07-15 12:00 UTC. Lord Howe is +10:30 in its winter (July),
        // so 22:30 the same day.
        let secs = 1_784_116_800;
        let off = tz.offset_at(secs).expect("offset");
        assert_eq!(off, 10 * 3600 + 1800);
        let c = civil::civil_from_unix(secs + off);
        assert_eq!(
            format_stamp(&c),
            "[2026-07-15 22:30:00]",
            "a half-hour zone must not be rounded to the hour"
        );
    }

    #[test]
    fn a_machine_with_no_tzdata_drops_the_stamp_rather_than_lying() {
        // Exercised through the real path: whatever this machine has, the
        // function must either give a well-formed stamp or nothing.
        match local_stamp(now()) {
            None => {}
            Some(s) => {
                assert_eq!(s.len(), 21, "[YYYY-MM-DD HH:MM:SS] is 21 chars: {s:?}");
                assert!(s.starts_with('[') && s.ends_with(']'), "{s:?}");
                let inner = &s[1..s.len() - 1];
                let (date, time) = inner.split_once(' ').expect("one space");
                assert_eq!(date.split('-').count(), 3, "{s:?}");
                assert_eq!(time.split(':').count(), 3, "second resolution: {s:?}");
                assert!(inner
                    .chars()
                    .all(|c| c.is_ascii_digit() || c == '-' || c == ':' || c == ' '));
            }
        }
    }

    /// The whole tz database, against an independent implementation.
    ///
    /// `#[ignore]`d because it needs two things the everyday suite must not:
    /// the host's `/usr/share/zoneinfo`, and a Python with `zoneinfo` to
    /// disagree with us. CI runs it explicitly
    /// (`cargo test --bin sasso -- --ignored`); the vendored-fixture tests
    /// above are what run on every `cargo test`.
    ///
    /// Python's `zoneinfo` is the oracle rather than the system `date`,
    /// which is not always right: for the three Greenland zones, whose
    /// footer uses angle-bracket abbreviations, macOS's `date` stops
    /// applying the footer past 2037 and reports standard time all year.
    /// The first version of this sweep reported six failures that were all
    /// the reference being wrong.
    #[test]
    #[ignore = "needs the host tz database and a Python with zoneinfo"]
    fn agrees_with_zoneinfo_on_every_zone() {
        use std::process::Command;

        // Awkward on purpose: DST transition seconds, half-hour and
        // 45-minute zones, both hemispheres, deep history, and well past
        // the transition table where the POSIX footer takes over.
        const INSTANTS: [i64; 12] = [
            0,
            1_772_949_600, // a US spring-forward instant
            1_780_000_000,
            1_788_000_000,
            1_796_000_000,
            -800_000_000,   // 1944
            -2_000_000_000, // 1906
            2_500_000_000,  // 2049
            3_000_000_000,  // 2065, winter
            3_013_651_200,  // 2065, summer
            3_045_187_200,  // 2066, summer
            4_102_444_800,  // 2100
        ];

        let script = r#"
import sys, datetime, zoneinfo
times = [int(x) for x in sys.argv[1:]]
for z in sorted(zoneinfo.available_timezones()):
    try:
        tz = zoneinfo.ZoneInfo(z)
    except Exception:
        continue
    row = [z]
    for t in times:
        try:
            row.append(str(int(datetime.datetime.fromtimestamp(t, tz).utcoffset().total_seconds())))
        except Exception:
            row.append("skip")
    print("\t".join(row))
"#;
        let out = Command::new("python3")
            .arg("-c")
            .arg(script)
            .args(INSTANTS.map(|t| t.to_string()))
            .output();
        let Ok(out) = out else {
            panic!("python3 is required for this test; it is #[ignore]d so CI opts in");
        };
        let table = String::from_utf8_lossy(&out.stdout);
        assert!(
            table.lines().count() > 100,
            "expected a real zone list, got {} lines; stderr: {}",
            table.lines().count(),
            String::from_utf8_lossy(&out.stderr)
        );

        // `bad` is capped so a systematic break prints twenty lines rather
        // than seven thousand; `wrong` is the honest count that goes in the
        // message, because "20 of 7176" when it is really 7176 would send
        // the next reader looking for a subtle bug instead of a total one.
        let (mut checked, mut zones, mut wrong, mut bad) = (0usize, 0usize, 0usize, Vec::new());
        for line in table.lines() {
            let mut cols = line.split('\t');
            let Some(zone) = cols.next() else { continue };
            let Some(bytes) = std::fs::read(format!("/usr/share/zoneinfo/{zone}")).ok() else {
                continue;
            };
            let Some(tz) = tzif::TimeZone::parse(&bytes) else {
                wrong += 1;
                bad.push(format!("{zone}: did not parse"));
                continue;
            };
            zones += 1;
            for (t, want) in INSTANTS.iter().zip(cols) {
                if want == "skip" {
                    continue;
                }
                let want: i64 = want.parse().expect("an integer offset");
                let got = tz.offset_at(*t);
                checked += 1;
                if got != Some(want) {
                    wrong += 1;
                    if bad.len() < 20 {
                        bad.push(format!("{zone} @ {t}: zoneinfo={want} ours={got:?}"));
                    }
                }
            }
        }
        assert!(
            wrong == 0,
            "{wrong} of {checked} checks across {zones} zones disagreed (first {}):\n  {}",
            bad.len(),
            bad.join("\n  ")
        );
        assert!(
            checked > 5_000,
            "only {checked} checks ran — the sweep is not covering the database"
        );
        eprintln!("localtime sweep: {checked} checks across {zones} zones, all matching zoneinfo");
    }

    #[test]
    fn now_is_plausible() {
        // Not a clock test — only that the epoch conversion has not lost a
        // factor of 1000, which is the classic way this goes wrong.
        let t = now();
        assert!(t > 1_700_000_000, "before 2023: {t}");
        assert!(t < 4_102_444_800, "after 2100: {t}");
    }
}

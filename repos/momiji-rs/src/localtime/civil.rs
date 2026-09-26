//! Calendar arithmetic: Unix seconds to a civil date and back.
//!
//! No I/O, no timezone knowledge, no allocation — give it a count of seconds
//! and it gives you the fields. Everything timezone-aware is a matter of
//! adding an offset before calling in here.
//!
//! The two conversions are Howard Hinnant's `civil_from_days` and
//! `days_from_civil`, the same pair every date library uses underneath. They
//! are exact for the whole `i64` range and have no leap-year special cases
//! beyond the formulas themselves, which is why they are worth copying
//! rather than reinventing with `if` statements.

// Half of this module exists for the POSIX TZ-string reader, which only a
// machine with a tz database needs (`posix` is `#[cfg(unix)]`). Off POSIX
// the stamp's offset comes from the platform instead, so `civil_from_unix`
// is the only entry point a lib or bin build reaches and the other four read
// as dead.
//
// Allowed rather than `#[cfg(unix)]`-gated, because they are NOT dead in a
// test build on any platform: the calendar tests below are pure, need no tz
// database, and are exactly the kind that should run everywhere — gating the
// functions would take the tests with them.
#![cfg_attr(not(unix), allow(dead_code))]

/// A civil date and time, with no zone attached.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub(crate) struct Civil {
    pub(crate) year: i64,
    pub(crate) month: u32,
    pub(crate) day: u32,
    pub(crate) hour: u32,
    pub(crate) minute: u32,
    pub(crate) second: u32,
}

/// Days since 1970-01-01 to `(year, month, day)`.
pub(crate) fn civil_from_days(z: i64) -> (i64, u32, u32) {
    // Shift the epoch to 0000-03-01 so leap days land at the end of the
    // 400-year cycle and the month formula below stays branch-free.
    let z = z + 719_468;
    let era = if z >= 0 { z } else { z - 146_096 } / 146_097;
    let doe = (z - era * 146_097) as u64; // day of era, [0, 146096]
    let yoe = (doe - doe / 1460 + doe / 36_524 - doe / 146_096) / 365; // [0, 399]
    let y = yoe as i64 + era * 400;
    let doy = doe - (365 * yoe + yoe / 4 - yoe / 100); // day of year, [0, 365]
    let mp = (5 * doy + 2) / 153; // month, March-based, [0, 11]
    let d = (doy - (153 * mp + 2) / 5 + 1) as u32; // [1, 31]
    let m = if mp < 10 { mp + 3 } else { mp - 9 } as u32; // [1, 12]
    (if m <= 2 { y + 1 } else { y }, m, d)
}

/// `(year, month, day)` to days since 1970-01-01. The exact inverse of
/// [`civil_from_days`].
pub(crate) fn days_from_civil(y: i64, m: u32, d: u32) -> i64 {
    let y = if m <= 2 { y - 1 } else { y };
    let era = if y >= 0 { y } else { y - 399 } / 400;
    let yoe = (y - era * 400) as u64;
    let mp = if m > 2 { m - 3 } else { m + 9 } as u64;
    let doy = (153 * mp + 2) / 5 + d as u64 - 1;
    let doe = yoe * 365 + yoe / 4 - yoe / 100 + doy;
    era * 146_097 + doe as i64 - 719_468
}

/// Day of the week, 0 = Sunday. 1970-01-01 was a Thursday, hence the `+ 4`.
pub(crate) fn weekday(days: i64) -> u32 {
    (days + 4).rem_euclid(7) as u32
}

pub(crate) fn is_leap(y: i64) -> bool {
    (y % 4 == 0 && y % 100 != 0) || y % 400 == 0
}

/// Days in `month` of `year`, 1-based month.
pub(crate) fn days_in_month(year: i64, month: u32) -> i64 {
    const LENGTHS: [i64; 12] = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if month == 2 && is_leap(year) {
        29
    } else {
        LENGTHS[(month - 1) as usize]
    }
}

/// Split a count of seconds since the epoch into civil fields. The caller
/// has already added whatever UTC offset applies, so this is "local" only in
/// the sense that it does not add one itself.
pub(crate) fn civil_from_unix(secs: i64) -> Civil {
    let days = secs.div_euclid(86_400);
    let rem = secs.rem_euclid(86_400);
    let (year, month, day) = civil_from_days(days);
    Civil {
        year,
        month,
        day,
        hour: (rem / 3600) as u32,
        minute: ((rem % 3600) / 60) as u32,
        second: (rem % 60) as u32,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn the_two_conversions_are_inverses() {
        // Every day across four centuries, which covers all four leap-year
        // rules including the 400-year exception that 2000 and 2400 hit and
        // 1900 and 2100 do not.
        let start = days_from_civil(1800, 1, 1);
        let end = days_from_civil(2200, 1, 1);
        for d in start..end {
            let (y, m, day) = civil_from_days(d);
            assert_eq!(
                days_from_civil(y, m, day),
                d,
                "round trip at day {d} -> {y}-{m}-{day}"
            );
        }
    }

    #[test]
    fn known_dates() {
        assert_eq!(civil_from_days(0), (1970, 1, 1));
        assert_eq!(civil_from_days(-1), (1969, 12, 31));
        assert_eq!(days_from_civil(1970, 1, 1), 0);
        // A leap day that exists, and the century that skips one.
        assert_eq!(civil_from_days(days_from_civil(2000, 2, 29)), (2000, 2, 29));
        assert_eq!(days_in_month(2000, 2), 29);
        assert_eq!(days_in_month(1900, 2), 28);
        assert_eq!(days_in_month(2100, 2), 28);
        assert_eq!(days_in_month(2024, 2), 29);
    }

    #[test]
    fn weekdays() {
        assert_eq!(weekday(0), 4, "1970-01-01 was a Thursday");
        assert_eq!(weekday(days_from_civil(2026, 9, 19)), 6, "a Saturday");
        // Before the epoch the arithmetic must still wrap the right way.
        assert_eq!(weekday(days_from_civil(1969, 12, 28)), 0, "a Sunday");
    }

    #[test]
    fn negative_seconds_floor_rather_than_truncate() {
        // The hour before the epoch is 1969-12-31 23:00, not 1970-01-01
        // -1:00. Integer division truncates toward zero and would give the
        // latter, which is why div_euclid/rem_euclid are used.
        let c = civil_from_unix(-3600);
        assert_eq!((c.year, c.month, c.day, c.hour), (1969, 12, 31, 23));
    }

    #[test]
    fn fields_split_correctly() {
        let c = civil_from_unix(days_from_civil(2026, 9, 19) * 86_400 + 13 * 3600 + 5 * 60 + 7);
        assert_eq!(
            c,
            Civil {
                year: 2026,
                month: 9,
                day: 19,
                hour: 13,
                minute: 5,
                second: 7
            }
        );
    }
}

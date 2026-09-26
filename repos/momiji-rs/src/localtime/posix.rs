//! The POSIX TZ string, which is where a TZif file's answers come from once
//! its transition table runs out (RFC 8536 §3.3).
//!
//! Tables stop around 2037 by convention, so without this a timestamp in
//! 2038 is an hour out for half the year — measured, not assumed: the first
//! version of this reader was exactly one hour wrong for
//! `America/New_York` on 2065-07-01.
//!
//! The grammar, from the footers actually shipped in tzdata:
//!
//! ```text
//! EST5EDT,M3.2.0,M11.1.0                      ordinary northern DST
//! GMT0IST,M3.5.0/1,M10.5.0                    a transition at 01:00
//! <+1030>-10:30<+11>-11,M10.1.0,M4.1.0        southern: DST spans New Year
//! <+1245>-12:45<+1345>,M9.5.0/2:45,M4.1.0/3:45   45-minute offsets
//! <-02>2<-01>,M3.5.0/-1,M10.5.0/0             a NEGATIVE transition time
//! <+0545>-5:45                                fixed offset, no DST at all
//! ```
//!
//! Two traps worth stating because they are silent when wrong:
//!
//! 1. POSIX writes offsets **west-positive** — `EST5` means UTC-5. Every
//!    other number in this module is east-positive, so the sign is flipped
//!    the moment it is parsed and never again.
//! 2. The two rule times are in **different clocks**: the start is local
//!    standard time, the end is local daylight time. Using one offset for
//!    both misplaces each transition by an hour, which only shows up within
//!    an hour of a transition and so survives casual testing.

use super::civil::{days_from_civil, days_in_month, is_leap, weekday};

/// When a transition happens, within a year.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub(crate) enum Rule {
    /// `Mm.w.d` — the `w`-th `d`-weekday of month `m`, where `w == 5` means
    /// the last one, whether that is the fourth or the fifth.
    Month { month: u32, week: u32, weekday: u32 },
    /// `Jn` — day `n` of the year, 1..=365, never counting 29 February.
    Julian(u32),
    /// `n` — day `n`, 0..=365, counting 29 February.
    Zero(u32),
}

/// A parsed POSIX TZ string. Offsets are east-positive seconds.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub(crate) struct Posix {
    pub(crate) std_offset: i64,
    /// `None` for a zone with no daylight saving, which is most of them.
    pub(crate) dst: Option<Dst>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub(crate) struct Dst {
    pub(crate) offset: i64,
    pub(crate) start: Rule,
    /// Seconds after local midnight, in STANDARD time. May be negative.
    pub(crate) start_time: i64,
    pub(crate) end: Rule,
    /// Seconds after local midnight, in DAYLIGHT time. May be negative.
    pub(crate) end_time: i64,
}

struct Cursor<'a> {
    s: &'a [u8],
    i: usize,
}

impl Cursor<'_> {
    fn peek(&self) -> Option<u8> {
        self.s.get(self.i).copied()
    }

    fn eat(&mut self, c: u8) -> bool {
        if self.peek() == Some(c) {
            self.i += 1;
            true
        } else {
            false
        }
    }

    fn number(&mut self) -> Option<i64> {
        let start = self.i;
        while matches!(self.peek(), Some(b'0'..=b'9')) {
            self.i += 1;
        }
        if self.i == start || self.i - start > 6 {
            return None; // empty, or long enough to be junk
        }
        let mut n: i64 = 0;
        for &b in &self.s[start..self.i] {
            n = n * 10 + i64::from(b - b'0');
        }
        Some(n)
    }

    /// A zone abbreviation, which carries no information we use — only its
    /// length matters, so it is skipped rather than kept. Either `<...>` or
    /// a run of letters.
    fn skip_name(&mut self) -> Option<()> {
        if self.eat(b'<') {
            while let Some(c) = self.peek() {
                self.i += 1;
                if c == b'>' {
                    return Some(());
                }
            }
            return None; // unterminated
        }
        let start = self.i;
        while matches!(self.peek(), Some(c) if c.is_ascii_alphabetic()) {
            self.i += 1;
        }
        (self.i > start).then_some(())
    }

    /// `[+|-]hh[:mm[:ss]]`, returned east-positive (POSIX writes it the
    /// other way round, so an unsigned value comes back negated).
    fn offset(&mut self) -> Option<i64> {
        let west = self.signed()?;
        Some(-west)
    }

    /// The same syntax as an offset but used for a time of day, where the
    /// sign means what it says and is not flipped.
    fn time(&mut self) -> Option<i64> {
        self.signed()
    }

    fn signed(&mut self) -> Option<i64> {
        let neg = if self.eat(b'-') {
            true
        } else {
            self.eat(b'+');
            false
        };
        let mut secs = self.number()?.checked_mul(3600)?;
        if self.eat(b':') {
            secs = secs.checked_add(self.number()? * 60)?;
            if self.eat(b':') {
                secs = secs.checked_add(self.number()?)?;
            }
        }
        Some(if neg { -secs } else { secs })
    }

    fn rule(&mut self) -> Option<(Rule, i64)> {
        let rule = if self.eat(b'M') {
            let month = self.number()? as u32;
            if !self.eat(b'.') {
                return None;
            }
            let week = self.number()? as u32;
            if !self.eat(b'.') {
                return None;
            }
            let weekday = self.number()? as u32;
            if !(1..=12).contains(&month) || !(1..=5).contains(&week) || weekday > 6 {
                return None;
            }
            Rule::Month { month, week, weekday }
        } else if self.eat(b'J') {
            let n = self.number()? as u32;
            if !(1..=365).contains(&n) {
                return None;
            }
            Rule::Julian(n)
        } else {
            let n = self.number()? as u32;
            if n > 365 {
                return None;
            }
            Rule::Zero(n)
        };
        // Default 02:00:00 when the `/time` part is absent.
        let time = if self.eat(b'/') { self.time()? } else { 2 * 3600 };
        Some((rule, time))
    }
}

/// Parse a POSIX TZ string. Returns `None` on anything it does not fully
/// understand — a partly-understood rule would be worse than no rule,
/// because the caller can fall back to the last tabulated offset.
pub(crate) fn parse(s: &str) -> Option<Posix> {
    let mut c = Cursor {
        s: s.as_bytes(),
        i: 0,
    };
    c.skip_name()?;
    let std_offset = c.offset()?;
    if c.i == c.s.len() {
        return Some(Posix {
            std_offset,
            dst: None,
        });
    }
    c.skip_name()?;
    // An omitted DST offset means one hour east of standard.
    let offset = if c.peek() == Some(b',') {
        std_offset + 3600
    } else {
        c.offset()?
    };
    if !c.eat(b',') {
        return None;
    }
    let (start, start_time) = c.rule()?;
    if !c.eat(b',') {
        return None;
    }
    let (end, end_time) = c.rule()?;
    if c.i != c.s.len() {
        return None; // trailing junk: do not guess
    }
    Some(Posix {
        std_offset,
        dst: Some(Dst {
            offset,
            start,
            start_time,
            end,
            end_time,
        }),
    })
}

/// Days from 1 January of `year` to the day a rule names.
fn day_of_year(rule: Rule, year: i64) -> i64 {
    match rule {
        // Julian days never count 29 February, so from 1 March onwards in a
        // leap year the ordinal and the actual day part company by one.
        Rule::Julian(n) => {
            let n = i64::from(n);
            if is_leap(year) && n >= 60 {
                n
            } else {
                n - 1
            }
        }
        Rule::Zero(n) => i64::from(n),
        Rule::Month {
            month,
            week,
            weekday: want,
        } => {
            let first = days_from_civil(year, month, 1);
            let shift = (i64::from(want) - i64::from(weekday(first))).rem_euclid(7);
            let mut day = 1 + shift + (i64::from(week) - 1) * 7;
            // `week == 5` means "the last such weekday", which for a month
            // with only four of them overshoots; step back until it fits.
            let last = days_in_month(year, month);
            while day > last {
                day -= 7;
            }
            days_from_civil(year, month, day as u32) - days_from_civil(year, 1, 1)
        }
    }
}

/// The UTC offset this rule set gives at `secs`.
pub(crate) fn offset_at(p: &Posix, secs: i64) -> i64 {
    let Some(dst) = p.dst else {
        return p.std_offset;
    };
    // Which local year is it? Standard time picks the right one except
    // within an hour of New Year, where either answer gives the same
    // in/out-of-DST verdict anyway.
    let (year, _, _) = super::civil::civil_from_days((secs + p.std_offset).div_euclid(86_400));
    let jan1 = days_from_civil(year, 1, 1);

    // The two times are in different clocks — see the module docs.
    let start = (jan1 + day_of_year(dst.start, year)) * 86_400 + dst.start_time - p.std_offset;
    let end = (jan1 + day_of_year(dst.end, year)) * 86_400 + dst.end_time - dst.offset;

    let in_dst = if start <= end {
        secs >= start && secs < end // northern hemisphere
    } else {
        secs >= start || secs < end // southern: the DST window spans New Year
    };
    if in_dst {
        dst.offset
    } else {
        p.std_offset
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn p(s: &str) -> Posix {
        parse(s).unwrap_or_else(|| panic!("failed to parse {s:?}"))
    }

    /// Every shape that appears in the vendored fixtures, so a parser change
    /// that breaks one of them fails here rather than in a date far away.
    #[test]
    fn the_footers_tzdata_actually_ships() {
        // Ordinary northern DST.
        let ny = p("EST5EDT,M3.2.0,M11.1.0");
        assert_eq!(ny.std_offset, -5 * 3600, "POSIX writes offsets west-positive");
        let dst = ny.dst.expect("New York has DST");
        assert_eq!(dst.offset, -4 * 3600, "an omitted DST offset is std + 1h");
        assert_eq!(
            dst.start,
            Rule::Month {
                month: 3,
                week: 2,
                weekday: 0
            }
        );
        assert_eq!(dst.start_time, 2 * 3600, "the default transition time");

        // An explicit transition time.
        assert_eq!(p("GMT0IST,M3.5.0/1,M10.5.0").dst.unwrap().start_time, 3600);

        // Half-hour offsets, southern hemisphere (start month AFTER end).
        let lh = p("<+1030>-10:30<+11>-11,M10.1.0,M4.1.0");
        assert_eq!(lh.std_offset, 10 * 3600 + 1800);
        assert_eq!(lh.dst.unwrap().offset, 11 * 3600);

        // 45-minute offsets with 45-minute transition times.
        let ch = p("<+1245>-12:45<+1345>,M9.5.0/2:45,M4.1.0/3:45");
        assert_eq!(ch.std_offset, 12 * 3600 + 45 * 60);
        assert_eq!(ch.dst.unwrap().offset, 13 * 3600 + 45 * 60);
        assert_eq!(ch.dst.unwrap().start_time, 2 * 3600 + 45 * 60);

        // A negative transition time: 01:00 the PREVIOUS day.
        let nuuk = p("<-02>2<-01>,M3.5.0/-1,M10.5.0/0");
        assert_eq!(nuuk.std_offset, -2 * 3600);
        assert_eq!(nuuk.dst.unwrap().offset, -3600);
        assert_eq!(nuuk.dst.unwrap().start_time, -3600);
        assert_eq!(nuuk.dst.unwrap().end_time, 0);

        // Fixed offsets, no DST clause at all.
        assert_eq!(
            p("<+0545>-5:45"),
            Posix {
                std_offset: 5 * 3600 + 45 * 60,
                dst: None
            }
        );
        assert_eq!(
            p("CST-8"),
            Posix {
                std_offset: 8 * 3600,
                dst: None
            }
        );
        assert_eq!(
            p("UTC0"),
            Posix {
                std_offset: 0,
                dst: None
            }
        );
    }

    #[test]
    fn junk_is_refused_rather_than_half_understood() {
        // A half-parsed rule is worse than none: the caller can fall back to
        // the last tabulated offset, which is right far more often than a
        // guess would be.
        for bad in [
            "",                         // empty
            "EST",                      // no offset
            "<unterminated5",           // no closing bracket
            "EST5EDT",                  // DST named with no rules
            "EST5EDT,M3.2.0",           // only one rule
            "EST5EDT,M3.2.0,M11.1.0,X", // trailing junk
            "EST5EDT,M13.2.0,M11.1.0",  // month 13
            "EST5EDT,M3.9.0,M11.1.0",   // week 9
            "EST5EDT,M3.2.9,M11.1.0",   // weekday 9
            "EST5EDT,J0,M11.1.0",       // Julian is 1-based
            "EST5EDT,J400,M11.1.0",     // beyond the year
            "EST5EDT,999,M11.1.0",      // day beyond the year
        ] {
            assert!(parse(bad).is_none(), "should have refused {bad:?}");
        }
    }

    #[test]
    fn week_five_means_the_last_one() {
        // October 2026 has five Sundays, November has five as well but the
        // fifth falls on the 29th; a month with only four must step back.
        // 2026-10: Sundays are 4, 11, 18, 25 — only four.
        let last_sunday_oct = day_of_year(
            Rule::Month {
                month: 10,
                week: 5,
                weekday: 0,
            },
            2026,
        );
        let jan1 = days_from_civil(2026, 1, 1);
        let (_, m, d) = super::super::civil::civil_from_days(jan1 + last_sunday_oct);
        assert_eq!((m, d), (10, 25), "the last Sunday of October 2026");

        // And a month where the fifth genuinely exists.
        let fifth_friday_jan = day_of_year(
            Rule::Month {
                month: 1,
                week: 5,
                weekday: 5,
            },
            2027,
        );
        let jan1 = days_from_civil(2027, 1, 1);
        let (_, m, d) = super::super::civil::civil_from_days(jan1 + fifth_friday_jan);
        assert_eq!((m, d), (1, 29), "the last Friday of January 2027");
    }

    #[test]
    fn julian_days_skip_the_leap_day() {
        // J60 is 1 March in every year, leap or not — that is the whole
        // point of the J form.
        for year in [2023, 2024] {
            let jan1 = days_from_civil(year, 1, 1);
            let d = day_of_year(Rule::Julian(60), year);
            let (_, m, day) = super::super::civil::civil_from_days(jan1 + d);
            assert_eq!((m, day), (3, 1), "J60 in {year}");
        }
        // The n form does not skip it, so day 60 moves.
        let jan1 = days_from_civil(2024, 1, 1);
        let (_, m, day) = super::super::civil::civil_from_days(jan1 + day_of_year(Rule::Zero(60), 2024));
        assert_eq!((m, day), (3, 1), "day 60 of a leap year is 1 March (0-based)");
    }

    #[test]
    fn the_southern_window_spans_new_year() {
        // Lord Howe: DST from October to April, so January IS daylight time
        // and July is not. A northern-only comparison gets both backwards.
        let lh = p("<+1030>-10:30<+11>-11,M10.1.0,M4.1.0");
        let jan = days_from_civil(2027, 1, 15) * 86_400;
        let jul = days_from_civil(2027, 7, 15) * 86_400;
        assert_eq!(offset_at(&lh, jan), 11 * 3600, "January is DST in the south");
        assert_eq!(offset_at(&lh, jul), 10 * 3600 + 1800, "July is standard");
    }

    #[test]
    fn a_transition_is_placed_to_the_second() {
        // New York 2027: DST starts 2027-03-14 at 02:00 EST, which is
        // 07:00 UTC. One second either side must land on either side.
        let ny = p("EST5EDT,M3.2.0,M11.1.0");
        let at = days_from_civil(2027, 3, 14) * 86_400 + 7 * 3600;
        assert_eq!(offset_at(&ny, at - 1), -5 * 3600, "still standard");
        assert_eq!(offset_at(&ny, at), -4 * 3600, "daylight from this second");
    }
}

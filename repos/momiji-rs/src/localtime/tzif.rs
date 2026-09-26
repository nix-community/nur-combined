//! The TZif binary format (RFC 8536) — the files under `/usr/share/zoneinfo`
//! that every Unix keeps its timezone rules in.
//!
//! The layout, once through for the reader who has not met it:
//!
//! ```text
//! "TZif" version[1] reserved[15]
//! six 32-bit counts: isutcnt isstdcnt leapcnt timecnt typecnt charcnt
//! a 32-bit data block                 <- kept only for pre-2005 readers
//! "TZif" ... the same header again    <- version >= 2 only
//! a 64-bit data block                 <- the one to read
//! "\n" a POSIX TZ string "\n"         <- what to do past the last transition
//! ```
//!
//! This reader BORROWS the bytes and allocates nothing: the transition list
//! is binary-searched in place rather than collected. A directory build can
//! ask for a timestamp thousands of times, and none of them should allocate.
//!
//! It also never panics and never indexes without checking. The input is a
//! file on disk that no part of this program wrote, and a malformed or
//! truncated one must produce `None`, not a crash in a build tool.

use super::posix;

/// A parsed TZif file: offsets into the caller's bytes, nothing owned.
pub(crate) struct TimeZone<'a> {
    bytes: &'a [u8],
    /// Where the 64-bit transition times begin.
    transitions: usize,
    count: usize,
    /// Where the per-transition type indices begin.
    indices: usize,
    /// Where the local-time-type records begin (6 bytes each).
    types: usize,
    type_count: usize,
    /// The POSIX TZ footer, when the file has a usable one.
    footer: Option<posix::Posix>,
}

struct Counts {
    isutcnt: usize,
    isstdcnt: usize,
    leapcnt: usize,
    timecnt: usize,
    typecnt: usize,
    charcnt: usize,
    version: u8,
}

fn be_u32(b: &[u8], at: usize) -> Option<u32> {
    let s = b.get(at..at + 4)?;
    Some(u32::from_be_bytes([s[0], s[1], s[2], s[3]]))
}

fn be_i64(b: &[u8], at: usize) -> Option<i64> {
    let s = b.get(at..at + 8)?;
    Some(i64::from_be_bytes([
        s[0], s[1], s[2], s[3], s[4], s[5], s[6], s[7],
    ]))
}

fn be_i32(b: &[u8], at: usize) -> Option<i32> {
    Some(be_u32(b, at)? as i32)
}

/// Read a 44-byte header at `at`.
fn header(b: &[u8], at: usize) -> Option<Counts> {
    if b.get(at..at + 4)? != b"TZif" {
        return None;
    }
    let version = *b.get(at + 4)?;
    // Counts are `u32` on disk but index into a slice, so they are widened
    // to `usize` once here; every later use is then checked arithmetic.
    Some(Counts {
        isutcnt: be_u32(b, at + 20)? as usize,
        isstdcnt: be_u32(b, at + 24)? as usize,
        leapcnt: be_u32(b, at + 28)? as usize,
        timecnt: be_u32(b, at + 32)? as usize,
        typecnt: be_u32(b, at + 36)? as usize,
        charcnt: be_u32(b, at + 40)? as usize,
        version,
    })
}

/// The size of a data block, in bytes. `stride` is 4 for the 32-bit block
/// and 8 for the 64-bit one. Returns `None` on overflow, which is how an
/// absurd count in a corrupt file is rejected rather than wrapping.
fn block_len(c: &Counts, stride: usize) -> Option<usize> {
    let leap_entry = stride + 4;
    c.timecnt
        .checked_mul(stride + 1)?
        .checked_add(c.typecnt.checked_mul(6)?)?
        .checked_add(c.charcnt)?
        .checked_add(c.leapcnt.checked_mul(leap_entry)?)?
        .checked_add(c.isstdcnt)?
        .checked_add(c.isutcnt)
}

impl<'a> TimeZone<'a> {
    /// Parse `bytes`. `None` if they are not a version 2+ TZif file.
    ///
    /// Version 1 files are refused rather than given a second code path:
    /// they have no 64-bit block and no footer, they stopped being produced
    /// in 2005, and supporting them would mean maintaining a parser that
    /// nothing exercises.
    pub(crate) fn parse(bytes: &'a [u8]) -> Option<TimeZone<'a>> {
        let v1 = header(bytes, 0)?;
        if v1.version < b'2' {
            return None;
        }
        // Skip the whole 32-bit block; the 64-bit one supersedes it.
        let second = 44usize.checked_add(block_len(&v1, 4)?)?;
        let c = header(bytes, second)?;

        let transitions = second.checked_add(44)?;
        let indices = transitions.checked_add(c.timecnt.checked_mul(8)?)?;
        let types = indices.checked_add(c.timecnt)?;
        let chars = types.checked_add(c.typecnt.checked_mul(6)?)?;
        // Everything above must be inside the file before any of it is read.
        let end = chars
            .checked_add(c.charcnt)?
            .checked_add(c.leapcnt.checked_mul(12)?)?
            .checked_add(c.isstdcnt)?
            .checked_add(c.isutcnt)?;
        if end > bytes.len() || c.typecnt == 0 {
            return None;
        }

        // The footer is the rest, wrapped in newlines. A file without one,
        // or with one this parser does not fully understand, simply has no
        // footer — the last tabulated offset is then the answer, which is
        // right for every zone that has stopped changing its rules.
        let footer = bytes
            .get(end..)
            .and_then(|rest| core::str::from_utf8(rest).ok())
            .map(|s| s.trim_matches('\n'))
            .filter(|s| !s.is_empty())
            .and_then(posix::parse);

        Some(TimeZone {
            bytes,
            transitions,
            count: c.timecnt,
            indices,
            types,
            type_count: c.typecnt,
            footer,
        })
    }

    fn transition(&self, i: usize) -> i64 {
        be_i64(self.bytes, self.transitions + i * 8).unwrap_or(i64::MIN)
    }

    fn offset_of_type(&self, t: usize) -> Option<i64> {
        if t >= self.type_count {
            return None;
        }
        be_i32(self.bytes, self.types + t * 6).map(i64::from)
    }

    /// The first local time type that is not daylight saving, which RFC 8536
    /// names as the answer for instants before the first transition.
    fn first_standard(&self) -> Option<i64> {
        for t in 0..self.type_count {
            if self.bytes.get(self.types + t * 6 + 4) == Some(&0) {
                return self.offset_of_type(t);
            }
        }
        self.offset_of_type(0)
    }

    /// The UTC offset, in seconds east, at `secs`.
    pub(crate) fn offset_at(&self, secs: i64) -> Option<i64> {
        // partition_point over the transitions, without materialising them.
        let (mut lo, mut hi) = (0usize, self.count);
        while lo < hi {
            let mid = lo + (hi - lo) / 2;
            if self.transition(mid) <= secs {
                lo = mid + 1;
            } else {
                hi = mid;
            }
        }

        // Past the last transition the footer is the authority. This is the
        // branch that makes a 2065 timestamp right instead of an hour out,
        // and it is reached for EVERY instant in a zone that has no
        // transitions left — which includes every zone without DST.
        if lo == self.count {
            if let Some(p) = &self.footer {
                return Some(posix::offset_at(p, secs));
            }
        }
        if lo == 0 {
            return self.first_standard();
        }
        let t = *self.bytes.get(self.indices + lo - 1)? as usize;
        self.offset_of_type(t)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    /// Vendored rather than read from the host: the test must give the same
    /// answer on a machine with different tzdata, on Windows CI where there
    /// is no zoneinfo at all, and in five years when these zones' rules have
    /// moved on.
    const NEW_YORK: &[u8] = include_bytes!("../../tests/fixtures/tz/America_New_York");
    const KATHMANDU: &[u8] = include_bytes!("../../tests/fixtures/tz/Asia_Kathmandu");
    const UTC: &[u8] = include_bytes!("../../tests/fixtures/tz/UTC");

    #[test]
    fn a_zone_with_dst() {
        let tz = TimeZone::parse(NEW_YORK).expect("parse");
        // 2026-01-15 12:00 UTC — winter, EST.
        assert_eq!(tz.offset_at(1_768_478_400), Some(-5 * 3600));
        // 2026-07-15 12:00 UTC — summer, EDT.
        assert_eq!(tz.offset_at(1_784_116_800), Some(-4 * 3600));
    }

    #[test]
    fn past_the_table_the_footer_answers() {
        let tz = TimeZone::parse(NEW_YORK).expect("parse");
        // 2065-07-01, long past the tabulated transitions. Without the
        // footer this was EST and an hour wrong.
        assert_eq!(tz.offset_at(3_013_651_200), Some(-4 * 3600));
        assert_eq!(tz.offset_at(3_000_000_000), Some(-5 * 3600), "2065 winter");
    }

    #[test]
    fn a_zone_with_no_dst_and_a_45_minute_offset() {
        let tz = TimeZone::parse(KATHMANDU).expect("parse");
        assert_eq!(tz.offset_at(1_768_478_400), Some(5 * 3600 + 45 * 60));
        // Fixed offsets must stay fixed however far out you look.
        assert_eq!(tz.offset_at(4_102_444_800), Some(5 * 3600 + 45 * 60), "2100");
    }

    #[test]
    fn utc_is_zero_everywhere() {
        let tz = TimeZone::parse(UTC).expect("parse");
        for t in [i64::from(i32::MIN), -1, 0, 1, 1_768_478_400, 4_102_444_800] {
            assert_eq!(tz.offset_at(t), Some(0), "at {t}");
        }
    }

    #[test]
    fn before_the_first_transition() {
        let tz = TimeZone::parse(NEW_YORK).expect("parse");
        // 1850, before any tabulated transition: RFC 8536 says the first
        // non-DST type, which for New York is Local Mean Time.
        let off = tz.offset_at(-3_786_825_600).expect("an offset");
        assert!(
            (-5 * 3600 - 300..=-5 * 3600 + 300).contains(&off),
            "LMT-ish, got {off}"
        );
    }

    /// Malformed input must come back as `None`. A build tool that panics
    /// while deciding what time it is has failed worse than one that prints
    /// no timestamp.
    #[test]
    fn corrupt_input_never_panics() {
        assert!(TimeZone::parse(b"").is_none(), "empty");
        assert!(TimeZone::parse(b"not a tzif file at all").is_none(), "bad magic");

        // Every truncation of a real file.
        for n in 0..NEW_YORK.len() {
            let _ = TimeZone::parse(&NEW_YORK[..n]).map(|tz| tz.offset_at(0));
        }

        // A version 1 file: refused, not misread.
        let mut v1 = NEW_YORK.to_vec();
        v1[4] = b'1';
        assert!(TimeZone::parse(&v1).is_none(), "version 1 is refused");

        // Absurd counts, which is how a corrupt file overflows a reader that
        // multiplies before it checks.
        let mut huge = NEW_YORK.to_vec();
        huge[32..36].copy_from_slice(&u32::MAX.to_be_bytes()); // timecnt
        assert!(TimeZone::parse(&huge).is_none(), "timecnt = u32::MAX");
        let mut huge = NEW_YORK.to_vec();
        huge[36..40].copy_from_slice(&u32::MAX.to_be_bytes()); // typecnt
        assert!(TimeZone::parse(&huge).is_none(), "typecnt = u32::MAX");

        // Single-byte corruption anywhere in the header region.
        for i in 0..64.min(NEW_YORK.len()) {
            let mut b = NEW_YORK.to_vec();
            b[i] ^= 0xFF;
            let _ = TimeZone::parse(&b).map(|tz| tz.offset_at(1_768_478_400));
        }
    }

    /// A cheap deterministic fuzz: mutate a real file at pseudo-random and
    /// require only that nothing panics. No dependency — xorshift is four
    /// lines, and `rand` would be a dependency this crate does not take.
    #[test]
    fn random_mutations_never_panic() {
        let mut state = 0x2545_F491_4F6C_DD1Du64;
        let mut next = move || {
            state ^= state << 13;
            state ^= state >> 7;
            state ^= state << 17;
            state
        };
        for _ in 0..2_000 {
            let mut b = NEW_YORK.to_vec();
            let flips = (next() % 8) as usize + 1;
            for _ in 0..flips {
                let at = (next() as usize) % b.len();
                b[at] = (next() & 0xFF) as u8;
            }
            if let Some(tz) = TimeZone::parse(&b) {
                let _ = tz.offset_at((next() as i64) >> 8);
            }
        }
    }
}

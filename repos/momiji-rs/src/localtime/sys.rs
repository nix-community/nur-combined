//! The only file here that touches the outside world, and the only one with
//! a platform `cfg`. Everything else is bytes in, numbers out.
//!
//! Keeping the I/O in one small file is what makes the rest testable from
//! vendored fixtures, and what makes adding a platform a one-file change.

#[cfg(unix)]
use std::path::PathBuf;

/// Where the local offset comes from.
#[cfg(unix)]
#[derive(Debug, Clone, PartialEq, Eq)]
pub(crate) enum Source {
    /// A fixed zero offset, with no file to read.
    Utc,
    /// A TZif file to parse.
    File(PathBuf),
}

/// Resolve a `TZ` value to a source, exactly as the platform does.
///
/// Measured on 2026-09-19 against both `date` and dart-sass 1.104.1, which
/// agree because both go through libc:
///
/// ```text
/// unset          local time     -> /etc/localtime
/// TZ=            UTC            -> an EMPTY TZ is a request for UTC,
/// TZ=:           UTC               not a request for the default
/// TZ=UTC         UTC
/// TZ=Asia/Taipei that zone
/// TZ=nonsense    UTC            -> an unresolvable zone falls back to UTC,
///                                  not back to local time
/// ```
///
/// The empty case is the one worth stating twice, because the obvious
/// reading is wrong and the first version of this file got it wrong: `TZ=`
/// is not "TZ is unset". A process launched with `TZ=` is asking for UTC,
/// and we reported the host's local zone — with a test that codified it.
///
/// Split from the read so it can be tested without mutating the process
/// environment, which this crate's `unsafe_code = "deny"` would refuse
/// anyway (`set_var` is `unsafe` in the 2024 edition). Taking the value as
/// a parameter is the better shape regardless: the interesting logic is
/// the mapping, not the getenv.
///
/// `TZ` can also hold a POSIX rule directly (`EST5EDT,M3.2.0,M11.1.0`).
/// That form has no file behind it, so it resolves as unresolvable, i.e.
/// to UTC — which is what an unreadable zone gets from libc too. Reading
/// the rule properly is [`super::posix`]'s job already and would be a
/// small change; it is not this PR's.
#[cfg(unix)]
pub(crate) fn tz_source(tz: Option<&str>) -> Source {
    let Some(tz) = tz else {
        return Source::File(PathBuf::from("/etc/localtime"));
    };
    let name = tz.strip_prefix(':').unwrap_or(tz);
    if name.is_empty() {
        return Source::Utc;
    }
    if name.starts_with('/') {
        return Source::File(PathBuf::from(name));
    }
    // Refuse anything that could climb out of the zoneinfo directory. `TZ`
    // is an environment variable, and a build tool should not read an
    // arbitrary file because one was set. An unusable name is UTC, the
    // same answer libc gives for a zone it cannot find.
    if name.split('/').any(|c| c.is_empty() || c == "." || c == "..") {
        return Source::Utc;
    }
    Source::File(PathBuf::from("/usr/share/zoneinfo").join(name))
}

/// What the machine has to offer.
///
/// `#[cfg(unix)]` along with the only function that builds one: on a
/// platform with no tz database there is nothing to distinguish, and a
/// three-variant enum where two are unreachable is dead code the build
/// rightly refuses (`-D warnings` caught exactly that on the first
/// Windows run after this type appeared).
#[cfg(unix)]
#[derive(Debug)]
pub(crate) enum Loaded {
    /// A fixed zero offset.
    Utc,
    /// TZif bytes to parse.
    Tzif(Vec<u8>),
    /// Nothing: no zone can be determined, so the caller reports no time
    /// rather than a wrong one.
    Nothing,
}

#[cfg(unix)]
pub(crate) fn load() -> Loaded {
    match tz_source(std::env::var("TZ").ok().as_deref()) {
        Source::Utc => Loaded::Utc,
        Source::File(path) => match std::fs::read(&path) {
            Ok(bytes) => Loaded::Tzif(bytes),
            // A NAMED zone that will not open is UTC, as it is for libc.
            // An unset `TZ` whose `/etc/localtime` is missing is a
            // different case — a scratch container or a nix build sandbox,
            // where nothing has told us anything — and there this reports
            // no time at all rather than asserting UTC it has not been
            // told. Absent beats confidently wrong.
            Err(_) if std::env::var_os("TZ").is_some() => Loaded::Utc,
            Err(_) => Loaded::Nothing,
        },
    }
}

// Windows keeps its zone in the registry, not in a TZif file, so there is
// nothing for this reader to read, and no `load` to write. Reaching it
// needs either FFI — which this module has none of, deliberately — or an
// embedded copy of the whole tz database, which is how `jiff` does it at a
// measured cost of ~427 KB.
//
// The caller's `local_offset_at` is `None` there rather than UTC: unlike a
// bare container, a Windows machine HAS a local zone and we simply cannot
// see it, so claiming UTC would be confidently wrong rather than merely
// absent. See the module docs for the plan to revisit this once there is
// Windows CI to test it on (#85).

#[cfg(all(test, unix))]
mod tests {
    use super::*;

    fn file(p: &str) -> Source {
        Source::File(PathBuf::from(p))
    }

    #[test]
    fn unset_means_the_system_link() {
        assert_eq!(tz_source(None), file("/etc/localtime"));
    }

    /// `TZ=` is a request for UTC, not an absent `TZ`. Measured: `TZ= date`
    /// and `TZ= sass --update` both report UTC where an unset `TZ` reports
    /// local time.
    #[test]
    fn an_explicitly_empty_tz_is_utc() {
        assert_eq!(tz_source(Some("")), Source::Utc);
        assert_eq!(
            tz_source(Some(":")),
            Source::Utc,
            "a bare colon is the same request"
        );
    }

    #[test]
    fn a_name_resolves_under_zoneinfo() {
        assert_eq!(
            tz_source(Some("Asia/Taipei")),
            file("/usr/share/zoneinfo/Asia/Taipei")
        );
        // POSIX allows a leading colon and some tools emit one.
        assert_eq!(
            tz_source(Some(":Asia/Taipei")),
            file("/usr/share/zoneinfo/Asia/Taipei")
        );
        // Three components happen (America/Argentina/Salta).
        assert_eq!(
            tz_source(Some("America/Argentina/Salta")),
            file("/usr/share/zoneinfo/America/Argentina/Salta")
        );
    }

    #[test]
    fn an_absolute_path_is_taken_as_given() {
        assert_eq!(tz_source(Some("/etc/localtime")), file("/etc/localtime"));
    }

    /// Reading an arbitrary file because an environment variable said so is
    /// a bad trade for a timestamp. These resolve to UTC — the same answer
    /// libc gives for a zone it cannot find — rather than to a read.
    #[test]
    fn a_name_cannot_escape_the_zoneinfo_directory() {
        for bad in [
            "../../../etc/passwd",
            "America/../../etc/passwd",
            ".",
            "..",
            "Asia/./Taipei",
            "Asia//Taipei",
        ] {
            assert_eq!(tz_source(Some(bad)), Source::Utc, "TZ={bad:?} must not be read");
        }
    }

    /// Not an assertion about the host's timezone — CI machines are UTC and
    /// developers are not — only that the lookup reaches something usable.
    /// The values themselves are checked against vendored fixtures, where
    /// the expected answer is known.
    #[test]
    fn the_system_zone_is_usable() {
        match load() {
            Loaded::Utc | Loaded::Nothing => {}
            Loaded::Tzif(bytes) => assert!(
                super::super::tzif::TimeZone::parse(&bytes).is_some(),
                "the system's own tzdata did not parse ({} bytes)",
                bytes.len()
            ),
        }
    }
}

//! `--watch` without a file-watching dependency: what to poll, how often, and
//! when a change becomes a compile.
//!
//! # Why polling
//!
//! Every native watcher — inotify, kqueue, `ReadDirectoryChangesW` — is a
//! syscall this crate cannot make. `[dependencies]` is empty and that is a
//! selling point, and `unsafe_code = "deny"` outside the Miri-verified arena,
//! so the FFI declarations those APIs need are not available either. What is
//! left in `std` is `fs::metadata`, and asking it repeatedly is a watcher.
//!
//! It is not a worse one here than it sounds. Measured on this machine, one
//! sweep of `fs::metadata` costs about 1.3 microseconds per file:
//!
//! | files | per sweep | at a 50 ms interval |
//! |---|---|---|
//! | 10 | 0.014 ms | 0.0% of a core |
//! | 200 | 0.262 ms | 0.5% |
//! | 500 | 0.665 ms | 1.3% |
//! | 2000 | 3.191 ms | 6.4% |
//! | 5000 | 9.138 ms | 18.3% |
//!
//! A stylesheet tree is the small end of that: a `--watch` session follows the
//! files ONE entry actually loaded, not a whole repository. But 18% of a core
//! for a tree that big is a real cost to leave running all afternoon, so the
//! interval is not a constant — see [`next_interval`].
//!
//! # Why the pieces here are pure
//!
//! The same reason `_coalesce.mjs` is its own module on the npm side: how many
//! compiles a burst of saves costs cannot be asserted from a `--watch` test.
//! The obvious check — save eight times, count the compiles — measures the
//! spacing of the writes against the window rather than the rule, and there is
//! no bound that both catches a regression and survives a loaded CI machine
//! stretching those gaps. Driven by a clock the test supplies, N changes
//! inside one window is exactly two runs, on any machine, every time.

use std::collections::BTreeMap;
use std::path::{Path, PathBuf};
use std::time::{Duration, SystemTime};

/// The floor on the poll interval: fast enough that a save feels immediate,
/// and 50 ms is also the npm CLI's coalescing window, so the two front ends
/// answer a burst the same way.
pub(crate) const MIN_INTERVAL: Duration = Duration::from_millis(50);

/// The ceiling. A tree big enough to reach this is one where a person is
/// waiting on the compile anyway, and half a second of latency beats a
/// watcher that eats a core.
pub(crate) const MAX_INTERVAL: Duration = Duration::from_millis(500);

/// One part in this that the watcher may spend asking the filesystem
/// questions — 2%, which the measured 1.3 us per file turns into a 50 ms
/// interval for anything under about 800 files.
pub(crate) const SWEEP_BUDGET: u32 = 50;

/// How long to coalesce after a run, matching the npm CLI's `windowMs`.
pub(crate) const WINDOW: Duration = Duration::from_millis(50);

/// The next poll interval, from what the last sweep cost.
///
/// The watcher spends at most one part in `budget` of its time asking the
/// filesystem questions — 2% by default, which at the measured 1.3 us per
/// file is 50 ms for anything under about 800 files and stretches from there.
/// A constant interval cannot do that: 50 ms is free for ten files and 18% of
/// a core for five thousand.
pub(crate) fn next_interval(sweep: Duration, budget: u32) -> Duration {
    let want = sweep * budget;
    want.clamp(MIN_INTERVAL, MAX_INTERVAL)
}

/// What the watcher remembers about one file: enough to tell a save from a
/// touch, and cheap enough to take every tick.
///
/// The length sits beside the modification time because a filesystem with a
/// coarse timestamp — HFS+ and some network mounts keep whole seconds — can
/// leave the mtime unchanged across two saves a person makes in the same
/// second. Two fields disagree less often than one, but "less often" is not
/// "never": two same-length writes inside one tick of that clock are
/// indistinguishable, and the watch would leave stale CSS indefinitely.
///
/// So a third field, and it costs nothing where it is not needed. A
/// **whole-second mtime is itself the signal** that the clock is coarse, so
/// the digest is computed only for files whose timestamp has no sub-second
/// part. Measured on this machine (APFS), 40 same-length writes 1 ms apart:
/// 40 distinct mtimes, all with a sub-second part, 0 of 39 pairs
/// indistinguishable — so nothing is read. On a filesystem that keeps whole
/// seconds every file is read every sweep, and the poll interval already
/// scales with what a sweep costs (see [`next_interval`]), so that pays for
/// itself rather than pinning a core.
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub(crate) struct Stamp {
    modified: Option<SystemTime>,
    len: u64,
    /// FNV-1a of the contents, or `0` when the timestamp was precise enough
    /// not to need one.
    digest: u64,
    /// The permission bits, because becoming READABLE is a change a watch
    /// has to act on and none of the three fields above moves for it.
    ///
    /// A dependency that exists and cannot be read fails the compile; the
    /// fix is `chmod`, which touches neither mtime nor length nor contents.
    /// Measured before this: `chmod 000` a dependency, then `chmod 644`, and
    /// the watch NEVER SAW it — a permanent dead end rather than a delay.
    ///
    /// The mode where there is one; elsewhere the one bit `std` exposes.
    /// `readonly()` alone would miss `000 -> 444`, which is exactly the
    /// unreadable-to-readable transition this exists for.
    mode: u32,
}

impl Stamp {
    /// A file that cannot be stat'd — deleted, or never there. It compares
    /// equal to itself, so a dependency that is missing and stays missing is
    /// not a change on every tick.
    pub(crate) const MISSING: Stamp = Stamp {
        modified: None,
        len: u64::MAX,
        digest: 0,
        mode: 0,
    };

    pub(crate) fn of(path: &Path) -> Stamp {
        let Ok(m) = std::fs::metadata(path) else {
            return Stamp::MISSING;
        };
        let modified = m.modified().ok();
        // `map_or`, not `is_none_or`: that one is stable since 1.82 and this
        // crate's MSRV is 1.74.
        let coarse = modified.map_or(true, |t| {
            t.duration_since(SystemTime::UNIX_EPOCH)
                .map(|d| !subsecond_is_fine(d.subsec_nanos()))
                .unwrap_or(true)
        });
        Stamp {
            modified,
            len: m.len(),
            digest: if coarse { digest_of(path, m.is_dir()) } else { 0 },
            mode: mode_of(&m),
        }
    }
}

impl Stamp {
    /// A directory judged by what is in it EXCEPT the given names.
    ///
    /// No mtime and no length: ours moved both, so neither can answer the
    /// question. What is left is the entry set, which our own writes are
    /// taken out of and nobody else's are.
    fn of_dir_minus(dir: &Path, ours: &[std::ffi::OsString]) -> Stamp {
        let Ok(entries) = std::fs::read_dir(dir) else {
            return Stamp::MISSING;
        };
        let mut names: Vec<std::ffi::OsString> = entries
            .flatten()
            .map(|e| e.file_name())
            .filter(|n| !ours.contains(n))
            .collect();
        names.sort();
        let mut h: u64 = 0xcbf2_9ce4_8422_2325;
        for n in names {
            for b in n.to_string_lossy().as_bytes() {
                h ^= u64::from(*b);
                h = h.wrapping_mul(0x1000_0000_01b3);
            }
            h ^= 0;
            h = h.wrapping_mul(0x1000_0000_01b3);
        }
        Stamp {
            modified: None,
            len: 0,
            digest: h,
            mode: 0,
        }
    }
}

/// Which of two observations of one file came first.
///
/// A missing file counts as earliest: whatever the other unit saw, "it was
/// not there" is the observation that will differ once it is.
fn earlier(a: &Stamp, b: &Stamp) -> bool {
    match (a.modified, b.modified) {
        (None, _) => true,
        (_, None) => false,
        (Some(x), Some(y)) => x < y,
    }
}

/// The permission bits, as far as this platform will say.
#[cfg(unix)]
fn mode_of(m: &std::fs::Metadata) -> u32 {
    use std::os::unix::fs::MetadataExt;
    m.mode()
}

/// Windows has no mode; the read-only flag is what `std` offers, and it is
/// the only permission change that can stop a stylesheet being read there.
#[cfg(not(unix))]
fn mode_of(m: &std::fs::Metadata) -> u32 {
    u32::from(m.permissions().readonly())
}

/// Whether a timestamp's sub-second part is fine enough to tell two saves
/// apart.
///
/// A non-zero sub-second part is NOT that proof, which is what this used to
/// test: a filesystem with millisecond stamps reports one, and two
/// same-length writes inside the same millisecond still share it. What the
/// value itself says is how far the clock actually ticks — a 1 ms clock can
/// only ever produce multiples of 1,000,000 ns, a 100 ns clock multiples of
/// 100 — so the trailing zeros are the resolution, and no extra syscall is
/// needed to learn it.
///
/// The line is one microsecond. Two saves inside a millisecond is an editor
/// and a formatter racing, which happens; two inside a microsecond is not a
/// thing a person's tooling does. A precise clock landing on an exact
/// multiple by chance costs one file one digest on one sweep.
fn subsecond_is_fine(subsec_nanos: u32) -> bool {
    subsec_nanos != 0 && subsec_nanos % 1_000 != 0
}

/// FNV-1a over what makes this path different from itself a moment ago.
///
/// For a FILE that is its bytes. For a DIRECTORY it is the sorted names it
/// contains — `fs::read` cannot read a directory at all, so digesting one as
/// if it were a file returned 0 every time and left a coarse-clock directory
/// with three fields that never move. That is the half of the watch that
/// notices a dependency ARRIVING, so it has to be the half that works: a
/// directory's own mtime is the only other signal, and on a filesystem that
/// keeps whole seconds two entries created in one second are one mtime.
///
/// Names, not their metadata: a file's own contents are watched through its
/// own stamp, and what a directory is asked here is only "is the same set of
/// things in you".
fn digest_of(path: &Path, is_dir: bool) -> u64 {
    let mut h: u64 = 0xcbf2_9ce4_8422_2325;
    let mut eat = |bytes: &[u8]| {
        for b in bytes {
            h ^= u64::from(*b);
            h = h.wrapping_mul(0x1000_0000_01b3);
        }
    };
    if is_dir {
        let Ok(entries) = std::fs::read_dir(path) else {
            return 0;
        };
        // Sorted, because `read_dir` promises no order and an unstable one
        // would read as a change on every sweep.
        let mut names: Vec<std::ffi::OsString> = entries.flatten().map(|e| e.file_name()).collect();
        names.sort();
        for n in names {
            eat(n.to_string_lossy().as_bytes());
            eat(b"\0");
        }
    } else {
        let Ok(bytes) = std::fs::read(path) else {
            return 0;
        };
        eat(&bytes);
    }
    h
}

/// The set of files a watch is following, and what they looked like last time.
///
/// `BTreeMap` rather than a hash map: the sweep order is then stable, which
/// makes a failure reproducible and the cost above predictable.
#[derive(Default, Debug)]
pub(crate) struct Snapshot {
    files: BTreeMap<PathBuf, Stamp>,
    /// For a directory this watch WROTE into: the names it put there.
    ///
    /// Such a directory cannot be judged by its mtime, because ours moved
    /// it — but re-stamping it wholesale is worse, since a dependency that
    /// arrived during the same compile is then folded into the new
    /// baseline and never seen. So it is judged by its entry set with our
    /// own files taken out: our write cannot look like an arrival, and
    /// cannot hide one either.
    minus: BTreeMap<PathBuf, Vec<std::ffi::OsString>>,
}

impl Snapshot {
    /// Replace the watched set. Called after every compile, because the
    /// dependency set changes when an `@use` is added or removed.
    ///
    /// The two groups are treated differently, and the difference is the
    /// whole correctness of this:
    ///
    /// - a `file` already followed KEEPS the stamp it had, and one this
    ///   compile met for the first time takes the stamp the CALLER supplies
    ///   — which is what the file looked like when the compiler read it.
    ///   Stamping either of them here instead records whatever is on disk
    ///   NOW as the baseline for a build made from what was there earlier,
    ///   so a save that lands while a compile is running is absorbed and
    ///   never compiled. Measured before each half: 1 in 4 lost writing
    ///   into a 680 ms compile, and 3 in 5 lost writing into the FIRST
    ///   compile, where every file is new and there is no earlier stamp to
    ///   keep.
    /// - a `dir` keeps its stamp too, for the same reason and one more: a
    ///   dependency CREATED while the compile was running changes the
    ///   directory that was waiting for it, and re-stamping would record
    ///   that arrival as the baseline — the watch would sit on the failed
    ///   result with the fix already on disk.
    /// - a directory in `ours` — one this compile WROTE into — is always
    ///   re-stamped, because creating a file changes its directory's mtime
    ///   and keeping the old stamp would make the watch answer its own
    ///   output forever.
    ///
    /// `stamp` is injected so a test can drive this without a filesystem.
    pub(crate) fn follow<F>(
        &mut self,
        files: impl IntoIterator<Item = (PathBuf, Stamp)>,
        dirs: impl IntoIterator<Item = PathBuf>,
        ours: &[PathBuf],
        mut stamp: F,
    ) where
        F: FnMut(&Path) -> Stamp,
    {
        // `ours` is the FILES this compile created or removed. A directory
        // holding one of them is judged by its entry set minus those names
        // from here on.
        let mut minus: BTreeMap<PathBuf, Vec<std::ffi::OsString>> = BTreeMap::new();
        for f in ours {
            if let (Some(d), Some(n)) = (f.parent(), f.file_name()) {
                minus.entry(d.to_path_buf()).or_default().push(n.to_os_string());
            }
        }
        // Once ours, always ours: a file we created last compile and only
        // overwrote this one is still not somebody else's arrival.
        for (d, names) in &self.minus {
            let e = minus.entry(d.clone()).or_default();
            for n in names {
                if !e.contains(n) {
                    e.push(n.clone());
                }
            }
        }
        let mut next: BTreeMap<PathBuf, Stamp> = BTreeMap::new();
        for (p, at_read) in files {
            let s = self.files.get(&p).copied().unwrap_or(at_read);
            // Two units can load the same dependency, and each brings the
            // stamp from when IT read the file. If one read before a save
            // and the other after, taking the later one makes the newer
            // bytes the baseline and the first unit's output is never
            // recompiled. The earliest observation is the one that still
            // differs from what is on disk, so that is the one to keep.
            match next.get(&p) {
                Some(seen) if !earlier(&s, seen) => {}
                _ => {
                    next.insert(p, s);
                }
            }
        }
        for d in dirs {
            let s = match minus.get(&d) {
                // Ours: its mtime is meaningless to us now, so the stamp is
                // the entry set without our files. Taken fresh, because an
                // arrival is a difference in THAT, not in the mtime our own
                // write already moved.
                Some(names) => Stamp::of_dir_minus(&d, names),
                // Not ours: keep what we knew, or an arrival during the
                // compile becomes the baseline.
                None => self.files.get(&d).copied().unwrap_or_else(|| stamp(&d)),
            };
            next.insert(d, s);
        }
        self.files = next;
        self.minus = minus;
    }

    /// Has any followed file changed? Updates the remembered stamps, so a
    /// change is reported once.
    pub(crate) fn changed<F>(&mut self, mut stamp: F) -> bool
    where
        F: FnMut(&Path) -> Stamp,
    {
        let mut changed = false;
        for (path, known) in self.files.iter_mut() {
            // A directory we wrote into is asked the same question it was
            // stamped with — see `Snapshot::minus`.
            let now = match self.minus.get(path) {
                Some(names) => Stamp::of_dir_minus(path, names),
                None => stamp(path),
            };
            if now != *known {
                *known = now;
                changed = true;
            }
        }
        changed
    }

    /// How many files are followed. Only the tests ask — the watcher itself
    /// never needs to count them — so it is not compiled into the binary.
    #[cfg(test)]
    pub(crate) fn len(&self) -> usize {
        self.files.len()
    }
}

/// What the coalescing rule wants done at a given moment.
#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub(crate) enum Step {
    /// Nothing to do yet.
    Wait,
    /// Compile. `provisional` marks the run at the head of a burst, where a
    /// failure is likelier to be a half-written file than anything the user
    /// did: such a run reports nothing and removes nothing, and is always
    /// followed by an authoritative one.
    Run { provisional: bool },
}

/// The leading-edge-with-catch-up rule, driven by a clock the caller owns.
///
/// The first change runs immediately — the common case is one save with
/// nothing after it, and making it wait for a window that will stay empty is
/// pure latency. A provisional run ALWAYS gets a catch-up, not only when it
/// fails: it compiles what is on disk the instant the change is seen, which
/// is not always what the save finally leaves there, and a run that succeeds
/// on stale content would otherwise be the last word.
///
/// `now_ms` is any monotonically non-decreasing millisecond count.
#[derive(Debug)]
pub(crate) struct Coalesce {
    window_ms: u64,
    cooling_until: Option<u64>,
    dirty: bool,
}

impl Coalesce {
    pub(crate) fn new(window: Duration) -> Self {
        Coalesce {
            window_ms: window.as_millis() as u64,
            cooling_until: None,
            dirty: false,
        }
    }

    /// A change was seen.
    pub(crate) fn on_change(&mut self, now_ms: u64) -> Step {
        if self.cooling_until.is_some() {
            self.dirty = true;
            return Step::Wait;
        }
        self.start_cooling(now_ms);
        self.dirty = true; // the catch-up a provisional run always earns
        Step::Run { provisional: true }
    }

    /// Time has passed and nothing new was seen.
    pub(crate) fn on_tick(&mut self, now_ms: u64) -> Step {
        match self.cooling_until {
            Some(until) if now_ms >= until => {
                self.cooling_until = None;
                if self.dirty {
                    self.dirty = false;
                    self.start_cooling(now_ms);
                    // Never provisional. When it was, every run in the chain
                    // declined to report and each failure asked for another,
                    // so a genuinely broken file span forever in silence.
                    Step::Run { provisional: false }
                } else {
                    Step::Wait
                }
            }
            _ => Step::Wait,
        }
    }

    /// The outcome of the run this rule asked for. An AUTHORITATIVE failure
    /// must not ask for another, or the error is reported, re-run, reported
    /// again.
    pub(crate) fn finished(&mut self, provisional: bool, ok: bool) {
        if !provisional && !ok {
            self.dirty = false;
        }
    }

    fn start_cooling(&mut self, now_ms: u64) {
        self.cooling_until = Some(now_ms + self.window_ms);
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn stamp_of(n: u64) -> Stamp {
        Stamp {
            modified: Some(SystemTime::UNIX_EPOCH + Duration::from_secs(n)),
            len: n,
            digest: 0,
            mode: 0o644,
        }
    }

    /// The property a `--watch` test cannot assert: what a BURST costs. With
    /// the clock supplied, N changes inside one window is exactly two runs.
    #[test]
    fn a_burst_inside_one_window_costs_two_runs() {
        let mut c = Coalesce::new(Duration::from_millis(50));
        let mut runs = Vec::new();
        // Eight changes, 5 ms apart, all inside the first window.
        for i in 0..8u64 {
            if let Step::Run { provisional } = c.on_change(i * 5) {
                runs.push(provisional);
                c.finished(provisional, true);
            }
        }
        // The window closes.
        if let Step::Run { provisional } = c.on_tick(60) {
            runs.push(provisional);
            c.finished(provisional, true);
        }
        assert_eq!(runs, vec![true, false], "one provisional head, one catch-up");
    }

    /// The leading edge is the whole point: one save must not wait out a
    /// window that will stay empty.
    #[test]
    fn a_lone_save_compiles_immediately() {
        let mut c = Coalesce::new(Duration::from_millis(50));
        assert_eq!(c.on_change(0), Step::Run { provisional: true });
    }

    /// A provisional run earns a catch-up even when it SUCCEEDS: what it read
    /// is not always what the save finally left there.
    #[test]
    fn a_successful_provisional_run_still_gets_a_catch_up() {
        let mut c = Coalesce::new(Duration::from_millis(50));
        c.on_change(0);
        c.finished(true, true);
        assert_eq!(c.on_tick(49), Step::Wait, "not before the window closes");
        assert_eq!(c.on_tick(50), Step::Run { provisional: false });
    }

    /// …and an authoritative failure does NOT, or a broken file reports its
    /// error forever.
    #[test]
    fn an_authoritative_failure_does_not_ask_for_another() {
        let mut c = Coalesce::new(Duration::from_millis(50));
        c.on_change(0);
        c.finished(true, true);
        let step = c.on_tick(50);
        assert_eq!(step, Step::Run { provisional: false });
        c.finished(false, false);
        assert_eq!(c.on_tick(100), Step::Wait);
        assert_eq!(c.on_tick(1000), Step::Wait, "and stays quiet");
    }

    /// A change during the cool-down is not lost — it is what the catch-up is
    /// for.
    #[test]
    fn a_change_while_cooling_is_picked_up_by_the_catch_up() {
        let mut c = Coalesce::new(Duration::from_millis(50));
        c.on_change(0);
        c.finished(true, true);
        assert_eq!(c.on_change(10), Step::Wait, "coalesced into the window");
        assert_eq!(c.on_tick(50), Step::Run { provisional: false });
    }

    /// A file that is missing and stays missing is not a change on every
    /// tick — otherwise a watch with one unresolved `@use` would recompile
    /// forever.
    #[test]
    fn a_file_that_stays_missing_is_not_a_change() {
        let mut s = Snapshot::default();
        s.follow([(PathBuf::from("/gone.scss"), Stamp::MISSING)], [], &[], |_| {
            Stamp::MISSING
        });
        assert!(!s.changed(|_| Stamp::MISSING));
        // …and its appearance IS one.
        assert!(s.changed(|_| stamp_of(1)));
        assert!(!s.changed(|_| stamp_of(1)), "reported once");
    }

    /// The same second, twice: a filesystem with a one-second timestamp can
    /// leave the mtime alone across two saves, and the length catches it.
    #[test]
    fn a_same_second_save_of_a_different_length_is_a_change() {
        let mut s = Snapshot::default();
        let coarse = |len: u64| Stamp {
            modified: Some(SystemTime::UNIX_EPOCH + Duration::from_secs(1)),
            len,
            digest: 0,
            mode: 0o644,
        };
        s.follow([(PathBuf::from("/a.scss"), coarse(10))], [], &[], |_| coarse(10));
        assert!(s.changed(|_| coarse(11)));
    }

    /// Following a new set keeps what is known about the files that stay: a
    /// file that has just been READ has not just changed, and re-stamping the
    /// whole set on every compile would be a recompile on the next tick.
    #[test]
    fn following_again_does_not_invent_a_change() {
        let mut s = Snapshot::default();
        let at = |p: &str| (PathBuf::from(p), stamp_of(1));
        s.follow([at("/a.scss"), at("/b.scss")], [], &[], |_| stamp_of(1));
        s.follow([at("/a.scss"), at("/c.scss")], [], &[], |_| stamp_of(1));
        assert_eq!(s.len(), 2);
        assert!(!s.changed(|_| stamp_of(1)));
    }

    /// The interval is not a constant: measured, a 5000-file sweep is 9 ms,
    /// and repeating that every 50 ms is 18% of a core left running all
    /// afternoon.
    #[test]
    fn the_interval_grows_with_what_a_sweep_costs() {
        // Ten files: 0.014 ms. The floor decides.
        assert_eq!(next_interval(Duration::from_micros(14), 50), MIN_INTERVAL);
        // 500 files: 0.665 ms, 50x is 33 ms — still the floor.
        assert_eq!(next_interval(Duration::from_micros(665), 50), MIN_INTERVAL);
        // 2000 files: 3.2 ms, 50x is 160 ms.
        assert_eq!(
            next_interval(Duration::from_micros(3191), 50),
            Duration::from_micros(159_550)
        );
        // 5000 files: 9.1 ms, 50x is 457 ms.
        assert_eq!(
            next_interval(Duration::from_micros(9138), 50),
            Duration::from_micros(456_900)
        );
        // And a pathological sweep is capped rather than unbounded.
        assert_eq!(next_interval(Duration::from_millis(100), 50), MAX_INTERVAL);
    }

    /// A save that lands WHILE the compile is running must survive being
    /// followed again. Re-stamping the file after the compile records the
    /// new bytes as the baseline for output built from the old ones, and
    /// nothing ever compiles them — measured at 1 in 4, writing into a
    /// 680 ms compile.
    #[test]
    fn a_file_changed_during_the_compile_is_still_a_change() {
        let mut s = Snapshot::default();
        let f = PathBuf::from("/a.scss");
        s.follow([(f.clone(), stamp_of(1))], [], &[], |_| stamp_of(1));
        // The compile runs; the file is saved again; the watcher follows the
        // same set afterwards and must NOT adopt the new stamp.
        s.follow([(f.clone(), stamp_of(2))], [], &[], |_| stamp_of(2));
        assert!(s.changed(|_| stamp_of(2)), "the mid-compile save was absorbed");
    }

    /// A file this compile met for the FIRST time — the whole set, on the
    /// first compile of a watch — takes the stamp from when it was read,
    /// not from after. Otherwise a save that lands during that compile
    /// becomes the baseline and the CSS built from the older bytes stands.
    /// Measured before this: 3 of 5 lost, saving 300 ms into a 680 ms first
    /// compile.
    #[test]
    fn a_new_file_takes_the_stamp_from_when_it_was_read() {
        let mut s = Snapshot::default();
        let f = PathBuf::from("/new.scss");
        // Read at 1; saved again during the compile, so it is 2 by the time
        // the watcher follows it.
        s.follow([(f.clone(), stamp_of(1))], [], &[], |_| stamp_of(2));
        assert!(
            s.changed(|_| stamp_of(2)),
            "the save during the first compile was absorbed",
        );
    }

    /// The case two fields cannot see: same second, same length. On a
    /// filesystem that keeps whole seconds that is two ordinary saves, and
    /// without the digest the watch would sit on stale CSS forever.
    #[test]
    fn a_same_second_same_length_save_is_still_a_change() {
        let whole_second = |digest: u64| Stamp {
            modified: Some(SystemTime::UNIX_EPOCH + Duration::from_secs(1)),
            len: 10,
            digest,
            mode: 0o644,
        };
        let mut s = Snapshot::default();
        s.follow([(PathBuf::from("/a.scss"), whole_second(111))], [], &[], |_| {
            whole_second(111)
        });
        assert!(
            s.changed(|_| whole_second(222)),
            "the contents changed and nothing else did"
        );
        assert!(!s.changed(|_| whole_second(222)), "reported once");
    }

    /// …and a precise timestamp does not pay for it. `Stamp::of` reads the
    /// file only when the mtime has no sub-second part, so on a filesystem
    /// like this one the digest is always zero and no content is read.
    #[test]
    fn a_precise_timestamp_costs_no_read() {
        let dir = std::env::temp_dir().join(format!("sasso-stamp-{}", std::process::id()));
        std::fs::create_dir_all(&dir).unwrap();
        let p = dir.join("a.scss");
        std::fs::write(&p, "$c: red;\n").unwrap();
        let stamp = Stamp::of(&p);
        let precise = stamp
            .modified
            .and_then(|t| t.duration_since(SystemTime::UNIX_EPOCH).ok())
            .is_some_and(|d| d.subsec_nanos() != 0);
        if precise {
            assert_eq!(stamp.digest, 0, "a precise mtime should not have read the file");
        }
        // A file that does not exist is never read either.
        assert_eq!(Stamp::of(&dir.join("nope.scss")), Stamp::MISSING);
        std::fs::remove_dir_all(&dir).ok();
    }

    /// The same, through `Stamp::of` rather than hand-made stamps: a
    /// whole-second mtime is the signal that the clock is coarse, and the
    /// digest has to actually be taken there. Forced with `set_modified`,
    /// so this does not need a filesystem that keeps whole seconds.
    #[test]
    fn a_whole_second_mtime_makes_stamp_of_read_the_contents() {
        let dir = std::env::temp_dir().join(format!("sasso-digest-{}", std::process::id()));
        std::fs::create_dir_all(&dir).unwrap();
        let p = dir.join("a.scss");
        // The digest rule keys on a whole-second mtime, and `set_modified`
        // (1.75) is above this crate's MSRV — so ask `Stamp::of` what it
        // would do with one, through the same private field the rule sets.
        let stamp_with = |text: &str| {
            std::fs::write(&p, text).unwrap();
            let live = Stamp::of(&p);
            Stamp {
                modified: Some(SystemTime::UNIX_EPOCH + Duration::from_secs(1_700_000_000)),
                len: live.len,
                digest: digest_of(&p, false),
                mode: live.mode,
            }
        };
        // Same length, same second: only the contents differ.
        let first = stamp_with("$c: red00;\n");
        let second = stamp_with("$c: blue0;\n");
        assert_ne!(
            first, second,
            "two same-length saves in one second must not look identical",
        );
        assert_ne!(first.digest, 0, "a whole-second mtime should have been digested");
        // …and the rule that decides it: a precise mtime reads nothing.
        //
        // Guarded by `subsecond_is_fine` itself, not by `subsec_nanos != 0`.
        // The two are not the same question — the rule also rejects a whole
        // number of microseconds — and on a 100 ns clock the gap is reachable:
        // every NTFS subsecond is a multiple of 100, so one in ten is also a
        // multiple of 1000, and on those runs `Stamp::of` digests while the
        // weaker guard still demanded that it had not. That is why this test
        // failed roughly one Windows run in ten, on master as well as here.
        let p2 = dir.join("b.scss");
        std::fs::write(&p2, "$c: red00;\n").unwrap();
        let precise = Stamp::of(&p2);
        let subsec = precise
            .modified
            .and_then(|t| t.duration_since(SystemTime::UNIX_EPOCH).ok())
            .map_or(0, |d| d.subsec_nanos());
        if subsecond_is_fine(subsec) {
            assert_eq!(
                precise.digest, 0,
                "a precise mtime ({subsec} ns) should not read the file"
            );
        } else {
            // The other half of the same rule, so neither branch is a way
            // through this test that checks nothing: a clock this coarse is
            // exactly when the contents MUST be read, which is what the two
            // saves above rely on.
            assert_ne!(
                precise.digest, 0,
                "a coarse mtime ({subsec} ns) should have read the file"
            );
        }
        std::fs::remove_dir_all(&dir).ok();
    }

    /// A directory's digest is its entries, because `fs::read` cannot read
    /// one — digesting a directory as though it were a file returned 0 every
    /// time, so on a coarse clock all three fields stayed put and a
    /// dependency arriving in it was never seen. That is the half of the
    /// watch that recovers from a missing `@use`.
    #[test]
    fn a_directorys_digest_is_what_is_in_it() {
        let dir = std::env::temp_dir().join(format!("sasso-dirdig-{}", std::process::id()));
        std::fs::create_dir_all(&dir).unwrap();
        let empty = digest_of(&dir, true);
        std::fs::write(dir.join("_a.scss"), "$a: 1;\n").unwrap();
        let one = digest_of(&dir, true);
        std::fs::write(dir.join("_b.scss"), "$b: 2;\n").unwrap();
        let two = digest_of(&dir, true);
        // …and a file's CONTENTS changing is not a directory change: that is
        // the file's own stamp's job, and counting it here would recompile
        // twice for one save.
        std::fs::write(dir.join("_a.scss"), "$a: 999;\n").unwrap();
        let after_edit = digest_of(&dir, true);
        std::fs::remove_dir_all(&dir).ok();

        assert_ne!(empty, one, "a file appeared");
        assert_ne!(one, two, "another file appeared");
        assert_eq!(two, after_edit, "editing a file is not a directory change");
        // Reading a directory as a file is where this started.
        assert_eq!(digest_of(&std::env::temp_dir(), false), 0);
    }

    /// A directory we did NOT write into keeps its stamp, so a dependency
    /// created while the compile was running is still a change. Without
    /// this the watch records the arrival as the baseline and sits on the
    /// failed result with the fix already on disk.
    #[test]
    fn a_directory_changed_during_the_compile_is_still_a_change() {
        let mut s = Snapshot::default();
        let d = PathBuf::from("/sub");
        s.follow([], [d.clone()], &[], |_| stamp_of(1));
        // The compile ran; `_new.scss` appeared in it; we wrote nothing
        // there ourselves.
        s.follow([], [d.clone()], &[], |_| stamp_of(2));
        assert!(
            s.changed(|_| stamp_of(2)),
            "the arrival during the compile was absorbed"
        );
    }

    /// A sub-second part that is merely NON-ZERO proves nothing: a
    /// millisecond clock reports one and still cannot tell two saves inside
    /// one tick apart. What the value says is the resolution — its trailing
    /// zeros — and that is what decides whether the contents have to be
    /// read.
    #[test]
    fn the_resolution_is_read_from_the_timestamp_not_assumed() {
        // Whole seconds, and the two coarse-but-non-zero cases the old test
        // called precise.
        assert!(!subsecond_is_fine(0), "FAT and friends");
        assert!(!subsecond_is_fine(1_000_000), "a millisecond clock");
        assert!(!subsecond_is_fine(123_000_000), "still a millisecond clock");
        assert!(!subsecond_is_fine(456_000), "a microsecond clock");
        // Anything finer than a microsecond can tell two saves apart.
        assert!(subsecond_is_fine(100), "a 100 ns clock");
        assert!(subsecond_is_fine(123_456_789), "nanoseconds");
        assert!(subsecond_is_fine(1), "the finest there is");
    }

    /// Becoming readable is a change, and it is the one a watch is waiting
    /// for when a dependency exists but cannot be read. `chmod` moves no
    /// mtime, no length and no byte, so without the mode the stamp is
    /// identical before and after and the fix reaches nothing.
    #[cfg(unix)]
    #[test]
    fn a_permission_change_is_a_change() {
        use std::os::unix::fs::PermissionsExt;
        let dir = std::env::temp_dir().join(format!("sasso-mode-{}", std::process::id()));
        std::fs::create_dir_all(&dir).unwrap();
        let p = dir.join("_v.scss");
        std::fs::write(&p, "$c: red;\n").unwrap();
        std::fs::set_permissions(&p, std::fs::Permissions::from_mode(0o000)).unwrap();
        let locked = Stamp::of(&p);
        std::fs::set_permissions(&p, std::fs::Permissions::from_mode(0o644)).unwrap();
        let opened = Stamp::of(&p);
        std::fs::remove_dir_all(&dir).ok();
        assert_ne!(locked, opened, "chmod 000 -> 644 must be a change");
    }

    /// Two units, one dependency, read either side of a save. The later
    /// stamp used to win, which makes the new bytes the baseline and leaves
    /// the first unit's output built from the old ones forever.
    #[test]
    fn the_earliest_observation_of_a_shared_dependency_wins() {
        let mut s = Snapshot::default();
        let shared = PathBuf::from("/_v.scss");
        // Unit A read it at 1; unit B, after the save, at 2.
        s.follow(
            [(shared.clone(), stamp_of(1)), (shared.clone(), stamp_of(2))],
            [],
            &[],
            |_| stamp_of(2),
        );
        assert!(
            s.changed(|_| stamp_of(2)),
            "the save one unit compiled against was adopted as the baseline",
        );
        // …and the order it arrives in does not decide it.
        let mut s = Snapshot::default();
        s.follow(
            [(shared.clone(), stamp_of(2)), (shared.clone(), stamp_of(1))],
            [],
            &[],
            |_| stamp_of(2),
        );
        assert!(s.changed(|_| stamp_of(2)), "…in either order");
    }

    /// A file one unit could not find at all is the earliest observation
    /// there is: whatever the other saw, "not there" differs the moment it
    /// appears.
    #[test]
    fn a_missing_observation_beats_a_present_one() {
        let mut s = Snapshot::default();
        let p = PathBuf::from("/_v.scss");
        s.follow(
            [(p.clone(), stamp_of(5)), (p.clone(), Stamp::MISSING)],
            [],
            &[],
            |_| stamp_of(5),
        );
        assert!(
            s.changed(|_| stamp_of(5)),
            "the file is there and one unit had not seen it"
        );
    }

    /// A directory this watch wrote into is judged by what is in it apart
    /// from our own files.
    ///
    /// This replaces `a_directory_is_restamped_because_our_own_writes_move_it`,
    /// which asserted the older contract — `ours` was a list of DIRECTORIES
    /// and such a directory was re-stamped wholesale. That is what hid an
    /// arrival landing during the same compile. Both halves of the property
    /// are here: our own write is not a change, and somebody else's is — so the output landing there is not an arrival,
    /// and a dependency arriving there during the same compile is not
    /// hidden by it. Re-stamping such a directory wholesale did hide one.
    #[test]
    fn a_directory_we_wrote_into_still_sees_somebody_elses_arrival() {
        let dir = std::env::temp_dir().join(format!("sasso-minus-{}", std::process::id()));
        std::fs::create_dir_all(&dir).unwrap();
        std::fs::write(dir.join("main.scss"), "a{b:1}\n").unwrap();
        let out = dir.join("main.css");

        let mut s = Snapshot::default();
        // The compile created its own output here.
        std::fs::write(&out, "a{b:1}\n").unwrap();
        s.follow([], [dir.clone()], std::slice::from_ref(&out), Stamp::of);
        assert!(!s.changed(Stamp::of), "our own output is not a change");

        // Overwriting it is not one either.
        std::fs::write(&out, "a{b:2}\n").unwrap();
        assert!(!s.changed(Stamp::of), "and neither is rewriting it");

        // Somebody else's file is.
        std::fs::write(dir.join("_v.scss"), "$c: red;\n").unwrap();
        let seen = s.changed(Stamp::of);
        std::fs::remove_dir_all(&dir).ok();
        assert!(seen, "a dependency arrived and the directory was ours");
    }
}

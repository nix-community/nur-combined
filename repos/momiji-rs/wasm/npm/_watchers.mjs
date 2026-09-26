/**
 * One live `fs.watch` handle per directory, and what to do when one dies.
 *
 * Its own module with an injectable `watch` because every way this goes
 * wrong is unreachable from a `--watch` test on a healthy machine. The
 * failures are real, though, and they are silent:
 *
 *   - Tearing every watcher down and rebuilding it on each compile
 *     leaves a gap in which a save is simply not seen. Measured at 1 in
 *     30 going stale FOREVER, and it got worse when a change doubled the
 *     number of rewatch cycles. So `sync` closes only what is no longer
 *     wanted and opens only what is new.
 *   - A watcher that fails takes the whole session with it: an `error`
 *     event with nobody listening throws, out of a callback with nothing
 *     to catch it.
 *   - A watcher that fails and is merely forgotten is worse than a crash
 *     in one way — nothing reopens it, nothing says so, and every save in
 *     that directory is missed for the life of the session.
 *
 * Two facts from node's own `internal/fs/watchers` source (v22.22.3)
 * shape this, and both are load-bearing:
 *
 *   - Before emitting `error`, node closes and nulls the handle, and
 *     deliberately does NOT fire `close` ("We don't use this.close()
 *     here to avoid firing the close event"). So `error` cannot be left
 *     to the `close` listener, the slot is genuinely uncovered when it
 *     arrives, and the dead handle cannot come back as a duplicate.
 *   - A watch that cannot be STARTED throws synchronously instead —
 *     including `ENOSPC`, "System limit for number of file watchers
 *     reached". That one must not be swallowed with the directory that
 *     merely does not exist.
 *
 * And one the platforms disagree about, measured rather than assumed —
 * the same probe on both, deleting a watched directory and recreating
 * it at the same path:
 *
 *              handle after the delete   recreated: still delivers?
 *   macOS      alive (FSEvents is by     YES
 *              path, not inode)
 *   Linux      dead                      NO
 *
 * On neither platform does it emit `error` OR `close`. So on Linux a
 * live-looking entry can be a dead handle, nothing will ever say so,
 * and `live.has(d)` claims the directory is covered for the rest of the
 * session. Only a look at the filesystem can tell, which is why `sync`
 * takes one: it is per DIRECTORY (a handful) and not per file, unlike
 * the snapshot survey that had to be made lazy.
 *
 * @param {object} o
 * @param {(dir: string, cb: (event: string, filename: string | null) => void) => object} o.watch
 * @param {(dir: string, event: string, filename: string | null) => void} o.onEvent
 * @param {(dir: string) => boolean} o.exists
 * @param {(dir: string) => void} o.onMissing  wait for this one to come back
 * @param {(line: string) => void} o.report  a warning for the user, one line
 * @param {number} [o.retries]  re-arms allowed per directory before giving up
 */
export function makeWatchers({ watch, onEvent, exists, onMissing, report, retries = 3 }) {
  /** directory -> the single live handle watching it. */
  const live = new Map();
  /** Consecutive failures since this directory last delivered an event. */
  const failures = new Map();
  /** Directories already complained about, so one fault is one line. */
  const said = new Set();

  const sayOnce = (d, line) => {
    if (said.has(d)) return;
    said.add(d);
    report(line);
  };

  const open = (d) => {
    let handle;
    try {
      handle = watch(d, (event, filename) => {
        // A delivered event is the only proof the watcher WORKS —
        // opening one is not, which is why neither of these is reset
        // where the handle is created. The budget is for a directory
        // failing in a burst, not for one that failed an hour ago, and
        // a fault after a working stretch is worth saying again.
        failures.delete(d);
        said.delete(d);
        onEvent(d, event, filename);
      });
    } catch (e) {
      // A directory that is not there is not a fault — but something
      // has to wait for it. Only configured load paths were probed, so
      // a dependency directory that was deleted and put back was never
      // watched again, and on Linux nothing else notices. Anything that
      // is NOT simply absent means this directory is unwatched and
      // nobody would ever know.
      if (e?.code === "ENOENT") onMissing(d);
      else sayOnce(d, `sasso: cannot watch ${d}: ${e?.message ?? e}`);
      return;
    }

    // Only ever drop OUR handle. `sync` already deletes what it closes,
    // so by the time a `close` arrives the slot may hold a newer handle
    // for the same directory; evicting that one would reopen the
    // teardown gap this module exists to avoid.
    handle.on("close", () => {
      if (live.get(d) === handle) live.delete(d);
    });
    handle.on("error", (e) => {
      // Stale: `sync` has already dropped or replaced this handle. The
      // `close` path returns here and so must this one — re-arming on
      // behalf of a handle nobody holds either resurrects a directory
      // that was dropped, or opens a SECOND watcher beside the
      // replacement and leaks the first.
      if (live.get(d) !== handle) return;
      live.delete(d);
      const n = (failures.get(d) ?? 0) + 1;
      failures.set(d, n);
      if (n > retries) {
        sayOnce(
          d,
          `sasso: gave up watching ${d} after ${n} errors (${e?.message ?? e}) — ` +
            `changes there will be missed until the next compile`,
        );
        return;
      }
      open(d);
    });

    live.set(d, handle);
  };

  return {
    /**
     * Make the live set exactly `dirs`, touching nothing that is already
     * right. In the common case the set does not change between compiles
     * and this does nothing at all.
     *
     * @param {Set<string>} dirs
     */
    sync(dirs) {
      for (const [d, handle] of live) {
        // Wanted no more, or gone from disk. The second is the one that
        // is easy to miss: a deleted directory leaves a handle that is
        // dead on Linux and silent on both platforms, so without this
        // the entry would claim it forever. Dropping it here lets the
        // open loop below reopen it, or hand it to the probe.
        if (!dirs.has(d) || !exists(d)) {
          live.delete(d);
          handle.close();
        }
      }
      for (const d of dirs) {
        if (!live.has(d)) open(d);
      }
    },
    /** How many directories are actually being watched. */
    get size() {
      return live.size;
    },
  };
}

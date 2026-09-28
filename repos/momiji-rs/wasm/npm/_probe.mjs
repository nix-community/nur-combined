/**
 * Waiting for a directory that does not exist yet.
 *
 * `-I generated` before `generated/` is there cannot be watched —
 * `fs.watch` throws — so this watches the nearest ancestor that DOES
 * exist and waits for the target to appear. If what appears is only the
 * next link in the chain (`-I a/b/c` with just `a` present) it re-arms
 * deeper rather than sitting on an ancestor that will never become the
 * directory it is waiting for.
 *
 * `fs.watch` is cheap to OPEN and expensive to CLOSE, which is why `arm`
 * returns early when nothing has changed. Measured on macOS, 300 iterations
 * of watch/close/re-watch on fresh directories:
 *
 *     worst fs.watch open   0.4 ms
 *     worst handle.close    3982.3 ms
 *     worst close+reopen    6788.0 ms
 *
 * Synchronously, so a close on the compile path freezes the whole session for
 * seconds. See `arm` for the redundant pair that used to happen on every
 * rewatch (#195).
 *
 * Its own module, with injectable `watch` and `exists`, because the way
 * this goes wrong is invisible to a `--watch` test until it is
 * catastrophic. The first version pushed a new watcher on every ancestor
 * event and closed none; each new watcher then also saw the events that
 * spawned it, so the growth was not linear. Twenty unrelated writes in
 * the ancestor directory was enough:
 *
 *     Error: EMFILE: too many open files, watch
 *
 * No integration test provokes that without becoming a stress test, and
 * a stress test that passes at nineteen writes tells you nothing. With a
 * fake `watch` the invariant is one line: one handle per target, however
 * many times it re-arms.
 *
 * @param {object} o
 * @param {(dir: string, cb: () => void) => {close(): void}} o.watch
 * @param {(path: string) => boolean} o.exists
 * @param {(path: string) => string} o.dirname
 * @param {(target: string) => void} o.onAppear  the target now exists
 */
export function makeProbe({ watch, exists, dirname, onAppear }) {
  /** target -> the single live watcher waiting for it. */
  const live = new Map();
  /** target -> the ancestor that watcher is actually watching. */
  const at = new Map();

  const arm = (target) => {
    // Which ancestor SHOULD be watched is decided before anything is torn
    // down, so that an arm which changes nothing can return having done
    // nothing.
    let dir = dirname(target);
    while (!exists(dir)) {
      const up = dirname(dir);
      if (up === dir) return; // reached the root without finding one
      dir = up;
    }
    // Already watching exactly that: re-arming is not free.
    //
    // `rewatch` arms every absent load path itself, and then `watchers.sync`
    // fails to watch the same directory, reports it missing, and arms it
    // AGAIN — twice for one target, microseconds apart. The second call used
    // to close a handle created by the first and open an identical one, and
    // closing a just-created watcher is where a `--watch` session was
    // observed to stall for 11-18 s under load: the arrival it was waiting
    // for then landed during the stall, and the test that waits 20 s for it
    // failed 5 times in 14 (#195).
    //
    // Re-arming still happens when it MEANS something — the callback's
    // `else arm(target)` after a link in the chain appears picks a deeper
    // ancestor, so `dir` differs and the handle is genuinely replaced.
    if (live.has(target) && at.get(target) === dir) return;

    // Replace, never add.
    live.get(target)?.close();
    live.delete(target);
    at.delete(target);

    try {
      live.set(
        target,
        watch(dir, () => {
          if (exists(target)) onAppear(target);
          else arm(target); // a link in the chain appeared; go deeper
        }),
      );
      at.set(target, dir);
    } catch {
      // it vanished between the check and the watch — the next event,
      // or the next rewatch, will try again
    }
  };

  return {
    arm,
    closeAll() {
      for (const w of live.values()) w.close();
      live.clear();
      at.clear();
    },
    /** How many handles are open. The invariant this module exists for. */
    get size() {
      return live.size;
    },
  };
}

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

  const arm = (target) => {
    // Replace, never add.
    live.get(target)?.close();
    live.delete(target);

    let at = dirname(target);
    while (!exists(at)) {
      const up = dirname(at);
      if (up === at) return; // reached the root without finding one
      at = up;
    }
    try {
      live.set(
        target,
        watch(at, () => {
          if (exists(target)) onAppear(target);
          else arm(target); // a link in the chain appeared; go deeper
        }),
      );
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
    },
    /** How many handles are open. The invariant this module exists for. */
    get size() {
      return live.size;
    },
  };
}

/**
 * A repeated look at the filesystem, beside the native watcher.
 *
 * `fs.watch` is the fast path and on Linux it is superb. On macOS it is
 * not usable on its own, and that is measured rather than assumed — no
 * sasso involved, just `fs.watch` on a directory, settle, write a file,
 * time the callback, 20 samples 1200ms apart (#164):
 *
 *   platform                  node       delivered   median      max
 *   macOS 26, Apple Silicon   v22.22.3      20/20     552ms    3386ms
 *   macOS 26, Intel           v26.7.0        8/20    9132ms   13799ms
 *   Linux, inotify            v26.8.1       20/20     0.2ms      0.3ms
 *
 * Twelve of twenty events never arrived at all on the Intel Mac, inside
 * fifteen seconds. Not a `/var/folders` artefact either: the same probe against a
 * directory in `$HOME` gave 8/20 and a 12970ms worst case. So the watcher
 * cannot be what GUARANTEES a save is seen; it can only make the common
 * case instant, which on Linux it does.
 *
 * The cost of asking instead of waiting, measured the same way the
 * binary's `src/watch.rs` measures its own sweep — stat every known file,
 * list every watched directory:
 *
 *     10 files   0.054ms        2000 files   5.323ms
 *    500 files   1.188ms        5000 files  13.184ms
 *
 * At the 50ms floor a ten-file project spends 0.1% of a core. A 5000-file
 * one would spend 26%, which is why the interval is not a constant: it
 * grows with what a sweep actually costs, exactly as the binary's does, so
 * a big tree polls more slowly rather than burning a core all afternoon.
 *
 * Its own module with injectable timers because none of that is reachable
 * from a `--watch` test: the interval rule needs a clock the test drives,
 * and the alternative — save, wait, count — measures the machine.
 */

/** Never faster than this, however cheap the sweep. */
export const MIN_INTERVAL_MS = 50;
/** Never slower than this, however expensive. */
export const MAX_INTERVAL_MS = 500;
/**
 * How much of one core a sweep may have: the next wait is the sweep's own
 * cost times this, so 50 means "at most 2% of a core".
 */
export const SWEEP_BUDGET = 50;

/**
 * How long to wait after a sweep that took `sweepMs`.
 *
 * @param {number} sweepMs
 * @param {number} [budget]
 * @returns {number}
 */
export function nextInterval(sweepMs, budget = SWEEP_BUDGET) {
  const want = sweepMs * budget;
  if (!(want > MIN_INTERVAL_MS)) return MIN_INTERVAL_MS; // also catches NaN
  // Whole milliseconds: `setTimeout` has no use for the fraction, and a
  // sweep timed by subtracting two floats does not land on one anyway —
  // 2.054 - 0.054 is 2.0000000000000004, and the wait it earns is 100ms.
  return Math.round(Math.min(want, MAX_INTERVAL_MS));
}

/**
 * Run `sweep` on a self-adjusting interval and report when it says the
 * filesystem moved.
 *
 * @param {object} o
 * @param {() => boolean} o.sweep  look at the filesystem; true = something
 *   changed. It is also responsible for re-baselining, or a single change
 *   would be reported on every tick from here on.
 * @param {() => void} o.onChange  called once per sweep that returned true
 * @param {typeof setTimeout} [o.setTimer]
 * @param {typeof clearTimeout} [o.clearTimer]
 * @param {() => number} [o.now]  a monotonic millisecond clock
 * @param {number} [o.budget]
 * @returns {{ start: () => void, stop: () => void, intervalMs: () => number }}
 */
export function makePoller({
  sweep,
  onChange,
  setTimer = setTimeout,
  clearTimer = clearTimeout,
  now = () => performance.now(),
  budget = SWEEP_BUDGET,
}) {
  let timer = null;
  let interval = MIN_INTERVAL_MS;
  // `timer` is null for the whole of a tick, so it cannot answer "are we
  // still running": a `stop()` from inside `sweep` would find nothing to
  // clear and the tick would rearm on top of it. This can.
  let running = false;

  const tick = () => {
    timer = null;
    const began = now();
    let moved = false;
    try {
      moved = sweep();
    } catch {
      // A sweep that threw tells us nothing about the filesystem and
      // must not take the watch down with it — the next one is 50ms
      // away. `fs.watch` is still live underneath; this is the safety
      // net, and a safety net that can crash the process is worse than
      // none.
    }
    interval = nextInterval(now() - began, budget);
    // Rearmed BEFORE the callback: `onChange` runs a compile, and a
    // compile that throws would otherwise stop the polling for good.
    // Unless the sweep just stopped us, which is the one thing that must
    // survive being decided mid-tick.
    if (running) timer = setTimer(tick, interval);
    if (moved && running) onChange();
  };

  return {
    start() {
      if (running) return;
      running = true;
      timer = setTimer(tick, interval);
    },
    stop() {
      running = false;
      if (timer !== null) clearTimer(timer);
      timer = null;
    },
    /** The wait the last sweep earned. Only the tests ask. */
    intervalMs: () => interval,
  };
}

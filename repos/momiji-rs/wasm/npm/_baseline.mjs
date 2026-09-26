/**
 * What the sweep is allowed to treat as "this is what the compile read".
 *
 * The sweep compares the filesystem against a baseline, and the baseline
 * has to be what the COMPILE saw — otherwise a save made while the compile
 * was running becomes the thing we compare against, and no later sweep can
 * ever find it. For a path that was already known there is a reading from
 * before the compile started and it simply wins.
 *
 * A path the compile DISCOVERED has no such reading. `@use "sub/dep"` puts
 * `sub/` in the watched set only once the compile resolves it, so the only
 * mtime available for anything in there was taken afterwards — and if the
 * file moved in between, that mtime is the save.
 *
 * Measured (#164, PR #173): a 900k-rule entry so the compile takes
 * seconds, `sub/_dep.scss` saved five seconds in, `--poll` so nothing but
 * the sweep can answer:
 *
 *   trusting the post-compile mtime    6 saves lost out of 6
 *   this rule                          0 lost out of 6
 *
 * The end-to-end window is a race — it needs a save to land between the
 * compile's read and the snapshot after it — so it is measured rather than
 * pinned in the suite, the same call `_coalesce.mjs` makes about its own
 * property. What IS pinned is the rule below.
 *
 * @param {number | null} mtimeMs  the path's mtime, or null if it is gone
 * @param {number | undefined} startedAt  when the compile began
 * @returns {number | null} the baseline to record. `null` means "unknown",
 *   which the sweep reads as a difference from whatever it finds next, so
 *   the change gets exactly one catch-up compile — and the compile after
 *   that has a real reading of its own.
 */
export function baselineFor(mtimeMs, startedAt) {
  if (startedAt === undefined) return mtimeMs;
  if (mtimeMs === null) return null;
  // `>=`, not `>`: a coarse mtime and the clock can land on the same
  // millisecond, and the safe direction is the one that costs a silent
  // recompile rather than a lost save. The binary makes the same call in
  // `subsecond_is_fine`, for the same reason.
  return mtimeMs >= startedAt ? null : mtimeMs;
}

// The one UTF-8 rule for every read in the `sasso` npm package.
//
// A module of its own, with no imports, because the CLI needs it on every run:
// importing it from `_importer.mjs` put that module's whole load on the path to
// handing a command line to the binary, about 4 ms of a 39 ms run (Linux/x86_64,
// Node 26, 2026-09-29).

/**
 * Decode bytes that are supposed to be UTF-8, or `null` when they are not.
 *
 * `readFileSync(path, "utf8")` does NOT reject invalid UTF-8 — it substitutes
 * U+FFFD and returns a string — so every read that went through it accepted a
 * file dart-sass refuses, and compiled it into replacement characters without
 * a word. Measured (#179): `$c: \xff\xfered;` gave `.a { color: ��red; }`
 * on the npm CLI while dart, the binary and the native addon's own reads all
 * errored.
 *
 * Shared because the entry, every dependency and standard input needed the
 * same rule — a copy at each read is how they drift. What each caller SAYS
 * about a failure differs, so only the decoding lives here.
 */
export function decodeUtf8(bytes) {
  try {
    return new TextDecoder("utf-8", { fatal: true }).decode(bytes);
  } catch {
    return null;
  }
}

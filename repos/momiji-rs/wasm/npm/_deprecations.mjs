// The deprecation ids `silenceDeprecations` / `--silence-deprecation` accept,
// and the one place that decides what to do with an id that is not among them.
//
// Shared by all three JS consumers (`cli.mjs`, `_loader.mjs`, `native.mjs`) so
// there is one copy to keep right. The list had been written out twice and the
// two copies were the same guess, missing seven ids — `if-function` among them,
// which sasso emits, so silencing it failed on a warning sasso had just
// printed. `src/main.rs` holds the Rust CLI's copy and a test in `wasm/test.mjs`
// derives this one from it, so the remaining two cannot drift apart.
//
// The list is dart-sass 1.104.1's whole `Deprecation` enum, in its declaration
// order, taken from the enum rather than guessed. The package ships most of it
// as `sass/types/deprecations.d.ts`, but that file omits the future-only ids
// (`calc-interp`), and the CLI accepts those, so the enum in `sass.dart.js` is
// the authority.
export const DEPRECATION_IDS = new Set([
  "call-string", "elseif", "moz-document", "relative-canonical",
  "new-global", "color-module-compat", "slash-div", "bogus-combinators",
  "strict-unary", "function-units", "duplicate-var-flags", "null-alpha",
  "abs-percent", "fs-importer-cwd", "css-function-mixin", "mixed-decls",
  "feature-exists", "color-4-api", "color-functions", "legacy-js-api",
  "import", "global-builtin", "type-function",
  "compile-string-relative-url", "misplaced-rest", "with-private",
  "if-function", "function-name", "adjacent-compounds", "user-authored",
  "calc-interp",
]);

// Normalise a `silenceDeprecations` option for the core, reporting ids
// dart-sass does not know.
//
// The CLI and the JS API differ here, and both follow dart. `sass` the command
// exits 64 on an unknown id, because a typo there would otherwise leave the
// warning printing with nothing to say why. The JS API does NOT throw: dart
// warns `Invalid deprecation "nope".` through the caller's own logger and
// compiles anyway — measured against 1.104.1, including that the warning is a
// plain one (`deprecation: false`, no span) and that it is emitted once per
// occurrence, duplicates included, in the order given.
//
// So throwing here would be stricter than dart and would break builds dart
// accepts; staying silent, which is what this did first, contradicts the option
// documented in `sasso.d.ts` and leaves a typo doing nothing with no trace.
//
// Unknown ids are then DROPPED rather than forwarded. Forwarding them looks
// harmless — an id that matches no deprecation silences nothing — but the wasm
// ABI carries this list as one comma-separated string, so the core splits it
// again on the way in and `["import,global-builtin"]`, a single invalid id,
// arrived as two valid ones. Measured against dart 1.104.1, which warns and
// silences NOTHING for that input, as the native path already did:
//
//     ["import,global-builtin"]   dart   INVALID, then all 3 warnings
//                                 native INVALID, then all 3 warnings
//                                 wasm   INVALID, then 1  <- silenced both
//
// Dropping them here fixes that at the one place both engines share, instead
// of teaching the marshalling not to trust its own input.
export function normalizeSilenced(value, warn) {
  if (!Array.isArray(value)) return [];
  const ids = value.map(String);
  if (typeof warn === "function") {
    for (const id of ids) if (!DEPRECATION_IDS.has(id)) warn(`Invalid deprecation "${id}".`);
  }
  return ids.filter((id) => DEPRECATION_IDS.has(id));
}

// Guard the wasm ABI's older entry point.
//
// `sasso_compile2` has no parameter for this list, so a module that predates
// `sasso_compile3` cannot honour a non-empty one. Failing is the point: this
// option exists because lichess found a deprecation flag that was accepted and
// did nothing (momiji-rs/sasso#24), and quietly dropping the list against a
// stale artifact would rebuild exactly that — a caller asking for silence,
// getting warnings, and nothing anywhere saying why.
//
// An empty list is not a request, so it still falls back: that is every caller
// who never passed the option, and they must keep working against an older
// .wasm. Lives here rather than inline in the loader so it can be tested
// without fabricating a wasm module that lacks the export.
export function ensureSilenceSupported(hasCompile3, silencedLen) {
  if (hasCompile3 || !silencedLen) return;
  throw new Error(
    "sasso: silenceDeprecations needs a wasm module exporting sasso_compile3, " +
      "but this one only has sasso_compile2 — it is older than the option. " +
      "Reinstall sasso so the .wasm and the loader come from the same build.",
  );
}

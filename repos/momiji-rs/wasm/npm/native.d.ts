// sasso/native — same dart-sass *modern* API as the default entry point,
// backed by the native Node addon (per-platform prebuilds installed as
// optionalDependencies; see the README's "Native addon" section). Types are
// re-exported to keep a single source of truth.
//
// Behavioral notes vs the wasm entries:
//   • concurrent async compiles run on OS threads (true multi-core) — there
//     is no engine pool to tune, so `configure()` accepts and ignores
//     `asyncInstances`/`arenaMiB` (wasm-only knobs);
//   • output is byte-identical to the wasm engines (CI-verified).
export * from "./sasso.js";
export { default } from "./sasso.js";

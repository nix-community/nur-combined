# Handoff: wasm async-importer path performance

**Date:** 2026-07-03 · **Machine:** arm64 macOS (Darwin 25.3), Node v22.22.2
**Baseline commit:** `92cd13b` (master; includes the keyframes-parity fix)
**Corpus:** `apps/rails` of the manekineko monorepo — `app/javascript/stylesheets/tailwind.scss`,
a 5,051-line Bootstrap→Tailwind compat layer, 36 loaded files, 132 KB expanded output.
Compared against `sass-embedded` 1.93.2 (dart-sass native) under rspack/sass-loader 16.

## TL;DR — read this before optimizing

The original suspicion ("per-import asyncify suspensions make sasso unusably slow in
bundler watch mode") was **measured and refuted**. At steady state, sasso wasm inside
rspack watch is at **parity with sass-embedded** (0.75–0.81 s vs 0.76–0.87 s per rebuild;
sasso's own share is 24–36 ms). An earlier 1.9–4.5 s reading was contamination from a
machine running concurrent `rustc -C lto=fat` fleets (load avg 40–70).

Three real, evidence-backed improvement opportunities remain, ranked by impact:

1. **`asyncLock` serializes all concurrent async compiles** (one asyncify stack).
   Bundlers fan out; 10 concurrent compiles queue behind each other.
2. **The async module is `-Oz` only** — engine is ~3.5× slower than native on the real
   corpus; a speed-variant async build would roughly halve engine time.
3. **`asyncHostFn` always unwinds, even for synchronously-resolving importers**
   (~70 µs × 2 host calls × N files wasted when the chain is sync, e.g. `loadPaths`).

## Evidence

### E1. Suspension cost is micro, not macro

`bench/asyncify/asyncify-bench-one.mjs` — K synthetic `@use` modules, one
(mode, K) per process, median of 50 reps (run on a noisy machine; medians stable,
p90s not trustworthy):

| K (modules) | sync wasm + sync imp | async wasm + sync imp | async wasm + async imp |
|---|---|---|---|
| 0 | 0.009 ms | 0.032 ms | 0.014 ms |
| 50 | 0.65 ms | 1.54 ms | 1.69 ms |
| 200 | 3.96 ms | 7.87 ms | 11.57 ms |

Marginal cost per `@use` (K=10→200 slope): sync ~20 µs, async+sync-imp ~38 µs,
async+async-imp ~56 µs. **Each suspension (unwind + microtask + rewind) costs on the
order of 20–70 µs**, linear in count — no super-linear blowup.

Note the middle column: a **synchronous** importer on the async module pays nearly the
async price. That is finding F3 (always-unwind), see below.

### E2. Real corpus: engine gap is -Oz, not asyncify

`bench/asyncify/real-corpus-bench.mjs` (medians, n=20, per-process):

| Engine | tailwind.scss full compile |
|---|---|
| native CLI, in-process (`--loop 200`) | **4.7 ms** |
| wasm sync module (`compileString`, loadPaths FS chain) | **16.3 ms** |
| wasm async module (`compileStringAsync`, same chain) | **21.6 ms** |

- wasm-vs-native = 16.3 / 4.7 ≈ **3.5×** → the `-Oz` + instrumentation tax (F2).
- async-vs-sync = +5.3 ms for 36 files ≈ 74 host calls ≈ **~70 µs/suspension** (F3),
  consistent with E1.

### E3. In-bundler attribution: the seconds were never sasso's

`bench/asyncify/sasso-instrumented.cjs` wraps the npm API and logs per-compile JSONL
(total / importerMs / engineMs / host-call counts). Wired into rspack via the rails
worktree's `config/webpack/base.js` (`SASSO=1 SASSO_INSTRUMENT=<path>` env hooks).

Steady-state watch rebuild (edit an ERB file → tailwind chunk recompiles):

```
{"api":"compileStringAsync","total":33.7,"importerMs":12.6,"engineMs":21.1,"calls":{"canonicalize":37,"load":37},...}
{"api":"compileStringAsync","total":28,  "importerMs":7.6, "engineMs":20.3, ...}
{"api":"compileStringAsync","total":24.3,"importerMs":4.9, "engineMs":19.4, ...}
```

End-to-end rebuild latency: **0.75–0.81 s with sasso vs 0.76–0.87 s with
sass-embedded** — the other ~0.75 s is Tailwind JIT/PostCSS + rspack, identical in
both. sass-loader's webpack-resolve importers cost 5–15 ms of the 24–36 ms.

### E4. asyncLock queueing under concurrency (the real finding)

Same JSONL during the **cold build** (rspack compiles ~10 sass entries concurrently):

```
{"total":840,   "importerMs":763.3,  "engineMs":76.7,  "calls":{"canonicalize":37,"load":37}, "src":368}
{"total":819.2, "importerMs":0,      "engineMs":819.2, "calls":{}, "src":2940}
{"total":2788.5,"importerMs":1960.9, "engineMs":827.6, "calls":{"canonicalize":14,"load":14}, "src":123}
{"total":2795.8,"importerMs":0,      "engineMs":2795.8,"calls":{}, "src":1058}
```

Rows with `engineMs` ≈ 2.8 s and **zero importer calls** are not compiling — they are
queued behind `asyncLock` (`_loader.mjs:467`, `runAsyncLocked` at `:638-645`). Wall
time per compile inflates ~10× under fan-out. (The rails cold build still lands at
3.85 s vs embedded's 4.09 s only because sass is a small slice of that build; a
sass-heavy project would regress visibly.)

## Code pointers (wasm/npm/_loader.mjs @ 92cd13b)

- `:467` — `asyncLock` (single serialized asyncify stack); `:638-645` `runAsyncLocked`.
- `:472-492` — `asyncHostFn`: on every host call it stashes
  `pendingDelivery = Promise.resolve().then(() => lookup(args))` and calls
  `asyncify_start_unwind` **unconditionally** — no sync fast-path.
- `:543-556` — `compileRawAsync` unwind/rewind drive loop (re-enters `callCompile2`
  per suspension; rewind cost ∝ saved stack depth).
- `:50`, `:531-539` — one 1 MiB asyncify stack struct per (single) instance.
- `wasm/build.sh:56-57, 62-80` — variants; **the async module is asyncify(-Oz size
  build) only**; there is no speed-based async variant.
- Global per-compile state (`asyncChain`, `asyncFunctions`, `asyncLogger`,
  `pendingDelivery`) is module-level — must become per-context for any concurrency fix.

## Suggested fixes, ranked

1. **F1 — concurrent async compiles.** One wasm instance has one asyncify context, so
   either (a) an instance pool (N = min(cpus, 4); note each instance reserves the
   arena — check `sasso_set_arena_bytes` interaction and lazy growth), or (b) keep one
   instance but shrink the critical section. (a) is the honest fix. Acceptance: cold
   build JSONL shows no `engineMs ≫ 100 ms, calls: {}` queue rows; a synthetic
   10-concurrent-compile bench scales.
2. **F2 — speed async variant.** Add `asyncify(-O3)` module (`sasso.speed.async.wasm`)
   and let `sasso/speed`'s async APIs use it (today they share the size async module).
   Expected: engine 21.6 ms → ~10 ms on the corpus. Cost: ~2× module size on the
   speed path only.
3. **F3 — sync-delivery fast path in `asyncHostFn`.** Run `lookup(args)`; if the
   result is not a thenable, encode and deliver immediately (return `rc`) without
   unwinding. Kills all suspensions for sync chains (`loadPaths`, sync importers) and
   E1's middle column collapses onto the left column. ~70 µs × 2N per compile.
   Careful: exceptions from a sync lookup must still map to `rc=-1` delivery.
4. **F4 (bigger hammer, separate track) — native Node addon via `ffi/`** (napi +
   threadsafe callbacks for async importers). Removes asyncify entirely; native 4.7 ms
   class engine. This is the long-term answer if bundler perf ever truly matters.

Non-goals / de-prioritized: batching canonicalize+load into one host call (halves an
already-micro cost); caching canonicalize across compiles (correctness risk vs watch
invalidation; dart-sass doesn't either).

## Repro quickstart

```bash
# micro (per-process isolation matters; check `uptime` first — quiet machine only)
for K in 0 50 200; do for m in sync async-syncimp async-asyncimp; do
  node bench/asyncify/asyncify-bench-one.mjs $m $K; done; done

# real corpus (paths inside point at the manekineko rails worktree)
node bench/asyncify/real-corpus-bench.mjs sync
node bench/asyncify/real-corpus-bench.mjs async

# in-bundler attribution (run from the manekineko rails worktree, apps/rails/)
rm -rf tmp/shakapacker tmp/cache/shakapacker public/packs
SASSO=1 SASSO_INSTRUMENT=~/Projects/rust-sass/bench/asyncify/sasso-instrumented.cjs \
SASSO_LOG=/tmp/sasso-timings.jsonl \
  bin/shakapacker --watch   # then edit an ERB under app/views and read the JSONL
```

The rails-side `SASSO=1` hook lives (uncommitted) in the manekineko worktree at
`apps/rails/config/webpack/base.js` — search for `BENCH: SASSO=1`.

## Known unrelated skew

`parity_at_rule_prelude_interpolation` fails against dart-sass **1.93.2** (`\#{` escape
in unknown at-rule preludes) — sasso targets 1.101 behavior. Version skew, not a bug;
irrelevant to this corpus. Do not "fix" it against 1.93.2.

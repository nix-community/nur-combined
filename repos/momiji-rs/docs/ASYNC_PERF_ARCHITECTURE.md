# Async-path performance: architecture plan & measurement harness

**Status:** F1/F2/F3 LANDED (§10) · F4 LANDED in-repo (§11) · **Baseline:** `92cd13b` + harness
**Prerequisite reading:** `docs/HANDOFF_ASYNC_IMPORTER_PERF.md` (the evidence: E1–E4, fix
ranking F1–F4). This doc turns that handoff into concrete designs plus a reproducible
harness (`bench/asyncify/`) whose metrics double as each fix's acceptance criteria.
Landed as `d48296d` (F2), `922b2d2` (F3), `34e2a4e` (F1); measured outcomes in §10.

## 1. Where the time actually goes (recap, one paragraph)

Asyncify suspensions are micro (20–70 µs each, linear); the engine gap on real corpora is
the `-Oz`-only async module (~3.5× native); and the one genuinely pathological behavior is
`asyncLock` serializing all concurrent async compiles — a 10-entry bundler cold build
queues single compiles up to ~10× their true wall time. Steady-state watch rebuilds are
already at parity with sass-embedded. So: fix concurrency (F1), fix the module variant
(F2), stop paying for suspensions nobody needs (F3), and keep the native addon (F4) as the
long-term ceiling-raiser.

## 2. Current architecture (verified facts)

- One `makeApi(syncWasmUrl, asyncWasmUrl)` closure per npm entry (`sasso`, `sasso/speed`),
  holding **singleton slots** for the async engine: `asyncEx`, `asyncData` (1 MiB asyncify
  stack), `asyncChain`, `asyncFunctions`, `asyncLogger`, `pendingDelivery`, `asyncLock`
  (`wasm/npm/_loader.mjs:459-467`). The host import object (`asyncHost`, `:493-526`)
  closes over those slots, so it is physically bound to the one instance.
- Wasm memory is **exported, not imported** (`ex.memory`), so every instance is naturally
  isolated; nothing wasm-side blocks multiple instances. The wasm-side per-instance state
  is the bump arena (`sasso_set_arena_bytes`, frozen after first compile) and the
  custom-function registry (`FUNCTIONS` thread-local, `wasm/src/lib.rs:134-136`) — the
  registry is exactly why interleaving two compiles on *one* instance is unsafe, i.e. why
  `asyncLock` exists.
- The asyncify protocol is driven entirely from JS: `asyncHostFn` (`:472-491`)
  unconditionally `asyncify_start_unwind`s on every host call; `compileRawAsync`
  (`:544-557`) re-enters `sasso_compile2` per suspension. Rust consumes each host rc with
  a plain synchronous match and has **zero awareness of suspension** — binaryen's asyncify
  explicitly supports imports that only *sometimes* unwind. rc contract: `1` = delivered,
  `0` = miss (canonicalize/load) **but error for `host_call_function`**, `<0` = error.
- The importer chain always promotes results to Promises in async mode (`settle()` in
  `_importer.mjs:235-239`; `buildChain`'s `async` functions in `_loader.mjs:148-167`), so
  even a `loadPaths`-only compile suspends on every host call today.
- Build variants (`wasm/build.sh`): sync size (`-Oz`), sync speed (`-O3`), async =
  asyncify(**size** build, `-Oz`). `sasso/speed`'s async APIs run on the size async module
  (`sasso.speed.mjs:11`).

## 3. F1 — replace `asyncLock` with an async-engine pool

### Design

Introduce an `AsyncEngine` record encapsulating everything that is per-instance today but
stored in singleton slots:

```
AsyncEngine {
  ex,               // exports of one instantiation of the (cached) async module
  data,             // its own asyncify stack struct (8B header + 1 MiB)
  ready,            // asyncify_* exports present
  chain, functions, logger, pendingDelivery,   // in-flight compile state
  busy,             // one compile at a time per engine (one asyncify stack each)
}
```

- **Module cached once, instantiated N times.** Cache the `WebAssembly.Module` (today it
  is a local, re-read per instantiation); `new WebAssembly.Instance(module, imports)` per
  engine. Each engine gets its **own host import object** from a factory
  `makeAsyncHost(engine)` — the current `asyncHostFn`/`asyncHost` code moves inside the
  factory with `engine.*` replacing the closure singletons. `_loader.mjs` diff is mostly
  mechanical renames.
- **Pool policy:** lazy growth. First async compile creates engine #1 (identical memory
  behavior to today). A compile arriving while all engines are busy creates a new engine
  up to `maxEngines`, then waits on a FIFO queue. Default
  `maxEngines = min(4, os.availableParallelism())`, configurable via
  `configure({ asyncInstances })`. `configure({ arenaMiB })` iterates live engines and
  applies to future ones (extend `_loader.mjs:571-579`).
- **Acquire/release** replaces `runAsyncLocked`: `finally { engine.busy = false; wake
  next waiter }` — the release-on-error semantics of the current lock chain
  (`:641-644`) are preserved by the `finally`.
- Per-compile function registration moves to the acquired engine
  (`registerFunctions(engine.ex, options)` … `engine.ex.sasso_clear_functions()`).

### What the win actually is (honesty section)

JS is single-threaded; the pool does **not** buy CPU parallelism inside the engine. The
win is that engine work and importer awaits **overlap across compiles**: today, while
compile A is suspended awaiting webpack's enhanced-resolve (ms-scale), the single engine
sits idle *and locked* — nine other compiles queue behind wall-clock they don't owe.
With N engines, compile B's engine work fills A's await gaps. For importer-latency-
dominated workloads (bundler cold builds) wall time per compile drops toward its true
cost; the handoff's `engineMs=2792ms, calls:{}` queue rows disappear. For pure-CPU
workloads the pool's benefit is bounded (~1 compile's engine time of overlap), which is
fine — that case was never the pathology.

### Cost & risks

| Risk | Mitigation |
|---|---|
| Memory: each engine reserves linear memory (32 MiB arena default) + 1 MiB asyncify stack | Lazy growth (single-compile users never pay), small default cap (4), configurable; document |
| State bleed between engines (chain/logger/functions) | The new `wasm/test.mjs` concurrency-isolation tests (distinct importers/loggers/functions/loadedUrls, N=4) were added *before* the refactor and gate CI |
| `sasso.async.wasm` read + compiled N times | Cache the `WebAssembly.Module`; instantiation is cheap relative to a compile |
| Waiter starvation / unfairness | FIFO queue; `concurrent-bench` reports per-compile wall distribution, not just makespan |

### Acceptance (harness)

- `concurrent-bench.mjs`: at `N=8, delay=2ms`, `serializationFactor` drops from ≈8 (lock
  staircase) to ≈1–2; `queuedCompiles → 0`; `startLag p90` collapses.
- `corpus-bench.mjs --concurrency 8` (realistic multi-entry cold build): same factor drop.
- `wasm/test.mjs` still green (isolation + mixed-outcome tests).

## 4. F3 — sync fast-path in `asyncHostFn` (no unwind for sync-resolving chains)

### Design

Three coordinated changes, all JS-side (wasm side verified safe — the sync module already
runs the exact "import returns final rc" contract):

1. **`_importer.mjs` `settle()`**: in async mode, stop unconditionally promoting to a
   Promise — return the mapped **plain value** when the user importer returned a plain
   value, a Promise only when it returned a thenable. Same for `wrapFileImporter`'s
   `findFileUrl` path. (Sync-mode behavior unchanged.)
2. **`_loader.mjs` `buildChain(options, true)`**: replace the `async
   canonicalize/load` functions with *maybe-async* equivalents — walk the resolver list
   synchronously; if a resolver returns a thenable, return a Promise that awaits it and
   continues the walk; otherwise return the value synchronously. `loadPaths`-only chains
   (the `makeFsImporter` resolver is fully sync) then never produce a Promise.
3. **`asyncHostFn`** grows a third branch (normal-state call):

   ```
   let v; try { v = lookup(args) } catch (e) { deliver(err(e)); return -1 }
   if (isThenable(v)) { pendingDelivery = …; asyncify_start_unwind(engine.data); return 0 }
   if (v == null) return MISS_RC        // 0 for canonicalize/load — NOT call_function
   deliver(encodeOk(v)); return 1       // no unwind: engine proceeds synchronously
   ```

### Correctness constraints (from the wasm-side read)

- **Never** both deliver a final rc and start an unwind in the same call; asyncify state
  must remain `NORMAL` on the fast path. Rust cannot detect a violation — discipline
  lives here.
- The rc=0 asymmetry: `host_call_function` treats 0 as an *error*, so the fast path's
  null handling is per-host-fn (custom functions already throw on null inside `lookup`).
- Sync exceptions from `lookup` must map to `deliver(message); return -1` — the new
  `wasm/test.mjs` sync-throwing-importer tests pin this.
- `deliver()` may grow memory (`sasso_alloc`); it already re-takes views afterwards.
- A fast-path call can be *followed* by a suspending call in the same compile — engine
  exclusivity (F1's `busy`, today's lock) is still required; F3 does not relax it.

### Expected effect & acceptance

- `suspension-bench.mjs`: the `async-syncimp` slope (~38 µs/module) collapses onto the
  `sync` slope (~20 µs/module); `async-fs` (loadPaths chains — every bundler-less user)
  loses **all** suspensions. E2's +5.3 ms async tax on the 36-file corpus → ≈0 for sync
  chains, and even sass-loader chains win on their cache-hit (sync-resolving) calls.
- `wasm/test.mjs` green, including: sync-returning importer on async API equals sync
  result; sync-throw maps to `Exception`.

## 5. F2 — speed-optimized async module

Mechanically small (verified against `build.sh`): parameterize `build_async()` (today
hardcodes the size build's raw artifact and `-Oz`), call it twice —
`(target-size, -Oz) → sasso.async.wasm` and `(target-speed, -O3) →
sasso.speed.async.wasm` (raw speed artifact already exists; **keep the pass order
`--asyncify` before the opt level**, same as today). Then `sasso.speed.mjs:11` points at
the new file; add it to `package.json` `files`. No `_loader.mjs` changes (`makeApi` is
already URL-parameterized).

Cost: ~3.5–4 MB uncompressed module on the **speed entry only** (~1.9× asyncify
multiplier observed on the size build); tarball grows accordingly. Acceptance:
`corpus-bench.mjs` — `sasso-speed-async` median moves from tracking the size async module
(~21.6 ms on the handoff corpus) to ≈ `sasso-speed-sync` × small asyncify tax (~10 ms
class). F3 shrinks the remaining tax further (suspension count → 0 on sync chains).

## 6. F4 — native Node addon (separate track, unchanged priority)

The `ffi/` C ABI is sync-only, and `ffi/poc/` holds Go + Python bindings — no napi
anywhere. The realistic path is **napi-rs binding the core crate directly** (skip the C
ABI), compiles on a worker thread, async JS importers via `ThreadsafeFunction` round-trips
into the main thread (works with the existing sync `Importer` trait). Missing surface
before it can replace the wasm path for Node: source maps, logger/warning channel,
importer chains + FileImporter, per-platform prebuilds. Not scheduled here; the harness is
deliberately engine-agnostic (`--impl <path>`) so the same scenarios score a future addon
against the wasm engines with zero harness changes.

## 7. Landing order

1. **Harness + tests first** (this change): baseline recorded; CI now guards the async
   behaviors the refactors touch (sync-returning/sync-throwing importers on async, async
   loggers, N=4 concurrent isolation, mixed outcomes).
2. **F2** — zero-correctness-risk build change, independently shippable, halves async
   engine time on the speed entry.
3. **F3** — small, self-contained loader/importer change; big per-suspension win for sync
   chains; lands the `asyncHostFn` three-branch shape F1 reuses.
4. **F1** — the structural change (pool), guarded by the new isolation tests; biggest
   real-world payoff (bundler cold builds / fan-out).
5. **F4** — long-term, separate track.

Rationale: rising-risk order, each step independently measurable via `ab-compare.mjs run`
against the pre-step commit (worktree + build + interleaved A/B, see
`bench/asyncify/README.md`).

## 8. Harness ↔ evidence ↔ fix map

| Scenario script | Reproduces | Gates | Primary metric |
|---|---|---|---|
| `concurrent-bench.mjs` | E4 (asyncLock queueing) — deterministic via programmed importer delays | F1 | `serializationFactor` (makespan / solo), `startLag` p90, `queuedCompiles` |
| `suspension-bench.mjs` | E1 (per-suspension cost, middle-column anomaly) | F3 | per-`@use` slope (µs/host-call) per mode |
| `corpus-bench.mjs` | E2 (engine gap on import-heavy corpus; in-repo `bench/corpus/modular/`, 10 entries × ~30+ files) + realistic concurrent cold build | F2, F1 | engine medians + ratio vs `sasso-sync`; concurrency-8 factor |
| `ab-compare.mjs` | — | all | interleaved ABBA paired runs, sign test, "within noise" verdict |
| `sasso-instrumented.cjs` | E3/E4 in a real bundler | F1 | per-compile JSONL now incl. `firstCallMs` (queue-wait signal) |

Measurement discipline (enforced by `lib/harness.mjs`): load guard fails runs on a busy
machine unless `--force` (result tagged); every result JSON carries commit+dirty, node,
CPU, loadavg, and **sha256 of the wasm binaries measured**; one configuration per child
process; stdout is data, stderr is for humans. Programmed-delay serialization factors and
ABBA sign tests remain meaningful on a noisy machine; absolute µs slopes do not — rerun
those quiet.

## 9. Baseline numbers (2026-07-03, load avg 4.5, arm64 macOS, Node v22.22.2)

Full runs recorded under `bench/asyncify/results/*--baseline.json` (gitignored); raw
docs carry commit + wasm sha256 + loadavg. Headline numbers:

**`concurrent--baseline` (E4/F1) — the pathology, deterministic:**

| N | delay | solo ms | serialization× | wall× | startLag p90 | queued |
|---|---|---|---|---|---|---|
| 1 | 2 ms | 54.4 | 1.01 | 1.01 | 0.1 ms | 0/7 |
| 2 | 2 ms | 55.8 | 1.95 | 1.45 | 54.8 ms | 0/14 |
| 4 | 2 ms | 55.1 | 3.98 | 2.48 | 164 ms | 15/28 |
| 8 | 2 ms | 55.4 | **7.89** | 4.42 | **380 ms** | 42/56 |

Serialization factor ≈ N and wall× ≈ (N+1)/2 — the exact FIFO-staircase signature of
`asyncLock`. F1 acceptance: factor → ~1–2, queued → 0.

**`suspension--baseline` (E1/F3) — marginal cost per `@use` (2 host calls):**

| mode | µs/host-call | r² |
|---|---|---|
| sync module | 4.0 | 0.98 |
| async + sync importer | **7.7** | 0.99 |
| async + async importer | 8.8 | 1.00 |

F3 signal: async+sync-importer is **1.90×** the sync slope — pure unwind/rewind waste.
Acceptance: ratio → ~1. (fs-chain modes are fs-cache-dominated; use the in-memory rows
for the F3 verdict.)

**`corpus--baseline` (E2/F2 + realistic fan-out) — in-repo modular corpus (36 files,
103 KB expanded):**

| engine | median | vs sasso-sync |
|---|---|---|
| sasso-sync (size) | 18.0 ms | 1.00× |
| sasso-async (size) | 19.4 ms | 1.08× |
| sasso-speed-sync | 15.2 ms | 0.84× |
| sasso-speed-async (shares size async module) | **21.5 ms** | 1.20× |
| sasso-async @ concurrency 8 | makespan 124 ms, wall/compile 74.8 ms | serialization× **5.56** |

The F2 gap in one row: `sasso-speed-async` is 42% slower than `sasso-speed-sync`
because its async APIs run the `-Oz` module. Acceptance: speed-async → speed-sync ×
small asyncify tax. The concurrency-8 row is the realistic bundler cold-build shape for
F1 (CPU-bound corpus, so post-F1 the factor drops toward the overlap-bound, not 1.0 —
the programmed-delay `concurrent` scenario is the clean F1 verdict).

## 10. Landed results (2026-07-03, idle 16-core x86 Linux, interleaved ABBA + sign test)

All three fixes landed in rising-risk order, each verified against the immediately
preceding commit with `ab-compare.mjs run` (before-impl = HEAD loader + identical
binaries, so each A/B isolates exactly one change):

| Fix | Canonical metric | Before → After | Verdict |
|---|---|---|---|
| **F2** `d48296d` | speed-async corpus median (steady state) | 23.6 → 16.9 ms (−29%) | 6/6 pairs, p=0.031 |
| **F2** | pure-compute (zero-import large.scss, `--no-liftoff`) | 45.5 → 23.0 ms (−50%, 2.0×) | 6/6 pairs |
| **F3** `922b2d2` | suspension async-syncimp K=50 | −9.6% | 6/6 pairs, p=0.031 |
| **F3** | K=200 steady state, vs sync-module 1.77 ms | 2.74 → 2.37 ms; residual gap ≡ instrumentation tax ⇒ **zero suspensions** on sync chains | 3/3 rounds |
| **F1** `34e2a4e` | concurrent N=8, delay=2 ms, K=12 makespan | 500 → 122 ms (−75.6%) | 6/6 pairs, p=0.031 |
| **F1** | full sweep serial-× at delay=2 (N=2/4/8) | 1.95/3.98/7.89 → **1.20/1.05/2.28** | N=8 hits the cap-4 floor (two waves = 2.0) |

Honest residuals:

- **CPU-bound fan-out still serializes** (delay=0 rows stay ≈N; post-F3 a loadPaths
  corpus compile never yields, so corpus@c8 stays ~6×). One JS thread cannot
  parallelize engine CPU — the pool buys overlap with *importer latency*, which is the
  real bundler cold-build shape. CPU parallelism is F4's (native addon) territory.
- **v8 tiering discovery (measure this way or get lied to):** short-lived bench
  processes spend most of their time in liftoff-compiled wasm, where `-O3` vs `-Oz`
  module differences *measure at parity* and early-run timings are bimodal. Steady
  state (`node --no-liftoff`, or any long-lived bundler/watch process) is the
  representative regime — F2's 2× only exists there. The suspension/concurrent
  scenarios are delay- or count-dominated and survive tiering; absolute engine medians
  from short default-tiering processes do not.
- The remaining async-vs-sync gap on sync chains is the asyncify instrumentation tax
  on engine code (~+30-50%), not suspensions. Shrinking it means asyncify pass tuning
  (e.g. `asyncify-only-list`) or F4 — both unscheduled.

Test coverage added with the fixes (CI-gated via `wasm/test.mjs`, both variants):
sync-returning/sync-throwing importers on the async API, mixed sync/async chains,
sync FileImporter on async, custom-function fast path + null-is-error, async logger
routing, 4-way concurrent isolation (importers/loggers/functions/loadedUrls), mixed
outcomes under concurrency, pool overlap (deadlocked under the old lock), and
`asyncInstances: 1` queue-and-drain semantics.

## 11. F4 landed: the native addon (in-repo, 2026-07-04)

`napi/` — napi2 addon binding the core crate directly (no wasm, no asyncify, no C ABI).
Architecture: thread-per-async-compile (the core's `Options` is deliberately not `Send` —
each compile builds its whole environment on its own OS thread); user importers / custom
functions / logger cross a ThreadsafeFunction + reply-by-id bridge; **`loadPaths` and
relative resolution run natively** (the core `FsImporter`) with zero JS round-trips. The
JS wrapper (`napi/npm/index.mjs`) reuses `_importer.mjs` (maybe-async user chains),
`_value.mjs` (custom-function byte protocol over a native `valueOp`), and the wasm
loader's `Exception` — one source of truth for API semantics in-repo.

**Correctness:** `napi/test.mjs` asserts **byte-identical CSS vs the wasm engine** (itself
dart-sass-byte-exact via the sass-spec ratchet) across all 10 modular-corpus entries +
handwritten + generated/large, sync/async/compressed/sourceMap, plus loadedUrls and
sourceMap equivalence — and the full behavior-guard set (importer bridging, error
mapping, logger routing, custom functions, 4-thread isolation, true overlap, re-entrant
sync compiles, valueOp engine). CI job `napi` gates all of it on every PR.

**Measured (idle 16-core x86 Linux, interleaved, wasm at `--no-liftoff` steady state):**

| Scenario | native | wasm (post F1-F3) | × |
|---|---|---|---|
| modular corpus, sync median | **6.17 ms** | 18.4 ms | 3.0× |
| modular corpus, async median | **7.3–8.0 ms** | 21.4 ms | ~2.8× |
| **concurrency-8 cold build, makespan** | **9.0 ms** (serial-× 1.14) | 141.8 ms (serial-× 5.84) | **15.7×** |
| concurrent sweep, delay=2 ms serial-× (N=2/4/8) | 1.00 / 1.00 / **1.02** | 1.20 / 1.05 / 2.28 | — |
| concurrent sweep, delay=0 (CPU-bound) serial-× at N=8 | **2.84** | 7.37 | 2.6× |
| bridge cost per host call (async user importer) | ~10.8 µs | ~7.7–11 µs (post-F3 fast path n/a: suspension) | parity |
| fs chain per host call (loadPaths, sync) | **10.8 µs** | 51.7 µs (JS fs) | 4.8× |

The two structural residuals of §10 are both resolved by F4: CPU-bound fan-out now
scales across real threads (2.84× at N=8 instead of ≈N), and the asyncify
instrumentation tax is gone entirely. Thread-per-compile is unbounded by design for
now (bundler fan-outs are ~10s of compiles); a bounded worker pool is a follow-up knob.

**Publish blocker (unchanged):** per-platform prebuilds (napi-rs artifact matrix or
node-gyp-build). Until then the addon is repo-internal: `bash napi/build.sh` then import
`napi/npm/index.mjs` — the bench harness scores it via `--impl` with zero changes.

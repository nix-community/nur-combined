# bench/asyncify — wasm async-importer path benchmarks

Operating manual for the benchmark suite that formalizes
[`docs/HANDOFF_ASYNC_IMPORTER_PERF.md`](../../docs/HANDOFF_ASYNC_IMPORTER_PERF.md).
Read that handoff first: it contains the evidence (E1–E4) these scenarios
reproduce and the fixes (F1–F4) whose acceptance criteria they score.

Everything here is plain-JS ESM, Node >= 22, zero npm dependencies. Shared
plumbing lives in [`lib/harness.mjs`](lib/harness.mjs).

## What this measures

| Evidence | Scenario | What it shows |
|---|---|---|
| E1 — suspension cost is micro, not macro | `suspension-bench.mjs` | per-`@use` marginal cost across (sync module, async module + sync importer, async module + async importer) at several K |
| E2 — engine gap is `-Oz`, not asyncify | `corpus-bench.mjs` | full real-corpus compile time per engine (sasso sync / async / speed variants, native where available) |
| E3 — in-bundler attribution | `sasso-instrumented.cjs` | per-compile JSONL (`total` / `importerMs` / `engineMs` / `firstCallMs` / call counts) inside a real bundler |
| E4 — `asyncLock` queueing under fan-out | `concurrent-bench.mjs` | makespan of N concurrent async compiles vs the serialized lower bound |

| Fix | Acceptance metric | Scored by |
|---|---|---|
| F1 — concurrent async compiles (instance pool / smaller critical section) | `concurrent` makespan for the n=8 fan-out drops toward the ideal (serialization factor → ~1); in-bundler JSONL shows no rows with a large-or-null `firstCallMs` and empty `calls` on a cold build | `concurrent-bench.mjs`, `sasso-instrumented.cjs` |
| F2 — speed (`-O3`) asyncify variant | `corpus` `sasso-async` median roughly halves (21.6 ms → ~10 ms class on the handoff corpus) | `corpus-bench.mjs` |
| F3 — sync-delivery fast path in `asyncHostFn` | `suspension` async-module + sync-importer median collapses onto the sync-module median (E1's middle column onto its left column) | `suspension-bench.mjs` |
| F4 — native Node addon (`ffi/`, long-term) | all scenarios re-run unchanged with `--impl` pointing at an addon entry exposing the same modern API | all, via `--impl` |

## Methodology contract

Every scenario script follows the same rules; results that break them are not
comparable.

- **Per-process isolation.** The orchestrator (default mode) spawns ONE child
  process per measurement configuration (same script + `--worker`). JIT and
  wasm-instance state pollutes cross-config numbers; never compare
  configurations measured in a shared process.
- **Load guard.** Orchestrators abort (exit 2) when the 1-minute load average
  exceeds half the cores (override with `--max-load N`). `--force` runs anyway
  and tags the result document's `warnings` — a forced result is a smoke
  signal, not a benchmark. The handoff's original "1.9–4.5 s regression" was
  load-avg-40–70 contamination; the guard exists so that never happens again.
- **stdout is data.** Workers print exactly one JSON object to stdout;
  orchestrators print the final result document to stdout only with `--json`.
  All progress, tables, and warnings go to stderr.
- **Sanity checks.** Every compile output is checked for a known marker in the
  CSS; a mismatch exits 1 loudly. A benchmark that silently compiles the wrong
  thing is worse than none.
- **Results.** Orchestrators write `results/<scenario>--<label>.json`
  (`--label`, defaulting to `<commit>[-dirty]`, so re-runs on the same tree
  overwrite). Documents carry full environment metadata — commit, node,
  machine, loadavg, and sha256 hashes of the wasm binaries next to the impl
  entry, which are the ground truth for *what* was measured. `results/` is
  gitignored.
- **Pluggable engines.** `--impl <path to sasso.mjs>` selects the
  implementation (default: this repo's `wasm/npm/sasso.mjs`). The speed
  variant, when a scenario needs it, is the sibling `sasso.speed.mjs` of the
  impl path.

## Quickstart

```bash
cd <repo root>
uptime   # quiet machine, or the guard will (rightly) refuse

# E1 / F3 — suspension micro-cost
node bench/asyncify/suspension-bench.mjs --quick     # smoke
node bench/asyncify/suspension-bench.mjs             # full grid

# E4 / F1 — concurrent fan-out vs asyncLock
node bench/asyncify/concurrent-bench.mjs --quick
node bench/asyncify/concurrent-bench.mjs

# E2 / F2 — real-corpus engine comparison
node bench/asyncify/corpus-bench.mjs --quick
node bench/asyncify/corpus-bench.mjs

# compare two runs of the same scenario metric-by-metric
node bench/asyncify/ab-compare.mjs diff \
  bench/asyncify/results/corpus--<labelA>.json \
  bench/asyncify/results/corpus--<labelB>.json
```

E3 (in-bundler JSONL) is not a script you run here — wire
`sasso-instrumented.cjs` into a bundler via `SASSO_IMPL` / `SASSO_LOG` (see
its header and the handoff's repro quickstart), then read the JSONL.

## Before/after: benchmarking a fix

Build the baseline in a separate worktree, then let `ab-compare.mjs run`
interleave the two builds (ABBA order per pair) and apply a sign test — this
is the only workflow whose verdict survives a moderately noisy machine.

```bash
REPO=$(pwd)                                # this repo's root

# 1. baseline worktree at the commit you are comparing against
git worktree add ../sasso-baseline 92cd13b
(cd ../sasso-baseline/wasm && bash build.sh)

# 2. build the candidate (your working tree)
(cd wasm && bash build.sh)

# 3. A/B at the scenario's canonical config (here: F1's scenario)
node bench/asyncify/ab-compare.mjs run --scenario concurrent \
  --impl-a ../sasso-baseline/wasm/npm/sasso.mjs \
  --impl-b "$REPO/wasm/npm/sasso.mjs" \
  --label-a baseline-92cd13b --label-b my-fix

# 4. clean up
git worktree remove ../sasso-baseline
```

Scenario → fix mapping for step 3: `concurrent` scores F1,
`corpus` scores F2, `suspension` scores F3. Six pairs is the default;
`--pairs 10` sharpens the sign test (minimum p with n pairs is `2/2^n`).
The verdict is `A faster` / `B faster` only when p <= 0.1 **and** the median
change is >= 2%; otherwise `within noise`. `--quick` shrinks each child's
reps for a fast smoke run — with fewer than 5 pairs the sign test cannot
reach significance, so keep `--pairs` at 6+ for a real verdict.

`ab-compare run` writes `results/ab-<scenario>--<label>.json` and warns when
the two impls have identical wasm hashes (comparing a build to itself).

## Noise discipline

What you may trust on a machine with background load:

- **A/B sign-test verdicts** from `ab-compare run` — interleaved ABBA pairs
  cancel slow drift; the *direction* of a delta survives load, its magnitude
  does not.
- **Programmed-delay serialization factors** (`concurrent-bench.mjs` uses a fixed
  importer delay, so its makespan ratio measures lock behavior, not CPU).
- **Medians of many in-process reps** — as directional signals.

What you may NOT trust under load:

- Absolute microsecond magnitudes and marginal-cost slopes (E1-style
  `linfit` slopes), p90s/maxes, and any single-shot cold-start number.

Default policy: don't benchmark on a loaded machine — the guard aborts, and
`--force` results are tagged so a future reader knows to distrust them.

## Known caveats

- **dart-sass version skew.** `parity_at_rule_prelude_interpolation` fails
  against dart-sass 1.93.2 (`\#{` escapes in unknown at-rule preludes); sasso
  targets 1.101 behavior. Version skew, not a bug — do not "fix" it against
  1.93.2, and expect small output diffs if you compare CSS bytes against an
  old dart.
- **sass-embedded is optional.** Engine comparisons against native dart run
  only where `sass-embedded` is installed; scenarios degrade gracefully
  (skip + note) without it.
- **`firstCallMs: null` is ambiguous in isolation.** In a bundler (sass-loader
  always injects importers) a null/large `firstCallMs` with a big `total`
  means asyncLock queue wait (E4). A `loadPaths`-only compile with no injected
  importers is legitimately null.
- **`ab-compare` env metadata.** The result's `env.commit` is this repo's
  HEAD even when `--impl-a` points into a baseline worktree; the per-side wasm
  hashes recorded under `params.a` / `params.b` are the ground truth.

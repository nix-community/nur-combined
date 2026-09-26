# SCSS compiler benchmark harness

Compares SCSS compilers on this machine on two axes that matter:

1. **Process startup cost** — what you pay per invocation when you shell out
   (e.g. `npx sass <file>`) vs running in-process.
2. **Pure compile throughput** — parse → evaluate → serialize, with startup
   removed.

Current engines: **sasso** (this repo's real CLI, in-process throughput via its
own `--loop`/`--no-css` flags), **dart-sass** (`npx sass` + the cached binary),
and **grass** (Rust, in-process via `grass_runner`).

Latest results: [`three_way.md`](./three_way.md) (sasso vs dart-sass vs grass).
The older two-way report is [`dart_vs_grass.md`](./dart_vs_grass.md).

A different axis, and the one a person actually feels: [`watch.md`](./watch.md)
measures how long a SAVE takes to become CSS under `--watch`, across the three
ways editors write files. It reports spurious errors beside the milliseconds,
because a watcher that compiles a half-written file looks faster and is worse.

For **why sasso costs what it costs**, rather than how it compares, read
[`perf_audit_2026-09-15.md`](./perf_audit_2026-09-15.md): a stage split of a
compile, the levers with measured deltas, and the dead ends not to re-propose.
Note that `three_way.md`'s 7.4 ms/compile figure is from master `dc5099b`; the
audit reproduced it and then traced a +37.4M-instruction regression to two
merges on 2026-09-15, so today's tree is slower. The plan for recovering it and
gating against a repeat is
[`../docs/PERF_PLAN_2026-09-16.md`](../docs/PERF_PLAN_2026-09-16.md).

The per-PR CI gate is a different harness: `../benches/compile.rs`, run by
divan under `.github/workflows/codspeed.yml`. Two rules apply there and nowhere
else in this directory. It **must** install `sasso::ScopedAlloc` as its
`#[global_allocator]`, because without it every number measures sasso against
the system malloc — an error that is not a constant offset but inverts the
macOS/Linux ranking. And at least one workload **must** supply a display URL,
because `compile` enables diagnostics only when `options.url` is `Some`, so a
URL-less suite never executes the deprecation path at all. Both were missing
until 2026-09-16; `large_expanded` and `large_expanded_with_url_silent` are a
deliberate pair, and their ratio is the signal.

`corpus/gate/` exists because that suite protected only the shapes that
happened to be in `corpus/generated/`, while three of the improvements in
`../docs/PERF_PLAN_2026-09-16.md` measure ~0.00% there. Landing one and later
regressing it would have looked identical in CI. The first four were verified to
show their lever, byte-identical output in both arms, on macOS/arm64 2026-09-16;
the fifth is coverage rather than a lever, and is explained under the table:

| Corpus | Protects | Delta on this corpus | On `large.scss` |
| --- | --- | --- | --- |
| `gate/legacy_deprecations.scss` | the deprecation path (A1) | **−48.3%** | −17.4% |
| `gate/extend_heavy.scss` | `@extend` (A2) | **−49.7%** | −0.2% |
| `gate/use_graph/entry.scss` | the module cache (A3) | **−39.5%** | −2.1% |
| `gate/use_graph/redundant.scss` | ditto, redundant `@use` | **−42.2%** | — |
| `gate/selector_lists.scss` | `eval_style_rule`'s `share_current == false` branch, and the #119/#120 span mapping | — (coverage, no lever) | — |

All five are compiled through the `diagnostics_live()` helper in
`../benches/compile.rs`, which is the only place the URL-and-silent-handler
pairing lives: a corpus wired up with a bare `Options::default()` would leave
`diag_enabled()` false and protect half of what it was added for. All five also
produce output byte-identical to dart-sass — the first four against 1.103.1
(verified 2026-09-16), `selector_lists.scss` against 1.104.1 (verified
2026-09-19: expanded 76,624 bytes and compressed 70,978 bytes, plus stderr, the
five `bogus-combinators` warnings it prints and the seven its repetition cap
omits) — so the gate measures shapes that are in parity rather than shapes only
sasso accepts. `corpora_still_compile()` runs before divan and asserts the
marker rule `.sasso-gate-corpus` in each — a corpus that stops resolving its
imports would otherwise just report a faster number, which is exactly how three
`@use`-graph measurements in `perf_audit_2026-09-15.md` came to be void.

`selector_lists.scss` (added 2026-09-18) is the one entry whose column reads "—"
on purpose. `share_current == false` is the branch `eval_style_rule` takes when
a rule's selector is a comma list written across lines — the normal shape of
hand-written CSS — and the flags are handed to every descendant, so one such
list puts the rest of the sheet on it. Every corpus above it, and `large.scss`,
contains exactly **zero** of that shape, so work added to the branch was not
merely unmeasured but unmeasurable. The corpus carries 246 multi-line lists,
nested so the inheritance path runs too, and six dropped `> +` rules at the
density a real sheet has them, so the span mapping behind `bogus-combinators` is
visited rather than dominant. No speed claim attaches to it: an ABBA on this
corpus put the two arms inside each other's spread. A corpus that makes a future
regression visible is worth gating even when nothing is trying to make it faster.

One more plan benchmark, `large_expanded_with_map_silent`, arrived on 2026-09-17
without a corpus of its own: it compiles `generated/large.scss` through
`compile_with_source_map`, so its ratio against `large_expanded_with_url_silent`
is the source-map surcharge, in the same way the pair above measures the
diagnostics surcharge. It deliberately does not serialize the map to JSON, which
is string escaping rather than mapping arithmetic.

One limit those deltas do not show. CodSpeed's simulation mode counts
instructions, and the first CI run put the `@use`-graph benchmarks at 6.7 ms
simulated against 3.5 ms of wall time here, where
`large_expanded_with_url_silent` is 71 ms simulated against 9.4 ms — about four
times less instruction work per unit of wall time. Import resolution spends much
of its time in the kernel, which instruction counting cannot see, so a lever that
saves syscalls will read smaller in CI than it does locally. That is the same
caveat the plan's B3 records for A3; the corpus is still worth gating, but read
its CI number as a floor.

The landed lever then measured exactly that. On the `@use` graphs, A3 took
**−13.7%** and **−17.0%** of wall time on Linux/x86_64 while moving instructions
by **−0.9%** and **−1.2%** (2026-09-17), so CodSpeed reported the whole suite
untouched for a change worth a sixth of the clock. "Read it as a floor" is not a
hedge here; on this shape it is a factor of more than ten.

There is also a **real-world corpus** harness in [`real-world/`](./real-world/):
it sparse-clones pinned, vetted, currently-active OSS Sass codebases
(bootstrap, bulma, mastodon, …), verifies output parity against dart-sass, and
benchmarks full CLI invocations with hyperfine. Report:
[`real-world/real_world.md`](./real-world/real_world.md); regenerate with
`node real-world/run.mjs all`.

## Layout

```
bench/
├── README.md                 # this file
├── dart_vs_grass.md          # results report (regenerate after a run)
├── three_way.md              # sasso vs dart-sass vs grass
├── perf_audit_2026-09-15.md  # where a compile's time goes; levers and dead ends
├── corpus/
│   ├── handwritten/
│   │   ├── main.scss         # exercises every requested feature
│   │   └── partials/         # _variables.scss, _mixins.scss (@import targets)
│   ├── generated/large.scss  # big file (gen_corpus.rb), ~26k lines of CSS
│   ├── batch/                # 40 medium generated files (amortized-startup test)
│   ├── modular/              # 51-file @use graph (gen_modular_corpus.mjs)
│   └── gate/                 # the CI gate's corpora (gen_gate_corpora.py):
│       ├── legacy_deprecations.scss   #   deprecation-dense (protects A1)
│       ├── extend_heavy.scss          #   @extend-heavy (protects A2)
│       ├── selector_lists.scss        #   multi-line comma lists (coverage corpus)
│       ├── use_graph/                 #   43-file @use graph + a redundant entry
│       └── MANIFEST.json              #   generator version, bytes, sha256
├── grass_runner/             # tiny Rust crate: grass CLI wrapper (build --release)
│   └── src/main.rs
├── scripts/
│   ├── gen_corpus.rb         # corpus generator (deterministic, offline)
│   ├── gen_gate_corpora.py   # the gate corpora; `--check` verifies no drift
│   ├── run_bench.sh          # the harness (hyperfine-driven)
│   ├── normalize_css.sh      # whitespace-only CSS normalizer
│   └── canon_css.py          # + canonicalizes color serialization (rgb<->hex)
└── results/                  # raw hyperfine JSON (git-ignorable)
```

## Prerequisites

- macOS/Linux, `bash`, `python3`, `ruby`
- `cargo` (build the runner)
- `npx` (runs dart-sass; first call downloads it, then it's cached)
- `hyperfine` (recommended). If absent, the harness still works for the grass
  `--loop` numbers; for wall-time you'd fall back to a `date +%s.%N` median loop.

## One-time setup

```bash
cd bench

# 1. Build the grass runner (release — required for fair numbers).
cargo build --release --manifest-path grass_runner/Cargo.toml

# 2. (Re)generate the corpus. Deterministic; safe to re-run.
ruby scripts/gen_corpus.rb 400 corpus/generated/large.scss
for i in $(seq -w 1 40); do ruby scripts/gen_corpus.rb 60 corpus/batch/file_$i.scss; done

# 3. Prime the dart-sass cache (downloads on first use).
npx --yes sass --version
```

`gen_corpus.rb N OUTFILE` emits a self-contained SCSS file with `N` themed
components (default 400). Bigger `N` → more work per compile.

The CI gate's corpora under `corpus/gate/` are checked into git — `benches/compile.rs`
reads them with `include_str!`, so the benchmark must not depend on a generator
having been run — and are regenerated, or verified, with:

```bash
python3 scripts/gen_gate_corpora.py            # rewrite in place
python3 scripts/gen_gate_corpora.py --check     # verify, write nothing (CI-able)
```

Deterministic by construction: no PRNG, no clock, no environment, so
re-running is byte-identical and `--check` exits non-zero only on a hand-edit.
Changing a size constant there changes what CI measures, which resets that
benchmark's CodSpeed history — do it deliberately, in its own commit.

## Run the benchmark

```bash
cd bench
RUNS=15 WARMUP=3 LOOP_N=200 bash scripts/run_bench.sh
```

Knobs (env vars): `RUNS` (timed runs), `WARMUP`, `LOOP_N` (in-process loop count
for grass). It prints hyperfine tables and grass `--loop` throughput, and writes
raw JSON to `results/`. Transcribe the key numbers into `dart_vs_grass.md`.

What it measures:

- **Startup** — compiles a ~empty file; that wall time ≈ pure process startup.
  Reported for grass, the dart-sass bin, and `npx sass` (so the npx tax is visible).
- **Cold single-file** — the large generated file, end-to-end (startup + compile).
- **Amortized batch** — the whole `corpus/batch/` dir in **one** invocation
  (dart-sass `dir:dir`; grass loops over argv), so startup is shared across files.
- **grass pure throughput** — `grass_runner --loop N` recompiles in-process N
  times and divides. For dart-sass, pure compute is derived by amortizing startup
  over K copies in one invocation (see methodology in `dart_vs_grass.md`).

## Correctness check

```bash
cd bench
RUNNER=./grass_runner/target/release/grass_runner
SASS=$(find "$HOME/.npm/_npx" -path '*node_modules/.bin/sass' | head -1)

for f in corpus/handwritten/main.scss corpus/generated/large.scss; do
  $SASS   "$f" 2>/dev/null | python3 scripts/canon_css.py > /tmp/dart.canon
  $RUNNER "$f" 2>/dev/null | python3 scripts/canon_css.py > /tmp/grass.canon
  echo "== $f =="; diff /tmp/dart.canon /tmp/grass.canon | head
done
```

`normalize_css.sh` forgives only whitespace; `canon_css.py` additionally folds
`rgb()`↔hex color serialization (rounding, lowercasing) **without reordering**,
so real structural/value divergences still surface. Known cosmetic differences
between dart-sass 1.100 and grass 0.13 are documented in `dart_vs_grass.md`.

## The grass runner

`grass_runner` (depends only on `grass = { version = "0.13.4", default-features = false }`):

```
grass_runner <file.scss> [more.scss ...]   # compile each once -> stdout
grass_runner --loop N <file.scss>          # compile N times in-process (throughput)
grass_runner --quiet ...                    # suppress CSS stdout (timing-only)
```

`--loop` prints a one-line `ms/compile` + `compiles/sec` summary to **stderr**
and the CSS once to stdout (unless `--quiet`). Exit code non-zero on compile error.

## Adding a third engine

The harness is engine-agnostic. To add `sasso`, provide a CLI that matches the
contract the others use:

> **Contract:** `engine <file.scss>` reads an SCSS path from argv and prints the
> compiled CSS to **stdout**; non-CSS chatter (warnings, timings) goes to
> **stderr**; exit non-zero on error. Optionally support `--loop N <file>` for an
> in-process throughput number, and `--quiet` to suppress stdout.

Then:

1. **Build a runner** the same way `grass_runner` wraps `grass` — a tiny
   `bin` crate depending on the `sasso` library, with `from_path -> String`
   in one-shot mode and an N-iteration `--loop` mode. Build `--release`.

2. **Register it in `scripts/run_bench.sh`.** Add a variable next to `GRASS`:
   ```bash
   RUSTSASS=../target/release/sasso        # or wherever it lands
   ```
   and add a `-n "sasso …" "$RUSTSASS …"` line to each `hyperfine` block
   (startup / cold-large / batch), plus a `$RUSTSASS --loop "$LOOP_N" "$LARGE"`
   call in the throughput section. The corpus and `canon_css.py` correctness step
   need no changes.

3. **Re-run** `bash scripts/run_bench.sh`, add a row to the results table in a new
   report (e.g. `three_way.md`), and run the correctness diff against both
   dart-sass and grass.

Because every engine is just "argv in, CSS on stdout," nothing else in the harness
has to change.

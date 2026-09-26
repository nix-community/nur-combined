# sasso performance audit — 2026-09-15

A 31-agent measurement campaign against master `ad11c61` (sasso 0.9.1),
**primarily on one macOS machine with one toolchain**. Linux was measured for
exactly one lever (4.4, §4.4) during the campaign, and for a whole-compile
cross-machine control afterwards on 2026-09-16
(`docs/PERF_PLAN_2026-09-16.md`, appendix); §7 states that coverage cap in full.
Headline: **the engine's general path is still
close to where the 2026-06-13 refactor campaign left it — but a 7.4 → 10.4 ms
regression landed on 2026-09-15 itself, in two merges, and it is 82% of the
gap.** The largest lever this audit found is therefore not a new optimisation:
it is **recovering a 48-hour-old regression**, byte-exactly, and that lever is
prototyped and measured at **−14.3% instructions**.

> **Metric of record: instructions retired** (`/usr/bin/time -l`), taken as a
> *marginal* per-compile figure — `(I_loop60 − I_loop20) / 40` — which cancels
> ~29M of fixed process startup plus the untimed warm compile. Wall-clock is
> reported where it is the only available signal and is explicitly labelled;
> machine load varied between 4.9 and 70 across the campaign's agents, so wall
> is comparable only *within* one interleaved A/B, never across sections.
> Reproduce commands: [§8](#8-reproduce).

> **Reading rule.** Every *lever delta* below is tagged with how it was
> obtained: `[measured]` = an A/B or instrumented build actually run during
> this audit, `[estimated]` = a model or extrapolation, never run. The tags do
> **not** cover every figure in the document, and an earlier draft of this
> paragraph claimed they did. The headline above, §2's bisect table and the
> secondary effects beside it carry their provenance in prose instead —
> naive loop-20/20 instructions, min-of-3 loop-60 wall, both stated where they
> appear. Read an untagged number as measured-but-uninterleaved: good enough to
> bracket a 15M-instruction step, not to settle a 1% question. Where a prototype
> measured flat, this report says flat. Where two agents disagreed, both
> verdicts are printed, including the dissent. Four of the ten extracted
> levers were **refuted by their own adversarial review** and are marked so.

---

## 1. Current state (verified 2026-09-15, master `ad11c61`, sasso 0.9.1)

### Headline, per workload

All figures `[measured]` this session or by a campaign agent, release build
(`lto="thin"`, `codegen-units=1`, rustc 1.98.1), arm64 macOS 26.3.0.

| Workload | Ms/compile (wall, loop-60) | Instr/compile (marginal) | Peak footprint |
| --- | --- | --- | --- |
| `bench/corpus/generated/large.scss`, expanded | **10.37–10.61** | **153.2–155.0M** | 28.4–30.0 MB |
| same, `--style compressed` | — | **167.5M** | — |
| same, with `--source-map` | — | +25% (real CLI) … +37% (in-process) | +8.0 MB |
| `bench/corpus/handwritten/main.scss` | ~0.27 | **4.38M** | — |
| batch of 40 medium files, one invocation | ~49 (total) | **997.8M** (total) | — |
| `bench/corpus/modular` entry_01 (10-file `@use` graph) | **5.24–5.26** | **72.5–83.0M** | 11.1–14.0 MB |

Max RSS on the large-expanded run is 30.5–32.2 MB; peak *memory footprint* is
the figure quoted above and the one that tracks the arena.

### Stage split

Two independently built instrumented binaries (`SASSO_STOP_AFTER=parse|validate|eval`
early-return differencing, plus a separate `parse_only` / `no_emit` pair) agree:

| Stage | Instr/compile | Share |
| --- | --- | --- |
| parse + scan | 2.45M | **1.6%** |
| eval | ~145.8M | **95.1%** |
| emit | 5.04M | **3.3%** |
| drop / teardown | ~1.5M | ~1% |

`/usr/bin/sample` statistical profiles put emit at 5.1–6.4% and eval at
90.1–91.8%. That is **not a contradiction** — it is an IPC difference. Emit
runs at IPC 2.58 against 4.39 for the compile as a whole, so emit costs more
*wall* per instruction than eval does. Instructions is the A/B metric; samples
are the wall attribution.

**Scan is not a stage.** A 16-second sample profile contains zero
`Scanner::bump` frames, and forcing a full extra scanner pass over
`large.scss` costs 5.9 µs = **0.05%** of a compile.

### Bottleneck verdict

**Eval is the program, and inside eval the single largest *addressable* item is
deprecation-warning bookkeeping on a success compile.** On `large.scss` the
compiler runs ~20,800 deprecation guard probes and ~6,000 `emit_deprecation`
calls per compile, which collapse to 70 distinct dedup keys and **10 printed
warnings** — roughly 99% of the constructed work is discarded. `--quiet` does
not help: the cost is upstream of the print decision.

### Machine load during this session's spot-check

`load averages: 5.89 5.21 6.17` (16 users, 7 days uptime). This matters: see
the reconciliation note immediately below.

### Which metric is noise-immune — and its actual limit

Marginal instructions retired is the noise-immune metric, but **this audit
measured its reproducibility to be ~0.2% within a measurement window and ~1.0%
across windows**, not the ~0.1% the project's method note claims. Concretely,
the spot-check for this report:

| Run | loop-60 instr | loop-20 instr | Marginal | Peak footprint |
| --- | --- | --- | --- | --- |
| Earlier tonight, same binary | 9,383,210,158 | 3,248,314,991 | **153.37M** | 28,361,040 |
| Now, pair 1 | 9,469,886,474 | 3,278,055,771 | **154.80M** | 29,999,440 |
| Now, pair 2 | 9,464,561,300 | 3,277,358,965 | **154.68M** | 29,999,440 / 30,540,112 |
| Now, `proto0-bins/arm0` (same source, different build) | 9,476,058,675 | 3,277,639,353 | **154.96M** | 29,475,152 |

**Discrepancy, reported rather than smoothed over:** the campaign's records
put the baseline at 153.23M / 153.26M / 153.278M / 153.42M; this session
reproduced 153.37M once and then 154.68–154.96M three times across two
different binaries, with peak footprint stepping 28.4 → 29.5–30.0 MB at the
same time. The within-window spread is 0.08–0.2%; the between-window offset is
~1.0%. Redirecting stdout to a file instead of `/dev/null` moves it by only
0.17%, so output plumbing is not the cause; the most likely cause is
allocation/page-fault behaviour changing with machine load, which
`/usr/bin/time -l` counts (it includes kernel-side instructions).

**Consequence for every A/B in this report:** only *interleaved, same-window*
A/B deltas are trustworthy to better than 1%. All four prototypes did run
interleaved passes, and their independent verifiers reproduced them to within
0.05 percentage points, so the deltas stand. But a bare "153.23M" quoted from
one agent and compared against "155.0M" from another is worth nothing, and
no lever below is scored that way.

Two further method corrections worth carrying forward:

- **Naive division is ~6% high.** `I_loop20 / 20` gives 162.4–164.1M, not
  153–155M, because it charges each compile 1/20th of process startup. The
  regression table in [§3](#3-the-regression-question) is internally
  consistent in naive units and labelled as such; do not mix the two scales.
- **Do not write benchmark output to `/tmp` on this machine.** The boot volume
  is ~98% full; one agent measured 21.2 ms ± 1.8 become **32.5 ms ± 17.1**
  purely by moving the output path.

---

## 2. Where the time goes

Inclusive cost by concern. **These are inclusive shares and deliberately sum to
well over 100%** — number formatting is *inside* eval, hashing is inside the
deprecation machinery, and so on. Method is stated per row because the rows do
not share one.

| Concern | Share | Method | Verdict |
| --- | --- | --- | --- |
| Parse + scan (front end) | **1.6%** instr | stage differencing | intrinsic — and scan alone is 0.05% |
| Eval, total | **95.1%** instr | stage differencing | the program |
| └ deprecation machinery | **9.9%** instr (whole `emit_deprecation` body, arm2 `return;` control) · **16–17%** instr (whole feature, incl. guards + eager arg construction) · **19.0%** of wall (sample subtree) | 4 independent A/Bs + a `return;` control + call-graph | **addressable** — largest single item |
| └ number formatting | **8.7%** instr (13.4M) · **14.0%** of wall inclusive | `num_const` / `num_cheap_int` crippled builds + sample | **partly addressable**; only ~1.0M is real digit generation |
| └ selector resolve + normalize (general path) | **8.8%** of wall | sample | intrinsic on the general path; `@extend` is separate — see lever 4.3 |
| └ hashing | **8.84%** of wall (SipHash 5.05% + FxHash 3.79%) | sample | SipHash drops to **0.00%** when deprecation is stubbed → subsumed by the deprecation lever, not a lever of its own |
| └ `Value` clone + drop | **4.05%** of wall (2.05 + 2.00) | sample | intrinsic |
| Arena + allocator + memmove | memmove **10.2–10.4%**, `ScopedAlloc::alloc` **7.74%** (self 6.32%, `_tlv_get_addr` 1.42%), `__rust_dealloc` **1.18%**, `Vec`/`String` regrowth ~**5–6%** net (`finish_grow` 6.09% + `do_reserve_and_handle` 4.75%, overlapping) | sample + allocation counters | **near floor** — the lever is allocation *count*, not allocator speed (see [§5](#5-measured-dead-ends)) |
| Emit | **3.3%** instr / **5.1–6.4%** of samples | stage differencing + sample | intrinsic; the gap is IPC 2.58 vs 4.39 |
| Compressed-style surcharge | **+15.4M** instr (167.5 vs 153.2M, +9.4%) | style A/B | mostly digits and `String` plumbing — see lever 4.6 |
| Source-map surcharge | **+25%** (real CLI) to **+37%** (in-process harness) instr, +8.0 MB peak, IPC 4.68 → 4.31 | axis A/B | `SmCollector::finalize`'s per-char loop is 16.3% of a map run; a bulk-ASCII rewrite removed 10.40M = −20.6% of the surcharge, no-map path unchanged (138.73 vs 138.65M) — **addressable, not deep-dived** |

### The allocation shape, in one paragraph

`large.scss` expanded does **387,321 allocations + 53,539 reallocations =
22.9 MB churned** to produce **521 KB of CSS**. That is 26.9 allocations per
emitted declaration, 44× byte amplification, and **294 instructions per output
byte**. The bump path itself is at floor (~23 instructions per allocation), and
the arena's in-place tail realloc already resizes **88.7% of reallocations
(997,164 of 1,124,432) for free** — total realloc copy volume is only
1.47 MB/compile, about 15 µs of `memmove`. So the diffuse allocation cluster is
real and large, but it is not attackable by tuning the allocator; it would take
a campaign to stop *creating* the objects.

---

## 3. The regression question

`bench/three_way.md` records **7.4 ms/compile** at master `dc5099b`
(2026-06-13). Today the same corpus on the same machine is **10.4–10.6 ms**.
**The regression is real, it is *diagnosed and attributed*, and
`bench/three_way.md` is not stale — it was correct when written.** Diagnosed is
not fixed: today's tree is still at 10.4–10.6 ms, and the recovery is scheduled
as PR 3 of `docs/PERF_PLAN_2026-09-16.md`.

Method: 14 historical commits rebuilt with **one** toolchain (rustc/cargo
1.98.1, `lto="thin"`, `codegen-units=1`), on **one** machine, against **one**
pinned corpus — `shasum` `78d2d586fd7d128c0eb6ff0a6503fd4ad911419f`, verified
byte-identical at `dc5099b` and at HEAD, so the corpus is not a variable.
Instructions below are **naive loop-20/20** (see the scale warning in §1); wall
is min-of-3 loop-60.

| Commit | What | Instr/compile (naive) | Wall (ms) |
| --- | --- | --- | --- |
| `dc5099b` | 2026-06-13, the `three_way.md` baseline | 125.5M | 7.45 |
| `ecb7999` | v0.6.3 | — | 7.18 |
| `a488c20` | v0.7.0 | — | 7.26 |
| `a695ce1` | v0.8.0 | — | 7.60 |
| `c54e6cb` | v0.8.1 | — | 7.58 |
| `878f849` | v0.9.0 | — | 7.86 |
| `461b3d3` | v0.9.1 | 132.1M | 8.02 |
| `d81b88a` | PR #26 | — | 7.68 |
| `3e17e66` | PR #31 | — | 7.81 |
| `c573e24` | PR #36 | 132.8M | 7.98 |
| `1fddec5` | PR #37 | — | 7.92 |
| `0d80ffe` | PR #38 | 132.3M | 7.99 |
| **`465c592`** | **PR #39 `fix/global-builtin-deprecation`** | **147.7M (+15.4M)** | **9.59** |
| **`da6d073`** | **PR #40 `feat/color-functions-deprecation`** | **162.8M (+15.1M)** | **10.33** |
| `ad11c61` | HEAD (PRs #41–#44) | 162.9M (+0.1M) | 10.27 |

### Mechanism

**30.5M of the 37.4M total regression (82%) landed in two merges on
2026-09-15**, both in the deprecation subsystem, and PRs #41–#44 added
+0.1M between them. Two independent methods agree on the size: the bisect
arithmetic gives 30.5/162.9 = **18.7%**, and the sample call graph's
deprecation subtree gives 694/3718 = **18.7%**.

The residual ~6.6M (5%) spread over the preceding 2.5 months was bracketed by
the version tags but **never bisected commit-by-commit** — that is a gap, not
a finding.

Secondary effects: peak footprint rose **24.3 → 28.3 MB**, and wall regressed
*more* than instructions (**+38% vs +30%**), consistent with the new work
being hash- and allocation-heavy rather than straight-line arithmetic.

The lead over `grass` narrowed from ~2.96× to **2.03×** purely because sasso
regressed — `grass` 0.13.4 measured 338.05M instr / 21.95 ms warm, unchanged.

### Justified cost vs waste

This is the important split, and both halves were measured.

- **Justified.** The output is required for dart-sass parity. Migrating
  `large.scss`'s five legacy calls to modern spellings produces **byte-identical
  CSS** and drops the compile from 153.42M to **129.47M** `[measured]` — i.e.
  the whole feature tax is **23.96M = 15.6%**, and it exists because dart-sass
  prints those warnings.
- **Waste.** Of the ~6,000 `emit_deprecation` calls per compile, 70 survive
  deduplication and **10 are printed**. The discarded ~99% is re-rendered
  message text, cloned URL `String`s, eagerly built replacement suggestions,
  and SipHash inserts into the one std `HashSet` on a success compile. A
  constructed-then-discarded warning costs ≈**10,300 instructions**
  `[measured]`. **Lever 4.1 recovers 14.3% of the compile without changing one
  output byte** — that is the waste, quantified.

So: the regression is ~82% two-merge, its *output* is non-negotiable, and ~91%
of the *deprecation feature tax* is recoverable — which is ~72% of the +30.5M
the two merges themselves added. See the denominator note in §4.1.

### The process finding

**Correctness is gated. Performance is not.**

- `.github/workflows/ci.yml` runs, on every `push` to master/main **and every
  `pull_request`**: `cargo fmt --all --check` + `cargo clippy -D warnings` +
  `cargo test --all-features` (line 12), a **dart-sass parity job**
  (`SASSO_PARITY=1 SASS_BIN=sass cargo test --test parity`, line 29), a native
  addon parity job (line 97), and the **sass-spec ratchet**
  (`python3 spec/check_baseline.py`, lines 164–175). Verified by reading the
  file this session. So the exposure from a wrong byte is "CI turns red", not
  "a wrong byte ships" — one campaign agent asserted this against the
  audit's earlier framing and is **correct**.
- `.github/workflows/codspeed.yml` also runs on every PR (`cargo codspeed
  build` + `CodSpeedHQ/action@v4` in `mode: simulation`). But the workflow
  itself declares **no regression threshold** — whether the CodSpeed app is
  configured to fail a PR was not checkable from the repo, so treat the perf
  signal as *reported*, not *enforced*, until someone confirms otherwise.
- Locally, nothing gates it at all: `cargo-codspeed` is **not installed** on
  this machine, and the prebuilt `compile` bench binary (`[[bench]] name =
  "compile", harness = false`, `Cargo.toml:97`) prints its benchmark tree and
  exits 0 without measuring. A contributor cannot notice a +19% day.

**Two merges added ~19% of runtime in one day and every gate stayed green.**
That is the finding; the fix is a threshold, not a rewrite.

---

## 4. Levers

Ranked by measured value on the workload each actually helps. Six levers were
deep-dived; four were prototyped. Every lever carries both adversarial
verdicts, and **four are refuted** — by their own review, not by opinion.

Patch locations are given per lever; all four prototype worktrees were
confirmed present on disk on 2026-09-15 (see [§8](#8-reproduce)).

### 4.1 `dep-no-eager-construction` — don't build a deprecation warning you will throw away

**Status: prototyped, neither verdict refuted it. The largest lever in this
audit.**

*Where.* `src/eval/mod.rs` (`emit_call_deprecations` ~1871, the
`Deprecation::global_builtin` path ~1882–1883, the dedup insert 1955–1962),
`src/builtins/mod.rs:128` (`is_builtin`), `src/builtins/color/deprecate.rs`.

*Measured evidence for the diagnosis.* Four independent A/Bs bracket the area
at 24–26M instructions (16–17%): rewriting the corpus to modern spellings with
byte-identical CSS gives **−23.98M** and **−25.95M**; short-circuiting the code
gives **−26.18M** and **−28.57M**.

*Proposal.* Gate before constructing. Swap `deprecations_seen` to `FxHashSet`;
add a `dep_memo: HashMap<(u32,u32,u32,u32,u64), DepProbe>` fingerprint-and-verify
cache so a repeated call site is answered without re-deriving anything; hoist
`deprecations_live()` above the work; put the gates *before* `is_builtin` and
before `color_function_suggestions`. Adds `deprecates()` to
`builtins/color/deprecate.rs` and `color_function_deprecates()` to
`builtins/mod.rs` so the gate can answer cheaply.

*A/B result `[measured]`.* 3 files, +196/−8.

| Workload | Base | Patched | Delta |
| --- | --- | --- | --- |
| large.scss expanded | 153,421,811 | 131,499,231 | **−14.29%** |
| same, verifier's independent re-run | 153,467,480 | 131,477,382 | **−14.33%** |
| large.scss compressed | — | — | −13.06% |
| batch/file_01 | — | — | −12.71% |
| batch of 40 | — | — | −12.68% |
| handwritten/main.scss | — | — | −5.40% |
| **modular entry_01** | — | — | **+0.03% — FLAT** |
| `/tmp/deplegacy.scss` (legacy-dense) | — | — | **−45.78%** |
| embedder path (`Options::default()`, no url) | 138,750,000 | 127,100,000 | −8.39% |

Wall −15.9 to −21.1%; **peak footprint 28.36 → 25.15 MB (−11.3%)**.

*Which half does the work `[measured]`.* A gates-only variant (no memo) gives
large −3.16%, handwritten −4.11%, deplegacy −8.32%, modular +0.02%. So the
**memo is ~11.1 of the 14.3 points** and the name gate is ~3.2. The lever's own
analysis had the causal story backwards, and the "cheap one-hour subset" it
proposed captures only ~22% of the CLI win.

*Byte-exactness.* ~30,500 A/B pairs: 136 repo files × 3 modes, **all 14,207
sass-spec cases extracted from 3,016 HRX archives**, and 1,916
flag-combination runs over the 604 warning-emitting inputs. Zero real
differences (one nondeterministic thread id in a stack-overflow message in
`libsass-todo-issues/issue_221264`, which differs base-vs-base too).
**`spec/check_baseline.py` did run**: `passing=14061 (pass=11570
error_expected=2491) attempted=14210`, delta +0, ratchet OK; 14,218 cases
compared base-vs-patched with 0 fields differing. `cargo test --release`: **803
passed**.

*Hazards.* The memo key is a fingerprint — a `debug_assert` verify path is
required, and the memo needs a size cap. `deprecates()` / `suggestions()` can
drift from the real deprecation tables; needs an equivalence test in the shape
of T1.3's. The throwaway `examples/embed_probe.rs` must be dropped before
landing.

*Adversarial verdicts.*
- **attribution — not refuted, but reframed.** Independently measured the
  patched build on *deprecation-free* input (the migrated corpus) at base
  129.47M vs patched 129.65M = **+0.136%, a real small regression**. So "never
  a regression" is measurably false; the memo costs a little where there is
  nothing to memoize. Also: the four −12.7…−14.3% workloads are **one
  `gen_corpus.rb` shape measured four times**, the −45.8% is a saturated
  microbenchmark, and the honest framing is "**recovery of a 48-hour-old
  regression**", not "the largest general-path win".

  *Denominator, stated precisely* — an earlier revision of this paragraph said
  "91% of the regression", which mixed two different denominators. The lever
  recovers **21.92M**. Against the **deprecation feature tax** bracketed by the
  corpus migration (23.96M) that is **91%**; against the **+30.5M the two
  merges actually added** (PR #39 +15.4M, PR #40 +15.1M) it is **~72%**. Use
  whichever you name, and name it.
- **correctness-and-cost — not refuted.** Re-measured −14.33%; modular +0.08%
  flat; audited the prototype's spec JSONs itself and confirmed
  `pass_including_error_expected=14061` matches `spec/BASELINE.json`; ran
  ~3,210 further A/B pairs including 1,033 deprecated-name spec cases × 3 modes
  and 8 hazard fixtures × 6 flag combinations. Revised best case **up** to
  −45.8…−46.1%. Ship conditions: the `debug_assert`, the drift guard, the memo
  cap, drop the probe example, and a comment explaining the `--verbose` bypass
  (the footer at `src/eval/mod.rs:2010` already prints "Run in verbose mode to
  see all warnings." although no such flag exists).

*Risk.* Medium — touches the diagnostics path that dart-sass parity depends on,
but the evidence is the strongest in this audit.

### 4.2 `dep-cheap-dedup-key` — stop cloning the URL into the dedup key

**Status: prototyped, neither verdict refuted it — but it is SUBSUMED by 4.1.
Do not sum them.**

*Where.* `src/eval/mod.rs:1106` (`deprecations_seen` declaration), `:1444`
(init), `:1669` (`diag_enabled()`), `:1955–1962` (dedup key + insert).

*Proposal.* One file, +70/−11 (42 of the 70 inserted lines are comments).
`deprecations_seen` becomes `FxHashSet<(&'static str, String, u32, usize,
usize)>` — an interned `u32` replaces the cloned url `String`; add
`diag_url_ids` + a stampless `intern_current_diag_url()`; add a `gb_seen`
pre-construction gate on the `[global-builtin]` path; hoist `diag_enabled()`
and `quiet_deps`.

*A/B result `[measured]`.*

| Workload | Base | Patched | Delta |
| --- | --- | --- | --- |
| large.scss expanded | 153,278,000 | 140,930,000 | **−8.06%** |
| same, verifier A | 153,397,750 | 141,081,504 | −8.03% |
| same, verifier B | — | — | −8.02% |
| large.scss compressed | 167,534,000 | 155,153,000 | −7.39% |
| handwritten/main.scss | 4,383,000 | 4,091,000 | −6.67% |
| batch of 40 | 997,820,000 | 918,500,000 | −7.95% |
| **modular entry_01** | — | — | **+0.46% — FLAT** (this corpus raises zero deprecations: `gb_seen=0`, 0 stderr bytes) |

Wall 10.705 → 9.711 ms (−9.3%). Instrumented gate counts on `large.scss`:
`gb_seen=6, deprecations_seen=70, diag_url_ids=1, omitted=60`.

*The control that matters.* An **arm2** build with `return;` as the first
statement of `emit_deprecation` measures **138.10M**, so the entire
`emit_deprecation` body is only **15.18M = 9.90%** of a compile — **not** the
16–17% the analysis claimed. The prototype's capture ratio is therefore
12.348/15.180 = **0.813**, outside the pre-stated [0.45, 0.70] acceptance band:
the patch over-performed against a budget that was over-scaled by ~60%.

*Byte-exactness.* 87 inputs × 5 modes = 435 pairs / 870 invocations, comparing
stdout + stderr + exit code: 24,230,447 B of stdout and 987,925 B of stderr,
**0 differences**, run twice. `cargo test --release`: **801 passed, 0 failed,
1 ignored**, including `tests/diagnostics.rs` 34/34 and `tests/parity.rs` 410.
**Skipped:** `spec/check_baseline.py` (the agent reported it unavailable — note
that a sibling agent *did* run it, so this was an agent-local problem, not a
real gap) and the live dart-sass parity arm.

*Process fault, disclosed by the agent itself:* a bad CLI probe overwrote
`bench/corpus/batch/file_02.scss`; it was restored and every number above is
post-restore.

*Adversarial verdicts.*
- **attribution — not refuted, but the denominator is wrong.** Reproduced
  −8.03% and the arm2 control independently. Then measured a **realistic
  whole-process invocation** (`-o out.css --source-map`, warnings to stderr):
  221,904,799 → 210,164,597 = **−5.29%**. So "7–9%" is a bench-harness axis
  figure. Best case revised **down** to 10–15%, *inferred, unmeasured*.
  Residual after the patch ~1.9%.
- **correctness-and-cost — not refuted**, and argues the identity preservation
  is a *proof*, not a sample: the set is never iterated, the `String`→`u32`
  interner is a bijection, `render_header` is injective in `replacement`, and
  both hoisted predicates sit above the gate. Ship conditions: a
  `debug_assert`, a networked spec run, and "stop calling it a general-path
  win".

*Two corrections this lever's review forced on the audit's own premises.*
`src/eval/mod.rs:18` is already `use crate::fxhash::FxHashMap as HashMap;`, so
every scope/module table is **already** FxHash and `deprecations_seen` was the
*only* std-hash container on a success compile — the "SipHash everywhere" lead
was stale, and a full sweep would be worth only 2.98%. And the claim that this
work "refutes the `diag.rs` don't-do entry" is **overstated**: only the ~10
printed blocks reach `diag.rs`, ≈0.5% of a compile. What is genuinely stale in
`docs/REFACTOR_NEXT.md` is the *reason* given ("never on a success compile") —
the deprecation *bookkeeping* in `eval` most certainly runs, 6,000 times.

### 4.3 `extend-store-index-and-ext-breaks-hoist` — index the extend store, hoist `ext_breaks`

**Status: built and measured, neither verdict refuted the lever — but two of
its specific claims are refuted, and one sub-lever is unbuilt. 0% on the
general path; very large on `@extend`-heavy real sheets.**

*Where.* `src/selector/mod.rs` — `extend_to_fixpoint_inner`, `expand_extensions`,
`build_extend_plan` (`src/eval/mod.rs:5692`), `ExtendOrderCtx::rank_for`
(`:5710–5760`).

*What exists.* Not a formal prototype, but the analyze agent **did build it**:
binary at `/Volumes/DevSSD/caches/xt-scratch-target/release/sasso`, differing
from the worktree in exactly one file, `src/selector/mod.rs`, +58/−34.

*A/B result `[measured]`.*

| Workload | Delta (instructions) | Peak footprint |
| --- | --- | --- |
| large.scss (the canonical axis) | **+0.02% / +0.06% — FLAT** | — |
| synthetic `ph_360` | **−71.41%** | 106.9 → 12.9 MB (**−87.9%**) |
| synthetic, 180 / 360 / 720 extends | −61.8% / −71.5% / −76.8% | 396.5 → 29.2 MB at 720 |
| adversarial true-line-break shape | −63.5% | — |
| **tabler** (real-world) | **−29.6%** (23.16G → 16.32G) | 562 → 242 MB |
| **forem** | **−32.5%** | 155.6 → 82.6 MB |
| **bootstrap** | **−13.6%** | 199 → 140 MB |
| bulma | +0.15% | — |
| uswds | +0.62% | — |
| govuk-frontend | −0.69% | — |

All byte-identical CSS. The verifier re-ran the 14,218-case ratchet comparison
plus a byte-level comparison of all 560 `@extend` spec cases × 2 styles
including stderr (1,120 runs, 0 differences).

*Refuted claims.*
- **The named best case (bulma) is falsified** — bulma measures +0.15%. The
  supporting arithmetic was a **misread `stars` column** in
  `bench/real-world/real_world.md:15-18`; the real figures (bulma 21,562 CSS
  lines / 161.6 ms vs bootstrap 11,861 lines / 82.5 ms) are proportional and
  imply nothing.
- **"Fixes the quadratic" is refuted.** Patched growth is still 2.58×/3.02× per
  doubling (exponent ~1.37→1.60) against baseline 3.46×/3.72× (~1.79→1.90).
  This is a **2.6–4.3× constant-factor and memory fix; the asymptote is
  intact.**
- **The extracted recipe for hunk (1) is unsound as written.** A plan-level
  `ext_breaks` map returns true where a substore returns false when one
  extender `Complex` is registered twice with different `extender_breaks`; that
  flag reaches `src/selector/mod.rs:4155` and changes a newline in expanded
  output. The deep dive's substitute — an `FxHashSet` of only the true-flagged
  extenders — is safe. Use that one.
- **Sub-lever (3), the target-simple index, is unbuilt and unmeasured. Do not
  land it on this evidence.**

*Why the bimodality.* 11 of the 21 corpus frameworks contain **zero**
`@extend`. `apply_extends`'s inclusive share is ~58% on tabler against 9.7% on
bulma.

*Verdicts.* Neither lens refuted it; both frame it as a **correctness and
robustness fix with a large memory win on the sheets that hit it**, to land as
(1)+(2)+`Cow` **together with an `@extend` corpus added to `bench/`** so it
never silently regresses. Note this is exactly the case `docs/REFACTOR_NEXT.md`
already carves out: the doctrine says the *general* path has no big lever, and
`@extend` was always the exception.

### 4.4 `module-cache-before-load` — probe the module cache before calling the importer

**Status: REFUTED as a headline lever by `correctness-and-cost`; re-scoped by
`attribution`. Flat on the canonical axis; ~78% of the macOS win is kernel
syscall cost.**

*Where.* `src/eval/modules.rs:694-733` (the unconditional `imp.load(&canon)` at
`:709`, the cache probe at `:805`), `pretty_path` (`:1690`/`:1721`,
`:1812`/`:1841`), `src/eval/mod.rs:1014`/`:1502`.

*Proposal.* Hunk A: restructure so the `module_cache` probe precedes
`imp.load()`. Hunk B: a `cwd_cache: OnceCell<Option<PathBuf>>` on `Evaluator`
so `pretty_path` stops calling `getcwd` per diagnostic.

*A/B result `[measured]`.* 2 files, +57/−22.

| Workload | Delta |
| --- | --- |
| large.scss expanded | **−0.003% — FLAT** (162.32M → 162.32M), exactly as predicted |
| large.scss compressed | −0.08% |
| batch of 40 | +0.02% |
| handwritten/main.scss | −2.94% (**all** of it hunk B) |
| modular entry_01 | −20.3% instr / −31.5% wall (macOS) |
| modular, all 10 | −19.3% (macOS) |
| synthetic f256 / f256_u4 | −41.1% / −53.1% (macOS) |

293 paired invocations, 0 differences. `cargo test --release`: 801 passed.

*Why it is refuted as a headline.* Both verifiers ran the analysis's own
falsifier on **x86_64 Linux** (Arch, rustc 1.98.1):

| | macOS (arm64) | Linux (x86_64) |
| --- | --- | --- |
| modular entry_01, wall | −18.6% | **−4.6% / −4.9%** |
| modular entry_01, instructions | −20.0% | **−0.34% / −0.35%** |
| f256 / f256_u4 | −41.1% / −53.1% | **−13.3% / −27.9%** |
| hunk B alone | −2.94% (handwritten) | **+1.9% min / +0.6% mean ≈ 0** |

**~78% of the macOS win is kernel syscall cost**, which `/usr/bin/time -l`
counts and Linux's `perf` user-space count does not: on this Mac
open+fstat+read+close is 11.3–11.5 µs and `getcwd` is 10.6–19.0 µs, against
3.03 µs and 0.476 µs on Linux. **Hunk B is macOS-only**, so on Linux the whole
portable win sits in the *risky* hunk A.

A realistic control (the 40 batch bodies as partials `@use`-ing a shared
`_tokens` + `_mixins`, with **more** redundancy than the modular corpus: 122
loads, 80 wasted, 42 `getcwd`) measures only **−1.71% instructions / −2.8% wall
on macOS and −1.0% on Linux**, because the saving is a fixed ~150–180k
instructions per graph event while `bench/corpus/modular` does 0.17 ms/file
against bootstrap's ~0.9 ms/file. `[estimated]` Linux real-world:
bootstrap ~−0.8%, bulma ~−0.7%, uswds ~−0.8%, govuk-frontend ~−5%.

*Recommended headline, per the refuting verifier:* "0% single-file; ~5% Linux /
~19% macOS multi-file; up to 28% with redundant `@use`" — **not** the 21–26%
the lever claimed.

*Hazards found.* Behaviour changes: a file readable on the first edge but
unreadable later now succeeds from cache, and napi's `loadedUrls`
(`napi/src/lib.rs:460`, `:604`) goes from per-edge to per-unique-file. The
refuting verifier also found and closed a hazard both prior agents missed:
`--quiet-deps` provenance is recorded in `canonicalize`
(`src/importer.rs:296-298`), not in `load`. Its safety argument is strong: the
`@import` path at `src/eval/mod.rs:1122-1137` **already** probes `import_cache`
before both canonicalize and load, citing dart's `ImportCache`.

### 4.5 `num-format-string-choreography` — one byte buffer instead of a `String` relay

**Status: REFUTED by `attribution`. −4.17% on the generated corpus, 0.0% ±0.25%
on every real sheet measured. `correctness-and-cost` did not refute it but
lists blocking ship conditions.**

*Where.* `src/value.rs:2506` (`fmt_num`), `:2590` (`ecma_shortest`), `:2674`
(`round_decimal_string`), `src/ryu.rs:235` (`format64`).

*Proposal.* 2 files, +151/−4. Add `format64_buf(f, &mut [u8], spare) ->
Option<(len, digit_count, exponent)>` to `ryu.rs`; rename the old `fmt_num`
body to `fmt_num_slow` as a fallback; the new `fmt_num` fills a `[u8;32]`, runs
dart's `_writeRounded` carry **on the byte slice**, and produces one `String`
at the end. Includes the `src/value.rs:2552` `s.remove(0)` one-liner.

*A/B result `[measured]`.*

| Workload | Delta |
| --- | --- |
| large.scss expanded | **−4.17%** (153.265M → 146.874M) |
| large.scss compressed | **−7.40%** (167.491M → 155.102M) |
| handwritten/main.scss | −2.75% |
| modular entry_01 | −2.03% |
| batch of 40 | −2.50% |
| wall | −4.48% / −7.02% |

*Why it is refuted.* The `attribution` verifier reproduced every number
(−4.08% / −7.33% / −2.80%, whole-process −3.85%) and then **found the
real-world corpora already checked out** at
`bench/real-world/repos` in another local checkout, and measured five of them:

| Framework | Delta |
| --- | --- |
| bootstrap, expanded | **+0.05%** (1,155.83M → 1,156.40M) |
| bootstrap, compressed | −0.08% |
| bulma | −0.05% |
| tabler | +0.18% |
| govuk-frontend | +0.04% |
| font-awesome | +0.02% |

Noise band ±0.25%. The cause is literal density: `large.scss` carries **264
numbers longer than 10 decimals per 1,000 output lines**, against bootstrap 39,
tabler 22, grafana 15, govuk 10, bulma 5, wagtail 0.8, reveal.js 0.4,
font-awesome 0. A calibrated model — ~450 instructions per >10-dp fraction,
~40 per other number — puts the whole lever at **~0.3–0.5M instr/compile on
any real sheet**. The verifier's own adversarial short-literal corpus:
**−1.00%**. **Corrected estimate: 0.0% ±0.25% general; −4.08%/−7.33% is a
property of `gen_corpus.rb`, not of the compiler.**

This is a direct vindication of the `docs/REFACTOR_NEXT.md` doctrine line "do
not micro-tune `ryu` / `fmt_num`".

*Byte-exactness (excellent, and worth keeping if the lever is ever revived).*
128 inputs × 2 styles = 256 comparisons, 0 differences; source maps — 12
artefact pairs, both `.css` and `.css.map` byte-identical; md5s
`d4fa66c492cd7ab56a56ca95b4aeb728` (large expanded),
`b0d5bead6fd70e006671c5bc9f3ce018` (large compressed),
`21a6df2434d52a86847019d306a61950` (handwritten). A differential fuzz of
~19.6M formattings, 0 mismatches (the verifier ran a further ~64M and
mutation-tested it). `cargo test --release`: 803 passed. **Skipped:** the spec
ratchet (agent-local unavailability), the real-world corpus (which the verifier
then ran, refuting the lever), codspeed, clippy/fmt.

*Ship conditions from `correctness-and-cost` (which measured −4.14% / −7.53% /
−2.55%, whole-process −3.52%, peak unchanged, and did **not** refute):*
`cargo fmt --all --check` **currently fails** on the diff; the doc comments
contain prototype language ("PROTOTYPE:") and a false claim that
`format64_buf` is "used by the numfmt microbench"; and there is **no permanent
in-tree differential test**, which matters because dart's `_writeRounded` would
then exist in two places.

*Verdict for the project:* do not land this for the general path. If a
string-dense/high-precision workload ever becomes a target, the patch and its
fuzzers are on disk.

### 4.6 `compressed-color-hsl-candidate` — the compressed HSL shortest-form probe

**Status: REFUTED by `attribution`. The proposed mechanism is worth −1.23%, not
the advertised 8–9%, and most of it is subsumed by lever 4.5.**

*Where.* `src/value.rs:1723-1728`, `:1770-1800`, `:1783`, `:1795`.

*Measured evidence.* The compressed surcharge reproduces (expanded
153.13–153.44M, compressed 167.54M, +9.4%). Ablating the whole `if compressed`
HSL block gives 154.98M, so the block is **12.56M = 87% of the surcharge and
7.50% of a compressed compile**.

*Why it is refuted.* The verifier **built the lever's own mechanism** and
measured **165.48M = −2.06M = −1.23%**, md5 unchanged. The block decomposes as:
`srgb_to_hsl` + hue nulling **0.45M (0.27%)**, `format!`/`String` plumbing
**2.06M (1.23%)**, and **digit generation + channel `String`s 10.06M (6.01%)** —
4,236 instructions per contested colour. **The advertised 8–9% is the entire
surcharge, which no mechanism short of not emitting the colours can reach.**
Worse, **1.85M of the advertised win is the `src/value.rs:2552` strip
(−1.10% standalone), which belongs to lever 4.5.** Both patches together
measure 163.69M = −2.30%.

*The other verdict.* `correctness-and-cost` did not refute it but scores it
**−2.28% best case and 0.00% general (exact — both sites sit behind `if
compressed`)**, says **most of the 2.28% is likely subsumed by lever 4.5, so do
not sum them**, and orders the deep dive's Patch 3 `fmt_num_len` length oracle
**killed**: its failure mode is a silently wrong colour at `src/value.rs:1795`.

---

## 5. Measured dead ends

For the project's don't-do list. Every one of these is a number, not an
opinion.

1. **`with_capacity` pre-sizing.** Emit output `String`: **+0.04%**. Per-rule
   `Vec<OutItem>`: **−0.08%**. Both full A/B rebuilds. Reason: the arena's
   in-place tail realloc already resizes **88.7% of reallocations (997,164 of
   1,124,432)** for free, and total realloc copy volume is **1.47 MB/compile**
   (~15 µs of `memmove`). There is nothing to pre-size away.
2. **The obvious `is_builtin` lowercase fix.** Replacing
   `to_ascii_lowercase() + contains` with
   `math::NAMES.iter().any(|n| n.eq_ignore_ascii_case(name))` measures
   **154.47M vs 153.26M = +0.8% SLOWER**. (A `stub_is_builtin` control reads
   −0.9%, but it is confounded — it also removes the call.)
3. **T2.4 borrowed-buffer compressed emit stays closed.** Emit is ~6% of a
   compile in **both** styles; the compressed-vs-expanded emit delta is
   **+0.25% of a compile**; a realistic T2.4 ceiling is **1.61%**. The 2026-06-13
   closure was correct and this audit confirms it against fresh numbers.
4. **Arena tail-free dealloc.** **−13.7% peak memory for +6.6% instructions.**
   It fights the deliberate design: the REGIONS registry exists to keep TLS out
   of `dealloc`, and `_tlv_get_addr` is 90.4% from `alloc`, 9.6% from
   `realloc`, and **0% from `dealloc`** (`src/arena.rs:305-314`).
5. **Disabling the arena.** **280.54M vs 153.26M = +83%.** The bump path
   (~23 instructions per allocation) is at floor. The lever is allocation
   **count**, never allocator speed. And "just reserve a bigger initial arena"
   is moot on native: `set_arena_bytes` is wasm-only.
6. **`fast_math_name`.** The attempted real fix measures **154.47M (+0.8%)**.
7. **The scanner byte-cursor idea is re-confirmed dead.** Scan is **0.05%** of
   a compile and produces zero frames in a 16 s profile. `docs/REFACTOR_NEXT.md`
   was right to defer it and this audit closes it with a number.
8. **Commit `0130919`'s recursive `item_writes_compressed` is not the
   compressed surcharge source** — it costs ~**0.41%** of a compressed compile.
9. **A full SipHash → FxHash sweep is not a lever.** `src/eval/mod.rs:18`
   already aliases `FxHashMap`; the residual sweep is worth **2.98%**, and the
   only std-hash container on a success compile (`deprecations_seen`) is already
   inside lever 4.1/4.2.
10. **`num-format-string-choreography` on real sheets** — see 4.5:
    **0.0% ±0.25%** across bootstrap, bulma, tabler, govuk-frontend and
    font-awesome. Filed here as well as in §4 because it is the sharpest
    "measured flat on reality, −4% on the corpus" result in the audit.

Two method dead ends, equally worth recording:

11. **Never A/B in a shared worktree.** At least three agents observed
    concurrent uncommitted edits to `src/eval/mod.rs`; one agent's first A/B
    silently included them and read **+21%**, nearly publishing a phantom
    regression. Build A/B arms from `git archive HEAD`; per-agent
    `git checkout --` in a shared worktree is unsafe.
12. **Never write benchmark output to `/tmp` on this machine** — 21.2 ms ± 1.8
    became **32.5 ms ± 17.1** (boot volume ~98% full).

---

## 6. How much can this improve, in total

### The budget, reconciled

Of the settled 153.23M baseline (this session's window reads ~154.8M; see the
§1 discrepancy note — use whichever is internally consistent, not a mix):

| Bucket | Instructions | Share | Basis |
| --- | --- | --- | --- |
| (a) Hard floor | ~9–10M | ~6% | parse+scan 2.45M + emit 5.04M + ~1.0M of real digit generation (pinned by `num_const` vs `num_cheap_int` = 0.97M) |
| (b) Near-floor by construction | ~9M | ~6% | 387,321 allocations × ~23 instructions |
| (c) Proven addressable | 24–26M | **16–17%** | the deprecation machinery; **~21.9M measured recovered, byte-verified** (lever 4.1) |
| (d) Bounded addressable | ~13.4M | 8.7% | number-format choreography — but ~0.3–0.5M of it on real sheets (lever 4.5 refuted) |
| (e) Unclassified | **~105–115M** | **69–75%** | genuine expansion work with **no measured lever** |

Plus two axis-only budgets: **~15.4M compressed-only** and **~10.4M
source-map-only** (a `SmCollector::finalize` bulk-ASCII rewrite already
measured −10.40M = −20.6% of the map surcharge, with the no-map path unchanged
at 138.73 vs 138.65M).

**Bucket (e) is not "irreducible" — it is *unattributed*.** No agent found a
lever in it; none proved there is none.

### (a) Measured and available now

| Lever | General path | Best case |
| --- | --- | --- |
| 4.1 `dep-no-eager-construction` | **−14.29%** `[measured]` | −45.8% `[measured]` on legacy-dense input |
| 4.2 `dep-cheap-dedup-key` | −8.06% `[measured]` | **subsumed by 4.1 — worth 0 additional** |
| 4.3 extend store index + `ext_breaks` hoist | **0.00%** `[measured]` | −13.6 / −29.6 / −32.5% `[measured]` on bootstrap / tabler / forem, peak −40 to −88% |
| 4.5 `num-format` | **0.0% ±0.25%** `[measured]` on real sheets | −4.2 / −7.4% `[measured]` on `large.scss` only |
| 4.6 compressed HSL | 0.00% `[measured]`, exact | −1.23% `[measured]`, mostly subsumed by 4.5 |
| 4.4 `module-cache-before-load` | 0.00% `[measured]` single-file | ~−5% Linux / ~−19% macOS multi-file `[measured]`; up to −28% with redundant `@use` |
| source-map `finalize` bulk ASCII | 0.00% `[measured]` (no-map path unchanged) | **−5.5% of a map compile** `[measured]` |

**Overlap, netted out — the arithmetic.** The two deprecation levers do **not**
add. Three independent measurements bound the area:

```
whole-area ceiling, code stub (arm2 return;)      15.18M =  9.90%   [measured]
whole-area ceiling, corpus migration              23.96M = 15.62%   [measured]
whole-feature A/Bs (4 methods)                 24–26M   = 16–17%    [measured]
lever 4.1 recovers                                21.92M = 14.29%   [measured]
lever 4.2 recovers                                12.35M =  8.06%   [measured]
```

4.2's 12.35M is a **subset** of 4.1's 21.92M (both act on the same guard,
construction and dedup path; 4.1's gates strictly dominate 4.2's `gb_seen`
gate, and 4.1's memo replaces 4.2's interner). **The combined figure is
therefore ~14.3%, not ~22%.** The residual after 4.1 is **~2.2–2.5%** — the
difference between 14.29% and the 15.6–17.1% area ceiling — and it is
*not* worth a second patch on this evidence.

Likewise 4.6 is largely inside 4.5 (both patches together: −2.30%, versus
−1.23% and −1.10% apart), and 4.5's compressed win would shrink ~25% if a
`Color::to_css` repr lever ever landed first.

So, for the general path, **the honest available total is one lever: −14.3%**,
taking `large.scss` expanded from ~153.2M to ~131.5M and 10.4–10.6 ms to
~8.7–8.9 ms `[measured]`, with peak footprint 28.4 → 25.2 MB. Adding 4.2 on
top buys ~0. Adding 4.5 buys ~0 on real sheets. Adding 4.3 buys 0 on the
general path and a great deal on `@extend`-heavy ones.

**Best-case workloads, stated per shape** (these do not compose either, since
each names a different corpus):

- legacy-deprecation-dense sheet: **−45.8%** `[measured]`
- `@extend`-heavy real framework (tabler, forem): **−29.6% / −32.5%**
  instructions and **−57% / −47% peak** `[measured]`
- redundant-`@use` multi-file graph on macOS: **−19%** `[measured]`, on Linux
  **~−5%** `[measured]`
- high-precision numeric sheet, compressed: **−7.4%** `[measured]`

### (b) Needs a real campaign

- **Cut allocation count.** 387,321 allocations for 521 KB of output, 26.9 per
  emitted declaration, 44× byte amplification. The allocator is at floor
  (dead end 5); the objects are the problem. `[estimated]` this is where most
  of bucket (e) lives, but **no lever in it was measured**, so no number is
  offered.
- **Source maps.** The +25…37% surcharge with a measured −20.6% already in
  hand from one rewrite, and 16.3% of a map run still in one per-char loop.
- **Deep `@use` graphs.** 256-deep measures **3.7× time and 9.3× peak (691 MB)
  for byte-identical output**. That is a shape, not a corpus artefact.
- **`@extend` asymptote.** Lever 4.3 fixes the constant, not the exponent
  (~1.37→1.60 after, ~1.79→1.90 before); `extend_simple` still measures
  **226.55 ms / 3,362M instr / 1,525.8 MB peak from ~45 KB of source**.

`[estimated]` A defensible engineering target for `large.scss` expanded is
**125–135M** (8.5–9.2 ms) — 4.1 plus disciplined allocation work. The deep
dive's more aggressive framing was 105–120M / 7.4–8.5 ms. The theoretical
10–26M implied by 20–50 instructions per output byte (today: 294) is **not** an
engineering target and should not be quoted as one.

### (c) Irreducible

**~18–19M (12%)** is genuinely hard floor plus near-floor-by-construction:
parse+scan 2.45M, emit 5.04M, ~1.0M of digit generation, ~9M of unavoidable
bump-allocation. Everything above that is either measured-addressable (~26M),
bounded (~13M), or unattributed (~95–115M) — and **only the first of those
three is a promise.**

Also note the yardstick, since it bounds how much this matters: `grass` 0.13.4
measures **338.05M instr / 21.95 ms** warm and 26.8 ms cold; dart-sass 1.101.0
AOT is 83.0 ms cold and ~18.7 ms warm; sasso is **10.8 ms warm / 14.5 ms cold**
even *after* the regression. External controls matched their documented values
(dart cold 83.0 vs 84.5; grass 21.95 vs 21.9), so the harness is sound.

### Does fresh evidence overturn "the general path has no remaining big lever"?

**No — and read the shape of the answer carefully.**

`docs/REFACTOR_NEXT.md` states: *"The general (non-extend) path has no
remaining big lever. Do not micro-tune `ryu` / `fmt_num` / `eval_expr_inner` —
they are intrinsic byte-exact costs."* This audit **confirms both halves**:

- The `fmt_num`/`ryu` clause is now *measured*, not asserted: lever 4.5 rebuilt
  that exact code path with a genuinely better design, produced byte-identical
  output over 256 comparisons and ~84M fuzzed formattings, and measured
  **0.0% ±0.25% on five real frameworks**. The doctrine was right for the right
  reason.
- The `@extend` carve-out is also confirmed, and quantified: −13.6 to −32.5%
  with 40–88% peak-memory reductions on the frameworks that hit it, 0.00% on
  the general path.
- T2.1 / T2.2 / T2.4 all stay closed. T2.4 in particular was re-measured
  against fresh numbers (dead end 3) and its 2026-06-13 closure holds.

**And yet this audit's biggest lever is 14.3%.** The resolution is that
**it is not a general-path optimisation at all — it is a 2026-09-15 regression
recovery.** The doctrine describes the engine as the June campaign left it;
what happened is that two merges added ~19% *outside* that steady state, on the
day of this audit. Recovering it is not evidence the doctrine was wrong. It is
evidence the doctrine needs a companion: **a perf gate, so that "no remaining
big lever" stays a description of the tree rather than of a snapshot.**

One line in `docs/REFACTOR_NEXT.md` *is* now factually stale, and it should be
amended when someone next edits that file: the don't-do entry "**`diag.rs`.**
Error-path only — never on a success compile. No hot-path cost." The
*conclusion* about `diag.rs` itself survives (the ~10 printed blocks are ≈0.5%
of a compile), but the *reason* does not — the deprecation bookkeeping in
`src/eval/mod.rs` runs ~6,000 times on a success compile and is this audit's
top lever.

---

## 7. What was not measured

Stated as caps, not as caveats — each one bounds a claim above.

### Coverage caps

- **6 of 10 extracted levers were deep-dived; 4 were prototyped.** The four
  dropped without a deep dive are `sourcemap-finalize-ascii-bulk` (which
  nevertheless has a **measured −10.40M** from the profiling stage — the
  best-supported unexamined lever in the audit), `env-modules-rc`,
  `diag-source-line-index`, and `importer-canonicalize-memo`.
- **Lever 4.3 was never formally prototyped** — the analyze agent built it, so
  its numbers are real, but it never went through the prototype stage's
  byte-identity and test discipline in the way 4.1 did. Its sub-lever (3)
  (target-simple index) is **unbuilt and unmeasured**.
- **The real-world corpus was not checked out in the audit's own worktree**
  (cloning needs network). Two verifiers found a copy at
  `bench/real-world/repos` in another local checkout and used it — and
  those runs are what refuted lever 4.5 and falsified 4.3's named best case.
  **Any lever whose evidence is only `bench/corpus/generated/large.scss` should
  be assumed corpus-specific until a real framework says otherwise.** That is
  the audit's single most transferable lesson.
- **`spec/check_baseline.py` ran for exactly one prototype** (4.1, 14,210
  cases attempted, delta +0). Two other agents reported it unavailable and
  skipped it; since a sibling agent ran it successfully in the same session,
  those were agent-local failures, not a real tooling gap. **Levers 4.2, 4.4
  and 4.5 have no spec-ratchet evidence.**
- **The live dart-sass parity arm** (`SASSO_PARITY=1 SASS_BIN=sass`) was not
  run for any prototype; `tests/parity.rs`' 410 in-tree cases were.
- **`cargo-codspeed` is not installed** on this machine, so no lever has a
  CodSpeed number.
- **`cargo fmt --all --check` fails on lever 4.5's diff** and was not run for
  the others; `cargo clippy -D warnings` was not run for any prototype.
- **Linux was measured for exactly one lever (4.4)** — and that single
  cross-platform check deflated its headline by ~3×. **No other lever in this
  report has been measured off macOS.** Levers 4.1 and 4.2 are hash- and
  allocation-bound, so they should port; that is `[estimated]`, not measured.
- **Wasm was not measured at all.** Note that it *does* get the arena —
  `wasm/src/lib.rs:39-40` installs `sasso::ScopedAlloc` as the wasm
  `#[global_allocator]` (verified 2026-09-16), so bucket (b) applies there too.
  What is unknown is how the wasm target's own allocator behaviour and lever
  4.1's memo interact, not whether the arena is present. An earlier revision of
  this note claimed the arena was absent; that was wrong.
- **The ~6.6M (5%) residual regression over 2.5 months was bracketed by version
  tag, never bisected commit-by-commit.**
- **The `bench/corpus/modular` figures from three earlier agents are void** —
  blocks 5, 8 and the orchestrator ran it **without `-I
  bench/corpus/modular/vendor`**, i.e. measured a failed compile. Only the
  corrected figures (5.24–5.26 ms / 72.5–83.0M instr / 11.13–14.02 MB) appear
  in this report; if you find modular numbers elsewhere in the evidence set,
  check for the `-I` flag before believing them.
- **`src/eval/modules.rs:199-200`'s claimed iteration-order nondeterminism was
  investigated and is not a live per-process bug** (`use super::*;` makes the
  bare `HashMap` the FxHash alias). It remains a refactor-ordering hazard with
  **zero local corpus coverage**.

### What to run next, in priority order

1. **Land lever 4.1** with its four ship conditions (memo `debug_assert`, size
   cap, `deprecates()`/`suggestions()` drift guard, drop
   `examples/embed_probe.rs`). It is the only measured double-digit general-path
   win and it recovers a two-day-old regression. Gate it on the full ratchet +
   the live dart-sass parity arm + clippy/fmt, and re-measure on Linux.
2. **Add a perf gate.** Either a CodSpeed threshold that actually fails a PR,
   or a `bench/scripts/` instructions-retired ratchet run in CI on
   `large.scss`. A ±3% band would have caught both 2026-09-15 merges. This is
   the highest-value item in the audit that is not a code change.
3. **Add an `@extend` corpus to `bench/`**, then land lever 4.3's hunks (1)
   (using the safe `FxHashSet`-of-true-flags substitute, **not** the plan-level
   map) + (2) + `Cow`. Frame it as the correctness/memory fix it is:
   −13.6 to −32.5% and −40 to −88% peak on the frameworks that hit it.
4. **Prototype `sourcemap-finalize-ascii-bulk` properly.** It already has a
   −10.40M measurement and an unchanged no-map path; it is the cheapest
   remaining measured win.
5. **Re-measure the whole audit on Linux**, at least levers 4.1 and 4.3. Lever
   4.4's ~3× deflation is a warning about how much of a macOS number can be
   kernel time.
6. **Bisect the residual ~6.6M** across the 2.5 months between `dc5099b` and
   `461b3d3`, commit by commit, now that the harness exists.
7. **Then, and only then, consider the allocation-count campaign** — 387,321
   allocations for 521 KB of output. It is where bucket (e) probably lives, and
   nobody has measured a lever in it.

---

## 8. Reproduce

Everything below was run on macOS 26.3.0 (arm64), rustc/cargo
1.98.1, release profile (`lto="thin"`, `codegen-units=1`).

> ⚠️ The boot volume on this machine is nearly full. Point cargo elsewhere
> before building anything, and never write benchmark output to `/tmp`:
> `export CARGO_TARGET_DIR=/Volumes/DevSSD/caches/<your-tag>`.

### The baseline and the metric of record

```bash
# marginal instructions/compile = (I_loop60 - I_loop20) / 40
S=/Volumes/DevSSD/caches/sasso-perf-target/release/sasso
C=bench/corpus/generated/large.scss
/usr/bin/time -l "$S" --loop 60 "$C" 2>&1 >/dev/null | egrep 'instructions retired|peak memory|real'
/usr/bin/time -l "$S" --loop 20 "$C" 2>&1 >/dev/null | egrep 'instructions retired|peak memory|real'
```

Run the pair **interleaved, in one window**, for both arms of any A/B — the
between-window offset is ~1.0% (§1). Naive `I_loop20 / 20` is ~6% high; do not
mix scales.

Wall, for the record: `"$S" --loop 60 "$C" 2>&1 >/dev/null | grep ms/compile`.

### Other axes

```bash
"$S" --style compressed bench/corpus/generated/large.scss     # compressed surcharge
"$S" --source-map -o /Volumes/DevSSD/tmp/out.css "$C"          # source-map surcharge
"$S" bench/corpus/handwritten/main.scss
"$S" -I bench/corpus/modular/vendor bench/corpus/modular/entry_01.scss  # the -I is REQUIRED
```

### Crippled-build differencing (how "how much work" was measured)

The stage split and the deprecation ceiling come from early-return builds, not
from profilers.

> ⚠️ **None of the instrumentation named here exists in the tree.**
> `SASSO_STOP_AFTER` and every named arm were **temporary local patches** made
> for this audit and never committed; the only matches for those strings in the
> repository are in this document (verified 2026-09-16). The commands in this
> section therefore do **not** reproduce the stage split as written — you must
> re-cripple a build first. Each arm is one early `return` or one constant
> substitution, described below so it can be re-derived:

| Arm | What to patch |
| --- | --- |
| `SASSO_STOP_AFTER=parse\|validate\|eval` | an env-gated early return at the end of the named stage in `src/lib.rs`'s compile sequence |
| `parse_only`, `no_emit` | the same, expressed as a compile-time edit instead of an env switch |
| `num_const` / `num_cheap_int` | replace `fmt_num`'s body with a constant / a cheap integer path, to price digit generation |
| `no_deprecation` | early `return` at the top of `emit_call_deprecations` **and** `emit_color_function_deprecation`, i.e. ahead of construction |
| `no_arena` | drop the `#[global_allocator]` from `src/main.rs:40` |
| arm2 control | a bare `return;` as the first statement of `emit_deprecation` — note this sits *after* construction, which is why it brackets a smaller area (9.90%) than the corpus migration (15.62%) |

### Statistical profiling (how "how much wall" was measured)

```bash
/usr/bin/sample <pid> 16 1 -file /Volumes/DevSSD/tmp/prof.txt   # 1 ms interval
```

Remember the IPC caveat: emit runs at IPC 2.58 against 4.39 for the whole
compile, so its sample share (5.1–6.4%) legitimately exceeds its instruction
share (3.3%).

### Where the prototype patches live

> **Salvaged 2026-09-16.** Every path in this section is local to the machine
> the audit ran on, and the `wf_*` worktrees are ephemeral, so all five
> prototypes were extracted to plain patch files against pristine base trees
> before those worktrees could be reaped:
>
> | Patch file under `/Volumes/DevSSD/caches/sasso-proto-salvage/` | Base | Files | sha256 (first 16) |
> | --- | --- | --- | --- |
> | `dep-no-eager-construction.patch` | `42f6db9` | 4, +215/−8 | `47b8eb35ad3aa6d5` |
> | `extend-store-index.patch` | `ad11c61` | 1 (`src/selector/mod.rs`) | `d54f51b29e5ab7ef` |
> | `module-cache-before-load.patch` | `ad11c61` | 2 | `6c8f6a77a3daf970` |
> | `dep-cheap-dedup-key.patch` | `ad11c61` | 1 | `8a2aa7d7dfbdc367` |
> | `num-format-choreography.patch` | `ad11c61` | 2 | `505bc618723d88a9` |
>
> The matching pristine trees are `base-42f6db9/` and `base-ad11c61/` in the
> same directory (`git archive <rev> src examples Cargo.toml`), so each patch
> applies with `patch -p1` after stripping the absolute prefixes. This is still
> one machine's scratch disk, not a durable artefact: the only genuinely durable
> copy of a lever is the PR that lands it.

All four worktrees were **verified present on 2026-09-15**, and still present on
2026-09-16; each holds its patch as uncommitted working-tree changes,
recoverable with `git -C <path> diff`.

| Lever | Worktree | Branch tip | Note |
| --- | --- | --- | --- |
| 4.2 `dep-cheap-dedup-key` | `<repo>/.claude/worktrees/wf_c383f781-ba0-16` | `ad11c61` | patch also at `/Volumes/DevSSD/caches/proto0-bins/arm1.patch`; binaries `arm0` (base), `arm1` (patched), `arm2` (`return;` control) in the same directory |
| 4.5 `num-format-string-choreography` | `<repo>/.claude/worktrees/wf_c383f781-ba0-19` | `ad11c61` | `git diff` there is byte-identical to `/tmp/numfmt_prototype.diff`; durable copies + fuzzers at `/Volumes/DevSSD/caches/sasso-perf-proto-2/` (`numfmt_prototype_plus_fuzz.diff`, `fuzz_mod.rs`, `fuzz2.rs`, `base-sasso`, `proto-sasso`) |
| 4.4 `module-cache-before-load` | `<repo>/.claude/worktrees/wf_c383f781-ba0-20` | `ad11c61` | — |
| 4.1 `dep-no-eager-construction` | `<repo>/.claude/worktrees/wf_c383f781-ba0-29` | **`42f6db9`** | ⚠️ **one commit newer than `ad11c61`** (`42f6db9` = "Merge pull request #45 from momiji-rs/fix/escaped-selector-chars"): master advanced mid-audit, so this lever's absolute base (153,421,811) is not strictly comparable to the other three (153,26x,xxx). Its A/B arms were interleaved against each other on the *same* base, so the **−14.29% delta stands**; only the absolute numbers need care. Also contains a throwaway `examples/embed_probe.rs` to drop before landing. |

Lever 4.3's build (not a worktree patch) is at
`/Volumes/DevSSD/caches/xt-scratch-target/release/sasso`, from the source tree
`/Volumes/DevSSD/caches/xt-scratch`, differing from `ad11c61` in exactly one file
(`src/selector/mod.rs`, +58/−34 — confirmed 2026-09-16, and salvaged as
`extend-store-index.patch` above).

The legacy-deprecation-dense fixture used for lever 4.1's best case is
`/tmp/deplegacy.scss` — regenerate it rather than trusting `/tmp`.

### Correctness gates (what any of these levers must pass)

```bash
cargo test --release                                  # 801-803 cases
SASSO_PARITY=1 SASS_BIN=sass cargo test --test parity # live dart-sass arm
bash spec/fetch.sh && python3 spec/check_baseline.py  # >=13895 ratchet, needs network
cargo fmt --all --check && cargo clippy --all-targets --all-features -- -D warnings
```

These run in CI on every `push` to master/main and every `pull_request`
(`.github/workflows/ci.yml`), with two differences from the list above: CI runs
`cargo test --all-features` **without** `--release` (`ci.yml:27`, verified
2026-09-16), and the `--release` test run is an extra ship condition a lever
should satisfy locally, not something CI does for you.
`.github/workflows/codspeed.yml` also runs on every PR, but declares no
threshold in the workflow — see the process finding in
[§3](#the-process-finding).

### Full evidence set

The 31 per-agent JSON records are indexed at
`/tmp/sasso_perf_evidence/INDEX.md`, with the merged lever extraction in
`extract_levers.json` and the settled roll-up in `/tmp/sasso_perf_result.json`.
`/tmp` is volatile on this machine — copy them somewhere durable before
relying on them.

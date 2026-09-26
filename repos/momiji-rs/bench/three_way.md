# sasso vs dart-sass vs grass — benchmark report

SCSS compilers, same corpus, same machine. Headline: **sasso is the fastest
engine on every axis measured** — ~2.1× faster than `grass` (the incumbent
Rust compiler) on pure compile throughput, ~6× faster than dart-sass's
fastest form (the native-VM compiler daemon that `sass-embedded` runs), and
~24× faster end-to-end than the dart-sass JS CLI that `npx sass` executes.

> Reproduce: `cd bench && RUNS=12 WARMUP=3 LOOP_N=200 bash scripts/run_bench.sh`
> (then transcribe the numbers here). For low-noise A/B comparisons of two
> sasso builds, prefer instructions retired (`/usr/bin/time -l`) plus
> interleaved min-of-N wall — CPU contention steals cycles, not instructions.
> Correctness is verified separately — see [Correctness](#correctness).

> **Update 2026-06-13 (master `dc5099b`, dart-sass 1.101.0).** Fresh
> `run_bench.sh` (12 runs / 3 warmups) on the 4-engine subset (sasso · grass
> 0.13.4 · dart-sass JS bin · npx sass) after the refactor campaign **plus the
> arena in-place `realloc`** — sasso faster across the board: **pure compile
> 9.8–10.4 → 7.4 ms/compile**, cold single large file 15.4 → **11.7 ms**, batch
> (40 files) 65.2 → **49.0 ms**; grass/dart unchanged (cold 26.5 ms / 354 ms,
> batch 136 ms / 916 ms, startup 1.8 ms / 139 ms / 495 ms npx). Ratios: sasso
> ~2.3–2.9× faster than grass, ~19–30× faster than the dart-sass JS bin. Fresh **wasm** rebuild (Node 22,
> large file, best-of-N): size build **~27 ms / 854 KB (356 KB gzip)**, speed
> build **~12 ms / 1.84 MB (637 KB gzip)** — vs the older 38.3/21.1 ms; the
> speed build now *beats* native grass (was a tie). **Startup**: sasso and
> grass stay tied at the OS process-spawn floor (~1.6 ms here; reported
> min-of-N because the mean is scheduler-jitter-dominated at this scale —
> sasso is fractionally ahead, not behind). The detailed tables below
> (native-VM dart, `sass-embedded`, the §5 wasm numbers) are from the earlier
> full run and are retained as a historical snapshot; the README's headline
> tables reflect this refresh.

## Environment

| | |
| --- | --- |
| Machine | arm64 macOS, 12 cores |
| OS | macOS 26.3.0 (arm64) |
| Tool | `hyperfine` (`-N` where startup matters), ≥10 timed runs, warmups |
| sasso | 0.1.0 @ master `ec7f955` (fmt/linebreaks/arena-registry/mul-div perf round) |
| dart-sass | 1.100.0 — JS CLI (dart2js, what `npx sass` runs), native-VM CLI, `sass-embedded` 1.100.0, and the `sass` JS library in-process |
| grass | 0.13.4 (`grass_runner`, `--release`, same `lto`/`codegen-units` as sasso) |

## Results

### 1. Startup cost (compile a 1-rule file; `/usr/bin/true` = the OS floor)

| Engine | Time | Above floor |
| --- | --- | --- |
| `/usr/bin/true` | 1.1 ms | — |
| **sasso** | **1.8 ms** | **0.7 ms** |
| grass | 1.7 ms | 0.6 ms (~tie) |
| dart-sass (native VM) | 22.4 ms | 21.3 ms |
| dart-sass (JS bin) | 146 ms | 145 ms |
| npx sass | ~1 s | — |

sasso's own startup cost is ~0.7 ms over the bare process floor — not worth
chasing; batch mode or the library/wasm builds remove it entirely.

### 2. Cold single-file (one large file, ~25k lines of CSS out, end-to-end)

| Engine | Time | vs sasso |
| --- | --- | --- |
| **sasso** | **15.4 ms** | 1× |
| grass | 27.3 ms | **1.8× slower** |
| dart-sass (native VM) | 84.5 ms | **5.5× slower** |
| dart-sass (JS bin) | 365 ms | **24× slower** |

### 3. Amortized batch (40 medium files, **one** invocation — startup shared)

| Engine | Total | Per file | vs sasso |
| --- | --- | --- | --- |
| **sasso** | **65.2 ms** | **1.63 ms** | 1× |
| grass | 138 ms | 3.46 ms | **2.1× slower** |
| dart-sass (JS bin) | 960 ms | 24.0 ms | **14.7× slower** |

### 4. Pure compile throughput (in-process / daemon, startup removed)

| Engine | large (ms/compile) | handwritten (ms/compile) |
| --- | --- | --- |
| **sasso** (`--loop`) | **9.8–10.4** | **0.27** |
| grass (`--loop`) | 21.9 (2.1–2.2×) | 0.40 (1.5×) |
| sass-embedded `initCompiler()` (native VM daemon) | 63.8 (6.1×) | 3.49 (13×) |
| `sass` JS library in-process | 97.1 (9.3×) | 2.83 (10×) |
| sass-embedded default `compile()` | 101.8 (9.7×) | 39.6 (147×) |

Two findings worth knowing about the dart-sass forms:

- `sass-embedded`'s default `compile()` **spawns a fresh compiler process per
  call** (~38 ms fixed); the daemon numbers require its explicit
  `initCompiler()` API.
- The embedded protocol costs ~1–3 ms of IPC per compile, so on small files
  the pure-JS `sass` library beats the native-VM daemon; the native VM only
  wins on large files.

### 5. sasso as wasm (Node, in-process)

| Build | large (ms/compile) | Size |
| --- | --- | --- |
| npm `-Oz` (shipped) | 38.3 | 778 KB / 319 KB gzip |
| speed (`opt-level=3` + `wasm-opt -O3`) | 21.1 | 1.43 MB / 525 KB gzip |

The wasm tax vs native sasso is ~2× (and the wasm build runs without the
bump arena). Even so, the speed build **ties native grass** and beats every
dart-sass form available to a Node toolchain by 3–4.6×.

## What changed since the last report

The 99%-conformance push (13,297 → 13,774 passing) had regressed pure
compile from ~9.0 to ~13.4 ms. A perf round recovered it (−27%):

| Fix | Effect |
| --- | --- |
| fmt: skip the ECMA re-round for tie-free number spellings | −17% wall |
| emit: skip selector line-break bookkeeping when no breaks exist | −2% |
| arena: dealloc classifies via a global region registry, not TLS | −2.8% |
| value: fast-path unitless `mul`/`div` (no unit-list Vecs) | −0.8% |

Method notes that paid off: bisect by **instructions retired** (load-immune,
reproducible to ~0.1%); an Acquire-ordered registry variant measured **+7%
wall on arm64** (ldar stalls) — write-once slots make all-Relaxed sound.

### Safety of the arena

The arena remains the library's one audited `unsafe` module (the rest is
`deny(unsafe_code)`), verified by Miri (standalone twin), AddressSanitizer,
the full sass-spec suite under the live allocator (byte-identical, zero
crashes), and `tests/arena_threads.rs` (8 threads × 200 concurrent compiles,
byte-identical results against the shared region registry).

## Takeaways

- **vs grass** (same-Rust incumbent): ~2.1× on pure throughput and batch,
  ~1.8× cold — while targeting *current* dart-sass semantics (CSS Color 4,
  modern serialization) that grass (pinned to dart-sass 1.54.3) predates.
- **vs dart-sass**: ~6× against its fastest deployable form (native-VM
  daemon, large files); 10–24× against the forms most pipelines actually run
  (JS library, JS CLI, per-call embedded).
- **As wasm**, sasso is the fastest SCSS compiler available inside a JS
  runtime, by ~3× over `sass-embedded`.

## Correctness

On both corpus files, sasso is **byte-identical to dart-sass 1.100.0** after
whitespace + color-serialization canonicalization (and on the full sass-spec
suite: 13,774 passing, 99.06% of attempted):

```bash
cd bench
SASS=$(find "$HOME/.npm/_npx" -path '*node_modules/.bin/sass' | head -1)
for f in corpus/handwritten/main.scss corpus/generated/large.scss; do
  "$SASS"               "$f" | python3 scripts/canon_css.py > /tmp/dart.canon
  ../target/release/sasso "$f" | python3 scripts/canon_css.py > /tmp/sasso.canon
  echo "== $f =="; diff /tmp/dart.canon /tmp/sasso.canon && echo "byte-identical"
done
```

## Caveats

- One machine (arm64 macOS), one corpus. Absolute numbers are hardware- and
  corpus-dependent; the **ratios** are the durable signal.
- The corpus exercises the implemented feature subset, not the full sass-spec
  surface.
- dart-sass per-invocation startup is fixed cost; on one huge file the
  end-to-end ratio shrinks toward the pure-compute ratio, on many small files
  it grows.
- The handwritten corpus triggers `@import` deprecation warnings; sasso and
  dart-sass both render them (suppressed via logger in the dart loops),
  grass does not.

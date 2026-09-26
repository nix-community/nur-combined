# Grass Landscape Analysis

> A skeptical, honest survey of `grass` (connorskees/grass, the mature pure-Rust SCSS→CSS
> compiler) — its weaknesses, its strengths, and where a fresh hand-rolled engine
> ("sasso") could realistically do better.
>
> Compiled June 2026. Sources cited inline by issue number + URL. Anything we could
> not verify is explicitly flagged as **[UNVERIFIED]**.

---

## TL;DR

- **grass is good and fast, but frozen behind modern dart-sass.** It targets dart-sass
  **1.54.3** (released mid-2022). The reference implementation is now at **1.101.0**.
  That ~46-minor-version gap is the single biggest opportunity: grass is missing the
  entire **CSS Color Level 4 color model** (color spaces, `color.channel()`, `oklch/lab/lch`,
  fractional/out-of-gamut RGB channels), the new `round($step)` signature, and relative
  color syntax (`hsl(from … )`).
- **grass's last release was v0.13.4 on 2024-08-04** — ~22 months ago as of this writing.
  Commits since are essentially housekeeping (license files, Sept 2024 / July 2025). This
  is a **single-maintainer project (bus factor 1)** in low-power maintenance mode, *not*
  active feature development.
- **Module system (`@use`/`@forward`) is "basic-usage" only.** The maintainer himself
  calls it the project's roughest edge (#19, #77). A concrete cross-file bug — placeholder
  selectors not extendable across `@use` boundaries (#104) — is a real correctness defect
  that hits real projects.
- **Spec coverage claim: 6230/6905 sass-spec tests pass (~90.2%)** as of July 2023, with the
  maintainer asserting most failures are "aesthetic" (comment whitespace, error spans). That
  number predates the new color model, so true parity-with-current-dart-sass is **lower than
  90%** and unmeasured. **[UNVERIFIED for current dart-sass]**.
- **Error-message quality is a genuine weakness** — grass has had multiple
  panic/DoS/OOM bugs in its error-reporting and selector-expansion paths (#116 UTF-8 panic;
  #117/#118/#119 OOM/DoS, recently fixed). A fresh engine built span-first can both avoid
  these and produce strictly better diagnostics.
- **Biggest fresh-engine opportunities (prioritized):** (1) modern color model, (2) a
  correct module system, (3) excellent span-based error messages, (4) byte-exact output
  pinned to a *specific current* dart-sass version, (5) panic-free/fuzz-hardened parser.
- **Don't fool ourselves:** grass already compiles Bootstrap 4/5, Bulma (≤1.0.2), Bourbon
  with byte-accuracy, is ~2x faster than dart-sass, zero-C-dependency, and ships to wasm/npm.
  Matching that bar is the price of entry, not a differentiator.

---

## 1. Known bug clusters (open issues, grouped by theme)

grass currently has **~12 open issues** and ~12+ closed. The open set is small, which
partly reflects low contributor traffic rather than a defect-free compiler. Grouped:

### 1a. Color model / modern color functions (the dominant cluster)
This is where grass is most clearly behind, because it predates dart-sass 1.79.0's color
overhaul.

- **#105 — "Support new color functions"** (opened 2025-02-04). Requests `color.channel()`,
  and the `$space` argument on `color.adjust()` / `color.scale()`. Reporter notes:
  *"Grass can build Bulma 1.0.2 but not 1.0.3 because they use `color.channel()` … and the
  `$space` argument of `color.adjust()` and `color.scale()`."* No maintainer response.
  https://github.com/connorskees/grass/issues/105
- **#107 — "Support relative color expressions"** (opened 2025-02-27). `hsl(from var(--x) h s 90)`
  fails with *"Only 3 elements allowed, but 5 were passed."* No maintainer response.
  https://github.com/connorskees/grass/issues/107
- **#106 — "`round()`: Only 1 argument allowed, but 3 were passed"** (opened 2025-02-18).
  grass lacks the modern `round($strategy, $number, $step)` signature
  (e.g. `round(down, 33.333%, 1px)`). Workaround is `unquote(...)`. No maintainer response.
  https://github.com/connorskees/grass/issues/106

These three are all symptoms of the same root cause: **grass implements the pre-CSS-Color-4
Sass color/number surface.**

### 1b. @extend / cross-file selector handling
- **#104 — "placeholder selectors not extendable when used from other files"**
  (opened 2025-01-05). `@use 'placeholders'; .nav { @extend %awesome; }` silently drops the
  extended styles. This is a **correctness bug, not cosmetic** — output is wrong, not just
  ugly. No maintainer response.
  https://github.com/connorskees/grass/issues/104
- From the **#19 megathread**: *"@extend should not be possible between media query
  boundaries"*, *"!optional in @extend"*. https://github.com/connorskees/grass/issues/19

### 1c. Selector / escaping
- **#113 — "escaped_selector test fails"** (opened 2025-11-17). Expected `.foo { escape: hex; }`
  but grass emits `\.foo, .bar { escape: hex; }` — `.bar` wrongly included; reporter believes
  it's a regression vs. an older dart-sass. No maintainer response.
  https://github.com/connorskees/grass/issues/113

### 1d. Parser robustness / panics & DoS (error-path quality)
This cluster is the most damning for a "production-grade" claim — a compiler should never
panic or OOM on adversarial input.
- **#116 — "Possible Panic via UTF-8 boundary panic in parse-error reporting"** (opened
  2026-06-03, **still open**). When an error span lands mid-multibyte-char, the `codemap`
  crate slices on a non-char-boundary and panics: *"byte index 30 is not a char boundary;
  it is inside 'ٯ'"*. Crashes both CLI and library API on a 35-byte input. No maintainer
  response yet. https://github.com/connorskees/grass/issues/116
- **#119 — "Unbounded @while loop allows trivial DoS via 48-byte SCSS"** (closed 2026-06-04).
- **#118 — "OOM via parent-selector cartesian-product cloning in SelectorList"** (closed 2026-06-04).
- **#117 — "Possible super-linear selector expansion OOM"** (closed 2026-06-04).
  The #117–119 trio was triaged and closed quickly — a positive maintenance signal — but
  their *existence* shows grass's parser/expander was not hardened against hostile input.
  https://github.com/connorskees/grass/issues/117 (and /118, /119)

### 1e. Built-in functions / CSS pass-through edge cases
- **#87 — "Using `auto` keyword with `min` function fails to compile"** (opened 2023-10-30).
  `width: min(200px, auto)` errors with *"auto is not a number"*; same for `100%`/`100vw` in
  some positions. Valid CSS that should pass through is rejected — grass over-eagerly treats
  `min()`/`max()` args as Sass numbers rather than allowing CSS-keyword pass-through. No
  maintainer response. https://github.com/connorskees/grass/issues/87
- From **#19**: `min(1, min(2))`, `min(1, env(--foo))` special-function args,
  `rgba(1, 2, 3 / 4)` slash syntax, angle units to math fns (`math.cos(1grad)`),
  `inspect(...)` paren preservation.

### 1f. Number / math semantics (from #19 megathread)
- *"zero divided by zero panics, but should return NaN"*, *"one divided by zero panics, but
  should return Infinity"*, *"numbers should use fuzzy matching"* (10-dp precision),
  *"non-comparable inverse units"* (`1px / 1em`). These are spec-conformance gaps in
  arithmetic. https://github.com/connorskees/grass/issues/19

### 1g. Missing larger features (from #19)
Indented `.sass` syntax, plain-CSS `@import`, compressed output edge cases, comma-separated
imports, full `@supports` parsing, Unicode ranges (`U+A2??`), media-query merging.
Note: some of these (compressed output, indented syntax) may be partially done since the
megathread is old — **[UNVERIFIED which #19 items remain open]**.

### 1h. Tooling gaps
- **#112 — "watch mode"** (opened 2025-10-13): grass CLI has no `--watch`. dart-sass does.
- **#88 — load_paths with file extensions** (opened 2023-11-23): import-resolution ergonomics.
- **#74 — CommonJS support in the npm package** (opened 2023-04-22): ESM-only npm build.

---

## 2. @use / @forward / module system status

**Status: "basic usage works; advanced usage does not."** This is grass's self-identified
weakest area.

- README (verbatim): *"We support basic usage of these rules, but more advanced features such
  as `@import`ing modules containing `@forward` with prefixes may not behave as expected."*
  https://github.com/connorskees/grass
- **#77 "Towards 1.0"** (opened 2023-05-17, by the maintainer): *"@use and @forward have a
  really surprising amount of depth and complexity,"* with *"a large number of failing spec
  tests"* in this area and *"at least one real project that fails compilation."* Achieving a
  *"feature complete module system"* is listed as core remaining 1.0 work.
  https://github.com/connorskees/grass/issues/77
- **#19** lists `@use`/module-system (MVP) and `@forward` as "Large Features".
  https://github.com/connorskees/grass/issues/19
- **#104** is a concrete, verified cross-file module bug (placeholder `@extend` dropped).

**What's missing / risky in grass's module system:**
- `@forward` with prefixes / `show`/`hide` visibility modifiers under `@import` interop.
- Cross-file `@extend` of placeholders (#104) — broken.
- Configuration (`@use 'x' with (...)`) advanced cases — implied by "large number of failing
  spec tests" but **[UNVERIFIED which exact cases]**.
- Note: grass does **not** implement the newer member-level `@forward ... as prefix-*` plus
  the 1.80 `@import` *deprecation-warning* behavior — but since sasso also won't warn
  unless we choose to, this matters less for output than for tooling parity.

**Implication for sasso:** The module system is *the* place where grass leaves the most
correctness on the table, and it's directly relevant to Jekyll/minima-style multi-file
partials (see §6).

---

## 3. Spec coverage

- **Claimed: 6230 passing / 545 failing / 6905 total ≈ 90.2%** against the official sass-spec
  suite, "as of July 9, 2023" (README).
  https://github.com/connorskees/grass
- The runner is **modified** to ignore warnings and error *spans* (but does include error
  *messages*). So the headline number already excludes two whole categories grass is weak in.
- Maintainer's framing: *"the majority of the failing tests are purely aesthetic, relating to
  whitespace around comments in expanded mode or error messages."* Treat "purely aesthetic"
  skeptically — #104 shows at least some failures are real semantic bugs.

**Where the gaps are (synthesized from #19, #77, README):**
1. The new color model (post-1.79.0) — **entirely absent** and *not counted* in the 90.2%
   because that number predates 1.79.0.
2. `@use`/`@forward` advanced cases.
3. Error message text and spans (excluded from the runner).
4. Loud-comment placement, custom-property whitespace, media-query splitting (cosmetic,
   per #77).
5. Indented syntax / plain-CSS import edge cases.

**Skeptical caveat / [UNVERIFIED]:** The 90.2% is **~3 years stale** and measured against
**dart-sass 1.54.3**, not 1.100.0. Against *current* dart-sass — which added color spaces,
new functions, and stricter behaviors — grass's true pass rate is **lower and unmeasured**.
Do not quote "90%" as current parity.

---

## 4. Maintenance signal

| Signal | Value | Source |
|---|---|---|
| Latest release | **v0.13.4, 2024-08-04** (~22 months ago) | crates.io |
| Prior releases | 0.13.3 (2024-05-19), 0.13.2 (2024-02-07), 0.13.1 (2023-07-17), 0.13.0 (2023-07-09) | crates.io |
| Last commit | ~2025-07-25 ("Add missing license files", #109) — housekeeping, not features | commits/master |
| Open issues | ~12 | github |
| Closed issues | ~12+ | github |
| Bus factor | **1** (connorskees is sole substantive maintainer) | repo/issue authorship |
| Stars / forks | ~587 / ~55 | github |
| Targets dart-sass | **1.54.3** (current upstream: **1.100.0**) | README |

**Reading the tea leaves:**
- **Positive:** When critical security issues landed (the #117/#118/#119 OOM/DoS trio in
  June 2026), the maintainer triaged and closed them within ~a day. So the project is *not
  abandoned* and the maintainer is responsive to severe bugs.
- **Negative:** *Feature* issues (#87 from 2023, #88, #104, #105, #106, #107, #113, #116) sit
  with **zero maintainer responses** for months-to-years. New color-model support has not been
  acknowledged. The 1.54.3 target hasn't moved. Release cadence collapsed after Aug 2024.
- **Net:** grass is in **stable-but-stalled maintenance**, dependent on one person, and is
  **structurally unlikely to catch up to modern dart-sass** without a sustained re-investment
  that there's no current signal of. This is the strategic gap sasso exploits.

---

## 5. Performance

- README/issue claims: grass is **~2x faster than dart-sass** and **~1.7x faster than sassc**.
  https://github.com/connorskees/grass
- #77 notes further perf headroom planned (variable-lookup and builtin-call optimization) —
  i.e., grass is fast but not maximally optimized.
- No open issues complain that grass is *slow*; performance is a grass **strength**, not a
  weakness.
- **[UNVERIFIED]:** The 2x figure is the maintainer's own benchmark with no linked
  reproducible methodology in the sources reviewed. Treat as directionally true (Rust vs.
  Dart-VM startup + native parsing plausibly yields a large constant-factor win, especially on
  small files / cold start) but don't cite a precise multiplier as fact.
- **Implication for sasso:** We must be *at least as fast* as grass to claim the speed
  high-ground. Beating grass meaningfully on hot-loop perf is possible but is **not** the main
  differentiator — correctness/parity-with-current-dart-sass is. Speed is table stakes here.

---

## 6. Differentiation opportunities for sasso (prioritized)

Each item: **what**, **effort**, **does it matter for Jekyll/minima?**

> Context: Jekyll's default theme **minima** is *old-school SCSS* — `@import` partials,
> classic global functions, simple nesting, no `@use`, no modern color functions, no
> `color.channel`. So several "shiny" differentiators below are **low value for minima
> specifically**, even though they're high value for the broader modern-Sass market. This
> distinction is called out per item.

### P0 — Modern dart-sass color model (CSS Color Level 4)
- **What:** Color-space-aware values (srgb, hsl, hwb, lab, lch, oklab, oklch, display-p3,
  xyz…), `color.channel()`, `color.space()`, `color.to-space()`, `color.is-in-gamut()`,
  `color.to-gamut()`, `$space` args on `adjust`/`scale`, relative color syntax
  (`hsl(from … )`), and — critically — **fractional & out-of-gamut RGB channels**. Note the
  emitted form: modern dart-sass outputs `rgb(63.75, 127.5, 191.25)`, **not** a rounded hex.
  This is exactly what grass cannot do (#105, #106, #107).
- **Effort:** **High.** This is the single largest correctness surface and the hardest to get
  byte-exact (gamut mapping math, channel rounding rules, serialization format per space).
- **Jekyll/minima?:** **Low for minima itself** (minima uses hex + `lighten/darken`), **but
  high for "credible dart-sass alternative" market** and for any modern theme. Build it, but
  it's not what unblocks a minima build.

### P1 — Correct module system (`@use` / `@forward`) done right
- **What:** Full `@use … with`, `@forward … show/hide`, `@forward … as prefix-*`, member
  namespacing, configured-module dedup rules, and **cross-file `@extend`/placeholder**
  resolution (fixing grass's #104). Plus `@import` (still needed) with correct ordering.
- **Effort:** **High.** The maintainer's own warning (#77: "surprising amount of depth") is the
  best evidence this is hard. Design it correctly from day one rather than retrofitting.
- **Jekyll/minima?:** **Medium.** minima uses `@import`, not `@use` — so `@import` correctness
  (ordering, partial resolution, `_`-prefix, extension search per #88) is what *actually*
  matters for minima. Full `@use` matters for the broader ecosystem and future-proofing.

### P2 — Best-in-class error messages with spans
- **What:** Rich diagnostics (à la `rustc`/`ariadne`/`miette`): byte-accurate spans, source
  snippets, caret underlines, "did you mean", suggestions. dart-sass already does this well;
  grass explicitly *excludes* error spans from its spec runner and has **panicked** in its
  error path (#116). A span-first architecture both (a) beats grass on DX and (b) structurally
  prevents the #116-class panic.
- **Effort:** **Medium** *if designed in from the start* (carry spans on every token/AST node);
  **High** to retrofit. Strong argument to bake spans into the core types now.
- **Jekyll/minima?:** **Medium.** Minima itself compiles clean, so end users rarely see errors
  — but theme *authors* and our own debugging benefit enormously. Good DX is a marketing win.

### P3 — Deterministic, byte-exact output pinned to a specific current dart-sass version
- **What:** Pick one pinned dart-sass version (e.g. latest 1.x), reproduce its serializer
  *exactly* (comment placement, whitespace, custom-prop preservation, media-query splitting,
  number formatting), and gate CI on byte-diffs against that pinned dart-sass. grass targets a
  3-year-old 1.54.3 and has known cosmetic deviations (#77). "Diff-clean against *current*
  dart-sass" is a concrete, defensible claim grass cannot make.
- **Effort:** **Medium-High** (mostly serializer fidelity + a golden-test harness).
- **Jekyll/minima?:** **High.** Byte-stable output matters for reproducible Jekyll builds and
  for users migrating off dart-sass without diff noise. This is one of the most *practically*
  valuable, minima-relevant differentiators.

### P4 — Panic-free, fuzz-hardened parser (no DoS/OOM on hostile input)
- **What:** No panics, no unbounded recursion/loops, bounded selector expansion, char-boundary-
  safe span slicing. Directly addresses grass's #116/#117/#118/#119. Differential-fuzz against
  dart-sass from day one (which is also on grass's own to-do list, #77).
- **Effort:** **Medium** (mostly discipline: `Result` everywhere, recursion/iteration limits,
  fuzz harness in CI).
- **Jekyll/minima?:** **Low-Medium.** Minima input is trusted, so DoS is moot for a static-site
  build — but robustness is cheap insurance and a credibility signal vs. grass's recent CVE-ish
  bugs.

### P5 — wasm-first / zero-dep / tiny binary
- **What:** First-class wasm target, no C deps, small binary, clean embeddable Rust API.
- **Effort:** **Low-Medium** — *but this is mostly parity, not differentiation:* grass already
  ships to npm/wasm and is zero-C-dep. We can aim for *smaller/cleaner API*, but don't oversell.
- **Jekyll/minima?:** **Low.** Jekyll runs native Ruby/CLI; wasm is irrelevant to that path.

### P6 — Watch mode & modern CLI ergonomics
- **What:** `--watch` (grass lacks it, #112), good `--load-path` resolution incl. extension
  search (#88), source maps, `--style` options.
- **Effort:** **Low** (watch/load-path are well-trodden).
- **Jekyll/minima?:** **Low** for the library path (Jekyll drives compilation itself), but a
  nice-to-have for standalone CLI users.

**Prioritization summary for a "win minima + be a credible dart-sass alternative" goal:**
For minima *specifically*, the high-leverage items are **P3 (byte-exact current output)** and
solid **`@import` resolution (part of P1)** plus legacy global color functions
(`lighten/darken/...`). For the *broader* market and durability, **P0 (color model)** and
**P1 (`@use`)** are the strategic moats grass has structurally failed to cross. **P2/P4** are
cheap-if-designed-in architectural choices that pay off everywhere.

---

## 7. grass's strengths (be honest — this is the bar to clear)

1. **Real-world framework accuracy.** grass compiles **Bootstrap 4 & 5, Bulma (≤1.0.2),
   bulma-scss, Bourbon** and "most other large Sass libraries with complete accuracy," and is
   tested against Bootstrap on **every commit** + the last 2,500 Bootstrap commits per release.
   That's a deep, battle-tested correctness baseline. https://github.com/connorskees/grass
2. **Speed.** ~2x faster than dart-sass, ~1.7x faster than sassc (directional). Fast cold start
   (native binary, no VM). https://github.com/connorskees/grass
3. **~90% sass-spec pass rate** (vs. 1.54.3) with most remaining failures being genuinely
   cosmetic. The *core language* (nesting, mixins, functions, control flow, most built-ins,
   `@extend` basics, math, legacy color functions) is solid.
4. **Mature, stable Rust API** — "no breaking change in well over 2 years" (#77). Predictable
   to depend on.
5. **Zero C dependencies, pure Rust, ships to npm/wasm** (`@connorskees/grass`). Easy to embed.
6. **Responsive to *critical* bugs** — the June 2026 DoS/OOM trio (#117/#118/#119) was fixed in
   ~a day. Not abandoned.
7. **Honest, well-documented limitations** — the README and #19/#77 are refreshingly candid
   about what doesn't work, which makes grass a trustworthy baseline to measure against.

**What this means:** Matching grass on items 1–5 is the **price of entry**, not a selling
point. sasso only "wins" by being demonstrably better on the §6 differentiators —
especially the modern color model, a correct module system, error DX, and byte-exact parity
with a *current* dart-sass — while *not regressing* on grass's framework-accuracy and speed.

---

## Appendix: source index

- grass repo / README — https://github.com/connorskees/grass
- grass open issues — https://github.com/connorskees/grass/issues
- #19 Known Outstanding Issues Megathread — https://github.com/connorskees/grass/issues/19
- #77 Towards 1.0 — https://github.com/connorskees/grass/issues/77
- #87 min() + auto — https://github.com/connorskees/grass/issues/87
- #88 load_paths extensions — https://github.com/connorskees/grass/issues/88
- #104 cross-file placeholder @extend — https://github.com/connorskees/grass/issues/104
- #105 new color functions — https://github.com/connorskees/grass/issues/105
- #106 round() 3-arg — https://github.com/connorskees/grass/issues/106
- #107 relative color expressions — https://github.com/connorskees/grass/issues/107
- #112 watch mode — https://github.com/connorskees/grass/issues/112
- #113 escaped_selector — https://github.com/connorskees/grass/issues/113
- #116 UTF-8 boundary panic — https://github.com/connorskees/grass/issues/116
- #117/#118/#119 OOM/DoS (closed) — https://github.com/connorskees/grass/issues/117
- grass crate versions/dates — https://crates.io/crates/grass
- dart-sass CHANGELOG — https://github.com/sass/dart-sass/blob/main/CHANGELOG.md
- dart-sass 1.79.0 color model / 1.80.0 @import deprecation — sass-lang.com breaking-changes docs
- Sass color docs (fractional rgb examples) — https://sass-lang.com/documentation/values/colors/

**Flagged unverified:** current-dart-sass spec pass rate for grass; exact 2x perf multiplier
methodology; which specific #19 megathread items are still open vs. since-fixed; precise list
of failing `@use` spec cases.

# Custom-functions / `Value` API — dart-sass compatibility gap analysis

> Status: Phase 4 shipped a **working** custom-functions feature in `sasso@0.7.2`;
> the FULL dart-sass `Value` type system + the dart-fidelity polish track are now
> done as of **`sasso@0.7.8`**. This document tracks the path to **100% dart-sass
> JS `Value` API compatibility**, so a custom function written for `sass` runs
> unchanged on `sasso`. (Tier 0–3 + Polish #1–6 below are all ✅.)
>
> Authoritative reference: the dart-sass JS API (`Value`, `SassNumber`,
> `SassColor`, …). Frequency = how often real-world custom functions hit it.

## What works today (`sasso@0.7.8`)

- Value types across the boundary: `null`, `bool`, `SassNumber` (full unit
  lists), `SassString`, `SassColor` (every CSS Color 4 space), `SassList` /
  `SassArgumentList`, `SassMap`.
- Base: `isTruthy`, `realNull`, `asList`, `hasBrackets`, `separator`, `equals`,
  `get(index)` (non-negative), `assertNumber/String/Color/Map/Boolean`.
- `SassNumber`: `value`, `numeratorUnits`, `denominatorUnits`, `hasUnits`,
  `isInt`, `asInt`, `hasUnit`, `assertInt`, `assertUnit`.
- `SassColor`: `space`, `channels`, `channelsOrNull`, `alpha`, `channel(name)`
  (current space), `isChannelMissing`, `red/green/blue`.
- Sync + async callbacks; precedence (user `@function` > custom > builtin); error
  surfacing.

## Gaps, by tier

### TIER 0 — return-type fidelity ✅ DONE (zero-dep shim, `_immutable.mjs`)

`asList`, `numeratorUnits`, `denominatorUnits`, `channels`, `channelsOrNull`,
`SassList` contents and `SassMap.contents` now return the dependency-free
`List`/`OrderedMap` (`_immutable.mjs`) — the common `immutable` read subset
(`get`/`size`/`has`/`keys`/`values`/`forEach`/iterate/`map`/`filter`/`slice`/
`equals`, `toArray`/`toJS` to escape). `SassMap.contents` is value-equality
keyed; the non-standard `SassMap.get(key)` was removed (use
`map.contents.get(key)`, matching dart). Chose the shim over a dependency to keep
the package dep-free; `.toArray()` covers any esoteric `immutable` method.

### TIER 1 — pure-JS methods ✅ DONE (one caveat)

`Value.get()` negative indexing, `sassIndexToListIndex`, `tryMap` (incl. empty
list → empty map), `hashCode`, `assertCalculation/Function/Mixin`;
`SassNumber.assertNoUnits` + `assertInRange`; `SassString.sassIndexToStringIndex`
+ `empty`; `SassColor.isLegacy`. All covered in `wasm/test.mjs` + tsc.
- ~~**Caveat:** `assert*`/index error messages not byte-exact~~ ✅ FIXED — see
  Polish #2 (now byte-for-byte vs dart-sass 1.101).

### TIER 2 — conversion-dependent methods (engine-routed)

The **engine-routing bridge is built**: a JS `Value` method serializes its
operands and calls a wasm `sasso_value_op` export → core `host_value_op` (reuses
the exact Rust math, ZERO divergence). It runs on an independent value instance,
so methods work **standalone** and **re-entrantly** during a (sync or async)
compile.

- **`SassNumber` ✅ DONE (Tier 2a):** `convert` / `convertToMatch` /
  `convertValue` / `convertValueToMatch` / `coerce` / `coerceToMatch` /
  `coerceValue` / `coerceValueToMatch`, `compatibleWithUnit` — routed to
  `unit_lists_factor` with dart's convert/coerce unitless rules. Tested
  standalone + re-entrant (sync & async).
- **`SassColor` ✅ DONE (Tier 2b + 2c):** `toSpace`, `channel(name, {space})`,
  `isInGamut`, `toGamut`, legacy getters (`red/green/blue` cross-space,
  `hue/saturation/lightness`, `whiteness/blackness`), `isChannelPowerless`,
  `interpolate` (→ `color.mix`), and `change({…})` (pure JS: a copy with channels
  replaced, converting via `toSpace` when a `space` is given). All routed to the
  Rust math; tested standalone + re-entrant. **Tier 2 is COMPLETE.**
- **Value equality with unit conversion** (`1in == 96px`) ✅ DONE — see Polish #1.

### TIER 3 — missing value TYPES (LOW frequency, varied effort)

- **`SassCalculation` ✅ DONE (Tier 3a):** `calc()`/`min()`/`max()`/`clamp()` as
  an argument or return, plus `CalculationOperation` and `assertCalculation`. The
  `CalcNode` tree round-trips both ways over a new `TAG_CALC` wire encoding
  (Number/Str/Op/Func). Tested (receive + inspect `calc(1px + 2%)`; return
  `calc`/`min` incl. `var()`). *(`CalculationInterpolation` is deprecated/legacy —
  not modelled.)*
- **`SassFunction` / `SassMixin` ✅ DONE (Tier 3b):** first-class refs round-trip
  as **opaque handles** — `serialize_args` stores the `Value` in a per-dispatch
  handle table (swapped/restored around each custom-function call for nesting
  safety) and emits its index; JS holds an opaque `SassFunction`/`SassMixin` and
  passes it back, which the engine looks up. Tested: receive a function ref and
  return it → `meta.call(it, 5)` = 10; same for a mixin → `meta.apply(it)`.

  **🎉 THE FULL dart-sass `Value` TYPE SYSTEM IS NOW SUPPORTED.**

## POLISH TRACK — remaining for 100% (no more Value types) — 2026-06-23

The full `Value` type system is done. What's left to be a byte-for-byte drop-in,
in priority order. Each item must ship with test coverage **and** be verified
against dart-sass (`sass` npm) for message/behaviour parity.

1. **Unit-aware `.equals` / `hashCode`** ✅ DONE — `SassNumber.equals` is now
   fuzzy + cross-unit (same units → fuzzy value compare; different → convert via
   the already-routed `convertValueToMatch`, incompatible → false; one-unitless →
   false). `hashCode` keeps the equal⇒equal invariant (unitless → value hash,
   united → one bucket). No new core op needed; reuses Tier 2's convert routing.
   Verified case-for-case against dart-sass 1.101 (incl. `1in==96px`, fuzzy
   `0.1+0.2==0.3`, `SassMap` key `1in` matched by `96px`; compound `m/s` vs
   `cm/s` is `false` in BOTH — dart's `convertToMatch` throws there too). Color
   equality already matched dart (space-aware structural). Tested in test.mjs.
2. **assert / index error-message byte-exactness** ✅ DONE — captured all 18
   messages from dart-sass 1.101 and diffed: sasso already matched 16/18; fixed
   the two outliers — `assertUnit` (`Expected 5px to have unit "em".`) and
   `assertNoUnits` (`Expected 5px to have no units.`) now use dart's `Expected … to
   …` form instead of the `… is not …` form. All 18 (with/without `$name:`)
   verified byte-identical; locked in test.mjs.
3. **`logger` option** (`@warn` / `@debug` / deprecation warnings) ✅ DONE — the
   core now routes every `@warn`/`@debug`/deprecation through a `WarnHandler`
   (`Options::with_warn_handler`, threaded into `EvalOptions`) instead of
   `eprintln!`; the handler-less path still prints byte-identically to stderr
   (native CLI unchanged). The wasm layer adds a `host_warn` import; the JS layer
   adds a `logger` option (`{ warn(message, opts), debug(message, opts) }`,
   dart-shaped: `opts.deprecation`/`deprecationType`/`span`) + `Logger.silent`,
   defaulting to stderr. **Fixes the real gap** — `@warn`/`@debug` were silently
   dropped in the npm build. Verified vs dart-sass 1.101: `@warn`/`@debug`/the
   `@import` deprecation/async all route; tested in test.mjs. *(Note: sasso emits
   only the `@import` deprecation today — other deprecation IDs like `slash-div`
   aren't detected yet; that's a separate conformance item, not a logger gap.)*
4. **`charset` option** + CLI `--no-charset` ✅ DONE — `Options::with_charset`
   (core, default `true`), threaded through `emit`/`sasso_compile2` + a JS
   `charset` option + CLI `--[no-]charset`. **Also fixed a pre-existing bug:** the
   JS `TextDecoder` was silently stripping the compressed-output U+FEFF BOM — CSS
   is now decoded BOM-preserving, so compressed non-ASCII output carries the BOM
   like dart. Verified all four cases (expanded `@charset`, compressed BOM, both
   suppressed by `charset:false`) vs dart-sass 1.101; tested in test.mjs + CLI.
5. **CLI flags** ✅ DONE (high-value set) — added `--embed-source-map` (inline
   data-URI map, implies source-map-on), `--no-charset` (#4), `-q`/`--quiet`
   (routes to `Logger.silent`), `--update` (skip outputs already newer than their
   input — entry-mtime based; transitive `@use`/`@import` dep tracking is a noted
   limitation vs dart's dep cache), and multiple `<in>:<out>` pairs (colon form,
   Windows-drive-aware). All tested in test.mjs. *(Deferred, low value:
   `--[no-]unicode` needs a wasm ABI param to switch error-snippet glyphs to
   ASCII; `--color`/`--no-color` is a no-op since sasso diagnostics aren't
   ANSI-colorized. Noted, not blocking drop-in use.)*
6. **`Exception.span` + `sassMessage`** ✅ DONE — the wasm error path now returns
   a structured frame (`line`/`col`/`url`/raw `sassMessage`/rendered block) instead
   of just the rendered string, so the JS `Exception` carries `.sassMessage` (the
   raw one-liner — **fixes a bug**: it used to be the whole block) and `.span`
   (`url` + 0-based `start`/`end`). Verified vs dart-sass 1.101: `span.start`
   line/column match exactly (e.g. `0:12`); structure (`name`/`span.url`/`message`)
   matches. *(`span.url` is the entry url — exact for single-file; a cross-file
   error reports the entry rather than the failing import. The raw-message
   **wording** still differs from dart in places — that's the broader
   diagnostic-conformance track, not the Exception shape.)* Tested in test.mjs.

**🎉 POLISH TRACK COMPLETE** — all six items done. No known Value-API or option
gaps remain for drop-in use; the residual items are deeper diagnostic-message
*wording* parity and a few low-value CLI flags (`--error-css`, `--[no-]unicode`,
`--color`), all noted above.

## CLI gaps (separate track)

- ~~**`--watch`**~~ ✅ DONE — `-w/--watch` recompiles on change, tracking
  dependencies via `loadedUrls` (watches their directories, debounced).
- ~~`--embed-source-map`, `--update`, multiple `input:output`, `--quiet`,
  `--no-charset`~~ ✅ DONE (Polish #4/#5). Still open (low value): `--error-css`,
  `--color`/`--no-color` (no-op — no ANSI), `--[no-]unicode` (needs an ABI param),
  `--[no-]source-map-urls=relative|absolute`, `--stop-on-error`.

## Recommended sequencing

1. ~~**Tier 0**~~ ✅ done (immutable shim + value-keyed `SassMap.contents`).
2. ~~**Tier 1**~~ ✅ done (pure-JS methods; error-message *exactness* still open).
3. ~~**CLI `--watch`**~~ ✅ done (`-w/--watch`, dependency-tracked).
4. **Tier 2** (engine-routed conversions) — the big one; design the ← next
   re-entrant value-conversion bridge once, reuse for number + color + equals.
5. **Tier 3** (calc / function / mixin types) — niche; do last.
6. Error-message byte-exactness pass (the Tier-1 caveat).

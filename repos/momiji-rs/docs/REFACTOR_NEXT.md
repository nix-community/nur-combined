# sasso refactor plan — round 2 (post-campaign)

Status snapshot: master @`40f50a4`, **13895/13896 sass-spec**, zero runtime deps,
`unsafe` only in `src/arena.rs`, byte-exact dart-sass output.

The original [`REFACTOR_PLAN.md`](./REFACTOR_PLAN.md) is **fully shipped** — every
sequenced step landed (eval.rs split, Color boxed, the whole selector campaign,
OutNode constructors, typed hoist markers, CartesianOrder rename, Cow arg-names,
`Rc<str>`/Rc List·Map, color.rs split), plus an extra round of `@extend`
incrementalisation and the arena in-place realloc. This round catalogues what
that campaign **left behind** — derived from a fresh 4-subsystem re-analysis of
the current tree (eval / front-end / value+arena+emit / selector+builtins).

## Round-2 status (2026-06-13)

- **T1.1 LineScanner** — ✅ shipped `0e282dd` (byte-identity parity oracle).
- **T1.2 eval split** — ✅ shipped `35ae035` (eval/mod.rs 7084→6108; base==refactor 13904 cases, 0 diff).
- **T2.3 string-serializer fast-path** — ✅ shipped `39f3c51` (string-dense −4.0%, general flat; byte-identical).
- **T1.3 is_builtin single source** — ✅ shipped `dc189b9` (per-family `NAMES` consts; equivalence test proved no pre-existing drift).
- **T2.1 Rc-back callable env** — ❌ **CLOSED (bench-first showed flat).** A 600k-`@function` profile (`sample`) put `capture_callable` at ~1% of top-of-stack even on that pathological corpus; the dominant definition-time cost is the intrinsic `HashMap` insert/rehash + arena alloc, which T2.1's Vec-clone optimization does not touch. The maximal design (Rc-ifying the live scope stack + `Rc::make_mut` COW, which ~negates the call-path save) carries a large blast radius and the scope-lazy-frame correctness hazard for a ~0% real-world gain. Per the tier's "if a bench is flat, close it" rule — the general path has no remaining big lever.
- **T1.4 extract selector/parse.rs** — ✅ shipped `c84e9a4` (selector.rs 5175→4634 + selector/parse.rs 551; the @extend/weave core stays in mod.rs; byte-identity over 1232 cases incl 581 @extend). The `parser.rs` domain split is deliberately NOT done standalone — per this doc it folds into the next PR that already touches parser.rs (a standalone split is pure churn).
- **T2.2 Slash → Rc<str>** — ❌ **CLOSED (bench-first showed flat).** `Value::Slash` never surfaced in a `sample` profile of a 23 MB slash-dense corpus; Slash is rare and its `String` clone is not a measurable cost. Consistency-only motivation does not justify the churn.
- **T2.4 borrowed-buffer compressed emit** — ❌ **CLOSED (bench-first showed flat).** On a pure-compressed 11 MB corpus (T2.4's best case), the `join_generic_copy` it removes was ~0.8% of total and the whole compressed serializer only ~7.4%; the run is dominated by eval + parser. Expanded output (the default, common case) already streams into `&mut String` so T2.4 does nothing there. A ~0.8%-on-compressed-only win against the don't-touch `emit.rs` at med risk is negative ROI.

**Round-2 is complete: 5 items shipped (T1.1, T1.2, T2.3, T1.3, T1.4-selector), 3 closed bench-first (T2.1, T2.2, T2.4). The doc's thesis holds — the general path has no remaining big lever; the one real perf win this round was T2.3 (string-dense −4%).**

---

## The honest framing

The engine is structurally healthy. The big **memory** levers (Value size,
read-only clone cost, extend-path malloc storm) and the big **perf** levers are
already pulled. The project's own measured verdict still holds:

> **The general (non-extend) path has no remaining big lever.** Do not
> micro-tune `ryu` / `fmt_num` / `eval_expr_inner` — they are intrinsic
> byte-exact costs.

The 2026-09-15 audit (`bench/perf_audit_2026-09-15.md`) re-tested both halves of
that verdict and **confirmed** them: a full rebuild of the `fmt_num`/`ryu` path
with a better design and byte-identical output over ~84M fuzzed formattings
measured **0.0% ±0.25% on five real frameworks**, and the `@extend` carve-out
came in at −13.6…−32.5% while staying 0.00% on the general path. The verdict now
rests on measurement rather than assertion.

It also needs a companion clause, because the audit's own largest lever is
−14.3%:

> The verdict describes **the tree**, not a snapshot. Only a perf gate keeps it
> from decaying — that −14.3% is not a new optimisation, it is recovery of a
> regression CI merged two days earlier with no perf threshold in the way. See
> `docs/PERF_PLAN_2026-09-16.md`.

So round 2 is **mostly maintainability** (collapse the last oversized files and
the duplicated code the campaign couldn't reach), with a short list of
**marginal perf/memory items gated behind a bench** — none are merged on a
hunch.

## Hard constraints (unchanged, every proposal respects these)

1. **Zero runtime dependencies** — `std` + the in-house `src/fxhash.rs` only.
2. **No new `unsafe`** — `arena.rs` keeps the sole `unsafe`.
3. **Byte-exact output is the contract** — gated by `spec/check_baseline.py`
   (≥13895) + `tests/parity.rs`.
4. **Preserve provenance** — keep the dart-sass method-name doc comments verbatim
   through any move/rename.
5. **No `Co-Authored-By` trailer** on commits.

## Don't-do list (verified low/negative ROI)

- **Scanner `Vec<char>` → byte-cursor.** Correctly deferred. The scanner runs
  once per file, off the hot path; the eval arena dominates peak RSS. Byte-offset
  line-tracking over UTF-8 is error-prone for a win that doesn't move the needle.
  Revisit only if a `massif` run shows the scanner >5% of peak RSS.
- **`parser.rs` value hot path** (lines ~4248–5722). Clone density ~0.14%;
  already a clean single-pass recursive descent. Splitting it buys 0 perf.
- **`diag.rs` itself.** Stays on this list: the ~10 warning blocks a success
  compile actually prints are ≈0.5% of it. **But the reason given here until
  2026-09-16 was wrong** — it read "error-path only — never on a success compile.
  No hot-path cost." Neither half of that is right. Rendering does run on a
  success compile — `emit_deprecation` calls `crate::diag::render_snippet`
  (`src/eval/mod.rs:1979`) for each of the ~10 warnings that survive dedup and
  the per-id cap — it is simply small, which is the ≈0.5% above. The
  *deprecation bookkeeping* around it in `src/eval/mod.rs` is neither
  error-path nor small: it runs ~20,800 guard probes and ~6,000
  `emit_deprecation` calls per success compile, discards ~99% of them, and is the
  top lever of `bench/perf_audit_2026-09-15.md` (§4.1, −14.3% instructions).
  `--quiet` does not help: `diag_enabled()` keys off the source text
  (`src/eval/mod.rs:1669`), and the dedup key is `format!`ed before the reject.

---

## Tier 1 — maintainability (high confidence, low risk; do these first)

### T1.1 — Collapse the 8 duplicate `.sass` scanners into one `LineScanner`
`[maintainability (+small memory) · S · low risk]`
`sass_parser.rs` (~1026–1515) hand-rolls **8 near-identical ad-hoc scanners**
(`split_top_level_commas`, `strip_silent_comment`, `custom_value_open`,
`interp_open_anywhere`, `scan_state`, `find_decl_colon`, `has_top_level_using`,
`find_top_level_semicolon`). Each does `s.chars().collect()` then re-runs the
same quote / bracket-depth / `#{}` / `/* */` state machine, differing only in the
final decision. Extract one borrowed-`&[char]` `LineScanner` with a
predicate-based `find_top_level` + state queries; each function becomes a
one-line wrapper. Pure refactor — the state machine is identical. This is the
single clearest code smell left in the tree. (`.sass` is off the `.scss` hot
path, so the allocation saving is a bonus, not the motivation.)

### T1.2 — Finish the `eval/mod.rs` split (still 7084 lines, the biggest file)
`[maintainability · S · negligible risk]`
The Phase-0a split stopped at the method level; `impl Evaluator` is still one
~2700-line block. Carve two more pure-code-move modules, no behaviour change:
- `eval/expr.rs` — `eval_expr_inner` (~2686–3283) + its expression-only helpers
  (`eval_if_function`, `eval_supports_calc_func`, module-call dispatch).
- `eval/scope.rs` — the environment layer (`lookup`/`var`/`assign`/`set_local`/
  `bind_each`/`assign_module_var`/scope-stack ops, ~1485–1774).
This is the prerequisite that keeps T2.1 (the one perf item that touches eval) a
reviewable diff.

### T1.3 — Kill the `is_builtin()` two-point sync hazard
`[maintainability · correctness hazard · M · med risk]`
`builtins/mod.rs` (~92–167) hardcodes a builtin-name match that **must** be kept
in sync with each family's `try_call` arms *and* with `is_math_builtin_name()`.
Adding a builtin and forgetting `is_builtin()` silently mis-routes a name between
builtin and plain-CSS-function handling. Drive all three from one declarative
source (a table or macro that mirrors the family dispatch) so a new builtin is a
single-site change. Gate on the full spec — mis-classification is byte-observable.

### T1.4 — Domain-split `parser.rs` (6724) and extract `selector/parse.rs`
`[maintainability · M · low risk]`
Pure file moves, no behaviour change. `parser.rs` has clean seams:
`statements` / `declarations` / `at_rules` (~1105–2680, the largest) /
`callables` / `control_flow` / `value`. `selector.rs` (5175) can shed its parser
(~685–1224) into `selector/parse.rs`; the `@extend`/superselector/weave core is
mutually recursive and should **stay together** (splitting it would force
internal `DComplex`/`TComp`/`CartesianOrder` types across module lines for no
gain). **Lower urgency** than T1.1–T1.3 — best folded into the next PR that
already touches these files, rather than a standalone churn-PR.

---

## Tier 2 — perf / memory (marginal; each gated behind a before/after bench)

> Merge only with a `bench/scripts/run_bench.sh` before/after showing a real win
> (instructions-retired via `/usr/bin/time -l`, plus interleaved min-of-N wall).
> If a bench is flat, close it — the general path is already optimal.

### T2.1 — `Rc`-back the captured callable environment `[perf+memory · M]`
**The one lever the original plan missed.** `capture_callable`
(`eval/mod.rs` ~1497) clones **four `Vec`s** (`scopes`, `scope_semi_global`,
`functions`, `mixins`) on *every* `@function`/`@mixin` definition, and the same
4-Vec `mem::replace`/restore dance repeats at ~9 call sites in `control_flow.rs`
+ `meta.rs`. Change `UserCallable`'s env fields to `Rc<Vec<…>>` so capture +
apply become refcount bumps; collapse the restore boilerplate into a `SavedEnv`
helper. Meaningful for function/mixin-dense or deeply-nested sheets.
⚠️ **Risk:** the scope-lazy-frame interaction the original plan flagged —
`capture_callable` must still see *later* sibling definitions. Needs a targeted
parity test, not just the ratchet.

### T2.2 — `Value::Slash` repr → `Rc<str>` `[perf · S]`
`Slash(Number, String)` (`value.rs:34`) clones its CSS repr on every serialize
(read-many, write-once). Align with the already-`Rc`-backed Str/List/Map.

### T2.3 — Fast-path the string serializers `[perf · S]`
`serialize_quoted`/`serialize_unquoted` (`value.rs` ~452/487) `chars().collect()`
into a `Vec<char>` *before* the no-escape early-out. Do a byte scan for the
escape triggers first; only collect when an escape is actually present.

### T2.4 — Borrowed-buffer compressed emit `[perf · M · med risk]`
The compressed path (`emit.rs` ~477–500) builds `Vec<String>` then `join`s twice
per nested rule; the expanded path already writes incrementally into `&mut
String`. Thread the buffer through the compressed recursion to match. Lowest
priority of the tier — touches `emit.rs`, which the original plan put on the
don't-touch list, so only if the bench justifies it.

---

## Suggested sequence

1. **T1.1** (LineScanner) — isolated, satisfying, zero risk.
2. **T1.2** (eval split) — unblocks T2.1's reviewability.
3. **T2.1** (Rc callable env) — bench first; the only real perf/memory candidate.
4. **T1.3** (is_builtin source-of-truth) — removes a live footgun.
5. T1.4 / T2.2 / T2.3 / T2.4 — opportunistic, fold into adjacent work.

## Method (per the project's discipline)

Each step = atomic commit + a new `tests/parity.rs` case byte-verified vs
dart-sass + `spec/check_baseline.py` (≥13895, no regression) + clippy/fmt + a
`bench/` before/after for any T2 item. No `Co-Authored-By` trailer.

---

## Adjacent track: wasm async-path performance (not core-crate work)

The npm package's asyncify path has its own measured backlog — F1 (asyncLock →
instance pool), F2 (speed `-O3` async wasm variant), F3 (sync-delivery fast
path in `asyncHostFn`), F4 (native Node addon, long-term) — with designs,
acceptance criteria, and a reproducible harness in
[`ASYNC_PERF_ARCHITECTURE.md`](./ASYNC_PERF_ARCHITECTURE.md) (evidence:
[`HANDOFF_ASYNC_IMPORTER_PERF.md`](./HANDOFF_ASYNC_IMPORTER_PERF.md); harness:
`bench/asyncify/`). Same discipline as this doc: every fix lands with a
before/after from `bench/asyncify/ab-compare.mjs` and the async guards in
`wasm/test.mjs` green. None of it touches the core crate's hot path.

---

## Adjacent track: real-world corpus compat (`bench/real-world/`, updated 2026-07-04)

The real-world harness (`node bench/real-world/run.mjs all`) compiles 10
vetted, currently-active, well-known OSS Sass codebases with dart-sass 1.101
and sasso. Status after the 2026-07-04 fix campaign: **all 10 compile**, and
the parity column reports byte-identical or canonical-identical for most
(report: `bench/real-world/real_world.md`).

Landed (each an atomic commit with parity tests + spec-baseline guard):

- Loud-comment dedent at serialize time (interpolated banners) — bootstrap.
- `@import`ed files get their own diagnostics/stamp context (also fixes
  error attribution inside imported files) — minimal-mistakes.
- Invisible (`@extend`-only) rules leave no blank-line group end — bootstrap.
- dart's `_preModuleComments` per-edge re-emission, including the
  inherited-map quirk — bulma.
- Selector linebreaks survive the nested-at-rule wrap — just-the-docs.
- Plain-CSS imports re-serialize selectors through the parser — primer.
- Multi-`&` parent expansion flattens column-major — mastodon.
- `@use` namespace tables captured in callable closures — uswds + quasar.
- CSS escapes are literal in template scans (`.govuk-\!-…`) — govuk-frontend.
- `as *` terminates a `@use`/`@forward` prelude (indented) — vuetify.
- Indented loud-comment first line stays verbatim (`/**`) — quasar.
- Indented selector comma-continuation vs pseudo colons (this one DROPPED
  selectors — correctness) — quasar.
- Pseudo-nested `&` substitutes inside multi-`&` cartesian parts — quasar.

Not a bug after all: carbon's `@forward 'scss/config'` resolves fine; carbon
fails identically in dart-sass on its publish-time codegen output
(`packages/layout/scss/generated/*`) and stays excluded.

Fixed since: single-module chained-`@extend` order (dart addSelector
pre-extension ungated — bootstrap navbar, commit `a445ede`); error
attribution across `@use`/`@forward`/`@import` chains incl. loader frames
(commit `0c5e6d0`); `@media` in unknown at-rules (Tailwind v4 `@utility`,
commit `5ad4889`).

Round 3 (2026-07-04, after the 0.7.0 release): linebreak-flag propagation
(pseudo-arg newlines + parent-resolution flags, `32eea4e`), indented comment
re-indent (`c5da8d5`), the invisible-last-child group seam + a drop-loop
index bug (`9520965`), and dart's addSelector one-shot timing for pre-rule
extensions (`461ff10`). bootstrap, quasar, mastodon and govuk-frontend all
moved to byte-identical — **8 of 10 corpus projects are now byte-identical**.

Round 4 (2026-07-04, later the same day): dart's `_extendModules`
downstream-store merge order landed for real (`5e9c87a` store-merge model,
`35b199c` one-shot gate, `95d2726` empty-module-scope anchor) — bulma went
byte-identical. Then the uswds residue fell to three pre-module-comment
engine fixes pinned against dart 1.101.0 (`4fe86ed`): registration
deep-scans pending comments through invisible module-scope placeholders
(dart's `_root.children` holds no placeholder for a CSS-less load), a
`pre_comment_floor` fences re-emitted clones so they never re-register
(dart materializes clones at combine time only), and `Module.phantom_css`
mirrors dart's `transitivelyContainsCss |= preModuleComments.isNotEmpty`
quirk (a css-less module built while the shared map is non-empty absorbs
pending registrations). Finally, marker-only module wrappers (a
placeholder-only module dropped to a bare GroupEnd) now count as empty in
the extend drop pass, so their group-separator Blank collapses
(`fbc6ee0`).

**All 10 compilable corpus projects are byte-identical** (carbon stays
excluded — publish-time codegen; fails identically in dart-sass). The
real-world byte-parity campaign is COMPLETE; `bench/real-world/run.mjs
check` is the regression gate. These fixes are unreleased on master
(post-0.7.0/npm-0.10.0) — ship with the next release.

Campaign 2 (2026-07-05): the corpus grew to 20 vetted projects (tabler,
AdminLTE, reveal.js, Font Awesome, video.js, forem, nextcloud, chirpy,
grafana, wagtail — 88c692a) and the sweep landed eight more compiler
fixes, each pinned by a parity test:

- `@each` over null iterates once, per dart `Value.asList` (b5ccff0 —
  tabler wouldn't compile).
- Extend component axis always uses dart's `paths` order (113e643 —
  forem `.crayons-btn + .crayons-btn` both-ends products).
- Duplicate (target, extender) pairs merge per module store, not
  globally (9418745 — chirpy `#access-lastmod a:hover` position).
- A trailing invisible chain owns the enclosing group's end at any
  nesting depth (328a3b6 — chirpy panel→footer seam).
- Import hoisting keeps the css flow's eval-time grouping; only the
  seam the pulled run vacated is re-derived (881ea84 — forem `body` vs
  `body.hidden-shell`; dart's blanks come ONLY from group-end flags,
  never source gaps).
- `@at-root` separators follow dart's `_styleRule == null` group-end
  gate via sink sentinels (12d38a1 — wagtail sidebar slim block).
- meta.load-css copies re-acquire per-rule separators — dart re-visits
  the combined css node-by-node (f9f4e18 — reveal.js pdf/paper).
- Re-emitted pre-module clones splice inside a `#premod` scope so the
  import-run sweep can't lift them to the top (c33bded — nextcloud
  SPDX header).

Campaign 3 (2026-07-06): the extend-engine milestone landed (76f9e08)
and **all 20 compilable corpus projects are byte-identical**. Three
coupled dart semantics, each pinned by parity tests: the LIVE
`_extensionsByExtender` list lets an extender containing its own target
self-derive within its registration (extend-loop chains WITHOUT any
application fixpoint); each batch then applies exactly once, killing
tabler's chained same-rule products; and `_originals` is an IDENTITY
set — original status is a per-INSTANCE flag threaded through the
pipeline (with dart's bare-fast-path object identity, scope-gated per
store), so products value-equal to originals coverage-trim away and the
originals keep their positions and line breaks.

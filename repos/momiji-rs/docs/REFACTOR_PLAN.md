# sasso refactor plan — maintainability · performance · memory

> **STATUS: ✅ fully shipped (2026-06-13).** Every sequenced step below landed —
> see git history and [`REFACTOR_NEXT.md`](./REFACTOR_NEXT.md) for the post-campaign
> round-2 backlog. This document is kept as the historical record + rationale.

Status snapshot: master @`60559a6`, **13895/13896 sass-spec (99.99%)**, zero
runtime deps, `unsafe` only in `src/arena.rs`, byte-exact dart-sass output.
The engine is functionally excellent and already **heavily perf-tuned** (arena,
FxHash for eval maps, Ryū float formatter, multiple clone-reduction rounds).
This plan targets the structural levers the micro-tuning left behind.

Derived from a 6-agent architecture analysis (5 subsystem deep-dives + an
empirical profiling pass + a cross-cutting critic). Empirical findings are
flagged **[measured]**.

---

## The one insight that organizes everything

**The structural selector model is a single refactor wearing three hats.**
Today selectors live as **`Vec<String>`** on `OutNode::Rule.selectors`
(`eval.rs:83`). The typed `Complex`/`Compound`/`Simple` tree already exists and
is good (`selector.rs:14-214`) — but it is **constantly serialized back to a
String** to be used as a storage type, a map key, and a re-parse source:

- `extend_selector_list` joins the strings with `", "` and **re-parses** via
  `parse_list` per touched rule (`eval.rs:10645`).
- The `@extend` engine keys **~28 HashMap/HashSet sites by `render()` Strings**
  (45 `render()` calls, **zero `FxHash`**).
- **[measured]** the malloc/free family is **~49% of extend-path self-time**,
  *solely* from this render-string + clone churn, and it **overflows the 2 GiB
  arena** → individually `malloc`'d *and* `free`'d (`arena.rs:294`), which is
  also the only thing standing between extend-heavy input and the **wasm 32 MiB
  arena target** blowing up.

So the selector campaign is simultaneously the #1 **memory** fix, the #1
non-trivial **perf** fix, and a real **maintainability** simplification. It is
the centerpiece — but it must land *after* the eval.rs split and *behind* a
correctness gate (below).

> **[measured] The general (non-extend) path has no remaining big lever** —
> `large.scss` matches the documented leaf profile (memmove / eval_style_rule /
> arena / ryu) at a 27.8M footprint. Do **not** chase micro-tweaks (ryu,
> fmt_num, eval_expr_inner) there; they are intrinsic byte-exact costs.

---

## Hard constraints (every proposal respects these)

1. **Zero runtime dependencies** — no `smallvec`/`hashbrown`/`bumpalo`. Use the
   in-house `src/fxhash.rs` and `std` (`Option<Combinator>` or a hand-rolled
   inline vec for the combinator shrink). A new crate would be rejected.
2. **No new `unsafe`** — all proposals (box Color, `Rc<[Complex]>`, `Cow` names,
   typed markers) are safe. `arena.rs` keeps the sole `unsafe`.
3. **Byte-exact output is the contract** — gated by `spec/check_baseline.py`
   (baseline 13895) + `tests/parity.rs`. The selector-typing changes are only
   safe if **typed `Eq`/`Hash` agrees with `render()`-string equality** for
   every selector the model represents → see the parity-proof gate.
4. **Preserve provenance** — every method carries a doc comment naming the
   dart-sass method it mirrors (`visitIf`, `_combineCss`, `addSelector` timing,
   `_writeReindentedValue`). Keep these verbatim through any move/rename.

## Don't-touch list (good as-is, refactor = downside only)

`emit.rs` (653 lines, already `Cow`-conscious) · the `Sink` enum · the
`OutNode`/`OutItem` split · the `DComplex`/`TComp` converters + weave/unify
port · the `EXTEND_WORK_BUDGET`/`100_000` caps (without them the overflow is
unbounded) · `Number`'s `Units` tiering · the `.sass`-as-transpiler
architecture · `CalcNode`.

---

## Sequenced plan

Each step is an atomic, independently gate-able change (ratchet + parity +
clippy/fmt + a before/after `bench/` run). Order matters where noted.

### Phase 0 — make the rest reviewable (do first)

**0a. Split `eval.rs` (12120 lines) into an `eval/` module directory.**
`[maintainability · M · low risk]` One `impl Evaluator` spread across files
(Rust allows this in-crate, zero behavior change): `eval/mod.rs` (struct + ctor
+ `exec` dispatch), `control_flow.rs`, `at_rules.rs` (media/supports/keyframes/
at-root + hoisting), `modules.rs` (use/forward/import/`load_module`/
`_combineCss`/`reparent`), `plain_css.rs`, `meta.rs`, `calc.rs`, `binop.rs`
(the free fns), `output.rs` (`Sink`, `OutNode`/`OutItem`, `push_at_rule`,
markers). **Pure code-move.** This is the **prerequisite that makes every later
eval-touching refactor a reviewable diff against stable boundaries** — without
it the selector campaign and the marker work collide in one 12k-line file.

**0b. Box the `Color` variant** (parallel, independent). `[memory · M · low
risk]` **[measured]** `Value` is **128 B, driven 100% by `Color` (120 B
inline)**. Box `Color.modern` (ideally the whole `Color`) → `Value` drops toward
**~64 B**, halving every scope-map slot, every `Vec<Value>` element, every
lookup-clone (`eval.rs:1617`), and every arena-overflow `Value` alloc. **This is
the real fix the earlier "`Rc<Value>` = neutral" experiment missed** — zero
semantic change, measured by a `size_of` probe + bench.

### Phase 1 — the selector campaign (the big lever; after 0a)

**1a. Build the parity-proof harness FIRST.** `[gate · S]` The
highest-value-missing piece: a debug assertion that **typed-`Eq`/`Hash` ⇔
`render()`-string equality** for every selector the engine touches — analogous
to the `fast==slow` `normalize_selector` oracle the project already runs across
the full spec. **Do not merge 1c/1d without this.** Two selectors must hash/
compare equal *iff* their render strings are equal, or dedup/origin/trim
ordering silently corrupts on `:is()`/`:not()` args + pseudo self-ref.

**1b. ~~Decide the `ComplexComponent` combinator storage shrink NOW~~ — WONTFIX
(2026-06-12).** `[memory · S]` `Vec<Combinator>` per component → an inline-1-
with-spill (`Option` loses the bogus multi-combinator case `c > > d`). Closed as
low-ROI: the common descendant join is an *empty* Vec (already no heap alloc),
`Combinator` is 1 B, and the strategic window passed — this was meant to precede
1c to avoid rehashing the maps twice, but 1c/1d shipped without it, so doing it
now means re-touching the `Hash`/`Eq` derives + re-running the 1a parity proof +
re-bench for a ~16 B/component win. A re-bench after the leniency campaign
confirmed the cost of *not* doing 1b is nil: 1a parity proof clean (0 violations
across 13 896), sasso 1.14× faster than dart, byte-identical output.

**1c. FxHash + typed-key the extend maps.** `[perf·memory · M · the higher-ROI
half]` Derive `Hash`/`Eq` on `Complex`/`Compound`/`Simple`; key
`originals`/`sources`/`by_extender`/`ext_breaks`/`source_specificity_map`/
`targets` by the **typed value** via the in-house `FxHashMap`
(`selector.rs:856,1073,2607,2769,4294,…`; `render_dcomplex` at ~3453 is pure
waste). **[measured]** kills most of the ~49% extend-path malloc storm + the
~2.8% SipHash cost. Ships before 1d and de-risks it.

**1d. Carry `Rc<[Complex]>` through `OutNode::Rule.selectors`.** `[perf·memory ·
L]` Replace the `Vec<String>` selector field; render only at serialization;
**delete the join→re-parse round trip** (`eval.rs:10645-10654`). **Preserve the
existing string fast-path** for unmodelable selectors
(`extend_selector_list` early return, `eval.rs:10642`).

### Phase 2 — maintainability cleanups (after 0a; 2 before 3)

**2. `OutNode::rule`/`plain_rule`/`at_rule` constructors + a small builder.**
`[maintainability · S]` **[measured] 18 duplicated construction sites** each
carry `extend_base`/`linebreaks`/`lines` boilerplate the recent `extend_base`
change had to touch one-by-one. Collapses them to one-liners; the next field
addition becomes a single-site change. Do **before** step 3.

**3. Typed hoist markers.** `[maintainability · M · med risk]` Replace the
stringly NUL-sentinel markers (`MEDIA_HOIST_MARKER`/`AT_ROOT_HOIST_MARKER`/
`STYLE_GROUP_END` + `strip_prefix`/`parse`) with explicit `OutNode::MediaHoist`/
`AtRootHoist { target }`/`GroupEnd` variants. Makes the @media/@at-root
bubbling — the hardest-to-reason-about core — legible. Lands inside
`eval/output.rs` + `eval/at_rules.rs`; **gate hard on the 17+ existing at-root
probes**.

**3b. `ExtendStrategy` (OneShot/Fold/PseudoWorklist) + `CartesianOrder` enums —
RENAME-ONLY.** `[maintainability · M · clarity only]` Replace the `one_shot`
bool cartesian-order plumbing (`selector.rs:882-965,1713,3328`). ⚠️ This is the
highest-byte-risk code in the repo and a **loop-swap here was already proven
wrong** (single- vs multi-component extenders need opposite order). **Any
behavioral change is a regression magnet — treat as pure rename/extract.**

### Phase 3 — allocation cleanups (low-risk, mostly anytime)

**4. The normalize-name batch (one PR).** `[perf · S]` `normalize_arg_name →
Cow<str>` (it allocates even with no underscore, **called 4-6× per function
call**); hoist **one** `lookup_function` per `Expr::Func` arm; pre-normalize
module-var map keys (kills O(n)-alloc-per-miss); replace `is_builtin`'s 8-family
empty-arg probing with a **name-only ownership check** (`mod.rs:82`) — which
*also removes a latent "probing is side-effect-free" correctness hazard*; fix
the unconditional clone in `sass_eq`'s unslash closure.

**5. Composite-value shared ownership (after 0b).** `[perf·memory · M]`
`Str → Rc<str>`, `Rc`-backed `List`/`Map` so a read-only `$var` clone is an O(1)
refcount bump instead of a deep copy — the structural answer to the lookup-clone
hotspot. Must follow boxing so the remaining clone cost is known. Then a
`write_css`/`write_interp`-into-borrowed-buffer `SerCtx` (owned by `value.rs`,
payoff realized in emit/interpolation; **don't touch `emit.rs` structure**).

**6. `color.rs` (3442 lines) split** at its `try_call`/`try_call_modern`/
color-math seam. `[maintainability · M]` Pure file move on the most-edited
builtin. Optional, anytime.

### Defer / measure-first

Scanner `Vec<char>` → byte-cursor and the `.sass` ad-hoc-lexer consolidation
(6 near-duplicate scanners in `sass_parser.rs`) — measure peak RSS first (the
eval arena likely dominates) and the `.sass` path is off the `.scss` hot path.

---

## Risk flags (carry into execution)

- **Byte-exact (highest):** 1c/1d are unsafe without the 1a parity proof.
- **Rewrite-trap:** the extend routing (3b) is rename-only; behavioral
  "simplification" regresses.
- **Scope-lazy-frame:** if `push_scope` fn/mixin frames are made lazy (an eval
  perf idea), `capture_callable` (`eval.rs:1626`) `Rc::clone`s all four chains —
  a closure capturing an empty frame must still see *later* sibling
  definitions. Byte-observable; needs a targeted parity test, not just the
  ratchet. (Lower priority; listed for completeness.)
- **Low-ROI trap:** don't micro-tune the general path; it's already optimal.

## Method (per the project's discipline)

Each step = atomic commit + a new `tests/parity.rs` case byte-verified vs
dart-sass + `spec/check_baseline.py` (≥13895, no regression) + clippy/fmt +
a `bench/scripts/run_bench.sh` before/after (instructions-retired via
`/usr/bin/time -l` is the load-immune metric; interleaved min-of-N wall). No
`Co-Authored-By` trailer.

## TL;DR priority

1. **eval.rs file-split** (unblocks everything, near-zero risk)
2. **Box `Color`** (halves `Value`; parallel, independent)
3. **Selector campaign** — parity proof → combinator shrink → FxHash+typed-key
   extend maps → `Rc<[Complex]>` through emit (the ~49% extend-path malloc +
   wasm-arena fix)
4. **OutNode constructors** → **typed markers** → **ExtendStrategy rename**
5. **normalize-name Cow batch**, then **`Rc<str>`/`Rc` List·Map + SerCtx**

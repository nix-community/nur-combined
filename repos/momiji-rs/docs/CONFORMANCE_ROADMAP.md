# sasso conformance roadmap (sass-spec)

> ⚠️ **Historical document, kept for its reasoning and its rankings — not for its
> facts.** Every count, and every "sasso does not support X" below, describes the
> tree at the 24.5% baseline in the next paragraph. The suite now passes
> **14,114 / 14,258 attempted (98.99%)** against sass-spec `b39c3276` and
> dart-sass 1.104.1, so a statement here about what sasso cannot do is very
> likely no longer true. For one, the appendix still says `/` outside `calc()`
> parse-errors and produces no numeric result, where today the values are right
> and only the `slash-div` warning is missing
> ([#119](https://github.com/momiji-rs/sasso/issues/119)). For what actually
> diverges today read [`dart-sass-divergences.md`](./dart-sass-divergences.md),
> which is measured per row and dated. Noted 2026-09-19.

> Evidence-based, ROI-ranked plan from bucketing every failing official
> sass-spec case (commit `1b03109a`, dart-sass 1.101) by the language
> feature sasso is missing. 11 parallel read-only analysis agents + synthesis.

**Baseline:** 1,110 / 4,528 attempted (24.5%); 9,376 skipped (mostly `@use`).

Aggregated 100+ failure buckets across 12 sass-spec directories into 24 merged features for the sasso SCSS compiler, summing fail_counts into est_unlocked and ranking by ROI with foundational-unblockers weighted up. Grounded in the actual source: parse_at_rule (parser.rs:265) is a single match that hard-rejects every directive except @import; eval has TWO separate hand-written statement loops (eval_top_stmts at eval.rs:115, eval_rule at eval.rs:135) over a closed Stmt enum with no call-frame mechanism; BinOp (ast.rs:103) has only Add/Sub/Mul/Mod (no comparison/logical); additive() (parser.rs:463) requires whitespace on both sides and has no `/` arm; skip_ws_inline skips only whitespace not comments; builtins::call (builtins.rs:11) is a match with a clean `_ => plain_css_function` fallback; calc() is opaque pass-through. THE CRITICAL PATH IS SEQUENTIAL: rank 1 (comparison/logical operators + if(), low complexity) unblocks all conditionals; rank 2 (rewrite the shared statement evaluator into one recursive scoped exec_block with call frames) is the structural foundation every directive plugs into and MUST be done before ranks 3-11; then @if (3), loops (4), @function (5), @mixin (6) flow sequentially because they all mutate that shared evaluator. IN PARALLEL via worktree isolation: the entire value/math/color track is disjoint from the statement evaluator and can run concurrently — the calc engine + division (rank 12, ~380, gates the biggest buckets), math functions (13, ~440), legacy color builtins (14, ~198, infrastructure already exists so medium not high), Color-4 (15), modern if() (16), plus escapes/emit-fidelity clusters (22-24) and custom-properties (21). Highest raw single unlocks are @mixin (~206) and math functions (~436), but operators and the evaluator rewrite rank first as low-cost unblockers without which nothing downstream compiles. Key source files: src/{parser.rs,eval.rs,ast.rs,value.rs,builtins.rs,emit.rs,scanner.rs,error.rs,lib.rs}.

## Ranked features

| Rank | Feature | Est. unlocked | Complexity | Parallel? | Depends on |
|---|---|--:|---|---|---|
| 1 | Comparison (==, !=, <, >, <=, >=) and logical (and/or/not) operators + the legacy if($c,$t,$f) builtin | 69 | low | no | — |
| 2 | Shared statement-evaluator rewrite: scoped, recursive block execution with call frames (foundation for all directives) | 30 | medium | no | Comparison and logical operators |
| 3 | @if / @else / @else if conditionals (with lazy branch evaluation) | 31 | medium | no | Comparison and logical operators, Shared statement-evaluator rewrite |
| 4 | @for / @each / @while loops (range, list/map iteration, re-checked condition) | 105 | medium | no | Comparison and logical operators, Shared statement-evaluator rewrite, @if / @else conditionals |
| 5 | @function / @return (user-defined functions with arg binding, defaults, keyword args, rest) | 165 | high | no | Shared statement-evaluator rewrite, @if / @else conditionals, @for / @each / @while loops |
| 6 | @mixin / @include / @content (definition, arg binding, content blocks, using(...) arglists) | 206 | high | no | Shared statement-evaluator rewrite, @function / @return |
| 7 | Unknown / vendor / generic at-rule passthrough (@foo, @-moz-document, @page, @charset, @font-face, @keyframes shell) | 71 | low | yes | Shared statement-evaluator rewrite |
| 8 | @warn / @debug / @error directives | 19 | low | yes | Shared statement-evaluator rewrite |
| 9 | @supports rule (parse + serialize the condition, evaluate nested body) | 94 | medium | yes | Unknown / vendor / generic at-rule passthrough |
| 10 | @media rule (parse + serialize + bubbling/merge out of style rules) | 123 | high | no | Shared statement-evaluator rewrite, Unknown / vendor / generic at-rule passthrough |
| 11 | @at-root (hoist contents to document root, with/without query) | 70 | medium | yes | Shared statement-evaluator rewrite |
| 12 | CSS calc() expression engine (parse inner expression, simplify, incompatible-unit errors) + compound-unit arithmetic and division-as-math | 380 | high | yes | — |
| 13 | CSS/Sass math functions (min/max/clamp/abs/round/sign/mod/rem/pow/sqrt/exp/log/hypot/sin/cos/tan/asin/acos/atan/atan2/calc-size) | 440 | high | yes | CSS calc() expression engine + division/compound units |
| 14 | Legacy color-manipulation builtins (adjust-hue, saturate, desaturate, invert, grayscale, complement, opacify/transparentize, scale/adjust/change-color, hue/saturation/lightness getters, ie-hex-str, opacity) | 198 | medium | yes | — |
| 15 | Modern CSS Color 4 builtins + space/slash channel syntax (color(), lab/lch/oklab/oklch, hwb, mix in spaces, rgb(r g b / a) / hsl space-slash parsing) | 308 | high | yes | CSS calc() expression engine + division/compound units |
| 16 | Modern CSS if() conditional function: if(cond: value; else: value) with sass()/css() conditions | 146 | high | yes | Comparison and logical operators |
| 17 | @import enhancements (CSS @import passthrough with url()/media/supports, comment/whitespace tolerance, nested @import, .sass/_index/.import.scss resolution, ordering) | 170 | medium | yes | Shared statement-evaluator rewrite, Unknown / vendor / generic at-rule passthrough |
| 18 | @keyframes rule (special from/to/percent block selectors + bubbling) | 19 | medium | yes | Unknown / vendor / generic at-rule passthrough |
| 19 | Maps ((k: v) literals, map type, lookup, map/list builtins) + named-arg/splat (...) plumbing | 35 | high | yes | @function / @return, @mixin / @include / @content |
| 20 | @extend / %placeholder selectors (selector-extension pass + placeholder dropping) | 40 | high | yes | Shared statement-evaluator rewrite |
| 21 | Custom property (--var) raw-value preservation + nested property sets (a: { b: c } -> a-b: c) | 33 | medium | yes | — |
| 22 | Backslash escape sequences in identifiers/unquoted values + quoted-string escape normalization on emit | 97 | high | yes | — |
| 23 | Strict-whitespace +/- string concatenation, '-' string-join semantics, and comments inside value expressions | 56 | medium | yes | — |
| 24 | Special CSS function verbatim handling (vendor-prefixed/uppercase calc/url/element, comments & special chars inside), alpha()/expression() IE hacks, and selector emit/validation fidelity | 171 | medium | yes | — |

## Implementation detail

### 1. Comparison (==, !=, <, >, <=, >=) and logical (and/or/not) operators + the legacy if($c,$t,$f) builtin

- Unlocks ~69 · complexity **low** · parallelizable: **False**
- Files: `src/ast.rs`, `src/parser.rs`, `src/eval.rs`, `src/value.rs`, `src/builtins.rs`

Extend BinOp with Eq/Neq/Lt/Gt/Le/Ge/And/Or and add a Not UnOp in ast.rs. In parser.rs add a precedence layer ABOVE comma_list (or between space_list and additive): an `or` level, then `and`, then `not` (unary keyword), then a relational/equality level that recognizes the multi-char tokens `==`/`!=`/`<=`/`>=`/`<`/`>` and the bare-ident keywords and/or/not (lex them as operators only outside selector context). Implement Sass equality in value.rs (number==number with unit compat, string, color, bool, list deep-eq), relational only on Numbers, and short-circuit truthiness (only null/false are falsy) in eval_binary. Register if() in builtins::call so it returns the selected branch value. This is small, self-contained, and is the precondition for every conditional/loop feature.

### 2. Shared statement-evaluator rewrite: scoped, recursive block execution with call frames (foundation for all directives)

- Unlocks ~30 · complexity **medium** · parallelizable: **False**
- Files: `src/ast.rs`, `src/eval.rs`, `src/parser.rs`
- Depends on: Comparison and logical operators

The two hand-written loops eval_top_stmts (eval.rs:115) and eval_rule (eval.rs:135) each `match stmt` over a closed Stmt enum and cannot host new statement kinds, conditional bodies, or function/mixin call frames. Refactor them into one reusable `exec_block(stmts, ctx)` that threads parent-selector context + output sink and is called recursively. Add a separate variable-scope stack vs a definition environment (for mixins/functions) and a call-frame push/pop so a mixin/function body sees its own params over a captured lexical parent. This unlocks little directly but is the structural unblocker that every directive (ranks 3-9) plugs into; it MUST be sequential because it rewrites the shared evaluator core that all later features mutate.

### 3. @if / @else / @else if conditionals (with lazy branch evaluation)

- Unlocks ~31 · complexity **medium** · parallelizable: **False**
- Files: `src/ast.rs`, `src/parser.rs`, `src/eval.rs`
- Depends on: Comparison and logical operators, Shared statement-evaluator rewrite

Add Stmt::If { branches: Vec<(Option<Expr>, Vec<Stmt>)> } to ast.rs. In parse_at_rule add an `if` arm that parses a condition Expr (via the new logical/comparison grammar), a brace body via parse_statements, then chained `@else if` / `@else`. In eval, evaluate conditions in order using Sass truthiness and execute the FIRST truthy branch's body via the shared exec_block — only that branch is evaluated (lazy), so undefined-variable/error in dead branches stay silent. Depends directly on comparison/logical operators (rank 1) and the recursive exec_block (rank 2). Sequential: edits the shared statement match.

### 4. @for / @each / @while loops (range, list/map iteration, re-checked condition)

- Unlocks ~105 · complexity **medium** · parallelizable: **False**
- Files: `src/ast.rs`, `src/parser.rs`, `src/eval.rs`, `src/value.rs`
- Depends on: Comparison and logical operators, Shared statement-evaluator rewrite, @if / @else conditionals

Add Stmt::For{var,from,to,inclusive,body}, Stmt::Each{vars,iter,body}, Stmt::While{cond,body} to ast.rs. parse_at_rule arms: @for parses `$v from A through/to B`, @each parses `$v[, $k] in EXPR`, @while parses a condition. In eval, push a fresh scope per iteration binding the loop var(s): @for iterates an inclusive/exclusive integer range; @each iterates list items (and destructures map entries / nested lists into multiple vars); @while re-evaluates the condition (needs operators) each pass. Each iteration runs body through exec_block. @each depends on the list value model (lists exist) and map iteration (maps are rank 18, but list-based @each lands without them). Sequential: extends the shared statement evaluator.

### 5. @function / @return (user-defined functions with arg binding, defaults, keyword args, rest)

- Unlocks ~165 · complexity **high** · parallelizable: **False**
- Files: `src/ast.rs`, `src/parser.rs`, `src/eval.rs`, `src/value.rs`, `src/builtins.rs`
- Depends on: Shared statement-evaluator rewrite, @if / @else conditionals, @for / @each / @while loops

Add Stmt::FunctionDef{name,params,body} and Stmt::Return(Expr) to ast.rs, plus a param-list parser (positional, $x: default, $rest...). Store defs in the eval definition-environment. In eval_expr's Func arm, dispatch user functions BEFORE builtins::call: push a call frame binding evaluated positional+keyword args (apply defaults, collect rest into an arglist), run the body via exec_block, and unwind on the first @return value. Normalize hyphen/underscore in names; keep special non-callable names (calc/clamp/url/and/or/not/expression/element) as verbatim CSS. Depends on control-flow (functions bodies use @if/@each) and the call-frame machinery from rank 2. Sequential: touches the shared evaluator + value-eval dispatch.

### 6. @mixin / @include / @content (definition, arg binding, content blocks, using(...) arglists)

- Unlocks ~206 · complexity **high** · parallelizable: **False**
- Files: `src/ast.rs`, `src/parser.rs`, `src/eval.rs`, `src/value.rs`
- Depends on: Shared statement-evaluator rewrite, @function / @return

Add Stmt::MixinDef{name,params,body}, Stmt::Include{name,args,content_block}, Stmt::Content to ast.rs, reusing the rank-5 param/arg-list parser. Store mixin defs in the definition-environment. On @include: push a call frame binding args, set the current @content slot to the include's trailing block (with its own `using(...)` params), then run the mixin body via exec_block; @content executes the captured slot in the include site's lexical scope. Mixin bodies emit statements (rules/decls) into the surrounding output, so it must integrate with the parent-selector context threaded by exec_block. Highest raw unlock (~206). Sequential: shares the statement evaluator and call-frame infra with @function.

### 7. Unknown / vendor / generic at-rule passthrough (@foo, @-moz-document, @page, @charset, @font-face, @keyframes shell)

- Unlocks ~71 · complexity **low** · parallelizable: **True**
- Files: `src/parser.rs`, `src/ast.rs`, `src/emit.rs`
- Depends on: Shared statement-evaluator rewrite

Replace the blanket `other => Err(...)` in parse_at_rule (parser.rs:303) with a generic Stmt::AtRule{name, prelude: Vec<TplPiece>, body: Option<Vec<Stmt>>} fallback: parse the interpolated prelude up to `{` or `;`, then optionally a nested block via parse_statements. In eval, evaluate the prelude template and recurse into the body via exec_block, bubbling it out of enclosing style rules to the document root where required (@font-face/@keyframes). emit.rs serializes `@name prelude { ... }` verbatim. Low complexity and high cross-directory yield. Parallelizable in principle (new disjoint Stmt variant + emit path), but its eval body-handling rides on exec_block, so land it just after rank 2; the parser/emit work itself is worktree-isolated.

### 8. @warn / @debug / @error directives

- Unlocks ~19 · complexity **low** · parallelizable: **True**
- Files: `src/parser.rs`, `src/ast.rs`, `src/eval.rs`, `src/error.rs`
- Depends on: Shared statement-evaluator rewrite

Add Stmt::Warn(Expr)/Stmt::Debug(Expr)/Stmt::Error(Expr) and parse_at_rule arms. In eval: @warn/@debug evaluate the expression and write to stderr (the harness discards stderr) producing NO CSS so surrounding rules still emit; @error evaluates and aborts compilation via Error. Trivial, self-contained; lands quickly to recover the directives/libsass/closed @warn fails. Parallelizable: new disjoint Stmt variants with a tiny eval arm, no shared-evaluator rewrite beyond hooking into exec_block.

### 9. @supports rule (parse + serialize the condition, evaluate nested body)

- Unlocks ~94 · complexity **medium** · parallelizable: **True**
- Files: `src/parser.rs`, `src/ast.rs`, `src/eval.rs`, `src/emit.rs`
- Depends on: Unknown / vendor / generic at-rule passthrough

Add Stmt::Supports{condition, body}. parse_at_rule parses the supports condition (declaration(), and/or/not, parenthesized groups, with #{} interpolation) into an interpolated prelude, then a nested block. eval runs the body via exec_block (no bubbling required for most cases); emit serializes `@supports <cond> { ... }`. Largely a special case of generic at-rule passthrough (rank 7) but with structured condition handling. Parallelizable: builds on the rank-7 generic at-rule scaffold in a separate worktree, disjoint from the math/value work.

### 10. @media rule (parse + serialize + bubbling/merge out of style rules)

- Unlocks ~123 · complexity **high** · parallelizable: **False**
- Files: `src/parser.rs`, `src/ast.rs`, `src/eval.rs`, `src/emit.rs`
- Depends on: Shared statement-evaluator rewrite, Unknown / vendor / generic at-rule passthrough

Add Stmt::Media{query, body}. Parse media queries with range/comparison syntax and #{}/$var interpolation in feature expressions. The hard part is eval: a @media nested inside a style rule must BUBBLE its inner rules out to top level wrapped in the (merged) media query, while declarations stay nested — this requires the exec_block output sink to support hoisting a media context and merging nested @media queries (`and`-joining). emit serializes the bubbled @media blocks. High complexity because of the bubbling/merge interaction with the selector-context threading. Sequential-ish: it reshapes how exec_block emits nested output, so coordinate with the evaluator core rather than a fully isolated worktree.

### 11. @at-root (hoist contents to document root, with/without query)

- Unlocks ~70 · complexity **medium** · parallelizable: **True**
- Files: `src/parser.rs`, `src/ast.rs`, `src/eval.rs`
- Depends on: Shared statement-evaluator rewrite

Add Stmt::AtRoot{query, body}. Parse the optional (with:/without:) query (with comment/whitespace tolerance) and a nested block. In eval, run the body via exec_block but reset the parent-selector context to root (or to a base-level parent per the query), so child rules emit at the stylesheet root instead of under the enclosing selector. Depends on exec_block exposing a settable parent-context. Parallelizable once exec_block lands: it manipulates the parent-selector context that exec_block already threads, in an isolated parser/eval arm disjoint from media/value work.

### 12. CSS calc() expression engine (parse inner expression, simplify, incompatible-unit errors) + compound-unit arithmetic and division-as-math

- Unlocks ~380 · complexity **high** · parallelizable: **True**
- Files: `src/parser.rs`, `src/eval.rs`, `src/value.rs`, `src/emit.rs`, `src/error.rs`

Stop treating calc(...) as opaque: parse its interior as a real SassScript/calc expression (+ - * / with a `/` arm finally added to additive/multiplicative, and `%`), build a Calculation value type in value.rs that tracks a numerator/denominator unit list. eval simplifies fully-numeric sub-trees (calc(1px+2px)->3px), preserves un-resolvable parts verbatim, cancels compound units (px*rad/ms), and raises incompatible-unit errors (deg vs s). Add the standalone `/` division operator outside calc with slash-separator preservation and the slash-div deprecation behavior. This also fixes floored-modulo and large-number formatting along the way. Huge unlock (~360 calc + ~436 math fns gated behind it). Parallelizable: it lives in value.rs/eval expression code, disjoint from the statement-evaluator and directive work, so it can run in its own worktree in parallel with ranks 2-11.

### 13. CSS/Sass math functions (min/max/clamp/abs/round/sign/mod/rem/pow/sqrt/exp/log/hypot/sin/cos/tan/asin/acos/atan/atan2/calc-size)

- Unlocks ~440 · complexity **high** · parallelizable: **True**
- Files: `src/builtins.rs`, `src/eval.rs`, `src/value.rs`, `src/parser.rs`
- Depends on: CSS calc() expression engine + division/compound units

Add a match arm per math function in builtins::call (the dispatch already has a clean `_ => plain_css_function` fallback, so additions are isolated). Each evaluates numeric args with unit checking, applies the operation, and simplifies; when an arg is an unsimplifiable calc/var, fall back to verbatim calc() emission. Reuses the Calculation/unit model from rank 12. Largest single bucket (~436). Parallelizable: purely additive builtins.rs arms plus the shared unit model; a clean worktree once the calc engine's Number/unit primitives exist.

### 14. Legacy color-manipulation builtins (adjust-hue, saturate, desaturate, invert, grayscale, complement, opacify/transparentize, scale/adjust/change-color, hue/saturation/lightness getters, ie-hex-str, opacity)

- Unlocks ~198 · complexity **medium** · parallelizable: **True**
- Files: `src/builtins.rs`, `src/value.rs`

Add a dispatch arm per function in builtins::call alongside the existing rgb/hsl/lighten/darken. value.rs already has to_hsl/from_hsl and full f64 channel precision, so most reduce to HSL adjust + clamp or channel getters; add out-of-bounds arg validation that errors. Marked medium not high because the color infrastructure (Color, HSL conversion) already exists — it is mostly filling in arms. Parallelizable: isolated additive builtins.rs work, completely disjoint from the parser/evaluator; ideal standalone worktree.

### 15. Modern CSS Color 4 builtins + space/slash channel syntax (color(), lab/lch/oklab/oklch, hwb, mix in spaces, rgb(r g b / a) / hsl space-slash parsing)

- Unlocks ~308 · complexity **high** · parallelizable: **True**
- Files: `src/parser.rs`, `src/builtins.rs`, `src/value.rs`, `src/eval.rs`
- Depends on: CSS calc() expression engine + division/compound units

Two parts: (a) parser — allow space-separated and `/`-alpha channel syntax inside rgb/hsl/color calls (the tokenizer currently aborts on the `/`); (b) value.rs — extend the Color model with a color-space tag and lab/lch/oklab/oklch/hwb conversions plus `none` channels, and add builtins arms in builtins.rs that validate args (raise too-many/too-few-args errors) and handle special-value (calc/var/attr/NaN) channels by preserving them verbatim. Large unlock but high complexity due to the color-space model rewrite. Parallelizable from the directive track, but the channel-syntax parsing overlaps rank 12's `/` handling — coordinate the parser change; the builtins/value-model parts are worktree-isolated.

### 16. Modern CSS if() conditional function: if(cond: value; else: value) with sass()/css() conditions

- Unlocks ~146 · complexity **high** · parallelizable: **True**
- Files: `src/parser.rs`, `src/eval.rs`, `src/value.rs`, `src/emit.rs`, `src/builtins.rs`
- Depends on: Comparison and logical operators

This is the new CSS conditional if() (distinct from the legacy if() builtin in rank 1): it uses `:` and `;` separators inside the parens which the comma-arg call parser chokes on. Add a dedicated if() grammar in parse_call that recognizes `cond: value; else: value` clauses with sass()/css() condition wrappers, evaluate the first matching condition's value (depends on comparison operators from rank 1), and emit the selected/serialized value. 146 fails concentrated in expressions/if. Parallelizable: a special-cased call parser + evaluator path, isolated to value-expression code; disjoint from the statement evaluator.

### 17. @import enhancements (CSS @import passthrough with url()/media/supports, comment/whitespace tolerance, nested @import, .sass/_index/.import.scss resolution, ordering)

- Unlocks ~170 · complexity **medium** · parallelizable: **True**
- Files: `src/parser.rs`, `src/eval.rs`, `src/emit.rs`, `src/lib.rs`
- Depends on: Shared statement-evaluator rewrite, Unknown / vendor / generic at-rule passthrough

Rework the @import arm (parser.rs:270) to accept url(...) forms, trailing media-query/supports conditions, and comments before/after the URL; classify protocol/.css/conditioned imports as literal CSS @import emitted in source order (fix ordering vs style rules) versus inlined Sass imports. Extend the resolver (lib.rs importer) to find .sass partials, directory _index.{scss,sass}, and apply load-precedence (.import.scss, import-only, partial-vs-normal). Support nested @import by inlining under the current parent via exec_block (eval_rule currently hard-errors at eval.rs:151), hoisting root-only at-rules and exposing parent-scope mixins/functions. Parallelizable mostly (parser + resolver), but nested-import inlining touches exec_block, so do it after rank 2.

### 18. @keyframes rule (special from/to/percent block selectors + bubbling)

- Unlocks ~19 · complexity **medium** · parallelizable: **True**
- Files: `src/parser.rs`, `src/ast.rs`, `src/eval.rs`, `src/emit.rs`
- Depends on: Unknown / vendor / generic at-rule passthrough

Add Stmt::Keyframes{name, blocks} where the inner block selectors (0%, from, to, percentages) are parsed as keyframe selectors NOT normal CSS selectors. name supports #{} interpolation. eval emits a nested at-rule, bubbling it out of any enclosing style rule. Builds on the generic at-rule scaffold (rank 7) with special selector handling. Parallelizable: isolated parser/emit path in its own worktree, disjoint from value/math work.

### 19. Maps ((k: v) literals, map type, lookup, map/list builtins) + named-arg/splat (...) plumbing

- Unlocks ~35 · complexity **high** · parallelizable: **True**
- Files: `src/parser.rs`, `src/value.rs`, `src/ast.rs`, `src/eval.rs`, `src/builtins.rs`
- Depends on: @function / @return, @mixin / @include / @content

Add a Map variant to Value (and an Expr map literal) and parse `(k: v, ...)` — disambiguating maps from parenthesized expressions by the inner `:`. Add map builtins (map-get/keys/values/merge/has-key) and the global list builtins to builtins::call. Add `...` splat handling in call-arg parsing to expand a list/map into positional/keyword args (needed by the callable splat specs and used by @each over maps in rank 4). High complexity due to the new value type threading through eval/emit/equality. Parallelizable: new Value variant + builtins, but the splat plumbing touches the shared call-arg path used by ranks 5-6, so coordinate or sequence after them.

### 20. @extend / %placeholder selectors (selector-extension pass + placeholder dropping)

- Unlocks ~40 · complexity **high** · parallelizable: **True**
- Files: `src/parser.rs`, `src/ast.rs`, `src/eval.rs`, `src/emit.rs`
- Depends on: Shared statement-evaluator rewrite

Add Stmt::Extend(selector) and parse %placeholder selectors. Implement a post-eval extension pass that, for each @extend, rewrites every ruleset whose selector list contains the extended selector to also include the extending selector (handling compound/nested-at-rule cases and :is()/:where() special serialization). Drop %placeholder rules from output unless they were extended. High complexity (a whole selector-graph pass) for modest direct unlock; ranked low because nothing else depends on it. Parallelizable: a self-contained extension pass operating on the emitted selector model, disjoint from the value engine.

### 21. Custom property (--var) raw-value preservation + nested property sets (a: { b: c } -> a-b: c)

- Unlocks ~33 · complexity **medium** · parallelizable: **True**
- Files: `src/parser.rs`, `src/ast.rs`, `src/eval.rs`, `src/emit.rs`

For declarations whose property starts with `--`, preserve the value text verbatim (only resolving #{} interpolation), keeping empty/whitespace/!/multiline content instead of running it through value parsing. Separately, parse a declaration whose value is a `{...}` block as a nested property set that namespaces children with the parent name (`b: {c: d}` -> `b-c: d`), plus the trailing-value-plus-block form. Both are localized declaration-parser changes. Parallelizable: isolated parser/emit declaration handling in its own worktree.

### 22. Backslash escape sequences in identifiers/unquoted values + quoted-string escape normalization on emit

- Unlocks ~97 · complexity **high** · parallelizable: **True**
- Files: `src/scanner.rs`, `src/parser.rs`, `src/value.rs`, `src/emit.rs`

Scanner/parser: consume CSS/Sass escape sequences (\\, \1, \0, \a, \41, line-continuations, unicode hex escapes) in identifier and unquoted-value positions instead of erroring on `\`. Emit: normalize string escapes per quoted-vs-unquoted context (\#{ -> #{, collapse/preserve \\, render \41 numeric escapes), so output matches dart-sass char-for-char. Also fixes adjacent/same-type-nested quoted strings (string schema parsing). Large parser-cluster unlock (~97 in the parser dir). Parallelizable: lexer + emit normalization, disjoint from the statement evaluator and value math; clean worktree.

### 23. Strict-whitespace +/- string concatenation, '-' string-join semantics, and comments inside value expressions

- Unlocks ~56 · complexity **medium** · parallelizable: **True**
- Files: `src/parser.rs`, `src/eval.rs`, `src/scanner.rs`

additive() (parser.rs:463) currently requires whitespace on BOTH sides of +/-, so c+d / c +d / c-(d) leave the operator unconsumed. Relax the rule to Sass semantics (consume the operator and apply string-concat / subtraction-as-join when operands are non-numeric) and fix unary-minus disambiguation. In eval.rs num_binop, make '-' on non-numbers join idents as 'a-b' instead of 'Undefined operation'. Make skip_ws_inline (parser.rs:109) also skip /* */ block comments so `c /**/+/**/ d` parses. Parallelizable: confined to the value-expression parser/eval, disjoint from directives; pairs naturally with rank 12's `/` work in the same worktree.

### 24. Special CSS function verbatim handling (vendor-prefixed/uppercase calc/url/element, comments & special chars inside), alpha()/expression() IE hacks, and selector emit/validation fidelity

- Unlocks ~171 · complexity **medium** · parallelizable: **True**
- Files: `src/parser.rs`, `src/value.rs`, `src/emit.rs`, `src/eval.rs`

Broaden parse_call's verbatim-function set to match vendor-prefixed (-a-calc), uppercase (URL/-A-CALC, lowercasing the name), element(), and tolerate /* */ and special chars (!, =) inside; this also recovers alpha(opacity=x)/expression() IE hacks. Separately tighten/fix the selector layer: reject invalid selectors that must error (bad attribute modifiers, leading/trailing combinators, misplaced &), correctly serialize escapes (\24, \41), break comma selector lists one-per-line in expanded mode, shorten #aabbcc->#abc, unquote attribute values, and normalize :nth() whitespace. A heterogeneous medium-complexity cluster of output-fidelity and error-detection fixes. Parallelizable: parser/emit/selector code, isolated from the evaluator and math engine.

## Appendix — per-directory failure buckets

### values — 892 fail / 1068 attempted

- **CSS math functions (min/max/clamp/abs/round/sign/mod/rem/pow/sqrt/exp/log/hypot/sin/cos/tan/asin/acos/atan/atan2/calc-size)** (~436, high): all named CSS/Sass math functions are passed through opaquely instead of being evaluated or simplified; no builtin implementations exist, and argument/unit errors are not raised
- **CSS calc() expression engine (simplify + unit-incompatibility errors)** (~359, high): sasso treats calc(...) as an opaque pass-through function: it never parses the inner expression, so it can neither simplify (calc(1px + 2px) stays verbatim instead of 3px) nor detect incompatible units and error
- **Slash division as math (/ operator outside calc, incl. (1/2) -> 0.5)** (~26, medium): sasso explicitly does not support division; '/' in a value either parse-errors ('unexpected character /') or fails to reduce, and it does not emit the slash-div deprecation warnings or produce numeric results
- **Color equality (==) and modern color() syntax** (~24, high): the == operator is unsupported ('unexpected character =') so color equality never evaluates to true/false; cases also use modern color-space syntax (color(), lch(), hwb(), none) that the color model does not parse
- **Compound unit arithmetic / cancellation (numerator/denominator units)** (~16, medium): multiplication/division of numbers with multiple units (e.g. px*rad/ms/Hz) requires tracking numerator/denominator unit lists and cancelling them; these cases are expressed via calc() and inherit the missing calc engine plus a richer unit model in value.rs
- **Bracketed lists ([a b]) and list equality** (~10, medium): the value parser rejects '[' ('unexpected character [') so bracketed list literals cannot be represented or emitted, and list == comparison is unsupported
- **Large-number / double formatting and bounds clamping** (~9, medium): very large numeric literals overflow to 'inf' instead of being parsed as f64 and printed in plain decimal; max_value/precision boundary cases mis-format, so number emission needs f64-accurate parsing and printing
- **Sass floored modulo semantics (result takes divisor sign)** (~8, low): the % operator uses Rust's truncated remainder (result takes dividend sign); Sass uses floored modulo so a negative divisor must yield a result with the divisor's sign (1.2 % -4.7 -> -3.5, sasso gives 1.2)

### css — 729 fail / 1031 attempted

- **@supports rule (parse + serialize, no bubbling needed for most)** (~94, medium): parser.rs parse_at_rule() hard-rejects every at-rule except @import/@charset with '@supports is not supported in this build'; sasso has no @supports statement at all.
- **Special CSS functions (calc/url/element/-prefix-/uppercase) verbatim handling** (~80, medium): parse_call() only treats a fixed lowercase set (url\|calc\|clamp\|var\|env\|min\|max) as verbatim; it does not match vendor-prefixed (-a-calc), uppercase (URL/-A-CALC, which must lowercase the function name), element(), or tolerate /* */ comments and special chars (! in url) inside, so it errors or emits wrong case.
- **Plain CSS @import (url(...) with media/supports conditions, .css/protocol URLs)** (~69, medium): parse_at_rule() @import branch only accepts a bare quoted string for inlining and errors ('expected a string after @import') on url(...) form, trailing media-query/supports conditions, and protocol/.css URLs that must be emitted as a literal CSS @import rather than inlined.
- **@media rule (parse + serialize + media-query bubbling/merge)** (~61, high): parse_at_rule() rejects @media outright; needs a media statement, nesting-aware bubbling out of style rules, and query merging in eval/emit.
- **@mixin / @include / @content** (~59, high): No mixin support; parse_at_rule() rejects @mixin/@include/@content, so every case using them errors at parse time. Needs definition storage, argument binding (incl. keyword args, defaults, rest), and @content block injection.
- **@function / @return (user-defined functions)** (~52, high): No user function support; parse_at_rule() rejects @function/@return. Needs function definitions, arg binding (keyword args, defaults), a return mechanism, and call dispatch that prefers user functions over builtins.
- **Misc value/parser edge cases (lone %, division as math, a few builtins, scss-tests format quirks)** (~51, low): Long tail: lone '%' token in a value errors ('a {b: c %}'), '/' as division/value-separator mishandled, a couple of builtin functions missing, plus assorted non_conformant/scss-tests output-format mismatches (unary ops, unicode idents, number/string formatting). Low-complexity, heterogeneous.
- **Control flow @if/@else/@each/@for/@while** (~46, high): parse_at_rule() rejects all control-flow at-rules; no conditional/loop evaluation exists. Depends on comparison/logical operators landing too. Many of these css-scope hits are whitespace/comment variants around the directive keywords.

### core_functions — 562 fail / 771 attempted

- **Legacy color-manipulation builtins (adjust-hue, saturate, desaturate, invert, grayscale, complement, opacify/fade-in, transparentize/fade-out, scale-color, adjust-color, change-color, hue/saturation/lightness getters, ie-hex-str, opacity)** (~198, high): builtins::call has no arm for these names so they fall through to plain_css_function() and are emitted verbatim instead of being computed (and out-of-bounds args never error).
- **Special-value (calc/var/attr/NaN/Infinity) channel arguments to color functions** (~112, high): builtins::num() rejects non-Number values ('calc(NaN) is not a number'); rgb/hsl/color cannot accept a calc()/var()/attr() arg that should be preserved verbatim or treated as a degenerate (clamped) channel, so the whole call errors rc=1.
- **CSS Color 4 color-space functions (color(), lab/lch/oklab/oklch, hwb, mix() in color spaces, relative color() from ...)** (~106, high): These functions are unimplemented and fall through to plain_css_function(), so they are emitted verbatim, never validate args (should error), and mix() ignores extra/space args.
- **CSS Color 4 space/slash channel syntax for color functions: rgb(r g b / a), hsl(h s l / a), color(srgb r g b / a)** (~90, high): parse_value tokenizer hits the '/' (and bare space-separated channels) inside a color call and aborts with 'unexpected character /'; sasso only parses comma-separated legacy color args.
- **Global builtins for sass:list / sass:map / sass:string / sass:math / sass:meta / sass:selector modules (length, nth, index, join, map-get, keys, str-length, abs, type-of, inspect, etc.)** (~44, high): None of these global functions are registered in builtins::call; they pass through verbatim (or error on map literal '(k: v)' which the parser cannot parse).
- **Global Sass math.min / math.max functions** (~4, medium): min/max are treated by the parser as verbatim CSS math functions (kept literal) and never evaluated as Sass numeric builtins, so trailing-comma / modulo arg forms are not folded to a single value.
- **Named-argument channel forms for rgb/hsl ($channels:, $color:+$alpha:)** (~3, medium): fn_rgb/fn_hsl require positional $red/$hue and do not recognize the special $channels / $color / $alpha named-only signatures, so they error 'Missing argument $red'.
- **Legacy IE alpha() filter passthrough (alpha(opacity=d))** (~2, low): parser cannot parse '=' inside a function argument list, so alpha(c=d) errors 'expected )' instead of being emitted verbatim as a plain CSS function.

### libsass — 394 fail / 549 attempted

- **@mixin / @include / @content** (~56, high): Mixin definition, invocation, args/defaults, and @content blocks are entirely unimplemented; parser rejects or eval drops these rules so nothing emits.
- **Selector/emit format fidelity (multi-selector one-per-line, hex shortening, attr-value unquoting, nth-child normalization, nested-property names)** (~49, medium): Compiles successfully but output differs from dart-sass: comma selector lists not broken onto separate lines in expanded mode, #aabbcc not shortened to #abc, attribute selector values not unquoted, whitespace inside :pseudo()/nth args not normalized, plus a math sign/precedence bug.
- **@media bubbling / nesting / hoisting** (~31, high): @media is not parsed/bubbled: nested rules inside @media, media inside selectors, variable interpolation in queries, and media hoisting are unsupported, so blocks are dropped or rejected.
- **@at-root (incl. base-level-parent resolution)** (~30, high): @at-root directive (with/without query, selector, parent-ref interaction) is unimplemented; the nested block is not lifted to the document root.
- **@function / @return** (~29, high): User-defined functions and @return are unimplemented; calls to them are emitted verbatim or the definition is rejected, so results mismatch or compilation errors.
- **Division as math + cross-unit arithmetic** (~28, medium): '/' inside values is rejected ('unexpected character / in value') instead of being parsed; sasso lacks division and cannot do unit conversion (s/ms, deg/grad, in/cm) or px*in multiplication.
- **Missing error detection (should reject, but compiles)** (~26, medium): 26 specs expect a hard error (invalid syntax, bad imports, illegal nesting, duplicate keyframe/selector rules) but sasso compiles them successfully, so the harness marks FAIL.
- **Unknown / CSS at-rules (@font-face, @charset, @keyframes, @supports, arbitrary @foo)** (~22, medium): Any at-rule outside the small known set hits 'X is not supported in this build'; @keyframes, @supports, @font-face, @charset and unknown directives must be parsed and passed through (with nested-block handling for @supports/@keyframes).

### libsass-closed-issues — 289 fail / 405 attempted

- **Output mismatches (interpolation-in-selector, hex spelling, nested props, &-edge-cases, escapes, comment/whitespace formatting)** (~46, medium): Cluster of behavior/format gaps: #{} inside attr/url/comment selectors not evaluated (#{&}, #{$x}), authored hex spelling not preserved (#F00->#ff0000), nested property blocks (border:{width}), lone/leading/trailing/repeated & mis-resolved, string-escape unescaping, and comment placement/whitespace normalization.
- **@mixin / @include / @content** (~40, high): Parser hard-rejects @mixin/@include/@content at-rules ('@mixin is not supported in this build'); no AST node, scoping, arg binding, or @content slot exists.
- **@media (and nested media)** (~30, high): @media is rejected at parse time; need to parse media queries (with interpolation), keep them as bubbling at-rule blocks, and emit them, including when nested inside selectors.
- **@function / @return** (~27, high): @function/@return rejected at parse; no user-function definition table, return semantics, or call dispatch into user functions during value eval.
- **Value/declaration parser robustness (escapes, IE hacks, custom-prop-ish values, nested-property collision)** (~27, high): parse_value/parse_declaration choke on legal value tokens it does not model: CSS escapes like '\9'/'\a', progid:/filter, font shorthand 'x/y', interpolation 0/0, '&' in value, unterminated-looking strings — surfaces as 'expected ":" in declaration' / 'expected "}"' / 'unexpected character'.
- **Slash handling in values (division-as-math + slash-separated shorthand)** (~19, medium): Value tokenizer rejects any '/' in a value ('unexpected character / in value'), blocking division math ((a/b)), slash-separated CSS shorthand (font/background '2rem 3rem / auto'), and slashes in unquoted tokens.
- **Error/validation specs (invalid selectors, bad/undefined fn calls, import cycles)** (~19, medium): sasso compiles inputs that dart-sass rejects: malformed id/pseudo selectors (#2, a:nth-child()), undefined function calls, builtin arg-count/type errors, import cycles, top-level interpolation-only selectors — no validation pass to raise these errors.
- **Generic / unknown plain at-rules passthrough (@font-face, @document, @page, @charset, vendor/custom @foo)** (~15, medium): Any at-rule not explicitly handled is rejected ('@foo is not supported in this build') instead of being emitted verbatim with its block; sasso has no generic at-rule passthrough.

### directives — 275 fail / 335 attempted

- **@use / @forward module system (incl. import-to-forward, configuration via `with`, .import.scss)** (~52, high): sasso has no module system: @use/@forward error out, and @import cannot pick up members forwarded/configured through module files or .import.scss shims.
- **@for loops** (~34, medium): @for from/to/through is rejected outright ('@for is not supported in this build'); need range iteration with a scoped loop variable.
- **@function / @return** (~31, high): @function definitions and user-function calls (plus top-level/edge @return) are rejected ('@function is not supported'); need function storage, arg binding, @return, name normalization, and special non-callable names (calc/clamp/url/and/or/not/expression/element).
- **@import parsing: comments, whitespace, modifiers, CSS-import passthrough/ordering** (~31, medium): @import statement parser only accepts a bare quoted string: a comment/whitespace before the URL errors, a comment after the URL leaks into output, import modifiers (supports()/url()/media) aren't parsed, and CSS @import ordering/conflict detection is wrong.
- **@mixin / @include / @content** (~30, high): @mixin definitions and @include calls are rejected ('@mixin is not supported in this build'); need mixin storage, argument binding, @content blocks, and using(...) arglists.
- **@at-root** (~25, medium): @at-root is rejected ('@at-root is not supported in this build'); need to hoist contents to the document root, plus the (without:/with:) query parser and its comment/whitespace handling.
- **@if / @else / @else if** (~21, medium): @if/@else are rejected ('@if is not supported in this build'); need conditional evaluation, which also depends on comparison/logical operators (and/or/not) for the conditions.
- **@extend / placeholder selectors** (~14, high): @extend is rejected ('@extend is not supported in this build'); need a selector-extension pass that rewrites the extended ruleset's selector list, including within nested at-rules.

### parser — 184 fail / 241 attempted

- **Quoted-string escape normalization in emit (\#{ -> #{, \\ collapsing, \41 CSS escapes)** (~49, medium): Emitter does not normalize string escapes: keeps literal '\#{' instead of '#{', and fails to collapse/preserve backslash escapes per quoted vs unquoted context, so output diverges char-for-char
- **Backslash escape sequences in identifiers and unquoted values (lexing)** (~48, high): Scanner/parser rejects '\' in value position (\\, \1, l\\ite\ral, \0, \a) with 'unexpected character' instead of consuming CSS/Sass escape sequences
- **Whitespace/quote emission semantics in interpolation lists (low-complexity output format)** (~30, medium): Pure output-format divergence: space/comma list spacing and quote-style around interpolated unquoted strings differ from Sass even though parsing succeeds
- **Adjacent / same-type-nested quoted strings (string schema parsing)** (~24, high): Parser cannot handle two quoted strings touching with no whitespace ("["'foo'"]") nor a same-type quote nested inside interpolation; it ends the string early or errors 'expected ":" in declaration'
- **Comparison operators == and != (and logical and/or/not)** (~10, medium): Lexer/parser has no token for == != and treats them as 'unexpected character =', and 'and'/'or'/'not'/'<'/'>' are not parsed as operators
- **Subtraction / unary-minus disambiguation and addition string concat** (~7, high): sasso mis-parses ambiguous '-'/'+' (e.g. 10-10 yields stray '-10' declarations; literal+$var concatenation 'literal$input' errors 'expected : after variable name')
- **Missing-identifier error specs (empty %placeholder, double-escaped selector)** (~7, low): Specs expect a compile error (bare '%' placeholder must report 'Expected identifier'; some 44_selector double-escape cases are error specs) but sasso compiles them successfully or mismatches selector escape output
- **Division as a math operator** (~4, medium): '/' in value position errors with 'unexpected character /'; sasso never handles slash division (10/10) the way Sass does, both as math and as a literal slash list separator

### expressions — 149 fail / 220 attempted

- **Modern CSS if() conditional function: if(cond: value; else: value)** (~146, high): sasso parses if(...) as an ordinary comma-arg function call and errors on the inner ':' and ';' tokens; it has no grammar or evaluator for the new CSS conditional if() syntax with sass()/css() conditions.
- **@media range syntax with SassScript and comparison operators (< = >) inside media queries** (~1, high): sasso lacks media-query range/comparison-operator parsing and variable+arithmetic resolution inside media query feature expressions, so it cannot reduce e.g. @media ($width < 500px + 100px).
- **Legacy Sass if($cond, $true, $false) function plus @function/@return and string '+' inside url()** (~1, high): Case combines several unsupported features: the old 3-arg if() builtin, user-defined @function/@return, and string concatenation, all evaluated inside url(); none are implemented so compilation errors.
- **Unknown/unsupported generic at-rule with raw expression prelude passthrough (@foo $x $y, hux { ... })** (~1, medium): sasso hard-rejects unrecognized at-rules ('@foo is not supported in this build') instead of emitting them verbatim with their prelude and nested block; it has no generic/unknown at-rule passthrough path.

### callable — 45 fail / 53 attempted

- **@function / @return (user-defined functions)** (~25, high): Parser rejects @function at parser.rs:303 ('@function is not supported in this build'); no AST node, parameter-list parsing, scope binding, or @return evaluation exists.
- **@mixin / @include (user-defined mixins)** (~18, high): Parser rejects @mixin/@include at parser.rs:303; no AST node, parameter/argument-list parsing, or body-inlining-with-arg-binding evaluation exists.
- **Splat (...) argument expansion + bracketed list literals in calls** (~2, medium): Value parser errors on '[' (bracketed list literal not supported) and there is no '...' splat handling to expand a list into positional args for a call like rgb([1, 2]..., 3); both function-splat error specs are success specs that emit warnings, so sasso aborts.

### operators — 29 fail / 31 attempted

- **'/' division / slash-separator operator entirely missing** (~7, high): No '/' arm exists in additive()/multiplicative(), so any '1/2', 'calc(1)/2', '1/ / /bar' leaves the '/...' unconsumed and the declaration parser reports 'expected :'; needs slash-separator value preservation (e.g. 1/2 -> 1/2).
- **Binary '-' operator: string-concat semantics + strict-whitespace parsing** (~6, medium): Sub on non-numbers errors 'Undefined operation' (eval.rs num_binop) instead of joining idents as 'a-b', and the additive parser only consumes '-' when whitespace exists on BOTH sides, so 'c-(d)'/'c -(d)'/'(c)-(d)' leave '-' unconsumed -> 'expected :'.
- **Comments (/* */) inside value expressions** (~6, low): skip_ws_inline() (parser.rs:109) skips only whitespace, not block comments, so 'c /**/+/**/ d' hits '/' as an unexpected character mid-expression.
- **Binary '+' operator: strict-whitespace parsing blocks string concatenation** (~5, low): binary_add already concatenates strings, but additive() requires whitespace on both sides of '+', so 'c+d' and 'c +d' fail to parse and leave '+d' as a stray token -> 'expected :'.
- **calc() evaluation with infinity/NaN and modulo semantics** (~4, high): calc() is parsed as an opaque function and '%' only operates on plain numbers; '1px % calc(infinity*1px)' needs calc evaluation, infinity recognition, and IEEE modulo rules (x % inf = x, x % -inf -> NaN emitted as 'calc(NaN * 1px)').
- **Comparison (> ==) and logical operators with @function/@return** (~1, high): '$x > $y == getResult()' requires '>' and '==' comparison operators plus @function/@return, none of which sasso implements; parse/eval fails.

### variables — 17 fail / 30 attempted

- **Comments (/**/ and //) adjacent to variable colon/value** (~6, low): The value/variable-name parser does not skip loud (/**/) or silent (//) comments before the colon, after the colon, or after the value, so it errors on the comment char.
- **Parent selector '&' as a value expression** (~6, medium): `$bar: &;` (and content: $bar / #{$bar}) is unsupported: the value parser rejects '&', so a stored selector value and its serialization (comma-joined, nested-resolved) is missing.
- **Non-ASCII (Unicode) characters in variable names** (~2, low): The identifier/variable-name lexer only accepts ASCII word chars, so '$vär' fails with 'expected ":" after variable name'.
- **@mixin / @include with variable scoping** (~1, high): @mixin definition and @include invocation are unsupported, and the case also exercises mixin-local vs outer-scope variable resolution; sasso errors at parse.
- **@if control flow with semi-global variable scoping** (~1, high): @if/@else are unsupported; the case sets $a inside nested @if blocks and reads it after, requiring control-flow plus correct (non-leaking) local scoping.
- **@media directive with interpolation and variable-in-feature-query** (~1, high): @media is explicitly unsupported ('@media is not supported in this build'); the case also needs #{} in the query and a variable used as a media feature ($var: $val).


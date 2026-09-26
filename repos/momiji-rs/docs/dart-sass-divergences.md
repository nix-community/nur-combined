# Known divergences from dart-sass

sasso aims for byte-for-byte parity with dart-sass. This file lists every
divergence we currently know about, so that "99.9% compatible" has a checkable
meaning rather than being a number without a denominator.

**Reference version: dart-sass 1.104.1.** Every row below was produced by
running both compilers on the same input. Where a row says "dart", that is the
observed output of 1.104.1 — not a reading of the specification.

Last verified in bulk: 2026-09-17; a row added or re-measured after that carries
its own date, and the bulk date is not a claim about it. The ones that need
design work or affect compiled output are tracked as issues
([#62](https://github.com/momiji-rs/sasso/issues/62),
[#63](https://github.com/momiji-rs/sasso/issues/63),
[#64](https://github.com/momiji-rs/sasso/issues/64),
[#66](https://github.com/momiji-rs/sasso/issues/66),
[#139](https://github.com/momiji-rs/sasso/issues/139),
[#147](https://github.com/momiji-rs/sasso/issues/147),
[#148](https://github.com/momiji-rs/sasso/issues/148)); the rest live here, and
are fixed as they come up.

## Where we stand

| measurement | result |
|---|---|
| [sass-spec](https://github.com/sass/sass-spec) suite | **14,114 / 14,258 attempted (98.99%)**, ratcheted in CI — 98.93% of all 14,266, the other 8 being cases tagged `:todo` for dart-sass itself |
| Lichess (lila) corpus, 148 entry points, `--style=expanded` | **147 / 148 byte-identical** |
| the same corpus, `--style=compressed` | **147 / 148 byte-identical** |
| the same corpus, source maps (`--embed-sources`) | **148 / 148 byte-identical** |

The one differing file in both styles is `learn.css`; see
[Deliberately not followed](#deliberately-not-followed).

## How to reproduce a row

```sh
# Pin the oracle: a bare `sass` on PATH is whatever is installed, and a future
# release would silently change every comparison below.
npm install sass@1.104.1 --prefix /tmp/dart1104
DART=/tmp/dart1104/node_modules/.bin/sass

printf '@use "sass:color";\n.a { b: %s; }\n' '<expression>' > t.scss
"$DART" --no-source-map t.scss
sasso   --no-source-map t.scss
```

`tests/parity.rs` runs every expectation in this repo against a real dart-sass
binary when `SASSO_PARITY=1 SASS_BIN=<path>` is set, so an expectation cannot
silently drift away from the reference.

### Which dart-sass 1.104.1?

There are two, and they do not agree about everything. `npm install sass` gives
the **dart2js** build; the GitHub release archives, `brew install sass` and the
standalone installers give the **native** one. Every measurement in this repo
is taken against the npm build, which is what the snippet above pins — so where
the two differ, a row here describes the dart2js answer unless it says
otherwise.

Swept on 2026-09-24 over **22 commands in two groups**, because output that
contains a clock cannot be compared the same way as output that does not.

**Group 1 — 19 commands, compared by exact equality.** Compile to stdout, parse
error, eval error, missing dependency, `@warn`, `@debug`, color output,
`math.div`, `--style=compressed`, `--indented`, `--help`, a bad flag, a bad
pair, a missing file, source maps, `--embed-sources`, `--quiet`, `--stdin`,
`--version`. **Three differ, from two causes:**

| | native | dart2js (npm) |
|---|---|---|
| `--version` | `1.104.1` | `1.104.1 compiled with dart2js 3.13.3` |
| a file it cannot read | `Error reading x.scss: Cannot open file.` | `Error reading x.scss: no such file or directory.` |

(Two of the three are the same cause: `a:b:c:d` and a plainly missing file both
fail to open something.) The second row is dart2js surfacing Node's `errno`
string where the VM prints Dart's own `FileSystemException` message. **sasso
matches the native build** there, on both front ends — so a comparison against
the npm build reads as a divergence and is not one:

```
  dart native    Error reading no-such.scss: Cannot open file.
  dart npm       Error reading no-such.scss: no such file or directory.
  sasso binary   Error reading no-such.scss: Cannot open file.
  sasso npm      Error reading no-such.scss: Cannot open file.
```

**Group 2 — the 3 `--update` commands**, kept separate because the one that
narrates prints a clock, and no by-equality sweep can include that: the two
runs happen at different instants, so the line always differs. Compared with
any stamp masked to `[STAMP]`, and the stamp's own shape reported separately:

```
  --update (writes a file)   same once masked   native [NNNN-NN-NN NN:NN:NN]
                                                npm    [NNNN-NN-NN NN:NN]
  --update --quiet           same               no output at all
  --update (to stdout)       same               refused, identically
```

Only the first actually carries a stamp, for two different reasons worth
knowing before reproducing this: `--quiet` suppresses the narration outright,
and `--update` to stdout is refused by both builds with `--update is not
allowed when printing to stdout.` (Narration is an `--update`/`--watch`
behaviour in the first place — a plain compile to a file prints nothing.)

So the **third** cause, and the only one that ever affected compiled-adjacent
output: dart-sass truncates `DateTime.now().toString()` by a fixed seven
characters — right for the VM's six microsecond digits, one field too many for
dart2js's three. sasso had matched the truncation; it prints
`[YYYY-MM-DD HH:MM:SS]` now, like the native build
([#190](https://github.com/momiji-rs/sasso/issues/190)). `--watch` narrates
through the same code path and is not separately swept because it does not
terminate.

Reproduction trap, since it produced a wrong answer the first time: give each
binary its **own** directory. `--update` narrates only when it actually writes,
so a shared directory lets the first run satisfy the second, which then prints
nothing and looks like a difference.

Everything else in both groups was byte-identical, so the npm build remains a
sound oracle for output — just not for I/O error text, the version banner, or
the timestamp.

---

## 1. Compiled output

These change the bytes a build emits. All of them are absent from the Lichess
corpus, which is why it still measures 147/148.

### 1.1 A literal property inside a custom `@function --foo()` is not evaluated

```scss
@function --foo() { q: 1 + 2; }
// dart:  q: 3;
// sasso: q: 1 + 2;
```

dart parses the body of a custom-property-named function as SassScript, with
exactly one exception: a declaration whose plain name is `result` (case-
insensitively) is kept verbatim, because that is the function's return value.
`result: 1 + 2` is `result: 1 + 2` in both, and `#{result}: 1 + 2` — which has
no plain name — is `result: 3` in both. It is every OTHER property that
diverges.

### 1.2 A degenerate calculation inside `@supports` is evaluated instead of preserved

```scss
@supports (a: lab(calc(infinity) 1 2)) { a { b: c } }
// dart:  @supports (a: lab(calc(infinity) 1 2))
// sasso: @supports (a: lab(100% 1 2))
```

### 1.3 `meta.call()` with an unknown name compiles instead of erroring ([#63](https://github.com/momiji-rs/sasso/issues/63))

```scss
@use "sass:meta";
.a { b: meta.call("nope"); }
// dart:  Error: () isn't a valid CSS value.
// sasso: emits `nope()` into the CSS, no error
```

### 1.4 `@charset`'s argument is interpolated instead of taken literally

```scss
@charset "#{$nope}";
// dart:  compiles — the argument is a plain string, never interpolated
// sasso: Error: Undefined variable.
```

dart reads it with `string()`, not `interpolatedString()`, so `#{` inside the
quotes is ordinary text in **both** syntaxes; the value is discarded either way,
because the output's own `@charset` is re-derived from its content. sasso parses
it as an interpolated string, which turns a body dart never evaluates into an
error — `Interpolation isn't allowed in plain CSS.` in a `.css` file, and
whatever the expression itself raises in a `.scss` one. Measured 2026-09-21.

## 2. Values and built-in semantics

A wrong value, or a missing error, rather than a wrong message.

| input | dart-sass 1.104.1 | sasso |
|---|---|---|
| `rgb(1, 2, 3, $nope: 4)` ([#62](https://github.com/momiji-rs/sasso/issues/62)) | `No parameter named $nope.` | returns `rgb(1, 2, 3)` |
| a built-in argument passed twice — `color.mix(red, blue, 10%, $color1: green)` ([#147](https://github.com/momiji-rs/sasso/issues/147)) | `Argument $color1 was passed both by position and by name.` | the positional wins and the call succeeds, so a stylesheet dart rejects compiles. Every family bar one: `map.remove` alone is checked, by hand, and names the wrong parameter (§3). dart raises this from its per-parameter loop, before `Missing argument`, before the positional-count error and before an unknown name, and raises it even when the declaration has a rest parameter. A *user* callable is rejected, with the wrong message (§3) — unless it declares a rest parameter, where the call compiles here too. Measured 2026-09-19 |
| `meta.function-exists("rgb", $module: "m")`, `m` being any module ([#148](https://github.com/momiji-rs/sasso/issues/148)) | `true` — a name the module does not have still resolves against the *global* built-ins, in a user module and a built-in one alike (`quote` with `$module: "color"` is `true` too) | `false`. A module-only member (`channel`) and a user global (`local`) are `false` in both, so it is the globals table specifically. Measured 2026-09-19 |
| `meta.function-exists("unique_id")` ([#148](https://github.com/momiji-rs/sasso/issues/148)) | `false` — dart matches a *built-in* name against the string exactly as given | `true`. sasso normalizes `_` to `-` for the built-in half as well as the user half; dart normalizes only the user half, where both spellings do resolve in both. Adjacent: a user `@function my_under` captured by `meta.get-function("my_under")` inspects as `get-function("my-under")` in dart (the callable's own name) and `get-function("my_under")` in sasso. Measured 2026-09-19 |
| `meta.inspect(33.333333333333336%)` | `33.333333333333336%` | `33.3333333333%` |
| `meta.inspect(color.hwb(0, calc(-infinity * 1%), 40%, 0.5))` | `hwb(0 calc(-infinity)% 40% / 0.5)` | `hwb(0 -Infinity% 40% / 0.5)` |
| `color.change(red, $red: calc(NaN))` | `hsl(0, 0%, 0%)` | `black` |
| `color.change(red, $saturation: calc(infinity))` | `hsl(0, 0%, 0%)` | `hsl(0, calc(infinity * 1%), 50%)` |

The first row has the widest blast radius: an unknown **named** argument is
silently ignored by every built-in, so a typo in an argument name compiles
instead of erroring. Fixing it needs a required-vs-optional split for all 48
built-in parameter lists, because dart's precedence is "a required parameter
still unbound wins with `Missing argument`" while an unbound *optional*
parameter does **not** suppress the unknown-name error.

The `meta.inspect` precision row is wide in a different way: it is every
fractional number under `inspect`, and `inspect` output appears throughout the
sass-spec expectations.

### The comma form of `color.hwb()` reports three diagnostics differently

The space form matches; only the legacy comma form diverges, and it does so in
three distinct ways, so each is given its own input:

```scss
color.hwb((1 2), 10%, 20%)
// dart:  Expected hue channel to be a number, was (1 2).
// sasso: $channels: Expected hue channel to be a number, was (1 2).

color.hwb(0, 10%, 20%, (1 2))
// dart:  (1 2) is not a number.
// sasso: $alpha: (1 2) is not a number.

color.hwb(0, 10%)
// dart:  Only 1 argument allowed, but 2 were passed.
// sasso: $channels: The hwb color space has 3 channels but (0 / 10%) has 1.
```

The third is not a wording difference: with two arguments dart binds the call
to the *modern* single-`$channels` overload and reports its arity, where sasso
stays on the comma form and complains about the channel count.

## 3. Diagnostics

Message text or span geometry. The compiler accepts and rejects the same
programs; only what it prints differs.

| input | dart-sass 1.104.1 | sasso |
|---|---|---|
| `string.index("abc" "b", "x")` ([#139](https://github.com/momiji-rs/sasso/issues/139)) | `$string: ("abc" "b") is not a string.` | `$string: "abc" "b" is not a string.` |
| a stray `}` after a complete rule | `unmatched "}".` | `unexpected "}"` |
| `red(#abcdef, 1)` | `Only 1 argument allowed, but 2 were passed.` | the same error, preceded by a `[global-builtin]` deprecation warning |
| `@mixin m($x )` included with no argument | `Missing argument $x .` — dart takes the name from the parameter's own span text, which swallowed the trailing space | `Missing argument $x.` |
| `color.grayscale(null)` ([#139](https://github.com/momiji-rs/sasso/issues/139)) | `$color: null is not a color.` | ` is not a color.` — the `$param: ` prefix is missing, and `null` prints as nothing. The same for `true`, a map, and a quoted string; a list additionally needs dart's parenthesized spelling (`$color: (1 2) is not a color.`), which is the row above's root cause too. The prefix alone accounts for 46 byte-mismatching sass-spec cases. Measured 2026-09-18, re-measured 2026-09-19 |
| a user callable given one argument twice — `@function f($a, $b)` called as `f(1, 2, $a: 3)` ([#147](https://github.com/momiji-rs/sasso/issues/147)) | `Argument $a was passed both by position and by name.`, as a single span | `No parameter named $a.`, with the two-span `declaration`/`invocation` frame. The built-in half of #147 is in §2, because there the call compiles. Measured 2026-09-19 |
| `map.remove((c: d, e: f), c, $key: e)` ([#147](https://github.com/momiji-rs/sasso/issues/147)) | `Argument $key was passed both by position and by name.` — the parameter bound positionally | `Argument $keys was passed both by position and by name.` — the name of the `$keys...` rest. The one place sasso implements this check at all, hand-rolled in `map.rs`. Measured 2026-09-19 |
| `@mixin --a { b: c }` in a `.css` file | `This at-rule isn't allowed in plain CSS.`, spanning `@mixin --a` | `Sass @mixin names beginning with -- are forbidden for forward-compatibility with plain CSS mixins.` — the message for the SCSS spelling, and a one-column caret. dart carves `--` out for `@function` but not for `@mixin`, so plain CSS has custom functions and no custom mixins. Measured 2026-09-21 |
| `a { b: if(media(x, 2, 3) }` | `expected ":".` at the `}` — once dart has read a raw token it requires a clause, and only a `,` sends it back to the legacy `if($c, $t, $f)` grammar | `expected ")"` at the same position — sasso attempts the modern grammar, and on ANY error rewinds and lets the legacy argument parse report instead. Plain-CSS interpolation errors are exempted (they can never be recovered by another grammar), so the divergence is confined to messages a retry can plausibly improve. Measured 2026-09-22 |
| `a { b: #{1 +} }` in a `.css` file | `Expected expression.`, at the `}` | `Operators aren't allowed in plain CSS.`, at the `+` — sasso's plain-CSS expression parser names the operator instead of the expression the operand needed. Measured 2026-09-21 |
| `a { b: #{$x} }` in a `.css` file | `Sass variables aren't allowed in plain CSS.`, spanning `$x` | the same message with a one-column caret. The interpolation error around it spans exactly as dart's does; this one is the operand inside it. Measured 2026-09-21 |

The two below are classes rather than single inputs, so each gets its own
example.

### Two-span messages ([#66](https://github.com/momiji-rs/sasso/issues/66))

sasso *does* have the two-frame renderer — a user-defined callable's arity error
draws the declaration and the invocation exactly as dart does. Two shapes do not
use it.

**A labelled second span on the same line.** dart marks the two halves of the
parent-selector error separately; sasso draws one unlabelled span:

```scss
p > { &.x { a: b } }
```

```
dart-sass 1.104.1:                          sasso:
Error: Selector "p >" can't be used …       Error: Selector "p >" can't be used …
  ╷                                           ╷
1 │ p > { &.x { a: b } }                     1 │ p > { &.x { a: b } }
  │ ^^^ outer selector                         │ ^^^
  │       ━ parent selector                    ╵
  ╵
```

**A declaration frame in another file, for a BUILT-IN.** dart shows where the
built-in is declared; sasso prints only the invocation, because it has no source
text for `sass:color` to point at:

```scss
@use "sass:color";
.a { b: color.lighten(#abcdef); }
```

```
dart-sass 1.104.1:
Error: Missing argument $amount.
  ┌──> t.scss
2 │ .a { b: color.lighten(#abcdef); }
  │         ^^^^^^^^^^^^^^^^^^^^^^ invocation
  ╵
  ┌──> sass:color
1 │ @function lighten($color, $amount) {
  │           ━━━━━━━━━━━━━━━━━━━━━━━━ declaration
  ╵

sasso: the first frame only.
```

The message text itself matches (#56, #58); re-measured 2026-09-19, when
`lighten` became a real `sass:color` member that reports its arity (#65) rather
than an undefined function.

### A multi-line span in a CRLF `.sass` file is one column long

Every `.sass` span that crosses a line ending is one byte short per CRLF,
because the transpiler normalises `\r\n` before the spans are taken. It is only
visible where a span covers more than one line:

```sass
@mixin m($a, $b)
  x: $a

.a
  @include m(1,
    2,
    3)
```

Saved with CRLF endings, the invocation's closing marker lands a column late:

```
dart-sass 1.104.1:        sasso:
    │ └─── invocation         │ └────^ invocation
```

With LF endings the same file matches exactly.

## 4. Module member enumeration ([#64](https://github.com/momiji-rs/sasso/issues/64))

`meta.module-functions()`, `meta.module-mixins()` and `meta.module-variables()`
list members only for `sass:meta`; every other built-in module answers with an
empty map. sasso has no member *table* for a built-in module — the lookup is a
predicate, so it can answer "is `get` in `sass:map`?" but not "what is in
`sass:map`?". The same table is what dart's eager `Two forwarded modules both
define a function named length.` check needs, and dart returns these members in
**source** order rather than sorted.

## Deliberately not followed

- **`learn.css` in the Lichess corpus.** An extender that reaches a placeholder
  through two chains is listed twice by dart (`.w, .w`), and which duplicate
  survives depends on `ExtensionStore` bookkeeping order. We emit it once.
- **`[a="b\\c"]`** — an attribute value holding a literal backslash. dart writes
  `[a=b\\c]`, which is not stable under its own compiler: feeding that output
  back through dart-sass 1.104.1 gives `[a=b\\c ]`, a different string again. We
  write `[a="b\\c"]`, which is valid and round-trips. Every other
  attribute-value shape matches (#61).
- **`color.alpha(red, 1)`** reports `Only 1 argument allowed, but 1 were
  passed.` in dart — two arguments reported as one, with the verb disagreeing
  with the count. It is an artifact of dart's overloaded declaration of
  `alpha()`. We report the real count. (The *wording* of that message is
  matched: `alpha()` does not say "positional" where other members do.)

## Version skew worth knowing

Lichess's own build bundles **dart-sass 1.100.0**, not 1.104.1, and those two
darts already disagree with each other on that corpus — measured 2026-09-17,
one dart against the other, no sasso involved:

| | files differing, dart 1.100.0 vs 1.104.1 |
|---|---|
| `--style=expanded` | 8 / 148 |
| `--style=compressed` | **100 / 148** |

So a comparison against a different dart than the one above is measuring mostly
that difference. Every number in this file is against 1.104.1; any comparison
should say which dart it used.

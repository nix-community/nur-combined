# stderr-conformance metric (`--check-stderr`)

An **additive, opt-in** diagnostics metric in `spec/run_spec.py`. It measures
how byte-faithful the compiler's **stderr** (errors + deprecation/`@warn`
warnings) is to dart-sass, *without* touching the CSS pass/fail ratchet.

## What it does

For every spec case that ships a `warning` / `warning-<impl>` / `error` /
`error-<impl>` expectation file, `--check-stderr` also captures the compiler's
stderr and compares it to that file, normalizing **only** what dart-sass's own
sass-spec runner normalizes:

* the absolute input path the compiler saw → the spec placeholder
  (`input.scss` / `input.sass`),
* CRLF/CR → LF, a leading UTF-8 BOM stripped,
* trailing whitespace per line, surrounding blank lines.

It does **not** touch glyphs, gutter widths, caret columns, message wording, or
the deprecation `[id]` tags — those are exactly what's under test.

The per-case CSS verdict (`PASS`/`FAIL`/`ERROR_EXPECTED`) is computed from a
**flag-clean** compile and is byte-identical whether or not `--check-stderr` is
passed (verified: 0 status diffs across all 13,904 cases; `check_baseline.py`
never passes `--check-stderr`, reads only `cases[].status`, so the 11341 verdict
is untouched). Results gain two optional fields (`stderr_status`,
`stderr_kind`) and a top-level `stderr_summary` block; the process exit status
is unchanged.

## Usage

```sh
# honest "before" baseline for sasso today
SASS_BIN=target/release/sasso python3 spec/run_spec.py --check-stderr --quiet

# faithful comparison for a compiler that supports the flag the
# expectation files were generated with (see below)
SASS_BIN=spec/dartsass.sh python3 spec/run_spec.py \
    --check-stderr --stderr-arg=--no-unicode --quiet
```

## LOAD-BEARING FINDING: expectations use `--no-unicode` (ASCII glyphs)

The checked-in sass-spec `error`/`warning` files use the **ASCII** glyph set:

```
Error: <msg>
  ,                 <- gutter top   (ASCII ',' ; Unicode is U+2577 '╷')
1 | <source>        <- gutter mid   (ASCII '|' ; Unicode is U+2502 '│')
  | ^               <- caret '^'
  '                 <- gutter bottom (ASCII ''' ; Unicode is U+2575 '╵')
  input.scss 1:2  root stylesheet
```

A secondary underline renders as `======` (ASCII) vs `━━━━━━` (Unicode).

dart-sass 1.100 emits the **Unicode** box-drawing set *by default*; the suite's
files match dart-sass only when run with `--no-unicode`. Confirmed empirically:
dart-sass self-matches **0/60** with default glyphs but **80/80** with
`--no-unicode` (and `--no-color` makes no difference — color is auto-disabled
when stderr is not a TTY). The integration step that makes sasso emit snippets
must therefore default to the ASCII glyph set (or honor `--no-unicode`) to
score against this suite.

## BASELINE (before): full suite, default skip config, sasso `target/release`

* spec commit `c6ac9a3…`, dart-sass 1.100.0
* cases with a warning/error stderr expectation (attempted): **3256**
  * error kind: **2491**   warning kind: **765**
* sasso stderr byte-matches today: **0 / 3256 (0.00%)**
  * sasso currently emits `Error: <msg> (line:col)` (no snippet/gutter/stack)
    and `WARNING: <msg>` (no stack frame), so nothing matches — as expected.
* metric self-validation: dart-sass `--no-unicode` matches **10/10** on the
  `callable/arguments` subset (and 80/80 on a 80-case sample), proving the
  normalizer is faithful and the 0 above is a real "before" floor.

### Distinct dart-sass deprecation `[id]`s across the suite's warning files: **20**

(anchored to `DEPRECATION WARNING [id]`; counts = files carrying that id)

```
slash-div 308   import 253   global-builtin 188   color-functions 145
bogus-combinators 121   new-global 63   strict-unary 56   if-function 43
function-units 36   call-string 24   moz-document 24   function-name 18
duplicate-var-flags 15   feature-exists 14   color-module-compat 11
with-private 9   misplaced-rest 4   adjacent-compounds 2   elseif 2
abs-percent 1
```

710 of the 769 warning files carry a `[id]`; the rest are plain `@warn` /
un-tagged warnings.

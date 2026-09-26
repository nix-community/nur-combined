# dart-sass 1.100 diagnostics reference

This directory is the **single source of truth** for byte-matching sasso's stderr
diagnostics against dart-sass. Every observation here was captured by driving the
real `dart-sass 1.100.0 (compiled with dart2js 3.12.0)` binary; nothing is
inferred from documentation.

## How the fixtures are laid out

Each diagnostic case is a triple:

| file                  | meaning                                                        |
| --------------------- | ------------------------------------------------------------- |
| `<name>.scss`         | the input                                                     |
| `<name>.stderr`       | byte-exact stderr with the **Unicode** glyph set (default)    |
| `<name>.ascii.stderr` | byte-exact stderr with `--no-unicode`                         |

Files starting with `_` (`_imported.scss`, `_libchain.scss`, `_liberr3.scss`) are
partials pulled in by other fixtures; they are **not** entrypoints.

`EXIT-CODES.txt` lists the process exit code for every entrypoint fixture.

### Reproducing a capture

The path printed inside the stderr is exactly the argument passed to `sass`. To
keep fixtures stable, every capture was run **from inside this directory** with the
bare basename, so the path in the snippet/frames is just `<name>.scss`:

```sh
SASS_BIN="$(find "$HOME/.npm/_npx" -path '*node_modules/.bin/sass' | head -1)"
cd tests/fixtures/diagnostics
"$SASS_BIN"            <name>.scss 1>/dev/null 2>"<name>.stderr"
"$SASS_BIN" --no-unicode <name>.scss 1>/dev/null 2>"<name>.ascii.stderr"
```

Diagnostics always go to **stderr**; CSS (or nothing, on error) goes to stdout.

---

## 1. The four diagnostic kinds

| kind          | header                                  | snippet? | frames? | exit |
| ------------- | --------------------------------------- | -------- | ------- | ---- |
| `@debug`      | `path:line DEBUG: <value>`              | no       | no      | 0    |
| `@warn`       | `WARNING: <message>`                    | no       | yes     | 0    |
| deprecation   | `DEPRECATION WARNING [id]: <message>`   | yes      | yes     | 0    |
| error         | `Error: <message>`                      | yes      | yes     | 65   |

A compile error and an `@error` produce the **identical** structure; only the
message text differs (`@error` messages are the quoted/serialized argument value).

---

## 2. `@debug` — the odd one out

Format is a single line, **no snippet, no frames, no glyphs** (Unicode and ASCII
output are byte-identical):

```
<path>:<line> DEBUG: <value>
```

- It is `:<line>` only — **no column**.
- Exactly one space before `DEBUG:`, one space after it.
- The value is serialized the same way it would be in CSS (a string is shown
  **unquoted**: `@debug "checkpoint reached"` -> `... DEBUG: checkpoint reached`).
- Terminated by a single `\n`. (See `debug-string`, `debug-values`.)

---

## 3. `@warn`

```
WARNING: <message>
    <path> <line>:<col>  <frame name>
    ...
                                        <- trailing blank line
```

- `WARNING: ` prefix; the message is the **string content, unquoted**.
- One or more stack frames, each indented **4 spaces** (see §6).
- The block is terminated by `\n\n` (a blank line follows the last frame).
- `@warn` is **never** subject to the repetitive-deprecation cap (§7); seven
  identical `@warn`s print seven blocks.
- Exit code 0. (See `warn-plain`, `warn-interpolated`, `warn-in-mixin`.)

---

## 4. Errors / `@error` — the snippet

```
Error: <message>
  ╷
N │ <source line, tabs expanded>
  │ <padding>^^^^^   <optional label>
  ╵
  <path> <line>:<col>  <frame name>
  ...
```

- Header is `Error: ` then the message. For real compile errors the message is a
  plain sentence ending in `.` (e.g. `Undefined variable.`, `expected ";".`,
  `Undefined operation "1px + #fff".`). For `@error` it is the **serialized
  argument** — a string argument keeps its quotes (`Error: "Something went wrong"`).
- Glyph rows and the highlighted source line(s) form the snippet (§5).
- Stack frames follow, indented **2 spaces** (§6). NOTE: errors use 2-space frame
  indent, warnings/deprecations use 4-space.
- No trailing blank line after the last error frame (file ends `...root stylesheet\n`).
- Exit code **65**.

`@error` snippet points at the **call site**, not the `@error` statement: an error
raised inside `@include require(false)` highlights the `@include` line in the
caller, and the stack unwinds from there (`error-in-mixin`, `error-stack-nested`,
`error-in-function`, `error-cross-file`).

---

## 5. Snippet glyphs and layout

### Glyph sets

| role            | Unicode | bytes        | ASCII (`--no-unicode`) |
| --------------- | ------- | ------------ | ---------------------- |
| top corner      | `╷` U+2577 | `e2 95 b7` | `,`                    |
| mid bar         | `│` U+2502 | `e2 94 82` | `\|`                   |
| bottom corner   | `╵` U+2575 | `e2 95 b5` | `'`                    |
| caret           | `^` U+005E | `5e`        | `^` (same)             |
| secondary mark  | `━` U+2501 | `e2 94 81` | `=`                    |

The caret `^` is identical in both modes. The heavy `━` only appears in multi-part
snippets (see `deprecation-bogus-combinators`, which labels a caret span
`invalid selector` and a `━━━━` span `this is not a style rule`).

### Gutter (line-number column)

- Width = number of digits in the **largest** line number shown in that snippet.
- The line-number is right-aligned in the gutter; then a single space, then `│`.
- The `╷`/`│`/`╵`-only rows pad the gutter with spaces (no number).
  - 1-digit example: `  ╷` (2 leading spaces) and `1 │ ...`.
  - 2-digit example: `   ╷` (3 leading spaces) and `11 │ ...` (`compile-gutter-alignment`).

### TAB expansion — byte-load-bearing

Tabs in the source line are expanded to **exactly 4 spaces** in the rendered
snippet, and the caret row is padded to match that visual width. The **column
number in the footer still counts the tab as 1 source column.**

`compile-tab-expansion.scss` line 2 is `\tcolor: $nope;`. Rendered:

```
2 │     color: $nope;     <- leading TAB became 4 spaces
  │            ^^^^^
  ╵
  compile-tab-expansion.scss 2:9  root stylesheet   <- col 9, tab = 1 col
```

---

## 6. Stack frames

Each frame is:

```
<indent><path> <line>:<col><pad>  <frame name>
```

- **Indent**: `2` spaces for errors, `4` spaces for warnings/deprecations.
- `<path> <line>:<col>` (note: a single space between path and `line:col`, a `:`
  between line and column).
- All frames in one trace are **column-aligned**: the `<path> <line>:<col>` field
  is left-justified and space-padded to the width of the **longest** such field in
  the trace, then followed by a **2-space** separator, then the frame name.
- The **outermost** frame name is literally `root stylesheet`.
- A user mixin frame is `<name>()`; a user function frame is `<name>()`
  (both with empty parens, name only — see `error-stack-nested` -> `outer()`,
  `error-in-function` -> `wrapper()`).
- A frame produced by crossing an `@import` boundary is named literally `@import`
  (`compile-import-chain` -> `_liberr3.scss 2:10  @import`).

Alignment example (`compile-import-chain`):

```
  _liberr3.scss 2:10             @import
  compile-import-chain.scss 1:9  root stylesheet
```

`_liberr3.scss 2:10` (18 chars) is padded to 29 (the width of
`compile-import-chain.scss 1:9`) + 2 separator spaces, so `@import` aligns with
`root stylesheet`.

---

## 7. Deprecation warnings

Header:

```
DEPRECATION WARNING [<id>]: <message...>
```

followed (for most ids) by a `More info...: https://sass-lang.com/d/<slug>` line,
then a snippet, then a 4-space-indented frame list, then a trailing blank line.
Some ids (`elseif`, `call-string`, `duplicate-var-flags`, `new-global`) emit **no**
`More info` URL line at all.

### IDs observed firing on 1.100 (with exact URL slug)

| id `[..]`             | URL slug (`sass-lang.com/d/<slug>`) | trigger (fixture)                         |
| --------------------- | ----------------------------------- | ----------------------------------------- |
| `slash-div`           | `slash-div`                         | `(1 / 2)` (`deprecation-slash-div`)       |
| `color-functions`     | `color-functions`                   | `lighten()`/`darken()`                    |
| `global-builtin`      | **`import`** (not `global-builtin`) | any global builtin: `lighten`, `type-of`, `call`, `feature-exists` |
| `import`              | `import`                            | `@import "..."` (`deprecation-import`)    |
| `elseif`              | *(no URL line)*                     | `@elseif` (`deprecation-elseif`)          |
| `call-string`         | *(no URL line)*                     | `call("foo")` (`deprecation-call-string`) |
| `feature-exists`      | `feature-exists`                    | `feature-exists(...)`                     |
| `abs-percent`         | `abs-percent`                       | `abs(10%)` (`deprecation-abs-percent`)    |
| `duplicate-var-flags` | *(no URL line)*                     | `$x: 1 !global !global`                    |
| `new-global`          | *(no URL line)*                     | also fired by the `!global` case above    |
| `bogus-combinators`   | `bogus-combinators`                 | `a + { ... }` (`deprecation-bogus-combinators`) |

Notable surprise: **`global-builtin`'s URL slug is `import`, not `global-builtin`.**
Its message ends with `Use <module>.<fn> instead.` naming the module replacement
(`color.adjust`, `meta.type-of`, `meta.call`, `meta.feature-exists`, ...).

Calling a deprecated **global color function** fires **two** deprecations in order:
first `global-builtin`, then `color-functions` (see `deprecation-color-functions`,
`deprecation-darken`). `call("foo")` likewise fires `global-builtin` then
`call-string`. `feature-exists(...)` fires `global-builtin` then `feature-exists`.
The `!global !global` case fires `duplicate-var-flags` then `new-global`.

### IDs recognized by 1.100 but NOT triggered by simple SCSS here

`--fatal-deprecation=<id>` accepts all of these on 1.100 (so they exist), but they
are CLI/JS-API-specific or needed conditions I could not reproduce with a minimal
single file: `moz-document`, `relative-canonical`, `new-disallowed-pseudo`,
`bogus-combinators` (does fire — see above), `import-relative-path-string`,
`fs-importer-cwd`, `css-function-mixin`, `function-units`, `mixed-decls`,
`strict-unary`, `nesting-leading-newline`, `legacy-js-api`, `type`.

`mixed-decls` in particular did **not** fire for plain `decl; nested-rule; decl`
nesting on 1.100 (such nesting is now emitted as ordered CSS without a warning) —
do not assume it fires for ordinary nested-then-declaration cases.

### Repetition cap / dedup — confirmed behavior

(`deprecation-cap-omitted`, `deprecation-cap-exactly-5`, `deprecation-cap-per-id`)

- For each deprecation **id**, at most **5** full warning blocks are printed.
- The counter is **per id, independent**: 7 `slash-div` + 7 `lighten` prints
  5 + 5 (`global-builtin`) + 5 (`color-functions`).
- Once any id exceeds 5, a single aggregate footer is appended:

  ```
  WARNING: <N> repetitive deprecation warnings omitted.
  Run in verbose mode to see all warnings.
  ```

  `<N>` is the **total** number of omitted blocks summed across all ids
  (8 slash-divs -> `3`; the per-id case -> `6` = 2+2+2). The word is always
  `warnings` (plural) even when `<N>` is 1.
- Exactly 5 occurrences -> all 5 shown, **no** footer.
- `--verbose` (`--no-verbose` is the default) disables the cap entirely: all blocks
  print and no omitted-footer is added.
- The block is terminated by `\n\n` (trailing blank line), same as `@warn`.

---

## 8. Trailing-newline summary (exact)

| kind                                  | trailing bytes        |
| ------------------------------------- | --------------------- |
| `@debug`                              | `...<value>\n`        |
| `@warn` block                         | `...root stylesheet\n\n` |
| deprecation block                     | `...<frame>\n\n`      |
| omitted footer                        | `...all warnings.\n\n` |
| error (final, after stack)            | `...root stylesheet\n` (single `\n`, no blank) |

When a run emits a deprecation **and then** an error (e.g. an `@import` that both
warns and fails), the deprecation block (with its trailing blank line) is printed
first, then the `Error:` block (`compile-import-chain`).

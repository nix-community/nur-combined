# sass-spec case format (as found in the cloned suite)

This documents the on-disk format of the official
[`sass/sass-spec`](https://github.com/sass/sass-spec) suite as observed in the
commit pinned in [`SPEC_VERSION.txt`](./SPEC_VERSION.txt). The runner
(`run_spec.py`) implements exactly what's described here.

## Where the cases live

All language-conformance cases live under `sass-spec/spec/`. The top-level
subdirectories are feature areas:

```
core_functions  values  css  non_conformant  directives
libsass  libsass-closed-issues  libsass-todo-issues  libsass-todo-tests
expressions  callable  operators  parser  variables
```

(`js-api-spec/` covers the JavaScript API, not the language — we ignore it.)

## A "case" is a directory with an input file

A single conformance case is a directory (physical OR virtual-inside-HRX) that
contains:

| File | Meaning |
|------|---------|
| `input.scss` | the SCSS source to compile (the common case) |
| `input.sass` | indented-syntax source (alternative to `input.scss`) |
| `output.css` | **expected** CSS — this is a *success* spec |
| `error` | **expected** error — this is an *error* spec (compiler must fail) |
| `warning` | expected stderr (warnings/`@debug`/`@warn`); not used for scoring CSS |
| `options.yml` | per-directory options, applies recursively to subdirs |
| *other* `*.scss` / `*.css` | sibling files referenced via `@import`/`@use` |

A case has **either** `output.css` (success) **or** `error` (error spec), never
both as the primary expectation. If neither is present the directory is not a
runnable conformance case (e.g. it only holds shared imports).

### Implementation-specific expectations

Different implementations can legitimately produce different output or even
disagree on success vs. error. To express that, a file may carry an
implementation suffix **before** the extension:

```
output-dart-sass.css      overrides   output.css
error-dart-sass           overrides   error
warning-dart-sass         overrides   warning
```

When scoring implementation `X`, the `*-X` file (if present) **completely
replaces** the generic file. The runner takes `--impl` (default `dart-sass`)
and applies this override during extraction. In this suite we observed
`output-libsass.css` and `error-dart-sass`, confirming the mechanism is live.

## `.hrx` archives (the dominant format)

Almost all cases are bundled into `.hrx` archives (≈3000 archives vs. ~11
loose directory cases). HRX is a plain-text, UTF-8 multi-file archive. The only
specs *not* in HRX are ones containing invalid UTF-8 (HRX can't represent
them).

### HRX grammar

* A line of the form `<===> path/to/file` begins a **virtual file**. Everything
  on the following lines, up to the next `<===>` marker, is that file's body.
* A bare `<===>` marker (no path) begins a **comment/separator block** whose
  body is discarded. By convention the suite puts a line of 80 `=` characters
  between cases for visual separation:

  ```hrx
  <===> first/input.scss
  a {b: c}

  <===> first/output.css
  a {
    b: c;
  }

  <===>
  ================================================================================
  <===> second/input.scss
  ...
  ```

* The blank line that HRX inserts between a file body and the next marker is a
  **separator, not content** — the runner strips exactly one trailing newline
  from each extracted body.

### One HRX → many cases

Because virtual paths can contain directories, **a single `.hrx` can hold many
cases**, each its own `dir/input.scss` + `dir/output.css` (or `dir/error`)
pair. The runner groups virtual files by their directory prefix and emits one
case per directory that contains an input file. Nested `dir/sub/input.scss`
cases are supported.

A case may also include sibling virtual files used as imports
(`dir/other.scss`), and a per-case or per-archive `options.yml`.

## `options.yml`

A tiny YAML file. It applies **recursively** to all cases in its directory and
below; the runner merges `root → … → case-dir`. Keys begin with `:`. The ones
the runner acts on:

| Key | Effect on scoring |
|-----|-------------------|
| `:todo:` (list) | implementations that haven't implemented this yet. For the scored impl, the case is **skipped** by default (matches `sass-spec.rb` without `--run-todo`). Entries may be bare names (`dart-sass`) or GitHub shorthands (`sass/dart-sass#123`). |
| `:ignore_for:` (list) | implementations never expected to pass this case → **skipped**. |
| `:warning_todo:` (list) | skip only stderr/warning validation. We don't score warnings, so it's a no-op for us. |
| `:precision:` N | numeric precision for this subtree (dart-sass is fixed at 10; recorded for our binary). |

Other legacy keys exist and are ignored.

## Comparison / normalization

The expected `output.css` is compared to the compiler's **stdout** (we capture
stdout only; warnings and deprecations go to stderr). sass-spec's comparison
ignores only trivial whitespace, so `normalize_css()`:

* strips a UTF-8 BOM,
* converts CRLF/CR to LF,
* trims trailing whitespace on every line,
* removes blank lines,
* trims leading/trailing whitespace of the whole document.

Interior indentation in expanded output is **significant** and is preserved.

## Census of the pinned snapshot

See [`REPORT.md`](./REPORT.md) for the case counts and the per-directory
breakdown, plus the dart-sass validation result.

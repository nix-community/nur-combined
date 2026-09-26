# sasso-ffi — C ABI for sasso

A thin, stable **C ABI** around the [`sasso`](https://crates.io/crates/sasso)
pure-Rust SCSS → CSS compiler. One prebuilt `libsasso.{so,dylib}` + one header
([`include/sasso.h`](include/sasso.h)) is callable from **any language with a C
FFI** — PHP FFI, Python `ctypes`/`cffi`, Ruby `Fiddle`, Go `cgo`, LuaJIT, … —
in-process, with no Node, no Dart VM, and no per-language native extension.

> Status: compile + options + load paths **and a userland importer callback**
> are implemented and tested (see [Importer callbacks](#importer-callbacks)).

## Build

```console
$ cargo build --release
# -> target/release/libsasso.dylib (macOS) / libsasso.so (Linux) + libsasso.a
```

The header is committed at [`include/sasso.h`](include/sasso.h) (and can be
regenerated with `cbindgen --config cbindgen.toml --output include/sasso.h`).

## API (see [`include/sasso.h`](include/sasso.h))

| Symbol | Purpose |
| --- | --- |
| `const char *sasso_version(void)` | Bundled compiler version (static; do not free). |
| `void sasso_options_init(SassoOptions*, size_t)` | Fill an options struct with defaults; pass `sizeof(SassoOptions)`. |
| `SassoResult *sasso_compile(const char *src, size_t len, const SassoOptions*)` | Compile a UTF-8 buffer; returns an owned result. |
| `void sasso_result_free(SassoResult*)` | Release a result (and its `css`/`error`). |
| `void sasso_importer_set_canonical(SassoImporterSink*, const char*, size_t)` | Deliver a canonical URL from a `canonicalize` callback. |
| `void sasso_importer_set_result(SassoImporterSink*, …)` | Deliver loaded contents + syntax (+ optional source-map URL) from a `load` callback. |
| `void sasso_importer_set_error(SassoImporterSink*, const char*, size_t)` | Deliver an error message from either callback. |

### Ownership & safety contract

- **Source** is a UTF-8 `(pointer, length)` buffer — it need **not** be
  NUL-terminated. Host paths (`url`, `load_paths`) **are** NUL-terminated.
- A `SassoResult*` from `sasso_compile` is **owned by sasso**; release it with
  `sasso_result_free` (which frees the `css`/`error` strings too). Never free
  `css`/`error` with your own `free()`.
- `css`/`error` are NUL-terminated **and** carry an explicit byte length
  (`css_len`/`error_len`) for binary-safe callers.
- Every entry point is **panic-safe**: an internal Rust panic becomes an error
  result rather than unwinding across the C boundary (which would be UB).
- `SassoOptions` is `#[repr(C)]` with a leading `struct_size` for forward
  compatibility — initialize with `sasso_options_init`, then override fields.
  Pass `NULL` options for all defaults.

## Importer callbacks

Set `SassoOptions.importer` to a `SassoImporter` to resolve
`@use`/`@forward`/`@import` yourself — from a database, a virtual filesystem, an
archive, anything. A non-NULL importer takes precedence over `load_paths`; NULL
keeps the built-in filesystem importer. It mirrors dart-sass's **two phases**:

- `canonicalize(user_data, url, ctx, sink)` maps a (possibly relative,
  extension-less) URL to a stable canonical key **without** loading it. `ctx`
  carries `from_import` and the importing file's `containing_url` (NULL at the
  entry) so you can resolve relatively.
- `load(user_data, canonical, sink)` fetches that key's source.

Each callback returns a tri-state code:

| Return | Meaning | What you must deliver first |
| --- | --- | --- |
| `SASSO_IMPORTER_OK` (1) | Handled. | `sasso_importer_set_canonical` / `sasso_importer_set_result`. |
| `SASSO_IMPORTER_NOT_FOUND` (0) | This importer doesn't handle the URL. | nothing |
| `SASSO_IMPORTER_ERROR` (-1) | Handled but failed. | `sasso_importer_set_error` |

**Memory model — no `free` callback.** You never hand sasso an owned pointer.
You deliver each value by calling a `sasso_importer_set_*` function with the
`sink`; sasso **copies the bytes immediately**, so you keep and free your own
buffers. This sidesteps cross-allocator `free` (e.g. a ctypes/PHP-FFI string is
owned by the host runtime, not C `malloc`). The `sink` is valid **only** for the
duration of that one callback — don't stash it.

The `sasso_importer_set_*` functions are panic-safe at the boundary, so a value
delivered from inside your callback can never unwind across your C frame.

## Examples

- **Python** (ctypes): [`examples/smoke.py`](examples/smoke.py) — basic compile,
  options, error path; also a smoke test:
  ```console
  $ python3 examples/smoke.py
  ```
- **Python** (ctypes): [`examples/importer.py`](examples/importer.py) — a custom
  in-memory importer resolving a nested, directory-relative module graph:
  ```console
  $ python3 examples/importer.py
  ```
- **PHP** (ext-ffi, no compiled extension): [`examples/example.php`](examples/example.php)
  ```console
  $ php examples/example.php
  ```

A minimal C use:

```c
#include "sasso.h"
#include <stdio.h>
#include <string.h>

int main(void) {
    const char *src = ".a { color: red; }";
    SassoResult *r = sasso_compile(src, strlen(src), NULL);
    int ok = r->ok;                 /* capture before freeing the result */
    if (ok) printf("%s", r->css);
    else    fprintf(stderr, "%s\n", r->error);
    sasso_result_free(r);
    return ok ? 0 : 1;
}
```

## Roadmap

- **Source maps.** The core already exposes `compile_with_source_map`; a
  result-carrying-map variant (and the importer's `source_map_url`, already
  plumbed through `sasso_importer_set_result`) can surface a map alongside `css`.
- **Convenience importer helpers.** An ordered importer list and a
  `load`-only file importer could follow if hosts ask for them.

## Relationship to php-sasso

[`shyim/php-sasso`](https://github.com/shyim/php-sasso) is a *compiled* PHP
extension (ext-php-rs). This C ABI is the *lighter, language-agnostic* path
(load the shared library at runtime via FFI) and also serves Python, Go, Ruby,
etc. The two are complementary.

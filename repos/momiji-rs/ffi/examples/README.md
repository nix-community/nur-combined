# sasso C-ABI examples — one ABI, many languages

Each is a self-contained, **runnable** binding to the prebuilt `libsasso` shared
library, exercising the C ABI: `sasso_version`, `sasso_compile` (+ `SassoOptions`),
`sasso_result_free`, and the **v2 userland importer callback** (`SassoImporter` +
the `sasso_importer_set_*` setters).

The eight dedicated binding directories (`c`, `go`, `ruby`, `swift`, `deno`,
`bun`, `luajit`, `csharp`) each assert the same five checks — version, an
expanded compile, a compressed compile, the error path, and a custom in-memory
importer resolving a relative `@use` — so they double as cross-language
conformance tests. The two top-level Python files split that coverage
(`smoke.py` = version/compile/compressed/error, `importer.py` = the importer
callback), and `example.php` is a v1 compile-only demo (no importer).

Build the library once, then run any example:

```console
$ cargo build --release            # in ffi/ — produces target/release/libsasso.{dylib,so}
```

Each example resolves the library relative to this repo (override with the
`SASSO_DYLIB` environment variable where applicable).

| Language | File | Mechanism | Run (from this directory) |
| --- | --- | --- | --- |
| **C** | [`c/test.c`](c/test.c) | link + `sasso.h` | `clang test.c -I ../../include -L ../../target/release -lsasso -o test && DYLD_LIBRARY_PATH=../../target/release LD_LIBRARY_PATH=../../target/release ./test` |
| **Go** | [`go/main.go`](go/main.go) | cgo (+ `shim.c`) | `DYLD_LIBRARY_PATH=../../target/release LD_LIBRARY_PATH=../../target/release go run .` |
| **Python** | [`smoke.py`](smoke.py), [`importer.py`](importer.py) | `ctypes` | `python3 smoke.py` · `python3 importer.py` |
| **Ruby** | [`ruby/test.rb`](ruby/test.rb) | `Fiddle` (stdlib) | `ruby test.rb` |
| **PHP** | [`example.php`](example.php) | `ext-ffi` | `php example.php` |
| **Swift** | [`swift/test.swift`](swift/test.swift) | module map + `@convention(c)` | `swiftc -I swift -L ../../target/release -lsasso swift/test.swift -o swift/test && DYLD_LIBRARY_PATH=../../target/release LD_LIBRARY_PATH=../../target/release swift/test` |
| **Deno** (TS) | [`deno/test.ts`](deno/test.ts) | `Deno.dlopen` | `deno run --allow-ffi --allow-read --allow-env deno/test.ts` |
| **Bun** (TS) | [`bun/test.ts`](bun/test.ts) | `bun:ffi` | `bun run bun/test.ts` |
| **LuaJIT** | [`luajit/test.lua`](luajit/test.lua) | `ffi` | `luajit luajit/test.lua` |
| **C#** (.NET) | [`csharp/Program.cs`](csharp/Program.cs) | P/Invoke | `cd csharp && dotnet run -c Release` |

All of the callback-based examples build a small in-memory file map and drive
`@use` resolution through the importer callbacks — the same path a host
(database, virtual filesystem, archive) would use in production. The recurring
care point across the dynamic hosts is keeping the callback trampolines rooted so
the GC can't collect them mid-compile; the "copy-on-emit, no `free_fn`" ownership
model handles everything else.

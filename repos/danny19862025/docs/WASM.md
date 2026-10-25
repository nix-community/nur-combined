# Sandboxed WebAssembly plugins · ABI v1

Spotlight runs binary WebAssembly with the [Wasmi Rust interpreter](https://docs.rs/wasmi/2.0.0/wasmi/). There is no JavaScript runtime. Any language/toolchain that can produce a **freestanding wasm32 module implementing this ABI** can be used. Rust has a ready-to-use [SDK](../sdk/rust), and C/C++ have a [header](../sdk/spotlight.h). Modules that depend on WASI, browser APIs, JavaScript glue, language-specific host runtimes, or arbitrary native libraries need to be adapted; those imports are not exposed.

Create `$XDG_DATA_HOME/spotlight/plugins/<id>/manifest.json` (normally `~/.local/share/spotlight/plugins/<id>/manifest.json`):

```json
{
  "schema_version": 1,
  "id": "wasm-text",
  "name": "Text Tools (WASM)",
  "description": "Uppercase, lowercase, and character count",
  "icon": "insert-text-symbolic",
  "runtime": "wasm",
  "module": "plugin.wasm",
  "mode": "search",
  "timeout_ms": 1500
}
```

The module must resolve to a `.wasm` file inside its manifest directory; paths and symlinks that escape the directory are rejected. Discovery validates manifests without executing modules. The plugins folder accepts only WASM manifests. Legacy scripts and process manifests continue to work in the separate `scripts` folder, and are labeled as scripts with full user access. IDs must be unique across both directories. Reopen Script Commands or press Ctrl+R to discover changes. Both `plugin wasm-text Hello` and `ext wasm-text Hello` run the plugin. Icons, command argument forms, search debounce, result selection, errors, and cancellation use the existing [extension protocol](EXTENSIONS.md).

## ABI

Export one linear memory called `memory` and `spotlight_run: () -> ()`. Only these imports exist, under module `spotlight`:

| Import | WebAssembly signature | Behavior |
| --- | --- | --- |
| `request_len` | `() -> i32` | Length in bytes of the UTF-8 JSON request |
| `read_request` | `(i32 pointer, i32 capacity) -> i32` | Copies the entire request into guest memory; returns bytes copied |
| `emit` | `(i32 pointer, i32 length) -> ()` | Emits and flushes one JSON message immediately |

The request is `{"api_version":1,"query":"Hello","args":["Hello"]}`. For search mode, `query` and the first argument contain the search text; for command mode, `query` is empty and `args` contains the argument-form values. Lengths count UTF-8 bytes. Buffers must fit inside guest memory. Invalid pointers or lengths trap, rather than exposing host memory.

Emit one compact JSON object per call, without raw newlines, using the same `result`, `results`, `status`, and `done` messages as script extensions. There is no need to emit `done`; returning successfully finishes the stream. Result actions are performed by Spotlight only when the user selects them. Copy and open actions do not give the plugin direct clipboard, filesystem, network, or window access. A `run` action reruns the same module with the declared arguments, in a fresh sandbox.

## Isolation and limits

Every invocation starts a fresh Wasmi instance in a dedicated Spotlight worker process. Module validation is enabled. No WASI or ambient operating-system imports are linked: the guest cannot read files or environment variables, open sockets, launch commands, inspect other plugins, or access the desktop. Worker environments are cleared. Plugins receive only the explicit request. State does not persist across invocations.

The limits are a 4 MiB module, 32 MiB guest linear memory, one memory/table/instance, 10,000 table elements, 256 recursive calls, 65,536 Wasmi stack slots, 20 million fuel units, 256 host calls, and Wasmi's strict module compilation limits. Requests are capped at 512 KiB. Each emitted message is below 64 KiB; output is capped at 1 MiB, with 50 visible results and 100 individual result updates. Manifest timeouts range from 100 to 30,000 ms. The parent supervises compilation and execution; changing the query, hiding Spotlight, or reaching the deadline terminates and reaps the worker process group, including a plugin stuck in an infinite loop. Linux parent-death signaling also terminates a worker if Spotlight exits abruptly. Memory/fuel failures surface as result errors without stopping the launcher.

This is the WASM guest capability boundary, not a general sandbox for native scripts. The worker is still a native process at the user's privilege level; the Wasmi engine and Spotlight's three host functions are trusted. The [Extension Store](TOOLS.md#extension-store) browses a local TOML catalog and offers reviewed, checksum-verified WASM installs from pinned GitHub releases or the bundled SDK example. It has no registry service or automatic update mechanism, and it cannot enable native code through a WASM manifest.

## Build the Rust example

From the Spotlight repository:

```sh
rustup target add wasm32-unknown-unknown
cargo fetch --locked --manifest-path examples/plugins/text-tools/Cargo.toml
sh examples/plugins/text-tools/build.sh
plugin_dir="${XDG_DATA_HOME:-$HOME/.local/share}/spotlight/plugins/text-tools"
mkdir -p "$plugin_dir"
install -m 644 examples/plugins/text-tools/manifest.json examples/plugins/text-tools/plugin.wasm "$plugin_dir/"
```

The example uses Rust's Unicode uppercase/lowercase functions, counts Unicode scalar values, and returns three copyable results. Only the author needs the Rust WASM target; users installing a built module need no extra runtime. Build products are ignored by Git. The Rust SDK handles JSON, buffers, and ABI imports. For C/C++, include `sdk/spotlight.h`, export `void spotlight_run(void)` and memory, and compile for wasm32 with no WASI dependencies, for example with Clang/LLD's `--target=wasm32 -nostdlib -Wl,--no-entry -Wl,--export=spotlight_run -Wl,--export-memory` options.

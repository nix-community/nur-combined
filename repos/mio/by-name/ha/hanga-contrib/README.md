# Hanga contrib

Language packs that are not the Rust engine mods. The engine ABI is still
`hanga/wit/world.wit`. This tree has Kotlin/Wasm, TinyGo, Zig, nlvm/Nim, Koka, and Hoot
(Scheme → WasmGC) utils plus example guests.

Standard Go `GOOS=js` talks to a browser; Hanga loads **WASI components**,
so the Go pack is TinyGo `wasi` + `wasm-tools component`. Zig has no guest
WIT generator yet: we generate **C** bindings and compile them with Zig.
[nlvm](https://github.com/arnetheduck/nlvm) runs the native Nim hangamod tests
on x86_64-linux. The continuous nlvm tarball **SIGSEGVs** on `--cpu:wasm32`, so
`lab_nim.wasm` is the Nim C backend (`nim c --compileOnly`) linked with the same
wit-bindgen C objects as Zig.

Koka (`--target=c32 --library`) emits C that we link with the same wit-bindgen
objects and Zig `wasm32-wasi-musl`. Official Koka wasm wants Emscripten; this
pack skips emcc so the result is a WASI component. kklib already has WASI
ifdefs; we stub `popen`/`system`.

[Hoot](https://codeberg.org/spritely/hoot) compiles Guile Scheme to Wasm 3
(GC, tail calls). It is **not** a WASI/WIT guest: the binary imports a `rt`
/ `io` host (JS `reflect.js` or Hoot’s own VM). `hoot compile` still runs in
this package so the Scheme pack is a real artifact. It is installed under
`share/hanga/hoot/` (not `mods/`) so wasmtime never tries to load it as a WIT
pack. A Hoot runtime in the host is still required before it can run.

## Layout

- `lib/hanga/mod` — Kotlin catalog CSV and recursive bus `Wire` (JVM-tested)
- `lib/go/hangamod` — the same helpers in Go (`go test`)
- `lib/zig/hangamod` — the same helpers in Zig (`zig test`)
- `lib/scheme/hangamod` — the same helpers in Scheme (`guile` + `hoot compile --run`)
- `lib/nim/hangamod` — the same helpers in Nim (`nlvm` native tests on x86_64-linux)
- `lib/koka/hangamod` — the same helpers in Koka (`koka -e`)
- `examples/lab-tile` — tiled floor pack (`lab_tile.wasm`, Kotlin)
- `examples/lab-slab` — checkerboard slabs (`lab_slab.wasm`, TinyGo)
- `examples/lab-grid` — checkerboard grid (`lab_grid.wasm`, Zig)
- `examples/lab-nim` — checkerboard nim (`lab_nim.wasm`, Nim C backend + wit-bindgen C)
- `examples/lab-koka` — checkerboard koka (`lab_koka.wasm`, Koka C32 + wit-bindgen C)
- `examples/lab-owl` — checkerboard owl (`share/hanga/hoot/lab_owl.wasm`, Hoot; not a WIT guest)
- `games/*.game` — menu chrome for those packs

Build with `nix build .#hanga-contrib`. Point the host at a WIT pack:

```
HANGA_MODS=$(nix build --print-out-paths .#hanga-contrib)/share/hanga/mods \
HANGA_GAMES=$(nix build --print-out-paths .#hanga-contrib)/share/hanga/games \
nix run .#hanga -- --game lab_grid
```

WIT bindings are generated at build time (`wit-bindgen` Kotlin fork,
`wit-bindgen-go`, or `wit-bindgen c` for Zig/nlvm), then the guest compiler and
`wasm-tools component embed`. Hoot uses `hoot compile` instead.

Required WIT is `abi` (major 6), `ready`, `voxel-catalog`, `query-voxel`, and
`invoke`. Host: `id`, `has-mod`, `invoke`, `send`, `emit`, `voxel`, `voxel-set`,
`player`, `after`. `value` is JSON-shaped (null, bool, number, string, array, object).
Empty `invoke` replies (including empty text) mean “not mine”. `fail` is a bus
error (`busy` / `self` / `noproc`), not a missing method. `send` is fire-and-forget
(OTP cast). Kits (`gravity`, `fracture-kit`, vehicles) are nested dicts/lists, not `key=value` strings.

Longer follow-ups (Hoot guest, Zig bindgen, lifting arena helpers):
`by-name/ha/hanga/FOLLOWUP.md`.

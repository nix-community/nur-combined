# Hanga contrib

Language packs that are not the Rust engine mods. The engine ABI is still
`hanga/wit/world.wit`. This tree has Kotlin/Wasm, TinyGo, Zig, and Hoot
(Scheme → WasmGC) utils plus example guests.

Standard Go `GOOS=js` talks to a browser; Hanga loads **WASI components**,
so the Go pack is TinyGo `wasi` + `wasm-tools component`. Zig has no guest
WIT generator yet: we generate **C** bindings and compile them with Zig.

[Hoot](https://codeberg.org/spritely/hoot) compiles Guile Scheme to Wasm 3
(GC, tail calls). It is **not** a WASI/WIT guest: the binary imports a `rt`
/ `io` host (JS `reflect.js` or Hoot’s own VM). `hoot compile` still runs in
this package so the Scheme pack is a real artifact; wasmtime will not load
`lab_owl.wasm` as a WIT component until a Hoot runtime is wired into the
host.

## Layout

- `lib/hanga/mod` — Kotlin kit strings, catalog CSV, bus `Wire` (JVM-tested)
- `lib/go/hangamod` — the same helpers in Go (`go test`)
- `lib/zig/hangamod` — the same helpers in Zig (`zig test`)
- `lib/scheme/hangamod` — the same helpers in Scheme (`guile` + `hoot compile --run`)
- `examples/lab-tile` — tiled floor pack (`lab_tile.wasm`, Kotlin)
- `examples/lab-slab` — checkerboard slabs (`lab_slab.wasm`, TinyGo)
- `examples/lab-grid` — checkerboard grid (`lab_grid.wasm`, Zig)
- `examples/lab-owl` — checkerboard owl (`lab_owl.wasm`, Hoot)
- `games/*.game` — menu chrome for those packs

Build with `nix build .#hanga-contrib`. Point the host at a WIT pack:

```
HANGA_MODS=$(nix build --print-out-paths .#hanga-contrib)/share/hanga/mods \
HANGA_GAMES=$(nix build --print-out-paths .#hanga-contrib)/share/hanga/games \
nix run .#hanga -- --game lab_grid
```

WIT bindings are generated at build time (`wit-bindgen` Kotlin fork,
`wit-bindgen-go`, or `wit-bindgen c` for Zig), then the guest compiler and
`wasm-tools component embed`. Hoot uses `hoot compile` instead.

Required WIT is `abi` (major 6), `ready`, `voxel-catalog`, `query-voxel`, and
`invoke`. Host: `id`, `has-mod`, `invoke`, `send`, `emit`, `voxel`, `voxel-set`,
`player`, `after`. `value` is JSON-shaped (null, bool, number, string, array, object).
Empty `invoke` replies (including empty text) mean “not mine”. `fail` is a bus
error (`busy` / `self` / `noproc`), not a missing method. `send` is fire-and-forget
(OTP cast). Kits (`gravity`, `fracture-kit`, vehicles) are nested dicts/lists, not `key=value` strings.

# Hanga: Larger Follow-ups

This document outlines larger structural or tooling follow-ups that go beyond everyday mod logic. 

## Hoot runtime in the host
[Hoot](https://codeberg.org/spritely/hoot) compiles Guile Scheme to Wasm 3 (GC, tail calls). Currently, the Hoot pack in `hanga-contrib` (`lab_owl`) is compiled, but **cannot be loaded** by the engine. It is not a WASI/WIT component; it is a core Wasm module that imports `rt` and `io` host environments.

To support Hoot guests:
1. **Host Instantiation**: Extend the Rust host's `wasmtime` linker to provide the `rt` and `io` imports that Hoot expects.
2. **ABI Bridging**: The engine ABI (`invoke`, `emit`, `query-voxel`, etc.) relies on the Component Model's Canonical ABI to pass JSON-like `value` trees. Since Hoot operates directly on WasmGC, we will need to map these cell arenas manually between Rust and Scheme (e.g., converting engine `value` cells into Scheme vectors/strings across the WasmGC boundary).
3. **Execution Mode**: Treat it either as a standalone sandbox type alongside WIT components, or wait for Spritely to support the Wasm Component Model natively.

## cargo-kani packaging
The `hanga-kani` package in `nurpkgs` currently packages `cargo-kani` to verify the engine's mathematical properties (anti-cheat, ranges). 

Kani bundles its own older version of `rustc`, which causes friction with the rest of the workspace:
1. **Vendored Crates Hack**: The `postPatch` phase currently strips `rust-version` from vendored crates and injects `#![feature(...)]` into files to force Kani to parse modern Rust syntax. 
2. **Follow-up**: As Kani tracks closer to upstream `rustc`, we need to remove these `sed` hacks. Long-term, `cargo kani` should either run directly inside the `hanga-dev` environment without patching, or we should separate the formally verified core logic into a `no_std` crate that builds cleanly on Kani's older compiler version to avoid vendoring issues.

## Zig guest bindgen
The Zig language does not yet have a native `wit-bindgen` generator. In `hanga-contrib`, Zig packs (like `lab_grid`) currently use the **C** backend (`wit-bindgen c`) and compile the generated C code with Zig alongside the Zig source.

1. **Native Bindgen**: Once a native `wit-bindgen-zig` matures, we should drop the `lib/c/hangamod` intermediary entirely.
2. **Simpler Build**: This will remove the need to parse and link C headers in the Zig pack build phase, allowing Zig guests to be pure Zig codebase interacting natively with the Component Model canonical ABI.

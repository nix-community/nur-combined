# Hanga follow-ups

Dedicated work, not drive-bys. Live ABI is **6**. Gate: `nix build .#hanga-dev`
(and `.#hanga-contrib` when touching guests). Fail-closed bus/kit rules live in
the host parsers and `cargo test` (`.#hanga-dev`).

## Still open

- **Selective receive / priorities.** Mailbox is FIFO. Wait until a pack both
  `send`s to self and must handle `on-step` first.
- **Multi-lead terrain merge.** Workers clone one lead for `query-voxel`. Extra
  packs overlay loot/kits only.
- **`ask_any` stops on the first `fail`.** A busy testbed slot can block urban
  for that topic. Changing that is a bus-policy change, not a parser tweak.
- **`lab_owl` (Hoot)** is not a WIT component; the host still needs a Hoot
  runtime (contrib README).
- **Zig has no guest wit-bindgen.** C `plugin.h` + `cabi_realloc` is fragile.
  Track upstream Zig component bindgen. nlvm uses the same C bindgen.
- **nlvm wasm32 SIGSEGV** on the continuous Linux tarball (`llgen`). `lab_nim`
  uses Nim C + Zig WASI until that is fixed.
- **Package cargo-kani** so proofs run as CBMC, not only `kani_replay_*`.
- **Continue parser review:** `by-name/ha/hanga/src/main.rs` (around line offset 3000) for fail-closed logic.

## Out of scope (do not do)

- ClassDB / Bevy `Entity` in the guest
- Recursive WIT `value` (parser rejects it; arena stays)
- A second VM beside WASM
- Full BeamNG node-beam solver (see `mods/urban_chaos/DESIGN.md`)

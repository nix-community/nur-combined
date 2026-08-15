# Hanga follow-ups

Things that are true of the current design but need a dedicated change, not a
drive-by edit. Live ABI is **6** (`wit/world.wit`). Gate: `nix build .#hanga-dev`
(and `.#hanga-contrib` when touching guests).

## Bus (OTP)

- **Mailbox bound.** Casts cap at 256; oldest is dropped with a warning. Drain
  requeues a message if the pack is still locked instead of dropping it as empty.
  Drain still stops after 32 rounds and warns if work remains.
- **No tests for live `busy` / mailbox.** Cap eviction and `emit_blocks` (busy /
  trap / veto) are unit-tested; still need a test that locks a pack mutex so
  `invoke` returns `fail("busy")` without enqueue and `send` enqueues.
- **No supervision.** A guest trap now returns `fail("trap")` (and `emit` treats
  fail as a closed/veto). The store is still dead; decide unload, restart WASM,
  or fail the game.
- **`empty` vs empty text.** Both mean “not mine”, so a pack cannot return a
  real empty string. Use `text` only for non-empty names; keep `empty` for skip.
- **Name replies vs kits.** Loot, craft, and labels use `ask_any_text` (plain
  `text` only). `ask_any_kit` still stringifies trees for leftover CSV callers.
- **Selective receive / priorities.** OTP can skip mailbox items. We FIFO only.
  Not needed until a pack both `send`s to self and must handle `on-step` first.

## Values and kits

- **Host still flattens kits.** Vehicle, crash, gravity, fire, fracture, planar,
  and contract-mark walk `Node`. `fields_from_wire` remains for leftover CSV
  callers (`ask_any_fields` / `bus_fields`).
- **Two value types.** `hanga::kit::Atom` is a flat scalar; `Node` is the tree;
  WIT `cell` is the arena encoding. Flattened `Fields` remain for CSV fallback.
- **`key=value;` fallback.** Keep until contrib examples and tests stop sending
  CSV `methods` / kit strings. Zig `methodsBag` still returns topic CSV text.

## Engine vs mods

- **Lead WASM for terrain.** Worker threads clone the **lead** component for
  `query-voxel`. Extra packs cannot own worldgen cells; they only overlay via
  loot/kits. Multi-lead terrain needs a defined merge, not silent lead-only.
- **`player` snapshot is engine-shaped.** Wallet and wanted `state` live on the
  host player. Fine for Urban Chaos; a pack that does not use wanted still sees
  those keys. Optional: omit keys the lead did not advertise.
- **P2P is not the mod bus.** Matchbox carries signed player actions. Mods do
  not message across peers. Documented in `DESIGN.md`; a collection checksum in
  the handshake is still optional.

## Contrib / languages

- **`lab_owl` (Hoot) is not a WIT component.** The artifact lives in
  `share/hanga/hoot/`, not next to WIT packs. Still needs a Hoot runtime in the
  host (see contrib README).
- **Zig has no guest wit-bindgen.** C `plugin.h` + `cabi_realloc` is fragile
  (already burned once). Track upstream Zig component bindgen.
- **Guests still rarely `send` or return `fail`.** Kotlin/Go/Zig `Wire` now has
  `Fail`; lab_tile maps it instead of collapsing to empty. Examples should still
  use `send` for hello and treat `fail` as `{error, Reason}` at call sites.
- **Go/Zig arena helpers are copy-pasted** in the example, not in `hangamod`.
  Lift pack/unpack into the libs so examples stay small.
- **lab_slab floor** was a uniform `mark` checker (both branches returned 2);
  it now alternates slab/mark. Add a TinyGo-level test if the example grows.

## Tooling

- Package **cargo-kani** so proofs run as CBMC, not only `kani_replay_*`.
- `.#hanga` still skips the long cargo checkPhase; keep `.#hanga-dev` as the
  gate and say so in CI if a workflow only builds `.#hanga`.

## Out of scope (do not do)

- ClassDB / Bevy `Entity` in the guest
- Recursive WIT `value` (parser rejects it; arena stays)
- A second VM beside WASM
- Full BeamNG node-beam solver (see `mods/urban_chaos/DESIGN.md`)

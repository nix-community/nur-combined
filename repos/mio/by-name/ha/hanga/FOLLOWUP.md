# Hanga follow-ups

Things that are true of the current design but need a dedicated change, not a
drive-by edit. Live ABI is **6** (`wit/world.wit`). Gate: `nix build .#hanga-dev`
(and `.#hanga-contrib` when touching guests).

## Bus (OTP)

- **Mailbox bound.** Casts cap at 256; oldest is dropped with a warning. Drain
  requeues a message if the pack is still locked instead of dropping it as empty.
  Drain still stops after 32 rounds and warns if work remains.
- **No tests for live `busy` / mailbox.** Cap eviction, `emit_blocks`, and a
  held-mutex call/cast split are unit-tested. A full LiveBus with WASM packs is
  still not in `cargo test --lib`.
- **No supervision.** A guest trap returns `fail("trap")`, `emit` treats fail as
  veto, and the host reinstantiates that pack from disk (OTP restart) at most
  once per 2s. Guest statics reset. If reload fails, the store stays dead.
- **`empty` vs empty text.** Both mean “not mine”, so a pack cannot return a
  real empty string. Use `text` only for non-empty names; keep `empty` for skip.
- **Name replies vs kits.** Loot, craft, labels, story events, and agent names
  use `ask_any_text` / `bus_text_payload`. `ask_any_kit` / `bus_kit` remain for
  leftover CSV callers.
- **Selective receive / priorities.** OTP can skip mailbox items. We FIFO only.
  Not needed until a pack both `send`s to self and must handle `on-step` first.

## Values and kits

- **Host still flattens kits.** Vehicle, crash, gravity, fire, fracture, planar,
  and contract-mark walk `Node`. `fields_from_wire` remains for leftover CSV
  callers (`ask_any_fields` / `bus_fields`).
- **Two value types.** `hanga::kit::Atom` is a flat scalar; `Node` is the tree;
  WIT `cell` is the arena encoding. Flattened `Fields` remain for CSV fallback.
- **`key=value;` fallback.** Keep until leftover CSV callers go away. Zig
  `methods` is now a list of topic names.

## Engine vs mods

- **Lead WASM for terrain.** Documented: workers clone the lead for
  `query-voxel`. Extra packs overlay loot/kits. Multi-lead merge is still unset.
- **`player` snapshot is engine-shaped.** Wallet and wanted `state` are always
  on the snapshot (documented on the host import). Optional: omit keys the lead
  did not advertise.
- **P2P is not the mod bus.** Matchbox carries signed player actions. The signed
  envelope includes `collection_key` (`id:mod+mod`); mismatched peers drop the
  action. Not a WASM content hash.

## Contrib / languages

- **`lab_owl` (Hoot) is not a WIT component.** The artifact lives in
  `share/hanga/hoot/`, not next to WIT packs. Still needs a Hoot runtime in the
  host (see contrib README).
- **Zig has no guest wit-bindgen.** C `plugin.h` + `cabi_realloc` is fragile
  (already burned once). Track upstream Zig component bindgen.
- **Guests still rarely `send` or return `fail`.** lab_tile / lab_slab / lab_grid
  `ready` now `send` `hello` to peers. Treat `fail` as `{error, Reason}` at more
  call sites.
- **Go/Zig arena helpers are copy-pasted** in the example, not in `hangamod`.
  Lift pack/unpack into the libs so examples stay small.
- **lab_slab floor** was a uniform `mark` checker (both branches returned 2);
  it now alternates slab/mark. Add a TinyGo-level test if the example grows.

## Tooling

- Package **cargo-kani** so proofs run as CBMC, not only `kani_replay_*`.
- `.#hanga` skips cargo checkPhase (`doCheck = false` in `package.nix`). Gate is
  `.#hanga-dev`. NUR CI evals the whole tree, not only `.#hanga`.

## Out of scope (do not do)

- ClassDB / Bevy `Entity` in the guest
- Recursive WIT `value` (parser rejects it; arena stays)
- A second VM beside WASM
- Full BeamNG node-beam solver (see `mods/urban_chaos/DESIGN.md`)

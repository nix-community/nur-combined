# Hanga follow-ups

Things that are true of the current design but need a dedicated change, not a
drive-by edit. Live ABI is **6** (`wit/world.wit`). Gate: `nix build .#hanga-dev`
(and `.#hanga-contrib` when touching guests).

## Bus (OTP)

- **Mailbox bound.** Casts cap at 256; oldest is dropped with a warning. Drain
  requeues a message if the pack is still locked instead of dropping it as empty.
  Drain still stops after 32 rounds and warns if work remains. `LiveBus` OTP
  errors (`self` / `noproc` / `busy`) and mailbox requeue are covered in
  `cargo test --bin hanga`.
- **Live WASM on the bus.** `live_wasm_testbed_ping_and_self_cast` and
  `live_wasm_two_packs_empty_peer_ping` load `HANGA_MODS` guests (set in
  `.#hanga-dev`) for ping, self-cast drain, and empty-peer override.
- **`empty` vs empty text.** Both mean “not mine”, so a pack cannot return a
  real empty string. Use `text` only for non-empty names; keep `empty` for skip.
- **Name replies vs kits.** Loot, craft, labels, story events, and agent names
  use `ask_any_text` / `bus_text_payload`. Kits use `ask_any_node` / `bus_node`.
- **Trap restart cooldown.** After `fail("trap")` the host reloads the pack from
  disk at most once per 2s (`trap_restart_ready`). Guest statics reset. If reload
  fails, the store stays dead. Covered in `cargo test --bin hanga`.
- **Selective receive / priorities.** OTP can skip mailbox items. We FIFO only.
  Not needed until a pack both `send`s to self and must handle `on-step` first.

## Values and kits

- **Host still flattens some kits via `Node` walks.** Vehicle, crash, gravity,
  fire, fracture, planar, and contract-mark parse trees. `key=value;` text is
  only a fallback inside those parsers (lib tests). The host bus no longer has
  CSV `bus_kit` / `fields_from_wire` callers.
- **Two value types.** `hanga::kit::Atom` is a flat scalar; `Node` is the tree;
  WIT `cell` is the arena encoding.

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
  (already burned once). Track upstream Zig component bindgen. The nlvm pack
  uses the same C bindgen; Nim itself does not generate WIT guests.
- **nlvm wasm32 SIGSEGV.** The continuous Linux tarball crashes in `llgen` on
  `--cpu:wasm32`. `lab_nim` uses the Nim C backend + Zig/wasi link until that
  is fixed. Native hangamod tests still use nlvm (x86_64-linux only).
- **Koka wasm is emcc in upstream.** Contrib uses `--target=c32` + Zig WASI
  instead of Emscripten so the guest is a WIT component.
- **Guests still rarely `send` or return `fail`.** lab_tile / lab_slab / lab_grid
  `ready` now `send` `hello` to peers. `ask_any` / empty-peer `invoke` stop on
  `fail` (`first_override`); they no longer skip it as “not mine”.
- **lab_slab / lab_grid / lab_nim / lab_koka floor** uses hangamod `checkerFloor`
  (Go/Zig/Nim/Koka tests).
- **Go/Zig arena helpers** live in `lib/go/hangamod/arena.go` (Pack/Unpack) and
  `lib/c/hangamod` (WIT C guests). Returned C strings are `plugin_string_dup`
  so `cabi_post_*` can free them; `send`/`peers` results are freed after the import.

## Tooling

- Package **cargo-kani** so proofs run as CBMC, not only `kani_replay_*`.
- `.#hanga` skips cargo checkPhase (`doCheck = false` in `package.nix`). Gate is
  `.#hanga-dev`. NUR CI evals the whole tree, not only `.#hanga`.

## Out of scope (do not do)

- ClassDB / Bevy `Entity` in the guest
- Recursive WIT `value` (parser rejects it; arena stays)
- A second VM beside WASM
- Full BeamNG node-beam solver (see `mods/urban_chaos/DESIGN.md`)

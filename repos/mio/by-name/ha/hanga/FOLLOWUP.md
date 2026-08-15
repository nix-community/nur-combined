# Hanga follow-ups

Things that are true of the current design but need a dedicated change, not a
drive-by edit. Live ABI is **6** (`wit/world.wit`). Gate: `nix build .#hanga-dev`
(and `.#hanga-contrib` when touching guests).

## Bus (OTP)

- **Mailbox bound.** Casts cap at 256; oldest is dropped with a warning. Drain
  requeues a message if the pack is still locked instead of dropping it as empty.
  Drain still stops after 32 rounds and warns if work remains. Guest `after`
  timers cap at 256 the same way. Guest `voxel-set` mesh flushes cap at 256
  (oldest dropped; overlay still records the write). `LiveBus` OTP
  errors (`self` / `noproc` / `busy`) and mailbox requeue are covered in
  `cargo test --bin hanga`. Live WASM `live_wasm_testbed_mailbox_cap_and_drain`
  fills a loaded testbed slot to the 256 cap (oldest `note` dropped) and
  checks drain-while-locked requeue.
- **Live WASM on the bus.** `live_wasm_testbed_ping_and_self_cast` and
  `live_wasm_two_packs_empty_peer_ping` load `HANGA_MODS` guests (set in
  `.#hanga-dev`) for ping, self-cast drain, empty-peer override, testbed
  `query-voxel` / catalog names, gravity, guest `fail("busy")` via `refuse`,
  and emit veto (`veto` vs `ping`). Testbed `selfie` returns the host `player()`
  snapshot. Urban live coverage is split: loot/kits, world/steer, locales.
  Empty-peer
  `craft-result` uses the urban pack over testbed's empty reply. Testbed
  `toss` is guest `send` (self mailbox or a free peer). `ask` is guest
  `invoke` (`self` / `noproc` / named peer). `boom` traps and reloads the
  pack (guest statics reset). A second `boom` within 2s still returns `trap`
  and leaves the store dead until the cooldown (`count` is `fail("trap")`,
  not a reloaded zero). Testbed `bark` covers guest `log`. Urban
  `steer` covers cop chase and traffic planar (`fwd-x` / `fwd-z` / `blocked`).
  `hello` / `name` / `has` / `methods` are live on testbed. `ready` greets a
  locked peer (`hello` mailbox) and logs `testbed ready`. Host `voxel()`
  matches guest `probe` for worldgen and overlay. `ModRuntime::load_collection`
  is live for `ask_any` (urban `craft-result` over testbed empty, `refuse` fail)
  and `emit_all` (veto vs ping, and `refuse` `fail("busy")` also blocks).
  A locked pack is `fail("busy")` / veto on `ask_any` and `emit_all`, not a
  blocking wait.
- **`empty` vs empty text.** Both mean “not mine”, so a pack cannot return a
  real empty string. Empty dict and empty `items` are the same skip
  (`Node::is_empty`). Use `text` only for non-empty names; keep `empty` for skip.
- **Name replies vs kits.** Loot, craft, labels, story events, and agent names
  use `ask_any_text` / `bus_text_payload`. Kits use `ask_any_node` / `bus_node`.
  `action-range` uses `reply_range`: empty/empty-text is the engine fallback;
  `fail` is range 0 (closed), not a skip. `reply_i32` / `payload_xyz` use
  fallback for empty shapes and `fail` (keep current state / player-spawn).
  Vehicle and ambient spawn use `reply_xyz` / `reply_xyz_name` (skip the index).
- **Trap restart cooldown.** After `fail("trap")` the host reloads the pack from
  disk at most once per 2s (`trap_restart_ready`). Guest statics reset. If reload
  fails, the store stays dead. Covered in `cargo test --bin hanga`.
- **Selective receive / priorities.** OTP can skip mailbox items. We FIFO only.
  Not needed until a pack both `send`s to self and must handle `on-step` first.

## Values and kits

- **Host still flattens some kits via `Node` walks.** Vehicle, crash, gravity,
  fire, fracture, planar, and contract-mark parse trees. `key=value;` text is
  only a fallback inside those parsers (lib tests). Gravity, crash, and
  vehicle kits treat empty text/dict like `Empty`. Fracture empty is
  `FractureKit::default()` (no invented impulse). `node_from_reply` /
  `bus_node_ok` drop `fail` so fire does not treat busy as `out`. Empty
  fire-kit still means extinguish. `with_mod` uses `try_lock` like
  `ask_any`. Hot reload `try_lock`s every slot and retries next frame
  if a pack is busy. `wake_all` leaves `woken` false if a slot is busy
  so load retries `ready`. Hot reload keeps a running pack if
  instantiate fails (lead already did) and only `ready`s stores that
  actually swapped. Traffic `steer` `fail`/busy keeps velocity
  (host cruise only when the kit is empty). `vehicle-kit` `fail` skips
  that spawn index instead of a default car. Vehicle spawn xyz skips
  `fail`/empty instead of stacking at a fallback point. Ambient agent
  spawn skips `fail`/empty instead of pedestrians at the origin. Voxel
  labels keep the voxel name on `fail` (`unknown` only when the method
  is missing). Story `event-label` `fail` keeps the event id. Economy
  ticks skip `fail`/empty instead of logging `$100`. Crash and fracture
  kits skip `fail` (no invented crumple or chain). Contract marks skip
  `fail`. The host bus no longer has
  CSV `bus_kit` / `fields_from_wire` callers.
- **Two value types.** `hanga::kit::Atom` is a flat scalar; `Node` is the tree;
  WIT `cell` is the arena encoding.

## Engine vs mods

- **Lead WASM for terrain.** Documented: workers clone the lead for
  `query-voxel`. Extra packs overlay loot/kits. Multi-lead merge is still unset.
  `methods` fail/trap at load refuses the pack (empty catalog still means try
  every topic). After `ready`, a failed methods refresh keeps the load catalog.
  `evaluate-action` `fail` skips spawn and wallet for that verb. Catalog trap
  skips that layer instead of merging an empty list. Typed `query-voxel` /
  `voxel-catalog` traps restart the pack like `invoke` (air / skip layer).
  Guest `voxel()` worldgen sample returns air if `query-voxel` traps. Worker `query-voxel`
  trap is air, not the engine `y < 0` stub. `tick` `fail`/busy keeps the
  current wanted level so agents are not despawned as if wanted were 0.
- **`player` snapshot is engine-shaped.** Pose is always present. `state` and
  `wallet` are included only if that pack advertised `evaluate-action`/`tick`
  or `wallet-after`, or if `methods` was empty (try every topic, same as
  `offers`). Testbed `selfie` returns `player()` so live WASM covers
  the host import.
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
- **Guests still rarely `send` or return `fail`.** Lab packs `send` `hello` on
  `ready`. Testbed and contrib labs (`refuse`) return `fail("busy")`. `ask_any`
  / empty-peer `invoke` stop on `fail` (`first_override`).
- **lab floors** use hangamod `checkerFloor` (Kotlin/Go/Zig/Nim/Koka/Scheme).
  Underground cells are catalog index 2.
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

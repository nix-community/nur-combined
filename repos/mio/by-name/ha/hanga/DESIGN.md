# Hanga: engine vs mods

Hanga is a Bevy host. Gameplay lives in WASM components (`wit/world.wit`).
WIT is only the **sandbox ABI**. Game nouns stay out of function names.

Required guest exports (`interface guest`, ABI **6**): `abi`, `ready`,
`voxel-catalog`, `query-voxel`, `invoke`. Everything else is a named `invoke`
method. Missing method, `empty`, or empty text is “not mine” (Luanti
`register_craft` that does not match). The host caches `methods` at load and
skips unused calls.

Each pack is a single-threaded actor (Erlang process / `gen_server`): one WASM
store, one mailbox. Wasmtime cannot re-enter a store, so this matches BEAM
“one mailbox, no shared heap” rather than Lua’s reentrant VM.

| OTP / BEAM | Hanga |
| --- | --- |
| `gen_server:call` | `invoke` — wait for a reply |
| `gen_server:cast` / `!` | `send` — mailbox, no reply |
| `gen_event` | `emit` — every listener; veto is fail-closed |
| `erlang:send_after` | `after` |
| `{error, Reason}` | `cell.fail` (`busy`, `self`, `noproc`) |
| `undefined` | `empty` |

`invoke` to a locked pack returns `fail("busy")` and does **not** queue. Queueing
a call and returning `empty` was a silent cast (Godot `call_deferred` pretending
to be `call`). Use `send` when you want later delivery. `invoke` to self is
`fail("self")` (OTP self-call deadlock). Unknown name is `fail("noproc")`.
`emit` to a busy listener **vetoes** (do not skip `before-dig`). Mailbox drains
when the host-import call stack unwinds (`flush_deferred`).

The engine uses **call** only when it needs a reply: `before-dig` is `emit_all`
(veto). A locked pack is `fail("busy")` on `ask_any` and a veto on `emit_all`
(`try_lock`, same as guest `invoke`/`emit`). Notifications are **cast**: `on-dig`, `on-place`, `on-step`,
`on-mods-loaded` (`notify_all` / `send`), and `after` delivers with `send`
(OTP `send_after`, not `call`).

**Engine API** (`import host`): `log`, `now-ms`, `id`, `peers`, `has-mod`,
`invoke`, `send`, `emit`, `voxel`, `voxel-set`, `player`, `after`.
`voxel` is the lead cell plus player overlay as a dict (`name` text, `edit` flag).
`voxel-set` is Luanti `core.set_node` (queued onto the mesh next tick).
`player` is a snapshot dict (`x` `y` `z` `yaw` float; `state` / `wallet` only
if that pack advertised wanted or wallet methods), or `empty` in the menu.
`after(ms, method, args)` is OTP `send_after`: the host **casts** that method
on the same pack later.
`has-mod` is Luanti `core.get_modpath != nil`.
`invoke(peer)` is a direct call into that pack (Luanti `mobs.api()`). Empty peer
asks later packs then the lead (Luanti `override_item`).
`emit(method)` calls **every** pack that lists the method and skips the caller
(Luanti `register_on_dignode`). `flag(true)` or `fail` vetoes (`emit_all` and
guest `emit` share `emit_blocks`).

`ready` runs after every pack in the collection exists (Luanti file load). The
host then **casts** `on-mods-loaded`. Each playing frame it **casts** `on-step`
with `{dt}` milliseconds (Luanti `register_globalstep`) and flushes `after`.

**Mod API** (`invoke`): packs answer `ping`, `gravity`, kits, labels, and methods
they invent. Engine hooks: `before-dig` (veto), `on-dig`, `on-place`,
`on-mods-loaded`, `on-step`. `value` is JSON-shaped: null (`empty`), bool, int,
float, string, array (`items`), object (`dict`). WIT cannot nest types, so the
tree is a cell arena (`cells` + index `at` / `root`). Host and kits still see
nested objects, e.g. `vehicle-kit`
`{kind, parts: [{name,sx,…}], beams: [{a,b}], tires: ["wheel"]}`.
A `key=value;` string is only a fallback inside kit parsers. Host bus kits are
`Node` trees (`bus_node` / `ask_any_node`). `has` / `methods` advertise names
(`methods` is an `items` list of topic strings, dict keys, or CSV text).

## Languages (Godot + Luanti)

Godot: one `Variant`, named `Object.call`, optional virtuals.

Luanti: mods share a world. They **register** stacked callbacks, **call** each
other's APIs by name, **override** later definitions, and **set nodes** through
the engine. They check `get_modpath` before using an optional dependency.

Hanga keeps WASM isolation (no shared Lua table) and maps those patterns onto
`value` + `invoke` / `send` / `emit` / `has-mod` / `voxel-set` / `player` / `after`. We do **not** copy
ClassDB or dump Bevy nodes into scripts.

What we take:

- Keep `query-voxel` (and catalog) **typed**.
- Treat empty `invoke` as “virtual not overridden”.
- Stacked world events: `emit` only for veto (`before-dig`); `send`/`notify_all` for `on-dig`, `on-place`, `on-step`.
- Fill-in / override via later packs on loot, craft, labels, fracture (empty reply skips).
- `has-mod` for optional dependencies (`if has_mod("testbed")`).
- `player` + `after` for ABM-style logic without dumping Bevy into the guest.

What we skip: engine `call("spawn_mesh", …)` into Bevy, script inheritance across
languages, and a second scripting VM beside WASM.

A **game** is a collection of mods plus presentation (menu backdrop, titles, sky,
clouds, lighting, voxel palette). `.game` files in `share/hanga/games`
(`HANGA_GAMES`) list the mods and the look. Textures are optional PNGs next to
the file or under `games/<id>/`; `cloud=generated` lets the host paint a tint
the game chose. The host does not invent Urban Chaos or Testbed chrome.

## Engine (Rust / Bevy)

The host knows nothing about cops, wanted levels, cities, or quests.

- Voxel meshing (`bevy_voxel_world`) and rigid-body physics (`avian3d`)
- Window / headless / `--text-client` / `--agent-client` I/O
- Player-editable key bindings (`bindings.conf` + Controls menu)
- Player-facing locale (`--lang` / `HANGA_LANG`): English, te reo Māori, français, 台灣中文.
  Host UI strings live here (Play, Controls, bindings). Game titles and menu
  backdrop come from the selected `.game` file; voxel/item names come from the mod.
- P2P transport (`matchbox`), TrustLedger distance checks, action fingerprints,
  and Ed25519 signatures on the wire (`~/.config/hanga/peer.key`)
- `wasmtime` component sandbox + hot-reload (WasmGC on so Kotlin/Wasm contrib mods load)
- Host imports for mods (`log`, clock, `id`, `has-mod`, `invoke`, `send`, `emit`, `voxel`, `voxel-set`, `player`, `after`)
- Teardown *execution*: unset voxels, spawn debris, collapse voxels not connected to ground
- Vehicle *execution*: any rideable that can carry a player. The host builds boxes
  from a kit dict, moves occupants, crumples/detaches named parts, and scales fold by
  `stiffness`. `tires` is a list of part names squashed on the local up axis when grounded.
  `beams` is `[{a,b}, …]` rest-length links. The host
  relaxes a small lattice: the first kit part stays pinned, other nodes
  share the length error. Crash and fire kits come from the pack that spawned
  the rideable.
- Gravity *execution*: apply a field the game named (`none`, constant vector, or
  point attractor). Walk/jump stay on the anti-gravity plane at the kit's
  `walk` / `jump` speeds. The host does not invent Earth.
- Fire *execution*: tick a burn the mod requested (`fire-kit`). The host hangs a
  light, may unset the voxel under the flame, may ignite another rideable in
  range, and may burst. It does not know petrol.

Anti-cheat is mathematical: `is_action_physically_possible` plus ranges the **mod** defines.

## Mods (Rust → `wasm32-unknown-unknown` component)

- World gen (`query-voxel`) is **lead-only**. Worker threads clone the lead
  component. Extra packs overlay loot, kits, and agents; they do not own cells.
- Rules (`evaluate-action`, `should-spawn-agent`, wanted level)
- Economy / storyteller
- Spawn positions
- What can shatter (`fracture-kit`: can / spread / impulse)
- Spatial SFX (`sound-kit`): action name in, `{file}` basename (`.wav`/`.ogg`) under
  `assets/sounds/`. Host stages a procedural beep when the file is missing.
- Rideable kit (`vehicle-kit`): kind, traffic, speed, stiffness 0–100, `tires` names, `beams` links, collider, named box parts.
  Urban Chaos ships a soft car with squashing wheels; Testbed ships a stiff platform (and a stiff cart when packed with Urban Chaos).
- Gravity (`gravity`): `none`, `constant`/`down`, or `point` (optional inv-sq),
  plus `jump` and `walk`. Urban Chaos is Earth; Testbed is a zero-g lab.
- Vehicle crash (`crash-kit`): dict (severity, crumple, wrecks,
  ignites, action, impulse, `detach` list). Urban Chaos owns street metal; the
  host only folds boxes and hangs a light.
- Burn (`fire-kit`): age + nearby voxel name in, heat / range / consume / jump /
  burst / out. The host only ticks fuel, unsets voxels, jumps the flame, and
  bursts. Urban Chaos owns street petrol; Testbed never burns.
- Planar AI (`steer`): role + measured context in, `vx`/`vz` out. Cops and
  traffic are role names, not engine types.
- Passive tick (wanted decay), ambient NPCs
- Localized copy (`voxel-label`, `event-label`, `contract-label`, `item-label`, `supported-locales`)
- Wallet / contracts (`wallet-after`, `offer-contract`, `can-complete`)
- English names for voxels, items, actions, agents, contracts, and story events
- `voxel-catalog` is a list of names in meshing-index order; `query-voxel` still returns that index
- Loot names (`loot-item`) that fill the host's generic 8-slot hotbar
- Crafting recipes (`craft-result`); the host only spends two items and adds the product
- Heist board (`offer-contract`, `contract-mark`, `can-complete` + context).
  The host paints a mark and reports held item / position / vehicle / near;
  Urban Chaos owns smash, subway pinch, chop-shop, and the armored truck.
- Mod bus (`invoke` call / `send` cast / `emit` event): OTP `gen_server` + `gen_event`.

### Shipped games

| Game | Mods | Menu |
| --- | --- | --- |
| `urban_chaos` | `urban_chaos` | dusk city, amber title, generated clouds, haze |
| `testbed` | `testbed` | lab teal, no clouds, dim sun |
| `sandbox` | `urban_chaos`,`testbed` | city look plus the lab pack's stiff cart |

Load with `--game urban_chaos` (default), `--game testbed`, or `--mod` for a
lone WASM (implicit one-mod game, neutral menu). Packaged builds install
WASM in `$out/share/hanga/mods` (`HANGA_MODS`) and `.game` files in
`$out/share/hanga/games` (`HANGA_GAMES`). Extra language packs live in
`nix build .#hanga-contrib` (`lab_tile` Kotlin/Wasm, `lab_slab` TinyGo, `lab_grid` Zig, `lab_nim` nlvm, `lab_koka` Koka, `lab_owl` Hoot). The engine
currently instantiates the lead mod for terrain (`query-voxel`) and extra packs
for vehicles, agents, and loot. Extra packs cannot replace lead worldgen.

## Commands

```
hanga
hanga --mod testbed
hanga --game testbed
hanga --headless
hanga --text-client
hanga --agent-client
hanga --cheat
hanga --text-client --lang mi
hanga --lang fr
hanga --lang zh-TW
hanga --play
hanga --p2p
hanga --p2p ws://host:3536/hanga_room
hanga --peer-key /path/to/peer.key
hanga --bindings /path/to/bindings.conf
nix run .#hanga-signal          # Matchbox on 0.0.0.0:3536
hanga-signal                    # same binary, also as matchbox_server
```

`nix run .#hanga` and `nix run .#hanga-dev` wrap `HANGA_MODS` so gameplay WASM
loads without a local Cargo target dir. Day-to-day: `nix build .#hanga-dev`
(crate2nix, runs host + mod + agent tests). `.#hanga` is the rustPlatform wrap
and does not re-run that suite.

`nix run .#hanga-dev` opens a main menu (Play / Multiplayer / Room / Game / Language / Controls / Quit).
The Game row cycles discovered `.game` files. Each game owns the menu title,
panel, buttons, and clear/sky colors; switching Game reloads that collection's
WASM (lead plus any extra packs) and, on the next Play, respawns the world and
retires old voxel chunks and rebakes player edits from the new lead WASM. Lead owns terrain, gravity, and jobs; extra mods add
voxels, vehicles, and agents. Sandbox is Urban Chaos plus the testbed pack.
Both shipped games and their mods install in `HANGA_GAMES` / `HANGA_MODS`.
Play is single-player and does **not** talk to Matchbox. Room cycles
`hanga_room` / `hanga_heist` / `hanga_test` / off without starting a session.
Multiplayer joins the selected room (default `ws://localhost:3536/hanga_room`);
`--p2p` does the same, optionally with a URL. Run `nix run .#hanga-signal` first
(also on `PATH` as `hanga-signal` / `matchbox_server` from `nix run .#hanga` and
`.#hanga-dev`). A refused or dropped connection stays in single-player; the HUD
shows wait / live / dropped. Multiplayer after a drop reconnects; pausing does
not open a second socket. Changing Room then Multiplayer switches rooms. Each
peer signs actions with Ed25519; unsigned or forged packets are dropped. Matchbox
is that player-action bus only: WASM packs do not `send` across peers. Both
clients must load the same `.game` collection (`collection_key`, e.g.
`sandbox:urban_chaos+testbed`) or signed actions are dropped. Mouse
look is captured while playing; the play camera is off in the menu.

Key bindings default to WASD / mouse / E / C / F / J K L (job) / 1–8 / Esc; menu Room is R. Players can change them
in the Controls menu or by editing `~/.config/hanga/bindings.conf` (`HANGA_BINDINGS` or
`--bindings` override). The file is created on first launch.

Locales: `en`, `mi` (Māori), `fr`, `zh-TW` (Taiwan Chinese). Also `HANGA_LANG` or `LANG`.
Text-client extras: `look` / `status`, `accept job`, `complete job`, `fence`, `lang mi`.
English commands always work; each locale has native aliases (`前進`, `avancer`, `titiro`, …).
Agent JSON stays keyed in English, with `locale` + `voxel_label` on Look.

Build a mod as a WASM component (needs `lld` / `wasm-ld` on PATH). Host
`Cargo.toml` keeps `crate-type = ["rlib"]` so native tests link; switch to
`cdylib` only for the wasm target:

```
sed -i 's/crate-type = \["rlib"\]/crate-type = ["cdylib"]/' mods/urban_chaos/Cargo.toml
cargo build -p urban_chaos --release --target wasm32-unknown-unknown
wasm-tools component new target/wasm32-unknown-unknown/release/urban_chaos.wasm -o urban_chaos.wasm
```

`mods.nix` does that for `urban_chaos` and `testbed`, then wraps `HANGA_MODS`.

## Tests

Development gate: `nix build .#hanga-dev` (host lib tests natively; agent-client
under xvfb; `mods.nix` runs `urban_chaos` / `testbed` unit tests before the WASM wrap).

- `cargo test --lib` — pure engine predicates (anti-cheat, fracture, economy pack)
- `cargo test -p urban_chaos` / `-p testbed` — mod rules
- `cargo test --test '*'` — agent-client integration (needs a display / xvfb)
- Kani proofs stay behind `cfg(kani)` for `cargo kani`; the same properties replay as
  `kani_replay_*` tests in `.#hanga-dev`

## Next

Larger follow-ups (Hoot runtime in the host, cargo-kani packaging, Zig guest
bindgen) are in [FOLLOWUP.md](FOLLOWUP.md).

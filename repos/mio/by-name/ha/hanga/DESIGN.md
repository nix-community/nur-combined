# Hanga: engine vs mods

Hanga is a Bevy host. Gameplay lives in WASM components (`wit/world.wit`).
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
- `wasmtime` component sandbox + hot-reload
- Teardown *execution*: unset voxels, spawn debris, collapse voxels not connected to ground
- Vehicle *execution*: any rideable that can carry a player. The host builds boxes
  from a kit, moves occupants, and crumples/detaches named parts. It does not
  know "car". Thresholds and which parts fly off come from the mod.
- Gravity *execution*: apply a field the game named (`none`, constant vector, or
  point attractor). Walk/jump stay on the anti-gravity plane at the kit's
  `walk=` / `jump=` speeds. The host does not invent Earth.

Anti-cheat is mathematical: `is_action_physically_possible` plus ranges the **mod** defines.

## Mods (Rust → `wasm32-unknown-unknown` component)

- World gen (`query-voxel`)
- Rules (`mod-evaluate-action`, `mod-should-spawn-agent`, wanted level)
- AI velocities, traffic speed, economy, storyteller
- Spawn positions
- What can shatter (`can-fracture`, `fracture-spread`, `debris-impulse`)
- Passive tick (wanted decay), ambient NPCs
- Localized copy (`voxel-label`, `event-label`, `contract-label`, `item-label`, `supported-locales`)
- Wallet / contracts (`mod-wallet-after`, `mod-offer-contract`, `mod-can-complete`)
- English names for voxels, items, actions, agents, contracts, and story events
- `voxel-catalog` lists meshing-index order (`air,concrete,...`); `query-voxel` still returns that index
- Loot names (`loot-item`) that fill the host's generic 8-slot hotbar
- Crafting recipes (`craft-result`); the host only spends two items and adds the product
- Rideable kit (`vehicle-kit`): kind, traffic, speed, collider, named box parts.
  Urban Chaos ships a car; Testbed ships a platform.
- Gravity (`gravity`): `none`, `constant`/`down`, or `point` (optional inv-sq),
  plus `jump=` and `walk=`. Urban Chaos is Earth; Testbed is a zero-g lab.
- Vehicle crash rules (`crash-severity`, `crash-crumple`, `crash-detach`,
  `crash-wrecks`, `crash-action`, `crash-part-impulse`)
- Heist board (`mod-offer-contract`, `contract-mark`, `mod-can-complete` + context).
  The host paints a mark and reports held item / position / vehicle / near;
  Urban Chaos owns smash, subway pinch, chop-shop, and the armored truck.

### Shipped games

| Game | Mods | Menu |
| --- | --- | --- |
| `urban_chaos` | `urban_chaos` | dusk city, amber title, generated clouds, haze |
| `testbed` | `testbed` | lab teal, no clouds, dim sun |

Load with `--game urban_chaos` (default), `--game testbed`, or `--mod` for a
lone WASM (implicit one-mod game, neutral menu). Packaged builds install
WASM in `$out/share/hanga/mods` (`HANGA_MODS`) and `.game` files in
`$out/share/hanga/games` (`HANGA_GAMES`). The engine currently instantiates
the first listed mod; extra names are reserved for later collections.

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
lead WASM and, on the next Play, respawns the world. Both shipped games and
their mods install in `HANGA_GAMES` / `HANGA_MODS`.
Play is single-player and does **not** talk to Matchbox. Room cycles
`hanga_room` / `hanga_heist` / `hanga_test` / off without starting a session.
Multiplayer joins the selected room (default `ws://localhost:3536/hanga_room`);
`--p2p` does the same, optionally with a URL. Run `nix run .#hanga-signal` first
(also on `PATH` as `hanga-signal` / `matchbox_server` from `nix run .#hanga` and
`.#hanga-dev`). A refused or dropped connection stays in single-player; the HUD
shows wait / live / dropped. Multiplayer after a drop reconnects; pausing does
not open a second socket. Changing Room then Multiplayer switches rooms. Each
peer signs actions with Ed25519; unsigned or forged packets are dropped. Mouse
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

## Next

1. Kani CI for engine + mods
2. Fuller BeamNG node-beam (Urban Chaos still uses severity + detach, not a solver)
3. Multi-mod collections (only the lead WASM loads) and voxel-chunk clear on game switch

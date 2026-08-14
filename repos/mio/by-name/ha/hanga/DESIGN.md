# Hanga: engine vs mods

Hanga is a Bevy host. Gameplay lives in WASM components (`wit/world.wit`).
WIT is only the **sandbox ABI**: the host can call what the component exports, and
mods can call what the host **imports**. Game nouns (cops, fire, lamps, wanted stars)
must not live as extra WIT functions. Host-facing kits (`crash-kit`, `vehicle-kit`,
`gravity`, `steer` context) stay `key=value` strings the host already executes.
Unknown keys are ignored.

**Engine API** (`import host`): `log`, `now-ms`, `self-name`, `peers`, `ask`,
`voxel-at`. `voxel-at` names the lead generator cell (`air` if missing). Player
breaks and places overlay that sample so packs see the edited world.
`payload` is a WIT variant: `empty`, `flag`, `int`, `float`, `text`, or `bag`
(list of `{key, atom}`). WIT here cannot recurse, so deeper trees use dotted
keys (`part.wheel`). `ask` and `on-message` use `payload`. `peers` is a list of
names. Empty peer broadcasts; the first non-`empty` reply wins. Nested asks that
would re-enter a locked store return `empty`.

**Mod API** (`on-message`): packs answer `ping`, `catalog`, `gravity`, and other
topics they invent. The host does not interpret the payload.

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
- Host imports for mods (`log`, clock, identity, `ask` bus, `voxel-at`, `payload` bags)
- Teardown *execution*: unset voxels, spawn debris, collapse voxels not connected to ground
- Vehicle *execution*: any rideable that can carry a player. The host builds boxes
  from a kit, moves occupants, crumples/detaches named parts, and scales fold by
  `stiffness`. Named `tire=` parts squash on the local up axis when grounded.
  Named `beam=` links keep rest length (shortened by crumple, relaxed a few
  passes so chains settle). Crash and fire kits come from the pack that spawned
  the rideable.
- Gravity *execution*: apply a field the game named (`none`, constant vector, or
  point attractor). Walk/jump stay on the anti-gravity plane at the kit's
  `walk=` / `jump=` speeds. The host does not invent Earth.
- Fire *execution*: tick a burn the mod requested (`fire-kit`). The host hangs a
  light, may unset the voxel under the flame, may ignite another rideable in
  range, and may burst. It does not know petrol.

Anti-cheat is mathematical: `is_action_physically_possible` plus ranges the **mod** defines.

## Mods (Rust → `wasm32-unknown-unknown` component)

- World gen (`query-voxel`)
- Rules (`mod-evaluate-action`, `mod-should-spawn-agent`, wanted level)
- Economy / storyteller
- Spawn positions
- What can shatter (`fracture-kit`: can / spread / impulse)
- Rideable kit (`vehicle-kit`): kind, traffic, speed, stiffness 0–100, `tire=` names, `beam=` links, collider, named box parts.
  Urban Chaos ships a soft car with squashing wheels; Testbed ships a stiff platform (and a stiff cart when packed with Urban Chaos).
- Gravity (`gravity`): `none`, `constant`/`down`, or `point` (optional inv-sq),
  plus `jump=` and `walk=`. Urban Chaos is Earth; Testbed is a zero-g lab.
- Vehicle crash (`crash-kit`): one impact string (severity, crumple, wrecks,
  ignites, action, impulse, detach names). Urban Chaos owns street metal; the
  host only folds boxes and hangs a light.
- Burn (`fire-kit`): age + nearby voxel name in, heat / range / consume / jump /
  burst / out. The host only ticks fuel, unsets voxels, jumps the flame, and
  bursts. Urban Chaos owns street petrol; Testbed never burns.
- Planar AI (`steer`): role + measured context in, `vx=`/`vz=` out. Cops and
  traffic are role names, not engine types.
- Passive tick (wanted decay), ambient NPCs
- Localized copy (`voxel-label`, `event-label`, `contract-label`, `item-label`, `supported-locales`)
- Wallet / contracts (`mod-wallet-after`, `mod-offer-contract`, `mod-can-complete`)
- English names for voxels, items, actions, agents, contracts, and story events
- `voxel-catalog` lists meshing-index order (`air,concrete,...`); `query-voxel` still returns that index
- Loot names (`loot-item`) that fill the host's generic 8-slot hotbar
- Crafting recipes (`craft-result`); the host only spends two items and adds the product
- Heist board (`mod-offer-contract`, `contract-mark`, `mod-can-complete` + context).
  The host paints a mark and reports held item / position / vehicle / near;
  Urban Chaos owns smash, subway pinch, chop-shop, and the armored truck.
- Mod bus (`on-message`): answer `ask` from other packs with a `payload` (`ping`, `catalog`, `voxel`, …).

### Shipped games

| Game | Mods | Menu |
| --- | --- | --- |
| `urban_chaos` | `urban_chaos` | dusk city, amber title, generated clouds, haze |
| `testbed` | `testbed` | lab teal, no clouds, dim sun |
| `sandbox` | `urban_chaos`,`testbed` | city look plus the lab pack's stiff cart |

Load with `--game urban_chaos` (default), `--game testbed`, or `--mod` for a
lone WASM (implicit one-mod game, neutral menu). Packaged builds install
WASM in `$out/share/hanga/mods` (`HANGA_MODS`) and `.game` files in
`$out/share/hanga/games` (`HANGA_GAMES`). The engine currently instantiates the lead mod for terrain and extra packs
for vehicles and agents.

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
- Kani proofs stay behind `cfg(kani)` for `cargo kani`; the same properties replay as
  `kani_replay_*` tests in `.#hanga-dev`

## Next

1. Package `cargo-kani` so proofs run as CBMC, not only replay tests
2. A real node-beam lattice (host now shortens named `beam=` rest lengths on crumple)

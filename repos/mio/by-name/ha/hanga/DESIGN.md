# Hanga: engine vs mods

Hanga is a Bevy host. Gameplay lives in WASM components (`wit/world.wit`).
A "game" is a mod, or a collection of mods.

## Engine (Rust / Bevy)

The host knows nothing about cops, wanted levels, cities, or quests.

- Voxel meshing (`bevy_voxel_world`) and rigid-body physics (`avian3d`)
- Window / headless / `--text-client` / `--agent-client` I/O
- Player-editable key bindings (`bindings.conf` + Controls menu)
- Player-facing locale (`--lang` / `HANGA_LANG`): English, te reo Māori, français, 台灣中文.
  Host UI strings live here; gameplay names are asked of the mod with that locale tag.
- P2P transport (`matchbox`), TrustLedger distance checks, action fingerprints
- `wasmtime` component sandbox + hot-reload
- Teardown *execution*: unset voxels, spawn debris, collapse voxels not connected to ground

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

### Shipped mods

| Mod | Purpose |
| --- | --- |
| `urban_chaos` | Voxel city + subway + GTA wanted level + Teardown buildings |
| `testbed` | Checkerboard void for engine/debug (no wanted level) |

Load with `--mod urban_chaos` (default) or `--mod testbed`. Packaged builds
install both as wasmtime components in `$out/share/hanga/mods` (`HANGA_MODS`).

## Commands

```
hanga
hanga --mod testbed
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
hanga --bindings /path/to/bindings.conf
```

`nix run .#hanga` and `nix run .#hanga-dev` wrap `HANGA_MODS` so gameplay WASM
loads without a local Cargo target dir.

`nix run .#hanga-dev` opens a main menu (Play / Multiplayer / Game / Language / Controls / Quit).
The Game row cycles Urban Chaos and Testbed; both WASM components ship in `HANGA_MODS`.
Play is single-player and does **not** talk to Matchbox. Multiplayer or `--p2p` joins a
room only if a signaling server is already running; a refused connection stays in
single-player instead of crashing. Mouse look is captured while playing.

Key bindings default to WASD / mouse / E / C / F / 1–8 / Esc. Players can change them
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

- `cargo test --lib` — pure engine predicates (anti-cheat, fracture, economy pack)
- `cargo test -p urban_chaos` / `-p testbed` — mod rules
- `cargo test --test '*'` — agent-client integration (needs a display / xvfb)

## Next

1. Matchbox signaling in nix; cryptographic signatures beyond fingerprints
2. Kani CI for engine + mods
3. Matchbox room UI / reconnect; more heist loops beyond smash-and-grab

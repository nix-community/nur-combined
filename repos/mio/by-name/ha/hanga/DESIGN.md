# Hanga: engine vs mods

Hanga is a Bevy host. Gameplay lives in WASM components (`wit/world.wit`).
A "game" is a mod, or a collection of mods.

## Engine (Rust / Bevy)

The host knows nothing about cops, wanted levels, cities, or quests.

- Voxel meshing (`bevy_voxel_world`) and rigid-body physics (`avian3d`)
- Window / headless / `--text-client` / `--agent-client` I/O
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
- Localized copy (`voxel-label`, `event-label`, `contract-label`, `supported-locales`)
- Wallet / contracts (`mod-wallet-after`, `mod-offer-contract`, `mod-can-complete`)

### Shipped mods

| Mod | Purpose |
| --- | --- |
| `urban_chaos` | Voxel city + GTA wanted level + Teardown buildings |
| `testbed` | Checkerboard void for engine/debug (no wanted level) |

Load with `--mod urban_chaos` (default) or `--mod testbed`.

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
```

Locales: `en`, `mi` (Māori), `fr`, `zh-TW` (Taiwan Chinese). Also `HANGA_LANG` or `LANG`.
Text-client extras: `look` / `status`, `accept job`, `complete job`, `fence`, `lang mi`.
English commands always work; each locale has native aliases (`前進`, `avancer`, `titiro`, …).
Agent JSON stays keyed in English, with `locale` + `voxel_label` on Look.

Build a mod as a WASM component (host tests use `rlib`; wasm needs `cdylib`):

```
cargo rustc -p urban_chaos --target wasm32-unknown-unknown -- --crate-type cdylib
# optional:
# wasm-tools component new target/wasm32-unknown-unknown/debug/urban_chaos.wasm -o urban_chaos.component.wasm
```

`wasmtime` 47's component loader accepts a core module *or* a component; for full WIT
binding the mod must be a component (`wit-bindgen` + `wasm-tools component new`, or
`cargo component`).

## Tests

- `cargo test --lib` — pure engine predicates (anti-cheat, fracture, economy pack)
- `cargo test -p urban_chaos` / `-p testbed` — mod rules
- `cargo test --test '*'` — agent-client integration (needs a display / xvfb)

## Next

1. Compile mods to components in `package.nix` and install them next to the binary
2. Matchbox signaling in nix; cryptographic signatures beyond fingerprints
3. Kani CI for engine + mods
4. Crafting / inventory and subway world-gen still live in Urban Chaos

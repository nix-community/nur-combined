# Hanga: engine vs mods

Hanga is a Bevy host. Gameplay lives in WASM components (`wit/world.wit`).
A "game" is a mod, or a collection of mods.

## Engine (Rust / Bevy)

The host knows nothing about cops, wanted levels, cities, or quests.

- Voxel meshing (`bevy_voxel_world`) and rigid-body physics (`avian3d`)
- Window / headless / `--text-client` / `--agent-client` I/O
- P2P transport (`matchbox`) and TrustLedger distance checks
- `wasmtime` component sandbox + hot-reload
- Teardown *execution*: unset voxels, spawn debris, collapse unsupported neighbors

Anti-cheat is mathematical: `is_action_physically_possible` plus ranges the **mod** defines.

## Mods (Rust → `wasm32-unknown-unknown` component)

- World gen (`query-voxel`)
- Rules (`mod-evaluate-action`, `mod-should-spawn-agent`, wanted level)
- AI velocities, traffic speed, economy, storyteller
- Spawn positions
- What can shatter (`can-fracture`, `fracture-spread`, `debris-impulse`)

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
```

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
2. Flood-fill support (connected-to-ground) instead of only "solid immediately below"
3. Matchbox signaling in nix; identity / signed actions
4. Kani CI for engine + mods

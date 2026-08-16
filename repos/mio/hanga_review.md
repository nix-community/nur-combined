# Hanga Codebase Review

## Architecture Overview

Hanga is a Bevy-based host engine that runs game logic encapsulated in WASM components. It strongly separates the "engine" (rendering, physics, host environments) from the "mods" (gameplay, rules, world generation, UI strings) via a well-defined `wit/world.wit` interface.

### The Host (Engine)
- **Language**: Rust
- **Frameworks**: `bevy` for the game loop, `bevy_voxel_world` for meshing, `avian3d` for physics, and `wasmtime` for WASM component sandboxing.
- **Role**: Manages the window, handles I/O (headless/text/GUI), networking via `matchbox` (P2P), manages player keybindings and locales, and handles physics updates (vehicles, crashes, fire). The engine acts as a platform; it is explicitly unaware of game-specific concepts like "cops" or "cities".
- **Interaction**: Exposes a `host` ABI providing tools to write to logs, invoke mods, edit voxels, query player state, and schedule future calls (`after`).

### The Mods (WASM Components)
- **Language**: Rust (compiled to `wasm32-unknown-unknown`), or any language supporting the WIT bindings (e.g., Kotlin, Zig, Nim in `hanga-contrib`).
- **Role**: Define world generation (via `query-voxel`), entity spawning, gameplay rules (economy, wanted levels), gravity configuration, vehicular configurations (`vehicle-kit`, `crash-kit`), localized names, and crafted recipes.
- **Communication**: Operates on an Erlang-style Actor model (`gen_server`/`gen_event`). Each mod pack has a single mailbox and does not share memory. Mods communicate using:
  - `invoke` for synchronous calls (waits for reply).
  - `send` for asynchronous mailbox casts (no reply).
  - `emit` for event broadcasting to all listeners.

## Codebase Structure

- `src/`: The Bevy host implementation. Contains logic for mod management (`mod_manager.rs`), physics and gravity (`gravity.rs`, `vehicle.rs`), game lifecycle (`game.rs`), and the host ABI bindings (`bindings.rs`).
- `wit/world.wit`: The WebAssembly Interface Types definition. Defines the data structures (`cell`, `value` forming a JSON-shaped structure) and the `host`/`guest` interfaces defining ABI version `6`.
- `mods/`: Shipped mods/games.
  - `urban_chaos/`: Earth-gravity mod containing cops, cities, street metal crashes, and petrol burns.
  - `testbed/`: Zero-G lab mod.
- `games/`: Configuration files mapping mods and visuals for different scenarios (`urban_chaos.game`, `sandbox.game`, `testbed.game`).

## Strengths
1. **Strong Isolation**: WASM provides fantastic isolation. By forcing mods to communicate over a message-passing bus and preventing shared heap access, the engine achieves a stable and highly modular environment without the reentrancy issues of typical embedded Lua/Godot setups.
2. **Clear Boundaries**: The engine only does math (physics, rendering) and the mods do meaning. The decision to make the host unaware of specific game nouns ensures it remains a general-purpose foundation.
3. **P2P Multiplayer**: TrustLedger-style Ed25519-signed actions over `matchbox` natively integrates multiplayer with anti-cheat capabilities based on mathematical constraints.

## Areas for Improvement
- [ ] **Serialization Overhead**: Since WIT cannot easily nest variant types like JSON natively, Hanga uses a flattened index-based arena (`cells` + `root`) for complex types. While clever, this necessitates heavy packing/unpacking over the FFI boundary, which might become a bottleneck for very complex JSON payloads on high-frequency events.
- [ ] **Synchronous `invoke` Deadlocks**: Making a direct `invoke` to a busy mod fails with `"busy"` rather than queueing. While this is well-documented (analogous to OTP's self-call deadlock prevention), it puts the burden on mod developers to explicitly use `send` when queueing is intended.

## Summary
The Hanga project leverages WASM Component Models and Bevy to build an exceptionally rigorous, actor-based engine. By embracing strict message-passing (Erlang-style) over the typical shared-state scripting models, it guarantees modularity and resilience, paving a strong path forward for safe modding and P2P environments.

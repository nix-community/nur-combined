# Design: auto-generate deploy.nodes (short)

- Date: 2026-10-25. Approach picked: generate from `configurations` + overrides (option 1 from brainstorming 2026-10-25).

## Intent and why

The 22 hand-written `deploy.nodes` in `flake.nix` duplicate what `configurations/default.nix` already knows. Every new host needs two edits that can drift. Generate nodes instead: infer everything, override the weird ones.

## Goals / non-goals / anti-goals

- Goal: adding a standard host = one entry in `configurations/default.nix`, zero `flake.nix` edits; same 22 nodes produced today, byte-for-byte same shape (`hostname`, `profiles.system.{user, path}`).
- Non-goal: changing deploy behavior, users, hostnames, or the `deploy-rs-checks` filter.
- Anti-goal: a generation scheme that evaluates all configs eagerly (would reintroduce the OOM pattern from the sharded-CI work) — generation must stay lazy per node via `mapAttrs`.

## Constraints

- `deploy-rs-checks` reads `profile.path.system` for every node, so each generated `path` must expose `.system` exactly like today's `activate.*` results (it will — same constructors).
- `nix flake check` ignores the `deploy` output (today: "unknown flake output" warning), so generation code never runs in CI eval.
- Verified: `.pkgs.stdenv.hostPlatform.system` evaluates on nixos (`nas` → `x86_64-linux`) and darwin (`MacBook-Pro` → `aarch64-darwin`) configs without building.

## Approaches

1. **Generate + overrides (picked):** `mapAttrs` over `configurations.nixosConfigurations` (type `nixos`) and `darwinConfigurations` (type `darwin`), inferring `system` from the evaluated config, defaults `hostname = name`, `user = "toyvo"`; standalone home-manager nodes (`pixel10a`→`debian`/`droid`, `steamdeck`→`deck`) plus any exceptions live in a small overrides table merged over the generated set. Why: only path to zero-touch standard hosts.
2. Per-host metadata in each `default.nix` (rejected: scatters deploy concerns over 20+ files, still one stanza per host).
3. Helper constructor with explicit table (rejected: still one line per host in `flake.nix`).

## Decided / left to builder

- Decided: helper + overrides live inline in `flake.nix`'s `flake.deploy.nodes` let-block (keeps the diff local); home-manager nodes are overrides-only (their node names don't match config attr names); overrides win over generated nodes via `//`.
- Left to builder: exact helper/override names, and whether to assert generated node set equals today's 22 (recommended: a comment listing them, or a one-off `nix eval` diff during review).

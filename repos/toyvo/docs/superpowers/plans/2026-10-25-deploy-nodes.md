# Auto-generate deploy.nodes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Generate `flake.deploy.nodes` from `configurations` with inferred defaults plus an overrides table, producing today's 22 nodes unchanged.

**Architecture:** A `let`-block helper in `flake.nix` maps over `configurations.nixosConfigurations`/`darwinConfigurations` (inferring type, system, hostname, user) and merges an overrides attrset for the home-manager nodes and exceptions.

**Tech Stack:** Nix flakes, deploy-rs activate constructors.

**Spec:** `docs/superpowers/specs/2026-10-25-deploy-nodes-design.md`

## Global Constraints

- Every generated node keeps today's exact shape: `{ hostname, profiles.system = { user, path }; }` built with `deploy-rs.lib.<system>.activate.<type>`.
- Generation stays lazy per node (`mapAttrs`); nothing may force all configs eagerly.
- `nix fmt` must pass; `nix flake check --no-build` must stay green.
- The 22 node names and their hostname/user/type/system must be identical before and after (verify with the baseline file).

## Review Focus

- A node missing or renamed after generation (deploy target silently disappears) — expect the coverage step to fail on any diff.
- A wrong `system` on a generated node (wrong `deploy-rs.lib.<system>`, broken deploy or wrong checks-filter bucket) — expect per-node system comparison against the hardcoded values.
- Overrides losing to generated nodes (merge order flipped, `pixel10a` deploys NixOS instead of home-manager) — expect an explicit check of both override nodes.

---

### Task 1: Record baseline and implement generation

**Files:**
- Modify: `flake.nix` (`flake.deploy.nodes` block)
- Test: `nix eval --json '.#deploy.nodes' --apply builtins.attrNames` and per-node field comparison

**Interfaces:**
- Consumes: `configurations` (from `inputs`), `deploy-rs.lib`, `self.{nixos,darwin,home}Configurations`.
- Produces: `deploy.nodes` with identical 22 entries.

- [ ] **Step 1: Write the failing test — record the baseline**

Run: `nix eval --json '.#deploy.nodes' --apply 'builtins.mapAttrs (_: n: { hostname = n.hostname; user = n.profiles.system.user; system = n.profiles.system.path.system; })' | jq -S . > /tmp/deploy-baseline.json && cat /tmp/deploy-baseline.json`
Expected: JSON object with all 22 nodes, their hostname/user/system. (This is the RED: after the rewrite, this same command must produce identical output.)

- [ ] **Step 2: Run it to confirm the baseline is captured**

Run: `jq 'keys | length' /tmp/deploy-baseline.json`
Expected: `22`.

- [ ] **Step 3: Implement generation in `flake.nix`**

Replace the hand-written `deploy.nodes = { ... }` with a `let`-block:
`mkNode = { type, system, config, hostname, user }: { inherit hostname; profiles.system = { inherit user; path = deploy-rs.lib.${system}.activate.${type} self.${if type == "nixos" then "nixosConfigurations" else if type == "darwin" then "darwinConfigurations" else "homeConfigurations"}.${config}; }; };`
plus `autoNixos = builtins.mapAttrs (name: _: mkNode { type = "nixos"; system = self.nixosConfigurations.${name}.pkgs.stdenv.hostPlatform.system; config = name; hostname = name; user = "toyvo"; }) configurations.nixosConfigurations;` (same for darwin), plus `overrides = { pixel10a = mkNode { type = "home-manager"; system = "aarch64-linux"; config = "droid@debian"; hostname = "debian"; user = "droid"; }; steamdeck = mkNode { type = "home-manager"; system = "x86_64-linux"; config = "deck@steamdeck"; hostname = "steamdeck"; user = "deck"; }; };`, final `deploy.nodes = autoNixos // autoDarwin // overrides;`. (Implementer: use `configurations` from the outer `let`, not `self`, to avoid self-reference cycles; keep exact current node names.)

- [ ] **Step 4: Verify identical output**

Run: `nix eval --json '.#deploy.nodes' --apply 'builtins.mapAttrs (_: n: { hostname = n.hostname; user = n.profiles.system.user; system = n.profiles.system.path.system; })' | jq -S . > /tmp/deploy-after.json && diff /tmp/deploy-baseline.json /tmp/deploy-after.json && echo IDENTICAL`
Expected: `IDENTICAL`, no diff.

- [ ] **Step 5: Verify evaluation stays green**

Run: `nix flake check --no-build 2>&1 | tail -2`
Expected: `all checks passed!`.

- [ ] **Step 6: Commit**

```bash
jj describe -m "flake: auto-generate deploy.nodes from configurations"
```

# Sharded CI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the OOM-killing monolithic CI evaluation with sharded per-slice builds that cover everything.

**Architecture:** Split `perSystem.checks` into 4 `all-shard-N` aggregates in `flake.nix` and rewrite the `build` job in `build.yml` to build per-host toplevels plus per-shard aggregates in separate `nix build -j 1` invocations, so no single nix process evaluates the whole flake.

**Tech Stack:** Nix flakes (flake-parts perSystem), Forgejo Actions workflow YAML, NixOS systemd service config.

**Spec:** `docs/superpowers/specs/2026-10-25-sharded-ci-design.md`

## Global Constraints

- Jobs run on the `native` nas runner, host executor, shared system store.
- Every CI `nix` invocation uses `-j 1` (build parallelism stays off; memory is the constraint, not CPU).
- Every host toplevel and every package currently covered must be covered by exactly one shard/step.
- CI must never invoke `nix flake check` or `nix flake show` on the full flake.
- `nix fmt` must pass before finishing.

## Review Focus

- A check present in the old `all` but missing from every shard (silent coverage loss) — expect the plan's coverage step to fail if any old input is orphaned.
- An aarch64 toplevel that can't build under binfmt on nas — expect a clear per-host build error naming the host, not a hung job.
- A shard that still OOMs because MC-server version bombs landed in one shard — expect roughly even shard sizes by derivation count.
- `nix flake check --no-build` locally still evaluating the new shards without error — expect it to pass (it builds all shards when run locally, so it stays heavy; CI just doesn't call it).
- Runner memory cap too tight killing healthy builds — expect the cap set with headroom (26G/28G on a 31G+15G-zram box), not near the 19G observed peak.

---

### Task 1: Shard `perSystem.checks` in `flake.nix`

**Files:**
- Modify: `flake.nix` (perSystem `checks` block, ~lines 361-393)
- Test: `nix eval --json '.#checks.x86_64-linux' --apply builtins.attrNames`

**Interfaces:**
- Consumes: existing `checks` attrset construction (`flattenPkgsWithPaths`, `isBuildable`/`isCacheable`/`forSystem` filters, `deploy-rs-checks`, `devShells` mapping).
- Produces: `checks.all-shard-1` … `checks.all-shard-4` derivations; `checks.all` removed. Later tasks invoke `nix build .#checks.<system>.all-shard-N`.

- [ ] **Step 1: Record the current check list as the coverage baseline**

Run: `nix eval --json '.#checks.x86_64-linux' --apply builtins.attrNames | jq -S . > /tmp/checks-baseline.json && cat /tmp/checks-baseline.json`
Expected: JSON list containing `all` plus the 12 other checks (13 total).

- [ ] **Step 2: Implement sharded aggregates in `flake.nix`**

In the perSystem `checks` block: bind the package-check attrset to a `pkgChecks` let-variable, sort its names, partition round-robin into 4 lists (`builtins.filter (n: builtins.mod (builtins.stringLength n + <index>) 4 == <shard>)` or equivalent index-mod-4 over sorted names — exact function is the implementer's choice, but it must be deterministic and even); pin deploy + devShell checks into shard 1; define `all-shard-1..4` each as a `runCommand` aggregating its slice (same pattern as today's `all`); delete `all`.

- [ ] **Step 3: Verify shards exist and `all` is gone**

Run: `nix eval --json '.#checks.x86_64-linux' --apply builtins.attrNames | jq -S .`
Expected: list contains `all-shard-1` … `all-shard-4`, does NOT contain `all`.

- [ ] **Step 4: Verify coverage — every baseline input (minus `all`) is in exactly one shard**

Run: `for s in 1 2 3 4; do nix eval --json ".#checks.x86_64-linux.all-shard-$s" --apply 'builtins.toString' >/dev/null && echo "shard $s ok"; done` plus a nix eval comparing the union of shard `buildInputs` against `/tmp/checks-baseline.json` minus `all` (implementer writes the one-liner; any orphan or duplicate fails the step).
Expected: all 4 shards evaluate; union equals baseline-minus-`all` with no orphans/duplicates.

- [ ] **Step 5: Commit**

```bash
jj describe -m "flake: shard checks.all into all-shard-1..4"
```

### Task 2: Rewrite the `build` job in `build.yml`

**Files:**
- Modify: `.forgejo/workflows/build.yml` (`build` job steps)
- Test: `nix fmt` + workflow YAML parse + dry-run of each new build command with `--dry-run` or `--no-link` on one host/one shard

**Interfaces:**
- Consumes: `checks.all-shard-N` from Task 1; `nixosConfigurations.<host>.config.system.build.toplevel` attribute paths.
- Produces: CI steps that build (a) per-host toplevels, (b) per-shard aggregates. Task 4 runs the full verification.

- [ ] **Step 1: Remove the monolith steps**

Delete the `Show evaluation` (`nix flake show`), `Check evaluation` (`nix flake check -j 1`), and `Build nix packages` (`nix build -j 1 -L ".#checks.$(...).all"`) steps from the `build` job.

- [ ] **Step 2: Add toplevel matrix steps**

Add a step (or matrix) that builds each `nixosConfigurations` host toplevel individually: `nix build -j 1 -L .#nixosConfigurations.<host>.config.system.build.toplevel --no-link`. Group 2–3 hosts per step if desired for log readability, but each `nix build` invocation covers at most one host so evaluation stays per-host. Cover all 18 hosts from `configurations/default.nix`. Keep `timeout-minutes: 240` on the job.

- [ ] **Step 3: Add package shard steps**

Add 4 steps, one per shard: `nix build -j 1 -L ".#checks.$(nix eval --raw --impure --expr builtins.currentSystem).all-shard-N"`. These replace the old single `checks.all` build.

- [ ] **Step 4: Verify one host + one shard build**

Run: `nix build -j 1 .#nixosConfigurations.nas.config.system.build.toplevel --no-link --dry-run 2>&1 | head -20`
Expected: succeeds (exit 0), prints planned store paths, no evaluation assertion errors.

Run: `nix build -j 1 -L .#checks.x86_64-linux.all-shard-1 --dry-run 2>&1 | head -20`
Expected: succeeds (exit 0).

- [ ] **Step 5: Commit**

```bash
jj describe -m "ci: shard build job into per-host toplevels and per-slice package builds"
```

### Task 3: Cap runner memory on nas

**Files:**
- Modify: `configurations/nixos/nas/configuration.nix` (`systemd.services.forgejo-runner-nas` block near `restartIfChanged = false`)
- Test: `nix flake check --no-build` (evaluation only) or `nixos-rebuild dry-run`

**Interfaces:**
- Consumes: nothing from Tasks 1–2.
- Produces: `MemoryHigh=26G` / `MemoryMax=28G` on `forgejo-runner-nas` so future blowups fail the job instead of kernel-OOM-killing the unit and starving postgres/forgejo.

- [ ] **Step 1: Implement the memory cap**

Add `systemd.services.forgejo-runner-nas.serviceConfig.MemoryHigh = "26G";` and `MemoryMax = "28G";` next to the existing `restartIfChanged = false` line.

- [ ] **Step 2: Verify evaluation**

Run: `nix flake check --no-build 2>&1 | tail -5`
Expected: `all checks passed!` (with the usual opencode-tui warnings only).

- [ ] **Step 3: Commit**

```bash
jj describe -m "nas: cap forgejo-runner memory so blowups fail the job, not the host"
```

### Task 4: Format, full verification, todos

**Files:**
- Modify: `todos.md` (check off the sharding item), `docs/superpowers/specs/2026-10-25-sharded-ci-design.md` (no change needed unless behavior drifted)
- Test: `nix fmt`, `nix flake check --no-build`

**Interfaces:**
- Consumes: Tasks 1–3.
- Produces: green tree ready for review/deploy.

- [ ] **Step 1: Format**

Run: `nix fmt`
Expected: exit 0; only intended files changed.

- [ ] **Step 2: Full evaluation check**

Run: `nix flake check --no-build 2>&1 | tail -5`
Expected: `all checks passed!`.

- [ ] **Step 3: Update todos.md**

Check off / remove the "shard the ~3h checks.all monolith" item; add a follow-up only if something was deferred (e.g. NUR legs if they still look heavy).

- [ ] **Step 4: Final commit**

```bash
jj describe -m "ci: sharded evaluation to fix runner OOMs"  # amend/squash as appropriate
```

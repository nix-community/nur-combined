# herdr-core 0.1.19 override for fish default shell Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** herdr-app spawns fish for new terminals by overriding nixpkgs herdr-core 0.1.15 with upstream v0.1.19, which supports the already-written `shell = [fish, -l]` in `~/.config/herdr-core/config.toml`.

**Architecture:** Follow the `herdr-desktop-fixed` precedent in `modules/os/gui.nix`: an inline `overrideAttrs` version bump with a TODO to drop it once nixpkgs moves past 0.1.15. No new `pkgs/` NUR package (avoids shadowing a nixpkgs name in NUR outputs). v0.1.19 tag exists upstream (`herdrdev/herdr-core`, tags verified: v0.1.16–v0.1.19).

**Tech Stack:** Nix (nixpkgs `rustPlatform.buildRustPackage`, `fetchFromGitHub` + submodules, `cargoHash`, `zig_0_16.fetchDeps`), `hc`, fish.

**Spec:** User request: "make the change in nix" so herdr-app uses fish. Prior findings: `~/.config/herdr-core/config.toml` already contains `shell = ["/run/current-system/sw/bin/fish", "-l"]`; live core 0.1.15 ignores it (feature needs >= 0.1.16, commit `ca23c642`); nixpkgs pinned revs and HEAD all ship 0.1.15; `programs.herdr.settings.terminal.default_shell` in `modules/home/users/toyvo.nix` targets the separate `herdr` CLI 0.9.5 config and does not affect herdr-app.

## Global Constraints

- `nix fmt` before finishing (nixfmt/prettier/yamlfmt/mdformat).
- Keep `todos.md` Herdr entry current: check off or reword once done.
- Version-control via jj: `jj describe -m "..."`, then `jj bookmark set main -r @ && jj git push` (never `jj git push --all`).
- Do not deploy with `darwin-rebuild`/`deploy` and do not restart the live core; verification uses `nix build` plus a scratch core session. Activation is the user's step.
- Console module is shared across darwin + NixOS hosts: the override must evaluate for Linux too.

## Review Focus

- v0.1.19's tree may have renamed files the nixpkgs `postPatch` `--replace-fail` substitutions touch (e.g. `vendor/ghostty/...`, `crates/herdr-core/src/releases.rs`): a build failure names the exact file; Task 2 pins this.
- `cargoHash`/`zigDeps` hashes are version-specific: each gets its value from a real build with `lib.fakeHash`, never invented.
- Darwin sandbox hides system keychains from Zig dep fetching: use `--option sandbox false` for hash-discovery builds on this Mac, as the nixpkgs comment documents.
- The live core keeps running 0.1.15 until the user rebuilds + restarts it: nothing in this plan restarts it, and the scratch-session test (Task 3) must use its own `HC_SESSION` and scratch XDG paths.

---

## Execution notes (2026-11-10)

- Targeted v0.1.16, not v0.1.19: v0.1.19 renamed `exe` to `bin` in
  `machines.rs`, breaking one nixpkgs `postPatch --replace-fail`
  substitution. v0.1.16 is the lowest version with the `shell` feature
  and applies all nixpkgs patches unchanged.
- `zigDeps` reuses `pkgs.herdr-core.zigDeps` (0.1.15 output): the
  `vendor/ghostty` submodule pin is identical in 0.1.15/0.1.16/0.1.19,
  a fresh `zig fetch` cannot init TLS on Darwin, and the output is
  platform-independent. Note: inside `overrideAttrs`, `old.zigDeps`
  already points at the new src (finalAttrs re-application), so the
  original package output must be named explicitly.
- Verified end to end: full 0.1.16 build succeeded; scratch core
  (`HC_SESSION` + temp `XDG_STATE_HOME`, live core untouched) spawned
  `argv: ['/run/current-system/sw/bin/fish', '-l']` for a no-arg
  terminal. Live core (0.1.15) and Herdr window untouched.
- Committed as an isolated commit (console.nix + todos.md only);
  pre-existing unrelated WIP left in the working copy. Did NOT push
  and did NOT deploy (`darwin-rebuild` + core restart are the owner's
  steps: rebuild, then `hc server restart` or a fresh core start so new
  terminals spawn fish).

### Task 1: Override herdr-core to v0.1.19 in `modules/os/console.nix`

**Files:**
- Modify: `modules/os/console.nix` (the `with pkgs;` `systemPackages` list containing `herdr-core`, ~line 46)

**Interfaces:**
- Consumes: nixpkgs `herdr-core` 0.1.15 (`rustPlatform.buildRustPackage`, `finalAttrs` with `version`, `src`, `cargoHash`, `zigDeps`).
- Produces: `herdr-core-fish` (name TBD in file) derivation of v0.1.19 used in `systemPackages` in place of `herdr-core`.

- [ ] **Step 1: Add the override next to the package list in `modules/os/console.nix`**

```nix
# herdr-core >= 0.1.16 honors `shell = [...]` in herdr-core/config.toml
# (fish default shell); nixpkgs still ships 0.1.15.
# TODO: drop once nixpkgs herdr-core moves past 0.1.15.
herdr-core-0-1-19 = pkgs.herdr-core.overrideAttrs (old: rec {
  version = "0.1.19";
  src = pkgs.fetchFromGitHub {
    owner = "herdrdev";
    repo = "herdr-core";
    tag = "v${version}";
    fetchSubmodules = true;
    hash = lib.fakeHash;
  };
  cargoHash = lib.fakeHash;
  zigDeps = pkgs.zig_0_16.fetchDeps {
    pname = "herdr-core";
    inherit version;
    src = "${src}/vendor/ghostty";
    fetchAll = true;
    hash = lib.fakeHash;
  };
});
```

and reference it in `systemPackages` instead of `herdr-core`. (`old` unused except via `rec` scoping is fine; keep `lib`/`pkgs` in scope as the module already has them.)

- [ ] **Step 2: Evaluate it**

Run: `nix build --no-link --option sandbox false .#legacyPackages.aarch64-darwin.herdr-core 2>&1 | head` — not applicable (override is inline, not a flake output).
Instead run: `nix-instantiate --eval ...` is awkward for a module; go straight to Task 2's build of the host config's package set is heavy. Cheapest check: `nix build --no-link --option sandbox false --expr '...'`? The reliable path is Task 2 Step 1 (build the darwin system), which surfaces eval errors too. Record this: Task 1 has no independent build; its test is Task 2's.

### Task 2: Resolve hashes and build

**Files:**
- Modify: `modules/os/console.nix` (replace the three `lib.fakeHash` values with real ones)

**Interfaces:**
- Consumes: Task 1's override with fake hashes.
- Produces: pinned-hash override that builds.

- [ ] **Step 1: Build to discover the src hash**

Run (from `~/nixcfg`): `nix build --no-link --option sandbox false '.#darwinConfigurations.FQ-M-6KL6HVKQ.config.system.build.toplevel'` — full system build is slow; prefer building just the package via a throwaway expression? Host pkgs isn't an output. Pragmatic: `nix build --no-link --option sandbox false --file '<nixpkgs>'` won't have the override. So: temporarily evaluate with `nix-build -E` using the flake's unstablePkgs + the overrideAttrs snippet? Simplest reliable: run the system build; it fails fast on the fake src hash and prints the expected hash. Copy it in.
Expected: FAIL with `got: sha256-...`; replace src `hash`.

- [ ] **Step 2: Repeat for `cargoHash`, then `zigDeps.hash`**

Run the same build after each replacement.
Expected: each run fails naming the next hash; final run proceeds to compile (long: Rust + Zig vendored build).

- [ ] **Step 3: Full package build succeeds**

Run: `nix build --no-link --option sandbox false '.#darwinConfigurations.FQ-M-6KL6HVKQ.config.system.build.toplevel'`
Expected: success (exit 0). If `postPatch` `--replace-fail` breaks on v0.1.19's tree, the error names the file: either adjust the substitution minimally or pick v0.1.16 (lowest version with the feature) and note why.

- [ ] **Step 4: Confirm the built binary reports 0.1.19**

Run: `nix build --option sandbox false --print-out-paths '.#darwinConfigurations.FQ-M-6KL6HVKQ.config.system.build.toplevel'` is the whole system; instead locate hc in the closure: `find $(...system path...) -path '*herdr-core*/bin/hc' | head -1` then `<that>/bin/hc --version`.
Expected: `hc 0.1.19`.

### Task 3: Verify fish default shell in a scratch core session, then finish

**Files:**
- Modify: `todos.md` (Herdr entry), `nix fmt` (whole tree)

**Interfaces:**
- Consumes: Task 2's built 0.1.19 `hc` binary path.
- Produces: proof the `shell` setting works; formatted tree; jj commit.

- [ ] **Step 1: Start a scratch core with the new binary and the live config**

Run: `export HC_SESSION=nishelltest XDG_CONFIG_HOME=~/.config XDG_STATE_HOME=$(mktemp -d) XDG_RUNTIME_DIR=${TMPDIR:-/tmp}; <0.1.19-hc> server start` (uses `~/.config/herdr-core/config.toml` with `shell = [fish, -l]`, isolated state; live core untouched).
Expected: server starts for session `nishelltest`.

- [ ] **Step 2: Spawn a no-arg terminal and check its argv**

Run: `<0.1.19-hc> run --bg --json` then `<0.1.19-hc> get <addr> --json | jq .argv`.
Expected: `argv` starts with the fish path (e.g. `/run/current-system/sw/bin/fish`), not `/bin/zsh`.

- [ ] **Step 3: Clean up the scratch session**

Run: `<0.1.19-hc> kill <addr>; <0.1.19-hc> rm <addr>` and stop the scratch server if one is running (`server stop` scoped to `HC_SESSION=nishelltest` only — never touch the default session).
Expected: no `nishelltest` terminals remain; live `hc ls` output unchanged from before.

- [ ] **Step 4: Format, update todos, commit**

Run: `nix fmt`; update the `todos.md` Herdr entry (check off / reword to "deployed?" state — activation + core restart still belong to the user); `jj describe -m "herdr-core 0.1.19 for fish default shell"`; `jj bookmark set main -r @ && jj git push`.
Expected: clean `nix fmt` diff only in intended files; commit pushed.

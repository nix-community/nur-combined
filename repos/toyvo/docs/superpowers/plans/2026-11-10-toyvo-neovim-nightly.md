# toyvo-neovim nightly Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `toyvo-neovim` builds its config on nightly neovim, with a bun `update.ts` that refreshes the nightly pin in `versions.json` (picked up by the daily CI updater like every other `pkgs/*/versions.json`).

**Architecture:** `pkgs/toyvo-neovim/versions.json` holds a single pin `{ version, rev, hash }` for the neovim/neovim `nightly` release commit. `default.nix` reads it and passes nvf a package set with `neovim-unwrapped` overridden to that rev. `update.ts` follows the tinycast updater pattern (GitHub API + cache-first, shared `scripts/update-lib.ts` helpers); the git-tree hash comes from `nix flake prefetch` on a `git+https` URL so it is byte-identical to what `fetchFromGitHub` expects. Registered in `scripts/update-all.ts`.

**Tech Stack:** Nix (overrideAttrs on `neovim-unwrapped`), nvf (`neovimConfiguration`), bun + `scripts/update-lib.ts`, GitHub REST API.

**Spec:** User directive: "just do an override on neovim-unwrapped using the hash and version we get from the update script" (bun, not deno).

## Global Constraints

- `nix fmt` before finishing (prettier covers `.ts`).
- `todos.md` upkeep; jj workflow (`jj describe`, bookmark + push per repo norms) — commit only this feature's files.
- No unit tests in this repo: verification is `nix build` of the package + `nvim --version` showing the nightly label, plus a dry run of the updater proving cache-hit no-op and pin refresh.
- The override must not rebuild the plugin world: only `neovim-unwrapped` changes; `vimPlugins`, `runtimeDeps`, wrapper stay on host pkgs.
- Updater runs under `nix develop` (needs `nix` for `flake prefetch`); keep GitHub calls anonymous-friendly (two a day is far under rate limits; honor `GITHUB_TOKEN` like the other updaters).

## Review Focus

- Neovim nightly moves daily and nvf modules can lag its APIs: a green build today doesn't promise green tomorrow; the daily CI updater + PR flow is the safety net, not this plan.
- `fetchFromGitHub` needs the git-tree hash, not a tarball hash: the plan pins the hash via `nix flake prefetch git+https://...?rev=`, never via download hashing.
- `pkgs.extend` inside `default.nix` must scope to `neovim-unwrapped` only; if the extended set leaks into plugin/runtime inputs, evaluation cost and closure churn grow for no reason.

---

### Task 1: `versions.json` + `update.ts` for the nightly pin

**Files:**
- Create: `pkgs/toyvo-neovim/versions.json` (seeded by running the updater)
- Create: `pkgs/toyvo-neovim/update.ts`
- Modify: `scripts/update-all.ts` (append `"pkgs/toyvo-neovim/update.ts"` to `UPDATERS`)

**Interfaces:**
- Consumes: GitHub API (`GET /repos/neovim/neovim/git/refs/tags/nightly` → commit sha; release `published_at` for the date), `nix flake prefetch --json git+https://github.com/neovim/neovim?rev=<sha>` → SRI hash.
- Produces: `versions.json` = `{ "version": "nightly-YYYYMMDD-gSHORT7", "rev": "<full sha>", "hash": "sha256-..." }`.

- [ ] **Step 1: Write `pkgs/toyvo-neovim/update.ts`**

Shebang `#!/usr/bin/env bun`, usage header like the other updaters. Logic: fetch nightly tag ref (sha) + release `published_at`; load cached pin (read JSON directly, single object not a map); if sha matches cached rev, log and exit 0 without touching the file; else run `nix flake prefetch --json` for the hash, build the version label, `writeVersions`. Reuse `fetchJson`, `githubHeaders("nixcfg-toyvo-neovim-updater")`, `writeVersions` from `../../scripts/update-lib.ts`. Fail loudly (nonzero exit) on API/prefetch errors so CI goes red, never silently stale.

- [ ] **Step 2: Register the updater**

Add `"pkgs/toyvo-neovim/update.ts"` to `UPDATERS` in `scripts/update-all.ts` (keep list order: append at end).

- [ ] **Step 3: Generate the initial `versions.json`**

Run: `bun ./pkgs/toyvo-neovim/update.ts` (from repo root, inside `nix develop`)
Expected: `versions.json` created with a `nightly-YYYYMMDD-gXXXXXXX` version, full-sha rev, `sha256-…` hash.

- [ ] **Step 4: Prove the no-op path**

Run the updater again immediately.
Expected: exit 0, "unchanged"-style log, file mtime/content untouched.

### Task 2: Wire the pin into `pkgs/toyvo-neovim/default.nix`

**Files:**
- Modify: `pkgs/toyvo-neovim/default.nix`

**Interfaces:**
- Consumes: `./versions.json` pin from Task 1.
- Produces: nvf config built against nightly `neovim-unwrapped`; everything else unchanged.

- [ ] **Step 1: Read the pin and extend pkgs with the override**

At the top of `default.nix`, after the args: `nightly = builtins.fromJSON (builtins.readFile ./versions.json);` then `nightlyPkgs = pkgs.extend (final: prev: { neovim-unwrapped = prev.neovim-unwrapped.overrideAttrs { version = nightly.version; src = prev.fetchFromGitHub { owner = "neovim"; repo = "neovim"; rev = nightly.rev; hash = nightly.hash; }; }; });` and change `neovimConfiguration { inherit pkgs; … }` to `neovimConfiguration { pkgs = nightlyPkgs; … }`. Leave `vimPlugins`, `runtimeDeps`, `mkWrappedProgram pkgs` on host `pkgs`. Comment why: tracks nightly release; bumped by `update.ts`; drop the override to return to nixpkgs neovim.

- [ ] **Step 2: Build the package**

Run: `nix build .#packages.aarch64-darwin.toyvo-neovim --print-out-paths` (adjust attr/system to what `nix flake show` lists)
Expected: success. (First build compiles nightly neovim from source: slow, up to ~30+ min; subsequent builds are cached.)

- [ ] **Step 3: Prove nightly is really underneath**

Run: `./result/bin/nvim --version | head -3`
Expected: `NVIM v0.12.0-dev-…+g<sha>` (dev build, commit matches `versions.json` rev) instead of the nixpkgs `v0.12.6` release string.

### Task 3: Finish (fmt, todos, commit)

**Files:**
- Modify: `todos.md` (only if it has a neovim entry; otherwise skip)

**Interfaces:**
- Consumes: Tasks 1–2 done and green.
- Produces: formatted tree, isolated jj commit.

- [ ] **Step 1: Format and review the diff**

Run: `nix fmt`; `jj diff --stat`
Expected: only `pkgs/toyvo-neovim/versions.json`, `pkgs/toyvo-neovim/update.ts`, `pkgs/toyvo-neovim/default.nix`, `scripts/update-all.ts` (+ maybe `todos.md`) changed.

- [ ] **Step 2: Commit this feature only**

Run: `jj describe -m "toyvo-neovim: track nightly neovim with update script"` (commit exactly the Task 1–2 files; leave any unrelated working-copy changes alone, per repo norms)
Expected: clean, isolated commit. Push/deploy left to the owner.

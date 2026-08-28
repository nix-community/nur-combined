# AGENTS.md

Compact guidance for OpenCode sessions in this NixOS flake repo. Covers only the non-obvious facts an agent is likely to miss.

## Commands

- `just check` — fast, no-sudo validation: evaluates the `local` config and prints what would be built (`nix build .#nixosConfigurations.local.config.system.build.toplevel --dry-run`). **Use this to verify changes instead of `just`** — it needs no password and doesn't activate the system. Requires new/untracked files to be `git add`ed first (Nix can't see untracked paths; the dry-run names the offending path).
- `just build` — build the `local` system closure to `./result` without activating (no sudo).
- `just` — build & activate the `local` config (`sudo nixos-rebuild test --flake .#local`). Only needed when you actually want to apply the config; otherwise prefer `just check`.
- `just local switch` / `just local boot` / `just rollback` — activate / set next-boot / revert.
- `just iso` — build the installer ISO.
- `just update` — `nix flake update` + `nix-update --flake` for `CloudflareSpeedTest` and `pw-duck`. Do not hand-edit version/sha in `package.nix`; for new `fetchurl` hashes use `hash = lib.fakeHash` and let the build failure report the correct `sha256-...`.
- `just check-ascii` — verify no Chinese characters in `modules/`, `justfile`, etc. (code must be English only, no Chinese). This is run automatically by `just check`.
- `nix build .#<leaf-dir-name>` — build a single package. Package attrs are flattened to the parent directory name despite arbitrary nesting (e.g. `modules/pipewire/pw-duck/package.nix` → `nix build .#pw-duck`).
- `nix fmt` — formatter is `nixfmt-tree`. Run before committing or CI lint fails.
- Dev shell: `.envrc` via direnv or `nix develop` provides `just`, `nixos-rebuild`, `sops`, `nix-update`, `nodejs`.

## Module auto-discovery (highest-signal gotcha)

`lib/fromDirectoryRecursive` in `lib/default.nix` walks `modules/` **recursively** (arbitrary depth, not one level) and only picks up **exact filenames**: `default.nix` (NixOS module), `home.nix` (Home Manager), `package.nix`, `packages.nix`, `overlay.nix`.

- Any other filename is **silently ignored** — a module you add won't load unless the file is named exactly one of these.
- Directories prefixed with `_` (e.g. `_archive`) are skipped.
- A `package.nix` is auto-wrapped as an overlay under `pkgs.<parent-dir-name>` (guarded by `assert !(lib.hasAttr name prev)`). A module's NixOS/Home config can reuse it directly as `pkgs.<name>`; name collisions with existing `pkgs` attrs are forbidden. A directory can mix names (e.g. `modules/pipewire` has `default.nix` alongside `pw-duck/package.nix`).

## Secrets

- Encrypted with sops-nix. Add/replace via `sops secrets/secrets.yaml`; reference in config with `sops.secrets.<name>` (see `modules/sops/default.nix`).
- Decrypt to inspect: `sops --decrypt secrets/secrets.yaml`. Age key is in `.sops.yaml`.

## Structure

- `modules/` — program configs needing setup (each dir = one feature).
- `hosts/local/` — the live host (`hardware-configuration.nix` + simple `environment.systemPackages`; README: `modules/` is for programs needing config, `hosts/` for everything else). `hosts/installer/` — minimal ISO.
- `flake.nix` — entry; builds all outputs from `modules/` tree, wires flake inputs via `_module.args.inputs` (access as `inputs` in modules), defines two `nixosConfigurations` (`local`, `installer`) and `devShells.default`; `packages` are `flattenAttrset`ed so nesting doesn't affect attr name. `stateVersion = "26.05"`.
- `default.nix` — NUR-compatible non-flake entry (walks `package.nix`/`packages.nix`).
- `ci.nix` — filters packages for CI (excludes `meta.broken`, unfree, `preferLocalBuild`).

## CI

- `.github/workflows/test.yml` triggers on push to `develop` and PRs. Builds the full NixOS system and evaluates packages via composite actions `check_system` / `check_packages`; the system derivation hash is cached so both checks are skipped on cache hit. Nix + Cachix (`slaier` + `nix-community`) + ccache are set up by `setup_nix`.
- `update_inputs.yml` runs weekly Thu 04:05 UTC, executes `just update` inside `nix develop`, and force-pushes to `wip-update-inputs`.
- Default branch is `develop` (not `main`).

## Environment quirks

- Nix `experimental-features` is `"cgroups nix-command flakes"` (note `cgroups`, not just `nix-command flakes`); `use-cgroups = true`. Keep this if running nix manually.
- Substituters: `https://mirrors.ustc.edu.cn/nix-channels/store`, `https://slaier.cachix.org`, `https://nix-community.cachix.org` (in `modules/nix/default.nix`); proxy at `http://local.lan:7890` (in `hosts/local/default.nix`).
- `programs.ccache.cacheDir = /nix/var/cache/ccache` in `extra-sandbox-paths`; CI configures the same path. `system.stateVersion = "26.05"`.

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

- `just` — test config (`sudo nixos-rebuild test --flake .#local`)
- `just local switch` — build and activate
- `just local boot` — set as next-boot default
- `just rollback` — revert to the previous generation (`--rollback`)
- `just iso` — build the installer ISO (`nixosConfigurations.installer`)
- `just update` — `nix flake update` + `nix-update` for `CloudflareSpeedTest`, `mattpocock-skills`, `pw-duck`, and `free-claude-code` (the last uses its custom `passthru.updateScript`, invoked via `-u`)
- `nix fmt` — format all Nix files (nixfmt-tree). Run before committing to avoid CI lint failures.
- `nix build .#<attr>` — build a package; attrs are flattened leaf dir names, e.g. `nix build .#free-claude-code`
- `sops --decrypt secrets/secrets.yaml` — decrypt secrets (age key in `.sops.yaml`)

The dev shell (`.envrc` via direnv, or `nix develop`) provides `just`, `nixos-rebuild`, `sops`, `nix-update`, `nodejs`.

## Module auto-discovery

`lib.fromDirectoryRecursive` in `lib/default.nix` walks `modules/` **recursively** — nesting is arbitrary, not limited to one level (e.g. `modules/ai/claude-code/free-claude-code/package.nix`) — and collects files by exact name:

| Filename       | Role                                    | Wired into                       |
| -------------- | --------------------------------------- | -------------------------------- |
| `default.nix`  | NixOS module                            | `nixosModules`                   |
| `home.nix`     | Home Manager module                     | `home-manager.users.nixos.imports` |
| `package.nix`  | Package definition                      | `packages` output + auto-overlay |
| `packages.nix` | Package set (via `makePackageSet`)      | NUR-style `default.nix`          |
| `overlay.nix`  | NixOS overlay                           | `overlays` output                |

**Critical**:
- Directories prefixed with `_` (e.g. `_archive`, `_experimental`) are skipped. Only the filenames above are recognized — any other filename is silently ignored.
- A directory can mix file names (e.g. `modules/pipewire/` has `default.nix` alongside `pw-duck/package.nix`).
- To add a new module, create a directory under `modules/` with the correct file name.

### Packages: naming and auto-overlay

- Each `package.nix` gets a top-level attribute named after its **parent directory** (`baseNameOf (dirOf pkg)` in `flake.nix`) — `modules/ai/claude-code/free-claude-code/package.nix` → `free-claude-code`.
- `packages.${system}` is `flattenAttrset`ed to a single level, so `nix build .#free-claude-code` works despite the nesting.
- Every `package.nix` is additionally auto-wrapped as an **overlay** under `pkgs.<dirname>`, guarded by `assert !(lib.hasAttr name prev)` (the flake asserts no collision with an existing `pkgs` attr). This means a module's NixOS/home config can reuse its own or another module's package directly as `pkgs.<name>`.

## Modifying Modules: Best Practices

1. **Verify Discovery**: Ensure your file matches the exact names above. If you rename a file to `other.nix`, it will be silently ignored.
2. **Testing**: Always run `just` (nixos-rebuild test) before committing. If you modified packages, verify the build with `nix build .#<leaf-dir-name>`.
3. **Secrets**: If adding a secret, encrypt it into `secrets/secrets.yaml` via `sops` and reference it with `sops.secrets.<name>` (see `modules/sops/default.nix`).
4. **Formatting**: Always run `nix fmt` before committing to avoid CI linting failures.

## Architecture

- `flake.nix` — entry point. Builds all outputs from the `modules/` tree; defines two `nixosConfigurations` (`local`, `installer`) and a `devShells.default`. Modules receive the flake inputs via `_module.args.inputs` — e.g. `modules/nix/default.nix` pins the nixpkgs registry and flake from `inputs`.
- `default.nix` — NUR-compatible non-flake entry point (walks `modules/` for `package.nix`/`packages.nix`).
- `ci.nix` — filters packages for CI (excludes broken, unfree, `preferLocalBuild`).
- `hosts/local/` — the host: `hardware-configuration.nix` + simple system packages in `environment.systemPackages` (README: `modules/` is for programs needing configuration; `hosts/` for everything else). Hardware is AMD + btrfs, proxy at `http://local.lan:7890`.
- `hosts/installer/` — minimal ISO definition (built via `just iso`).
- `secrets/` — sops-nix encrypted files (age key in `.sops.yaml`; `secrets.yaml` is the default file referenced by `modules/sops/default.nix`).

## CI

GitHub Actions (`.github/workflows/test.yml`): triggers on push to `develop` and PRs. Builds the full NixOS system and evaluates packages via two composite actions (`.github/actions/check_system`, `check_packages`); the config derivation is cached by hash so both checks are skipped on a cache hit. Nix + Cachix (`slaier` + `nix-community`) + ccache are set up by the `.github/actions/setup_nix` composite action. The default branch is `develop`.

An automated `.github/workflows/update_inputs.yml` runs weekly (Thursdays), performs `just update`, and pushes the result to the `wip-update-inputs` branch.

## Environment gotchas

- Nix is configured with upstream inputs: `mirrors.ustc.edu.cn/nix-channels/store`, `slaier.cachix.org`, and `nix-community.cachix.org` substituters (in `modules/nix/default.nix`).
- ccache is enabled (`programs.ccache.cacheDir = /nix/var/cache/ccache`) and included in `extra-sandbox-paths`; CI configures `/nix/var/cache/ccache` the same way.
- `nix.settings.experimental-features` is `"cgroups nix-command flakes"` (note `cgroups`, not just `nix-command flakes`), with `use-cgroups = true`.
- `system.stateVersion` is `"26.05"`.
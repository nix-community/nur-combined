# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

- `just` — test config (`sudo nixos-rebuild test --flake .#local`)
- `just local switch` — build and activate config
- `just local boot` — set as next boot default
- `just rollback` — roll back to previous generation
- `just iso` — build installer ISO
- `just update` — update flake inputs + `nix-update` for several packages
- `nix fmt` — format all Nix files (nixfmt-tree). Run before committing.
- `nix build .#modules/<name>.package` — build a specific package
- `sops --decrypt secrets/<file>` — decrypt a secret

The dev shell (`.envrc` via direnv) provides `just`, `nixos-rebuild`, `sops`, `nix-update`.

## Module auto-discovery

`lib.fromDirectoryRecursive` in `lib/default.nix` walks `modules/` and collects files by exact name:

| Filename       | Role                                    | Wired into                       |
| -------------- | --------------------------------------- | -------------------------------- |
| `default.nix`  | NixOS module                            | `nixosModules`                   |
| `home.nix`     | Home Manager module                     | `home-manager.users.nixos.imports` |
| `package.nix`  | Package definition                      | `packages` output + auto-overlay |
| `packages.nix` | Package set (via `makePackageSet`)      | NUR-style `default.nix`          |
| `overlay.nix`  | NixOS overlay                           | `overlays` output                |

**Critical**: directories prefixed with `_` (e.g. `_archive`, `_experimental`) are skipped. Only the filenames above are recognized — any other filename is ignored. To add a new module, create a directory under `modules/` with the correct file name.

## Modifying Modules: Best Practices

1. **Verify Discovery**: Ensure your file matches the exact names above. If you rename a file to `other.nix`, it will be silently ignored.
2. **Testing**: Always run `just` (nixos-rebuild test) before committing. If you are modifying packages, use `nix build .#packages.x86_64-linux.<name>` to verify the build.
3. **Secrets**: If adding new secrets, ensure they are encrypted via `sops` and referenceable by the module.
4. **Formatting**: Always run `nix fmt` before committing to avoid CI linting failures.

## Architecture

- `flake.nix` — entry point; builds all outputs from the `modules/` tree. Defines two `nixosConfigurations`: `local` (the host) and `installer`.
- `default.nix` — NUR-compatible non-flake entry point (walks `modules/` for `package.nix`/`packages.nix`)
- `ci.nix` — filters packages for CI (excludes broken, unfree, `preferLocalBuild`)
- `hosts/local/` — hardware config (AMD, btrfs, proxy at `http://local.lan:7890`)
- `hosts/installer/` — minimal ISO definition
- `secrets/` — sops-nix encrypted files (age key in `.sops.yaml`)

Package `package.nix` files are auto-wrapped as overlays using the parent directory name as the attribute name (the flake asserts no collisions with existing `pkgs` attrs when generating these).

## CI

GitHub Actions (`.github/workflows/test.yml`): triggers on push to `develop` and PRs. Builds the full NixOS system and evaluates packages. Uses Cachix (`slaier` + `nix-community`). The default branch is `develop`.

An automated workflow (`.github/workflows/update_inputs.yml`) runs weekly to update flake inputs and push to `wip-update-inputs`.

## Environment gotchas

- npm registry is overridden to Tencent mirror in both `flake.nix` and `modules/nix/default.nix`
- ccache is enabled (`/nix/var/cache/ccache`) — CI setup also configures this
- `nix.settings.experimental-features` includes `cgroups` (not just `nix-command flakes`)
- `system.stateVersion` is `"26.05"`

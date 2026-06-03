# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Build and development
- `just` - Test current NixOS configuration (`sudo nixos-rebuild test`)
- `just local switch` - Build and switch to current NixOS configuration
- `just local <goal>` - Run any nixos-rebuild goal (e.g., `just local boot`, `just local test`)
- `just rollback` - Test rollback to previous generation
- `just iso` - Build installer ISO image
- `just update` - Update all flake inputs and specific packages via `nix-update`
- `nix build .#nixosConfigurations.local.config.system.build.toplevel` - Build the full system
- `nix fmt` - Format all Nix files (uses `nixfmt-tree`)

### Package management
- `nix-env -f . -qa` - List all buildable packages
- `nix build .#modules/<package-name>.package` - Build a specific package from modules

### Secrets
- `sops --decrypt secrets/<filename>` - Decrypt a secret file

### Dev shell
- `.envrc` is configured for direnv — entering the repo auto-loads the dev shell with `just`, `nixos-rebuild`, `sops`, and `nix-update`.

## Architecture

NixOS dotfiles/configuration repository using Nix flakes. Single host (`local`) targeting `x86_64-linux`.

### Module auto-discovery

The core mechanism is `lib.fromDirectoryRecursive` (`lib/default.nix`), which recursively walks `modules/` and collects files by name:

- `default.nix` → NixOS system modules
- `home.nix` → Home Manager modules (imported into `users.nixos`)
- `package.nix` → Buildable packages (also auto-converted to overlays)
- `overlay.nix` → Additional NixOS overlays

Directories prefixed with `_` are skipped during traversal.

`packages.nix` (distinct from `package.nix`) defines a package set via `lib.makePackageSet`, used by the root `default.nix` for NUR-style package collection.

### Key patterns

- **flake.nix** is the entry point: it builds `nixosModules`, `homeModules`, `packages`, and `overlays` from the same `modules/` tree using `fromDirectoryRecursive` with different filenames.
- **Home-manager** is integrated as a NixOS module; all `home.nix` files are collected and passed via `users.nixos.imports`.
- **Overlays**: `package.nix` files are automatically wrapped as overlays (asserting no name collisions). `overlay.nix` files provide custom overlays.
- **ci.nix**: Filters packages for CI — excludes broken, unfree, and `preferLocalBuild` packages.
- **Secrets**: sops-nix with age key defined in `.sops.yaml`. Secret files live in `secrets/` and are decrypted at build time.

### Hosts

`hosts/local/` contains hardware-specific configuration (AMD CPU/GPU, btrfs with subvolumes, Logitech peripherals, networking with proxy). `hosts/installer/` defines a minimal ISO image.

### CI

GitHub Actions (`.github/workflows/test.yml`) builds the full NixOS system module and checks packages. Uses Cachix for binary caching. Triggers on push to `develop` and pull requests.

### Non-flake entry point

`default.nix` provides NUR compatibility by walking `modules/` for `package.nix`/`packages.nix` files. `ci.nix` filters these into `buildPkgs` and `cachePkgs` (excluding broken, unfree, and `preferLocalBuild` packages).

### Inputs
- `nixpkgs/nixos-unstable`, `home-manager/master`, `NUR`, `sops-nix`
- `niri` (tiling Wayland compositor), `bluetooth-player`
- `darkmatter-grub-theme`, `nix-index-database`

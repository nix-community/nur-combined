# AGENTS.md

Guidance for AI coding agents working in this Nix/NixOS configuration repository.

## Repository Overview

Dual-purpose Nix flake: a **NUR (Nix User Repository)** publishing custom packages, and a **shared system configuration** for 16+ machines across NixOS, nix-darwin, and Home Manager.

- GitHub: `ToyVo/nixcfg`
- Primary branch: `main`
- Uses `nixos-unstable` as base nixpkgs

## Build, Lint, and Test Commands

### Formatting (Required Before Commit)

```bash
nix fmt                          # Format all files (nixfmt, prettier, yamlfmt, mdformat)
```

### Evaluation and Building

```bash
nix flake show                   # Show all flake outputs (evaluation check)
nix flake check                  # Run all flake checks

# Build specific system configurations
nix build .#darwinConfigurations.MacBook-Pro.config.system.build.toplevel
nix build .#nixosConfigurations.nas.config.system.build.toplevel

# Build specific packages
nix build .#setup-sops
nix build .#packages.x86_64-linux.fabricServers.fabric-1-21-4

# Build and run
nix run .#setup-sops
```

### Development Environment

```bash
nix develop                      # Enter dev shell with tools and git hooks
```

### Deployment (System Updates)

```bash
# NixOS
nixos-rebuild switch --flake .#<hostname>
nh os switch ~/nixcfg

# nix-darwin (macOS)
darwin-rebuild switch --flake .#<hostname>
nh darwin switch ~/nixcfg

# Home Manager
home-manager switch --flake .#<hostname>
```

**No Traditional Tests**: This repo has no unit tests. Validation is via `nix flake show` (evaluation check) and building outputs. CI uses `nix-fast-build` for all checks.

## Code Style Guidelines

### Nix Language Style

- Use `nixfmt` for formatting (enforced by `nix fmt`)
- Prefer `lib.mkEnableOption` and `lib.mkOption` for module options
- Use `lib.mkIf` for conditional config, `lib.mkDefault` for defaults
- Functions: `camelCase` for parameters, lowercase for local vars
- Modules: `cfg = config.path.to.option` pattern for accessing config
- Use `with lib;` sparingly; prefer explicit `lib.` prefix for clarity

### Module Structure

```nix
{ config, lib, pkgs, ... }:
let
  cfg = config.myModule.option;
in
{
  options.myModule.option = {
    enable = lib.mkEnableOption "description";
    setting = lib.mkOption {
      type = lib.types.str;
      default = "value";
      description = "Description here";
    };
  };

  config = lib.mkIf cfg.enable {
    # Configuration here
  };
}
```

### Package Structure

Each package directory has a `package.nix` entry point:

```nix
{ lib
, stdenv
, fetchurl
, # ... other deps
}:

stdenv.mkDerivation rec {
  pname = "package-name";
  version = "1.0.0";

  src = fetchurl {
    url = "...";
    hash = lib.fakeHash; # Replace after first build attempt
  };

  meta = {
    description = "Brief description";
    homepage = "https://example.com";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.toyvo ];
    mainProgram = "program-name";
  };
}
```

### Imports and Dependencies

- Use `callPackage` pattern for package dependencies
- Prefer `pkgs.callPackage` over direct imports
- For flakes: explicit inputs in `flake.nix`, use `inputs.nixpkgs.follows` to reduce duplication
- Access custom lib functions via `self.lib`

### Naming Conventions

- **Files/Directories**: `kebab-case` (e.g., `fabric-servers`, `setup-sops`)
- **Nix Attributes**: `camelCase` (e.g., `nixosConfigurations`, `darwinConfigurations`)
- **Module Options**: `camelCase` (e.g., `containerPresets`, `programs.bat`)
- **Packages**: match upstream naming where possible

### Error Handling

- Use `lib.mkOption` with appropriate `type` for validation
- Fail fast with `throw` or `assert` for impossible states
- Use `lib.optional` and `lib.optionals` for conditional lists
- For package hashes: start with `lib.fakeHash`, run build, copy actual hash

### Secrets Management

- Uses `sops-nix` with age encryption
- `.sops.yaml` defines per-machine age keys
- `secrets.yaml` contains encrypted secrets
- **Never commit unencrypted secrets**
- Use `setup-sops` command to generate age keys

## Architecture

### Module Tree (`modules/`)

Auto-discovered via `lib.importDirRecursive`:

| Directory         | Scope        | Description                                       |
| ----------------- | ------------ | ------------------------------------------------- |
| `modules/os/`     | Shared       | OS-agnostic config for NixOS and Darwin           |
| `modules/nixos/`  | NixOS        | Linux-specific: services, containers, filesystems |
| `modules/darwin/` | Darwin       | macOS-specific: ollama, podman                    |
| `modules/home/`   | Home Manager | User-level programs, user profiles                |

Reference modules via `self.modules.<tree>.<path>` (e.g., `self.modules.nixos.systems`).

### System Configurations (`systems/`)

Factory functions in `systems/default.nix`:

- `nixosSystem { system, nixosModules, homeModules }` — NixOS config
- `darwinSystem { system, darwinModules, homeModules }` — nix-darwin config
- `homeConfiguration { system, homeModules }` — Standalone Home Manager

Each machine has a directory in `systems/<hostname>/` with:

- `default.nix`: Metadata `{ type = "nixos"; system = "x86_64-linux"; }`
- `configuration.nix` or `home.nix`: Actual configuration

### Packages (`pkgs/`)

Auto-discovered via `lib.callDirPackageWithRecursive`. Each package:

- Lives in `pkgs/<name>/`
- Entry point is `package.nix`
- Common pattern: `package.nix` calls `derivation.nix` with versions from `versions.json`

### Custom Library (`lib/`)

Key utilities:

- `importDirRecursive` — Recursive `.nix` file importer
- `callDirPackageWithRecursive` — Auto-discovers packages
- `flakePackages` / `flakeChecks` — Filters for flake outputs

## Common Patterns

### Adding a New System

1. Create `systems/<hostname>/`
1. Add `default.nix` with `{ type = "nixos"; system = "x86_64-linux"; }`
1. Add `configuration.nix` (NixOS/Darwin) or `home.nix` (Home Manager)
1. Auto-discovered; no registration needed

### Adding a New Package

1. Create `pkgs/<name>/`
1. Add `package.nix` (function accepting deps)
1. Auto-discovered; no registration needed

### Adding a New Module

1. Place `.nix` file under appropriate `modules/<tree>/`
1. Auto-discovered via `importDirRecursive`
1. Reference via `self.modules.<tree>.<path>`

## Binary Caches

Configured substituters:

- `https://cache.nixos.org`
- `https://nix-community.cachix.org`
- `https://toyvo.cachix.org`
- `https://zed.cachix.org`
- `https://cache.garnix.io`
- `https://cache.toyvo.dev`

## Git Hooks

Dev shell includes pre-commit and pre-push hooks (auto-enabled):

- Pre-commit: formatting checks
- Pre-push: validation checks

Hooks configured in `flake.nix` via `devshell` module.

## Downstream Usage

Work machine config imports this flake and uses `nixcfg.lib.darwinSystem` to inherit shared modules/overlays.

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

Dual-purpose Nix flake: a **NUR (Nix User Repository)** publishing custom packages, and a **shared system configuration** for 16+ machines across NixOS, nix-darwin, and Home Manager.

GitHub: `ToyVo/nixcfg`. Primary branch: `main`. Uses `nixpkgs-unstable` as the base nixpkgs.

## Common Commands

```bash
# Format all files (nixfmt, prettier, yamlfmt, mdformat)
nix fmt

# Show all flake outputs (evaluation check)
nix flake show

# Build a specific system configuration
nix build .#darwinConfigurations.MacBook-Pro.config.system.build.toplevel
nix build .#nixosConfigurations.nas.config.system.build.toplevel

# Build a specific package
nix build .#setup-sops

# Enter the dev shell (provides setup-sops, setup-git-sops, git hooks)
nix develop

# Update flake inputs
nix flake update

# Deploy with nh (system rebuild tool)
nh os switch ~/nixcfg          # NixOS
nh darwin switch ~/nixcfg      # nix-darwin
```

There are no test commands beyond `nix flake show` (evaluation check) and building specific outputs. CI builds all checks via `nix-fast-build`.

## Architecture

### Flake Structure (flake-parts)

The flake uses `flake-parts` to split per-system outputs from system-independent outputs:

- **`flake.*`** — System-independent: `lib`, `modules`, `nixosConfigurations`, `darwinConfigurations`, `homeConfigurations`
- **`perSystem`** — Per-system: `packages`, `checks`, `devshells`, `treefmt`, `overlayAttrs`

### Module Tree (`modules/`)

Four module directories, auto-discovered via `lib.importDirRecursive`:

| Directory         | Scope        | Description                                                     |
| ----------------- | ------------ | --------------------------------------------------------------- |
| `modules/os/`     | Shared       | OS-agnostic config imported by both NixOS and Darwin            |
| `modules/nixos/`  | NixOS        | Linux-specific: services, containers, filesystems, gaming       |
| `modules/darwin/` | Darwin       | macOS-specific: ollama, podman                                  |
| `modules/home/`   | Home Manager | User-level programs (editors, shells, terminals), user profiles |

Modules are referenced via `self.modules.<tree>.<path>` (e.g., `self.modules.nixos.systems`, `self.modules.home.systems`).

### System Configurations (`systems/`)

`systems/default.nix` defines three factory functions that wire all flake inputs and shared modules:

- **`nixosSystem { system, nixosModules, homeModules }`** — Creates a NixOS config with arion, disko, sops-nix, home-manager, catppuccin, etc.
- **`darwinSystem { system, darwinModules, homeModules }`** — Creates a nix-darwin config with mac-app-util, sops-nix, home-manager, etc.
- **`homeConfiguration { system, homeModules }`** — Standalone Home Manager config (used for steamdeck).

Each machine has a file (or directory) in `systems/` that passes its system architecture and machine-specific modules to the appropriate factory function. All flake inputs are passed as `specialArgs`.

### Custom Library (`lib/default.nix`)

Key functions used throughout:

- **`importDirRecursive`** — Recursively imports all `.nix` files in a directory tree, building a nested attrset (powers module auto-discovery)
- **`callDirPackageWithRecursive`** — Auto-discovers packages by finding `package.nix` files recursively (powers NUR package discovery)
- **`flakePackages`** / **`flakeChecks`** — Filters packages by platform and buildability for flake outputs

These factory functions are also exported as `self.lib` so downstream flakes (e.g., work machine config) can use `nixcfg.lib.darwinSystem`.

### Packages (`pkgs/`)

Each package gets a directory with a `package.nix` entry point, auto-discovered by `callDirPackageWithRecursive`. Categories: Minecraft servers (fabricServers, neoforgeServers, papermcServers, purpurServers), SOPS utilities (setup-sops, setup-git-sops, git-sops), git hooks (pre-commit, pre-push), themes (catppuccin KDE/Papirus).

### Secrets

sops-nix with age encryption. `.sops.yaml` defines per-machine age keys. `secrets.yaml` contains all encrypted secrets. Never commit unencrypted secrets.

### Overlays

Global overlays applied: `nixpkgs-esp-dev`, `nur`, `rust-overlay`. Custom packages are exposed via `overlayAttrs.toyvo` through flake-parts' easyOverlay.

## Conventions

- **Formatter:** Always run `nix fmt` on changed files. Configured formatters: nixfmt (Nix), prettier (JS/YAML/MD), yamlfmt (YAML), mdformat (Markdown).
- **New packages:** Create `pkgs/<name>/package.nix` — auto-discovered, no manual registration needed.
- **New modules:** Place `.nix` files under the appropriate `modules/` subtree — auto-discovered via `importDirRecursive`.
- **New machines:** Add a `.nix` file (or directory with `default.nix`) in `systems/`, then register it in `systems/default.nix` using the appropriate factory function.
- **Binary caches:** `toyvo.cachix.org`, `cache.toyvo.dev`, nix-community cachix, garnix, zed cachix.
- **Git hooks:** Dev shell includes pre-commit and pre-push hooks (auto-enabled via devshell).
- **Downstream usage:** Work machine config imports this flake and uses `nixcfg.lib.darwinSystem` to inherit all shared modules/overlays.

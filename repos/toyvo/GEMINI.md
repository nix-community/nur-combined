# Gemini Context: nixcfg

Personal Nix flake-based configuration repository by Collin Diekvoss (`toyvo`). This project manages configurations for multiple operating systems (NixOS, macOS via nix-darwin, and Home Manager) and exports custom packages and modules, some of which are available via the Nix User Repository (NUR).

## Project Overview

- **Architecture:** Modular Nix flake using `flake-parts`.
- **System Management:** Supports NixOS, nix-darwin (macOS), and standalone Home Manager.
- **Custom Content:** Includes local packages (`pkgs/`), reusable modules (`modules/`), and a custom library (`lib/`).
- **Secret Management:** Uses `sops-nix` for managing encrypted secrets.
- **Formatting:** Standardized via `treefmt-nix` (nixfmt, prettier, yamlfmt, mdformat).

## Building and Running

### System Updates

Update your system by targeting the appropriate host configuration defined in `systems/`:

- **NixOS:** `nixos-rebuild switch --flake .#<host>`
- **macOS (nix-darwin):** `darwin-rebuild switch --flake .#<host>`
- **Home Manager:** `home-manager switch --flake .#<host>`

### Package Operations

Custom packages are auto-discovered from `pkgs/`:

- **Build:** `nix build .#packages.<system>.<package-name>`
- **Run:** `nix run .#<package-name>`

### Development Environment

A `devshell` is provided with essential tools:

- Enter via: `nix develop`
- Includes `setup-sops` for secret management.
- Pre-commit and pre-push hooks are configured for linting and formatting.

## Development Conventions

### 1. Adding a New System

- Create a directory in `systems/<host-name>/`.
- Add a `default.nix` with metadata:
  ```nix
  { type = "nixos"; system = "x86_64-linux"; } # or type = "darwin"/"home"
  ```
- Add a `configuration.nix` (for NixOS/Darwin) or `home.nix` (for Home Manager).

### 2. Adding a New Package

- Create a directory in `pkgs/<package-name>/`.
- Add a `package.nix` which should be a function accepting `callPackage`, `lib`, etc.
- The `lib.callDirPackageWithRecursive` function will automatically find and export it if it contains a `package.nix`.
- Common pattern: `package.nix` calls `derivation.nix` with version data from `versions.json`.

### 3. Adding a New Module

- Place Nix files in `modules/<platform>/`.
- Modules are automatically discovered and exported via `self.modules` in the flake.
- Internal configurations typically import modules via relative paths from `systems/`.

### 4. Code Style & Formatting

- Run `nix fmt` to format the entire repository using `treefmt`.
- Follow existing modular patterns: separate OS-level defaults from user-specific configurations.

### 5. Library Functions

- Custom helpers are in `lib/default.nix`.
- Includes powerful utilities like `importDirRecursive` and `callDirPackageWithRecursive` for auto-discovery.

## Key Files

- `flake.nix`: Main flake entry point and input management.
- `systems/default.nix`: Logic for auto-discovering and building system configurations.
- `homelab.nix`: Shared metadata/settings for the homelab environment.
- `secrets.yaml`: SOPS-encrypted secrets.

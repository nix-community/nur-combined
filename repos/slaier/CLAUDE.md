# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Build and development
- `just test` - Build and test packages in the modules
- `just switch` - Build and switch to current NixOS configuration (`./hosts/local/default.nix`)
- `just rollback` - Test rollback to previous generation
- `nix flake update` - Update all flake inputs
- `nix build .#nixosConfigurations.local.config.system.build.toplevel` - Build the local NixOS system
- `nix run .#devShells.default` - Start the development shell with just, nixos-rebuild, and sops

### Package management
- `nix-env -f . -qa` - List all buildable packages
- `nix-env -f . -qa --meta` - List packages with meta information
- `nix build .#modules/<package-name>.package` - Build a specific package from modules

### Secrets
- `sops --decrypt secrets/<filename>` - Decrypt secret files in `secrets/` directory
- `watch_file outputs/devShells.nix` - Watch dev shell output (from .envrc)

## Architecture

This is a NixOS dotfiles/configuration repository using Nix flakes. The structure is:

```
nixos-config/
├── flake.nix           # Main flake definition with inputs and outputs
├── default.nix         # Collects all package.nix files from modules/
├── hosts/              # NixOS system configurations
│   └── local/         # Primary configuration (develop environment)
│       └── default.nix # System modules + home-manager users.nixos
├── modules/            # Organized configuration modules
│   ├── common/        # Base system settings
│   ├── <program>/     # Individual program configurations
│   │   ├── default.nix   # NixOS module
│   │   ├── home.nix      # Home manager module
│   │   └── package.nix   # Buildable package (optional)
│   └── installer/     # Installation scripts (nixos-fs-init, nixos-fs-mount)
├── lib/               # Reusable Nix functions (in lib/default.nix)
├── secrets/           # Encrypted secrets (sops managed)
├── ci.nix             # CI package set definition
└── justfile           # Task runner (just, justfile)
```

### Module structure
Each program module typically has:
- `default.nix` - NixOS system module with `config.xxx = { ... }`
- `home.nix` - Home manager module with `home.configHome.xxx = { ... }`
- `package.nix` - Optional buildable package using `pkgs.callPackage`

### Key patterns
- **Recursive imports**: `modules/` directory is processed via `lib.fromDirectoryRecursive` in `flake.nix`
- **Home-manager**: Uses `users.nixos.imports` to import all `home.nix` files
- **Packages**: Collected via `default.nix` which traverses `modules/` for `package.nix` files
- **CI**: `ci.nix` defines buildable/cacheable packages for GitHub Actions
- **Secrets**: Encrypted with sops using age keys stored in `secrets/secrets.yaml`

### Inputs
- `nixpkgs/nixos-25.11` (stable), `nixpkgs/nixos-unstable` (unstable)
- `home-manager/release-25.11`
- `NUR` (Nix Unstable Repository)
- `sops-nix` (encrypted secrets)
- Custom inputs like niri, bluetooth-player, etc.

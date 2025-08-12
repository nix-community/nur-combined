# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is **serpent213's personal NUR (Nix User Repository)** - a collection of custom Nix packages, NixOS modules, and overlays that follows NUR conventions for community distribution. The repository uses a hybrid approach supporting both modern Nix flakes and traditional Nix tooling.

## Common Development Commands

### Package Management and Evaluation
- `just help` - Show available commands
- `just eval-pkgs` - Evaluate all packages with restricted mode and metadata checking
- `just trigger-update` - Trigger NUR repository update via webhook

### Package Testing and Building
- `nix-build -A <package-name>` - Build a specific package (e.g., `nix-build -A pushlog`)
- `nix-build ci.nix -A buildOutputs` - Build all buildable packages
- `nix-build ci.nix -A cacheOutputs` - Build all cacheable packages
- `nix flake check` - Check flake validity
- `nix develop` - Enter development shell (if available)

### Flake Commands
- `nix build .#<package-name>` - Build package via flake (e.g., `nix build .#pushlog`)
- `nix run .#<package-name>` - Run package via flake

## Architecture Overview

### Core Structure
- **`default.nix`**: Main entry point exposing `lib`, `modules`, `overlays`, and packages
- **`flake.nix`**: Modern flake interface with `legacyPackages` and `packages` outputs
- **`ci.nix`**: CI configuration that filters packages based on buildability, licensing, and caching preferences
- **`overlay.nix`**: Standard overlay export

### Package Organization
- **`pkgs/`**: Custom package definitions, each in its own directory with `default.nix`
- **`modules/`**: NixOS modules for system configuration
- **`overlays/`**: Nixpkgs overlays (currently empty)
- **`lib/`**: Custom library functions (currently empty)

### CI/CD Integration
- GitHub Actions builds packages on push, PR, and daily schedule
- Uses `ci.nix` to intelligently filter packages based on:
  - Build status (excludes broken packages)
  - License compatibility (only free licenses)
  - Build preferences (local vs cacheable)
- Supports multiple nixpkgs channels (unstable, nixos-unstable, nixos-24.11)

## Package Development Patterns

### Package Structure
Each package follows standard Nix derivation patterns:
- Located in `pkgs/<package-name>/default.nix`
- Uses `pkgs.callPackage` for dependency injection
- Includes comprehensive metadata (description, homepage, license, maintainers)
- Properly handles dependencies via `nativeBuildInputs`, `buildInputs`, or `dependencies`

### Module Development
NixOS modules in `modules/` provide:
- Structured options with types and validation
- Comprehensive service configuration
- Systemd service hardening
- Environment file support for secrets

### Quality Standards
- All packages must include proper metadata
- License information is required and checked by CI
- Security hardening is applied to systemd services
- Version pinning with checksum verification

## Development Workflow

1. **Adding New Packages**: Create directory in `pkgs/`, add `default.nix`, then expose in root `default.nix`
2. **Testing**: Use `just eval-pkgs` to verify evaluation, then `nix-build -A <package>` to build
3. **CI Integration**: Package automatically included in CI if properly licensed and not marked broken
4. **NUR Updates**: Successful builds trigger automatic NUR repository updates

## Important Files
- `justfile` - Task definitions for common operations
- `ci.nix` - CI filtering logic and package selection
- `default.nix` - Main package set definition
- `flake.nix` - Modern flake interface
- `.github/workflows/build.yml` - GitHub Actions CI configuration
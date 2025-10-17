# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a NUR (Nix User Repository) containing custom Nix packages and NixOS modules. The repository is designed to work with the [Nix Community NUR](https://github.com/nix-community/NUR) infrastructure and provides various packages across multiple Python versions.

## Core Architecture

### Package Management System

The repository uses a template-based system to automatically generate `default.nix`:
- **Template**: `.default_template.nix` defines the structure
- **Generator**: `update-pkgs.py` scans `pkgs/` and regenerates `default.nix`
- **Python Versioning**: Automatically creates versioned packages (e.g., `python-jwt_311`, `python-jwt_312`, `python-jwt_313`)

**Important**: After adding or modifying packages, run `./update-pkgs.py` to regenerate `default.nix`. Do NOT manually edit the package list in `default.nix` as it will be overwritten.

### Directory Structure

- `pkgs/`: Individual package definitions (each in their own subdirectory with `default.nix`)
- `modules/`: NixOS modules (service definitions, system configurations)
- `overlays/`: Nixpkgs overlays
- `lib/`: Custom Nix functions and utilities
- `ci.nix`: CI-specific package filtering for cacheable builds

### Package Types

1. **Regular packages**: Standard Nix packages (e.g., `alvr`, `opencode-sst`)
2. **Python packages**: Use `buildPythonPackage`, automatically versioned across Python 311, 312, 313
3. **Python applications**: Use `buildPythonApplication`, built only for Python 312 (configurable via `python_app_version`)

## Common Commands

### Building Packages

```bash
# Build a specific package
nix-build -A <package-name>

# Build with flakes
nix build .#<package-name>

# Build all packages (via CI configuration)
nix-build ci.nix -A cacheOutputs

# Check evaluation of all packages
nix-env -f . -qa \* --meta
```

### Testing

```bash
# Evaluate all packages (checks for syntax/evaluation errors)
nix-env -f . -qa \* --meta --xml \
  --allowed-uris https://static.rust-lang.org \
  --option restrict-eval true \
  --option allow-import-from-derivation true \
  --drv-path --show-trace \
  -I nixpkgs=$(nix-instantiate --find-file nixpkgs) \
  -I $PWD
```

### Package Management

```bash
# Regenerate default.nix after adding/removing packages
./update-pkgs.py

# Add a new package:
# 1. Create pkgs/<package-name>/default.nix
# 2. Run ./update-pkgs.py
# 3. Build and test: nix-build -A <package-name>
```

## Adding New Packages

1. Create a new directory in `pkgs/<package-name>/`
2. Add `default.nix` with package definition
3. For Python packages:
   - Use `buildPythonPackage` in function arguments for libraries
   - Use `buildPythonApplication` for applications
   - Accept `python-ver` parameter if needed: `{ buildPythonPackage, python-ver ? 312, ... }`
4. Run `./update-pkgs.py` to update `default.nix`
5. Test build: `nix-build -A <package-name>` (or versioned variant for Python packages)

To ignore a package from auto-generation, add it to the `ignore_list` in `update-pkgs.py`.

## NixOS Modules

Modules are defined in `modules/` and exposed via `modules/default.nix`. Current modules:
- `timew-sync-server`: Timewarrior sync server service
- `g13d`: G13 device daemon service
- `taskchampion-sync-server`: TaskChampion sync server service

Modules are used as: `imports = [ nur.repos.falconprogrammer.modules.<module-name> ];`

## CI/CD

GitHub Actions workflow (`.github/workflows/build.yml`):
- Builds against multiple nixpkgs channels (unstable, 25.05)
- Evaluates all packages for correctness
- Builds cacheable outputs via `ci.nix`
- Triggers NUR registry update on success

The `ci.nix` file filters packages by:
- `isBuildable`: Excludes broken or non-free packages
- `isCacheable`: Excludes packages marked with `preferLocalBuild`

## Special Package Notes

### opencode-sst

This package requires runtime patching of downloaded binaries for NixOS compatibility. The package includes:
- Automatic patchelf wrapper that fixes dynamic linker paths
- Standalone patching script at `$out/share/opencode/patch-opencode-cache.sh`
- Bundled Node.js runtime to avoid download issues

**Auto-update Workflow** (`.github/workflows/update-opencode.yml`):
- Runs daily at 3:30 AM UTC or manually via workflow_dispatch
- Checks GitHub API for new opencode releases
- Automatically updates version and recalculates hash using Nix
- Creates PR, builds package, and auto-merges if successful
- Closes/deletes older update PRs/branches
- Triggers NUR sync after merge
- Creates draft PR for manual review if build fails

To manually update: modify version in `pkgs/opencode-sst/default.nix`, set dummy hash, run `nix build .#opencode-sst` to get correct hash from error message.

## Flake Structure

The flake (`flake.nix`) provides:
- `legacyPackages.<system>`: All packages via `default.nix`
- `packages.<system>`: Only derivations (filters out lib/modules/overlays)
- `nixosModules`: NixOS modules for system configuration

Supports platforms: x86_64-linux, i686-linux, x86_64-darwin, aarch64-darwin, aarch64-linux, armv6l-linux, armv7l-linux

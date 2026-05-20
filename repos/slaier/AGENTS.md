# Repository Overview

## Project Description
- This repository contains a modular NixOS configuration, managed using Nix Flakes.
- The goal is to provide a reproducible, declarative, and scalable system configuration with Home Manager integration.
- Key technologies used: NixOS, Nix Flakes, Home Manager, SOPS (for secrets management), and various community modules (NUR, nix-index, niri).

## Architecture Overview
- The repository is organized into modules, allowing for clean separation of concerns between system services, user applications, and packages.
- The `flake.nix` serves as the entry point, defining inputs, outputs (nixosConfigurations, packages), and dev shells.
- It utilizes a custom library in `lib/` for recursive directory processing, which allows modules to be automatically imported if they follow the standard `default.nix`, `home.nix`, and `package.nix` pattern.
- Secrets are managed via `sops-nix` and stored in the `secrets/` directory.

## Directory Structure
- `hosts/`: Contains system-specific configurations (e.g., `local/` for current system, `installer/` for ISOs).
- `modules/`: Contains program-specific modules, split into `default.nix` (NixOS), `home.nix` (Home Manager), and `package.nix` (buildable package).
- `lib/`: Contains helper functions for processing the modular structure.
- `secrets/`: Holds encrypted configuration secrets managed by SOPS.
- `flake.nix`: The root configuration file defining system builds and flake inputs.
- `justfile`: Contains command aliases for common development tasks.

## Development Workflow
- **Building/Switching**: Use `just local switch` to rebuild and switch to the local NixOS configuration.
- **Testing**: Use `just` to run `nixos-rebuild test`.
- **Environment**: Development tools are defined in the flake `devShells`. Use `nix run .#devShells.default` to enter.
- **Updates**: Use `just update` to update flake inputs.
- **Lint/Format**: `nixpkgs-fmt` is used as the formatter; `nix flake check` can be used to verify consistency.

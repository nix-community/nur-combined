# urio-nur

**My personal [NUR](https://github.com/nix-community/NUR) repository**

[![Cachix Cache](https://img.shields.io/badge/cachix-uriotv-blue.svg)](https://uriotv.cachix.org)
[![Build and populate cache](https://github.com/urioTV/urio-nur/workflows/Update%20packages/badge.svg)](https://github.com/urioTV/urio-nur/actions)

## Packages

| Package | Description | Update Policy |
| :--- | :--- | :--- |
| **`wowup-cf`** | World of Warcraft addon manager with CurseForge support (AppImage) | **Auto** (Weekly) |
| **`scopebuddy`** | ScopeBuddy application | **Auto** (Weekly) |
| **`cybergrub2077`** | Cyberpunk 2077 inspired GRUB theme | **Auto** (Weekly) |
| **`vintagestory`** | Vintage Story (Sandbox Survival Game) | **Manual** (Version control) |

## Usage

### Using Flakes (Recommended)

Add to your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    urio-nur.url = "github:urioTV/urio-nur";
    urio-nur.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, urio-nur, ... }: {
    nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        urio-nur.nixosModules.default # Imports all modules
      ];
    };
  };
}
```

Flake overlay: `urio-nur.overlays.default`

## Vintage Story Configuration

Vintage Story requires manual version selection. Use the provided NixOS module:

```nix
programs.vintagestory = {
  enable = true;
  version = "1.21.0"; # Check https://www.vintagestory.at/download/
  hash = "sha256-90YQOur7UhXxDBkGLSMnXQK7iQ6+Z8Mqx9PEG6FEXBs="; # Use nix-prefetch-url
};
```

To get the hash for a new version:
```bash
nix-prefetch-url https://cdn.vintagestory.at/gamefiles/stable/vs_client_linux-x64_<VERSION>.tar.gz
nix hash convert --hash-algo sha256 --to sri <HASH>
```

## Updates

- Packages are automatically updated weekly via GitHub Actions.
- **Vintage Story** is excluded from auto-updates to ensure version stability and user control.

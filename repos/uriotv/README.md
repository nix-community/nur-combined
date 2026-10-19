# urio-nur

**My personal [NUR](https://github.com/nix-community/NUR) repository**

[![Cachix Cache](https://img.shields.io/badge/cachix-uriotv-blue.svg)](https://uriotv.cachix.org)
[![Build and populate cache](https://github.com/urioTV/urio-nur/workflows/Update%20packages/badge.svg)](https://github.com/urioTV/urio-nur/actions)

## Packages

| Package | Description | Update Policy |
| :--- | :--- | :--- |
| **`nmssaveeditor`** | Save editor for No Man's Sky | **Auto** (Weekly) |
| **`pig`** | Pi coding agent rebuilt in Go as a single native binary | **Auto** (Weekly) |
| **`rimsort-appimage`** | Open source mod manager for RimWorld (AppImage) | **Auto** (Weekly) |
| **`wowup-cf`** | World of Warcraft addon manager with CurseForge support (AppImage) | **Auto** (Weekly) |
| **`scopebuddy`** | ScopeBuddy application | **Auto** (Weekly) |
| **`storyforge`** | Story Forge desktop application, built independently of the upstream flake | Manual |
| **`bbport`** | Native Linux port of Bloodborne (needs your own game dump) | **Auto** (Weekly) |
| **`cybergrub2077`** | Cyberpunk 2077 inspired GRUB theme | **Auto** (Weekly) |

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

### Story Forge

Use `urio-nur.packages.${pkgs.system}.storyforge` in your package list, or
`pkgs.storyforge` after enabling the overlay. No StoryForge flake input is required.

Build locally with:

```bash
nix build .#storyforge
```

## Updates

- Packages are automatically updated weekly via GitHub Actions.

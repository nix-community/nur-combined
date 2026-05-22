# urio-nur

**My personal [NUR](https://github.com/nix-community/NUR) repository**

[![Cachix Cache](https://img.shields.io/badge/cachix-uriotv-blue.svg)](https://uriotv.cachix.org)
[![Build and populate cache](https://github.com/urioTV/urio-nur/workflows/Update%20packages/badge.svg)](https://github.com/urioTV/urio-nur/actions)

## Packages

| Package | Description | Update Policy |
| :--- | :--- | :--- |
| **`optiscaler-client`** | Modern manager for OptiScaler | **Auto** (Weekly) |
| **`optiscaler-install`** | Downloader and launcher for the official OptiScaler Linux setup script | Manual (runtime latest) |
| **`optipatcher-install`** | Downloader for the latest OptiPatcher ASI plugin | Manual (runtime latest) |
| **`rimsort-appimage`** | Open source mod manager for RimWorld (AppImage) | **Auto** (Weekly) |
| **`wowup-cf`** | World of Warcraft addon manager with CurseForge support (AppImage) | **Auto** (Weekly) |
| **`scopebuddy`** | ScopeBuddy application | **Auto** (Weekly) |
| **`cybergrub2077`** | Cyberpunk 2077 inspired GRUB theme | **Auto** (Weekly) |
| **`vs-launcher`** | Unofficial Vintage Story Launcher | **Auto** (Weekly) |

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


## Updates

- Packages are automatically updated weekly via GitHub Actions.

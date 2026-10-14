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
| **`cybergrub2077`** | Cyberpunk 2077 inspired GRUB theme | **Auto** (Weekly) |
| **`rea-agents`** | Bare REA CLI and MCP server | **Auto** (Weekly) |

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

### REA with Home Manager

Import the module and enable REA. Ghidra is optional; when enabled it is added
to the user's Home Manager profile (so `ghidra` is on `PATH`) and its paths are
configured for REA:

```nix
{
  imports = [ urio-nur.homeModules.rea ];
  programs.rea = {
    enable = true;
    ghidra.enable = true;
    freeTools.enable = true; # all supported free REA tools except Ghidra
    # Example: leave one out while keeping the rest of the bundle:
    # freeTools.chromium.enable = false;
    # ghidra.package = pkgs.ghidra; # default
  };
}
```

`urio-nur.packages.<system>.rea-agents` is the bare CLI/MCP package and does not
pull Ghidra or optional tools into its closure. `programs.rea.freeTools` also has
individual switches for Chromium, Android tools, Apktool, JADX, ILSpy, Binwalk,
Unblob, mitmproxy, Wakaru, pwntools, pwndbg, and `prlimit`. The full free-tools
bundle currently targets x86_64-linux; `ghidra` remains a separate option. The
pinned REA 6.4.0 release does not yet wire Rizin or GNU objdump into REA, so the
module does not expose misleading install-only switches for them. See
[`pkgs/rea-agents/README.md`](pkgs/rea-agents/README.md) for details.

## Updates

- Packages are automatically updated weekly via GitHub Actions.

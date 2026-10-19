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
| **`bbport`** | Native Linux port of Bloodborne (needs your own game dump) | **Auto** (Weekly) |
| **`cybergrub2077`** | Cyberpunk 2077 inspired GRUB theme | **Auto** (Weekly) |
| **`linux-cachyos-bore-x86_64-v3`** | Latest stable CachyOS BORE kernel, v3, no LTO | **Auto** (Daily, gated kernel build) |

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
        urio-nur.nixosModules.default # Imports module options; features remain opt-in
      ];
    };
  };
}
```

Flake overlay: `urio-nur.overlays.default`

## CachyOS kernel

The opt-in `urio-nur.nixosModules.cachyos` module installs the pinned BORE v3
kernel with `boot.cachyos.enable = true` and an explicit
`boot.cachyos.cpuSupportsV3 = true` acknowledgement. Enable the Cachix cache in
an earlier generation first. See the [kernel guide](pkgs/linux-cachyos-bore-x86_64-v3/README.md)
for the complete two-stage installation, CPU requirements, CI/publication,
licensing and free-tier limitations. No LTS or LTO variants are built.

All CI Nix builds run on [nixbuild.net](https://nixbuild.net) (repository secret
`NIXBUILD_TOKEN`, no fallback to GitHub runners); results are published to
`uriotv.cachix.org` from `main` only.

Local publication is available with `nix run .#build-and-cache-kernel`.
For credentials, this repo includes sops-nix and an optional
`nixosModules.kernel-publisher` module; follow [the SOPS setup guide](secrets/README.md)
to provide recipients and an encrypted token. No credentials are shipped.

## Updates

- Packages are automatically updated weekly via GitHub Actions.

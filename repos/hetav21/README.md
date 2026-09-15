# NUR Packages

[![Build and populate cache](https://github.com/Hetav21/NUR/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/Hetav21/NUR/actions/workflows/build.yml)
[![Cachix Cache](https://img.shields.io/badge/cachix-hetav21-blue.svg)](https://hetav21.cachix.org)

Personal [NUR (Nix User Repository)](https://github.com/nix-community/NUR) repository maintained by [@Hetav21](https://github.com/Hetav21).

## Packages

| Package | Description | Upstream |
| :--- | :--- | :--- |
| [`direnv-nvim`](./pkgs/direnv-nvim) | Direnv integration for Neovim written in Lua | [NotAShelf/direnv.nvim](https://github.com/NotAShelf/direnv.nvim) |
| [`wsl-notify-send`](./pkgs/wsl-notify-send) | Send Windows 10/11 toast notifications from WSL | [stuartleeks/wsl-notify-send](https://github.com/stuartleeks/wsl-notify-send) |

---

## Binary Cache (Cachix)

Pre-built binaries are cached via Cachix.

### With Cachix CLI
```bash
cachix use hetav21
```

### Declaratively in NixOS / Home Manager
```nix
nix.settings = {
  extra-substituters = [
    "https://hetav21.cachix.org"
  ];
  extra-trusted-public-keys = [
    "hetav21.cachix.org-1:O5O3aE7/wLp4F0uMLu4vJEr/Rn5UUWu97clxBxFALzc="
  ];
};
```

### In a Flake (`nixConfig`)
```nix
nixConfig = {
  extra-substituters = [ "https://hetav21.cachix.org" ];
  extra-trusted-public-keys = [ "hetav21.cachix.org-1:O5O3aE7/wLp4F0uMLu4vJEr/Rn5UUWu97clxBxFALzc=" ];
};
```

---

## Usage

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Optional: Binary cache for faster builds
  nixConfig = {
    extra-substituters = [ "https://hetav21.cachix.org" ];
    extra-trusted-public-keys = [ "hetav21.cachix.org-1:O5O3aE7/wLp4F0uMLu4vJEr/Rn5UUWu97clxBxFALzc=" ];
  };

  outputs = { self, nixpkgs, nur, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
          nixpkgs.overlays = [ nur.overlays.default ];
        }
        ({ pkgs, ... }: {
          environment.systemPackages = [
            pkgs.nur.repos.hetav21.direnv-nvim
            pkgs.nur.repos.hetav21.wsl-notify-send
          ];
        })
      ];
    };
  };
}
```

---

## Development

```bash
# Build an individual package (Flakes)
nix build .#<package-name>

# Build an individual package (Classic Nix)
nix-build -A <package-name>

# Build all packages locally
nix-build ci.nix -A buildOutputs

# Check only packages pushed to Cachix by CI
nix-build ci.nix -A cacheOutputs

# Test restricted evaluation (NUR CI check)
nix-env -f . -qa \* --meta --xml \
  --allowed-uris https://static.rust-lang.org \
  --option restrict-eval true \
  --option allow-import-from-derivation true \
  --drv-path --show-trace \
  -I nixpkgs=$(nix-instantiate --find-file nixpkgs) \
  -I $PWD
```

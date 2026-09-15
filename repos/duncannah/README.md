<div align="center">

# duncannah's NUR repository

Personal Nix packages and modules.

[![Build](https://img.shields.io/github/actions/workflow/status/duncannah/nur-packages/build.yml)](https://github.com/duncannah/nur-packages/actions/workflows/build.yml) [![Cachix Cache](https://img.shields.io/badge/cachix-duncannah--nur-purple.svg)](https://duncannah-nur.cachix.org)

</div>

## Usage

### Run directly from this flake

```sh
nix run github:duncannah/nur-packages#gomerge -- --help
```

### Manual flake installation

Add this repository as an input in your own `flake.nix`:

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  nurPackages.url = "github:duncannah/nur-packages";
};
```

Add the package to your system package list:

```nix
environment.systemPackages = [
  nurPackages.packages.${pkgs.system}.gomerge
];
```

The `nurPackages` input must be available in the `outputs` function:

```nix
outputs = { self, nixpkgs, nurPackages, ... }: {
  # Your system and user configurations go here.
};
```

### Use through NUR

Add NUR to your `flake.nix`:

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  nur = {
    url = "github:nix-community/NUR";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

Add the NUR overlay to your package set:

```nix
pkgs = import nixpkgs {
  inherit system;
  overlays = [ nur.overlays.default ];
};
```

You can then add the package to your system or user packages:

```nix
pkgs.nur.repos.duncannah.gomerge
```

## Cachix

Cachix provides builds from the `duncannah-nur` cache, for `x86_64-linux`, `aarch64-linux`, and `aarch64-darwin`.

Add this to the top level of the flake that uses this repository:

```nix
nixConfig = {
  extra-substituters = [ "https://duncannah-nur.cachix.org" ];
  extra-trusted-public-keys = [ "duncannah-nur.cachix.org-1:miatqAoEE+7++VDIf6BxFOFe2Or4JJj7ixeKrd9TXdc=" ];
};
```

These settings work with standalone Nix, NixOS, and nix-darwin. Only trust caches and signing keys that you have reviewed. See the [Nix binary cache guide](https://nix.dev/guides/recipes/add-binary-cache.html) and [Stop trusting Nix caches](https://web.archive.org/web/20251001154446/https://garnix.io/blog/stop-trusting-nix-caches).

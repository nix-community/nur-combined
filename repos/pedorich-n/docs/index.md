# NUR {#index-title}

This repo contains a few personal packages and NixOS modules that I use with NUR.

## Usage {#index-usage}

### Packages (Using Flakes) {#index-usage-packages}

Include NUR in your `flake.nix`, apply the overlay, and then access packages via `pkgs.<package>`:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };


  outputs = { self, nixpkgs, nur, ... }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          nur.repos.pedorich-n.overlays.default
        ];
      };
    in {
      ...
    };
}
```

#### In NixOS {#index-usage-packages-nixos}

If you want these packages available in your NixOS configuration:

First, pass `nur` to the NixOS configuration using `specialArgs`:

```nix
nixpkgs.lib.nixosSystem {
  modules = [
    ...
  ];

  specialArgs = {
    inherit (inputs) nur;
  };
}
```

Then apply the overlay in your NixOS configuration:

```nix
{
  nur,
  ...
}:
{
  nixpkgs.overlays = [
    nur.repos.pedorich-n.overlays.default
  ];
}
```

#### Binary cache {#index-usage-packages-cache}

In order to improve the build time, this repository also provides a biniary cache for the custom packages.
To use it, add the following to your `flake.nix`:

```nix
{
  nixConfig = {
    extra-substituters = [
      "https://pedorich-n-nur.cachix.org"
    ];
    extra-trusted-public-keys = [
      "pedorich-n-nur.cachix.org-1:EisUgiRsKFmZ3LJN7r29oDae+Wxq9FQpkcydRx19N7Q="
    ];
  };

  # The rest of flake.nix
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  }

  outputs = ...
}
```

Or, if using with NixOS:

```nix
{
  config,
  pkgs,
  ...
}:
{
  nix.settings = {
    substituters = [
      "https://pedorich-n-nur.cachix.org"
    ];
    trusted-public-keys = [
      "pedorich-n-nur.cachix.org-1:EisUgiRsKFmZ3LJN7r29oDae+Wxq9FQpkcydRx19N7Q="
    ];
  };
}

```

### NixOS modules (Using Flakes) {#index-usage-modules-nixos}

Include NUR in your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

}
```

Pass the modules you want to use to the `nixosSystem` builder:

```nix
nixpkgs.lib.nixosSystem {
  modules = [
    ./configuration.nix
    nur.repos.pedorich-n.modules.nixos.<module-name>
  ];
  ...
}
```

If a module you want to use also requires a custom package, you'll need to make that package available via an [overlay](#index-usage-packages-nixos).

## Available NixOS modules

See [Options](options.md).

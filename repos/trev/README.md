# trev's [nur](https://github.com/nix-community/NUR) repository

[![checks status](https://img.shields.io/github/actions/workflow/status/spotdemo4/nur/checks.yaml?logo=github&label=checks&labelColor=%2311111b)](https://github.com/spotdemo4/nur/actions/workflows/checks.yaml)
[![checks status](https://img.shields.io/github/actions/workflow/status/spotdemo4/nur/flake.yaml?logo=nixos&logoColor=%2389dceb&label=flake&labelColor=%2311111b)](https://github.com/spotdemo4/nur/actions/workflows/flake.yaml)
[![cachix](https://img.shields.io/badge/cachix-trevnur-%23313244?logo=nixos&logoColor=%2389dceb&labelColor=%2311111b)](https://trevnur.cachix.org)

### devshell example
```nix
{
  nixConfig = {
    extra-substituters = [
      "https://trevnur.cachix.org"
    ];
    extra-trusted-public-keys = [
      "trevnur.cachix.org-1:hBd15IdszwT52aOxdKs5vNTbq36emvEeGqpb25Bkq6o="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    flake-utils,
    nur,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [nur.overlays.default];
        };
      in {
        devShells.default = pkgs.mkShell {
          packages = [pkgs.nur.repos.trev.bobgen];
        };
      }
    );
}
```


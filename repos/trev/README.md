# trev's [nur](https://github.com/nix-community/NUR) repository

[![checks status](https://img.shields.io/github/actions/workflow/status/spotdemo4/nur/checks.yaml?logo=github&label=checks&labelColor=%2311111b)](https://github.com/spotdemo4/nur/actions/workflows/checks.yaml)
[![flake status](https://img.shields.io/github/actions/workflow/status/spotdemo4/nur/flake.yaml?logo=nixos&logoColor=%2389dceb&label=flake&labelColor=%2311111b)](https://github.com/spotdemo4/nur/actions/workflows/flake.yaml)
[![nur sync status](https://img.shields.io/github/actions/workflow/status/spotdemo4/nur/synced.yaml?logo=nixos&logoColor=%2389dceb&label=nur%20sync&labelColor=%2311111b)](https://github.com/spotdemo4/nur/actions/workflows/synced.yaml)
[![cachix](https://img.shields.io/badge/cachix-trevnur-%23313244?logo=nixos&logoColor=%2389dceb&labelColor=%2311111b)](https://trevnur.cachix.org)

## Packages

- [bobgen](https://github.com/stephenafamo/bob) - Generates an ORM for Go based on a database schema
  - Pending nixpkgs [NixOS#420450](https://github.com/NixOS/nixpkgs/pull/420450)
- [protoc-gen-connect-openapi](https://github.com/sudorandom/protoc-gen-connect-openapi) - Plugin for generating OpenAPIv3 from protobufs matching the Connect RPC interface
  - Pending nixpkgs [NixOS#398495](https://github.com/NixOS/nixpkgs/pull/398495)
- [renovate](https://github.com/renovatebot/renovate) - Cross-platform dependency automation
  - Patched with [renovate#37222](https://github.com/renovatebot/renovate/pull/37222) to fix flake.lock refreshes
- [opengrep](https://github.com/opengrep/opengrep) - Static code analysis engine to find security issues in code
- [bumper](https://github.com/spotdemo4/nur/blob/main/pkgs/bumper/bumper.sh) - Shell script for doing git version bumps (ie. 0.0.1 -> 0.0.2)
- [shellhook](https://github.com/spotdemo4/nur/blob/main/pkgs/shellhook/shellhook.sh) - Shell script to run when entering a git repo with direnv

## Libs

- mkChecks - Utility function to make creating flake checks easier

```nix
checks = forSystem ({pkgs, ...}:
  pkgs.nur.repos.trev.lib.mkChecks {
    lint = {
      src = ./.;
      deps = with pkgs; [
        alejandra
        sqlfluff
        revive
      ];
      script = ''
        alejandra -c .
        sqlfluff lint
        revive -config revive.toml -set_exit_status ./...
      '';
    };
});
```

- go.moduleToPlatform - Changes the goos & goarch values of a buildGoModule derivation
- go.moduleToImage - Turns a buildGoModule derivation into a docker image

```nix
packages = forSystem (
  {
    pkgs,
    system,
    ...
  }:
    with pkgs.nur.repos.trev.lib; rec {
      default = ts-server."${system}";

      linux-amd64 = go.moduleToPlatform default "linux" "amd64";
      linux-arm64 = go.moduleToPlatform default "linux" "arm64";
      linux-arm = go.moduleToPlatform default "linux" "arm";
      darwin-arm64 = go.moduleToPlatform default "darwin" "arm64";
      windows-amd64 = go.moduleToPlatform default "windows" "amd64";

      linux-amd64-image = go.moduleToImage linux-amd64;
      linux-arm64-image = go.moduleToImage linux-arm64;
      linux-arm-image = go.moduleToImage linux-arm;
    }
);
```

- buf.fetchDeps & buf.configHook - Creates a fixed-output derivation containing buf dependencies

```nix
pkgs.stdenv.mkDerivation (finalAttrs: {
  pname = "proto";
  version = "1.0.0";
  src = ./.;

  nativeBuildInputs = with pkgs; [
    buf
    pkgs.nur.repos.trev.lib.buf.configHook
  ];

  bufDeps = pkgs.nur.repos.trev.lib.buf.fetchDeps {
    inherit (finalAttrs) pname version src;
    hash = "...";
  };

  doCheck = true;
  checkPhase = ''
    buf lint
  '';
});
```

## Install

### DevShell

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
          overlays = [nur.overlays.default]; # Add the NUR overlay
        };
      in {
        devShells.default = pkgs.mkShell {
          packages = [pkgs.nur.repos.trev.bobgen]; # Use the NUR overlay
        };
      }
    );
}
```

### NixOS

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
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nur }: {
    nixosConfigurations.myConfig = nixpkgs.lib.nixosSystem {
      modules = [
        nur.modules.nixos.default # Add the NUR overlay

        ({ pkgs, ... }: {
          environment.systemPackages = [pkgs.nur.repos.trev.bobgen]; # Use the NUR overlay
        })
      ];
    };
  };
}
```

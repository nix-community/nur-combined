# trev's [nur](https://github.com/nix-community/NUR) repository

[![checks status](https://img.shields.io/github/actions/workflow/status/spotdemo4/nur/checks.yaml?logo=github&label=checks&labelColor=%2311111b)](https://github.com/spotdemo4/nur/actions/workflows/checks.yaml)
[![flake status](https://img.shields.io/github/actions/workflow/status/spotdemo4/nur/flake.yaml?logo=nixos&logoColor=%2389dceb&label=flake&labelColor=%2311111b)](https://github.com/spotdemo4/nur/actions/workflows/flake.yaml)
[![cachix](https://img.shields.io/badge/cachix-trevnur-%23313244?logo=nixos&logoColor=%2389dceb&labelColor=%2311111b)](https://trevnur.cachix.org)

## Packages

- [bobgen](https://github.com/stephenafamo/bob) - Generates an ORM for Go based on a database schema 
  - Pending nixpkgs [NixOS#420450](https://github.com/NixOS/nixpkgs/pull/420450)
- [protoc-gen-connect-openapi](https://github.com/sudorandom/protoc-gen-connect-openapi) - Plugin for generating OpenAPIv3 from protobufs matching the Connect RPC interface 
  - Pending nixpkgs [NixOS#398495](https://github.com/NixOS/nixpkgs/pull/398495)
- [opengrep](https://github.com/opengrep/opengrep) - Static code analysis engine to find security issues in code
  - Blocked by [opengrep#347](https://github.com/opengrep/opengrep/pull/347)

## Overlays

- [renovate](https://github.com/renovatebot/renovate) - Automated dependency update tool
  - patch: fix flake lock refresh [renovatebot#33991](https://github.com/renovatebot/renovate/pull/33991)

## Libs

- mkChecks - Utility function to make creating flake checks easier

```nix
checks = forSystem ({pkgs, ...}:
  pkgs.nur.repos.trev.lib.mkChecks {
    lint = {
      src = ./.;
      nativeBuildInputs = with pkgs; [
        alejandra
        revive
        sqlfluff
      ];
      checkPhase = ''
        alejandra -c .
        sqlfluff lint
        revive -config revive.toml -set_exit_status ./...
      '';
    };
});
```

## Examples

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
    flake-utils.url = "github:numtide/flake-utils";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nur }: {
    nixosConfigurations.myConfig = nixpkgs.lib.nixosSystem {
      modules = [
        # Adds the NUR overlay
        nur.modules.nixos.default

        # Use the NUR overlay
        ({ pkgs, ... }: {
          environment.systemPackages = [pkgs.nur.repos.trev.bobgen];
        })
      ];
    };
  };
}
```

# trev's nix repository

![check](https://github.com/spotdemo4/nur/actions/workflows/check.yaml/badge.svg)
![vulnerable](https://github.com/spotdemo4/nur/actions/workflows/vulnerable.yaml/badge.svg)
![synced](https://github.com/spotdemo4/nur/actions/workflows/sync.yaml/badge.svg)

Extra packages, bundlers and libs for nix

## Packages

- [bobgen](https://github.com/stephenafamo/bob)
  - Pending nixpkgs [NixOS#420450](https://github.com/NixOS/nixpkgs/pull/420450)
- [bumper](https://github.com/spotdemo4/bumper)
- [ffmpeg-quality-metrics](https://github.com/slhck/ffmpeg-quality-metrics)
- [nix-fix-hash](https://github.com/spotdemo4/nix-fix-hash)
- [opengrep](https://github.com/opengrep/opengrep)
- [protoc-gen-connect-openapi](https://github.com/sudorandom/protoc-gen-connect-openapi)
  - Pending nixpkgs [NixOS#398495](https://github.com/NixOS/nixpkgs/pull/398495)
- [qsvenc](https://github.com/rigaya/QSVEnc)
- [renovate](https://github.com/renovatebot/renovate)
  - Patched with [renovate#37899](https://github.com/renovatebot/renovate/pull/37899) to fix flake updates
- [shellhook](https://github.com/spotdemo4/nur/blob/main/pkgs/shellhook/shellhook.sh)

## Bundlers

### toDockerStream

An alternative to `github:NixOS/bundlers#toDockerImage` that uses `streamLayeredImage` rather than `buildLayeredImage`

```console
$ nix bundle --bundler github:spotdemo4/nur#toDockerImage
```

### goTo[GOOS][GOARCH]

Builds a go package using the GOOS and GOARCH values supplied

```console
$ nix bundle -o binary --bundler github:spotdemo4/nur#goToLinuxAmd64
$ nix bundle -o binary.exe --bundler github:spotdemo4/nur#goToWindowsAmd64
```

## Libs

### mkChecks

Utility function to make creating flake checks easier

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

### go.moduleToPlatform & go.moduleToImage

Changes the goos & goarch values of a buildGoModule derivation, and turns a buildGoModule derivation into a docker image

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

### buf.fetchDeps & buf.configHook

Creates a fixed-output derivation for [buf](https://buf.build/) dependencies

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
      "https://cache.trev.zip/nur"
    ];
    extra-trusted-public-keys = [
      "nur:70xGHUW1+1b8FqBchldaunN//pZNVo6FKuPL4U/n844="
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
      "https://cache.trev.zip/nur"
    ];
    extra-trusted-public-keys = [
      "nur:70xGHUW1+1b8FqBchldaunN//pZNVo6FKuPL4U/n844="
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

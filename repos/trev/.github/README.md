# trev's nix repository

![check](https://github.com/spotdemo4/nur/actions/workflows/check.yaml/badge.svg)
![vulnerable](https://github.com/spotdemo4/nur/actions/workflows/vulnerable.yaml/badge.svg)
![nix user repository](https://github.com/spotdemo4/nur/actions/workflows/sync.yaml/badge.svg)

Extra [packages](#packages), [bundlers](#bundlers) and [libs](#libs) for [nix](https://nixos.org/)

## Packages

Packages are [cached](#cache) and kept up-to-date automatically. Available here or the [Nix User Repository](https://nur.nix-community.org/repos/trev/).

### [bob](https://github.com/stephenafamo/bob)

SQL query builder and ORM/Factory generator for Go

- pending nixpkgs [NixOS#420450](https://github.com/NixOS/nixpkgs/pull/420450)

```elm
nix run github:spotdemo4/nur#bobgen
```

### [bumper](https://github.com/spotdemo4/bumper)

Version bumper for projects using git and semantic versioning

```elm
nix run github:spotdemo4/nur#bumper
```

### [ffmpeg-quality-metrics](https://github.com/slhck/ffmpeg-quality-metrics)

Calculates video quality metrics with FFmpeg (SSIM, PSNR, VMAF, VIF)

```elm
nix run github:spotdemo4/nur#ffmpeg-quality-metrics
```

### [nix-fix-hash](https://github.com/spotdemo4/nix-fix-hash)

Nix hash fixer

```elm
nix run github:spotdemo4/nur#nix-fix-hash
```

### [nix-flake-release](https://github.com/spotdemo4/nix-flake-release)

Nix flake package releaser

```elm
nix run github:spotdemo4/nur#nix-flake-release
```

### [opengrep](https://github.com/opengrep/opengrep)

Static code analysis engine to find security issues in code

```elm
nix run github:spotdemo4/nur#opengrep
```

### [protoc-gen-connect-openapi](https://github.com/sudorandom/protoc-gen-connect-openapi)

Protobuf plugin for generating OpenAPI specs matching the Connect RPC interface

- pending nixpkgs [NixOS#398495](https://github.com/NixOS/nixpkgs/pull/398495)

```elm
nix run github:spotdemo4/nur#protoc-gen-connect-openapi
```

### [qsvenc](https://github.com/rigaya/QSVEnc)

QSV high-speed encoding performance experiment tool

```elm
nix run github:spotdemo4/nur#qsvenc
```

### [renovate](https://github.com/renovatebot/renovate)

Cross-platform dependency automation, with patches for nix

- patched with [renovate#37899](https://github.com/renovatebot/renovate/pull/37899) to fix flake updates

```elm
nix run github:spotdemo4/nur#renovate
```

### [shellhook](https://github.com/spotdemo4/nur/blob/main/pkgs/shellhook/shellhook.sh)

Shell hook for nix development shells

```elm
nix run github:spotdemo4/nur#shellhook
```

## Bundlers

A collection of [nix bundlers](https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-bundle) mainly used for cross-compilation. The `system` is in the format given by `builtins.currentSystem` ([examples](https://github.com/NixOS/nixpkgs/blob/master/lib/systems/flake-systems.nix)).

### deno-`system`

Overrides `pkgs.buildNpmPackage` to build an npm package for the given system with [deno compile](https://docs.deno.com/runtime/reference/cli/compile/)

```elm
nix bundle --bundler github:spotdemo4/nur#deno-x86_64-linux
```

### docker & docker-stream

An alternative to `github:NixOS/bundlers#toDockerImage`

```elm
nix bundle --bundler github:spotdemo4/nur#docker # buildLayeredImage
nix bundle --bundler github:spotdemo4/nur#docker-stream # streamLayeredImage
```

### go-`system`

Overrides `pkgs.buildGoModule` to build a go module for the given system

```elm
nix bundle --bundler github:spotdemo4/nur#go-x86_64-linux
```

### go-compress-`system`

Overrides `pkgs.buildGoModule` to build a go module for the given system and compresses the output with [upx](https://upx.github.io/)

```elm
nix bundle --bundler github:spotdemo4/nur#go-compress-x86_64-linux -o binary
```

## Libs

### mkFlake

Utility function to simplify creating flakes. Basically [flake-utils.lib.eachDefaultSystem](https://github.com/numtide/flake-utils) but you can put non-system specific outputs like `overlays` inside the function too.

```nix
inputs = {
  systems.url = "github:nix-systems/default";
  nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  trev = {
    url = "github:spotdemo4/nur";
    inputs.systems.follows = "systems";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};

outputs =
  {
    nixpkgs,
    trev,
    ...
  }:
  trev.libs.mkFlake (
    system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          trev.overlays.packages
          trev.overlays.libs
        ];
      };
    in
    rec {
      devShells = {
        default = pkgs.mkShell {
          packages = with pkgs; [
            nixfmt
          ];
          shellHook = pkgs.shellhook.ref;
        };
      };
    }
  );
```

### mkChecks

Utility function to simplify flake checks

```nix
checks = pkgs.lib.mkChecks {
  lint = {
    src = ./.;
    deps = with pkgs; [
      nixfmt-tree
      sqlfluff
      prettier
    ];
    script = ''
      treefmt --ci
      sqlfluff lint
      prettier --check .
    '';
  };
};
```

### mkApps

Utility function to simplify flake apps

```nix
apps = pkgs.lib.mkApps {
  lint = {
    deps = with pkgs; [
      nixfmt-tree
      sqlfluff
      prettier
    ];
    script = ''
      treefmt --ci
      sqlfluff lint
      prettier --check .
    '';
  };
};
```

```elm
nix run #lint
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
    with pkgs.lib; rec {
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
    lib.buf.configHook
    buf
  ];

  bufDeps = pkgs.lib.buf.fetchDeps {
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

### Direct

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
    systems.url = "github:nix-systems/default";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    trev = {
      url = "github:spotdemo4/nur";
      inputs.systems.follows = "systems";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      trev,
      ...
    }:
    trev.libs.mkFlake (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            trev.overlays.packages
            trev.overlays.libs
          ];
        };
      in
      rec {
        devShells = {
          default = pkgs.mkShell {
            packages = with pkgs; [
              nixfmt
              prettier
            ];
            shellHook = pkgs.shellhook.ref;
          };
        };

        checks = pkgs.lib.mkChecks {
          nix = {
            src = ./.;
            deps = with pkgs; [
              nixfmt-tree
            ];
            script = ''
              treefmt --ci
            '';
          };
        };
      }
    );
}
```

### Nix User Repository

Using the [Nix User Repository](https://github.com/nix-community/NUR)

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

## Cache

Every package in this repo is built and cached each update. To pull from the cache instead of building:

### Single flake

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
}
```

### Entire NixOS system

```nix
{
  nix.settings = {
    trusted-substituters = [
      "https://cache.trev.zip/nur"
    ];
    trusted-public-keys = [
      "nur:70xGHUW1+1b8FqBchldaunN//pZNVo6FKuPL4U/n844="
    ];
  };
}
```

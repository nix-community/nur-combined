# trev's nix repository

[![check](https://github.com/spotdemo4/trevpkgs/actions/workflows/check.yaml/badge.svg)](https://github.com/spotdemo4/trevpkgs/actions/workflows/check.yaml)
[![vulnerable](https://github.com/spotdemo4/trevpkgs/actions/workflows/vulnerable.yaml/badge.svg)](https://github.com/spotdemo4/trevpkgs/actions/workflows/vulnerable.yaml)
[![nix user repository](https://github.com/spotdemo4/trevpkgs/actions/workflows/sync.yaml/badge.svg)](https://github.com/spotdemo4/trevpkgs/actions/workflows/sync.yaml)

Extra [packages](#packages), [bundlers](#bundlers), [images](#images) and [libs](#libs) for [nix](https://nixos.org/)

## Packages

Packages are [cached](#cache) and kept up-to-date automatically. Available here or the [Nix User Repository](https://nur.nix-community.org/repos/trev/).

### [bob](https://github.com/stephenafamo/bob)

SQL query builder and ORM/Factory generator for Go

- pending nixpkgs [NixOS#420450](https://github.com/NixOS/nixpkgs/pull/420450)

```elm
nix run github:spotdemo4/trevpkgs#bobgen
```

### [bumper](https://github.com/spotdemo4/bumper)

Version bumper for projects using git and semantic versioning

```elm
nix run github:spotdemo4/trevpkgs#bumper
```

### [catppuccin-gtk](https://github.com/Fausto-Korpsvart/Catppuccin-GTK-Theme)

Catppuccin theme for GTK

```nix
gtk = {
  enable = true;
  theme = {
    package = pkgs.trev.catppuccin-gtk.override {
      themeVariants = [ "sky" ];
      colorVariants = [ "dark" ];
    };
    name = "Catppuccin-Sky-Dark";
  };

  # https://raw.githubusercontent.com/nix-community/home-manager/f2d3e04e278422c7379e067e323734f3e8c585a7/modules/misc/news/2025/11/2025-11-26_11-55-28.nix
  gtk4.theme = config.gtk.theme;
};
```

### [catppuccin/zen-browser](https://github.com/catppuccin/zen-browser)

Catppuccin theme for Zen Browser

Using with [`0xc000022070/zen-browser-flake`](https://github.com/0xc000022070/zen-browser-flake):

```nix
programs.zen-browser.profiles.default = {
  userChrome = builtins.readFile "${pkgs.trev.catppuccin-zen-browser}/Mocha/Sky/userChrome.css";
  userContent = builtins.readFile "${pkgs.trev.catppuccin-zen-browser}/Mocha/Sky/userContent.css";
};
```

### [ffmpeg-quality-metrics](https://github.com/slhck/ffmpeg-quality-metrics)

Calculates video quality metrics with FFmpeg (SSIM, PSNR, VMAF, VIF)

```elm
nix run github:spotdemo4/trevpkgs#ffmpeg-quality-metrics
```

### [flake-release](https://github.com/spotdemo4/flake-release)

Flake package releaser

```elm
nix run github:spotdemo4/trevpkgs#flake-release
```

### [gleescript](https://github.com/lpil/gleescript)

Bundles your Gleam-on-Erlang project into an escript

```elm
nix run github:spotdemo4/trevpkgs#gleescript
```

### [go-over](https://github.com/bwireman/go-over)

A tool to audit Erlang & Elixir dependencies

```elm
nix run github:spotdemo4/trevpkgs#go-over
```

### [helium](https://github.com/imputnet/helium)

Private, fast, and honest web browser

```elm
nix run github:spotdemo4/trevpkgs#helium
```

### [igsc](https://github.com/intel/igsc)

Intel graphics system firmware update library

```elm
nix run github:spotdemo4/trevpkgs#igsc
```

### [modal](https://pypi.org/project/modal)

Provides convenient, on-demand access to serverless cloud compute from Python scripts on your local computer

```nix
buildInputs = with pkgs.python314Packages; [
  modal
];
```

### [nix-fix-hash](https://github.com/spotdemo4/nix-fix-hash)

Nix hash fixer

```elm
nix run github:spotdemo4/trevpkgs#nix-fix-hash
```

### [nix-scan](https://github.com/spotdemo4/nix-scan)

Nix vulnerability scanner

```elm
nix run github:spotdemo4/trevpkgs#nix-scan
```

### [nvtop-exporter](https://github.com/spotdemo4/nvtop-exporter)

Prometheus exporter for nvtop

```elm
nix run github:spotdemo4/trevpkgs#nvtop-exporter
```

### [opengrep](https://github.com/opengrep/opengrep)

Static code analysis engine to find security issues in code

```elm
nix run github:spotdemo4/trevpkgs#opengrep
```

### [protoc-gen-connect-openapi](https://github.com/sudorandom/protoc-gen-connect-openapi)

Protobuf plugin for generating OpenAPI specs matching the Connect RPC interface

- pending nixpkgs [NixOS#398495](https://github.com/NixOS/nixpkgs/pull/398495)

```elm
nix run github:spotdemo4/trevpkgs#protoc-gen-connect-openapi
```

### [pysentry](https://github.com/nyudenkov/pysentry)

Scans your Python dependencies for known security vulnerabilities

```elm
nix run github:spotdemo4/trevpkgs#pysentry
```

### [qsvenc](https://github.com/rigaya/QSVEnc)

QSV high-speed encoding performance experiment tool

```elm
nix run github:spotdemo4/trevpkgs#qsvenc
```

### [renovate](https://github.com/renovatebot/renovate)

Cross-platform dependency update tool, with patches for nix

- patched with [renovate#40282](https://github.com/renovatebot/renovate/pull/40282) to fix flake updates

```elm
nix run github:spotdemo4/trevpkgs#renovate
```

### [shellhook](https://github.com/spotdemo4/trevpkgs/blob/main/pkgs/shellhook/shellhook.sh)

Shell hook for nix development shells

Displays info about the environment and creates a pre-push hook that runs `nix flake check`

```nix
devShells.x86_64-linux.default = pkgs.mkShell {
  shellHook = pkgs.shellhook.ref;
};
```

### [uv-build-latest](https://pypi.org/project/uv-build)

Build backend for uv; latest version

```nix
build-system = with pkgs.python314Packages; [
  setuptools
  uv-build-latest
];
```

### [yt-dlp](https://github.com/yt-dlp/yt-dlp)

A feature-rich command-line audio/video downloader; unstable version

```elm
nix run github:spotdemo4/trevpkgs#yt-dlp
```

### [zig-protobuf](https://github.com/Arwalk/zig-protobuf)

A protobuf 3 implementation for zig

```elm
nix run github:spotdemo4/trevpkgs#zig-protobuf
```

## Images

Docker container images

### nix ([nixos/nix](https://hub.docker.com/r/nixos/nix))

```sh
nix build github:spotdemo4/trevpkgs#images.x86_64-linux.nix &&
docker load -i result
```

### ffmpeg ([linuxserver/ffmpeg](https://hub.docker.com/r/linuxserver/ffmpeg))

```sh
nix build github:spotdemo4/trevpkgs#images.x86_64-linux.ffmpeg &&
docker load -i result
```

## Bundlers

A collection of [nix bundlers](https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-bundle)

### image

A better alternative to `github:NixOS/bundlers#toDockerImage` that also sets `org.opencontainers.image` labels according to the packages `meta` attributes

```elm
nix bundle --bundler github:spotdemo4/trevpkgs#image
```

### appimage

An alternative to [`ralismark/nix-appimage`](https://github.com/ralismark/nix-appimage) that uses bwrap to create compressed AppImages

```elm
nix bundle --bundler github:spotdemo4/trevpkgs#appimage
```

## Libs

### mkFlake

Utility function to simplify creating flakes.

- Imports nixpkgs and adds all the [overlays](#overlays)
- Inserts system attributes where necessary (like [flake-utils.lib.eachDefaultSystem](https://github.com/numtide/flake-utils))
- Creates cross-compiled sub-derivations for `packages`, `images` and `appimages`

```nix
outputs = { trev, ... }:
  trev.libs.mkFlake (
    system: pkgs: {
      packages.default = pkgs.rustPlatform.buildRustPackage (
        final: with pkgs.lib; {
          name = "rust-example";
          src = fileset.toSource {
            root = ./.;
            fileset = fileset.unions [
              ./Cargo.lock
              ./Cargo.toml
              (fileset.fileFilter (file: file.hasExt "rs") ./.)
            ];
          };
          cargoLock.lockFile = ./Cargo.lock;
        }
      );
    }
  );
```

To build `rust-example` into a statically linked binary:

```sh
nix build .#default.x86_64-unknown-linux-musl
```

To build `rust-example` into a different architecture:

```sh
nix build .#default.aarch64-unknown-linux-gnu
```

View all possible cross-compilation targets with:

```sh
nix flake show
```

### mkImage

Creates a `docker save`-formatted image for a given `src`. Other attributes will be passed to [`dockerTools.buildLayeredImage`](https://ryantm.github.io/nixpkgs/builders/images/dockertools/#ssec-pkgs-dockerTools-buildLayeredImage)

```nix
images.default = pkgs.mkImage {
  src = self.packages.${system}.default;
  contents = with pkgs; [ dockerTools.caCertificates ];
};
```

```sh
nix build .#images.x86_64-linux.default
docker load -i result
```

### mkAppImage

Creates an [AppImage](https://appimage.org/) for a given `src`. `squashfsArgs` can be used to modify the compression.

```nix
appimages.default = pkgs.mkAppImage {
  src = self.packages.${system}.default;
};
```

```sh
nix build .#appimages.x86_64-linux.default
```

### mkChecks

Utility function to simplify creating flake [checks](https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-flake-check.html). Can take either an `src` pointing to a derivation or a `root` pointing to a directory.

Directories can be filtered with `files`, `filter`, `ignore` and `include`. The order is:
`root`/`files` -> `filter` applied -> `ignore`'d file(s) removed -> `include` file(s) added

`filter`'s `file` attributes are inherited from [fileset.fileFilter](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.fileset.fileFilter)

```nix
checks = pkgs.lib.mkChecks {
  rust = {
    src = self.packages.${system}.default;
    packages = with pkgs; [
      rustfmt
      clippy
    ];
    script = ''
      cargo test --offline
      cargo fmt --check
      cargo clippy --offline -- -D warnings
    '';
  };

  tombi = {
    root = ./.;
    filter = file: file.hasExt "toml";
    packages = with pkgs; [
      tombi
    ];
    forEach = ''
      tombi format --offline --check "$file"
      tombi lint --offline --error-on-warnings "$file"
    '';
  };
};
```

### mkApps

Utility function to simplify creating flake [apps](https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-run.html)

```nix
apps = pkgs.mkApps {
  default = "cargo run";
  test = "cargo test";
};
```

```sh
nix run
nix run .#test
```

### bufFetchDeps & bufHook

Creates a fixed-output derivation for [buf](https://buf.build/) dependencies

```nix
pkgs.stdenv.mkDerivation (finalAttrs: {
  pname = "protobuf-pkg";
  version = "1.0.0";
  src = ./.;

  bufDeps = pkgs.bufFetchDeps {
    inherit (finalAttrs) pname version src;
    hash = "...";
  };

  nativeBuildInputs = with pkgs; [
    bufHook
  ];
});
```

### gleamFetchDeps, gleamErlangHook & gleamJavascriptHook

- Creates a fixed-output derivation for [gleam](https://gleam.run/) dependencies
- Builds with either erlang (`gleamErlangHook`) or Javascript (`gleamJavascriptHook`)

```nix
pkgs.stdenv.mkDerivation (finalAttrs: {
  pname = "gleam-pkg";
  version = "1.0.0";
  src = ./.;

  gleamDeps = pkgs.gleamFetchDeps {
    inherit (finalAttrs) pname version src;
    hash = "...";
  };

  nativeBuildInputs = with pkgs; [
    gleamErlangHook
  ];
});
```

## Overlays

- [packages](#packages)
- [images](#images)
- [libs](#libs)

```nix
import nixpkgs {
  overlays = [
    trev.overlays.packages
    trev.overlays.images
    trev.overlays.libs
  ];
}
```

### trev

An overlay that adds all of the overlays but with the prefix `trev` (e.g. `pkgs.trev.bobgen`)

```nix
import nixpkgs {
  overlays = [ trev.overlays.trev ];
}
```

## NixOS Modules

### Overlay

Adds the [trev](#trev) overlay to the nixosSystem's `pkgs`

```nix
nixosConfigurations = {
  laptop = nixpkgs.lib.nixosSystem {
    modules = [
      trev.nixosModules.overlay
      ({ pkgs, ... }: {
        environment.systemPackages = with pkgs; [
          trev.bobgen
        ];
      })
    ];
  };
};
```

## Examples

### Development flake

A flake for developing rust projects

```nix
{
  nixConfig = {
    extra-substituters = [
      "https://nix.trev.zip"
    ];
    extra-trusted-public-keys = [
      "trev:I39N/EsnHkvfmsbx8RUW+ia5dOzojTQNCTzKYij1chU="
    ];
  };

  inputs = {
    systems.url = "github:nix-systems/default";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    trevpkgs = {
      url = "github:spotdemo4/trevpkgs";
      inputs.systems.follows = "systems";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      trevpkgs,
      ...
    }:
    trevpkgs.libs.mkFlake (
      system: pkgs: {

        # nix develop [#...]
        devShells = {
          default = pkgs.mkShell {
            shellHook = pkgs.shellhook.ref;
            packages = with pkgs; [
              rustc
              cargo
            ];
          };
        };

        # nix run [#...]
        apps = pkgs.mkApps {
          default = "cargo run";
          test = "cargo test";
        };

        # nix build [#...]
        packages = {
          default = pkgs.rustPlatform.buildRustPackage (
            final: with pkgs.lib; {
              pname = "rust-template";
              version = "0.4.8";

              src = fileset.toSource {
                root = ./.;
                fileset = fileset.unions [
                  ./Cargo.lock
                  ./Cargo.toml
                  (fileset.fileFilter (file: file.hasExt "rs") ./.)
                ];
              };
              cargoLock.lockFile = ./Cargo.lock;
            }
          );
        };

        # nix build #images.[...]
        images = {
          default = pkgs.mkImage {
            src = self.packages.${system}.default;
          };
        };

        # nix flake check
        checks = pkgs.mkChecks {
          rust = {
            src = self.packages.${system}.default;
            packages = with pkgs; [
              rustfmt
              clippy
            ];
            script = ''
              cargo test --offline
              cargo fmt --check
              cargo clippy --offline -- -D warnings
            '';
          };

          tombi = {
            root = ./.;
            filter = file: file.hasExt "toml";
            packages = with pkgs; [
              tombi
            ];
            forEach = ''
              tombi format --offline --check "$file"
              tombi lint --offline --error-on-warnings "$file"
            '';
          };
        };
      }
    );
}
```

Templates for various languages can be found at [spotdemo4/templates](https://github.com/spotdemo4/templates)

### NixOS flake

A flake for NixOS utilizing the [Nix User Repository](https://github.com/nix-community/NUR)

```nix
{
  nixConfig = {
    extra-substituters = [
      "https://nix.trev.zip"
    ];
    extra-trusted-public-keys = [
      "trev:I39N/EsnHkvfmsbx8RUW+ia5dOzojTQNCTzKYij1chU="
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
    nixosConfigurations = {
      laptop = nixpkgs.lib.nixosSystem {
        modules = [
          nur.modules.nixos.default # Add the NUR overlay

          ({ pkgs, ... }: {
            environment.systemPackages = [pkgs.nur.repos.trev.bobgen]; # Use the NUR overlay
          })
        ];
      };
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
      "https://nix.trev.zip"
    ];
    extra-trusted-public-keys = [
      "trev:I39N/EsnHkvfmsbx8RUW+ia5dOzojTQNCTzKYij1chU="
    ];
  };
}
```

### Entire NixOS system

```nix
{
  nix.settings = {
    trusted-substituters = [
      "https://nix.trev.zip"
    ];
    trusted-public-keys = [
      "trev:I39N/EsnHkvfmsbx8RUW+ia5dOzojTQNCTzKYij1chU="
    ];
  };
}
```

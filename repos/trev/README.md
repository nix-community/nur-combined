# trev's nix repository

[![check](https://img.shields.io/github/actions/workflow/status/spotdemo4/trevpkgs/check.yaml?branch=main&logo=github&logoColor=%23bac2de&label=check&labelColor=%23313244)](https://github.com/spotdemo4/trevpkgs/actions/workflows/check.yaml)
[![vulnerable](https://img.shields.io/github/actions/workflow/status/spotdemo4/trevpkgs/vulnerable.yaml?branch=main&logo=github&logoColor=%23bac2de&label=vulnerable&labelColor=%23313244)](https://github.com/spotdemo4/trevpkgs/actions/workflows/vulnerable.yaml)
[![nix user repository](https://img.shields.io/github/actions/workflow/status/spotdemo4/trevpkgs/sync.yaml?branch=main&logo=github&logoColor=%23bac2de&label=sync&labelColor=%23313244)](https://github.com/spotdemo4/trevpkgs/actions/workflows/sync.yaml)

Extra [packages](#packages), [bundlers](#bundlers), [images](#images) and [libs](#libs) for [nix](https://nixos.org/)

## Packages

Packages are [cached](#cache) and kept up-to-date automatically. Available here or the [Nix User Repository](https://nur.nix-community.org/repos/trev/).

### [bumper](https://trev.zip/llc/bumper)

Version bumper for projects using git and semantic versioning

```elm
nix run github:spotdemo4/trevpkgs#bumper
```

### [burrito](https://github.com/burrito-elixir/burrito)

Wrap your application in a BEAM Burrito; used by [mkGleamBurrito](#mkgleamburrito)

```nix
nativeBuildInputs = with pkgs.beamPackages; [
  burrito
];
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

### [chrome-devtools-mcp](https://github.com/ChromeDevTools/chrome-devtools-mcp)

Chrome DevTools for coding agents

```elm
nix run github:spotdemo4/trevpkgs#chrome-devtools-mcp
```

### [cliproxyapi](https://github.com/router-for-me/CLIProxyAPI)

Proxy server providing OpenAI-compatible APIs for CLI models

```elm
nix run github:spotdemo4/trevpkgs#cliproxyapi
```

### [duckdb](https://github.com/duckdb/duckdb)

Embeddable SQL OLAP Database Management System

```elm
nix run github:spotdemo4/trevpkgs#duckdb
```

Extensions are built with nix rather than downloaded at runtime with `INSTALL`. The in-tree `autocomplete`, `icu`, `json`, `tpcds` and `tpch` extensions are enabled by default; out-of-tree extensions can be enabled with an override:

```nix
pkgs.trev.duckdb.override {
  withHttpfs = true;
  withPostgresScanner = true;
  withSpatial = true;
};
```

- out-of-tree: `withAvro`, `withAws`, `withAzure`, `withDucklake`, `withEncodings`, `withExcel`, `withFts`, `withHttpfs`, `withIceberg`, `withInet`, `withMysqlScanner`, `withOdbcScanner`, `withPostgresScanner`, `withQuack`, `withSpatial`, `withSqliteScanner`, `withSqlsmith`, `withVss`
- drivers: `withJdbc`, `withOdbc`

Out-of-tree extensions are built as loadable extensions against the default duckdb, so enabling them does not rebuild duckdb; the `duckdb` binary finds them through `DUCKDB_NIX_EXTENSION_DIRECTORIES`, which programs linking `libduckdb` can set to `duckdb.extensionDirectory`. `spatial`, `vss` and `odbc_scanner` are not autoloaded and need `LOAD`. Static builds (`pkgsStatic`) compile every extension into the binary, except `odbc_scanner` which is unsupported.

Out-of-tree extensions are pinned to the commits the duckdb release builds (`.github/config/extensions` in the duckdb source), with the patches it applies from `.github/patches/extensions`. `packages/duckdb/update.sh` updates duckdb and the extension pins together.

### [fetch-hash](https://github.com/spotdemo4/trevpkgs/blob/main/packages/fetch-hash)

Fetch the hashes of remote files

```elm
nix run github:spotdemo4/trevpkgs#fetch-hash
```

### [fix-hash](https://github.com/spotdemo4/nix-fix-hash)

Nix hash fixer

```elm
nix run github:spotdemo4/trevpkgs#fix-hash
```

### [flake-release](https://trev.zip/llc/flake-release)

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

### [helium](https://github.com/imputnet/helium-linux)

Private, fast, and honest web browser

```elm
nix run github:spotdemo4/trevpkgs#helium
```

### [igsc](https://github.com/intel/igsc)

Intel graphics system firmware update library

```elm
nix run github:spotdemo4/trevpkgs#igsc
```

### [kagimcp](https://github.com/kagisearch/kagimcp)

Model Context Protocol (MCP) server for Kagi Search

```elm
nix run github:spotdemo4/trevpkgs#kagimcp
```

### [kotlin-lsp](https://github.com/Kotlin/kotlin-lsp)

Kotlin Language Server

```elm
nix run github:spotdemo4/trevpkgs#kotlin-lsp
```

### [libvmaf-latest](https://github.com/Netflix/vmaf)

Perceptual video quality assessment based on multi-method fusion (VMAF); latest version

```nix
buildInputs = with pkgs.trev; [
  libvmaf-latest
];
```

### [libwtf](https://github.com/andrewmd5/libwtf)

C WebTransport over HTTP/3 library built on MsQuic

```nix
buildInputs = with pkgs.trev; [
  libwtf
];
```

### [modal](https://pypi.org/project/modal)

Provides convenient, on-demand access to serverless cloud compute from Python scripts on your local computer

```nix
buildInputs = with pkgs.python3Packages; [
  modal
];
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

### [paper-mono](https://github.com/paper-design/paper-mono)

Beautiful monospace font for design and code by Paper

```nix
fonts.packages = with pkgs.trev; [
  paper-mono
];
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

- patched with [renovate#45258](https://github.com/renovatebot/renovate/pull/45258) to support flake input updates
- patched to update the `rev` and `ref` attributes of flake inputs

```elm
nix run github:spotdemo4/trevpkgs#renovate
```

### [shellhook](https://trev.zip/llc/shellHook)

Shell hook for nix development shells

Displays info about the environment and creates a pre-push hook that runs `nix flake check`

```nix
devShells.x86_64-linux.default = pkgs.mkShell {
  shellHook = pkgs.shellhook.ref;
};
```

### [trev-mono](https://trev.zip/llc/trev-mono)

[Paper Mono](#paper-mono), patched for coding

```nix
fonts.packages = with pkgs.trev; [
  trev-mono
];
```

### [uv-build-latest](https://pypi.org/project/uv-build)

Build backend for uv; latest version

```nix
build-system = with pkgs.python3Packages; [
  setuptools
  uv-build-latest
];
```

### [xdg-desktop-portal-hyprland](https://github.com/hyprwm/xdg-desktop-portal-hyprland)

xdg-desktop-portal backend for Hyprland, with RemoteDesktop and Clipboard support

- built from [a fork](https://github.com/spotdemo4/xdg-desktop-portal-hyprland) with [xdg-desktop-portal-hyprland#428](https://github.com/hyprwm/xdg-desktop-portal-hyprland/pull/428), its keyboard fixes, and the Clipboard portal

```nix
programs.hyprland.portalPackage = pkgs.trev.xdg-desktop-portal-hyprland;
```

### [xdg-desktop-portal-luminous](https://github.com/waycrate/xdg-desktop-portal-luminous)

xdg-desktop-portal backend for wlroots based compositors, providing screenshot and screencast

```nix
xdg.portal.extraPortals = with pkgs.trev; [
  xdg-desktop-portal-luminous
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

### deno-\<system\>

Compiles a JavaScript package into a standalone binary for the given system with `deno compile`. Available for `x86_64-linux`, `aarch64-linux`, `x86_64-darwin`, `aarch64-darwin` and `x86_64-windows`

```elm
nix bundle --bundler github:spotdemo4/trevpkgs#deno-x86_64-linux
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

Linux builders also automatically attempt macOS cross-compilation using the Apple SDK packaged by nixpkgs:

```sh
nix build .#default.arm64-apple-darwin
```

Darwin cross-compilation is best-effort per package. Target binaries cannot run on the Linux builder, so builds and checks must inspect them without executing them. For target-specific package logic, use `pkgs.stdenv.hostPlatform`; the `system` callback argument remains the build system.

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

Utility function to simplify creating flake [checks](https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-flake-check.html). Can take an `src` pointing to a derivation, a `root` pointing to a directory, or neither for checks that do not need a source.

Directories can be filtered with `files`, `filter`, `ignore` and `include`. The order is:
`root`/`files` -> `filter` applied -> `ignore`'d file(s) removed -> `include` file(s) added

`filter`'s `file` attributes are inherited from [fileset.fileFilter](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.fileset.fileFilter)

```nix
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
```

### mkApps

Utility function to simplify creating flake [apps](https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-run.html).
Strings are shorthand for an app script. Structured entries accept `script`, optional `packages`, and optional
`inputsFrom`. Like `pkgs.mkShell`, `inputsFrom` collects and flattens each derivation's `buildInputs`,
`nativeBuildInputs`, `propagatedBuildInputs`, and `propagatedNativeBuildInputs` into the app's runtime `PATH`.

```nix
let
  devShell = pkgs.mkShell {
    packages = with pkgs; [
      go
      buf
    ];
  };
in
{
  devShells.default = devShell;

  apps = pkgs.mkApps {
    default = "go run .";
    configure = {
      inputsFrom = [ devShell ];
      script = "buf generate";
    };
  };
}
```

```sh
nix run
nix run .#configure
```

### mkRustPackage

Wraps [`rustPlatform.buildRustPackage`](https://nixos.org/manual/nixpkgs/stable/#compiling-rust-applications-with-cargo), building dependencies in a separate derivation (`cargoArtifacts`) from a stubbed copy of the workspace. Source changes and version bumps only rebuild the workspace crates. Dependencies are vendored from `Cargo.lock`, so `cargoHash` isn't needed. The check phase also runs in the dependency derivation, against the stubs, so the dependencies of custom check commands (e.g. `cargo clippy`) are built there too. `cargoArtifactsArgs` can be used to modify the dependency derivation, e.g. overriding `checkPhase` if it needs other source files.

```nix
pkgs.mkRustPackage (finalAttrs: {
  pname = "rust-pkg";
  version = "1.0.0";
  src = ./.;
});
```

### mkGoModule

Wraps [`buildGoModule`](https://nixos.org/manual/nixpkgs/stable/#sec-language-go), building the vendored dependencies in a separate derivation (`goCache`) and restoring its build cache. Source changes and version bumps only rebuild the main module's packages. The dependency derivation only uses `vendor/modules.txt` and the vendor directory, which is named without the version, so it only changes when the dependencies do. `vendorHash` is required and `proxyVendor` isn't supported. `goCacheArgs` can be used to modify the dependency derivation.

Dependencies of tests are cached for the build directory used on Linux, on Darwin they're rebuilt in the check phase.

Go names binaries after their package's directory, so when `meta.mainProgram` is set and a single binary is installed, it's renamed to `meta.mainProgram`.

```nix
pkgs.mkGoModule (finalAttrs: {
  pname = "go-pkg";
  version = "1.0.0";
  src = ./.;
  vendorHash = "sha256-...";
  meta.mainProgram = "go-pkg";
});
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

### mkGleamBurrito

Wraps a [gleam](https://gleam.run/) project into a single self-contained executable with [burrito](https://github.com/burrito-elixir/burrito). `src` can be a source directory or a gleam package built with `gleamFetchDeps` & `gleamErlangHook`. `target` (`linux`, `macos` or `windows`) and `targetCpu` (`x86_64` or `aarch64`) default to the host system.

```nix
pkgs.mkGleamBurrito {
  src = self.packages.${system}.default;
};
```

### denoCompile

Compiles a JavaScript package into a standalone binary with `deno compile`. The entrypoint defaults to `main` in `package.json`, then `build/index.js`. Permissions can be denied with `allow-read`, `allow-write`, `allow-net`, `allow-env` and `allow-run`.

```nix
pkgs.denoCompile {
  package = self.packages.${system}.default;
  target = "aarch64-apple-darwin";
  allow-run = false;
};
```

### getForgejoFlake

Fetches a flake from a [Forgejo](https://forgejo.org/) instance by `url`, `rev` and `hash`

```nix
(pkgs.getForgejoFlake {
  url = "https://trev.zip/llc/bumper";
  rev = "...";
  hash = "sha256-...";
}).packages.${system}.default
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

Python packages are added to every python package set (e.g. `pkgs.python3Packages.modal`), BEAM packages to `pkgs.beamPackages` and images to `pkgs.image`.

### trev

An overlay that adds all of the overlays but with the prefix `trev` (e.g. `pkgs.trev.bumper`). Also available as `trev.overlays.default`.

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
          trev.bumper
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
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    trevpkgs = {
      url = "github:spotdemo4/trevpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
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
            environment.systemPackages = [pkgs.nur.repos.trev.bumper]; # Use the NUR overlay
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
    extra-substituters = [
      "https://nix.trev.zip"
    ];
    extra-trusted-public-keys = [
      "trev:I39N/EsnHkvfmsbx8RUW+ia5dOzojTQNCTzKYij1chU="
    ];
  };
}
```

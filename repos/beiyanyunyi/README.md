# NUR-Repo

A personal [NUR](https://github.com/nix-community/NUR) package repository.

| Package | Source version | Platforms |
| --- | --- | --- |
| `rime-ice` | `99662ba01e3affa6a0f009174ca530b887bac3b6` | Same as nixpkgs rime-ice |
| `qingjian` | v0.3.3 | Linux |
| `patchelf-unstable` | 0.19.3-unstable-2026-10-30 | Same as nixpkgs patchelf |
| `portop` | v0.4.0 | Linux, Darwin |
| `mihomo-oix` | alpha-oix-83a0a17 | x86_64-linux (amd64-v3), aarch64-linux, aarch64-darwin |
| `codex-bin` | 0.167.1 | aarch64-darwin, x86_64-linux (musl binaries) |

The initial versions and hashes were migrated from nix-conf.

## Usage

```sh
nix build .#portop
nix run .#mihomo-oix -- -v
nix run .#codex-bin -- --version
# Linux
nix build .#qingjian
```

The traditional NUR entry point, `default.nix`, accepts the caller's `pkgs`:

```nix
let
  packages = import /path/to/NUR-Repo { inherit pkgs; };
in {
  environment.systemPackages = [ packages.portop packages.mihomo-oix ];
}
```

Use `overlays.default` (or `overlay.nix`) to expose the same package attributes in `pkgs`.
Use `overlays.rime-ice` to override only `rime-ice`:

```nix
nixpkgs.overlays = [ inputs.nur-repo.overlays.rime-ice ];
```

The default overlay reuses this overlay, which explicitly passes the previous scope's
`rime-ice` package to avoid resolving its own replacement through `callPackage`.

`mihomo-oix` provides `bin/mihomo`; the overlay does not replace nixpkgs' `mihomo` attribute.
`codex-bin` provides `bin/codex` and `bin/codex-code-mode-host`, shell completions,
and the package layout required by the daemon. The overlay leaves nixpkgs' `codex`
attribute unchanged. This package uses official release binaries; no `codex-src`
package is provided.
Flake `packages` outputs are filtered by platform.
`patchelf-unstable` includes the pinned LOAD segment fix from nix-conf (upstream PR #672); the overlay does not replace the standard `patchelf` package.

## Modules

- `nixosModules.qingjian`: enable `services.qingjian.enable` to install the Qingjian server, settings application, Fcitx5 addon, and product data, and start the user service. Override the package with `services.qingjian.package`.

## Package updates

Run the update scripts from any directory. They use Nix to provide their tools:

```sh
./pkgs/rime-ice/update.sh [ref]
./pkgs/portop/update.sh [tag]
./pkgs/patchelf-unstable/update.sh [ref]
./pkgs/mihomo-oix/update.sh [revision]
./pkgs/codex-bin/update.sh [tag]
```

`rime-ice` follows `main` by default, or accepts a branch, tag, or commit.
`portop` defaults to the latest stable GitHub release, or accepts a version tag
such as `v0.3.0`. It updates the version, resolved commit, source NAR hash, and
Go `vendorHash` together in `source.json`, using the repository's pinned nixpkgs
to compute the dependency hash. The GitHub CLI must be authenticated for release
discovery. `patchelf-unstable` follows `master` by default, or accepts a branch,
tag, or commit. It derives the unstable version from the source's `version` file
and commit date. These scripts replace `source.json` only after all prefetches
succeed.

`mihomo-oix` checks that all rolling-release assets have the same version before
updating its binary hash manifest.

`codex-bin` defaults to the latest stable GitHub release, or accepts a tag such
as `rust-v0.167.0`. It updates the version and hashes of both the CLI and
code-mode host for every supported platform together in `versions.json`, and
replaces the manifest only after all downloads succeed.

To update all five supported packages from this checkout:

```sh
nix develop
update-packages
# Or without entering an interactive shell:
nix develop --command update-packages
```

The development shell provides all required tools. `update-packages` calls the
root `update.sh`, which can also be run directly. It stops on the first failure;
updates completed before that failure remain in the working tree. Qingjian is
excluded because its source, Cargo lock files, and Git dependency hashes require
additional coordinated maintenance. Review the generated manifests and build the
affected packages after updating.

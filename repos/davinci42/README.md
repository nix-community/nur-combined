# NUR packages

Personal Nix packages and NixOS modules using the caller's `pkgs`.

| Package | NixOS module | Documentation |
| --- | --- | --- |
| `changedetection-io` | Use nixpkgs' module with this package | [changedetection.io](pkgs/changedetection-io/README.md) |
| `fluxdown-server` | `nixosModules.fluxdown` | [FluxDown Server](pkgs/fluxdown-server/README.md) |
| `spotify-spotx` | None | [Spotify with SpotX](pkgs/spotify-spotx/README.md) |

`default.nix` exports packages and module paths. This repository is not yet
registered in the public NUR index.

## Maintenance and tests

Run from the repository root with `<nixpkgs>` and `nix-command` enabled.
`nix-shell` supplies the tools; GitHub queries use authenticated `gh`.

```sh
nix-shell
just --list
just build changedetection-io
just update changedetection-io
just check changedetection-io
just update fluxdown-server
just contract fluxdown-server
just check fluxdown-server
just update-spotx
NIXPKGS_ALLOW_UNFREE=1 just check spotify-spotx
NIXPKGS_ALLOW_UNFREE=1 just check-all
NIXPKGS_ALLOW_UNFREE=1 just check-updates
NIXPKGS_ALLOW_UNFREE=1 just check-updates --update
just lint
```

`just update <package> [version]` refreshes hashes and validates in a temporary
copy before writing back. Review contract changes before accepting them with
`just update-reviewed <package> <version>`. SpotX uses `just update-spotx` instead.

`just check` builds, runs declared tests and lints. `just check-all` also runs
updater tests. Only the current platform is build-tested; VM tests are opt-in.
`just check-updates` only checks for updates; add `--update` to update and validate
locally. These commands do not deploy, commit or push.

## Automated updates

GitHub Actions checks all packages daily at 00:00 UTC (08:00 China time), or
manually through `workflow_dispatch`. Validated updates are proposed as PRs,
without auto-merging. Publishing requires a self-hosted runner and a token with
repository write and PR permissions.

Each `pkgs/<name>/maintenance.toml` declares update files, test commands and
optional contract commands. `[release]` monitors GitHub releases with required
assets (`assets = []` for source-only packages); `[snapshot]` monitors a branch.
See existing package metadata for examples.

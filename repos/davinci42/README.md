# NUR packages

Personal Nix packages and NixOS modules using the caller's `pkgs`.

| Package | NixOS module | Documentation |
| --- | --- | --- |
| `changedetection-io` | Use nixpkgs' module with this package | [changedetection.io](pkgs/changedetection-io/README.md) |
| `fluxdown-server` | `nixosModules.fluxdown` | [FluxDown Server](pkgs/fluxdown-server/README.md) |
| `rsshub` | Use nixpkgs' module with this package | [RSSHub](pkgs/rsshub/README.md) |
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
`just update-reviewed fluxdown-server <version>`. `just update-spotx` is an alias
for `just update spotify-spotx`; Spotify itself follows the caller's nixpkgs.

`just check` builds the package and its `passthru.tests`, then lints. `just check-all` also runs
updater tests. Only the current platform is build-tested; VM tests are opt-in.
`just check-updates` runs each package's update script in a temporary copy
with source and dependency downloads disabled. Add `--update` to update and
validate locally. These commands do not deploy, commit or push.

## Automated updates

GitHub Actions checks all packages daily at 00:00 UTC (08:00 China time), or
manually through `workflow_dispatch`. Validated updates are proposed as PRs,
without auto-merging. Publishing requires a self-hosted runner and a token with
repository write and PR permissions.

Packages declare `passthru.updateScript` and `passthru.tests`. Simple updates
use `nix-update-script`; FluxDown declares a complete custom script that calls
nix-update, refreshes both architecture hashes, verifies release checksums and
regenerates its reviewed contract. There are no implicit follow-up scripts.
Script paths, command arrays and `{ command, attrPath, supportedFeatures }`
objects are supported, with the standard `UPDATE_NIX_*` environment variables.

`nix-update -f . <package> --use-update-script` is supported through a small
adapter to nixpkgs' official update runner. This updates in place; use `just
update` for isolated validation and writeback. Plain nix-update does not select
the package's updateScript automatically. No command schedules itself.

The daily workflow supplies tokens to both gh and nix-update. A package failure
is reported without skipping later packages; the job fails after the summary.
For read-only detection, custom scripts honor `NUR_DETECT_VERSION=1`; this is
a repository extension, not part of the official updateScript protocol.

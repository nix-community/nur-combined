# Spotify with SpotX

`spotify-spotx` reuses the caller's `pkgs.spotify` and applies pinned
[SpotX-Bash](https://github.com/SpotX-Official/SpotX-Bash) patches during the build,
before the output becomes read-only. Supports `x86_64-linux` only; the app name
is still Spotify and the command is `spotify`. Allow unfree packages to install it.

## Options

Defaults follow SpotX-Bash. Use `.override { spotxFlags = [ ... ]; }` with
`--premium`, `--noexp`, `--devmode`, `--hide`, `--lyricsbg`, or `--oldui`.
Paid subscribers should use `--premium`. Installer, interactive, and path flags
are rejected. Upstream backups remain in the output; the SpotX license is
installed under `share/licenses/spotify-spotx/`.

## Updates

From the repository root:

```sh
nix-shell --run 'just update-spotx'
```

This runs `nix-update` on `spotify-spotx.spotx` with `--version=branch=main`,
`--src-only`, and an explicit upstream repository URL. It updates the commit,
snapshot date, and single-file hash in `spotx.nix`; Spotify still follows nixpkgs.
The date is updater metadata, not a SpotX release number.

The command downloads only `spotx.sh` and edits metadata in place; it does not
build Spotify or publish changes. It tracks all `main` commits, even those not
changing the script. Review upstream changes and the local license. Do not use
`just update spotify-spotx`, which would target Spotify rather than the script.

`maintenance.toml` sets a 168-hour check interval. The
[shared Actions workflow](../../README.md#automated-updates) updates in isolation,
runs `just check spotify-spotx`, and proposes only `spotx.nix` after validation.

## Validation

Evaluate without building:

```sh
NIXPKGS_ALLOW_UNFREE=1 nix-instantiate --eval --strict \
  --expr '(import ./tests/spotify-spotx.nix {}).name'
```

Build and validate:

```sh
NIXPKGS_ALLOW_UNFREE=1 nix-shell --run 'just check spotify-spotx'
```

Checks cover evaluation, archive integrity, patch marker, temporary extraction
cleanup, license contents, desktop integration, launcher version, and lint.
They do not verify authenticated playback or ad blocking.

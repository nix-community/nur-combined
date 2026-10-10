# Spotify with SpotX

Uses the caller's `pkgs.spotify` with pinned
[SpotX-Bash](https://github.com/SpotX-Official/SpotX-Bash) patches applied during
the build. Supports x86_64-linux; the command remains `spotify`.

## Usage

```sh
NIXPKGS_ALLOW_UNFREE=1 nix build -f . spotify-spotx
./result/bin/spotify
```

Use `.override { spotxFlags = [ ... ]; }` for `--premium`, `--noexp`, `--devmode`,
`--hide`, `--lyricsbg` or `--oldui`. Paid subscribers should use `--premium`.

## Maintenance and tests

```sh
nix-shell --run 'just update-spotx'
NIXPKGS_ALLOW_UNFREE=1 nix-shell --run 'just check spotify-spotx'
```

`update-spotx` updates the pinned script in place; Spotify follows nixpkgs.
Do not use `just update spotify-spotx`. All packages are checked daily or manually.

Tests cover packaging, patching, desktop integration and lint, not authenticated
playback or ad blocking.

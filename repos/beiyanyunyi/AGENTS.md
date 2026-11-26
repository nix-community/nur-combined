# Repository instructions

## Documentation

All repository documentation, including README.md and this file, must be written in English.

## Package maintenance

Source revisions and NAR hashes for `rime-ice`, `qingjian`, `portop`, and `patchelf-unstable` are stored in their respective `pkgs/<name>/source.json` files.
Update both the revision and hash when upgrading a package.
For portop, `version` and `vendorHash` are also stored in `source.json` and must be updated together.
Use `./pkgs/rime-ice/update.sh [ref]` (default: `main`) and
`./pkgs/portop/update.sh [tag]` (default: latest stable release) to update these packages.
For patchelf-unstable, `version` is also stored in `source.json`.
Use `./pkgs/patchelf-unstable/update.sh [ref]` (default: `master`) to update it.
Run `nix develop --command update-packages` to update all supported packages;
Qingjian is intentionally excluded.
Qingjian fetches its source with `pkgs.fetchgit`. Update `version`, the bundled `Cargo.lock`, `dicts.lock` and `models.lock`, and any changed Cargo Git dependency hashes together.
Check the model release manifests for changes to the archive parts.

mihomo-oix has a manifest of binary hashes for each platform and an update script:

```sh
./pkgs/mihomo-oix/update.sh [revision]
```

The script verifies that the rolling release has a consistent version across all platforms before updating `versions.json`.

codex-bin stores its release version and per-platform release archive hashes in
`pkgs/codex-bin/versions.json`. Use `./pkgs/codex-bin/update.sh [tag]` (default:
latest stable release) to update them together. Tags use the `rust-v<version>`
format. The script replaces the manifest only after every archive has been
downloaded successfully.

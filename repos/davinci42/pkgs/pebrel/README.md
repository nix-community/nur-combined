# pebrel

[Pebrel](https://github.com/Kuddev/pebrel) GPU-accelerated terminal and SSH
workspace, packaged from upstream release binaries. Supports `x86_64-linux` and
`aarch64-darwin`. Provides `pebrel` and `pebrel-hook`. Licensed under
GPL-3.0-or-later.

## Usage

```sh
nix build -f . pebrel
./result/bin/pebrel --help
./result/bin/pebrel config init
```

Linux installs the executables, desktop entry, icon, AppStream metadata and
shell completions, with `secret-tool` on `PATH` for optional Secret Service
credential storage. Darwin installs `Applications/Pebrel.app` with its bundled
ad-hoc signature intact and symlinks `pebrel` and `pebrel-hook` into `bin/`.

## Maintenance and tests

```sh
nix-shell --run 'just update pebrel'
nix-shell --run 'just check pebrel'
```

The package splits platform installation into `linux.nix` and `darwin.nix`.
`passthru.updateScript` uses `nix-update-script`, and the repository updater
refreshes both platform source hashes. Review upstream release assets,
`scripts/package-linux.sh`, `scripts/package-macos.sh`, dynamic library
dependencies and CLI arguments when updating.

Packaging checks verify metadata, Darwin derivation evaluation, CLI version and
help output, configuration template generation, shell completions, the
`pebrel-hook` bridge and platform installation layout without launching a GUI
session.

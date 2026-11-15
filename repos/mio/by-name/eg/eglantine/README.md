# Eglantine

Build with `nix build .#eglantine`, then run `./result/bin/eglantine`.

`upstream.nix` and `build-eden-emulator.nix` are adapted from the pinned upstream
`nix/` recipes. Local changes disable the host ccache requirement, use the
adjacent dependency manifest without import-from-derivation, and give git
snapshots conventional unstable versions. `cpmfile.json` is copied from that
same revision and must be kept in sync when updating the source.

In-app updates are disabled; update this package through Nix.

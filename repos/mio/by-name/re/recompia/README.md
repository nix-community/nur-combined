# Recompia

Build with `nix build .#recompia`, then run `./result/bin/recompia`.
The launcher, native runtime, and shader translator are built from pinned sources.
No game data is included. Setup requires your own extracted game matching the
version in upstream's `dump_hashes.json`.

The wrapper stages package files as symlinks under
`${XDG_DATA_HOME:-$HOME/.local/share}/recompia`, where the launcher can create its
game builds, shader caches, and saves. Python (with capstone and lz4) and Zig come
from Nix; the launcher does not need to download those tools. Update this package
through Nix. The launcher's in-app installer is disabled to preserve that build.
The optional external PokoHex save-editor extractor is not bundled.

`runtime-deps.json` records the archive URLs and SHA-256 hashes from
`runtime/cmake/gfx_deps.cmake`. `nuget-deps.json` records the shader translator's
NuGet dependencies; regenerate it when updating the pinned shader sources.

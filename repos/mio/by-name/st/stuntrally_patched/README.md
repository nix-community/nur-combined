# stuntrally_patched

Patched `stuntrally` package from Nixpkgs for the revision pinned by this flake.

## Build issue in the pinned Nixpkgs revision

With newer GCC releases, `mygui` (the GUI library bundled for stuntrally in Nixpkgs) and the game can select a C++ standard newer than the versions they support.

## Fix

Build both MyGUI and stuntrally as C++17 and require that standard. This mirrors the fix in [Nixpkgs commit 710de4985ce4](https://github.com/NixOS/nixpkgs/commit/710de4985ce44dd6cd338fbc1ec6885ded6ce1e2), which landed after this flake's pinned Nixpkgs revision.

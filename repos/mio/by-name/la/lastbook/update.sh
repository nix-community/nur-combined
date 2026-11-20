#!/usr/bin/env nix-shell
#! nix-shell -i bash -p curl nix-update
# shellcheck shell=bash

# Bumps lastbook and refreshes the setup manifest the package ships. The
# manifest lists the packs, state maps, address indexes and model setup can
# install; upstream writes it with packaging/release_manifest.py for each
# release and publishes it beside the downloads. upstream's release builds
# bundle that file, so this package does too, and it has to move with the
# version.
set -euo pipefail

# Run from a nurpkgs checkout, directly or through scripts/update-packages.sh.
# That runner executes the store copy of this file, which is not part of a
# flake or a git tree, so the checkout it edits is the one it runs in.
root=$(git rev-parse --show-toplevel)
cd "$root"

nix-update lastbook
curl -fsSL --retry 3 -o by-name/la/lastbook/manifest-v1.json https://downloads.lastbook.org/manifest-v1.json

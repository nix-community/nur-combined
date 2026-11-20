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

cd "$(dirname "${BASH_SOURCE[0]}")"

nix-update --flake lastbook
curl -fsSL --retry 3 -o manifest-v1.json https://downloads.lastbook.org/manifest-v1.json

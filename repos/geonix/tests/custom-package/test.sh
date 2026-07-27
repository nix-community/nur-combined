#!/usr/bin/env bash

set -euo pipefail

cp ../../overrides.nix overrides.nix
patch -u overrides.nix -i gdal.patch

"$(nix build --accept-flake-config --no-link --print-out-paths .#gdal)"/bin/gdalinfo --help \
    | grep "Usage (patched): gdalinfo"

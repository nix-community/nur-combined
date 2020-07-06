#!/usr/bin/env bash
set -euo pipefail

datapack="${1?install script should be called from nix}"
datapack_name="${2?install script should be called from nix}"

location="${3?install.sh <world location>}"

install_dir="$location/datapacks/$datapack_name"

if [ -e "$install_dir" ]; then
    rm -rf "$install_dir"
fi

cp -r "$datapack" "$install_dir"
chmod +w -R "$install_dir"

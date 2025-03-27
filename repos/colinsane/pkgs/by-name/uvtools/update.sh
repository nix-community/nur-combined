#!/usr/bin/env nix-shell
#!nix-shell -I nixpkgs=./. -i bash -p curl jq common-updater-scripts
#shellcheck shell=bash
#
# TAKEN FROM <repo:nixos/nixpkgs:pkgs/by-name/ma/marksman/update.sh>

set -eu -o pipefail

version=$(curl -s ${GITHUB_TOKEN:+-u ":$GITHUB_TOKEN"} \
    https://api.github.com/repos/sn4k3/UVtools/releases/latest | jq -e -r .tag_name)
old_version=$(nix-instantiate --eval -A uvtools.version | jq -e -r)

if [[ $version == "$old_version" ]]; then
    echo "New version same as old version, nothing to do." >&2
    exit 0
fi

update-source-version uvtools "${version/v/}"

$(nix-build -A uvtools.fetch-deps --no-out-link)

#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq common-updater-scripts

set -eu -o pipefail

version="$(curl 'https://data.services.jetbrains.com/products/releases?code=FL&latest=true&type=preview' | jq -r '.FL[0].build')"
update-source-version jetbrains-fleet "$version"

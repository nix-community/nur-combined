#!/usr/bin/env nix-shell
#! nix-shell -i bash -p python3 -p nix-prefetch-github

# Update GDAL master package to the latest master revision.
# Usage: update-master.sh

set -Eeuo pipefail

python ./update-master.py > master-rev.nix

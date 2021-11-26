#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-prefetch-github
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

nix-prefetch-github koverstreet bcachefs-tools --no-fetch-submodules > version.json

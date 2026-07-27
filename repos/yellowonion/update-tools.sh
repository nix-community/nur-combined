#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-prefetch-git
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

nix-prefetch-git https://github.com/koverstreet/bcachefs-tools.git > tools-version.json

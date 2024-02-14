#! /usr/bin/env nix-shell
#! nix-shell update-shell.nix -i bash

set -eou pipefail

ROOT="$(dirname "$(readlink -f "$0")")"
if [ ! -f "$ROOT/package.nix" ]; then
  echo "ERROR: cannot find package.nix in $ROOT"
  exit 1
fi

LOCK="$(nix-prefetch-github catppuccin discord)"
REV=$(jq .rev <<< "$LOCK")
HASH=$(jq .hash <<< "$LOCK")

sed -i "$ROOT/package.nix" \
  -e "s|rev = \".*\"|rev = $REV|" \
  -e "s|hash = \".*\"|hash = $HASH|" \

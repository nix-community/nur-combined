#!/usr/bin/env -S nix shell nixpkgs#nix-update -c bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
cd "$SCRIPT_DIR/.."

NIX_FILE="$SCRIPT_DIR/package.nix"

nix-update --use-github-releases _7zip-zstd

if git diff --quiet -- "$NIX_FILE"; then
  echo "No changes in $NIX_FILE after first nix-update; skipping second nix-update."
else
  nix-update --version=skip _7zip-zstd-rar
fi

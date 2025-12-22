#! /usr/bin/env nix
#! nix shell nixpkgs#nix-update -c bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
cd "$SCRIPT_DIR/.."

DAED_NIX_FILE="$SCRIPT_DIR/daed/default.nix"

nix-update --use-github-releases daed.web

if git diff --quiet -- "$DAED_NIX_FILE"; then
  echo "No changes in $DAED_NIX_FILE after first nix-update; skipping second nix-update."
else
  nix-update --version=skip daed
fi

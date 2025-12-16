#! /usr/bin/env nix
#! nix shell nixpkgs#nix-update -c bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
cd $SCRIPT_DIR/..

nix-update --use-github-releases daed.web
nix-update --version=skip daed

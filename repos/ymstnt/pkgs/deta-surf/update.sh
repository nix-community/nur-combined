#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-update

set -euo pipefail

nix-update deta-surf \
  --version=unstable \
  --subpackage cargoDepsBackend \
  --subpackage cargoDepsServer \
  "$@"

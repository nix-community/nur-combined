#!/usr/bin/env bash
set -euo pipefail
nixpkgs_path="$(nix-instantiate --find-file nixpkgs)"
nix-env -f . -qa '*' --meta --json \
  --allowed-uris https://static.rust-lang.org \
  --option restrict-eval true \
  --option allow-import-from-derivation true \
  --drv-path --show-trace \
  -I "nixpkgs=$nixpkgs_path" -I "$PWD"

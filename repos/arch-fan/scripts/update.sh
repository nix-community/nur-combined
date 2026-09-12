#!/usr/bin/env bash
# Runs in CI via `nix run .#update` from the repository root. Assumes a
# predictable environment: nix-update is on PATH (flake app runtimeInputs)
# and the working directory is the repo checkout.
set -euo pipefail

failed=0
for dir in pkgs/*/; do
  pkg="$(basename "$dir")"
  if [[ -f "$dir/no-auto-update" ]]; then
    echo "skipped: $pkg (see ${dir}no-auto-update)"
    continue
  fi
  nix-update --flake --build -u "$pkg" || { echo "failed: $pkg"; failed=1; }
done
exit "$failed"

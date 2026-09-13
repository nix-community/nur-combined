#!/usr/bin/env bash
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

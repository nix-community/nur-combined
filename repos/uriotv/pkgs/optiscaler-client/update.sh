#!/usr/bin/env bash
set -euo pipefail

pkg="optiscaler-client"
pkg_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$pkg_dir/../.." && pwd)"

cd "$repo_root"

nix-update \
  --flake "$pkg" \
  --src-only \
  --use-github-releases \
  --version-regex 'OptiscalerClient-(.*)'

fetch_deps_script="$(nix build ".#${pkg}.fetch-deps" --no-link --print-out-paths)"
"$fetch_deps_script" "$pkg_dir/deps.json"

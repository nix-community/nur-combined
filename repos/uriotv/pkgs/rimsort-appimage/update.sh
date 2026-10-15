#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

curl_args=(
  --fail
  --silent
  --show-error
  --location
  --header 'Accept: application/vnd.github+json'
)
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  curl_args+=(--header "Authorization: Bearer ${GITHUB_TOKEN}")
fi

releases="$(curl "${curl_args[@]}" \
  'https://api.github.com/repos/RimSort/RimSort/releases?per_page=100')"
version="$(printf '%s' "$releases" | python3 "$repo_root/pkgs/rimsort-appimage/latest-stable-version.py")"

echo "Updating RimSort to stable release ${version} with an available AppImage"
nix-update --flake --version="$version" rimsort-appimage

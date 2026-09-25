#!/usr/bin/env bash
# Checks can1357/oh-my-pi's latest GitHub release against pkgs/omp/default.nix
# and, if newer, rewrites `version` and the per-platform `hash` fields in
# place. Safe to run locally (e.g. `./scripts/update-omp.sh`) or from CI.
#
# Requires: curl, jq, nix (for `nix hash convert`), git.
set -euo pipefail

repo_root=$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)
pkg_file="$repo_root/pkgs/omp/default.nix"

declare -A assets=(
  [x86_64-linux]=omp-linux-x64
  [aarch64-linux]=omp-linux-arm64
  [x86_64-darwin]=omp-darwin-x64
  [aarch64-darwin]=omp-darwin-arm64
)

current=$(grep -m1 -oP '(?<=version = ")[^"]+' "$pkg_file")
latest_tag=$(curl -fsSL https://api.github.com/repos/can1357/oh-my-pi/releases/latest | jq -r .tag_name)
latest=${latest_tag#v}

echo "current version: $current" >&2
echo "latest version:  $latest" >&2

if [ "$current" = "$latest" ]; then
  echo "already up to date" >&2
  echo "changed=false" >>"${GITHUB_OUTPUT:-/dev/null}"
  exit 0
fi

sums=$(curl -fsSL "https://github.com/can1357/oh-my-pi/releases/download/${latest_tag}/SHA256SUMS.txt")

sed -i "0,/version = \"${current}\"/s//version = \"${latest}\"/" "$pkg_file"

for system in "${!assets[@]}"; do
  asset=${assets[$system]}
  hex=$(grep -E "  ${asset}\$" <<<"$sums" | awk '{print $1}')
  if [ -z "$hex" ]; then
    echo "::error::no digest for ${asset} in ${latest_tag}'s SHA256SUMS.txt" >&2
    exit 1
  fi
  sri=$(nix hash convert --hash-algo sha256 --to sri "$hex")

  block_line=$(grep -n "^    ${system} = {\$" "$pkg_file" | head -1 | cut -d: -f1)
  if [ -z "$block_line" ]; then
    echo "::error::could not find a '${system} = {' block in $pkg_file" >&2
    exit 1
  fi
  offset=$(tail -n "+${block_line}" "$pkg_file" | grep -n 'hash = "' | head -1 | cut -d: -f1)
  hash_line=$((block_line + offset - 1))
  sed -i "${hash_line}s#hash = \"[^\"]*\"#hash = \"${sri}\"#" "$pkg_file"
done

if command -v nixfmt >/dev/null 2>&1; then
  nixfmt "$pkg_file"
fi

echo "changed=true" >>"${GITHUB_OUTPUT:-/dev/null}"
echo "new_version=${latest}" >>"${GITHUB_OUTPUT:-/dev/null}"
echo "updated to ${latest}" >&2

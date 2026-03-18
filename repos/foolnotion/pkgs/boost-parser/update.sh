#!/usr/bin/env nix-shell
#!nix-shell -i bash -p coreutils git gnused nix-update nix

set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

requested_version="${1:-}"

if [[ -n "$requested_version" ]]; then
  latest_version="$requested_version"
else
  latest_tag="$(${GIT:-git} ls-remote --refs --sort='version:refname' --tags https://github.com/boostorg/boost.git 'boost-*.*.*' | tail -n1 | cut -d/ -f3)"
  latest_version="${latest_tag#boost-}"
fi

current_version="$(sed -n 's/^  version = "\([0-9.]*\)";/\1/p' pkgs/boost-parser/default.nix | head -n1)"

if [[ "$current_version" == "$latest_version" ]]; then
  echo "Boost cluster already at ${latest_version}"
  exit 0
fi

declare -a packages=(
  "boost-config:pkgs/boost-config/default.nix"
  "boost-core:pkgs/boost-core/default.nix"
  "boost-assert:pkgs/boost-assert/default.nix"
  "boost-container-hash:pkgs/boost-container-hash/default.nix"
  "boost-throw-exception:pkgs/boost-throw-exception/default.nix"
  "boost-type-index:pkgs/boost-type-index/default.nix"
  "boost-hana:pkgs/boost-hana/default.nix"
  "boost-parser:pkgs/boost-parser/default.nix"
)

for package in "${packages[@]}"; do
  IFS=":" read -r attr file <<< "$package"
  nix-update --flake --version="$latest_version" --override-filename "$file" "$attr"
done

echo "Updated Boost cluster to ${latest_version}"
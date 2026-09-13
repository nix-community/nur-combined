#!/usr/bin/env nix-shell
#!nix-shell -i bash -p git nix nix-update gnused gawk coreutils
# shellcheck shell=bash

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
package=redrix-ec
path="pkgs/$package/default.nix"

backup=$(mktemp)
cp "$path" "$backup"
cleanup() {
  status=$?
  if (( status != 0 )); then
    cp "$backup" "$path"
    echo "Update failed; restored the original EC source and version." >&2
  fi
  rm -f "$backup"
  exit "$status"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

nix-update --flake --version=branch=my --src-only "$package"
revision=$(nix eval --raw ".#$package.src.rev")
version=$(bash tasks/firmware-version.sh "$package" "$revision")
sed -i -E "s/^  version = \"[^\"]+\";/  version = \"$version\";/" "$path"
echo "Updated $package to $version"

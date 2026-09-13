#!/usr/bin/env nix-shell
#!nix-shell -i bash -p git nix nix-update gnused coreutils
# shellcheck shell=bash

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
package=redrix-coreboot
path="pkgs/$package/default.nix"

# Keep the source and payload pins together, including when fetching fails.
backup=$(mktemp)
cp "$path" "$backup"
cleanup() {
  status=$?
  if (( status != 0 )); then
    cp "$backup" "$path"
    echo "Update failed; restored the original coreboot and EDK2 pins." >&2
  fi
  rm -f "$backup"
  exit "$status"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

nix-update --flake --version=branch=my --src-only "$package"
source=$(nix build --no-link --print-out-paths ".#$package.src")

# Redrix normally inherits MrChromebox's default. Honor an explicit board pin
# as well; read the immutable source selected above, never a moving branch.
tag=$(sed -nE 's/^CONFIG_EDK2_TAG_OR_REV="([^"]+)"$/\1/p' \
  "$source/configs/adl/config.redrix.uefi")
if [[ -z "$tag" ]]; then
  tag=$(sed -nE '/^config EDK2_TAG_OR_REV$/,/^config /{
    s/^[[:space:]]*default "([^"]+)" if EDK2_REPO_MRCHROMEBOX$/\1/p
  }' "$source/payloads/external/edk2/Kconfig")
fi

# This fetcher tracks release tags. Stop for review if upstream changes to a
# branch or a Kconfig expression instead of silently selecting another release.
if [[ ! "$tag" =~ ^[[:alnum:]][[:alnum:]._-]*$ ]]; then
  echo "Cannot determine a single EDK2 release tag from coreboot: $tag" >&2
  exit 1
fi

old_tag=$(nix eval --raw ".#$package.edk2.tag")
if [[ "$tag" != "$old_tag" ]]; then
  sed -i -E "/edk2 = fetchFromGitHub/,/^  };/s/tag = \"[^\"]+\";/tag = \"$tag\";/" "$path"
  nix-update --flake --version=skip --no-src --custom-dep edk2 "$package"
  echo "Updated EDK2: $old_tag -> $tag"
else
  echo "EDK2 is up to date at $tag"
fi

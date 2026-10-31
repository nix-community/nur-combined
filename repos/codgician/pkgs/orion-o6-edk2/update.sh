#!/usr/bin/env nix-shell
#!nix-shell -i bash -p git nix nurl gnused coreutils
# shellcheck shell=bash
# Move the edk2 and edk2-platforms pins to the tips of codgician's sky1 branches.

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
path=pkgs/orion-o6-edk2/default.nix
# Keep both pins and the build date together, including when a step fails.
backup=$(mktemp)
cp "$path" "$backup"
work=$(mktemp -d)
cleanup() {
  status=$?
  if ((status != 0)); then
    cp "$backup" "$path"
    echo "Update failed; restored the original edk2 and edk2-platforms pins." >&2
  fi
  rm -rf "$backup" "$work"
  exit "$status"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

newest=0
pin() {
  local attr=$1 repo=$2 submodules=$3 rev hash time
  rev=$(git ls-remote "https://github.com/codgician/$repo" refs/heads/sky1 | cut -f1)
  [[ "$rev" =~ ^[0-9a-f]{40}$ ]]
  hash=$(nurl --submodules="$submodules" --hash "https://github.com/codgician/$repo" "$rev")
  git init --bare -q "$work/$repo"
  git -C "$work/$repo" fetch --quiet --depth=1 --filter=tree:0 "https://github.com/codgician/$repo" "$rev"
  time=$(git -C "$work/$repo" show -s --format=%ct FETCH_HEAD)
  ((time > newest)) && newest=$time
  sed -i -E "/^  $attr = fetchFromGitHub \{/,/^  \};/{
    s|^    rev = \"[^\"]+\";|    rev = \"$rev\";|
    s|^    hash = [^;]+;|    hash = \"$hash\";|
  }" "$path"
}

pin edk2 edk2 true
pin edk2Platforms edk2-platforms false

# The newest pinned commit dates the build (SMBIOS date, PrePi __DATE__).
sed -i -E "s|^  env.SOURCE_DATE_EPOCH = \"[0-9]+\";|  env.SOURCE_DATE_EPOCH = \"$newest\";|" "$path"
sed -i -E "s|^  version = \"([0-9.]+)-unstable-[0-9-]+\";|  version = \"\\1-unstable-$(date -u -d "@$newest" +%F)\";|" "$path"
echo "Updated orion-o6-edk2 to $(sed -nE 's/^  version = "([^"]+)";/\1/p' "$path")"

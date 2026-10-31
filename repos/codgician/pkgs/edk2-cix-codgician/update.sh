#!/usr/bin/env nix-shell
#!nix-shell -i bash -p git nix nurl gnused coreutils
# shellcheck shell=bash
# Follow the tip of codgician/edk2-cix's sky1 branch: pin it, the firmware-tree
# revisions its submodules record, and the Debian version it releases.

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
path=pkgs/edk2-cix-codgician/default.nix
fork=https://github.com/codgician/edk2-cix
# Keep every pin and the build date together, including when a step fails.
backup=$(mktemp)
cp "$path" "$backup"
work=$(mktemp -d)
cleanup() {
  status=$?
  if ((status != 0)); then
    cp "$backup" "$path"
    echo "Update failed; restored the original pins." >&2
  fi
  rm -rf "$backup" "$work"
  exit "$status"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# Point the fetchFromGitHub block of attribute $1 at github.com/$2 revision $3.
set_pin() {
  local attr=$1 slug=$2 rev=$3 submodules=$4 hash
  hash=$(nurl --submodules="$submodules" --hash "https://github.com/$slug" "$rev")
  sed -i -E "/^  $attr = fetchFromGitHub \{/,/^  \};/{
    s|^    owner = \"[^\"]+\";|    owner = \"${slug%%/*}\";|
    s|^    repo = \"[^\"]+\";|    repo = \"${slug#*/}\";|
    s|^    rev = \"[^\"]+\";|    rev = \"$rev\";|
    s|^    hash = [^;]+;|    hash = \"$hash\";|
  }" "$path"
}

rev=$(git ls-remote "$fork" refs/heads/sky1 | cut -f1)
[[ "$rev" =~ ^[0-9a-f]{40}$ ]]
git init --bare -q "$work/edk2-cix"
git -C "$work/edk2-cix" fetch --quiet --depth=1 "$fork" "$rev"
git -C "$work/edk2-cix" show FETCH_HEAD:.gitmodules > "$work/gitmodules"
set_pin src codgician/edk2-cix "$rev" false

# The Debian version Radxa's changelog releases prefixes the package version.
deb_version=$(git -C "$work/edk2-cix" show FETCH_HEAD:debian/changelog | sed -nE '1s/^[^ ]+ \(([^)]+)\).*/\1/p')
[[ "$deb_version" =~ ^[0-9][0-9A-Za-z.+~]*$ ]]

newest=0
pin_tree() {
  local attr=$1 tree=$2 submodules=$3 rev url slug time
  rev=$(git -C "$work/edk2-cix" rev-parse "FETCH_HEAD:src/$tree")
  [[ "$rev" =~ ^[0-9a-f]{40}$ ]]
  url=$(git config -f "$work/gitmodules" "submodule.src/$tree.url")
  slug=${url#https://github.com/}
  slug=${slug%.git}
  [[ "$slug" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]]
  set_pin "$attr" "$slug" "$rev" "$submodules"
  git init --bare -q "$work/$tree"
  git -C "$work/$tree" fetch --quiet --depth=1 --filter=tree:0 "https://github.com/$slug" "$rev"
  time=$(git -C "$work/$tree" show -s --format=%ct FETCH_HEAD)
  if ((time > newest)); then
    newest=$time
  fi
}

pin_tree edk2 edk2 true
pin_tree edk2Platforms edk2-platforms false
pin_tree edk2NonOsi edk2-non-osi false

# The newest firmware-tree commit dates the build (SMBIOS date, PrePi
# __DATE__); a change to the build glue alone does not.
sed -i -E "s|^  env.SOURCE_DATE_EPOCH = \"[0-9]+\";|  env.SOURCE_DATE_EPOCH = \"$newest\";|" "$path"
sed -i -E "s|^  version = \"[^\"]+\";|  version = \"$deb_version-unstable-$(date -u -d "@$newest" +%F)\";|" "$path"
echo "Updated edk2-cix-codgician to $(sed -nE 's/^  version = "([^"]+)";/\1/p' "$path")"

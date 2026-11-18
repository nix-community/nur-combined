#!/usr/bin/env bash
# Bump qingjian. nix-update alone is not enough: the product data tarball is
# pinned separately by upstream's tools/release/data.lock.
# Usage: ./update.sh [--commit]
set -euo pipefail

root="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$root"
nix_file=pkgs/qingjian/default.nix

old_version="$(sed -n 's/^  version = "\(.*\)";$/\1/p' "$nix_file")"
# data-vN releases share the repo; only follow app tags.
nix-shell -p nix-update --run "nix-update qingjian --version-regex 'v(\d+\.\d+\.\d+)$'"
new_version="$(sed -n 's/^  version = "\(.*\)";$/\1/p' "$nix_file")"

if [ "$new_version" = "$old_version" ]; then
  echo "qingjian is up to date: $old_version"
  exit 0
fi

lock="$(curl -fsSL "https://raw.githubusercontent.com/qingjian-team/qingjian/v${new_version}/tools/release/data.lock")"
tag="$(sed -nE 's/^tag *= *//p' <<<"$lock" | tr -d '[:space:]')"
hex="$(sed -nE 's/^qingjian-data\.tar\.gz *= *//p' <<<"$lock" | tr -d '[:space:]')"
if ! [[ "$tag" =~ ^data-v[0-9]+$ && "$hex" =~ ^[0-9a-f]{64}$ ]]; then
  echo "error: unexpected data.lock at v${new_version}: tag='$tag' hash='$hex'" >&2
  exit 1
fi
sri="$(nix --extra-experimental-features nix-command hash convert --hash-algo sha256 --to sri "$hex")"
sed -i.bak \
  -e 's|^  dataTag = ".*";|  dataTag = "'"$tag"'";|' \
  -e 's|^  dataHash = ".*";|  dataHash = "'"$sri"'";|' \
  "$nix_file"
rm -f "$nix_file.bak"

subject="qingjian: $old_version -> $new_version"
echo "$subject"
if [ "${1:-}" = "--commit" ]; then
  git commit -m "$subject" -- "$nix_file"
fi

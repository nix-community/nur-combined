#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash curl jq gnugrep gnused nix nix-update
# shellcheck shell=bash
#
# Usage: update.sh releases/<year>/<minor>
#
# ollama_openvino has no usable tags and must match the OpenVINO GenAI C API
# in nixpkgs, so package.nix passes the openvino_contrib release branch for
# nixpkgs' openvino version and this tracks the head of that branch.
#
# Run from the NixOS/ directory (scripts/nix-update.sh does this): nix-update
# evaluates the package set in NixOS/default.nix, and the script itself is
# copied into the Nix store, so package.nix can't be found relative to "$0".

set -euo pipefail

pkg="pkgs/by-name/ollama-openvino/package.nix"
if ! [ -e "$pkg" ]; then
  echo "Unable to find $pkg; run this from the NixOS/ directory" >&2
  exit 1
fi

branch="${1:?usage: $0 releases/<year>/<minor>}"
prefix="$(tr / . <<<"${branch#releases/}")"

declare -a curlArgs=(--fail --silent --show-error --location)
token="${GITHUB_TOKEN:-${GH_TOKEN:-}}"
if [ -n "$token" ]; then
  curlArgs+=(--header "Authorization: Bearer $token")
fi

read -r new_rev date < <(
  curl "${curlArgs[@]}" "https://api.github.com/repos/openvinotoolkit/openvino_contrib/commits/$branch" |
    jq -r '"\(.sha) \(.commit.committer.date[:10])"'
)
new_vsn="$prefix-unstable-$date"

old_rev="$(grep --only-matching --perl-regexp '^    rev = "\K[^"]+' "$pkg")"
old_vsn="$(grep --only-matching --perl-regexp '^  version = "\K[^"]+' "$pkg")"

if [ "$old_rev" = "$new_rev" ]; then
  echo "ollama-openvino is already at $old_vsn ($branch), skipping"
  exit 0
fi

echo "ollama-openvino: $old_vsn -> $new_vsn"

sed -i \
  -e 's|^  version = "[^"]*";|  version = "'"$new_vsn"'";|' \
  -e 's|^    rev = "[^"]*";.*|    rev = "'"$new_rev"'"; # '"$branch"'|' \
  "$pkg"

# Refresh the src hash and vendorHash for the new rev.
nix-update ollama-openvino --version=skip

#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash curl jq gnugrep gnused nix
# shellcheck shell=bash
#
# Run from the NixOS/ directory (scripts/nix-update.sh does this). The script
# itself is copied into the Nix store, so package.nix can't be found relative
# to "$0".

set -euo pipefail

pkg="pkgs/by-name/docker-sbx/package.nix"
if ! [ -e "$pkg" ]; then
  echo "Unable to find $pkg; run this from the NixOS/ directory" >&2
  exit 1
fi

old_vsn="$(grep --only-matching --perl-regexp 'version = "\K[^"]+' "$pkg")"

# Unauthenticated requests are fine for one call; use a token if one is set.
declare -a curlArgs=(--fail --silent --show-error --location)
token="${GITHUB_TOKEN:-${GH_TOKEN:-}}"
if [ -n "$token" ]; then
  curlArgs+=(--header "Authorization: Bearer $token")
fi

new_vsn="$(curl "${curlArgs[@]}" https://api.github.com/repos/docker/sbx-releases/releases | \
  jq -r '.[0].tag_name' | \
  grep --only-matching --perl-regexp '\d+\.\d+\.\d+(-rc\d+)?')"

if [ "$old_vsn" = "$new_vsn" ]; then
  echo "No new version available, skipping"
  exit 0
fi

echo "docker-sbx: $old_vsn -> $new_vsn"

fetch_arch () {
  local vsn="$1" plat="$2" url hash
  url="https://github.com/docker/sbx-releases/releases/download/v${vsn}/DockerSandboxes-${plat}.tar.gz"
  hash="$(nix-prefetch-url --type sha256 "$url")";
  nix-hash --to-sri --type sha256 "$hash"
}

declare -A hashes
declare -A platNames=(
  ["linux-amd64"]="x86_64-linux"
  ["linux-arm64"]="aarch64-linux"
  ["darwin"]="aarch64-darwin"
)
declare -a platforms=(
  "linux-amd64"
  "linux-arm64"
  "darwin"
)

for plat in "${platforms[@]}"; do
  hashes[$plat]="$(fetch_arch "$new_vsn" "$plat")"
done

declare -a sedArgs=(
  -e 's:version = "'"$old_vsn"'":version = "'"$new_vsn"'":'
)

for plat in "${platforms[@]}"; do
  p="${platNames[$plat]}"
  sedArgs+=(
    -e '0,/"'"$p"'" = / s:"'"$p"'" = .*;:"'"$p"'" = "'"${hashes[$plat]}"'";:'
  )
done
sed -i "${sedArgs[@]}" "$pkg"

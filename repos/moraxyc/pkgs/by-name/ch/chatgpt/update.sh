#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl gzip libxml2
# shellcheck shell=bash

set -o errexit
set -o nounset
set -o pipefail

BASE_URL="https://persistent.oaistatic.com/codex-app-prod"
DARWIN_APPCAST_URL="$BASE_URL/appcast.xml"
LINUX_REPOSITORY_URL="$BASE_URL/linux/deb"

get_field() {
  local field="$1"
  local metadata="$2"

  sed -n "s/^$field: //p" <<< "$metadata" | head -n 1
}

fetch_linux_metadata() {
  local architecture="$1"

  curl --fail --location --silent --show-error \
    "$LINUX_REPOSITORY_URL/dists/stable/main/binary-$architecture/Packages.gz" \
    | gzip --decompress --stdout
}

DARWIN_XML=$(curl --fail --location --silent --show-error "$DARWIN_APPCAST_URL")
DARWIN_VERSION=$(xmllint --xpath '/rss/channel/item[1]/*[local-name()="shortVersionString"]/text()' - <<< "$DARWIN_XML")
DARWIN_URL=$(xmllint --xpath 'string(//item[1]/enclosure/@url)' - <<< "$DARWIN_XML")
DARWIN_NIX32_HASH=$(nix-prefetch-url "$DARWIN_URL")
DARWIN_HASH=$(nix --extra-experimental-features nix-command hash convert \
  --hash-algo sha256 --from nix32 "$DARWIN_NIX32_HASH")

AMD64_METADATA=$(fetch_linux_metadata amd64)
ARM64_METADATA=$(fetch_linux_metadata arm64)

[[ $(get_field Package "$AMD64_METADATA") == chatgpt ]]
[[ $(get_field Architecture "$AMD64_METADATA") == amd64 ]]
[[ $(get_field Package "$ARM64_METADATA") == chatgpt ]]
[[ $(get_field Architecture "$ARM64_METADATA") == arm64 ]]

AMD64_VERSION=$(get_field Version "$AMD64_METADATA")
AMD64_FILENAME=$(get_field Filename "$AMD64_METADATA")
AMD64_SHA256=$(get_field SHA256 "$AMD64_METADATA")
AMD64_HASH=$(nix --extra-experimental-features nix-command hash convert \
  --hash-algo sha256 --from base16 "$AMD64_SHA256")

ARM64_VERSION=$(get_field Version "$ARM64_METADATA")
ARM64_FILENAME=$(get_field Filename "$ARM64_METADATA")
ARM64_SHA256=$(get_field SHA256 "$ARM64_METADATA")
ARM64_HASH=$(nix --extra-experimental-features nix-command hash convert \
  --hash-algo sha256 --from base16 "$ARM64_SHA256")

SOURCE_NIX=${SOURCE_NIX:-"$(dirname "${BASH_SOURCE[0]}")/source.nix"}

cat > "$SOURCE_NIX" << _EOF_
{
  aarch64-darwin = {
    version = "$DARWIN_VERSION";
    src = {
      url = "$DARWIN_URL";
      hash = "$DARWIN_HASH";
    };
  };
  aarch64-linux = {
    version = "$ARM64_VERSION";
    src = {
      url = "$LINUX_REPOSITORY_URL/$ARM64_FILENAME";
      hash = "$ARM64_HASH";
    };
  };
  x86_64-linux = {
    version = "$AMD64_VERSION";
    src = {
      url = "$LINUX_REPOSITORY_URL/$AMD64_FILENAME";
      hash = "$AMD64_HASH";
    };
  };
}
_EOF_

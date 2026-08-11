#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq
#shellcheck shell=bash

set -eu -o pipefail

update() {
  local info_url="https://yuanbao.tencent.com/api/info/public/general"
  source_url=$(curl -s "$info_url" | jq -r '.pcDownloadUrl.mac')

  local version
  version=$(echo "$source_url" | sed -E -n 's/.*yuanbao_([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+).*/\1/p')

  local dlhash
  dlhash=$(echo "$source_url" | sed -n 's#.*/\([^/]\{32\}\)/.*#\1#p')

  local hash
  hash=$(nix --extra-experimental-features nix-command hash convert --to sri --hash-algo sha256 "$(nix-prefetch-url --type sha256 "$source_url")")

  local path
  path=`realpath $(dirname $0)`

  if [ -f "${path}/default.nix" ]; then
    #   version = "2.36.0.624";
    # source = {
    #   url = "https://cdn-hybrid-prod.hunyuan.tencent.com/Desktop/official/90a3aed2a9526055a607eaddf1e59a7a/yuanbao_2.36.0.624_universal.dmg";
    #   hash = "sha256-UAeuOPzu+90YSLAjUoDM0R4o6uqEvrInnIEG8aXkjVk=";
    #  };

    sed -i "s|version = \".*\";|version = \"$version\";|" "${path}/default.nix"
    sed -i "s|url = \".*\";|url = \"$source_url\";|" "${path}/default.nix"
    sed -i "s|hash = \".*\";|hash = \"$hash\";|" "${path}/default.nix"
  fi
}

update
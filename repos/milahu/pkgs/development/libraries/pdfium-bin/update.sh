#!/usr/bin/env bash

set -eu

cd "$(dirname "$0")"

owner=bblanchon
repo=pdfium-binaries

#pdfium_v8=false

ignore_urls=(
  -android-arm.tgz
  -android-arm64.tgz
  -android-x64.tgz
  -android-x86.tgz
  -ios-arm64.tgz
  -ios-x64.tgz
  #-linux-arm.tgz
  #-linux-arm64.tgz
  -linux-musl-x64.tgz
  -linux-musl-x86.tgz
  #-linux-x64.tgz
  #-linux-x86.tgz
  #-mac-arm64.tgz
  #-mac-univ.tgz
  #-mac-x64.tgz
  -win-arm64.tgz
  -win-x64.tgz
  -win-x86.tgz
)

# release url: https://github.com/bblanchon/pdfium-binaries/releases/latest
release_url="https://github.com/$owner/$repo/releases/latest"

echo "release url: $release_url"


release_html="$(curl -s -L "$release_url")"

# debug
echo writing release.html
echo "$release_html" >release.html

# assets url: https://github.com/bblanchon/pdfium-binaries/releases/expanded_assets/chromium/5961
assets_url=$(
  echo "$release_html" |
  grep "https://github.com/$owner/$repo/releases/expanded_assets/" |
  sed -E 's|^.*src="(https://github\.com/'"$owner/$repo"'/releases/expanded_assets/[^"]+)".*$|\1|'
)

echo "assets url: $assets_url"

version=$(basename "$assets_url")
echo "version: $version"

assets_html="$(curl -s -L "$assets_url")"

# debug
echo writing release-assets.html
echo "$assets_html" >release-assets.html

asset_url_list=($(
  echo "$assets_html" |
  grep 'href="/bblanchon/pdfium-binaries/releases/download/' |
  sed -E 's|^.*href="(/'"$owner/$repo"'/releases/download/[^"]+)".*$|\1|' |
  sed 's|^/|https://github.com/|'
))

sources_json='{ "version": "", "sources": {} }'

sources_json="$(echo "$sources_json" | jq -c '.version=$version' --arg version "$version")"

for url in "${asset_url_list[@]}"; do

  if false; then
  if $pdfium_v8; then
    # keep only pdfium-v8 urls
    if ! echo "$url" | grep -q "/pdfium-v8-"; then
      continue
    fi
  else
    # remove all pdfium-v8 urls
    if echo "$url" | grep -q "/pdfium-v8-"; then
      continue
    fi
  fi
  fi

  ignore_this_url=false
  for ignore in "${ignore_urls[@]}"; do
    if echo "$url" | grep -q -F -- "$ignore"; then
      ignore_this_url=true
      break
    fi
  done
  $ignore_this_url && continue

  echo "asset url: $url"
  hash=sha256-$(sha256sum <(curl -sL "$url") | cut -c 1-64 | xxd -r -p | base64)
  asset_json="$(echo '{}' | jq -c '.url=$url | .hash=$hash' --arg url "$url" --arg hash "$hash")"
  echo "asset json: $asset_json"
  name=$(basename "$url")
  sources_json="$(echo "$sources_json" | jq -c '.sources[$name]=$asset' --arg name "$name" --argjson asset "$asset_json")"
done

echo writing sources.json
echo "$sources_json" | jq >sources.json

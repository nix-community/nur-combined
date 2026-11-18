#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash -p curl -p jq -p nix
# shellcheck shell=bash
set -euo pipefail

CONFIG_JSON='https://qq-web.cdn-go.cn/im.qq.com_new/latest/rainbow/pcConfig.json'
SIGN_ENDPOINT='https://im.qq.com/http2rpc/gotrpc/noauth/trpc.qqntv2.urlsign.UrlSign/GetSign'

DIR="$(dirname "$(readlink -f "$0")")"

sign() {
  curl -fsS --retry 3 -X POST "$SIGN_ENDPOINT" \
    -H "Content-Type: application/json" \
    -H 'x-oidb: {"uint32_command":"0x9b8e","uint32_service_type":1}' \
    -d "{\"url\":\"$1\"}" | jq -er '.data.url'
}

update_one() {
  local key=$1 url=$2 name version current hash
  name=$(basename "$url")
  version=${name%.deb}
  current=$(jq -r --arg k "$key" '.[$k].version' "$DIR/sources.json")
  if [ "$current" = "$version" ]; then
    echo "$key: already at $version"
    return
  fi
  hash=$(nix store prefetch-file --json "$(sign "$url")" | jq -er '.hash')
  jq --indent 2 --sort-keys \
    --arg k "$key" --arg v "$version" --arg u "$url" --arg h "$hash" \
    '.[$k] = { version: $v, url: $u, hash: $h }' "$DIR/sources.json" >"$DIR/sources.json.new"
  mv "$DIR/sources.json.new" "$DIR/sources.json"
  echo "$key: updated to $version"
}

config=$(curl -fsSL --retry 3 "$CONFIG_JSON")
update_one qq-amd64 "$(jq -er '.Linux.x64DownloadUrl.deb' <<<"$config")"
update_one qq-arm64 "$(jq -er '.Linux.armDownloadUrl.deb' <<<"$config")"

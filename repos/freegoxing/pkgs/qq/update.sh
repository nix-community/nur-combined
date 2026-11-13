#! /usr/bin/env nix-shell
#! nix-shell -i bash --pure --keep GITHUB_TOKEN -p nix git curl cacert nix-prefetch-git jq python3
# shellcheck shell=bash

set -euo pipefail

cd "$(readlink -e "$(dirname "${BASH_SOURCE[0]}")")"

sign_url() {
  # https://github.com/flathub/com.qq.QQ/issues/274#issuecomment-5512982615
  curl -fsS -X POST "https://im.qq.com/http2rpc/gotrpc/noauth/trpc.qqntv2.urlsign.UrlSign/GetSign" \
    -H "Content-Type: application/json" \
    -H 'x-oidb: {"uint32_command":"0x9b8e","uint32_service_type":1}' \
    -d "{\"url\":\"$1\"}" | jq -er '.data.url'
}

# linux

linux_payload=$(curl -fsSL --connect-timeout 15 --max-time 60 https://cdn-go.cn/qq-web/im.qq.com_new/latest/rainbow/linuxConfig.js | grep -oP "var params= \K\{.*\}(?=;)")
linux_version=$(jq -er '.version | select(type == "string" and test("^[0-9]+(\\.[0-9]+)+$"))' <<<"$linux_payload")-$(jq -er '.updateDate | select(type == "string" and test("^[0-9]{4}-[0-9]{2}-[0-9]{2}$"))' <<<"$linux_payload")

if [[ -n ${UPDATE_NIX_OLD_VERSION:-} && $linux_version != "$UPDATE_NIX_OLD_VERSION" &&
  $(printf '%s\n%s\n' "$linux_version" "$UPDATE_NIX_OLD_VERSION" | sort -V | head -n 1) == "$linux_version" ]]; then
  echo "Skipping QQ downgrade from $UPDATE_NIX_OLD_VERSION to $linux_version" >&2
  exit 0
fi

linux_x86_64_url=$(jq -er '.x64DownloadUrl.deb | select(type == "string" and test("^https://[a-zA-Z0-9._/-]+$"))' <<<"$linux_payload")

linux_x86_64_hash=$(nix-prefetch-url "$(sign_url "$linux_x86_64_url")")

# use friendlier hashes
linux_x86_64_hash=$(nix --extra-experimental-features nix-command hash convert --to sri --hash-algo sha256 "$linux_x86_64_hash")

python3 - "$linux_version" "$linux_x86_64_url" "$linux_x86_64_hash" <<'PYTHON'
import json
from pathlib import Path
import sys

path = Path("default.nix")
text = path.read_text()
start_marker = "  # Source updated by update.sh.\n"
end_marker = "  passthru = {"
if text.count(start_marker) != 1 or text.count(end_marker) != 1:
    raise SystemExit("Could not uniquely locate QQ source in default.nix")
start = text.index(start_marker) + len(start_marker)
end = text.index(end_marker, start)
version, url, hash_value = map(json.dumps, sys.argv[1:])
source = f"  version = {version};\n  src = fetchqq {{\n    url = {url};\n    hash = {hash_value};\n  }};\n"
path.write_text(text[:start] + source + text[end:])
PYTHON
if [[ -n ${UPDATE_NIX_OLD_VERSION:-} && $linux_version == "$UPDATE_NIX_OLD_VERSION" ]]; then
  echo "Checked QQ version: $linux_version"
else
  echo "Updated QQ version: ${UPDATE_NIX_OLD_VERSION:-unknown} -> $linux_version"
fi

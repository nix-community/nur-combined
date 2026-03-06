#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

URL="https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.deb"

echo "[*] Fetching latest .deb from $URL ..."

# 使用 fetch-sri-hash.sh 获取 SRI hash
HASH=$("$SCRIPT_DIR/../../.github/script/fetch-sri-hash.sh" "$URL")
echo "[*] Computed Nix hash: $HASH"

# 下载并提取版本
STORE_PATH=$(nix-prefetch-url --print-path "$URL" 2>/dev/null | tail -n1)
VERSION=$(dpkg-deb -f "$STORE_PATH" Version)
echo "[*] Extracted version: $VERSION"

# 更新 default.nix
sed -i \
    -e "s|version = \".*\";|version = \"$VERSION\";|" \
    -e "s|hash = \".*\";|hash = \"$HASH\";|" \
    default.nix

echo "[+] Updated default.nix with version=$VERSION and hash=$HASH"

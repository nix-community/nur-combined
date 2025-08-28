#!/usr/bin/env bash

set -euo pipefail

URL="https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.deb"

echo "[*] Fetching latest .deb from $URL ..."

# nix-prefetch-url 下载并返回 store 路径和 base32 hash
STORE_PATH=$(nix-prefetch-url --print-path "$URL" 2>/dev/null | tail -n1)
RAW_HASH=$(nix-prefetch-url "$URL" 2>/dev/null || true)

# 计算 Nix-friendly sha256
HASH="sha256-$(nix hash to-base64 --type sha256 "$RAW_HASH")"
echo "[*] Computed Nix hash: $HASH"

# 直接用 dpkg-deb 读取 store 里的 .deb 文件，而不是 curl
VERSION=$(dpkg-deb -f "$STORE_PATH" Version)
echo "[*] Extracted version: $VERSION"

# 更新 default.nix
sed -i \
    -e "s|version = \".*\";|version = \"$VERSION\";|" \
    -e "s|hash = \".*\";|hash = \"$HASH\";|" \
    default.nix

echo "[+] Updated default.nix with version=$VERSION and hash=$HASH"

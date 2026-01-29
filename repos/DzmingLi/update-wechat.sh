#!/usr/bin/env bash
set -euo pipefail

PKG_FILE="pkgs/wechat/default.nix"
APPIMAGE_URL="https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.AppImage"

OLD_HASH=$(grep -A 1 'url = "'$APPIMAGE_URL'"' "$PKG_FILE" | grep 'hash' | sed -e 's/.*hash = "\(.*\)";/\1/')

echo "Current hash: $OLD_HASH"

NEW_HASH=$(nix-hash --to-sri --type sha256 "$(nix-prefetch-url "$APPIMAGE_URL")")

echo "Latest hash:  $NEW_HASH"

if [ "$OLD_HASH" != "$NEW_HASH" ]; then
  echo "New version found! Updating $PKG_FILE..."
  sed -i "s|hash = \"$OLD_HASH\";|hash = \"$NEW_HASH\";|" "$PKG_FILE"
  echo "Update complete. The Nix expression is now pointing to the latest version."
else
  echo "Package is already up-to-date. No changes needed."
fi

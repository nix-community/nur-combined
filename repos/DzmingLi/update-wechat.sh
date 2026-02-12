#!/usr/bin/env bash
set -euo pipefail

PKG_FILE="pkgs/wechat/default.nix"
APPIMAGE_URLS=(
  "https://dldir1.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.AppImage"
  "https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.AppImage"
)

OLD_HASH=$(grep -m 1 'hash = "' "$PKG_FILE" | sed -e 's/.*hash = "\(.*\)";/\1/')

echo "Current hash: $OLD_HASH"

NEW_HASH=""
USED_URL=""
for url in "${APPIMAGE_URLS[@]}"; do
  if PREFETCH_PATH=$(nix-prefetch-url "$url" 2>/dev/null); then
    NEW_HASH=$(nix-hash --to-sri --type sha256 "$PREFETCH_PATH")
    USED_URL="$url"
    break
  fi
done

if [ -z "$NEW_HASH" ]; then
  echo "Failed to download WeChat AppImage from all URLs." >&2
  exit 1
fi

echo "Using URL:   $USED_URL"
echo "Latest hash:  $NEW_HASH"

if [ "$OLD_HASH" != "$NEW_HASH" ]; then
  echo "New version found! Updating $PKG_FILE..."
  sed -i "s|hash = \"$OLD_HASH\";|hash = \"$NEW_HASH\";|" "$PKG_FILE"
  echo "Update complete. The Nix expression is now pointing to the latest version."
else
  echo "Package is already up-to-date. No changes needed."
fi

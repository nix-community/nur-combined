#!/usr/bin/env bash
# update-wechat-latest.sh
# 更新 wechat-latest 包到最新版本

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_FILE="$SCRIPT_DIR/package.nix"

# 获取最新的 .deb 包 URL
WECHAT_URL="https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.deb"

echo "正在获取 $WECHAT_URL 的 sha256..."

# 使用 nix-prefetch-url 获取 sha256
NEW_SHA256=$(nix-prefetch-url "$WECHAT_URL")

# 从 package.nix 中提取当前的 sha256
OLD_SHA256=$(grep -oP 'sha256 = "\K[^"]+' "$PACKAGE_FILE" || echo "")

echo "当前 SHA256: $OLD_SHA256"
echo "最新 SHA256: $NEW_SHA256"

# 如果 sha256 没有变化，不更新
if [ "$NEW_SHA256" = "$OLD_SHA256" ]; then
  echo "SHA256 未变化，无需更新"
  exit 0
fi

# sha256 有变化，获取当前日期时间作为版本号
VERSION=$(date +%Y%m%d.%H%M%S)

echo "检测到新版本: $VERSION"

# 更新 package.nix 文件
tmpfile=$(mktemp)
trap "rm -f $tmpfile" EXIT

# 使用 sed 替换 version 和 sha256
sed -E \
  -e "s|(version = \")[0-9]+\.[0-9]+(\";)|\1$VERSION\2|" \
  -e "s|(sha256 = \")[^\"]+(\";)|\1$NEW_SHA256\2|" \
  "$PACKAGE_FILE" > "$tmpfile"

# 替换原文件
mv "$tmpfile" "$PACKAGE_FILE"

echo "已更新 $PACKAGE_FILE:"
echo "  version: $VERSION"
echo "  sha256: $NEW_SHA256"

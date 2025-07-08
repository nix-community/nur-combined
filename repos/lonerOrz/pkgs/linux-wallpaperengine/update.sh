#!/usr/bin/env bash
set -euo pipefail

OWNER="Almamu"
REPO="linux-wallpaperengine"
BRANCH="main"
PKG_FILE="default.nix"

# 获取最新 commit hash（short）
LATEST_COMMIT=$(git ls-remote "https://github.com/$OWNER/$REPO.git" $BRANCH | awk '{print $1}')
if [ -z "$LATEST_COMMIT" ]; then
  echo "Failed to fetch latest commit hash."
  exit 1
fi

# 生成版本号，格式：0-unstable-YYYY-MM-DD
VERSION="0-unstable-$(date +%F)"

# 获取 base32 hash
RAW_HASH=$(nix-prefetch-git --quiet \
  --fetch-submodules \
  --url https://github.com/$OWNER/$REPO.git \
  --rev $LATEST_COMMIT | jq -r .sha256)

if [ -z "$RAW_HASH" ]; then
  echo "Failed to fetch sha256 hash."
  exit 1
fi

BASE64_HASH=$(nix hash to-base64 "sha256:$RAW_HASH")
HASH="sha256-$BASE64_HASH"

# 替换 rev/version/hash
# 只替换 linux-wallpaperengine 的字段（确保 p.name 行在文件中）
sed -i -E "/pname\s*=\s*\"linux-wallpaperengine\"/,/^}/ {
  s|(rev\s*=\s*\")[^\"]*(\";)|\1$LATEST_COMMIT\2|
  s|(version\s*=\s*\")[^\"]*(\";)|\1$VERSION\2|
  s|(hash\s*=\s*\")[^\"]*(\";)|\1$HASH\2|
}" "$PKG_FILE"

echo "Updated $PKG_FILE:"
echo "  version = $VERSION"
echo "  rev = $LATEST_COMMIT"
echo "  hash = $HASH"

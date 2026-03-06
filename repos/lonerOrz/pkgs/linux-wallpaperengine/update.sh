#!/usr/bin/env bash
set -euo pipefail

OWNER="Almamu"
REPO="linux-wallpaperengine"
BRANCH="main"
PKG_FILE="default.nix"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 获取最新 commit hash（使用 github-rev-fetch.sh 支持认证避免限流）
LATEST_COMMIT=$("$SCRIPT_DIR/../../.github/script/github-rev-fetch.sh" "$OWNER/$REPO" "$BRANCH")
if [ -z "$LATEST_COMMIT" ]; then
  echo "Failed to fetch latest commit hash."
  exit 1
fi

# 生成版本号，格式：0-unstable-YYYY-MM-DD
VERSION="0-unstable-$(date +%F)"

# 获取 SRI hash（使用 git archive tarball）
HASH=$("$SCRIPT_DIR/../../.github/script/fetch-sri-hash.sh" "https://github.com/$OWNER/$REPO/archive/$LATEST_COMMIT.tar.gz" --unpack)

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

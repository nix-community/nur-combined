#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."

OWNER="google-gemini"
REPO="gemini-cli"
PKG_FILE="pkgs/gemini-cli/default.nix"
PACKAGE_LOCK_FILE="pkgs/gemini-cli/package-lock.fixed.json"
FIX_SCRIPT="pkgs/gemini-cli/fix.js"

# 获取当前 default.nix 中的版本（取 pname 区块附近的第一个 version）
CURRENT_VERSION=$(awk '/pname *= *"gemini-cli"/, /^}/' "$PKG_FILE" \
  | grep 'version = "' | head -n1 | sed -E 's/.*version = "([^"]+)";/\1/')

# 获取最新 release tag
LATEST_RELEASE=$(curl -s "https://api.github.com/repos/$OWNER/$REPO/releases/latest" | jq -r .tag_name)
[ -z "$LATEST_RELEASE" ] && { echo "❌ Failed to fetch latest release tag."; exit 1; }

# 去掉 v 前缀
LATEST_VERSION="${LATEST_RELEASE#v}"

# 版本未变则退出
if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
  echo "✅ No update needed. Current version: $CURRENT_VERSION"
  exit 0
fi

echo "🔄 New version detected: $LATEST_VERSION"

# 获取 git 源码哈希（适用于 fetchgit）
RAW_HASH=$(nix-prefetch-git \
  --url "https://github.com/$OWNER/$REPO.git" \
  --rev "$LATEST_RELEASE" \
  --fetch-submodules | jq -r .sha256)

[ -z "$RAW_HASH" ] && { echo "❌ Failed to fetch source hash from nix-prefetch-git."; exit 1; }

# 转换为 base64 表达形式（fetchgit 支持）
SOURCE_HASH=$(nix hash to-base64 "sha256:$RAW_HASH")
SOURCE_HASH="sha256-$SOURCE_HASH"

# 克隆仓库并运行 fix.js 修复 package-lock.json
TEMP_DIR=$(mktemp -d)
git clone --depth 1 --branch "$LATEST_RELEASE" "https://github.com/$OWNER/$REPO.git" "$TEMP_DIR"

[ ! -f "$TEMP_DIR/package-lock.json" ] && {
  echo "❌ package-lock.json not found in cloned repo."
  rm -rf "$TEMP_DIR"
  exit 1
}

cp "$FIX_SCRIPT" "$TEMP_DIR/fix.js"
if ! (cd "$TEMP_DIR" && node fix.js); then
  echo "❌ Failed to run fix.js"
  rm -rf "$TEMP_DIR"
  exit 1
fi

[ ! -f "$TEMP_DIR/package-lock.fixed.json" ] && {
  echo "❌ fix.js did not generate package-lock.fixed.json"
  rm -rf "$TEMP_DIR"
  exit 1
}

cp "$TEMP_DIR/package-lock.fixed.json" "$PACKAGE_LOCK_FILE"
echo >> "$PACKAGE_LOCK_FILE"  # 添加末尾换行
rm -rf "$TEMP_DIR"

# 使用 prefetch-npm-deps 获取 npmDepsHash
NPM_DEPS_HASH=$(prefetch-npm-deps $PACKAGE_LOCK_FILE)
if [ -z "$NPM_DEPS_HASH" ]; then
  echo "❌ Failed to fetch npmDepsHash using prefetch-npm-deps."
  exit 1
fi

# 更新 default.nix 中 version srcHash npmDepsHash
sed -i -E \
  -e "s@(version = \")[^\"]*(\";)@\\1$LATEST_VERSION\\2@" \
  -e "s@(srcHash = \")[^\"]*(\";)@\\1$SOURCE_HASH\\2@" \
  -e "s@(npmDepsHash = \")[^\"]*(\";)@\\1$NPM_DEPS_HASH\\2@" \
  "$PKG_FILE"

# 完成信息
echo "✅ Updated $PKG_FILE:"
echo "  version      = $LATEST_VERSION"
echo "  source hash  = $SOURCE_HASH"
echo "  npmDepsHash  = $NPM_DEPS_HASH"
echo "✅ Updated $PACKAGE_LOCK_FILE using fix.js"

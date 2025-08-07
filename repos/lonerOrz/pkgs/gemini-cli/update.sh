#!/usr/bin/env bash
set -euo pipefail

# 工具检测
command -v nix-prefetch-url >/dev/null || { echo >&2 "请先安装 nix-prefetch-url"; exit 1; }
command -v prefetch-npm-deps >/dev/null || { echo >&2 "请先安装 prefetch-npm-deps"; exit 1; }
command -v jq >/dev/null || { echo >&2 "请先安装 jq"; exit 1; }

# 获取脚本所在目录
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
package_file="$script_dir/default.nix"
lock_file="$script_dir/package-lock.json"

cleanup() {
  if [ -n "${tmp_dir:-}" ] && [ -d "$tmp_dir" ]; then
    rm -rf "$tmp_dir"
  fi
}
trap cleanup EXIT

echo "Fetching latest version..."
latest_version=$(npm view @google/gemini-cli version)
echo "Latest version: $latest_version"

current_version=$(nix eval .#gemini-cli.version --raw)
echo "Current version: $current_version"

if [ "$latest_version" = "$current_version" ] && [ "${FORCE_UPDATE:-}" != "true" ]; then
  echo "Package is already up to date!"
  echo "Use FORCE_UPDATE=true to force hash updates"
  exit 0
fi

if [ "$latest_version" = "$current_version" ]; then
  echo "Forcing hash update for version $current_version"
else
  echo "Update available: $current_version -> $latest_version"
fi

# 下载并生成 package-lock.json
echo "Downloading npm package and generating package-lock.json..."
tmp_dir=$(mktemp -d)
cd "$tmp_dir"
npm pack "@google/gemini-cli@$latest_version" >/dev/null 2>&1
tarball_name="google-gemini-cli-${latest_version}.tgz"
tar -xzf "$tarball_name"

cd package
npm install --package-lock-only --ignore-scripts >/dev/null 2>&1
cp package-lock.json "$lock_file"

cd "$script_dir"

# 计算 tarball URL 和 hash
tarball_url="https://registry.npmjs.org/@google/gemini-cli/-/gemini-cli-${latest_version}.tgz"
echo "Fetching tarball hash from nix-prefetch-url..."
raw_hash=$(nix-prefetch-url "$tarball_url")
tarball_hash=$(nix hash to-base64 "sha256:$raw_hash")
echo "Tarball hash: sha256-$tarball_hash"

# 获取 npmDeps hash
echo "Fetching npmDeps hash via prefetch-npm-deps..."
npmdeps_hash=$(prefetch-npm-deps "$lock_file")
echo "npmDeps hash: $npmdeps_hash"

# Updating default.nix
echo "Updating default.nix..."
sed -i "s|version = \".*\";|version = \"$latest_version\";|" "$package_file"
sed -i -E "s|url = \".*\";|url = \"$tarball_url\";|" "$package_file"
sed -i -E "s|srcHash = \"sha256-[^\"]+\";|srcHash = \"sha256-$tarball_hash\";|" "$package_file"
sed -i -E "s|npmDepsHash = \"sha256-[^\"]+\";|npmDepsHash = \"$npmdeps_hash\";|" "$package_file"

echo "✅ Update completed successfully!"
if [ "$latest_version" = "$current_version" ]; then
  echo "✅ Hashes have been updated for gemini-cli $current_version"
else
  echo "✅ gemini-cli has been updated from $current_version to $latest_version"
fi

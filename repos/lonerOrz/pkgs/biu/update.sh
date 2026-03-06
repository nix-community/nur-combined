#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl gnugrep gnused coreutils nix git jq

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_NIX="$SCRIPT_DIR/default.nix"
REPO_OWNER="wood3n"
REPO_NAME="biu"

WORKDIR="$(mktemp -d)"
TMP_NIX="$WORKDIR/default.nix"

# Trap 显示失败命令和返回码
trap 'rc=$?; echo "[ERROR] Command failed with exit code $rc"; echo "Cleaning $WORKDIR"; ls -l "$WORKDIR"; exit $rc' ERR INT

echo "[DEBUG] Reading current version"
current_version=$(grep -oE 'version\s*=\s*"[0-9]+\.[0-9]+\.[0-9]+"' "$DEFAULT_NIX" \
                  | head -1 \
                  | cut -d'"' -f2)
echo "当前版本：$current_version"

echo "[DEBUG] Getting latest version"
latest_version=$("$SCRIPT_DIR/../../.github/script/github-tag-fetch.sh" "${REPO_OWNER}/${REPO_NAME}")
latest_version="${latest_version#v}"
echo "最新版本：$latest_version"

if [ "$latest_version" = "" ]; then
    echo "[ERROR] Failed to get latest version from GitHub"
    exit 1
fi

if [ "$latest_version" = "$current_version" ]; then
    echo "Already latest version, nothing to do"
    exit 0
fi

echo "[DEBUG] Copying default.nix"
cp "$DEFAULT_NIX" "$TMP_NIX"

echo "[DEBUG] Updating version in $TMP_NIX"
sed -i -E 's|(version\s*=\s*")[0-9]+\.[0-9]+\.[0-9]+(")|\1'"$latest_version"'\2|' "$TMP_NIX"

x86_url="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/v${latest_version}/Biu-${latest_version}-linux-x86_64.AppImage"
aarch64_url="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/v${latest_version}/Biu-${latest_version}-linux-arm64.AppImage"

echo "[DEBUG] Prefetching x86_64 hash"
x86_hash=$("$SCRIPT_DIR/../../.github/script/fetch-sri-hash.sh" "$x86_url")
echo "x86_64 hash: $x86_hash"

echo "[DEBUG] Prefetching aarch64 hash"
aarch64_hash=$("$SCRIPT_DIR/../../.github/script/fetch-sri-hash.sh" "$aarch64_url")
echo "aarch64 hash: $aarch64_hash"

echo "[DEBUG] Replacing x86_64 hash"
sed -i -zE 's|(x86_64-linux = fetchurl \{.*?hash = ")[^"]*(";)|\1'"$x86_hash"'\2|' "$TMP_NIX"

echo "[DEBUG] Replacing aarch64 hash"
sed -i -zE 's|(aarch64-linux = fetchurl \{.*?hash = ")[^"]*(";)|\1'"$aarch64_hash"'\2|' "$TMP_NIX"

echo "[DEBUG] Moving TMP_NIX to DEFAULT_NIX"
mv "$TMP_NIX" "$DEFAULT_NIX"

echo "[DEBUG] Cleaning up workdir"
rm -rf "$WORKDIR"
trap - ERR INT

echo "Update finished: version $latest_version, hashes refreshed"

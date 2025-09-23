#!/usr/bin/env nix-shell
#!nix-shell -i bash --pure --keep GITHUB_TOKEN -p curl jq cacert nix

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

NIX_FILE="default.nix"
GITHUB_REPO="QwenLM/qwen-code"
ASSET_NAME="gemini.js"
REV_PREFIX="v"

CURRENT_VER=$(grep -oP 'version = "\K[^"]+' "${NIX_FILE}" || { echo "错误：无法提取版本号" >&2; exit 1; })

API_URL="https://api.github.com/repos/${GITHUB_REPO}/releases/latest"
RELEASE_JSON=$(curl --fail -s "${API_URL}" || { echo "错误：无法获取 GitHub 发布信息" >&2; exit 1; })
LATEST_VER=$(echo "${RELEASE_JSON}" | jq -r '.tag_name // empty' || { echo "错误：无法获取最新版本" >&2; exit 1; })
LATEST_VER="${LATEST_VER#"${REV_PREFIX}"}"

[[ "${LATEST_VER}" == "${CURRENT_VER}" ]] && { echo "已是最新版本：${CURRENT_VER}"; exit 0; }

ASSET_URL=$(echo "${RELEASE_JSON}" | jq -r ".assets[] | select(.name == \"${ASSET_NAME}\") | .browser_download_url")
[[ -z "${ASSET_URL}" ]] && { echo "错误：未找到资产 ${ASSET_NAME}" >&2; exit 1; }

# LATEST_HASH=$(nix-prefetch-url "${ASSET_URL}" || { echo "错误：无法计算哈希值" >&2; exit 1; })
raw_hash=$(nix-prefetch-url "${ASSET_URL}")
LATEST_HASH=$(nix hash to-base64 "sha256:$raw_hash")

sed -i "s|hash = \"[^\"]*\"|hash = \"sha256-${LATEST_HASH}\"|g" "${NIX_FILE}"
sed -i "s|version = \"${CURRENT_VER}\"|version = \"${LATEST_VER}\"|g" "${NIX_FILE}"

echo "成功更新到版本 ${LATEST_VER}"

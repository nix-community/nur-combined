#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
sources_file="$SCRIPT_DIR/sources.nix"
package_file="$SCRIPT_DIR/default.nix"

# 获取最新 release tag
latestTag=$("$SCRIPT_DIR/../../.github/script/github-tag-fetch.sh" "INKCR0W/sparkle")
latestVersion="${latestTag#v}"

declare -A archMap=(
  ["x86_64-linux"]="amd64"
  ["aarch64-linux"]="arm64"
)

# 获取该 tag 的完整 release JSON
if [ -n "${GITHUB_TOKEN:-}" ]; then
  release_json=$(curl -sL -H "Authorization: Bearer ${GITHUB_TOKEN}" "https://api.github.com/repos/INKCR0W/sparkle/releases/tags/$latestTag")
else
  release_json=$(curl -sL "https://api.github.com/repos/INKCR0W/sparkle/releases/tags/$latestTag")
fi

# 检查 API 响应是否有效
if echo "$release_json" | jq -e '.message' >/dev/null 2>&1; then
  msg=$(echo "$release_json" | jq -r '.message')
  echo "❌ GitHub API error: $msg" >&2
  if [ -z "${GITHUB_TOKEN:-}" ]; then
    echo "💡 Hint: Set GITHUB_TOKEN to avoid rate limits" >&2
  fi
  exit 1
fi

# 生成合法的 sources.nix
{
  echo "{"
  for sys in "${!archMap[@]}"; do
    arch=${archMap[$sys]}

    url=$(echo "$release_json" |
      jq -r --arg arch "$arch" '.assets[] | select(.name | test("^sparkle-linux-.*"+$arch+".deb$")) | .browser_download_url' |
      head -n 1)

    if [[ -z $url ]]; then
      echo "  # Warning: no release asset found for $sys"
      continue
    fi

    hash=$("$SCRIPT_DIR/../../.github/script/fetch-sri-hash.sh" "$url")

    echo "  $sys = {"
    echo "    url = \"$url\";"
    echo "    hash = \"$hash\";"
    echo "  };"
  done
  echo "}"
} >"$sources_file"

sed -i -E "s/^(  version\s*=\s*\").*(\";)/\1$latestVersion\2/" "$package_file"

echo "Updated sources.nix and package.nix to version $latestVersion"

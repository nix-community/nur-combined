#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

sources_file="./sources.nix"
package_file="./default.nix"

# 获取最新 release tag
latestTag=$(curl -sL https://api.github.com/repos/xishang0128/sparkle/releases/latest | jq -r ".tag_name")
latestVersion="${latestTag#v}"

declare -A archMap=(
  ["x86_64-linux"]="amd64"
  ["aarch64-linux"]="arm64"
)

# 获取该 tag 的完整 release JSON
release_json=$(curl -sL "https://api.github.com/repos/xishang0128/sparkle/releases/tags/$latestTag")

# 生成合法的 sources.nix
{
  echo "{"
  for sys in "${!archMap[@]}"; do
    arch=${archMap[$sys]}

    url=$(echo "$release_json" |
      jq -r --arg arch "$arch" '.assets[] | select(.name | test($arch) and (test(".sha256") | not)) | .browser_download_url' |
      head -n 1)

    if [[ -z $url ]]; then
      echo "  # Warning: no release asset found for $sys"
      continue
    fi

    raw_hash=$(nix-prefetch-url "$url")
    hash="sha256-$(nix hash to-base64 "sha256:$raw_hash")"

    echo "  $sys = {"
    echo "    url = \"$url\";"
    echo "    hash = \"$hash\";"
    echo "  };"
  done
  echo "}"
} >"$sources_file"

sed -i -E "s/^(  version\s*=\s*\").*(\";)/\1$latestVersion\2/" "$package_file"

echo "Updated sources.nix and package.nix to version $latestVersion"

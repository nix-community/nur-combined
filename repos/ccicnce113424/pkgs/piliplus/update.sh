#!/usr/bin/env nix-shell
#!nix-shell -i bash -p jq yq nix-prefetch-git
set -euo pipefail

owner=bggRGjQaUbCoE
repo=PiliPlus

# 支持 -f/--force 强制刷新 src-info.json
force=false
if [[ ${1-} == "-f" || ${1-} == "--force" ]]; then
  force=true
fi

# 通过脚本自身位置推导仓库根目录，无需依赖当前工作目录
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
REPO_ROOT=$(cd "$SCRIPT_DIR/../.." && pwd)
cd "$REPO_ROOT"

package_name=piliplus
package_dir=$SCRIPT_DIR

lock_file=$package_dir/pubspec.lock.json
git_hashes=$package_dir/git-hashes.nix
src_info=$package_dir/src-info.json

lock_path=$(jq -r ".\"$package_name\".extract.\"pubspec.lock\"" _sources/generated.json)
version=$(jq -r ".\"$package_name\".src.rev" _sources/generated.json)

# 如果已有 src-info.json 且版本未变化且未指定 -f，则直接跳过后续操作
if [[ -f $src_info && $force != true ]]; then
  old_version=$(jq -r '.version // empty' "$src_info" || true)
  if [[ -n $old_version && $old_version == "$version" ]]; then
    echo "src-info.json is up to date (version=$version), skipping."
    exit 0
  fi
fi

yq <"_sources/$lock_path" >"$lock_file"

echo "{" >"$git_hashes"

jq -r '
  .packages
  | to_entries[]
  | select(.value.source == "git")
  | "\(.key) \(.value.description.url) \(.value.description["resolved-ref"] // .value.description.ref // "HEAD")"
' "$lock_file" | while read -r name url ref; do
  echo "Fetching $name from $url ($ref)..."
  hash=$(nix-prefetch-git --quiet --url "$url" --rev "$ref" | jq -r .hash)
  echo "  \"$name\" = \"$hash\";" >>"$git_hashes"
done

echo "}" >>"$git_hashes"

info_json=$(nix-prefetch-git --quiet --url "https://github.com/$owner/$repo" --rev "$version")

rev=$(jq -r .rev <<<"$info_json")
date_iso=$(jq -r .date <<<"$info_json")

# 将 ISO8601 时间转换为时间戳，失败则回退为 0，避免 --argjson 报错
if [[ -n $date_iso ]] && time_val=$(date -d "$date_iso" +%s 2>/dev/null); then
  :
else
  time_val=0
fi

rev_count=$(curl -sS -D - -o /dev/null "https://api.github.com/repos/$owner/$repo/commits?sha=$version&per_page=1" |
  tr -d '\r' |
  sed -n 's/^link: .*[\?&]page=\([0-9]\+\)>; rel="last".*/\1/p')

# 如果没有 Link 头，说明只有一页，rev_count 置为 1，仍是合法 JSON 数字
if [[ -z $rev_count ]]; then
  rev_count=1
fi

jq -n \
  --arg version "$version" \
  --arg rev "$rev" \
  --argjson time "$time_val" \
  --argjson revCount "$rev_count" \
  '{ version: $version, rev: $rev, time: $time, revCount: $revCount }' >"$src_info"

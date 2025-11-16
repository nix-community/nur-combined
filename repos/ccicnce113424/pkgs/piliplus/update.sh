#! /usr/bin/env nix
#! nix shell nixpkgs#nix-prefetch-git .#jaq -c bash
set -euo pipefail

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

src_info=$package_dir/src-info.json

lock_path=$(jaq -r ".\"$package_name\".extract.\"pubspec.lock\"" _sources/generated.json)
version=$(jaq -r ".\"$package_name\".src.rev" _sources/generated.json)

owner=$(jaq -r ".\"$package_name\".src.owner" _sources/generated.json)
repo=$(jaq -r ".\"$package_name\".src.repo" _sources/generated.json)

# 如果已有 src-info.json 且版本未变化且未指定 -f，则直接跳过后续操作
if [[ -f $src_info && $force != true ]]; then
  old_version=$(jaq -r '.version // empty' "$src_info" || true)
  if [[ -n $old_version && $old_version == "$version" ]]; then
    echo "src-info.json is up to date (version=$version), skipping."
    exit 0
  fi
fi

info_json=$(nix-prefetch-git --quiet --url "https://github.com/$owner/$repo" --rev "$version")

rev=$(jaq -r .rev <<<"$info_json")
date_iso=$(jaq -r .date <<<"$info_json")

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

git_hashes_object=$(
  jaq --from yaml -r '.packages
    | to_entries
    | map(select(.value.source == "git"))
    | map({
        key: .key,
        url: .value.description.url,
        ref: (.value.description["resolved-ref"] // .value.description.ref // "HEAD")
      })
    | .[]
    | "\(.key) \(.url) \(.ref)"' "_sources/$lock_path" |
    while read -r name url ref; do
      echo "Fetching $name from $url ($ref)..." >&2
      # 只用 stdout，stderr 直接流向终端日志，不参与 JSON
      hash=$(
        nix-prefetch-git --quiet --url "$url" --rev "$ref" |
          jaq -r .hash 2>/dev/null
      )
      if [[ -z $hash ]]; then
        echo "Failed to parse hash for $name from nix-prefetch-git output" >&2
        # 如果想看详细输出，可以临时去掉 --quiet 或单独测试
        continue
      fi
      jaq -n --arg name "$name" --arg hash "$hash" '{ ($name): $hash }'
    done |
    jaq -s 'add'
)

# 防御：如果整个循环没产出任何对象，给一个空对象，避免后面 --argjson 报错
if [[ -z ${git_hashes_object:-} ]]; then
  git_hashes_object='{}'
fi

jaq --from yaml -n \
  --arg version "$version" \
  --arg rev "$rev" \
  --argjson time "$time_val" \
  --argjson revCount "$rev_count" \
  --argjson gitHashes "$git_hashes_object" \
  '{ version: $version, rev: $rev, time: $time, revCount: $revCount,
     pubspecLock: input, gitHashes: $gitHashes }' "_sources/$lock_path" >"$src_info"

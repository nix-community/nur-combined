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

package_name=pixes
package_dir=$SCRIPT_DIR

src_info=$package_dir/src-info.json

lock_path=$(jaq -r ".\"$package_name\".extract.\"pubspec.lock\"" _sources/generated.json)
version=$(jaq -r ".\"$package_name\".src.rev" _sources/generated.json)

# 如果已有 src-info.json 且版本未变化，且未指定 -f，则直接跳过
if [[ -f $src_info && $force != true ]]; then
  old_version=$(jaq -r '.version // empty' "$src_info" || true)
  if [[ -n $old_version && $old_version == "$version" ]]; then
    echo "src-info.json is up to date (version=$version), skipping."
    exit 0
  fi
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
      hash=$(
        nix-prefetch-git --quiet --url "$url" --rev "$ref" |
          jaq -r .hash 2>/dev/null
      )
      if [[ -z $hash ]]; then
        echo "Failed to parse hash for $name from nix-prefetch-git output" >&2
        continue
      fi
      jaq -n --arg name "$name" --arg hash "$hash" '{ ($name): $hash }'
    done |
    jaq -s 'add'
)

if [[ -z ${git_hashes_object:-} ]]; then
  git_hashes_object='{}'
fi

jaq --from yaml -n \
  --arg version "$version" \
  --argjson gitHashes "$git_hashes_object" \
  '{ version: $version, pubspecLock: input, gitHashes: $gitHashes }' "_sources/$lock_path" >"$src_info"

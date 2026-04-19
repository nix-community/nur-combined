#!/usr/bin/env nix-shell
#!nix-shell -i bash -p gnugrep jq
set -euo pipefail

# 支持 -f/--force 强制刷新 src-info.json
force=false
if [[ ${1-} == "-f" || ${1-} == "--force" ]]; then
  force=true
fi

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
REPO_ROOT=$(cd "$SCRIPT_DIR/../.." && pwd)
cd "$REPO_ROOT"

package_name="motrix-next-beta"
package_dir=$SCRIPT_DIR
src_info=$package_dir/src-info.json

version=$(jq -r ".\"$package_name\".src.rev" _sources/generated.json)
source_sha256=$(jq -r ".\"$package_name\".src.sha256" _sources/generated.json)
if [[ -z $source_sha256 || $source_sha256 == "null" ]]; then
  echo "Failed to read source sha256 from _sources/generated.json."
  exit 1
fi

# 如果已有 src-info.json 且源码哈希未变化，且未指定 -f，则直接跳过
if [[ -f $src_info && $force != true ]]; then
  old_source_sha256=$(jq -r '.sourceSha256 // empty' "$src_info" || true)
  if [[ -n $old_source_sha256 && $old_source_sha256 == "$source_sha256" ]]; then
    echo "src-info.json is up to date (sourceSha256=$source_sha256), skipping."
    exit 0
  fi
fi

build_output=$(nix build --impure --expr "(import ./pkgs {}).${package_name}.pnpmDeps.overrideAttrs (_: { outputHash = \"\"; outputHashAlgo = \"sha256\"; })" 2>&1) || true
echo "MotrixNext git deps build output is:"
echo "$build_output"
hash_motrix_next_git=$(tr -s ' ' <<<$build_output | grep -Po "got: \K.+$")
if [ -z "$hash_motrix_next_git" ]; then
  echo "Failed to extract hash from build output."
  exit 1
fi
echo "MotrixNext git deps hash is: $hash_motrix_next_git"

jq -n \
  --arg version "$version" \
  --arg hash "$hash_motrix_next_git" \
  --arg sourceSha256 "$source_sha256" \
  '{ version: $version, hash: $hash, sourceSha256: $sourceSha256 }' >"$src_info"

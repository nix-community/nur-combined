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

package_name="splayer-git"
package_dir=$SCRIPT_DIR
src_info=$package_dir/src-info.json

version=$(jq -r ".\"$package_name\".src.rev" _sources/generated.json)

# 如果已有 src-info.json 且版本未变化，且未指定 -f，则直接跳过
if [[ -f $src_info && $force != true ]]; then
  old_version=$(jq -r '.version // empty' "$src_info" || true)
  if [[ -n $old_version && $old_version == "$version" ]]; then
    echo "src-info.json is up to date (version=$version), skipping."
    exit 0
  fi
fi

build_output=$(nix build --impure --expr "(import ./pkgs {}).${package_name}.pnpmDeps.overrideAttrs (_: { outputHash = \"\"; outputHashAlgo = \"sha256\"; })" 2>&1) || true
echo "SPlayer git deps build output is:"
echo "$build_output"
hash_splayer_git=$(tr -s ' ' <<<$build_output | grep -Po "got: \K.+$")
if [ -z "$hash_splayer_git" ]; then
  echo "Failed to extract hash from build output."
  exit 1
fi
echo "SPlayer git deps hash is: $hash_splayer_git"

jq -n \
  --arg version "$version" \
  --arg hash "$hash_splayer_git" \
  '{ version: $version, hash: $hash }' >"$src_info"

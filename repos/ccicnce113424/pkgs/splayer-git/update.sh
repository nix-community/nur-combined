#!/usr/bin/env nix-shell
#!nix-shell -i bash -p jq nix-update
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

jq -n \
  --arg version "$version" \
  '{ version: $version }' >"$src_info"

cd $SCRIPT_DIR/..
nix-update --version=skip splayer-git

#!/usr/bin/env -S nix shell nixpkgs#nix-prefetch-git .#jaq -c bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../../_scripts/update-lib.sh"
package_name="pixes-git"

parse_args "$@"
setup_paths
# pixes-git 的 package_dir 是 git 子目录
package_dir=$SCRIPT_DIR/git
src_info=$package_dir/src-info.json

lock_path=$(jaq -r ".\"$package_name\".extract.\"pubspec.lock\"" _sources/generated.json)
read_source_info "jaq"
check_stale "jaq"
fetch_git_hashes "$lock_path"

jaq --from yaml -n \
  --arg version "$version" \
  --arg sourceSha256 "$source_sha256" \
  --argjson gitHashes "$git_hashes_object" \
  '{ version: $version, sourceSha256: $sourceSha256, pubspecLock: input, gitHashes: $gitHashes }' "_sources/$lock_path" >"$src_info"

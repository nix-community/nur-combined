#!/usr/bin/env -S nix shell nixpkgs#nix-prefetch-git .#jaq -c bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../../_scripts/update-lib.sh"
package_name=kikoflu

parse_args "$@"
setup_paths
lock_path=$(jaq -r ".\"$package_name\".extract.\"pubspec.lock\"" _sources/generated.json)
read_source_info "jaq"
check_stale "jaq"
fetch_git_hashes "$lock_path"

jaq --from yaml -n \
  --arg version "$version" \
  --arg sourceSha256 "$source_sha256" \
  --argjson gitHashes "$git_hashes_object" \
  '{ version: $version, sourceSha256: $sourceSha256, pubspecLock: input, gitHashes: $gitHashes }' "_sources/$lock_path" >"$src_info"

#!/usr/bin/env -S nix shell -L nixpkgs#nix-prefetch-git nixpkgs#yq-go nixpkgs#jq -c bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../../_scripts/update-lib.sh"
package_name=kikoflu

parse_args "$@"
setup_paths
lock_path=$(jq -r ".\"$package_name\".extract.\"pubspec.lock\"" _sources/generated.json)
read_source_info
check_stale

convert_pubspec_lock "$lock_path"
fetch_git_hashes

jq -n \
  --arg version "$version" \
  --arg sourceSha256 "$source_sha256" \
  '{ version: $version, sourceSha256: $sourceSha256 }' >"$src_info"

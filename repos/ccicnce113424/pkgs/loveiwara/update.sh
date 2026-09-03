#!/usr/bin/env -S nix shell -L nixpkgs#nix-prefetch-git nixpkgs#yq-go nixpkgs#jq -c bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../../_scripts/update-lib.sh"
package_name=loveiwara

parse_args "$@"
setup_paths
lock_path=$(jq -r ".\"$package_name\".extract.\"pubspec.lock\"" _sources/generated.json)
read_source_info
check_stale

convert_pubspec_lock "$lock_path"

# 将国内镜像源替换为官方源
jq 'walk(if . == "https://pub.flutter-io.cn" then "https://pub.dev" else . end)' \
  "$pubspec_lock_json" >"$pubspec_lock_json.new"
mv "$pubspec_lock_json.new" "$pubspec_lock_json"

fetch_git_hashes

jq -n \
  --arg version "$version" \
  --arg sourceSha256 "$source_sha256" \
  '{ version: $version, sourceSha256: $sourceSha256 }' >"$src_info"

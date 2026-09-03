#!/usr/bin/env -S nix shell -L nixpkgs#nix-prefetch-git nixpkgs#yq-go nixpkgs#jq -c bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../../_scripts/update-lib.sh"
package_name=piliplus

parse_args "$@"
setup_paths
lock_path=$(jq -r ".\"$package_name\".extract.\"pubspec.lock\"" _sources/generated.json)
read_source_info
check_stale

owner=$(jq -r ".\"$package_name\".src.owner" _sources/generated.json)
repo=$(jq -r ".\"$package_name\".src.repo" _sources/generated.json)

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

convert_pubspec_lock "$lock_path"
fetch_git_hashes

jq -n \
  --arg version "$version" \
  --arg sourceSha256 "$source_sha256" \
  --arg rev "$rev" \
  --argjson time "$time_val" \
  --argjson revCount "$rev_count" \
  '{ version: $version, sourceSha256: $sourceSha256, rev: $rev, time: $time, revCount: $revCount }' >"$src_info"

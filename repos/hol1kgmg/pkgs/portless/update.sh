#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash coreutils curl jq gnused
# Bump portless to the newest npm release (or to $1).
#
# The source is the npm tarball, so `just bump` (fetchFromGitHub) does not
# apply. The hash is left as a placeholder — `just fix-hashes portless`
# resolves it.
set -euo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
nixfile="$dir/default.nix"

fake_src="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="

old_version=$(sed -nE 's/^  version = "(.*)";$/\1/p' "$nixfile")

if [[ $# -gt 0 ]]; then
  version="${1#v}"
else
  # 公開から MIN_AGE_DAYS 日（既定 2）経った最新の安定版
  cutoff=$(date -u -d "${MIN_AGE_DAYS:-2} days ago" +%FT%TZ)
  version=$(curl -fsSL "https://registry.npmjs.org/portless" \
    | jq -r --arg cutoff "$cutoff" \
        '.time | to_entries[] | select(.key | test("^[0-9]+\\.[0-9]+\\.[0-9]+$")) | select(.value < $cutoff) | .key' \
    | sort -V | tail -1)
fi

if [[ -z "$version" || "$version" == "null" ]]; then
  echo "could not determine the upstream version" >&2
  exit 1
fi

# 手で先に上げた場合、cutoff に阻まれて候補が古いことがある。巻き戻さない
if [[ "$(printf '%s\n%s\n' "$old_version" "$version" | sort -V | tail -1)" == "$old_version" ]]; then
  echo "portless is already at $old_version"
  exit 0
fi

echo "==> portless: $old_version -> $version"

sed -i \
  -e "s|^  version = \".*\";$|  version = \"${version}\";|" \
  -e "s|^    hash = \"sha256-[A-Za-z0-9+/=]*\";$|    hash = \"${fake_src}\";|" \
  "$nixfile"

echo "==> hash stubbed; run 'just fix-hashes portless' to resolve it"
git --no-pager diff --stat -- "$dir" || true

#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash coreutils curl jq just nix
# Bump herdr to the newest upstream release (or to $1).
#
# `just bump` covers the version / rev / src hash, but not the vendored
# build.zig.zon.nix: that file lives in the upstream tree and is taken in here
# to keep the package free of IFD (see default.nix).
set -euo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$dir/../.." && pwd)"
nixfile="$dir/default.nix"
repo="ogulcancelik/herdr"

old_version=$(sed -nE 's/^  version = "(.*)";$/\1/p' "$nixfile")

if [[ $# -gt 0 ]]; then
  version="${1#v}"
else
  # 公開から MIN_AGE_DAYS 日（既定 2）経った安定版のうち最大の version
  cutoff=$(date -u -d "${MIN_AGE_DAYS:-2} days ago" +%FT%TZ)
  token="${GITHUB_TOKEN:-${GH_TOKEN:-}}"
  version=$(curl -fsSL \
    ${token:+-H "Authorization: Bearer $token"} \
    "https://api.github.com/repos/$repo/releases?per_page=100" \
    | jq -r --arg cutoff "$cutoff" \
        '.[] | select((.draft or .prerelease) | not) | select(.published_at < $cutoff) | .tag_name' \
    | sed -e 's|^v||' | sort -V | tail -1)
fi

if [[ -z "$version" || "$version" == "null" ]]; then
  echo "could not determine the upstream version" >&2
  exit 1
fi

# 手で先に上げた場合、cutoff に阻まれて候補が古いことがある。巻き戻さない
if [[ "$(printf '%s\n%s\n' "$old_version" "$version" | sort -V | tail -1)" == "$old_version" ]]; then
  echo "herdr is already at $old_version"
  exit 0
fi

# default.nix を書き換える前に vendoring を済ませる。取得に失敗しても
# version と build.zig.zon.nix が食い違った状態を残さない
echo "==> vendoring build.zig.zon.nix from v$version"
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
curl -fsSL \
  ${token:+-H "Authorization: Bearer $token"} \
  "https://raw.githubusercontent.com/$repo/v$version/vendor/libghostty-vt/build.zig.zon.nix" \
  -o "$tmp"

# zon2nix の生成物。取り違えたら以降のビルドが謎の失敗をするので、ここで弾く
grep -q 'zon2nix' "$tmp" || {
  echo "fetched build.zig.zon.nix does not look like a zon2nix output" >&2
  exit 1
}

(cd "$root" && just bump herdr "$version")
mv "$tmp" "$dir/build.zig.zon.nix"

git --no-pager diff --stat -- "$dir" || true

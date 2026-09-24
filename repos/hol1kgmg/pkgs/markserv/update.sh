#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash coreutils curl jq nodejs gnused
# Bump markserv to the newest npm release (or to $1).
#
# `just bump` cannot handle this package: upstream publishes no git tags, so
# the source is an npm tarball and the lockfile is vendored here.
#
# The two hashes are left as placeholders on purpose — `just fix-hashes
# markserv` resolves them from the build failures.
set -euo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
nixfile="$dir/default.nix"

fake_src="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
fake_deps="sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB="

old_version=$(sed -nE 's/^  version = "(.*)";$/\1/p' "$nixfile")

if [[ $# -gt 0 ]]; then
  version="${1#v}"
else
  # 公開から MIN_AGE_DAYS 日（既定 2）経った最新の安定版
  cutoff=$(date -u -d "${MIN_AGE_DAYS:-2} days ago" +%FT%TZ)
  version=$(curl -fsSL "https://registry.npmjs.org/markserv" \
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
  echo "markserv is already at $old_version"
  exit 0
fi

echo "==> markserv: $old_version -> $version"

# Regenerate the vendored lockfile from the new tarball.
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
curl -fsSL "https://registry.npmjs.org/markserv/-/markserv-${version}.tgz" \
  | tar -xz -C "$work"
(cd "$work/package" && npm install --package-lock-only --ignore-scripts >/dev/null)
cp "$work/package/package-lock.json" "$dir/package-lock.json"

sed -i \
  -e "s|^  version = \".*\";$|  version = \"${version}\";|" \
  -e "s|^    hash = \"sha256-[A-Za-z0-9+/=]*\";$|    hash = \"${fake_src}\";|" \
  -e "s|^  npmDepsHash = \"sha256-[A-Za-z0-9+/=]*\";$|  npmDepsHash = \"${fake_deps}\";|" \
  "$nixfile"

echo "==> hashes stubbed; run 'just fix-hashes markserv' to resolve them"
git --no-pager diff --stat -- "$dir" || true

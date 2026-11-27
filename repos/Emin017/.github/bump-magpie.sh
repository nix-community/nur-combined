#!/usr/bin/env bash
# Bump pkgs/magpie to the latest release published by yetone/magpie-releases.
#
#   .github/bump-magpie.sh
#
# The script reads the newest release tag from the GitHub API, downloads the
# linux-amd64 asset, recomputes the fetchurl hashes (binary and desktop icon),
# rewrites pkgs/magpie/default.nix and builds the package to make sure the
# result still starts. It does not commit anything; that is up to the caller.
#
# Environment:
#   GITHUB_TOKEN      optional, lifts GitHub API rate limits
#   SKIP_NIX_BUILD=1  skip the `nix build .#magpie` verification
#
# In GitHub Actions the result is reported through $GITHUB_OUTPUT
# (`updated`, `previous`, `version`) so the workflow knows whether to commit.
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
nix_file="$repo_root/pkgs/magpie/default.nix"
release_repo="yetone/magpie-releases"
asset_name="magpie-linux-amd64"

gh_curl() {
  local -a args=(-fsSL --retry 3)
  if [ -n "${GITHUB_TOKEN:-}" ]; then
    args+=(-H "Authorization: Bearer ${GITHUB_TOKEN}")
  fi
  curl "${args[@]}" "$@"
}

report() {
  if [ -n "${GITHUB_OUTPUT:-}" ]; then
    printf '%s=%s\n' "$1" "$2" >>"$GITHUB_OUTPUT"
  fi
}

fail() {
  echo "error: $*" >&2
  exit 1
}

latest=$(
  gh_curl "https://api.github.com/repos/${release_repo}/releases/latest" |
    grep -o '"tag_name": *"[^"]*"' |
    head -n1 |
    sed 's/.*"\([^"]*\)"$/\1/'
)
latest=${latest#v}
[ -n "$latest" ] || fail "could not determine the latest release of ${release_repo}"

current=$(sed -n 's/^  version = "\(.*\)";$/\1/p' "$nix_file" | head -n1)
[ -n "$current" ] || fail "could not read the current version from ${nix_file}"

echo "current: ${current}"
echo "latest:  ${latest}"

if [ "$current" = "$latest" ]; then
  echo "already at the latest release, nothing to do"
  report updated false
  exit 0
fi

newest=$(printf '%s\n%s\n' "$current" "$latest" | sort -V | tail -n1)
if [ "$newest" != "$latest" ]; then
  echo "the latest release (${latest}) is not newer than ${current}, not downgrading"
  report updated false
  exit 0
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

echo "downloading ${asset_name} v${latest}"
gh_curl "https://github.com/${release_repo}/releases/download/v${latest}/${asset_name}" \
  -o "$tmp/${asset_name}"
[ "$(head -c4 "$tmp/${asset_name}" | od -An -tx1 | tr -d ' \n')" = "7f454c46" ] ||
  fail "${asset_name} is not an ELF binary"
src_hash=$(nix hash file --type sha256 --sri "$tmp/${asset_name}")
echo "src hash:  ${src_hash}"

# The desktop icon lives in the source repository (yetone/magpie), whose tags
# can lag behind the release repository. A missing tag is not fatal: keep the
# icon that is already packaged.
icon_hash=$(sed -n 's/^    hash = "\(sha256-.*\)";$/\1/p' "$nix_file" | tail -n1)
old_icon_hash=$icon_hash
if gh_curl -H 'Accept: application/vnd.github.raw' \
  "https://api.github.com/repos/yetone/magpie/contents/site/public/img/icon-256.png?ref=v${latest}" \
  -o "$tmp/icon-256.png" 2>/dev/null; then
  icon_hash=$(nix hash file --type sha256 --sri "$tmp/icon-256.png")
fi
if [ "$icon_hash" = "$old_icon_hash" ]; then
  echo "icon:      unchanged"
else
  echo "icon hash: ${icon_hash}"
fi

awk -v version="$latest" -v src="$src_hash" -v icon="$icon_hash" '
  /^  version = "/ { sub(/"[^"]*"/, "\"" version "\"") }
  /^  src = fetchurl \{/ { in_src = 1 }
  /^  icon = fetchurl \{/ { in_src = 0; in_icon = 1 }
  in_src && /^    hash = "/ { sub(/"[^"]*"/, "\"" src "\""); in_src = 0 }
  in_icon && /^    hash = "/ { sub(/"[^"]*"/, "\"" icon "\""); in_icon = 0 }
  { print }
' "$nix_file" >"$tmp/default.nix"
mv "$tmp/default.nix" "$nix_file"

if [ "${SKIP_NIX_BUILD:-0}" != "1" ]; then
  echo "building magpie ${latest} to verify the bump"
  ( cd "$repo_root" && nix build .#magpie --no-link --print-out-paths )
fi

report updated true
report previous "$current"
report version "$latest"
echo "bumped magpie ${current} -> ${latest}"

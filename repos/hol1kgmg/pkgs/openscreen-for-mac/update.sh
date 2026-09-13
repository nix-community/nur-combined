#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash curl jq nix
# Bump openscreen-for-mac to the newest upstream release (or to $1).
#
# `just bump` cannot handle this package: it looks for a fetchFromGitHub
# owner/repo pair, and this one pins two prebuilt .dmg release assets instead.
set -euo pipefail

nixfile="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/default.nix"
repo="getopenscreen/openscreen"

old_version=$(sed -nE 's/^  version = "(.*)";$/\1/p' "$nixfile")

if [[ $# -gt 0 ]]; then
  version="${1#v}"
else
  version=$(curl -fsSL \
    ${GITHUB_TOKEN:+-H "Authorization: Bearer $GITHUB_TOKEN"} \
    "https://api.github.com/repos/$repo/releases/latest" | jq -r '.tag_name')
  version="${version#v}"
fi

if [[ -z "$version" || "$version" == "null" ]]; then
  echo "could not determine the upstream version" >&2
  exit 1
fi

if [[ "$version" == "$old_version" ]]; then
  echo "openscreen-for-mac is already at $version"
  exit 0
fi

echo "==> openscreen-for-mac: $old_version -> $version"

base="https://github.com/$repo/releases/download/v$version"

prefetch() {
  local raw
  raw=$(nix-prefetch-url --type sha256 "$1" 2>/dev/null | tail -1)
  [[ -n "$raw" ]] || { echo "failed to fetch $1" >&2; exit 1; }
  nix hash convert --hash-algo sha256 --to sri "$raw"
}

aarch64_hash=$(prefetch "$base/Openscreen-macOS-Apple-Silicon-$version.dmg")
echo "==> aarch64-darwin $aarch64_hash"
x86_64_hash=$(prefetch "$base/Openscreen-macOS-Intel-$version.dmg")
echo "==> x86_64-darwin  $x86_64_hash"

# Rewrite each `hash = ...` line under the system attribute it belongs to; the
# two lines are otherwise identical, so they cannot be matched on their own.
awk -v version="$version" \
    -v aarch64_hash="$aarch64_hash" \
    -v x86_64_hash="$x86_64_hash" '
  /^  version = "/ { print "  version = \"" version "\";"; next }
  /aarch64-darwin = \{/ { cur = "aarch64" }
  /x86_64-darwin = \{/  { cur = "x86_64" }
  /^      hash = "/ {
    if (cur == "aarch64") { print "      hash = \"" aarch64_hash "\";"; next }
    if (cur == "x86_64")  { print "      hash = \"" x86_64_hash "\";";  next }
  }
  { print }
' "$nixfile" > "$nixfile.new"
mv "$nixfile.new" "$nixfile"

git --no-pager diff -- "$nixfile" || true

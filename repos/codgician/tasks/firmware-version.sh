#!/usr/bin/env bash
# Resolve upstream release metadata at update time, never during a Nix build.
set -euo pipefail

package=$1
revision=$2
case "$package" in
  redrix-ec)
    fork=https://github.com/codgician/redrix-ec
    upstream=https://chromium.googlesource.com/chromiumos/platform/ec
    pattern='v[0-9]*'
    ;;
  redrix-coreboot)
    fork=https://github.com/codgician/coreboot
    upstream=https://github.com/MrChromebox/coreboot
    # MrChromebox's release tags are not ancestors of its next branch.
    # The ordinary coreboot release tags describe the actual upstream base.
    pattern='[0-9]*'
    ;;
  *) echo "Unknown firmware package: $package" >&2; exit 1 ;;
esac
[[ "$revision" =~ ^[0-9a-f]{40}$ ]]

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
git init --bare -q "$work/repo"
git -C "$work/repo" fetch --quiet --filter=tree:0 --no-tags "$fork" "$revision"
git -C "$work/repo" rev-list "$revision" > "$work/ancestors"
git ls-remote --tags "$upstream" "refs/tags/$pattern" > "$work/tags"

# Import only release tags whose commits are ancestors of the exact fork pin.
# Use peeled commits for annotated tags; no unrelated branches or blobs needed.
awk 'NR == FNR { reachable[$1] = 1; next }
  $1 in reachable { sub(/\^\{\}$/, "", $2); print $1, $2 }
' "$work/ancestors" "$work/tags" > "$work/reachable-tags"
while read -r commit ref; do
  git -C "$work/repo" update-ref "$ref" "$commit"
done < "$work/reachable-tags"
description=$(git -C "$work/repo" describe --tags --long --match "$pattern" "$revision")

case "$package" in
  redrix-ec)
    # Match upstream getversion.sh: add distance to the tag's patch component.
    [[ "$description" =~ ^v([0-9]+)\.([0-9]+)\.([0-9]+)-([0-9]+)-g[0-9a-f]+$ ]]
    version="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}.$((10#${BASH_REMATCH[3]} + 10#${BASH_REMATCH[4]}))-g${revision:0:8}"
    identity="redrix_$version"
    if (( ${#identity} > 31 )); then
      echo "EC firmware identity exceeds 31 bytes: $identity" >&2
      exit 1
    fi
    ;;
  redrix-coreboot)
    [[ "$description" =~ ^([0-9][0-9.]*)-([0-9]+)-g[0-9a-f]+$ ]]
    version="${BASH_REMATCH[1]}"
    if (( BASH_REMATCH[2] != 0 )); then
      version+="-unstable.${BASH_REMATCH[2]}"
    fi
    version+="-g${revision:0:12}"
    ;;
esac
printf '%s\n' "$version"

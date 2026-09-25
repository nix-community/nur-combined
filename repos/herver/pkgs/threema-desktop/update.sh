#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl gnused gnugrep nix ostree

set -eu -o pipefail

dirname=$(dirname "$0" | xargs realpath)
attr=threema-desktop
nix_file="$dirname/default.nix"

repo_url="https://releases.threema.ch/flatpak/threema-desktop/"
ref="app/ch.threema.threema-desktop/x86_64/master"
metainfo="export/share/metainfo/ch.threema.threema-desktop.metainfo.xml"

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT

# Threema publishes no download without the Flatpak indirection, so a full
# checkout is needed both to learn the current version and to hash the tree.
ostree --repo="$workdir/repo" init --mode=archive-z2
ostree --repo="$workdir/repo" remote add --no-gpg-verify threema "$repo_url"
ostree --repo="$workdir/repo" pull --depth=-1 threema "$ref"
commit=$(ostree --repo="$workdir/repo" rev-parse "threema:$ref")
ostree --repo="$workdir/repo" checkout -U "threema:$ref" "$workdir/tree"

# AppStream metadata lists the current release first.
latestVersion=$(sed -n 's/.*<release version="\([^"]*\)".*/\1/p' "$workdir/tree/$metainfo" | head -1)
# `~` is not a legal character in a Nix store path.
latestVersion=${latestVersion//\~/-}

currentVersion=$(grep 'version = ' "$nix_file" | head -1 | sed 's/.*"\(.*\)".*/\1/')
currentCommit=$(grep 'flatpakCommit = ' "$nix_file" | sed 's/.*"\(.*\)".*/\1/')

if [ -z "$latestVersion" ]; then
  echo "$attr: failed to parse the release version from $metainfo" >&2
  exit 1
fi

if [ "$currentVersion" = "$latestVersion" ] && [ "$currentCommit" = "$commit" ]; then
  echo "$attr is up-to-date: ${currentVersion}"
  exit 0
fi

echo "$attr: $currentVersion -> $latestVersion ($currentCommit -> $commit)"

sriHash=$(nix hash path --type sha256 --sri "$workdir/tree")

sed -E \
  -e "s|version = \"$currentVersion\";|version = \"$latestVersion\";|" \
  -e "s|flatpakCommit = \"[a-f0-9]+\";|flatpakCommit = \"$commit\";|" \
  -e "s|outputHash = \"sha256-[^\"]+\";|outputHash = \"$sriHash\";|" \
  -i "$nix_file"

echo "Updated $nix_file"

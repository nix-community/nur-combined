#!/usr/bin/env nix-shell
#! nix-shell -i bash -p curl jq nix nix-update nixfmt-rfc-style python3
# shellcheck shell=bash

# Bumps the port and the winrecomp toolkit pin it is built with.  winrecomp
# has no tags, so the toolkit follows its main branch.
set -euo pipefail

root=$(git rev-parse --show-toplevel)
cd "$root"
dir=by-name/gr/grand-theft-auto-2-recompiled

if [ $# -ge 1 ]; then
    tag=v${1#v}
else
    tag=$(
        curl -fsSL --retry 3 "https://api.github.com/repos/almost-drowned-rat/Grand-Theft-Auto-2-Recompiled/tags?per_page=100" |
            jq -r '.[].name' |
            grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' |
            sort -V |
            tail -n 1
    )
fi
if [ -z "$tag" ]; then
    echo "update.sh: no release tag found" >&2
    exit 1
fi
version=${tag#v}
echo "update.sh: $version"

nix-update --version "$version" grand-theft-auto-2-recompiled

rev=$(git ls-remote https://github.com/almost-drowned-rat/winrecomp.git refs/heads/main | cut -f1)
if [ -z "$rev" ]; then
    echo "update.sh: cannot resolve winrecomp main" >&2
    exit 1
fi
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
nix store prefetch-file --json \
    "https://github.com/almost-drowned-rat/winrecomp/archive/$rev.tar.gz" > "$tmp/meta.json"
archive=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["storePath"])' "$tmp/meta.json")
mkdir "$tmp/src"
tar -xf "$archive" -C "$tmp/src" --strip-components=1
hash=$(nix hash path --sri "$tmp/src")

cat > "$dir/toolkit.nix" <<EOF
{ fetchFromGitHub }:

fetchFromGitHub {
  owner = "almost-drowned-rat";
  repo = "winrecomp";
  rev = "$rev";
  hash = "$hash";
}
EOF

nixfmt "$dir/package.nix" "$dir/toolkit.nix"

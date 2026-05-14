#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash jq nix-prefetch-github yarn-berry_4.yarn-berry-fetcher

# based on
# https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/javascript.section.md

set -e
set -u

# set -x # debug
export RUST_BACKTRACE=full # debug

cd "$(dirname "$0")"

# TODO parse from package.nix
owner=mifi
repo=lossless-cut

git_remote="https://github.com/$owner/$repo"



# get new version
tag=$(git ls-remote --tags --refs "$git_remote" | cut -c52- | sort -V -r | head -n1)
version=${tag#v} # remove leading "v"
# tag="v${version}"

old_version=$(grep -m1 'version = "' package.nix | cut -d'"' -f2)

if [ "$version" == "$old_version" ]; then
  echo "already up to date"
  exit
fi



if false; then
# if true; then

# use cached values

version=3.68.1
src_hash=sha256-9eyfhJDQD3cYTZ3rdASS2fSloPa+/dvxSBmYQhKcPXo=
offlineCache_hash=sha256-0HMeaTm4jx5FFwTVeqQOJMfTlWnNKTsJRjQEGz1zJmY=

else

# slow...

src_hash="$(nix-prefetch-github --rev "$tag" "$owner" "$repo" | jq -r .hash)"
echo "src_hash: $src_hash"

wget -N "$git_remote/raw/$tag/yarn.lock"

stat yarn.lock
stat missing-hashes.json || true

yarn-berry-fetcher missing-hashes yarn.lock >missing-hashes.json

offlineCache_hash="$(yarn-berry-fetcher prefetch yarn.lock missing-hashes.json)"

echo "src_hash: $src_hash"
echo "offlineCache_hash: $offlineCache_hash"

fi



echo "patching package.nix"
s=""
s+='s|version = "'"$old_version"'";|version = "'"$version"'";|;'
s+='s|hash = ".*"; # src.hash|hash = "'"$src_hash"'"; # src.hash|;'
s+='s|hash = ".*"; # offlineCache.hash|hash = "'"$offlineCache_hash"'"; # offlineCache.hash|;'
sed -i -E "$s" package.nix



echo "TODO:"
echo "git add ${PWD@Q}/{package.nix,missing-hashes.json}"
echo "git commit -m 'losslesscut: $old_version -> $version'"

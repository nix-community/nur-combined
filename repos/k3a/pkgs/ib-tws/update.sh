#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl gnused gnugrep

set -eu -o pipefail

dirname=$(dirname "$0" | xargs realpath)
nixpkgs=$(realpath "${dirname}/../..")
attr=ib-tws
nix_file="$dirname/default.nix"

url="https://download2.interactivebrokers.com/installers/tws/latest-standalone/tws-latest-standalone-linux-x64.sh"
latestEtagHash=$(curl -sI $url | grep ETag | sed -E 's/.*"([^:]+):.*/\1/')

currentEtagHash=$(nix-instantiate --eval -E "with import $nixpkgs {}; $attr.etagHash or (builtins.parseDrvName $attr.name).etagHash" | tr -d '"')
currentVersion=$(nix-instantiate --eval -E "with import $nixpkgs {}; $attr.version or (builtins.parseDrvName $attr.name).version" | tr -d '"')

if [ "$currentEtagHash" = "$latestEtagHash" ]; then
    echo "ib-tws is up-to-date: ${currentVersion}"
    exit 0
fi

# download install script, get hash and store path
{
    read hash
    read installScriptPath
} < <(nix-prefetch-url "$url" --type sha256 --print-path)

# convert to SRI hash
sriHash=$(nix hash to-sri --type sha256 $hash)

# extract install script to extract the version string
src="$(mktemp -d /tmp/ib-tws-src.XXX)"
pushd "$src"

INSTALL4J_TEMP="$src" sh "$installScriptPath" __i4j_extract_and_exit
latestVersion=$(grep buildInfo "$src/"*.dir/i4jparams.conf | sed -E 's/.*name="buildInfo" value="Build (\S+) .*/\1/')

popd
rm -r "$src"

# update hash, version and etagHash
sed -E \
    -e "s|hash = \"[a-zA-Z0-9\/+-=]*\";|hash = \"$sriHash\";|" \
    -e "s|version = \"$currentVersion\";|version = \"$latestVersion\";|" \
    -e "s|etagHash = \"$currentEtagHash\";|etagHash = \"$latestEtagHash\";|" \
    -i "$nix_file"

# prepare a commit for automation
cmd=`echo "git commit -a -m \"$attr: $currentVersion -> $latestVersion\""`

if [ -n "$GITHUB_ACTION" ]; then
    eval $cmd
else
    echo $cmd
fi

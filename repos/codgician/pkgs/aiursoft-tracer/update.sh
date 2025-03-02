#!/usr/bin/env nix-shell
#!nix-shell -i bash -p git curl jq nodejs prefetch-npm-deps nix-prefetch-git

nur="$(git rev-parse --show-toplevel)"
path="$nur/pkgs/aiursoft-tracer/default.nix"
prefetch=$(nix-prefetch-git --url https://github.com/AiursoftWeb/Tracer --no-deepClone)

new_rev=$(echo "$prefetch" | jq -r '.rev')
new_version="0-unstable-"$(echo "$prefetch" | jq -r '.date' | sed 's/T.*//')
old_rev="$(sed -nE 's/\s*rev = "(.*)".*/\1/p' $path)"
old_version="$(sed -nE 's/\s*version = "(.*)".*/\1/p' $path)"

if [[ "$new_rev" == "$old_rev" ]]; then
    echo "Current revision $old_rev is up-to-date."
    exit 0
fi

# Update the revision
hash=$(echo $prefetch | jq -r '.hash')
sed -i -e "s,rev = \"$old_rev\",rev = \"$new_rev\"," \
    -e "s,version = \"$old_version\",version = \"$new_version\"," \
    -e "s,hash = \"sha256-.*\",hash = \"$hash\"," "$path" 

# Fetch npm deps
tmpdir=$(mktemp -d)
curl -O --output-dir $tmpdir "https://raw.githubusercontent.com/AiursoftWeb/Tracer/$new_rev/src/Aiursoft.Tracer/wwwroot/package-lock.json"
curl -O --output-dir $tmpdir "https://raw.githubusercontent.com/AiursoftWeb/Tracer/$new_rev/src/Aiursoft.Tracer/wwwroot/package.json"
pushd $tmpdir
npm_hash=$(prefetch-npm-deps package-lock.json)
sed -i 's#npmDepsHash = "[^"]*"#npmDepsHash = "'"$npm_hash"'"#' $path
popd
rm -rf $tmpdir

# Update nuget deps
eval "$(nix-build . -A aiursoft-tracer.fetch-deps --no-out-link)"

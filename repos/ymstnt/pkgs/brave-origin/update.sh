#!/usr/bin/env nix-shell
#!nix-shell --pure --keep NIX_PATH -i bash -p bash cacert curl jq nix

FILE="default.nix"

VERSION=$(curl -s https://api.github.com/repos/brave/brave-browser/releases | jq -r 'map(select(any(.assets[]; .name | test("brave-origin_.*_amd64.deb"))))[0].tag_name' | sed 's/^v//')

if [ -z "$VERSION" ] || [ "$VERSION" == "null" ]; then
    echo "Failed to fetch version. Rate limited?"
    exit 1
fi

sed -i -E "s/version = \".*\";/version = \"$VERSION\";/" "$FILE"

URL="https://github.com/brave/brave-browser/releases/download/v${VERSION}/brave-origin_${VERSION}_amd64.deb"
HASH=$(nix store prefetch-file --json "$URL" 2>/dev/null | jq -r .hash)

if [ -z "$HASH" ]; then
    echo "Failed to prefetch URL."
    exit 1
fi

sed -i -E "s|hash = \".*\";|hash = \"$HASH\";|" "$FILE"

echo "Updated $FILE to $VERSION"

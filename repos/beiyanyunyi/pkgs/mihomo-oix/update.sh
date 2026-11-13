#!/usr/bin/env nix
#!nix shell nixpkgs#bash nixpkgs#gh nixpkgs#jq --command bash
set -euo pipefail

# Usage: ./update.sh [revision], e.g. ./update.sh 9910e8e
# Pre-Alpha is rolling: discover the version from asset names, not the tag.
JSON_FILE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/versions.json"
REVISION=${1:-}
if (( $# > 1 )) || [[ -n "$REVISION" && ! "$REVISION" =~ ^[0-9a-f]+$ ]]; then
  echo "Usage: $0 [revision]" >&2
  exit 1
fi

TMP=$(mktemp "${JSON_FILE}.tmp.XXXXXX")
trap 'rm -f "$TMP" "$TMP.next" "$TMP.release"' EXIT
gh api repos/vernesong/mihomo-oix/releases/tags/Pre-Alpha > "$TMP.release"
cp "$JSON_FILE" "$TMP"

VERSION=""
for system in $(jq -r 'keys[] | select(. != "version")' "$JSON_FILE"); do
  name=$(jq -r --arg system "$system" '.[$system].name' "$JSON_FILE")
  # Require exactly one matching asset per platform; never choose arbitrarily
  # while a rolling release contains a mixture of old and new files.
  asset=$(jq -ce --arg name "$name" --arg revision "$REVISION" '
    [.assets[]
      | select(.name | startswith($name + "-alpha-oix-"))
      | . + {version: (.name | ltrimstr($name + "-") | rtrimstr(".gz"))}
      | select(.name == ($name + "-" + .version + ".gz"))
      | select(.version | test("^alpha-oix-[0-9a-f]+$"))
      | select($revision == "" or .version == ("alpha-oix-" + $revision))]
    | if length == 1 then .[0]
      else error("expected exactly one release asset for " + $name) end
  ' "$TMP.release")
  version=$(jq -r .version <<< "$asset")
  if [[ -n "$VERSION" && "$VERSION" != "$version" ]]; then
    echo "Release assets have inconsistent versions: $VERSION and $version" >&2
    exit 1
  fi
  VERSION=$version
  url=$(jq -r .browser_download_url <<< "$asset")
  echo "Prefetching $system: $version"
  hash=$(nix store prefetch-file "$url" --json | jq -er .hash)
  jq --arg system "$system" --arg hash "$hash" --arg version "$VERSION" \
    '.version = $version | .[$system].hash = $hash' "$TMP" > "$TMP.next"
  mv "$TMP.next" "$TMP"
done

# Replace the manifest only after every platform has been downloaded successfully.
mv "$TMP" "$JSON_FILE"
echo "Updated $JSON_FILE to $VERSION"

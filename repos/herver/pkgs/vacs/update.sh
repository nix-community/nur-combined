#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl gnugrep gnused jq nix nix-update

set -eu -o pipefail

dirname=$(dirname "$0" | xargs realpath)
root=$(realpath "$dirname/../..")
attr=vacs
nix_file="$dirname/default.nix"

currentVersion=$(grep 'version = ' "$nix_file" | head -1 | sed 's/.*"\(.*\)".*/\1/')

# The repo also publishes vacs-server releases; only stable client tags count.
# Prereleases (-rc/-beta) are built with the `rc` feature and talk to the dev backend.
latestVersion=$(curl -s 'https://api.github.com/repos/vacs-project/vacs/releases?per_page=100' \
  | jq -r '[ .[] | select(.draft == false and .prerelease == false) | .tag_name
             | select(test("^vacs-client-v[0-9]+\\.[0-9]+\\.[0-9]+$")) | sub("^vacs-client-v"; "") ]
           | max_by(split(".") | map(tonumber)) // "ERROR"')

if [ -z "$latestVersion" ] || [ "$latestVersion" = "ERROR" ]; then
  echo "$attr: failed to fetch latest version from GitHub" >&2
  exit 1
fi

if [ "$currentVersion" = "$latestVersion" ]; then
  echo "$attr is up-to-date: ${currentVersion}"
  exit 0
fi

echo "$attr: $currentVersion -> $latestVersion"

# Recomputes the source hash, cargoHash and the npmDeps hash in one go.
cd "$root"
nix-update --file ./default.nix "$attr" --version "$latestVersion"

echo "Updated $nix_file"

#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl gnugrep gnused jq nix nix-update

set -eu -o pipefail

dirname=$(dirname "$0" | xargs realpath)
root=$(realpath "$dirname/../..")
attr=vaccfr-installer
nix_file="$dirname/default.nix"

currentTag=$(grep 'tag = "' "$nix_file" | head -1 | sed 's/.*"\(.*\)".*/\1/')

# Releases are tagged by AIRAC cycle (e.g. 2610_1); the installer version lives in the Cargo workspace.
latestTag=$(curl -s 'https://api.github.com/repos/vaccfr/Sector-Files/releases/latest' | jq -r '.tag_name // "ERROR"')

if [ -z "$latestTag" ] || [ "$latestTag" = "ERROR" ]; then
  echo "$attr: failed to fetch latest release from GitHub" >&2
  exit 1
fi

if [ "$currentTag" = "$latestTag" ]; then
  echo "$attr is up-to-date: ${currentTag}"
  exit 0
fi

latestVersion=$(curl -s "https://raw.githubusercontent.com/vaccfr/Sector-Files/$latestTag/installer/Cargo.toml" \
  | grep -m1 '^version = ' | sed 's/.*"\(.*\)".*/\1/')

echo "$attr: $currentTag -> $latestTag (installer $latestVersion)"

sed -i "s/tag = \"$currentTag\";/tag = \"$latestTag\";/" "$nix_file"

# Recomputes the source hash, cargoHash and the bunDeps hash.
cd "$root"
nix-update --file ./default.nix "$attr" --version "$latestVersion" --subpackage bunDeps

echo "Updated $nix_file"

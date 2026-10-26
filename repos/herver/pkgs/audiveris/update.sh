#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl gnused gnugrep jq nix

set -eu -o pipefail

dirname=$(dirname "$0" | xargs realpath)
attr=audiveris
nix_file="$dirname/default.nix"

currentVersion=$(grep 'version = ' "$nix_file" | head -1 | sed 's/.*"\(.*\)".*/\1/')

# Newest stable X.Y.Z tag, ranked numerically (never trust /releases/latest).
latestVersion=$(curl -s 'https://api.github.com/repos/Audiveris/audiveris/releases?per_page=100' \
  | jq -r '[ .[] | select(.draft==false and .prerelease==false) | .tag_name
             | select(test("^[0-9]+\\.[0-9]+\\.[0-9]+$")) ]
           | if length==0 then "ERROR"
             else max_by(split(".") | map(tonumber)) end')

if [ -z "$latestVersion" ] || [ "$latestVersion" = "null" ] || [ "$latestVersion" = "ERROR" ]; then
  echo "$attr: failed to fetch latest version from GitHub" >&2
  exit 1
fi

newer=$(printf '%s\n%s\n' "$currentVersion" "$latestVersion" | sort -V | tail -1)
if [ "$latestVersion" = "$currentVersion" ] || [ "$newer" = "$currentVersion" ]; then
  echo "$attr is up-to-date: ${currentVersion}"
  exit 0
fi

echo "$attr: $currentVersion -> $latestVersion"

url="https://github.com/Audiveris/audiveris/releases/download/${latestVersion}/Audiveris-${latestVersion}-ubuntu24.04-x86_64.deb"
hash=$(nix-prefetch-url "$url" --type sha256)
sriHash=$(nix hash convert --hash-algo sha256 --to sri "$hash")

sed -E \
  -e "s|version = \"$currentVersion\";|version = \"$latestVersion\";|" \
  -e "s|hash = \"sha256-[a-zA-Z0-9/+=]+\";|hash = \"$sriHash\";|" \
  -i "$nix_file"

echo "Updated $nix_file"

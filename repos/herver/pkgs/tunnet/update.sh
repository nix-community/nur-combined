#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl gnused gnugrep gawk jq nix

set -eu -o pipefail

dirname=$(dirname "$0" | xargs realpath)
attr=tunnet
nix_file="$dirname/default.nix"

currentVersion=$(sed -nE 's/^\s*version = "(.*)";/\1/p' "$nix_file" | head -1)
latestVersion=$(curl -s https://api.github.com/repos/tunnetio/Tunnet/releases/latest \
  | jq -r '.tag_name' | sed 's/^v//')

if [[ -z "$latestVersion" || "$latestVersion" == "null" ]]; then
  echo "$attr: could not resolve the latest release tag" >&2
  exit 1
fi

if [[ "$currentVersion" == "$latestVersion" ]]; then
  echo "$attr is up-to-date ($currentVersion)"
  exit 0
fi

# Upstream publishes a .sha256 next to every asset, so nothing needs downloading.
update_hash() {
  local system=$1 target=$2 sha sri
  sha=$(curl -fsSL "https://github.com/tunnetio/Tunnet/releases/download/v${latestVersion}/tunnet-headless-${latestVersion}-${target}.tar.gz.sha256" | awk '{print $1}')
  sri=$(nix hash convert --hash-algo sha256 --to sri "$sha")
  # Restrict the rewrite to this system's block: key line, target line, hash line.
  sed -E -i "/\"$system\" = \{/,+2 s|hash = \"sha256-[^\"]+\";|hash = \"$sri\";|" "$nix_file"
}

sed -E -i "s|version = \"$currentVersion\";|version = \"$latestVersion\";|" "$nix_file"
update_hash x86_64-linux x86_64-unknown-linux-gnu
update_hash aarch64-linux aarch64-unknown-linux-gnu

echo "$attr: $currentVersion -> $latestVersion"

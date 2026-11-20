#! /usr/bin/env nix-shell
#! nix-shell -i bash -p curl jq nix coreutils unzip
set -euo pipefail

cd "$(dirname "$0")"

tag=$(curl -fsSL https://api.github.com/repos/Novavero-AI/nova-nix/releases/latest | jq -r .tag_name)
version=${tag#v}
url="https://github.com/Novavero-AI/nova-nix/releases/download/${tag}/nova-nix-windows-x64.zip"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

curl -fsSL -o "$tmp/nova.zip" "$url"
unzip -q "$tmp/nova.zip" -d "$tmp"
hash=$(nix hash path "$tmp/nova-nix-windows-x64")

sed -i \
  -e "s|version = \"[^\"]*\";|version = \"${version}\";|" \
  -e "s|hash = \"sha256-[A-Za-z0-9+/=]*\";|hash = \"${hash}\";|" \
  package.nix

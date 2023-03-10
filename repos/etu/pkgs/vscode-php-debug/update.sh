#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix curl gnused yarn yarn2nix nix-prefetch-github coreutils jq

set -euo pipefail

latestVersion="$(curl -s "https://api.github.com/repos/xdebug/vscode-php-debug/releases?per_page=1" | jq -r ".[0].tag_name" | sed 's/^v//')"
currentVersion=$(nix-instantiate --eval -E "with import ./. {}; vscode-php-debug.version" | tr -d '"')

if [[ "$currentVersion" == "$latestVersion" ]]; then
    echo "vscode-php-debug is up-to-date: $currentVersion"
    exit 0
fi

# Go to script dir
cd "$(dirname "${BASH_SOURCE[0]}")"

# Remove the old package files.
rm yarn.nix yarn.lock package.json package-lock.json

# Download and update the package.json and package-lock.json files.
curl https://raw.githubusercontent.com/xdebug/vscode-php-debug/v$latestVersion/package.json --output package.json
curl https://raw.githubusercontent.com/xdebug/vscode-php-debug/v$latestVersion/package-lock.json --output package-lock.json

# Convert the package.json and pcakage-lock.json to a yarn lock file.
yarn import

# Get needed hashes for locking
srcHash=$(nix-prefetch-github xdebug vscode-php-debug --rev v${latestVersion} | jq -r .sha256)

# Remove the temporary node_modules directory.
rm -rf node_modules

# Output a yarn.nix file to build from.
yarn2nix > yarn.nix

# Write a lock file
cat > pin.json << EOF
{
  "version": "$latestVersion",
  "srcHash": "$srcHash"
}
EOF

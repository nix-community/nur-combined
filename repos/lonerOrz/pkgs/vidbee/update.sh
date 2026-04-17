#!/usr/bin/env bash
set -euo pipefail

# https://github.com/nexmoe/VidBee
owner="nexmoe"
repo="VidBee"
pname="vidbee"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
package_file="$script_dir/default.nix"

echo "Checking latest version"
raw_tag=$("$script_dir/../../.github/script/github-tag-fetch.sh" "${owner}/${repo}")
latest_version="${raw_tag#v}"
echo "Latest version: $latest_version"

current_version=$(grep -oP '^\s*version\s*=\s*"\K[0-9.]+' "$package_file")
echo "Current version in default.nix: $current_version"

if [[ "$latest_version" == "$current_version" ]]; then
    echo "✅ Package is already at the latest version ($current_version). Nothing to do."
    exit 0
fi

echo "⚡ Update needed: $current_version -> $latest_version"

bash +x $script_dir/patch.sh "$raw_tag"

# Dummy hashes
dummy_src="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
dummy_pnpm="sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB="

# Update version
sed -i -E "s|(version\s*=\s*\")[0-9.]+(\")|\1${latest_version}\2|" "$package_file"

echo "Building to get src hash..."
sed -i -E '/baseSrc =/,/hash =/ s/(hash = ")[^"]*(")/\1'"$dummy_src"'\2/' "$package_file"
output=$(nix build ./#vidbee 2>&1 || true)

src_hash=$(echo "$output" | grep -oP 'got:\s*\Ksha256-[A-Za-z0-9+/=]+' | head -n1)

if [ -z "$src_hash" ]; then
    echo "❌ Failed to extract src hash from build output"
    echo "$output" | tail -n30
    exit 1
fi

echo "New src hash: $src_hash"
sed -i -zE "s|${dummy_src}|${src_hash}|" "$package_file"

echo "Building to get pnpmDeps hash..."
sed -i -E '/pnpmDeps = fetchPnpmDeps/,/hash =/ s/(hash = ")[^"]*(")/\1'"$dummy_pnpm"'\2/' "$package_file"
output=$(nix build ./#vidbee 2>&1 || true)

pnpm_hash=$(echo "$output" | grep -oP 'got:\s*\Ksha256-[A-Za-z0-9+/=]+' | head -n1)

if [ -z "$pnpm_hash" ]; then
    echo "❌ Failed to extract pnpmHash from build output"
    echo "$output" | tail -n30
    exit 1
fi

echo "New pnpmHash: $pnpm_hash"
sed -i -zE "s|${dummy_pnpm}|${pnpm_hash}|" "$package_file"

echo "✅ Update completed successfully!"
echo "Package is now at version $latest_version."

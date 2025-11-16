#!/usr/bin/env bash
set -euo pipefail

owner="Fabric-Development"
repo="fabric-cli"
pname="fabric-cli"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
package_file="$script_dir/default.nix"

# 检查是否需要更新
echo "Checking latest version"
latest_rev=$(git ls-remote "https://github.com/$owner/$repo.git" HEAD | cut -f1)
echo "Latest commit: $latest_rev"

current_rev=$(grep -oP 'rev\s*=\s*"\K[^"]+' "$package_file" | head -n1)
echo "Current rev in default.nix: $current_rev"

if [[ "$latest_rev" == "$current_rev" ]]; then
    echo "✅ Package is already at the latest commit ($current_rev). Nothing to do."
    exit 0
fi

echo "⚡ Update needed: $current_rev -> $latest_rev"

# 第一次构建获取 src hash
dummy_src="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
sed -i "s|rev = \".*\"|rev = \"$latest_rev\"|" "$package_file"
sed -i "s|hash = \".*\"|hash = \"$dummy_src\"|" "$package_file"

echo "Building to get src hash..."
output=$(nix build "$script_dir/../.."#$pname 2>&1 || true)

src_hash=$(echo "$output" | grep 'got:' | head -n1 | grep -oP 'sha256-[a-zA-Z0-9+/=]+')
if [ -z "$src_hash" ]; then
    echo "❌ Failed to extract src hash from build output"
    echo "$output" | tail -n20
    exit 1
fi
echo "New src hash: $src_hash"
sed -i "s|$dummy_src|$src_hash|" "$package_file"

# 第二次构建获取 vendorHash
dummy_vendor="sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB="
sed -i "s|vendorHash = \".*\"|vendorHash = \"$dummy_vendor\"|" "$package_file"

echo "Building to get vendorHash..."
output=$(NIX_BUILD_CORES=1 nix build "$script_dir/../.."#$pname 2>&1 || true)

vendor_hash=$(echo "$output" | grep 'got:' | tail -n1 | grep -oP 'sha256-[a-zA-Z0-9+/=]+')
if [ -z "$vendor_hash" ]; then
    echo "❌ Failed to extract vendor hash from build output"
    echo "$output" | tail -n20
    exit 1
fi
echo "New vendor hash: $vendor_hash"
sed -i "s|$dummy_vendor|$vendor_hash|" "$package_file"

echo "✅ Update completed successfully!"
echo "Package is now at commit $latest_rev"

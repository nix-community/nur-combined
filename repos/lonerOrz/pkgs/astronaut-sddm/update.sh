#!/usr/bin/env bash
set -euo pipefail

# https://github.com/Keyitdev/sddm-astronaut-theme
owner="Keyitdev"
repo="sddm-astronaut-theme"
package_name="astronaut-sddm"
pname="astronaut"

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

# 构建获取 hash
dummy_src="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
sed -i "s|rev = \".*\"|rev = \"$latest_rev\"|" "$package_file"
sed -i "s|hash = \".*\"|hash = \"$dummy_src\"|" "$package_file"

echo "Building to get src hash..."
output=$(nix build "$script_dir/../.."#$package_name 2>&1 || true)

src_hash=$(echo "$output" | grep 'got:' | head -n1 | grep -oP 'sha256-[a-zA-Z0-9+/=]+')
if [ -z "$src_hash" ]; then
    echo "❌ Failed to extract src hash from build output"
    echo "$output" | tail -n20
    exit 1
fi
echo "New src hash: $src_hash"
sed -i "s|$dummy_src|$src_hash|" "$package_file"

# 修改 version 到更新日期

echo "✅ Update completed successfully!"
echo "Package is now at commit $latest_rev."

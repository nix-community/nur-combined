#!/usr/bin/env bash
set -euo pipefail

owner="visualglitch91"
repo="niri"
branch="feat/blur"
pname="niri-blur"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
package_file="$script_dir/default.nix"

echo "Checking Niri version..."

# 1️⃣ 获取 GitHub 上 Cargo.toml 的 workspace.package version
latest_version=$(curl -sL "https://raw.githubusercontent.com/$owner/$repo/$branch/Cargo.toml" \
  | grep -A1 "\[workspace.package\]" \
  | grep 'version' \
  | sed -E 's/version = "(.*)"/\1/')

echo "Latest version on GitHub: $latest_version"

# 2️⃣ 获取 default.nix 中的 raw-version
current_version=$(grep -oP 'raw-version\s*=\s*"\K[^"]+' "$package_file")
echo "Current version in default.nix: $current_version"

# 3️⃣ 比较版本
if [ "$latest_version" = "$current_version" ]; then
  echo "Package is already up to date!"
  exit 0
fi

echo "Update needed: $current_version -> $latest_version"

# 4️⃣ 第一次构建：获取 src hash
dummy_src="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
sed -i "s|hash = \".*\"|hash = \"$dummy_src\"|" "$package_file"

echo "Building to get src hash..."
output=$(nix build "$script_dir/../.."#$pname 2>&1 || true)

src_hash=$(echo "$output" | grep -oP 'got:\s*\Ksha256-[a-zA-Z0-9+/=]+' | head -n1)
if [ -z "$src_hash" ]; then
  echo "ERROR: Could not extract src hash from build output"
  echo "$output" | tail -20
  exit 1
fi
echo "New GitHub src hash: $src_hash"
sed -i "s|$dummy_src|$src_hash|" "$package_file"

# 5️⃣ 第二次构建：获取 cargoHash
dummy_cargo="sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB="
sed -i "s|cargoHash = \".*\"|cargoHash = \"$dummy_cargo\"|" "$package_file"

echo "Building to get Cargo hash..."
output=$(NIX_BUILD_CORES=1 nix build "$script_dir/../.."#$pname 2>&1 || true)

cargo_hash=$(echo "$output" | grep -oP 'got:\s*\Ksha256-[a-zA-Z0-9+/=]+' | head -n1)
if [ -z "$cargo_hash" ]; then
  echo "ERROR: Could not extract Cargo hash from build output"
  echo "$output" | tail -20
  exit 1
fi
echo "New Cargo hash: $cargo_hash"
sed -i "s|$dummy_cargo|$cargo_hash|" "$package_file"

# 6️⃣ 更新 raw-version
sed -i "s/raw-version = \".*\"/raw-version = \"$latest_version\"/" "$package_file"

echo "Update completed successfully! Niri is now at version $latest_version."

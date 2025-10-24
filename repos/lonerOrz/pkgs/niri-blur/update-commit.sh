#!/usr/bin/env bash
set -euo pipefail

owner="visualglitch91"
repo="niri"
branch="feat/blur"
pname="niri-blur"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
package_file="$script_dir/default.nix"

echo "Checking Niri version..."

# 1️⃣ 获取 feat/blur 分支的最新 commit（完整哈希）
echo "Fetching latest commit for branch '$branch'..."
api_url="https://api.github.com/repos/$owner/$repo/commits/$branch"
json=$(curl -fsSL "$api_url" || true)

if [[ -z "$json" ]]; then
  echo "❌ ERROR: No data from GitHub API ($api_url)"
  exit 1
fi

# 提取第一个 "sha" 值（主 commit）
latest_commit=$(echo "$json" | grep -m1 '"sha":' | sed -E 's/.*"sha":\s*"([^"]+)".*/\1/' || true)

if [[ -z "$latest_commit" ]]; then
  echo "❌ ERROR: Could not parse commit SHA from API response!"
  echo "API response (first 10 lines):"
  echo "$json" | head -10
  exit 1
fi

short_commit="${latest_commit:0:7}"
latest_version="$latest_commit"

echo "Latest commit on GitHub ($branch): $latest_commit"
echo "Using version string (raw-version): $latest_version"

# 2️⃣ 获取 default.nix 中的 raw-version
current_version=$(grep -oP 'raw-version\s*=\s*"\K[^"]+' "$package_file" || true)
echo "Current version in default.nix: ${current_version:-<none>}"

# 3️⃣ 比较版本
if [[ "$latest_version" == "$current_version" ]]; then
  echo "✅ Package is already up to date!"
  exit 0
fi

echo "Update needed: ${current_version:-none} -> $short_commit"

# 4️⃣ 第一次构建：获取 src hash
dummy_src="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
sed -i "s|hash = \".*\"|hash = \"$dummy_src\"|" "$package_file"

echo "Building to get src hash..."
output=$(nix build "$script_dir/../.."#$pname 2>&1 || true)

src_hash=$(echo "$output" | grep -oP 'got:\s*\Ksha256-[a-zA-Z0-9+/=]+' | head -n1 || true)
if [[ -z "$src_hash" ]]; then
  echo "❌ ERROR: Could not extract src hash from build output"
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

cargo_hash=$(echo "$output" | grep -oP 'got:\s*\Ksha256-[a-zA-Z0-9+/=]+' | head -n1 || true)
if [[ -z "$cargo_hash" ]]; then
  echo "❌ ERROR: Could not extract Cargo hash from build output"
  echo "$output" | tail -20
  exit 1
fi

echo "New Cargo hash: $cargo_hash"
sed -i "s|$dummy_cargo|$cargo_hash|" "$package_file"

# 6️⃣ 更新 raw-version（完整 commit 哈希）
sed -i "s/raw-version = \".*\"/raw-version = \"$latest_version\"/" "$package_file"

echo "✅ Update completed successfully!"
echo "Niri ($pname) is now at commit $short_commit ($branch)."

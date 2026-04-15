#!/usr/bin/env bash
set -euo pipefail

OWNER="niri-wm"
REPO="niri"
BRANCH="main"
package_name="niri-git"
pname="niri-git"

FAST_MODE=false
if [[ ${1:-} == "--fast" ]]; then
  FAST_MODE=true
fi

script_dir=$(cd "$(dirname "$0")" && pwd)
package_file="$script_dir/default.nix"

cd "$script_dir/"

# 1️⃣ Get the latest commit from remote
latest_rev=$("$script_dir/../../.github/script/github-rev-fetch.sh" "${OWNER}/${REPO}" "${BRANCH}")
if [ -z "$latest_rev" ]; then
  echo "ERROR: Cannot fetch the latest commit of ${OWNER}/${REPO}:${BRANCH}"
  exit 1
fi
echo "Latest remote commit: $latest_rev"

# 2️⃣ Get the current rev in the derivation
current_rev=$(grep 'rev = ' "$package_file" | sed -E 's/.*"([^"]+)".*/\1/')
echo "Current derivation commit: $current_rev"

if [ "$latest_rev" = "$current_rev" ]; then
  echo "✅ Already up-to-date, no update needed"
  exit 0
fi

echo "⚡ New commit detected, updating..."

# 3️⃣ Update rev
sed -i "s|rev = \".*\";|rev = \"$latest_rev\";|" "$package_file"

# 4️⃣ First build: get the src hash
dummy_src="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
sed -i "s|hash = \".*\";|hash = \"$dummy_src\";|" "$package_file"

echo "Building to get src hash..."
output=$(nix build "$script_dir/../.."#$package_name 2>&1 || true)

src_hash=$(echo "$output" | grep -oP 'got:\s*\Ksha256-[a-zA-Z0-9+/=]+' | head -n1)
if [ -z "$src_hash" ]; then
  echo "❌ ERROR: Cannot extract src hash"
  echo "$output" | tail -20
  exit 1
fi
echo "✅ New source hash: $src_hash"
sed -i "s|$dummy_src|$src_hash|" "$package_file"

# 5️⃣ Second build: get Cargo hash (only if not in fast mode)
if [ "$FAST_MODE" = false ]; then
  dummy_cargo="sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB="
  sed -i "s|cargoHash = \".*\";|cargoHash = \"$dummy_cargo\";|" "$package_file"

  echo "Building to get Cargo hash..."
  output=$(NIX_BUILD_CORES=1 nix build "$script_dir/../.."#$package_name 2>&1 || true)

  cargo_hash=$(echo "$output" | grep -oP 'got:\s*\Ksha256-[a-zA-Z0-9+/=]+' | head -n1)
  if [ -z "$cargo_hash" ]; then
    echo "❌ ERROR: Cannot extract Cargo hash"
    echo "$output" | tail -20
    exit 1
  fi
  echo "✅ New Cargo hash: $cargo_hash"
  sed -i "s|$dummy_cargo|$cargo_hash|" "$package_file"
else
  echo "⚡ Fast mode enabled: skipping cargoHash update"
fi

# 6️⃣ Update version date
today=$(date +%Y-%m-%d)
sed -i "s|version = \"0-unstable-[0-9-]*\";|version = \"0-unstable-$today\";|" "$package_file"
echo "📅 Version date updated to: $today"

echo "🎉 Update completed! rev=$latest_rev"

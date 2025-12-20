#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-prefetch-scripts nix git gnused coreutils jq dotnet-sdk_8 nuget-to-json

set -euo pipefail

repo_root=$(git rev-parse --show-toplevel)
cd "$repo_root"

repo_url="https://github.com/yaobiao131/downkyicore"

version="${1:-$(
  git ls-remote --tags "$repo_url" 'v*' \
    | sed -E 's|^.*/v?||' \
    | sort -V \
    | tail -n1
)}"

current_version=$(sed -n 's/^[[:space:]]*version = "\(.*\)";/\1/p' pkgs/downkyicore/package.nix | head -n1)

if [[ -z "$version" ]]; then
  echo "Could not determine version" >&2
  exit 1
fi

tarball="$repo_url/archive/refs/tags/v${version}.tar.gz"
base32_hash=$(nix-prefetch-url --unpack "$tarball")
sri_hash=$(nix hash to-sri --type sha256 "$base32_hash")

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

git clone --depth 1 --branch "v${version}" "$repo_url" "$tmpdir/src"

(
  cd "$tmpdir/src"
  export HOME=$PWD/.home
  export NUGET_PACKAGES=$PWD/.nuget/packages
  export DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_NOLOGO=1 DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1
  dotnet restore DownKyi/DownKyi.csproj --runtime linux-x64
  nuget-to-json "$NUGET_PACKAGES" > "$tmpdir/deps.json"
)

sed -i "s/version = \\\".*\\\";/version = \\\"${version}\\\";/" pkgs/downkyicore/package.nix
sed -i "s|hash = \\\"sha256-.*\\\";|hash = \\\"${sri_hash}\\\";|" pkgs/downkyicore/package.nix
cp "$tmpdir/deps.json" pkgs/downkyicore/deps.json

echo "Updated to ${version}"

# Commit changes if inside a git repo
if command -v git >/dev/null 2>&1 && [ -d .git ]; then
  git add pkgs/downkyicore/package.nix pkgs/downkyicore/deps.json
  git commit -m "downkyicore: ${current_version:-unknown} -> ${version}" || true
fi

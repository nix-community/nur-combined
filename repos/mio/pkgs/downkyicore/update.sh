#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-prefetch-scripts nix git gnused coreutils jq python3 dotnet-sdk_8 nuget-to-json

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
  sed -i 's/net6.0/net8.0/g' DownKyi/DownKyi.csproj DownKyi.Core/DownKyi.Core.csproj
  export HOME=$PWD/.home
  export NUGET_PACKAGES=$PWD/.nuget/packages
  export DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_NOLOGO=1 DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1
  dotnet restore DownKyi/DownKyi.csproj --runtime linux-x64
  nuget-to-json "$NUGET_PACKAGES" > "$tmpdir/deps.json"
)

sed -i "s/version = \\\".*\\\";/version = \\\"${version}\\\";/" pkgs/downkyicore/package.nix
sed -i "s|hash = \\\"sha256-.*\\\";|hash = \\\"${sri_hash}\\\";|" pkgs/downkyicore/package.nix
cp "$tmpdir/deps.json" tmp.deps.json
python - <<'PY'
import json

def version_key(value: str):
    parts = value.replace("-", ".").split(".")
    out = []
    for part in parts:
        try:
            out.append(int(part))
        except ValueError:
            out.append(part)
    return out

runtime_packs = {
    "Microsoft.NETCore.App.Runtime.linux-x64",
    "Microsoft.AspNetCore.App.Runtime.linux-x64",
}

with open("tmp.deps.json") as fh:
    data = json.load(fh)

filtered = {}
for entry in data:
    name = entry["pname"]
    if name in runtime_packs:
        continue
    current = filtered.get(name)
    if current is None or version_key(entry["version"]) > version_key(current["version"]):
        filtered[name] = entry

deduped = sorted(filtered.values(), key=lambda item: item["pname"].lower())
with open("pkgs/downkyicore/deps.json", "w") as fh:
    json.dump(deduped, fh, indent=2, ensure_ascii=False)
PY
rm -f tmp.deps.json

echo "Updated to ${version}"

# Commit changes if inside a git repo
if command -v git >/dev/null 2>&1 && [ -d .git ]; then
  if ! git diff --quiet -- pkgs/downkyicore/package.nix pkgs/downkyicore/deps.json; then
    git add pkgs/downkyicore/package.nix pkgs/downkyicore/deps.json
    git commit -m "downkyicore: ${current_version:-unknown} -> ${version}" || true
  else
    echo "No changes to commit"
  fi
fi

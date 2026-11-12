#!/usr/bin/env bash
set -euo pipefail

# Launcher releases are distinct from the game's v* tags and prereleases.
latest=$(curl -fsSL --retry 4 --retry-max-time 60 --max-time 30 'https://api.github.com/repos/VlcekM/MeitouClient/releases?per_page=100' \
  | python3 -c 'import json,re,sys; releases=json.load(sys.stdin); versions=[x["tag_name"][len("launcher-v"):] for x in releases if not x["draft"] and not x["prerelease"] and re.fullmatch(r"launcher-v[0-9]+\.[0-9]+\.[0-9]+", x["tag_name"])]; print(max(versions, key=lambda s: tuple(map(int,s.split(".")))) if versions else "")')
[[ -n "$latest" ]] || { echo 'No stable launcher release found' >&2; exit 1; }
current=$(nix eval --raw --no-write-lock-file .#meitou-launcher.version)
if ! python3 -c 'import sys; sys.exit(0 if tuple(map(int,sys.argv[1].split("."))) > tuple(map(int,sys.argv[2].split("."))) else 1)' "$latest" "$current"; then
  echo "meitou-launcher is up to date (pinned $current, latest stable $latest)"
  exit 0
fi

# Check the release SDK before mutating version/hash or fetching NuGet packages.
# Honor upstream's latestFeature policy without accepting another major/minor,
# a prerelease SDK or a downgrade. Unknown policies require explicit review.
sdk_config=$(curl -fsSL --retry 4 --retry-max-time 60 --max-time 30 \
  "https://raw.githubusercontent.com/VlcekM/MeitouClient/launcher-v${latest}/global.json")
package_sdk=$(nix eval --raw --no-write-lock-file .#meitou-launcher.dotnetSdkVersion)
python3 -c '
import json,re,sys
sdk=json.loads(sys.argv[1])["sdk"]
required=sdk["version"]
actual=sys.argv[2]
def stable(v):
    if not re.fullmatch(r"[0-9]+\.[0-9]+\.[0-9]+", v):
        return None
    return tuple(map(int,v.split(".")))
r,a=stable(required),stable(actual)
policy=sdk.get("rollForward", "patch")
compatible = r is not None and a is not None and (a == r or (
    policy == "latestFeature" and a[:2] == r[:2] and a >= r))
if not compatible:
    sys.exit(f"Unsupported upstream .NET SDK {required} (package pins {actual}, policy {policy}); update the package SDK first")
' "$sdk_config" "$package_sdk"

nix-update --flake meitou-launcher --version "$latest"
fetch_deps=$(nix build --no-link --print-out-paths --no-write-lock-file .#meitou-launcher.fetch-deps)
"$fetch_deps" pkgs/meitou-launcher/deps.json

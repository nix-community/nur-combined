set -euo pipefail

temp_zon="$(mktemp)"

curl -Lo "$temp_zon" https://github.com/kewuaa/kwm/raw/refs/heads/master/build.zig.zon
nix run nixpkgs#zon2nix -- "$temp_zon" > "$1"

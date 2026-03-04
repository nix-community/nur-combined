#! /usr/bin/env nix-shell
#! nix-shell -i bash -p curlMinimal jq nix

set -euo pipefail

function cleanup() {
    [[ -d "$TMP_DIR" ]] && rm -r "$TMP_DIR"
}

trap "cleanup" EXIT

OUT_PATH="$1"

TMP_DIR="$(mktemp -d)"
mkdir -p "$TMP_DIR"

# Fetch latest release info from GitHub
RELEASE_URL="https://api.github.com/repos/wshanks/tbkeys/releases/latest"
RELEASE_FILE="$TMP_DIR/tbkeys-release.json"
curl -sSL -o "$RELEASE_FILE" "$RELEASE_URL"

VERSION="$(jq -r '.tag_name | ltrimstr("v")' "$RELEASE_FILE")"
TAG="$(jq -r '.tag_name' "$RELEASE_FILE")"
URL="https://github.com/wshanks/tbkeys/releases/download/${TAG}/tbkeys.xpi"

# Download and compute hash
XPI_FILE="$TMP_DIR/tbkeys.xpi"
curl -sSL -o "$XPI_FILE" "$URL"
HASH="$(nix-hash --type sha256 --flat "$XPI_FILE")"

cat << EOF > "$OUT_PATH"
{
  buildMozillaXpiAddon,
  lib,
  ...
}:

buildMozillaXpiAddon {
  pname = "tbkeys";
  version = "$VERSION";
  addonId = "tbkeys@addons.thunderbird.net";
  url = "$URL";
  sha256 = "$HASH";
  meta = with lib; {
    homepage = "https://github.com/wshanks/tbkeys";
    description = "Custom keyboard shortcuts for Thunderbird";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
EOF

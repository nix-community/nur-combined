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

UPDATES_URL="https://gitflic.ru/project/magnolia1234/bpc_updates/blob/raw?file=updates.json&branch=main"
UPDATES_FILE="$TMP_DIR/bpc-updates.json"
curl -sSL -o "$UPDATES_FILE" "$UPDATES_URL"

VERSION="$(jq -r '.addons."magnolia@12.34".updates[-1].version' "$UPDATES_FILE")"
URL="https://gitflic.ru/project/magnolia1234/bpc_uploads/blob/raw?file=bypass_paywalls_clean-${VERSION}.xpi&branch=main"

# Download file first, then calculate hash (URL contains & which nix-prefetch-url can't handle)
XPI_FILE="$TMP_DIR/bypass_paywalls_clean.xpi"
curl -sSL -o "$XPI_FILE" "$URL"
HASH="$(nix-hash --type sha256 --flat "$XPI_FILE")"

cat << EOF > "$OUT_PATH"
{
  buildFirefoxXpiAddon,
  lib,
  ...
}:

buildFirefoxXpiAddon {
  pname = "bypass-paywalls-clean";
  version = "$VERSION";
  addonId = "magnolia@12.34";
  url = "$URL";
  sha256 = "$HASH";
  meta = with lib; {
    homepage = "https://gitflic.ru/project/magnolia1234/bypass-paywalls-clean";
    description = "Bypass Paywalls of (custom) news sites";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
EOF

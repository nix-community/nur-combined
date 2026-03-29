#! /usr/bin/env nix-shell
#! nix-shell -i bash -p curlMinimal jq unzip

set -euo pipefail

function cleanup() {
    [[ -d "$TMP_DIR" ]] && rm -r "$TMP_DIR"
}

trap "cleanup" EXIT

OUT_PATH="$1"

TMP_DIR="$(mktemp -d)"
mkdir -p "$TMP_DIR"

UPDATES_URL="https://raw.githubusercontent.com/uBlockOrigin/uBOL-home/master/dist/firefox/updates.json"
UPDATES_FILE="$TMP_DIR/uBOLite-updates.json"
curl -L -o "$UPDATES_FILE" "$UPDATES_URL"

VERSION="$(jq -r '.addons."uBOLiteRedux@raymondhill.net".updates[-1].version' "$UPDATES_FILE")"
URL="$(jq -r '.addons."uBOLiteRedux@raymondhill.net".updates[-1].update_link' "$UPDATES_FILE")"

UBOL_FILE="$TMP_DIR/uBOLite.xpi"
UBOL="$TMP_DIR/uBOLite"
UBOL_MANIFEST="$UBOL/manifest.json"

curl -L -o "$UBOL_FILE" "$URL"
HASH="$(nix-hash --type sha256 --flat "$UBOL_FILE")"

unzip -q "$UBOL_FILE" -d "$UBOL"
PERMISSIONS="$(jq .permissions[] "$UBOL_MANIFEST" | sed 's/^/    /')"
HOST_PERMISSIONS="$(jq .host_permissions[] "$UBOL_MANIFEST" | sed 's/^/    /')"

cat << EOF > "$OUT_PATH"
{
  buildFirefoxXpiAddon,
  lib,
  ...
}:

buildFirefoxXpiAddon {
  pname = "ubolite";
  version = "$VERSION";
  addonId = "uBOLiteRedux@raymondhill.net";
  url = "$URL";
  sha256 = "${HASH}";
  mozPermissions = [
${HOST_PERMISSIONS}
${PERMISSIONS}
  ];
  meta = with lib; {
    homepage = "https://github.com/uBlockOrigin/uBOL-home";
    description = "An efficient content blocker based on the MV3 API.";
    license = licenses.agpl3Plus;
    platforms = platforms.all;
  };
}
EOF

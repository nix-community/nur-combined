#! /usr/bin/env nix-shell
#! nix-shell -i bash -p curlMinimal jq unzip

# Adopted from
# https://gitlab.com/NetForceExplorer/firefox-addons/-/blob/500b44b00635de8aae3a2d117d7790cbe406cd03/fetch_addons/zotero/update_zotero.sh
#
# Originally developed by Tobias Fischbach.

set -euo pipefail

function cleanup() {
    [[ -d "$TMP_DIR" ]] && rm -r "$TMP_DIR"
}

trap "cleanup" EXIT

OUT_PATH="$1"

TMP_DIR="$(mktemp -d)"
mkdir -p "$TMP_DIR"

UPDATES_URL="https://www.zotero.org/download/connector/firefox/release/updates.json"
UPDATES_FILE="$TMP_DIR/zotero-updates.json"
curl -o "$UPDATES_FILE" "$UPDATES_URL"

VERSION="$(jq -r '.addons."zotero@chnm.gmu.edu".updates[-1].version' "$UPDATES_FILE")"
HASH="$(jq -r '.addons."zotero@chnm.gmu.edu".updates[-1].update_hash | sub("^sha256:"; "")' "$UPDATES_FILE")"
URL="$(jq -r '.addons."zotero@chnm.gmu.edu".updates[-1].update_link' "$UPDATES_FILE")"

ZOTERO_FILE="$TMP_DIR/zotero.xpi"
ZOTERO="$TMP_DIR/zotero"
ZOTERO_MANIFEST="$ZOTERO/manifest.json"

curl -o "$ZOTERO_FILE" "$URL"
unzip -q "$ZOTERO_FILE" -d "$ZOTERO"

PERMISSIONS="$(jq .permissions[] "$ZOTERO_MANIFEST" | sed 's/^/    /')"
OPTIONAL_PERMISSIONS="$(jq .optional_permissions[] "$ZOTERO_MANIFEST" | sed 's/^/    /')"

cat << EOF > "$OUT_PATH"
{
  buildFirefoxXpiAddon,
  lib,
  ...
}:

buildFirefoxXpiAddon {
  pname = "zotero-connector";
  version = "$VERSION";
  addonId = "zotero@chnm.gmu.edu";
  url = "$URL";
  sha256 = "${HASH}";
  mozPermissions = [
${PERMISSIONS}
${OPTIONAL_PERMISSIONS}
  ];
  meta = with lib; {
    homepage = "https://www.zotero.org/";
    description = "Save references to Zotero from your web browser";
    license = licenses.agpl3Plus;
    platforms = platforms.all;
  };
}
EOF

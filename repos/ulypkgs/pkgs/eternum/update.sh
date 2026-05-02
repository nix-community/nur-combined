#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq common-updater-scripts find-itch-upload

set -euo pipefail

package=eternum
attr() {
  nix-instantiate --eval -A $package.$1 --json | jq -r
}

uploadId="$(find-itch-upload $package -m traits p_linux -m host 'mediafire\.com' --no-update | jq -r .id)"
mediafireLink="$(curl -s -X GET -I "https://api.itch.io/uploads/$uploadId/download?api_key=$ITCHIO_API_KEY" \
  | grep -Ei '^location:' | tail -n 1 | grep -oP 'location:\s*\K.+' | tr -d '\r')"
fileId="$(echo "$mediafireLink" | grep -oP 'file(_premium)?/\K[^/\r\n]+')"
oldFileId="$(attr src.fileId)"
if [[ "$fileId" == "$oldFileId" ]]; then
  echo "No new version found. Current file ID: $fileId" >&2
  exit 0
fi

sed -i "s/fileId = \"$oldFileId\"/fileId = \"$fileId\"/" "$(attr meta.position | cut -d: -f1)"
newVersion="$(echo "$mediafireLink" | sed -E 's/.*([0-9]+\.[0-9]+\.[0-9]+).*/\1/')"
update-source-version $package "$newVersion"

#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq common-updater-scripts

set -euo pipefail

if [[ -z "$ITCHIO_API_KEY" ]]; then
  echo "Please set the ITCHIO_API_KEY environment variable." >&2
  exit 1
fi

attr() {
  nix-instantiate --eval -A eternum.$1 --json | jq -r
}

gameId="$(curl -s "$(attr meta.homepage)/data.json" | jq -r .id)"
upload="$(curl -s "https://api.itch.io/games/$gameId/uploads?api_key=$ITCHIO_API_KEY" \
  | jq -r 'first(.uploads[] | select((.traits | type == "array" and any(. == "p_linux")) and .host != null and (.host | contains("mediafire.com"))))')"
uploadId="$(echo "$upload" | jq -r .id)"
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
update-source-version eternum "$newVersion"

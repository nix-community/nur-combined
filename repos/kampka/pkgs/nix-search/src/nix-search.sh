#!/usr/bin/env bash

set -eu
set -o pipefail

CHANNEL_HASH=$(ls -A /nix/var/nix/profiles/per-user/root/*/manifest.nix | xargs sha1sum | sha1sum | cut -d' ' -f 1)

META_STRING='to_entries | .[] | .key + "|" + .value.version + "|" + .value.meta.description'

CACHE_DIR="$HOME/.cache/nix-search"
mkdir -p "$CACHE_DIR"

CACHE="$CACHE_DIR/$CHANNEL_HASH-$(echo $META_STRING | sha1sum | cut -d' ' -f 1)"
if ! [ -e "$CACHE" ]; then
    echo "Refreshing nix-search cache ..."
    rm -f "$CACHE_DIR"/* 
    nice nix-env -qa --json | jq -r "$META_STRING" > "$CACHE"
    echo ""
fi

# Double grep to preserve coloring
RESULT="$(rg -i "$*" "$CACHE" )"
echo "$RESULT" | column -t -N "Package,Version,Description" -s "|" | head -n 1
echo "$RESULT" | column -t -s "|" | rg -i "$*"

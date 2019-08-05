#!/bin/bash
set -eu
set -o pipefail

urls() {
	local LIMIT=$1
	shift
	local TAGS=$*

	local URL="https://konachan.com/post.json?limit=$LIMIT&tags=$TAGS"
	URLS=$(curl -fSsLG "$URL" 2> /dev/null | jq -r '.[].file_url')
	echo "$URLS" >&2 # for logging
	echo "$URLS"
}

if [ -z "${KONATAGS-}" ]; then
	KONATAGS="score:>=200+width:>=1600+nobody"
fi

TAGS="$KONATAGS+order:random"

if [ -n "${SWAYSOCK-}" ]; then
	OUTPUTS=($(swaymsg -t get_outputs | jq -r .[].name))
	OUTPUT_I=0
	FILES=()
	for url in $(urls ${#OUTPUTS[@]} "$TAGS"); do
		file=$(mktemp)
		timeout 30 curl -fsSLo "$file" "$url"
		swaymsg output "${OUTPUTS[OUTPUT_I]}" background "$file" fill
		OUTPUT_I=$((OUTPUT_I + 1))
		FILES+=($file)
	done

	sleep 2

	# delete our temporary files
	# TODO: maybe use a cache directory that only gets cleaned up at the start
	for file in "${FILES[@]}"; do
		rm "$file"
	done
elif [ -n "${DISPLAY-}" ]; then
	SCREEN_COUNT=$(xrandr -q | grep ' connected' | wc -l)

	timeout 30 feh --no-fehbg --bg-fill $(urls "$SCREEN_COUNT" "$TAGS")
	xsetroot -cursor_name left_ptr
fi

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
FILES=()

cleanup() {
	# delete our temporary files
	# TODO: maybe use a cache directory that only gets cleaned up at the start
	for file in "${FILES[@]}"; do
		rm -f "$file"
	done
}

trap cleanup EXIT

if [ -n "${SWAYSOCK-}" ]; then
	OUTPUTS=($(swaymsg -t get_outputs | jq -r .[].name))
	URL_COUNT=${#OUTPUTS[@]}
elif [ -n "${DISPLAY-}" ]; then
	URL_COUNT=$(xrandr -q | grep ' connected' | wc -l)
fi

WAITPIDS=()
for url in $(urls $URL_COUNT "$TAGS"); do
	file=$(mktemp)
	curl --retry 3 -fsSLo "$file" "$url" &
	WAITPIDS+=($!)
	FILES+=($file)
done
for pid in "${WAITPIDS[@]}"; do
	wait -n $pid
done

if [ -n "${SWAYSOCK-}" ]; then
	OUTPUT_I=0
	for file in "${FILES[@]}"; do
		swaymsg output "${OUTPUTS[OUTPUT_I]}" background "$file" fill
		OUTPUT_I=$((OUTPUT_I + 1))
	done

	sleep 2
elif [ -n "${DISPLAY-}" ]; then
	feh --no-fehbg --bg-fill "${FILES[@]}"
	xsetroot -cursor_name left_ptr
fi

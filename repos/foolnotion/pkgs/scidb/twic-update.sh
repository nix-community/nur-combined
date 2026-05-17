#!/usr/bin/env bash
# Download new TWIC issues and import them into ~/scid/twic.
set -euo pipefail

TWIC_DIR="${TWIC_DIR:-$HOME/scid/twic}"
PGN_DIR="$TWIC_DIR/pgn"
DATABASE="$TWIC_DIR/twic"
BASE_URL="https://theweekinchess.com/zips"

mkdir -p "$PGN_DIR"

# Determine last downloaded issue from existing PGN files.
last_issue=$(ls "$PGN_DIR"/twic*.pgn 2>/dev/null \
    | grep -oP 'twic\K[0-9]+' | sort -n | tail -1 || echo 0)

# Fetch current issue number from TWIC index page.
current_issue=$(curl -sf "https://theweekinchess.com/twic" \
    | grep -oP '(?<=twic)[0-9]+(?=g\.zip)' | sort -n | tail -1)

if [[ -z "$current_issue" ]]; then
    echo "Could not determine current TWIC issue number." >&2
    exit 1
fi

echo "Last downloaded: $last_issue  /  Current: $current_issue"

new=0
for ((i = last_issue + 1; i <= current_issue; i++)); do
    url="$BASE_URL/twic${i}g.zip"
    dest="$PGN_DIR/twic${i}.pgn"
    echo -n "Downloading TWIC $i ... "
    tmpzip=$(mktemp --suffix=.zip)
    if curl -sf -o "$tmpzip" "$url"; then
        unzip -p "$tmpzip" "*.pgn" > "$dest" 2>/dev/null \
            || { unzip -p "$tmpzip" > "$dest"; }
        rm "$tmpzip"
        echo "ok"
        ((++new))
    else
        rm "$tmpzip"
        echo "not available yet"
        break
    fi
done

if ((new == 0)); then
    echo "Already up to date."
    exit 0
fi

echo "Importing $new new issue(s) into $DATABASE ..."
new_pgns=()
for ((i = last_issue + 1; i <= last_issue + new; i++)); do
    new_pgns+=("$PGN_DIR/twic${i}.pgn")
done

sc_import "$DATABASE" "${new_pgns[@]}"
echo "Done."

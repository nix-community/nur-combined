#!/usr/bin/env nix-shell
#!nix-shell -i bash -p jq

set -euxo pipefail

API_KEY='${{ secrets.GOOGLE_FONT_API_KEY }}'
latest_json=$(curl -q https://www.googleapis.com/webfonts/v1/webfonts?family=Noto+Emoji\&key=$API_KEY)
font_family=$(jq -r '.items[0].family' <<<"$latest_json")
latest_version=$(jq -r '.items[0].version' <<<"$latest_json")

if [[ "$(nix-instantiate -A noto-bw-emoji.font-family-name --eval --json | jq -r)" != "$font_family" ]]; then
	echo "Incorrect font is being fetched, suggest manual intervention in update.sh"
	exit 1
fi

if [[ "$(nix-instantiate -A noto-bw-emoji.version --eval --json | jq -r)" = "$latest_version" ]]; then
	echo "Already using $latest_version, skipping"
	exit 0
fi

echo "Updating to $latest_version"
echo "$latest_json" >version.json
noto_emoji_regular_url=$(jq -r '.items[0].files.regular' <<<"$latest_json")
filename="NotoEmoji.ttf"

# Create a temporary directory
temp_dir=$(mktemp -d)
trap "rm -rf $temp_dir" EXIT

# Download the file
curl -o "$temp_dir/$filename" "$noto_emoji_regular_url"

# Calculate the SHA256 hash
sha256sum_output=$(sha256sum "$temp_dir/$filename")
sha256_hash=$(echo "$sha256sum_output" | awk '{ print $1 }' | xxd -r -p | base64)

sed -i "./default.nix" \
	-e 's,version = ".*",version = "'"$latest_version"'",' \
	-e 's,regular-url = ".*",regular-url = "'"$noto_emoji_regular_url"'",' \
	-e 's,regular-hash = ".*",regular-hash = "'"$sha256_hash"'",'

nix-build -A noto-fonts-bw-emoji

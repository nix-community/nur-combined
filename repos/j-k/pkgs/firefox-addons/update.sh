#!/usr/bin/env bash

get_xpi_url() {
	curl -s "https://addons.mozilla.org/api/v5/addons/addon/${1}/?app=firefox" | jq -r ".current_version.files[].url" | grep ".xpi"
}

replace_sha() {
	sed -i "s#sha256 = \"sha256-.\{44\}\"#sha256 = \"$2\"#" "$1"
}

replace_url() {
	sed -i "s#url = \".*\"#url = \"$2\"#" "$1"
}

extract_val() {
	grep "  $2 = \"" "$1" | cut -d '"' -f2
}

fetch_sha() {
	nix-prefetch "{ fetchFirefoxAddon }:
fetchFirefoxAddon {
  name = \"$1\"; url = \"$2\";
  sha256 = \"sha256-0000000000000000000000000000000000000000000=\";
}"
}


# Addons packaged from addons.mozilla.org
ADDONS_MOZILLA=$(rg "url = \"https://addons.mozilla.org/firefox/downloads/file/" --files-with-matches --type=nix)

for ADDON in $ADDONS_MOZILLA; do
	# NAME=$(grep "  name = \"" "$ADDON" | cut -d '"' -f2)
	NAME=$(extract_val "$ADDON" "name")
	if [[ "$NAME" == "sty-lus" || "$NAME" == "cors_everywhere" ]]; then
		echo "[$NAME] skipping because addons api broken"
		continue
	fi
	echo "[$NAME] updating $ADDON"

	EXISTING_XPI=$(extract_val "$ADDON" "url")
	XPI=$(get_xpi_url "$NAME")
	if [[ "$EXISTING_XPI" == "$XPI" ]]; then
		echo "[$NAME] XPI matches already"
		continue
	fi
	replace_url "$ADDON" "$XPI"

	SHA="$(fetch_sha "$NAME" "$XPI")"
	replace_sha "$ADDON" "$SHA"
	echo "[$NAME] updated $ADDON"
done

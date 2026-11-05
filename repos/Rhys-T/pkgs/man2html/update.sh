#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl gnugrep gnused gnutar nix common-updater-scripts
set -euo pipefail
curlVersion="$(curl -V | head -1 | cut -d' ' -f2)"
latest="$(
	curl --user-agent "curl/$curlVersion Rhys-T NUR update script for man2html https://github.com/Rhys-T/nur-packages" -s 'https://invisible-island.net/archives/man2html/' | \
	grep -Eo 'href="man2html-[0-9]{8}\.tgz"' | \
	sed -E 's@href="man2html-([0-9]{8})\.tgz"@\1@g' | \
	sort -nr | head -n1
)"
[[ "$latest" =~ ([0-9]{4})([0-9]{2})([0-9]{2}) ]]
YYYY="${BASH_REMATCH[1]}"
MM="${BASH_REMATCH[2]}"
DD="${BASH_REMATCH[3]}"
versionForNix="3.0.1-unstable-$YYYY-$MM-$DD" # TODO don't hardcode 3.0.1 - fix this if man2html ever gets another release
update-source-version "${UPDATE_NIX_ATTR_PATH:-man2html}" "$versionForNix" --print-changes

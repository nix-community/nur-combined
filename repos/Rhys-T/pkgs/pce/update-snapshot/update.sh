#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl gnugrep gnused gnutar nix common-updater-scripts
set -euo pipefail
latest="$(
	curl -s 'http://hampa.ch/pub/pce/pre/' | \
	grep -Eo 'href="pce-[0-9]{8}-[0-9a-f]{8}/"' | \
	sed -E 's@href="pce-(.*)/"@\1@g' | \
	sort -nr | head -n1
)"
[[ "$latest" =~ ([0-9]{4})([0-9]{2})([0-9]{2})-([0-9a-f]{8}) ]]
YYYY="${BASH_REMATCH[1]}"
MM="${BASH_REMATCH[2]}"
DD="${BASH_REMATCH[3]}"
shortRev="${BASH_REMATCH[4]}"
versionForNix="0.2.2-unstable-$YYYY-$MM-$DD" # TODO don't hardcode 0.2.2 - fix this if PCE ever gets another release
if [[ "$(update-source-version "$UPDATE_NIX_ATTR_PATH._pkgForUpdater" "$versionForNix" --rev="$shortRev" --print-changes)" == '[]' ]]; then
	exit 0
fi
srcArchive="$(nix-build -E "(import ./. {}).$UPDATE_NIX_ATTR_PATH.src")"
fullRev="$(tar xOf "$srcArchive" --wildcards '*/ChangeLog' | egrep "^commit $shortRev" | head -n1 | cut -d' ' -f2)"
update-source-version "$UPDATE_NIX_ATTR_PATH._pkgForUpdater" "$versionForNix" --rev="$fullRev" --ignore-same-version

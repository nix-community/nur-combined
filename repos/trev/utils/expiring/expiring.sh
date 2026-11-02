#!/usr/bin/env bash

# Fails when a package's passthru.expiresAt is less than a week away,
# so it can be updated before it stops working.

set -euo pipefail

system=$(nix eval --impure --raw --expr 'builtins.currentSystem')
now=$(date +%s)
window=$((7 * 24 * 60 * 60))
status=0

while read -r package expires; do
    date=$(date -u -d "@${expires}" '+%Y-%m-%d %H:%M UTC')

    if ((expires <= now)); then
        echo "::error::${package} expired on ${date}"
        status=1
    elif ((expires - now < window)); then
        echo "::error::${package} expires on ${date}"
        status=1
    else
        echo "${package} expires on ${date}"
    fi
done < <(
    nix eval --json ".#packages.${system}" \
        --apply 'builtins.mapAttrs (_: package: package.expiresAt or null)' |
        jq -r 'to_entries[] | select(.value != null) | "\(.key) \(.value)"'
)

exit "${status}"

#!/usr/bin/env bash

set -euo pipefail

update() {
    FILE=$1

    if ! grep -q 'update-my-nur = true;' "$FILE"; then
        echo -e "\033[0;31m\033[0m Skipping $FILE as it does not have update-my-nur = true;"
        return
    fi

    OWNER=$(grep -oP 'owner = "\K[^"]+' "$FILE")
    REPO=$(grep -oP 'repo = "\K[^"]+' "$FILE")

    echo -e '\033[0;32m\033[0m Fetch last commit hash and rev from GitHub'
    NIX_PREFETCH=$(nix-prefetch-github --json "${OWNER}" "${REPO}")

    NEW_HASH=$(echo "$NIX_PREFETCH" | jq -r .hash)
    LATEST_COMMIT=$(echo "$NIX_PREFETCH" | jq -r .rev)
    SHORT_COMMIT=$(echo "$LATEST_COMMIT" | cut -c1-7)

    echo -e "\033[0;32m\033[0m Update the version, rev, and hash in $FILE"
    sed -i "s/version = \".*\";/version = \"${SHORT_COMMIT}\";/g" "$FILE"
    sed -i "s/rev = \".*\";/rev = \"${LATEST_COMMIT}\";/g" "$FILE"
    sed -i "s|hash = \".*\";|hash = \"${NEW_HASH}\";|g" "$FILE"
}

# for all folders in pkgs
for folder in pkgs/*; do
    update "$folder/default.nix"
done

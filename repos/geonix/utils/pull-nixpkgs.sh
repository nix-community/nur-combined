#!/usr/bin/env bash

# Pull packages from nixpkgs.
# Requires `files.txt` file to be present in `pkgs/<PACKAGE>/nixpkgs` directory.
# Usage: pull-packages.sh <NIXPKGS-DIR>

set -Eeuo pipefail

nixpkgs_dir=$1

for pkg in pkgs/*; do
    # pull files from nixpkgs
    if [[ -f $pkg/nixpkgs/files.txt ]]; then
        echo -e "\nPulling $pkg ..."

        while IFS= read -r paths; do
            eval cp -v "$nixpkgs_dir"/"$paths" | sed -e 's/^/  /'
        done < "$pkg"/nixpkgs/files.txt
    else
        echo -e "\n  $pkg/nixpkgs/files.txt doesn't exit. Skipping ..."
    fi

    # apply geonix patches to nixpkgs files
    if [ 0 -lt $(ls $pkg/nixpkgs/*.patch 2>/dev/null | wc -w) ]; then
        for patch_file in "$pkg"/nixpkgs/*.patch; do
            echo "  Applying patch $patch_file ..."
            patch -p1 -i "$patch_file" | sed -e 's/^/    /'
        done
    fi
done

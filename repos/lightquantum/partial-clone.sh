#!/usr/bin/env bash
set -euo pipefail

# This script is used to clone a git repository and only fetch a subdirectory

# Usage: partial-clone.sh <repo> <subdir> <dest>

repo="$1"
subdir="$2"
dest="$3"

# Clone the repo
git clone --depth 1 --filter=blob:none --sparse "$repo" "temp-clone"
pushd "temp-clone"
git sparse-checkout init --cone
git sparse-checkout set "$subdir"
popd
mv "temp-clone/$subdir" "$dest"
rm -rf "temp-clone"
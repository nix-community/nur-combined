#! /usr/bin/env bash

# This updates cargo-lock.patch for the diesel version listed in default.nix.

set -eu -o verbose

here=$PWD
version=$(jq -r '.rev' ./source.json)
checkout=$(mktemp -d)
git clone https://github.com/JonathanHelianthicusDoe/shticker_book_unwritten "$checkout"
cd "$checkout"

git checkout "$version"
rm -f rust-toolchain
cargo generate-lockfile
git add -f Cargo.lock
git diff HEAD -- Cargo.lock > "$here"/cargo-lock.patch

cd "$here"
rm -rf "$checkout"

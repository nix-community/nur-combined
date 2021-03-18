#! /usr/bin/env nix-shell
#! nix-shell ../../shell.nix -i bash

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

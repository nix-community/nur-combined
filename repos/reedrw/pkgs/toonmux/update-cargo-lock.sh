#! /usr/bin/env nix-shell
#! nix-shell -i bash -p cargo coreutils git gnugrep jq

set -eu -o verbose
set -x

here=$PWD
version=$(jq -r '.rev' ./source.json)
checkout=$(mktemp -d)
git clone https://github.com/JonathanHelianthicusDoe/toonmux "$checkout"
cd "$checkout"

git checkout "$version"
rm -f rust-toolchain
cargo generate-lockfile
git add -f Cargo.lock
git diff HEAD -- Cargo.lock > "$here"/cargo-lock.patch

cd "$here"
rm -rf "$checkout"

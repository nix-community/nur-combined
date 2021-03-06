#! /usr/bin/env nix-shell
#! nix-shell ../../shell.nix -I channel:nixos-20.09 -i bash

set -e
set -x

nix-prefetch-github-latest-release jonathanhelianthicusdoe shticker_book_unwritten | tee source.json
./update-cargo-lock.sh

package="$(basename "$PWD")"

pushd "$(git rev-parse --show-toplevel)" || exit
nix-update "$package"
popd || exit

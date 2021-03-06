#! /usr/bin/env nix-shell
#! nix-shell ../../shell.nix -i bash

set -x

oldRev="$(jq -r '.rev' ./source.json)"

nix-prefetch-github-latest-release jonathanhelianthicusdoe shticker_book_unwritten | tee source.json

newRev="$(jq -r '.rev' ./source.json)"

# This check is necessary because otherwise the cargo lock file will update without `nix-update` updating cargoSha256
if ! [[ "$oldRev" == "$newRev" ]]; then
  ./update-cargo-lock.sh
fi

package="$(basename "$PWD")"

pushd "$(git rev-parse --show-toplevel)" || exit
nix-update "$package"
popd || exit

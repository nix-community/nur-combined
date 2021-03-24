#! /usr/bin/env nix-shell
#! nix-shell ../../shell.nix -i bash

set -x

nix-prefetch-github-latest-release Daniel-Liu-c0deb0t uwu | tee source.json

package="$(basename "$PWD")"

pushd "$(git rev-parse --show-toplevel)" || exit
nix-update "$package"
popd || exit


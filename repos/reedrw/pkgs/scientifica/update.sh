#! /usr/bin/env nix-shell
#! nix-shell ../../shell.nix -i bash

set -e
set -x

package="$(basename "$PWD")"

pushd "$(git rev-parse --show-toplevel)" || exit
nix-update "$package"
popd || exit

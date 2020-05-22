#!/usr/bin/env bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

pushd $DIR/../pkgs
set +e
for p in *; do
    nix-build . -A $p | cachix push shortbrain
done
set -e

# cleanup
for r in result*; do
    unlink $r
done
popd

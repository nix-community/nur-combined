#!/usr/bin/env bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

nix-build . | cachix push shortbrain

# cleanup
for r in result*; do
    unlink $r
done

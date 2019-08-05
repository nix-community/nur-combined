#!/bin/sh

exec nix-build --no-out-link --cores 0 --show-trace ci/all.nix "$@"

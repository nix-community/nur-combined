#!/bin/sh

set -eu

# Install latest
nix-env -iA cachix -f https://cachix.org/api/v1/install

#!/bin/sh

set -e  # abort on failure

nix run nixpkgs#node2nix -- -i node-packages.json

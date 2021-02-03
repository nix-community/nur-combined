#!/bin/sh
nix repl -I nixpkgs="$(dirname $0)/default.nix"

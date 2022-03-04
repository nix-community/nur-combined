#! /usr/bin/env nix-shell
#! nix-shell -i bash -p crate2nix

rm -f crate2nix.json
crate2nix source add git --name lightspeed-ingest https://github.com/GRVYDEV/Lightspeed-ingest --rev $1
crate2nix generate

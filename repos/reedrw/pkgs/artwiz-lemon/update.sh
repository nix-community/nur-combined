#!/usr/bin/env nix-shell
#! nix-shell -i bash -p nix-prefetch-github

nix-prefetch-github cmvnd fonts | tee source.json


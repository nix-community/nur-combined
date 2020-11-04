#!/usr/bin/env nix-shell
#!nix-shell -i sh -p nix-prefetch-git jq

nix-prefetch-git --fetch-submodules "https://github.com/LukeSmithxyz/voidrice" | jq '{ rev: .rev, sha256: .sha256 }' > pkgs/voidrice.json

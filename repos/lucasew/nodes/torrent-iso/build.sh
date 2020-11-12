#! /usr/bin/env nix-shell
#! nix-shell -i bash -p nixos-generators

nixos-generate -f install-iso -c iso.nix --cores 2

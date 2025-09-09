#! /usr/bin/env nix-shell
#! nix-shell -i bash -p nix-update

nix-update faugus-launcher
nix-update --version=skip goverlay
nix-update gupax
nix-update steam-optionx

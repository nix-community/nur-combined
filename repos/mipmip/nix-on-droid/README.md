# Nix on droid

## Setup nix-on-droid

ln -s ~/nixos/nix-on-droid ~/.config/

## Apply nix config

nix-on-droid switch -F ~/.config/nix-on-droid/flake.nix


## SSH Connect

ssh nix-on-droid@xxxxx -p8022

#! /usr/bin/env -S nix shell nixpkgs#nix-update nixpkgs#nixfmt-rfc-style --command bash

nix-update --commit --format --flake bmi260
nix-update --commit --format --flake get-lrc
nix-update --commit --format --flake mdbook-typst-pdf
nix-update --commit --format --flake vutronmusic

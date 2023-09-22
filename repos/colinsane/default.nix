# limited, non-flake interface to this repo.
# this file exposes the same view into `pkgs` which the flake would see when evaluated.
#
# the primary purpose of this file is so i can run `updateScript`s which expect
# the root to be `default.nix`
{ pkgs ? import <nixpkgs> {} }:
pkgs.appendOverlays [
  (import ./overlays/all.nix)
]

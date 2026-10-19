# Pokanop Apps package set. Takes pkgs as an argument rather than
# importing <nixpkgs>, so it composes with NUR and overlays.

{ pkgs ? import <nixpkgs> { } }:

{
  nostromo = pkgs.callPackage ./pkgs/nostromo { };
}

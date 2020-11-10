#
# This is the channel's default.nix
#
{ overlays ? [], ... }@args :

let
  lib = import ./nixpkgs/lib;
  args' = lib.filterAttrs (n: v: n != "overlays") args;

in import ./nixpkgs ({
  overlays = overlays ++ [ (import ./NixOS-QChem) ];
} // args' )

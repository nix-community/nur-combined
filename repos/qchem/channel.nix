#
# This is the channel's default.nix
#
{ overlays ? [], ... }@args :

let
  lib = import ./lib;
  args' = lib.filterAttrs (n: v: n != "overlays") args;

  createPkgs = src: overlay: import src ({
    overlays = overlay;
  } // args' );

  composePkgs = src:
    createPkgs src overlays //
    { qchem = (createPkgs src (overlays ++ [ (import ./NixOS-QChem) ])).qchem; };

in composePkgs ./nixpkgs-default.nix


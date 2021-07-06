{ pkgs ? import <nixpkgs> { }, overlay ? false }: let
  overlays = import ./overlays;
  pkgs'cleared = if overlays.arc'internal.needsSanitation pkgs
    then overlays.arc'internal.sanitize pkgs
    else pkgs;
  pkgs'overlaid = pkgs'cleared.extend overlays;
  arc'overlaid = {
    inherit (pkgs'overlaid.arc) path super callPackageAttrs pkgs lib packages build shells;
  } // import ./static.nix;
  arc = if overlay
    then arc'overlaid
    else import ./canon.nix { inherit pkgs; };
in arc

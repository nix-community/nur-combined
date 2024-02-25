{pkgs ? import <nixpkgs> {}, ...}: let
  inherit (pkgs.callPackage ./helpers/flatten-pkgs.nix {}) flattenPkgs;
in
  flattenPkgs (pkgs.callPackage ./pkgs {
    mode = "nur";
  })

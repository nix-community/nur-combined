{ pkgs, ... }:
let
  fetchrixLoader = pkgs.callPackage ./fetchrix-loader.nix { };
in
fetchrixLoader ../../../../_sources

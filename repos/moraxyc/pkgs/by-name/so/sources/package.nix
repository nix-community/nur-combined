{ pkgs, ... }:
let
  nvfetcherLoader = pkgs.callPackage ./nvfetcher-loader.nix { };
in
nvfetcherLoader ../../../../_sources/generated.nix

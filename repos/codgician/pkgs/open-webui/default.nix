{ pkgs, lib, ... }:
let
  current = pkgs.callPackage ./package.nix { };
  upstream = pkgs.open-webui;
in
# Only use the current package when it is newer than upstream
(if lib.versionOlder upstream.version current.version then current else upstream).overrideAttrs
  (_: {
    meta.platforms = [ "x86_64-linux" ];
  })

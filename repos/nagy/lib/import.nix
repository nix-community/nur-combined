{ pkgs, lib, ... }:
with lib; rec {
  mapNixFiles = fn: dir: (map fn (attrNames (builtins.readDir dir)));
  importNixFiles = dir: (mapNixFiles (x: import (dir + "/${x}")) dir);
  callNixFiles = callPackage: dir:
    let
      nixFiles = filterAttrs (k: v: (v == "regular") && hasSuffix ".nix" k)
        (builtins.readDir dir);
    in mapAttrs' (k: v:
      nameValuePair (removeSuffix ".nix" k) (callPackage (dir + ("/" + k)) { }))
    nixFiles;
}

{ lib, ... }:
with lib; rec {
  mapNixFiles = fn: dir: (map fn (attrNames (builtins.readDir dir)));
  importNixFiles = dir: (mapNixFiles (x: import (dir + "/${x}")) dir);
  nixRegularFiles = dir:
    mapAttrs' (k: v: nameValuePair (removeSuffix ".nix" k) k)
    (filterAttrs (k: v: (v == "regular") && hasSuffix ".nix" k)
      (builtins.readDir dir));
  callNixFiles = callPackage: dir:
    mapAttrs (name: value: callPackage (dir + "/${value}") { })
    (nixRegularFiles dir);
}

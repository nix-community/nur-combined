{ lib, callPackage }:
let
  mapAttrValues = callPackage ./mapAttrValues.nix {};
  unpack = callPackage ./unpack.nix {};
  unpackNode = data:
  if lib.isDerivation data then
    unpack { src = data; }
  else
    mapAttrValues unpackNode data;
in unpackNode

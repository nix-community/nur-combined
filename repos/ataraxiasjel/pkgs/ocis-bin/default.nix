{ lib, callPackage }:
let
  infoJson = builtins.fromJSON (builtins.readFile ./versions.json);
  mkOcis = callPackage ./generic.nix { };
in
lib.mapAttrs' (
  majorVersion: info: lib.nameValuePair "ocis_${majorVersion}-bin" (mkOcis info.version info.hashes)
) infoJson

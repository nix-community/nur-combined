{ stdenv, pkgs, lib }:
let
  mangohud_64 = pkgs.callPackage ./default.nix { };
  mangohud_32 = pkgs.pkgsi686Linux.callPackage ./default.nix { };

in
pkgs.buildEnv rec {
  name = "mangohud-${mangohud_64.version}";

  paths = [
    mangohud_32
  ] ++
  lib.lists.optionals
    stdenv.is64bit
    [ mangohud_64 ]
  ;

  meta = mangohud_64.meta;
}

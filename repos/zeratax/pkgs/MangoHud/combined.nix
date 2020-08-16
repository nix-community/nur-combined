{ stdenv, pkgs, lib }:
let
  mangohud_64 = pkgs.callPackage ./default.nix { libXNVCtrl = pkgs.linuxPackages.nvidia_x11.settings.libXNVCtrl; };
  mangohud_32 = pkgs.pkgsi686Linux.callPackage ./default.nix { libXNVCtrl = pkgs.linuxPackages.nvidia_x11.settings.libXNVCtrl; };

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
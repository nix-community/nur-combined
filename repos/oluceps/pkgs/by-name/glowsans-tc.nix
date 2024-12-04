{
  lib,
  stdenv,
  unzip,
  fetchurl,
  callPackage,
}:

let
  glowsans = import ../tool/glow-sans.nix;
in

callPackage (glowsans {
  pname = "glowsans-TC";
  version = "0.93";
  lang = "TC";

  sha256 = "sha256-FuiigAGrGymIfb9jb7NiPkExeMSy/LgmBKZrudGAZUc=";
}) { }

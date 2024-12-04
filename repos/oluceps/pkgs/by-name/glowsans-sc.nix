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
  pname = "glowsans-SC";
  version = "0.93";
  lang = "SC";

  sha256 = "sha256-qi4f2yAzcROh0mcLaVv+6DkQ7vouSPUccE5fSp+OyfE=";
}) { }

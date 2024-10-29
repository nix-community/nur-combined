{
  lib,
  stdenv,
  unzip,
  fetchurl,
  callPackage,
}:

let
  glowsans = (import ../tool/glow-sans.nix);
in

# inherit
# (
# {
(callPackage (glowsans {
  pname = "glowsans-J";
  version = "0.93";
  lang = "J";
  sha256 = "sha256-tKhPbSd9PA7G6DOsD+JbQFRe3twZ31+0ZDcx7vD3MKI=";
}) { })
#   glowsansSC = callPackage (glowsans {
#     pname = "glowsans-SC";
#     version = "0.93";
#     lang = "SC";

#     sha256 = "sha256-qi4f2yAzcROh0mcLaVv+6DkQ7vouSPUccE5fSp+OyfE=";
#   }) { };
#   glowsansTC = callPackage (glowsans {
#     pname = "glowsans-TC";
#     version = "0.93";
#     lang = "TC";

#     sha256 = "sha256-FuiigAGrGymIfb9jb7NiPkExeMSy/LgmBKZrudGAZUc=";
#   }) { };
# })
# glowsansTC
# glowsansSC
# glowsansJ
# ;

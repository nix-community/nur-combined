{ stdenv, callPackage, buildEnv }:
with stdenv.lib;
let
  setbg = callPackage ./setbg.nix { };
  ds = callPackage ./displayselect { };
in
  buildEnv {
    name = "larbs-scripts";
    paths = [
      setbg
      ds
    ];

    meta = {
      homepage = "https://github.com/LukeSmithxyz/voidrice";
      description = "Set of larbs user scripts";
      platforms = [ "x86_64-linux" ];
    };
  }

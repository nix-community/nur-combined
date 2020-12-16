{ stdenv, callPackage, buildEnv, opustags }:
with stdenv.lib;
let
  bare = callPackage ./bare.nix { };
  cron = callPackage ./cron.nix { };
  statusbar = callPackage ./statusbar.nix { };
  slider = callPackage ./slider.nix { };
in
  buildEnv {
    name = "larbs-scripts";
    paths = [
      bare
      cron
      statusbar

      opustags

      ## Movie creation
      slider
    ];

    meta = {
      homepage = "https://github.com/LukeSmithxyz/voidrice";
      description = "Set of larbs user scripts";
      platforms = [ "x86_64-linux" ];
    };
  }

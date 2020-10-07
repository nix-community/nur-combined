{ stdenv, callPackage, buildEnv }:
with stdenv.lib;
let
  bare = callPackage ./bare.nix { };
  cron = callPackage ./cron.nix { };
  i3cmds = callPackage ./i3cmds.nix { };
  statusbar = callPackage ./statusbar.nix { };
in
  buildEnv {
    name = "larbs-scripts";
    paths = [
      bare
      cron
      i3cmds
      statusbar
    ];

    meta = {
      homepage = "https://github.com/LukeSmithxyz/voidrice";
      description = "Set of larbs user scripts";
      platforms = [ "x86_64-linux" ];
    };
  }

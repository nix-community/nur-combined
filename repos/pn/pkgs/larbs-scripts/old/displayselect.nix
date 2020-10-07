{ stdenv, buildEnv, callPackage, xrandr, libnotify, arandr }:
with stdenv.lib;

let
  voidrice = callPackage ../voidrice.nix { };
  dmenu = callPackage ../larbs/dmenu { };
in
  buildEnv {
    name = "displayselect";

    paths = [
      xrandr
      arandr
      libnotify
      dmenu
    ];

    postBuild = ''
      mkdir -p $out/bin
      cp ${voidrice}/.local/bin/displayselect $out/bin
    '';


    meta = {
      description = "A fancy monitor configuration menu.";
      homepage = "https://github.com/LukeSmithXYZ/voidrice";
    };
  }

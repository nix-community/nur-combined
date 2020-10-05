{ stdenv, buildEnv, callPackage, lib, xrandr, libnotify, arandr }:

displayselect:

let

  mapCase = options:
  builtins.concatStringsSep "\n"
  (builtins.map
  (option: "\t\"${option}\") ${builtins.getAttr option options} ;;")
  (builtins.attrNames options));

  wrapper = { moreOptions ? {} }:
  let
    dmenu = callPackage ../../dmenu { };
  in
  buildEnv {
    name = "displayselect-env";

    paths = [
      xrandr
      arandr
      libnotify
      dmenu
    ];

    postBuild = ''
      mkdir -p $out/bin
      cp ${displayselect}/bin/displayselect $out/bin
      echo ${mapCase moreOptions} >> $out/bin/test
    '';


    meta = {
      description = "A fancy monitor configuration menu.";
      homepage = "https://github.com/LukeSmithXYZ/voidrice";
    };
  };
in
  lib.makeOverridable wrapper

{ stdenv, callPackage, xwallpaper, libnotify, pywal }:
let
  voidrice = callPackage ../voidrice.nix { };
in
  stdenv.mkDerivation {
    name = "setbg";
    src = voidrice;

    buildInputs = [
      xwallpaper
      libnotify
      pywal
    ];

    installPhase = ''
      mkdir -p $out/bin
      cp ${voidrice}/.local/bin/setbg $out/bin/setbg
    '';

    meta = {
      description = "A fancy background setter.";
      homepage = "https://github.com/LukeSmithXYZ/voidrice";
    };
  }

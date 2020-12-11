{ stdenv, callPackage }:
let
  voidrice = callPackage ../voidrice.nix { };
in
  stdenv.mkDerivation {
    name = "statusbar";
    src = voidrice;

    installPhase = ''
      mkdir -p $out
      cp -r ${voidrice}/.local/bin/statusbar $out/bin
    '';

    meta = {
      description = "statusbar";
      homepage = "https://github.com/LukeSmithXYZ/voidrice";
    };
  }

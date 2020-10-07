{ stdenv, callPackage }:
let
  voidrice = callPackage ../voidrice.nix { };
in
  stdenv.mkDerivation {
    name = "linkhandler";
    src = voidrice;

    installPhase = ''
      mkdir -p $out/bin
      cp ${voidrice}/.local/bin/linkhandler $out/bin/linkhandler
    '';

    meta = {
      description = "Link handler";
      homepage = "https://github.com/LukeSmithXYZ/voidrice";
    };
  }

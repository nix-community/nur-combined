{ stdenv, callPackage }:
let
  voidrice = callPackage ../../voidrice.nix { };
in
  stdenv.mkDerivation {
    name = "displayselect";
    src = voidrice;

    installPhase = ''
      mkdir -p $out/bin
      cp ${voidrice}/.local/bin/displayselect $out/bin/displayselect
    '';
  }

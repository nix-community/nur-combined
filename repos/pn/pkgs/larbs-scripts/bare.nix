{ stdenv, callPackage }:
let
  voidrice = callPackage ../voidrice.nix { };
in
  stdenv.mkDerivation {
    name = "bare";
    src = voidrice;

    installPhase = ''
      mkdir -p $out/bin
      for f in `ls -p ${voidrice}/.local/bin | grep -v /`; do
        cp ${voidrice}/.local/bin/$f $out/bin
      done
      rm $out/bin/slider
    '';

    meta = {
      description = "bare";
      homepage = "https://github.com/LukeSmithXYZ/voidrice";
    };
  }

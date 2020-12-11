{ stdenv, callPackage }:
let
  voidrice = callPackage ../voidrice.nix { };
in
  stdenv.mkDerivation {
    name = "cron";
    src = voidrice;

    installPhase = ''
      mkdir -p $out
      cp -r ${voidrice}/.local/bin/cron $out/bin
    '';

    meta = {
      description = "cron";
      homepage = "https://github.com/LukeSmithXYZ/voidrice";
    };
  }

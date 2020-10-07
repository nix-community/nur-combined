{ stdenv, callPackage }:
let
  voidrice = callPackage ../voidrice.nix { };
in
  stdenv.mkDerivation {
    name = "i3cmds";
    src = voidrice;

    installPhase = ''
      mkdir -p $out/bin
      cp -r ${voidrice}/.local/bin/i3cmds $out/bin
    '';

    meta = {
      description = "i3cmds";
      homepage = "https://github.com/LukeSmithXYZ/voidrice";
    };
  }

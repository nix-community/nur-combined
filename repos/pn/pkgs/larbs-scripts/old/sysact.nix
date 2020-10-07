{ stdenv, callPackage, slock }:
let
  voidrice = callPackage ../voidrice.nix { };
in
  stdenv.mkDerivation {
    name = "sysact";
    src = voidrice;

    installPhase = ''
      mkdir -p $out/bin
      cp ${voidrice}/.local/bin/sysact $out/bin/sysact
      sed -i "s:slock:${slock}/bin/slock:g" $out/bin/sysact
    '';

    meta = {
      description = "Power menu. (shutdown, hibernate etc)";
      homepage = "https://github.com/LukeSmithXYZ/voidrice";
    };
  }

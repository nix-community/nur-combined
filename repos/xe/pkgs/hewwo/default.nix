{ stdenv, perl, coreutils, makeWrapper, lib }:

let
  hewwo = stdenv.mkDerivation {
    pname = "hewwo";
    version = "watest";
    src = ./hewwo.sh;

    phases = "installPhase";

    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/hewwo
      chmod a+x $out/bin/hewwo
    '';
  };
in stdenv.mkDerivation {
  inherit (hewwo) name;
  phases = "installPhase";

  buildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${hewwo}/bin/hewwo $out/bin/hewwo --prefix PATH : ${
      lib.makeBinPath [ perl coreutils ]
    }
  '';
}

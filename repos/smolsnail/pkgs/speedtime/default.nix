{ lib, stdenv, fetchgit, tup }:

let
  pname = "speedtime";
  url = "https://gitdab.com/elle/${pname}";
in 
  stdenv.mkDerivation rec {
    inherit pname;
    version = "2021.10.12";

    src = fetchgit {
      inherit url;
      rev = version;
      sha256 = "1595ls0l742nfdhs7xy2dkw8m7yz41pl692a5r14g4d6vpf83p0h";
    };

    nativeBuildInputs = [ tup ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin $out/share/man/man1
      cp ./speedtime $out/bin/
      cp ./speedtime.1 $out/share/man/man1/
      runHook postInstall
    '';

    meta = with lib; {
      description = "A timer for Linux.";
      longDescription = ''
        Speedtime is a timer for Linux that runs entirely within a terminal.
      '';
      homepage = url;
      license = licenses.free;
      platforms = platforms.linux;
    };
  }

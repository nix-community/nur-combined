{ stdenv, lib, fetchurl }:

stdenv.mkDerivation rec {
    pname = "travis-analyzer";
    version = "03Jun2020";

    src = fetchurl  {
      url = "http://www.travis-analyzer.de/files/travis-src-200504-hf2.tar.gz";
      sha256= "01c5jpaa1mvh0fk0h3ch0hdxd5bqnpf3i68nnql26qjf5q7s5a51";
    };

    dontConfigure = true;
    enableParallelBuilding = true;

    installPhase = ''
      mkdir -p $out/bin
      cp exe/travis $out/bin/.
    '';

    meta = with lib; {
      description = "Molecular dynamics trajectory analyzer and visualizer";
      license = licenses.lgpl3Only;
      homepage = "http://www.travis-analyzer.de/";
      platforms = platforms.linux;
    };
  }

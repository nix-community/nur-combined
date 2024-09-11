{ fetchzip, stdenv, lib, makeWrapper, jre }:
stdenv.mkDerivation rec {
  pname = "ltsatool";
  version = "3.0";

  src = fetchzip {
    url = "https://www.doc.ic.ac.uk/~jnm/book/ltsa/ltsatool.zip";
    hash = "sha256-1qoy69GVOZMBFQondG1yDaK219umgA5B/3usPZb03S8=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/opt
    cp -R $src/* $out/opt/
    mkdir -p $out/bin
    makeWrapper ${jre}/bin/java $out/bin/ltsatool \
        --add-flags "-jar $out/opt/ltsa.jar" \
        --set GTK_THEME Adwaita
  '';
}

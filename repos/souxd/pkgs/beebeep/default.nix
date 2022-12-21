{ stdenv
, lib
, fetchurl
, qtbase
, qtmultimedia
, qtx11extras
, unzip
, autoPatchelfHook
, wrapQtAppsHook
}:

stdenv.mkDerivation rec {
  pname = "beebeep";
  version = "5.8.4";

  src = fetchurl {
    url = "https://sourceforge.net/projects/beebeep/files/Linux/${pname}-${version}-qt5-amd64.tar.gz";
    sha256 = "0r79kiqk4klah810srkxgdfg2lisvxfz9w432y2h48k0via8g6n3";
  };

  nativeBuildInputs = [
    unzip
    autoPatchelfHook
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    qtmultimedia
    qtx11extras
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp -t $out/bin *
  '';

  meta = with lib; {
    description = "Free office messenger";
    longDescription = ''BeeBEEP is the office messaging application that does not need
 an external server to let users communicate with each other.'';
    homepage = https://www.beebeep.net/;
    changelog = "https://sourceforge.net/p/beebeep/code/HEAD/tree/CHANGELOG.txt";
    licence = licenses.gpl3;
    platforms = platforms.linux;
  };
}

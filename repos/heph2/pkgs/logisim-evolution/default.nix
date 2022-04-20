{ lib, stdenv, fetchurl, jre, makeWrapper }:

stdenv.mkDerivation {
  pname = "logisim-evolution";
  version = "3.6.0";

  src = fetchurl {
    url = "https://github.com/logisim-evolution/logisim-evolution/releases/download/v3.6.0/logisim-evolution-3.6.0-all.jar";
    sha256 = "1ysq5grj011c0d93ky48a5zkpcp10dxs8azqcwn1yjapdw5a5a36";
  };

  phases = [ "installPhase" ];

  nativeBuildInputs = [makeWrapper];

  installPhase = ''
     mkdir -pv $out/bin
     makeWrapper ${jre}/bin/java $out/bin/logisim-evolution --add-flags "-jar $src"
  '';

  meta = {
    homepage = "https://github.com/logisim-evolution";
    description = "Educational tool for designing and simulating digital logic circuits";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    broken = true;
  };
}

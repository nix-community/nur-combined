 { stdenv, lib
, fetchurl
}:

stdenv.mkDerivation rec {
  pname = "cntb-bin";
  version = "1.4.2";

  src = fetchurl {
    url = "https://github.com/contabo/cntb/releases/download/v${version}/cntb_v${version}_Linux_x86_64.tar.gz";
    sha256 = "sha256-PLuMsKyYVuVwvFjtUda61kZ6sSOiFSq/goXjf5jBfBQ=";
  };

  sourceRoot = ".";

  installPhase = ''
    install -m755 -D cntb $out/bin/cntb
  '';

  meta = with lib; {
    homepage = "https://github.com/contabo/cntb";
    description = "Contabo Command Line Interface (Binary)";
    platforms = platforms.linux;
    license = licenses.gpl3;
  };
}

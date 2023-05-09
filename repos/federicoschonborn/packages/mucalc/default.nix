{ lib
, stdenv
, fetchzip
, cmake
, muparser
, readline
}:

stdenv.mkDerivation rec {
  pname = "mucalc";
  version = "2.1";

  src = fetchzip {
    url = "https://marlam.de/mucalc/releases/mucalc-${version}.tar.gz";
    hash = "sha256-qXqe9U7y3YrzSeJKgW53vkdNpPcAmxysxzT7SIlSzMo=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    muparser
    readline
  ];

  meta = with lib; {
    description = "A convenient calculator for the command line";
    homepage = "https://marlam.de/mucalc/";
    downloadPage = "https://marlam.de/mucalc/download/";
    license = licenses.gpl3Plus;
  };
}

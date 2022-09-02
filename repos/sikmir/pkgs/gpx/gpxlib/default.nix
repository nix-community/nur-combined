{ lib, stdenv, fetchFromGitHub, cmake, expat }:

stdenv.mkDerivation rec {
  pname = "gpxlib";
  version = "2021-02-16";

  src = fetchFromGitHub {
    owner = "irdvo";
    repo = "gpxlib";
    rev = "43df92be29412b7f3b58e63ebea516df9f15b883";
    hash = "sha256-Ai6d2N0H+V/xzWVYL/jfJtQMaUVpY0ecNCISfugbE2k=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ expat ];

  cmakeFlags = [
    "-DBUILD_EXAMPLES=OFF"
    "-DBUILD_TESTS=OFF"
  ];

  doCheck = false;
  checkPhase = ''
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH''${LD_LIBRARY_PATH:+:}$PWD/gpx
    export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH''${DYLD_LIBRARY_PATH:+:}$PWD/gpx
    test/gpxcheck
  '';

  meta = with lib; {
    description = "A c++ library for parsing, browsing, changing and writing of GPX files";
    homepage = "http://irdvo.nl/gpxlib/";
    license = licenses.lgpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}

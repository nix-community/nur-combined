{ stdenv, cmake, expat, sources }:

stdenv.mkDerivation {
  pname = "gpxlib-unstable";
  version = stdenv.lib.substring 0 10 sources.gpxlib.date;

  src = sources.gpxlib;

  nativeBuildInputs = [ cmake ];

  buildInputs = [ expat ];

  cmakeFlags = [
    "-DBUILD_EXAMPLES=OFF"
    "-DBUILD_TESTS=ON"
  ];

  doCheck = true;
  checkPhase = ''
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH''${LD_LIBRARY_PATH:+:}$PWD/gpx
    export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH''${DYLD_LIBRARY_PATH:+:}$PWD/gpx
    test/gpxcheck
  '';

  meta = with stdenv.lib; {
    inherit (sources.gpxlib) description homepage;
    license = licenses.lgpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}

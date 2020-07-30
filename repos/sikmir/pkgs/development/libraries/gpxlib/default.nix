{ stdenv, cmake, expat, sources }:
let
  pname = "gpxlib";
  date = stdenv.lib.substring 0 10 sources.gpxlib.date;
  version = "unstable-" + date;
in
stdenv.mkDerivation {
  inherit pname version;
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

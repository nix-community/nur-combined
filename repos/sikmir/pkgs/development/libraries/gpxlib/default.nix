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

  meta = with stdenv.lib; {
    inherit (sources.gpxlib) description homepage;
    license = licenses.lgpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}

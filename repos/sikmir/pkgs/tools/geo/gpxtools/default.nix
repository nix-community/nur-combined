{ stdenv, cmake, expat, sources }:

stdenv.mkDerivation rec {
  pname = "gpxtools";
  version = stdenv.lib.substring 0 7 src.rev;
  src = sources.gpxtools;

  nativeBuildInputs = [ cmake ];
  buildInputs = [ expat ];

  installPhase = ''
    install -Dm755 gpx* -t $out/bin
  '';

  meta = with stdenv.lib; {
    inherit (src) description homepage;
    license = licenses.gpl3;
    maintainers = with maintainers; [ sikmir ];
    platforms = with platforms; linux ++ darwin;
  };
}

{ stdenv, cmake, expat, gpxtools }:

stdenv.mkDerivation rec {
  pname = "gpxtools";
  version = stdenv.lib.substring 0 7 src.rev;
  src = gpxtools;

  nativeBuildInputs = [ cmake ];
  buildInputs = [ expat ];

  installPhase = ''
    install -Dm755 gpx* -t $out/bin
  '';

  meta = with stdenv.lib; {
    description = gpxtools.description;
    homepage = gpxtools.homepage;
    license = licenses.gpl3;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}

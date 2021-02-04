{ lib, stdenv, cmake, expat, exiv2, sources }:

stdenv.mkDerivation {
  pname = "gpxtools";
  version = lib.substring 0 10 sources.gpxtools.date;

  src = sources.gpxtools;

  nativeBuildInputs = [ cmake ];
  buildInputs = [ expat ];

  postPatch = ''
    substituteInPlace gpxgeotag.cpp \
      --replace "exiv2" "${exiv2}/bin/exiv2"
  '';

  installPhase = "install -Dm755 gpx* -t $out/bin";

  meta = with lib; {
    inherit (sources.gpxtools) description homepage;
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}

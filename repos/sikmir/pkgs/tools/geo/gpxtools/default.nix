{ stdenv, cmake, expat, exiv2, sources }:

stdenv.mkDerivation {
  pname = "gpxtools";
  version = stdenv.lib.substring 0 7 sources.gpxtools.rev;
  src = sources.gpxtools;

  nativeBuildInputs = [ cmake ];
  buildInputs = [ expat ];

  postPatch = ''
    substituteInPlace gpxgeotag.cpp \
      --replace "exiv2" "${exiv2}/bin/exiv2"
  '';

  installPhase = ''
    install -Dm755 gpx* -t $out/bin
  '';

  meta = with stdenv.lib; {
    inherit (sources.gpxtools) description homepage;
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}

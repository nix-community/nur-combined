{ lib, stdenv, fetchgit, cmake, expat, exiv2 }:

stdenv.mkDerivation {
  pname = "gpxtools";
  version = "2022-01-11";

  src = fetchgit {
    url = "https://notabug.org/irdvo/gpxtools.git";
    rev = "45b7b8f5a42d8426f2fc998d017d2f224943f959";
    hash = "sha256-hhvxQ+2jOvY0OVt8iKQ9XcHgRN4ECywV1W1fKV7Q9Mo=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ expat ];

  postPatch = ''
    substituteInPlace gpxgeotag.cpp \
      --replace "exiv2" "${exiv2}/bin/exiv2"
  '';

  installPhase = "install -Dm755 gpx* -t $out/bin";

  meta = with lib; {
    description = "A collection of c++ tools for using GPX files";
    homepage = "https://notabug.org/irdvo/gpxtools";
    license = licenses.gpl3Only;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}

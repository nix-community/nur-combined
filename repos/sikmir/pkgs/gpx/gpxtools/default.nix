{
  lib,
  stdenv,
  fetchFromGitea,
  cmake,
  expat,
  exiv2,
}:

stdenv.mkDerivation {
  pname = "gpxtools";
  version = "0-unstable-2023-08-13";

  src = fetchFromGitea {
    domain = "notabug.org";
    owner = "irdvo";
    repo = "gpxtools";
    rev = "bad31cc7e278c835db196ed4013551034c606f09";
    hash = "sha256-QFjHlUByD4iqEUDYhl3dcol3B8sGV+BLN7IumqQXxdA=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ expat ];

  postPatch = ''
    substituteInPlace gpxgeotag.cpp \
      --replace-fail "exiv2" "${exiv2}/bin/exiv2"
  '';

  installPhase = "install -Dm755 gpx* -t $out/bin";

  meta = {
    description = "A collection of c++ tools for using GPX files";
    homepage = "https://notabug.org/irdvo/gpxtools";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
}

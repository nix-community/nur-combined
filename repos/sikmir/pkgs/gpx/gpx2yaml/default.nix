{
  lib,
  stdenv,
  fetchFromSourcehut,
}:

stdenv.mkDerivation {
  pname = "gpx2yaml";
  version = "0-unstable-2025-01-29";

  src = fetchFromSourcehut {
    owner = "~sikmir";
    repo = "gpx2yaml";
    rev = "ca58a14ad48f76fbf7b6ad7ff52ddda9c4448309";
    hash = "sha256-GYSTqbRkv0oYIRgNS8VlMLj/GMA4FipfaGvxk959eMc=";
  };

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "GPX to YAML converter";
    homepage = "https://git.sikmir.ru/gpx2yaml";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
}

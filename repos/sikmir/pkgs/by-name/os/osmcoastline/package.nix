{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  bzip2,
  expat,
  gdal,
  geos,
  libosmium,
  protozero,
  sqlite,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "osmcoastline";
  version = "2.4.1";

  src = fetchFromGitHub {
    owner = "osmcode";
    repo = "osmcoastline";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mycETpGyC5Se3ruR4c+7NQQJaoE7XpRb9gUSSew4QX8=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    bzip2
    expat
    gdal
    geos
    libosmium
    protozero
    sqlite
    zlib
  ];

  meta = {
    description = "Extracts coastline data from OpenStreetMap planet file";
    homepage = "https://osmcode.org/osmcoastline/";
    license = lib.licenses.boost;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})

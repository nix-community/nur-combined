{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  boost,
  bzip2,
  expat,
  gdal,
  geos,
  libosmium,
  protozero,
  sqlite,
  zlib,
}:

stdenv.mkDerivation {
  pname = "osm-area-tools";
  version = "0-unstable-2024-12-16";

  src = fetchFromGitHub {
    owner = "osmcode";
    repo = "osm-area-tools";
    rev = "2d633ec085501afa04db2b915339ccc6ac0123f7";
    hash = "sha256-x3EvtuyP0shtl5HntmNh0cfycV/yqH80YuC1PAP6PP4=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    boost
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
    description = "OSM Area Tools";
    homepage = "https://osmcode.org/osm-area-tools/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
}

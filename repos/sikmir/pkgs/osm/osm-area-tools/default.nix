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
  version = "0-unstable-2023-06-15";

  src = fetchFromGitHub {
    owner = "osmcode";
    repo = "osm-area-tools";
    rev = "774443167f2e08222178253d83de359eb967d1e2";
    hash = "sha256-3RfZhexzaLx3CJol3gKkNP4f9z0ccT1l2WNf3EOuhkE=";
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

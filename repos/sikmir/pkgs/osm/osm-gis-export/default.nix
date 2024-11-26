{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  boost,
  bzip2,
  expat,
  fmt,
  gdal,
  libosmium,
  protozero,
  sqlite,
  zlib,
}:

stdenv.mkDerivation {
  pname = "osm-gis-export";
  version = "0-unstable-2024-11-01";

  src = fetchFromGitHub {
    owner = "osmcode";
    repo = "osm-gis-export";
    rev = "4b1ccdf360650e7c2e417aa32290037f8348de51";
    hash = "sha256-+57FHSLP9wCeEGziPrKdsvzXvjwo9HXtgj+yP94psiU=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    boost
    bzip2
    expat
    fmt
    gdal
    libosmium
    protozero
    sqlite
    zlib
  ];

  meta = {
    description = "Export OSM data to GIS formats like Shapefiles, Spatialite or PostGIS";
    homepage = "https://github.com/osmcode/osm-gis-export";
    license = lib.licenses.boost;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
}

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
  version = "0-unstable-2024-12-16";

  src = fetchFromGitHub {
    owner = "osmcode";
    repo = "osm-gis-export";
    rev = "2b3796c53b255018630fa4ee4042c8b2721b24e5";
    hash = "sha256-uQRIeBUGEiEilfNtnJIj6w8J7Q3GQvx5plgRNxLIoOY=";
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

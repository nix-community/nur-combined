{ lib
, stdenv
, fetchFromGitHub
, cmake
, bzip2
, expat
, gdal
, geos
, libosmium
, protozero
, sqlite
, zlib
}:

stdenv.mkDerivation rec {
  pname = "osmcoastline";
  version = "2.3.1";

  src = fetchFromGitHub {
    owner = "osmcode";
    repo = "osmcoastline";
    rev = "v${version}";
    hash = "sha256-z72xDag3CDik/zGhQjlmE/Yfz/KEwK/A1clyP3AY7Uo=";
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

  meta = with lib; {
    description = "Extracts coastline data from OpenStreetMap planet file";
    homepage = "https://osmcode.org/osmcoastline/";
    license = licenses.boost;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}

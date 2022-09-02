{ lib
, stdenv
, fetchFromGitHub
, cmake
, boost
, bzip2
, expat
, gdal
, libosmium
, protozero
, sqlite
, zlib
}:

stdenv.mkDerivation rec {
  pname = "osm-area-tools";
  version = "2021-01-04";

  src = fetchFromGitHub {
    owner = "osmcode";
    repo = "osm-area-tools";
    rev = "b96db0ced55f1bb574084620ca34f0a2e9d19b5a";
    hash = "sha256-bMD+8Md3rwlpsAu48YerfIFGq86PDfqTsKw5JeQUi6s=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    boost
    bzip2
    expat
    gdal
    libosmium
    protozero
    sqlite
    zlib
  ];

  meta = with lib; {
    description = "OSM Area Tools";
    homepage = "https://osmcode.org/osm-area-tools/";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}

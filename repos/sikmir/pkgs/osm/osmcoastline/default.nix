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
  version = "2021-01-08";

  src = fetchFromGitHub {
    owner = "osmcode";
    repo = pname;
    rev = "56371668ebb6261009f35a7411a8fbcc83aabfe0";
    hash = "sha256-gW6VJ4u4FBJO4mnDIpDW3KRoXmTbcsZhb5762bqv92A=";
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

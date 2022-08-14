{ lib
, stdenv
, fetchFromGitHub
, cmake
, boost
, bzip2
, expat
, fmt
, gdal
, libosmium
, protozero
, sqlite
, zlib
}:

stdenv.mkDerivation rec {
  pname = "osmium-surplus";
  version = "2022-08-13";

  src = fetchFromGitHub {
    owner = "osmcode";
    repo = "osmium-surplus";
    rev = "ac330247d75337e9381f6a3d21c8b851d5061ed9";
    hash = "sha256-hvfeKUw/kMeja48WFTgmkAQhisCizLuLdoNh9yhNvWM=";
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

  meta = with lib; {
    description = "Collection of assorted small programs based on the Osmium framework";
    homepage = "https://github.com/osmcode/osmium-surplus";
    license = with licenses; [ gpl3Plus boost ];
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}

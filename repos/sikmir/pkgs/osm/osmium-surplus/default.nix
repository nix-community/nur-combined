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
  pname = "osmium-surplus";
  version = "0-unstable-2023-08-27";

  src = fetchFromGitHub {
    owner = "osmcode";
    repo = "osmium-surplus";
    rev = "0500e8583da3634a2304513dc33cba27f080c7af";
    hash = "sha256-NFOui9wWUSHSsyKh5UxOXQMUNgfVln1hSXJo9yb4cnY=";
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
    license = [
      licenses.gpl3Plus
      licenses.boost
    ];
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}

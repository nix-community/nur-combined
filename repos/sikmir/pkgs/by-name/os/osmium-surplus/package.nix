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
  version = "0-unstable-2026-06-26";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "osmcode";
    repo = "osmium-surplus";
    rev = "1335bfe2b0e02fedd43311eb5b618b8a27550a8e";
    hash = "sha256-hbSSx+4t8T+VquSKIRYCVmWtfaiPy/6hTOeCeBahW7I=";
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
    description = "Collection of assorted small programs based on the Osmium framework";
    homepage = "https://github.com/osmcode/osmium-surplus";
    license = with lib.licenses; [
      gpl3Plus
      boost
    ];
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
}

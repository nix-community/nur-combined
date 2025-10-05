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
  version = "0-unstable-2024-12-16";

  src = fetchFromGitHub {
    owner = "osmcode";
    repo = "osmium-surplus";
    rev = "ebb21d60b4b585b4f87bfd880be54907638c70a0";
    hash = "sha256-Yuay8w2MvZOwXFWaVzSex/o7AVCfFSfmc8v3LXoM7d8=";
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

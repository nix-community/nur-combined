{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  boost188,
  gdal,
  gsl,
  hdf5,
  kealib,
  muparser,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rsgislib";
  version = "5.2.3";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "remotesensinginfo";
    repo = "rsgislib";
    tag = finalAttrs.version;
    hash = "sha256-LaqKhINW0LDjlhWZaSZ9Yw6xmEfG5xSYwUPHMcz1I18=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    boost188
    gdal
    gsl
    hdf5
    kealib
    muparser
    python3
  ];

  meta = {
    description = "Remote Sensing and GIS Software Library";
    homepage = "https://www.rsgislib.org/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
    skip.ci = true;
  };
})

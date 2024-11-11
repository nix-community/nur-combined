{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  boost,
  gdal,
  gsl,
  hdf5,
  kealib,
  muparser,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rsgislib";
  version = "5.1.7";

  src = fetchFromGitHub {
    owner = "remotesensinginfo";
    repo = "rsgislib";
    rev = finalAttrs.version;
    hash = "sha256-IaDSn+8cF7fo+l4/gTUJrF5iro3qHnXUd5iImekaqLg=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    boost
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
  };
})

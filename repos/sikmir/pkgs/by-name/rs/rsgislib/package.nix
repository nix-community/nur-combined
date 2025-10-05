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
  version = "5.1.8";

  src = fetchFromGitHub {
    owner = "remotesensinginfo";
    repo = "rsgislib";
    tag = finalAttrs.version;
    hash = "sha256-Hy7wYdi9M2UTAC9paZz2/EXC4FpjxTjuZ5iRPHw8zIU=";
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
    skip.ci = true;
  };
})

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
  version = "5.2.1";

  src = fetchFromGitHub {
    owner = "remotesensinginfo";
    repo = "rsgislib";
    tag = finalAttrs.version;
    hash = "sha256-2U5Kyrp7mc/x2GP/HMU5grVk4Trzo5Jq4YjMbGBZvm4=";
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

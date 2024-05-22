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

stdenv.mkDerivation rec {
  pname = "rsgislib";
  version = "5.1.3";

  src = fetchFromGitHub {
    owner = "remotesensinginfo";
    repo = "rsgislib";
    rev = version;
    hash = "sha256-RE5i2ULlgHEWHJIqeWNdnxtREcHrmP4dS996onJrBFk=";
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

  meta = with lib; {
    description = "Remote Sensing and GIS Software Library";
    homepage = "https://www.rsgislib.org/";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}

{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  hdf5,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kealib";
  version = "1.5.3";

  src = fetchFromGitHub {
    owner = "ubarsc";
    repo = "kealib";
    rev = "kealib-${finalAttrs.version}";
    hash = "sha256-s6sL8T1jRBmVCrFm00uCw9x6s43u9+GU3ihyMi7XSaQ=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ hdf5 ];

  meta = {
    description = "KEALib provides an implementation of the GDAL data model";
    homepage = "http://kealib.org/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})

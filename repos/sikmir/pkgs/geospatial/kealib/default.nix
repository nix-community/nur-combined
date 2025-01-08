{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  hdf5,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kealib";
  version = "1.6.1";

  src = fetchFromGitHub {
    owner = "ubarsc";
    repo = "kealib";
    tag = "kealib-${finalAttrs.version}";
    hash = "sha256-4EPOgojhtjBzygd7P1B3e1zvWhUrfc311vcHQ3j01Gc=";
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

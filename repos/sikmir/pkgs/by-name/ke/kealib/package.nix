{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  hdf5,
  highfive,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kealib";
  version = "2.0.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "ubarsc";
    repo = "kealib";
    tag = "kealib-${finalAttrs.version}";
    hash = "sha256-qfJmQy0iIu564tjAaMMypQ9pTbMCAwjjPHcvogt1guQ=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    hdf5
    highfive
  ];

  meta = {
    description = "KEALib provides an implementation of the GDAL data model";
    homepage = "http://kealib.org/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})

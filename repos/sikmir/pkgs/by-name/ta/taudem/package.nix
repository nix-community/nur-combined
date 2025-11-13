{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gdal,
  mpich,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "taudem";
  version = "5.3.8";

  src = fetchFromGitHub {
    owner = "dtarb";
    repo = "TauDEM";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lomjPyNzm9K4jCs7fYwDYrG48qbeRedakWFwJj7pDEI=";
  };

  sourceRoot = "${finalAttrs.src.name}/src";

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    gdal
    mpich
  ];

  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.10")
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-narrowing";

  meta = {
    description = "Terrain Analysis Using Digital Elevation Models";
    homepage = "http://hydrology.usu.edu/taudem";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})

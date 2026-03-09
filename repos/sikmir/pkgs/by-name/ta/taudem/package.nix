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
  version = "5.4.0";

  src = fetchFromGitHub {
    owner = "dtarb";
    repo = "TauDEM";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9gQUXmaA463Fra7u6Kyn2dplOXRCdvYp04gKNoG7Q4Y=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    gdal
    mpich
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-parentheses";

  postInstall = ''
    mv $out/{taudem,bin}
  '';

  meta = {
    description = "Terrain Analysis Using Digital Elevation Models";
    homepage = "http://hydrology.usu.edu/taudem";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})

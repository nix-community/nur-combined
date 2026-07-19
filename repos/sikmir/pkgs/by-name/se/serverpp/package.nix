{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  boost,
  gsl-lite,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "serverpp";
  version = "0.3.2";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "KazDragon";
    repo = "serverpp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OFuoNz+3bQ9PvZ79J7R8Qm/8atAR8TDWfhrGBQPgjrQ=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    boost
    gsl-lite
  ];

  meta = {
    description = "A C++ library for basic network server handling";
    homepage = "https://github.com/KazDragon/serverpp";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
    broken = stdenv.isDarwin;
  };
})

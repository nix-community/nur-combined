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
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "KazDragon";
    repo = "serverpp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-22mwf0/fwqkXzlgs+RMpjBQVT2D4T/vGZ3t0kKUqNsk=";
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

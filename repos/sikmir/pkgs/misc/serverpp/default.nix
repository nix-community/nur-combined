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
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "KazDragon";
    repo = "serverpp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-z7aLE7RyRGwUCpnJr0NS6yXUBPtHTnd81JOI/tGHDo0=";
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
  };
})

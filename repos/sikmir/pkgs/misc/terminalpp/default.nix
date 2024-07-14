{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  doxygen,
  boost,
  fmt,
  gsl-lite,
  gtest,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "terminalpp";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "KazDragon";
    repo = "terminalpp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-aD80uiZKyYRD2C7Oi+ESode6YZ0/KQUSor3u6nb5OD8=";
  };

  nativeBuildInputs = [
    cmake
    doxygen
  ];

  buildInputs = [
    boost
    fmt
    gsl-lite
    gtest
  ];

  meta = {
    description = "A C++ library for interacting with ANSI terminal windows";
    homepage = "https://github.com/KazDragon/terminalpp";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})

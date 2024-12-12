{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  doxygen,
  boost,
  gsl-lite,
  gtest,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "telnetpp";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "KazDragon";
    repo = "telnetpp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BfRu0dv2d7qwz2jTdaQczOQQBO3qmO1E754hWqxT66g=";
  };

  nativeBuildInputs = [
    cmake
    doxygen
  ];

  buildInputs = [
    boost
    gsl-lite
    gtest
    zlib
  ];

  cmakeFlags = [ (lib.cmakeBool "TELNETPP_WITH_ZLIB" true) ];

  meta = {
    description = "A C++ library for interacting with Telnet streams";
    homepage = "https://github.com/KazDragon/telnetpp";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})

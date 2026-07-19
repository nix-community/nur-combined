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
  version = "4.0.2";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "KazDragon";
    repo = "telnetpp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kA5V+vI3DiHIQnylY1kcCYirmT4Qm+sKX0G6uHcr6mw=";
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
    broken = stdenv.isDarwin;
  };
})

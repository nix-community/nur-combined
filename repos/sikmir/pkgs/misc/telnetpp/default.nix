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
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "KazDragon";
    repo = "telnetpp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BHN1zEnS7v0LScIbKSVETlO3gA5/7HLYVBkaFlu6k50=";
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

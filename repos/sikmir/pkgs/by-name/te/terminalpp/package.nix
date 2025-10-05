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
  version = "4.0.1";

  src = fetchFromGitHub {
    owner = "KazDragon";
    repo = "terminalpp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-d9fUfzEU5jUqWhaYVl6SH7+I4qn1Q7JIw0rtjZXivDU=";
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
    broken = stdenv.isDarwin;
  };
})

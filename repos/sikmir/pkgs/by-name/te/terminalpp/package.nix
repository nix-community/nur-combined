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
  version = "4.0.3";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "KazDragon";
    repo = "terminalpp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2B/k0BUAyetDgHGldZlqh/QU+jeWrHRvf5M4DLnlHoM=";
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

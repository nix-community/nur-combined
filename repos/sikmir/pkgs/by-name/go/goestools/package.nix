{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  opencv4,
  rtl-sdr,
  zlib,
}:

stdenv.mkDerivation {
  pname = "goestools";
  version = "0-unstable-2024-02-10";

  src = fetchFromGitHub {
    owner = "pietern";
    repo = "goestools";
    rev = "80ece1a7ab8a93fb5dfa50d47387ae7c4a8f2a73";
    hash = "sha256-qrtLiS1nFsGIFrazitLQetrEPiMP5SbBSbwp0bPhCV0=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    opencv4
    rtl-sdr
    zlib
  ];

  meta = {
    description = "Tools to work with signals and files from GOES satellites";
    homepage = "https://pietern.github.io/goestools/";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
    broken = true;
  };
}

{
  lib,
  stdenv,
  fetchFromGitHub,
  unstableGitUpdater,

  SDL2,
  libglvnd,
  libxext,
  libX11,
  libXcursor,
  libXrandr,
  libXi,

  pkg-config,
}:
stdenv.mkDerivation {
  pname = "sowon";
  version = "0-unstable-2025-12-03";

  src = fetchFromGitHub {
    owner = "tsoding";
    repo = "sowon";
    rev = "79b0f4fa3a3f3a6a702e9d25e69d9d7b1f011a06";
    hash = "sha256-bqedCIdxYON5UEJx6jimdeC5Fh90ElQ8ZeSIfq22U1s=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    SDL2
    libglvnd
    libxext
    libX11
    libXcursor
    libXrandr
    libXi
  ];

  installPhase = "make PREFIX=$out install";

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Starting Soon Timer for Tsoding Streams";
    homepage = "https://github.com/tsoding/sowon";
    license = lib.licenses.mit;
    mainProgram = "sowon";
  };
}

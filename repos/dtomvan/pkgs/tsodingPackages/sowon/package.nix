{
  lib,
  stdenv,
  fetchFromGitHub,
  unstableGitUpdater,

  SDL2,
  libglvnd,
  libxext,
  xorg,

  pkg-config,
}:
stdenv.mkDerivation {
  pname = "sowon";
  version = "0-unstable-2025-10-18";

  src = fetchFromGitHub {
    owner = "tsoding";
    repo = "sowon";
    rev = "31097e24bfea6f69c40fedfb8434d30c503a2e61";
    hash = "sha256-jrnyAHh8lNA7irXWXOavClRGUplmJP+nGddQN6N4zGA=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    SDL2
    libglvnd
    libxext
    xorg.libX11
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXi
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

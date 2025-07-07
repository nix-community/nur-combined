{
  stdenv,
  lib,
  meson,
  ninja,
  pkg-config,
  cmake,
  aubio,
  pipewire,
}:

stdenv.mkDerivation {
  pname = "beat-detector";
  version = "0.0.1";

  src = ./.;

  nativeBuildInputs = [
    meson
    ninja
    cmake
    pkg-config
    pipewire.dev
  ];

  buildInputs = [
    aubio
    pipewire
  ];

  meta = {
    description = "Util to detect beats from songs (from caelestia)";
    license = lib.licenses.gpl3;
    downloadPage = "https://github.com/caelestia-dots/shell/blob/main/assets/beat_detector.cpp";
    homePage = "https://github.com/caelestia-dots/shell";
    mainProgram = "beat-detector";
  };
}

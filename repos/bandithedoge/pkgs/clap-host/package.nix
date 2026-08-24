{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  cmake,
  ninja,
  pkg-config,
  qt6,
  rtaudio_6,
  rtmidi,
}:
stdenv.mkDerivation {
  pname = "clap-host";
  version = "1.0.3-unstable-2026-06-18";
  src = fetchFromGitHub {
    owner = "free-audio";
    repo = "clap-host";
    rev = "c8ce3ee3800fc605d31ffb077991004f26e8cb03";
    hash = "sha256-5QHY967WeSJt0k5YKa8/qor9TGRh6b22yVeD+zCbb44=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    rtaudio_6
    rtmidi
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "CLAP reference host";
    homepage = "https://github.com/free-audio/clap-host";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "clap-host";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}

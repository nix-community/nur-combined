{
  sources,

  lib,
  stdenv,

  cmake,
  ninja,
  pkg-config,
  qt6,
  rtaudio_6,
  rtmidi,
}:
stdenv.mkDerivation {
  inherit (sources.clap-host) pname version src;

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

  meta = {
    description = "CLAP reference host";
    homepage = "https://github.com/free-audio/clap-host";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "clap-host";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}

{
  stdenv,
  lib,
  fetchFromGitHub,
  pkg-config,
  libsForQt5,
  libjack2,
  fluidsynth,
  carla,
  liblscp,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "konfyt";
  version = "1.6.2";

  src = fetchFromGitHub {
    owner = "noedigcode";
    repo = "konfyt";
    rev = "v1.6.2";
    hash = "sha256-qbSUCpOVQdqeBLo/Zpd17pmzWO932CUV3nKli3eZBdQ=";
  };

  nativeBuildInputs = [
    libsForQt5.qmake
    libsForQt5.wrapQtAppsHook
    pkg-config
  ];

  buildInputs = [
    libsForQt5.qtbase
    libsForQt5.qtdeclarative
    libjack2
    fluidsynth
    carla
    liblscp
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp konfyt $out/bin/

    mkdir -p $out/share/applications
    cp desktopentry/konfyt.desktop $out/share/applications/

    mkdir -p $out/share/icons/hicolor/128x128/apps
    cp "icons/konfyt 128.png" $out/share/icons/hicolor/128x128/apps/konfyt.png

    runHook postInstall
  '';

  meta = with lib; {
    description = "Digital keyboard workstation for Linux";
    homepage = "https://github.com/noedigcode/konfyt";
    license = licenses.gpl3Plus;
    mainProgram = "konfyt";
    platforms = platforms.linux;
  };
})

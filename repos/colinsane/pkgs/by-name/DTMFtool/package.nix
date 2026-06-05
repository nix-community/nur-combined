{
  copyDesktopItems,
  fetchFromGitHub,
  makeDesktopItem,
  qt5,
  stdenv,
}:
stdenv.mkDerivation {
  pname = "DTMFtool";
  version = "0-unstable-2014-11-30";

  src = fetchFromGitHub {
    owner = "aso824";
    repo = "DTMFtool";
    rev = "7aeb5e6642f02f7679c76df949b10bb90bb700f9";
    hash = "sha256-6kkIm2KttJzR9RiBq8h6FJLSeT0kZLG9nAZuF/2RK1s=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    qt5.qmake
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    qt5.qtmultimedia
  ];

  # see <repo:nixos/nixpkgs:pkgs/development/libraries/qt-5/hooks/qtbase-setup-hook.sh>.
  # qmakePathHook only reads from nativeBuildInputs, not buildInputs.
  # this is probably wrong? maybe CMake has guidance for how that should be changed.
  preConfigure = ''
    export QMAKEPATH="${qt5.qtmultimedia.dev}''${QMAKEPATH:+:$QMAKEPATH}"
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "DTMFtool";
      exec = "DTMFtool";
      desktopName = "DTMF Tone Dialer";
    })
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 DTMFtool $out/bin/DTMFtool

    runHook postInstall
  '';

  strictDeps = true;

  meta = {
    description = "Easy-to-use DTMF generator";
    homepage = "https://github.com/aso824/DTMFtool";
  };
}

{
  lib,
  stdenv,
  fetchFromGitHub,
  makeDesktopItem,
  cmake,
  qt6,
}:

let
  desktopItem = makeDesktopItem {
    name = "linux-devmgmt";
    exec = "devmgmt";
    desktopName = "Device Manager";
    #comment = "";
    startupWMClass = ".devmgmt-wrapped";
  };
in
stdenv.mkDerivation rec {
  pname = "linux-devmgmt";
  version = "1.0-beta-8";

  src = fetchFromGitHub {
    owner = "actuallyaridan";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-6qH+KJ9M4yit1ZVpbpS0mSOxuKYMOJ/zdg5r9jssmpA=";
  };

  buildInputs = [
    qt6.qtbase
  ];

  nativeBuildInputs = [
    cmake
    qt6.wrapQtAppsHook
  ];

  installPhase = ''
    mkdir -p $out/{bin,share/applications}
    cp devmgmt $out/bin
    cp ${desktopItem}/share/applications/*.desktop $out/share/applications/
  '';

  meta = with lib; {
    description = "A faithful recreation of the Windows Device Manager built with Qt6 and real hardware backends via sysfs/procfs";
    homepage = "https://github.com/actuallyaridan/linux-devmgmt";
    license = licenses.gpl3;
    platforms = platforms.linux;
    mainProgram = "devmgmt";
  };
}

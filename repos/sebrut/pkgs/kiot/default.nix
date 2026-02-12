{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  qt6,
  kdePackages,
  pkg-config
}:
stdenv.mkDerivation rec {
  pname = "kiot";

  version = "1b516256825214540192fe45de2a86018a05301b";

  src = fetchFromGitHub {
    owner = "davidedmundson";
    repo = "kiot";
    rev = "${version}";
    hash = "sha256-aw0ZkU6Lhmn8ExosY8kBgDAsg6PWk5iuK8C4+lqQm50=";
  };

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
    qt6.wrapQtAppsHook
    qt6.qttools
    pkg-config
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtmqtt
    kdePackages.frameworkintegration
    kdePackages.kidletime
    kdePackages.bluez-qt
    kdePackages.pulseaudio-qt
  ];

  meta = with lib; {
    mainProgram = "kiot";
  };
}

{ stdenv
, lib
, fetchFromGitHub
, cmake
, pkg-config
, kdePackages
, qt6
, xorg
, freetype
, libxcrypt
, lingmoui
, lingmo-core
, lib_lingmo
}:

stdenv.mkDerivation rec {
  pname = "lingmo-settings";
  version = "main";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-settings";
    rev = "78c6f1483594285dc01ea59591f761a570ecea80";
    # TODO: 首次构建将报错，请将报错提供的 Hash 填入此处
    hash = "sha256-2R/luQQvjRseK0sXOmBh4tni2uT24QEZih/DFTYOnPM=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    kdePackages.extra-cmake-modules
    kdePackages.wrapQtAppsHook
    qt6.qttools
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtwayland
    kdePackages.kcoreaddons
    kdePackages.kwindowsystem
    kdePackages.kconfig
    kdePackages.networkmanager-qt
    kdePackages.modemmanager-qt
    xorg.libX11
    freetype
    libxcrypt
    lingmoui
    lingmo-core
    lib_lingmo
  ];
}

{ stdenv
, lib
, fetchFromGitHub
, cmake
, pkg-config
, kdePackages
, qt6
, polkit
, xorg
, lingmoui
}:

stdenv.mkDerivation rec {
  pname = "lingmo-core";
  version = "main";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-core";
    rev = "50f42d6c6531ce34852446278f27be8238a3a8f4";
    # TODO: 首次构建将报错，请将报错提供的 Hash 填入此处
    hash = "sha256-oDIIe/Wcbs8ZP3ayo9SaM8WBfTZ5vAmvvuuFcYn8YvY=";
  };

  postPatch = ''
    # Fix absolute installation paths
    sed -i 's|DESTINATION /usr/|DESTINATION |g' notificationd/CMakeLists.txt
    sed -i 's|DESTINATION /etc|DESTINATION etc|g' CMakeLists.txt
  '';

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
    qt6.qtsvg
    qt6.qtwayland
    kdePackages.kwindowsystem
    kdePackages.kcoreaddons
    kdePackages.kconfig
    kdePackages.polkit-qt-1
    kdePackages.kidletime
    polkit
    xorg.libSM
    xorg.libXcursor
    xorg.libX11
    xorg.xorgserver
    xorg.xf86inputlibinput
    xorg.xf86inputsynaptics
    lingmoui
  ];
}

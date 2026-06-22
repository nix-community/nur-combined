{ stdenv, lib, fetchFromGitHub, cmake, pkg-config, libsForQt5, xorg, pam }:

stdenv.mkDerivation rec {
  pname = "lingmo-screenlocker";
  version = "main";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-screenlocker";
    rev = "d16aa1d2b2cb39489da4f2bbda06422cac09ec16";
    hash = "sha256-6GjkyC5BhXAuO7lqMcw+eXtKHLkfnQx6AUTRclVulu8=";
  };

  postPatch = ''
    find . -name "CMakeLists.txt" -exec sed -i 's|DESTINATION "/usr/|DESTINATION "|g' {} +
    find . -name "CMakeLists.txt" -exec sed -i 's|DESTINATION "/etc/|DESTINATION "etc/|g' {} +
    find . -name "CMakeLists.txt" -exec sed -i 's|DESTINATION /usr/|DESTINATION |g' {} +
    find . -name "CMakeLists.txt" -exec sed -i 's|DESTINATION /etc/|DESTINATION etc/|g' {} +
    find . -name "CMakeLists.txt" -exec sed -i 's|DESTINATION /etc|DESTINATION etc|g' {} +
    find . -name "CMakeLists.txt" -exec sed -i 's|''${QT_PLUGINS_DIR}|lib/qt-5/plugins|g' {} +
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    libsForQt5.qtbase
    libsForQt5.qtx11extras
    libsForQt5.qtdeclarative
    libsForQt5.qttools
    xorg.libX11
    pam
  ];
}

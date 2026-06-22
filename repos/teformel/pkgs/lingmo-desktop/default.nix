{ stdenv, lib, fetchFromGitHub, cmake, pkg-config, libsForQt5, qt5 }:

stdenv.mkDerivation rec {
  pname = "lingmo-desktop";
  version = "main";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-desktop";
    rev = "0c2db3a0f856f54a7145a19e6fd0c79fc1e31131";
    # TODO: 首次构建将报错，请将报错提供的 Hash 填入此处
    hash = "sha256-613S8ofX4vbD6+8FyddxTp6sfd3JshVyI92NVtLOavs=";
  };

  postPatch = ''
    find . -name "CMakeLists.txt" -exec sed -i 's|DESTINATION /usr/|DESTINATION |g' {} +
    find . -name "CMakeLists.txt" -exec sed -i 's|DESTINATION /etc/|DESTINATION etc/|g' {} +
    find . -name "CMakeLists.txt" -exec sed -i 's|DESTINATION /etc|DESTINATION etc|g' {} +
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    libsForQt5.extra-cmake-modules
    libsForQt5.wrapQtAppsHook
    qt5.qttools
  ];

  buildInputs = [
    qt5.qtbase
    qt5.qtdeclarative
    qt5.qtsvg
    qt5.qtwayland
    qt5.qtx11extras
    libsForQt5.kcoreaddons
    libsForQt5.kwindowsystem
    libsForQt5.kio
  ];
}

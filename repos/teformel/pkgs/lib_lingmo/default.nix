{ stdenv
, lib
, fetchFromGitHub
, cmake
, pkg-config
, kdePackages
, qt6
, libcanberra
, sound-theme-freedesktop
}:

stdenv.mkDerivation rec {
  pname = "lib_lingmo";
  version = "main";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lib_lingmo";
    rev = "65138ba3f91c08bf88d3a10b9dc17fe75bd91ff4";
    # TODO: 首次构建将报错，请将报错提供的 Hash 填入此处
    hash = "sha256-4O25RkO4qN3v7Y04M8c+M9P54A/oA/0mH5+k5l5tq3I=";
  };

  postPatch = ''
    # 彻底拦截 ecm_query_qt 覆盖安装路径的行为
    sed -i 's/ecm_query_qt(INSTALL_QMLDIR QT_INSTALL_QML)/set(INSTALL_QMLDIR "\$\{CMAKE_INSTALL_PREFIX\}\/lib\/qt-6\/qml")/g' CMakeLists.txt
    
    # 修复写死的 Qt5
    if [ -f "system/CMakeLists.txt" ]; then
      sed -i 's/find_package(Qt5 REQUIRED COMPONENTS DBus)/find_package(Qt6 REQUIRED COMPONENTS DBus)/g' system/CMakeLists.txt
    fi
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    kdePackages.extra-cmake-modules
    kdePackages.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtsensors
    kdePackages.bluez-qt
    kdePackages.networkmanager-qt
    kdePackages.modemmanager-qt
    kdePackages.libkscreen
    kdePackages.kio
    libcanberra
    sound-theme-freedesktop
  ];
}

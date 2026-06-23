{ stdenv, lib, fetchFromGitHub, cmake, pkg-config, libsForQt5, qt5, python3 }:

stdenv.mkDerivation rec {
  pname = "lingmo-daemon";
  version = "main";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-daemon";
    rev = "610162449954c5ac12eca33493f7c9fe211cb5c0";
    # TODO: 首次构建将报错，请将报错提供的 Hash 填入此处
    hash = "sha256-Ix9PC0tr9zkLvqjj/UqnpbZ7R60ga9rgIh2kqgLwok4=";
  };

    postPatch = ''
    find . -name "CMakeLists.txt" -exec sed -i 's|DESTINATION "/usr/|DESTINATION "|g' {} +
    find . -name "CMakeLists.txt" -exec sed -i 's|DESTINATION "/etc/|DESTINATION "etc/|g' {} +
    find . -name "CMakeLists.txt" -exec sed -i 's|DESTINATION /usr/|DESTINATION |g' {} +
    find . -name "CMakeLists.txt" -exec sed -i 's|DESTINATION /etc/|DESTINATION etc/|g' {} +
    find . -name "CMakeLists.txt" -exec sed -i 's|DESTINATION /etc|DESTINATION etc|g' {} +
    
    # QApt is an Ubuntu/Debian specific APT wrapper. It is not available on NixOS.
    # We stub it out so the daemon can compile.
    sed -i '/QApt/d' CMakeLists.txt
    
    echo '#include "appmanager.h"' > src/appmanager.cpp
    echo 'AppManager::AppManager(QObject *parent) : QObject(parent) {}' >> src/appmanager.cpp
    echo 'void AppManager::uninstall(const QString &content) {}' >> src/appmanager.cpp
    echo 'void AppManager::notifyUninstalling(const QString &packageName) {}' >> src/appmanager.cpp
    echo 'void AppManager::notifyUninstallFailure(const QString &packageName) {}' >> src/appmanager.cpp
    echo 'void AppManager::notifyUninstallSuccess(const QString &packageName) {}' >> src/appmanager.cpp

    sed -i '/#include <QApt/d' src/appmanager.h
    sed -i '/QApt::/d' src/appmanager.h
  '';

  postInstall = ''
    # Add executable permissions to surveillance daemon since upstream used FILES in CMake
    chmod +x $out/bin/lingmo-permission-surveillance
    # Fix python shebang to include dependencies
    sed -i "s|#!/usr/bin/python3|#!${python3.withPackages(ps: with ps; [ dbus-python pyinotify ])}/bin/python3|g" $out/bin/lingmo-permission-surveillance
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
    libsForQt5.kcoreaddons
    libsForQt5.kwindowsystem
  ];
}

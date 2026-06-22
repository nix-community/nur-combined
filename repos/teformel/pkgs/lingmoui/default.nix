{ stdenv
, lib
, fetchFromGitHub
, cmake
, pkg-config
, kdePackages
, qt6
}:

stdenv.mkDerivation rec {
  pname = "lingmoui";
  version = "main";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmoui";
    rev = "87ed8ecd4359b236be687f97aafd7a242c5b6ba9";
    # TODO: 由于无法预取，首次构建将报错并提示正确的 Hash。请将报错中 "got: sha256-xxx" 的值填入此处！
    hash = "sha256-IB6/CHqjqv+S8WnAAj2vidh+WqMR3D7llYl9ab7mvn8="; 
    fetchSubmodules = true;
  };

  postPatch = ''
    # 修复 QHotkey 缺少 find_package 导致找不到 KF6::GlobalAccel 的问题
    if [ -f "thirdparty/QHotkey/CMakeLists.txt" ]; then
      sed -i '1i find_package(KF6GlobalAccel REQUIRED)' thirdparty/QHotkey/CMakeLists.txt
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
    qt6.qtsvg
    qt6.qtwayland
    qt6.qt5compat
    kdePackages.kwindowsystem
    kdePackages.kglobalaccel
  ];

  cmakeFlags = [
    "-DQT_QML_GENERATE_QMLLS_INI=OFF"
    "-DBUILD_TESTING=OFF"
  ];
}

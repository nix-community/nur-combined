{ stdenv, lib, fetchFromGitHub, cmake, pkg-config, kdePackages, qt6, lingmoui, lingmo-core, lib_lingmo }:

stdenv.mkDerivation rec {
  pname = "lingmo-dock";
  version = "main";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-dock";
    rev = "4f0f30a06515bb45c011eca8c98c278e497ffe0f";
    # TODO: 首次构建将报错，请将报错提供�?Hash 填入此处
    hash = "sha256-Y8f7daoseLr4EJAYhlD+rQVMvnkG0PPEmsk6MD4eFhM=";
  };

    postPatch = ''
    find . -name "CMakeLists.txt" -exec sed -i 's|DESTINATION /usr/|DESTINATION |g' {} +
    find . -name "CMakeLists.txt" -exec sed -i 's|DESTINATION /etc/|DESTINATION etc/|g' {} +
    find . -name "CMakeLists.txt" -exec sed -i 's|DESTINATION /etc|DESTINATION etc|g' {} +
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
    kdePackages.kcoreaddons
    kdePackages.kwindowsystem
    lingmoui
    lingmo-core
    lib_lingmo
  ];
}





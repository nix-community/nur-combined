{ stdenv, lib, fetchFromGitHub, cmake, pkg-config, kdePackages, qt6, lingmoui, lingmo-core, lib_lingmo }:

stdenv.mkDerivation rec {
  pname = "lingmo-launcher";
  version = "main";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-launcher";
    rev = "eac296ecccf47c9d25eb989e06a7cc6e953129fb";
    # TODO: 首次构建将报错，请将报错提供的 Hash 填入此处
    hash = "sha256-s4TvyLXORW6jqDm0tijU49LdHhyvEf4wzVr+gKgdn5Q=";
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





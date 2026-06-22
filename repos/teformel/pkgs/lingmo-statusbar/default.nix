{ stdenv, lib, fetchFromGitHub, cmake, pkg-config, kdePackages, qt6, lingmoui, lingmo-core, lib_lingmo }:

stdenv.mkDerivation rec {
  pname = "lingmo-statusbar";
  version = "main";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-statusbar";
    rev = "main";
    hash = "sha256-+nV+adCcjEElQuOXU1idUHCUf7qkSY4LF0B/MrpII2E=";
  };

  postPatch = ''
    find . -name "CMakeLists.txt" -exec sed -i 's|DESTINATION /usr/|DESTINATION |g' {} +
    find . -name "CMakeLists.txt" -exec sed -i 's|DESTINATION /etc/|DESTINATION etc/|g' {} +
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

  meta = with lib; {
    description = "Lingmo OS Status Bar";
    homepage = "https://github.com/LingmoOS/lingmo-statusbar";
    license = licenses.gpl3;
  };
}

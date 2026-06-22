{ stdenv, lib, fetchFromGitHub, cmake, pkg-config, kdePackages, qt6, lingmoui, lingmo-core, lib_lingmo }:

stdenv.mkDerivation rec {
  pname = "lingmo-kwin-plugins";
  version = "main";

  src = fetchFromGitHub {
    owner = "LingmoOS";
    repo = "lingmo-kwin-plugins";
    rev = "988697004e2828d48e6a970d8516671a3387a677";
    # TODO: 首次构建将报错，请将报错提供的 Hash 填入此处
    hash = "sha256-xyvjGUCsq+5lSVG7eK7OK1tDaeJTrKvTPA9ntVCRgk8=";
  };

    postPatch = ''
    # Lingmo uses KDecoration3 but KDE Plasma 6 still uses KDecoration2.
    find . -type f \( -name "CMakeLists.txt" -o -name "*.cpp" -o -name "*.h" -o -name "*.json" \) -exec sed -i 's/KDecoration3/KDecoration2/g; s/kdecoration3/kdecoration2/g; s/DecoratedWindow/DecoratedClient/g; s/QRectF/QRect/g' {} +

    find . -name "CMakeLists.txt" -exec sed -i 's|DESTINATION "/usr/|DESTINATION "|g' {} +
    find . -name "CMakeLists.txt" -exec sed -i 's|DESTINATION "/etc/|DESTINATION "etc/|g' {} +
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
    kdePackages.kconfig
    kdePackages.kdecoration
    lingmoui
    lingmo-core
    lib_lingmo
  ];
}





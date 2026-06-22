{ stdenv
, lib
, fetchFromGitHub
, cmake
, pkg-config
, kdePackages
, qt6
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
    hash = lib.fakeHash;
  };

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
    kdePackages.kwindowsystem
    kdePackages.kcoreaddons
    kdePackages.kconfig
    lingmoui
  ];
}

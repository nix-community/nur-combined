{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  qt6,
  kdePackages,
}:
stdenv.mkDerivation rec {
  pname = "kiot";

  version = "5a050d4ef20b2b159950ba1b40f43170cb17a119";

  src = fetchFromGitHub {
    owner = "davidedmundson";
    repo = "kiot";
    rev = "${version}";
    hash = "sha256-2Fk3logWxpZrzlVcZl4l2DiJcJQQBtS3X9231ZvQxuE=";
  };

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
    qt6.wrapQtAppsHook
    qt6.qttools
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtmqtt
    kdePackages.frameworkintegration
    kdePackages.kidletime
  ];

  meta = with lib; {
    mainProgram = "kiot";
  };
}

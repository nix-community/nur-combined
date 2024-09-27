{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  kdePackages,
  ninja,
  python3,
  qt6,
  nix-update-script,
}:

stdenv.mkDerivation {
  pname = "plasma-camera";
  version = "1.0-unstable-2024-09-20";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "plasma-mobile";
    repo = "plasma-camera";
    rev = "33825dfea38a75e7033f5e99499bf1732ff028e1";
    hash = "sha256-i91JNpO3Mwc6Vvy+FXGqPg950LOSTkL2b8RoZ/RbJQI=";
  };

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
    ninja
    python3
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    kdePackages.kconfig
    kdePackages.kcoreaddons
    kdePackages.ki18n
    kdePackages.kirigami
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtsvg
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    mainProgram = "plasma-camera";
    description = "Camera application for Plasma Mobile";
    homepage = "https://invent.kde.org/plasma-mobile/plasma-camera";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}

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
  version = "1.0-unstable-2025-05-21";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "plasma-mobile";
    repo = "plasma-camera";
    rev = "54f5ea0281c5ceb3c7254c758b880e67f8c3459a";
    hash = "sha256-adcdBCTHiSbFI5JVaXIhiFTcOtYx/nztu0Xo3U6OcVw=";
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

  strictDeps = true;

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
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}

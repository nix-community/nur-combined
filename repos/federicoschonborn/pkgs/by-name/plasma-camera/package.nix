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
  version = "1.0-unstable-2024-07-10";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "plasma-mobile";
    repo = "plasma-camera";
    rev = "73de8e63ed969595cc70ce88686e3458aa997da0";
    hash = "sha256-CswF37czOLwU77U/qtF/TB46S3fNwtfIz3IZww1Pauc=";
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
    badPlatforms = lib.platforms.darwin;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}

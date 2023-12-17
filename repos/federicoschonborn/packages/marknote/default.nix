{ lib
, stdenv
, fetchFromGitLab
, cmake
, extra-cmake-modules
, ninja
, wrapQtAppsHook
, kconfig
, kcoreaddons
, ki18n
, kirigami2
, qtbase
, qtquickcontrols2
, unstableGitUpdater
}:

stdenv.mkDerivation {
  pname = "marknote";
  version = "unstable-2023-12-15";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "office";
    repo = "marknote";
    rev = "18dbce057bd7f9bc4dfe227217b44691705232d7";
    hash = "sha256-hncyfeuVxNPz2KNuvpKAs8H1hP+WE7TPboKuFLM2TwU=";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    ninja
    wrapQtAppsHook
  ];

  buildInputs = [
    kconfig
    kcoreaddons
    ki18n
    kirigami2
    qtbase
    qtquickcontrols2
  ];

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    mainProgram = "marknote";
    description = "A simple markdown note management app";
    homepage = "https://invent.kde.org/office/marknote";
    license = with lib.licenses; [
      bsd3
      cc-by-sa-40
      cc0
      gpl2Only
      gpl2Plus
      gpl3Only
      gpl3Plus
      lgpl2Plus
      lgpl3Only
    ];
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}

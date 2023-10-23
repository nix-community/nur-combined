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
  version = "unstable-2023-10-23";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "office";
    repo = "marknote";
    rev = "f043663ffd9fb95b748c66d37159bbe785eba576";
    hash = "sha256-LpUvk0ONPtYREjzTLzqhn3t0JVvGpNv7sOa2lwqgPL4=";
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

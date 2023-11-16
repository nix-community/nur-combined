{ lib
, stdenv
, fetchFromGitLab
, cmake
, extra-cmake-modules
, ninja
, wrapQtAppsHook
, kconfig
, kcoreaddons
, kdbusaddons
, ki18n
, kirigami2
, qtbase
, qtquickcontrols2
, unstableGitUpdater
}:

stdenv.mkDerivation {
  pname = "eloquens";
  version = "unstable-2023-11-07";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "sdk";
    repo = "eloquens";
    rev = "3547cf1012bf0c93fc5b09ee2d3e035bff15ff21";
    hash = "sha256-NeRF5fefCSDHp7pZU5Miw7bOypB/bsTIONtKiI4ivIo=";
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
    kdbusaddons
    ki18n
    kirigami2
    qtbase
    qtquickcontrols2
  ];

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    mainProgram = "eloquens";
    description = "Generate the lorem ipsum text";
    homepage = "https://invent.kde.org/sdk/eloquens";
    license = with lib.licenses; [
      bsd2
      cc0
      gpl3Plus
      lgpl2Plus
      lgpl21Plus
    ];
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}

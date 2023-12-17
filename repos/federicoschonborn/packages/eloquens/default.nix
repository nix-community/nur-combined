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
  version = "unstable-2023-12-14";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "sdk";
    repo = "eloquens";
    rev = "6c187759b5fefc4830e2b81e1edaa16a8427ffcc";
    hash = "sha256-dHvQbq2D5KUMhZ+zKKrOX4LIx63ScUgjdmiaHqnvjKA=";
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
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}

{ lib
, stdenv
, fetchFromGitLab
, cmake
, extra-cmake-modules
, qtbase
, qtquickcontrols2
, wrapQtAppsHook
, kirigami2
, kirigami-addons
, kcoreaddons
, kconfig
, kdbusaddons
, ki18n
, knotifications
, unstableGitUpdater
}:

stdenv.mkDerivation {
  pname = "francis";
  version = "unstable-2023-08-02";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "utilities";
    repo = "francis";
    rev = "53ca525aa03f994a48f3fe69d065e0e4ec6b8519";
    hash = "sha256-TdqjEP4JOP/lpuah7dFqcwvfc3RkPsWwASTdabcjn20=";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    qtquickcontrols2
    kirigami2
    kirigami-addons
    kcoreaddons
    kconfig
    kdbusaddons
    ki18n
    knotifications
  ];

  passthru = {
    updateScript = unstableGitUpdater { };
  };

  meta = with lib; {
    description = "Track your time";
    homepage = "https://invent.kde.org/utilities/francis";
    license = with licenses; [
      bsd2
      bsd3
      cc0
      gpl3Plus
      lgpl2Plus
      lgpl21Plus
    ];
    platforms = platforms.linux;
    maintainers = with maintainers; [ federicoschonborn ];
  };
}

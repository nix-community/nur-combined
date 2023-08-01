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
}:

stdenv.mkDerivation {
  pname = "francis";
  version = "unstable-2023-07-31";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "utilities";
    repo = "francis";
    rev = "e24930d968d0eea9ae55143189a7098502dc7ed8";
    hash = "sha256-73YT1sC1Y+qZBffWJaiuQNqTJAfdgOaa2CzD7uBxh50=";
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

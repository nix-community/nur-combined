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
, kirigami-addons
, kirigami2
, qtbase
, qtquickcontrols2
, syntax-highlighting
}:

stdenv.mkDerivation {
  pname = "notae";
  version = "unstable-2023-04-09";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "utilities";
    repo = "notae";
    rev = "b8738b16e03fe6812389bf30ce704131b61730d6";
    hash = "sha256-FVSbUIlKhYGMOpTXfLwKlt9z8Y71CqQjm+uxhRPkKUc=";
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
    kirigami-addons
    kirigami2
    qtbase
    qtquickcontrols2
    syntax-highlighting
  ];

  meta = with lib; {
    description = "A simple note taking application that automatically saves your work";
    homepage = "https://invent.kde.org/utilities/notae";
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

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
, knotifications
, qtbase
, qtquickcontrols2
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
    knotifications
    qtbase
    qtquickcontrols2
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
    broken = versionOlder kirigami-addons.version "0.10";
  };
}

{ lib
, stdenv
, fetchFromGitLab
, cmake
, extra-cmake-modules
, ninja
, wrapQtAppsHook
, kconfigwidgets
, kcoreaddons
, kcrash
, kdbusaddons
, kdoctools
, ki18n
, kio
, ktexteditor
, ktextwidgets
, kxmlgui
, syntax-highlighting
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kommit";
  version = "1.0.2";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "sdk";
    repo = "kommit";
    rev = "v${finalAttrs.version}";
    hash = "sha256-hEn6G6CWtvhdtG5mnhuyiq2O9bmjdctQkJN2OQuFnGA=";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    ninja
    wrapQtAppsHook
  ];

  buildInputs = [
    kconfigwidgets
    kcoreaddons
    kcrash
    kdbusaddons
    kdoctools
    ki18n
    kio
    ktexteditor
    ktextwidgets
    kxmlgui
    syntax-highlighting
  ];

  meta = {
    description = "Graphical Git client for KDE";
    homepage = "https://apps.kde.org/kommit/";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})

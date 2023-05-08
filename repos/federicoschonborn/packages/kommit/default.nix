{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  extra-cmake-modules,
  kconfigwidgets,
  kcoreaddons,
  kcrash,
  kdbusaddons,
  kdoctools,
  ki18n,
  kio,
  ktexteditor,
  ktextwidgets,
  kxmlgui,
  syntax-highlighting,
  wrapQtAppsHook,
  ...
}:
stdenv.mkDerivation rec {
  pname = "kommit";
  version = "1.0.2";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "sdk";
    repo = "kommit";
    rev = "v${version}";
    hash = "sha256-hEn6G6CWtvhdtG5mnhuyiq2O9bmjdctQkJN2OQuFnGA=";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
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

  meta = with lib; {
    description = "Graphical Git client for KDE";
    longDescription = ''
      Graphical Git client for KDE
    '';
    homepage = "https://apps.kde.org/kommit/";
    license = licenses.gpl3Plus;
  };
}

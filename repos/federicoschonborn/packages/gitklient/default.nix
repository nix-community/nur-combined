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
stdenv.mkDerivation {
  pname = "gitklient";
  version = "unstable-2023-02-09";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "sdk";
    repo = "gitklient";
    rev = "919447fb1982a46cd4c565aaa7aeca3f9e4b9aab";
    sha256 = "sha256-p7CD/+0wGf5dzCQ8Y2fJSSrv2f/BKO+/OilUZIt0BR0=";
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
    homepage = "https://apps.kde.org/gitklient/";
    license = licenses.gpl3Plus;
  };
}

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
  kxmlgui,
  kio,
  ktextwidgets,
  ktexteditor,
  syntax-highlighting,
  wrapQtAppsHook,
  ...
}:
stdenv.mkDerivation {
  pname = "gitklient";
  version = "unstable-2022-11-21";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "sdk";
    repo = "gitklient";
    rev = "8a048d3d03d282478ef575581d4d3ccd61969611";
    sha256 = "CcbEDMLuDcJlB1MKc2KK8LWuFeaPI6n4PkjSpluUzcM=";
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
    kxmlgui
    kio
    ktextwidgets
    ktexteditor
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

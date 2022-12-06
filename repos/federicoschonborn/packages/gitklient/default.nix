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
  version = "unstable-2022-11-29";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "sdk";
    repo = "gitklient";
    rev = "ec5f049b37ce9e646dc5ae58770c8a26e95c94e9";
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
    platforms = platforms.all;
  };
}

{
  lib,
  stdenv,
  fetchzip,
  bluez-qt,
  cmake,
  extra-cmake-modules,
  karchive,
  kdbusaddons,
  kcmutils,
  kconfig,
  kconfigwidgets,
  kcrash,
  ki18n,
  kiconthemes,
  kio,
  kitemviews,
  knewstuff,
  knotifications,
  kservice,
  kwidgetsaddons,
  kwindowsystem,
  networkmanager-qt,
  packagekit-qt,
  qtx11extras,
  solid,
  wrapQtAppsHook,
  ...
}:
stdenv.mkDerivation rec {
  pname = "liquidshell";
  version = "1.8.1";

  src = fetchzip {
    url = "https://download.kde.org/stable/${pname}/${version}/${pname}-${version}.tar.xz";
    sha256 = "S7Bzexzm4UT6c7TV7bVnbaF6pMRCvNi+h+iPwGvU3sM=";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    wrapQtAppsHook
  ];

  buildInputs = [
    bluez-qt
    extra-cmake-modules
    karchive
    kdbusaddons
    kcmutils
    kconfig
    kconfigwidgets
    kcrash
    ki18n
    kiconthemes
    kio
    kitemviews
    knewstuff
    knotifications
    kservice
    kwidgetsaddons
    kwindowsystem
    networkmanager-qt
    qtx11extras
    solid
  ];

  meta = with lib; {
    description = "Basic desktop shell using QtWidgets";
    longDescription = ''
      liquidshell is a basic Desktop Shell implemented using QtWidgets.
    '';
    homepage = "https://apps.kde.org/liquidshell/";
    license = licenses.gpl3Plus;
  };
}

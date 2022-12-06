{
  lib,
  stdenv,
  fetchFromGitLab,
  bluez-qt,
  cmake,
  extra-cmake-modules,
  karchive,
  kcmutils,
  kconfig,
  kconfigwidgets,
  kcrash,
  kdbusaddons,
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

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "system";
    repo = pname;
    rev = "v${version}";
    sha256 = "vyI+eFEUc8guptpwRinJ+aXxkkkYyAx/Pi8kxQlWoA8=";
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
    kcmutils
    kconfig
    kconfigwidgets
    kcrash
    kdbusaddons
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
    platforms = platforms.all;
  };
}

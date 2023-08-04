{ stdenv
, lib
, fetchgit
, cmake
, extra-cmake-modules
, qtbase
, qtdeclarative
, qtx11extras
, kpipewire
, ki18n
, knotifications
, kwidgetsaddons
, kwindowsystem
, libxcb
, wrapQtAppsHook
, isHyprland ? false
}:

stdenv.mkDerivation {
  name = "xwaylandvideobridge";

  src = fetchgit {
    url = "https://invent.kde.org/system/xwaylandvideobridge.git";
    sha256 = "sha256-XgrgRXqBUbdz6tegVMTwppTYWJVqPyGoXfjhRCQEBxs=";
    rev = "6b76657f9e171e726c7c8d9c194d29d0026be268";
  };

  nativeBuildInputs = [
    wrapQtAppsHook
    cmake
    extra-cmake-modules
  ];

  buildInputs = [
    qtbase
    qtdeclarative
    qtx11extras
    kpipewire
    ki18n
    knotifications
    kwidgetsaddons
    kwindowsystem
    libxcb
  ];

  patches = lib.optionals isHyprland [ ./cursor-mode-2.diff ];

  meta = with lib; {
    name = "xwaylandvideobridge";
    description = "XWayland Video Bridge";
    homepage = "https://invent.kde.org/system/xwaylandvideobridge";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}

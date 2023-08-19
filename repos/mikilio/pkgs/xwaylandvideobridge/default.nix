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

stdenv.mkDerivation rec {
  pname = "xwaylandvideobridge";
  version = "8842032fe672575a9dfe44adc7ef84b468d931fe";

  src = fetchgit {
    url = "https://invent.kde.org/system/xwaylandvideobridge.git";
    sha256 = "sha256-XRqv8VLSINO0nVBDiuhbc26p/aJh9pWUqGtFeoTo1LY=";
    rev = version;
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

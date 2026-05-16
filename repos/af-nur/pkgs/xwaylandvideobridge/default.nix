{
  lib,
  stdenv,
  fetchurl,
  cmake,
  extra-cmake-modules,
  pkg-config,
  qtbase,
  qtdeclarative,
  kcoreaddons,
  ki18n,
  knotifications,
  kpipewire,
  kstatusnotifieritem,
  kwindowsystem,
  wrapQtAppsHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xwaylandvideobridge";
  version = "0.3.0";

  src = fetchurl {
    url = "mirror://kde/stable/xwaylandvideobridge/xwaylandvideobridge-${finalAttrs.version}.tar.xz";
    hash = "sha256-+Npuj+DsO9XqeXr4qtj+Haqzb8PHfi02u3RDgyzfz/o=";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    qtdeclarative
    kcoreaddons
    ki18n
    knotifications
    kpipewire
    kstatusnotifieritem
    kwindowsystem
  ];

  postPatch = ''
    sed -i '/#include <private\/qtx11extras_p.h>/d' src/contentswindow.cpp
    sed -i '/#include <KX11Extras>/a #include <xcb/xcb.h>' src/contentswindow.cpp
    sed -i 's/QX11Info::connection()/xcb_connect(nullptr, nullptr)/g' src/contentswindow.cpp
    sed -i 's/Qt6::GuiPrivate/Qt6::Gui/g' src/CMakeLists.txt
  '';

  cmakeFlags = [ "-DQT_MAJOR_VERSION=6" ];

  meta = {
    description = "Utility to allow streaming Wayland windows to X applications";
    homepage = "https://invent.kde.org/system/xwaylandvideobridge";
    license = with lib.licenses; [
      bsd3
      cc0
      gpl2Plus
    ];
    maintainers = with lib.maintainers; [ stepbrobd ];
    platforms = lib.platforms.linux;
    mainProgram = "xwaylandvideobridge";
  };
})

{
  lib,
  stdenv,
  cmake,
  extra-cmake-modules,
  pkg-config,
  qtbase,
  qtdeclarative,
  kcoreaddons,
  kcrash,
  kdbusaddons,
  ki18n,
  kpipewire,
  kstatusnotifieritem,
  kwindowsystem,
  libxcb,
  wrapQtAppsHook,
  sources,
}:

stdenv.mkDerivation {
  pname = "xwaylandvideobridge";
  version = sources.xwaylandvideobridge.version;

  src = sources.xwaylandvideobridge.src;

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
    kcrash
    kdbusaddons
    ki18n
    kpipewire
    kstatusnotifieritem
    kwindowsystem
    libxcb
  ];

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
}

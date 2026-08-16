{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  qt6,
  kdePackages,
  wayland,
  wayland-protocols,
  libepoxy,
  pkgconf,
}:

stdenv.mkDerivation rec {
  pname = "aeroshell-smod";
  version = "0";

  src = fetchFromGitHub {
    owner = "aeroshell-desktop";
    repo = "smod";
    rev = "f149d75a1436f081a1c1e5c91acea0c01bbc48c3";
    hash = "sha256-qSpPkwLTodBQFHiRBk3Xh/51ytBHKX0Yk4JOk2693vQ=";
  };

  dontWrapQtApps = true;

  buildInputs = [
    libepoxy
    wayland
    wayland-protocols
  ]
  ++ (with kdePackages; [
    qtbase
    qtwayland
    qttools
    kwin
    kwin-x11
    kdecoration
    kcoreaddons
    ki18n
    kcmutils
    kguiaddons
    plasma-wayland-protocols
    kwindowsystem
    kwidgetsaddons
  ]);

  nativeBuildInputs = [
    cmake
    pkgconf
    kdePackages.extra-cmake-modules
    kdePackages.kdoctools
  ];

  cmakeFlakgs = [
    (lib.cmakeFeature "KWIN_BUILD_WAYLAND" "ON")
    (lib.cmakeFeature "BUILD_TESTING" "OFF")
  ];

  #configurePhase = ''
  #  runHook preConfigure
  #  runHook postConfigure
  #'';

  # i could probably do this better,
  # but due to it being like "configure, build, configure, build",
  # i just put it all in buildPhase
  #buildPhase = ''
  #  runHook preBuild
  #  cmake -B build .
  #  cmake --build build
  #  DESTDIR=smodtemp cmake --install build
  #  PKG_CONFIG_PATH=smodtemp/usr/lib/pkgconfig/ cmake -B build_smodglow/ -DCMAKE_CXX_FLAGS="-I../smodtemp/usr/include -L../smodtemp/usr/lib/qt6/plugins/org.kde.kdecoration3" -S smodglow
  #  cmake --build build_smodglow
  #  cd build
  #  runHook postBuild
  #'';

  #installPhase = ''
  #  runHook preInstall
  #  DESTDIR=$out cmake --install build
  #  DESTDIR=$out cmake --install build_smodglow
  #  runHook postInstall
  #'';

  meta = with lib; {
    license = licenses.agpl3Plus;
    description = "A KDecoration3 decoration engine made for AeroShell-based desktops";
    homepage = "https://github.com/aeroshell-desktop/smod";
    platforms = platforms.unix;
  };
}

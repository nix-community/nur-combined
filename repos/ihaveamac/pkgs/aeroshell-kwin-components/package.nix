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
  aeroshell-libplasma,
}:

stdenv.mkDerivation rec {
  pname = "aeroshell-kwin-components";
  version = "0";

  src = fetchFromGitHub {
    owner = "aeroshell-desktop";
    repo = pname;
    rev = "c9a0a9ef1227134018bd0175015aebef15845c30";
    hash = "sha256-mUKsQFcHwLQVL6qicfH0/Dur5bHM+eJHW8snxCB1psM=";
  };

  dontWrapQtApps = true;

  buildInputs = [
    wayland
    libepoxy
  ] ++ (with kdePackages; [
    qtbase
    qtsvg
    qt5compat
    qtdeclarative
    qttools
    kwin
    kwin-x11
    kconfig
    kcmutils
    kdecoration
    ki18n
    kcoreaddons
    kwindowsystem
    kirigami
    ksvg
    plasma-workspace
    plasma5support
    aeroshell-libplasma
  ]);

  nativeBuildInputs = [
    cmake
    wayland-protocols
    kdePackages.kdoctools
    kdePackages.plasma-wayland-protocols
    kdePackages.extra-cmake-modules
  ];

  cmakeFlakgs = [
    (lib.cmakeFeature "KWIN_BUILD_WAYLAND" "ON")
    (lib.cmakeFeature "BUILD_TESTING" "OFF")
  ];

  meta = with lib; {
    license = licenses.agpl3Plus;
    description = "KWin effects, scripts, and other components for AeroShell-based desktops";
    homepage = "https://github.com/aeroshell-desktop/aeroshell-kwin-components";
    platforms = platforms.unix;
  };
}

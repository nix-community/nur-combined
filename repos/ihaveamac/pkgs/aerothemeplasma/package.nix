{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  kdePackages,
  bash,
  wayland,
  pkgconf,
  aeroshell-libplasma,
  aeroshell-workspace,
  aeroshell-kwin-components,
  aerothemeplasma-sounds,
  aerothemeplasma-icons,
  aeroshell-smod,
  aeroshell-smodglow,
}:

stdenv.mkDerivation rec {
  pname = "aerothemeplasma";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "aeroshell-desktop";
    repo = pname;
    rev = "d4ca559d1ff9f26dd6652df66ecc075aa14efdc2";
    hash = "sha256-Ac8M1ZjWum41lGbR5o6uX69xez5zT2rbYqF/Sl0NXl8=";
  };

  buildInputs = [
    bash
    wayland
    aeroshell-libplasma
    aeroshell-workspace
    aeroshell-kwin-components
    aerothemeplasma-sounds
    aerothemeplasma-icons
    aeroshell-smod
    aeroshell-smodglow
  ] ++ (with kdePackages; [
    qtbase
    qtvirtualkeyboard
    qtmultimedia
    qt5compat
    qtwayland
    qtdeclarative
    kconfigwidgets
    ksvg
    kiconthemes
    plasma-activities
    kjobwidgets
    kio
    kglobalaccel
    kpipewire
    ki18n
    kwin
    kwin-x11
    plasma-workspace
    powerdevil
    kauth
    kcmutils
    networkmanager-qt
    kconfig
    kquickcharts
    prison
    knewstuff
    kdeclarative
    kirigami-addons
    kcoreaddons
    kservice
    kxmlgui
    plasma5support
    qtstyleplugin-kvantum
    sddm
    sddm-kcm
    plasma-nm
    plasma-pa
    kwindowsystem
    knotifications
    knotifyconfig
    kmenuedit
    kirigami
    kitemmodels
    kpackage
    kwidgetsaddons
    plasma-desktop
  ]);

  nativeBuildInputs = [
    cmake
    pkgconf
    kdePackages.extra-cmake-modules
    kdePackages.plasma-wayland-protocols
  ];

  dontWrapQtApps = true;

  cmakeFlags = [
    (lib.cmakeFeature "BUILD_TESTING" "OFF")
    (lib.cmakeFeature "CMAKE_INSTALL_LIBEXECDIR" "lib")
  ];

  env.NIX_CXXFLAGS_COMPILE = "${aeroshell-libplasma}/include/Plasma";

  postPatch = ''
    substituteInPlace plasma/plasmoids/src/sevenstart_src/CMakeLists.txt \
      --replace-fail KF6Plasma Plasma
    #substituteInPlace plasma/plasmoids/src/seventasks_src/src/seventasks.h \
    #  --replace-fail 'Plasma/Applet' '${aeroshell-libplasma}/include/Plasma/Plasma/
  '';
}

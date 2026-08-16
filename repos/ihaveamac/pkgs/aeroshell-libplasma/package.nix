{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  qt6,
  kdePackages,
  wayland,
  libx11,
  libglvnd,
  libxcb,
}:

stdenv.mkDerivation rec {
  pname = "aeroshell-libplasma";
  version = "0";

  # TODO: make this usable across plasma versions
  src = fetchFromGitHub {
    owner = "aeroshell-desktop";
    repo = "libplasma";
    rev = "31f72c780a194460eed467d57cc13128768dc161";
    hash = "sha256-6uWiiEWp3mfEatHncGSszm3rQjx19PaRhOMpXkzuNw0=";
  };

  postPatch = ''
    substituteInPlace src/plasmaquick/CMakeLists.txt \
      --replace-fail "\''${Wayland_DATADIR}" ${kdePackages.qtbase}/share/qt6/wayland/protocols/wayland
  '';

  dontWrapQtApps = true;

  buildInputs = [
    wayland
    libx11
    libglvnd
    libxcb
  ]
  ++ (with kdePackages; [
    qtbase
    qtdeclarative
    qt5compat
    kcolorscheme
    kconfig
    kcoreaddons
    kglobalaccel
    kguiaddons
    ki18n
    kiconthemes
    kio
    kirigami
    knotifications
    kpackage
    ksvg
    kwidgetsaddons
    kwindowsystem
    plasma-activities
  ]);

  nativeBuildInputs = [
    cmake
    kdePackages.kdoctools
    kdePackages.plasma-wayland-protocols
    kdePackages.extra-cmake-modules
  ];

  meta = with lib; {
    description = "Libplasma with AeroShell patches";
    homepage = "https://github.com/aeroshell-desktop/libplasma";
    platforms = platforms.unix;
  };
}

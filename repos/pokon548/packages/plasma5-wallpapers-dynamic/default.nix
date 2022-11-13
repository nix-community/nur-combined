{ lib, fetchurl, gtk3, gsettings-desktop-schemas, fetchFromGitHub, cmake, extra-cmake-modules, qtx11extras, kcoreaddons, kguiaddons, kdecoration, kconfigwidgets, kwindowsystem, kiconthemes, kwayland }:

# Based on zettlr nixpkgs
let
  pname = "plasma5-wallpapers-dynamic";
  version = "4.4.0";

  src = fetchFromGitHub {
    owner = "zzag";
    repo = "plasma5-wallpapers-dynamic";
    rev = "3e1b9d09ad620442e524ab68a4c4e47848f2dc2a";
    sha256 = "sha256-n+yUmBUrkS+06qLnzl2P6CTQZZbDtJLy+2mDPCcQz9M=";
  };
in rec {
  nativeBuildInputs = [ cmake extra-cmake-modules ];

  buildInputs = [
    qtx11extras
    kcoreaddons
    kguiaddons
    kdecoration
    kconfigwidgets
    kwindowsystem
    kiconthemes
    kwayland
  ];

  meta = with lib; {
    description = "A wallpaper plugin for KDE Plasma that continuously updates the desktop background based on the current time in your location.";
    homepage = "https://github.com/zzag/plasma5-wallpapers-dynamic";
    license = licenses.gpl2;
    maintainers = with maintainers; [ pokon548 ];
  };
}
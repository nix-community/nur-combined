{ lib
, mkDerivation
, stdenv
, fetchFromGitHub
, cmake
, extra-cmake-modules
, qtx11extras
, plasma-framework
, kdecoration
, qtbase
, qtdeclarative
, qtlocation
, libexif
, libavif
, unstableGitUpdater
}:

mkDerivation rec {
  pname = "plasma5-wallpapers-dynamic";
  version = "4.4.0";

  src = fetchFromGitHub {
    owner = "zzag";
    repo = "plasma5-wallpapers-dynamic";
    rev = "3e1b9d09ad620442e524ab68a4c4e47848f2dc2a";
    sha256 = "sha256-UELJxU7cgG3+4CJvMk9f0iuQYV1F3P5sRbfcrWgZRD8=";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules ];

  buildInputs = [
    qtx11extras
    plasma-framework
    kdecoration
    qtbase
    qtdeclarative
    qtlocation
    libexif
    libavif
  ];

  passthru = {
    updateScript = unstableGitUpdater { };
  };

  meta = with lib; {
    description = "Dynamic wallpaper plugin for KDE Plasma";
    homepage = "https://github.com/zzag/plasma5-wallpapers-dynamic";
    license = licenses.gpl2;

    # Upstreaming issue of libyuv cause this package not buildable for NixOS 22.11+
    # See this commit: https://github.com/NixOS/nixpkgs/commit/ddd1e56610607ceec26054fee2afb8421678b1c3
    #
    # TODO: Wait for this commit to be merged into nixos-unstable / nixos-22.11
    #       then I will remove the mark of broken anyway
    broken = true;
  };
}

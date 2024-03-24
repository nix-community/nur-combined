{ lib
, stdenv
, cairo
, copyDesktopItems
, fetchFromGitHub
, fetchzip
, gdk-pixbuf
, getconf
, libsodium
, libxkbcommon
, makeDesktopItem
, meson
, ninja
, openssl
, pam
, pkg-config
, scdoc
, wayland
, wayland-protocols
, wayland-scanner
}:
stdenv.mkDerivation rec {
  pname = "schlock";
  version = "unstable-2022-02-02";

  src = fetchFromGitHub {
    owner = "telent";
    repo = "schlock";
    rev = "f3dde16f074fd5b7482a253b9d26b4ead66dea82";
    hash = "sha256-Ot86vALt1kkzbBocwh9drCycbRIw2jMKJU4ODe9PYQM=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    meson
    ninja
    pkg-config
    scdoc
    wayland-scanner
  ];
  buildInputs = [
    cairo
    gdk-pixbuf
    libsodium
    libxkbcommon
    wayland
    wayland-protocols
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "schlock";
      # exec = "schlock -p $HOME/.config/schlock/schlock.pin";
      exec = ''/bin/sh -c "schlock -p \\$HOME/.config/schlock/schlock.pin"'';
      desktopName = "mobile screen locker";
    })
  ];

  meta = with lib; {
    description = "Touchscreen locker for Wayland";
    longDescription = ''
      schlock is a fork of Swaylock adapted for touchscreen devices.
    '';
    inherit (src.meta) homepage;
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ colinsane ];
  };
}

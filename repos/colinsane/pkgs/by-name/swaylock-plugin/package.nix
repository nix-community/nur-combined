# STATUS:
# - can't find any virtual keyboard it works with
# - run with `swaylock-plugin --command='/nix/store/my-virtual-keyboard-.../bin/vkbd'`
#   - if it crashes, launch `sane-open swaylock.desktop` from another TTY
#   - `cd /etc/pam.d; sudo cp swaylock swaylock-plugin`
{ lib, stdenv
, cairo
, fetchFromGitHub
, gdk-pixbuf
, libxkbcommon
, meson
, ninja
, pam
, pkg-config
, scdoc
, wayland
, wayland-protocols
, wayland-scanner
}:
stdenv.mkDerivation rec {
  pname = "swaylock-plugin";
  version = "1.6-unstable-2024-02-21";  #< from meson.build

  src = fetchFromGitHub {
    owner = "mstoeckl";
    repo = "swaylock-plugin";
    rev = "1dd15b6ecbe91be7a3dc4a0fa9514fb166fb2e07";
    hash = "sha256-xWyDDT8sXAL58HtA9ifzCenKMmOZquzXZaz3ttGGJuY=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    scdoc
    wayland-scanner
  ];
  buildInputs = [
    cairo
    gdk-pixbuf
    libxkbcommon
    pam
    wayland
    wayland-protocols
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error=maybe-uninitialized";

  meta = with lib; {
    description = "Screen locker for Wayland -- fork with background plugin support";
    longDescription = ''
      This is a fork of swaylock, a screen locking utility for Wayland compositors.
      With swaylock-plugin, you can for your lockscreen background display the
      animated output from any wallpaper program that implements the
      wlr-layer-shell-unstable-v1 protocol.

      N.B.: it's necessary to install /etc/pam.d/swaylock-plugin without which
      swaylock-plugin will never unlock your session.
    '';
    inherit (src.meta) homepage;
    mainProgram = "swaylock-plugin";
    platforms = platforms.linux;
    maintainers = with maintainers; [ colinsane ];
  };
}

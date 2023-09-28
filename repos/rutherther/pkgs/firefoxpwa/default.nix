{ lib, pkgs, ... }:

# Don't forget to add firefoxpwa
# to extraNativePackagesMessagingHosts in firefox
#  pkgs.firefox.override {
#    extraNativeMessagingHosts = [
#      firefoxpwa
#    ];
#  };
#
# or use the overlays:
# rutherther.overlays.firefoxpwa
# rutherther.overlays.firefox-native-messaging

let
  firefoxpwa-unwrapped = pkgs.callPackage ./unwrapped.nix {};
in pkgs.buildFHSEnv {
    name = "firefoxpwa";

    targetPkgs = pkgs: (with pkgs; [
      firefoxpwa-unwrapped

      xorg.libX11
      xorg.libXrender
      xorg.libXcursor
      xorg.libXdamage
      xorg.libXfixes
      xorg.libXrandr
      xorg.libXcomposite
      xorg.libXext
      xorg.libxcb
      xorg.libXtst
      xorg.libXi

      glib
      freetype
      gtk3
      gtk2
      openssl
      libxcrypt
      libxcrypt-legacy
      zlib
      stdenv.cc.cc.lib

      fontconfig
      freetype
      gcc
      unzip
      nettools

      glib
      bzip2
      dbus
      dbus-glib
      file
      gnum4
      icu
      icu72
      libGL
      libGLU
      libevent
      libffi
      libjpeg
      libpng
      libvpx
      libwebp
      nasm
      nspr
      zip
      zlib
      nss_latest
      pango
      atk
      cairo
      gdk-pixbuf
    ]);
    multiPkgs = pkgs: with pkgs; [
      gdk-pixbuf
      cairo
      atk
      gtk3
      pango
      alsa-lib
      libjack2
      libkrb5
      jemalloc
      libxcrypt
      coreutils
      ncurses5
      zlib
      glibc.dev
    ];

    # Firefox detaches from parent,
    # if true, it would kill firefox
    # right away.
    dieWithParent = false;

    runScript = "${firefoxpwa-unwrapped}/bin/firefoxpwa";
}

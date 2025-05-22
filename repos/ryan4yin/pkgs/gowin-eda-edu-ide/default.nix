{
  lib,
  buildFHSEnv,
  freetype,
  xkeyboard_config,
  callPackage,
}: let
  gowin-ide = callPackage ./gowin-ide.nix {};
in
  buildFHSEnv {
    name = "gowin-env";
    targetPkgs = pkgs:
    # ldd /nix/store/*gowin-version/bin/gw_ide
      with pkgs; [
        gowin-ide
        # runtime dependencies
        libGL
        fontconfig
        libxcrypt-legacy
        zlib
        libuuid
        libpulseaudio
        glib
        dbus
        libusb1

        nss
        nspr
        expat
        krb5
        xorg.libXcomposite
        xorg.libXdamage
        xorg.libXfixes
        xorg.libXtst

        udev
        alsa-lib
        vulkan-loader
        xorg.libX11
        xorg.libXcursor
        xorg.libXi
        xorg.libXrandr # To use the x11 feature
        libxkbcommon
        wayland # To use the wayland feature
        libsForQt5.qt5.qtwayland
        libsForQt5.qt5.qtbase
      ];
    profile = ''
      export LD_PRELOAD="${lib.getLib freetype}/lib/libfreetype.so"
      export QT_XKB_CONFIG_ROOT="${xkeyboard_config}/etc/X11/xkb"
      export FHS=1

      gw_ide
    '';
  }

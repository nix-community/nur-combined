{
  lib,
  aliasmode-unwrapped,
  buildFHSEnv,
  glib-networking,
}:
buildFHSEnv {
  pname = "aliasmode";
  inherit (aliasmode-unwrapped) version;

  targetPkgs =
    pkgs: with pkgs; [
      aliasmode-unwrapped
      glibc
      stdenv.cc.cc.lib
      webkitgtk_4_1
      glib-networking
      glib
      udev
      gtk3
      nss
      nspr
      alsa-lib
      libdrm
      mesa
      libGL
      libva
      libgbm
      libxkbcommon
      libX11
      libXcomposite
      libXcursor
      libXi
      libXrender
      libXdamage
      libXext
      libXfixes
      libXrandr
      libxcb
      libxshmfence
      at-spi2-atk
      cups
      dbus
      pango
      cairo
      gdk-pixbuf
      expat
      curl
      unzip
      gnutar
      zstd
      pciutils
      procps
      fontconfig
      freetype
      liberation_ttf
    ];
  profile = ''
    export GIO_EXTRA_MODULES=${glib-networking}/lib/gio/modules
  '';
  runScript = lib.getExe aliasmode-unwrapped;
  extraInstallCommands = ''
    mkdir -p $out/share
    ln -s ${aliasmode-unwrapped}/share/applications $out/share/applications
    ln -s ${aliasmode-unwrapped}/share/icons $out/share/icons
  '';
  passthru.unwrapped = aliasmode-unwrapped;
  meta = aliasmode-unwrapped.meta // {
    mainProgram = "aliasmode";
  };
}

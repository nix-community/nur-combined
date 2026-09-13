{
  alsa-lib,
  at-spi2-atk,
  buildFHSEnv,
  cairo,
  callPackage,
  dbus,
  dpkg,
  fontconfig,
  gdk-pixbuf,
  glib,
  glib-networking,
  gtk3,
  lib,
  libappindicator-gtk3,
  libdrm,
  libepoxy,
  libgbm,
  libGL,
  libice,
  libnotify,
  libpulseaudio,
  libsm,
  libva,
  libx11,
  libxcb,
  libxcursor,
  libxcrypt-legacy,
  libxext,
  libxfixes,
  libxi,
  libxinerama,
  libxkbcommon,
  libxrandr,
  libxrender,
  libxtst,
  libxxf86vm,
  makeDesktopItem,
  pango,
  pcsclite,
  pipewire,
  procps,
  source ? callPackage ./source.nix { },
  stdenvNoCC,
  systemd,
  uiScale ? null,
  util-linux,
  vulkan-loader,
  wayland,
  webkitgtk_4_1,
  writeShellScript,
  xdg-utils,
  xrandr,
  zenity,
  zlib,
}:

assert lib.assertMsg (
  uiScale == null || (builtins.isInt uiScale && uiScale > 0)
) "sunloginclient: uiScale must be null or a positive integer";

let
  unwrapped = stdenvNoCC.mkDerivation {
    pname = "sunloginclient-unwrapped";
    inherit (source) version src;
    strictDeps = true;
    dontBuild = true;
    dontFixup = true;
    nativeBuildInputs = [ dpkg ];

    unpackPhase = ''
      runHook preUnpack
      dpkg-deb -x "$src" .
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/libexec"
      cp -a usr/local/awesun "$out/libexec/"
      install -Dm444 usr/local/awesun/awesun.png \
        "$out/share/icons/hicolor/128x128/apps/awesun.png"
      runHook postInstall
    '';
  };

  desktopItem = makeDesktopItem {
    name = "awesun";
    desktopName = "Sunlogin";
    comment = "Sunlogin remote control";
    exec = "sunloginclient";
    icon = "awesun";
    categories = [
      "Network"
      "RemoteAccess"
    ];
    extraConfig."Name[zh_CN]" = "向日葵远程控制";
  };
in
buildFHSEnv {
  pname = "sunloginclient";
  inherit (source) version;
  multiArch = false;

  targetPkgs = _pkgs: [
    alsa-lib
    at-spi2-atk
    cairo
    dbus
    fontconfig
    gdk-pixbuf
    glib
    gtk3
    libappindicator-gtk3
    libdrm
    libepoxy
    libgbm
    libGL
    libice
    libnotify
    libpulseaudio
    libsm
    libva
    libx11
    libxcb
    libxcursor
    libxcrypt-legacy
    libxext
    libxfixes
    libxi
    libxinerama
    libxkbcommon
    libxrandr
    libxrender
    libxtst
    libxxf86vm
    pango
    pcsclite
    pipewire
    procps
    systemd
    util-linux
    vulkan-loader
    wayland
    webkitgtk_4_1
    xdg-utils
    xrandr
    zenity
    zlib
  ];

  # The daemon and its helpers use this path internally.
  extraBuildCommands = ''
    mkdir -p "$out/usr/local"
    ln -s ${unwrapped}/libexec/awesun "$out/usr/local/awesun"
    # Keep the application's autostart writer inside the read-only FHS root.
    mkdir -p "$out/etc/xdg/autostart"
    # Let buildFHSEnv forward the host's PAM rules for the daemon's runuser.
    rm -rf "$out/etc/pam.d"
  '';

  extraBwrapArgs = [
    "--bind-try /var/lib/sunloginclient/orayconfig.conf /etc/orayconfig.conf"
    "--bind-try /var/lib/sunloginclient/sys_config.conf /etc/sys_config.conf"
    # The system service has no DISPLAY from which to infer an X11 socket.
    "--bind-try /tmp/.X11-unix /tmp/.X11-unix"
  ];

  runScript = writeShellScript "sunloginclient-start" ''
    if [ "''${1-}" = --service ]; then
      shift
      exec /usr/local/awesun/bin/awesun_daemon -m server -name awesun "$@"
    fi
    # WebKit loads its HTTPS backend through GIO modules.
    export GIO_EXTRA_MODULES="${glib-networking}/lib/gio/modules''${GIO_EXTRA_MODULES:+:$GIO_EXTRA_MODULES}"
    ${lib.optionalString (uiScale != null) ''
      export GDK_SCALE=${toString uiScale}
    ''}
    exec /usr/local/awesun/awesun "$@"
  '';

  extraInstallCommands = ''
    mkdir -p "$out/share"
    ln -s "${desktopItem}/share/applications" "$out/share/applications"
    ln -s "${unwrapped}/share/icons" "$out/share/icons"
  '';

  meta = {
    description = "Sunlogin remote control desktop client (AweSun)";
    homepage = "https://sunlogin.oray.com/download/linux";
    license = lib.licenses.unfree;
    mainProgram = "sunloginclient";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}

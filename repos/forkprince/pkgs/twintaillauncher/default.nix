# NOTE: I do not want to talk about this package. It is a mess.
# FIXME: This package is broken on NixOS 25.11 so use unstable or wait for 26.05
{
  gsettings-desktop-schemas,
  libayatana-appindicator,
  libappindicator-gtk3,
  autoPatchelfHook,
  webkitgtk_4_1,
  buildFHSEnv,
  gdk-pixbuf,
  gamemode,
  fetchurl,
  mangohud,
  stdenv,
  cairo,
  pango,
  dpkg,
  glib,
  gtk3,
  lib,
  # Game compatibility
  mesa,
  libglvnd,
  libdrm,
  openssl,
  SDL2,
  wayland,
  libxkbcommon,
  alsa-lib,
  libpulseaudio,
  vulkan-loader,
  nss,
  cups,
  fontconfig,
  freetype,
  udev,
  dbus,
  zlib,
  # X11 libraries
  libx11,
  libxcursor,
  libxrandr,
  libxext,
  libxi,
  libxinerama,
  libxxf86vm,
  libxrender,
  libxfixes,
  libxcomposite,
  libxdamage,
  # WebKitGTK networking (required for CDN image loading)
  glib-networking,
}:
let
  ver = lib.helper.read ./version.json;
  platform = stdenv.hostPlatform.system;
  pname = "twintaillauncher";

  unwrapped = stdenv.mkDerivation {
    pname = "${pname}-unwrapped";
    inherit (ver) version;

    src = fetchurl (lib.helper.getPlatform platform ver);

    nativeBuildInputs = [
      autoPatchelfHook
      dpkg
    ];

    buildInputs = [
      gsettings-desktop-schemas
      libayatana-appindicator
      libappindicator-gtk3
      webkitgtk_4_1
      gdk-pixbuf
      mangohud
      gamemode
      cairo
      pango
      glib
      gtk3
    ];

    dontBuild = true;
    dontStrip = true;

    unpackPhase = ''
      runHook preUnpack

      dpkg-deb -x $src .

      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin

      cp -r usr/* $out/

      chmod +x \
        $out/bin/twintaillauncher \
        $out/lib/twintaillauncher/resources/reaper \
        $out/lib/twintaillauncher/resources/winetricks

      runHook postInstall
    '';

    meta = {
      description = "A multi-platform launcher for your anime games";
      homepage = "https://github.com/TwintailTeam/TwintailLauncher";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.gpl3Only;
      platforms = lib.platforms.linux;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      mainProgram = "twintaillauncher";
    };
  };
in
buildFHSEnv {
  name = pname;
  inherit (ver) version;

  targetPkgs = pkgs: [
    unwrapped
    # Launcher dependencies
    gsettings-desktop-schemas
    libayatana-appindicator
    libappindicator-gtk3
    webkitgtk_4_1
    gdk-pixbuf
    cairo
    pango
    glib
    gtk3
    nss
    # WebKitGTK networking (required for image loading from CDNs)
    glib-networking
    # Game runtime dependencies
    mangohud
    gamemode
    # Graphics libraries
    mesa
    libglvnd
    libdrm
    vulkan-loader
    # Core system libraries
    openssl
    zlib
    fontconfig
    freetype
    udev
    dbus
    cups
    # SDL and input
    SDL2
    libx11
    libxcursor
    libxrandr
    libxext
    libxi
    libxinerama
    libxxf86vm
    libxrender
    libxfixes
    libxcomposite
    libxdamage
    # Wayland support
    wayland
    libxkbcommon
    # Audio
    alsa-lib
    libpulseaudio
  ];

  profile = ''
    export WEBKIT_DISABLE_DMABUF_RENDERER=1
    export __NV_DISABLE_EXPLICIT_SYNC=1
    export XDG_DATA_DIRS="${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:$XDG_DATA_DIRS"
    export GIO_EXTRA_MODULES="${glib.out}/lib/gio/modules"
    # GLib networking modules for WebKit TLS/SSL support (required for CDN image loading)
    export GIO_MODULE_DIR="${glib-networking}/lib/gio/modules"
  '';

  runScript = "${unwrapped}/bin/twintaillauncher";

  extraInstallCommands = ''
    mkdir -p "$out/share/applications"
    ln -s "${unwrapped}/share/applications/twintaillauncher.desktop" "$out/share/applications/"

    # Copy icons if they exist
    if [ -d "${unwrapped}/share/icons" ]; then
      mkdir -p "$out/share/icons"
      cp -r "${unwrapped}/share/icons"/* "$out/share/icons/" || true
    fi
    if [ -d "${unwrapped}/share/pixmaps" ]; then
      mkdir -p "$out/share/pixmaps"
      cp -r "${unwrapped}/share/pixmaps"/* "$out/share/pixmaps/" || true
    fi
  '';

  inherit (unwrapped) meta;
}

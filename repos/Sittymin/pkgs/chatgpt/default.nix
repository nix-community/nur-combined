{
  fetchurl,
  stdenv,
  lib,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  # Runtime dependencies
  alsa-lib,
  atk,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  libX11,
  libXcomposite,
  libXcursor,
  libXdamage,
  libXext,
  libXfixes,
  libXi,
  libXrandr,
  libXrender,
  libXtst,
  libgbm,
  libglvnd,
  nspr,
  nss,
  pango,
  libdrm,
  libxkbcommon,
  libxcb,
  libxshmfence,
  wayland,
  udev,
  libnotify,
  libappindicator-gtk3,
  pipewire,
  libpulseaudio,
  qt5,
  qt6,
  libusb1,
  libxscrnsaver,
}:
let
  version = "26.831.21537";

  libPath = lib.makeLibraryPath [
    alsa-lib
    atk
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libX11
    libXcomposite
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXi
    libXrandr
    libXrender
    libXtst
    libxscrnsaver
    libgbm
    libglvnd
    nspr
    nss
    pango
    libdrm
    libxkbcommon
    libxcb
    libxshmfence
    wayland
    udev
    libnotify
    libappindicator-gtk3
    pipewire
    libpulseaudio
    qt5.qtbase
    qt6.qtbase
    libusb1
    stdenv.cc.cc.lib
  ];
in
stdenv.mkDerivation {
  pname = "chatgpt";
  inherit version;

  src = fetchurl {
    url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest/chatgpt_amd64.deb";
    hash = "sha256-XBVu8qLgKRWW0HuuhmDvTwt0jfO6+Rv8ko97XjxhCxE=";
  };

  dontBuild = true;
  dontConfigure = true;
  dontFixup = true;

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
    copyDesktopItems
  ];

  autoPatchelfIgnoreMissingDeps = [
    "libc.musl-x86_64.so.1"
  ];

  unpackPhase = ''
    dpkg -x $src .
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/lib/chatgpt
    mkdir -p $out/share/icons

    cp -r usr/lib/chatgpt/* $out/lib/chatgpt/

    install -Dm644 usr/lib/chatgpt/resources/icon-chatgpt.png \
      $out/share/icons/hicolor/512x512/apps/chatgpt.png

    makeWrapper $out/lib/chatgpt/ChatGPT $out/bin/chatgpt \
      --prefix LD_LIBRARY_PATH : "${libPath}" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "chatgpt";
      desktopName = "ChatGPT";
      exec = "chatgpt %U";
      terminal = false;
      icon = "chatgpt";
      startupWMClass = "chatgpt";
      comment = "ChatGPT by OpenAI";
      mimeTypes = [
        "x-scheme-handler/codex"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
        "text/csv"
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        "application/vnd.openxmlformats-officedocument.presentationml.presentation"
        "text/tab-separated-values"
        "application/vnd.ms-excel"
        "application/vnd.ms-excel.sheet.macroEnabled.12"
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      ];
      categories = [
        "Utility"
        "Development"
      ];
    })
  ];

  meta = {
    description = "ChatGPT by OpenAI";
    homepage = "https://developers.openai.com/codex/app";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "chatgpt";
  };
}

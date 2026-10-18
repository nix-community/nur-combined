{ lib
, stdenv
, fetchurl
, makeDesktopItem
, makeWrapper
, autoPatchelfHook
, nix-update-script
, patchelfUnstable
, zstd
, alsa-lib
, cairo
, dbus
, fontconfig
, freetype
, glib
, gtk3
, libdrm
, libglvnd
, libpulseaudio
, libva
, libvdpau
, libx11
, libxcb
, libxcomposite
, libxcursor
, libxdamage
, libxext
, libxfixes
, libxi
, libxinerama
, libxkbcommon
, libxrandr
, libxrender
, libxtst
, mesa
, pango
, pipewire
, systemd
, wayland
, xcbutilkeysyms
, xkeyboard-config
}:

let
  pname = "materialgram";
  version = "7.3.1.1";

  desktopItem = makeDesktopItem {
    name = pname;
    exec = "${pname} -- %U";
    icon = pname;
    desktopName = "materialgram";
    comment = "Unofficial Telegram Desktop with Material Design";
    categories = [ "Chat" "Network" "InstantMessaging" "Qt" ];
    startupNotify = true;
    startupWMClass = "materialgram";
    mimeTypes = [ "x-scheme-handler/tg" "x-scheme-handler/tonsite" ];
  };
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/kukuruzka165/materialgram/releases/download/v${version}/materialgram-v${version}.tar.zst";
    hash = "sha256-UOC9bI5CPY1PK7mftFQWLKW21azrD6EkAEn03DPdNAU=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    patchelfUnstable
    zstd
  ];

  buildInputs = [
    alsa-lib
    cairo
    dbus
    fontconfig
    freetype
    glib
    libpulseaudio
    pango
    pipewire
    stdenv.cc.cc.lib
  ];

  runtimeDependencies = [
    gtk3
    libdrm
    libglvnd
    libva
    libvdpau
    libx11
    libxcb
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxinerama
    libxkbcommon
    libxrandr
    libxrender
    libxtst
    mesa
    systemd
    wayland
    xcbutilkeysyms
  ];

  sourceRoot = "usr";

  dontConfigure = true;
  dontBuild = true;
  dontPatchELF = true;

  preInstall = ''
    export PATH=${lib.makeBinPath [ patchelfUnstable ]}:$PATH
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/materialgram
    cp -r . $out/opt/materialgram/

    makeWrapper $out/opt/materialgram/bin/${pname} $out/bin/${pname} \
      --set-default XKB_CONFIG_ROOT ${xkeyboard-config}/share/X11/xkb \
      --set-default QT_XKB_CONFIG_ROOT ${xkeyboard-config}/share/X11/xkb

    install -m 444 -D ${desktopItem}/share/applications/${pname}.desktop \
      $out/share/applications/${pname}.desktop

    install -m 444 -D $out/opt/materialgram/share/icons/hicolor/512x512/apps/io.github.kukuruzka165.materialgram.png \
      $out/share/icons/hicolor/512x512/apps/${pname}.png

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Telegram Desktop fork with material icons and some improvements";
    homepage = "https://github.com/kukuruzka165/materialgram";
    license = licenses.gpl3Only;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
  };
}

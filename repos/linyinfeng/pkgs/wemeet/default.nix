{ sources
, lib
, autoPatchelfHook
, stdenv
, libsForQt5
, makeWrapper
, dpkg
, makeDesktopItem
, xlibs
, wayland
, gmpxx
, glib
, harfbuzz
, libglvnd
, p11-kit
, fontconfig
, libpulseaudio
, e2fsprogs
, mtdev
, alsaLib
, xkeyboard_config
}:

let
  desktopItem = makeDesktopItem {
    name = "wemeetapp";
    desktopName = "Wemeet App";
    exec = "wemeetapp %u";
    icon = "wemeetapp";
    categories = "AudioVideo";
    mimeType = "x-scheme-handler/wemeet";
  };
in
stdenv.mkDerivation rec {
  inherit (sources.wemeet) pname version src;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    dpkg
  ];

  unpackPhase = ''
    dpkg -x "$src" .
  '';

  buildInputs = [
    wayland
    gmpxx
    glib
    harfbuzz
    libglvnd
    p11-kit
    fontconfig
    libpulseaudio
    e2fsprogs
    mtdev
    alsaLib
  ] ++ (with xlibs; [
    libSM
    libX11
  ]) ++ (with libsForQt5; [
    fcitx-qt5
  ]);

  autoPatchelfIgnoreMissingDeps = "true"; # TODO: remove this

  installPhase = ''
    mkdir -p "$out"
    cp -r opt "$out/opt"

    mkdir -p "$out/bin"
    # 1. workaround for error:
    #   xkbcommon: ERROR: failed to add default include path /usr/share/X11/xkb
    #   manually set QT_XKB_CONFIG_ROOT
    # 2. wayland workaround
    #   set XDG_SESSION_TYPE, QT_QPA_PLATFORM, and unset WAYLAND_DISPLAY
    makeWrapper "$out/opt/wemeet/bin/wemeetapp" "$out/bin/wemeetapp" \
      --suffix QT_XKB_CONFIG_ROOT ":" "${xkeyboard_config}/share/X11/xkb" \
      --set XDG_SESSION_TYPE x11 \
      --set QT_QPA_PLATFORM xcb \
      --unset WAYLAND_DISPLAY

    mkdir -p "$out/share/applications"
    install "${desktopItem}/share/applications/"* "$out/share/applications/"

    mkdir -p "$out/share"
    cp -r opt/wemeet/icons "$out/share"
  '';

  meta = with lib; {
    homepage = https://meeting.tencent.com;
    description = "Tencent Video Conferencing, tencent meeting";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}

{ sources
, lib
, autoPatchelfHook
, stdenv
, dpkg
, makeDesktopItem
, rsync
, fd
, qt5
}:

let
  desktopItem = makeDesktopItem
    {
      name = "wemeetapp";
      desktopName = "Wemeet App";
      exec = "wemeetapp %u";
      icon = "wemeetapp";
      categories = [ "AudioVideo" ];
    } //
  (if with lib; (versionAtLeast (versions.majorMinor trivial.version) "22.05")
  then {
    mimeTypes = [ "x-scheme-handler/wemeet" ];
  } else {
    mimeType = "x-scheme-handler/wemeet";
  });
in
qt5.mkDerivation rec {
  inherit (sources.wemeet) pname version src;

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    rsync
    fd
  ];

  unpackPhase = ''
    dpkg -x "$src" .
  '';

  buildInputs = with qt5; [
    qtwebkit
    qtwebengine
    qtx11extras
  ];

  installPhase = ''
    mkdir -p "$out"
    # use system libraries instead
    # https://github.com/NickCao/flakes/blob/ca564395aad0f2cdd45649a3769d7084a8a4fb18/pkgs/wemeet/default.nix
    rsync -rv opt/ "$out/" \
      --include "wemeet/lib/libwemeet*" \
      --include "wemeet/lib/libxnn*" \
      --include "wemeet/lib/libxcast*" \
      --include "wemeet/lib/libImSDK.so" \
      --include "wemeet/lib/libui_framework.so" \
      --include "wemeet/lib/libnxui*" \
      --include "wemeet/lib/libdesktop_common.so" \
      --include "wemeet/lib/libqt_*" \
      --exclude "wemeet/lib/*" \
      --exclude "wemeet/plugins" \
      --exclude "wemeet/icons" \
      --exclude "wemeet/wemeetapp.sh" \
      --exclude "wemeet/bin/Qt*"

    mkdir -p "$out/bin"
    # TODO remove IBus and Qt style workaround
    # https://aur.archlinux.org/cgit/aur.git/commit/?h=wemeet-bin&id=32fc5d3ba55649cb1143c2b8881ba806ee14b87b
    makeQtWrapper "$out/wemeet/bin/wemeetapp" "$out/bin/wemeetapp" \
      --set-default IBUS_USE_PORTAL 1 \
      --set-default QT_STYLE_OVERRIDE fusion
    makeWrapper "$out/bin/wemeetapp" "$out/bin/wemeetapp-force-x11" \
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

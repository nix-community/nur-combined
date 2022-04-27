{ sources
, lib
, autoPatchelfHook
, stdenv
, dpkg
, makeDesktopItem
, rsync
, xkeyboard_config
, qt5
, xorg
, libbsd
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
  ];

  unpackPhase = ''
    dpkg -x "$src" .
  '';

  buildInputs = [
    libbsd
  ] ++ (with qt5; [
    qtwebkit
    qtx11extras
  ]) ++ (with xorg; [
    libXrandr
    libXdamage
    libXinerama
  ]);

  autoPatchelfIgnoreMissingDeps = [
    "libcudart.so.9.0"
    "libcudnn.so.7"
    "libnvinfer.so.5"
    "libnvinfer_plugin.so.5"
  ];

  installPhase = ''
    mkdir -p "$out"
    # use system libraries instead
    # https://github.com/NickCao/flakes/blob/ca564395aad0f2cdd45649a3769d7084a8a4fb18/pkgs/wemeet/default.nix
    rsync -rv opt/ "$out/" \
      --include "wemeet/lib/libwemeet*" \
      --include "wemeet/lib/libxnn*" \
      --include "wemeet/lib/libxcast.so" \
      --include "wemeet/lib/libtquic.so" \
      --exclude "wemeet/lib/*" \
      --exclude "wemeet/plugins" \
      --exclude "wemeet/icons" \
      --exclude "wemeet/wemeetapp.sh"

    mkdir -p "$out/bin"
    # wayland workaround: set XDG_SESSION_TYPE, and unset WAYLAND_DISPLAY
    makeQtWrapper "$out/wemeet/bin/wemeetapp" "$out/bin/wemeetapp" \
      --set XDG_SESSION_TYPE x11 \
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

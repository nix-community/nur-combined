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
      --include "wemeet/lib/libdesktop_common.so" \
      --exclude "wemeet/lib/*" \
      --exclude "wemeet/plugins" \
      --exclude "wemeet/icons" \
      --exclude "wemeet/wemeetapp.sh" \
      --exclude "wemeet/bin/Qt*"

    # fix symbol issue
    # TODO remove this workaround
    libraries=($(fd '^.*\.so(\.\d+)?$' "$out"))
    patchelf \
      --clear-symbol-version "_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_assignERKS4_" \
      --clear-symbol-version "_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE10_M_replaceEmmPKcm" \
      "''${libraries[@]}" "$out/wemeet/bin/"{wemeetapp,crashpad_handler}

    mkdir -p "$out/bin"
    makeQtWrapper "$out/wemeet/bin/wemeetapp" "$out/bin/wemeetapp"

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

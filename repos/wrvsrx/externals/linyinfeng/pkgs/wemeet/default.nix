{
  callPackage,
  system,
  fetchurl,
  lib,
  autoPatchelfHook,
  dpkg,
  makeDesktopItem,
  rsync,
  fd,
  qt5,
  libyuv,
  libjpeg8,
}:

let
  sourceInfo = builtins.fromJSON (lib.readFile ./source.json);
  desktopItem = makeDesktopItem {
    name = "wemeetapp";
    desktopName = "Wemeet";
    exec = "wemeetapp %u";
    icon = "wemeetapp";
    categories = [ "AudioVideo" ];
    mimeTypes = [ "x-scheme-handler/wemeet" ];
    extraConfig = {
      "Name[zh_CN]" = "腾讯会议";
    };
  };
  desktopItemForceX11 = desktopItem.override {
    name = "wemeetapp-force-x11";
    desktopName = "Wemeet (X)";
    exec = "wemeetapp-force-x11 %u";
    extraConfig = {
      "Name[zh_CN]" = "腾讯会议 (X)";
    };
  };
in
qt5.mkDerivation {
  pname = "wemeet";
  inherit (sourceInfo.${system}) version;
  src = fetchurl { inherit (sourceInfo.${system}) url sha512; };

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
    qtwebengine
    qtx11extras
    libyuv
    libjpeg8
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
      --include "wemeet/lib/libservice_manager.so" \
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
    install "${desktopItem}/share/applications/"*         "$out/share/applications/"
    ${
      with lib;
      if versionAtLeast (versions.majorMinor trivial.version) "22.11" then
        ''install "${desktopItemForceX11}/share/applications/"* "$out/share/applications/"''
      else
        ""
    }

    mkdir -p "$out/share"
    if [ -d opt/wemeet/icons ]; then
      cp -r opt/wemeet/icons "$out/share"
    else
      echo "directory 'opt/wemeet/icons' not found"
    fi
  '';

  passthru = {
    # TODO fix 3.19.1.400
    updateScriptEnabled = false;
    updateScript =
      let
        script = callPackage ./update.nix { };
      in
      [ "${script}/bin/update-wemeet" ];
  };

  meta = with lib; {
    homepage = "https://meeting.tencent.com";
    description = "Tencent Video Conferencing, tencent meeting";
    license = licenses.unfree;
    platforms = lib.attrNames sourceInfo;
    maintainers = with maintainers; [ yinfeng ];
  };
}
